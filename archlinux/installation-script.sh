#######################################################################################################################
##                                                    Arch Linux                                                     ##
##                                              INSTALLATION ASSISTANT                                       v1.0.0  ##
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
# |-- 1-6.Select the mirrors
# |-- 1-7.Install linux kernel & base packages
# |-- 1-8.Generate fstab
# |-- 1-9.Change root into the new system
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
# |-- 3-5.Install GPU driver, font and plasma desktop
# |-- 3-6.Install applications from official repo
# |-- 3-7.Install applications from archlinuxcn repo
# |-- 3-8.Install applications from aur repo
# |-- 
# |-- 
# |-- 
# |-- 
# |-- 
# |-- 
# |-- 

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
    echo "   5.Manual partitioning"
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
                    mkfs.ext4 /dev/nvme0n1p2 &&
                        echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log ||
                        echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log
                    ;;
                2)  mkfs.vfat /dev/nvme0n1p1 &&
                    mkfs.ext4 /dev/nvme0n1p2 &&
                    mkfs.ext4 /dev/sda1 &&
                    mkfs.ext4 /dev/sdb1
                        echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log ||
                        echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log
                    ;;
                3)  parted -s /dev/nvme0n1 mklabel gpt &&
                    parted -s /dev/nvme0n1 mkpart "esp" fat32 '0%' 300MB &&
                    parted -s /dev/nvme0n1 set 1 esp on &&
                    parted -s /dev/nvme0n1 mkpart "root" ext4 300MiB '100%' &&
                    parted -s /dev/sda mklabel gpt &&
                    parted -s /dev/sda mkpart "2000G" ext4 '0%' '100%' &&
                    parted -s /dev/sdb mklabel gpt &&
                    parted -s /dev/sdb mkpart "500G" ext4 '0%' '100%' &&
                    mkfs.vfat /dev/nvme0n1p1 &&
                    mkfs.ext4 /dev/nvme0n1p2 &&
                    mkfs.ext4 /dev/sda1 &&
                    mkfs.ext4 /dev/sdb1 &&
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
                    mkfs.ext4 /dev/sda2
                        echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log ||
                        echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log
                    ;;
                2)  parted -s /dev/sda mklabel gpt &&
                    parted -s /dev/sda mkpart "esp" fat32 '0%' 300MB &&
                    parted -s /dev/sda set 1 esp on &&
                    parted -s /dev/sda mkpart "root" ext4 300MiB '100%' &&
                    mkfs.vfat /dev/sda1 &&
                    mkfs.ext4 /dev/sda2 &&
                        echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log ||
                        echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log
                    ;;
            esac
            ;;
        3)  parted -s /dev/vda mklabel gpt &&
            parted -s /dev/vda mkpart "esp" fat32 '0%' 200MB &&
            parted -s /dev/vda set 1 esp on &&
            parted -s /dev/vda mkpart "root" ext4 200MiB '100%' &&
            mkfs.vfat /dev/sda1 &&
            mkfs.ext4 /dev/sda2
                echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log ||
                echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log
            ;;
        4)  parted -s /dev/vda mkpart primary fat32 '0%' 200MB &&
            parted -s /dev/vda set 1 boot on &&
            parted -s /dev/vda mkpart primary ext4 200MiB '100%' &&
            mkfs.vfat /dev/vda1 &&
            mkfs.ext4 /dev/vda2
                echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log ||
                echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-4.Partition & foemat the disks" | tee -a ./log
            ;;
        5)  parted
            exit
            ;;
    esac

# 1-5.Mount the file systems
    echo
    case $PARTITION in
    1)  mount /dev/nvme0n1p2 /mnt &&
        mkdir /mnt/boot &&
        mount /dev/nvme0n1p1 /mnt/boot &&
            echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-5.Mount the file systems" | tee -a ./log ||
            echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-5.Mount the file systems" | tee -a ./log
        ;;
    2)  mount /dev/sda2 /mnt &&
        mkdir /mnt/boot &&
        mount /dev/sda1 /mnt/boot &&
            echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-5.Mount the file systems" | tee -a ./log ||
            echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-5.Mount the file systems" | tee -a ./log
        ;;
    2)  mount /dev/vda2 /mnt &&
        mkdir /mnt/boot &&
        mount /dev/vda1 /mnt/boot &&
            echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-5.Mount the file systems" | tee -a ./log ||
            echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-5.Mount the file systems" | tee -a ./log
        ;;
    2)  mount /dev/vda2 /mnt &&
        mkdir /mnt/boot &&
        mount /dev/vda1 /mnt/boot &&
            echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-5.Mount the file systems" | tee -a ./log ||
            echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-5.Mount the file systems" | tee -a ./log
        ;;
    esac

# 1-6.Select the mirrors
    echo
    sed -i '11iServer = https://archlinux.ccns.ncku.edu.tw/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist &&
    sed -i '12iServer = http://archlinux.cs.nctu.edu.tw/$repo/os/$arch' /etc/pacman.d/mirrorlist &&
        echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-6.Select the mirrors" | tee -a ./log ||
        echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-6.Select the mirrors" | tee -a ./log

# 1-7.Install linux kernel & base packages
    echo
    pacstrap /mnt base linux linux-firmware &&
        echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-7.Install linux kernel & base packages" | tee -a ./log ||
        echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-7.Install linux kernel & base packages" | tee -a ./log

# 1-8.Generate fstab
    echo
    genfstab -U /mnt >> /mnt/etc/fstab &&
    cat /mnt/etc/fstab &&
        echo "( $(tput setaf 2)O$(tput sgr 0) ) 1-8.Generate fstab" | tee -a ./log ||
        echo "( $(tput setaf 1)X$(tput sgr 0) ) 1-8.Generate fstab" | tee -a ./log

# 1-9.Change root into the new system
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
                            pacman -S --noconfirm amd-ucode sudo nano git
                        else
                            pacman -S --noconfirm intel-ucode sudo nano git iwd
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
                        passwd &&
                            echo "( $(tput setaf 2)O$(tput sgr 0) ) 2-5.Set the root password" | tee -a ./log ||
                            echo "( $(tput setaf 1)X$(tput sgr 0) ) 2-5.Set the root password" | tee -a ./log

                    # 2-6.Add users account
                        echo
                        read -p ":: Add your user account : " username
                        echo $username >> username.tmp
                        useradd -m $username &&
                        passwd $username &&
                        sed -i "/root/a $username ALL=(ALL) ALL" /etc/sudoers &&
                            echo "( $(tput setaf 2)O$(tput sgr 0) ) 2-6.Add users account" | tee -a ./log ||
                            echo "( $(tput setaf 1)X$(tput sgr 0) ) 2-6.Add users account" | tee -a ./log

                    # 2-7.systemd-boot Configuration
                        echo
                        bootctl --path=/boot install &&
                        if find /dev/nvme0n1 >> /dev/null 2>&1; then
                            PARTUUID=$(blkid -o export /dev/nvme0n1p2 | grep PARTUUID)
                        if find /dev/sda1 >> /dev/null 2>&1; then
                            PARTUUID=$(blkid -o export /dev/sda2 | grep PARTUUID)
                        if find /dev/vda1 >> /dev/null 2>&1; then
                            PARTUUID=$(blkid -o export /dev/vda2 | grep PARTUUID)
                        fi
                        
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

                    # 2-8.systemd-networkd Configuration
                        echo
                        mkdir /etc/systemd/network
                        while [[ ! "$ACTION" =~ ^[eEwW]$ ]]; do
                            read -n1 -p ":: Which is your connection, Ethernet or WiFi ? [E/W]: " ACTION
                            echo ; done
                                case $ACTION in
                                [eE]) echo "[Match]"     >> /etc/systemd/network/20-dhcp.network &&
                                    echo "Name=enp*" >> /etc/systemd/network/20-dhcp.network &&
                                    echo ""            >> /etc/systemd/network/20-dhcp.network &&
                                    echo "[Network]"   >> /etc/systemd/network/20-dhcp.network &&
                                    echo "DHCP=true"   >> /etc/systemd/network/20-dhcp.network &&
                                        echo "( $(tput setaf 2)O$(tput sgr 0) ) 2-8.systemd-networkd Configuration" | tee -a ./log ||
                                        echo "( $(tput setaf 1)X$(tput sgr 0) ) 2-8.systemd-networkd Configuration" | tee -a ./log
                                    ;;
                                [wW]) echo "[Match]"     >> /etc/systemd/network/20-dhcp.network &&
                                    echo "Name=enp*" >> /etc/systemd/network/20-dhcp.network &&
                                    echo ""            >> /etc/systemd/network/20-dhcp.network &&
                                    echo "[Network]"   >> /etc/systemd/network/20-dhcp.network &&
                                    echo "DHCP=true"   >> /etc/systemd/network/20-dhcp.network &&
                                    echo "[Match]"     >> /etc/systemd/network/25-wireless.network &&
                                    echo "Name=wlp*" >> /etc/systemd/network/25-wireless.network &&
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
        sudo systemctl start systemd-networkd
        sudo systemctl enable systemd-networkd
        sudo systemctl start systemd-resolved
        sudo systemctl enable systemd-resolved
        sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
        sudo mkdir /etc/systemd/resolved.conf.d
        sudo sh -c "echo '[Resolve]' >> /etc/systemd/resolved.conf.d/dnssec.conf"
        sudo sh -c "echo 'DNSOverTLS = true' >> /etc/systemd/resolved.conf.d/dnssec.conf"
        sudo sh -c "echo 'DNSSEC = false' >> /etc/systemd/resolved.conf.d/dnssec.conf"
        sudo sh -c "echo 'Cache = true' >> /etc/systemd/resolved.conf.d/dnssec.conf"

        if pacman -Qs iwd ; then
            sudo systemctl start iwd
            sudo systemctl enable iwd
            sudo iwctl wlan0 scan
            sudo iwctl wlan0 connect CHT_2.4G
        fi
        
        ping -c 3 www.google.com > /dev/null &&
        echo "( $(tput setaf 2)O$(tput sgr 0) ) 3-1.Enable network service" | tee -a ./log ||
        echo "( $(tput setaf 1)X$(tput sgr 0) ) 3-1.Enable network service" | tee -a ./log

        # 3-2.Enable SSD Trim
        sudo systemctl enable fstrim.timer &&
        echo "( $(tput setaf 2)O$(tput sgr 0) ) 3-2.Enable SSD Trim" | tee -a ./log ||
        echo "( $(tput setaf 1)X$(tput sgr 0) ) 3-2.Enable SSD Trim" | tee -a ./log 

        # 3-3.Automount disk partitions ('ls -lh /dev/disk/by-uuid' or 'lsblk -f' to find UUID) ---------------------------------------------------------
        #    # /dev/nvme0n1p1
        #    UUID={UUID} /boot/efi vfat rw,noatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro 0 2
        #    # /dev/nvme0n1p2
        #    UUID={UUID} / ext4 defaults,noatime 0 1
        #    # /dev/sdb1
        #    UUID={UUID} /home/zelko/Downloads ext4 defaults,noatime 0 2
        #    # /dev/sda1
        #    UUID={UUID} /home/zelko/Purple ext4 defaults,noatime 0 2
        echo "( $(tput setaf 2)!$(tput sgr 0) ) 3-3.Automount disk partitions" | tee -a ./log ||
        echo "( $(tput setaf 1)X$(tput sgr 0) ) 3-3.Automount disk partitions" | tee -a ./log 
        
        # 3-4.Add archlinuxcn repo
        # sudo sh -c "echo '' >> /etc/pacman.conf"
        # sudo sh -c "echo '[archlinuxcn]' >> /etc/pacman.conf"
        # sudo sh -c "echo 'Server = https://repo.archlinuxcn.org/\$arch' >> /etc/pacman.conf"
        sudo pacman -Syyu
        # sudo pacman -S --noconfirm archlinuxcn-keyring &&
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

        # 3-5.Install GPU driver, font and plasma desktop
        sudo pacman -S --noconfirm --needed noto-fonts
        sudo pacman -S --noconfirm --needed xorg-server
        sudo pacman -S --noconfirm --needed nvidia
        sudo pacman -S --noconfirm --needed breeze
        sudo pacman -S --noconfirm --needed breeze-gtk
        sudo pacman -S --noconfirm --needed drkonqi
        sudo pacman -S --noconfirm --needed kde-gtk-config
        sudo pacman -S --noconfirm --needed kdeplasma-addons
        sudo pacman -S --noconfirm --needed kinfocenter
        sudo pacman -S --noconfirm --needed ksysguard
        sudo pacman -S --noconfirm --needed plasma-desktop
        sudo pacman -S --noconfirm --needed plasma-integration
        sudo pacman -S --noconfirm --needed plasma-pa
        sudo pacman -S --noconfirm --needed plasma-workspace
        sudo pacman -S --noconfirm --needed sddm-kcm
        sudo pacman -S --noconfirm --needed user-manager

        # 3-6.Install applications from official repo
        sudo pacman -S --noconfirm --needed ark
        sudo pacman -S --noconfirm --needed baidupcs-go
        # sudo pacman -S --noconfirm --needed binutils
        sudo pacman -S --noconfirm --needed bleachbit
        sudo pacman -S --noconfirm --needed code
        sudo pacman -S --noconfirm --needed cronie
        sudo pacman -S --noconfirm --needed dolphin
        sudo pacman -S --noconfirm --needed exfatprogs
        # sudo pacman -S --noconfirm --needed fakeroot
        sudo pacman -S --noconfirm --needed firefox
        sudo pacman -S --noconfirm --needed gimp
        sudo pacman -S --noconfirm --needed gnome-boxes
        sudo pacman -S --noconfirm --needed ibus
        sudo pacman -S --noconfirm --needed kate
        sudo pacman -S --noconfirm --needed kcalc
        sudo pacman -S --noconfirm --needed kdegraphics-thumbnailers
        sudo pacman -S --noconfirm --needed kdenlive
        sudo pacman -S --noconfirm --needed kdialog
        sudo pacman -S --noconfirm --needed keepassxc
        sudo pacman -S --noconfirm --needed kolourpaint
        sudo pacman -S --noconfirm --needed kompare
        sudo pacman -S --noconfirm --needed konsole
        sudo pacman -S --noconfirm --needed krename
        sudo pacman -S --noconfirm --needed ksystemlog
        sudo pacman -S --noconfirm --needed libreoffice-still
        sudo pacman -S --noconfirm --needed libreoffice-still-zh-tw
        sudo pacman -S --noconfirm --needed markdownpart
        sudo pacman -S --noconfirm --needed mpg123
        sudo pacman -S --noconfirm --needed mpv
        sudo pacman -S --noconfirm --needed noto-fonts-cjk
        sudo pacman -S --noconfirm --needed okular
        sudo pacman -S --noconfirm --needed p7zip
        sudo pacman -S --noconfirm --needed partitionmanager
        sudo pacman -S --noconfirm --needed pcsclite
        sudo pacman -S --noconfirm --needed perl-rename
        sudo pacman -S --noconfirm --needed pulseaudio-alsa
        sudo pacman -S --noconfirm --needed profile-sync-daemon
        sudo pacman -S --noconfirm --needed qmmp
        sudo pacman -S --noconfirm --needed rclone
        sudo pacman -S --noconfirm --needed rsync
        sudo pacman -S --noconfirm --needed skanlite
        sudo pacman -S --noconfirm --needed spectacle
        sudo pacman -S --noconfirm --needed telegram-desktop
        sudo pacman -S --noconfirm --needed unrar
        sudo pacman -S --noconfirm --needed xdg-user-dirs
        sudo pacman -S --noconfirm --needed yakuake
        sudo pacman -S --noconfirm --needed youtube-dl
        sudo pacman -S --noconfirm --needed zsh
        sudo pacman -S --noconfirm --needed zsh-theme-powerlevel10k

        # 3-7.Install applications from archlinuxcn repo
        # sudo pacman -S --noconfirm megatools
        # sudo pacman -S --noconfirm ibus-libzhuyin
        # sudo pacman -S --noconfirm qbittorrent-enhanced-git
        # sudo pacman -S --noconfirm qview
        # sudo pacman -S --noconfirm rclone-browser
        # sudo pacman -S --noconfirm safeeyes
        # sudo pacman -S --noconfirm yay
        # sudo pacman -S --noconfirm ytop

        ### sudo pacman -S --noconfirm --needed bluedevil
        ### sudo pacman -S --noconfirm --needed caprine
        ### sudo pacman -S --noconfirm --needed clipgrab
        ### sudo pacman -S --noconfirm --needed converseen
        ### sudo pacman -S --noconfirm --needed crow-translate
        ### sudo pacman -S --noconfirm --needed cups
        ### sudo pacman -S --noconfirm --needed dolphin-plugins
        ### sudo pacman -S --noconfirm --needed faad2 (qmmp)
        ### sudo pacman -S --noconfirm --needed ffmpegthumbs
        ### sudo pacman -S --noconfirm --needed firewalld
        ### sudo pacman -S --noconfirm --needed k3b
        ### sudo pacman -S --noconfirm --needed kaccounts-providers
        ### sudo pacman -S --noconfirm --needed kde-cli-tools
        ### sudo pacman -S --noconfirm --needed kdenetwork-filesharing
        ### sudo pacman -S --noconfirm --needed khotkeys
        ### sudo pacman -S --noconfirm --needed kio-fuse
        ### sudo pacman -S --noconfirm --needed kfind
        ### sudo pacman -S --noconfirm --needed kscreen
        ### sudo pacman -S --noconfirm --needed ktimer
        ### sudo pacman -S --noconfirm --needed kwayland-integration
        ### sudo pacman -S --noconfirm --needed kwrited
        ### sudo pacman -S --noconfirm --needed libmpcdec (qmmp)
        ### sudo pacman -S --noconfirm --needed libva-vdpau-driver (vlc)
        ### sudo pacman -S --noconfirm --needed man-db
        ### sudo pacman -S --noconfirm --needed man-pages
        ### sudo pacman -S --noconfirm --needed mtpfs
        ### sudo pacman -S --noconfirm --needed opera
        ### sudo pacman -S --noconfirm --needed opera-ffmpeg-codecs
        ### sudo pacman -S --noconfirm --needed opusfile (qmmp)
        ### sudo pacman -S --noconfirm --needed plasma-browser-integration
        ### sudo pacman -S --noconfirm --needed pulseaudio-bluetooth
        ### sudo pacman -S --noconfirm --needed qt5-imageformats
        ### sudo pacman -S --noconfirm --needed unzip-natspec
        ### sudo pacman -S --noconfirm --needed wine
        ### sudo pacman -S --noconfirm --needed xdg-desktop-portal-kde (flatpak)
        ### sudo pacman -S virtualbox

        # 3-8.Install applications from aur repo

        # git clone https://aur.archlinux.org/trizen.git
        # cd trizen
        # makepkg -si

        # yay -S anydesk-bin
        # yay -S kde-servicemenus-rootactions
        # yay -S jellyfin
        # yay -S powerdevil-light
        # yay -S qt-avif-image-plugin-git (qview)
        # yay -S qt5-heif-git (qview)
        # yay -S taipei-sans-tc
        # yay -S ttf-meslo-nerd-font-powerlevel10k
        # yay -S wine-x64
        
        ### yay -S ezusb (driver for EZ100PU)
        ### yay -S isoimagewriter
        ### yay -S ksnip
        ### yay -S megacmd-bin
        ### yay -S ms-office-online
        ### yay -S stacer
        ### yay -S tiny-media-manager

        # sudo sh ../../../Config/Sophos-Antivirus-free/install.sh
        # sudo pacman -Rsn --noconfirm xdg-user-dirs

        sudo systemctl enable sddm
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


###  ERROR: One or more PGP signatures could not be verified
###  gpg --keyserver keys.gnupg.net --recv-keys <key>
