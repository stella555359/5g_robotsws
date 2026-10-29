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


Suite Setup    Run Keywords    Configure VM interfaces
    ...        AND             Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/inter_iphy.xml
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB007813_Inter_HO_1.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/inter_basic_setup.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SMOD}    ASIB
${GNB_IP}    192.168.255.129
${NOKIA_USERNAME}    toor4nsn
${NOKIA_PASS}    oZPS0POrRieRtu

*** Test Cases ***
CB007813_A1_A4_Inter-gNB_HO_between_cells_with_asymmetric_BW_20MHz_DL_10MHz_UL_and_asymetric_BW_30MHz_DL_10MHz_UL_Single_UE_SA
    Complete Inter GNB Handover History
    Set Internal Traffic Type To UE
    Attach Ue Which Support Asymmetric Bandwidth
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start DL and UL Data Traffic
    Perform INTER HO In Both Ways
   [Teardown]    Stop All Data Transfers And Detach UE SA

CB007813_A1_A4_Inter-gNB_HO_between_cells_with_asymmetric_BW_20MHz_DL_10MHz_UL_and_asymetric_BW_30MHz_DL_10MHz_UL_Single_UE_NSA
    Set interface
    Attach Ue To Enb And Start Gnb Addition    ue_id=11   target_cells=1
    Sleep    10s
    Start Data Traffic for NSA UE
    Verify Tput For UE NSA    ue_id=11    id=2    dir=dl    unit=M    expected_tput=9.5
    Verify Tput For UE NSA    ue_id=11    id=2    dir=ul    unit=M    expected_tput=4.8
    Perform INTER HO In Both Ways NSA
    [Teardown]    Stop All Data Transfers And Detach UE NSA

*** Keywords ***
Set interface
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=3

Stop All Data Transfers And Detach UE NSA
    Execute Egate Command    cmd=trf_data_stop id=2 ue=11
    Sleep    5s
    Execute Egate Command    cmd=ue_detach id=11
    Sleep    10s

Attach Ue To Enb And Start Gnb Addition
    [Arguments]    ${ue_id}    ${target_cells}
    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure
    ...    ue=${ue_id}
    ...    target_cells=${target_cells}
    ...    target_gnb=2
    ...    bearer=2
    ...    dc_type=split_scg
    Sleep    15s


Start Data Traffic for NSA UE
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=dl mbps=10
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=ul mbps=5
    Sleep    20s

Verify Tput For UE NSA
    [Arguments]   ${ue_id}    ${id}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Nsa    ue_id=${ue_id}    id=${id}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} > ${expected_tput}
#Stop Biplog And Validate
#    Log To Console    BIP logs validation
#    bip_logs.Stop Biplog Collection And Download Biplog
#    ...    smod=${SMOD}
#    bip_logs.Verify BipLog Messages
#    ...    messages=${BIP_MESSAGES}
#    ...    bip_logs_dir=${OUTPUT_DIR}/${SUITE_NAME}

Configure VM interfaces
    Start Vm Ethernet Interface    if_name=eth3:xn    ip_with_mask=10.0.1.51/24
    Start Vm Ethernet Interface    if_name=eth3:ng    ip_with_mask=10.0.1.50/24
    Start Vm Ethernet Interface    if_name=eth3:SGNB3_S1U  ip_with_mask=10.0.1.53/24
    Start Vm Ethernet Interface    if_name=eth3:SGNB3_X2   ip_with_mask=10.0.1.54/24


Complete Inter GNB Handover History
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Sleep   5s
    Execute egate command
    ...    cmd=ue_history_information_list id=1 action=reset
    Execute egate command
    ...    cmd=ue_history_information_list_add_ngran id=1 gnb_id=2 cell_type=large nrcgi=311:489|0x01 time_ue_stayed_in_cell=97
    Execute egate command
    ...    cmd=ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=large nrcgi=311:489|0x1 time_ue_stayed_in_cell=98
    Execute egate command
    ...    cmd=ue_history_information_list_add_ngran id=1 gnb_id=2 cell_type=large nrcgi=311:489|0x01 time_ue_stayed_in_cell=99
    Execute egate command  cmd=ue_history_information_list id=1 action=commit
    Execute egate command  cmd=ue_enb_param id=1 ue_history_list=1

Perform INTER HO In Both Ways
    ${meas_id}=  Get Measurement id    EventA3   ue_id=1
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=49 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=PATH_SWITCH_REQUEST_ACK Received
    ...    timeout=20
    ${meas_id}=  Get Measurement id    EventA3   ue_id=1
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    ...    timeout=20

Perform INTER HO In Both Ways NSA
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=11 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=49 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=UE11: Successfully reconfigured dual connectivity
    ...    timeout=20
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=11 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=UE11: === Inter Sgnb Handover is successful ===
    ...    timeout=20

Attach Ue Which Support Asymmetric Bandwidth
    Attach Ue    ue_id=1

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

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

Stop All Data Transfers And Detach UE SA
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off
    Sleep   10s

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
    ...            ${local_bip_path}=${OUTPUT_DIR}/CB007813_tcp/tcpdump.pcap
    Run On Gnb    cmd=pkill tcpdump
    Run On Gnb    cmd=bsh 0:1 pkill tcpdump
    Run On Gnb    cmd=scp -r /tcpdump.pcap ute@192.168.255.126:/tmp
    ssh.download_file    remote_path=${remote_bip_path}    local_path=${local_bip_path}    connection=ASIB
#    [Teardown]    Run On Gnb    cmd=rm /tmp/tcpdump.pcap

Get Measurement id
    [Arguments]  ${event_type}=EventA3  ${ue_id}=1  ${matching_line}=0
    ${measurements}=    Execute Egate Command And Wait For Data    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=${event_type}  timeout=10s
    ${matching_lines}=  Get Lines Containing String  ${measurements}  ${event_type}
    ${first_line}=  Get Line  ${matching_lines}  ${matching_line}
    @{words}=  Split String  ${first_line}
    Log to console  MeasId: ${words}[0] for event: ${words}[2] found for RAT: ${words}[1]
    [Return]  ${words}[0]
