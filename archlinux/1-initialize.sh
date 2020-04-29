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
    echo ""
    timedatectl set-ntp true &&
        echo "(O) 2.Update the system clock" ||
      { echo "(X) 2.Update the system clock <<<<<<<<<<"; exit; }

# 3.Identify UEFI/BIOS
    echo ""
    if find /sys/firmware/efi >> /dev/null; then
        echo "The computer support UEFI"
    else
        echo "The computer support BIOS only"
    fi

# 4.Partition the disks
    echo ""
    echo "Partition the disks"
    while [[ ! "$ACTION" =~ ^[yYnN]$ ]]; do
        read -n1 -p "Do you want to partition the disks? [Y/N]: " ACTION
        echo ""; done
            case $ACTION in
            [yY]) echo "Ctrl+C and fdisk disks"
                  exit ;;
            [nN]) echo "(O) 4.Partition the disks" ;;
            esac

# 5.Format the partitions
    echo ""
    echo "Format the partitions"
    echo "1.Desktop with 1*NVME + 2*HDD"
    echo "2.Laptop with 1*SSD"
    while [[ ! "$ACTION" =~ ^[123]$ ]]; do
        read -n1 -p "3.Custom : " ACTION
        echo ""; done
        case $ACTION in
        1)  mkfs.vfat /dev/nvme0n1p1 &&
            mkfs.ext4 /dev/nvme0n1p2 &&
            mkfs.ext4 /dev/sda1 &&
            mkfs.ext4 /dev/sdb1 &&
            echo "(O) 5.Format the partitions" ||
          { echo "(X) 5.Format the partitions <<<<<<<<<<"; exit; }
            ;;
        2)  mkfs.vfat /dev/sda1
            mkfs.ext4 /dev/sda2
            mkswap /dev/sda3
            swapon /dev/sda3
            echo "(O) 5.Format the partitions" ||
          { echo "(X) 5.Format the partitions <<<<<<<<<<"; exit; }
            ;;
        3)  echo "Ctrl+C and mkfs disks"
            exit
            ;;
        esac

# 6.Mount the file systems
    echo ""
    case $ACTION in
    1)  mount /dev/nvme0n1p2 /mnt &&
        mkdir /mnt/boot &&
        mount /dev/nvme0n1p1 /mnt/boot &&
        echo "(O) 6.Mount the file systems" ||
      { echo "(X) 6.Mount the file systems <<<<<<<<<<"; exit; }
        ;;
    2)  mount /dev/sda2 /mnt &&
        mkdir /mnt/boot &&
        mount /dev/sda1 /mnt/boot &&
        echo "(O) 6.Mount the file systems" ||
      { echo "(X) 6.Mount the file systems <<<<<<<<<<"; exit; }
        ;;
    esac

# 7.Select the mirrors
    echo ""
    sed -i '7i## Taiwan' /etc/pacman.d/mirrorlist &&
    sed -i '8iServer = http://ftp.tku.edu.tw/Linux/ArchLinux/$repo/os/$arch' /etc/pacman.d/mirrorlist &&
    echo "(O) 7.Select the mirrors" ||
  { echo "(X) 7.Select the mirrors <<<<<<<<<<"; exit; }

# 8.Install linux kernel & base packages
    echo ""
    pacstrap /mnt base linux linux-firmware &&
    echo "(O) 8.Install linux kernel & base packages" ||
  { echo "(X) 8.Install linux kernel & base packages <<<<<<<<<<"; exit; }

# 9.Generate fstab
    echo ""
    genfstab -U /mnt >> /mnt/etc/fstab &&
    cat /mnt/etc/fstab &&
    echo "(O) 9.Generate fstab" ||
  { echo "(X) 9.Generate fstab <<<<<<<<<<"; exit; }
    
# 10.Change root into the new system
    echo ""
    while [[ ! "$ACTION" =~ ^[yYnN]$ ]]; do
        read -n1 -p "Do you want to change root into the new system? [Y/N]: " ACTION
        echo ""; done
            case $ACTION in
            [yY]) cp /root/linux-master/archlinux/*.sh /mnt/opt
                  rm /root/script.zip
                  rm -r /root/linux-master
                  arch-chroot /mnt /opt/2-configure.sh
                  echo "(O) 10.Change root into the new system"
                  ;;
            [nN]) echo "(X) 10.Change root into the new system"
                  exit
                  ;;
            *) echo "(X) 10.Change root into the new system"
                  exit
                  ;;
            esac

# Reboot
    echo ""
    read -n1 -p "Install sucessed, do you want to reboot ? [Y/N]: " ACTION
        case $ACTION in
        [yY]) exit
              umount -R /mnt
              reboot ;;
        esac
