#!/usr/bin/env bash

# Strict mode: Exit on error, undefined vars, or pipe failures
set -euo pipefail

sudo -v
trap 'sudo -k' EXIT

cd "${HOME}/Documents/Configs"

IMAGE="localhost/henry-os"
LATEST="${IMAGE}:latest"
PREVIOUS="${IMAGE}:previous"

# 1. Capture state (Assume current :previous will be unseated)
OLD_LATEST=$(sudo podman image inspect -f '{{.Id}}' "${LATEST}" 2>/dev/null || true)
UNSEATED_ID=$(sudo podman image inspect -f '{{.Id}}' "${PREVIOUS}" 2>/dev/null || true)
UNSEATED_DIG=$(sudo podman image inspect -f '{{.Digest}}' "${PREVIOUS}" 2>/dev/null || true)

echo "=== 1. Building Image ==="
sudo podman build --pull=newer -t "${LATEST}" .

echo "=== 2. Managing Tags ==="
NEW_LATEST=$(sudo podman image inspect -f '{{.Id}}' "${LATEST}" 2>/dev/null || true)

if [ -n "${OLD_LATEST}" ] && [ "${OLD_LATEST}" != "${NEW_LATEST}" ]; then
    echo "-> Changes built. Tagging old :latest as :previous..."
    sudo podman tag "${OLD_LATEST}" "${PREVIOUS}"
else
    echo "-> No changes detected. Tags remain unchanged."
    UNSEATED_ID="" # Cancel cleanup since no rotation happened
fi

echo -e "\n=== 3. Staging bootc Update ==="
sudo bootc update

echo -e "\n=== 4. Cleaning Up ==="
if [ -n "${UNSEATED_ID}" ] && [ "${UNSEATED_ID}" != "${OLD_LATEST}" ]; then

    # Format grep search string: "id_hash|digest_hash"
    SEARCH="${UNSEATED_ID#sha256:}"
    [ -n "${UNSEATED_DIG}" ] && SEARCH="${SEARCH}|${UNSEATED_DIG#sha256:}"

    if ! sudo bootc status | grep -qE "(${SEARCH})"; then
        echo "-> Unseated image is detached from bootc. Removing..."
        sudo podman rmi -f "${UNSEATED_ID}" 2>/dev/null || true
    else
        echo "-> Unseated image is still pinned by bootc (Rollback). Preserving."
    fi
fi

echo -e "\n=== Done! Reboot at your leisure. ==="
