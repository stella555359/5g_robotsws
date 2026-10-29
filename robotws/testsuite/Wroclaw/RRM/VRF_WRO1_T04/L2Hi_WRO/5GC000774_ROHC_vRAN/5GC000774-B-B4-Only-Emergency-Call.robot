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
...    author: Anna Chabik
...    maintainer: Anna Chabik (anna.chabik@nokia.com)
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
5GC000774-B-B4_Verification_Of_Ctx_Pm_Counters_With_Only_Emergency_Call
    Attach One 5g Ue With Emergency Session Capable Of Supporting Rohc
    Start Dl And Ul Data Traffic For Emergency Session
    Display Emergency Call Statistics
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long
    Verify Rohc Contexts Pm Counters Values

*** Keywords ***
Attach One 5g Ue With Emergency Session Capable Of Supporting Rohc
    ${alias}=    Start Tshark For Custom Interface  eth_interface=eth7
    Set Internal Traffic Type To UEs
    Attach Ue    ue_id=1
    Execute Egate Command    cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1 request_type=initial-emergency-request
    Verify Tshark For Single Message    alias=${alias}    packet_filter=${ICS_SETUP_RESP_SUCCESS}
    Stop Tshark    alias=${alias}
    Modify Pdu Session    ue_id=1    pdu_id=1    qos_to_add=1
    Modify Pdu Session    ue_id=1    pdu_id=1    qos_to_add=3
    Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=3 by=amf
    Sleep    3s

Start Dl And Ul Data Traffic For Emergency Session
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 trf_id=2 kbps=10 dir=dl
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 trf_id=1 kbps=10 dir=ul
    Sleep    3s

Display Emergency Call Statistics
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

Verify Rohc Contexts Pm Counters Values
    Wait For Next PM counters Interval
    Verify CU Counter Value Is Exact As Given Value
    ...    value=2    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_REQ_SENT}
        Verify CU Counter Value Is Exact As Given Value
    ...    value=2    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_RESP_RECD}
        Verify CU Counter Value Is Exact As Given Value
    ...    value=2    local_moid=MRBTS-1/NRBTS-1/NRCELL-1    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_REQ_SENT}
        Verify CU Counter Value Is Exact As Given Value
    ...    value=2    local_moid=MRBTS-1/NRBTS-1/NRCELL-1    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_CMP_RECD}
