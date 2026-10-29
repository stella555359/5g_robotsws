*** Settings ***
Documentation
...    Author:  Sun, Ya
...    Contact: ya.1.sun@nokia-sbell.com
...    Feature: CB005973
...    Release: 23R1
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot
Force Tags    4G_RAN_FDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    49    Cell blocked
${scfc_file}         CB005973_A.xml

*** Test Cases ***

CB005973_A_TC18_Concurrent_ABIN_NR_LTE_FDD_CPRI_shared_FH_3LTE_3NR_20M_L3call
    [Tags]    CRT    Trunk    CB005973    CB005973_US18
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB005973${/}CB005973_A.xml
    Perform NR Cell block 12,13 via AdminCLI
    Perform 4G Cell block 2,3,4,5,6 via AdminCLI
    SMAwave L3 call with IQ capture    180125707    70M    30M    10%    5G    71
    SMAwave L3 call    1    34M    25M    10%    4G    71
    Perform NR Cell unblock 12,13 via AdminCLI
    Perform 4G Cell unblock 2,3,4,5,6 via AdminCLI

CB005973_B_TC16_Concurrent_ABIN_NR_LTE_FDD_CPRI_dedicated_FH_3LTE_6NR_reset
    [Tags]    CRT    Trunk    CB005973    CB005973_US16
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB005973${/}CB005973_B.xml
    Reset BBMODs     2
    sleep    120s
    Wait Until Keyword Succeeds    2min    30s    Check If All Cells Are OnAir
    Perform NR Cell block 1,2,3,5,6 via AdminCLI
    Perform 4G Cell block 7,8,9 via AdminCLI
    SMAwave L3 call    180125700    150M    70M    10%    5G    71
    Perform 4G Cell unblock 7 via AdminCLI
    SMAwave L3 call    7    34M    25M    10%    4G    71
    Perform NR Cell unblock 1,2,3,5,6 via AdminCLI
    Perform 4G Cell unblock 8,9 via AdminCLI

*** Keywords ***
SMAwave L3 call with IQ capture
    [Arguments]    ${cell_id}    ${dl_tput}    ${ul_tput}    ${dl_deviation}    ${rat}    ${band}=41    ${specific_UE_index}=${EMPTY}
    ...    ${duration}=600    ${protocol}=udp
    SMAwave UE attach    ${rat}    ${cell_id}    ${band}    ${specific_UE_index}
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${duration}

    ${abin_r_id}    Get BBMOD ID    ABIN_R
    Set Test Variable    ${abin_r_id}
    ${ul_subcell_index_list}=    Create List    [${abin_r_id}(ABIN)] [PCI: 445]${72a_flag}NRCELL-11: Subcell 2
    ${dl_subcell_index_list}=    Create List    [${abin_r_id}(ABIN)] [PCI: 445]${72a_flag}NRCELL-11: Subcell 2

    Configure IQ capture via webUI    ul_subcell_index_list=${ul_subcell_index_list}    dl_subcell_index_list=${None}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Event    capture_from=BBU
    ...    profile_prefix=${None}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}
    ADMIN Set RAD debug parameters    NrUlPhy    phyEventEnableExt    2147483648
    ADMIN Set RAD debug parameters    LteUlPhy    phyEventEnableExt    2147483648

    SMAwave Verify throughput for DL and UL    ${dl_tput}    ${ul_tput}    ${dl_deviation}    ${rat}

    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    1min    30s    Check Event Trigger Is Successed
    Save Snapshot Via WebUI
    Disable IQ capture via webUI

    Configure IQ capture via webUI    ul_subcell_index_list=${None}    dl_subcell_index_list=${dl_subcell_index_list}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Event    capture_from=BBU
    ...    profile_prefix=${None}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}
    ADMIN Set RAD debug parameters    NrDlPhy    dlPhyEventEnable    1
    ADMIN Set RAD debug parameters    LteDlPhy    dlPhyEventEnable    256

    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    1min    30s    Check Event Trigger Is Successed
    Save Snapshot Via WebUI
    Disable IQ capture via webUI

    [Teardown]    SMAwave Stop Data And Detach

Check Event Trigger Is Successed
    ${event_count}    Get Event Trigger Count on BBMOD    bsh ${abin_r_id.split('-')[-1]}:1    NR
    Should Be True    ${event_count}>0    [ERROR]Event Trigger Count not large than zero
