*** Settings ***
Documentation
...    Author:  liang.kong
...    Contact: liang.kong@nokia-sbell.com
...    Feature: CB009170
...    Release: 24R3

Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF
Resource          ../resources/common_resources.robot

*** Variables ***
@{ALLOWED_FAULT}
${scf_file_72e}      CB009170_ABIP_AVQL_NRTDD_100M_A1_gscn_636666_1xNRCELL_${bts_id}.xml

${pm_period}    5

*** Test Cases ***
CB009170_F_TC01_NR_FR1_TDD_eCPRI_ABIP_72e_Basic_L3_call
    [Tags]    ABIP    SMAwave    CB009170    CB009170_TC01    72e    Trunk    QL3Daily
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/CB009170/${scf_file_72e}    ${pm_period}min
    gNB Tool Start Capture Log    bip
    SMAwave UE attach    rat=5G    cell_id=617136129    band=78    specific_UE_index=UE_1
    SMAwave Start Data Traffic    1200M    140M    udp    920
    SMAwave Verify throughput for DL and UL    1200M    140M    10%    5G    78
    ${pm_counter_file}    get PM counter file    ${pm_period}
    check PM counter value    ${pm_counter_file}
    [Teardown]    Run keywords    SMAwave Stop Data And Detach    AND    common_resource_suite.Common Test Teardown    AND    gNB Tool Stop Log

*** Keywords ***
check PM counter value
    [Arguments]    ${pm_counter_file}
    ${eCPRI_U_C_Plane_messages}=    get_counter_value_from_counter_file   ${pm_counter_file}    M55318C00004    1    -1
    ${Corrupted_eCPRI_U_C_Plane_messages}=    get_counter_value_from_counter_file   ${pm_counter_file}    M55318C00010    1    -1
    ${eCPRI_U_C_Plane_check} =    Run Keyword And Return Status    Should Be True
    ...    ${eCPRI_U_C_Plane_messages}>=10000000
    ${Corrupted_eCPRI_U_C_Plane_check} =    Run Keyword And Return Status    Should Be True
    ...    ${Corrupted_eCPRI_U_C_Plane_messages}<=50
    Run Keyword If    not ${eCPRI_U_C_Plane_check}    Fail    [ ERROR ] ${eCPRI_U_C_Plane_messages} should be large than 10000000.
    Run Keyword If    not ${Corrupted_eCPRI_U_C_Plane_check}    Fail    [ ERROR ] ${Corrupted_eCPRI_U_C_Plane_messages} should be less than 50.
