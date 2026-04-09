# Fedora Atomic bootc Migration Setup

If you install Kinoite/Silverblue/Atomic Desktop of your choosing, it turns out you can easily pin your ostree deployment as a backup if anything goes wrong, then instead build and swap to a customized container image with any packages burned in! I am super excited by this because it's truly an amazing feat that this is so easy.  
  
Because I haven't found much good documentation for this migration on Fedora I figured I'd share what it took in a GitHub repo for you guys to try it out. It's truly awesome and surprisingly easy.

Essentially the workflow is:

1. run/install Fedora atomic desktop of your choosing
2. update the system on/to 43
2. if applicable document your packages you custom-installed with `rpm-ostree status`
3. with that, you now need to run `rpm-ostree reset`
4. run a `reboot`
5. in fresh booted system, pin your cleaned rpm-ostree as a base to revert to anytime: `sudo ostree admin pin 0`
6. edit the `Containerfile` or build a new one using mine as a template, as you see fit. For most people, simple deleting all of my customizations and injecting only your package installs will be enough, for others the image itself is enough
7. run a podman build off your container file under sudo in your `Containerfile`'s directory (name is customizable): `sudo podman build --pull=newer -t localhost/my-kinoite-image-name:latest .` then you need to switch to your image tag of your custom image like so (this can easily be a one-time setup): `sudo bootc switch --transport containers-storage localhost/my-kinoite-image-name:latest`

Running the bash script for allowing clean rollbacks: In dir, one-time setup: `chmod +x rebuild-system-bootc.sh`
Then just run my script to rebuild the OS anytime with rollbacks still supported easily: `./rebuild-system-bootc.sh`

This way, to update your system/change base system customizations you simply rebuild your `Containerfile` with the script then you merely may run `sudo bootc update`. You can also manually rebuild it with the same tag. Ultimately, to ensure you don't lose your old custom container version for rollback purposes, you should retag it by its image ID. For automating this, I built a script with some handy variables to handle this handshake, generally to be run in the same folder as the `Containerfile` for build purposes. Be sure to edit the variables for image name at the top of the script to whatever you'd like. Ensure it matches your custom-switched `bootc`.

In this setup, `rpm-ostree` is obsoleted for the most part except for seeing old deployments (although `bootc` can do this too). For example, to see deployments in `bootc` merely run `sudo bootc status` and to rollback to an older custom deployment it is as simple as `sudo bootc rollback`. Basically, ignore `rpm-ostree` as the flow has changed. All images can be managed with podman, erased, etc. Just be careful not to erase deployments that are in use.

*Note*: this can 100% be customized with more complex flows, versioned release tags, registry-uploads, etc. That's all up to you!

Feel free to test on bare-metal or in a VM if you are concerned about whether this would work for you. Although rollbacks are a non-issue and `bootc` is here to stay. Also, issues are welcome and needed!
