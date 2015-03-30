#!/bin/bash

# ==============================================
# Created with UBUNTU 14.10 - Sony VPCEJ
# Maintened by Nicolas GAUTIER <ngautier@enroot.fr>
# ==============================================

# ==============================================
# Bash configuration
# ==============================================
export DEBIAN_FRONTEND=noninteractive

# ==============================================
# Add repositories
# ==============================================
echo "deb http://get.docker.io/ubuntu docker main" > /etc/apt/sources.list.d/docker.list # Docker
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list # Google Chrome
echo "deb http://ppa.launchpad.net/teejee2008/ppa/ubuntu utopic main" > /etc/apt/sources.list.d/teejee2008-ubuntu-ppa-utopic.list # ConkyManager
echo "deb http://ppa.launchpad.net/webupd8team/atom/ubuntu utopic main" > /etc/apt/sources.list.d/webupd8team-ubuntu-atom-utopic.list # Atom
echo "deb http://ppa.launchpad.net/webupd8team/gnome3/ubuntu utopic main" > /etc/apt/sources.list.d/webupd8team-ubuntu-gnome3-utopic.list # Gnome 3
echo "deb http://ppa.launchpad.net/webupd8team/sublime-text-3/ubuntu utopic main" > /etc/apt/sources.list.d/webupd8team-ubuntu-sublime-text-3-utopic.list # SublimeText 3
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" > /etc/apt/sources.list.d/webupd8team-java.list # Java
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list.d/webupd8team-java.list # Java
echo "deb http://archive.canonical.com/ trusty partner" >> /etc/apt/sources.list.d/skype.list # Skype

# ==============================================
# Install softwares
# ==============================================
apt-get update && apt-get upgrade && apt-get dist-upgrade

# apt-get install -y default-jre default-jdk
apt-get install -y --force-yes atom sublime-text git htop \
			       virtualbox preload vlc google-chrome-stable \
			       skype \
			       oracle-java8-installer

# Only for GNOME 3
apt-get install -y --force-yes conky cairo-dock

# ==============================================
# Install and configure Docker
# ==============================================
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9

apt-get install -y lxc-docker
groupadd docker
gpasswd -a ${USER} docker
service docker restart


# ==============================================
# Install and configure Docker-Compose (ex Fig)
# ==============================================
wget -O /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/1.1.0/docker-compose-`uname -s`-`uname -m`
wget -O /etc/bash_completion.d/docker-compose https://raw.githubusercontent.com/docker/compose/1.1.0/contrib/completion/bash/docker-compose
chmod +x /usr/local/bin/docker-compose

# ==============================================
# Install graphical driver
# ==============================================
apt-get purge nvidia*
apt-get install -y nvidia-304 nvidia-settings

# Add this line in /usr/share/X11/xorg.conf.d/20-nvidia.conf
# Option "RegistryDwords" "EnableBrightnessControl=1"
# nano /usr/share/X11/xorg.conf.d/20-nvidia.conf
if [ -f /usr/share/X11/xorg.conf.d/20-nvidia.conf ] then
  sed -i "s/BoardName      \"GeForce 410M\"/\1\nOption \"RegistryDwords\" \"EnableBrightnessControl=1\"/g" /usr/share/X11/xorg.conf.d/20-nvidia.conf
  sed -i "s/Driver         \"nvidia\"/\1\nOption \"NoLogo\"/g" /usr/share/X11/xorg.conf.d/20-nvidia.conf
elseif
  echo '
  Section "Device"
    Identifier     "Device0"
    Driver         "nvidia"
    VendorName     "NVIDIA Corporation"
    BoardName      "GeForce 410M"
    Option         "RegistryDwords" "EnableBrightnessControl=1"
  EndSection' > /usr/share/X11/xorg.conf.d/20-nvidia.conf
fi


# ==============================================
# Edit grub file (/etc/default/grub)
# ==============================================
# Usefull : Fix backlight, shorcut keys and touchpad
# GRUB_CMDLINE_LINUX="acpi_backlight=vendor acpi_osi=Linux i8042.reset i8042.nomux i8042.nopnp i8042.noloop"
#nano /etc/default/grub
sed -i "s/^GRUB_CMDLINE_LINUX=\"\"$/GRUB_CMDLINE_LINUX=\"acpi_backlight=vendor acpi_osi=Linux i8042.reset i8042.nomux i8042.nopnp i8042.noloop\"/g" /etc/default/grub

# ==============================================
# Configure SSD
# ==============================================
# Use SWAP when RAM is full use
echo -e "vm.swappiness=0" | tee -a /etc/sysctl.conf

# Disable access time logging
#nano /etc/fstab
# ===> Now change “errors=remount-ro” to “noatime,errors=remount-ro” on SSD disk
sed -i "s/errors=remount-ro/noatime,errors=remount-ro/g" /etc/fstab

# Enable TRIM
echo -e "#\x21/bin/sh\\nfstrim -v /" | tee /etc/cron.daily/trim
chmod +x /etc/cron.daily/trim


# ==============================================
# Restore workstation configuration
# ==============================================
sudo export DEBIAN_FRONTEND=dialog
