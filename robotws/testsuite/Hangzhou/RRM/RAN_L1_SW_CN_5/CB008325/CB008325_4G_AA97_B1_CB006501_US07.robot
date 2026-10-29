*** Settings ***
Documentation
...    Author:  Xu Zefang
...    Contact: zefang.xu@nokia-sbell.com
...    Feature: CB008325_CB006501
...    Release: 23R1
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot
Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}
${scfc_file_TC07}    CB008325_AA97_ABIP_3AHCA_LTE_FDD_CPRI_3LNCELL_2T2R.xml

${pb_bts}     10.108.228.17
${pb_rru1}    10.108.228.21
${pb_rru2}    10.108.228.21

*** Test Cases ***
CB008325_4G_AA97_B1_CB006501_US07_ABIP_LTE_FDD_CPRI_Basic_UL_Comp_2RX_Cells_runtime_Activation_trunk
    [Tags]    CB008325    QC_417393    QL3    Trunk
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008325${/}${scfc_file_TC07}
    perform delta scf recommission    ${SCFC_path}${/}CB008325${/}actulcomp.json
    Adjust HBTE attenuation values    10.108.228.28    5:35; 6:35; 7:35; 8:35; 9:40; 10:40; 11:40; 12:40
    SMAwave UE attach    rat=4G    cell_id=None    band=5
    SMAwave Start Data Traffic    110M    50M
    ${comp_counter_file}    get PM counter file    3
    Set test Variable    ${comp_counter_file}
    SMAwave Stop Data And Detach
    check PM counter value
    [Teardown]    Adjust HBTE attenuation values    10.108.228.28    5:30; 7:30; 7:30; 8:30; 9:30; 10:30; 11:30; 12:30

CB008325_4G_AA97_B1_CB006501_US07_ABIP_LTE_FDD_CPRI_Basic_UL_Comp_2RX_Cells_runtime_Activation_branch
    [Tags]    CB008325    QC_538346    QL3    Branch
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008325${/}${scfc_file_TC07}
    perform delta scf recommission    ${SCFC_path}${/}CB008325${/}actulcomp.json
    Adjust HBTE attenuation values    10.108.228.28    5:35; 6:35; 7:35; 8:35; 9:40; 10:40; 11:40; 12:40
    SMAwave UE attach    rat=4G    cell_id=None    band=5
    SMAwave Start Data Traffic    110M    50M
    ${comp_counter_file}    get PM counter file    3
    Set test Variable    ${comp_counter_file}
    SMAwave Stop Data And Detach
    check PM counter value
    [Teardown]    Adjust HBTE attenuation values    10.108.228.28    5:30; 7:30; 7:30; 8:30; 9:30; 10:30; 11:30; 12:30

*** Keywords ***
check PM counter value
    ${cell1_comp_counter_M8051C119}=    get_counter_value_from_counter_file   ${comp_counter_file}    M8051C119    1
    ${cell1_comp_counter_M8011C230}=    get_counter_value_from_counter_file   ${comp_counter_file}    M8011C230    1
    ${cell1_comp_ULThroughput}=    get_counter_value_from_counter_file   ${comp_counter_file}    M8012C23    1
    should_be_true    ${cell1_comp_counter_M8051C119}>=92
    should_be_true    ${cell1_comp_counter_M8011C230}>=40000
    should_be_true    ${cell1_comp_ULThroughput}>0
