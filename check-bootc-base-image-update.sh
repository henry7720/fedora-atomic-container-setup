#!/usr/bin/env bash
#---------------------------------------------------------------------#
# Author     : henry7720
# Script Name: check-podman-update.sh
# Description: Checks for remote updates of a Podman container image.
#
# SPDX-License-Identifier: AGPL-3.0-only
#---------------------------------------------------------------------#

#---------------------------------- Variables
export IMAGE="quay.io/fedora/fedora-kinoite:44"

# Colors
fRed="\e[31;1m"
fGreen="\e[32;1m"
fYellow="\e[33;1m"
fBlue="\e[34;1m"
fEnd="\e[m"

#---------------------------------- Functions
die()
{
	msg="$@"
	echo -e "${fRed}${msg}${fEnd}"
	exit 1
}

#---------------------------------- Start Here

echo -e "${fGreen}Checking:${fEnd} $IMAGE..."
echo "----------------------------------------"

# 1. Ask Podman directly for the architecture
ARCH=$(podman info --format '{{.Host.Arch}}')

# 2. Get remote digest (Universal: handles both multi-arch and single-arch)
REMOTE=$(skopeo inspect --raw docker://$IMAGE | jq -r ".manifests[]? | select(.platform.architecture == \"$ARCH\") | .digest" | grep '^sha256' || skopeo inspect docker://$IMAGE --format '{{.Digest}}' 2>/dev/null)
if [ -z "$REMOTE" ]; then
    die "[X] Error: Could not fetch remote digest. Check the image name or your network."
    exit 1
fi

# 3. Get local digest
LOCAL=$(sudo podman image inspect $IMAGE --format '{{.Digest}}' 2>/dev/null)

if [ -z "$LOCAL" ]; then
    die "[X] Error: Image not found locally.\nRun: sudo podman pull $IMAGE"
fi

# 4. Compare
if [ "$LOCAL" == "$REMOTE" ]; then
    echo -e "${fGreen}[Y] Your local image is up to date.${fEnd}"
else
    echo -e "${fYellow}[Y][!] Update available!${fEnd}\nRun: sudo podman pull $IMAGE"
fi

echo -e "${fBlue}Local:${fEnd}  $LOCAL"
echo -e "${fBlue}Remote:${fEnd} $REMOTE"
echo "----------------------------------------"
