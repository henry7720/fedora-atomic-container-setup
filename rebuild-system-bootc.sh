#!/usr/bin/env bash

# Strict mode: Exit on error, undefined vars, or pipe failures
set -euo pipefail

sudo -v
trap 'sudo -k' EXIT

cd "${HOME}/Your/Dir/Here"

IMAGE="localhost/henry-os"
LATEST="${IMAGE}:latest"
PREVIOUS="${IMAGE}:previous"

# 1. Capture IDs for Podman operations, and Digest specifically for bootc
OLD_LATEST_ID=$(sudo podman image inspect -f '{{.Id}}' "${LATEST}" 2>/dev/null || true)

OLD_PREVIOUS_ID=$(sudo podman image inspect -f '{{.Id}}' "${PREVIOUS}" 2>/dev/null || true)
OLD_PREVIOUS_DIGEST=$(sudo podman image inspect -f '{{.Digest}}' "${PREVIOUS}" 2>/dev/null || true)

echo "=== 1. Building Image ==="
sudo podman build --pull=newer -t "${LATEST}" .

NEW_LATEST_ID=$(sudo podman image inspect -f '{{.Id}}' "${LATEST}" 2>/dev/null || true)
UNSEATED_ID=""
UNSEATED_DIGEST=""

echo "=== 2. Managing Tags ==="
if [ -n "${OLD_LATEST_ID}" ] && [ "${OLD_LATEST_ID}" != "${NEW_LATEST_ID}" ]; then
    echo "-> Changes built. Tagging old :latest as :previous..."
    # Podman requires the local ID to tag
    sudo podman tag "${OLD_LATEST_ID}" "${PREVIOUS}"
    
    # Store both the ID and Digest of the image getting bumped out
    UNSEATED_ID="${OLD_PREVIOUS_ID}"
    UNSEATED_DIGEST="${OLD_PREVIOUS_DIGEST}"
else
    echo "-> No changes detected. Tags remain unchanged."
fi

echo -e "\n=== 3. Staging bootc Update ==="
sudo bootc update

echo -e "\n=== 4. Cleaning Up ==="
if [ -n "${UNSEATED_ID}" ] && [ "${UNSEATED_ID}" != "${OLD_LATEST_ID}" ]; then
    
    # Build a search pattern for grep. We check for BOTH the ID and the Digest just to be safe.
    BOOTC_SEARCH="${UNSEATED_ID}"
    if [ -n "${UNSEATED_DIGEST}" ]; then
        BOOTC_SEARCH="${BOOTC_SEARCH}|${UNSEATED_DIGEST#sha256:}"
    fi
    
    # Check if bootc status references either identifier (-E allows extended regex for the OR operator '|')
    if ! sudo bootc status | grep -qE "(${BOOTC_SEARCH})"; then
        echo "-> Unseated image is detached from bootc. Removing..."
        # Podman requires the local ID to remove
        sudo podman rmi -f "${UNSEATED_ID}" 2>/dev/null || echo "   Image already pruned."
    else
        echo "-> Unseated image is still pinned by bootc (Rollback). Preserving."
    fi
fi

echo -e "\n=== Done! Reboot at your leisure. ==="
