#!/usr/bin/env bash

# Exit immediately if any command fails
set -e

sudo -v

trap 'sudo -k' EXIT

# Navigate to your project directory
cd ${HOME}/Documents/Configs

# synchronize this with your image name
IMAGE="localhost/my-kinoite-image-name"
LATEST="${IMAGE}:latest"
PREVIOUS="${IMAGE}:previous"

echo "=== 1. Capturing Current State ==="
# Get the unique Image ID of the current latest (returns empty if none exists)
OLD_ID=$(sudo podman images -q "${LATEST}")

if [ -n "$OLD_ID" ]; then
    echo "Current ${LATEST} ID: ${OLD_ID}"
else
    echo "No existing ${LATEST} found."
fi

echo -e "\n=== 2. Building Image (Pulling if Needed) ==="
sudo podman build --pull=newer -t "${LATEST}" .

echo -e "\n=== 3. Managing Tag Rotation ==="
# Get the Image ID of latest after the build
NEW_ID=$(sudo podman images -q "${LATEST}")

if [ -n "$OLD_ID" ]; then
    if [ "$OLD_ID" != "$NEW_ID" ]; then
        echo "Changes detected! Tagging the old image as ${PREVIOUS}..."
        # Tag the specific old ID so it isn't lost
        sudo podman tag "${OLD_ID}" "${PREVIOUS}"
    else
        echo "No changes in build. Preserving your existing ${PREVIOUS}."
    fi
fi

echo -e "\n=== 4. Cleaning Up Leaf Images ==="
sudo podman image prune -f

echo -e "\n=== 5. Staging Update with bootc ==="
sudo bootc update

echo -e "\n=== If update applied, reboot at your leisure! ==="
