# !/bin/bash

# Sync Date&Time ----------------------------------------------------------------------------------

sudo timedatectl set-ntp true &&
    echo "OK, Network time sync is Enabled." || 
    echo "Error : Network time sync is Faulted. <<<<<<<<<<<<<<" ;

# Enable SSD Trim ---------------------------------------------------------------------------------

sudo systemctl enable fstrim.timer &&
    echo "OK, SSD Trim is Enabled." ||
    echo "Error : SSD Trim can't be turn on.    <<<<<<<<<<<<<<" ;

# Automount HDD ('ls -lh /dev/disk/by-uuid' or 'lsblk -f' to find UUID) ---------------------------------------------------------

#    # /dev/nvme0n1p1
#    UUID={UUID} /boot/efi vfat rw,noatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro 0 2
#    # /dev/nvme0n1p2
#    UUID={UUID} / ext4 defaults,noatime 0 1
#    # /dev/sdb1
#    UUID={UUID} /home/zelko/Downloads ext4 defaults,noatime 0 2
#    # /dev/sda1
#    UUID={UUID} /home/zelko/Purple ext4 defaults,noatime 0 2

# Auto update systemd-boot bootloader -------------------------------------------------------------

sudo echo "[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot
When = PostTransaction
Exec = /usr/bin/bootctl update" >> /etc/pacman.d/hooks/100-systemd-boot.hook &&
    echo "OK, Auto update systemd-boot is configured." ||
    echo "Error : Auto update systemd-boot configuration is wrong. <<<<<<<<<<<<<<<" ;

# Auto mount GSuite --------------------------------------------------------------------------------

#   mkdir ~/Downloads/GSuite/
#   echo "rclone mount GSuite: ~/Downloads/GSuite/ --daemon --buffer-size 128M" >> ~/.xprofile &&
#       echo "OK, Automount GSuite is configured." ||
#       echo "Error : Automount GSuite configuration is wrong. <<<<<<<<<<<<<<<" ;

# Turn on HiDPI & NumLock in SDDM -------------------------------------------------------------------------

sudo echo "[General]
Numlock=on

[X11]
EnableHiDPI=true
ServerArguments=-nolisten tcp -dpi 120" >> /etc/sddm.conf &&
    echo "OK, HiDPI & NumLock in SDDM is enabled." ||
    echo "Error : HiDPI & NumLock can't be turn on. <<<<<<<<<<<<<<<<<<" ;
 
# Set iBus input method ---------------------------------------------------------------------------

echo "export XMODIFIERS=@im=ibus
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
ibus-daemon -drx" >> ~/.xprofile &&
    echo "OK, iBus is configured." ||
    echo "Error : iBus configuration is wrong. <<<<<<<<<<<<<<<" ;

# Set Kate ----------------------------------------------------------------------------------------

cp ./config/kate/anonymous.katesession ~/.local/share/kate/ &&
cp ./config/kate/katerc ~/.config/ &&
cp ./config/kate/kateschemarc ~/.config/ &&
cp ./config/kate/katesyntaxhighlightingrc ~/.config/ &&
    echo "OK, Kate is configured." ||
    echo "Error : Kate configuration is wrong. <<<<<<<<<<<<<<<" ;

# Set KeePassXC -----------------------------------------------------------------------------------

cp -r ./config/keepassxc/ ~/.config/ &&
sudo cp ./config/keepassxc/icons/* /usr/share/keepassxc/icons/database/ &&
    echo "OK, KeePassXC is configured." ||
    echo "Error : KeePassXC configuration is wrong. <<<<<<<<<<" ;

# Set Konsole -------------------------------------------------------------------------------------

cp -r ./config/konsole/ ~/.local/share/ &&
cp ./config/konsole/konsolerc ~/.config/ &&
    echo "OK, Konsole is configured." ||
    echo "Error : Konsole configuration is wrong. <<<<<<<<<<<<" ;

# Set Kwallet -------------------------------------------------------------------------------------

cp ./config/kwallet/kwalletrc ~/.config/ &&
    echo "OK, Kwallet is disabled." ||
    echo "Error : Kwallet still enable. <<<<<<<<<<<<<<<<<<<<<<" ;

# Set MPV Player ----------------------------------------------------------------------------------

cp -r ./config/mpv/ ~/.config/ &&
    echo "OK, MPV is configured." ||
    echo "Error : MPV configuration is wrong. <<<<<<<<<<<<<<<<" ;

# Set qBittorrent ---------------------------------------------------------------------------------

cp -r ./config/qBittorrent/ ~/.config/ &&
    echo "OK, qBittorrent is configured." ||
    echo "Error : qBittorrent configuration is wrong. <<<<<<<<" ;

# Set qmmp ----------------------------------------------------------------------------------------

cp -r ./config/.qmmp/ ~/ &&
    echo "OK, qmmp is configured." ||
    echo "Error : qmmp configuration is wrong. <<<<<<<<<<<<<<<" ;

# Set qView ---------------------------------------------------------------------------------------

cp -r ./config/qView/ ~/.config/ &&
    echo "OK, qView is configured." ||
    echo "Error : qView configuration is wrong. <<<<<<<<<<<<<<" ;

# Set rclone & rclone browser ---------------------------------------------------------------------

cp -r ./config/rclone/ ~/.config/ &&
    echo "OK, rclone is configured." ||
    echo "Error : rclone configuration is wrong. <<<<<<<<<<<<<" ;

# Set Safe Eyes -----------------------------------------------------------------------------------

cp -r ./config/safeeyes/ ~/.config/ &&
    echo "OK, Safe Eyes is configured." ||
    echo "Error : Safe Eyes configuration is wrong. <<<<<<<<<<" ;
    
# Set WifiAudio -----------------------------------------------------------------------------------

sudo cp -r ./config/WifiAudio/ /usr/share/ &&
    echo "OK, WifiAudio is configured." ||
    echo "Error : WifiAudio configuration is wrong. <<<<<<<<<<" ;

# Set Wine 7zip library (20.02) -------------------------------------------------------------------

mkdir -p ~/.wine/drive_c/windows/ &&
cp ./config/7-zip/* ~/.wine/drive_c/windows/ &&
    echo "OK, Wine is configured." ||
    echo "Error : Wine configuration is wrong. <<<<<<<<<<<<<<<" ;

# Add Custom Command ------------------------------------------------------------------------------

echo "alias script-list='cat ~/Documents/scripts/.list'" >> ~/.bashrc &&

echo "alias count='sh ~/Documents/scripts/count.sh'
alias cc='sh ~/Documents/scripts/check.sh'
alias dd='sh ~/Documents/scripts/download.sh'
alias ee='sh ~/Documents/scripts/extract.sh'
alias aa='sh ~/Documents/scripts/archive.sh'
alias uu='sh ~/Documents/scripts/upload.sh'" >> ~/.bashrc &&

## Show Nvidia GPU state
echo "alias gpuinfo='watch -n 1 nvidia-smi'" >> ~/.bashrc &&

## Wait & Notify
echo "
function notify {
    TIME=\$1
    sleep \${TIME} &&
    kdialog --passivepopup 'Time is up !';
    sleep 1s &&
    kdialog --passivepopup 'Something you must to do.';
}" >> ~/.bashrc

## Play DVD format by mpv
echo "
function dvd {
    FILENAME=$1
    mpv dvdnav:// --dvd-device=${FILENAME}
}" >> ~/.bashrc &&

echo "
function blu {
    FILENAME=$1
    mpv bd:// --bd-device=${FILENAME}
}" >> ~/.bashrc &&

## Extract ZIP format with custom encoding
## echo "alias unzip-jp='python ~/Documents/scripts/unzip-jp.py'" >> ~/.bashrc &&
## echo "alias unzip-sc='python ~/Documents/scripts/unzip-sc.py'" >> ~/.bashrc &&

## Cloud storage download scripts
cat ./scripts/dl-gdrive.o >> ~/.bashrc &&
cat ./scripts/dl-zippyshare.o >> ~/.bashrc &&
echo "
alias baidu='baidupcs'
alias baidu-login='baidupcs login -bduss=Z4d0NWbEFpYTZ-SUxwUDZUSEhNckd6RHJpRHVtbnZmWXVXRkpUdW1wY0R2NlplRUFBQUFBJCQAAAAAAAAAAAEAAAA6iYUJbWluYXMxNjE4MDMzAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMyf14DMn9eQX'" >> ~/.bashrc &&
echo "alias mega='megadl'" >> ~/.bashrc &&

## Convert filename case
echo "alias uppercase='
for file in * ; do
   basename=$(tr '[:lower:]' '[:upper:]' <<< "${file%.*}")
   newname="$basename.${file#*.}"
   mv "$file" "$newname"
done'" >> ~/.bashrc &&

echo "alias lowercase='
for file in * ; do
   basename=$(tr '[:upper:]' '[:lower:]' <<< "${file%.*}")
   newname="$basename.${file#*.}"
   mv "$file" "$newname"
done'" >> ~/.bashrc &&

    echo "OK, Custom Command is added to bashrc." ||
    echo "Error : Custom Command configuration is wrong. <<<<<<<<<<" ;

# Change LibreOffice splash -----------------------------------------------------------------------

sudo cp ./config/libreoffice/intro.png /usr/lib/libreoffice/program &&
sudo cp ./config/libreoffice/intro-highres.png /usr/lib/libreoffice/program &&
    echo "OK, LibreOffice splash is changed." ||
    echo "Error : LibreOffice splash isn't changed. <<<<<<<<<<" ;

# Change GIMP splash ------------------------------------------------------------------------------

# mkdir -p ~/.config/GIMP/2.10/splashes &&
# cp ./config/gimp/maxresdefault1.png ~/.config/GIMP/2.10/splashes/maxresdefault1.png &&
#     echo "OK, GIMP splash is changed." ||
#     echo "Error : GIMP splash isn't changed. <<<<<<<<<<<<<<<<<" ;

# Change Applications & Files icon ----------------------------------------------------------------

sudo cp -r ./config/icons/apps/48/ /usr/share/icons/breeze/apps/ &&
sudo cp -r ./config/icons/pixmaps/ /usr/share/ &&
# sudo cp -r ./config/icons/mimetypes/32/ /usr/share/icons/breeze/mimetypes/ &&
# sudo cp -r ./config/icons/mimetypes/64/ /usr/share/icons/breeze/mimetypes/ &&

sudo cp ./config/icons/hicolor/anydesk.svg /usr/share/icons/hicolor/scalable/apps/anydesk.svg &&
sudo cp ./config/icons/hicolor/crow-translate.svg /usr/share/icons/hicolor/scalable/apps/crow-translate.svg &&
sudo cp ./config/icons/hicolor/ibus-zhuyin.svg /usr/share/ibus-libzhuyin/icons/ibus-zhuyin.svg &&
sudo cp ./config/icons/hicolor/ibus-zhuyin.svg /usr/share/icons/hicolor/scalable/apps/ibus-engine.svg &&
sudo cp ./config/icons/hicolor/ibus-zhuyin.svg /usr/share/icons/hicolor/scalable/apps/ibus-keyboard.svg &&
sudo cp ./config/icons/hicolor/ibus-zhuyin.svg /usr/share/icons/hicolor/scalable/apps/ibus-setup.svg &&
sudo cp ./config/icons/hicolor/ibus-zhuyin.svg /usr/share/icons/hicolor/scalable/apps/ibus.svg &&
sudo cp ./config/icons/hicolor/kate.svg /usr/share/icons/hicolor/scalable/apps/kate.svg &&
sudo cp ./config/icons/hicolor/mpv.svg /usr/share/icons/hicolor/scalable/apps/mpv.svg &&
sudo cp ./config/icons/hicolor/qview.svg /usr/share/icons/hicolor/scalable/apps/qview.svg &&
sudo cp ./config/icons/hicolor/rclone-browser.svg /usr/share/icons/hicolor/scalable/apps/rclone-browser.svg &&
sudo cp ./config/icons/hicolor/safeeyes_enabled.png /usr/share/icons/hicolor/24x24/status/safeeyes_enabled.png &&
sudo cp ./config/icons/hicolor/safeeyes_disabled.png /usr/share/icons/hicolor/24x24/status/safeeyes_disabled.png &&
sudo cp ./config/icons/hicolor/safeeyes_disabled.png /usr/share/icons/hicolor/24x24/status/safeeyes_timer.png &&
sudo cp ./config/icons/hicolor/torrents.svg /usr/share/icons/hicolor/scalable/status/qbittorrent-tray-light.svg &&
sudo cp ./config/icons/hicolor/torrents_dark.svg /usr/share/icons/hicolor/scalable/status/qbittorrent-tray-dark.svg &&
    echo "OK, Applications & Files icon is changed." ||
    echo "Error : Applications & Files icon isn't changed. <<<" ;

# Add Plasma themes -------------------------------------------------------------------------------

sudo cp -r ./config/themes/usr/share/plasma/desktoptheme/breath-dark/ /usr/share/plasma/desktoptheme/ &&
# sudo cp -r ./config/themes/usr/share/sddm/themes/breath/ /usr/share/sddm/themes/breath/ &&
# sudo cp -r ./config/themes/usr/share/themes/Breath/ /usr/share/themes/ &&
# sudo cp -r ./config/themes/usr/share/themes/Breath-Dark/ /usr/share/themes/ &&
    echo "OK, Plasma themes is added." ||
    echo "Error : Plasma themes isn't added. <<<<<<<<<<<<<<<<<" ;

# Delete unnecessary files ------------------------------------------------------------------------

sudo rm -r /usr/share/wallpapers/Next/ ;
sudo rm -r /usr/share/icons/Adwaita/ ;
sudo rm -r /usr/share/icons/gnome/ ;
sudo rm -r /usr/share/plasma/desktoptheme/air/ ;
sudo rm -r /usr/share/plasma/desktoptheme/oxygen/ ;
sudo pacman -Qdt ; #所有不再作為依賴的軟件包
sudo pacman -Scc ; #清理整個軟體包快取
echo "Unnecessary files is deleted." ;

echo "Script is Finished !" ;
