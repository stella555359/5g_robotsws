*** Settings ***
Resource    keywords_CB009324_Cloud.robot
Resource    ../CB009324_Traffic_shaping_at_gNB_L2_with_DL_data_over_X2-U/keywords_CB009324.robot
Resource    ../5GC001354_Cloud/keywords_5GC001354_AiC.robot
Resource    ../resources/common_keywords_vran.robot
Resource    ../resources/common_configuration.robot
Library    ../resources/common_keywords_vran.py
Library    ../resources/pm_counters_validator_vran.py

Documentation
...    author: Marcin Kotuła
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 24R2

Suite Setup    Run Keywords    Update Gscn In Iphy File    GSCN_1=7832    GSCN_2=7902
    ...    AND    Enable AiC Carrier Aggregation With Blind Scell Activation
    ...    AND    Modify AiC Config To 2CC CA
    ...    AND    Adapt AiC RLO Params
    ...    AND    Enable AiC Traffic Shaping
    ...    AND    Enable AiC FSTSCH Counters

Test Setup    Run Keywords    Configure SA VM interfaces AiC
    ...    AND    Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
    ...    AND    Enable AiC X2 And F1 Measurements
    ...    AND    Enable AiC 1354-C Pdcp Delay Threshold Based Pdu Retransmission
    ...    AND    Set AiC Drxlongcycle To 320ms
    ...    AND    Enable AiC Burst Size Divider
    ...    AND    Wait For Next PM counters Interval

Test Teardown     Run Keywords    Deregister Multiple Ues    first_ue_id=1    last_ue_id=4
    ...    AND    Detach Multiple Ues Without Confirmation    first_ue_id=11    last_ue_id=14
    ...    AND    Sleep    3s    Waiting for deregister

*** Variables ***
${TRAFFIC_DURATION_SEC}=    30s
${NUMBER_OF_SA_UES}=    4
${LAST_NSA_UE_ID}=    12

*** Test Cases ***
CB009324-B-US3_Traffic_Shaping_For_DL_Split_Traffic_Over_X2-U_For_Multiple_UEs_PDCP_Fast_Retransmissions_And_Forwarded_Data_Over_X2-U_Cloud
    Attach NSA MUe With SgNBAddition
    Attach Multi Sa Ues And Start Traffic    ${NUMBER_OF_SA_UES}
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Sa Ue Statistics    ${NUMBER_OF_SA_UES}
    Display Bearer Statistics
    Trigger Radio Link Outage Multiple Ues    last_nsa_ue_id=${LAST_NSA_UE_ID}
    Perform Sgnb Release
    Clear Bearer Statistics
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Statistics
    Verify If Downlink PDCP Pdu QoS Grp 9 Pm Counters Were Incremented
    Verify Pdcp Pdu Packet Lost On X2-U Cloud
    Verify Packet Drops At Transport First Level Scheduler Cloud
    Verify If 1354-C Threshld 1 Qos Grp 9 X2 Pm Counters Were Incremented
    Verify If 1354-C Threshld 2 Qos Grp 9 X2 Pm Counters Were Incremented
    Verify If 1354-C Treshold 1 Transmission Delay Bin 1 And Bin 2 X2 Pm Counters Were Incremented
    Verify If 1354-C Treshold 2 Transmission Delay Bin 1 And Bin 2 X2 Pm Counters Were Incremented