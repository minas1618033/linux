# 10.Install essential packages
    if grep -q "AMD" "/proc/cpuinfo"; then
        pacman -S --noconfirm amd-ucode sudo nano git iwd &&
    else
        pacman -S --noconfirm intel-ucode sudo nano git iwd &&
    fi
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
    read -p "    Input your username : " username
    useradd -m $username &&
    passwd $username &&
    sed -i '/root/a\$username ALL=(ALL) ALL' /etc/sudoers &&
    echo "(O) 15.Add users account" ||
  { echo "(X) 15.Add users account <<<<<<<<<<"; exit; }

# 16.systemd-boot Configuration
    bootctl --path=/boot install &&
    if find /dev -maxdepth 1 -iname 'nvme0n1' >> /dev/null; then
        PARTUUID=$(blkid -o export /dev/nvme0n1p2 | grep PARTUUID)
    else
        PARTUUID=$(blkid -o export /dev/sda1 | grep PARTUUID)
    fi
    rm /boot/loader/entries/arch.conf &&
    echo "title   Arch Linux"                 >> /boot/loader/entries/arch.conf &&
    echo "linux   /vmlinuz-linux"             >> /boot/loader/entries/arch.conf &&
    echo "initrd  /amd-ucode.img"             >> /boot/loader/entries/arch.conf &&
    echo "initrd  /initramfs-linux.img"       >> /boot/loader/entries/arch.conf &&
    echo "options root=$PARTUUID rw" >> /boot/loader/entries/arch.conf &&
    sed -i '/default/d' /boot/loader/loader.conf &&
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
        mkdir /etc/iwd
        echo "[General]"                       >> /etc/iwd/main.conf &&
        echo "EnableNetworkConfiguration=true" >> /etc/iwd/main.conf &&
        echo ""                                >> /etc/iwd/main.conf &&
        echo "[Network]"                       >> /etc/iwd/main.conf &&
        echo "NameResolvingService=systemd"    >> /etc/iwd/main.conf &&
        echo "(O) 18.iwd Configuration" ||
      { echo "(X) 18.iwd Configuration"; exit; }
    fi
