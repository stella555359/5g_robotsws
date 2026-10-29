*** Settings ***
Documentation
...    Author:  Claire.gao
...    Contact: claire.gao@nokia-sbell.com
...    Feature: CB009180
...    Release: 23R4
...    Only NR_FDD_CPRI_8cells_and_LTE_FDD_CPRI_6cells on CRT testline
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot
Force Tags    5G_RAN_FDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    1908    9298    4001    7102    49
${scfc_file}      CB009180_ABIP_2AHFII_2AHEH_FDD_CPRI_4T4R_6LNCEL_8NRCEL_Shared.xml

*** Test Cases ***
CB009180_D_TC24_Concurrent_ABIP_NR_FR1_FDD_CPRI_12cells_and_LTE_FDD_CPRI_12cells_shared_FH_L3call
    [Tags]    SMAwave    CB009180    CB009180_US24    Trunk    QL3
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB009180${/}${scfc_file}    5min    600
    Perform NR Cell block 1,9,3,2,11,7 via AdminCLI
    Perform 4G Cell block 5,6,3 via AdminCLI
    Run Keyword And Continue On Failure    SMAwave L3 call    2    120M    60M    10%    4G    66    UE_2
    Perform NR Cell unblock 7 via AdminCLI
    Wait Until Keyword Succeeds    80s    20s    Check If Specific Cell Is OnAir    7    5G
    Run Keyword And Continue On Failure    SMAwave L3 call    7    200M    39M    15%    5G    66    UE_4
    Perform NR Cell unblock 1,9,3,2,11 via AdminCLI
    Perform 4G Cell unblock 5,6,3 via AdminCLI
