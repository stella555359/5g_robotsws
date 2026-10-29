*** Settings ***
Documentation
...    Author:  Ya.1.sun
...    Contact: ya.1.sun@nokia-sbell.com
...    Feature: CNI-94379
...    Release: 23R4
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot
Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    7102    49    7116    2922
${scfc_file}      CNI_94379_ABIP_AKQJ_NRTDD_1xNRCELL.xml

*** Test Cases ***
CNI94379_TC03_NR_FR1_TDD_eCPRI_ABIP_cell_Response_message_collection_together_with_Blind_IQ_data_with_ABIP
    [Tags]    SMAwave    CNI_94379    CNI_94379_US03    Trunk    QL3
    Append To List    ${L1_WRN_whitelist}    SYSCOM STATE_CHANGE_NOTIF    HLAPI Already created static HOs, not doing it again
    ...    handle_client_msg_int
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CNI_94379${/}${scfc_file}    15min    600
    SMAwave L3 call with 5G blind IQ capture    0M    40M    5G    78    UE_3
    SMAwave L3 call with 5G event IQ capture    0M    40M    5G    78    UE_3
    [Teardown]    Run Keywords    common_resource_suite.Common Test Teardown
    ...    AND    Remove Values From List    ${L1_WRN_whitelist}    SYSCOM STATE_CHANGE_NOTIF
    ...    HLAPI Already created static HOs, not doing it again    handle_client_msg_int


*** Keywords ***
SMAwave L3 call with 5G blind IQ capture
    [Arguments]    ${dl_tput}    ${ul_tput}    ${rat}    ${band}    ${specific_UE_index}=${EMPTY}
    ...    ${duration}=600    ${protocol}=udp
    SMAwave UE attach    rat=${rat}    cell_id=None    band=${band}    specific_UE_index=${specific_UE_index}
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${duration}
    ${params}=     set variable   69:895
    ADMIN Change Bts Rad Parameters    128    ${params}
    ${ul_subcell_index_list}=    Create List    [BBMOD_R-1(ABIP)] [PCI: 11]${72a_flag}NRCELL-11: Subcell 0
    Configure IQ capture via webUI    ul_subcell_index_list=${ul_subcell_index_list}    dl_subcell_index_list=${None}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Blind    capture_from=BBU
    ...    profile_prefix=${None}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}
    Sleep    60s
    Save IQ capture data via webUI
    [Teardown]    SMAwave Stop Data And Detach


SMAwave L3 call with 5G event IQ capture
    [Arguments]    ${dl_tput}    ${ul_tput}    ${rat}    ${band}    ${specific_UE_index}=${EMPTY}
    ...    ${duration}=600    ${protocol}=udp
    SMAwave UE attach    rat=${rat}    cell_id=None    band=${band}    specific_UE_index=${specific_UE_index}
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${duration}
    ${params}=     set variable   69:895
    ADMIN Change Bts Rad Parameters    128    ${params}
    ${ul_subcell_index_list}=    Create List    [BBMOD_R-1(ABIP)] [PCI: 11]${72a_flag}NRCELL-11: Subcell 0
    Configure IQ capture via webUI    ul_subcell_index_list=${ul_subcell_index_list}    dl_subcell_index_list=${None}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Event    capture_from=BBU
    ...    profile_prefix=${None}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}
    ADMIN Set RAD debug parameters    NrUlPhy    phyEventEnableExt    3758096399
    # Wait Until Keyword Succeeds    2min    30s    Check Event Trigger Count
    Save Snapshot Via WebUI
    ADMIN Reset All Rad Debug Parameters
    ADMIN Set RAD debug parameters    NrUlPhy    phyEventEnableExt    536870927
    # Wait Until Keyword Succeeds    2min    30s    Check Event Trigger Count
    Save Snapshot Via WebUI
    ADMIN Reset All Rad Debug Parameters
    ADMIN Set RAD debug parameters    NrUlPhy    phyEventEnableExt    1073750000
    # Wait Until Keyword Succeeds    2min    30s    Check Event Trigger Count
    Save Snapshot Via WebUI
    Sleep    60s
    [Teardown]    SMAwave Stop Data And Detach

Check Event Trigger Count
    ${count}    Get Event Trigger Count on BBMOD    bsh 1:1    NR
    Should Be True    ${count}>0    [ERROR]Event is NOT Triggered: count=${count}.
