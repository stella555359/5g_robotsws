*** Settings ***
Resource     ../resources/common_keywords_vran.robot
Resource     ../resources/common_variables.robot
Resource     ../resources/common_keywords.robot
Resource     keywords_5GC001354_AiC.robot
Library     ../resources/pm_counters_validator_vran.py

Documentation
...    author: Marcin Kotula
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    release: 23R1

Test Setup    Run Keywords    Configure SA VM interfaces AiC
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
...   AND   Enable AiC X2 And F1 Measurements
...   AND   Enable AiC 1354-A_B
...   AND   Wait For Next PM counters Interval

Test Teardown     Run Keywords    Detach Ue   ue_id=11
...   AND   Sleep    3s   Waiting for deregister

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s

*** Test Cases ***
5GC001354-A-B4_Nsa_Non_Gbr_Drb_Retransmission_Of_Lost_Duplicated_PDU_X2_Tcp_Cloud
    Attach Ue And Perform SgNBAdditionRequest
    Start Data Traffic With Tcp
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Statistics On MCG And SCG
    Trigger Radio Link Outage
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Statistics On MCG And SCG
    Wait For Next PM counters Interval
    Verify If Dl Pdcp Sdus Were Transmitted For Nsa Bearer
    Verify If DL Pdcp Pdu Were Sent Over Nr X2-u Dl Gtp-u Tunnel
    Verify If 1354-A Retx Counters Were Incremented
    Verify If 1354-B Counters Were Incremented
