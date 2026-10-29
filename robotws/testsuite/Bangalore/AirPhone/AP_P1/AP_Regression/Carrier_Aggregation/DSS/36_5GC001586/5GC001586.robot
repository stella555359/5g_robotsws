*** Settings ***

Documentation     author: Himanshu Singh
...               contact: himanshu.3.singh@nokia.com
...               Description:

Resource        ../../DSS_Common_Keywords.robot

Suite Setup       Suite Setup    feature_folder=5GC001586

*** Variables ***
${NUMBER_OF_CELLS}                   1
${WTS_CFG_PATH}                      ${CURDIR}/../../Config_Files/36_5GC001586/wts
${dl_tput}                           10
${ul_tput}                           10
@{DSS_NSA_UE}                        1
@{noofcells}                         1
@{target_cell}                       1
${assigned_dl_minimum_share_to_nr}   15
${assigned_dl_maximum_share_to_nr}   70
@{logical_cell_list}                 1
${dl_norsubframes}                   0011101110-0111101110-0011101110-0111101110-0011101110-0111101110-0011101110-0111101110
${ul_allocated_prb_list}             0,3|10,52|49,3

*** Test Cases ***
5GC001586_TC1 NSA_DSS Verify Tput for DSS Phase 2
    [Documentation]    Verify Tput for DSS Phase 2
    [Tags]    AP_REG    1586_TC1_NSA_DSS
    [Setup]    Test setup for DSS Phase2    ${noofcells}    ${target_cell}    ${logical_cell_list}    ${assigned_dl_minimum_share_to_nr}
    ...    ${assigned_dl_maximum_share_to_nr}    ${dl_norsubframes}    ${ul_allocated_prb_list}
    Attach and Start Traffic For NSA UEs    nsa_ue_list=${DSS_NSA_UE}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    ...    target_cells=1
    Validate Bearer Stats for multiple UEs    ue_list=${DSS_NSA_UE}    expected_dl_tput=${dl_tput}    expected_ul_tput=${ul_tput}
    ...    mode=NSA
    Stop Traffic and Detach NSA UEs    ${DSS_NSA_UE}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    ${DSS_NSA_UE}
    [Teardown]    Test Teardown    nsa_ue_list=${DSS_NSA_UE}
