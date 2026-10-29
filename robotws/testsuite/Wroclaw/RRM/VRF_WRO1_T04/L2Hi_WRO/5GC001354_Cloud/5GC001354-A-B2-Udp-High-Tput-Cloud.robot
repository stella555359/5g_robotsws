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
...   AND   Enable AiC 1354-A
...   AND   Wait For Next PM counters Interval

Test Teardown     Run Keywords    Detach Ue   ue_id=11
...   AND   Sleep    3s   Waiting for deregister

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s

*** Test Cases ***
5GC001354-A-B2_Nsa_Non_Gbr_Drb_Retransmission_of_lost_Pdcp_Pdus_Over_X2u_Interface_Udp_High_Tput_Cloud
    Attach Ue And Perform SgNBAdditionRequest
    Start Dl Data Traffic With Udp
    Force Packet Losts On X2-U
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Statistics On MCG And SCG
    Wait For Next PM counters Interval
    Verify If Dl Pdcp Sdus Were Transmitted For Nsa Bearer
    Verify If 1354-A Retx Counters Were Incremented

*** Keywords ***
Start Dl Data Traffic With Udp
    Start Data Traffic  ues=11    bearer_id=2    direction=dl    throughput=150mbps    optional_parameters=protocol=udp trf_id=1
    Start Data Traffic  ues=11    bearer_id=2    direction=dl    throughput=150mbps    optional_parameters=protocol=udp trf_id=2
    Start Data Traffic  ues=11    bearer_id=2    direction=dl    throughput=150mbps    optional_parameters=protocol=udp trf_id=3
