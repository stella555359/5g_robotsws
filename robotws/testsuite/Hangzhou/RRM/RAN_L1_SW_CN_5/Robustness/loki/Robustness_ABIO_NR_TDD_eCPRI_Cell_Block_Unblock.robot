*** Settings ***
Documentation
...    Author:  Hou Yuguo
...    Feature: Robustness
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../../resources/common_resources.robot
Force Tags    5G_RAN_TDD    QL3    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    49
&{tp_with_100M}    DLTP=700M    ULTP=80M
&{tp_with_50M}    DLTP=350M    ULTP=40M
&{tp_with_20M}    DLTP=140M    ULTP=16M
&{tp_with_diff_chbw}    100MHz=&{tp_with_100M}    50MHz=&{tp_with_50M}    20MHz=&{tp_with_20M}

${cellband}    41

${scfc_file_3cells}      scf_BTS10420_ABIO_AEHC_TDD_eCPRI_3x16DL8UL_NR_cells.xml

${repeat_number}    10

${ue_index}    UE_1

*** Test Cases ***
Robustness_TC11_NR_FR1_TDD_eCPRI_ABIO_Cell_Block_Unblock
    [Tags]    ABIO    Robustness    Trunk    QL3    CellBlock    cgao
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Robustness${/}${scfc_file_3cells}
    ${cell_id_dict}    Get id From NR Cells
    ${cell_chbw_dict}    Get chBw From NR Cells
    ${cell_global_cell_id_list}    Get Dictionary Keys    ${cell_id_dict}
    Set Test Variable    ${cell_global_cell_id_list}
    Set Test Variable    ${cell_chbw_dict}
    Repeat Keyword    1 hours    Ue Attach to cell and data traffic

*** Keywords ***
Ue Attach to cell and data traffic
    Perform NR Cell block ${cell_global_cell_id_list} via AdminCLI
    ${random_cell_id}    Random Choice Cell Id
    Perform NR Cell unblock ${random_cell_id} via AdminCLI
    ${chbw}    Set Variable    ${cell_chbw_dict[${random_cell_id}]}
    ${dl_ul_tp_dict}    Set Variable    ${tp_with_diff_chbw['${chbw}']}
    Wait Until Keyword Succeeds    80s    20s    Check If Specific Cell Is OnAir    ${random_cell_id}
    SMAwave L3 call    cell_id=${random_cell_id}    dl_tput=${dl_ul_tp_dict['DLTP']}    ul_tput=${dl_ul_tp_dict['ULTP']}
    ...    dl_deviation=10%    rat=5G    band=${cellband}    specific_UE_index=${ue_index}    duration=60
    Perform NR Cell block ${random_cell_id} via AdminCLI
    Perform NR Cell unblock ${cell_global_cell_id_list} via AdminCLI
    Wait Until Keyword Succeeds     200s    20s    Check If All Cells Are OnAir

Random Choice Cell Id
    ${selected_cell}      Evaluate    random.choice(${cell_global_cell_id_list})    random
    [Return]    ${selected_cell}
