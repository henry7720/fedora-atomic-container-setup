Do fedora everything install, KDE, uncheck everything, full disk encryption, chinese traditional and simplified locales

In desktop:
- hide desktop folder in Dolphin, set documents as desktop folder
- set labels in task manager, show only those
- Date format: `ddd, dd MMM` (Chinese date format: `MMMd日 ddd`)
- basic customizations, copy old configs needed
- no media controls on lock screen
- touchscreen disable (only use if want)
- disable flip to start in BIOS
- Dolphin: add reload, up buttons, move view-type to right, confirmations for delete
- konsole: set linux colors, font jetbrains mono 12 pt, unlock upper toolbar, hide toolbars main and session, then, to show it again right click > menu > toolbars shown > recheck main and session, open to /home/henry
- Install raleway font to system
- disable notification sounds
- apply plasma settings to login screen
- navigation wraps around virtual desktops
- uncheck play audio feedback for changes to volume
- change audio change to 2% per step

set icon for root bookmark drive-harddisk-encrypted-...

# bootc Setup
Install kinoite with user creation and basic setup
Then pin original image you're booted on to revert anytime: sudo ostree admin pin 0

Using `Containerfile`, build image:

    sudo podman build --pull=newer -t localhost/henry-os:latest .

Apply to system:
    
    sudo bootc switch --transport containers-storage localhost/henry-os:latest

In future after updates to Containerfile, you can just

    sudo bootc update

Built helper script build-os to automate this handshake of swapping old latest to be previous without doing it manually, this way you can rollback, just call `build-os`

If something broke between two builds you can always `sudo bootc rollback`

If you really need to, there is always the rpm-ostree setup -- it could be booted and the current custom container recreated on that if needed

## Arch Dev Container (can use --init if need to)
Distrobox create
```bash
distrobox create --image quay.io/toolbx/arch-toolbox:latest --home /home/henry/arch-dev --hostname arch-dev arch-dev
```

Packages:
```bash
github-cli
python python-pip python-pipx python-virtualenv
gcc gdb make valgrind
nodejs npm
#jdk-openjdk
bash-completion
ffmpeg
rust
```

Exports to local system:
```bash
distrobox-export --bin /usr/bin/ffmpeg
distrobox-export --bin /usr/bin/gh
distrobox-export --bin /usr/bin/node
distrobox-export --bin /usr/bin/gcc
distrobox-export --bin /usr/bin/gdb
distrobox-export --bin /usr/bin/make
distrobox-export --bin /usr/bin/valgrind
distrobox-export --bin /usr/bin/pipx
# Optional for cli need
# distrobox-export --bin /usr/bin/java
# distrobox-export --bin /usr/bin/javac
distrobox-export --bin /usr/bin/rustc
distrobox-export --bin /usr/bin/cargo
distrobox-export --bin /home/henry/arch-dev/.local/bin/yt-dlp
```

pipx: install `yt-dlp[default,curl-cffi]` and can install `linuxdir2html` -- `internetarchive` is also an option
make and edit: /home/henry/arch-dev/.config/yt-dlp/config:
```
# Use Node.js as the JS runtime
--js-runtimes node
```
pipx in arch dev: install `yt-dlp[default,curl-cffi]` and `linuxdir2html` -- `internetarchive` is also an option


## Optional: Enable tailscale SSH and disable sshd
```bash
sudo systemctl stop sshd
sudo systemctl mask sshd
sudo systemctl stop sshd.socket
sudo systemctl mask sshd.socket
sudo tailscale set --ssh
sudo systemctl enable --now tailscaled
# you could always unmask standard sshd and its socket and then re-enable sshd (default preset) and do tailscale set --ssh=false
```

## Firefox Config
in `about:config` set `browser.urlbar.trimURLs` to false (to show "https://").
- For setup of using kde file picker
`widget.use-xdg-desktop-portal.file-picker` set to 1

## External repos
get: `mullvad-vpn`, `vscodium`

###### cursor is an option

jigmo manual font install

raleway manual font install from google fonts

## Groups to add to:
```bash
# Virtualization group
sudo usermod -aG libvirt henry

# Optical drive group
#sudo usermod -aG cdrom henry
```


# Flatpaks (add Flathub, disable fedora flatpak and uninstall --delete-data all of the default ones):
```bash
# Spotify
com.spotify.Client

# USB ISO writer
org.fedoraproject.MediaWriter

# Image viewer
org.kde.gwenview

# PDF and e-book viewer
org.kde.okular

# Calculator
org.kde.kcalc

# Clock + alarms
org.kde.kclock

# Chat
#com.tencent.WeChat

# Blu-ray ripping
com.makemkv.MakeMKV

# Screen recording/streaming
com.obsproject.Studio

# Flash cards
net.ankiweb.Anki

# Backups
org.gnome.World.PikaBackup

# Notes (text-based)
net.cozic.joplin_desktop

# Note-taking (general)
com.github.xournalpp.xournalpp

# Input methods
# (share input state all, make font noto cjk tc size 14, add pinyin, in system keyboard options, don't add any layouts but configure key bindings and caps lock behavior make additional control modifier which identifies as caps lock, remove keybind for clipboard module), for mac
# ctrl position for mac users: swap left win with elft control
org.fcitx.Fcitx5
org.fcitx.Fcitx5.Addon.ChineseAddons

# Synchronize file versions
org.freefilesync.FreeFileSync

# Office suite
org.libreoffice.LibreOffice

# Image editing
org.kde.krita

# Remote desktop
org.remmina.Remmina

# Video editor
org.kde.kdenlive

# Torrent client
org.qbittorrent.qBittorrent

# MKV video remuxing
org.bunkus.mkvtoolnix-gui

# Video player
org.videolan.VLC

# Audio player
org.atheme.audacious

# Chat
org.signal.Signal

# Web browsers
com.brave.Browser

org.jdownloader.JDownloader
```
    
Bug fix for fcitx through xmodifiers flatpaks (including wechat):
`flatpak override --user --env=XMODIFIERS=@im=fcitx`

Full home folder permissions (if I dare):
`flatpak override --user --filesystem=home com.tencent.WeChat`

### custom `~/.bashrc.d/` scripts:

`deb_prompt.sh`
```bash
# DEBIAN PROMPT (ripped from default install)

# Could use helper functions
prompt_color 35
prompt_dir_color 36
prompt_highlight 1

# Debian style -- example where set variables, color is default at 32
# PROMPT_COLOR="32"
# THESE NEED TO BE SET
# PROMPT_DIR_COLOR="34"
# PROMPT_HIGHLIGHT="1"

# Original Debian
# PS1="\[\e]0;\u@\h: \w\a\]\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "

```

`set_editor.sh`
```bash
# Set editor
export EDITOR="micro"
```

`update_grub.sh`
```bash
# COPY DEBIAN STYLE
alias update-grub='sudo grub2-mkconfig -o /boot/grub2/grub.cfg'
```

`ignore_podman_warnings.sh`
```bash
# IGNORE PODMAN WARNINGS ABOUT USING PODMAN AS DOCKER BACKEND, found via `man 1 podman-compose`
export PODMAN_COMPOSE_WARNING_LOGS="false"
```

## Firewall
Firewall for Webhosting if needed:

    sudo firewall-cmd --add-port=8000/tcp --permanent

    sudo firewall-cmd --reload
    
# Extra tools:

## OCR a PDF
Optional base system packages: `img2pdf`, `ocrmypdf`
For lossless OCR: `ocrmypdf --output-type pdf --optimize 0 input_file.pdf output_file.pdf`

Then for, for better lossless merging if needed, use `qpdf`:
`qpdf --empty --pages input1.pdf input2.pdf -- merged_output.pdf`

#~/.local/share/applications is custom shortcut place


## For packet scanning:
Install `wireshark` and add to group

## For C memory leak checker:
Install `valgrind`

## Potentially useful Flatpaks (pick from list as needed):_
```bash
io.github.flattool.Warehouse
com.discordapp.Discord
us.zoom.Zoom
io.github.ungoogled_software.ungoogled_chromium
org.fooyin.fooyin
org.nicotine_plus.Nicotine
org.kde.kolourpaint
org.audacityteam.Audacity
org.gimp.GIMP
org.inkscape.Inkscape
com.github.wwmm.easyeffects
org.kde.skanpage
org.kde.kamoso
org.fcitx.Fcitx5.Addon.Mozc
org.fcitx.Fcitx5.Addon.Rime
com.usebottles.bottles
com.valvesoftware.Steam
io.github.dvlv.boxbuddyrs
io.gitlab.librewolf-community
io.mpv.Mpv
org.texstudio.TeXstudio # dependency: org.freedesktop.Sdk.Extension.texlive
io.podman_desktop.PodmanDesktop
com.github.qarmin.czkawka
io.github.nozwock.Packet
org.torproject.torbrowser-launcher
```

# Miscellaneous:
## Rocky Linux Packages (COELinux style):
`distrobox create --image quay.io/rockylinux/rockylinux:8.10-ubi --home /home/henry/systems-dev --hostname rocky-8 rocky-8`

for C Rocky Linux, in container:
```bash
sudo dnf install vim nano gcc make valgrind gdb; sudo dnf debuginfo-install glibc
```

## CMMC old code (use slim images)
For cmmc project (can remove eventually)
```distrobox-create --name debian-cmmc --image docker.io/library/debian:bookworm-slim --home /home/henry/debian-cmmc --hostname debian-cmmc```

in container:
```bash
nodejs npm

npm install
npm fund
npm audit fix
npm start
```

do `npm start` again

for old java, sudo apt install default-jdk


## Debian remove old configs:
remove all dead configs even if you just ran `sudo apt remove` on past packages:
`sudo apt purge ~c`

# Useful commands

## Lock kernel versions
```bash
#keep kernel:

sudo dnf versionlock add kernel-6.x.x-300.fc43.x86_64

# remove pin
sudo dnf versionlock delete kernel OR kernel-6.x.x-300.fc43
```
you can add all versions installed with just "kernel"

On upgrade: `pipx reinstall-all`

## SSH useful commands:
Run `ssh-keygen` if not done already
then
Setup key to server:
`ssh-copy-id user@device-ip`

then on server side, edit: `/etc/ssh/sshd_config`

and add/set: `PasswordAuthentication` to no and `PermitRootLogin` no

Update passphrase:
`ssh-keygen -p -f ~/.ssh/id_ed25519`

Update comment of SSH key:
`ssh-keygen -c -f ~/.ssh/id_ed25519`

## Root account setup:
To check if check if root account is locked: "L" means locked, "P" means password:
`sudo passwd -S root`

`sudo passwd root` (to set root password for worst cases)

`sudo passwd -l root` (lock root account for security)

## For chinese vocab:
use zhongwen extension in browser then `proc_zh input.txt out.txt`

## Distrobox and Podman commands:
Remove:
`distrobox rm container-name`

Remove old images (list, then remove)
```bash
podman images
podman rmi image-name
```

rename distrobox/container:
`podman container rename old-name new-name`

suppress warnings about using `podman` in place of `docker`: create `/etc/containers/nodocker`

## Script setups:
```bash
# Update/system maintenance script
ln -s /home/henry/Documents/Scripts/update-system-all.sh /home/henry/.local/bin/update-all

# Chinese text format parser for flashcards
ln -s /home/henry/Documents/Scripts/process_zhongwen_export.py /home/henry/.local/bin/proc_zh

# Restart shell for strange bugs
ln -s /home/henry/Documents/Scripts/restart-plasmashell.sh /home/henry/.local/bin/restart_shell

# Remote backup solution
ln -s /home/henry/Documents/Scripts/backup-remote.sh /home/henry/.local/bin/backup-remote

# Update script
ln -s /home/henry/Documents/Scripts/rebuild-system-bootc.sh /home/henry/.local/bin/build-os

# Allow Family Media Archive accessibility from home but on external drive
ln -s '/run/media/henry/Diff_Backups/FAMILY MEDIA ARCHIVE' /home/henry/Documents/Personal/FAMILY\ MEDIA\ ARCHIVE
