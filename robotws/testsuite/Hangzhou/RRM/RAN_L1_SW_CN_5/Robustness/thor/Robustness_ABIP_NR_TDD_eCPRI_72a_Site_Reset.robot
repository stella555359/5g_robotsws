*** Settings ***
Documentation
...    Author:  Kong Liang
...    Feature: Robustness

Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../../resources/common_resources.robot
Force Tags    5G_RAN_TDD    QL3    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}
${cellband}    78

${scfc_file_72a}    ABIP_AVQL_NRTDD_50M_A1_gscn_630954_4xNRCELL_72a.xml

${repeat_number}    20

*** Test Cases ***
Robustness_TC15_NR_FR1_TDD_eCPRI_ABIP_AVQL_72a_Site_Reset
    [Tags]    ABIP    SMAwave    Robustness    SiteReset    Trunk    QL3    72a
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Robustness${/}${btsid}${/}${scfc_file_72a}
    FOR    ${item}    IN RANGE    ${repeat_number}
        # Site Reset Via WebUI
        Site Reset Via AdminCLI    False    True
        Log To Console    \n[INFO] Round-${item+1} Site resetting ...
        Sleep    120s
        Wait Until Keyword Succeeds    10 min    30 sec    Check If All Cells Are OnAir
        #SMAwave L3 call    cell_id=311    dl_tput=600M    ul_tput=65M    dl_deviation=10%    rat=5G    band=${cellband}
    END
