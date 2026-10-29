*** Settings ***
Resource     ../resources/common_keywords_vran.robot
Resource     ../resources/common_keywords.robot
Resource     ../resources/common_variables.robot
Resource     keywords_5GC001354_AiC.robot
Library     ../resources/pm_counters_validator_vran.py
Library     ../resources/common_keywords_vran.py
Library     ../resources/common_variables_vran.py
Variables     ../resources/common_variables.py

Documentation
...    author: Marcin Kotula
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
...    release: 24R2

Test Setup    Run Keywords    Update Gscn In Iphy File    GSCN_1=7832    GSCN_2=7902
...   AND   Enable AiC Carrier Aggregation With Blind Scell Activation
...   AND   Modify AiC Config To 2CC CA
...   AND   Configure SA VM interfaces AiC
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
...   AND   Enable AiC X2 And F1 Measurements
...   AND   Enable AiC 1354-C Pdcp Delay Threshold Based Pdu Retransmission
...   AND   Set AiC Drxlongcycle To 320ms
...   AND   Wait For Next PM counters Interval

Test Teardown     Run Keywords    Detach Ue   ue_id=11
...   AND   Sleep    3s   Waiting for deregister

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s
${UE_DC_ID}=    11

*** Test Cases ***
5GC001354-C-B2_Nsa_Non_Gbr_Drb_Retransmission_Of_Pdcp_Pdus_Due_To_Rlo_With_Ca_Enabled_Cloud_Long_Drx
    Attach NSA Ue And Start Gnb Addition
    Start Data Traffic With Tcp
    Trigger Radio Link Outage
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Statistics On MCG And SCG
    Wait For Next PM counters Interval
    Verify If 1354-C Threshld 1 Qos Grp 9 X2 Pm Counters Were Incremented
    Verify If 1354-C Threshld 2 Qos Grp 9 X2 Pm Counters Were Incremented
    Verify If 1354-C Treshold 1 Transmission Delay Bin 1 And Bin 2 X2 Pm Counters Were Incremented
    Verify If 1354-C Treshold 2 Transmission Delay Bin 1 And Bin 2 X2 Pm Counters Were Incremented
    Verify That Due To High Attenuation Some Dl Pdcp Pdus Exceeded Max Delay Allowed For Retransmissioncn Qos Group 09

*** Keywords ***
Attach NSA Ue And Start Gnb Addition
    Execute Egate Command    cmd=ue_param id=${UE_DC_ID} ue_nr_capabilities=${UE_CAPA_FOR_2CC}
    Execute Egate Command    cmd=ue_param id=${UE_DC_ID} ue_eutra_nr_capabilities=${UE_EUTRA_CAPA_FOR_2CC}
    Attach Ue And Perform SgNBAdditionRequest
