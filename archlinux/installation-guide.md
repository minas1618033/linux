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
    mkdir -p /mnt/boot/efi
    mount /dev/nvme0n1p1 /mnt/boot/efi
    mount /dev/nvme0n1p2 /mnt

## Select the mirrors & Install essential packages
    vim /etc/pacman.d/mirrorlist
        ## Taiwan
        Server = http://ftp.yzu.edu.tw/Linux/archlinux/$repo/os/$arch
    pacstrap /mnt base linux linux-firmware
    mkdir -p /mnt/boot/efi
    mount /dev/nvme0n1p1 /mnt/boot/efi

## Generate fstab
    genfstab -U /mnt >> /mnt/etc/fstab
    cat /mnt/etc/fstab
    (if no boot partition, mount /dev/nvme0n1p1 /mnt/boot/efi again)

## Change root into the new system
    arch-chroot /mnt

## Install essential packages
    pacman -S sudo dhcpcd nano

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

## Install Boot loader
    pacman -S os-prober ntfs-3g amd-ucode grub efibootmgr

## GRUB Configuration
    mkdir /boot/grub
    grub-mkconfig -o /boot/grub/grub.cfg
    grub-install --target=x86_64-efi --efi-directory=/boot/efi

## Set the root password
    passwd

## Add users account
    useradd -m {username}
    passwd {username}
    nano /etc/sudoers
        root ALL=(ALL) ALL
        {username} ALL=(ALL) ALL

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

## Grub2 Theme Installation
    sudo pacman -S grub-theme-vimix

    sudo nano /etc/default/grub
        GRUB_THEME="/boot/grub/themes/Vimix/theme.txt"

    sudo grub-mkconfig -o /boot/grub/grub.cfg

## If Opera crash :
    opera --disable-seccomp-filter-sandbox