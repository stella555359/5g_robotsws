*** Settings ***
Documentation
...    Author:  Yanqing Li
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
${cellband}    78

${scfc_file_16DL_2eCPRI_72e}    CB010630_D_ABIP_AVQL_NRTDD_50M_A1_4xNRCELL_72e_16D4U_16D2U_8D4U_4D2U_2xeCPRI.xml

*** Test Cases ***
Robustness_TC07_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_Cell_Online_Deletion_Addition
    [Tags]    ABIP    Robustness    Trunk    QL3Weekly    CellDelAdd    TC07
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/Robustness/${btsid}/${scfc_file_16DL_2eCPRI_72e}
    Repeat Keyword    2 hour    cell_deletion_then_addition

*** Keywords ***

cell_deletion_then_addition
    online cell deletion for NR    1    0

    ${cell_info}    Create Dictionary    cell_id=1    lcrId=1    cell_group_id=0    nrarfcn=630954
    ...    gscnOrSsPbchArfcn=2    physCellId=311    type0CoresetConfigurationIndex=12
    ...    prachConfigurationIndex=195    cell_id_to_copy_from=2    cell_grp_id_to_copy_from=1    duplex=TDD

    Online Add Cell Based On Existing Cell     ${cell_info}
    Wait Until Keyword Succeeds     200s    20s    Check If All Cells Are OnAir
    Perform NR Cell block 2,3,4 via AdminCLI
    SMAwave L3 call    182648833    ${tp_with_50M['DLTP']}    ${tp_with_50M['ULTP']}    10%    5G    78    duration=60
    Perform NR Cell unblock 2,3,4 via AdminCLI
