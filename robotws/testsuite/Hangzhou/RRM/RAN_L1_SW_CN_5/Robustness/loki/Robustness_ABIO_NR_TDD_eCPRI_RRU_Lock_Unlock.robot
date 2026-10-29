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
&{tp_with_100M}    DLTP=600M    ULTP=80M
&{tp_with_50M}    DLTP=350M    ULTP=40M
&{tp_with_20M}    DLTP=140M    ULTP=16M
&{tp_with_diff_chbw}    100MHz=&{tp_with_100M}    50MHz=&{tp_with_50M}    20MHz=&{tp_with_20M}

${cellband}    41

${scfc_file_1cell}      scf_BTS10420_ABIO_AEHC_TDD_eCPRI_1x16DL8UL_NR_cells.xml

${repeat_number}    10

${ue_index}    UE_1

*** Test Cases ***
Robustness_TC10_NR_FR1_TDD_eCPRI_ABIO_RRU_Lock_Unlock
    [Tags]    ABIO    Robustness    Trunk    QL3    rrublock    cgao
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Robustness${/}${scfc_file_1cell}
    RU lock and unlock ${repeat_number} times make L3 call

*** Keywords ***
RU lock and unlock ${num} times make L3 call
    FOR    ${id}    IN RANGE    ${num}
        RU lock and unlock for gnb    ru_index=1
        SMAwave L3 call    cell_id=1    dl_tput=${tp_with_100M['DLTP']}    ul_tput=${tp_with_100M['ULTP']}
        ...    dl_deviation=10%    rat=5G    band=${cellband}    specific_UE_index=${ue_index}    duration=60
    END

RU lock and unlock for gnb
    [Arguments]    ${ru_index}=1
    5G RMOD Operation via WebUI    locked    ${ru_index}
    5G RMOD Operation via WebUI    unlocked    ${ru_index}
    Wait Until Keyword Succeeds    300 min    30 sec    Check If All Cells Are OnAir
