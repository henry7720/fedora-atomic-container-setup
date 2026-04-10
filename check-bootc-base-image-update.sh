#!/usr/bin/env bash

IMAGE="quay.io/fedora/fedora-kinoite:44"
echo "Checking $IMAGE..."
echo "----------------------------------------"

# 1. Ask Podman directly for the architecture
ARCH=$(podman info --format '{{.Host.Arch}}')

# 2. Get remote digest (Universal: handles both multi-arch and single-arch)
REMOTE=$(skopeo inspect --raw docker://$IMAGE | jq -r ".manifests[]? | select(.platform.architecture == \"$ARCH\") | .digest" | grep '^sha256' || skopeo inspect docker://$IMAGE --format '{{.Digest}}' 2>/dev/null)

if [ -z "$REMOTE" ]; then
    echo "[X] Error: Could not fetch remote digest. Check the image name or your network."
    exit 1
fi

# 3. Get local digest
LOCAL=$(sudo podman image inspect $IMAGE --format '{{.Digest}}' 2>/dev/null)

if [ -z "$LOCAL" ]; then
    echo "[X] Error: Image not found locally. Run: sudo podman pull $IMAGE"
    exit 1
fi

echo "Local:  $LOCAL"
echo "Remote: $REMOTE"
echo "----------------------------------------"

# 4. Compare
if [ "$LOCAL" == "$REMOTE" ]; then
    echo "[Y] Your local image is up to date."
else
    echo "[!] Update available! Run: sudo podman pull $IMAGE"
fi
