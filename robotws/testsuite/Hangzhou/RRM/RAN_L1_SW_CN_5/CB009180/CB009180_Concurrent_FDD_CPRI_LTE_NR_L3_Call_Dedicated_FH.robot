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
${scfc_file}      CB009180_ABIP_2AHFII_2AHEH_FDD_CPRI_4T4R_6LNCEL_8NRCEL_Dedicated.xml

*** Test Cases ***
CB009180_D_TC20_Concurrent_ABIP_NR_FR1_FDD_CPRI_12cells_and_LTE_FDD_CPRI_12cells_dedicated_FH_L3call
    [Tags]    SMAwave    CB009180    CB009180_US20    Trunk    QL3
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB009180${/}${scfc_file}    5min    600
    Perform NR Cell block 1,8,9,11,3,10,12 via AdminCLI
    Perform 4G Cell block 4,7,6,8,11 via AdminCLI
    Run Keyword And Continue On Failure    SMAwave L3 call    10    100M    50M    10%    4G    3    UE_1    600
    Run Keyword And Continue On Failure    SMAwave L3 call    13    200M    36M    15%    5G    66    UE_4
    Perform NR Cell Unblock 1,8,9,11,3,10,12 via AdminCLI
    Perform 4G Cell unblock 4,7,6,8,11 via AdminCLI
