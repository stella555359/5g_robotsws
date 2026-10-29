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
...    maintainer: Anna Chabik (anna.chabik@nokia.com)
...    testline: CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH
...    release: 22R3

Test Setup    Run Keywords    Configure SA VM interfaces AiC
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SA_TDD_AIC}
...   AND   Enable AiC Vonr And Rohc

Test Teardown     Run Keywords    Deregister Multiple Ues   first_ue_id=1    last_ue_id=9
...   AND   Sleep    3s   Waiting for deregister

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s

*** Test Cases ***
5GC000774-Multi_Ue
    Wait For Next PM counters Interval
    Attach Multiple 5g Ues Capable Of Supporting Rohc    num_of_ues=${9}
    Start Dl And Ul Data Traffic For Tcp Udp And Rtp Packet Stream
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics
    Verify If Rohc Dl And Ul Header Pm Counters Are Incremented
    Verify Rohc Contexts Pm Counters Values
    Check If Expected Throughout Is Reached For All Ues And There Are No Packets Lost

*** Keywords ***
Attach Multiple 5g Ues Capable Of Supporting Rohc
    [Arguments]    ${num_of_ues}=${9}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Set Internal Traffic Type To UEs    ue_id=${ue_id}    pdu_id=${ue_id}
        Attach Ue    ue_id=${ue_id}
        ta5g_ue_mobility.Establish Pdu Session    ue_id=${ue_id}    pdu_id=${ue_id}    gw_id=${ue_id}
        Modify Pdu Session    ue_id=${ue_id}    pdu_id=${ue_id}     qos_to_add=2
        Modify Pdu Session    ue_id=${ue_id}    pdu_id=${ue_id}     qos_to_add=3
    END

Display Ue Statistics
    [Arguments]    ${num_of_ues}=${9}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Display Qfi stats    ue_id=${ue_id}    pdu_id=${ue_id}    qfi_id=3
    END
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

Start Dl And Ul Data Traffic For Tcp Udp And Rtp Packet Stream
    FOR    ${ue_id}    IN RANGE    ${1}    ${3}+${1}
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=3 dir=dl kbps=30 protocol=tcp
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=3 dir=ul kbps=30 protocol=tcp
    END
    FOR    ${ue_id}    IN RANGE    ${4}    ${6}+${1}
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=3 dir=dl rtp_codec=amr_wb_23_85
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=3 dir=ul rtp_codec=amr_wb_23_85
    END
    FOR    ${ue_id}    IN RANGE    ${7}    ${9}+${1}
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=3 dir=dl kbps=30
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=3 dir=ul kbps=30
    END

Check That Amount Of Compressed And Decompressed Pdus For Profile 1 Is Incremented As Expected For This Traffic Time
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=compressed_pdu    mode=am    value=560    enb_id=2    cell_id=1
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=decompressed_profile_1_pdus    mode=am    value=560    enb_id=2    cell_id=1

Check That Difference Between Compressed And Decompressed Bytes For Profile 1 Is In Expected Range For This Traffic Time
    Rohc Statistic Smaller Than Given Value    rohc_statistic_prefix=size_of_compressed_pdus    mode=am    value=34000    enb_id=2    cell_id=1
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=decompressed_profile_1_bytes    mode=am    value=54000    enb_id=2    cell_id=1

Check If Expected Throughout Is Reached For All Ues And There Are No Packets Lost
    [Arguments]    ${num_of_ues}=${9}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Expected Throughput For Qfi Should Be Reached    ue_id=${ue_id}    pdu_id=${ue_id}    qfi_id=3
        ...    expected_throughput=30    unit=kbps    margin=1    direction=bi
        Check Number Of Total Packets Lost    ue_id=${ue_id}    pdu_id=${ue_id}    qfi_id=3    packet_loss=1
        ...    margin=1.0    direction=bi
    END

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
    ...    value=18    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_REQ_SENT}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=18    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_RESP_RECD}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=18    local_moid=MRBTS-1/NRBTS-1/NRCELL-1    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_REQ_SENT}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=18    local_moid=MRBTS-1/NRBTS-1/NRCELL-1    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_CMP_RECD}