*** Settings ***
Resource    keywords_CB009324_Cloud.robot
Resource    ../CB009324_Traffic_shaping_at_gNB_L2_with_DL_data_over_X2-U/keywords_CB009324.robot
Resource    ../resources/common_keywords_vran.robot
Resource    ../resources/common_configuration.robot
Library    ../resources/pm_counters_validator_vran.py
Library    ../resources/common_keywords_vran.py

Documentation
...    author: Marcin Kotuła
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 24R2

Suite Setup    Run Keywords    Enable AiC Traffic Shaping
    ...    AND    Adapt AiC RLO Params
    ...    AND    Enable AiC FSTSCH Counters

Test Setup    Run Keywords    Configure SA VM interfaces AiC
    ...    AND    Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
    ...    AND    Enable AiC Burst Size Divider
    ...    AND    Wait For Next PM counters Interval

Test Teardown    Run Keywords    Deregister Multiple Ues    first_ue_id=1    last_ue_id=9
    ...    AND    Detach Multiple Ues Without Confirmation    ${FIRST_NSA_UE_ID_TDD}    ${LAST_NSA_UE_ID_TDD}

*** Variables ***
${TRAFFIC_DURATION_SEC}=    30s
${FIRST_NSA_UE_ID_TDD}=    11
${LAST_NSA_UE_ID_TDD}=    14
${FIRST_NSA_UE_ID_FDD}=    15
${LAST_NSA_UE_ID_FDD}=    18
${CELL_ID_FDD}=    3

*** Test Cases ***
CB009324-A-US2_Multiple_Ue_With_A_Combination_Of_Sa_And_Nsa_With_Radio_Link_Outage_TDD_CLoud
    Attach NSA MUe With SgNBAddition
    Attach Multi Sa Ues And Start Traffic
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Sa Ue Statistics
    Display Bearer Statistics
    Trigger Radio Link Outage Multiple Ues
    Clear Bearer Statistics
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Statistics
    Verify If Downlink PDCP Pdu QoS Grp 9 Pm Counters Were Incremented
    Verify Pdcp Pdu Packet Lost On X2-U Cloud
    Verify Packet Drops At Transport First Level Scheduler Cloud

CB009324-A-US2_Multiple_Ue_With_A_Combination_Of_Sa_And_Nsa_With_Radio_Link_Outage_FDD_Cloud
    Attach NSA MUe With SgNBAddition    ${FIRST_NSA_UE_ID_FDD}    ${LAST_NSA_UE_ID_FDD}    ${CELL_ID_FDD}
    Attach Multi Sa Ues And Start Traffic
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Sa Ue Statistics
    Display Bearer Statistics    ${FIRST_NSA_UE_ID_FDD}    ${LAST_NSA_UE_ID_FDD}
    Trigger Radio Link Outage Multiple Ues    ${FIRST_NSA_UE_ID_FDD}    ${LAST_NSA_UE_ID_FDD}
    Clear Bearer Statistics    ${LAST_NSA_UE_ID_FDD}
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Statistics    ${FIRST_NSA_UE_ID_FDD}    ${LAST_NSA_UE_ID_FDD}
    Verify If Downlink PDCP Pdu QoS Grp 9 Pm Counters Were Incremented
    Verify Pdcp Pdu Packet Lost On X2-U Cloud
    Verify Packet Drops At Transport First Level Scheduler Cloud