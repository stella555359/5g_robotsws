*** Settings ***
Documentation
...     Test Suite Purpose:
...         Test Suite variables
...
...     AUTHOR (mmW&SC Pz NPS 4 SG):
...         I_MNP_5G_NPS_IVU_SISO_MOBILITY@nokia.com

*** Variables ***
# Test execution flags, range: False, True
${REBOOT_UE}      True
${UE_PWR_RESET}   False
${DEBUG}          False
${NO_ENB}         True

# Ute Vm infos   probably to be suppress
${vm_ip}                             ${tl.test_pc.default_ssh_connection_details.addr}
${vm_user}                           ${tl.test_pc.default_ssh_connection_details.username}
${vm_password}                       ${tl.test_pc.default_ssh_connection_details.password}

# Physical mapping
@{adminState_gnb0_cell1_distName}           NRCELL-1       Unlocked
@{adminState_gnb0_cell2_distName}           NRCELL-2       Unlocked

# Traffic mapping:
# ----------------
${protocol}               udp
${tput_duration}          180s
${tput_DL_bandwith}       10 Mbits/sec
${tput_UL_bandwith}       5 Mbits/sec
${qci_dl}                 0
${qci_ul}                 1
${tput_deviation}         10%
${Packet_Size}            1200
${LOG_PATH}               /home/ute/tput/robotws5g/
#Updated by Youssef Leulmi - 2024.10.03 10:47
#${LOG_PATH}               /tmp/

# About ue:
# ---------
${mdm}                    mdm      # For SDX50
${ue_pdu_addr[0]}         ${custom['ATEN_QCT'][0]['Address IP']}
${ue_pdu_port[0]}         ${custom['ATEN_QCT'][0]['Port Number']}
${filter_file_path}       ${CURDIR}/../filters/filters.txt

