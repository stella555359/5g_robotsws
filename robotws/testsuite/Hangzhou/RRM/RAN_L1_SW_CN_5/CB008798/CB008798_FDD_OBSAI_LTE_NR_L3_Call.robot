*** Settings ***
Documentation
...    Author:  claire.gao@nokia-sbell.com

Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot
Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    49    Cell blocked
${scfc_file_obsai}      CB008798_ABIO_FRHG_FDD_OBSAI_4NRCEL_4T4R_5LNCEL_2T2R.xml
${scfc_file_mix}        CB008798_ABIO_FRHG_AHLOA_FDD_OBSAI_CPRI_4NRCEL_4T4R_5LNCEL_2T2R.xml
${5G_Cell_id_348}    180125699
${5G_Cell_id_546}    180125698
${5G_Cell_id_400}    180125700
${4G_Global_Cell_id_14}    6

*** Test Cases ***
CB008798_C_B4_TC06_Concurrent_ABIO_NR_LTE_FDD_OBSAI_Cells_Shared_Radiolink_with_IQ_Forwarding_5G_4G_L3_Call
    [Tags]    LOKI    SMAwave    Trunk    CB008798    CB008798_US06
    modify_scfc_and_perform_full_commission    ${scfc_file_obsai}
    Perform NR Cell Block 5 via AdminCLI
    Perform 4G Cell block 2,6,7 via AdminCLI
    SMAwave L3 call    ${5G_Cell_id_348}    130M    80M    10%    5G    7
    Perform 4G Cell unblock 6 via AdminCLI
    Perform NR Cell Block 3 via AdminCLI
    SMAwave L3 call    ${4G_Global_Cell_id_14}    110M    48M    10%    4G    7

CB008798_C_B4_TC15_Concurrent_ABIO_NR_LTE_FDD_OBSAI_CPRI_Mixed_Cells_Shared_Radiolink_with_IQ_Forwarding_5G_4G_L3_Call
    [Tags]    LOKI    SMAwave    Trunk    CB008798    CB008798_US15
    modify_scfc_and_perform_full_commission    ${scfc_file_mix}
    Perform NR Cell Block 1,4 via AdminCLI
    Perform 4G Cell block 1,2,5 via AdminCLI
    SMAwave L3 call    ${5G_Cell_id_546}    60M    30M    10%    5G    7
    Perform NR Cell unblock 4 via AdminCLI
    Perform NR Cell Block 2 via AdminCLI
    SMAwave L3 call    ${5G_Cell_id_400}    110M    60M    10%    5G    71
    Perform 4G Cell unblock 1,2,5 via AdminCLI


*** Keywords ***
modify_scfc_and_perform_full_commission
    [Arguments]    ${scfc_file}
    ${scfc_path}=    Set Variable    ${SCFC_path}${/}CB008798${/}${scfc_file}
    Full Commission gNB SCFC and wait for onair    ${scfc_path}
