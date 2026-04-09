#!/usr/bin/env bash

# Strict mode: Exit on error, undefined vars, or pipe failures
set -euo pipefail

sudo -v
trap 'sudo -k' EXIT

cd "${HOME}/Documents/Configs"

IMAGE="localhost/henry-os"
LATEST="${IMAGE}:latest"
PREVIOUS="${IMAGE}:previous"

# 1. Silently capture pre-build state using digests
OLD_LATEST=$(sudo podman image inspect -f '{{.Digest}}' "${LATEST}" 2>/dev/null || true)
OLD_PREVIOUS=$(sudo podman image inspect -f '{{.Digest}}' "${PREVIOUS}" 2>/dev/null || true)

echo "=== 1. Building Image ==="
sudo podman build --pull=newer -t "${LATEST}" .

NEW_LATEST=$(sudo podman image inspect -f '{{.Digest}}' "${LATEST}" 2>/dev/null || true)
UNSEATED=""

echo "=== 2. Managing Tags ==="
if [ -n "${OLD_LATEST}" ] && [ "${OLD_LATEST}" != "${NEW_LATEST}" ]; then
    echo "-> Changes built. Tagging old :latest as :previous..."
    sudo podman tag "${OLD_LATEST}" "${PREVIOUS}"
    UNSEATED="${OLD_PREVIOUS}"
else
    echo "-> No changes detected. Tags remain unchanged."
fi

echo -e "\n=== 3. Staging bootc Update ==="
sudo bootc update

echo -e "\n=== 4. Cleaning Up ==="
# If we unseated an image, and it's not somehow identical to the old latest, process it
if [ -n "${UNSEATED}" ] && [ "${UNSEATED}" != "${OLD_LATEST}" ]; then
    DIGEST="${UNSEATED#sha256:}"

    # Check if bootc status still references this exact string
    if ! sudo bootc status | grep -qF "${DIGEST}"; then
        echo "-> Unseated image (${DIGEST:0:12}...) is detached from bootc. Removing..."
        sudo podman rmi -f "${UNSEATED}" 2>/dev/null || echo "   Image already pruned."
    else
        echo "-> Unseated image is still pinned by bootc (Rollback). Preserving."
    fi
fi

echo -e "\n=== Done! Reboot at your leisure. ==="
