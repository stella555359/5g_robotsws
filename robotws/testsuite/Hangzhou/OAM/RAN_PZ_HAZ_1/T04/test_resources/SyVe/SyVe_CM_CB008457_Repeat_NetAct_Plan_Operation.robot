*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot
Variables         ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/python/SyVe_Oper_Duration_Standard.py

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${REPEAT_TIME}    ${EMPTY}    # Number of repetitions of netact operation
${RECORD_FILE}    ${OUTPUT DIR}/CB008457_TA_EXECUTE_RECORD.csv    # Test result record file.
# Must conform to the format: [BTS_DN]_ [OPER_TYPE]_ [ACTION_TYPE]_ [MO_TYPE], please refer to ${CURDIR}
#/../../test_line_specific/Hangzhou/${TESTLINE_NAME}/SyVe_Oper_Duration_Standard.py for details,
#for example: MRBTS-1896_ ACTIVATE_ OUTAGE_ 5G-RAT
${NETACT_PLAN_NAME}    ${EMPTY}

*** Keywords ***
SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation
    [Documentation]    [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23501
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    New TC for CB008457
    ...    Manual case see file 'RAN_SyVe_CB008681_003_CM_Verify duration of validation with delta Plan via NetAct.docx'
    ...    TA case only cover step1 to step3.
    ...
    ...    The main steps performed for the test are:
    ...    - Explain NetAct Plan Name
    ...    - Get HW And SW Version From Current NetAct Configuration
    ...    - Prepare SyVe Plan
    ...    - Repeat Oper NetAct Plan
    ...    - Check Durations
    ...
    ...    Pass criteria: create, edit, export and provision operation works as expected; states and alarms are as expected.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 08.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23501 - New case
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
	...    TAT-23501_SyVe_CM_Repeat_NetAct_Plan_Operation.png
    Set Tags    CM    AUTHOR-bin.7.liu@nokia.com    PHASE-SyVe    OWNER-I_NSB_MN_RAN_PZ1_HAZ_OPER1_VRF@internal.nsn.com    CB008457
    Step 1: Explain NetAct Plan Name
    Step 2: Get HW And SW Version From Current NetAct Configuration
    Step 3: Prepare SyVe Plan
    Step 4: Repeat Oper NetAct Plan
    Step 5: Check Durations

TC Setup
    Log    TC Setup    console=True
    Common Test Setup
    ${TIME_RECORD}    Create List
    Set Test Variable    ${TIME_RECORD}
    ${is_record_file_not_exist}    Run Keyword And Return Status    OperatingSystem.File Should Not Exist    ${RECORD_FILE}
    ${head_line}    Catenate    SEPARATOR=,    Pass or Fail    Duration(s)    Duration Standard(s)    Start Time
    ...    End Time    SW Version    HW Config    SBTS Name    Oper Type    SBTS Action
    ...    MO Type    Is Outage Happenned
    Run Keyword If    ${is_record_file_not_exist}    OperatingSystem.Create File    ${RECORD_FILE}    ${head_line}

TC Teardown
    Log    TC TearDown    console=True
    Common Test Teardown
    Run Keyword If    not ${IS_OUTAGE_PLAN}    Return From Keyword
    ${time}    Get Time    epoch
    Capture Page Screenshot    ${time}.png
    Close All Browsers

Step ${index}: Explain NetAct Plan Name
    Log    Step ${index}: Explain NetAct Plan Name    console=True
    LOG    NetAct plan name is: ${NETACT_PLAN_NAME}    console=True
    ${split_strs}    Split String    ${NETACT_PLAN_NAME}    _
    Set Test Variable    ${MRBTS_NAME}    ${split_strs[0]}
    Set Test Variable    ${MRBTS_DN}    PLMN-PLMN/${split_strs[0]}
    Set Test Variable    ${OPER}    ${split_strs[1]}
    Set Test Variable    ${ACTION}    ${split_strs[2]}
    Set Test Variable    ${MO_TYPE}    ${split_strs[3]}
    ${DURATION}    Evaluate    ${DURATION_STANDARD["${OPER}"]["${ACTION}"]["${MO_TYPE}"]["duration_standard"]}*1.15
    Set Test Variable    ${DURATION}
    Set Test Variable    ${META_CLASS}    ${DURATION_STANDARD["${OPER}"]["${ACTION}"]["${MO_TYPE}"]["params"]["class"]}
    Set To Dictionary    ${DURATION_STANDARD["${OPER}"]["${ACTION}"]["${MO_TYPE}"]["params"]}    class    ${META_CLASS.split(':')[-1]}
    Set Test Variable    ${TEST_DATA}    ${DURATION_STANDARD["${OPER}"]["${ACTION}"]["${MO_TYPE}"]["params"]}
    ${IS_OUTAGE_PLAN}    Evaluate    '${ACTION}'=='OUTAGE'
    Set Test Variable    ${IS_OUTAGE_PLAN}
#    Run Keyword Unless    ${IS_OUTAGE_PLAN}    Return From Keyword
    Run Keyword If    not ${IS_OUTAGE_PLAN}    Return From Keyword
    SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}    setup_param=${False}
    Status Of RAT Should Be OK
    SBTS WEM Open RunTime View    SV

Step ${index}: Get HW And SW Version From Current NetAct Configuration
    Log    Step ${index}: Get HW And SW Version From Current NetAct Configuration    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${MRBTS_NAME}.xml    dist_names=${MRBTS_DN}
    ...    plan_name=${MRBTS_NAME}_current_plan    operation_type=actual
    ${cur_plan}    L_XML.Parse XML    ${Test Results Dir}/NetActLogs/${MRBTS_NAME}.xml
    ${all_product_name_elements}    L_XML.Get Elements    ${cur_plan}    cmData/managedObject[@class="SMOD_R"]/p[@name="productName"]
    ${all_product_names}    Create List
    FOR    ${element}    IN    @{all_product_name_elements}
        ${product_name}    L_XML.Get Element Text    ${element}
        ${not_unknow}    Run Keyword And Return Status    Should Not Be Equal As Strings    ${product_name}    unknown    ignore_case=${True}
        Run Keyword If    ${not_unknow}    Append To List    ${all_product_names}    ${product_name}
    END
    LOG List    ${all_product_names}
    ${sw_version_element}    L_XML.Get Element    ${cur_plan}    cmData/managedObject/p[@name="activeSWReleaseVersion"]
    ${SW_VERSION}    L_XML.Get Element Text    ${sw_version_element}
    LOG    ${SW_VERSION}
    ${HW_CONFIG}    Catenate    SEPARATOR=+    @{all_product_names}
    Set Test Variable    ${HW_CONFIG}
    Set Test Variable    ${SW_VERSION}
    Set Test Variable    ${cur_plan}

Step ${index}: Prepare SyVe Plan
    Log    Step ${index}: Prepare SyVe Plan    console=True
    ${sub_expect_status}    ${sub_list_param_for_create_plan}    Get Parameter For NetAct Plan Due To TestData    ${cur_plan}    ${TEST_DATA}
    ${count}    Get Length    ${sub_list_param_for_create_plan}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${param_for_create_plan}    Set Variable    ${sub_list_param_for_create_plan[${index}]}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${NETACT_PLAN_NAME}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${NETACT_PLAN_NAME}_backup
    ${plan}    NetAct Create Plan    ${NETACT_PLAN_NAME}    Automation for ${TEST_NAME}
    ${managed_object}    netact.Create Managed Object    plan=${plan}    meta_class=${META_CLASS}
    ...    meta_version=${param_for_create_plan['meta_version']}    mo_id=${param_for_create_plan['mo_id']}
    ...    operation=${param_for_create_plan['operation']}
    ...    &{param_for_create_plan['parameters']}
    ${time}    Get Time    epoch
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${NETACT_PLAN_NAME}_${time}.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${NETACT_PLAN_NAME}    operation_type=plan

Step ${index}: Repeat Oper NetAct Plan
    Log    Step ${index}: Repeat Oper NetAct Plan    console=True
    ${is_not_error_plan}    Evaluate    '${ACTION}'!='ERROR'
    FOR    ${i}    IN RANGE    ${0}    ${REPEAT_TIME}
        LOG    Loop ${i}    console=${True}
        Preactivate Plan Before Validate Or Activate
        ${start_time}    Get Time
        ${status}    Run Keyword And Return Status    Oper_NetAct_Plan
        Should Be Equal    ${is_not_error_plan}    ${status}
        ${end_time}    Get Time
        ${time}    Subtract Date From Date    ${end_time}    ${start_time}
        ${is_done_intime}    Run Keyword And Return Status    Should Be True    ${time}<${DURATION}
        ${is_done_intime}    Set Variable If    ${is_done_intime}    PASS    FAIL
	    ${any_service_down}    Run Keyword If    ${IS_OUTAGE_PLAN}    Wait For Outage Finish
        ${line_record}    Catenate    SEPARATOR=,    ${is_done_intime}    ${time}    ${DURATION}    ${start_time}
        ...    ${end_time}    ${SW_VERSION}    ${HW_CONFIG}    ${MRBTS_NAME}    ${OPER}    ${ACTION}
        ...    ${MO_TYPE}    ${any_service_down}
        LOG    ${time}    console=${True}
        Append To File    ${RECORD_FILE}    \n${line_record}
        Append To List    ${TIME_RECORD}    ${time}
        Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
        ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}
        Continue For Loop If    '${OPER}'!='ACTIVATE' and '${OPER}'!='PROVISION'
        netact.provision_plan    plan_name=${NETACT_PLAN_NAME}_backup    dist_names=${MRBTS_DN}    backup_plan_name=${None}
        ...    create_backup_plan=False
        netact.Delete Plan    ${NETACT_PLAN_NAME}_backup
	    Run Keyword If    ${IS_OUTAGE_PLAN}    Wait For Outage Finish
    END

Step ${index}: Check Durations
    Log    Step ${index}: Check Durations    console=True
    FOR    ${time}    IN    @{TIME_RECORD}
        Should Be True    ${time}<${DURATION}
    END

Validate Or Activate NetAct Plan
    Preactivate Plan Before Validate Or Activate
    Run Keyword If    '${OPER}'=='VALIDATE'    netact.validate_plan    plan_name=${NETACT_PLAN_NAME}    dist_names=${MRBTS_DN}
    Run Keyword If    '${OPER}'=='ACTIVATE'    netact.activate_preactivated_plan    plan_name=${NETACT_PLAN_NAME}    dist_names=${MRBTS_DN}

Preactivate Plan Before Validate Or Activate
    ${create_backup_plan}    Evaluate    '${OPER}'=='ACTIVATE'
    Run Keyword If    '${OPER}'=='ACTIVATE' or '${OPER}'=='VALIDATE'    NetAct Provision Plan    plan_name=${NETACT_PLAN_NAME}
    ...    dist_names=${MRBTS_DN}    backup_plan_name=${NETACT_PLAN_NAME}_backup    create_backup_plan=${create_backup_plan}
    ...    provisioning_operation=preactivate

Oper_NetAct_Plan
    Run Keyword If    '${OPER}'=='VALIDATE'    netact.validate_plan    plan_name=${NETACT_PLAN_NAME}    dist_names=${MRBTS_DN}
    Run Keyword If    '${OPER}'=='ACTIVATE'    netact.activate_preactivated_plan    plan_name=${NETACT_PLAN_NAME}    dist_names=${MRBTS_DN}
    Run Keyword If    '${OPER}'=='PREACTIVATE'    NetAct Provision Plan    plan_name=${NETACT_PLAN_NAME}    dist_names=${MRBTS_DN}
    ...    backup_plan_name=${None}    create_backup_plan=False
    ...    provisioning_operation=preactivate
    Run Keyword If    '${OPER}'=='PROVISION'    netact.provision_plan    plan_name=${NETACT_PLAN_NAME}    dist_names=${MRBTS_DN}
    ...    backup_plan_name=${NETACT_PLAN_NAME}_backup    create_backup_plan=True

Wait For Outage Finish
    ${any_service_down}    Run Keyword And Return Status    Wait Until Keyword Succeeds    60s    1s    Run Keyword And Expect Error    *
    ...    Status Of RAT Should Be OK
    Run Keyword If    ${any_service_down}    Wait Until Keyword Succeeds    1200s    10s    Status Of RAT Should Be OK
    [Return]    ${any_service_down}