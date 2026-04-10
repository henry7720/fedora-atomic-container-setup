# Start from the official Fedora 44 Kinoite OCI image
FROM quay.io/fedora/fedora-kinoite:44

# Add repos here before install
# RUN tee ...repo contents here to go into repo file....

# Add your custom package overlays, rpmfusion can also go here
# Since we're using bootc, we use standard dnf commands, you can just install and also swap toolbox for distrobox, etc.
# Use -y for all dnf commands as it can't be interactive

# I recommend following my template in Container-custom-example -- one RUN block for removals with a dnf clean all
# one RUN block for hardware drivers and codecs (RPMFusion etc.) with a dnf clean all, and one RUN block for your GUI apps/extra CLI tools
RUN dnf -y install \
    package-here && \
    dnf clean all -y

# Custom services enable/disable or none at all can go here as Fedora default-enables most. Stringing together with && is a good idea.
# RUN systemctl enable non-default.service

# Here you can run any image-layer-level /etc overrides. Useful if you don't want to have to think about these or have a specific need.
# In general, not usually necessary for most people, but YMMV. You can always do these configs manually.
# RUN echo "some-content" > /etc/some-default-os-config

# Important: Label the image as bootc-compatible
LABEL containers.bootc=1
