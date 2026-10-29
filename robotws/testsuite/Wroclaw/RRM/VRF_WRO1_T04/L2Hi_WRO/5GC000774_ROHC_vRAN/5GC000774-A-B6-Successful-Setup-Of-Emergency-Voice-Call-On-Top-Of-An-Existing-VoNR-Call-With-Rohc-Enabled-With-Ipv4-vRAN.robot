*** Settings ***
Resource     ../resources/common_keywords.robot
Resource     ../resources/common_keywords_vran.robot
Resource     ../resources/common_variables.robot
Variables     ../resources/common_variables_vran.py
Library     ../resources/common_keywords.py
Library     ../resources/common_keywords_vran.py
Library     ../5GC000774_ROHC/keywords_ROHC.py
Library     ../resources/pm_counters_validator_vran.py
Documentation
...    author: Pawel Konieczny
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH
...    release: 22R3

Test Setup    Run Keywords    Modify AiC Config To Emergency Call
...   AND   Configure SA VM interfaces AiC
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
...   AND   Enable AiC Vonr And Rohc
...   AND   Enable AiC Emergency Call
...   AND   Set Internal Traffic Type To UEs

Test Teardown     Run Keywords    Deregister Ue   ue_id=1
...   AND   Sleep    3s   Waiting for deregister

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s

*** Test Cases ***
5GC000774-A-B6_Successful_Setup_Of_Emergency_Voice_Call_On_Top_Of_An_Existing_VoNR_Call_With_Rohc_Enabled_With_Ipv4
    Attach One 5g Ue Capable Of Supporting Rohc
    Start Dl And Ul Data Traffic For Rtp Packet Stream    pdu_id=1    qfi_id=3
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics    qfi_id=3
    Check That Amount Of Compressed And Decompressed Pdus For Profile 1 Is Incremented As Expected For This Traffic Time
    ...    number_of_pdus=560
#    Check That Difference Between Compressed And Decompressed Bytes For Profile 1 Is In Expected Range For This Traffic Time
#    ...    number_of_compressed_bytes=34000    number_of_uncompressed_bytes=54000
    Check If Expected Throughput Is Reached And There Are No Packets Lost    pdu_id=1    qfi_id=3
    Verify If Rohc Dl And Ul Header Pm Counters Are Incremented
    Verify Rohc Contexts Pm Counters Values
    Establish Emergency Pdu Session  ue_id=1    pdu_id=2   gw_id=2
    ${minimum_number_of_pdus}=    Get Rohc Statistic    prefix=compressed_pdu    enb_id=2    cell_id=1
    ${minimum_compressed_bytes}=    Get Rohc Statistic    prefix=size_of_compressed_pdus    enb_id=2    cell_id=1
    ${minimum_uncompressed_bytes}=    Get Rohc Statistic    prefix=decompressed_profile_1_bytes    enb_id=2    cell_id=1
    Start Dl And Ul Data Traffic For Rtp Packet Stream    pdu_id=2    qfi_id=2
    Display Ue Statistics    qfi_id=2
    Check That Amount Of Compressed And Decompressed Pdus For Profile 1 Is Incremented As Expected For This Traffic Time
    ...    number_of_pdus=1000
    Check If Expected Throughput Is Reached And There Are No Packets Lost    pdu_id=2    qfi_id=2
    Wait For Next PM counters Interval
    Verify Rohc Contexts Pm Counters Values

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

Attach One 5g Ue Capable Of Supporting Rohc
    ${alias}=    Start Tshark For Custom Interface  eth_interface=eth7
    Set Internal Traffic Type To UEs
    Attach Ue    ue_id=1
    ta5g_ue_mobility.Establish Pdu Session    ue_id=1    pdu_id=1   gw_id=1
    Verify Tshark For Single Message    alias=${alias}    packet_filter=${ICS_SETUP_RESP_SUCCESS}
    Stop Tshark    alias=${alias}
    Modify Pdu Session    ue_id=1    pdu_id=1    qos_to_add=1
    Modify Pdu Session    ue_id=1    pdu_id=1    qos_to_add=3
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
    ...    value=${number_of_pdus}   enb_id=2    cell_id=1
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=decompressed_profile_1_pdus    mode=am
    ...    value=${number_of_pdus}   enb_id=2    cell_id=1

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
    Wait For Next PM counters Interval
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_DL_NUM_ROHC_COMP_HEADER}
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_DL_VOL_ROHC_COMP_HEADER}
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_UL_NUM_ROHC_DECOMP_HEADER}
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_UL_VOL_ROHC_DECOMP_HEADER}

Verify Rohc Contexts Pm Counters Values
    Verify CU Counter Value Is Exact As Given Value
    ...    value=2    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_REQ_SENT}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=2    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_RESP_RECD}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=2    local_moid=MRBTS-1/NRBTS-1/NRCELL-1    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_REQ_SENT}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=2    local_moid=MRBTS-1/NRBTS-1/NRCELL-1    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_CMP_RECD}

Enable Vran Emergency Call
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/Emergency_Call_CU_delta.json
    Perform DU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/Emergency_Call_DU_delta.json
    Sleep    180s
