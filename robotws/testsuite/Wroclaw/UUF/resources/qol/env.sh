#!/bin/bash

# install aliases
echo "installing aliases"
cp /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/resources/qol/bash_aliases /home/ute/.bash_aliases
source /home/ute/.bashrc

# customized terminator view
echo "installing terminator view"
cp /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/resources/qol/predator.conf /home/ute/.config/terminator/config

# customized quicklaunch with UUF tools
echo "installing quicklaunch menu"
cp /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/resources/qol/quicklaunch.cfg /home/ute/.config/lxpanel/LXDE/panels/panel
lxpanelctl restart

# load terminator to autostart so it opens automaticaly upon VM login
echo "installing terminator autostart"
mkdir /home/ute/.config/autostart
cp /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/resources/qol/desktop /home/ute/.config/autostart/.desktop

# mount UUF repo shortcut in /home/ute
echo "installing uuf repository link"
ln -s /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/ /home/ute/uuf_repository

# mount burak in /home/ute
echo "installing uuf burak"
sudo mkdir -p /home/ute/burak
sudo chmod 777 /home/ute/burak
sudo mount -t cifs //burak2.intra.noklab.net/csv4all/UUF/SBTS /home/ute/burak -o username=uufwro,password=uufpass18,rw,nounix,file_mode=0777,dir_mode=0777,uid=ute,gid=ute,domain=noklab,vers=3.0

# szylkows PC rsa public key
echo "installing ssh-rsa keys"
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCv1wAGPNymnnROa65ufRkaEHt1tvXle7RHbTDx5qgKm6A7TzhMOsKKoDc9GZ5P/xRsNaLlwJf3lMOsg0d2ijdJ4dvVe1IxTQKqdClGhsC70E+fyWvdoWlDB3NuqJAc/zpb81xT1i84U6IUZaekQXt3XBEmZpCfgX7VEYYoRDMHvELiOMcBXoPDmShkLfptPAMSleemrsA1SK66FhQoIN9IU5JNVeGcolzPQeTVoA2iYQBUI3uG+sqGXuvYSM5pLE0VE+jsETY/d7GvGkkC51vOdSCVak1XGxg5HVF4B8Qcg8OpgbYa61AQoLr4r8hweBU/FcDlOlF+6OMs9kBFnu+v szylkows@N-20S1PF2LGX4V" | sudo tee -a /home/ute/.ssh/authorized_keys

# host aliases for UUF testlines in form Cxxxx where x is TL number. Can be used in ssh commands etc.
echo "installing hosts file"
sudo bash -c 'cat /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/resources/qol/uufhosts >> /etc/hosts'

# quicklaunch QOL script in /home/ute to be used on released VMs
echo "installing hosts qol installer link"
sudo cp /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/resources/qol/qol.sh /home/ute/qol.sh
sudo chmod +x /home/ute/qol.sh

# janitor script to delete ims2 files from /tmp - must be some leaking admin sessions
echo "installing janitor"
(
  crontab -l 2>/dev/null
  echo "*/30 * * * * find /tmp/ -mindepth 1 -maxdepth 1 -name \"*.ims2\" -mmin +720 -delete"
) | crontab -


# copy PyCharm files to setup default project location to UUF directory and disable typo inspection
#echo "installing pycharm settings"
#cp /home/ute/burak/tomke/PyCharmUUFFiles/recentProjects.xml /home/ute/.config/JetBrains/PyCharmCE2021.2/options/recentProjects.xml
#cp /home/ute/burak/tomke/PyCharmUUFFiles/Default.xml /home/ute/.config/JetBrains/PyCharmCE2021.2/inspection/Default.xml

#clone topology-configs
bash -elc 'cd /home/ute; git clone git@gitlabe2.ext.net.nokia.com:uca/ran/topology-configs.git'

# mount testline_configuration/hostname directory in /home/ute as it is missing in agent_dummy
echo "installing testline_configuration link"
/home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/resources/qol/mount_config.sh



# benchmarking test which copies SBTS package and unpacks it measuring time of processes
#echo "UUF VM benchmark started, feel free to ctrl+c if you can't wait"
#/home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/resources/qol/benchmark.sh

# install ute-ca
sudo systemctl start ute-ca
sudo systemctl status ute-ca | grep Active:

#install matplotlib and rafaello
bash -elc 'pyenv activate test_repo; python -m pip install matplotlib; python -m pip install -U taf.rfrl.csv4all ; pyenv deactivate'

# end
echo "UUF scripts installer exit"