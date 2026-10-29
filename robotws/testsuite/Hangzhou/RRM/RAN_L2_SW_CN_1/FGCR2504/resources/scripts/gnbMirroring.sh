#!/bin/bash
#
###############################################################################
# Script to configure and enable Mirroring in Loner and tcpdumps to ABIL Slave Xeon.
# ASIK can be on left or right side of AMIA.
#
# USAGE
#   - Copy script files to ASIK (for example to /ffs/run/config/scripts/ folder)
#       - gnbMirroring.sh, gnbMirroringConfig.sh and gulp
#   - Give execution rights 
#       chmod +x /ffs/run/config/scripts/*.sh
#   - Modify options in gnbMirroringConfig.sh
#   - Run script
#       sh /ffs/run/config/scripts/gnbMirroring.sh
#   - In local mode, capture is stored to /tmp/tcpdumpL2L1[_gulp]_filtering_[off|on].pcap000
#   - Remember to delete captures from ASIK after downloading to not to break SW upgrade due to insufficient disk space
#
# FILTERING
# Capture filter in tcpdump filters out the following messages, message IDs apply for 5G19, may not work correctly in 19A
#   - SyncInd 0x206
#   - PatternConfigReq 0x116
#   - SlotTypeReq 0x122
#   - CsiRsSendReq 0x120
#   - SsBlocSendReq 0x123
#   - PrachReceiveReq 0x233
#   Changes in 5G19A - L1R51
#   - PatternConfigReq 0x12b
#   - CsiRsSendReq 0x12a
#   - SsBlocSendReq 0x127
#   Changes in 5G19B
#   - PrachReceiveReq 0x240
#   - CsiRsSendReq 0x131
#   Changes in 5G20A
#   - PatternConfigReq 0xe101
#
# LINKS AND INFORMATION
#   gnbMirroring confluence
#     https://confluence.int.net.nokia.com/pages/viewpage.action?spaceKey=CV&title=gNB+Mirroring
#
#   ASIK Red Rock Canyon (RRC) ports distribution:
#     https://confluence.int.net.nokia.com/display/OPSW1/ASIK+Red+Rock+Canyon+%28RRC%29+ports+distribution
#
#   Loner problem solving wiki BIP mirroring
#     https://confluence.int.net.nokia.com/display/CUP/Capture+Loner+BIP+traffic
#
#   Script is stored in rotta:
#     \\eseefsn50.emea.nsn-net.net\rotta4internal\5G\Oulu_L3_CAMP\gnbMirroring
#
# HISTORY:
#   12.7.2019  V1:  - The first version. 
#                   - Tested with Loner HIFIX_VERSION_ID="loner_R50.0.0.20190625-083354"
#                   - Partly tested with HIFIX_VERSION_ID="loner_R51-TDD-CPRI.0.0.20190703-073310"
#
#   6.8.2019   V2:  - MAC interface for loner mirroring was changed with the new Loner release.
#                   - IP addresses in right side of AMIA are different than left side with cOAM.
#                   - Fixed tcpdump filtering for 5G19A
#                   - Tested with HIFIX_VERSION_ID="loner_R51-TDD-CPRI.0.0.20190722-124846"
#
#   16.8.2019  V3:  - Support for Carrier Aggregation, not tested, for GC2/GD2 L2-RT instances
#                   - support for eCpri Loner, tested with HIFIX_VERSION_ID="loner_R51-TDD-eCPRI.0.0.20190722-134619"
#                   - L1R51 version string was changed to capitals, HIFIX_VERSION_ID="LONER-TDD-CPRI-QSFP_R51.0.0.20190813-134103"
#
#   23.8.2019  V4:  - Support for L1R52
#                   - Use monitored_ports_mask and monitored_port_flag to enable Loner mirroring
#                   - Loner mirroring is disabled in standalone mode after tcpdump
#                   - Tested 
#                       - HIFIX_VERSION_ID="LONER-TDD-CPRI-QSFP_R51.0.0.20190813-134103"
#                       - HIFIX_VERSION_ID="loner_R50.0.0.20190719-112539"
#                       - HIFIX_VERSION_ID="loner_R52-TDD-CPRI.0.0.20190806-013011"
#
#   12.9.2019  V5:  - Corrected standalone tcpdump target ABIL Slave Xeon IP for ASIK on right side configs
#
#   20.9.2019  V6:  - Support for 5G19B
#                   - Tested
#                       - HIFIX_VERSION_ID="LONER-TDD-CPRI_5G19B.0.0.20190912-205633"
#
#   22.9.2019  V7:  - Corrected instructions to stop standalone tcpdump, use Ctrl-C instead of Ctrl-Z
#                   - Kill tcpdump process from Abil Slave Xeon if standalone tcpdump is interrupted
#
#   25.9.2019  V8:  - Loner security does not allow direct ssh, changed to bsh
#                   - Tested
#                       - HIFIX_VERSION_ID="LONER-TDD-CPRI-SFP_R52.0.0.20190918-025115"
#
#   3.10.2019  V9:  - eLoner monitoring arbiter changed to arb0p2
#                   - Tested
#                       - HIFIX_VERSION_ID="LONER-TDD-eCPRI_R51.0.0.20191002-122705"
#
#   25.10.2019 V10: - Added checks for script file name and folder
#                   - Changed folder for storing standalone tcpdump files
#                   - Added support to start standalone mirroring after remote
#
#   25.10.2019 V11: - Hide unnecessary warnings from console logs
#                   - Moved options to an own file
#
#   11.11.2019 V12: - Removed dual option from filtering 
#                   - Standalone tcpdump is done to /tmp folder in Abil Slave Xeon and then copied to Asik Master Xeon
#
#   15.11.2019 V13: - Preaparations for using GULP, not working yet
#                   - Quick and dirty hack to support standalone dumping in ASIB
#
#   19.11.2019 V14: - Automatic detection of HW type
#                   - Removed dependency for script location and name
#                   - support for multiple ABILs with ASIB
#
#   20.11.2019 V15: - Standalone mode dump size is defined in duration instead of number of packets
#                   - GULP is supported for ASIK/ABIL, needs to be enabled from config, thanks to jakub.trznadel@nokia.com
#
#   4.12.2019  V16: - Fixed 5G19 mirroring which was broken in V15
#                   - Preparations for ASOD
#
#   5.12.2019  V17: - Added support for command line arguments, see gnbMirroringConfig.sh for syntax
#                   - Fixed path dependency problem for gnbMirroringConfig.sh
#                   
#   13.12.2019 V18: - Added command line help, can be printed with -h|--help
#
#   13.12.2019 V19: - Added support for rotating buffer, i.e. user can define size and number of files for dumping
#                     Thanks to tomasz.turski@nokia.com and guillaume.bousquet@nokia.com for contributing
#
#   19.12.2019 V20: - Preparations for ASIL. Missing correction to "PR492359: [5G20A][ASIL]: L1/L2 mirroring not working"
#                   - Added support for ASIB remote mirroring, thanks to jari-pekka.tuikka@nokia.com
#                     Requires Loner with correction to "PR488560: [5G20A] [ASIB] BIP mirroring in ASIB-ABIL config doesn't work"
#
#   19.12.2019 V21: - Added a new MIRRORING_MODE 'manual' which starts standalone type mirroring but does not capture data nor disable mirroring
#
#   4.2.2020   V22: - ASIB mirroring SEI interface changed according to ICOM specification
#
#   10.2.2020  V23: - Support for "5GC001514 Distributed SW Deployment"
#
#   12.5.2020  V24: - Preparation for ASOD
#                   - Added 5G20A dldata_patternConfigReq to filter
#                   - Added 5G19B dldata_csiRsSendReq to filter
#                   - Only RRC ingress traffic is mirrored from Loner port
#
#   29.5.2020  V25: - Changed mode standalone -> local 
#                   - Added a few checks for options to prevent illegal configuration
#                   - Optimized ASIK RRC configuration to prevent RRC flooding in CARRIER_AGGREGATION
#                   - Added enabling Loner L1->L2 mirroring which is disabled by default in new Loners (PR504347)
#                   - Added options for backhaul and F1-u mirroring, functionality is not verified
#
#   1.6.2020   V26: - Fixed bug in multi-ABIL syscom mirroring
#                   - Fixed bug in multi-ABIL L1->L2 mirroring enabling
#
# BUG REPORTS:
#   Provide console log and capture to juha.kangas@nokia.com
# 
###############################################################################

YELLOW='\e[33m'
RED='\e[31m'
GREEN='\e[32m'
NC='\e[0m'

#abil1_master_xeon 192.168.253.20
#abil1_slave_xeon 192.168.253.21
#abil1_loner 192.168.253.22
##etha01=`ifconfig etha01 | grep inet`
##etha01_ip=${etha01:13:14}
##if [ $etha01_ip = '192.168.253.32' ]; then
##  abil1_slave_xeon_ip='192.168.253.37'
##  abil1_loner_ip='192.168.253.38'
##  abil2_loner_ip='192.168.253.42'
##  abil3_loner_ip='192.168.253.46'
##else
##  abil1_slave_xeon_ip='192.168.253.21'
##  abil1_loner_ip='192.168.253.22'
##  abil2_loner_ip='192.168.253.26'
##  abil3_loner_ip='192.168.253.30'
##fi

filtered_messages_when_filtering_on="ether[0x18:2]!=0xe101 && ether[0x18:2]!=0x131 && ether[0x18:2]!=0x206 && ether[0x18:2]!=0x116 && ether[0x18:2]!=0x122 && ether[0x18:2]!=0x120 && ether[0x18:2]!=0x123 && ether[0x18:2]!=0x233 && ether[0x18:2]!=0x12b && ether[0x18:2]!=0x12a && ether[0x18:2]!=0x127 && ether[0x18:2]!=0x240"

abil1_master_xeon_node='1:0'
abil1_slave_xeon_node='1:1'
abil1_loner_node='1:2'
abil2_loner_node='2:2'
abil3_loner_node='3:2'

enable='e'
disable='d'

# ASIK RRC
asik_rrc_eif1_port=14
asik_rrc_eif2_port=15
asik_rrc_abil1_master_xeon_port=20
asik_rrc_abil1_slave_xeon_port=21
asik_rrc_abil1_loner_port0=22
asik_rrc_abil1_eth_switch_port=23
asik_rrc_abil1_loner_port1=25
asik_rrc_abil2_master_xeon_port=28
asik_rrc_abil2_slave_xeon_port=29
asik_rrc_abil2_loner_port0=30
asik_rrc_abil2_eth_switch_port=31
asik_rrc_abil2_loner_port1=33
asik_rrc_abil3_master_xeon_port=36
asik_rrc_abil3_slave_xeon_port=37
asik_rrc_abil3_loner_port0=38
asik_rrc_abil3_eth_switch_port=39
asik_rrc_abil3_loner_port1=41
asik_abil1_l2ps_mac1111='02:40:43:80:11:11'
asik_abil1_l2ps_mac1112='02:40:43:80:11:12'
asik_abil1_l2ps_mac1113='02:40:43:80:11:13'
asik_abil1_l2ps_mac1114='02:40:43:80:11:14'
asik_abil1_l2ps_mac1115='02:40:43:80:11:15'
asik_abil1_l2ps_mac1116='02:40:43:80:11:16'
asik_abil1_l2ps_mac1117='02:40:43:80:11:17'
asik_abil1_l2ps_mac2111='02:40:43:80:21:11'
asik_abil1_l2ps_mac2112='02:40:43:80:21:12'
asik_abil1_l2ps_mac2113='02:40:43:80:21:13'
asik_abil1_l2ps_mac2114='02:40:43:80:21:14'
asik_abil1_l2ps_mac2115='02:40:43:80:21:15'
asik_abil1_l2ps_mac2116='02:40:43:80:21:16'
asik_abil1_l2ps_mac2117='02:40:43:80:21:17'
asik_abil1_l2ps_mac1131='02:40:43:80:11:31'
asik_abil1_l2ps_mac1132='02:40:43:80:11:32'
asik_abil1_l2ps_mac1133='02:40:43:80:11:33'
asik_abil1_l2ps_mac1134='02:40:43:80:11:34'
asik_abil1_l2ps_mac1135='02:40:43:80:11:35'
asik_abil1_l2ps_mac1136='02:40:43:80:11:36'
asik_abil1_l2ps_mac1137='02:40:43:80:11:37'
asik_abil1_l2ps_mac2131='02:40:43:80:21:31'
asik_abil1_l2ps_mac2132='02:40:43:80:21:32'
asik_abil1_l2ps_mac2133='02:40:43:80:21:33'
asik_abil1_l2ps_mac2134='02:40:43:80:21:34'
asik_abil1_l2ps_mac2135='02:40:43:80:21:35'
asik_abil1_l2ps_mac2136='02:40:43:80:21:36'
asik_abil1_l2ps_mac2137='02:40:43:80:21:37'
asik_abil1_l2ps_mac0131='02:40:43:80:01:31'
asik_abil1_l2ps_mac0132='02:40:43:80:01:32'
asik_abil1_l2ps_mac0133='02:40:43:80:01:33'
asik_abil1_l2ps_mac0134='02:40:43:80:01:34'
asik_abil1_l2ps_mac0135='02:40:43:80:01:35'
asik_abil1_l2ps_mac0136='02:40:43:80:01:36'
asik_abil1_l2ps_mac0137='02:40:43:80:01:37'
asik_abil1_l2ps_mac1131='02:40:43:80:11:31'
asik_abil1_l2ps_mac1132='02:40:43:80:11:32'
asik_abil1_l2ps_mac1133='02:40:43:80:11:33'
asik_abil1_l2ps_mac1134='02:40:43:80:11:34'
asik_abil1_l2ps_mac1135='02:40:43:80:11:35'
asik_abil1_l2ps_mac1136='02:40:43:80:11:36'
asik_abil1_l2ps_mac1137='02:40:43:80:11:37'
asik_abil1_l2ps_mac0139='02:40:43:80:01:39'
asik_abil1_l2ps_mac013a='02:40:43:80:01:3a'
asik_abil1_l2ps_mac013b='02:40:43:80:01:3b'
asik_abil1_l2ps_mac013c='02:40:43:80:01:3c'
asik_abil1_l2ps_mac013d='02:40:43:80:01:3d'
asik_abil1_l2ps_mac013e='02:40:43:80:01:3e'
asik_abil1_l2ps_mac013f='02:40:43:80:01:3f'
asik_abil1_l2ps_mac1139='02:40:43:80:11:39'
asik_abil1_l2ps_mac113b='02:40:43:80:11:3a'
asik_abil1_l2ps_mac113b='02:40:43:80:11:3b'
asik_abil1_l2ps_mac113c='02:40:43:80:11:3c'
asik_abil1_l2ps_mac113d='02:40:43:80:11:3d'
asik_abil1_l2ps_mac113e='02:40:43:80:11:3e'
asik_abil1_l2ps_mac113f='02:40:43:80:11:3f'
asik_abil1_loner_mac='02:40:43:80:11:04'
asik_abil2_loner_mac='02:40:43:80:12:04'
asik_abil3_loner_mac='02:40:43:80:13:04'
asik_abil1_loner_mac_ipv6='02:40:43:80:01:04'
asik_abil2_loner_mac_ipv6='02:40:43:80:02:04'
asik_abil3_loner_mac_ipv6='02:40:43:80:03:04'
asik_bip_vlan=201

# ASIL Monterey 3MS
asil_monterey_nac_port=13
asil_monterey_abil1_master_xeon_port=35
asil_monterey_abil1_slave_xeon_port=36
asil_monterey_abil1_eth_switch_port=37
asil_monterey_abil1_loner_port=38
asil_monterey_abil2_master_xeon_port=39
asil_monterey_abil2_slave_xeon_port=40
asil_monterey_abil2_eth_switch_port=41
asil_monterey_abil2_loner_port=42
asil_monterey_abil3_master_xeon_port=43
asil_monterey_abil3_slave_xeon_port=44
asil_monterey_abil3_eth_switch_port=45
asil_monterey_abil3_loner_port=46
# ASIL NAC (Network Accelerator Complex)
asil_nac_monterey_port=0
asil_nac_eif2_port=14

# ASIB Marvell 98DX8324
asib_marvell_abil1_master_xeon_port=4
asib_marvell_abil1_slave_xeon_port=5
asib_marvell_abil1_eth_switch_port=6
asib_marvell_abil1_loner_port=7
#asib_marvell_abil2_master_xeon_port=8
#asib_marvell_abil2_slave_xeon_port=9
asib_marvell_abil2_eth_switch_port=10
asib_marvell_abil2_loner_port=11
#asib_marvell_abil3_master_xeon_port=12
#asib_marvell_abil3_slave_xeon_port=13
asib_marvell_abil3_eth_switch_port=14
asib_marvell_abil3_loner_port=15
asib_marvell_ncp_port=2
# ASIB NCP () 
asib_ncp_marvell_interface='eths2'
asib_ncp_marvell_port='xgmac97'
#asib_ncp_sei_interface='ethsei00'
#asib_ncp_sei_port='xgmac64'
asib_ncp_sei_interface='ethsei10'
asib_ncp_sei_port='xgmac32'
#asib_ncp_sei_interface='ethsei12'
#asib_ncp_sei_port='xgmac48'


# ASOD Marvell 98DX8312



################################## COMMON ##################################

setFilter() {
    if [ $FILTERING = 'off' ]; then
        filtered_messages=""
    else
        filtered_messages=$filtered_messages_when_filtering_on
    fi
    echo -e "\n${YELLOW}Filtering $filtered_messages${NC}"
}

evaluateTimeout() {
    if [ $CAPTURING_TIME_SECONDS = 'infinite' ]; then
        timeoutCommand=""
    else
        timeoutCommand="timeout -s 2 --foreground $CAPTURING_TIME_SECONDS"
    fi
}

runTcpdump() {
    echo -e "\n${YELLOW}tcpdump $CAPTURING_TIME_SECONDS seconds. Can be stopped with Ctrl-C. Output is saved to /tmp/tcpdumpL2L1_filtering_$FILTERING.pcap${NC}"
    setFilter
    evaluateTimeout
    $timeoutCommand bsh $1 "tcpdump -i ethbp1 -C $FILE_SIZE_MBYTES -W $NUMBER_OF_FILES -w /tmp/tcpdumpL2L1_filtering_$FILTERING.pcap '$filtered_messages'"
    bsh $1 "pkill -2 tcpdump"
    files=`bsh $1 "ls /tmp/tcpdumpL2L1_filtering_$FILTERING.pcap*"`
    for file in $files 
    do
        bget $1 $file /tmp/
    done
    bsh $1 "rm /tmp/tcpdumpL2L1*"
}

copyAndRunGulp() {
    echo -e "\n${YELLOW}Copy gulp to Abil Slave Xeon${NC}"
    bput $1 $directory/gulp /usr/sbin/
    bsh $1 "chmod +x /usr/sbin/gulp"
    bsh $1 "ln -s /usr/lib64/libpcap.so.1 /usr/lib64/libpcap.so.0.8" 2> /dev/null
    setFilter
    evaluateTimeout
    echo -e "\n${YELLOW}gulp $CAPTURING_TIME_SECONDS seconds. Can be stopped with Ctrl-C. Output is saved to /tmp/tcpdumpL2L1_gulp_filtering_$FILTERING.pcap000${NC}"
    $timeoutCommand bsh $1 "gulp -i ethbp1 -r $FILE_SIZE_MBYTES -C 1 -W $NUMBER_OF_FILES -o /tmp/ -n tcpdumpL2L1_gulp_filtering_$FILTERING.pcap -f '$filtered_messages'"
    bsh $1 "pkill -2 gulp"
    files=`bsh $1 "ls /tmp/tcpdumpL2L1_gulp_filtering_$FILTERING.pcap0*"`
    for file in $files 
    do
        bget $1 $file /tmp/
    done
    bsh $1 "rm /tmp/tcpdumpL2L1*"
}

captureData() {
    if [ $USE_GULP = 'true' ]; then
        copyAndRunGulp $1
    else
        runTcpdump $1
    fi
}

################################## ABIL ##################################

enableMirroringInLoner() {
    echo -e "\n${YELLOW}Enabling mirroring in Loner $1${NC}"
    bsh $1 "echo fffffff 2 > /sys/class/bip/bip0/device/multicast_ctrl"
    if [[ $swReleaseString == *"5G19_"* ]]; then
        echo -e "${YELLOW}Enable Loner mirroring from arb0p0 to arb0p1${NC}"
        bsh $1 "echo 0x1 > /sys/class/xlgx/xlgx0/device/monitored_ports_mask && echo 0x2 > /sys/class/xlgx/xlgx0/device/monitoring_port_flag"
    elif [[ $swReleaseString == *"ASIB"* ]] || [[ $swReleaseString == *"ASIL"* ]]; then
        echo -e "${YELLOW}Enable Loner mirroring from arb0p1 to arb0p0${NC}"
        bsh $1 "echo 0x2 > /sys/class/xlgx/xlgx0/device/monitored_ports_mask && echo 0x1 > /sys/class/xlgx/xlgx0/device/monitoring_port_flag"
        bsh $1 "ethtool -s arb0p0 phyad 1"
    else
        echo -e "${YELLOW}Enable Loner mirroring from arb0p0 and arb0p1 to arb0p2${NC}"
        bsh $1 "echo 0x3 > /sys/class/xlgx/xlgx0/device/monitored_ports_mask && echo 0x4 > /sys/class/xlgx/xlgx0/device/monitoring_port_flag"
    fi
}

enableMirroringInLoners() {
    if [ $MIRROR_ABIL_1 = 'true' ]; then enableMirroringInLoner "$abil1_loner_node"; fi
    if [ $MIRROR_ABIL_2 = 'true' ]; then enableMirroringInLoner "$abil2_loner_node"; fi
    if [ $MIRROR_ABIL_3 = 'true' ]; then enableMirroringInLoner "$abil3_loner_node"; fi
}

disableMirroringInLoner() {
    echo -e "${YELLOW}Disable mirroring in Loner $1${NC}"
    bsh $1 "echo 0x0 > /sys/class/xlgx/xlgx0/device/monitored_ports_mask && echo 0x0 > /sys/class/xlgx/xlgx0/device/monitoring_port_flag"
}

disableMirroringInLoners() {
    bsh $abil1_loner_node "echo 0 2 > /sys/class/bip/bip0/device/multicast_ctrl"
    if [ $MIRROR_ABIL_1 = 'true' ]; then disableMirroringInLoner "$abil1_loner_node"; fi
    if [ $MIRROR_ABIL_2 = 'true' ]; then disableMirroringInLoner "$abil2_loner_node"; fi
    if [ $MIRROR_ABIL_3 = 'true' ]; then disableMirroringInLoner "$abil3_loner_node"; fi
}



################################## ASOD ##################################
startMirroringInAsod() {
    if [ $MIRRORING_MODE = 'remote' ]; then
        echo -e "${RED}Disabling mirroring is not yet supported in ASIL${NC}"
        ./luaCLI -c "cpss-api call cpssDxChMirrRxAnalyzerDpTcSet devNum 0 analyzerDp CPSS_DP_GREEN_E analyzerTc 7"
        ./luaCLI -c "cpss-api call cpssDxChMirrTxAnalyzerDpTcSet devNum 0 analyzerDp CPSS_DP_GREEN_E analyzerTc 7"
        ./luaCLI -c "cpss-api call cpssDxChMirrorToAnalyzerForwardingModeSet devNum 0 mode CPSS_DXCH_MIRROR_TO_ANALYZER_FORWARDING_SOURCE_BASED_OVERRIDE_E"
        
        echo 1 both > /var/run/cpss/ports/9/mirroring_port
        echo 1 > /var/run/cpss/ports/1/enable
        cat /var/run/cpss/ports/mirror_info
        
        ddal -s ddal_sfp_ctrl_set 1 0 0
        
    else
        echo -e "${RED}Local mirroring is not yet supported in ASOD${NC}"
        
    fi
}


################################## ASIL ##################################

setMirroringInAsilMonterey() {
    if [ $2 = $enable ]; then
        command="both"
    else
        command="none"
    fi

    if [ $MIRROR_ABIL_1 = 'true' ]; then
        bcicmd -n 3msd -c "/dbg3ms/mirror set $asil_monterey_abil1_loner_port $1 $command"
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            bcicmd -n 3msd -c "/dbg3ms/mirror set $asil_monterey_abil1_eth_switch_port $1 $command"
        fi
    fi
    if [ $MIRROR_ABIL_2 = 'true' ]; then
        bcicmd -n 3msd -c "/dbg3ms/mirror set $asil_monterey_abil2_loner_port $1 $command"
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            bcicmd -n 3msd -c "/dbg3ms/mirror set $asil_monterey_abil2_eth_switch_port $1 $command"
        fi
    fi
    if [ $MIRROR_ABIL_3 = 'true' ]; then
        bcicmd -n 3msd -c "/dbg3ms/mirror set $asil_monterey_abil3_loner_port $1 $command"
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            bcicmd -n 3msd -c "/dbg3ms/mirror set $asil_monterey_abil3_eth_switch_port $1 $command"
        fi
    fi
    if [ $CARRIER_AGGREGATION = 'true' ]; then
        bcicmd -n 3msd -c "/dbg3ms/mirror set $asil_monterey_abil1_slave_xeon_port $1 $command"
    fi
	bcicmd -n 3msd -c "/dbg3ms/mirror show"
}

enableMirroringInAsilMonterey() {
    echo -e "${YELLOW}Enable mirroring in ASIL Monterey${NC}"
    setMirroringInAsilMonterey $1 "$enable"
}

disableMirroringInAsilMonterey() {
    echo -e "${YELLOW}Disable mirroring in ASIL Monterey${NC}"
    setMirroringInAsilMonterey $1 "$disable"
}

enableMirroringInAsilNac() {
    dbgnac set port $asil_nac_eif2_port speed 10000
    dbgnac enable port $asil_nac_eif2_port
    dbgnac mirror sport $asil_nac_monterey_port dport $asil_nac_eif2_port e b
    dbgnac mirror dump
}

startMirroringInAsil() {
    enableMirroringInLoners
    if [ $MIRRORING_MODE = 'remote' ]; then
        enableMirroringInAsilMonterey $asil_monterey_nac_port
        enableMirroringInAsilNac
    else
        enableMirroringInAsilMonterey $asil_monterey_abil1_master_xeon_port
        runTcpdump $abil1_master_xeon_node
        
        echo -e "${RED}Disabling mirroring is not yet supported in ASIL${NC}"
        #echo -e "\n${YELLOW}Disable mirroring${NC}"
        #disableMirroringInLoners
        #disableMirroringInAsilMonterey
    fi
}




################################## ASIB ##################################

setMirroringInAsibMarvell() {

    if [ $2 = $enable ]; then
        dest_port=$1
        file_to_write="mirroring_port"
    else
        dest_port=""
        file_to_write="disable_mirroring"
    fi
    
    if [ $MIRROR_ABIL_1 = 'true' ]; then
        echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil1_loner_port/$file_to_write
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil1_eth_switch_port/$file_to_write
        fi
    fi
    if [ $MIRROR_ABIL_2 = 'true' ]; then
        echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil2_loner_port/$file_to_write
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil2_eth_switch_port/$file_to_write
        fi
    fi
    if [ $MIRROR_ABIL_3 = 'true' ]; then
        echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil3_loner_port/$file_to_write
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil3_eth_switch_port/$file_to_write
        fi
    fi
    if [ $CARRIER_AGGREGATION = 'true' ]; then
        echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil1_slave_xeon_port/$file_to_write
    fi
    
    cat /var/run/cpss/ports/mirror_info
}

enableMirroringInAsibMarvell() {
    echo -e "\n${YELLOW}Enable mirroring in ASIB Marvell${NC}"
    setMirroringInAsibMarvell $1 "$enable"
}

disableMirroringInAsibMarvell() {
    echo -e "\n${YELLOW}Disable mirroring in ASIB Marvell${NC}"
    setMirroringInAsibMarvell $1 "$disable"
}

enableMirroringInAsibNcp() {
    ifconfig $asib_ncp_marvell_interface up
    ifconfig $asib_ncp_sei_interface up
    echo 1 > /var/run/cpss/ports/$asib_marvell_ncp_port/enable
    ncp_l2 -p $asib_ncp_marvell_port -I -sdefaultVlanId.100
    ncp_portmirror -p $asib_ncp_marvell_port -d $asib_ncp_sei_port
}

disableAsibMarvellRemoteMirroring() {
	echo both > /var/run/cpss/ports/$asib_marvell_abil1_loner_port/disable_mirroring 1> /dev/null
	echo both > /var/run/cpss/ports/$asib_marvell_abil1_eth_switch_port/disable_mirroring 1> /dev/null
	echo both > /var/run/cpss/ports/$asib_marvell_abil2_loner_port/disable_mirroring 1> /dev/null
	echo both > /var/run/cpss/ports/$asib_marvell_abil2_eth_switch_port/disable_mirroring 1> /dev/null
	echo both > /var/run/cpss/ports/$asib_marvell_abil3_loner_port/disable_mirroring 1> /dev/null
	echo both > /var/run/cpss/ports/$asib_marvell_abil3_eth_switch_port/disable_mirroring 1> /dev/null
	echo both > /var/run/cpss/ports/$asib_marvell_abil1_slave_xeon_port/disable_mirroring 1> /dev/null
}

startMirroringInAsib() {
    enableMirroringInLoners
    if [ $MIRRORING_MODE = 'remote' ]; then
        enableMirroringInAsibMarvell $asib_marvell_ncp_port
        enableMirroringInAsibNcp
    else
		disableAsibMarvellRemoteMirroring
        enableMirroringInAsibMarvell $asib_marvell_abil1_master_xeon_port
        
        if [ $MIRRORING_MODE = 'local' ]; then
            captureData $abil1_master_xeon_node
				
            echo -e "\n${YELLOW}Disable mirroring${NC}"
            disableMirroringInLoners
            disableMirroringInAsibMarvell $asib_marvell_abil1_master_xeon_port
        fi
    fi
}



################################## ASIK ##################################

disableMacLearningAndConfigureStaticMacAddressesToRrc() {
    dbgrrc set port $asik_rrc_abil1_loner_port1 macLearning 0
    dbgrrc add mac $asik_abil1_l2ps_mac1111 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1112 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1113 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1114 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1115 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1116 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1117 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac2111 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac2112 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac2113 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac2114 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac2115 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac2116 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac2117 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1131 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1132 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1133 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1134 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1135 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1136 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1137 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac2131 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac2132 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac2133 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac2134 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac2135 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac2136 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac2137 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac0131 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac0132 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac0133 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac0134 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac0135 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac0136 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac0137 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1131 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1132 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1133 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1134 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1135 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1136 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1137 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac0139 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac013a $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac013b $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac013c $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac013d $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac013e $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac013f $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac1139 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac113b $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac113b $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac113c $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac113d $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac113e $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_l2ps_mac113f $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil1_loner_mac $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil2_loner_mac $asik_bip_vlan $asik_rrc_abil2_loner_port0 static
    dbgrrc add mac $asik_abil3_loner_mac $asik_bip_vlan $asik_rrc_abil3_loner_port0 static
    dbgrrc add mac $asik_abil1_loner_mac_ipv6 $asik_bip_vlan $asik_rrc_abil1_loner_port1 static
    dbgrrc add mac $asik_abil2_loner_mac_ipv6 $asik_bip_vlan $asik_rrc_abil2_loner_port0 static
    dbgrrc add mac $asik_abil3_loner_mac_ipv6 $asik_bip_vlan $asik_rrc_abil3_loner_port0 static
}

setMirroringInAsikRrc() {
    if [ $MIRROR_ABIL_1 = 'true' ]; then
        if [ $CARRIER_AGGREGATION = 'true' ]; then
            disableMacLearningAndConfigureStaticMacAddressesToRrc
            dbgrrc mirror sport $asik_rrc_abil1_loner_port1 dport $1 $2 both
        else
            dbgrrc mirror sport $asik_rrc_abil1_loner_port1 dport $1 $2 ingress
        fi
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            dbgrrc mirror sport $asik_rrc_abil1_eth_switch_port dport $1 $2 both
        fi
    fi
    if [ $MIRROR_ABIL_2 = 'true' ]; then
        dbgrrc mirror sport $asik_rrc_abil2_loner_port1 dport $1 $2 ingress
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            dbgrrc mirror sport $asik_rrc_abil2_eth_switch_port dport $1 $2 both
        fi
    fi
    if [ $MIRROR_ABIL_3 = 'true' ]; then
        dbgrrc mirror sport $asik_rrc_abil3_loner_port1 dport $1 $2 ingress
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            dbgrrc mirror sport $asik_rrc_abil3_eth_switch_port dport $1 $2 both
        fi
    fi
    if [ $F1U_MIRRORING = 'true' ]; then
        dbgrrc mirror sport $asik_rrc_abil1_master_xeon_port dport $1 $2 both
    fi
    if [ $BACKHAUL_MIRRORING = 'true' ]; then
        dbgrrc mirror sport $asik_rrc_eif1_port dport $1 $2 both
    fi
    
}

enableMirroringInAsikRrc() {
    echo -e "${YELLOW}Enable mirroring in ASIK RRC${NC}"
    setMirroringInAsikRrc $1 "$enable"
}

disableMirroringInAsikRrc() {
    echo -e "${YELLOW}Disable mirroring in ASIK RRC${NC}"
    setMirroringInAsikRrc $1 "$disable"
}

disableAsikRrcRemoteMirroring() {
    dbgrrc mirror sport $asik_rrc_abil1_loner_port1 dport $asik_rrc_eif2_port disable ingress 1> /dev/null
    dbgrrc mirror sport $asik_rrc_abil1_eth_switch_port dport $asik_rrc_eif2_port disable both 1> /dev/null
    dbgrrc mirror sport $asik_rrc_abil2_loner_port1 dport $asik_rrc_eif2_port disable ingress 1> /dev/null
    dbgrrc mirror sport $asik_rrc_abil2_eth_switch_port dport $asik_rrc_eif2_port disable both 1> /dev/null
    dbgrrc mirror sport $asik_rrc_abil3_loner_port1 dport $asik_rrc_eif2_port disable ingress 1> /dev/null
    dbgrrc mirror sport $asik_rrc_abil3_eth_switch_port dport $asik_rrc_eif2_port disable both 1> /dev/null
    dbgrrc mirror sport $asik_rrc_abil1_master_xeon_port dport $asik_rrc_eif2_port disable both 1> /dev/null
}

enableEif2PortInAsikRrc() {
    dbgrrc enable port $asik_rrc_eif2_port
    dbgrrc set port $asik_rrc_eif2_port speed 10000
}

startMirroringInAsik() {
    enableMirroringInLoners
    
    if [ $MIRRORING_MODE = 'remote' ]; then
        enableMirroringInAsikRrc $asik_rrc_eif2_port
        enableEif2PortInAsikRrc
        
    else
        disableAsikRrcRemoteMirroring
        enableMirroringInAsikRrc $asik_rrc_abil1_slave_xeon_port
        
        if [ $MIRRORING_MODE = 'local' ]; then
            captureData $abil1_slave_xeon_node
                    
            echo -e "\n${YELLOW}Disable RRC and Loner mirroring from enabled interface(s)${NC}"
            disableMirroringInLoners
            disableMirroringInAsikRrc $asik_rrc_abil1_slave_xeon_port
        fi
    fi
}


################################## COMMON ##################################

readOptionsFromConfigFile() {
    directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    source $directory/gnbMirroringConfig.sh
    if [ $? -eq 0 ]; then 
        echo -e "\n${YELLOW}Read options from gnbMirroringConfig.sh${NC}"
    else 
        echo -e "\n${RED}Config file (gnbMirroringConfig.sh) not found${NC}"
        exit
    fi
}

printHelp() {
    echo "Usage: ./gnbMirroring.sh [OPTION]"
    echo "Capture traffic in gNB internal interfaces"
    echo "Example: ./gnbMirroring.sh --use_gulp='true' --capturing_time_seconds='infinite' --number_of_files=5 --file_size_mbytes=10"
    echo -e "\nGeneral options:"
    echo "  -h|--help   print help"
    echo "  --mirroring_mode=['local'|'remote']"
    echo -e "\nMirrored interfaces:"
    echo "  --syscom_mirroring=['false'|'true']"
    echo "  --mirror_abil_1=['true'|'false']"
    echo "  --mirror_abil_2=['true'|'false']"
    echo "  --mirror_abil_3=['true'|'false']" 
    echo "  --carrier_aggregation=['false'|'true']"
    echo "  --backhaul_mirroring=['false'|'true']"
    echo "  --f1u_mirroring=['false'|'true']"
    echo -e "\nlocal mode options:"
    echo "  --filtering=['off'|'on']"
    echo "  --use_gulp=['false'|'true']"
    echo "  --capturing_time_seconds=[<seconds>|'infinite']"
    echo "  --number_of_files=<number_of_files>"
    echo "  --file_size_mbytes=<file_size_in_mbytes>"
}

parseCommandLineOptions() {
    echo -e "${YELLOW}Parse command line options${NC}"
    for i in "$@"
    do
    case $i in
        -h|--help)
            printHelp
            exit
        ;;
        --mirroring_mode=*)
            MIRRORING_MODE="${i#*=}"
            shift
        ;;
        --syscom_mirroring=*)
            SYSCOM_MIRRORING="${i#*=}"
            shift
        ;;
        --mirror_abil_1=*)
            MIRROR_ABIL_1="${i#*=}"
            shift
        ;;
        --mirror_abil_2=*)
            MIRROR_ABIL_2="${i#*=}"
            shift
        ;;
        --mirror_abil_3=*)
            MIRROR_ABIL_3="${i#*=}"
            shift
        ;;
        --carrier_aggregation=*)
            CARRIER_AGGREGATION="${i#*=}"
            shift
        ;;
        --backhaul_mirroring=*)
            BACKHAUL_MIRRORING="${i#*=}"
            shift
        ;;
        --f1u_mirroring=*)
            F1U_MIRRORING="${i#*=}"
            shift
        ;;
        --filtering=*)
            FILTERING="${i#*=}"
            shift
        ;;
        --use_gulp=*)
            USE_GULP="${i#*=}"
            shift
        ;;
        --capturing_time_seconds=*)
            CAPTURING_TIME_SECONDS="${i#*=}"
            shift
        ;;
        --number_of_files=*)
            NUMBER_OF_FILES="${i#*=}"
            shift
        ;;
        --file_size_mbytes=*)
            FILE_SIZE_MBYTES="${i#*=}"
            shift
        ;;
        *)
            #echo -e "\n${UELLOW}No options given in command line${NC}"
        ;;
    esac
    done
}

printOptions() {
    echo "Options used"
    echo "MIRRORING_MODE=$MIRRORING_MODE"
    echo "SYSCOM_MIRRORING=$SYSCOM_MIRRORING"
    echo "MIRROR_ABIL_1=$MIRROR_ABIL_1"
    echo "MIRROR_ABIL_2=$MIRROR_ABIL_2"
    echo "MIRROR_ABIL_3=$MIRROR_ABIL_3"
    echo "CARRIER_AGGREGATION=$CARRIER_AGGREGATION"
    echo "BACKHAUL_MIRRORING=$BACKHAUL_MIRRORING"
    echo "F1U_MIRRORING=$F1U_MIRRORING"
    echo "FILTERING=$FILTERING"
    echo "USE_GULP=$USE_GULP"
    echo "CAPTURING_TIME_SECONDS=$CAPTURING_TIME_SECONDS"
    echo "NUMBER_OF_FILES=$NUMBER_OF_FILES"
    echo "FILE_SIZE_MBYTES=$FILE_SIZE_MBYTES"
}

checkOptions() {
    #if [ $MIRRORING_MODE = 'local' ] && [ $MIRROR_ABIL_1 == 'false' ]; then
    #    echo -e "\n${RED}Local mirroring does not work without the first ABIL${NC}"
    #    exit
    #fi
    if [ $CARRIER_AGGREGATION = 'true' ] && [ $MIRROR_ABIL_2 == 'true' ]; then
        echo -e "\n${RED}Do not enable ABIL2 with CA ${NC}"
        exit
    fi
    if [ $CARRIER_AGGREGATION = 'true' ] && [ $MIRROR_ABIL_3 == 'true' ]; then
        echo -e "\n${RED}Do not enable ABIL3 with CA ${NC}"
        exit
    fi
}

readSwReleseFromTargetBD() {
    targetBdFile=`find /ffs/run/ -name TargetBD*.xml`
    swReleaseLine=`grep swReleaseVersionPackageName $targetBdFile`
    swReleaseString=${swReleaseLine#*swReleaseVersionPackageName}
    swReleaseString=${swReleaseString#*\"}
    swReleaseString=${swReleaseString%%\"*}
    echo -e "\n${YELLOW}swReleaseVersionPackageName $swReleaseString${NC}"
}

detectHwAndStartMirroring() {
    if [[ $swReleaseString == *"ASIB"* ]]; then 
        echo -e "\n${YELLOW}Enable mirroring in ASIB/ABIL${NC}"
        startMirroringInAsib
    elif [[ $swReleaseString == *"ASOD"* ]]; then 
        echo -e "\n${RED}ASOD testing${NC}"
        startMirroringInAsod
    elif [[ $swReleaseString == *"ASIL"* ]]; then 
        echo -e "\n${YELLOW}Enable mirroring in ASIL/ABIL${NC}"
        startMirroringInAsil
    else
        echo -e "\n${YELLOW}Enable mirroring in ASIK/ABIL${NC}"
        startMirroringInAsik
    fi
}

echo -e "\n${YELLOW}gnbMirroring.sh V26${NC}"

readOptionsFromConfigFile
parseCommandLineOptions "$@"
printOptions
checkOptions
readSwReleseFromTargetBD
detectHwAndStartMirroring


