*** Settings ***
Resource    keywords_CB009324.robot
Resource    ../resources/common_configuration.robot

Documentation
...    author: Marcin Kotuła
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 24R2

Suite Setup     Run Keywords    Enable Burst Size Divider
    ...       AND    Enable Traffic Shaping TDD
    ...       AND    Adapt RLO Params
    ...       AND    Prepare Sa Test Environement And Reach Onair
    ...              perform_tl_reset=${RESET_TL}
    ...              cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
    ...       AND    Enable FSTSCH Counters

Test Teardown    Send Configuration ID To Scout

Suite Teardown     Run Keywords    Check For An Unexpected Alarm
...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${TRAFFIC_DURATION_SEC}=   30s
${FIRST_NSA_UE_ID_TDD}=    11
${LAST_NSA_UE_ID_TDD}=    14
${FIRST_NSA_UE_ID_FDD}=    15
${LAST_NSA_UE_ID_FDD}=    18
${CELL_ID_FDD}=    3

*** Test Cases ***
CB009324-A-US2_Multiple_Ue_With_A_Combination_Of_Sa_And_Nsa_With_Radio_Link_Outage_TDD
    Wait For Next Full Pm Interval
    Attach 4 Nsa Ues With Sgnb And Start Traffic
    Attach Multi Sa Ues And Start Traffic
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Sa Ue Statistics
    Display Bearer Statistics
    Trigger Radio Link Outage Multiple Ues
    Clear Bearer Statistics
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Statistics
    Verify If Downlink PDCP Pdu QoS Grp 6 Pm Counters Were Incremented
    Verify Pdcp Pdu Packet Lost On X2-U
    Verify Packet Drops At Transport First Level Scheduler
    Deregister Multiple Ues    first_ue_id=1    last_ue_id=10
    Detach Multiple Ues Without Confirmation    ${FIRST_NSA_UE_ID_TDD}    ${LAST_NSA_UE_ID_TDD}

CB009324-A-US2_Multiple_Ue_With_A_Combination_Of_Sa_And_Nsa_With_Radio_Link_Outage_FDD
    Wait For Next Full Pm Interval
    Enable Traffic Shaping FDD
    Attach 4 Nsa Ues With Sgnb And Start Traffic    ${FIRST_NSA_UE_ID_FDD}    ${LAST_NSA_UE_ID_FDD}    ${CELL_ID_FDD}
    Attach Multi Sa Ues And Start Traffic
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Sa Ue Statistics
    Display Bearer Statistics    ${FIRST_NSA_UE_ID_FDD}    ${LAST_NSA_UE_ID_FDD}
    Trigger Radio Link Outage Multiple Ues    ${FIRST_NSA_UE_ID_FDD}    ${LAST_NSA_UE_ID_FDD}
    Clear Bearer Statistics
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Statistics    ${FIRST_NSA_UE_ID_FDD}    ${LAST_NSA_UE_ID_FDD}
    Verify If Downlink PDCP Pdu QoS Grp 6 Pm Counters Were Incremented
    Verify Pdcp Pdu Packet Lost On X2-U
    Verify Packet Drops At Transport First Level Scheduler
    Deregister Multiple Ues    first_ue_id=1    last_ue_id=10
    Detach Multiple Ues Without Confirmation    ${FIRST_NSA_UE_ID_FDD}    ${LAST_NSA_UE_ID_FDD}
