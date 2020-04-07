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
    mkfs.fat -F32 /dev/nvme0n1p1
    mkfs.ext4 /dev/nvme0n1p2
    mkfs.ext4 /dev/sda1
    mkfs.ext4 /dev/sdb1
    mkswap /dev/nvme0n1p3
    swapon /dev/nvme0n1p3

## Mount the file systems
    mkdir -p /mnt/boot/temp
    mount /dev/nvme0n1p1 /mnt/boot
    mount /dev/nvme0n1p2 /mnt

## Select the mirrors & Install essential packages
    vim /etc/pacman.d/mirrorlist
        ## Taiwan
        Server = http://ftp.yzu.edu.tw/Linux/archlinux/$repo/os/$arch
    pacstrap /mnt base linux linux-firmware
    cp /mnt/boot/* /mnt/boot/temp
    mount /dev/nvme0n1p1 /mnt/boot

## Generate fstab
    genfstab -U /mnt >> /mnt/etc/fstab
    cat /mnt/etc/fstab
    (if no boot partition, mount /dev/nvme0n1p1 /mnt/boot again)

## Change root into the new system
    arch-chroot /mnt

## Install essential packages
    pacman -S amd-ucode sudo dhcpcd nano git

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

## Systemd-boot Configuration
    bootctl --path=/boot install
    blkid /dev/nvme0n1p2
    nano /boot/loader/entries/arch.conf
        title   Arch Linux
        linux   /vmlinuz-linux
        initrd  /amd-ucode.img
        initrd  /initramfs-linux.img
        options root={PARTUUID} rw
    
    nano /boot/loader/loader.conf
        default arch
        timeout 4
        editor no
    
    bootctl --path=/boot update
    
    mv /mnt/boot/temp/* /mnt/boot
    rm -r /mnt/boot/temp
    
    (use bootctl status to check config)
    
## Reboot
    exit
    umount -R /mnt
    reboot

## Enable DHCP
    sudo systemctl start dhcpcd
    sudo systemctl enable dhcpcd
    logout
    login

## Clone installation scripts
    git clone https://github.com/minas1618033/archlinux.git
    cd archlinux
    sh auto-install.sh
    sh auto-config.sh
    
## Install KDE environment
    xorg-server
    nvidia
    plasma
    1 2 3 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 22 23 24 25 26 29 30 31 32 36 38 39 40 41 42 43
    sudo systemctl enable sddm
    sudo systemctl enable NetworkManager
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
