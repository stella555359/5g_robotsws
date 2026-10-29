*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library    ta5g_pm_counters
Library     keywords_ROHC.py
Documentation
...    author: Pawel Konieczny
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 22R3

Suite Setup      Run Keywords    Modify Config To Emergency Call
...            AND    Prepare Sa Test Environement And Reach Onair
...               perform_tl_reset=${RESET_TL}
...               cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
...               cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
...               cfg_filepath_tdd_fdd=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
...            AND    Enable Rohc Param For Gnb
...            AND    Enable Syslog Debug Prints For Rohc

Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs

Test Teardown    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s

*** Test Cases ***
5GC000774-A-B6_Successful_Setup_Of_Emergency_Voice_Call_On_Top_Of_An_Existing_VoNR_Call_With_Rohc_Enabled_With_Ipv4
    Attach One 5g Ue Capable Of Supporting Rohc
    Start Dl And Ul Data Traffic For Rtp Packet Stream    pdu_id=1    qfi_id=3
    Display Ue Statistics    qfi_id=3
    Check That Amount Of Compressed And Decompressed Pdus For Profile 1 Is Incremented As Expected For This Traffic Time
    ...    number_of_pdus=560
    Check That Difference Between Compressed And Decompressed Bytes For Profile 1 Is In Expected Range For This Traffic Time
    ...    number_of_compressed_bytes=34000
    Check If Expected Throughput Is Reached And There Are No Packets Lost    pdu_id=1    qfi_id=3
    Verify If Rohc Dl And Ul Header Pm Counters Are Incremented
    Verify Rohc Contexts Pm Counters Values
    Establish Emergency Pdu Session  ue_id=1    pdu_id=2    gw_id=2
    ${minimum_number_of_pdus}=    Get Rohc Statistic    prefix=compressed_pdu    enb_id=2    cell_id=1
    ${minimum_compressed_bytes}=    Get Rohc Statistic    prefix=size_of_compressed_pdus    enb_id=2    cell_id=1
    ${minimum_uncompressed_bytes}=    Get Rohc Statistic    prefix=decompressed_profile_1_bytes    enb_id=2    cell_id=1
    Start Dl And Ul Data Traffic For Rtp Packet Stream    pdu_id=2    qfi_id=2
    Display Ue Statistics    qfi_id=2
    Check That Amount Of Compressed And Decompressed Pdus For Profile 1 Is Incremented As Expected For This Traffic Time
    ...    number_of_pdus=${minimum_number_of_pdus}
    Check If Expected Throughput Is Reached And There Are No Packets Lost    pdu_id=2    qfi_id=2
    Verify Rohc Contexts Pm Counters Values
    Deregister Ue    ue_id=1

*** Keywords ***
Establish Emergency Pdu Session
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}
    Execute Egate Command    cmd=qosflow_modify qos_flow=2 priority=5
    Execute Egate Command    cmd=qosflow_modify qos_flow=3 priority=5
    Set Internal Traffic Type To UEs    pdu_id=${pdu_id}
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gw_id} request_type=initial-emergency-request
    Sleep    5s
    Modify Pdu Session    ue_id=1    pdu_id=2    qos_to_add=3
    Sleep    10s

Enable Rohc Param For Gnb
    Enable Vonr And Rohc TDD FDD
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Vonr_and_Rohc/delta_enable_emergency_call.json

Attach One 5g Ue Capable Of Supporting Rohc
    Set Internal Traffic Type To UEs
    Register Ue With Default Pdu Session
    Modify Pdu Session And Wait For Regexp    qos_id=1    qfi_id=2    5qi_id=8
    Modify Pdu Session And Wait For Regexp    qos_id=3    qfi_id=3    5qi_id=1
    Sleep    3s

Display Ue Statistics
    [Arguments]    ${qfi_id}
    Display Qfi stats    qfi_id=${qfi_id}
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

Start Dl And Ul Data Traffic For Rtp Packet Stream
    [Arguments]    ${pdu_id}    ${qfi_id}
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=${pdu_id} qfi=${qfi_id} dir=dl rtp_codec=amr_wb_23_85
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=${pdu_id} qfi=${qfi_id} dir=ul rtp_codec=amr_wb_23_85
    Sleep    ${TRAFFIC_DURATION_SEC}

Check That Amount Of Compressed And Decompressed Pdus For Profile 1 Is Incremented As Expected For This Traffic Time
    [Arguments]    ${number_of_pdus}
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=compressed_pdu    mode=am
    ...    value=${number_of_pdus}    enb_id=2    cell_id=1
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=decompressed_profile_1_pdus    mode=am
    ...    value=${number_of_pdus}    enb_id=2    cell_id=1

Check That Difference Between Compressed And Decompressed Bytes For Profile 1 Is In Expected Range For This Traffic Time
    [Arguments]    ${number_of_compressed_bytes}
    Rohc Statistic Smaller Than Given Value    rohc_statistic_prefix=size_of_compressed_pdus    mode=am
    ...    value=${number_of_compressed_bytes}    enb_id=2    cell_id=1
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=decompressed_profile_1_bytes    mode=am
    ...    value=${number_of_compressed_bytes}    enb_id=2    cell_id=1

Check If Expected Throughput Is Reached And There Are No Packets Lost
    [Arguments]    ${pdu_id}    ${qfi_id}
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    ...    expected_throughput=20    unit=kbps    margin=0.2    direction=bi
    Check Number Of Total Packets Lost    ue_id=1    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    ...    packet_loss=0    margin=0.0    direction=bi

Verify If Rohc Dl And Ul Header Pm Counters Are Incremented
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_NUM_ROHC_COMP_HEADER}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_VOL_ROHC_COMP_HEADER}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_UL_NUM_ROHC_DECOMP_HEADER}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_UL_VOL_ROHC_DECOMP_HEADER}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify Rohc Contexts Pm Counters Values
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_REQ_SENT}
    ...    value=2    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_RESP_RECD}
    ...    value=2    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_REQ_SENT}
    ...    value=2    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_CMP_RECD}
    ...    value=2    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
