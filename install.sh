#!/usr/bin/env bash

#This bash shall install all necessary installs that the razer blade 15 is functioning correctly.

function isRoot() {
	if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
	fi
}

function initialQuestions() {
        echo "Welcome to the Razer Blade fixer script!"
        echo "The git repository is available at: https://github.com/WantClue/Ubuntu-Razer-Blade-15-Base-Mid-2021"
        echo ""
        echo ""
        echo ""
        read -n1 -r -p "Press any key to continue..."
        
}
function manageMenu() {
       echo "What do you want to do?"
	     echo "   1) Fix trackpad issue"
       echo "   2) Install Nvidia driver"
       echo "   3) Delete Nvidia driver"
	     echo "   4) Exit"
 
      until [[ ${MENU_OPTION} =~ ^[1-4]$ ]]; do
		read -rp "Select an option [1-4]: " MENU_OPTION
	done
	    case "${MENU_OPTION}" in
	      1)
		      installFixes
		      ;;
        2)
		      installGraphics
		      ;;
        3)
		      purgeNvidia
		      ;;    
	      4)
		      exit 0
		      ;;
	      esac
 
}

function installFixes() {
  # create file1
  touch /etc/systemd/system/acpi-wake-andy.service
  echo "[Unit]" > /etc/systemd/system/acpi-wake-andy.service
  echo "Description=ACPI Wake Service" >> /etc/systemd/system/acpi-wake-andy.service
  echo "" >> /etc/systemd/system/acpi-wake-andy.service
  echo "[Service]" >> /etc/systemd/system/acpi-wake-andy.service
  echo "Type=oneshot" >> /etc/systemd/system/acpi-wake-andy.service
  echo "ExecStart=/bin/sh -c \"echo RP05 | sudo tee /proc/acpi/wakeup\"" >> /etc/systemd/system/acpi-wake-andy.service
  echo "" >> /etc/systemd/system/acpi-wake-andy.service
  echo "[Install]" >> /etc/systemd/system/acpi-wake-andy.service
  echo "WantedBy=multi-user.target" >> /etc/systemd/system/acpi-wake-andy.service
  # activate services
  sudo systemctl start acpi-wake-andy.service
  sudo systemctl enable acpi-wake-andy.service
  sudo systemctl status acpi-wake-andy.service # check status
  # create file2
  touch /etc/modprobe.d/nvidia-s2idle.conf
  echo "options nvidia NVreg_EnableS0ixPowerManagement=1" > /etc/modprobe.d/nvidia-s2idle.conf
  echo "NVreg_S0ixPowerManagementVideoMemoryThreshold=10000" >> /etc/modprobe.d/nvidia-s2idle.conf
  
  #check status output
  s2idle=$(cat /sys/power/mem_sleep |grep s2idle [deep])
  if $s2idle
  then sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash mem_sleep_default=s2idle"/g' /etc/default/grub
  fi
  sudo update-grub
  echo "reboot and test if your trackpad works"
}
function installGraphics(){
  #update current drivers
  sudo ubuntu-drivers autoinstall
  #add autoupdate functionality
  touch /etc/systemd/system/update-nvidia.service
  echo "[Unit]" > /etc/systemd/system/update-nvidia.service
  echo "Description= Update Nvidia Driver" >> /etc/systemd/system/update-nvidia.service
  echo "After=network-online.target" >> /etc/systemd/system/update-nvidia.service
  echo "" >> /etc/systemd/system/update-nvidia.service
  echo "[Service]" >> /etc/systemd/system/update-nvidia.service
  echo "Type=oneshot" >> /etc/systemd/system/update-nvidia.service
  echo "ExecStart=/usr/bin/ubuntu-drivers install" >> /etc/systemd/system/update-nvidia.service
  echo "" >> /etc/systemd/system/update-nvidia.service
  echo "[Install]" >> /etc/systemd/system/update-nvidia.service
  echo "WantedBy=multi-user.target" >> /etc/systemd/system/update-nvidia.service

  sudo systemctl enable update-nvidia.service

  echo "go to the nvidia x server to toggle performance settings"

}

function purgeNvidia(){
sudo apt purge nvidia-*
sudo apt autoremove
}

isRoot
initialQuestions
 manageMenu
