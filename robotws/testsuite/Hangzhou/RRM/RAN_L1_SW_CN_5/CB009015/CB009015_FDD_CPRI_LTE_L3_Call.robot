*** Settings ***
Documentation
...    Author:  Chen Qian
...    Contact: qian.2.chen@nokia-sbell.com
...    Feature: CB009015
...    Release: 23R2
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot
Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    1908    9298    4001
${scfc_file}      CB009015_ABIP_5AHCA_FDD_CPRI_4T4R_16LNCEL.xml

*** Test Cases ***
CB009015_A_US04_ABIP_LTE_FDD_CPRI_L3Call_with_16_4T4R_10M_Cells_in_One_L1Pool_trunk
    [Tags]    QC_452657    SMAwave    CB009015    Trunk   QL3
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB009015${/}${scfc_file}
    SMAwave L3 call    3    30M    10M    10%    4G    3    UE_1

CB009015_A_US04_ABIP_LTE_FDD_CPRI_L3Call_with_16_4T4R_10M_Cells_in_One_L1Pool_branch
    [Tags]    SMAwave    CB009015    Branch   QL3    QC_538350
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB009015${/}${scfc_file}
    SMAwave L3 call    3    30M    10M    10%    4G    3    UE_1
