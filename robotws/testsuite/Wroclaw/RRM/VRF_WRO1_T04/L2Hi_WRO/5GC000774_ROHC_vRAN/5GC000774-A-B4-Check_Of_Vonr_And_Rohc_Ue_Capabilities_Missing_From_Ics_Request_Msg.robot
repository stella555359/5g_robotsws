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
...    author: Marcin Kotula
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH
...    release: 22R3

Test Setup    Run Keywords    Configure SA VM interfaces AiC
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
...   AND   Enable AiC Vonr And Rohc
...   AND   Set Internal Traffic Type To UEs

Test Teardown     Run Keywords    Deregister Ue   ue_id=1
...   AND   Sleep    3s   Waiting for deregister

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s
${ROHC_PROFILES}=    ((nr-rrc.profile0x0000 == 1) && (nr-rrc.profile0x0002 == 1)) && (nr-rrc.profile0x0001 == 1)

*** Test Cases ***
5GC000774-A-B4_Check_Of_Vonr_And_Rohc_Ue_Capabilities_Missing_From_Ics_Request_Msg
    Attach Ue And Set Pdu Session
    #Trigger Radio Capability And Check Reqexp
    Sleep    10s
    Start Dl And Ul Data Traffic For All Packet Stream
    Display Stats

*** Keywords ***
Attach Ue And Set Pdu Session
    ${alias}=    Start Tshark For Custom Interface  eth_interface=eth7
    Attach Ue    ue_id=1
    Execute Egate Command    cmd=amf_ue_ics_param id=1 ue=1 include_ue_capabilities=off
    ta5g_ue_mobility.Establish Pdu Session    ue_id=1    pdu_id=1   gw_id=1
    Verify Tshark For Single Message    alias=${alias}    packet_filter=${ICS_SETUP_RESP_SUCCESS}
    Verify Tshark For Single Message    alias=${alias}    packet_filter=${ROHC_PROFILES}
    Stop Tshark    alias=${alias}
    Modify Pdu Session    ue_id=1    pdu_id=1    qos_to_add=2
    Modify Pdu Session    ue_id=1    pdu_id=1    qos_to_add=3

Start Dl And Ul Data Traffic For All Packet Stream
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=dl trf_id=1 rtp_codec=amr_wb_23_85
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=ul trf_id=2 rtp_codec=amr_wb_23_85
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=dl trf_id=3 kbps=30
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=ul trf_id=4 kbps=30
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=dl trf_id=5 kbps=30 protocol=tcp
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=ul trf_id=6 kbps=30 protocol=tcp

Display Stats
    Sleep    ${TRAFFIC_DURATION_SEC}
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=compressed_pdu    mode=am    value=650    enb_id=2    cell_id=1
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=3
    ...    expected_throughput=80    unit=kbps    margin=0.2    direction=dl
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=3
    ...    expected_throughput=80    unit=kbps    margin=0.2    direction=ul
    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=3    packet_loss=0
    ...    margin=0.0    direction=bi