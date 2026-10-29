*** Settings ***
Documentation
...    Author:  zefang.xu
...    Contact: zefang.xu@nokia-sbell.com
...    Feature: CB010543
...    Release: 24R1
...    for CB010543-A Only NR FDD NB 12cells and TDD 100MHz 2cells on CRT testline
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot
Force Tags    5G_RAN_FDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    7116    2922
${scfc_file}      CB010543_A_ABIQ_AKQL_2AHFII_2AHEH_FDD_CPRI_NB_12NRCEL_TDD_2NRCEL.xml

*** Test Cases ***
CB010543_A_TC07_NR_FR1_Concurrent_ABIQ_FDD_CPRI_NB_12cells_With_TDD_eCPRI_BF_cells_With_dedicated_FH_L3call
    [Tags]    SMAwave    CB010543    Trunk    ABIQ    QL3
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB010543${/}${scfc_file}    15min    600
    Perform NR Cell block 1,2,12,11 via AdminCLI
    Run Keyword And Continue On Failure    SMAwave L3 call    10    180M    90M    10%    5G    78    UE_3
    Run Keyword And Continue On Failure    SMAwave L3 call    3    80M    70M    20%    5G    66    UE_4
    Perform NR Cell Unblock 1,2,12,11 via AdminCLI
