*** Settings ***
Documentation
...    Author:  Claire.gao
...    Contact: claire.gao@nokia-sbell.com
...    Feature: CB009180
...    Release: 23R4
...    Only NR_FDD_CPRI_6cells_and_LTE_FDD_CPRI_6cells with supercells on CRT testline
...    Add one LTE supercell case in CB009180
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot
Force Tags    5G_RAN_FDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    1908    9298    4001    7102    49
${scfc_file}      CB009180_ABIP_2AHFII_2AHEH_FDD_CPRI_4T4R_6LNCEL_6NRCEL_Supercell.xml

*** Test Cases ***
CB009180_D_TC25_Concurrent_ABIP_NR_FR1_FDD_CPRI_12cells_and_LTE_FDD_CPRI_12cells_shared_FH_IQCapture
    [Tags]    SMAwave    CB009180    CB009180_US25    Trunk    QL3    Supercell
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB009180${/}${scfc_file}    5min    600
    Perform NR Cell block 1,9,3,2,11,7 via AdminCLI
    Perform 4G Cell block 5,6,3,2,0 via AdminCLI
    SMAwave L3 call with IQ capture    8    50M    30M    20%    4G    3    UE_1
    Perform NR Cell unblock 1,9,3,2,11,7 via AdminCLI
    Perform 4G Cell unblock 5,6,3,2,0 via AdminCLI

*** Keywords ***
SMAwave L3 call with IQ capture
    [Arguments]    ${cell_id}    ${dl_tput}    ${ul_tput}    ${dl_deviation}    ${rat}    ${band}=41    ${specific_UE_index}=${EMPTY}
    ...    ${duration}=900    ${protocol}=udp
    SMAwave UE attach    ${rat}    ${cell_id}    ${band}    ${specific_UE_index}
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${duration}
    ${Lte_ul_cell_list}=    Create List    LNCEL-8
    ${Lte_dl_cell_list}=    Create List    LNCEL-8
    Configure IQ capture via webUI    ul_subcell_index_list=${None}    dl_subcell_index_list=${None}
    ...    lte_ul_cell_ids=${Lte_ul_cell_list}    lte_dl_cell_ids=${Lte_dl_cell_list}    enable_capture_on=Blind    capture_from=BBU
    ...    profile_prefix=${None}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}
    Sleep    5s
    Save IQ capture data via webUI
    SMAwave Verify throughput for DL and UL    ${dl_tput}    ${ul_tput}    ${dl_deviation}    ${rat}
    [Teardown]    SMAwave Stop Data And Detach
