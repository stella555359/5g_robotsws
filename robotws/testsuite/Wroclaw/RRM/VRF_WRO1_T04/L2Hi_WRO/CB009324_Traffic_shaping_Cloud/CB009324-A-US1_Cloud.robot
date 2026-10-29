*** Settings ***
Resource    keywords_CB009324_Cloud.robot
Resource    ../5GC001354_Cloud/keywords_5GC001354_AiC.robot
Resource    ../resources/common_keywords_vran.robot
Resource    ../resources/common_variables.robot
Resource    ../resources/common_configuration.robot
Library    ../resources/pm_counters_validator_vran.py

Documentation
...    author: Marcin Kotuła
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 24R2

Suite Setup    Run Keywords    Enable AiC Traffic Shaping
    ...    AND    Enable AiC FSTSCH Counters

Test Setup    Run Keywords    Configure SA VM interfaces AiC
    ...    AND    Enable Cloud
    ...    AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    ...    AND    Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
    ...    AND    Enable AiC Burst Size Divider
    ...    AND    Enable miNrNGCC
    ...    AND    Wait For Next PM counters Interval

Test Teardown     Run Keywords    Stop Default Logging    output_dirpath=${OUTPUT_DIR}
...   AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${TRAFFIC_DURATION_SEC}=    60s
${UE_ID_TDD}=    11
${UE_ID_FDD}=    15
${CELL_ID_FDD}=    3

*** Test Cases ***
CB009324-A-US1_Single_Nsa_Ue_With_Higher_Throughput_Over_Lte_TDD_Cloud
    Attach Ue And Perform SgNBAdditionRequest
    Start Dl And Ul Data Traffic
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Statistics On MCG And SCG
    Verify If Downlink PDCP Pdu QoS Grp 9 Pm Counters Were Incremented
    Verify Pdcp Pdu Packet Lost On X2-U Cloud
    Verify Packet Drops At Transport First Level Scheduler Cloud
    Detach Ue    ue_id=${UE_ID_TDD}

CB009324-A-US1_Single_Nsa_Ue_With_Higher_Throughput_Over_Lte_FDD_Cloud
    Attach Ue And Perform SgNBAdditionRequest    ${UE_ID_FDD}    ${CELL_ID_FDD}
    Start Dl And Ul Data Traffic    ${UE_ID_FDD}
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Statistics On MCG And SCG    ${UE_ID_FDD}
    Verify If Downlink PDCP Pdu QoS Grp 9 Pm Counters Were Incremented
    Verify Pdcp Pdu Packet Lost On X2-U Cloud
    Verify Packet Drops At Transport First Level Scheduler Cloud
    Detach Ue    ue_id=${UE_ID_TDD}