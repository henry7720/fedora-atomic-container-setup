# Start from the official Fedora 44 Kinoite OCI image
FROM quay.io/fedora/fedora-kinoite:44

# Add repos here before install
# RUN tee ...repo contents here to go into repo file.... / 'dnf config-manager add repo' commands

# Since we're using bootc, we use standard dnf commands, you can just install and also swap toolbox for distrobox, etc.
# Use -y for all dnf commands as it can't be interactive
# I recommend following my template in Container-custom-example -- one RUN block for removals, one block for hardware drivers and codecs (RPMFusion etc.) and one for your GUI apps/extra CLI tools
# We set a cache directory to map to the repo result cache dir so we can build faster and also spare some container size
# The second dnf install setup expresses how to string together another dnf command with special options - this can be removed by removing the && and all that follows after it in that RUN block
RUN --mount=type=cache,target=/var/cache/libdnf5 \
    dnf -y install \
    package-here && \
    dnf -y install --special-options \
    package-here

# Custom services enable/disable or none at all can go here as Fedora default-enables most. Stringing together with && is a good idea.
# RUN systemctl enable non-default.service

# Here you can run any image-layer-level /etc overrides. Useful if you don't want to have to think about these or have a specific need.
# In general, not stroct;y necessary , but YMMV. You can always do these configs manually.
# RUN echo "some-content" > /etc/some-default-os-config

# Important: Label the image as bootc-compatible
LABEL containers.bootc=1
