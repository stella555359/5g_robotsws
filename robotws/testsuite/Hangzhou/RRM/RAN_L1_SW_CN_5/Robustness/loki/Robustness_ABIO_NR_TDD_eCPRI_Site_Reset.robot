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
@{ALLOWED_FAULT}
&{tp_with_100M}    DLTP=700M    ULTP=80M
&{tp_with_50M}    DLTP=350M    ULTP=40M
&{tp_with_20M}    DLTP=140M    ULTP=16M
&{tp_with_diff_chbw}    100MHz=&{tp_with_100M}    50MHz=&{tp_with_50M}    20MHz=&{tp_with_20M}

${cellband}    41

${scfc_file_3cells}      scf_BTS10420_ABIO_AEHC_TDD_eCPRI_3x16DL8UL_NR_cells.xml

${repeat_number}    10

${ue_index}    UE_1

*** Test Cases ***
Robustness_TC13_NR_FR1_TDD_eCPRI_ABIO_Site_Reset
    [Tags]    ABIP    SMAwave    Robustness    SiteReset    Trunk    QL3    yaqin
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Robustness${/}${scfc_file_3cells}
    FOR    ${item}    IN RANGE    ${repeat_number}
        Site Reset Via WebUI
        Log To Console    \n[INFO] Round-${item+1} Site resetting ...
        Sleep    120s
        Wait Until Keyword Succeeds    300 min    30 sec    Check If All Cells Are OnAir
        SMAwave L3 call    180125707    ${tp_with_20M['DLTP']}    ${tp_with_20M['ULTP']}    10%    5G    41    ${ue_index}
    END
