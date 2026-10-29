*** Settings ***
Documentation
...    Tests for CB006483 HZ

Library    BuiltIn
Library    json
Library    DateTime
Library    Collections
Library    taf.ul.verify_snapshot    WITH NAME    snapshot
Library    taf.rfrl.cbts.utilities.generic_utils    WITH NAME    generic_utils
Library    taf.rfrl.cbts.connections.rest_conn_vdu.GenericVDU    WITH NAME   vdu_gen
Library    taf.rfrl.cbts.devices.vdu.business.vdu_cm_business    WITH NAME   vdu_cm_business
Library    taf.gnb.oam.coam.vdu  WITH NAME  vdu

Resource    ../../common_resources/vdu_frame.robot
Resource    ../../common_resources/vdu_general.robot
Resource    ../../common_resources/vcu_frame.robot
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_logging.robot
Resource    ../resources/LOGS_general.robot

*** Variables ***
${VDU_SCFC_PATH}  ${CURDIR}/SCF/vCu/vDu.xml
${VCU_SCFC_PATH}  ${CURDIR}/SCF/vCu/vCu.xml
@{LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}=    Create List
${REVERT_DELTA_CHANGES}    ${False}

*** Keywords ***
TC_CB006483_5G_C_Add_modify_remove_the_triggers_Remote_Tool
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of the test case is to verify if user can remove triggers by disabling feature CB006483.
    ...    (CB006483-A-C?CB006796-SR-A)
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 31.03.2022 - - Created
    ...    - 20.10.2025 - Adapted for TSR1 team; Dan Moldovan
    ...    *******************
    ...    Notice: if cell group has servals cell, get ue failed
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    ...    Owner:dan.moldovan@nokia.com
    [Tags]  CRT_TRUNK    RF50


    Step 0: Precondition
    Step 1: Check Default Snapshot Fault List True
    Step 2: Operate an Alarm From the Default List
    Step 3: Set Active Defalut Trigger to False and Check Auditlog
    Step 4: Check Default Snapshot Fault List False


Step 0: Precondition
   [Documentation]
    ...   In this step Precond
     Log    \nStep 0: Precondition    console=${True}

    ${rmod_listed}    get rmods status
    ${ids}    Create List
    Set Test Variable    ${ids}

    FOR    ${item}    IN    @{rmod_listed}
        ${serial_number}    Get From Dictionary    ${item}    serial_number
        ${id}    Get From Dictionary    ${item}    id
        ${dist_names}    Get From Dictionary    ${item}    dist_names

        Append To List    ${ids}    ${id}
    END

    ${config_value}    Set Variable    ${dist_names['config']}
    ${split}    Split String    ${config_value}    /
    ${mr_id}    Get From List    ${split}    0
    ${vdu_id}    Split String    ${mr_id}    -
    ${vdu_id}    Get From List    ${vdu_id}   1
    Set Test Variable  ${vdu_id}

Step 1: Check Default Snapshot Fault List True
     Log    \nStep 1: Check Default Snapshot Fault List True    console=${True}

    Set Active Default Trigger Value    set_value=true
    Check Default Snapshot Fault List       contain=${True}

Step 2: Operate an Alarm From the Default List
    Log    \nStep 2: Operate an Alarm From the Default List    console=${True}
    VDU Rest Login
    ${faultSnapshotTriggers}    Get Snapshot Fault list
    ${update_alarm}    set variable    ${faultSnapshotTriggers[0]}
    sleep    60
    Operate an Alarm From the Default List    alarm_dict=${update_alarm}    alarm_operation=update
    sleep    60
    ${operation_alarm}    set variable    ${faultSnapshotTriggers[1]}
    Operate an Alarm From the Default List    alarm_dict=${operation_alarm}    alarm_operation=delete
    sleep    60
    Operate an Alarm From the Default List    alarm_dict=${operation_alarm}    alarm_operation=add
#    [Teardown]  vDU Rest Logout

Step 3: Set Active Defalut Trigger to False and Check Auditlog
    Log    \nStep 3: Set Active Defalut Trigger to False and Check Auditlog    console=${True}
    sleep    60
    Set Active Defalut Trigger to False and Check Auditlog
    sleep    60
    Check Default Snapshot Fault List    contain=${False}

Step 4: Check Default Snapshot Fault List False
     Log    \nStep 4: Check Default Snapshot Fault List False   console=${True}
    sleep    60
    Check Default Snapshot Fault List False      contain=${False}

Check Default Snapshot Fault List False
    [Arguments]   ${contain}=${True}
    Log To Console   \nCheck Default Snapshot Fault List
    VDU Rest Login
    ${current_fault_list}    vdu.get_default_snapshot_fault_triggers
    ${fault_6450}    create dictionary    fault_number=${6450}    trigger_type=onFaultDetection
    ${fault_1868}    create dictionary    fault_number=${1868}    trigger_type=onAlarmSend
    ${fault_4547}    create dictionary    fault_number=${4547}    trigger_type=onAlarmSend
    ${fault_10}    create dictionary    fault_number=${10}    trigger_type=onAlarmCancellation
    ${default_list}    create list    ${fault_6450}    ${fault_1868}    ${fault_4547}    ${fault_10}
    Check Fault Trigger List    fault_trigger_list=${current_fault_list}    compare_fault_trigger_list=${default_list}
    ${faultSnapshotTriggers}    Get Snapshot Fault list
    ${new_faultSnapshotTriggers}    create list
    FOR    ${fault}    IN    @{faultSnapshotTriggers}
        ${new_fault}    create dictionary    fault_number=${fault['faultNumber']}    trigger_type=${fault['triggerType']}
        append to list    ${new_faultSnapshotTriggers}    ${new_fault}
    END
    Check Fault Trigger List    fault_trigger_list=${new_faultSnapshotTriggers}    compare_fault_trigger_list=${default_list}
	...    contain=${contain}

Check Default Snapshot Fault List
    [Arguments]   ${contain}=${True}
    Log To Console   \nCheck Default Snapshot Fault List
#    VDU Rest Login
    ${current_fault_list}    vdu.get_default_snapshot_fault_triggers
    ${fault_6450}    create dictionary    fault_number=${6450}    trigger_type=onFaultDetection
    ${fault_1868}    create dictionary    fault_number=${1868}    trigger_type=onAlarmSend
    ${fault_4547}    create dictionary    fault_number=${4547}    trigger_type=onAlarmSend
    ${fault_10}    create dictionary    fault_number=${10}    trigger_type=onAlarmCancellation
    ${default_list}    create list    ${fault_6450}    ${fault_1868}    ${fault_4547}    ${fault_10}
    Check Fault Trigger List    fault_trigger_list=${current_fault_list}    compare_fault_trigger_list=${default_list}
    ${faultSnapshotTriggers}    Get Snapshot Fault list
    ${new_faultSnapshotTriggers}    create list
    FOR    ${fault}    IN    @{faultSnapshotTriggers}
        ${new_fault}    create dictionary    fault_number=${fault['faultNumber']}    trigger_type=${fault['triggerType']}
        append to list    ${new_faultSnapshotTriggers}    ${new_fault}
    END
    Check Fault Trigger List    fault_trigger_list=${new_faultSnapshotTriggers}    compare_fault_trigger_list=${default_list}
	...    contain=${contain}

Set Active Defalut Trigger to False and Check Auditlog
    [Documentation]    Set Active Defalut Trigger to False and Check Auditlog
    ...    update 2024-09-19 by jie.2.li@nokia-sbell.com: https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10879
    [Arguments]  ${alias}=vDU
    sleep    60
    Log To Console   \nSet Active Defalut Trigger to False and Check Auditlog
    Connect To vDU K8s Master Node With Tenant  alias=${alias}
    ${ns}	Set Variable    ${VDU_CRAN}
    ${log_path}  ${kubectl_cmd}    Generate Auditlog Get    namespace=${ns}

    ${id}  Set Active Default Trigger Value False    set_value=false
    wait until keyword succeeds    8min    30sec    Check Auditlog
    ...    kubectl_cmd=${kubectl_cmd}    alias=${alias}    log_file=${log_path}/auditlog
    ...    id=${id}
#    [Teardown]  vDU Disconnect Interactive Connection    alias=${alias}

Generate Auditlog Get
    [Arguments]  ${namespace}=cran1
    ${pod_abbr}    set variable    logservice
    ${ctr_abbr}    set variable    logstorageserver
    set suite variable    ${_G_CONTAINER_PREFIX}    ctr-${namespace}-

    ${ns}	Set Variable    ${VDU_CRAN}
    Open SSH Connection To VDU And Connect To Openshift
    ${pod_full_name}  ${container_full_name}  Get Full Names For Pod And Container  ${ns}  logservice

    ${log_path}    set variable    /var/log/audit/

    #${kubectl_cmd}    Set Variable    kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns}
    ${kubectl_cmd}    Set Variable    kubectl exec -it ${pod_full_name} -c ctr-logstorageserver -n ${ns}
    [Return]  ${log_path}  ${kubectl_cmd}

Check Auditlog
    [Arguments]  ${kubectl_cmd}    ${log_file}    ${id}    ${alias}=vDU
    Log To Console   \nCheck auditlog
    ${validate_plan_content}    issh.Execute    command=${kubectl_cmd} -- cat ${log_file} | grep ${id}    alias=${alias}
    ${match}   ${appl_session_id}   Should Match Regexp    ${validate_plan_content}    "applSessionId":"(\\d+)"
    ${activate_plan_content}   issh.Execute   command=${kubectl_cmd} -- cat ${log_file} | grep TRBLCADM | grep ${appl_session_id}   alias=${alias}
    sleep    1
    ${check_log}    Get Regexp Matches    ${activate_plan_content}
    ...    \{[\\s\\S]*TRBLCADM[\\s\\S]*\{[\\s\\S]*actDefaultFaultSnapTriggers[\\s\\S]*false[\\s\\S]*\}\}
    should not be empty    ${check_log}

Operate an Alarm From the Default List
    [Documentation]    alarm_operation=delete/add/update
    [Arguments]    ${alarm_dict}    ${alarm_operation}=delete    ${vdu_index}=0    ${gnb_index}=0
    Log To Console   \n${alarm_operation} an Alarm From the Default List
    ${faultSnapshotTriggers}    Get Snapshot Fault list
    ${delta_faultSnapshotTriggers}    Update ALarm List    alarm_list=${faultSnapshotTriggers}
    ...    alarm_dict=${alarm_dict}    alarm_operation=${alarm_operation}
    ${distname}    Set Variable   MRBTS-${vdu_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${delta_data_list}=    Evaluate    [['${distname}', {'faultSnapshotTriggers': ${delta_faultSnapshotTriggers}}, 'replace']]
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    vdu_cm_business.delta_commission_step_by_step    delta_data_list=${delta_data_list}    conn_alias=${conn_alias}
    ${alarm_dict_string}    convert to string    ${alarm_dict}
    ${faultSnapshotTriggers}    Get Snapshot Fault list
    ${faultSnapshotTriggers_string}    convert to string    ${faultSnapshotTriggers}
    run keyword if    '${alarm_operation}'=='delete'
    ...    should not contain     ${faultSnapshotTriggers_string}    ${alarm_dict_string}
    ...    ELSE    should contain    ${faultSnapshotTriggers_string}    ${alarm_dict_string}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Update ALarm List
    [Arguments]  ${alarm_list}    ${alarm_dict}    ${alarm_operation}=delete
    ${faultNumber}    get from dictionary    ${alarm_dict}    faultNumber
    run keyword if    '${alarm_operation}'=='add'    append to list    ${alarm_list}    ${alarm_dict}
    ${alarm_len}    get length    ${alarm_list}
    FOR    ${index}    IN RANGE    ${alarm_len}
        ${faultNumber_tmp}    get from dictionary    ${alarm_list[${index}]}    faultNumber
        IF    '${faultNumber_tmp}'=='${faultNumber}' and '${alarm_operation}'=='update'
            ${alarm_dict_tmp}    Update Alarm Dict    ${alarm_dict}
            remove from list    ${alarm_list}    ${index}
            append to list    ${alarm_list}    ${alarm_dict_tmp}
            exit for loop
        END
        run keyword if    '${faultNumber_tmp}'=='${faultNumber}' and '${alarm_operation}'=='delete'    run keywords
        ...    remove from list    ${alarm_list}    ${index}    AND
        ...    exit for loop
    END
    [Return]  ${alarm_list}

Update Alarm Dict
    [Arguments]  ${alarm_dict}
    ${trigger_type}    create list    onAlarmCancellation    onAlarmSend    onFaultDetection   onFaultCancellation
    ${alarm_value}    get from dictionary    ${alarm_dict}    triggerType
    remove values from list    ${trigger_type}    ${alarm_value}
    ${new_type}    evaluate    random.choice(${trigger_type})    modules=random
    set to dictionary    ${alarm_dict}    triggerType=${new_type}
    [Return]  ${alarm_dict}

Check Fault Trigger List
    [Arguments]   ${fault_trigger_list}    ${compare_fault_trigger_list}    ${contain}=${True}
    ${len}    get length    ${fault_trigger_list}
    ${compare_len}    get length    ${compare_fault_trigger_list}
    ${fault_trigger_list_string}    convert to string    ${fault_trigger_list}
    FOR    ${fault}    IN    @{compare_fault_trigger_list}
        ${fault}    convert to string    ${fault}
        run keyword if    ${contain}    should contain    ${fault_trigger_list_string}    ${fault}
        ...    ELSE    should not contain    ${fault_trigger_list_string}    ${fault}
    END

Get Snapshot Fault list
    VDU Rest Login
    ${dist_names}    create list   MRBTS-${vdu_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${objects}    vdu.get_current_plan_objects    class_name=TRBLCADM
    ...    dist_names=${dist_names}
    ${trblcadm}    set variable    ${objects['objects']}[0]
    ${json_repr}    json.loads    ${trblcadm['json_repr']}
    ${status}    run keyword and return status    dictionary should contain key    ${json_repr}    faultSnapshotTriggers
    ${faultSnapshotTriggers}    run keyword if    ${status}    get from dictionary    ${json_repr}    faultSnapshotTriggers
    ...    ELSE    create list
    [Return]  ${faultSnapshotTriggers}
    [Teardown]  vDU Rest Logout

Set Active Default Trigger Value
    [Arguments]   ${set_value}

#    VDU Rest Login
    ${parameter0}  Create Dictionary      parameterName=actDefaultFaultSnapTriggers  value=${set_value}  operation=create
    ${parameter_change_list0}  Create List  ${parameter0}
    ${parameter_changed_param0}   Create Dictionary    distName=MRBTS-${vdu_id}/MNL-1/MNLENT-1/TRBLCADM-1     operation=update
    ...    parameters=${parameter_change_list0}

    ${changed_parameter_list}  Create List     ${parameter_changed_param0}
    ${changed_parameters_string}  Evaluate  json.dumps(${changed_parameter_list})  json
    ${out}  vdu.Perform Delta Recommissioning    ${changed_parameters_string}    #vdu_connection=default
    ${get_id}    String.Split String    ${out['id']}    separator=_
    [Return]  ${get_id[1]}
#    [Teardown]  vDU Rest Logout

Set Active Default Trigger Value False
    [Arguments]   ${set_value}

    VDU Rest Login
    ${parameter0}  Create Dictionary      parameterName=actDefaultFaultSnapTriggers  value=${set_value}  operation=create
    ${parameter_change_list0}  Create List  ${parameter0}
    ${parameter_changed_param0}   Create Dictionary    distName=MRBTS-${vdu_id}/MNL-1/MNLENT-1/TRBLCADM-1     operation=update
    ...    parameters=${parameter_change_list0}

    ${changed_parameter_list}  Create List     ${parameter_changed_param0}
    ${changed_parameters_string}  Evaluate  json.dumps(${changed_parameter_list})  json
    ${out}  vdu.Perform Delta Recommissioning    ${changed_parameters_string}    #vdu_connection=default
    ${get_id}    String.Split String    ${out['id']}    separator=_
    [Return]  ${get_id[1]}
#    [Teardown]  vDU Rest Logout

Test Teardown
#    Common VDU Teardown
    log to console    TBD - restore initial scf

TC Setup
    Common VDU Setup
#    Suite Precondition

TC Teardown

    Test Teardown
    Logs To Rotta Copy
