#!/bin/bash -x
####################################################
# V1.0  ABIO mirror script - Gopalakrishnan N      #
#                                                  #
####################################################
fs_asib_abio() {
    /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L2HI_L2RT -b "C2B4(2)" -s 5 -l eths3 -v 303
    ncp_portmirror -p xgmac96 -r
    ncp_portmirror -d netdriver -p xgmac96
    /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b "C2B4(2)" -s 5 -l eths3 -v 304
    ncp_portmirror -p xgmac96 -r
    ncp_portmirror -d netdriver -p xgmac96
    /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL -b "C2B4(2)" -s 5 -l eths3 -v 305
    ncp_portmirror -p xgmac96 -r
    ncp_portmirror -d netdriver -p xgmac96
    echo 3 ingress > /var/run/cpss/ports/5/mirroring_port
    echo 3 ingress > /var/run/cpss/ports/6/mirroring_port
    ncp_portmirror -d netdriver -p xgmac96
    ncp_l2 -p XGMAC96 -I -senableSwitching.false
    ncp_l2 -p XGMAC96 -i -sdiscardInvalidVlanidPackets.false
    ncp_l2 -p XGMAC96 -i -sdiscardBadLengthPackets.false
}

l1b_asib_abio() {
   for i in 4 5 6
   do
     echo 3 both> /var/run/cpss/ports/$i/mirroring_port
   done
   ncp_portmirror -d netdriver -p xgmac96
   ncp_l2 -p XGMAC96 -I -senableSwitching.false
   ncp_l2 -p XGMAC96 -i -sdiscardInvalidVlanidPackets.false
   ncp_l2 -p XGMAC96 -i -sdiscardBadLengthPackets.false
}

l1b_BOOO_AP_KLL() {
   for i in 4 5 6 8 9 10 12 13 14
   do
     echo 3 both> /var/run/cpss/ports/$i/mirroring_port
   done
   ncp_portmirror -d netdriver -p xgmac96
   ncp_l2 -p XGMAC96 -I -senableSwitching.false
   ncp_l2 -p XGMAC96 -i -sdiscardInvalidVlanidPackets.false
   ncp_l2 -p XGMAC96 -i -sdiscardBadLengthPackets.false
}

l1b_BOO_AP_KLLL() {
   echo 1 >  /var/run/cpss/ports/3/enable
   ifconfig eths3 up
   for i in 4 5 6 7 8 9 10 11
   do
     echo 3 both> /var/run/cpss/ports/$i/mirroring_port
   done
   ncp_portmirror -d netdriver -p xgmac96
   ncp_l2 -p XGMAC96 -I -senableSwitching.false
   ncp_l2 -p XGMAC96 -i -sdiscardInvalidVlanidPackets.false
   ncp_l2 -p XGMAC96 -i -sdiscardBadLengthPackets.false
}


l1b_asil_abio() {
   bcicmd -n 3msd -c '/dbg3ms/mirror set 28 13 both'
   dbgnac set port 2 speed 25000
   dbgnac enable port 2
   dbgnac set port 2 loop e t
   dbgnac mirror sport 0 dport 2 e b
   dbgnac mirror sport 2 dport 20 e b
   /usr/bin/netd_uspace_lnk 2 1 25000 1
   ifconfig nac_eth2 up
}

start_abio_mirroring() {
    topology=$1
    if [ $topology = 'CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD' ]; then
        fs_asib_abio
    fi
    if [ $topology = 'CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD' -o $topology = 'CLOUD_5G_I_BO_AP_KL_NSA_L1B_ECPRI_MMWV_TDD' ]; then
        l1b_asib_abio
    fi
    if [ $topology = 'CLOUD_5G_I_LO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD' ]; then
        l1b_asil_abio
    fi
    if [ $topology = 'CLOUD_5G_I_BN_AP_KL_SANSA_FS_CPRI_CMWV_FDD' ]; then
        fs_asib_abio
    fi
    if [ $topology = 'CLOUD_5G_I_BOOO_AP_KLL_NSA_L1B_ECPRI_CMWV_TDD' ]; then
        l1b_BOOO_AP_KLL
    fi
    if [ $topology = 'CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD' ]; then
        l1b_BOO_AP_KLLL
    fi
}

start_abio_mirroring "$@"
