*** Settings ***
Documentation    This is for SG8 common keywords for cloud
...              Author: linjiangjing
...              Squard: HZ SG8

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library    SG8_common_cloud.py
Variables    SG8_cloud_alarm.py

*** Keywords ***
Setup Suite For Cloud
    log to console    ******Suite Setup******
    ${mrbtsID}    Set Variable     ${tl.gnbs[0].cu.instance_id}
    ${nrbtsID}    Set Variable     ${tl.gnbs[0].cu.global_bts_id}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}
    ${START_TIME}    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}
    ${SUITE_LOG_PATH}=    Get A Directory
    Set Suite Variable    ${SUITE_LOG_PATH}
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    vDU Login SG8
    ${vdu_state_data}    vdu.get_vdu_state_data
    ${du_software_verion}    set variable   ${vdu_state_data['software_version']}
    ${release_du}    ${version_du}    get_relase_and_version    software_verion=${du_software_verion}
    log to console    release of du is: ${release_du}, version of du is: ${version_du}
    set suite variable    ${release_du}
    set suite variable    ${version_du}
    set suite variable    ${scf_name_du_golden}    SCF_SBTS${release_du}_${version_du}.xml
    CU Login SG8
    ${cu_state_data}    cu.get_cu_state
    ${cu_software_verion}    set variable   ${cu_state_data['software_version']}
    ${release_cu}    ${version_cu}    get_relase_and_version    software_verion=${cu_software_verion}
    log to console    release of cu is: ${release_cu}, version of cu is: ${version_cu}
    set suite variable    ${release_cu}
    set suite variable    ${version_cu}
    set suite variable    ${scf_name_cu_golden}    SCF_SBTS${release_cu}_${version_cu}.xml
    [Teardown]    run keyword and ignore error    run keywords    vDU Logout SG8    AND    CU Logout SG8

Setup Test For Cloud
    log to console    *****Test setup*****
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    ${START_TIME}    Get time    exclude_millis=yes
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    log to console  case log path:${TS_CASE_LOG_PATH}
    ${cell_status}    run keyword and return status    Verify All Cells Status Should Be Onair for vDU
    ${ru_status}    run keyword and return status    Verify All Rmods Status Should Be Normal for vDU
    run keyword if    ${cell_status}==${False} or ${ru_status}==${False}   commission scf
    ...    vdu_scf_path=${scf_path_du}/${scf_name_du_golden}    cu_scf_path=${scf_path_cu}/${scf_name_cu_golden}
    ...    wait_for_completion=True

Teardown Test For Cloud
    [Arguments]    ${is_case_teardown}=${True}
    log to console    *****Test teardown*****
    robot_common_operations.Common Case Teardown
    ${ru_status}   run keyword and ignore error   Verify All Rmods Status Should Be Normal for vDU
    log to console  RU status: ${ru_status}
    ${ru_status_check_result}=    Run Keyword And Return Status    Should Contain    ${ru_status}    PASS
    ${cell_status}    run keyword and return status    Verify All Cells Status Should Be Onair for vDU
    should be true    ${cell_status}
    ${VDU_alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist For VDU
    ...    allowed_faults=@{ALLOWED_FAULT_VDU}
    should be true    ${VDU_alarm_status}
    ${VCU_alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist For VCU
    ...    allowed_faults=@{ALLOWED_FAULT_VCU}
    should be true    ${VCU_alarm_status}

#    ${fault1806_status}    Run Keyword And Return Status    Unexpect fault1806 Should Not Exist for special RU
#    Run Keyword If    not ${fault1806_status}    login_ru_by_control_pc_and_LMI_collect_rulog

    ${test_fail_flag}    run keyword if    ${is_case_teardown}    run keyword if test failed
    ...    set variable    ${True}
    ${test_fail_flag}    set variable if    ${test_fail_flag}    ${True}    ${False}
    run keyword if    ${save_snapshot} and ${test_fail_flag}    run keywords
    ...    Save Local Snapshot In vDU    AND    Save Local Snapshot In CU
    ...    ELSE
    ...    log to console    don't collect snapshot in test teardown!!!
    CI interface.Common Case Teardown

Teardown Suite For Cloud
    log to console    *****Suite teardown*****
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

commission scf
    [Arguments]    ${vdu_scf_path}    ${cu_scf_path}    ${wait_for_completion}=True
    log to console    commission scf for cu...
    CU Full Commsion By M2M API    scf_file=${cu_scf_path}    wait_for_completion=${wait_for_completion}
    log to console    commission scf for du...
    VDU Full Commsion By M2M API    scf_file=${vdu_scf_path}    wait_for_completion=${wait_for_completion}
    log to console    check cell status should be on air for du...
    wait until keyword succeeds     12min    30s    Verify All Cells Status Should Be Onair for vDU
    log to console    check ru status should be normal for du...
    wait until keyword succeeds     12min    30s    Verify All Rmods Status Should Be Normal for vDU
    log to console    check cell status should be on air for cu...
    wait until keyword succeeds     12min    30s    Verify All Cells Are Enabled for CU

Block Cell In vDU
    [Arguments]    ${cell_id}=1    ${vdu_index}=0    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${cell_id}    convert to string     ${cell_id}
    ${out}    vdu.block_cell    cell_id=${cell_id}    vdu_connection=${alias}
    Wait Until Keyword Succeeds  60   3   _Check Block Cell Should Be Expected   operation_id=${out["id"]}
    ...    expected_status=success    vdu_connection=${alias}
    vdu.delete_block_cell_operation    operation_id=${out["id"]}
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Block Cells In vDU
    [Arguments]    ${vdu_index}=0    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${cells}    Get CellList For vDU
    FOR    ${cell}    IN    ${cells}
            ${out}    vdu.block_cell    cell_id=${cell_id}    vdu_connection=${alias}
            Wait Until Keyword Succeeds  60   3   _Check Block Cell Should Be Expected   operation_id=${out["id"]}
            ...    expected_status=success    vdu_connection=${alias}
            vdu.delete_block_cell_operation    operation_id=${out["id"]}
    END
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Unblock Cell In vDU
    [Arguments]    ${cell_id}=1    ${vdu_index}=0    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${cell_id}    convert to string     ${cell_id}
    ${out}    vdu.unblock_cell    cell_id=${cell_id}    vdu_connection=${alias}
    Wait Until Keyword Succeeds  60   3   _Check Unblock Cell Should Be Expected   operation_id=${out["id"]}
    ...    expected_status=success    vdu_connection=${alias}
    vdu.delete_unblock_cell_operation   operation_id=${out["id"]}
    [Teardown]  Run keyword and ignore error    vDU Logout SG8

Unblock Cells In vDU
    [Arguments]    ${vdu_index}=0    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${cells}    Get CellList For vDU
    FOR    ${cell}    IN    ${cells}
            ${out}    vdu.unblock_cell    cell_id=${cell_id}    vdu_connection=${alias}
            Wait Until Keyword Succeeds  60   3   _Check Block Cell Should Be Expected   operation_id=${out["id"]}
            ...    expected_status=success    vdu_connection=${alias}
            vdu.delete_unblock_cell_operation    operation_id=${out["id"]}
    END
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Reset Rmod By Rest
    [Arguments]   ${rmods_list}   ${vdu_index}=0    ${alias}=default
    log to console   Reset RUs ${rmods_list} by REST...
    vDU Login SG8  vdu_index=${vdu_index}
    ${out}   vdu.reset_rmods     rmods_list=${rmods_list}    vdu_connection=${alias}
    Wait Until Keyword Succeeds  60   3   _Check Reset RUs Status Should Be Expected
    ...    operation_id=${out["operation_id"]}    expected_status=ongoing    vdu_connection=${alias}
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Reset vDU With Check Cell On Air
    [Arguments]    ${need_check_on_air}=${True}    ${vdu_index}=${0}    ${alias}=default
    vDU Login SG8  vdu_index=${vdu_index}
    ${out}    vdu.reset_vdu    vdu_connection=${alias}
    Should be True    "${out["status"]}"=="ongoing"
#    ${error_msg}    set variable  ${out["error_message"]}
#    should contain    ${error_msg}    No error
#    Wait Until Keyword Succeeds  60   10   _Check Reset VDU Status Should Be Expected    operation_id=${out["id"]}
#    ...    expected_status=ongoing    vdu_connection=${alias}
    sleep    60s
    Run Keyword If    ${need_check_on_air}   Wait Until Keyword Succeeds  1800s   30s
    ...    Verify All Cells Status Should Be Onair for VDU    vdu_index=${vdu_index}
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Verify All Cells Status Should Be Onair for vDU
    [Arguments]  ${vdu_index}=0    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${cells_status}=  vdu.get_vdu_cells_status     vdu_connection=${alias}
    FOR  ${cell}  IN  @{cells_status}
        Run keyword    Should be equal as strings    ${cell['operational_state']}    enabled
        ...  msg=operational_state for cell ${cell['id']} is not enabled
        Run keyword    Should be equal as strings    ${cell['availability_status']}    on line
        ...  msg=availability_status for cell ${cell['id']} is not on line
        Run keyword    Should be equal as strings    ${cell['administrative_state']}    Unlocked
        ...  msg=administrative_state for cell ${cell['id']} is not Unlocked
        Run keyword    Should be equal as strings    ${cell['procedural_status']}    configured
        ...  msg=procedural_status for cell ${cell['id']} is not configured
        Run keyword    Should be equal as strings    ${cell['blocking_state']}    Unblocked
        ...  msg=blocking_state for cell ${cell['id']} is not Unblocked
    END
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Verify All Cells Are Disabled for vDU
    [Arguments]  ${vdu_index}=0    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    sleep    1s
    ${cells_status}=    vdu.get_vdu_cells_status     vdu_connection=${alias}
    FOR  ${cell}  IN  @{cells_status}
        Run keyword    Should be equal as strings    ${cell['operational_state']}    disabled
        ...  msg=operational_state for cell ${cell['id']} is not disabled
    END
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Verify All RMOD Status Should Be enabled and locked for vDU
    [Arguments]  ${vdu_index}=0    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${rmods_status}=    vdu.get_rmods_status    vdu_connection=${alias}
    FOR  ${rmod}  IN  @{rmods_status}
        Run keyword    Should be equal as strings    ${rmod['operational_state']}    enabled
        ...  msg=operational_state for cell ${rmod} is not enabled
        Run keyword    Should be equal as strings    ${rmod['availability_status']}    on line
        ...  msg=availability_status for cell ${rmod} is not on line
        Run keyword    Should be equal as strings    ${rmod['administrative_state']}    Locked
        ...  msg=administrative_state for cell ${rmod} is not Unlocked
        Run keyword    Should be equal as strings    ${rmod['procedural_status']}    configured
        ...  msg=procedural_status for cell ${rmod} is not configured
    END
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Verify All RMOD Status Should enter deepsleep for vDU
    [Arguments]  ${vdu_index}=0    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${rmods_status}=    vdu.get_rmods_status    vdu_connection=${alias}
    FOR  ${rmod}  IN  @{rmods_status}
        Run keyword    Should be equal as strings    ${rmod['operational_state']}    enabled
        ...  msg=operational_state for cell ${rmod} is not enabled
        Run keyword    Should be equal as strings    ${rmod['availability_status']}    on line
        ...  msg=availability_status for cell ${rmod} is not on line
        Run keyword    Should be equal as strings    ${rmod['administrative_state']}    Unlocked
        ...  msg=administrative_state for cell ${rmod} is not Unlocked
        Run keyword    Should be equal as strings    ${rmod['procedural_status']}    configured
        ...  msg=procedural_status for cell ${rmod} is not configured
        Run keyword    Should be equal as strings    ${rmod['power_state']}    SLEEP
        ...  msg=procedural_status for cell ${rmod} is not SLEEP
    END
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Verify All RMOD Are Disabled for vDU
    [Arguments]  ${vdu_index}=0    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    sleep    1s
    ${rmods_status}=    vdu.get_rmods_status     vdu_connection=${alias}
    FOR  ${rmod}  IN  @{rmods_status}
        Run keyword    Should be equal as strings    ${rmod['operational_state']}    disabled
        ...  msg=operational_state for cell ${rmod} is not disabled
    END
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Verify All Cells Are Enabled for CU
    [Arguments]  ${gnb_index}=0
    CU Login SG8  ${gnb_index}
    sleep    1s
    ${cells_status}=   cu.get_cells_statuses
    FOR  ${cell}  IN  @{cells_status}
        Run keyword    Should be equal as strings    ${cell['operational_state']}    enabled
        ...  msg=operational_state for cell ${cell['id']} is not enabled
    END
    [Teardown]   run keyword and ignore error   CU Logout SG8

Verify All Cells Are Disabled for CU
    [Arguments]  ${gnb_index}=0
    CU Login SG8  ${gnb_index}
    ${cells_status}=   cu.get_cells_statuses
    FOR  ${cell}  IN  @{cells_status}
        Run keyword    Should be equal as strings    ${cell['operational_state']}    disabled
        ...  msg=operational_state for cell ${cell['id']} is not disabled
    END
    [Teardown]   run keyword and ignore error   CU Logout SG8

Get vDU Ru numbers
    [Arguments]    ${vdu_index}=0    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${rmods_status}    vdu.get_rmods_status    vdu_connection=${alias}
    ${rmods_num}    get length    ${rmods_status}
    [Return]    ${rmods_num}
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Get Rmod List
    [Arguments]    ${vdu_index}=0    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${rmods_status}    vdu.get_rmods_status    vdu_connection=${alias}
    ${rmods}  create list
    FOR    ${rmod}    IN    @{rmods_status}
        append to list    ${rmods}    ${rmod}[id]
    END
    [Return]    ${rmods}
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Get CellList For vDU
    [Arguments]    ${vdu_index}=0    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${cells_status}    vdu.get_vdu_cells_status    vdu_connection=${alias}
    ${cells}  create list
    FOR    ${cell}    IN    @{cells_status}
        append to list    ${cells}    ${cell}[id]
    END
    [Return]    ${cells}
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Get vDU Cell numbers
    [Arguments]    ${vdu_index}=0    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${cells_status}    vdu.get_vdu_cells_status    vdu_connection=${alias}
    ${cells_num}    get length    ${cells_status}
    [Return]    ${cells_num}
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Verify All Rmods Status Should Be Normal for vDU
    [Arguments]    ${vdu_index}=0    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${rmods_status}    vdu.get_rmods_status    vdu_connection=${alias}
    Should not be empty    ${rmods_status}
    FOR  ${ru}  IN  @{rmods_status}
        Run keyword    Should be equal as strings    ${ru['operational_state']}    enabled
        ...  msg=operational_state for ru ${ru['id']} is not enabled
        Run keyword    Should be equal as strings    ${ru['availability_status']}    on line
        ...  msg=availability_status for ru ${ru['id']} is not on line
        Run keyword    Should be equal as strings    ${ru['administrative_state']}    Unlocked
        ...  msg=administrative_state for ru ${ru['id']} is not Unlocked
        Run keyword    Should be equal as strings    ${ru['procedural_status']}    configured
        ...  msg=procedural_status for ru ${ru['id']} is not configured
    END
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Verify All Rmods Status Should Be Locked for vDU
    [Arguments]    ${vdu_index}=0    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${rmods_status}    vdu.get_rmods_status    vdu_connection=${alias}
    FOR  ${ru}  IN  @{rmods_status}
        Run keyword    Should be equal as strings    ${ru['administrative_state']}    Locked
        ...  msg=administrative_state for ru ${ru['id']} is not Locked
        Run keyword    Should be equal as strings    ${ru['availability_status']}    on line
        ...  msg=availability_status for ru ${ru['id']} is not on line
        Run keyword    Should be equal as strings    ${ru['operational_state']}    enabled
        ...  msg=operational_state for ru ${ru['id']} is not enabled
        Run keyword    Should be equal as strings    ${ru['procedural_status']}    configured
        ...  msg=procedural_status for ru ${ru['id']} is not configured
    END
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

reboot_asky_or_cpe_ue
    [Documentation]  Use adb command to reboot askey and cpe ue
    [Arguments]    ${ue_index}=${0}
    _Prepare Variables    ue_index=${ue_index}
    csn.connect to    hostname=${cpc_ip}    username=${cpc_username}    password=${cpc_password}  alias=cpc_${ue_index}    look_for_keys=False
    csn.execute    command=adb -s ${serial} root   connection=cpc_${ue_index}
    sleep    4s
    csn.execute    command=adb -s ${serial} reboot   connection=cpc_${ue_index}
    sleep    25s
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

vDU Update Full SCF By Rest
    [Arguments]    ${scf_path}    ${vdu_index}=0    ${alias}=default
    [Documentation]   send commission on one vdu, including upload validate and activate scf
    log to console    \n*** start send commission on vdu ***
    vDU Login SG8    vdu_index=${vdu_index}
    ${upload_plan_response}=    vdu.upload_plan    path_to_plan_file=${scf_path}    vdu_connection=${alias}
    wait until keyword succeeds    2min    5s    _Check Upload Plan Status Should Be Expected
    ...    expected_status=success    upload_action_id=${upload_plan_response['action_id']}
    ${validate_plan_response}=    vdu.validate_plan    plan_id=${upload_plan_response['plan_id']}
    ...    vdu_connection=${alias}
    wait until keyword succeeds    2min    5s    _Check Validate Plan Status Should Be Expected
    ...    plan_id=${upload_plan_response['plan_id']}    action_id=${validate_plan_response['action_id']}
    ...    expected_status=success
    ${activate_plan_response}=    vdu.activate_plan    plan_id=${upload_plan_response['plan_id']}
    ...    vdu_connection=${alias}
    sleep    90s    reason=Wait for activate sucessful
    wait until keyword succeeds    10min    20s    _Check Activate Plan Status Should Be Expected
    ...    plan_id=${upload_plan_response['plan_id']}    action_id=${activate_plan_response['id']}
    ...    expected_status=success
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Lock RU In vDU
    [Arguments]    ${rmod_id_list}    ${vdu_index}=${0}    ${timeout}=${60}    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${out}    vdu.lock_rmods    rmod_id_list=${rmod_id_list}    timeout=${timeout}    vdu_connection=${alias}
    Wait Until Keyword Succeeds  60   3   _Check Lock RU Should Be Expected   operation_id=${out["id"]}
    ...    expected_status=ongoing    vdu_connection=${alias}
    [Teardown]  Run keyword and ignore error    vDU Logout SG8

Unlock RU In vDU
    [Arguments]    ${rmod_id_list}    ${vdu_index}=${0}    ${timeout}=${60}    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${out}    vdu.unlock_rmods    rmod_id_list=${rmod_id_list}    timeout=${timeout}    vdu_connection=${alias}
    Wait Until Keyword Succeeds  120   3   _Check Unlock RU Should Be Expected   operation_id=${out["id"]}
    ...    expected_status=ongoing    vdu_connection=${alias}
    [Teardown]  Run keyword and ignore error    vDU Logout SG8

_Check Lock RU Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}    ${vdu_connection}=default
    ${out}    vdu.get_operation_state_of_locking_rmods    operation_id=${operation_id}    timeout=${timeout}
    ...    vdu_connection=${vdu_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"

_Check Unlock RU Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}    ${vdu_connection}=default
    ${out}    vdu.get_operation_state_of_locking_rmods    operation_id=${operation_id}    timeout=${timeout}
    ...    vdu_connection=${vdu_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"

_Check Block Cell Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}    ${vdu_connection}=default
    ${out}    vdu.get_block_cell_operation_status    operation_id=${operation_id}    timeout=${timeout}
    ...    vdu_connection=${vdu_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"

_Check Unblock Cell Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}     ${vdu_connection}=default
    ${out}    vdu.get_unblock_cell_operation_status    operation_id=${operation_id}    timeout=${timeout}
    ...    vdu_connection=${vdu_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"

_Check Reset RUs Status Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}     ${vdu_connection}=default
    ${out}    vdu.get_reset_rmods_operation_status    operation_id=${operation_id}    timeout=${timeout}
    ...    vdu_connection=${vdu_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"

_Check Reset VDU Status Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}     ${vdu_connection}=default
    ${out}    vdu.get_reset_vdu_operation_status    operation_id=${operation_id}    timeout=${timeout}
    ...    vdu_connection=${vdu_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"

_Check Upload Plan Status Should Be Expected
    [Arguments]    ${upload_action_id}    ${expected_status}    ${vdu_connection}=default
    [Documentation]    checking upload plan operation status should be successful
    ${upload_operation_response}=    vdu.get_upload_plan_operation_status    operation_id=${upload_action_id}
    ...    vdu_connection=${vdu_connection}
    should be equal as strings    "${upload_operation_response['status']}"    "${expected_status}"

_Check Validate Plan Status Should Be Expected
    [Arguments]    ${plan_id}    ${action_id}    ${expected_status}    ${timeout}=${60}    ${vdu_connection}=default
    [Documentation]   checking validate plan operation status should be successful
    ${validate_plan_response}=    vdu.get_validate_plan_operation_status    plan_id=${plan_id}
    ...    operation_id=${action_id}    timeout=${timeout}    vdu_connection=${vdu_connection}
    should be equal as strings    "${validate_plan_response['status']}"    "${expected_status}"
    [Return]    ${validate_plan_response}

_Check Activate Plan Status Should Be Expected
    [Arguments]    ${plan_id}    ${action_id}    ${expected_status}    ${timeout}=${60}    ${vdu_connection}=default
    ${activate_plan_response}=    vdu.get_activate_plan_operation_status    plan_id=${plan_id}
    ...    operation_id=${action_id}    timeout=${timeout}    vdu_connection=${vdu_connection}
    should be equal as strings    "${activate_plan_response['status']}"    "${expected_status}"

Expect Fault Should Present On vDU
    [Arguments]    ${fault_id}    ${alarming_object}=${None}    ${severity}=${None}    ${alarm_id}=${None}
    ...            ${vdu_index}=0    ${alias}=default
    ${fault_id}    Convert To Integer    ${fault_id}
    vDU Login SG8    vdu_index=${vdu_index}
    ${alarms}    vdu.vdu_get_active_alarms    vdu_connection=${alias}
    ${alarm_num}    Get From Dictionary    ${alarms}    total
    Run Keyword If    ${alarm_num}==0    Fail
    ${alarms}    Get From Dictionary    ${alarms}    alarms
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
        ${present_status}    Run Keyword And Return Status    Run Keywords
        ...    Dictionary Should Contain Item    ${alarm}    fault_id    ${fault_id}    AND
        ...    Run Keyword If    '${alarming_object}'!='${None}'
        ...    Should Contain     ${alarm['alarming_object']}    ${alarming_object}    case_insensitive=True    AND
        ...    Run Keyword If    '${severity}'!='${None}'
        ...    Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
        ...    Run Keyword If    '${alarmId}'!='${None}'
        ...    Should Be Equal As Strings    ${alarm['alarm_id']}    ${alarm_id}
        Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail
    [Teardown]  Run keyword and ignore error    vDU Logout SG8

Expect Fault Should Present On VCU
    [Arguments]    ${fault_id}    ${alarming_object}=${None}    ${severity}=${None}    ${alarm_id}=${None}
    ...            ${gnb_index}=0    ${alias}=default
    ${fault_id}    Convert To Integer    ${fault_id}
    CU Login SG8  ${gnb_index}
    ${alarms}    cu.get_active_alarms    connection=${alias}
    ${alarm_num}    Get From Dictionary    ${alarms}    total
    Run Keyword If    ${alarm_num}==0    Fail
    ${alarms}    Get From Dictionary    ${alarms}    alarms
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
        ${present_status}    Run Keyword And Return Status    Run Keywords
        ...    Dictionary Should Contain Item    ${alarm}    fault_id    ${fault_id}    AND
        ...    Run Keyword If    '${alarming_object}'!='${None}'
        ...    Should Contain     ${alarm['alarming_object']}    ${alarming_object}    case_insensitive=True    AND
        ...    Run Keyword If    '${severity}'!='${None}'
        ...    Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
        ...    Run Keyword If    '${alarmId}'!='${None}'
        ...    Should Be Equal As Strings    ${alarm['alarm_id']}    ${alarm_id}
        Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail
    [Teardown]  Run keyword and ignore error    CU Login SG8

Expect history Fault Should Present On vDU
    [Arguments]    ${fault_id}    ${alarming_object}=${None}    ${severity}=${None}    ${alarm_id}=${None}
    ...            ${vdu_index}=0    ${alias}=default
    ${fault_id}    Convert To Integer    ${fault_id}
    vDU Login SG8    vdu_index=${vdu_index}
    ${alarms}    vdu.vdu_get_historical_alarms    vdu_connection=${alias}
    ${alarm_num}    Get From Dictionary    ${alarms}    total
    Run Keyword If    ${alarm_num}==0    Fail
    ${alarms}    Get From Dictionary    ${alarms}    alarms
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
        ${present_status}    Run Keyword And Return Status    Run Keywords
        ...    Dictionary Should Contain Item    ${alarm}    fault_id    ${fault_id}    AND
        ...    Run Keyword If    '${alarming_object}'!='${None}'
        ...    Should Contain     ${alarm['alarming_object']}    ${alarming_object}    case_insensitive=True    AND
        ...    Run Keyword If    '${severity}'!='${None}'
        ...    Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
        ...    Run Keyword If    '${alarmId}'!='${None}'
        ...    Should Be Equal As Strings    ${alarm['alarm_id']}    ${alarm_id}
        Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail
    [Teardown]  Run keyword and ignore error    vDU Logout SG8

Expect Fault Should Absent On vDU
    [Arguments]   ${fault_id}   ${alarming_object}=${None}    ${severity}=${None}    ${alarm_id}=${None}
    ...    ${vdu_index}=0    ${alias}=default
    ${fault_id}    Convert To Integer    ${fault_id}
    vDU Login SG8    vdu_index=${vdu_index}
    ${status}    Run Keyword And Return Status   Expect Fault Should Present On vDU
    ...          fault_id=${fault_id}
    ...          alarming_object=${alarming_object}
    ...          severity=${severity}
    ...          alarm_id=${alarm_id}
    ...          vdu_index=${vdu_index}
    ...          alias=${alias}
    Run Keyword If  ${status}==${True}   Fail
    [Teardown]  Run keyword and ignore error    vDU Logout SG8

Check Cell Should Be Blocked On vDU
    [Arguments]  ${cell_id}=${1}    ${vdu_index}=0    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${cells_status}=  vdu.get_vdu_cells_status     vdu_connection=${alias}
    FOR  ${cell}  IN  @{cells_status}
        Run keyword if    '${cell_id}'!='${cell}[id]'    Continue For Loop
        Should Be Equal As Strings  ${cell["operational_state"]}    disabled
        Should Be Equal As Strings  ${cell["availability_status"]}    off line
        Should Be Equal As Strings  ${cell["administrative_state"]}    Unlocked
        Should Be Equal As Strings  ${cell["blocking_state"]}    Blocked
        Should Be Equal As Strings  ${cell["procedural_status"]}    configured
    END
    [Teardown]  Run keyword and ignore error    vDU Logout SG8

get mapping long cell id
    [Arguments]    ${vdu_index}=0    ${cell_id}=1    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${cells_status}    vdu.get_vdu_cells_status    vdu_connection=${alias}
    FOR  ${cell}  IN  @{cells_status}
        return from keyword if    '${cell_id}'=='${cell['id']}'     ${cell['nr_cell_identity']}
    END
    [Return]    ${None}
    [Teardown]  Run keyword and ignore error    vDU Logout SG8

make_call_and_check_tput_for_all_cells
    [Documentation]    make call for all pointed cell.
    ...  :author  linjiangjing
    ...  :param  tput_info: E.G
    ...          {
    ...              1: {
    ...                  'dl_exp': 300,
    ...                  'dl_tp': '500M',
    ...                  'ul_exp': 20,
    ...                  'ul_tp': '50M',
    ...                  'ue_index': 0
    ...              },
    ...          }
    ...  :param  cell_list: E.G [1, 2]
    [Arguments]    ${ue_type}    ${tput_info}    ${cell_list}    ${protocol}=udp    ${duration}=600
    ...    ${gnb_index}=0    ${vdu_index}=0    ${target_avg_percent}=0.95    ${min_percent}=0.85    ${process_num}=1
    ...    ${appserver}=APPserver
    ${ue_index_list}    create list
    set test variable    ${ue_index_list}
    FOR  ${cell_index}  IN  @{cell_list}
        ${ue_index}    set variable    ${tput_info[${cell_index}]['ue_index']}
        log to console    use ue${ue_index} to make call on cell${cell_index}
        ${tput_cell}    set variable    ${tput_info[${cell_index}]}
        log to console    tput info for cell ${cell_index} is: ${tput_cell}
        make_call    tput_info=${tput_cell}    ue_index=${ue_index}    protocol=${protocol}    ue_type=${ue_type}
        ...    process_num=${process_num}    appserver=${appserver}
    END
    ${tput_log}    Collect Tput from VDU    gnb_index=${gnb_index}     vdu_index=${vdu_index}   duration=${duration}
    FOR  ${cell_index}  IN  @{cell_list}
        ${ue_index}    set variable    ${tput_info[${cell_index}]['ue_index']}
        check_tput_for_each_cell    ue_type=${ue_type}    tput_info=${tput_info}    cell_id=${cell_index}
        ...    tput_log=${tput_log}    target_avg_percent=${target_avg_percent}
        ...    min_percent=${min_percent}
    END
    [Teardown]    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    ...    protocol=${protocol}

data_transfer_common
    [Documentation]    make call for all pointed cell.
    ...  :author  linjiangjing
    ...  :param  cell_id: if cell_id is not None, make call according cell_id list. E.G [1, 2]
    ...  :param  ru_index: if cell_id is None, and ru_index is not None, make call on cells under the pointed ru. E.G 1
    ...                    if both cell_id and ru_index are None, make call on all cells
    [Arguments]    ${ue_type}    ${tput_self_define}    ${ru_index}=${1}    ${cell_id}=${None}
    ...    ${target_avg_percent}=${0.95}    ${min_percent}=${0.85}    ${protocol}=udp    ${duration}=${600}
    ...    ${gnb_index}=0    ${vdu_index}=0    ${loop_times}=${2}    ${process_num}=1    ${appserver}=APPserver
    ${cell_list}    run keyword if    ${cell_id}!=${None}    set variable    ${cell_id}
    ...    ELSE    Get Cell Ids Related To Pointed RU    ru_index=${ru_index}
    FOR  ${i}  IN RANGE  ${loop_times}
        ${status}    run keyword and return status    make_call_and_check_tput_for_all_cells
        ...    tput_info=${tput_self_define}    cell_list=${cell_list}    protocol=${protocol}
        ...    duration=${duration}    gnb_index=${gnb_index}    vdu_index=${vdu_index}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    ue_type=${ue_type}
        ...    process_num=${process_num}    appserver=${appserver}
        exit for loop if    ${status}
    END
    run keyword if      not ${status}    FAIL

make_call
    [Documentation]    use pointed ue to make call
    ...  :author  linjiangjing
    ...  :param  tput_info: dict, should contain dl_tp and ul_tp. E.G
    ...          {
    ...              'dl_tp': '500M',
    ...              'ul_tp': '50M',
    ...          }
    [Arguments]    ${ue_type}    ${tput_info}    ${ue_index}=0    ${protocol}=udp
    ...    ${duration_call}=${1800}    ${process_num}=1    ${appserver}=APPserver
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    append to list    ${ue_index_list}    ${ue_index}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
    ${dl_tp}    set variable    ${tput_info['dl_tp']}
    ${ul_tp}    set variable    ${tput_info['ul_tp']}
    ${dl_tp}    set variable   ${dl_tp}
    ${ul_tp}    set variable   ${ul_tp}
    log to console    start dl traffic...
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${process_num}
    ...    appserver=${appserver}
    log to console    start ul traffic...
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}
    ...    appserver=${appserver}    data_amount=2M    process_num=${process_num}

traffic_stop_and_detach_ue
    [Documentation]    stop traffic and detach ue
    ...  :author  linjiangjing
    ...  :param  ue_index_list E.G [0], [0,1]
    [Arguments]    ${ue_index_list}    ${protocol}=udp
    FOR  ${ue_index}  IN    @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
        ...    ue_index=${ue_index}    protocol=${protocol}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
        ...    ue_index=${ue_index}    iperf_type=${iperf_type}    protocol=${protocol}
        run keyword and ignore error    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    END

check_tput_for_each_cell
    [Documentation]    check tput for pointed cell
    ...  :author  linjiangjing
    ...  :param  tput_info    dict, key is cell id. value should contain dl_exp and ul_exp. E.G
    ...          {
    ...              1: {
    ...                  'dl_exp': 300,
    ...                  'ul_exp': 20,
    ...              },
    ...          }
    ...  :param  cell_id E.G 1
    ...  :param  ue_index E.G 0
    ...  :param  tput_log  output of power_ue.Collect Tput
    [Arguments]    ${ue_type}    ${tput_info}    ${cell_id}    ${tput_log}    ${target_avg_percent}=0.95
    ...    ${min_percent}=0.85
    ${cell_id}    convert to integer  ${cell_id}
    ${dl_exp}    set variable    ${tput_info[${cell_id}]['dl_exp']}
    ${ul_exp}    set variable    ${tput_info[${cell_id}]['ul_exp']}
    ${cell_id}    get mapping long cell id    cell_id=${cell_id}
    ${cell_id}    Create List    ${cell_id}
    ${output}    power_ue.Check Bi Tput   ue_type=${ue_type}    log=${tput_log}    cells=${cell_id}
    ...    ultarget_throughput=${ul_exp}    dltarget_throughput=${dl_exp}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}
    log to console    \n${output}

Collect Tput from VDU
    [Arguments]    ${gnb_index}=0     ${vdu_index}=0    ${duration}=600
    ${handle}    vDU Begin K8s Log    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    Set test variable    ${handle}
    ${container_prefix}    vDU Get Container Name Prefix SG08
    sleep    ${duration}s
    ${tput_log}    vDU End K8s Log      handle=${handle}     pod_abbr=l2rt     container=${container_prefix}l2rt
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    [Return]    ${tput_log}

Get Cell Ids Related To Pointed RU
    [Arguments]  ${ru_index}    ${vdu_index}=0    ${alias}=default
    ${ru_index}    convert to string     ${ru_index}
    vDU Login SG8    vdu_index=${vdu_index}
    ${rmods_status}    vdu.get_rmods_status    vdu_connection=${alias}
    FOR    ${rmod}    IN    @{rmods_status}
        return from keyword if    ${rmod}[id]==${ru_index}     ${rmod}[cell_ids]
    END
    [Return]    ${None}
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Connect To vDU K8s Master
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0  ${alias}=default
    [Documentation]   Connect To K8s Master In vDU
    ${vdu_k8s_master_ssh_connection_info}    Get vDU K8s Master SSH Connection Info    gnb_index=${gnb_index}
    ...    vdu_index=${vdu_index}
    ${ip}    set variable    ${vdu_k8s_master_ssh_connection_info["addr"]}
    ${username}    set variable    ${vdu_k8s_master_ssh_connection_info["username"]}
    ${password}    set variable    ${vdu_k8s_master_ssh_connection_info["password"]}
    issh.Connect_To    ip=${ip}    username=${username}    password=${password}
       ...   prompt=\\$
       ...   alias=${alias}
       ...   width=200
       ...   timeout=150

Get vDU K8s Master SSH Connection Info
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0
    [Documentation]    this kw is used to Get vDU K8s Master SSH Connection Info
    ${result}    ${addr}        Run Keyword And Ignore Error
    ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    Should Be True    "${result}"=="PASS"    Please give K8s Master SSH ip in __init__.py for vdu_index=${vdu_index}

    ${result}    ${username}    Run Keyword And Ignore Error
    ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    Should Be True  "${result}"=="PASS"    Please give K8s Master SSH username in __init__.py for vdu_index=${vdu_index}

    ${result}    ${password}    Run Keyword And Ignore Error
    ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    Should Be True  "${result}"=="PASS"    Please give K8s Master SSH password in __init__.py for vdu_index=${vdu_index}

    ${result}    ${port}        Run Keyword And Ignore Error
    ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.port}
    Should Be True    "${result}"=="PASS"    Please give K8s Master SSH port in __init__.py for vdu_index=${vdu_index}

    ${du_info}    create dictionary    addr=${addr}    username=${username}    password=${password}    port=${port}
    [Return]  ${du_info}

login ru
    [Arguments]    ${alias}    ${ru_ip}    ${password}    ${username}=serviceuser
    ...   ${prompt_ru}=Node0:~#    ${need_login_node}=${True}    ${ru_node_ip}=192.168.101.2    ${ru_node_index}=1
    ${cmd}    Set Variable    ssh -o StrictHostKeyChecking=no ${username}@${ru_ip}
    ${old_prompt}    issh.get prompt    alias=${alias}
    issh.set prompt   ${old_prompt}|password:   alias=${alias}
    ${out}    issh.Execute   command=${cmd}    alias=${alias}     check_result=${False}
    issh.set prompt   ${old_prompt}|\\$|${prompt_ru}   alias=${alias}
    issh.Execute    command=${password}     alias=${alias}    check_result=${False}
    sleep   3
    Run Keyword If   '${need_login_node}'=='True'   issh.set prompt   ${old_prompt}|Node${ru_node_index}:~#   alias=${alias}
    Run Keyword If   '${need_login_node}'=='True'   issh.Execute    command=ssh ${ru_node_ip}     alias=${alias}
    ...    check_result=${False}
    Run Keyword If   '${need_login_node}'=='True'   sleep   3

get ru ip
    [Arguments]    ${alias}    ${ns}
    ${container_name}=    set variable if    '${release_du}'=='25R3'    ctr-${ns}-oamfh    ctr-oamfh
    ${pod_name}=    set variable if    '${release_du}'=='25R3'   po-${ns}-oamfh-0    po-oamfh-0
    ${cmd}    set variable    kubectl exec -it ${pod_name} -n ${ns} -c ${container_name} -- bash
    run keyword and ignore error    issh.Execute  command=${cmd}
     ...   check_result=${False}
     ...   alias=${alias}
    sleep    5s
    ${cmd}    set variable    arp -a
    ${r}    ${out}    run keyword and ignore error    issh.Execute  command=${cmd}
     ...   check_result=${False}
     ...   alias=${alias}
    @{lines}    Split String	   ${out}    separator=\r\n
    ${result}  create list
    FOR    ${line}    IN    @{lines}
        ${status}    Run Keyword And Return Status    Should End With    ${line}    [ether] on fhmplane
        run keyword if    ${status}    append to list    ${result}    ${line}
    END
    ${result}    set variable    ${result}[-1]
    ${result}    Fetch From Left    ${result}    )
    ${result}    Fetch From Right    ${result}    (
    log to console    ru ip is: ${result}
    [Return]    ${result}

Save Local Snapshot In vDU
    [Arguments]    ${local_snapshot_location}=vdu_snapshot    ${vdu_index}=${0}    ${compressed_or_not}=${True}
    log to console    Save vdu Local Snapshot...
    vDU Login SG8    vdu_index=${vdu_index}
    set test variable  ${Snapshot_path}    ${SAVE LOG DIRECTORY}${local_snapshot_location}
    create directory   ${Snapshot_path}
    ${Snapshot_file_path}    vdu.Get_Local_Snapshot    ${Snapshot_path}    compressed_or_not=${compressed_or_not}
    [Return]    ${Snapshot_file_path}
    [Teardown]  Run keyword and ignore error    vDU Logout SG8

Save Local Snapshot In CU
    [Arguments]    ${local_snapshot_location}=cu_snapshot    ${gnb_index}=${0}
    log to console    Save cu Local Snapshot...
    CU Login SG8    gnb_index=${gnb_index}
    set test variable  ${Snapshot_path}    ${SAVE LOG DIRECTORY}${local_snapshot_location}/
    create directory   ${Snapshot_path}
    ${Snapshot_file_path}    cu.Get_Local_Snapshot    ${Snapshot_path}
    [Return]    ${Snapshot_file_path}
    [Teardown]    Run Keyword And Ignore Error    CU Logout SG8

Unexpect Alarm Should Not Exist For VDU
    [Arguments]   ${allowed_faults}    ${vdu_index}=${0}    ${file_path}=${TS_CASE_LOG_PATH}    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${alarms}    vdu.vdu_get_active_alarms    vdu_connection=${alias}
    ${active_alarms_list}    Get From Dictionary    ${alarms}    alarms
    ${active_alarms_num}     Get From Dictionary    ${alarms}    total
    ${unexpect_alarms}    Create List
    FOR  ${alarm}  IN  @{active_alarms_list}
       Exit For Loop If   ${active_alarms_num}==${0}
       ${status}   Run Keyword And Return Status   Check Alarm Is Allowed For Cloud
       ...                                         allowed_alarm_list=${allowed_faults}
       ...                                         check_alarm=${alarm}
       Run Keyword If   ${status}==${False}    Append To List    ${unexpect_alarms}   ${alarm}
       Run Keyword If   ${status}==${False}    Log to console    Unexpect Active Alarm : ${alarm['fault_id']}
    END
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${unexpect_alarm_file}    Set variable    ${file_path}/vdu_unexpect_active_alarms_${timestamp}.txt
    ${alarm_num}   Get Length   ${unexpect_alarms}
    Run Keyword If  ${alarm_num}!=${0}    Run   command=echo "unexpect alarm number:${alarm_num}">${unexpect_alarm_file}
    FOR  ${alarm}  IN  @{unexpect_alarms}
        Exit For Loop If  ${alarm_num}==${0}
        run    command=echo "${alarm}">>${unexpect_alarm_file}
    END
    Run Keyword If   ${alarm_num}!=${0}   fail   ${alarm_num} alarms are not allowed, details in log: ${unexpect_alarm_file}
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Unexpect Alarm Should Not Exist For VCU
    [Arguments]   ${allowed_faults}    ${gnb_index}=${0}    ${file_path}=${TS_CASE_LOG_PATH}    ${alias}=default
    CU Login SG8    gnb_index=${gnb_index}
    ${alarms}    cu.get_active_alarms    connection=${alias}
    ${active_alarms_list}    Get From Dictionary    ${alarms}    alarms
    ${active_alarms_num}     Get From Dictionary    ${alarms}    total
    ${unexpect_alarms}    Create List
    FOR  ${alarm}  IN  @{active_alarms_list}
       Exit For Loop If   ${active_alarms_num}==${0}
       ${status}   Run Keyword And Return Status   Check Alarm Is Allowed For Cloud
       ...                                         allowed_alarm_list=${allowed_faults}
       ...                                         check_alarm=${alarm}
       Run Keyword If   ${status}==${False}    Append To List    ${unexpect_alarms}   ${alarm}
       Run Keyword If   ${status}==${False}    Log to console    Unexpect Active Alarm : ${alarm['fault_id']}
    END
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${unexpect_alarm_file}    Set variable    ${file_path}/vcu_unexpect_active_alarms_${timestamp}.txt
    ${alarm_num}   Get Length   ${unexpect_alarms}
    Run Keyword If  ${alarm_num}!=${0}    Run   command=echo "unexpect alarm number:${alarm_num}">${unexpect_alarm_file}
    FOR  ${alarm}  IN  @{unexpect_alarms}
        Exit For Loop If  ${alarm_num}==${0}
        run    command=echo "${alarm}">>${unexpect_alarm_file}
    END
    Run Keyword If   ${alarm_num}!=${0}   fail   ${alarm_num} alarms are not allowed, details in log: ${unexpect_alarm_file}
    [Teardown]    Run Keyword And Ignore Error    CU Logout SG8

Check Alarm Is Allowed For Cloud
    [Arguments]   ${allowed_alarm_list}     ${check_alarm}
    ${allowed_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{allowed_alarm_list}
        ${allowed_status}    Run Keyword And Return Status
        ...                  Should Be Equal    ${check_alarm['fault_id']}    ${alarm['faultId']}
        Exit For Loop If   ${allowed_status}
    END
    ${msg}    set variable    fault ${check_alarm['fault_id']} report by ${check_alarm['alarming_object']} is not allow
    Run Keyword If  ${allowed_status}==${False}  Fail    ${msg}

Get Pointed Counter For vDU
    [Arguments]    ${counter_id}     ${dimension_dn}    ${vdu_index}=0
    vDU Login SG8    vdu_index=${vdu_index}
    ${counters}=    vdu.get_counter_values    ${counter_id}    ${dimension_dn}
    [Return]    ${counters}
    [Teardown]    Run Keyword And Ignore Error    vDU Logout SG8

Get Last Pointed Counter For vDU
    [Arguments]    ${counter_id}     ${dimension_dn}    ${vdu_index}=0
    vDU Login SG8    vdu_index=${vdu_index}
    ${counters}=    vdu.get_counter_values    ${counter_id}    ${dimension_dn}
    ${counter_last}    set variable    ${counters[-1]}
    [Return]    ${counter_last}
    [Teardown]  Run keyword and ignore error    vDU Logout SG8

vDU Get Container Name Prefix SG08
    [Documentation]   Get Container Name Prefix
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...    *RETURN VALUE*
    ...    Container Name Prefix, e.g, ctr-cran1-
    ...    Example
    ...    | ${container_prefix} | Get Container Name Prefix |
    ...    | ${container_prefix} | Get Container Name Prefix | vdu_index=0 |
    ${r}  ${out}  run keyword and ignore error   set variable   ${_G_CONTAINER_PREFIX}
    return from keyword if  "${r}"=="PASS"   ${_G_CONTAINER_PREFIX}

    ${_G_CONTAINER_PREFIX}   _Get Container Name Prefix Internal Use SG08
    set suite variable   ${_G_CONTAINER_PREFIX}

    [Return]  ${_G_CONTAINER_PREFIX}

_Get Container Name Prefix Internal Use SG08
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  run keyword and ignore error  fast_disconnect  alias=${alias}
#    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]   _Get Container Name Prefix Internal Use
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   14.8.2021,chris.l.cao@nokia-sbell.com, change from tenant to admin account to adapt OCP
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...    *RETURN VALUE*
    ...    Container Name Prefix, e.g, ctr-cran1-
    ...    Example
    ...    | ${container_prefix} | _Get Container Name Prefix Internal Use |
    ...    | ${container_prefix} | _Get Container Name Prefix Internal Use | vdu_index=0 |
    ${pod_prefix}   _Get Pod Name Prefix Internal Use
    ${alias}  get unique id
    fast_connect_to_k8s_master  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${command}  Set Variable  kubectl describe pod ${pod_prefix}l2rt-0
    #${with_pipeline_command}  Set Variable  |grep l1hi:|head -n 1|awk -F l1hi '{print $1}'
	#${with_pipeline_command}  Set Variable  |grep l2hi:|head -n 1|awk -F l2hi '{print $1}'
	#${with_pipeline_command}  Set Variable  |grep -w CONTAINER_NAME:|sed -e 's/ //g'|awk -F ":" '{print $2}'|awk -F "l2" '{print $1}'
	${with_pipeline_command}  Set Variable  |grep -w CONTAINER_NAME:|sed -e 's/ //g'|awk -F ":" '{print $2}'|awk -F "l2" '{print $1}' | grep -v "nwmgmt"
    ${container_prefix}  fast_execute   command=${command}  with_pipeline_command=${with_pipeline_command}
     ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}

    [Return]  ${container_prefix}

Get Rannic Info From SCF
    [Arguments]    ${mrbts_id}=${EMPTY}    ${vdu_index}=0
    log to console    Get Rannic Info From SCF
    vDU Login SG8    vdu_index=${vdu_index}
    ${rnic_status}=    vdu.get_rnic_info_from_plan    mrbts_id=${mrbts_id}
    [Return]    ${rnic_status}
    [Teardown]  Run keyword and ignore error    vDU Logout SG8

Get Rannic Number And ModList
    [Arguments]    ${mrbts_id}    ${return_list}=${False}
    ${rnic_status}=    Get Rannic Info From SCF    mrbts_id=${mrbts_id}
    ${rnic_num}=   get length    ${rnic_status}
    @{rnic_mod_list}=  create list
    FOR   ${index}   IN RANGE   0    ${rnic_num}
       append to list  ${rnic_mod_list}   ${rnic_status[${index}]['r_nic_mod_dist_name']}
    END
    Return From Keyword If    "${return_list}"=="${True}"      ${rnic_num}    ${rnic_mod_list}
    [Return]    ${rnic_num}    @{rnic_mod_list}

Trigger Rannic Reset
    [Arguments]    ${rnic_mod_dist_name}    ${vdu_index}=0    ${timeout}=60
    log to console    start to reset rannic
    vDU Login SG8    vdu_index=${vdu_index}
    ${response}    vdu.reset_rannic    rannic_r_dn=${rnic_mod_dist_name}    timeout=${timeout}
    ${operation_id} =    Set Variable    ${response}[id]
    Wait until keyword succeeds    3min    10s    Wait Rannic Reset operation success    ${operation_id}
    vdu.delete_rnic_rest_operation    operation_id=${operation_id}
    [Teardown]  run keyword and ignore error    vDU Logout SG8

Wait Rannic Reset operation success
    [Arguments]    ${operation_id}
    ${status}    vdu.get_rnic_reset_operation    operation_id=${operation_id}
    Should Be Equal As Strings    ${status["status"]}    success

Rannic Status Should Be As Expected
    [Arguments]    ${rnic_mod_list}    ${expected_operational_state}    ${expected_availability_state}
    log to console    Check Rannic Status
    ${mrbts_id}=    Set Variable  ${rnic_mod_list[0].split('/')[0].split('-')[-1]}
    ${rnics_info}=    Get Rannic Info From SCF    mrbts_id=${mrbts_id}
    log to console    ${rnics_info}
    FOR  ${rnic_info}   IN  @{rnics_info}
        Run Keyword If  '${rnic_info}[r_nic_mod_dist_name]' in ${rnic_mod_list}   Run Keywords
        ...  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${rnic_info}[operational_state]  ${expected_operational_state}
        ...  AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${rnic_info}[availability_status]  ${expected_availability_state}
    END

Trigger Rannic Reset and Check Fault
    log to console   Trigger Rannic Reset and Check Fault
    ${rnic_num}    ${rnic_mod_list}        Get Rannic Number And ModList    mrbts_id=${mrbts_id}
    log to console    ${rnic_mod_list}
    FOR   ${rnic_rmod}    IN   @{rnic_mod_list}
        log to console    ${rnic_rmod}
        run keyword and continue on failure    Trigger Rannic Reset    rnic_mod_dist_name=${rnic_rmod}
    END

Wait Site Normal after Rannic Reset
    ${rnic_num}    ${rnic_mod_list}        Get Rannic Number And ModList    mrbts_id=${mrbts_id}
    wait until keyword succeeds    8min    60s    Rannic Status Should Be As Expected    rnic_mod_list=${rnic_mod_list}
    ...    expected_operational_state=enabled    expected_availability_state=on line
    wait until keyword succeeds    8min    60s    vDU Verify All Cells Status Should Be Onair
    AlarmWatchdog.disallow_alarm    fault_id=4350

Check Rannic Reset in Auditlog
    [Arguments]  ${namespase}=cran1  ${alias}=vDU
    vDU Connect To K8s Master Interactively    alias=${alias}
    ${log_path}  ${kubectl_cmd}    Generate Auditlog Get    namespase=${namespase}    alias=${alias}
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

Slove ocp l2nrt container garbled code
    ${alias}  get unique id
    Connect To vDU K8s Master   alias=${alias}
    ${slove_garbled_code_command}=    Catenate    kubectl get node | grep -v NAME | awk '{print $1}' | xargs -I {}
    ...    ssh -o StrictHostKeyChecking=no  {} "cat /etc/inputrc | grep 'set enable-bracketed-paste off' || echo 'set
    ...    enable-bracketed-paste off' | sudo tee -a /etc/inputrc"
    ${check_command}    Catenate    kubectl get node | grep -v NAME | awk '{print $1}' | xargs -I {} ssh -o
    ...    StrictHostKeyChecking=no  {} "cat /etc/inputrc | grep 'set enable-bracketed-paste off'"
    ${check_result}    issh.Execute    command=${check_command}    alias=${alias}    check_result=False
    ${ret}=    Run Keyword And Return Status    Should Contain    ${check_result}    set enable-bracketed-paste off
    ${out}    Run Keyword If   ${ret}==False    issh.Execute    command=${slove_garbled_code_command}    alias=${alias}
    [Teardown]    run keyword and ignore error  issh.disconnect  alias=${alias}

Verify RANNIC Status Should enabled for vDU
    ${rnic_status}=    Get Rannic Info From SCF     mrbts_id=${mrbts_id}
    ${rnic_num}=   get length    ${rnic_status}
    FOR   ${index}   IN RANGE   0    ${rnic_num}
        Run keyword    Should be equal as strings    ${rnic_status[${index}]['operational_state']}    enabled
        ...  msg=operational_state for ${rnic_status[${index}]['r_nic_mod_dist_name']} is not enabled
    END

CU Full Commsion By M2M API
    [Arguments]    ${scf_file}   ${timeout}=300s    ${gnb_index}=0    ${wait_for_completion}=True
    CU Login SG8  ${gnb_index}
    log to console   \n*** Start to perform VCU commissioning ***
    ${perform_commissioning_responsed}=     Run Keyword If    '${wait_for_completion}'=='False'
    ...    CU Perform commissioning By M2M API     scf_file=${scf_file}    timeout=${timeout}
    ...    wait_for_completion=${wait_for_completion}
    ...    ELSE
    ...    wait until keyword succeeds     3min    20s    CU Perform commissioning By M2M API
    ...    scf_file=${scf_file}    timeout=${timeout}    wait_for_completion=${wait_for_completion}
    Run Keyword If    '${wait_for_completion}'=='False'    Run Keywords
    ...    log to console   \n*** Start to check status after performing VDU commissioning ***
    ...    AND
    ...    wait until keyword succeeds     3min    20s    CU Check Perform commissioning status By M2M API
    ...    timeout=${timeout}    operation_id=${perform_commissioning_responsed["id"]}    expected_status=success
     [Teardown]    run keyword and ignore error   CU Logout SG8

CU Perform commissioning By M2M API
    [Arguments]    ${scf_file}    ${wait_for_completion}=True    ${timeout}=300
    ${perform_commissioning_responsed}=     cu.perform_commissioning     scf_file=${scf_file}
    ...    wait_for_completion=${wait_for_completion}    timeout=${timeout}
    [Return]    ${perform_commissioning_responsed}

CU Check Perform commissioning status By M2M API
     [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=300
     Log To Console    ${operation_id}
     ${check_perform_commissioning_responsed}    cu.get_status_of_perform_commissioning    operation_id=${operation_id}
     ...    timeout=${timeout}
     Should Be True    "${check_perform_commissioning_responsed["status"]}"=="${expected_status}"

VDU Full Commsion By M2M API
    [Arguments]    ${scf_file}   ${timeout}=300    ${vdu_index}=0    ${gnb_index}=0    ${wait_for_completion}=True
    VDU Rest Login SG8    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    log to console   \n*** Start to perform VDU commissioning ***
    ${perform_commissioning_responsed}=     Run Keyword If    '${wait_for_completion}'=='False'
    ...    VDU Perform commissioning By M2M API     scf_file=${scf_file}    timeout=${timeout}
    ...    wait_for_completion=${wait_for_completion}
    ...    ELSE
    ...    wait until keyword succeeds     3min    20s    VDU Perform commissioning By M2M API
    ...     scf_file=${scf_file}    timeout=${timeout}    wait_for_completion=${wait_for_completion}
    Run Keyword If    '${wait_for_completion}'=='False'    Run Keywords
    ...    log to console   \n*** Start to check status after performing VDU commissioning ***
    ...    AND
    ...    wait until keyword succeeds     3min    20s    VDU Check Perform commissioning status By M2M API
    ...    timeout=${timeout}    operation_id=${perform_commissioning_responsed["id"]}    expected_status=success
     [Teardown]    run keyword and ignore error   vDU Rest Logout

VDU Perform commissioning By M2M API
    [Arguments]    ${scf_file}   ${timeout}=300s    ${wait_for_completion}=True
    ${perform_commissioning_responsed}=     vdu.perform_commissioning     scf_file=${scf_file}    timeout=${timeout}
    ...    wait_for_completion=${wait_for_completion}
    [Return]    ${perform_commissioning_responsed}

VDU Check Perform commissioning status By M2M API
     [Arguments]    ${operation_id}    ${timeout}=300    ${expected_status}=success
     ${check_perform_commissioning_responsed}    vdu.get_status_of_perform_commissioning    operation_id=${operation_id}
     ...    timeout=${timeout}
     Should Be True    "${check_perform_commissioning_responsed["status"]}"=="${expected_status}"

VDU Delta recommission update parameters by M2M API
    [Arguments]    ${delta_file}   ${timeout}=300    ${wait_for_completion}=True
    vDU Login SG8
    log to console   \n*** Start to perform delta recommissioning ***
    ${perform_delta_recommissioning_responsed}=     Run Keyword If    '${wait_for_completion}'=='False'
    ...    VDU Perform delta recommissioning By M2M API    delta_file=${delta_file}    timeout=${timeout}
    ...    wait_for_completion=${wait_for_completion}
    ...    ELSE
    ...    wait until keyword succeeds     1min    5s    VDU Perform delta recommissioning By M2M API
    ...     delta_file=${delta_file}    timeout=${timeout}    wait_for_completion=${wait_for_completion}
    Run Keyword If    '${wait_for_completion}'=='False'    Run Keywords
    ...    log to console   \n*** Start to check status after performing delta recommissioning ***
    ...    AND
    ...    wait until keyword succeeds     3min    5s    VDU Check Perform delta recommissioning status By M2M API
    ...    operation_id=${perform_delta_recommissioning_responsed["id"]}    expected_status=success
    [Teardown]    run keyword and ignore error    vDU Logout SG8

VDU Perform delta recommissioning By M2M API
    [Arguments]    ${delta_file}   ${timeout}=300s    ${wait_for_completion}=True    ${expected_status}=success
    ${perform_delta_recommissioning_responsed}=     vdu.perform_delta_recommissioning     delta_file=${delta_file}    timeout=${timeout}
    ...    wait_for_completion=${wait_for_completion}
    Run Keyword If    ${wait_for_completion}==True    Should Be True
    ...    "${perform_delta_recommissioning_responsed["status"]}"=="${expected_status}"
    [Return]    ${perform_delta_recommissioning_responsed}

VDU Check Perform delta recommissioning status By M2M API
     [Arguments]    ${operation_id}    ${expected_status}=success    ${timeout}=30
     ${check_perform_delta_recommissioning_responsed}    vdu.get_status_of_perform_delta_recommissioning    operation_id=${operation_id}
     ...    timeout=${timeout}
     Should Be True    "${check_perform_delta_recommissioning_responsed["status"]}"=="${expected_status}"

Get VDU ids list
    [Arguments]    ${vdu_index}=${0}
    vDU Login SG8    vdu_index=${vdu_index}
    ${VDU_ids_list}    Create List
    ${VDU_info}    vdu.get_vdu_state_data
    Append To List    ${VDU_ids_list}    ${VDU_info['nr_du_id']}
    [RETURN]    ${VDU_ids_list}
    [Teardown]   run keyword and ignore error   CU Logout SG8

_Check lock vdu state in VCU side
    [Arguments]    ${operation_id}    ${expected_status}    ${VCU_connection}=default
    ${out}    cu.get_opeartion_state_of_locking_du    operation_id=${operation_id}
    ...    connection=${VCU_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"

Lock DU in VCU side
    [Arguments]    ${gnb_index}=0        ${alias}=default
    ${VDU_ids_list}    Get VDU ids list
    CU Login SG8  ${gnb_index}
    ${out}    cu.lock_du    du_id=${VDU_ids_list}
    Wait Until Keyword Succeeds  60   10   _Check lock vdu state in VCU side   operation_id=${out["id"]}
    ...    expected_status=ongoing    VCU_connection=${alias}
    [Teardown]   run keyword and ignore error   CU Logout SG8

_Check unlock vdu state in VCU side
    [Arguments]    ${operation_id}    ${expected_status}    ${VCU_connection}=default
    ${out}    cu.get_opeartion_state_of_unlocking_du    operation_id=${operation_id}
    ...    connection=${VCU_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"

Unlock VDU in VCU side
    [Arguments]    ${gnb_index}=0        ${alias}=default
    ${VDU_ids_list}    Get VDU ids list
    CU Login SG8  ${gnb_index}
    ${out}    cu.unlock_du    du_id=${VDU_ids_list}
    Wait Until Keyword Succeeds  60   10   _Check unlock vdu state in VCU side   operation_id=${out["id"]}
    ...    expected_status=ongoing    VCU_connection=${alias}
    [Teardown]   run keyword and ignore error   CU Logout SG8

Get NG link ids list
    [Arguments]    ${gnb_index}=0
    CU Login SG8  ${gnb_index}
    ${NG_ids_list}    Create List
    ${NG_link_info}    cu.get_ng_links_info
    ${list_length}    Get Length    ${NG_link_info}
    FOR    ${i}    IN RANGE    ${list_length}
        Append To List    ${NG_ids_list}    ${NG_link_info[${i}]['served_amf_id']}
    END
    [RETURN]    ${NG_ids_list}
    [Teardown]   run keyword and ignore error   CU Logout SG8

_Check lock NG link state in VCU side
    [Arguments]    ${operation_id}    ${expected_status}    ${VCU_connection}=default
    ${out}    cu.get_operation_state_of_locking_ng_links    operation_id=${operation_id}
    ...    connection=${VCU_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"

Lock NG link in VCU side
    [Arguments]    ${gnb_index}=0        ${alias}=default
    Log To Console    lock NG link from vcu side ...
    ${NG_ids_list}    Get NG link ids list
    CU Login SG8  ${gnb_index}
    ${out}    cu.lock_ng_links    ng_links_ids=${NG_ids_list}
    Wait Until Keyword Succeeds  60   10   _Check lock NG link state in VCU side   operation_id=${out["id"]}
    ...    expected_status=ongoing    VCU_connection=${alias}
    [Teardown]   run keyword and ignore error   CU Logout SG8

_Check unlock NG link state in VCU side
    [Arguments]    ${operation_id}    ${expected_status}    ${VCU_connection}=default
    ${out}    cu.get_operation_state_of_unlocking_ng_links    operation_id=${operation_id}
    ...    connection=${VCU_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"

Unlock NG link in VCU side
    [Arguments]    ${gnb_index}=0        ${alias}=default
    Log To Console    unlock NG link from vdu side ...
    ${NG_ids_list}    Get NG link ids list
    CU Login SG8  ${gnb_index}
    ${out}    cu.unlock_ng_links    ng_links_ids=${NG_ids_list}
    Wait Until Keyword Succeeds  60   10   _Check unlock vdu state in VCU side   operation_id=${out["id"]}
    ...    expected_status=ongoing    VCU_connection=${alias}
    [Teardown]   run keyword and ignore error   CU Logout SG8


_Check lock cells state in VCU side
    [Arguments]    ${operation_id}    ${expected_status}    ${VCU_connection}=default
    ${out}    cu.get_operation_state_of_locking_cells    operation_id=${operation_id}
    ...    connection=${VCU_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"

Get cells ids list
    [Arguments]    ${gnb_index}=0
    CU Login SG8  ${gnb_index}
    ${cell_ids_list}    Create List
    ${cells_statuses}    cu.get_cells_statuses
    ${list_length}    Get Length    ${cells_statuses}
    FOR    ${i}    IN RANGE    ${list_length}
        Append To List    ${cell_ids_list}    ${cells_statuses[${i}]['id']}
    END
    [RETURN]    ${cell_ids_list}
    [Teardown]   run keyword and ignore error   CU Logout SG8

Lock cells in VCU side
    [Arguments]    ${gnb_index}=0    ${alias}=default
    ${cell_ids_list}    Get cells ids list
    CU Login SG8  ${gnb_index}
    ${out}    cu.lock_cells    cell_ids=${cell_ids_list}
    Wait Until Keyword Succeeds  60   10   _Check lock cells state in VCU side   operation_id=${out["id"]}
    ...    expected_status=ongoing    VCU_connection=${alias}
    [Teardown]   run keyword and ignore error   CU Logout SG8

_Check unlock cells state in VCU side
    [Arguments]    ${operation_id}    ${expected_status}    ${VCU_connection}=default
    ${out}    cu.get_operation_state_of_unlocking_cells    operation_id=${operation_id}
    ...    connection=${VCU_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"

Unlock cells in VCU side
    [Arguments]    ${gnb_index}=0    ${alias}=default
    ${cell_ids_list}    Get cells ids list
    CU Login SG8  ${gnb_index}
    ${out}    cu.unlock_cells    cell_ids=${cell_ids_list}
    Wait Until Keyword Succeeds  60   10   _Check unlock cells state in VCU side   operation_id=${out["id"]}
    ...    expected_status=ongoing    VCU_connection=${alias}
    [Teardown]   run keyword and ignore error   CU Logout SG8

Reset vCU With Check Cell On Air
    [Arguments]    ${need_check_on_air}=${True}    ${gnb_index}=0    ${vdu_index}=0    ${alias}=default
    CU Login SG8  ${gnb_index}
    ${out}    cu.reset_cu    connection=${alias}
#    Should Be True    "${out["status"]}"=="ongoing"
#    ${error_msg}    set variable  ${out["error_message"]}
#    should contain    ${error_msg}    No error
    sleep    60s
    Run Keyword If    ${need_check_on_air}   Wait Until Keyword Succeeds  1800s   30s
    ...    Verify All Cells Status Should Be Onair for VDU    vdu_index=${vdu_index}
    [Teardown]    Run Keyword And Ignore Error    CU Logout SG8

Lock Cells In vDU
    [Arguments]    ${vdu_index}=0    ${alias}=default
    ${cells}    Get CellList For vDU
    vDU Login SG8    vdu_index=${vdu_index}
    FOR    ${cell}    IN    ${cells}
            ${out}    vdu.lock_cells    cell_id_list=${cells}    vdu_connection=${alias}
            Wait Until Keyword Succeeds  60   3   _Check lock Cell Should Be Expected   operation_id=${out["id"]}
            ...    expected_status=success    vdu_connection=${alias}
    END
    [Teardown]  Run keyword and ignore error    vDU Logout SG8

Unlock Cells In vDU
    [Arguments]    ${vdu_index}=0    ${alias}=default
    ${cells}    Get CellList For vDU
    vDU Login SG8    vdu_index=${vdu_index}
    FOR    ${cell}    IN    ${cells}
            ${out}    vdu.unlock_cells    cell_id_list=${cells}    vdu_connection=${alias}
            Wait Until Keyword Succeeds  60   3   _Check unlock Cell Should Be Expected   operation_id=${out["id"]}
            ...    expected_status=success    vdu_connection=${alias}
    END
    [Teardown]  Run keyword and ignore error    vDU Logout SG8

_Check lock Cell Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}    ${vdu_connection}=default
    ${out}    vdu.get_operation_state_of_locking_cells    operation_id=${operation_id}    timeout=${timeout}
    ...    vdu_connection=${vdu_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"

_Check unlock Cell Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}     ${vdu_connection}=default
    ${out}    vdu.get_operation_state_of_unlocking_cells    operation_id=${operation_id}    timeout=${timeout}
    ...    vdu_connection=${vdu_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"


Check VCU should be enabled
    [Arguments]    ${gnb_index}=0    ${operationalState}=enabled
    CU Login SG8  ${gnb_index}
    ${out}    cu.get_cu_state
    Should Be Equal   ${out['operational_state']}    ${operationalState}
    [Teardown]   run keyword and ignore error   CU Logout SG8

Verify All Rmods Status Should Be disabled for vDU
    [Arguments]    ${vdu_index}=0    ${alias}=default
    vDU Login SG8    vdu_index=${vdu_index}
    ${rmods_status}    vdu.get_rmods_status    vdu_connection=${alias}
    FOR  ${ru}  IN  @{rmods_status}
        Run keyword    Should be equal as strings    ${ru['operational_state']}    disabled
        ...  msg=operational_state for ru ${ru['id']} is not disabled
    END
    [Teardown]  Run keyword and ignore error    vDU Logout SG8


CU Login SG8
    [Arguments]     ${gnb_index}=0   ${solution}=rest
    [Documentation]  Login to CU via rest or webui.
    run keyword if  "${solution}"=="rest"    CU Rest Login SG8   ${gnb_index}
    ...   ELSE    CU Webui Login SG8

CU Rest Login SG8
   [Arguments]   ${gnb_index}
   [Documentation]  Create rest session to CU.
    cu.connect to    host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    secure=${True}

CU Webui Login SG8
    [Documentation]  Login to CU via WebUI.
    log   Login to CU webui function is not ready!     level=ERROR

CU Logout SG8
    [Arguments]   ${solution}=rest
    [Documentation]  Teardown login session to CU.
    run keyword if  "${solution}"=="rest"    CU Rest Logout SG8
    ...   ELSE    CU Webui Logout SG8

CU Rest Logout SG8
    [Documentation]  Teardown rest session to CU.
    cu.disconnect

CU Webui Logout SG8
      [Documentation]  Logout CU webui.
    log   Logout CU WebUI function is not ready!   level=ERROR

vDU Login SG8
    [Arguments]  ${login_type}=rest   ${vdu_index}=0
    [Documentation]  Login to vdu via rest or webem.
    run keyword if  "${login_type}"=="rest"    vDU Rest Login SG8   ${vdu_index}
    ...   ELSE   vDU WebEM Login SG8  ${vdu_index}

vDU Rest Login SG8
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]  login vdu webem.
    ...    author: calla.wang@nokia-sbell.com
    run keyword and ignore error  vDU Rest Logout SG8   vdu_index=${vdu_index}
    ${vdu_connection}   vdu.connect to
    ...  host=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...  port=${EMPTY}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...  secure=True

vDU WebEM Login SG8
    [Arguments]   ${vdu_index}=0
    [Documentation]  Login to vDU via WebEM.
    Log    message=\nArgument vdu_index=${vdu_index} is not used and will be removed in the future.
    log to console   \n*** Start vDU webui login  ***
    log   Login to vdu WebEM function is not ready!     level=ERROR

vDU Logout SG8
    [Arguments]   ${logout_type}=rest
    [Documentation]  Teardown login session to CU.
    run keyword if  "${logout_type}"=="rest"    vDU Rest Logout SG8
    ...   ELSE    vDU WebEM Logout SG8

vDU Rest Logout SG8
    [Arguments]  ${vdu_index}=0
    [Documentation]  Teardown rest session to vdu.
    # log to console   \n*** Start vdu logout ***
    Log    message=\nArgument vdu_index=${vdu_index} is not used and will be removed in the future.
    vdu.disconnect

vDU WebEM Logout SG8
      [Documentation]  Logout vDU webui.
    log to console   \n*** CU Webui Logout ***
    log   Logout vdu WebEM function is not ready!   level=ERROR
