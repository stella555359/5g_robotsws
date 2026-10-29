*** Settings ***
Library     ta5g_pm_counters

Documentation
...    This file contains general keywords used for testing Feature CB008159.

*** Keywords ***
Enable Rd Flag For C5
    Change Rad Param With Aashell    param=0x58076E    value=0

Set Default Rd Flag For C5
    Change Rad Param With Aashell    param=0x58076E    value=800

Start Data Traffic And Increment Insession Time
    [Arguments]    ${ue_id}    ${qfi_id}    ${direction}    ${duration}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=${qfi_id} dir=${direction} period_ms=50 burst=5 mbps=5 seconds=${duration}
    ...    pass_regexp=Started .{2,4}link Internal traffic
    Increment In Session Time    ue_id=${ue_id}    duration=${duration}

Start Data Traffic Extended Period Ms
    [Arguments]    ${ue_id}    ${qfi_id}    ${direction}    ${duration}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=${qfi_id} dir=${direction} period_ms=200 burst=1 kbps=200 seconds=${duration}
    ...    pass_regexp=Started .{2,4}link Internal traffic
    Increment In Session Time By Half   ue_id=${ue_id}    duration=${duration}

Start Data Traffic Above 60mbps
    [Arguments]    ${ue_id}    ${qfi_id}    ${direction}    ${duration}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=${qfi_id} dir=${direction} mbps=60 seconds=${duration}
    ...    pass_regexp=Started .{2,4}link Internal traffic

Start Data Traffic Above 60mbps On The Same Qos At The Same Time
    [Arguments]    ${ue_id}=2    ${qfi_id}=1    ${duration}=20s
    Start Data Traffic Above 60mbps    ue_id=${ue_id}    qfi_id=${qfi_id}    direction=dl    duration=${duration}
    Start Data Traffic Above 60mbps    ue_id=${ue_id}    qfi_id=${qfi_id}    direction=ul    duration=${duration}
    Increment In Session Time    ue_id=${ue_id}    duration=${duration}

Start Data Traffic Above 60mbps On Different Qos At The Same Time
    [Arguments]    ${ue_id}=1    ${qfi_1}=3    ${qfi_2}=4     ${duration}=20s
    Start Data Traffic Above 60mbps    ue_id=${ue_id}    qfi_id=${qfi_1}    direction=dl    duration=${duration}
    Increment In Session Time    ue_id=${ue_id}    duration=${duration}
    Start Data Traffic Above 60mbps    ue_id=${ue_id}    qfi_id=${qfi_2}    direction=ul    duration=${duration}
    Increment In Session Time    ue_id=${ue_id}    duration=${duration}

Start Data Traffic With Bearer Delete
    [Arguments]    ${ue_id}    ${qfi_id}    ${direction}    ${duration}
    Increment In Session Time    ue_id=${ue_id}    duration=${duration}
    Execute Egate Command And Wait For Data    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=${qfi_id} dir=${direction} period_ms=50 burst=5 mbps=5
    ...    pass_regexp=Started .{2,4}link Internal traffic
    Sleep    ${duration}
    Deregister Ue    ue_id=${ue_id}

Start Data Traffic With Ho
    [Arguments]    ${ue_id}    ${qfi_id}    ${direction}    ${duration}    ${time_to_handover}    ${dst_cell}    ${dst_phy_cell_id}
    Start Data Traffic And Increment Insession Time    ${ue_id}    ${qfi_id}    ${direction}    ${duration}
    Sleep    ${time_to_handover}
    Trigger Handover To Second Cell    ${ue_id}    ${dst_cell}    ${dst_phy_cell_id}
    Recalculate In Session Time    ${ue_id}    ${duration}    ${time_to_handover}

Display Uec Statistics
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=2

Check In Session Status
    [Arguments]    ${status}
    Verify Tshark For Single Message    alias=${DEFAULT_S1_MME_ALIAS}
    ...    pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    packet_filter=itf_l2_hi_cu_user_BearerDeleteResp_t.inSession == ${status} && itf_l2_hi_cu_user_BearerDeleteResp_t.drbIdentity == 6

Start Collect Gpt Message
    Start tshark
    ...    log_filename=wireshark_eth3.pcap
    ...    eth_interface=eth3
    ...    alias=GTP_MESSAGE

Stop Collect Gpt Message
    Stop Capturing    alias=GTP_MESSAGE
    Stop tshark    alias=GTP_MESSAGE

Verify If Qos Flow Duration Counters Were Not Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NG_FLOW_IN_SESSION_DUR}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NG_FLOW_IN_SESSION_DUR}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2    filepath=${PM_COUNTERS}

Verify If Qos Flow Duration Counters Were Incremented
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Pm Counter Is In Range Of Given Values    counter_id=${COUNTER_ID_NG_FLOW_IN_SESSION_DUR}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}    margin=3%
    Verify If Pm Counter Is In Range Of Given Values    counter_id=${COUNTER_ID_NG_FLOW_IN_SESSION_DUR}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2    filepath=${PM_COUNTERS}    margin=3%

Verify If Qos Flow Duration PMQAP Counters Were Incremented
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Pm Counter Is In Range Of Given Values    counter_id=${COUNTER_ID_NG_FLOW_IN_SESSION_DUR_PMQAP}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}    margin=3%
    Verify If Pm Counter Is In Range Of Given Values    counter_id=${COUNTER_ID_NG_FLOW_IN_SESSION_DUR_PMQAP}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2    filepath=${PM_COUNTERS}    margin=3%

Trigger Handover To Second Cell
    [Arguments]    ${ue_id}    ${dst_cell}    ${dst_phy_cell_id}
    Intercell Handover Trigger By A3    ue_id=${ue_id}    dst_cell=${dst_cell}     dst_phy_cell_id=${dst_phy_cell_id}

Enable PM Counters
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_enable_miNrPDCPCell.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_set_timerX2DataFwdGuard_to_10ms.json

Enable PMQAP Counters And Set Profiles
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_enable_miNrL2HiCUBearerpmqap.json
    Configure    ${DELTA_FILES_PATH}/Pm_counters/delta_sa_pmqap_5qi_value-6_1_2.yaml
