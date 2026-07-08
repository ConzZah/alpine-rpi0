#!/usr/bin/env sh

# Author: ConzZah
# Project: alpine-rpi0
# File: setup.sh
# /// core setup script ///

## set vars
## NOTE: YOU MAY CHANGE ALL OF THOSE TO SUIT YOUR NEEDS!!
user="${user:-user}"
user_pass="${user_pass:-123}"
img="alpine-rpi0"

## install essential packages
apk upgrade -U
apk add util-linux coreutils pciutils cloud-utils-growpart parted grep sed lsblk mount nano htop ntfs-3g 7zip fastfetch wget curl git tar sudo man-pages mandoc bash bash-completion w3m w3m-image xz shadow udisks2 e2fsprogs e2fsprogs-extra android-tools libqrencode-tools fzf build-base linux-headers

## create $user
setup-user -a -g audio,input,video,netdev "${user}"

## change password for $user
printf '%s' "${user}:${user_pass}"| chpasswd

## add $user to sudoers
echo "${user} ALL=(ALL:ALL) ALL" > "${user}"
mv "${user}" "/etc/sudoers.d/${user}"
chmod 0440 "/etc/sudoers.d/${user}"

## install resize_sd.sh
curl -LO "https://github.com/ConzZah/alpine-rpi0/raw/refs/heads/main/resize_sd.sh"
mkdir -p '/etc/.firstboot'
chmod +x 'resize_sd.sh'
mv -f 'resize_sd.sh' '/etc/.firstboot'

## install dotfiles for both $user and root
curl -LO "https://github.com/ConzZah/alpine-rpi0/raw/refs/heads/main/dotfilez.7z"
7z x -y 'dotfilez.7z' -o"/home/${user}"
7z x -y 'dotfilez.7z' -o'/root'
rm dotfilez.7z*

## install shellcheck (because it's not in the repo for armv7 or armhf (as of: 2026-07-03)):
## https://pkgs.alpinelinux.org/packages?name=shellcheck&branch=edge&repo=&arch=armhf&origin=&flagged=&maintainer=
## if a new version is released, update $sc_version to the new tag
## if it appears in the repo at any point, remove this block.
sc_version="v0.11.0"
curl -Lo "shellcheck-${sc_version}.tar.xz" "https://github.com/koalaman/shellcheck/releases/download/${sc_version}/shellcheck-${sc_version}.linux.armv6hf.tar.xz"
tar xf "shellcheck-${sc_version}.tar.xz"
chmod +x "shellcheck-${sc_version}/shellcheck"
mv -f "shellcheck-${sc_version}/shellcheck" "/usr/bin"
rm -rf "shellcheck-${sc_version}"*

## install networkmanager and ufw
## (NOTE: this needs to be the last task that requires networking, because we won't have internet until we reboot)
git clone --depth=1 'https://github.com/conzzah/nm4alpine'
git clone --depth=1 'https://github.com/conzzah/ufw4alpine'
sed -i -e 's/; read -n1 -s//g' -e 's/doas //g' -e "s#\$USER#$user#g" 'nm4alpine/nm4alpine.sh' 'ufw4alpine/ufw4alpine.sh'
sh 'ufw4alpine/ufw4alpine.sh'
sh 'nm4alpine/nm4alpine.sh'
rm -rf 'ufw4alpine' 'nm4alpine'

## edit /etc/mke2fs.conf to enable periodic fscks
sed -i 's#enable_periodic_fsck = 0#enable_periodic_fsck = 1#g' '/etc/mke2fs.conf'

## install root crontab
echo '# do daily/weekly/monthly maintenance
# min	hour	day	month	weekday	command
*/15	*	*	*	*	run-parts /etc/periodic/15min
0	*	*	*	*	run-parts /etc/periodic/hourly
0	2	*	*	*	run-parts /etc/periodic/daily
0	3	*	*	6	run-parts /etc/periodic/weekly
0	5	1	*	*	run-parts /etc/periodic/monthly

### FIRSTBOOT STUFF ###

# if .firstboot exist, generate ssh keys @ reboot, then remove /etc/firstboot so we only regen once.
@reboot [ -f /etc/.firstboot/firstboot ] && { rm /etc/.firstboot/firstboot; rm /etc/ssh/ssh_host_*; ssh-keygen -A; sh /etc/.firstboot/resize_sd.sh ;}
@reboot [ -f /etc/.firstboot/.repart ] && sh /etc/.firstboot/resize_sd.sh

### FIXES ###

# restart chronyd as soon as we have internet, so we get the system time right:
@reboot { until ping -q -c 1 -w 1 google.com; do sleep 1; done; rc-service chronyd restart ;} &
' > 'crontab'; mv -f 'crontab' '/var/spool/cron/crontabs/root'

## install /etc/motd
echo "

Welcome to Alpine!

you are running: $img by ConzZah

The Alpine Wiki contains a large amount of how-to guides and general
information about administrating Alpine systems.
See <https://wiki.alpinelinux.org/>.

You may change this message by editing /etc/motd.

" > 'motd'; rm -f '/etc/motd'; mv -f 'motd' '/etc/'

## change default shell to bash
chsh "${user}" -s /bin/bash
chsh root -s /bin/bash

## change ownership of /home/$user
chown -R "${user}":"${user}" -- "/home/$user".*
chown -R "${user}":"${user}" -- "/home/$user"*

## poweroff
sync; sleep 10; poweroff
