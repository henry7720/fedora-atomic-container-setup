#!/usr/bin/env bash
#---------------------------------------------------------------------#
# Author     : henry7720
# Script Name: rebuild-system-bootc.sh
# Description: Checks for remote updates of a Podman container image.
#
# SPDX-License-Identifier: AGPL-3.0-only
#---------------------------------------------------------------------#

# Strict mode: Exit on error, undefined vars, or pipe failures
set -euo pipefail

#---------------------------------- Variables
export IMAGE="localhost/my-kinoite-image-name"
export LATEST="${IMAGE}:latest"
export PREVIOUS="${IMAGE}:previous"

# Set the absolute path to your bootc Containerfile project directory.
# This directory should contain the Containerfile and related build files.
# Example: /var/home/slackjeff/fedora-atomic-container-setup
export CONTAINERFILE_PATH="/My/Path/Containerfile"

# Colors
fRed="\e[31;1m"
fGreen="\e[32;1m"
fYellow="\e[33;1m"
fBlue="\e[34;1m"
fEnd="\e[m"

#---------------------------------- Functions
function msg_steps()
{
	local msg="$@"
	
	echo -e "\n${fGreen}$msg${fEnd}"
}

#---------------------------------- Start Here

sudo -v
trap 'sudo -k' EXIT
cd "$CONTAINERFILE_PATH"

#---- Step 1
msg_steps "=== Step 1: Building Container Image ==="

# 1. Capture state (Assume current :previous will be unseated)
OLD_LATEST=$(sudo podman image inspect -f '{{.Id}}' "${LATEST}" 2>/dev/null || true)
UNSEATED_ID=$(sudo podman image inspect -f '{{.Id}}' "${PREVIOUS}" 2>/dev/null || true)
UNSEATED_DIG=$(sudo podman image inspect -f '{{.Digest}}' "${PREVIOUS}" 2>/dev/null || true)

sudo podman build --pull=newer -t "${LATEST}" .

#---- Step 2
msg_steps "=== Step 2: Managing Image Tags ==="
NEW_LATEST=$(sudo podman image inspect -f '{{.Id}}' "${LATEST}" 2>/dev/null || true)

if [ -n "${OLD_LATEST}" ] && [ "${OLD_LATEST}" != "${NEW_LATEST}" ]; then
    echo "-> Changes built. Tagging old :latest as :previous..."
    sudo podman tag "${OLD_LATEST}" "${PREVIOUS}"
else
    echo "-> No changes detected. Tags remain unchanged."
    UNSEATED_ID="" # Cancel cleanup since no rotation happened
fi

#---- Step 3
msg_steps "=== Step 3: Staging bootc Update ==="
sudo bootc update

#---- Step 4
msg_steps "=== Step 4: Cleaning Up Local Resources ==="
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

#---- Finished
msg_steps "->Cleaning up old images "
sudo podman image prune -f

echo -e "${fGreen}Done!${fEnd} If a bootc update was applied, you can reboot whenever you're ready."
