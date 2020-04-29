sudo systemctl start systemd-networkd
sudo systemctl enable systemd-networkd
sudo systemctl start systemd-resolved
sudo systemctl enable systemd-resolved
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo mkdir /etc/systemd/resolved.conf.d
echo "[Resolve]" >> /etc/systemd/resolved.conf.d/dnssec.conf
echo "DNSSEC=false" >> /etc/systemd/resolved.conf.d/dnssec.conf

if pacman -Qs iwd ; then
    sudo systemctl start iwd
    sudo systemctl enable iwd
    sudo iwctl wlan0 scan
    sudo iwctl wlan0 connect CHT_2.4G
fi
