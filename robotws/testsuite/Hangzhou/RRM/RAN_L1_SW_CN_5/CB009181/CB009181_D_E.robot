*** Settings ***
Documentation
...    Author:  zefang.xu
...    Contact: zefang.xu@nokia-sbell.com
...    Feature: CB009181
...    Release: 23R4
...    for CB009181-D Only NR FDD WB 2cells NB 4cell and TDD 100MHz 2cells on CRT testline
...    for CB009181-E Only NR FDD NB 9cells and TDD supercell on CRT testline
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot
Force Tags    5G_RAN_FDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    7116    2922    49
${scfc_file_D}      CB009181_D_ABIP_AKQL_2AHFII_2AHEH_FDD_CPRI_WB_NB_6NRCEL_TDD_2NRCEL.xml
${scfc_file_E}      CB009181_E_ABIP_AKQL_2AHFII_2AHEH_FDD_CPRI_NB_9NRCEL_TDD_supercell.xml

*** Test Cases ***
CB009181_D_TC10_NR_FR1_Concurrent_ABIP_FDD_CPRI_WB_NB_mixing_6cells_With_TDD_eCPRI_BF_cells_With_dedicated_FH_block_unblock
    [Tags]    SMAwave    CB009181    CB009181_US10    Trunk    QL3
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB009181${/}${scfc_file_D}    15min    600
    Perform NR Cell block 1,2,3,4,5,6,10,11 via AdminCLI
    Perform NR Cell Unblock 1,10 via AdminCLI
    Run Keyword And Continue On Failure    SMAwave L3 call    10    150M    90M    10%    5G    78    UE_3
    Run Keyword And Continue On Failure    SMAwave L3 call    1    150M    90M    10%    5G    66    UE_4
    Perform NR Cell Unblock 2,3,4,5,6,11 via AdminCLI

CB009181_E_TC02_NR_FR1_Concurrent_ABIP_FDD_CPRI_NB_9cells_With_TDD_eCPRI_Super_cell_with_dedicated_FH_L3call
    [Tags]    SMAwave    CB009181    CB009181_US02    Trunk    QL3
    Append To List    ${L1_WRN_whitelist}    SYSCOM STATE_CHANGE_NOTIF    HLAPI Already created static HOs, not doing it again
    ...    handle_client_msg_int
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB009181${/}${scfc_file_E}    15min    600
    Perform NR Cell block 1,2,4,5,6 via AdminCLI
#    Run Keyword And Continue On Failure    SMAwave L3 call    10    180M    90M    10%    5G    78    UE_3
    Run Keyword And Continue On Failure    SMAwave L3 call    10    180M    60M    10%    5G    78    UE_3
    Run Keyword And Continue On Failure    SMAwave L3 call    3    180M    70M    10%    5G    66    UE_4
    Perform NR Cell Unblock 1,2,4,5,6 via AdminCLI
    [Teardown]    Run Keywords    common_resource_suite.Common Test Teardown
    ...    AND    Remove Values From List    ${L1_WRN_whitelist}    SYSCOM STATE_CHANGE_NOTIF    HLAPI Already created static HOs, not doing it again
    ...    handle_client_msg_int
