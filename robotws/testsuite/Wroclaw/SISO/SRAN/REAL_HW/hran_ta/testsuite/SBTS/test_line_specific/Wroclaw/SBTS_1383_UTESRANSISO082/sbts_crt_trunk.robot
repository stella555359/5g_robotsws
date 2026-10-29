*** Settings ***
Documentation
...  Test Suite Author: Patryk Naroznik
...  Test Suite Owner:  Agata Skorasinska
...  Team: T08



Resource          ../../../test_resources/BS-RF/BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM1_1__RP001548__Automated.robot
Resource          ../../../test_resources/BS-RF/BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-3__RP001548__Automated.robot


*** Variables ***
${HW_LOCATION_CODE}         Wroclaw
${COMMISSIONING_PATH}       /home/ute/testline_init_results/execution/configs/topology_configs/node_1/10_16_UTESRANSISO082_TESTMODELS.xml
${COLLECT_SNAPSHOT_FLAG}    failed_verdict
${TESTLINE_NAME}            10_16_UTESRANSISO082

*** Test Cases ***
[TM][1.0] Automated_Start_Stop_LTE_Downlink_TestModels
    [Setup]    Run Keywords    Set Test Variable    ${USER_LTE_CELL}    71
    ...    AND    Set Test Variable    ${USER_PHY_CELL_ID}
    ...    AND    BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM1_1__RP001548__Automated.TC Setup
    ...    AND    Set Library Search Order    BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM1_1__RP001548__Automated
    [Timeout]    14400
    TC__BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM1_1__RP001548__Automated
    [Teardown]   BS-RF__Start_Stop_LTE_Downlink_TestModels_E-TM1_1__RP001548__Automated.TC Teardown

[TM][2.0] Automated_Start_Stop_LTE_Uplink_TestModels
    [Setup]    Run Keywords    Set Test Variable    ${USER_LTE_CELL}    73
    ...    AND    BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-3__RP001548__Automated.TC Setup
    ...    AND    Set Library Search Order    BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-3__RP001548__Automated
    [Timeout]    14400
    TC__BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-3__RP001548__Automated
    [Teardown]    BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-3__RP001548__Automated.TC Teardown



