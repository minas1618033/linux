# !/bin/bash

clear
echo "
          Arch Linux install script

--------------------------------------------

"

# 0.Download installation script
# 	(wireless network) ip link set wlan0 up
# 	(wireless network) wifi-menu
# 	curl -L https://github.com/minas1618033/linux/archive/master.zip --output scripts.zip
# 	bsdtar -x -f scripts.zip
# 	chmod +x /root/linux-master/archlinux/*.sh
# 	sh /root/linux-master/archlinux/1-initialize.sh

printf "<<<<<<<<<< Script for Renaming >>>>>>>>>>\n\n   1.Normal Insatllation\n   3.Custom Installation\n   4.Remove first n characters\n   5.Remove middle n characters\n   6.Remove last n characters\n   7.Remove all letters\n   8.Remove all numbers\n   9.Remove extensions\n\n"

	function selection {
		ESC=$( printf "\033")
		cursor_blink_on()  { printf "$ESC[?25h"; }
		cursor_blink_off() { printf "$ESC[?25l"; }
		cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
		print_option()     { printf "   $1 "; }
		print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
		get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
		key_input()        { read -s -n3 key 2>/dev/null >&2
							 if [[ $key = $ESC[A ]]; then echo up;    fi
							 if [[ $key = $ESC[B ]]; then echo down;  fi
							 if [[ $key = ""     ]]; then echo enter; fi; }

		# initially print empty new lines (scroll down if at bottom of screen)
		for opt; do printf "\n"; done

		# determine current screen position for overwriting the options
		local lastrow=`get_cursor_row`
		local startrow=$(($lastrow - $#))

		# ensure cursor and input echoing back on upon a ctrl+c during read -s
		trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
		cursor_blink_off

		local selected=0
		while true; do
			# print options by overwriting the last lines
			local idx=0
			for opt; do
				cursor_to $(($startrow + $idx))
				if [ $idx -eq $selected ]; then
					print_selected "$opt"
				else
					print_option "$opt"
				fi
				((idx++))
			done

			# user key control
			case `key_input` in
				enter) break;;
				up)    ((selected--));
					   if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
				down)  ((selected++));
					   if [ $selected -ge $# ]; then selected=0; fi;;
			esac
		done

		# cursor position back to normal
		cursor_to $lastrow
		printf "\n"
		cursor_blink_on

		return $selected
	}

# 1.Connect to the Internet
	function step1 {
		if ping -c 3 8.8.8.8 > /dev/null 2>&1 then
			if ping -c 3 www.google.com > /dev/null 2>&1 then
				echo "(O) 1.Connected to the Internet"
				step2
			else
				echo "(X) 1.Connected to the Internet, but DNS server is unavailable <<<<<<<<<<"
				systemctl disable systemd-resolved
				rm /etc/resolv.conf # removes symlink to /run
				echo "nameserver 168.95.192.1" >> /etc/resolv.conf
				echo "Disable systemd-resolved & Reset DNS resolver"
				step1
		else
			echo "(X) 1.Connection error, the network is unavailable <<<<<<<<<<"
			step1a
		fi
	}

# 1-A.Connect to Wi-Fi networks
	function step1a {
		echo
		echo "Select your network interface :"
		echo
		options=("Wi-Fi" "Enable wireless network interface (ip link set wlan0 up)" "Disable wireless network interface (ip link set wlan0 down)")
		selection "${options[@]}"
		choice=$?
		case $choice in
			0)	read -t 20 -n 1 -s -r -p "Connecting to Wi-Fi networks (netctl), Press any key to continue..."
				wifi-menu
				read -t 20 -n 1 -s -r -p "If connect failed, Press any key to continue..."
				;;
			1)	ip link set wlan0 up
				wifi-menu
				step1
				;;
			2)	ip link set wlan0 down
				wifi-menu
				step1
				;; 
		esac
	}

# 2.Update the system clock
	function step2 {
		echo
		timedatectl set-ntp true &&
		echo "(O) 2.Update the system clock" && step3 ||
		{ echo "(X) 2.Update the system clock <<<<<<<<<<"; exit; }
	}

# 3.Identify UEFI/BIOS
	function step3 {
		echo
		find /sys/firmware/efi >> /dev/null &&
		echo "(O) 3.The computer support UEFI" ||
		echo "(O) 3.The computer support BIOS only"
		step4
		read -t 20 -n 1 -s -r -p "Press any key to continue..."
	}

# 4.Partition & Format the disks
	function step4 {
		echo
		echo "Select your disks partition configuration :"
		echo
		options=("Config 1 (For Desktop 1*NVME + 2*HDD)" "Config 2 (For Laptop 1*SSD)" "Custom partitioning")
		selection "${options[@]}"
		choice=$?
		case $choice in
			0)  step4a && echo "(O) 4.Partition & foemat the disks";;
			1)  step4b ;;
			2)  gdisk ;;
		esac
	}

	function step4a {
		echo "Config 1 (1*NVME + 2*HDD):"
		echo
		options=("Format ROOT partition only" "Format ALL partitions" "Repartition and format all partitions" "    " "Back")
		selection "${options[@]}"
		choice=$?
		case $choice in
			0)	mkfs.vfat /dev/nvme0n1p1 &&
				mkfs.ext4 /dev/nvme0n1p2
				;;
			1)	mkfs.vfat /dev/nvme0n1p1 &&
				mkfs.ext4 /dev/nvme0n1p2 &&
				mkfs.ext4 /dev/sda1 &&
				mkfs.ext4 /dev/sdb1
				;;
			2)	parted rm 1
				parted rm 2
				parted rm 3
				parted rm 4
				parted /dev/nvme0n1 mklabel gpt mkpart "EFI system partition" fat32 1MiB 300MiB
				parted set 1 esp on
				parted /dev/nvme0n1 mkpart "Root" ext4 300MiB '100%'
				parted set 2 root on
				parted -a optimal /dev/sda mklabel gpt mkpart "Western Digital" ext4 1MiB '100%'
				parted -a optimal /dev/sdb mklabel gpt mkpart "Toshiba" ext4 1MiB '100%'
				mkfs.vfat /dev/nvme0n1p1
				mkfs.ext4 /dev/nvme0n1p2
				mkfs.ext4 /dev/sda1
				mkfs.ext4 /dev/sdb1
				;;
			3)	step4a;;
			4)	step4;;
		esac
	}

	function step4b {
		echo "Config 2 (1*SSD):"
		echo
		options=("Format ALL partitions" "Repartition and format all partitions" "    " "Back")
		selection "${options[@]}"
		choice=$?
		case $choice in
			0)	mkfs.vfat /dev/sda1 &&
				mkfs.ext4 /dev/sda2
				;;
			1)	parted rm 1
				parted rm 2
				parted /dev/sda mklabel gpt mkpart "EFI system partition" fat32 1MiB 300MiB
				parted set 1 esp on
				parted /dev/sda mkpart "Root" ext4 300MiB '100%'
				parted set 2 root on
				mkfs.vfat /dev/sda1
				mkfs.ext4 /dev/sda2
				;;
			3)	step4b;;
			4)	step4;;
		esac
	}

# 5.Mount the file systems
	function step5 {
		echo
		case $ACTION in
			1)	mount /dev/nvme0n1p2 /mnt &&
				mkdir /mnt/boot &&
				mount /dev/nvme0n1p1 /mnt/boot &&
				echo "(O) 5.Mount the file systems" && step6 || { 
				echo "(X) 5.Mount the file systems <<<<<<<<<<"; exit; }
				;;
			2)	mount /dev/sda2 /mnt &&
				mkdir /mnt/boot &&
				mount /dev/sda1 /mnt/boot &&
				echo "(O) 5.Mount the file systems" && step6 || { 
				echo "(X) 5.Mount the file systems <<<<<<<<<<"; exit; }
				;;
		esac
	}

# 6.Select the mirrors
	function step6 {
		echo
		sed -i '7i## Taiwan' /etc/pacman.d/mirrorlist &&
		sed -i '8iServer = http://ftp.tku.edu.tw/Linux/ArchLinux/$repo/os/$arch' /etc/pacman.d/mirrorlist &&
		echo "(O) 6.Select the mirrors" && step7 || {
		echo "(X) 6.Select the mirrors <<<<<<<<<<"; exit; }
	}

# 7.Install linux kernel & base packages
	function step7 {
		echo
		pacstrap /mnt base linux linux-firmware &&
		echo "(O) 7.Install linux kernel & base packages" && step8 || { 
		echo "(X) 7.Install linux kernel & base packages <<<<<<<<<<"; exit; }
	}

# 8.Generate fstab
	function step8 {
		echo
		genfstab -U /mnt >> /mnt/etc/fstab &&
		cat /mnt/etc/fstab &&
		echo "(O) 8.Generate fstab" && step9 || { 
		echo "(X) 8.Generate fstab <<<<<<<<<<"; exit; }
	}

# 9.Change root into the new system
	function step9 {
		echo
		while [[ ! "$ACTION" =~ ^[yYnN]$ ]]; do
			read -n1 -p "Do you want to change root into the new system? [Y/N]: " ACTION
			echo ""; done
			case $ACTION in
				[yY]) cp /root/linux-master/archlinux/*.sh /mnt/opt
					rm /root/script.zip
					rm -r /root/linux-master
					arch-chroot /mnt /opt/2-configure.sh
					echo "(O) 9.Change root into the new system"
					step10
					;;
				[nN]) echo "(X) 9.Change root into the new system"
					exit
					;;
				*) echo "(X) 9.Change root into the new system"
					exit
					;;
			esac
	}

# Reboot
	echo
	read -n1 -p "Install sucessed, do you want to reboot ? [Y/N]: " ACTION
		case $ACTION in
			[yY]) exit
				umount -R /mnt
				reboot ;;
		esac