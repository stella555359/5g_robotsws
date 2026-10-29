*** Settings ***
Documentation
...    Author:  Yu Yaqin
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

${scfc_file_3cells}      scf_BTS10420_ABIO_AEHC_TDD_eCPRI_3x16DL8UL_NR_cells_Online_Deletion_Addition.xml

${ue_index}    UE_1

*** Test Cases ***
Robustness_TC14_NR_FR1_TDD_eCPRI_ABIO_Cell_Online_Deletion_Addition
    [Tags]    ABIO    Robustness    Trunk    QL3    CellDelAdd
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Robustness${/}${scfc_file_3cells}
    Repeat Keyword    2 hour    cell_deletion_then_addition

*** Keywords ***

cell_deletion_then_addition
    online cell deletion for NR    1    0

    ${cell_info}    Create Dictionary    cell_id=1    lcrId=1    cell_group_id=0    nrarfcn=509202
    ...    gscnOrSsPbchArfcn=1    physCellId=100    type0CoresetConfigurationIndex=12
    ...    prachConfigurationIndex=98    cell_id_to_copy_from=3    cell_grp_id_to_copy_from=2    duplex=TDD

    Online Add Cell Based On Existing Cell     ${cell_info}
    Wait Until Keyword Succeeds     200s    20s    Check If All Cells Are OnAir
    Perform NR Cell block 2,3 via AdminCLI
    SMAwave L3 call    180125707    ${tp_with_20M['DLTP']}    ${tp_with_20M['ULTP']}    10%    5G    41    ${ue_index}
    Perform NR Cell unblock 2,3 via AdminCLI
