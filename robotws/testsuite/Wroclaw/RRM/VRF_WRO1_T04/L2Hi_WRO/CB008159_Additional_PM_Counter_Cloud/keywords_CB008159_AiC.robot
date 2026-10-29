*** Settings ***
Library     ta5g_pm_counters

Documentation
...    This file contains keywords used for testing Feature CB008159 on Cloud RINLINE TL.

*** Keywords ***
Send 8159-C-3 Delta Commissioning
    Perform CU Delta Commissioning    ${CURDIR}/config/8159-C_CU_delta.json
    Perform DU Delta Commissioning    ${CURDIR}/config/8159-C_DU_delta.json
    Sleep    180s

Prepare Environment
    Wait For Next PM counters Interval
    Set Internal Traffic Type To UEs    ue_id=1
    Execute Egate Command    cmd=ue_change_location id=2 cell=2
    Set Internal Traffic Type To UEs    ue_id=2

Start Data Traffic
    [Arguments]    ${ue_id}    ${qfi_id}    ${direction}    ${duration}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=${qfi_id} dir=${direction} period_ms=50 burst=5 mbps=5 seconds=${duration}
    ...    pass_regexp=Started .{2,4}link Internal traffic
    Increment In Session Time    ue_id=${ue_id}    duration=${duration}

Start Data Traffic Above 40mbps
    [Arguments]    ${ue_id}    ${qfi_id}    ${direction}    ${duration}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=${qfi_id} dir=${direction} mbps=40 seconds=${duration}
    ...    pass_regexp=Started .{2,4}link Internal traffic

Start Data Traffic Above 40mbps On The Same Qos At The Same Time
    [Arguments]    ${ue_id}=2    ${qfi_id}=1    ${duration}=20s
    Start Data Traffic Above 40mbps    ue_id=${ue_id}    qfi_id=${qfi_id}    direction=dl    duration=${duration}
    Start Data Traffic Above 40mbps    ue_id=${ue_id}    qfi_id=${qfi_id}    direction=ul    duration=${duration}
    Increment In Session Time    ue_id=${ue_id}    duration=${duration}

Start Data Traffic Above 40mbps On Different Qos At The Same Time
    [Arguments]    ${ue_id}=1    ${qfi_1}=3    ${qfi_2}=4     ${duration}=20s
    Start Data Traffic Above 40mbps   ue_id=${ue_id}    qfi_id=${qfi_1}    direction=dl    duration=${duration}
    Increment In Session Time    ue_id=${ue_id}    duration=${duration}
    Start Data Traffic Above 40mbps    ue_id=${ue_id}    qfi_id=${qfi_2}    direction=ul    duration=${duration}
    Increment In Session Time    ue_id=${ue_id}    duration=${duration}

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
    ...    log_filename=wireshark_eth7.pcap
    ...    eth_interface=eth7
    ...    alias=GTP_MESSAGE

Stop Collect Gpt Message
    Stop Capturing    alias=GTP_MESSAGE
    Stop tshark    alias=GTP_MESSAGE
