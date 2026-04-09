# Fedora Atomic bootc Migration Setup
If you install Kinoite/Silverblue, it turns out you can easily pin your ostree deployment as a backup if anything goes wrong, then instead build and swap to a customized container image with any packages burned in! I haven't found much good documentation on this in Fedora so I figured I'd share what it took in a GitHub repo for you guys to try out. It's truly awesome and surprisingly easy.

Essentially the workflow is:
1. build an image with your packages and customizations off the fedora-kinoite 44 official base with a `Containerfile`
2. document your packages you installed with `rpm-ostree status`
3. with that, you now need to run `rpm-ostree reset`
4. run a `reboot`
5. in fresh booted system, pin your cleaned rpm-ostree as a base to revert anytime:
`sudo ostree admin pin 0`
6. edit the `Containerfile` or build a new one using mine as a template, as you see fit. For most people, simple deleting all of my customizations and injecting only your package installs will be enough.
6. run a podman build off your container file under sudo in your `Containerfile`'s directory (name customizable):
`sudo podman build --pull=newer -t localhost/my-kinoite-image-name:latest .`
then you need to switch to your image tag of your custom image like so (can be a one-time command run):
`sudo bootc switch --transport containers-storage localhost/my-kinoite-image-name:latest`

This way, to update your system/change base system customizations you simply rebuild your `Containerfile` and if you keep it with the same tag (acting as a release channel), you merely may run `sudo bootc update`. Ultimately, to ensure you don't lose your old custom container version, you should retag it by its image ID. For automating this, I built a script with some handy variables to handle this handshake.

In this setup, `rpm-ostree` is obsoleted for the most part except for seeing old deployments (although `bootc` can do this too). For example, to see deployments in `bootc` merely run `sudo bootc status` and to rollback to an older custom deployment it is as simple as `sudo bootc rollback`.
