*** Settings ***
Documentation
...   author: winnie.he
...   contact: winnie.he@nokia-sbell.com
...   this is a robot case for UTE regression
Resource          ../Resources/common_resource.robot
Resource          ../Resources/top50_resource.robot
# Resource          ../Resources/ute_case_common_resource.robot
Library           ute_ue
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Run keywords     Common MutliBTS Suite Teardown For RRM    AND
...    Top50 Suite Teardown
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
...    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags              CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIL_ABIO2_AHFIB2_AHLOB2_AEHC_AQQL
# ...                     SBTS22R4
...                     SBTS00
...                     STATE_SKIP_AGENT
...                     CA_VRF_HAZ1
...                     VRF_HAZ1_T05
...                     TA_LEVEL_22
Test Timeout            75h
*** Variables ***
&{Init_Enviroment}      IP=10.108.230.19
...                     USERNAME=root
...                     PASSWORD=uteadmin
...                     Reinstall_Script_Path=${/}root${/}scripts
...                     VM_Required_File=~/MN/UTE/robotws/requirements.cfg
${testline_configuration_path}    ~${/}testline_configuration
#storge case file info and path case file : { case path : path, case list: case list}
&{Upgrade_Case_Info}      Case_Path=${CURDIR}${/}..${/}GNB_EAR_Case${/}upgrade.robot
&{Feature_File_INFO}
...    Clear Configuration And Upgrade For Local=&{Upgrade_Case_Info}
...    Upgrade SRAN Local=&{Upgrade_Case_Info}

${TEST_ITERATION}       1
&{fault_6129}              faultId=${6129}
&{fault_6134}              faultId=${6134}
&{fault_4694}              faultId=${4694}
&{fault_8150}              faultId=${8150}
@{Ohter_Allow_Alarms}      &{fault_4694}    &{fault_6134}    &{fault_6129}
...    &{fault_8150}
# &{fault_7512}              faultId=${7512}
# &{fault_7509}              faultId=${7509}
# &{fault_6133}              faultId=${6133}
# @{DSS_Allow_Alarms}    &{fault_7512}    &{fault_7509}    &{fault_6133}
# &{fault_7313}              faultId=${7313}
# &{fault_1815}              faultId=${1815}
# @{Mode_Allow_Alarms}    &{fault_7313}    &{fault_1815}
${BTS_INDEX}               ${0}
&{E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_WITH_L3_CALL}
...    testname=OAM_Stability_5G_Upgrade_SA_call    SBTS00=55666
&{E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_WITH_L3_CALL}    SBTS00=55230
...    testname=OAM_Stability_5G_Site_reset_SA_call
&{UUF4ALL_CASE_QC_ID}
...    E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_WITH_L3_CALL=&{E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_WITH_L3_CALL}
...    E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_WITH_L3_CALL=&{E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_WITH_L3_CALL}
&{Stability_TEST_ITERATION}
...    E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_WITH_L3_CALL=${3}
...    E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_WITH_L3_CALL=${30}


*** Test Cases ***
Upgrade
    ${sw_list}    Split String    ${SW_LIST}    ,
    ${latest_sw}    Get Latest Sw    ${BTS0_ACTIVE_SW_VERSION}    ${sw_list}[0]
    Log To Console    Upgrade from ${BTS0_ACTIVE_SW_VERSION} to ${sw_list}[0]
    Upgrade For Local By Configuration Reset    ${BTS0_ACTIVE_SW_VERSION}    ${sw_list}[0]
    Log To Console    Start Upgrade Loop
    FOR    ${i}    IN RANGE    ${TEST_ITERATION}
        Log To Console    Upgrade Loop ${i}
        Loop To Upgrade Sw List    ${sw_list}
    END

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_WITH_L3_CALL
    [Tags]    5G
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    # Log To Console    test
    SW_Upgrade_Rollback_with_OAM_KPI
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_WITH_L3_CALL
    [Tags]    5G
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    # SA_Call    cell_used_in_test=${None}
    # Append BBMOD Reset Allow Alarms
    UUF4ALL_Site_Reset_without_HWF_with_OAM_KPI
    # ...    L3_CALL_Kw=SA_Call
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

*** Keywords ***
Case Setup
    UUF4ALL Set Base Variable    bts_index=${BTS_INDEX}
    UUF4ALL Send QC For Custom

Loop To Upgrade Sw List
    [Arguments]    ${sw_list}
    FOR    ${sw}    IN    @{sw_list}
        _Get All Gnb Active Sw Version
        Log To Console    Upgrade from ${BTS0_ACTIVE_SW_VERSION} to ${sw}
        Upgrade For Local By Configuration Reset    ${BTS0_ACTIVE_SW_VERSION}    ${sw}
    END

Upgrade For Local By Configuration Reset
    [Arguments]    ${source_sw}    ${target_sw}
    ${latest_sw}    Get Latest Sw    ${source_sw}    ${target_sw}
      Run Keyword If    '${source_sw}'!='${target_sw}' and '${source_sw}'=='${latest_sw}'
    ...    Run Feature Case     feature_name=Clear Configuration And Upgrade For Local
    ...    test_name=Clear Configuration And Upgrade For Local
    ...    ELSE IF    '${source_sw}'!='${target_sw}' and '${target_sw}'=='${latest_sw}'
    ...    Run Feature Case     feature_name=Upgrade SRAN Local
    ...    test_name=Upgrade SRAN Local
    ...    ELSE IF    '${source_sw}'=='${target_sw}'
    ...    Log To Console
    ...    no need to upgrade, active sw version ${source_sw} same with ${target_sw}

Get Latest Sw
    [Arguments]    ${sw1}     ${sw2}
    ${release1}    Get Release By Sw Version    sw=${sw1}
    ${release2}    Get Release By Sw Version    sw=${sw2}
    ${latest_sw}    Run Keyword If    '${release1}'=='${release2}'
    ...        Run Keyword If   '${sw1}'>'${sw2}'    Set Variable    ${sw1}
    ...        ELSE   Set Variable    ${sw2}
    ...    ELSE IF    '${release1}'>'${release2}'
    ...        Run Keyword If   '${release2}'=='SBTS00'    Set Variable    ${sw2}
    ...        ELSE    Set Variable    ${sw1}
    ...    ELSE IF   '${release1}'<'${release2}'
    ...        Run Keyword If   '${release1}'=='SBTS00'    Set Variable    ${sw1}
    ...        ELSE    Set Variable    ${sw2}
    [Return]    ${latest_sw}

Top50 Suite Teardown
    Run Keyword And Ignore Error    Run keyword If    ${MoveLog_to_Logserver}
    ...    Move All Test Result To Log Server

Case Teardown
    Log to console    TL Test Teardown
    Run Keyword And Ignore Error    Run Keyword If Test Passed    Delete Logs
    ${testcase_name}    UUF4ALL Get QC Test Case Name
    TL Test Teardown    ${testcase_name}