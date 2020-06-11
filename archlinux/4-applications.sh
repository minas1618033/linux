# !/bin/bash
sudo sh -c "echo '' >> /etc/pacman.conf"
sudo sh -c "echo '[archlinuxcn]' >> /etc/pacman.conf"
sudo sh -c "echo 'Server = https://repo.archlinuxcn.org/\$arch' >> /etc/pacman.conf"
sudo pacman -Syyu
sudo pacman -S --noconfirm archlinuxcn-keyring

printf "\nContinue to install applications? [Y/N] "
read -n1 action
echo
    case $action in
        [Nn]) exit ;;
        [Yy]) break ;;
        *) exit ;;
    esac

sudo pacman -S --noconfirm xorg-server
sudo pacman -S --noconfirm nvidia
sudo pacman -S --noconfirm gnu-free-fonts
sudo pacman -S --noconfirm bluedevil
sudo pacman -S --noconfirm breeze
sudo pacman -S --noconfirm breeze-gtk
sudo pacman -S --noconfirm drkonqi
sudo pacman -S --noconfirm kde-cli-tools
sudo pacman -S --noconfirm kde-gtk-config
sudo pacman -S --noconfirm kdeplasma-addons
sudo pacman -S --noconfirm khotkeys
sudo pacman -S --noconfirm kinfocenter
sudo pacman -S --noconfirm kscreen
sudo pacman -S --noconfirm ksysguard
sudo pacman -S --noconfirm kwrited
sudo pacman -S --noconfirm plasma-browser-integration
sudo pacman -S --noconfirm plasma-desktop
sudo pacman -S --noconfirm plasma-integration
sudo pacman -S --noconfirm plasma-pa
sudo pacman -S --noconfirm plasma-workspace
sudo pacman -S --noconfirm sddm-kcm
sudo pacman -S --noconfirm user-manager
sudo pacman -S --noconfirm ark
sudo pacman -S --noconfirm baidupcs-go
sudo pacman -S --noconfirm binutils
sudo pacman -S --noconfirm bleachbit
sudo pacman -S --noconfirm clipgrab
sudo pacman -S --noconfirm code
sudo pacman -S --noconfirm cronie
sudo pacman -S --noconfirm dolphin
sudo pacman -S --noconfirm dolphin-plugins
sudo pacman -S --noconfirm ffmpegthumbs
sudo pacman -S --noconfirm gimp
sudo pacman -S --noconfirm htop
sudo pacman -S --noconfirm ibus
sudo pacman -S --noconfirm kate
sudo pacman -S --noconfirm kcalc
sudo pacman -S --noconfirm kdegraphics-thumbnailers
sudo pacman -S --noconfirm kdenetwork-filesharing
sudo pacman -S --noconfirm kdenlive
sudo pacman -S --noconfirm kdialog
sudo pacman -S --noconfirm keepassxc
sudo pacman -S --noconfirm kfind
sudo pacman -S --noconfirm kget
sudo pacman -S --noconfirm kio-fuse
sudo pacman -S --noconfirm kolourpaint
sudo pacman -S --noconfirm kompare
sudo pacman -S --noconfirm konsole
sudo pacman -S --noconfirm krename
sudo pacman -S --noconfirm ksystemlog
sudo pacman -S --noconfirm libreoffice-still
sudo pacman -S --noconfirm libreoffice-still-zh-tw
sudo pacman -S --noconfirm mpv
sudo pacman -S --noconfirm noto-fonts-cjk
sudo pacman -S --noconfirm okular
sudo pacman -S --noconfirm opera
sudo pacman -S --noconfirm opera-ffmpeg-codecs
sudo pacman -S --noconfirm p7zip
sudo pacman -S --noconfirm partitionmanager
sudo pacman -S --noconfirm pcsclite
sudo pacman -S --noconfirm profile-sync-daemon
sudo pacman -S --noconfirm qmmp
sudo pacman -S --noconfirm qt5-imageformats
sudo pacman -S --noconfirm rclone
sudo pacman -S --noconfirm rsync
sudo pacman -S --noconfirm skanlite
sudo pacman -S --noconfirm spectacle
sudo pacman -S --noconfirm unrar
sudo pacman -S --noconfirm xdg-user-dirs
sudo pacman -S --noconfirm yakuake

sudo pacman -S --noconfirm crow-translate
sudo pacman -S --noconfirm megatools
sudo pacman -S --noconfirm ibus-libzhuyin
sudo pacman -S --noconfirm qbittorrent-enhanced-git
sudo pacman -S --noconfirm qview
sudo pacman -S --noconfirm rclone-browser
sudo pacman -S --noconfirm safeeyes-git
sudo pacman -S --noconfirm unzip-iconv
sudo pacman -S --noconfirm wine-x64
sudo pacman -S --noconfirm yay
sudo pacman -S virtualbox

# sudo pacman -S --noconfirm caprine
# sudo pacman -S --noconfirm cups
# sudo pacman -S --noconfirm exfat-utils
# sudo pacman -S --noconfirm faad2 (qmmp)
# sudo pacman -S --noconfirm k3b
# sudo pacman -S --noconfirm kaccounts-providers
# sudo pacman -S --noconfirm kwayland-integration
# sudo pacman -S --noconfirm libmpcdec (qmmp)
# sudo pacman -S --noconfirm libva-vdpau-driver (vlc)
# sudo pacman -S --noconfirm man-db
# sudo pacman -S --noconfirm man-pages
# sudo pacman -S --noconfirm mpg123 (qmmp)
# sudo pacman -S --noconfirm mtpfs
# sudo pacman -S --noconfirm opusfile (qmmp)
# sudo pacman -S --noconfirm pulseaudio-alsa
# sudo pacman -S --noconfirm pulseaudio-bluetooth
# sudo pacman -S --noconfirm unzip-natspec
# sudo pacman -S --noconfirm wildmidi (qmmp)
# sudo pacman -S --noconfirm wine
# sudo pacman -S --noconfirm xdg-desktop-portal-kde
# sudo pacman -S --noconfirm youtube-dl

# git clone https://aur.archlinux.org/trizen.git
# cd trizen
# makepkg -si

yay -S anydesk-bin
yay -S kde-servicemenus-rootactions
yay -S ms-office-online
yay -S powerdevil-light

# yay -S isoimagewriter
# yay -S kmarkdownwebview
# yay -S ksnip
# yay -S megacmd-bin
# yay -S stacer

# sudo pacman -Rsn --noconfirm xdg-user-dirs

# sudo sh ../../../Config/Sophos-Antivirus-free/install.sh

sudo systemctl enable sddm
