*** Settings ***
Documentation
...    Author:  Chen Qian
...    Contact: qian.2.chen@nokia-sbell.com
...    Feature: CB009027_CB008609
...    Release: 23R2
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot
Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    1908    9298    4001
${scfc_file_TC02}    CB009027_CB008609_ABIP_5AHCA_LTE_FDD_CPRI_12LNCELL_4T4R.xml

*** Test Cases ***
CB009027_4G_G1_CB008609_US02_ABIP_LTE_FDD_CPRI_L3Call_with_12_4T4R_20M_10M_Cells_in_One_L1Pool_trunk
    [Tags]    CB009027    QC_452658    QL3    Trunk
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB009027${/}${scfc_file_TC02}
    Perform 4G Cell block 9,12 via AdminCLI
    SMAwave L3 call    3    30M    10M    10%    4G    3    UE_1
    Perform 4G Cell unblock 9,12 via AdminCLI

CB009027_4G_G1_CB008609_US02_ABIP_LTE_FDD_CPRI_L3Call_with_12_4T4R_20M_10M_Cells_in_One_L1Pool_branch
    [Tags]    CB009027    QC_538355   QL3    Branch
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB009027${/}${scfc_file_TC02}
    Perform 4G Cell block 9,12 via AdminCLI
    SMAwave L3 call    3    30M    10M    10%    4G    3    UE_1
    Perform 4G Cell unblock 9,12 via AdminCLI
