*** Settings ***
Documentation
...    Author:  yanqing.li
...    Contact: yanqing.li@nokia-sbell.com
...    Feature: CB010542
...    Release: 23R4
...    Only NR_FDD_CPRI_8cells_and_LTE_FDD_CPRI_6cells on CRT testline
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot
Force Tags    5G_RAN_FDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    1908    9298    4001    7102
${scfc_file}      CB010542_ABIP_2AHFII_2AHEH_FDD_CPRI_4T4R_6LNCEL_8NRCEL_Shared.xml

*** Test Cases ***
CB010542_D_TC06_Concurrent_ABIQ_NR_FR1_FDD_CPRI_NB_12cells_and_LTE_FDD_CPRI_12cells_shared_FH_L3call
    [Tags]    SMAwave    CB010542    Trunk    QL3    24R1    ABIQ
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB010542${/}${scfc_file}    15min    600
    Perform NR Cell block 1,9,3,2,11 via AdminCLI
    Perform 4G Cell block 5,6,3 via AdminCLI
    Run Keyword And Continue On Failure    SMAwave L3 call    2    120M    60M    10%    4G    66    UE_2
    Run Keyword And Continue On Failure    SMAwave L3 call    7    200M    40M    15%    5G    66    UE_4
    Perform NR Cell unblock 1,9,3,2,11 via AdminCLI
    Perform 4G Cell unblock 5,6,3 via AdminCLI
