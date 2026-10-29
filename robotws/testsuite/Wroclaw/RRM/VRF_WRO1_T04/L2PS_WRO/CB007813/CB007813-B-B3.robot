*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)

Force Tags    CLOUD_5G_I_MP_AP_KL_SANSA_FS_CPRI_CMWV_FDD    RAN_5G    RAN_5G_FDD    CRT     SBTS00    SBTS22R4    SBTS23R1
...   CDRT

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     ./resources/CB007813_common_keywords.robot
Library      ../resources/Python/webem_alarms.py
Library    OperatingSystem
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    CB007813-B_keywords.py
Library      ../CB007262/CB007262_A/CB007262_keywords.py


Suite Setup    Run Keywords    Add Noise To AP L1
    ...        AND             Configure VM interfaces
    ...        AND             Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_AHFIB_7813_B_HO.xml
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB007813_Intra_HO_B3.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/inter_basic_setup_B3.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SMOD}    ASIB
${GNB_IP}    192.168.255.129
${NOKIA_USERNAME}    toor4nsn
${NOKIA_PASS}    oZPS0POrRieRtu

*** Test Cases ***
CB007813_B3_Intra-gNB_HO_between_cells_with_asymmetric_BW_20MHz_DL_10MHz_UL_and_asymetric_BW_30MHz_DL_10MHz_UL_Single_UE_with_inner_guardband
    Complete Inter GNB Handover History
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start DL and UL Data Traffic
    Perform INTER HO In Both Ways And Verify Tput
   [Teardown]    Stop All Data Transfers And Detach UE SA

*** Keywords ***
Configure VM interfaces
    Start Vm Ethernet Interface    if_name=eth3:xn    ip_with_mask=10.0.1.51/24
    Start Vm Ethernet Interface    if_name=eth3:ng    ip_with_mask=10.0.1.50/24

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

Perform INTER HO In Both Ways And Verify Tput
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=49 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=PATH_SWITCH_REQUEST_ACK Received
    ...    timeout=20
    Sleep   5s
    Verify Tput For UE    ue_id=1    pdu=1   qfi=1    dir=dl    unit=M    expected_tput=9.5
    Verify Tput For UE    ue_id=1    pdu=1   qfi=1    dir=ul    unit=M    expected_tput=4.8
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    ...    timeout=20

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

Start DL and UL Data Traffic
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=10
    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=5
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
