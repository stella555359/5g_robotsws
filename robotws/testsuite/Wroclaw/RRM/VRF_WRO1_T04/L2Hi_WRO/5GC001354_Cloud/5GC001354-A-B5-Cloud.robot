*** Settings ***
Resource     ../resources/common_keywords_vran.robot
Resource     ../resources/common_variables.robot
Resource     keywords_5GC001354_AiC.robot
Library     ../resources/pm_counters_validator_vran.py
Library    ute_wtssim
Library    ta5g_cell_operations
Library    ta5g_tshark

Documentation
...    author: Marcin Kotula
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    release: 23R1

Test Setup    Run Keywords    Configure SA VM interfaces AiC
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
...   AND   Enable AiC X2 And F1 Measurements
...   AND   Enable AiC 1354-A_B
...   AND   Enable AiC A3 Measurements
...   AND   Enable AiC NSA Mobility
...   AND   Wait For Next PM counters Interval

Test Teardown     Run Keywords    Detach Ue    ue_id=11
...   AND   Sleep    3s   Waiting for deregister

*** Variables ***
${TRAFFIC_DURATION_SEC}=    20s
${UE_DC_ID}=    11
${SCG_BEARER_ID}=    2
${srsrp_part}=    srsrp_nr=11 srsrq_nr=11 ssinr_nr=11
${nrsrp_part}=    nrsrp_nr=30 nrsrq_nr=30 nsinr_nr=30
${UE_NR_CAPA}=    21000000010800000004DE4D0780720800000520800001520800002524A000034C00454000000000000054
${UE_EUTRA_NR_CAPA}=    A10180902C100389A0000008800B0400F89A000008000800080402004008

*** Test Cases ***
5GC001354-A-B5_Nsa_Non_Gbr_Drb_Duplicate_Transmission_Of_Pdcp_Pdu_For_Ddds_Handling_During_Pdcp_Sn_Rollover_Actx2duplicatetxnsa3x_True_Cloud
    Attach NSA Ue And Start Gnb Addition
    Start Dl Data Traffic With Tcp
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Statistics On MCG And SCG
    Trigger Handover to second cell
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Statistics On MCG And SCG
    Wait For Next PM counters Interval
    Verify If 1354-B Counters Were Incremented

*** Keywords ***
Attach NSA Ue And Start Gnb Addition
    Execute Egate Command    cmd=ue_param id=${UE_DC_ID} ue_nr_capabilities=${UE_NR_CAPA}
    Execute Egate Command    cmd=ue_param id=${UE_DC_ID} ue_eutra_nr_capabilities=${UE_EUTRA_NR_CAPA}
    Attach Ue And Perform SgNBAdditionRequest

Start Dl Data Traffic With Tcp
    Start Data Traffic  ues=${UE_DC_ID}    bearer_id=${SCG_BEARER_ID}    direction=dl    throughput=150mbps    optional_parameters=protocol=tcp

Trigger Handover to second cell
    Execute Egate Command   cmd=ue_measurement_send_nr id=${UE_DC_ID} meas_id=1 event=A3 ${srsrp_part} phycell_id=51 ${nrsrp_part}
