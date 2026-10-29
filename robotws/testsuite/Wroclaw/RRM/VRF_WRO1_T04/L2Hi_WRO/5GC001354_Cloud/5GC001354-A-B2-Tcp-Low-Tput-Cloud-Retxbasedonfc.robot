*** Settings ***
Resource     ../resources/common_keywords_vran.robot
Resource     ../resources/common_variables.robot
Resource     keywords_5GC001354_AiC.robot
Library     ../resources/pm_counters_validator_vran.py

Documentation
...    author: Marcin Kotula
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    release: 23R1

Test Setup    Run Keywords    Configure SA VM interfaces AiC
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
...   AND   Enable AiC X2 And F1 Measurements
...   AND   Enable AiC 1354-A RetxBasedOnFC
...   AND   Wait For Next PM counters Interval

Test Teardown     Run Keywords    Detach Ue   ue_id=11
...   AND   Sleep    3s   Waiting for deregister

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s

*** Test Cases ***
5GC001354-A-B2_Nsa_Non_Gbr_Drb_Retransmission_of_lost_Pdcp_Pdus_Over_X2u_Interface_Tcp_Low_Tput_Cloud_Retxbasedonfc
    Attach Ue And Perform SgNBAdditionRequest
    Start Low Dl Data Traffic With Tcp
    Force Packet Losts On X2-U
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Statistics On MCG And SCG
    Wait For Next PM counters Interval
    Verify If Dl Pdcp Sdus Were Transmitted For Nsa Bearer
    Verify If DL Pdcp Pdu Were Sent Over Nr X2-u Dl Gtp-u Tunnel
    Verify If 1354-A Retx Counters Were Incremented

*** Keywords ***
Enable AiC 1354-A RetxBasedOnFC
    Send XML CU Delta Commisioning    ${DELTA_FILES_PATH_AIC}/5GC001354/delta_enable_1354-A_retxBasedOnFC_vCU.xml

Start Low Dl Data Traffic With Tcp
    Start Data Traffic  ues=11    bearer_id=2    direction=dl    throughput=5mbps    optional_parameters=protocol=tcp
