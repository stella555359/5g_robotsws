*** Settings ***
Documentation
...    Author:  Kong liang
...    Feature: Robustness

Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../../resources/common_resources.robot
Force Tags    5G_RAN_TDD    QL3    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}
${cellband}    77
${scfc_file_WMP_ORAN}    Robustness_ABIP_AWHQN_WMP_ORAN_1x4D4U_NR_cells.xml

${repeat_number}    10

*** Test Cases ***
Robustness_TC21_NR_FR1_TDD_eCPRI_ABIP_AWHQN_WMP_ORAN_Site_Reset
    [Tags]    ABIP    SMAwave    Robustness    SiteReset    Trunk    QL3    WMP_ORAN    TC21
    &{swconfig_flags}    Create Dictionary    0x420088=1    0x750000=1
    modify swconfig file    ${swconfig_flags}
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/Robustness/${btsid}/${scfc_file_WMP_ORAN}
    FOR    ${item}    IN RANGE    ${repeat_number}
        Site Reset Via WebUI
        Log To Console    \n[INFO] Round-${item+1} Site resetting ...
        Sleep    120s
        Wait Until Keyword Succeeds    15 min    30 sec    Check If All Cells Are OnAir
        SMAwave L3 call    cell_id=84    dl_tput=1200M    ul_tput=100M    dl_deviation=10%    rat=5G    band=${cellband}
    END
