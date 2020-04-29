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
    echo ""
    echo "    Partition the disks"
    while [[ ! "$ACTION" =~ ^[yYnN]$ ]]; do
        read -n1 -p "    Do you want to partition the disks? [Y/N]: " ACTION
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
        echo ""; done
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
    sed -i '7i## Taiwan' /etc/pacman.d/mirrorlist &&
    sed -i '8iServer = http://ftp.tku.edu.tw/Linux/ArchLinux/$repo/os/$arch' /etc/pacman.d/mirrorlist &&
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
            [yY]) cp /root/linux-master/archlinux/*.sh /mnt/opt
                  rm /root/script.zip
                  rm -r /root/linux-master
                  arch-chroot /mnt /opt/2-configure.sh
                  echo "(O) 9.Change root into the new system"
                  ;;
            [nN]) echo "(X) 9.Change root into the new system"
                  exit
                  ;;
            *) echo "(X) 9.Change root into the new system"
                  exit
                  ;;
            esac

# 19.Reboot
    echo ""
    read -n1 -p "Install sucessed, do you want to reboot ? [Y/N]: " ACTION
        case $ACTION in
        [yY]) exit
              umount -R /mnt
              reboot ;;
        esac
