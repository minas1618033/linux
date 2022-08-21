#######################################################################################################################
##                                                    Arch Linux                                                     ##
##                                              INSTALLATION ASSISTANT                                       v1.7.0  ##
#######################################################################################################################
#
# This file is a script for installing Arch Linux using the live system booted from an official image on my PC & NB. 
#
#######################################################################################################################
###################################################   DIRECTORY   #####################################################
#######################################################################################################################
# |
# |STEP0 Pre-installation
# |-- 0-1.Download the image
# |-- 0-2.Verify the image signature
# |-- 0-3.Prepare an installation medium
# |-- 0-4.Reboot from the live usb
# |-- 0-5.Check the internet status
# |-- 0-6.Download the installation script
# |-- 0-7.Run the script
# |
# |STEP1 Install the system
# |-- 1-1.Connected to the Internet
# |-- 1-2.Update the system clock
# |-- 1-3.Identify UEFI/BIOS
# |-- 1-4.Partition the disks
# |-- 1-5.Mount the file systems
# |-- 1-6.Install linux kernel & base packages
# |-- 1-7.Generate fstab
# |-- 1-8.Change root into the new system
# |
# |STEP2 Configure the system
# |-- 2-1.Install essential packages
# |-- 2-2.Set the time zone
# |-- 2-3.Localization
# |-- 2-4.Network Configuration
# |-- 2-5.Set the root password
# |-- 2-6.Add users account
# |-- 2-7.systemd-boot Configuration
# |-- 2-8.systemd-networkd Configuration
# |-- 2-9.iwd Configuration
# |
# |STEP3 Configure the applications
# |-- 3-1.Enable network service
# |-- 3-2.Enable SSD Trim
# |-- 3-3.Automount disk partitions
# |-- 3-4.Add archlinuxcn repo
# |-- 3-5.Install applications from official repo
# |-- 3-6.Install applications from unofficial repo
#
#
#######################################################################################################################
############################################### STEP0 Pre-installation ################################################
#######################################################################################################################
#
#   0-1.Download the image from https://www.archlinux.org/download/
#
#   0-2.Verify the image signature by
#       # gpg --keyserver-options auto-key-retrieve --verify archlinux-version-x86_64.iso.sig
#         or
#       # pacman-key -v archlinux-version-x86_64.iso.sig
#
#   0-3.Prepare an installation medium
#       # dd bs=4M if=/path/to/archlinux.iso of=/dev/sdX status=progress && sync
#
#   0-4.Reboot from the live usb
#
#   0-5.Check the internet status
#       if use wireless network,use iwd to connect.
#       # iwctl station wlan0 connect CHT_24.G
#
#   0-6.Download the installation script
#       curl -o installation.sh https://raw.githubusercontent.com/minas1618033/linux/master/archlinux/installation-script.sh 
#
#   0-7.Run the script
#
#######################################################################################################################
############################################## STEP1 Install the system ###############################################
#######################################################################################################################

clear
umount -R /mnt >> /dev/null 2>&1
find ./log >> /dev/null 2>&1 && rm -i ./log
echo "
             $(tput setab 6)      Arch Linux      $(tput sgr 0)
             $(tput setaf 6)INSTALLATION ASSISTANT$(tput setaf 242)
                                           1.0.0
------------------------------------------------
      Copyright (c) 2020-2021 Zelko Rocha$(tput sgr 0)
"
# 1-1.Connected to the Internet
    ping -c 2 www.google.com > /dev/null &&
        echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-1.Connected to the Internet" | tee -a ./log ||
        echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-1.Connected to the Internet" | tee -a ./log 

# 1-2.Update the system clock
    echo
    timedatectl set-ntp true &&
    sleep 3s &&
        echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-2.Update the system clock" | tee -a ./log ||
        echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-2.Update the system clock" | tee -a ./log ;

# 1-3.Identify UEFI/BIOS
    echo
    find /sys/firmware/efi >> /dev/null 2>&1 &&
        echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-3.The computer support UEFI" | tee -a ./log ||
        echo "( $(tput setaf 2)!$(tput sgr 0) ) 1-3.The computer support BIOS only" | tee -a ./log
    
# 1-4.Partition the disks
    echo
    echo "   1.Default A (AMD Desktop: 1*NVME + 2*HDD)"
    echo "   2.Default B (Intel Laptop: 1*SSD)"
    echo "   3.Virtual Machine (UEFI: 1*SSD)"
    echo "   4.Virtual Machine (BIOS: 1*SSD)"
    echo "   5.AOMedia Video 1 Encoder Machine (Intel: 1*HDD)"
    echo "   6.Manual partitioning"
    echo
    read -p ":: Select disks PARTITIONING configuration : " PARTITION
    case $PARTITION in
        1)  echo
            echo "   1.Format ROOT partition only"
            echo "   2.Format ALL partitions"
            echo "   3.Repartition and format all partitions"
            echo
            read -p ":: Select disks FORMATING configuration : " ACTION
            echo
            case $ACTION in
                1)  mkfs.vfat /dev/nvme0n1p1 &&
                    mkfs.xfs /dev/nvme0n1p2 &&
                        echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log ||
                        echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log
                    ;;
                2)  mkfs.vfat /dev/nvme0n1p1 &&
                    mkfs.xfs /dev/nvme0n1p2 &&
                    mkfs.xfs /dev/sda1 &&
                    mkfs.xfs /dev/sdb1
                        echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log ||
                        echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log
                    ;;
                3)  parted -s /dev/nvme0n1 mklabel gpt &&
                    parted -s /dev/nvme0n1 mkpart "esp" fat32 '0%' 200MB &&
                    parted -s /dev/nvme0n1 set 1 esp on &&
                    parted -s /dev/nvme0n1 mkpart "root" xfs 200MiB '100%' &&
                    parted -s /dev/sda mklabel gpt &&
                    parted -s /dev/sda mkpart "disk2" xfs '0%' '100%' &&
                    parted -s /dev/sdb mklabel gpt &&
                    parted -s /dev/sdb mkpart "disk1" xfs '0%' '100%' &&
                    mkfs.vfat /dev/nvme0n1p1 &&
                    mkfs.xfs /dev/nvme0n1p2 &&
                    mkfs.xfs /dev/sda1 &&
                    mkfs.xfs /dev/sdb1 &&
                        echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log ||
                        echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log
                    ;;
            esac
            ;;
        2)  echo
            echo "   1.Format ROOT partition only"
            echo "   2.Repartition and format all partitions"
            echo
            read -p ":: Select disks FORMATING configuration : " ACTION
            echo
            case $ACTION in
                1)  mkfs.vfat /dev/sda1 &&
                    mkfs.xfs /dev/sda2
                        echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log ||
                        echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log
                    ;;
                2)  parted -s /dev/sda mklabel gpt &&
                    parted -s /dev/sda mkpart "esp" fat32 '0%' 300MB &&
                    parted -s /dev/sda set 1 esp on &&
                    parted -s /dev/sda mkpart "root" xfs 300MiB '100%' &&
                    mkfs.vfat /dev/sda1 &&
                    mkfs.xfs /dev/sda2 &&
                        echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log ||
                        echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log
                    ;;
            esac
            ;;
        3)  parted -s /dev/vda mklabel gpt &&
            parted -s /dev/vda mkpart "esp" fat32 '0%' 200MB &&
            parted -s /dev/vda set 1 esp on &&
            parted -s /dev/vda mkpart "root" xfs 200MiB '100%' &&
            mkfs.vfat /dev/sda1 &&
            mkfs.xfs /dev/sda2
                echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log ||
                echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log
            ;;
        4)  parted -s /dev/vda mkpart primary fat32 '0%' 200MB &&
            parted -s /dev/vda set 1 boot on &&
            parted -s /dev/vda mkpart primary xfs 200MiB '100%' &&
            mkfs.vfat /dev/vda1 &&
            mkfs.xfs /dev/vda2
                echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log ||
                echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log
            ;;
        5)  echo
            echo "   1.Format ROOT partition only"
            echo "   2.Repartition and format all partitions"
            echo
            read -p ":: Select disks FORMATING configuration : " ACTION
            echo
            case $ACTION in
                1)  mkfs.vfat /dev/sda1 &&
                    mkfs.xfs /dev/sda2
                        echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log ||
                        echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log
                    ;;
                2)  parted -s /dev/sda mklabel gpt &&
                    parted -s /dev/sda mkpart "esp" fat32 '0%' 300MB &&
                    parted -s /dev/sda set 1 esp on &&
                    parted -s /dev/sda mkpart "root" xfs 300MiB '99%' &&
                    parted -s /dev/sda mkpart "swap" linux-swap '99%' '100%' &&
                    mkfs.vfat /dev/sda1 &&
                    mkfs.xfs /dev/sda2 &&
                    mkswap /dev/sda3 &&
                    swapon /dev/sda3 &&
                        echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log ||
                        echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log
                    ;;
            esac
            ;;
        6)  parted
            exit
            ;;
    esac

# 1-5.Mount the file systems
    echo
    case $PARTITION in
    1)  mount /dev/nvme0n1p2 /mnt &&
        mkdir -p /mnt/boot &&
        mount /dev/nvme0n1p1 /mnt/boot &&
            echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-5.Mount the file systems" | tee -a ./log ||
            echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-5.Mount the file systems" | tee -a ./log
        ;;
    2)  mount /dev/sda2 /mnt &&
        mkdir -p /mnt/boot &&
        mount /dev/sda1 /mnt/boot &&
            echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-5.Mount the file systems" | tee -a ./log ||
            echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-5.Mount the file systems" | tee -a ./log
        ;;
    3)  mount /dev/vda2 /mnt &&
        mkdir -p /mnt/boot &&
        mount /dev/vda1 /mnt/boot &&
            echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-5.Mount the file systems" | tee -a ./log ||
            echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-5.Mount the file systems" | tee -a ./log
        ;;
    4)  mount /dev/vda2 /mnt &&
        mkdir -p /mnt/boot &&
        mount /dev/vda1 /mnt/boot &&
            echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-5.Mount the file systems" | tee -a ./log ||
            echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-5.Mount the file systems" | tee -a ./log
        ;;
    5)  mount /dev/sda2 /mnt &&
        mkdir -p /mnt/boot &&
        mount /dev/sda1 /mnt/boot &&
            echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-5.Mount the file systems" | tee -a ./log ||
            echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-5.Mount the file systems" | tee -a ./log
        ;;
    esac

# 1-6.Install linux kernel & base packages
    echo
    pacstrap /mnt base linux linux-firmware &&
        echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-7.Install linux kernel & base packages" | tee -a ./log ||
        echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-7.Install linux kernel & base packages" | tee -a ./log

# 1-7.Generate fstab
    echo
    genfstab -U /mnt >> /mnt/etc/fstab &&
    cat /mnt/etc/fstab &&
        echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-8.Generate fstab" | tee -a ./log ||
        echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-8.Generate fstab" | tee -a ./log

# 1-8.Change root into the new system
    echo
    cat ./log
    echo
    while [[ ! "$ACTION" =~ ^[yYnN]$ ]]; do
        read -n1 -p ":: Do you want to change root into the new system? [Y/N]: " ACTION
        echo ; done
            case $ACTION in
            [yY]) awk '/EOF/{f=0} f; /EOF/{f=1}' installation.sh >> /mnt/installation-step2.sh
            
#######################################################################################################################
############################################# STEP2 Configure the system ##############################################
#######################################################################################################################

                  :<<EOF
                    echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-9.Change root into the new system" | tee -a ./log
                    
                    # 2-1.Install essential packages
                        if grep -q "AMD" "/proc/cpuinfo"; then
                            pacman -S --noconfirm amd-ucode opendoas nano git xfsprogs zsh
                        else
                            pacman -S --noconfirm intel-ucode opendoas nano git zsh iwd
                        fi
                            echo "( $(tput setaf 2)O$(tput sgr 0) ) 2-1.Install essential packages" | tee -a ./log ||
                            echo "( $(tput setaf 1)X$(tput sgr 0) ) 2-1.Install essential packages" | tee -a ./log

                    # 2-2.Set the time zone
                        echo
                        ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime &&
                        hwclock --systohc &&
                            echo "( $(tput setaf 2)O$(tput sgr 0) ) 2-2.Set the time zone" | tee -a ./log ||
                            echo "( $(tput setaf 1)X$(tput sgr 0) ) 2-2.Set the time zone" | tee -a ./log

                    # 2-3.Localization
                        echo
                        sed -i '/#en_US.UTF-8 UTF-8/a\en_US.UTF-8 UTF-8' /etc/locale.gen &&
                        sed -i '/#en_US.UTF-8 UTF-8/d' /etc/locale.gen &&
                        sed -i '/#ja_JP.UTF-8 UTF-8/a\ja_JP.UTF-8 UTF-8' /etc/locale.gen &&
                        sed -i '/#ja_JP.UTF-8 UTF-8/d' /etc/locale.gen &&
                        sed -i '/#zh_CN.UTF-8 UTF-8/a\zh_CN.UTF-8 UTF-8' /etc/locale.gen &&
                        sed -i '/#zh_CN.UTF-8 UTF-8/d' /etc/locale.gen &&
                        sed -i '/#zh_TW.UTF-8 UTF-8/a\zh_TW.UTF-8 UTF-8' /etc/locale.gen &&
                        sed -i '/#zh_TW.UTF-8 UTF-8/d' /etc/locale.gen &&
                        locale-gen &&
                        echo "LANG=en_US.UTF-8" >> /etc/locale.conf &&
                        echo "LC_CTYPE="zh_TW.UTF-8"" >> /etc/locale.conf &&
                            echo "( $(tput setaf 2)O$(tput sgr 0) ) 2-3.Localization" | tee -a ./log ||
                            echo "( $(tput setaf 1)X$(tput sgr 0) ) 2-3.Localization" | tee -a ./log

                    # 2-4.Network Configuration
                        echo
                        read -p ":: Input your hostname : " hostname
                        echo "$hostname" >> /etc/hostname &&
                        echo "127.0.0.1   localhost" >> /etc/hosts &&
                        echo "::1         localhost" >> /etc/hosts &&
                        echo "127.0.1.1   $hostname.localdomain  $hostname" >> /etc/hosts &&
                            echo "( $(tput setaf 2)O$(tput sgr 0) ) 2-4.Network Configuration" | tee -a ./log ||
                            echo "( $(tput setaf 1)X$(tput sgr 0) ) 2-4.Network Configuration" | tee -a ./log

                    # 2-5.Set the root password
                        echo
                        echo ":: Set ROOT account password" &&
                        passwd || (echo "Pelease input again:"; echo; passwd) &&
                            echo "( $(tput setaf 2)O$(tput sgr 0) ) 2-5.Set the root password" | tee -a ./log ||
                            echo "( $(tput setaf 1)X$(tput sgr 0) ) 2-5.Set the root password" | tee -a ./log

                    # 2-6.Add users account
                        echo
                        read -p ":: Add your user account : " username
                        echo $username >> username.tmp
                        useradd -m $username -G wheel -s /bin/zsh &&
                        passwd $username || (echo "Pelease input again:"; echo; passwd $username) &&
                        echo "permit persist :wheel" >> /etc/doas.conf
                            echo "( $(tput setaf 2)O$(tput sgr 0) ) 2-6.Add users account" | tee -a ./log ||
                            echo "( $(tput setaf 1)X$(tput sgr 0) ) 2-6.Add users account" | tee -a ./log

                    # 2-7.systemd-boot Configuration
                        echo
                        if find /dev/sda1 >> /dev/null 2>&1; then
                            bootctl --path=/boot install
                            PARTUUID=$(blkid -o export /dev/nvme0n1p2 | grep PARTUUID) ||
                            PARTUUID=$(blkid -o export /dev/sda2 | grep PARTUUID)
                            
                            # Edit /boot/loader/entries/arch.conf
                            rm /boot/loader/entries/arch.conf
                            echo "title   Arch Linux"                 >> /boot/loader/entries/arch.conf &&
                            echo "linux   /vmlinuz-linux"             >> /boot/loader/entries/arch.conf &&
                            if grep -q "AMD" "/proc/cpuinfo"; then
                                echo "initrd  /amd-ucode.img"         >> /boot/loader/entries/arch.conf
                            else
                                echo "initrd  /intel-ucode.img"       >> /boot/loader/entries/arch.conf
                            fi
                            echo "initrd  /initramfs-linux.img"       >> /boot/loader/entries/arch.conf &&
                            echo "options root=$PARTUUID rw" >> /boot/loader/entries/arch.conf &&
                            
                            # Edit /boot/loader/loader.conf
                            sed -i '/default/d' /boot/loader/loader.conf &&
                            echo "default arch" >> /boot/loader/loader.conf &&
                            echo "timeout 4"    >> /boot/loader/loader.conf &&
                            echo "editor no"    >> /boot/loader/loader.conf &&
                            
                            # Edit /etc/pacman.d/hooks/100-systemd-boot.hook
                            mkdir /etc/pacman.d/hooks/
                            echo "[Trigger]"                           >> /etc/pacman.d/hooks/100-systemd-boot.hook &&
                            echo "Type = Package"                      >> /etc/pacman.d/hooks/100-systemd-boot.hook &&
                            echo "Operation = Upgrade"                 >> /etc/pacman.d/hooks/100-systemd-boot.hook &&
                            echo "Target = systemd"                    >> /etc/pacman.d/hooks/100-systemd-boot.hook &&
                            echo ""                                    >> /etc/pacman.d/hooks/100-systemd-boot.hook &&
                            echo "[Action]"                            >> /etc/pacman.d/hooks/100-systemd-boot.hook &&
                            echo "Description = Updating systemd-boot" >> /etc/pacman.d/hooks/100-systemd-boot.hook &&
                            echo "When = PostTransaction"              >> /etc/pacman.d/hooks/100-systemd-boot.hook &&
                            echo "Exec = /usr/bin/bootctl update"      >> /etc/pacman.d/hooks/100-systemd-boot.hook &&

                            bootctl --path=/boot update &&
                                echo "( $(tput setaf 2)O$(tput sgr 0) ) 2-7.systemd-boot configuration" | tee -a ./log ||
                                echo "( $(tput setaf 1)X$(tput sgr 0) ) 2-7.systemd-boot configuration" | tee -a ./log
                        else
                            mkinitcpio -p linux &&
                            pacman -S grub &&
                            grub-install --target=i386-pc --recheck /dev/vda &&
                            grub-mkconfig -o /boot/grub/grub.cfg &&
                                echo "( $(tput setaf 2)O$(tput sgr 0) ) 2-7.systemd-boot configuration" | tee -a ./log ||
                                echo "( $(tput setaf 1)X$(tput sgr 0) ) 2-7.systemd-boot configuration" | tee -a ./log
                        fi

                    # 2-8.systemd-networkd Configuration
                        echo
                        mkdir /etc/systemd/network
                        while [[ ! "$ACTION" =~ ^[eEwW]$ ]]; do
                            read -n1 -p ":: Which is your connection, Ethernet or WiFi ? [E/W]: " ACTION
                            echo ; done
                                case $ACTION in
                                [eE]) echo "[Match]"   >> /etc/systemd/network/20-wired.network &&
                                    echo "Name=enp*"   >> /etc/systemd/network/20-wired.network &&
                                    echo ""            >> /etc/systemd/network/20-wired.network &&
                                    echo "[Network]"   >> /etc/systemd/network/20-wired.network &&
                                    echo "DHCP=true"   >> /etc/systemd/network/20-wired.network &&
                                        echo "( $(tput setaf 2)O$(tput sgr 0) ) 2-8.systemd-networkd Configuration" | tee -a ./log ||
                                        echo "( $(tput setaf 1)X$(tput sgr 0) ) 2-8.systemd-networkd Configuration" | tee -a ./log
                                    ;;
                                [wW]) echo "[Match]"   >> /etc/systemd/network/20-wired.network &&
                                    echo "Name=enp*"   >> /etc/systemd/network/20-wired.network &&
                                    echo ""            >> /etc/systemd/network/20-wired.network &&
                                    echo "[Network]"   >> /etc/systemd/network/20-wired.network &&
                                    echo "DHCP=true"   >> /etc/systemd/network/20-wired.network &&
                                    echo "[Match]"     >> /etc/systemd/network/25-wireless.network &&
                                    echo "Name=wlp*"   >> /etc/systemd/network/25-wireless.network &&
                                    echo ""            >> /etc/systemd/network/25-wireless.network &&
                                    echo "[Network]"   >> /etc/systemd/network/25-wireless.network &&
                                    echo "DHCP=true"   >> /etc/systemd/network/25-wireless.network &&
                                        echo "( $(tput setaf 2)O$(tput sgr 0) ) 2-8.systemd-networkd Configuration" | tee -a ./log ||
                                        echo "( $(tput setaf 1)X$(tput sgr 0) ) 2-8.systemd-networkd Configuration" | tee -a ./log
                                    ;;
                                esac

                    # 2-9.iwd Configuration
                        echo
                        if [ "$ACTION" = w ] || [ "$ACTION" = W ]; then
                            mkdir /etc/iwd
                            echo "[General]"                       >> /etc/iwd/main.conf &&
                            echo "EnableNetworkConfiguration=true" >> /etc/iwd/main.conf &&
                            echo ""                                >> /etc/iwd/main.conf &&
                            echo "[Network]"                       >> /etc/iwd/main.conf &&
                            echo "NameResolvingService=systemd"    >> /etc/iwd/main.conf &&
                                echo "( $(tput setaf 2)O$(tput sgr 0) ) 2-9.Wireless network configuration" | tee -a ./log ||
                                echo "( $(tput setaf 1)X$(tput sgr 0) ) 2-9.Wireless network configuration" | tee -a ./log
                        else
                                echo "( $(tput setaf 2)O$(tput sgr 0) ) 2-9.Wireless network configuration (ignored)" | tee -a ./log
                        fi

                    exit
EOF
                  arch-chroot /mnt /bin/bash installation-step2.sh
                  ;;
            [nN]) echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-9.Change root into the new system" | tee -a ./log
                  exit
                  ;;
            *)    echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-9.Change root into the new system" | tee -a ./log
                  exit
                  ;;
            esac

# 2-10.Check installation status
    echo "


             $(tput setaf 6)INSTALLATION FINISHED$(tput setaf 242)


" 
    cat /mnt/log >> ./log
    rm -f /mnt/log
    rm -f /mnt/installation-step2.sh
    cat ./log
    
    function configuration() {
    
#######################################################################################################################
############################################# STEP3 Configure the applications ########################################
#######################################################################################################################

        # 3-1.Enable network service
        doas systemctl start systemd-networkd
        doas systemctl enable systemd-networkd
        doas systemctl start systemd-resolved
        doas systemctl enable systemd-resolved
        doas ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
        doas mkdir /etc/systemd/resolved.conf.d
        doas sh -c "echo '[Resolve]'           >> /etc/systemd/resolved.conf.d/dnssec.conf"
        doas sh -c "echo 'DNS = 2606:4700:4700::1111' >> /etc/systemd/resolved.conf.d/dnssec.conf"
        doas sh -c "echo 'DNSSEC = true'   >> /etc/systemd/resolved.conf.d/dnssec.conf"
        doas sh -c "echo 'DNSOverTLS = true'       >> /etc/systemd/resolved.conf.d/dnssec.conf"
        doas sh -c "echo 'Cache = true'        >> /etc/systemd/resolved.conf.d/dnssec.conf"

        doas sh -c "echo '[Resolve]'                     >> /etc/systemd/resolved.conf.d/fallback_dns.conf"
        doas sh -c "echo 'FallbackDNS = 101.101.101.101' >> /etc/systemd/resolved.conf.d/fallback_dns.conf"
        doas sh -c "echo 'FallbackDNS = 1.1.1.1'         >> /etc/systemd/resolved.conf.d/fallback_dns.conf"
        doas sh -c "echo 'FallbackDNS = 168.95.1.1'      >> /etc/systemd/resolved.conf.d/fallback_dns.conf"
        doas sh -c "echo 'FallbackDNS = 8.8.8.8'         >> /etc/systemd/resolved.conf.d/fallback_dns.conf"
        
        if pacman -Qs iwd ; then
            doas systemctl start iwd
            doas systemctl enable iwd
            doas iwctl wlan0 scan
            doas iwctl wlan0 connect CHT_2.4G
        fi
        
        echo "Checking your connection status......"
        sleep 3s
        ping -c 3 www.google.com > /dev/null &&
        echo "( $(tput setaf 2)O$(tput sgr 0) ) 3-1.Enable network service" | tee -a ./log ||
        echo "( $(tput setaf 1)X$(tput sgr 0) ) 3-1.Enable network service" | tee -a ./log

        # 3-2.Enable SSD Trim
        doas systemctl enable fstrim.timer &&
        echo "( $(tput setaf 2)O$(tput sgr 0) ) 3-2.Enable SSD Trim" | tee -a ./log ||
        echo "( $(tput setaf 1)X$(tput sgr 0) ) 3-2.Enable SSD Trim" | tee -a ./log 

        # 3-3.Automount disk partitions ('ls -lh /dev/disk/by-uuid' or 'lsblk -f' to find UUID) ---------------------------------------------------------
        #    # /dev/nvme0n1p1
        #    UUID={UUID} /boot/efi vfat rw,noatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro 0 2
        #    # /dev/nvme0n1p2
        #    UUID={UUID} / xfs defaults,noatime 0 1
        #    # /dev/sdb1
        #    UUID={UUID} /home/zelko/Downloads ext4 defaults,noatime 0 2
        #    # /dev/sda1
        #    UUID={UUID} /home/zelko/Purple ext4 defaults,noatime 0 2
        echo "( $(tput setaf 2)!$(tput sgr 0) ) 3-3.Automount disk partitions" | tee -a ./log ||
        echo "( $(tput setaf 1)X$(tput sgr 0) ) 3-3.Automount disk partitions" | tee -a ./log 
        
        # 3-4.Add archlinuxcn repo
        # doas sh -c "echo '' >> /etc/pacman.conf"
        # doas sh -c "echo '[archlinuxcn]' >> /etc/pacman.conf"
        # doas sh -c "echo 'Server = https://repo.archlinuxcn.org/\$arch' >> /etc/pacman.conf"
        
        doas pacman -Syyu || doas pacman -Syyu
        # doas pacman -S --noconfirm archlinuxcn-keyring &&
        # echo "( $(tput setaf 2)O$(tput sgr 0) ) 21.Add archlinuxcn repo" | tee -a ./log ||
        # echo "( $(tput setaf 1)X$(tput sgr 0) ) 21.Add archlinuxcn repo" | tee -a ./log 

        # printf "\nContinue to install applications? [Y/N] "
        # read -n1 action
        # echo
        #     case $action in
        #         [Nn]) exit ;;
        #         [Yy]) break ;;
        #         *) exit ;;
        #     esac

        # 3-5.Install applications from official repo
        
        ## 3-5-1.GPU driver, font and plasma desktop
        doas pacman -S --noconfirm --needed noto-fonts
        doas pacman -S --noconfirm --needed noto-fonts-cjk
        doas pacman -S --noconfirm --needed xorg-server
        doas pacman -S --noconfirm --needed nvidia
        doas pacman -S --noconfirm --needed breeze
        doas pacman -S --noconfirm --needed breeze-gtk
        doas pacman -S --noconfirm --needed drkonqi
        doas pacman -S --noconfirm --needed kde-gtk-config
        doas pacman -S --noconfirm --needed kdeplasma-addons
        doas pacman -S --noconfirm --needed kinfocenter
        doas pacman -S --noconfirm --needed kwrited
        doas pacman -S --noconfirm --needed plasma-desktop
        doas pacman -S --noconfirm --needed plasma-disks
        doas pacman -S --noconfirm --needed plasma-integration
        doas pacman -S --noconfirm --needed plasma-pa
        doas pacman -S --noconfirm --needed plasma-systemmonitor
        doas pacman -S --noconfirm --needed plasma-workspace
        doas pacman -S --noconfirm --needed sddm-kcm
        doas pacman -S --noconfirm --needed user-manager
        #doas pacman -S --noconfirm --needed bluedevil
        #doas pacman -S --noconfirm --needed kaccounts-providers
        #doas pacman -S --noconfirm --needed kdenetwork-filesharing
        #doas pacman -S --noconfirm --needed khotkeys
        #doas pacman -S --noconfirm --needed kscreen
        
        ## 3-5-2.System
        doas pacman -S --noconfirm --needed cronie
        doas pacman -S --noconfirm --needed exfatprogs
        doas pacman -S --noconfirm --needed fcitx5-im
        doas pacman -S --noconfirm --needed fcitx5-chewing
        doas pacman -S --noconfirm --needed kdialog
        doas pacman -S --noconfirm --needed konsole
        doas pacman -S --noconfirm --needed ksystemlog
        doas pacman -S --noconfirm --needed nftables
        doas pacman -S --noconfirm --needed partitionmanager
        doas pacman -S --noconfirm --needed samba
        doas pacman -S --noconfirm --needed xdg-user-dirs
        doas pacman -S --noconfirm --needed yakuake
        doas pacman -S --noconfirm --needed zsh-theme-powerlevel10k
        #doas pacman -S --noconfirm --needed cups
        #doas pacman -S --noconfirm --needed firewalld
        #doas pacman -S --noconfirm --needed ibus
        #doas pacman -S --noconfirm --needed xdg-desktop-portal-kde ----> flatpak depend
        
        ## 3-5-3.Utillities
        doas pacman -S --noconfirm --needed ark
        doas pacman -S --noconfirm --needed bottom
        doas pacman -S --noconfirm --needed code
        doas pacman -S --noconfirm --needed dolphin
        doas pacman -S --noconfirm --needed kate
        doas pacman -S --noconfirm --needed kcalc
        doas pacman -S --noconfirm --needed keepassxc
        doas pacman -S --noconfirm --needed kompare
        doas pacman -S --noconfirm --needed krename
        doas pacman -S --noconfirm --needed p7zip
        doas pacman -S --noconfirm --needed perl-rename
        doas pacman -S --noconfirm --needed rclone
        doas pacman -S --noconfirm --needed rsync
        doas pacman -S --noconfirm --needed spectacle
        doas pacman -S --noconfirm --needed unrar
        #doas pacman -S --noconfirm --needed bleachbit
        #doas pacman -S --noconfirm --needed crow-translate
        #doas pacman -S --noconfirm --needed dolphin-plugins ----> netdrive and git control
        #doas pacman -S --noconfirm --needed kfind
        #doas pacman -S --noconfirm --needed kio-fuse
        #doas pacman -S --noconfirm --needed ktimer
        #doas pacman -S --noconfirm --needed unzip-natspec
        
        ## 3-5-4.Office applications
        doas pacman -S --noconfirm --needed libreoffice-still
        doas pacman -S --noconfirm --needed libreoffice-still-zh-tw
        doas pacman -S --noconfirm --needed markdownpart
        doas pacman -S --noconfirm --needed okular
        doas pacman -S --noconfirm --needed pcsclite
        doas pacman -S --noconfirm --needed skanlite
        
        ## 3-5-5.Internet applications
        doas pacman -S --noconfirm --needed baidupcs-go
        doas pacman -S --noconfirm --needed opera
        doas pacman -S --noconfirm --needed opera-ffmpeg-codecs
        doas pacman -S --noconfirm --needed profile-sync-daemon
        doas pacman -S --noconfirm --needed telegram-desktop
        doas pacman -S --noconfirm --needed youtube-dl
        #doas pacman -S --noconfirm --needed caprine  -------------> FB Messenger app
        #doas pacman -S --noconfirm --needed clipgrab  ------------> Videosites downloader
        #doas pacman -S --noconfirm --needed firefox
        
        ## 3-5-6.Media applications
        doas pacman -S --noconfirm --needed gimp
        doas pacman -S --noconfirm --needed imagemagick
        doas pacman -S --noconfirm --needed kdegraphics-thumbnailers
        doas pacman -S --noconfirm --needed mpg123
        doas pacman -S --noconfirm --needed mpv
        doas pacman -S --noconfirm --needed opusfile
        doas pacman -S --noconfirm --needed pulseaudio-alsa
        doas pacman -S --noconfirm --needed qmmp
        #doas pacman -S --noconfirm --needed converseen  ----------> Image converter app
        #doas pacman -S --noconfirm --needed faad2  ---------------> qmmp AAC plugin
        #doas pacman -S --noconfirm --needed k3b  -----------------> CD burning app
        #doas pacman -S --noconfirm --needed kdenlive
        #doas pacman -S --noconfirm --needed kid3
        #doas pacman -S --noconfirm --needed kolourpaint
        #doas pacman -S --noconfirm --needed libmpcdec  -----------> qmmp MusePack plugin
        #doas pacman -S --noconfirm --needed libva-vdpau-driver ---> vlc plugin
        #doas pacman -S --noconfirm --needed pulseaudio-bluetooth
        #doas pacman -S --noconfirm --needed qt5-imageformats
        
        ## 3-5-7.Virtualization applications
        #doas pacman -S --noconfirm --needed qemu
        #doas pacman -S --noconfirm --needed edk2-ovmf
        #doas pacman -S --noconfirm --needed virt-manager
        #doas pacman -S virtualbox

        ## 3-6.Install applications from unofficial repo
        # doas pacman -S --noconfirm --needed anydesk-bin
        # doas pacman -S --noconfirm --needed kde-servicemenus-rootactions
        # doas pacman -S --noconfirm --needed freetube
        # doas pacman -S --noconfirm --needed megatools
        # doas pacman -S --noconfirm --needed plasmafox
        # doas pacman -S --noconfirm --needed qbittorrent-enhanced-git
        # doas pacman -S --noconfirm --needed qt-avif-image-plugin-git ---> qview plugin
        # doas pacman -S --noconfirm --needed qt5-heif-git ---------------> qview plugin
        # doas pacman -S --noconfirm --needed qview
        # doas pacman -S --noconfirm --needed rclone-browser
        # doas pacman -S --noconfirm --needed safeeyes
        # doas pacman -S --noconfirm --needed ttf-meslo-nerd-font-powerlevel10k
        # doas pacman -S --noconfirm --needed wine-x64
        ### doas pacman -S --noconfirm --needed ezusb (driver for EZ100PU)
        ### doas pacman -S --noconfirm --needed ibus-libzhuyin
        ### doas pacman -S --noconfirm --needed jellyfin
        ### doas pacman -S --noconfirm --needed jellyfin-server
        ### doas pacman -S --noconfirm --needed jellyfin-web
        ### doas pacman -S --noconfirm --needed ksnip
        ### doas pacman -S --noconfirm --needed megacmd-bin
        ### doas pacman -S --noconfirm --needed ms-office-online
        ### doas pacman -S --noconfirm --needed powerdevil-light
        ### doas pacman -S --noconfirm --needed tiny-media-manager
        ### doas pacman -S --noconfirm --needed ventoy-bin

        ## 3-7-1.Encoder System
        # doas pacman -S --noconfirm --needed mesa
        ### doas pacman -S --noconfirm --needed vulkan-intel xf86-video-intel lib32-mesa
        # doas pacman -S --noconfirm --needed xfce4 xorg
        
        ## 3-7-2.AOMedia Video 1 applications
        # doas pacman -S --noconfirm --needed av1an mkvtoolnix-cli vapoursynth-plugin-lsmashsource
        # yay -S aom-psy-git aom-av1-psy-git

        ### doas sh ./config/sophos-antivirus-free/install.sh
        # doas pacman -Rsn --noconfirm xdg-user-dirs
        doas systemctl start nftables.service
        doas systemctl enable nftables.service
        doas systemctl enable sddm
        # doas systemctl start libvirtd.service
        # doas systemctl enable libvirtd.service
    }
    
    echo
    read -n1 -p ":: Reboot now? " ACTION
    case $ACTION in
        [yY]) username=$(cat /mnt/username.tmp)
              type configuration >> /mnt/home/$username/configuration.sh
              rm /mnt/username.tmp
              mv installation.sh /mnt/home/$username/
              reboot ;;
        [nN]) exit ;;
    esac



############## SCRIPT END ############################################################################


###  Add Taiwan repo mirrors
###     sed -i '11iServer = https://archlinux.ccns.ncku.edu.tw/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
###     sed -i '12iServer = http://archlinux.cs.nctu.edu.tw/$repo/os/$arch' /etc/pacman.d/mirrorlist

###  Install applications from AUR repo
###     git clone https://aur.archlinux.org/trizen.git
###     cd trizen
###     makepkg -si

###  pacman ERROR: One or more PGP signatures could not be verified
###     gpg --keyserver keys.gnupg.net --recv-keys <key>

###  pacman ERROR: failed to update (unable to lock database)
###     doas rm /var/lib/pacman/db.lck
