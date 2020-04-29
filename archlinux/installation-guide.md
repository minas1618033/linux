## Download install script
    curl -L https://github.com/minas1618033/linux/archive/master.zip --output scripts.zip
    bsdtar -x -f scripts.zip
    chmod +x /root/linux-master/archlinux/*.sh
    sh /root/linux-master/archlinux/1-initialize.sh

## Connect to the wireless LAN by netctl
    wifi-menu
    (ip link set wlan0 up)

## Update the system clock
    timedatectl set-ntp true

## Partition the disks
    fdisk /dev/{nvme0n1, sda, sdb}
    
    g : create GPT partition table
    n : add new partition
    t : change partition type
        1 EFI System
        20 Linux System
        19 Linux Swap
        28 LinuxHome

## Format the partitions
    mkfs.vfat /dev/nvme0n1p1
    mkfs.ext4 /dev/nvme0n1p2
    mkfs.ext4 /dev/sda1
    mkfs.ext4 /dev/sdb1
    mkswap /dev/nvme0n1p3
    swapon /dev/nvme0n1p3

## Mount the file systems
    mount /dev/nvme0n1p2 /mnt
    mkdir /mnt/boot
    mount /dev/nvme0n1p1 /mnt/boot

## Select the mirrors & Install essential packages
    vim /etc/pacman.d/mirrorlist
        ## Taiwan
        Server = http://ftp.yzu.edu.tw/Linux/archlinux/$repo/os/$arch
    pacstrap /mnt base linux linux-firmware

## Generate fstab
    genfstab -U /mnt >> /mnt/etc/fstab
    cat /mnt/etc/fstab
    (if no boot partition, mount /dev/nvme0n1p1 /mnt/boot again)

## Change root into the new system
    arch-chroot /mnt

## Install essential packages
    pacman -S amd-ucode sudo nano git (iwd)

## Set the time zone
    ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
    hwclock --systohc

## Localization
    nano /etc/locale.gen
        Uncomment en_US.UTF-8 UTF-8, zh_TW.UTF-8 UTF8
    locale-gen
    nano /etc/locale.conf
        LANG=en_US.UTF-8
        LC_CTYPE="zh_TW.UTF-8"

## Network Configuration
    echo {myhostname} > /etc/hostname

    nano /etc/hosts
        127.0.0.1   localhost
        ::1         localhost
        127.0.1.1   {myhostname}.localdomain  {myhostname}

## Set the root password
    passwd

## Add users account
    useradd -m {username}
    passwd {username}
    nano /etc/sudoers
        root ALL=(ALL) ALL
        {username} ALL=(ALL) ALL

## systemd-boot Configuration
    bootctl --path=/boot install
    blkid /dev/nvme0n1p2
    nano /boot/loader/entries/arch.conf
        title   Arch Linux
        linux   /vmlinuz-linux
        initrd  /amd-ucode.img
        initrd  /initramfs-linux.img
        options root=PARTUUID={PARTUUID} rw
    
    nano /boot/loader/loader.conf
        default arch
        timeout 4
        editor no
    
    bootctl --path=/boot update
    (use bootctl status to check config)

## systemd-networkd Configuration
    mkdir /etc/systemd/network
    (for Ethernet) nano /etc/systemd/network/20-dhcp.network
        [Match]
        Name=enp1s0
        [Network]
        DHCP=ipv4
    
    (for WiFi) nano /etc/systemd/network/25-wireless.network
        [Match]
        Name=wlp2s0
        [Network]
        DHCP=ipv4

    nano /etc/iwd/main.conf
        [General]
        EnableNetworkConfiguration=true
        [Network]
        NameResolvingService=systemd

## Reboot
    exit
    umount -R /mnt
    reboot

## Enable Network and DHCP
    sudo systemctl start systemd-networkd
    sudo systemctl enable systemd-networkd
    sudo systemctl start systemd-resolved
    sudo systemctl enable systemd-resolved
    ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
    sudo mkdir /etc/systemd/resolved.conf.d
    echo "[Resolve]" >> /etc/systemd/resolved.conf.d/dnssec.conf
    echo "DNSSEC=false" >> /etc/systemd/resolved.conf.d/dnssec.conf
    logout
    login

## Clone installation scripts
    git clone https://github.com/minas1618033/linux.git
    cd linux/archlinux
    sh auto-install.sh
    sh auto-config.sh
    
## Install KDE environment
    xorg-server
    nvidia
    plasma {breeze, breeze-gtk, drkonqi, kactivitymanagerd, kde-cli-tools, kde-gtk-config, kdecoration, kdeplasma-addons, khotkeys, kinfocenter, kmenuedit, knetattach, kscreen, kscreenlocker, ksysguard, kwin, kwrited, libkscreen, libksysguard, plasma-browser-integration, plasma-desktop, plasma-integration, plasma-pa, plasma-workspace, polkit-kde-agent, sddm-kcm, systemsettings, user-manager, xdg-desktop-portal-kde
    2 3 5 6 7 8 9 10 12 13 14 15 16 17 19 22 23 24 25 28 29 30 32 36 38 40 41 42 43}
    sudo systemctl enable sddm
    reboot

## Add archlinuxcn Repository
    echo "[archlinuxcn]" >> /etc/pacman.conf
    echo "Server = https://repo.archlinuxcn.org/$arch" >> /etc/pacman.conf
    sudo pacman -Sy
    pacman -S archlinuxcn-keyring

## If keyring could not be locally signed
    rm -fr /etc/pacman.d/gnupg
    pacman-key --init
    pacman-key --populate archlinux

## If AUR package fails to verify PGP/GPG key
    gpg --recv-keys {keys}

## If Opera crash :
    opera --disable-seccomp-filter-sandbox
