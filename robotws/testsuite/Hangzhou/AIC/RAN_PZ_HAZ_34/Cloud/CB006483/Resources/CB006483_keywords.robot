*** Settings ***
Documentation
...   author: tingting.zhong@nokia-sbell.com
...   contact: tingting.zhong@nokia-sbell.com
...   update: jie.2.li@nokia-sbell.com

Library           DateTime
Library           json
Library           taf.config.scf                        WITH NAME    scf
Library           taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library           taf.hw.fhgw.cli                       WITH NAME    issh
Library           taf.transport.ssh                     WITH NAME    tafssh
Library           taf.rfrl.cbts.utilities.generic_utils
Library           taf.rfrl.cbts.connections.rest_conn_vdu.GenericVDU    WITH NAME    vdu_gen
Library           taf.rfrl.cbts.devices.vdu.business.vdu_cm_business    WITH NAME   vdu_cm_business
Library           testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB006483/Resources/utils.py
Library           testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/common_trans.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vcu.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot


*** Keywords ***
Case Setup
    ${START_TIME}    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}
    ${SUITE_LOG_DIRECTORY}    Get A Directory
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}
    ${status}    run keyword and return status    vDU Verify All Cells Status Should Be Onair
    VDU Rest Login
    ${scf_path}    Get A Directory    scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File    local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    set test variable    ${scf_file_with_fullpath}
    scf.Load_Scf    file_path=${scf_file_with_fullpath}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_file_with_fullpath}
    set test variable    ${mrbts_id}
	run keyword if    not ${status}    run keywords    Reset VDU    AND
    ...    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair
    AlarmWatchdog.init_watchdog    interval=5 sec    bts_config=${tl.gnbs[0]}    du_id=0
    Run Keyword And Ignore Error    Fix OCP Syslog Format    # https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10335
    [Teardown]  run keyword and ignore error    vDU Rest Logout

Case Teardown
    [Documentation]    Case Teardown
    ...    update by jie.2.li@nokia-sbell.com: 2024-09-18 https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10778
    vDU Verify All Cells Status Should Be Onair
    [Teardown]
    ...    Run Keywords    run keyword and ignore error    AlarmWatchdog.teardown_watchdog    AND    run keyword and ignore error    vDU Rest Logout

Save Local Snapshot In vDU
    [Arguments]    ${local_snapshot_location}=vdu_snapshot    ${vdu_index}=${0}
    log to console    \nSave Local Snapshot...
    VDU Rest Login    vdu_index=${vdu_index}
    ${Snapshot_path}    Get A Directory    ${local_snapshot_location}
    ${a}    vdu.Get_Local_Snapshot    ${Snapshot_path}
    [Return]    ${Snapshot_path}
    [Teardown]  run keyword and ignore error    vDU Rest Logout

Set Active Defalut Trigger Value
    [Arguments]    ${set_value}    ${vdu_index}=0    ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    Log To Console   \nSet Active Defalut Trigger Value to ${set_value}
    ${distname}    Set Variable   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${delta_data_list}=    Evaluate    [['${distname}', {'actDefaultFaultSnapTriggers': '${set_value}'}, 'replace']]
    ${out}   vdu_cm_business.delta_commission_step_by_step    delta_data_list=${delta_data_list}    conn_alias=${conn_alias}
    ${get_id}    String.Split String    ${out['id']}    separator=_
    [Return]  ${get_id[1]}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Set Active Default Trigger Value to True by Fullscf
    Log To Console   \nSet Active Defalut Trigger Value by Fullscf
    ${distname}    Set Variable   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${vdu_scf_file_pre}    replace string  ${scf_file_with_fullpath}  .xml  ${EMPTY}
    ${vdu_scf_file}  set variable  ${vdu_scf_file_pre}_active_default_trigger.xml
    scf.modify_scf_element    value=true    dist_name=${distname}   p_name=actDefaultFaultSnapTriggers
    scf.save_scf  file_path=${vdu_scf_file}
    vDU Full Commission SCF    scf_file=${vdu_scf_file}
	sleep    3min
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair

Check Default Snapshot Fault List
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
    [Teardown]  run keyword and ignore error    vDU Rest Logout

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
    ${dist_names}    create list   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${objects}    vdu.get_current_plan_objects    class_name=TRBLCADM
    ...    dist_names=${dist_names}
    ${trblcadm}    set variable    ${objects['objects']}[0]
    ${json_repr}    json.loads    ${trblcadm['json_repr']}
    ${status}    run keyword and return status    dictionary should contain key    ${json_repr}    faultSnapshotTriggers
    ${faultSnapshotTriggers}    run keyword if    ${status}    get from dictionary    ${json_repr}    faultSnapshotTriggers
    ...    ELSE    create list
    [Return]  ${faultSnapshotTriggers}
    [Teardown]  vDU Rest Logout

Operate a Alarm From the Default List
    [Documentation]    alarm_operation=delete/add/update
    [Arguments]    ${alarm_dict}    ${alarm_operation}=delete    ${vdu_index}=0    ${gnb_index}=0
    Log To Console   \n${alarm_operation} a Alarm From the Default List
    ${faultSnapshotTriggers}    Get Snapshot Fault list
    ${delta_faultSnapshotTriggers}    Update ALarm List    alarm_list=${faultSnapshotTriggers}
    ...    alarm_dict=${alarm_dict}    alarm_operation=${alarm_operation}
    ${distname}    Set Variable   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
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

Operate Fast Activation and Check Status
    [Arguments]  ${payload}    ${operation}=update    ${operation_status}=success
    VDU Rest Login
    ${distname}    Set Variable   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${feedback}    vdu.fast_activations_for_delta_plan    class_name=TRBLCADM    dist_name=${distname}
    ...    operation=${operation}    payload=${payload}
    wait until keyword succeeds    3min    10sec    Check Fast Activation Status    operation_id=${feedback['id']}
    ...    operation_status=${operation_status}
    [Teardown]  vDU Rest Logout

Check Fast Activation Status
    [Arguments]  ${operation_id}    ${operation_status}=success
    ${status}    vdu.get_fast_activation_operation_of_delta_plan    operation_id=${operation_id}
    should be true    '${status['status'].lower()}'=='${operation_status}'

Get Diagnostic Snapshot Destination
    VDU Rest Login
    ${dist_names}    create list   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${objects}    vdu.get_current_plan_objects    class_name=TRBLCADM
    ...    dist_names=${dist_names}
    ${trblcadm}    set variable    ${objects['objects']}[0]
    ${json_repr}    json.loads    ${trblcadm['json_repr']}
    ${diagSnapDestination}    get from dictionary    ${json_repr}    diagSnapDestination
    [Return]  ${diagSnapDestination}
    [Teardown]  vDU Rest Logout

Update Snapshot Configuration to NetAct
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    Log To Console   \nUpdate Snapshot Configuration to NetAct
	${diagSnapDestination}    Get Diagnostic Snapshot Destination
    ${distname}    Set Variable   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
	${delta_data_list}    run keyword if    '${diagSnapDestination}'=='nms'    Evaluate
    ...    [['${distname}', {'maxNumSnapByFaultTrigPerDay': '2'}, 'replace']]    ELSE    Evaluate
    ...    [['${distname}', {'diagSnapDestination': 'nms', 'lssConfig': 'null', 'maxNumSnapByFaultTrigPerDay': '2'}, 'replace']]
    ${out}   vdu_cm_business.delta_commission_step_by_step    delta_data_list=${delta_data_list}    conn_alias=${conn_alias}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Recovery Snapshot Configuration to NetAct
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    Log To Console   \nUpdate Snapshot Configuration to NetAct
	${diagSnapDestination}    Get Diagnostic Snapshot Destination
    ${distname}    Set Variable   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${delta_data_list}    run keyword if    '${diagSnapDestination}'=='nms'    Evaluate
    ...    [['${distname}', {'maxNumSnapByFaultTrigPerDay': '20'}, 'replace']]    ELSE    Evaluate
    ...    [['${distname}', {'diagSnapDestination': 'nms', 'lssConfig': 'null', 'maxNumSnapByFaultTrigPerDay': '20'}, 'replace']]
    ${out}   vdu_cm_business.delta_commission_step_by_step    delta_data_list=${delta_data_list}    conn_alias=${conn_alias}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Add Trigger Fault 49
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    ${alarm_dict}    create dictionary    faultNumber=${49}    triggerType=onFaultDetection    snapshotCoverageLevel=Full
    ${faultSnapshotTriggers}    create list    ${alarm_dict}
    ${distname}    Set Variable   MRBTS-${mrbtsID}/MNL-1/MNLENT-1/TRBLCADM-1
    ${delta_data_list}=    Evaluate    [['${distname}', {'faultSnapshotTriggers': ${faultSnapshotTriggers}}, 'replace']]
    vdu_cm_business.delta_commission_step_by_step    delta_data_list=${delta_data_list}    conn_alias=${conn_alias}
    ${faultSnapshotTriggers}    Get Snapshot Fault list
    ${exsit}    set variable    ${False}
    FOR    ${fault}    IN    @{faultSnapshotTriggers}
        ${status}    run keyword and return status    dictionary should contain sub dictionary    ${fault}    ${alarm_dict}
        ${exsit}    set variable if    ${status}    ${True}    ${False}
    END
    should be true    ${exsit}    msg=Trigger fault 49 not in triggers!
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Block Cell by Rest
    [Arguments]  ${cell_id}=1    ${vdu_index}=0
    Log To Console   \nBlock Cell ${cell_id}
    vDU Rest Login    vdu_index=${vdu_index}
    ${return_info}   vdu.block_cell     cell_id=${cell_id}
    Wait until keyword succeeds  10x  5s
    ...   Block Cell Operation Should Be Successful   operation_id=${return_info["id"]}
	vdu.delete_block_cell_operation   operation_id=${return_info["id"]}
    [Teardown]  vDU Rest Logout

Block Cell Operation Should Be Successful
    [Arguments]  ${operation_id}
    ${block_operation_response}=  vdu.get_block_cell_operation_status  operation_id=${operation_id}
    should be equal as strings  ${block_operation_response['status']}  success

Unblock Cell by Rest
    [Arguments]  ${cell_id}=1    ${vdu_index}=0
	Log To Console   \nUnblock Cell ${cell_id}
    vDU Rest Login    vdu_index=${vdu_index}
    ${return_info}   vdu.unblock_cell     cell_id=${cell_id}
    Wait until keyword succeeds  10x  5s
    ...   Unblock Cell Operation Should Be Successful   operation_id=${return_info["id"]}
	vdu.delete_unblock_cell_operation   operation_id=${return_info["id"]}
    [Teardown]  vDU Rest Logout

Unblock Cell Operation Should Be Successful
    [Arguments]  ${operation_id}
    ${unblock_operation_response}=  vdu.get_unblock_cell_operation_status  ${operation_id}
    should be equal as strings  ${unblock_operation_response['status']}  success

Reset VDU
    Log To Console   \nReset VDU
    VDU Rest Login
    vdu.reset_vdu
    sleep    3min
    [Teardown]  run keyword and ignore error    vDU Rest Logout

Check Diagnostic Snapshot Collection Info
    [Arguments]
    ...    ${diagSnapAddInfo}=49 - On fault detection
    ...    ${diagSnapState}=Upload completed
    ...    ${diagSnapFilename}=5gvDU_substring_test_${random}
    VDU Rest Login
    ${dist_names}    create list   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1/TRBLCADM_R-1
    ${objects}    vdu.get_current_plan_objects    class_name=TRBLCADM_R
    ...    dist_names=${dist_names}
    ${trblcadm_r}    set variable    ${objects['objects']}[0]
    ${json_repr}    json.loads    ${trblcadm_r['json_repr']}
    ${BTS_diagSnapAddInfo}    set variable    ${json_repr['diagSnapAddInfo']}
    should contain    ${BTS_diagSnapAddInfo}    ${diagSnapAddInfo}
    ${BTS_diagSnapState}    set variable    ${json_repr['diagSnapState']}
    should contain    ${BTS_diagSnapState}    ${diagSnapState}
    ${BTS_SnapFilename}    set variable    ${json_repr['diagSnapFilename']}
    should contain    ${BTS_SnapFilename}    ${diagSnapFilename}
    [Teardown]  vDU Rest Logout

Check Diagnostic Snapshot Failname
    VDU Rest Login
    ${dist_names}    create list   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1/TRBLCADM_R-1
    ${objects}    vdu.get_current_plan_objects    class_name=TRBLCADM_R
    ...    dist_names=${dist_names}
    ${trblcadm_r}    set variable    ${objects['objects']}[0]
    ${json_repr}    json.loads    ${trblcadm_r['json_repr']}
    ${diagSnapFilename}    set variable    ${json_repr['diagSnapFilename']}
    [Return]  ${diagSnapFilename}
    [Teardown]  vDU Rest Logout

Update Snapshot Configuration to Incorrect LSS
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    Log To Console   \nUpdate Snapshot Configuration to Incorrect LSS
    ${diagSnapDestination}    Get Diagnostic Snapshot Destination
    ${distname}    Set Variable   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${lssConfig}    create dictionary    lssIPaddress=1.1.1.1    lssPortNo=2222
    ${delta_data_list}    run keyword if    '${diagSnapDestination}'=='lss'    Evaluate
    ...    [['${distname}', {'lssConfig': ${lssConfig}}, 'replace']]    ELSE    Evaluate
    ...    [['${distname}', {'diagSnapDestination': 'lss', 'lssConfig': ${lssConfig}}, 'replace']]
    vdu_cm_business.delta_commission_step_by_step    delta_data_list=${delta_data_list}    conn_alias=${conn_alias}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Get vdu time
    [Arguments]  ${alias}=vDU
    Connect To K8s Master    alias=${alias}
    ${cmd}    set variable   date -u +"%Y-%m-%d %H:%M:%S"
    ${result}    tafssh.Execute    ${cmd}    connection=${alias}
    [Return]  ${result}
    [Teardown]  Disconnect From K8s Master    connection=${alias}

Get vDU Time Cst
    [Arguments]  ${alias}=vDU
    Connect To K8s Master    alias=${alias}
    ${cmd}    set variable   date -u +"%Y-%m-%d %H:%M:%S" -d '8 hour'
    ${result}    tafssh.Execute    ${cmd}    connection=${alias}
    [Return]  ${result}
    [Teardown]  Disconnect From K8s Master    connection=${alias}

Check Alarm exsit in active Alarm
    [Arguments]  ${fault_id}    ${alarming_object}=${None}    ${exsit}=${True}
    vdu rest login
    ${out}   vdu.vdu_get_active_alarms
    ${alarm_list}   get from dictionary    ${out}    alarms
    ${check_flag}    set variable    ${False}
    FOR    ${alarm}    IN    @{alarm_list}
        continue for loop if    '${alarm['fault_id']}'!='${fault_id}'
        ${get_alarming_object}    get from dictionary    ${alarm}    alarming_object
        ${status}    run keyword and return status    should contain    ${get_alarming_object}    ${alarming_object}
        ${check_flag}    set variable if    ${status} or '${alarming_object}'=='${None}'   ${True}    ${check_flag}
        exit for loop if    ${check_flag}
    END
    should be true    ${check_flag}==${exsit}
    run keyword if    ${exsit}    Log To Console   \nFault ${fault_id} Appeard in Active Alarm
    ...    ELSE    Log To Console   \nFault ${fault_id} Disappeard in Active Alarm
    [Teardown]  vDU Rest Logout

Set Active Defalut Trigger to False and Check Auditlog
    [Documentation]    Set Active Defalut Trigger to False and Check Auditlog
    ...    update 2024-09-19 by jie.2.li@nokia-sbell.com: https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10879
    [Arguments]  ${alias}=vDU
    Log To Console   \nSet Active Defalut Trigger to False and Check Auditlog
    vDU Connect To K8s Master Interactively    alias=${alias}
    ${ns}   Get vDU Namespace From TestLine   gnb_index=0   vdu_index=0
    ${log_path}  ${kubectl_cmd}    Generate Auditlog Get    namespase=${ns}    alias=${alias}
    ${id}    Set Active Defalut Trigger Value    set_value=false
    wait until keyword succeeds    8min    30sec    Check Auditlog
    ...    kubectl_cmd=${kubectl_cmd}    alias=${alias}    log_file=${log_path}/auditlog
    ...    id=${id}
    [Teardown]  vDU Disconnect Interactive Connection    alias=${alias}

Generate Auditlog Get
    [Arguments]  ${namespase}=cran1  ${alias}=vDU
    ${pod_abbr}    set variable    logservice
    ${ctr_abbr}    set variable    logstorageserver
    set suite variable    ${_G_CONTAINER_PREFIX}    ctr-${namespase}-
    ${container_full_name}     Get Full Container Name By Container Abbreviation  ctr_abbr=${ctr_abbr}    vdu_index=0
    ${pod_full_name}    wait until keyword succeeds    3x    4sec    vDU Get Full Pod Name By Pod Abbreviation Interactively
    ...    pod_abbr=${pod_abbr}    alias=${alias}
    ${ns}   get_vdu_namespace_from_testline     gnb_index=0    vdu_index=0
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

check upload failed in snapshot history
    Log To Console   \ncheck upload failed in snapshot history
    vdu rest login
    ${file_path}    vdu.get_snapshot_history_file
    ${content}    OperatingSystem.Get File    ${file_path}
    ${check_log}    Get Regexp Matches    ${content}
    ...    failed\_reason[\\s\\S]*maxNumSnapByFaultTrigPerDay[\\s\\S]*exceeded[\\s\\S]*snapshot\_result[\\s\\S]*ignored
    ${check_log}    set variable    ${check_log[0]}
    [Teardown]  vDU Rest Logout

Set Syslog Substring Trigger Value
    [Arguments]    ${set_value}    ${operation}=replace    ${vdu_index}=0    ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    Log To Console   \nSet Syslog Substring Value to ${set_value}
    ${distname}    Set Variable   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${delta_data_list}=    Evaluate    [['${distname}', {'syslogSubstringTrigger': '${set_value}'}, '${operation}']]
    vdu_cm_business.delta_commission_step_by_step    delta_data_list=${delta_data_list}    conn_alias=${conn_alias}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Get Bts Name by Rest
    VDU Rest Login
    ${distname}    Set Variable   MRBTS-${mrbts_id}
    ${value}    Online Get VDU Parameter Value    mo_dn=${distname}    para_name=btsName
    [Teardown]  run keyword and ignore error    vDU Rest Logout
    [Return]    ${value}

Modify Bts Name by Rest
    [Arguments]    ${bts_name}=5gvDU_substring_test    ${vdu_index}=0    ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    Log To Console   \nModify bts name to ${bts_name}
    ${distname}    Set Variable   MRBTS-${mrbts_id}
    ${delta_data_list}=    Evaluate    [['${distname}', {'btsName': '${bts_name}'}, 'replace']]
    vdu_cm_business.delta_commission_step_by_step    delta_data_list=${delta_data_list}    conn_alias=${conn_alias}
    ${value}    Get Bts Name by Rest
    should be equal as strings    ${value}    ${bts_name}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Get Rannic Info From SCF
    [Arguments]    ${mrbts_id}    ${vdu_index}=0    ${gnb_index}=0
    log to console    Get Rannic Info
    vDU Rest Login   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${rnic_status}=    vdu.get_rnic_info_from_plan    mrbts_id=${mrbts_id}
    [Return]    ${rnic_status}
    [Teardown]  run keyword and ignore error    vDU Rest Logout

Get Rannic Number And ModList
    [Arguments]    ${mrbts_id}
    ${rnic_status}=    Get Rannic Info From SCF    mrbts_id=${mrbts_id}
    ${rnic_num}=   get length    ${rnic_status}
    @{rnic_mod_list}=  create list
    FOR   ${index}   IN RANGE   0    ${rnic_num}
        append to list    ${rnic_mod_list}   ${rnic_status[${index}]['r_nic_mod_dist_name']}
    END
    [Return]    ${rnic_num}    ${rnic_mod_list}

Trigger Rannic Reset
    [Arguments]    ${rnic_mod_dist_name}    ${vdu_index}=0    ${gnb_index}=0    ${timeout}=60
    log to console    start to reset rannic
    vDU Rest Login   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${response}    vdu.reset_rannic    rannic_r_dn=${rnic_mod_dist_name}    timeout=${timeout}
    ${operation_id} =    Set Variable    ${response}[id]
    Wait until keyword succeeds    3min    10s    Wait Rannic Reset operation success    ${operation_id}
    vdu.delete_rnic_rest_operation    operation_id=${operation_id}
    [Teardown]  run keyword and ignore error    vDU Rest Logout

Wait Rannic Reset operation success
    [Arguments]    ${operation_id}
    ${status}    vdu.get_rnic_reset_operation    operation_id=${operation_id}
    Should Be Equal As Strings    ${status["status"]}    success

Rannic Status Should Be As Expected
    [Arguments]    ${rnic_mod_list}    ${expected_operational_state}
    log to console    Check Rannic Status
    ${mrbts_id}=    Set Variable  ${rnic_mod_list[0].split('/')[0].split('-')[-1]}
    ${rnics_info}=    Get Rannic Info From SCF    mrbts_id=${mrbts_id}
    log to console    ${rnics_info}
    FOR  ${rnic_info}   IN  @{rnics_info}
        Run Keyword If  '${rnic_info}[r_nic_mod_dist_name]' in ${rnic_mod_list}   Run Keywords
        ...  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${rnic_info}[operational_state]  ${expected_operational_state}
        ...  AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${rnic_info}[procedural_status]  configured
    END

Trigger Rannic Reset and Check Fault
    log to console   Trigger Rannic Reset and Check Fault
    ${rnic_num}    ${rnic_mod_list}        Get Rannic Number And ModList    mrbts_id=${mrbts_id}
    log to console    ${rnic_mod_list}
    FOR   ${rnic_rmod}    IN   @{rnic_mod_list}
        log to console    ${rnic_rmod}
        run keyword and continue on failure    Trigger Rannic Reset    rnic_mod_dist_name=${rnic_rmod}
    END

Trigger Rannic Reset and Verify Cell status
    [Documentation]    Trigger Rannic Reset and Check Fault
    [Arguments]  @{para_list}
    log to console   Trigger Rannic Reset and Check Fault
    ${rnic_num}    ${rnic_mod_list}        Get Rannic Number And ModList    mrbts_id=${mrbts_id}
    log to console    ${rnic_mod_list}
    FOR   ${rnic_rmod}    IN   @{rnic_mod_list}
        log to console    ${rnic_rmod}
        run keyword and continue on failure    Trigger Rannic Reset    rnic_mod_dist_name=${rnic_rmod}
    END
    log to console   Check all vDU Cell status
    ${cell_list}    vDU Get Cells ID list
    Wait Until Keyword Succeeds   3min   10s    vDU Cells Status Should Be As Expected    cells_id_list=${cell_list}
    ...   blocking_state=Unblocked  operational_state=disabled   availability_status=off line

Wait Site Normal after Rannic Reset
    ${rnic_num}    ${rnic_mod_list}        Get Rannic Number And ModList    mrbts_id=${mrbts_id}
    wait until keyword succeeds    8min    60s    Rannic Status Should Be As Expected    rnic_mod_list=${rnic_mod_list}
    ...    expected_operational_state=enabled
    wait until keyword succeeds    8min    60s    vDU Verify All Cells Status Should Be Onair
    AlarmWatchdog.disallow_alarm    fault_id=4350

Check Rannic Reset in Auditlog
    [Documentation]    Check Rannic Reset in Auditlog
    ...    update 2024-09-19 by jie.2.li@nokia-sbell.com: https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10879
    [Arguments]  ${alias}=vDU
    ${ns}   Get vDU Namespace From TestLine   gnb_index=0   vdu_index=0
    vDU Connect To K8s Master Interactively    alias=${alias}
    ${log_path}  ${kubectl_cmd}    Generate Auditlog Get    namespase=${ns}    alias=${alias}
    wait until keyword succeeds    8min    30sec    Check Rannic Reset
    ...    kubectl_cmd=${kubectl_cmd}    alias=${alias}    log_file=${log_path}/auditlog
    [Teardown]  vDU Disconnect Interactive Connection    alias=${alias}

Check Rannic Reset
    [Arguments]  ${kubectl_cmd}    ${log_file}    ${alias}=vDU
    Log To Console   \nCheck auditlog
    ${rnic_num}    ${rnic_mod_list}        Get Rannic Number And ModList    mrbts_id=${mrbts_id}
    FOR   ${rnic_rmod}    IN   @{rnic_mod_list}
        ${content}    issh.Execute    command=${kubectl_cmd} -- cat ${log_file} | grep ${rnic_rmod}    alias=${alias}
        sleep    1
        ${check_log}    Get Regexp Matches    ${content}
        ...    "operationResult":"success"
        should not be empty    ${check_log}
    END


VDU Get Alias
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0   ${alias}=default
    [Documentation]  VDU Get Alias
    ...    author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   1.7.2023, chris.l.cao@nokia-sbell.com, support multip VDU operation
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    |  vdu_index  | No |  gnb index to indicate which vdu will be used  |
    ...    |  alias | No. | alias that identifies this connection |

	...
    ...    *RETURN VALUE*
    ...    the connection alias
    ...
    ...    Example
    ...    | ${alias} | VCU Get Alias   |  gnb_index=0   |
    ...
    Return From Keyword If   "${alias}"!="default"      ${alias}
    ${alias}   Set Variable If   ${gnb_index}==0 and ${vdu_index}==0   default   vdu_connection_${gnb_index}_${vdu_index}
    [Return]  ${alias}

vDU Get History Operation
    [Arguments]   ${start_timestamp}   ${end_timestamp}=${NONE}   ${ope_name_substring}=${NONE}   ${target}=${NONE}  ${vdu_index}=0
    [Documentation]    Get operation history by giving an operation type.
    ...  If not giving operation type (ope_name_substring=NONE), all operation histories which satisfied the time condition are returned.
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...  Change History
    ...  8.9.2023,  chris.l.cao@nokia-sbell.com, change KW name from 'vDU Get One Certain Type Of Operation History' to 'vDU Get History Operation'
    ...
    ...    | Input Parameters | Man. | Description |
    ...  | ope_name_substring  | No. | the substring of operation, like 'reset', 'login'. Default is None means all history will be get.|
    ...   | start_timestamp |Yes.| the start timestamp that used to filter operation history, can be assigned by keyword `get_current_utc_timestamp`|
    ...  |end_timestamp| No.| the end timestamp that used to filter operation history, can be get by `get_current_utc_timestamp`, default is NONE|
    ...  | target | No. | used to filter the operation history, for some operations (i.e. reset orlock), target is the targeted MO, default is None.|
    ...    | gnb_index | No. | the gnb index, default value is 0. |
    ...    | vdu_index | No. | the vdu index, default value is 0. |
    ...
    ...    *RETURN VALUE*
    ...     filterd operaion history list that satisfied filter conditions.
    ...
    ...    [{'end_time': '2023-08-21T20:08:24.423071+08:00',
    ...      'id': '344d8109-439c-496e-8397-eeada099d760',
    ...      'name': 'Trigger reset operation',
    ...      'session_id': '1827',
    ...      'start_time': '2023-08-21T20:07:59.045876+08:00',
    ...      'status': 'succeeded',
    ...      'targets': 'MRBTS-10700/NRBTS-10700',
    ...      'triggering_ip_address': '10.108.229.110',
    ...      'triggering_source': 'M2M',
    ...      'user_name': 'Nemuadmin'}]
    ...
    ...    Example
    ...    | ${start_timestamp} | Get Current Utc Timestamp |   |   |   |
    ...    |                    | do some operation, like `reset vdu by rest` |   |   |   |
    ...    | ${end_timestamp}   | Get Current Utc Timestamp |  |   |   |
    ...    | ${ope_history}    | vDU Get History Operation |  ${start_timestamp} |  ${end_timestamp} | reset |
    ...
    ${alias}   VDU Get Alias
    vDU Rest Login   vdu_index=${vdu_index}
    ${ope_history}      vdu.get_vdu_operation_history    vdu_connection=${alias}
	${target_ope_history_list}=   Filter Operation History
	...  ope_history=${ope_history}
	...  ope_name_substring=${ope_name_substring}
	...  start_timestamp=${start_timestamp}
	...  end_timestamp=${end_timestamp}
	...  target=${target}
	[Return]    ${target_ope_history_list}
	[Teardown]  run keyword and ignore error  vDU Rest Logout

Check rannic reset operation history from webem
    [Arguments]    ${operation_start_time}=${CASE_OPERATION_START_TIME}
    Log To Console   Check rannic reset operation history from webem
    ${history}    vDU Get History Operation    start_timestamp=${operation_start_time}    ope_name_substring=reset
    Should Be True  ${history.__len__()==1}
    Should Contain    ${history[0]["triggering_source"]}       WebEM

L3 Call And Throughput with Customize CELL List
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to verify that radio module
    ...    and OAM behaves correctly during procedure of radio module reset triggered by user from GUI with use of RP1 messaging.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Connect to vDU.
    ...        2. Reset RU.
    ...        3. Check cell disabled on vCU and vDU
    ...        4. Check RU should be normal
    ...        5. Check cell on air on vCU and vDU
    ...    - [EXPECTED RESULTS] the RU should reset successfully.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The gNB index. Default value is 0. |
    ...    | with_call | No | Flag for l3call. Default value is True. |
    ...    | suite_name | No | The suite name used for customed peak rate. Default value is default. |
    ...    | test_name | No | The test name used for customed peak rate. Default value is default. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 05.16.2025  - Created
    ...    *******************
    ...    * Owner_xiaomiaz
    ...    * Group: VRF_HAZ3_T02
    ...    *******************
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${with_call}=${True}   ${suite_name}=default   ${test_name}=default
    log to console    Get Cell id list from Vdu
    ${cell_list}    Cloud Get Cells Id List    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    log to console    rmods_info
    ${rmods}     Get Rmod List    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    Run Keyword If    ${with_call}    Cloud UE L3 Call And Throughput    cell_list=${cell_list}
    ...    test_name=${test_name}    suite_name=${suite_name}

VDU Reset Cell
    [Arguments]    ${cell_id}    ${connection}=default
    Log To Console    \n*** Reset Cell By REST ***
    vDU Rest Login   vdu_index=0
    ${dist_name}    Get Dist Name By Cell ID    ${cell_id}    connection=${connection}
    ${out}    vdu.reset_cells    dist_name=${dist_name}    vdu_connection=${connection}
    Sleep    30s    reason=wait for cell reset

Get Dist Name By Cell ID
    [Arguments]    ${cell_id}    ${connection}
    ${cells_status}    vdu.get_vdu_cells_status    vdu_connection=${connection}
    ${dist_name}    Set Variable    ${None}
    FOR    ${cell}    IN    @{cells_status}
        ${dist_name}=    Set Variable If    '${cell["id"]}' == '${cell_id}'    ${cell["dist_names"]["config"]}
        Run Keyword If    '${cell["id"]}' == '${cell_id}'    Exit For Loop
    END
    [Return]    ${dist_name}
