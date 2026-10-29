*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)

Force Tags    CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD    CRT    SBTS00    SBTS22R4    SBTS23R1    RAN_5G    RAN_5G_FDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library    OperatingSystem
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library      ../CB007262/CB007262_A/CB007262_keywords.py


Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_A5.xml
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_scf_CB007813_A5.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_A5.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SMOD}    ASIB
${GNB_IP}    192.168.255.129
${NOKIA_USERNAME}    toor4nsn
${NOKIA_PASS}    oZPS0POrRieRtu

*** Test Cases ***
CB007813_A5_UE_attach_failure_lack_asymmetric_ capability_30MHz_DL_10MHz_UL_with_disabled_CB007552
    Set Internal Traffic Type To UE
    Attach Ue Which Support Asymmetric Bandwidth
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start DL and UL Data Traffic
    Verify Tput For UE     ue_id=1    pdu=1    qfi=1    dir=dl    unit=M    expected_tput=99.5
    Verify Tput For UE     ue_id=1    pdu=1    qfi=1    dir=ul    unit=M    expected_tput=30.5
    Verify If Attach Ue Which Not Support Asymmetric Bandwidth Is Not Possible
    [Teardown]    Stop All Data Transfers And Detach UE


*** Keywords ***
Attach Ue Which Support Asymmetric Bandwidth
    Attach Ue    ue_id=1

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=2 pdu=2 trf_type=internal

Verify If Attach Ue Which Not Support Asymmetric Bandwidth Is Not Possible
   Execute Egate Command   cmd=ue_register id=2
   Sleep    5s
   Execute Egate Command And Wait For Data
    ...    cmd=ue_pdu_session_setup ue=2 pdu=2 nwslice=1 gw=2
    ...    pass_regexp=UE2: Received RRC Release while in FIVE-GS-MM-REGISTERED state

Start DL and UL Data Traffic
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=100
    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=50
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    Sleep    30s

Verify Tput For UE
    [Arguments]   ${ue_id}    ${pdu}    ${qfi}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Sa    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} > ${expected_tput}

Stop All Data Transfers And Detach UE
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

Prepare gNB For Bip Log Collection
    Run On Gnb
    ...    cd /usr/bin;./lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei00 -f L1_L2_UL -b "C1B1(2)" -s 5 -l eths2 -v 303
    Run On Gnb
    ...    cd /usr/bin;./lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei00 -f L1_L2_DL -b "C1B1(2)" -s 5 -l eths2 -v 303
    Run On Gnb    cd /usr/bin;ncp_portmirror -p xgmac97 -r
    Run On Gnb    cd /usr/bin;ncp_portmirror -d netdriver -p xgmac97

Start BIP log collection
    Create Directory    ${OUTPUT_DIR}/CB007813-A
    Prepare gNB For Bip Log Collection
    Setup Biplog Collection
    Start Collection

Setup Biplog Collection
    Run On Gnb    cmd=echo 1 > /var/run/cpss/ports/2/enable
    Run On Gnb    cmd=ip link set eths2 up
    Run On Gnb    cmd=ncp_portmirror -d netdriver -p xgmac97
    Run On Gnb    cmd=echo 2 both > /var/run/cpss/ports/4/mirroring_port
    Run On Gnb    cmd=echo 2 both > /var/run/cpss/ports/5/mirroring_port
    Run On Gnb    cmd=echo 2 both > /var/run/cpss/ports/6/mirroring_port
    Run On Gnb    cmd=ncp_l2 -p XGMAC97 -I -senableSwitching.false
    Run On Gnb    cmd=ncp_l2 -p XGMAC97 -i -sdiscardInvalidVlanidPackets.false
    Run On Gnb    cmd=ncp_l2 -p XGMAC97 -i -sdiscardBadLengthPackets.false
    Run On Gnb    cmd=dbgrrc mirror sport 20 dport 3 e b && dbgrrc mirror sport 21 dport 3 e b
    Run On Gnb    cmd=dbgrrc mirror sport 15 dport 3 e b

Start Collection
    [Arguments]    ${host}=${GNB_IP}    ${user}=${NOKIA_USERNAME}  ${password}=${NOKIA_PASS}
    ssh.Connect To    hostname=${host}    username=${user}    password=${password}    alias=ASIB
    ${filter}=    Get Gnb Bip Filter
    ssh.Send Command    command=nohup tcpdump -i eths2 -w /tmp/tcpdump.pcap -vvv ${filter}    connection=ASIB

Get Gnb Bip Filter
    [Documentation]      Create specific BIP filter
    ...                  Creation Date: 19.01.2021
    ...                  Modified Date:
    ...                  Last Modified by: mateusz.pajor@nokia.com

    ${gnb_bip_filter}=    Catenate
    ...    'ether[0x18:2]!=0xe101 && ether[0x18:2]!=0x122 && ether[0x18:2]!=0x131 && ether[0x18:2]!=0x127
    ...    && ether[0x18:2]!=0xf2ff && ether[0x18:2]!=0xf31b && ether[0x18:2]!=0x240 && ether[0x18:2]!=0xe105
    ...    && ether[0x18:2]!=0xe206'
    [Return]    ${gnb_bip_filter}

Stop BIP log collection
    Stop Biplog Collection And Download Biplog

Stop Biplog Collection And Download Biplog
    [Arguments]    ${remote_bip_path}=/tmp/tcpdump.pcap
    ...            ${local_bip_path}=${OUTPUT_DIR}/${SUITE_NAME}/tcpdump.pcap
    Run On Gnb    cmd=pkill tcpdump
    Run On Gnb    cmd=bsh 0:1 pkill tcpdump
    Run On Gnb    cmd=bget 0:1 /tmp/tcpdump.pcap /tmp
    ssh.download_file    remote_path=${remote_bip_path}    local_path=${local_bip_path}    connection=ASIB
    [Teardown]    Run On Gnb    cmd=rm /tmp/tcpdump.pcap
