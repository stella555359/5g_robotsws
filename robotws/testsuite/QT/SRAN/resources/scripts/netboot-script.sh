#!/bin/bash

smod_list=( "asia" "asib" "asik" "asoe" "asod" "asil" )


if [ $# -eq 0 ]; then
    echo "No arguments provided, please provide argument with lower case e.g. './netboot-script.sh asik' "
    echo "List of possible arguments: { "asia" "asib" "asik" "asoe" "asod" "asil" } "
    exit 1
fi

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 1; done
  return 0
}

containsElement "$1" "${smod_list[@]}"

if [ $? = 0 ]; then
    echo "Wrong argument, please provide argument with lower case e.g. './netboot-script.sh asik' "
    echo "List of possible arguments: { "asia" "asib" "asik" "asoe" "asod" "asil" } "
    exit 1
fi

echo "Argument is ok, proceeding..."

cd /home/ute

sudo systemctl stop dnsmasq

sudo apt update
sudo apt-get install --reinstall dnsmasq
sudo apt-get install ute-netboot-recovery

sudo ln -s /etc/apparmor.d/usr.sbin.dnsmasq /etc/apparmor.d/disable/
sudo apparmor_parser -R /etc/apparmor.d/disable/usr.sbin.dnsmasq

cd /netboot/
sudo rm eth1
sudo rm eth2

sudo ln -s config/eth1-$1.conf eth1
sudo ln -s config/eth2-fsmf.conf eth2

if [ "$1" = "asik" ]; then
	sudo rm eth2
    sudo ln -s config/eth2-asik.conf eth2
fi

if [ "$1" = "asil" ]; then
	sudo rm eth2
    sudo ln -s config/eth2-asil.conf eth2
fi

if [ "$1" = "asod" ]; then
	sudo rm eth2
	  sudo touch config/eth2-asod.conf
	  sudo dd of=config/eth2-asod.conf << EOF
tftp-root=/netboot/images/asod,eth2
dhcp-boot=tag:iphy,xstart.efi
EOF
    sudo ln -s config/eth2-asod.conf eth2
fi

sudo systemctl stop dnsmasq

echo ""
echo "Symbolic links created"
echo ""
ls -al /netboot/
echo ""
echo "#######################################################################################"
echo "-Enable netboot using command: 'sudo systemctl start dnsmasq' and reboot SMOD"
echo "-To check if netboot works correctly use 'sudo systemctl status dnsmasq' during bootup"
echo "-SMOD should be accessible through 'ssh toor4nsn@192.168.255.129' command"
echo "-192.168.255.129 and WEBM will not be accessible"
echo "-Remember to disable netboot after you're finished with 'sudo systemctl stop dnsmasq'"
echo "#######################################################################################"
echo "-Use 'uboot_env get' and 'uboot_env set active_partition=1 or =2' to change partition"
echo "#######################################################################################"
echo "Use following commands on SMOD to prepare it for YAFT:"
echo "1.  systemctl start /ffs/fs1; systemctl start /ffs/fs2; mount -o remount,rw,async /ffs/fs1;mount -o remount,rw,async /ffs/fs2; ls /ffs/"
echo "2.  systemctl stop etc-keys.d-board.mount; systemctl start etc-keys.d-board.mount; systemctl stop etc-keys.d-bcerts.mount; systemctl start etc-keys.d-bcerts.mount"
echo "3.  systemctl stop crypto-agent.service; systemctl start crypto-agent.service; systemctl stop crypto-agent-check.service; systemctl start crypto-agent-check.service"
echo "#######################################################################################"
echo ""

exit 1


