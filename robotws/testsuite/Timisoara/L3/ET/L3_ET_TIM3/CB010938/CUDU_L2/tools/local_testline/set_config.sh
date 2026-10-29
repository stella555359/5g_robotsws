#cat /etc/resolv.conf
#ls -al /etc/resolv.conf
#/etc/resolv.conf -> /etc/resolvconf/run/resolv.conf
#sudo cat /etc/apt/sources.list.d/debian_repo.list
sudo sshpass -p ute scp ute@10.57.205.5:/etc/resolvconf/run/resolv.conf /etc/resolvconf/run/resolv.conf
sudo sshpass -p ute scp ute@10.57.205.5:/etc/apt/sources.list.d/debian_repo.list /etc/apt/sources.list.d/debian_repo.list
sudo sshpass -p nokia123 scp nokia@10.57.215.253:/home/nokia/LogServer/tools/local_control_pc_config/resolv.conf /etc/resolvconf/run/resolv.conf
sudo apt update
unset http_proxy https_proxy ftp_proxy
sudo apt install aria2
