#backup gnb ap and iphy config files
# 20220707 xiang.5.li@nokia-sbell.com
mkdir -p /home/ute/scf_bakup/wts
mkdir -p /home/ute/scf_bakup/airphone/
mkdir -p /home/ute/scf_bakup/gnb/

rm -rf /home/ute/scf_back/wts/*
rm -rf /home/ute/scf_bakup/airphone/*
rm -rf /home/ute/scf_bakup/gnb/*

# backup wts cfg
cp /opt/iphy/latest/basic_*.cfg /home/ute/scf_bakup/wts
cp /opt/iphy/latest/wts_*.cfg /home/ute/scf_bakup/wts
echo = show wts files =
ls /home/ute/scf_bakup/wts

# backup gnb cfg
sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/ffs/run/swconfig.txt /home/ute/scf_bakup/gnb/
sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/ffs/run/TargetBD_SBTS*.xml /home/ute/scf_bakup/gnb/
sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/user/toor4nsn/DCI/deploy.cfg /home/ute/scf_bakup/gnb/
echo = show gnb files =
ls /home/ute/scf_bakup/gnb/

# backup ap cfg
sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.200.1:/ffs/run/swconfig.txt /home/ute/scf_bakup/airphone/
sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.200.1:/ffs/run/TargetBD_5G_AP*.xml /home/ute/scf_bakup/airphone/
sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.200.1:/ffs/run/simmode/iphy.xml /home/ute/scf_bakup/airphone/
sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.200.1:/user/toor4nsn/DCI/deploy.cfg /home/ute/scf_bakup/airphone/
echo = show airphone files =
ls /home/ute/scf_bakup/airphone/