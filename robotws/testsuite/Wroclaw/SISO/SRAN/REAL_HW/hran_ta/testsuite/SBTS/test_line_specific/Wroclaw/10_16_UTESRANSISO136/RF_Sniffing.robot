*** Settings ***
Documentation
...  Test Suite Author: Marek Gazarkiewicz
...  Test Suite Owner:  Mateusz Chryplewicz
...  Team : T01


Resource          ../../../test_resources/BS-RF/SiSo_TEST_online_RF_Sniffing_RF_Scanning_3G_4G_5G.robot
Resource          ../../../test_resources/BS-RF/SiSo_TEST_TDS_RF_Sniffing_RF_Scanning_3G_4G_5G.robot

*** Variables ***
${HW_LOCATION_CODE}         Wroclaw
${COMMISSIONING_PATH}    SEPARATOR=    /home/ute/testline_configuration/10_16_UTESRANSISO136/10_16_UTESRANSISO136_DEFAULT.xml
${COLLECT_SNAPSHOT_FLAG}    failed_verdict
${TESTLINE_NAME}            10_16_UTESRANSISO136

*** Test Cases ***

[RF_SNIFFING][1.0] Automated_SiSo_TEST_online_RF_Sniffing_RF_Scanning_3G_4G_5G
    [Setup]    Run Keywords
    ...    Set Test Variable    ${RMOD_SN}    K9245128908
    ...    AND    Set Test Variable    ${USER_RAT_TO_LAUNCH}  5G-4G
    ...    AND    SiSo_TEST_online_RF_Sniffing_RF_Scanning_3G_4G_5G.TC Setup
    ...    AND    Set Library Search Order  SiSo_TEST_online_RF_Sniffing_RF_Scanning_3G_4G_5G
    [Timeout]    14400
    TC__SiSo_TEST_online_RF_Sniffing_RF_Scanning_3G_4G_5G
    [Teardown]  SiSo_TEST_online_RF_Sniffing_RF_Scanning_3G_4G_5G.TC Teardown

[RF_SNIFFING][1.0] Automated_SiSo_TEST_TDS_RF_Sniffing_RF_Scanning_3G_4G_5G
    [Setup]    Run Keywords
    ...    Set Test Variable    ${RMOD_SN}    K9245128908
    ...    AND    Set Test Variable    ${USER_RAT_TO_LAUNCH}  5G-4G
    ...    AND    SiSo_TEST_TDS_RF_Sniffing_RF_Scanning_3G_4G_5G.TC Setup
    ...    AND    Set Library Search Order  SiSo_TEST_TDS_RF_Sniffing_RF_Scanning_3G_4G_5G
    [Timeout]    14400
    TC__SiSo_TEST_TDS_RF_Sniffing_RF_Scanning_3G_4G_5G
    [Teardown]  SiSo_TEST_TDS_RF_Sniffing_RF_Scanning_3G_4G_5G.TC Teardown
