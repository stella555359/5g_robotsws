*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LPP_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD   CONFIGS_L2PS_WRO/CB007813/FDD_FDD_CA_SA_PC_20M/CB007813-C_F-F_SA_PC_20M.yaml
...   RAN_5G    RAN_5G_TDD    CRT     SBTS00    SBTS22R4    SBTS23R1

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library    OperatingSystem
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    ta5g_pm_counters
Library    CB007813-B_keywords.py


Suite Setup    Run Keywords   Start Default Logging
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_FDD_2Cells_SA_n66_20M_n66_30_10M.lua
    ...        AND             Start Tshark With Alias

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${TSHARK_ALIAS}=                   tshark_uu_alias_01
${TSHARK_DIR}=                     ${OUTPUT_DIR}/Tshark_logs
@{SWCONFIG_FLAGS}=                 0x340000 = 5
...                                0x4F0214 = 0
${SUM_UE_SCELL_CONF_LARGE_BWP}=    M55167C00003
${SUM_UE_SCELL_CONF_SMALL_BWP}=    M55167C00002
${LOCAL_MOID_PCELL}=               PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${LARGE_BWP_SCELL}=                SEPARATOR=
...                                (nr-rrc.subcarrierSpacing == 0 && nr-rrc.carrierBandwidth ==160)
...                                && nr-rrc.sCellToAddModList && iphy.ue_id==1
${SMALL_BWP_SCELL}=                SEPARATOR=
...                                (nr-rrc.subcarrierSpacing == 0 && nr-rrc.carrierBandwidth ==106)
...                                && nr-rrc.sCellToAddModList && iphy.ue_id==2
${UE_CONTEXT_RELEASE_RLF}=         ((f1ap.procedureCode == 6))  && (f1ap.criticality == 1)
${RRC_SETUP_REQUEST}=              ((nr-rrc.c1 == 0)) && (f1ap.id == 128)
${LARGE_BWP_UE_ID}=                1
${SMALL_BWP_UE_ID}=                2

*** Test Cases ***
CB007813_C_IWK2_FDD_FDD_CA_Scell_selection_with_20MHz_symmetric_Pcell_and_inner_guardband_and_reattach_SA
    Wait For Next Full Pm Interval
    Attach CA UE    ue_id=${LARGE_BWP_UE_ID}    pdu=1    gw_id=1
    Verify BWP SCell Selection    ${LARGE_BWP_SCELL}
    Trigger Radio Link Failure    ue_id=${LARGE_BWP_UE_ID}
    Verify BWP SCell Selection    ${LARGE_BWP_SCELL}
    Start Data Traffic For Large BWP UE
    Verify Tput For Large BWP UE
    Verify Scell Selection PM Counter For Large BWP
    Stop All Data Transfers And Detach UE SA    ue_id=${LARGE_BWP_UE_ID}    pdu=1

    Attach CA UE    ue_id=${SMALL_BWP_UE_ID}    pdu=2    gw_id=2
    Verify BWP SCell Selection    ${SMALL_BWP_SCELL}
    Trigger Radio Link Failure    ue_id=${SMALL_BWP_UE_ID}
    Verify BWP SCell Selection    ${SMALL_BWP_SCELL}
    Start Data Traffic For Small BWP UE
    Verify Tput For Small BWP UE
    Verify Scell Selection PM Counter For Small BWP
    Stop All Data Transfers And Detach UE SA    ue_id=${SMALL_BWP_UE_ID}    pdu=2

*** Keywords ***
Start Tshark With Alias
    Start Tshark
    ...    log_filename=7813_uu.pcapng
    ...    alias=${TSHARK_ALIAS}
    ...    eth_interface=eth4
    ...    capture_filter=''
    ...    log_dirpath=${TSHARK_DIR}

Stop Tshark With Alias
    Stop Tshark    alias=${TSHARK_ALIAS}
    Remove Directory    path=${TSHARK_DIR}    recursive=True

Verify BWP SCell Selection
   [Arguments]    ${packet_filter}
    Stop Capturing    alias=${TSHARK_ALIAS}
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${TSHARK_ALIAS}
    ...    packet_filter=${packet_filter}
    ...    number_of_messages=1
    ...    source_ip='10.0.2.1/24'
    Start Capturing    alias=${TSHARK_ALIAS}    capture_filter=''

Trigger Radio Link Failure
    [Arguments]    ${ue_id}
    Execute Egate Command     cmd=ue_rrc_reestablish id=${ue_id}
    Sleep    5s

Attach CA UE
    [Arguments]    ${ue_id}    ${pdu}    ${gw_id}
    Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Attach Ue    ue_id=${ue_id}
    Establish Pdu Session    ue_id=${ue_id}    pdu_id=${pdu}    gw_id=${gw_id}
    Sleep    3s

Start Data Traffic For Large BWP UE
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175
    ...    pass_regexp=SCellIndex 1 activated successfully
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=50 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=50
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    Sleep    40s

Start Data Traffic For Small BWP UE
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=2 dir=dl mbps=175
    ...    pass_regexp=SCellIndex 1 activated successfully
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=2 dir=ul mbps=50
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:2 UpfId:1 Pdu:2 Qfi:1 TrfId:1
    Sleep    40s

Attach Large BWP Capable UE And Start Data Traffic
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Sleep    3s
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175
    ...    pass_regexp=SCellIndex 1 activated successfully
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=50 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=50
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    Sleep    40s

Attach Small BWP Capable UE And Start Data Traffic
    Execute Egate Command   cmd=set_pdu_param ue=2 pdu=2 trf_type=internal
    Attach Ue    ue_id=2
    Establish Pdu Session    ue_id=2    pdu_id=2    gw_id=2
    Sleep    3s
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=2 dir=dl mbps=175
    ...    pass_regexp=SCellIndex 1 activated successfully
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=2 dir=ul mbps=50
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:2 UpfId:1 Pdu:2 Qfi:1 TrfId:1
    Sleep    40s

Verify Tput For UE SA
    [Arguments]   ${ue_id}    ${dir}    ${cc}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic For Given Cc    ue_id=${ue_id}   cc=${cc}   direction=${dir}    unit=Mbps
    Should Be True    ${avg_tput} > ${expected_tput}

Verify Tput For Large BWP UE
    Verify Tput For UE SA    ue_id=1    dir=dl    cc=0    expected_tput=90
    Verify Tput For UE SA    ue_id=1    dir=dl    cc=1    expected_tput=80
    Verify Tput For UE SA    ue_id=1    dir=ul    cc=0    expected_tput=40

Verify Tput For Small BWP UE
    Verify Tput For UE SA    ue_id=2    dir=dl    cc=0    expected_tput=70
    Verify Tput For UE SA    ue_id=2    dir=dl    cc=1    expected_tput=50
    Verify Tput For UE SA    ue_id=2    dir=ul    cc=0    expected_tput=30

Verify Scell Selection PM Counter For Large BWP
    Wait For Next Full Pm Interval
    ${PM_COUNTERS_FILE}=    Get Latest Unpacked Raw Pm Counters File
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${SUM_UE_SCELL_CONF_LARGE_BWP}
    ...    value=60
    ...    local_moid=${LOCAL_MOID_PCELL}
    ...    filepath=${PM_COUNTERS_FILE}

Verify Scell Selection PM Counter For Small BWP
    Wait For Next Full Pm Interval
    ${PM_COUNTERS_FILE}=    Get Latest Unpacked Raw Pm Counters File
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${SUM_UE_SCELL_CONF_SMALL_BWP}
    ...    value=60
    ...    local_moid=${LOCAL_MOID_PCELL}
    ...    filepath=${PM_COUNTERS_FILE}

Stop All Data Transfers And Detach UE SA
    [Arguments]    ${ue_id}    ${pdu}
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu}
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off

