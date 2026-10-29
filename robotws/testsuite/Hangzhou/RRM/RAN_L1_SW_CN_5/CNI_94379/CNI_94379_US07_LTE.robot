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
Force Tags    4G_RAN_FDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    7102    49    7116    2922
${scfc_file}      CNI_94379_ABIP_AHFII_LTEFDD_1xLTECELL.xml

*** Test Cases ***
CNI94379_TC07_LTE_FDD_CPRI_ABIP_cell_Response_message_collection_together_with_Blind_IQ_data_with_ABIP
    [Tags]    SMAwave    CNI_94379    CNI_94379_US07    Trunk    QL3    SY
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CNI_94379${/}${scfc_file}    15min    600
    SMAwave L3 call with 4G blind IQ capture    2    0M    60M    4G    66    UE_2
    SMAwave L3 call with 4G event IQ capture    2    0M    60M    4G    66    UE_2

*** Keywords ***
SMAwave L3 call with 4G blind IQ capture
    [Arguments]    ${cell_id}    ${dl_tput}    ${ul_tput}    ${rat}    ${band}    ${specific_UE_index}=${EMPTY}
    ...    ${duration}=600    ${protocol}=udp
    SMAwave UE attach    rat=${rat}    cell_id=None    band=${band}    specific_UE_index=${specific_UE_index}
    ${lte_ul_cell_ids}=    Create List    LNCEL-${cell_id}
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${duration}
    ${params}=     set variable   46:2147483648
    ADMIN Change Bts Rad Parameters    130    ${params}
    Configure IQ capture via webUI    ul_subcell_index_list=${None}    dl_subcell_index_list=${None}
    ...    lte_ul_cell_ids=${lte_ul_cell_ids}    lte_dl_cell_ids=${lte_ul_cell_ids}    enable_capture_on=Blind    capture_from=BBU
    ...    profile_prefix=${None}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}
    sleep    60s
    Save IQ capture data via webUI
    [Teardown]    SMAwave Stop Data And Detach

SMAwave L3 call with 4G event IQ capture
    [Arguments]    ${cell_id}    ${dl_tput}    ${ul_tput}    ${rat}    ${band}    ${specific_UE_index}=${EMPTY}
    ...    ${duration}=600    ${protocol}=udp
    SMAwave UE attach    rat=${rat}    cell_id=None    band=${band}    specific_UE_index=${specific_UE_index}
    ${lte_ul_cell_ids}=    Create List    LNCEL-${cell_id}
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${duration}
    ${params}=     set variable   46:262143
    ADMIN Change Bts Rad Parameters    130    ${params}
    Configure IQ capture via webUI    ul_subcell_index_list=${None}    dl_subcell_index_list=${None}
    ...    lte_ul_cell_ids=${lte_ul_cell_ids}    lte_dl_cell_ids=${lte_ul_cell_ids}    enable_capture_on=Event    capture_from=BBU
    ...    profile_prefix=${None}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}
    ADMIN Set RAD debug parameters    LteUlPhy    phyEventEnableExt    3758096399
    # Wait Until Keyword Succeeds    20min    60s    Check Event Trigger Count
    Save Snapshot Via WebUI
    Sleep    60s
    [Teardown]    Run Keywords    SMAwave Stop Data And Detach    AND    Run Keyword And Ignore Error    Disable IQ capture via webUI

Check Event Trigger Count
    ${count}    Get Event Trigger Count on BBMOD    bsh 1:1    LTE
    Should Be True    ${count}>0    [ERROR]Event is NOT Triggered: count=${count}.
