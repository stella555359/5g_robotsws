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

${repeat_number}    10

*** Test Cases ***
Robustness_TC02_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_BBU_Lock_Unlock
    [Tags]    QL3    Trunk    Robustness    ABIP    BBULock   hhh
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/Robustness/${btsid}/${scfc_file_16DL_2eCPRI_72e}
    FOR    ${round}    IN RANGE    ${repeat_number}
        Log To Console     \n--------------------------------------- Round-${round+1} ----------------------------------------
        BBMOD operation via WebUI    Locked    ABIP
        BBMOD operation via WebUI    Unlocked    ABIP
        Online change SCFC parameter    MRBTS-${btsid}/NRBTS-${btsid}/NRCELL-1    actDlSrsSubbandBm    true
        Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir
        Online change SCFC parameter    MRBTS-${btsid}/NRBTS-${btsid}/NRCELL-1    actDlSrsSubbandBm    false
        Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir
        SMAwave L3 call    cell_id=11    dl_tput=${tp_with_50M['DLTP']}    ul_tput=${tp_with_50M['ULTP']}    dl_deviation=10%
        ...    rat=5G    band=${cellband}
    END
