#!/bin/bash

# EDIT ACCORDING TO TESTLINES CONFIGURATIONS
OAM_GNB_IP="" # Leave blank if gNB is classical
ASIK_GNB_IP="192.168.255.129"
ASIK_AP_IP="192.168.200.1"
WTS_PATH="/opt/iphy/latest"
###########################################

OAM_HOSTNAME=robot
OAM_PASSWORD=rastre1
ASIK_HOSTNAME=toor4nsn
ASIK_PASSWORD=oZPS0POrRieRtu

function auto_ssh_copy_id(){
    rm  ~/.ssh/known_hosts

    ./auto-ssh-copy-id ${ASIK_HOSTNAME}@${ASIK_GNB_IP} ${ASIK_PASSWORD} \
    & ./auto-ssh-copy-id ${ASIK_HOSTNAME}@${ASIK_AP_IP} ${ASIK_PASSWORD}

    if [ "${GNB_TYPE}" != 'classical' ]; then
        ./auto-ssh-copy-id ${OAM_HOSTNAME}@${OAM_GNB_IP} ${OAM_PASSWORD}
    fi
}

function get_gnb_du_logs(){
    printf "\n########## GNB DU LOG COLLECTION IN PROGRESS ##########\n"

    if [ ! -d "/tmp/GNB_DU_LOGS" ]
    then
        mkdir /tmp/GNB_DU_LOGS/
    fi

    mkdir -p /tmp/GNB_DU_LOGS/ASIK_MASTER/ /tmp/GNB_DU_LOGS/ABIL_MASTER/
    cp /tmp/*startup* /tmp/GNB_DU_LOGS/ASIK_MASTER/
    bsh 1:0 "journalctl -ab > /tmp/GNB_L2RT.log"
    scp fsp-1-1a:/tmp/GNB_L2RT.log /tmp/GNB_DU_LOGS/ABIL_MASTER/
    scp fsp-1-1a:/tmp/*startup* /tmp/GNB_DU_LOGS/ABIL_MASTER/
}

function get_gnb_vm_logs(){
    printf "\n########## GNB VMs LOG COLLECTION IN PROGRESS ##########\n"

    if [ ! -d "/tmp/GNB_VM_LOGS" ]
    then
        mkdir -p /tmp/GNB_VM_LOGS/OAM/siteoam/ /tmp/GNB_VM_LOGS/_OAM/racoam/
    fi

    sudo cp -r /opt/nokia/SS_MzOam/cloud-siteoam/siteoam/logs/* /tmp/GNB_VM_LOGS/OAM/siteoam/
    sudo cp -r /opt/nokia/SS_MzOam/cloud-racoam/logs/* /tmp/GNB_VM_LOGS/OAM/racoam/
    ssh cpcl-0.local "sudo journalctl -b > /tmp/CPCL.log; \
        sudo scp /tmp/CPCL.log oam-0.local:/tmp/GNB_VM_LOGS/"
    ssh cpif-0.local "sudo journalctl -b > /tmp/CPIF.log; \
        sudo scp /tmp/CPIF.log oam-0.local:/tmp/GNB_VM_LOGS/"
    ssh cpnb-0.local "sudo journalctl -b > /tmp/CPNB.log; \
        sudo scp /tmp/CPNB.log oam-0.local:/tmp/GNB_VM_LOGS/"
    ssh cpue-0.local "sudo journalctl -b > /tmp/CPUE.log; \
        sudo scp /tmp/CPUE.log oam-0.local:/tmp/GNB_VM_LOGS/"
    ssh upue-0.local "sudo journalctl -b > /tmp/UPUE.log; \
        sudo scp /tmp/UPUE.log oam-0.local:/tmp/GNB_VM_LOGS/"
    ssh cpnrt-0.local "sudo journalctl -b > /tmp/CPNRT.log; \
        sudo scp /tmp/CPNRT.log oam-0.local:/tmp/GNB_VM_LOGS/"
}

function get_gnb_classical_logs(){
    printf "\n########## CLASSICAL GNB LOG COLLECTION IN PROGRESS ##########\n"

    if [ ! -d "/tmp/GNB_CLASSICAL_LOGS" ]
    then
        mkdir /tmp/GNB_CLASSICAL_LOGS/
    fi

    cd /tmp/GNB_CLASSICAL_LOGS/
    mkdir ASIK_MASTER/ ABIL_MASTER/ ASIK_SLAVE/ ASIK_CONTAINERS/
    cd /tmp/GNB_CLASSICAL_LOGS/ASIK_CONTAINERS/
    mkdir -p CPCL/ CPNB/ CPIF/ CPRT/ CPUE/ UPUE/ CPNRT/ OAM/siteoam/ OAM/racoam/

    cp /tmp/*startup* /tmp/GNB_CLASSICAL_LOGS/ASIK_MASTER/
    cp -f /tmp/node_0xe000/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/logs/* /tmp/GNB_CLASSICAL_LOGS/ASIK_CONTAINERS/OAM/siteoam/
    cp -f /tmp/node_0xe000/opt/nokia/SS_MzOam/cloud-racoam/logs/* /tmp/GNB_CLASSICAL_LOGS/ASIK_CONTAINERS/OAM/racoam/
    cp -f /tmp/node_0xe002/tmp/*startup* /tmp/GNB_CLASSICAL_LOGS/ASIK_CONTAINERS/CPCL/
    cp -f /tmp/node_0xe003/tmp/*startup* /tmp/GNB_CLASSICAL_LOGS/ASIK_CONTAINERS/CPNB/
    cp -f /tmp/node_0xe004/tmp/*startup* /tmp/GNB_CLASSICAL_LOGS/ASIK_CONTAINERS/CPIF/
    cp -f /tmp/node_0xe00a/tmp/*.log* /tmp/GNB_CLASSICAL_LOGS/ASIK_CONTAINERS/UPUE/
    scp -o StrictHostKeyChecking=no toor4nsn@192.168.253.17:/tmp/node_0xe005/tmp/startup* /tmp/GNB_CLASSICAL_LOGS/ASIK_CONTAINERS/CPRT/
    scp -o StrictHostKeyChecking=no toor4nsn@192.168.253.17:/tmp/node_0xe007/tmp/startup* /tmp/GNB_CLASSICAL_LOGS/ASIK_CONTAINERS/CPUE/
    scp -o StrictHostKeyChecking=no toor4nsn@192.168.253.17:/tmp/node_0xe008/tmp/startup* /tmp/GNB_CLASSICAL_LOGS/ASIK_CONTAINERS/CPNRT/
    scp -o StrictHostKeyChecking=no toor4nsn@192.168.253.20:/tmp/*startup* /tmp/GNB_CLASSICAL_LOGS/ABIL_MASTER/
    scp -o StrictHostKeyChecking=no toor4nsn@192.168.253.17:/tmp/*startup* /tmp/GNB_CLASSICAL_LOGS/ASIK_SLAVE/
}

function get_ap_logs(){
    printf "\n########## CLASSICAL AP LOG COLLECTION IN PROGRESS ###########\n"

    if [ ! -d "/tmp/AP_LOGS" ]
    then
        mkdir /tmp/AP_LOGS/
    fi

    cd /tmp/AP_LOGS/
    mkdir -p ASIK_MASTER/ ASIK_SLAVE/ ABIL_MASTER/ ABIL_SLAVE/ OAM/siteoam/ OAM/racoam/

    cp /tmp/*startup* /tmp/APL3.log /tmp/AP_LOGS/ASIK_MASTER/
    scp -o StrictHostKeyChecking=no toor4nsn@192.168.253.81:/tmp/*startup* /tmp/AP_LOGS/ASIK_SLAVE/
    scp -o StrictHostKeyChecking=no toor4nsn@192.168.253.84:/tmp/*startup* /tmp/AP_LOGS/ABIL_MASTER/
    scp -o StrictHostKeyChecking=no toor4nsn@192.168.253.85:/tmp/*startup* /tmp/AP_LOGS/ABIL_SLAVE/
    cp -f /tmp/node_0xe000/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/logs/* /tmp/AP_LOGS/OAM/siteoam/
    cp -f /tmp/node_0xe000/opt/nokia/SS_MzOam/cloud-racoam/logs/* /tmp/AP_LOGS/OAM/racoam/

    bsh 1 "[ -e '/var/tmp/CCS-RT_crashdumps_0_B_502a.tar' ]"
    if [ $? ]
    then
        scp toor4nsn@192.168.253.2:/var/tmp/CCS-RT_crashdumps_0_B_502a.tar /tmp/AP_LOGS/ASIK_SLAVE/
    fi

    bsh 1:0 "[ -e '/var/tmp/CCS-RT_crashdumps_1_A_523a.tar' ]"
    if [ $? ]
    then
        scp fsp-5-1a:/var/tmp/CCS-RT_crashdumps_1_A_523a.tar /tmp/AP_LOGS/ABIL_MASTER/
    fi
    bsh 1:1 "[ -e '/var/tmp/CCS-RT_crashdumps_1_B_524a.tar' ]"
    if [ $? ]
    then
        scp fsp-5-1b:/var/tmp/CCS-RT_crashdumps_1_B_524a.tar /tmp/AP_LOGS/ABIL_SLAVE/
    fi
}

function get_wts_logs(){
    printf "\n########## WTS LOG COLLECTION IN PROGRESS ##########\n"

    mkdir ./${DEST}/LOGS/WTS_LOGS/
    cp ${WTS_PATH}/*.log* ./${DEST}/LOGS/WTS_LOGS/
    printf "########## WTS LOG COLLECTION DONE ##########\n"
}

function collect_logs(){
    mkdir -p $DEST/LOGS/

    sshpass -p $ASIK_PASSWORD ssh ${ASIK_HOSTNAME}@${ASIK_AP_IP} "$(typeset -f); get_ap_logs"
    sshpass -p $ASIK_PASSWORD scp -r ${ASIK_HOSTNAME}@${ASIK_AP_IP}:/tmp/AP_LOGS "./${DEST}/LOGS"

    if [ "${GNB_TYPE}" == 'classical' ]
    then
        sshpass -p $ASIK_PASSWORD ssh ${ASIK_HOSTNAME}@${ASIK_GNB_IP} "$(typeset -f); get_gnb_classical_logs"
        sshpass -p $ASIK_PASSWORD scp -r ${ASIK_HOSTNAME}@${ASIK_GNB_IP}:/tmp/GNB_CLASSICAL_LOGS "./${DEST}/LOGS"
    else
        sshpass -p $ASIK_PASSWORD ssh ${OAM_HOSTNAME}@${OAM_GNB_IP} "$(typeset -f); get_gnb_vm_logs"
        sshpass -p $ASIK_PASSWORD ssh ${ASIK_HOSTNAME}@${ASIK_GNB_IP} "$(typeset -f); get_gnb_du_logs"

        sshpass -p $ASIK_PASSWORD scp -r ${OAM_HOSTNAME}@${OAM_GNB_IP}:/tmp/GNB_VM_LOGS/ ./${DEST}/LOGS/
        sshpass -p $ASIK_PASSWORD scp -r ${ASIK_HOSTNAME}@${ASIK_GNB_IP}:/tmp/GNB_DU_LOGS/ ./${DEST}/LOGS/
    fi

    get_wts_logs
}

function collect_configs(){
    mkdir -p $DEST/CONFIGS/WTS/

    sshpass -p $ASIK_PASSWORD ssh ${ASIK_HOSTNAME}@${ASIK_AP_IP} "
        mkdir -p /tmp/AP_CLASSICAL_CONFIGS/
        cd /tmp/AP_CLASSICAL_CONFIGS/
        mkdir ASIK_MASTER/ BIM_FILES/
        cp /ffs/run/swconfig.txt* /tmp/AP_CLASSICAL_CONFIGS/ASIK_MASTER/
        cp /ffs/run/config/node_0xe000/config/cbim_repo.json /tmp/AP_CLASSICAL_CONFIGS/BIM_FILES/
        cp /ffs/run/config/node_0xe000/config/pbim_repo.json /tmp/AP_CLASSICAL_CONFIGS/BIM_FILES/"

    sshpass -p $ASIK_PASSWORD scp -r ${ASIK_HOSTNAME}@${ASIK_AP_IP}:/tmp/AP_CLASSICAL_CONFIGS/ ./$DEST/CONFIGS/

    if [ "${GNB_TYPE}" == 'classical' ]
    then
        sshpass -p $ASIK_PASSWORD ssh ${ASIK_HOSTNAME}@${ASIK_GNB_IP} "
            mkdir -p /tmp/GNB_CLASSICAL_CONFIGS/ASIK_MASTER/ /tmp/GNB_CLASSICAL_CONFIGS/BIM_FILES/
            cp /ffs/run/swconfig.txt* /tmp/GNB_CLASSICAL_CONFIGS/ASIK_MASTER/
            cp /ffs/run/config/node_0xe000/config/cbim_repo.json /tmp/GNB_CLASSICAL_CONFIGS/BIM_FILES/
            cp /ffs/run/config/node_0xe000/config/pbim_repo.json /tmp/GNB_CLASSICAL_CONFIGS/BIM_FILES/"

        sshpass -p $ASIK_PASSWORD scp -r ${ASIK_HOSTNAME}@${ASIK_GNB_IP}:/tmp/GNB_CLASSICAL_CONFIGS/ ./$DEST/CONFIGS/
    else
        sshpass -p $ASIK_PASSWORD ssh ${ASIK_HOSTNAME}@${ASIK_GNB_IP} "
            mkdir -p /tmp/GNB_DU_CONFIGS/ASIK_MASTER/
            cp /ffs/run/swconfig.txt* /tmp/GNB_DU_CONFIGS/ASIK_MASTER/"

        sshpass -p $ASIK_PASSWORD ssh ${OAM_HOSTNAME}@${OAM_GNB_IP} "
            mkdir -p /tmp/GNB_VM_CONFIGS/BIM_FILES/
            sudo cp /mnt/services/mzoam/config/*.*.*/bims/*bim_repo.json /tmp/GNB_VM_CONFIGS/BIM_FILES/"

        sshpass -p $ASIK_PASSWORD scp -r ${ASIK_HOSTNAME}@${ASIK_GNB_IP}:/tmp/GNB_DU_CONFIGS/ ./$DEST/CONFIGS/
        sshpass -p $ASIK_PASSWORD scp -r ${OAM_HOSTNAME}@${OAM_GNB_IP}:/tmp/GNB_VM_CONFIGS/ ./$DEST/CONFIGS/
    fi

    cp ${WTS_PATH}/AirPhoneConfig* ./$DEST/CONFIGS/WTS/
    cp ${WTS_PATH}/basic* ./$DEST/CONFIGS/WTS/
}

function collect_pcaps(){
    mkdir -p $DEST/PCAPS/WTS/ $DEST/PCAPS/AP/ $DEST/PCAPS/GNB/

    if [ "${GNB_TYPE}" != 'classical' ]
    then
        sshpass -p $ASIK_PASSWORD ssh ${OAM_HOSTNAME}@${OAM_GNB_IP} "sudo scp ueup-0.local:/tmp/*.pcap* /tmp/"
        sshpass -p $ASIK_PASSWORD scp ${OAM_HOSTNAME}@${OAM_GNB_IP}:/tmp/*.pcap* ./${DEST}/PCAPS/AP/
    fi

    sshpass -p $ASIK_PASSWORD ssh ${ASIK_HOSTNAME}@${ASIK_AP_IP} "scp toor4nsn@192.168.253.2:/tmp/*.pcap* /tmp/"
    sshpass -p $ASIK_PASSWORD ssh ${ASIK_HOSTNAME}@${ASIK_GNB_IP} "scp toor4nsn@192.168.253.2:/tmp/*.pcap* /tmp/"

    sshpass -p $ASIK_PASSWORD scp ${ASIK_HOSTNAME}@${ASIK_AP_IP}:/tmp/*.pcap* ./${DEST}/PCAPS/AP/
    sshpass -p $ASIK_PASSWORD scp ${ASIK_HOSTNAME}@${ASIK_GNB_IP}:/tmp/*.pcap* ./${DEST}/PCAPS/GNB/
    cp ${WTS_PATH}/*.pcap* ./$DEST/PCAPS/WTS/
}

if [ "${OAM_GNB_IP}" == '' ]; then
    GNB_TYPE='classical'
fi


clear
DEST=` date '+%Y%m%d_%H%M%S'_LOGS`
collect_logs
collect_configs
collect_pcaps
tar czvf ${DEST}.tar.tgz ${DEST}
rm -rf $DEST
