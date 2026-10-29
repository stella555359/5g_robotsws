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
&{tp_with_100M}    DLTP=700M    ULTP=130M
&{tp_with_50M}    DLTP=350M    ULTP=40M
&{tp_with_20M}    DLTP=140M    ULTP=16M
&{tp_with_diff_chbw}    100MHz=&{tp_with_100M}    50MHz=&{tp_with_50M}    20MHz=&{tp_with_20M}
&{enable_72e_dict}    actEcpri72e=Ecpri72eULDL
&{disable_72e_dict}    actEcpri72e=disabled
${cellband}    78

${scfc_file_16DL_2eCPRI_72e}    CB010630_D_ABIP_AVQL_NRTDD_50M_A1_4xNRCELL_72e_16D4U_16D2U_8D4U_4D2U_2xeCPRI.xml

${repeat_number}    20

*** Test Cases ***
Robustness_TC06_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_Site_Reset
    [Tags]    ABIP    SMAwave    Robustness    SiteReset    Trunk    QL3    yaqin
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/Robustness/${btsid}/${scfc_file_16DL_2eCPRI_72e}
    FOR    ${item}    IN RANGE    ${repeat_number}
        #Site Reset Via WebUI    ${False}    ${True}
        Site Reset Via AdminCLI
        Log To Console    \n[INFO] Round-${item+1} Site resetting ...
        Sleep    120s
        Wait Until Keyword Succeeds    300 min    30 sec    Check If All Cells Are OnAir
        #SMAwave L3 call    cell_id=11    dl_tput=140M    ul_tput=16M    dl_deviation=10%    rat=5G    band=${cellband}
    END
