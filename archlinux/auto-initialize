clear
echo "
          Arch Linux install script

--------------------------------------------

"
# 1.Connected to the Internet
    ping -c 3 www.google.com > /dev/null 2>&1 &&
        echo "(O) 1.Connected to the Internet" ||
      { echo "(X) 1.Connected to the Internet <<<<<<<<<<"; exit; }

# 2.Update the system clock
    timedatectl set-ntp true &&
        echo "(O) 2.Update the system clock" ||
      { echo "(X) 2.Update the system clock <<<<<<<<<<"; exit; }

# 3.Partition the disks
    echo "    Partition the disks"
    while [[ ! "$ACTION" =~ ^[yYnN]$ ]]; do
        read -n1 -p "     Do you want to partition the disks? [Y/N]: " ACTION
        echo ""; done
            case $ACTION in
            [yY]) echo "     Ctrl+C and fdisk disks"
                  exit ;;
            [nN]) echo "(O) 3.Partition the disks" ;;
            esac

# 4.Format the partitions
    echo "     Format the partitions"
    echo "     1.Desktop with 1*NVME + 2*HDD"
    echo "     2.Laptop with 1*SSD"
    while [[ ! "$ACTION" =~ ^[123]$ ]]; do
    read -n1 -p "     3.Custom : " ACTION
        case $ACTION in
        1)  mkfs.vfat /dev/nvme0n1p1 &&
            mkfs.ext4 /dev/nvme0n1p2 &&
            mkfs.ext4 /dev/sda1 &&
            mkfs.ext4 /dev/sdb1 &&
            echo "(O) 4.Format the partitions" ||
          { echo "(X) 4.Format the partitions <<<<<<<<<<"; exit; }
            ;;
        2)  mkfs.vfat /dev/sda1
            mkfs.ext4 /dev/sda2
            mkswap /dev/sda3
            swapon /dev/sda3
            echo "(O) 4.Format the partitions" ||
          { echo "(X) 4.Format the partitions <<<<<<<<<<"; exit; }
            ;;
        3)  echo "     Ctrl+C and mkfs disks"
            exit
            ;;
        esac

# 5.Mount the file systems
    mount /dev/sda2 /mnt &&
    mkdir /mnt/boot &&
    mount /dev/sda1 /mnt/boot &&
    echo "(O) 5.Mount the file systems" ||
  { echo "(X) 5.Mount the file systems <<<<<<<<<<"; exit; }

# 6.Select the mirrors
    vim /etc/pacman.d/mirrorlist &&
    echo "(O) 6.Select the mirrors" ||
  { echo "(X) 6.Select the mirrors <<<<<<<<<<"; exit; }

# 7.Install linux kernel & base packages
    pacstrap /mnt base linux linux-firmware &&
    echo "(O) 7.Install linux kernel & base packages" ||
  { echo "(X) 7.Install linux kernel & base packages <<<<<<<<<<"; exit; }

# 8.Generate fstab
    genfstab -U /mnt >> /mnt/etc/fstab &&
    cat /mnt/etc/fstab &&
    echo "(O) 8.Generate fstab" ||
  { echo "(X) 8.Generate fstab <<<<<<<<<<"; exit; }
    
# 9.Change root into the new system
    while [[ ! "$ACTION" =~ ^[yYnN]$ ]]; do
        read -n1 -p "     Do you want to change root into the new system? [Y/N]: " ACTION
        echo ""; done
            case $ACTION in
            [yY]) arch-chroot /mnt
                  echo "(O) 9.Change root into the new system"
                  ;;
            [nN]) echo "(X) 9.Change root into the new system"
                  exit
                  ;;
            esac

# 10.Install essential packages
    pacman -S amd-ucode sudo nano git iwd &&
    echo "(O) 10.Install essential packages" ||
  { echo "(X) 10.Install essential packages <<<<<<<<<<"; exit; }

# 11.Set the time zone
    ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime &&
    hwclock --systohc &&
    echo "(O) 11.Set the time zone" ||
  { echo "(X) 11.Set the time zone <<<<<<<<<<"; exit; }

# 12.Localization
    sed -i '/#en_US.UTF-8 UTF-8/a\en_US.UTF-8 UTF-8' /etc/locale.gen &&
    sed -i '/#en_US.UTF-8 UTF-8/d' /etc/locale.gen &&
    sed -i '/#zh_TW.UTF-8 UTF-8/a\zh_TW.UTF-8 UTF-8' /etc/locale.gen &&
    sed -i '/#zh_TW.UTF-8 UTF-8/d' /etc/locale.gen &&
    locale-gen &&
    echo "LANG=en_US.UTF-8" >> /etc/locale.conf &&
    echo "LC_CTYPE="zh_TW.UTF-8"" >> /etc/locale.conf &&
    echo "(O) 12.Localization" ||
  { echo "(X) 12.Localization <<<<<<<<<<"; exit; }

# 13.Network Configuration
    read -p "     Input your hostname : " hostname
    echo "$hostname" >> /etc/hostname &&
    echo "127.0.0.1   localhost" >> /etc/hosts &&
    echo "::1         localhost" >> /etc/hosts &&
    echo "127.0.1.1   $hostname.localdomain  $hostname" >> /etc/hosts &&
    echo "(O) 13.Network Configuration" ||
  { echo "(X) 13.Network Configuration <<<<<<<<<<"; exit; }

# 14.Set the root password
    echo "Input root password" &&
    passwd &&
    echo "(O) 14.Set the root password" ||
  { echo "(X) 14.Set the root password <<<<<<<<<<"; exit; }

# 15.Add users account
    read -p "     Input your username : " username
    useradd -m $username &&
    passwd $username &&
    sed -i '/root/a\$username ALL=(ALL) ALL' /etc/sudoers &&
    echo "(O) 15.Add users account" ||
  { echo "(X) 15.Add users account <<<<<<<<<<"; exit; }

# 16.systemd-boot Configuration
    bootctl --path=/boot install &&
    PARTUUID=$(blkid -o export /dev/nvme0n1p2 | grep PARTUUID) &&
    echo "title   Arch Linux"                 >> /boot/loader/entries/arch.conf &&
    echo "linux   /vmlinuz-linux"             >> /boot/loader/entries/arch.conf &&
    echo "initrd  /amd-ucode.img"             >> /boot/loader/entries/arch.conf &&
    echo "initrd  /initramfs-linux.img"       >> /boot/loader/entries/arch.conf &&
    echo "options root=PARTUUID=$PARTUUID rw" >> /boot/loader/entries/arch.conf &&
    echo "default arch" >> /boot/loader/loader.conf &&
    echo "timeout 4"    >> /boot/loader/loader.conf &&
    echo "editor no"    >> /boot/loader/loader.conf &&
    bootctl --path=/boot update &&
    echo "(O) 16.systemd-boot Configuration" ||
  { echo "(X) 16.systemd-boot Configuration <<<<<<<<<<"; exit; }
    bootctl status to check config
    
# 17.systemd-networkd Configuration
    mkdir /etc/systemd/network
    while [[ ! "$ACTION" =~ ^[eEwW]$ ]]; do
        read -n1 -p "     Which is your connection, Ethernet or WiFi ? [E/W]: " ACTION
        echo ""; done
            case $ACTION in
            [eE]) echo "[Match]"     >> /etc/systemd/network/20-dhcp.network &&
                  echo "Name=enp1s0" >> /etc/systemd/network/20-dhcp.network &&
                  echo ""            >> /etc/systemd/network/20-dhcp.network &&
                  echo "[Network]"   >> /etc/systemd/network/20-dhcp.network &&
                  echo "DHCP=ipv4"   >> /etc/systemd/network/20-dhcp.network &&
                  echo "(O) 17.systemd-networkd Configuration" ||
                { echo "(X) 17.systemd-networkd Configuration"; exit; }
                  ;;
            [wW]) echo "[Match]"     >> /etc/systemd/network/25-wireless.network &&
                  echo "Name=wlp2s0" >> /etc/systemd/network/25-wireless.network &&
                  echo ""            >> /etc/systemd/network/25-wireless.network &&
                  echo "[Network]"   >> /etc/systemd/network/25-wireless.network &&
                  echo "DHCP=ipv4"   >> /etc/systemd/network/25-wireless.network &&
                  echo "(O) 17.systemd-networkd Configuration" ||
                { echo "(X) 17.systemd-networkd Configuration"; exit; }
                  ;;
            esac

# 18.iwd Configuration
    if [ "$ACTION" = w ] || [ "$ACTION" = W ]; then
        echo "[General]"                       >> /etc/iwd/main.conf &&
        echo "EnableNetworkConfiguration=true" >> /etc/iwd/main.conf &&
        echo ""                                >> /etc/iwd/main.conf &&
        echo "[Network]"                       >> /etc/iwd/main.conf &&
        echo "NameResolvingService=systemd"    >> /etc/iwd/main.conf &&
        echo "(O) 18.iwd Configuration" ||
      { echo "(X) 18.iwd Configuration"; exit; }
    fi

# 19.Reboot
    echo ""
    read -n1 -p "Install sucessed, do you want to reboot ? [Y/N]: " ACTION
        case $ACTION in
        [yY]) exit
              umount -R /mnt
              reboot ;;
        esac
