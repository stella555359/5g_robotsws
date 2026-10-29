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
#   9.6.2020   V27: - Added backhaul and F1-u mirorring for ASIB
#                   - Force Loner to read multicast_ctrl register https://jira3.int.net.nokia.com/browse/BIPIP-384
#
#   26.6.2020  V28: - Added a new local dumping method "local_in_l2rt_core" for L2-L1 BIP capturing
#                   - Added memory amount check for local mode
#                   - Moved local dump from ABIL to ASIK from 5G20A onwards
#                   - Fixed Loner mirroring disabling for multi ABIL
#                   - Added debug option XTRACE
#
#   29.6.2020  V29: - Added FILTER as configurable parameter for local dump
#
#   6.8.2020   V30: - Reverted "Moved local dump from ABIL to ASIK from 5G20A onwards"
#                   - Separated options to choose BB boards and interfaces
#
#   14.10.2020 V31: - Removed https://jira3.int.net.nokia.com/browse/BIPIP-384 WA for 5G20B
#                   - Fixed "ASIB detection based on TargetBD does not work anymore AirScale-9.1800.1115"
#
#   14.10.2020 V32: - Moved tcpdump to ASIK 5G20A onwards
#
#   26.11.2020 V33: - ASIB: Moved tcpdump from ABIL to ASIB
#                   - Added local mode support for ASOD
#
#   11.12.2020 V34: - Fixed ASOD tcpdump copy condition
#                   - ASIL local dump preparations
#                   - ABIO preparations
#                   - Removed https://jira3.int.net.nokia.com/browse/BIPIP-384 WA for 5G21B
#                   - Fixed missing jumbo frames by forcing dump interface MTU size 8024 -> 9194
#
#   11.12.2020 V35: - ASIB: Reverted tcpdump back to ABIL
#
#   18.12.2020 V36: - Added note about pressing Ctrl-c only once to stop tcpdump
#                   - Removed forced broadcast register read for other HW than ASIK
#                   - ASIB: Moved tcpdump from ABIL to ASIB (SBTS will work as well)
#
#   28.12.2020 V37: - Changed MTU size comparison from '<' to '-lt'
#                   - Preparations for ASIB+ABIO
#
#   07.01.2020 V38: - Fixed 'ERROR: Found no register whose name is BIPregs_BIP_Stream_blk.rf0[31].BIP_EG_PROTOCOL'
#
#   08.01.2020 V39: - Changed ASIK mirroring interface to pepbp1
#                   - Cleaned up loggin
#                   - Restore initial eth SS state after mirroring
#                   - Fixed bug in local_in_l2rt_core mode
#
#
# BUG REPORTS:
#   Provide console log and capture to juha.kangas@nokia.com
#
###############################################################################

VERSION_STRING='V39'
GNB_MIRRORING_LOG_FILE='gnbMirroring.log'

YELLOW='\e[33m'
RED='\e[31m'
GREEN='\e[32m'
NC='\e[0m'

MBYTES_TO_KBYTES=1024
# In ASIB 9216
MTU_SIZE=9194

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

enable='e'
disable='d'

asib_bip_vlan=218

# ASIK/ASIB/ABIL Nodes
asik_master_xeon_node='0'
asik_slave_xeon_node='1'
asib_axm_node='0'
asil_axm_node='0'
abil1_master_xeon_node='1:0'
abil1_slave_xeon_node='1:1'
abil1_loner_node='1:2'
abil2_loner_node='2:2'
abil3_loner_node='3:2'

abil_xeon_loner_interface='ethloner0'
abil_xeon_rrc_interface='ethbp1'
asik_xeon_rrc_interface='etha01'
asik_xeon_rrc_bip_interface='pepbp1'

# ASIK RRC
asik_rrc_asik_master_xeon_port=2
asik_rrc_asik_slave_xeon_port=3
asik_rrc_asik_master_xeon_bip_port=4
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
asil_nac_monterey_interface='eth1'

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
asod_xeon_a_node='0'
asod_xeon_b_node='1'
asod_xeon_a_bip_interface='pepbp1'
#asod_aldrin_sei_port=0
#asod_aldrin_eif1_port=1
asod_aldrin_eif2_port=1
asod_aldrin_lodin_arb0p2_port=4
asod_aldrin_lodin_arb0p1_port=5
asod_aldrin_lodin_arb0p0_port=6
asod_aldrin_ethlmp0_port=7
asod_aldrin_xeon_b_10ge_0_port=8
asod_aldrin_xeon_b_10ge_1_port=9
asod_aldrin_xeon_a_10ge_0_port=10
asod_aldrin_xeon_a_10ge_1_port=11



################################## COMMON ##################################

setFilter() {
    if [ $FILTERING = 'off' ]; then
        filtered_messages=""
    else
        filtered_messages=$FILTER
    fi
    echo -e "${NC}Filter: $filtered_messages${NC}"
}

evaluateTimeout() {
    if [[ $CAPTURING_TIME_SECONDS = 'infinite' ]] || [[ $CAPTURING_TIME_SECONDS = 0 ]]; then
        timeoutCommand=""
    else
        timeoutCommand="timeout -s 2 --foreground $CAPTURING_TIME_SECONDS"
    fi
}

copyDumpFiles() {
    echo -e "\n${YELLOW}Capturing stopped, copy dump files if needed${NC}"
    if [[ $1 != $asik_master_xeon_node ]] && [[ $1 != $asib_axm_node ]] && [[ $1 != $asod_xeon_a_node ]]; then
        files=`bsh $1 "ls /tmp/tcpdumpL2L1*"`
        for file in $files
        do
            bget $1 $file /tmp/
        done
        bsh $1 "rm /tmp/tcpdumpL2L1*"
    fi
    echo -e "\n${YELLOW}Dump files in /tmp/ folder${NC}"
    ls -la /tmp/tcpdumpL2L1*
}

runTcpdump() {
    setFilter
    echo -e "${NC}tcpdump $CAPTURING_TIME_SECONDS seconds. Can be stopped with Ctrl-c. Output is saved to /tmp/tcpdumpL2L1_filtering_$FILTERING.pcap${NC}"
    echo -e "${RED}NOTE!!! Ctrl-c must be pressed only once${NC}"
    evaluateTimeout
    $timeoutCommand bsh $1 "tcpdump -i $2 -C $FILE_SIZE_MBYTES -W $NUMBER_OF_FILES -w /tmp/tcpdumpL2L1_filtering_$FILTERING.pcap '$filtered_messages'"
    bsh $1 "pkill -2 tcpdump"
    copyDumpFiles $1
}

copyAndRunGulp() {
    echo -e "${NC}Copy gulp${NC}"
    bput $1 $directory/gulp /usr/sbin/
    bsh $1 "chmod +x /usr/sbin/gulp"
    bsh $1 "ln -s /usr/lib64/libpcap.so.1 /usr/lib64/libpcap.so.0.8" 2> /dev/null
    setFilter
    evaluateTimeout
    echo -e "${NC}gulp $CAPTURING_TIME_SECONDS seconds. Can be stopped with Ctrl-c. Output is saved to /tmp/tcpdumpL2L1_gulp_filtering_$FILTERING.pcap000${NC}"
    echo -e "${RED}NOTE!!! Ctrl-c must be pressed only once${NC}"
    $timeoutCommand bsh $1 "gulp -i $2 -r $FILE_SIZE_MBYTES -C 1 -W $NUMBER_OF_FILES -o /tmp/ -n tcpdumpL2L1_gulp_filtering_$FILTERING.pcap -f '$filtered_messages'"
    bsh $1 "pkill -2 gulp"
    copyDumpFiles $1
}

checkMemory() {
    memoryRequired=`expr $NUMBER_OF_FILES \* $FILE_SIZE_MBYTES \* $MBYTES_TO_KBYTES`
    #if [ $( bsh $1 "df --output=avail /tmp | tail -n 1" ) -lt $memoryRequired ]; then
    memoryAvailable=$( bsh $1 "df --output=avail /tmp | tail -n 1" )
    echo -e "${NC}Memory check, memoryRequired: $memoryRequired kB memoryAvailable $memoryAvailable kB${NC}"
    if [ $( bsh $1 "df --output=avail /tmp | tail -n 1" ) -lt $memoryRequired ]; then
        echo -e "\n${RED}Not enough memory, decrease NUMBER_OF_FILES or FILE_SIZE_MBYTES${NC}"
        exit
    fi
}

removeOldDumpFiles() {
    rm /tmp/tcpdumpL2L1* 2> /dev/null
}

setMtuSize() {
    mtuLine=`bsh $1 "ifconfig $2 | grep mtu"`
    MTU_SIZE_ORIGINAL=${mtuLine#*mtu }
    echo -e "${NC}Node bsh $1 interface $2 MTU size is $MTU_SIZE_ORIGINAL, required $MTU_SIZE${NC}"
    if [ "$MTU_SIZE_ORIGINAL" -lt "$MTU_SIZE" ]; then
        echo -e "${YELLOW}Change bsh $1 interface $2 MTU size to $MTU_SIZE, original MTU size $MTU_SIZE_ORIGINAL${NC}"
        bsh $1 "ifconfig $2 mtu $MTU_SIZE up"
    fi
}

resetMtuSize() {
    if [ "$MTU_SIZE_ORIGINAL" -lt "$MTU_SIZE" ]; then
        echo -e "${YELLOW}Revert bsh $1 interface $2 MTU size to $MTU_SIZE_ORIGINAL${NC}"
        bsh $1 "ifconfig $2 mtu $MTU_SIZE_ORIGINAL up"
    fi
}

captureData() {
    echo -e "\n${YELLOW}Capture data in node $1, interface $2 ${NC}"
    removeOldDumpFiles
    checkMemory $1
    setMtuSize $1 $2
    if [ $USE_GULP = 'true' ]; then
        copyAndRunGulp $1 $2
    else
        runTcpdump $1 $2
    fi
    resetMtuSize $1 $2
}

captureDataInL2rtCore() {
    bsh $1 "echo "write 0x0000F600 0x702" > /sys/kernel/debug/ixgbe/0000:04:00.1/reg_ops"
    bsh $1 "echo "write 0x0000F604 0x704" > /sys/kernel/debug/ixgbe/0000:04:00.1/reg_ops"
    captureData $1 $abil_xeon_loner_interface
    #tcpdump -nei ethloner0 -B 2000  -C 100 -W 14  -w /tmp/bipcapture.cap
}

################################## ABIO ##################################
enableMirroringInLoki() {
    echo -e "\n${YELLOW}Enabling mirroring in Loki $1${NC}"
    /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -f L1_L2_UL -v 304
    /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -f L1_L2_DL -v 304
}

enableMirroringInAbio() {
    echo -e "\n${YELLOW}Enabling mirroring in ABIO${NC}"
    lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b "C1B2(1)" -s 5 -l eths2 -v 304
    lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL -b "C1B2(1)" -s 5 -l eths2 -v 305
}

################################## ABIL ##################################

enableMirroringInLoner() {
    echo -e "\n${YELLOW}Enabling mirroring in Loner $1${NC}"
    bsh $1 "echo fffffff 2 > /sys/class/bip/bip0/device/multicast_ctrl"
    if [[ $controlCardHwType == "ASIK" ]]; then
        if [ "$swBranch" == "5G19B" ] || [ "$swBranch" == "5G20A" ]; then bsh $1 "lr BIPregs_BIP_Stream_blk.rf0[31].BIP_EG_PROTOCOL=0x60100000"; fi
    fi

    monitored_ports_mask_initial=$( bsh $1 "cat /sys/class/xlgx/xlgx0/device/monitored_ports_mask" )
    monitoring_port_flag_initial=$( bsh $1 "cat /sys/class/xlgx/xlgx0/device/monitoring_port_flag" )
    echo -e "${NC}monitored_ports_mask_initial $monitored_ports_mask_initial${NC}"
    echo -e "${NC}monitoring_port_flag_initial $monitoring_port_flag_initial${NC}"

    if [[ "$swBranch" == "5G19_" ]]; then
        monitored_ports_mask_addition="0x1"
        monitoring_port_flag_addition="0x2"
        echo -e "${NC}Enable Loner mirroring from arb0p0 to arb0p1${NC}"
    elif [[ $controlCardHwType == "ASIB" ]] || [[ $controlCardHwType == "ASIL" ]]; then
        monitored_ports_mask_addition="0x2"
        monitoring_port_flag_addition="0x1"
        echo -e "${NC}Enable Loner mirroring from arb0p1 to arb0p0${NC}"
        bsh $1 "ethtool -s arb0p0 phyad 1"
    else
        monitored_ports_mask_addition="0x3"
        monitoring_port_flag_addition="0x4"
        echo -e "${NC}Enable Loner mirroring from arb0p0 and arb0p1 to arb0p2${NC}"
    fi
    monitored_ports_mask_combined_dec=$(( $monitored_ports_mask_initial | $monitored_ports_mask_addition ))
    monitoring_port_flag_combined_dec=$(( $monitoring_port_flag_initial | $monitoring_port_flag_addition ))
    monitored_ports_mask_combined_hex=`printf '0x%x\n' $monitored_ports_mask_combined_dec`
    monitoring_port_flag_combined_hex=`printf '0x%x\n' $monitoring_port_flag_combined_dec`
    echo -e "${NC}monitored_ports_mask_combined_hex $monitored_ports_mask_combined_hex${NC}"
    echo -e "${NC}monitoring_port_flag_combined_hex $monitoring_port_flag_combined_hex${NC}"
    bsh $1 "echo $monitored_ports_mask_combined_hex > /sys/class/xlgx/xlgx0/device/monitored_ports_mask && echo $monitoring_port_flag_combined_hex > /sys/class/xlgx/xlgx0/device/monitoring_port_flag"

}

enableMirroringInLoners() {
    if [ $MIRROR_ABIL_1 = 'true' ]; then enableMirroringInLoner "$abil1_loner_node"; fi
    if [ $MIRROR_ABIL_2 = 'true' ]; then enableMirroringInLoner "$abil2_loner_node"; fi
    if [ $MIRROR_ABIL_3 = 'true' ]; then enableMirroringInLoner "$abil3_loner_node"; fi
}

disableMirroringInLoner() {
    echo -e "${YELLOW}Disable mirroring in Loner $1${NC}"
    bsh $1 "echo 0 2 > /sys/class/bip/bip0/device/multicast_ctrl"
    if [[ $controlCardHwType == "ASIK" ]]; then
        if [[ "$swBranch" == "5G19B" ]] || [[ "$swBranch" == "5G20A" ]]; then bsh $1 "lr BIPregs_BIP_Stream_blk.rf0[31].BIP_EG_PROTOCOL=0x60100000"; fi
    fi
    bsh $1 "echo $monitored_ports_mask_initial > /sys/class/xlgx/xlgx0/device/monitored_ports_mask && echo $monitoring_port_flag_initial > /sys/class/xlgx/xlgx0/device/monitoring_port_flag"
}

disableMirroringInLoners() {
    if [ $MIRROR_ABIL_1 = 'true' ]; then disableMirroringInLoner "$abil1_loner_node"; fi
    if [ $MIRROR_ABIL_2 = 'true' ]; then disableMirroringInLoner "$abil2_loner_node"; fi
    if [ $MIRROR_ABIL_3 = 'true' ]; then disableMirroringInLoner "$abil3_loner_node"; fi
}



################################## ASOD ##################################


enableMirroringInAsodAldrin() {
    echo $1 both > /var/run/cpss/ports/$asod_aldrin_lodin_arb0p0_port/mirroring_port
    cat /var/run/cpss/ports/mirror_info
}

disableMirroringInAsodAldrin() {
    echo both > /var/run/cpss/ports/$asod_aldrin_lodin_arb0p0_port/disable_mirroring
}

startMirroringInAsod() {
    if [ $MIRRORING_MODE = 'remote' ]; then
        echo -e "${YELLOW}Enable remote mirroring in ASOD${NC}"
        #luaCLI -c "cpss-api call cpssDxChMirrRxAnalyzerDpTcSet devNum 0 analyzerDp CPSS_DP_GREEN_E analyzerTc 7"
        #luaCLI -c "cpss-api call cpssDxChMirrTxAnalyzerDpTcSet devNum 0 analyzerDp CPSS_DP_GREEN_E analyzerTc 7"
        #luaCLI -c "cpss-api call cpssDxChMirrorToAnalyzerForwardingModeSet devNum 0 mode CPSS_DXCH_MIRROR_TO_ANALYZER_FORWARDING_SOURCE_BASED_OVERRIDE_E"
        disableMirroringInAsodAldrin
        echo 1 > /var/run/cpss/ports/$asod_aldrin_eif2_port/enable
        enableMirroringInAsodAldrin $asod_aldrin_eif2_port

        ddal -s ddal_sfp_ctrl_set 1 0 0

    else
        disableMirroringInAsodAldrin
        enableMirroringInAsodAldrin $asod_aldrin_xeon_a_10ge_1_port
        if [ $MIRRORING_MODE = 'local' ]; then
            captureData $captureNode $captureInterface
            echo -e "\n${YELLOW}Disable mirroring from Aldrin(s)${NC}"
            disableMirroringInAsodAldrin
        fi
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
    if [ $BB_BOARD_TYPE = 'ABIO' ]; then
        enableMirroringInLoki
    else
        enableMirroringInLoners
    fi
    if [ $MIRRORING_MODE = 'remote' ]; then
        enableMirroringInAsilMonterey $asil_monterey_nac_port
        enableMirroringInAsilNac
    else
        enableMirroringInAsilMonterey $capturePort
        runTcpdump $captureNode $captureInterface

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
        if [ $CARRIER_AGGREGATION = 'true' ]; then
            echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil1_loner_port/$file_to_write
        else
            echo $dest_port ingress > /var/run/cpss/ports/$asib_marvell_abil1_loner_port/$file_to_write
        fi
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil1_eth_switch_port/$file_to_write
        fi
    fi
    if [ $MIRROR_ABIL_2 = 'true' ]; then
        echo $dest_port ingress > /var/run/cpss/ports/$asib_marvell_abil2_loner_port/$file_to_write
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil2_eth_switch_port/$file_to_write
        fi
    fi
    if [ $MIRROR_ABIL_3 = 'true' ]; then
        echo $dest_port ingress > /var/run/cpss/ports/$asib_marvell_abil3_loner_port/$file_to_write
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil3_eth_switch_port/$file_to_write
        fi
    fi
    if [ $L2HI_L2LO_MIRRORING = 'true' ]; then
        echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil1_slave_xeon_port/$file_to_write
    fi
    if [ $BACKHAUL_MIRRORING = 'true' ]; then
        echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil1_master_xeon_port/$file_to_write
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

enableNcpMarvellInterface() {
    ifconfig $asib_ncp_marvell_interface up
    ncp_l2 -p $asib_ncp_marvell_port -I -s defaultVlanId.100
    ncp_l2 -i -p $asib_ncp_marvell_port -v $asib_bip_vlan -a
    ncp_portmirror -p $asib_ncp_marvell_port -d netdriver
    ##nice -n -19 tcpdump -i eths2 -xx -w trace.pcap
    echo 1 > /var/run/cpss/ports/$asib_marvell_ncp_port/enable
}

enableMirroringInAsibNcp() {
    enableNcpMarvellInterface
    ifconfig $asib_ncp_sei_interface up
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
    if [ $BB_BOARD_TYPE = 'ABIO' ]; then
        enableMirroringInAbio
    else
        enableMirroringInLoners
    fi
    if [ $MIRRORING_MODE = 'remote' ]; then
        enableMirroringInAsibMarvell $asib_marvell_ncp_port
        enableMirroringInAsibNcp
    else
        disableAsibMarvellRemoteMirroring
        enableNcpMarvellInterface
        enableMirroringInAsibMarvell $capturePort

        if [ $MIRRORING_MODE = 'local' ]; then
            captureData $captureNode $captureInterface

            echo -e "\n${YELLOW}Disable mirroring${NC}"
            if [ $BB_BOARD_TYPE = 'ABIO' ]; then
                echo -e "${RED}Disabling mirroring is not supported in ABIO${NC}"
            else
                disableMirroringInLoners
            fi

            disableMirroringInAsibMarvell $capturePort
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
        if [ $L2_L1_BIP = 'true' ]; then
            if [ $CARRIER_AGGREGATION = 'true' ]; then
                dbgrrc mirror sport $asik_rrc_abil1_loner_port1 dport $1 $2 both
                echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil1_loner_port1 dport $1 $2 both${NC}"
            else
                dbgrrc mirror sport $asik_rrc_abil1_loner_port1 dport $1 $2 ingress
                echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil1_loner_port1 dport $1 $2 ingress${NC}"
            fi
        fi
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            dbgrrc mirror sport $asik_rrc_abil1_eth_switch_port dport $1 $2 both
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil1_eth_switch_port dport $1 $2 both${NC}"
        fi
        if [ $L2HI_L2LO_MIRRORING = 'true' ]; then
            dbgrrc mirror sport $asik_rrc_abil1_master_xeon_port dport $1 $2 both
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil1_master_xeon_port dport $1 $2 both${NC}"
        fi
    fi
    if [ $MIRROR_ABIL_2 = 'true' ]; then
        if [ $L2_L1_BIP = 'true' ]; then
            dbgrrc mirror sport $asik_rrc_abil2_loner_port1 dport $1 $2 ingress
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil2_loner_port1 dport $1 $2 ingress${NC}"
        fi
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            dbgrrc mirror sport $asik_rrc_abil2_eth_switch_port dport $1 $2 both
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil2_eth_switch_port dport $1 $2 both${NC}"
        fi
        if [ $L2HI_L2LO_MIRRORING = 'true' ]; then
            dbgrrc mirror sport $asik_rrc_abil2_master_xeon_port dport $1 $2 both
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil2_master_xeon_port dport $1 $2 both${NC}"
        fi
    fi
    if [ $MIRROR_ABIL_3 = 'true' ]; then
        if [ $L2_L1_BIP = 'true' ]; then
            dbgrrc mirror sport $asik_rrc_abil3_loner_port1 dport $1 $2 ingress
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil3_loner_port1 dport $1 $2 ingress${NC}"
        fi
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            dbgrrc mirror sport $asik_rrc_abil3_eth_switch_port dport $1 $2 both
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil3_eth_switch_port dport $1 $2 both${NC}"
        fi
        if [ $L2HI_L2LO_MIRRORING = 'true' ]; then
            dbgrrc mirror sport $asik_rrc_abil3_master_xeon_port dport $1 $2 both
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil3_master_xeon_port dport $1 $2 both${NC}"
        fi
    fi
    if [ $BACKHAUL_MIRRORING = 'true' ]; then
        dbgrrc mirror sport $asik_rrc_eif1_port dport $1 $2 both
        echo -e "${NC}dbgrrc mirror sport $asik_rrc_eif1_port dport $1 $2 both${NC}"
    fi
}

enableMirroringInAsikRrc() {
    echo -e "\n${YELLOW}Enable mirroring in ASIK RRC${NC}"
    if [ $CARRIER_AGGREGATION = 'true' ]; then
        disableMacLearningAndConfigureStaticMacAddressesToRrc
    fi
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
    dbgrrc mirror sport $asik_rrc_abil2_master_xeon_port dport $asik_rrc_eif2_port disable both 1> /dev/null
    dbgrrc mirror sport $asik_rrc_abil3_master_xeon_port dport $asik_rrc_eif2_port disable both 1> /dev/null
    dbgrrc mirror sport $asik_rrc_eif1_port dport $asik_rrc_eif2_port disable both 1> /dev/null
}

enableEif2PortInAsikRrc() {
    dbgrrc enable port $asik_rrc_eif2_port
    dbgrrc set port $asik_rrc_eif2_port speed 10000
}

startMirroringInAsik() {
    if [ $MIRRORING_MODE = 'remote' ]; then
        enableMirroringInLoners
        enableMirroringInAsikRrc $asik_rrc_eif2_port
        enableEif2PortInAsikRrc
    elif [ $MIRRORING_MODE = 'local_in_l2rt_core' ]; then
        captureDataInL2rtCore $l2rtNode
    else
        disableAsikRrcRemoteMirroring
        enableMirroringInLoners
        enableMirroringInAsikRrc $capturePort

        if [ $MIRRORING_MODE = 'local' ]; then
            captureData $captureNode $captureInterface

            echo -e "\n${YELLOW}Disable RRC and Loner mirroring from enabled interface(s)${NC}"
            disableMirroringInLoners
            disableMirroringInAsikRrc $capturePort
        fi
    fi
}


################################## COMMON ##################################

readOptionsFromConfigFile() {
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
    echo "  --mirroring_mode=['local'|'remote'|'manual'|'local_in_l2rt_core']"
    echo "  --bb_board_type=['ABIL'|'ABIO']"
    echo -e "\nMirrored BB boards:"
    echo "  --mirror_abil_1=['true'|'false']"
    echo "  --mirror_abil_2=['true'|'false']"
    echo "  --mirror_abil_3=['true'|'false']"
    echo -e "\nMirrored interfaces:"
    echo "  --l2_l1_bip=['true'|'false']"
    echo "  --syscom_mirroring=['true'|'false']"
    echo "  --carrier_aggregation=['true'|'false']"
    echo "  --backhaul_mirroring=['true'|'false']"
    echo "  --l2hi_l2lo_mirroring=['true'|'false']"
    echo -e "\nlocal mode options:"
    echo "  --filtering=['on'|'off']"
    echo "  --filter=[ether[0x18:2]!=<msg_id_1> && ether[0x18:2]!=<msg_id_2>]"
    echo "  --use_gulp=['true'|'false']"
    echo "  --capturing_time_seconds=[<seconds>|'infinite']"
    echo "  --number_of_files=<number_of_files>"
    echo "  --file_size_mbytes=<file_size_in_mbytes>"
    echo -e "\ndebug options:"
    echo "  --xtrace=['on'|'off']"
}

parseCommandLineOptions() {
    echo -e "\n${YELLOW}Parse command line options${NC}"
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
        --bb_board_type=*)
            BB_BOARD_TYPE="${i#*=}"
            shift
        ;;
        --l2_11_bip=*)
            L2_L1_BIP="${i#*=}"
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
        --l2hi_l2lo_mirroring=*)
            L2HI_L2LO_MIRRORING="${i#*=}"
            shift
        ;;
        --filtering=*)
            FILTERING="${i#*=}"
            shift
        ;;
        --filter=*)
            FILTER="${i#*=}"
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
        --xtrace=*)
            XTRACE="${i#*=}"
            shift
        ;;
        *)
            #echo -e "\n${UELLOW}No options given in command line${NC}"
        ;;
    esac
    done
}

printOptions() {
    echo -e "General options"
    echo -e "  MIRRORING_MODE=$MIRRORING_MODE"
    echo -e "Mirrored BB boards"
    echo -e "  BB_BOARD_TYPE=$BB_BOARD_TYPE"
    echo -e "  MIRROR_ABIL_1=$MIRROR_ABIL_1"
    echo -e "  MIRROR_ABIL_2=$MIRROR_ABIL_2"
    echo -e "  MIRROR_ABIL_3=$MIRROR_ABIL_3"
    echo -e "Mirrored interfaces"
    echo -e "  L2_L1_BIP=$L2_L1_BIP"
    echo -e "  SYSCOM_MIRRORING=$SYSCOM_MIRRORING"
    echo -e "  CARRIER_AGGREGATION=$CARRIER_AGGREGATION"
    echo -e "  BACKHAUL_MIRRORING=$BACKHAUL_MIRRORING"
    echo -e "  L2HI_L2LO_MIRRORING=$L2HI_L2LO_MIRRORING"
    echo -e "Local mode options"
    echo -e "  FILTERING=$FILTERING"
    echo -e "  FILTER=$FILTER"
    echo -e "  USE_GULP=$USE_GULP"
    echo -e "  CAPTURING_TIME_SECONDS=$CAPTURING_TIME_SECONDS"
    echo -e "  NUMBER_OF_FILES=$NUMBER_OF_FILES"
    echo -e "  FILE_SIZE_MBYTES=$FILE_SIZE_MBYTES"
    echo -e "Debug options"
    echo -e "  XTRACE=$XTRACE"

}

checkOptions() {
    #if [ $MIRRORING_MODE = 'local' ] && [ $MIRROR_ABIL_1 == 'false' ]; then
    #    echo -e "\n${RED}Local mirroring does not work without the first ABIL${NC}"
    #    exit
    #fi
    if [ $CARRIER_AGGREGATION == 'true' ] && [ $MIRROR_ABIL_2 == 'true' ]; then
        echo -e "\n${RED}Do not enable ABIL2 with CA ${NC}"
        exit
    fi
    if [ $CARRIER_AGGREGATION == 'true' ] && [ $MIRROR_ABIL_3 == 'true' ]; then
        echo -e "\n${RED}Do not enable ABIL3 with CA ${NC}"
        exit
    fi
    if [ $MIRRORING_MODE = 'local_in_l2rt_core' ]; then
        if [ $MIRROR_ABIL_2 = 'true' ]; then
            echo -e "\n${RED}Only ABIL1 supported for local_in_l2rt_core mode ${NC}"
            exit
        fi
        if [ $MIRROR_ABIL_3 = 'true' ]; then
            echo -e "\n${RED}Only ABIL1 supported for local_in_l2rt_core mode ${NC}"
            exit
        fi
        if [ $BACKHAUL_MIRRORING = 'true' ]; then
            echo -e "\n${RED}Only ABIL1 supported for local_in_l2rt_core mode ${NC}"
            exit
        fi
        if [ $L2HI_L2LO_MIRRORING = 'true' ]; then
            echo -e "\n${RED}Only ABIL1 supported for local_in_l2rt_core mode ${NC}"
            exit
        fi
    fi
}

checkSwReleaseAndHW() {
    controlCardHwTypeRow=`ddal -s ddal_sysinfo_module_get_unit_id 0 | grep value`
    controlCardHwType=${controlCardHwTypeRow:7:4}

    if [ $controlCardHwType != 'ASOE' ]; then
        targetBdFile=`find /ffs/run/ -name TargetBD*.xml`
        offsetToBranch=${targetBdFile%%"5G"*}
        swBranch=${targetBdFile:${#offsetToBranch}:5}
    fi

    echo -e "\n${YELLOW}Environment: ${NC}"
    echo -e "${NC}SW branch $swBranch ${NC}"
    echo -e "${NC}controlCardHwType $controlCardHwType${NC}"

}

detectHwAndStartMirroring() {
    if [ $controlCardHwType == 'ASIK' ]; then
        if [[ $swBranch = '5G19A' ]] || [[ $swBranch = '5G19B' ]]; then
            l2rtNode=$abil1_master_xeon_node
            captureNode=$abil1_slave_xeon_node
            capturePort=$asik_rrc_abil1_slave_xeon_port
            captureInterface=$abil_xeon_rrc_interface
        else
            l2rtNode=$abil1_slave_xeon_node

            #captureNode=$abil1_master_xeon_node
            #capturePort=$asik_rrc_abil1_master_xeon_port
            #captureInterface=$abil_xeon_rrc_interface

            #captureNode=$asik_master_xeon_node
            #capturePort=$asik_rrc_asik_master_xeon_port
            #captureInterface=$asik_xeon_rrc_interface

            captureNode=$asik_master_xeon_node
            capturePort=$asik_rrc_asik_master_xeon_bip_port
            captureInterface=$asik_xeon_rrc_bip_interface

        fi
    elif [ $controlCardHwType == 'ASOD' ]; then
        l2rtNode=$asod_xeon_b_node
        captureNode=$asod_xeon_a_node
        captureInterface=$asod_xeon_a_bip_interface
        capturePort=$asod_aldrin_xeon_a_10ge_1_port
    elif [ $controlCardHwType == 'ASIL' ]; then
        l2rtNode=$abil1_slave_xeon_node
        captureNode=$asil_axm_node
        capturePort=$asil_monterey_nac_port
        captureInterface=$asil_nac_monterey_interface
    elif [ $controlCardHwType == 'ASIB' ]; then
        l2rtNode=$abil1_slave_xeon_node
        #captureNode=$abil1_master_xeon_node
        #capturePort=$asib_marvell_abil1_master_xeon_port
        #captureInterface=$abil_xeon_rrc_interface
        captureNode=$asib_axm_node
        capturePort=$asib_marvell_ncp_port
        captureInterface=$asib_ncp_marvell_interface
    else
        echo -e "${RED}controlCardHwType not supported $controlCardHwType${NC}"
    fi
    echo -e "\n${YELLOW}Mirroring details:${NC}"
    echo -e "${NC}l2rtNode $l2rtNode, used in local_in_l2rt_core mode${NC}"
    echo -e "${NC}captureNode $captureNode${NC}"
    echo -e "${NC}capturePort $capturePort${NC}"
    echo -e "${NC}captureInterface $captureInterface${NC}"


    if [ $controlCardHwType == 'ASIB' ]; then
        echo -e "${YELLOW}Enable mirroring in ASIB${NC}"
        startMirroringInAsib
    elif [[ $controlCardHwType == 'ASOD' ]] || [[ $controlCardHwType == 'ASOE' ]]; then
        echo -e "${YELLOW}Enable mirroring in ASOD${NC}"
        startMirroringInAsod
    elif [ $controlCardHwType == 'ASIL' ]; then
        echo -e "${YELLOW}Enable mirroring in ASIL/ABIL${NC}"
        startMirroringInAsil
    elif [ $controlCardHwType == 'ASIK' ]; then
        echo -e "\n${YELLOW}Enable mirroring in ASIK/ABIL${NC}"
        startMirroringInAsik
    else
        echo -e "${RED}Unknow controlCardHwType $controlCardHwType${NC}"
    fi
}

directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo -e "\n${YELLOW}gnbMirroring.sh $VERSION_STRING${NC}"
readOptionsFromConfigFile
parseCommandLineOptions "$@"
if [ $XTRACE = 'on' ]; then
    set -x
fi
printOptions
checkOptions
checkSwReleaseAndHW
detectHwAndStartMirroring

#rm $directory/$GNB_MIRRORING_LOG_FILE 1> /dev/null
#set -x
#set -o xtrace
#2>&1 | tee $GNB_MIRRORING_LOG_FILE
#2>&1 | tee -a $GNB_MIRRORING_LOG_FILE
#cat /ram/RTCCSConfig.xml | grep -i l2ps


















