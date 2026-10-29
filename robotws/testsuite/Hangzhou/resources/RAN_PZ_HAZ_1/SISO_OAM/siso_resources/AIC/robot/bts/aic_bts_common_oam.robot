*** Settings ***
Documentation
...    Author:    Wu Amy;Zhou Qiang;Ding Lisa
...    Maintainer:    Wu Amy;Zhou Qiang;Ding Lisa

Library           taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu
Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library           ../../../admin_alarms.py
Library           taf.transport.ssh                     WITH NAME    csn
Library   XML    use_lxml=${True}
Resource          ../../../pdu.robot

*** Keywords ***
#---------------------vDU--------------------------------------------------------------------------
Login To vDU By Rest
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0    ${alias}=default
    ${gnb_index}    Fetch From Right    ${cu_index}    _
    ${vdu_index}    Fetch From Right    ${vdu_index}    _
    ${oam_httpaddr}    set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${oam_web_ip}    set variable if    ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    Run keyword and ignore error    Run Keyword And Ignore Error    Logout To vDU By Rest    vdu_index=${alias}
    vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=${EMPTY}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...  secure=True
    ...  connection_name=${alias}


Login To Specify Resource vDU
    [Arguments]    ${resource_type}    ${resource_id}
    ${cu_index}    ${vdu_index}    Get CU vDU Index    ${resource_type}    ${resource_id}
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}

Logout To vDU By Rest
    [Arguments]    ${vdu_connection}=default
    vdu.disconnect    ${vdu_connection}

Wait For All Cells Onair In All vDUs
    [Arguments]    ${timeout}=${ONAIR_TIME}
    Wait Until Keyword Succeeds    ${timeout}    30 sec    vDU Verify All Cells Onair For All CUs

#Reset vDUs Until All Cells Onair In All vDUs
#    [Arguments]    ${vdu_list}=${VDU_LIST}    ${timeout}=${ONAIR_TIME}
#    FOR    ${vdu}    IN    @{vdu_list}
#        ${cu_index}    ${vdu_index}    Split String    ${vdu}    -
#        Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
#        ${out}    vdu.reset_vdu
#        ${error_msg}    set variable  ${out["error_message"]}
#        should contain    ${error_msg}    No error
#        ${out}    Wait Until Keyword Succeeds  60   10   _Check Reset VDU Status As Expected    operation_id=${out["id"]}
#        ...                                                                                expected_status=ongoing
#    END
#    Wait For All Cells Onair In All vDUs    timeout=${timeout}
#    Check RU List Status Should Be As Expected
#    [Teardown]    Run Keyword And Ignore Error    Logout To vDU By Rest

#_Check Reset VDU Status As Expected
#    [Arguments]    ${operation_id}    ${expected_status}
#    ${out}    vdu.get_reset_vdu_operation_status    operation_id=${operation_id}
#    Should Be True    "${out["status"]}"=="${expected_status}"
#    [Return]    ${out}

Get vDU Current SCFC
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    ${date}    Get Current Date    result_format=%Y%m%d%H%M%S
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${vdu_current_scfc}=    vdu.get_current_plan_file    local_dir_path=${TEST_LOGS_DIR_PATH}
    ...    filename=SCFC_${cu_index}_${vdu_index}_${date}.xml
    ...    include_runtime_data=${True}
    [Return]    ${vdu_current_scfc}
    [Teardown]    Run Keyword And Ignore Error    Logout To vDU By Rest

Create vDUs Parameters From Current SCF
    [Arguments]    ${vdu_list}=${VDU_LIST}
    ${ALL_VDU_CELL_LIST}    Create List
    ${USED_FR_SN_LIST}    Create List
    Set Suite Variable    ${ALL_VDU_CELL_LIST}
    Set Suite Variable    ${USED_FR_SN_LIST}
    FOR    ${vdu}    IN    @{vdu_list}
        ${cu_index}    ${vdu_index}    Split String    ${vdu}    -
        ${vdu_current_scfc}    Get vDU Current SCFC    ${vdu_index}    ${cu_index}
        Create Parameters Init In vDU    ${vdu_current_scfc}    ${vdu_index}    ${cu_index}
    END

Template File Commissioning In Multi vDUs
    [Arguments]    ${vdu_list}=${VDU_LIST}
    FOR    ${vdu}    IN    @{vdu_list}
        ${cu_index}    ${vdu_index}    Split String    ${vdu}    -
        ${vdu_scf}    Set Variable    ${NODE_CFG["${cu_index}"]["${vdu_index}"]["scfc"]}
        vDU Full Commission SCF    ${vdu_scf}    vdu_index=${vdu_index}    cu_index=${cu_index}
    END

vDU Full Commission SCF
    [Arguments]  ${scf_file}=${EMPTY}   ${vdu_index}=vDU_0    ${cu_index}=CU_0    ${timeout}=300
    log to console  Full Commission SCF On VDU ${cu_index}-${vdu_index}
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    vdu.perform_commissioning     ${scf_file}    timeout=${timeout}
    ...    wait_for_completion=True
#    vDU Check Maximum Plan Number And Delete One If Reach Maximum Number
#    log to console  Begin to commission SCF file...
#    ${out}  vDU Upload Plan And Validate And Activate  plan_file=${scf_file}    vdu_index=${vdu_index}    active=${active}
#    sleep   2
    [Teardown]    run keyword and ignore error    Logout To vDU By Rest

vDU Upload Plan And Validate And Activate
    [Arguments]   ${plan_file}  ${plan_name}=TA_Upload_Plan_And_Validate_And_Activate  ${plan_description}=${EMPTY}
    ...   ${retries}=1    ${vdu_index}=vDU_0    ${timeout}=60    ${active}=${True}
    log to console  Upload Plan And Validate And Activate
    ${out}  vdu.Upload Plan   path_to_plan_file=${plan_file}   plan_name=${plan_name}   plan_description=${plan_description}
    ...    timeout=${timeout}
    ${temp_plan_id}   Set Variable  ${out["plan_id"]}
    ${temp_action_id}   Set Variable  ${out["action_id"]}
    ${temp_validation_id}   Set Variable  ${EMPTY}

    vDU Upload Plan Status Should Be Successful  operation_id=${temp_action_id}
    sleep   2
    ${temp_validation_id}   Run Keyword If  ${active}  vDU Validate Plan By REST  plan_id=${temp_plan_id}   retries=${retries}
    sleep   2
    ${out}   Run Keyword If  ${active}  vDU Activate Staged Plan By REST   plan_id=${temp_plan_id}    vdu_index=${vdu_index}

    [Return]   ${temp_plan_id}   ${temp_action_id}    ${temp_validation_id}

vDU Activate Staged Plan By REST
    [Arguments]  ${plan_id}    ${vdu_index}=vDU_0    ${timeout}=60
    [Documentation]   Activate Delta Plan By REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id             | yes | delta plan id |
    ...   | force_reset       | no | default is ${True} |
    ...   | auto_lock_cells   | no | default is ${True} |
    ...   | timeout           | no | default is 60 (seconds) |
    ...   *RETURN VALUE*
    ...    Activate plan operation information.
    ...   Example
    ...   | VDU Rest Login |
    ...   | Activate Staged Plan By REST | plan_id=my_plan_id |
    ...   | VDU Rest Logout |
    ${out}   vdu.activate_plan   plan_id=${plan_id}    timeout=${timeout}
    ${action_id}  set variable   ${out['id']}

    ${out}   vDU Activate Plan Operation Should Be Successful With Retry   action_id=${action_id}   plan_id=${plan_id}    vdu_index=${vdu_index}
    [Return]  ${out}

vDU Activate Plan Operation Should Be Successful With Retry
    [Arguments]  ${plan_id}  ${action_id}    ${vdu_index}=vDU_0    ${timeout}=30
    [Documentation]   checking activate plan operation status should be successful
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...    | action_id | Yes | the activate action id, get from activate_plan |
    ...    *RETURN VALUE*
    ...    None
    ${activate_plan_response}=  vdu.get_activate_plan_operation_status  ${plan_id}  ${action_id}   timeout=${timeout}
    ${rtn}  Wait Until Keyword Succeeds  900   30
    ...    _vDU Activate Plan Operation Status Should Be Expected   plan_id=${plan_id}    operation_id=${action_id}
    ...    expected_status=success    vdu_index=${vdu_index}
    [Return]  ${rtn}


_vDU Activate Plan Operation Status Should Be Expected
    [Arguments]   ${plan_id}  ${operation_id}   ${expected_status}   ${vdu_index}=vDU_0
    ...    ${timeout}=30
    ${r}  ${out}   run keyword and ignore error   Login To vDU By Rest   vdu_index=${vdu_index}
    should be true    "${r}"=="PASS"
    return from keyword if   "${r}"!="PASS"

    ${r}  ${out}   run keyword and ignore error
    ...   vdu.get_activate_plan_operation_status   plan_id=${plan_id}   operation_id=${operation_id}  timeout=${timeout}
    should be true    "${r}"=="PASS"

    Should Be True    "${out["status"]}"=="${expected_status}"

    [Return]  ${out}


vDU Upload Plan Status Should Be Successful
    [Arguments]  ${operation_id}
    Wait Until Keyword Succeeds  30   3  _vDU Upload Plan Status Should Be Expected   operation_id=${operation_id}    expected_status=success

_vDU Upload Plan Status Should Be Expected
    [Arguments]  ${operation_id}   ${expected_status}    ${timeout}=30
    ${out}   vdu.Get_Upload_Plan_Operation_Status   operation_id=${operation_id}    timeout=${timeout}
    Should Be True  "${out["status"]}"=="${expected_status}"

vDU Validate Plan By REST
    [Arguments]  ${plan_id}   ${retries}=1    ${timeout}=60
    FOR   ${i}    IN RANGE    0   ${retries}
      ${out}  vdu.Validate_Plan   plan_id=${plan_id}    timeout=${timeout}
      ${action_id}   Set Variable  ${out["action_id"]}
      ${out}   vDU Validate Plan Status Should Be Successful   operation_id=${action_id}  plan_id=${plan_id}
      ${validation_id}  Set Variable   ${out["validation_id"]}
      sleep   2
    END
    [Return]   ${validation_id}

vDU Validate Plan Status Should Be Successful
    [Arguments]  ${operation_id}   ${plan_id}
    ${rtn}  Wait Until Keyword Succeeds  20   3
    ...  _vDU Validate Plan Status Should Be Expected   operation_id=${operation_id}    plan_id=${plan_id}   expected_status=success
    [Return]  ${rtn}

_vDU Validate Plan Status Should Be Expected
    [Arguments]  ${operation_id}   ${expected_status}   ${plan_id}   ${timeout}=30
    ${out}   vdu.Get_Validate_Plan_Operation_Status   operation_id=${operation_id}   plan_id=${plan_id}
    ...    timeout=${timeout}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


vDU Check Maximum Plan Number And Delete One If Reach Maximum Number
    [Documentation]   Check Maximum Plan Number And delete one if reach Maximum number
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...  | vdu rest login |
    ...  | Check Maximum Plan Number And delete one if reach Maximum number |
    [Arguments]    ${timeout}=30
    ${all_plans}   vdu.Get_Staged_Plans_Info_List    timeout=${timeout}
    Should Be True  ${all_plans.__len__()}<=3
    Run Keyword If  ${all_plans.__len__()}==3   Log To Console  ${all_plans[0]["plan_name"]}/${all_plans[0]["plan_id"]} will be deleted!
    Run Keyword If  ${all_plans.__len__()}==3   vdu.Delete_Staged_Plan_File   plan_id=${all_plans[0]["plan_id"]}
    ...    timeout=${timeout}

Check RU List Status Should Be As Expected
    [Arguments]    ${ru_sn_list}=${USED_FR_SN_LIST}   ${expected_administrative_state}=unlocked
    ...    ${expected_operational_state}=enabled    ${expected_availability_status}=on line
    ...    ${expected_procedural_status}=configured
    FOR    ${ru_sn}    IN    @{ru_sn_list}
        Check RU Status As Expected    ${ru_sn}    expected_administrative_state=${expected_administrative_state}
        ...    expected_operational_state=${expected_operational_state}
        ...    expected_availability_status=${expected_availability_status}
        ...    expected_procedural_status=${expected_procedural_status}
    END

Check RU Status As Expected
    [Arguments]   ${ru_sn}   ${expected_administrative_state}=unlocked
    ...    ${expected_operational_state}=enabled    ${expected_availability_status}=on line
    ...    ${expected_procedural_status}=configured
    ${ru_administrativeState}  ${ru_operationalState}  ${ru_availabilityStatus}  ${ru_proceduralStatus}   Get Specified RU Status In vDU   ${ru_sn}
    run keyword and continue on failure    should be true     "${ru_administrativeState}"=="${expected_administrative_state}"
    ...    Administrative state of ru ${ru_sn} is not ${expected_administrative_state}!
    run keyword and continue on failure    should be true     "${ru_operationalState}"=="${expected_operational_state}"
    ...    Operational state of ru ${ru_sn} is not ${expected_operational_state}!
    run keyword and continue on failure    should be true     "${ru_availabilityStatus}"=="${expected_availability_status}"
    ...    Availability state of ru ${ru_sn} is not ${expected_availability_status}!
    run keyword and continue on failure    should be true     "${ru_proceduralStatus}"=="${expected_procedural_status}"
    ...    Availability state of ru ${ru_sn} is not ${expected_procedural_status}!

Get Specified RU Status In vDU
    [Arguments]   ${ru_sn}
    Login To Specify Resource vDU    fr    ${ru_sn}
    ${ru_infos}=  vdu.get_rmods_status
    FOR    ${ru_info}    IN    @{ru_infos}
       ${administrative_state}=    Convert To Lowercase   ${ru_info["administrative_state"]}
       ${operational_state}=    Convert To Lowercase     ${ru_info["operational_state"]}
       ${status}    ${availability_status}    Run Keyword And Ignore Error    Get From Dictionary    ${ru_info}    availability_status
       ${availability_status}    Set Variable If    "${status}"=="PASS"    ${availability_status}    ${EMPTY}
       ${availability_status}    Convert To Lowercase     ${availability_status}
       ${procedural_status}    Convert To Lowercase     ${ru_info["procedural_status"]}
       Return From Keyword If    '${ru_info["serial_number"]}' == '${ru_sn}'
       ...     ${administrative_state}    ${operational_state}    ${availability_status}    ${procedural_status}
    END
   [Teardown]   Run keyword and ignore error    Logout To vDU By Rest

Get RU type
    [Arguments]    ${ru_sn}
    Login To Specify Resource vDU    fr    ${ru_sn}
    ${ru_infos}=  vdu.get_rmods_status
    FOR    ${ru_info}    IN    @{ru_infos}
       Return Form Keyword If    "${ru_info["serial_number"]}"=="${ru_sn}"    ${ru_info["interface_type"]}
    END
    Fail
   [Teardown]   Run keyword and ignore error    Logout To vDU By Rest

Save VDU Snapshot
    [Arguments]    ${logs_dir_path}=${TEST_LOGS_DIR_PATH}    ${coverage}=full    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    Wait Until Keyword Succeeds    10 min    10 sec    Check Snapshot Status    idle
    vdu.Get_Local_Snapshot    ${logs_dir_path}    compressed_or_not=True    coverage=${coverage}
    ${rc}    ${target_file_name}    Run And Return RC And Output    ls -t ${logs_dir_path} | head -n 1
    ${target_file_path}    Join Path    ${logs_dir_path}    ${target_file_name}
    [Return]    ${target_file_path}
    [Teardown]    Run keyword and ignore error    Logout To vDU By Rest

Check Snapshot Status
    [Arguments]    ${expected_status}    ${vdu_connection}=default
    ${status}    vdu.check_snapshot_status    vdu_connection=${vdu_connection}
    Should Be Equal    ${status}    ${expected_status}

Create snapshot and cancel it during creation
    [Arguments]  ${logs_dir_path}=${TEST_LOGS_DIR_PATH}  ${vdu_index}=vDU_0    ${cu_index}=CU_0
    ${snapshots_before}    List Files In Directory    ${logs_dir_path}    Snapshot*
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${operation_id}    vdu.trigger_local_snapshot
    sleep    10 sec
    vdu.cancel_snapshot_operation    ${operation_id}    directory=${TEST_LOGS_DIR_PATH}
    Sleep    60
    ${snapshots_after}    List Files In Directory    ${logs_dir_path}    Snapshot*
    Remove Values From List    ${snapshots_after}    @{snapshots_before}
    Should Not Be Empty    ${snapshots_after}

Check Expected Alarms Is Appear In vDUs
    [Arguments]    ${expected_fault_id}    ${vdu_list}=${VDU_LIST}
    FOR    ${vdu}    IN    @{vdu_list}
        ${cu_index}    ${vdu_index}    Split String     ${vdu}    -
        Run Keyword And Continue On Failure    Check Expected Alarms Is Appear in vDU    ${vdu_index}    ${cu_index}    ${expected_fault_id}
    END

Check Expected Alarms Is Not Appear In vDUs
    [Arguments]    ${expected_fault_id}
    ${status}    Run Keyword And Return Status    Check Expected Alarms Is Appear In vDUs    ${expected_fault_id}
    Should Not Be True     ${status}

Check Expected Alarms Is Appear In vDU
    [Arguments]  ${expected_fault_id}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${out}    vdu.vdu_get_active_alarms
    ${status}=   set variable   False
    FOR    ${alarm}    IN    @{out['alarms']}
        ${fault_id}    Set Variable    ${alarm['fault_id']}
        ${status}=    set variable if    ${fault_id}==${expected_fault_id}    True
        exit for loop if    ${fault_id}==${expected_fault_id}
    END
    should be equal    ${status}    True    expected fault id in ${cu_index}-${vdu_index} is not appear!
    [Teardown]    Run keyword and ignore error    Run Keyword And Ignore Error    Logout To vDU By Rest

Check Alarms In vDUs
    [Arguments]    ${vdu_list}=${VDU_LIST}
    FOR    ${vdu}    IN    @{vdu_list}
        ${cu_index}    ${vdu_index}    Split String     ${vdu}    -
        vDU Alarms Get And Check    allowed=${GLO_VDU_ALLOWED_ALARM}    vdu_index=${vdu_index}    cu_index=${cu_index}
    END

vDU Alarms Get And Check
    [Arguments]    ${allowed}=${EMPTY}    ${mandatory}=${EMPTY}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${out_active_alarms_list}=    vdu.Vdu Get Active Alarms
    Admin Alarms Check    available=${out_active_alarms_list["alarms"]}    allowed=${allowed}    mandatory=${mandatory}
    ...    allowed_key=fault_name
    [Teardown]    Run keyword and ignore error    Run Keyword And Ignore Error    Logout To vDU By Rest

Check Historical Alarms In vDUs
    [Arguments]    ${additional_allowed_alarms}=${EMPTY}    ${origin_history_alarms}=${VDU_ORIGIN_HISTORICAL_ALARMS}
    ${additional_allowed_alarm_list}    split_string    ${additional_allowed_alarms}    :
    ${allowed_alarm_list}     combine_lists    ${GLO_VDU_ALLOWED_ALARM}    ${additional_allowed_alarm_list}
    Remove Values From List    ${allowed_alarm_list}    ${empty}
    FOR    ${vdu}    IN    @{VDU_LIST}
        ${cu_index}    ${vdu_index}    Split String    ${vdu}    -
        ${orgin_history_alarm}    Get From Dictionary    ${origin_history_alarms}    ${vdu}
        ${target_history_alarm}    Get Historical Alarm In vDU    vdu_index=${vdu_index}    cu_index=${cu_index}
        Remove Values From List      ${target_history_alarm}    @{orgin_history_alarm}
        Admin Alarms Check    available=${target_history_alarm}    allowed=${allowed_alarm_list}    allowed_key=fault_name
    END

Get Historical Alarm In vDUs
    [Arguments]    ${vdu_list}=${VDU_LIST}
    ${vdu_historical_alarms}    Create Dictionary
    FOR    ${vdu}    IN    @{vdu_list}
        ${cu_index}    ${vdu_index}    Split String     ${vdu}    -
        ${historical_alarm_list}    Get Historical Alarm In vDU    ${vdu_index}    ${cu_index}
        Set To Dictionary    ${vdu_historical_alarms}    ${vdu}=${historical_alarm_list}
    END
    [Return]    ${vdu_historical_alarms}

Get Historical Alarm In vDU
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${historical_alarm_list}=    vdu.Vdu Get Historical Alarms    page_number=${1}    items_per_page=${1000}
    [Return]    ${historical_alarm_list["alarms"]}
    [Teardown]    Run keyword and ignore error    Run Keyword And Ignore Error    Logout To vDU By Rest

Get Unique ID
    [Arguments]    ${prefix}=TA
    ${unique_id}    Evaluate    str(time.time())    modules=time
    ${unique_id}    String.Replace String    ${unique_id}    .    ${EMPTY}
    [Return]    ${prefix}_${unique_id}

vDU Get Cell Number From SCF
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    ${vdu_current_scfc}    Get vDU Current SCFC    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${scf_content}    OperatingSystem.Get File    ${vdu_current_scfc}
    ${result}    Get Regexp Matches    ${scf_content}
    ...    .*NRCELL"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRCELL-(\\d+)"\\s+.*   3
    ${cell_number}    Set Variable    ${result.__len__()}
    [Return]   ${cell_number}

vDU Get Cells Summary
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0

    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${cells_summary}    vdu.get_vdu_cells_summary
    [Return]    ${cells_summary}
    [Teardown]    Run Keyword And Ignore Error    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU Verify All Cells OnAir
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    ${cell_number}    vDU Get Cell Number From SCF    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${cells_summary}    vDU Get Cells Summary    vdu_index=${vdu_index}    cu_index=${cu_index}
    Should Be Equal As Numbers    ${cells_summary['basic_cells_summary']['operational_state']['disabled']}    0
    Should Be Equal As Numbers    ${cells_summary['basic_cells_summary']['administrative_state']['locked']}    0
    Should Be Equal As Numbers    ${cells_summary['basic_cells_summary']['administrative_state']['shutting_down']}  0
    ${online_number}    Set Variable    ${cells_summary['availability_status']['on_line']}
    Should Be True    "${online_number}"=="${cell_number}"

vDU Verify All Cells Onair For All CUs
    [Arguments]    ${vdu_list}=${VDU_LIST}
    FOR    ${vdu_index}    IN    @{vdu_list}
        ${vdu_index}    ${cu_index}    Split String    ${vdu_index}    -
        vDU Verify All Cells OnAir    vdu_index=${vdu_index}    cu_index=${cu_index}
    END

vDU Get Rmods Status
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0

    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${rmods_status}    vdu.get_rmods_status
    [Return]    ${rmods_status}
    [Teardown]    Run Keyword And Ignore Error    Run Keyword And Ignore Error    Logout To vDU By Rest

Get RMOD ID List
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    ${rmod_id_list}    Create List
    ${rmods_info}    vDU Get Rmods Status    vdu_index=${vdu_index}    cu_index=${cu_index}
    FOR    ${rmod}    IN    @{rmods_info}
         Append To List    ${rmod_id_list}    ${rmod["id"]}
    END
    [Return]   ${rmod_id_list}

vDU Get Specified RU Status By ID
    [Arguments]    ${ru_id}    ${vdu_index}=vDU_0   ${cu_index}=CU_0
    ${rus_info}    vDU Get Rmods Status    vdu_index=${vdu_index}    cu_index=${cu_index}
    FOR    ${ru_info}    IN    @{rus_info}
        ${administrative_state}=    Convert To Lowercase   ${ru_info["administrative_state"]}
        ${operational_state}=    Convert To Lowercase     ${ru_info["operational_state"]}
        ${availability_state}=    Convert To Lowercase     ${ru_info["availability_status"]}
        ${ru_status}    Create Dictionary    administrative_state=${administrative_state}
        ...    operational_state=${operational_state}   availability_state=${availability_state}
        Return From Keyword If    '${ru_info["id"]}' == '${ru_id}'     ${ru_status}
    END

vDU Get Rmods Info By ID
    [Arguments]    ${ru_id}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${rmods_status}    vdu.get_rmods_status
	FOR    ${rmod_status}    IN    @{rmods_status}
		Return From Keyword If    ${rmod_status['id']}==${ru_id}    ${rmod_status}
	END
    [Teardown]    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU Check RUs Status By ID
    [Arguments]     ${rmod_id_list}    ${except_rmod_id_list}=${EMPTY}
    ...    ${expected_administrative_state}=unlocked
    ...    ${expected_operational_state}=enabled
    ...    ${expected_availability_status}=on line
    ...    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    FOR    ${ru_id}    IN    @{rmod_id_list}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${except_rmod_id_list}   ${ru_id}
        Continue For Loop If   ${status}
        ${ru_status}    vDU Get Specified RU Status By ID    ${ru_id}    ${vdu_index}    ${cu_index}
        Run Keyword And Continue On Failure    Should Be True
        ...    "${expected_administrative_state}"=="${ru_status["administrative_state"]}"
        ...    RU ${ru_id} administrative state does not meet expectations!
        Run Keyword And Continue On Failure    Should Be True
        ...    "${expected_operational_state}"=="${ru_status["operational_state"]}"
        ...    RU ${ru_id} operational state does not meet expectations!
        Run Keyword And Continue On Failure    Should Be True
        ...    "${expected_availability_status}"=="${ru_status["availability_state"]}"
        ...    RU ${ru_id} availability state does not meet expectations!
    END

vDU Lock RUs
    [Arguments]    ${rmod_id_list}    ${vdu_index}=vDU_0    ${cu_index}=CU_0

    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    vdu.lock_rmods    rmod_id_list=${rmod_id_list}
    [Teardown]    Run Keyword And Ignore Error    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU Unlock RUs
    [Arguments]    ${rmod_id_list}    ${vdu_index}=vDU_0    ${cu_index}=CU_0

    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    vdu.unlock_rmods    rmod_id_list=${rmod_id_list}
    [Teardown]    Run Keyword And Ignore Error    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU Lock All RUs And Check Status
    [Arguments]    ${vdu_index}=vDU_0   ${cu_index}=CU_0
    ${rmod_id_list}    Get RMOD ID List    ${vdu_index}   ${cu_index}
    vDU Lock RUs    rmod_id_list=${rmod_id_list}    vdu_index=${vdu_index}    cu_index=${cu_index}
    Wait Until Keyword Succeeds    120s    5s
    ...    vDU Check RUs Status By ID    ${rmod_id_list}   expected_administrative_state=locked
    ...    expected_operational_state=enabled    vdu_index=${vdu_index}    cu_index=${cu_index}

vDU Unlock All RUs And Check Status
    [Arguments]    ${vdu_index}=vDU_0   ${cu_index}=CU_0
    ${rmod_id_list}    Get RMOD ID List    ${vdu_index}   ${cu_index}
    vDU Unlock RUs    rmod_id_list=${rmod_id_list}    vdu_index=${vdu_index}    cu_index=${cu_index}
    Wait Until Keyword Succeeds    120s    5s
    ...    vDU Check RUs Status By ID    ${rmod_id_list}   expected_administrative_state=unlocked
    ...    expected_operational_state=enabled    vdu_index=${vdu_index}    cu_index=${cu_index}

vDU Lock RU And Check Status
    [Arguments]    ${rmod_id}   ${vdu_index}=vDU_0   ${cu_index}=CU_0
    ${rmod_id_list}  Convert To List  ${rmod_id}
    vDU Lock RUs    rmod_id_list=${rmod_id_list}    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${rmod_info}    vDU Get Rmods Info By ID    ${rmod_id}
    ${cell_ids}   Set Variable  ${rmod_info["cell_ids"]}
    Wait Until Keyword Succeeds    120s    5s
    ...    vDU Check RUs Status By ID    ${rmod_id_list}   expected_administrative_state=locked
    ...    expected_operational_state=enabled    vdu_index=${vdu_index}    cu_index=${cu_index}
    Wait Until Keyword Succeeds    120s    5s
    ...    vDU Check Cells Status    ${cell_ids}   expected_operational_state=disabled
    ...    expected_availability_status=dependency    vdu_index=${vdu_index}    cu_index=${cu_index}
    Wait Until Keyword Succeeds    120s    5s
    ...    vDU Check RUs Status By ID    ${RMOD_ID_LIST}    except_rmod_id_list=${rmod_id_list}
    ...    vdu_index=${vdu_index}    cu_index=${cu_index}
    Wait Until Keyword Succeeds    120s    5s
    ...    vDU Check Cells Status    ${ALL_CELLS_ID_LIST}   except_cell_id_list=${cell_ids}
    ...    vdu_index=${vdu_index}    cu_index=${cu_index}

vDU Unlock RU And Check Status
    [Arguments]    ${rmod_id}   ${vdu_index}=vDU_0   ${cu_index}=CU_0
    ${rmod_id_list}  Convert To List  ${rmod_id}
    vDU Unlock RUs    rmod_id_list=${rmod_id_list}    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${rmod_info}    vDU Get Rmods Info By ID    ${rmod_id}
    ${cell_ids}   Set Variable  ${rmod_info["cell_ids"]}
    Wait Until Keyword Succeeds    120s    5s
    ...    vDU Check RUs Status By ID    ${rmod_id_list}   expected_administrative_state=unlocked
    ...    expected_operational_state=enabled    vdu_index=${vdu_index}    cu_index=${cu_index}
    Wait Until Keyword Succeeds    120s    5s
    ...    vDU Check Cells Status    ${cell_ids}   expected_operational_state=enabled
    ...    vdu_index=${vdu_index}    cu_index=${cu_index}

vDU Lock Unlock All RUs And Check Status
    [Arguments]    ${vdu_index}=vDU_0   ${cu_index}=CU_0
    ${rmod_id_list}    Get RMOD ID List    ${vdu_index}   ${cu_index}
    ${all_cells_id__list}    Get Cell ID List    ${vdu_index}   ${cu_index}
    Set Test Variable  ${RMOD_ID_LIST}    ${rmod_id_list}
    Set Test Variable  ${ALL_CELLS_ID_LIST}    ${all_cells_id_list}
    FOR    ${rmod_id}    IN    @{RMOD_ID_LIST}
        vDU Lock RU And Check Status    ${rmod_id}    vdu_index=${vdu_index}    cu_index=${cu_index}
        vDU Unlock RU And Check Status    ${rmod_id}    vdu_index=${vdu_index}    cu_index=${cu_index}
    END

vDU Lock All RUs And Check Status For All CUs
    [Arguments]    ${vdu_list}=${VDU_LIST}
    FOR    ${vdu_index}    IN    @{vdu_list}
        ${vdu_index}    ${cu_index}    Split String    ${vdu_index}    -
        vDU Lock All RUs And Check Status    vdu_index=${vdu_index}   cu_index=${cu_index}
    END

vDU Unlock All RUs And Check Status For All CUs
    [Arguments]    ${vdu_list}=${VDU_LIST}
    FOR    ${vdu_index}    IN    @{vdu_list}
        ${vdu_index}    ${cu_index}    Split String    ${vdu_index}    -
        vDU Unlock All RUs And Check Status    vdu_index=${vdu_index}   cu_index=${cu_index}
    END

vDU Lock Unlock All RUs And Check Status For All CUs
    [Arguments]    ${vdu_list}=${VDU_LIST}
    FOR    ${vdu_index}    IN    @{vdu_list}
        ${vdu_index}    ${cu_index}    Split String    ${vdu_index}    -
        vDU Lock Unlock All RUs And Check Status    vdu_index=${vdu_index}   cu_index=${cu_index}
    END

vDU Get Cells Status
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${cells_status}    vdu.get_vdu_cells_status
    [Return]    ${cells_status}
    [Teardown]    Run Keyword And Ignore Error    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU Get Specified Cell Status
    [Arguments]    ${cell_id}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    ${cells_info}    vDU Get Cells Status    vdu_index=${vdu_index}    cu_index=${cu_index}
    FOR    ${cell_info}    IN    @{cells_info}
        ${administrative_state}=    Convert To Lowercase   ${cell_info["administrative_state"]}
        ${operational_state}=    Convert To Lowercase     ${cell_info["operational_state"]}
        ${blocking_state}=    Convert To Lowercase     ${cell_info["blocking_state"]}
        ${availability_status}=    Convert To Lowercase     ${cell_info["availability_status"]}
        ${cell_status}    Create Dictionary    administrative_state=${administrative_state}
        ...    operational_state=${operational_state}    blocking_state=${blocking_state}
        ...    availability_status=${availability_status}
        Return From Keyword If    '${cell_info["id"]}' == '${cell_id}'     ${cell_status}
    END

Get Cell ID List
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    ${cell_id_list}    Create List
    ${cells_info}    vDU Get Cells Status    vdu_index=${vdu_index}    cu_index=${cu_index}
    FOR    ${cell_info}    IN    @{cells_info}
        Append To List    ${cell_id_list}    ${cell_info["id"]}
    END
    [Return]    ${cell_id_list}

vDU Check Cells Status
    [Arguments]    ${cell_id_list}    ${except_cell_id_list}=${EMPTY}
    ...    ${expected_administrative_state}=unlocked
    ...    ${expected_operational_state}=enabled    ${expected_blocking_state}=unblocked
    ...    ${expected_availability_status}=on line    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${except_cell_id_list}   ${cell_id}
        Continue For Loop If   ${status}
        ${cell_status}    vDU Get Specified Cell Status    ${cell_id}    ${vdu_index}    ${cu_index}
        Run Keyword And Continue On Failure    Should Be True
        ...    "${expected_administrative_state}"=="${cell_status["administrative_state"]}"
        ...    Cell ${cell_id} administrative state does not meet expectations!
        Run Keyword And Continue On Failure    Should Be True
        ...    "${expected_operational_state}"=="${cell_status["operational_state"]}"
        ...    Cell ${cell_id} operational state does not meet expectations!
        Run Keyword And Continue On Failure    Should Be True
        ...    "${expected_blocking_state}"=="${cell_status["blocking_state"]}"
        ...    Cell ${cell_id} blocking state does not meet expectations!
        Run Keyword And Continue On Failure    Should Be True
        ...    "${expected_availability_status}"=="${cell_status["availability_status"]}"
        ...    Cell ${cell_id} availability status does not meet expectations!
    END

vDU Check All Cells Status
    [Arguments]    ${expected_administrative_state}=unlocked    ${expected_operational_state}=enabled
    ...            ${expected_blocking_state}=unblocked         ${expected_availability_status}=on line
    FOR    ${vdu_index}    IN    @{VDU_LIST}
        ${vdu_index}    ${cu_index}    Split String    ${vdu_index}    -
        ${cell_id_list}    Get Cell ID List    vdu_index=${vdu_index}    cu_index=${cu_index}
        Wait Until Keyword Succeeds    120s    5s    vDU Check Cells Status
        ...    ${cell_id_list}    ${expected_administrative_state}    ${expected_operational_state}
        ...    ${expected_blocking_state}    ${expected_availability_status}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    END

vDU Lock Cells
    [Arguments]    ${cell_id_list}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    vdu.lock_cells    ${cell_id_list}
    [Teardown]    Run Keyword And Ignore Error    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU Unlock Cells
    [Arguments]    ${cell_id_list}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    vdu.unlock_cells    ${cell_id_list}
    [Teardown]    Run Keyword And Ignore Error    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU Lock Cells And Check Status
    [Arguments]    ${cell_id_list}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    vDU Lock Cells    ${cell_id_list}    vdu_index=${vdu_index}    cu_index=${cu_index}
    Wait Until Keyword Succeeds    120s    5s
    ...    vDU Check Cells Status    cell_id_list=${cell_id_list}    expected_administrative_state=locked
    ...    expected_operational_state=enabled   vdu_index=${vdu_index}    cu_index=${cu_index}
    Wait Until Keyword Succeeds    120s    5s    Check Expected Alarms Is Appear In vDU    expected_fault_id=49
    ...    vdu_index=${vdu_index}    cu_index=${cu_index}

vDU Unlock Cells And Check Status
    [Arguments]    ${cell_id_list}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    vDU Unlock Cells    ${cell_id_list}    vdu_index=${vdu_index}    cu_index=${cu_index}
    Wait Until Keyword Succeeds    120s    5s
    ...    vDU Check Cells Status    cell_id_list=${cell_id_list}    expected_administrative_state=unlocked
    ...    expected_operational_state=enabled    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${status}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    60s    10s    Check Expected Alarms Is Appear In vDU    expected_fault_id=49
    ...    vdu_index=${vdu_index}    cu_index=${cu_index}
    Should Not Be True     ${status}

vDU Lock All Cells And Check Status
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    ${cell_id_list}    Get Cell ID List    vdu_index=${vdu_index}    cu_index=${cu_index}
    vDU Lock Cells And Check Status    ${cell_id_list}    ${vdu_index}    ${cu_index}

vDU Unlock All Cells And Check Status
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    ${cell_id_list}    Get Cell ID List    vdu_index=${vdu_index}    cu_index=${cu_index}
    vDU Unlock Cells And Check Status    ${cell_id_list}    ${vdu_index}    ${cu_index}

vDU Lock All Cells And Check Status For All CUs
    [Arguments]    ${vdu_list}=${VDU_LIST}
    FOR    ${vdu_index}    IN    @{vdu_list}
        ${vdu_index}    ${cu_index}    Split String    ${vdu_index}    -
        vDU Lock All Cells And Check Status    vdu_index=${vdu_index}    cu_index=${cu_index}
    END

vDU Unlock All Cells And Check Status For All CUs
    [Arguments]    ${vdu_list}=${VDU_LIST}
    FOR    ${vdu_index}    IN    @{vdu_list}
        ${vdu_index}    ${cu_index}    Split String    ${vdu_index}    -
        vDU Unlock All Cells And Check Status    vdu_index=${vdu_index}    cu_index=${cu_index}
    END

vDU Check Block Cell Operation Status
    [Arguments]    ${operation_id}    ${expected_status}
    ${out}    vdu.get_block_cell_operation_status    operation_id=${operation_id}
    Should Be True    "${out["status"]}"=="${expected_status}"

vDU Check Unblock Cell Operation Status
    [Arguments]    ${operation_id}    ${expected_status}
    ${out}    vdu.get_unblock_cell_operation_status    operation_id=${operation_id}
    Should Be True    "${out["status"]}"=="${expected_status}"

vDU Block Cells
    [Arguments]    ${cell_id_list}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${out}    vdu.block_cell    cell_id=${cell_id}
        Wait Until Keyword Succeeds    60    5    vDU Check Block Cell Operation Status
        ...    operation_id=${out["id"]}    expected_status=success
    END
    [Teardown]    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU Unblock Cells
    [Arguments]    ${cell_id_list}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${out}    vdu.unblock_cell    cell_id=${cell_id}
        Wait Until Keyword Succeeds    60    5    vDU Check Unblock Cell Operation Status
        ...    operation_id=${out["id"]}    expected_status=success
    END
    [Teardown]    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU Block Cells And Check Status
    [Arguments]    ${cell_id_list}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    vDU Block Cells    ${cell_id_list}    vdu_index=${vdu_index}    cu_index=${cu_index}
    Wait Until Keyword Succeeds    120s    5s
    ...    vDU Check Cells Status    cell_id_list=${cell_id_list}    expected_blocking_state=blocked
    ...    expected_operational_state=disabled    vdu_index=${vdu_index}    cu_index=${cu_index}

vDU Unblock Cells And Check Status
    [Arguments]    ${cell_id_list}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    vDU Unblock Cells    ${cell_id_list}    vdu_index=${vdu_index}    cu_index=${cu_index}
    Wait Until Keyword Succeeds    120s    5s
    ...    vDU Check Cells Status    cell_id_list=${cell_id_list}    expected_blocking_state=unblocked
    ...    expected_operational_state=enabled    vdu_index=${vdu_index}    cu_index=${cu_index}

vDU Block All Cells And Check Status
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    ${cell_id_list}    Get Cell ID List    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    vDU Block Cells And Check Status    ${cell_id_list}    ${vdu_index}    ${cu_index}

vDU Unblock All Cells And Check Status
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    ${cell_id_list}    Get Cell ID List    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    vDU Unblock Cells And Check Status    ${cell_id_list}    ${vdu_index}    ${cu_index}

vDU Block All Cells And Check Status For All CUs
    [Arguments]    ${vdu_list}=${VDU_LIST}
    FOR    ${vdu_index}    IN    @{vdu_list}
        ${vdu_index}    ${cu_index}    Split String    ${vdu_index}    -
        vDU Block All Cells And Check Status    vdu_index=${vdu_index}    cu_index=${cu_index}
    END

vDU Unblock All Cells And Check Status For All CUs
    [Arguments]    ${vdu_list}=${VDU_LIST}
    FOR    ${vdu_index}    IN    @{vdu_list}
        ${vdu_index}    ${cu_index}    Split String    ${vdu_index}    -
        vDU Unblock All Cells And Check Status    vdu_index=${vdu_index}    cu_index=${cu_index}
    END

vDU Check Reset RUs Operation Status
    [Arguments]    ${operation_id}    ${expected_status}
    ${out}    vdu.get_reset_rmods_operation_status    operation_id=${operation_id}
    Should Be True    "${out["status"]}"=="${expected_status}"

vDU Reset RU
    [Arguments]    ${rmod_id}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${out}    vdu.reset_rmods    ${rmod_id}
#        Wait Until Keyword Succeeds    ${ONAIR_TIME}    30
#        ...    vDU Check Reset RUs Operation Status   operation_id=${out["operation_id"]}    expected_status=success
     ${rmod_info}    vDU Get Rmods Info By ID    ${rmod_id[0]}
     ${cell_ids}   Set Variable  ${rmod_info["cell_ids"]}
     Wait Until Keyword Succeeds    10min    30
        ...    vDU Check Cells Status   cell_id_list=${cell_ids}    expected_operational_state=disabled
        ...    expected_availability_status=failed
    [Teardown]    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU Reset All RUs And Check Onair
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    ${rmod_id_list}    Get RMOD ID List    ${vdu_index}   ${cu_index}
    FOR    ${rmod_id}    IN    @{rmod_id_list}
        ${rmod_id}    Convert To List    ${rmod_id}
        vDU Reset RU    ${rmod_id}    vdu_index=${vdu_index}    cu_index=${cu_index}
    END
    Wait Until Keyword Succeeds    600    10s
    ...    vDU Verify All Cells OnAir    vdu_index=${vdu_index}    cu_index=${cu_index}

vDU Reset All RUs And Check Onair For All CUs
    [Arguments]    ${vdu_list}=${VDU_LIST}
    FOR    ${vdu_index}    IN    @{vdu_list}
        ${vdu_index}    ${cu_index}    Split String    ${vdu_index}    -
        vDU Reset All RUs And Check Onair    vdu_index=${vdu_index}    cu_index=${cu_index}
    END

vDU Check Reset VDU Operation Status
    [Arguments]    ${operation_id}    ${expected_status}
    ${out}    vdu.get_reset_vdu_operation_status    operation_id=${operation_id}
    Should Be True    "${out["status"]}"=="${expected_status}"

vDU Reset VDU
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    ${vdu_state_bef}    vCU Get vDU State    cu_index=${cu_index}
    ${vdu_available_count_bef}    Set Variable    ${vdu_state_bef["f1_link_status"]["available"]}
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${out}    vdu.reset_vdu
    Wait Until Keyword Succeeds    30    3    vDU Check Reset VDU Operation Status    operation_id=${out["id"]}
    ...    expected_status=ongoing
    Sleep    10s
    ${compare_value}    Evaluate    ${vdu_available_count_bef}-1
    Wait Until Keyword Succeeds    ${ONAIR_TIME}    5s    vCU Check vDU State    ${compare_value}    cu_index=${cu_index}
    [Teardown]    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU Reset VDU And Check Onair
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    vDU Reset VDU    vdu_index=${vdu_index}    cu_index=${cu_index}
    Wait Until Keyword Succeeds    ${ONAIR_TIME}    10s
    ...    vDU Verify All Cells OnAir    vdu_index=${vdu_index}    cu_index=${cu_index}

vDU Reset VDU And Check Onair For All CUs
    [Arguments]    ${vdu_list}=${VDU_LIST}
    FOR    ${vdu_index}    IN    @{vdu_list}
        ${vdu_index}    ${cu_index}    Split String    ${vdu_index}    -
        vDU Reset VDU And Check Onair    vdu_index=${vdu_index}    cu_index=${cu_index}
    END

vDU Delete Delta Plan By Id
    [Arguments]    ${plan_id}    ${vdu_index}=vDU_0    ${cu_index}=CU_0    ${timeout}=60
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    vdu.delete_delta_plan_file    plan_id=${plan_id}    timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU Get Delta Plan Number
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${plan_list}    vdu.get_delta_plan_info_list
    [Return]    ${plan_list}
    [Teardown]    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU Check Delta Plan Number
    [Arguments]    ${expect_num}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    ${plan_list}    vDU Get Delta Plan Number    vdu_index=${vdu_index}    cu_index=${cu_index}
    Should Be True    "${plan_list.__len__()}"=="${expect_num}"

vDU Delete Delta Plan If Reach Max
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    ${all_plans}    vDU Get Delta Plan Number    vdu_index=${vdu_index}    cu_index=${cu_index}
    Run Keyword If    ${all_plans.__len__()}==1    vDU Delete Delta Plan By Id    plan_id=${all_plans[0]["plan_id"]}
    Wait Until Keyword Succeeds    60    5
    ...    vDU Check Delta Plan Number    expect_num=0    vdu_index=${vdu_index}    cu_index=${cu_index}

vDU Check Delta Plan Generate Status
    [Arguments]    ${action_id}    ${expected_status}
    ${out}    vdu.get_delta_plan_generated_action_status    action_id=${action_id}
    Should Be True    "${out["status"]}"=="${expected_status}"

vDU Generate Delta Plan
    [Arguments]    ${plan_name}    ${plan_description}=${EMPTY}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${out}    vdu.generate_delta_plan    plan_name=${plan_name}    plan_description=${plan_description}
    ${temp_plan_id}    Set Variable    ${out["plan_id"]}
    ${temp_action_id}    Set Variable    ${out["action_id"]}
    Wait Until Keyword Succeeds    30    3    vDU Check Delta Plan Generate Status    action_id=${temp_action_id}
    ...    expected_status=success
    [Return]    ${temp_plan_id}    ${temp_action_id}
    [Teardown]    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU Check Update Parameter Status
    [Arguments]    ${plan_id}    ${action_id}    ${expected_status}
    ${out}    vdu.get_update_paras_action_status_of_delta_plan
    ...    plan_id=${plan_id}    action_id=${action_id}
    Should Be True    "${out["status"]}"=="${expected_status}"

vDU Update Parameter Of Delta Plan
    [Arguments]    ${plan_id}    ${dist_name}    ${updated_paras_dict}    ${operation}=replace
    ...    ${mo_uuid}=${None}    ${timeout}=30    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${timeout}    convert to integer    ${timeout}
    ${out}    vdu.update_vdu_parameter_of_delta_plan    plan_id=${plan_id}    mo_dn=${dist_name}
    ...    updated_paras_dict=${updated_paras_dict}    operation=${operation}    mo_uuid=${mo_uuid}
    ...    timeout=${timeout}
    Wait Until Keyword Succeeds    20    2    vDU Check Update Parameter Status
    ...    plan_id=${plan_id}    action_id=${out["action_id"]}    expected_status=success
    [Return]  ${out}
    [Teardown]    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU Check Validate Delta Plan Status
    [Arguments]    ${expected_status}    ${action_id}    ${plan_id}   ${timeout}=30
    ${out}    vdu.get_validate_delta_plan_operation_status    action_id=${action_id}    delta_plan_id=${plan_id}
    ...    timeout=${timeout}
    Should Be True    "${out["status"]}"=="${expected_status}"
    [Return]    ${out}

vDU Validate Delta Plan
    [Arguments]    ${plan_id}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${out}    vdu.validate_delta_plan    delta_plan_id=${plan_id}
    ${rtn}    Wait Until Keyword Succeeds    20    2
    ...    vDU Check Validate Delta Plan Status    action_id=${out["action_id"]}    plan_id=${plan_id}
    ...    expected_status=success
    ${validation_id}    Set Variable    ${rtn["validation_id"]}
    ${errors}    vdu.get_delta_plan_validation_results    plan_id=${plan_id}    validation_id=${validation_id}
    ${error_num}    Set Variable    ${errors["total"]}
    Should Be True    ${error_num}<=0
    [Return]    ${validation_id}
    [Teardown]    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU Check Activate Delta Plan Status
    [Arguments]    ${operation_id}    ${plan_id}    ${expected_status}   ${timeout}=30
    ${out}    vdu.get_activate_delta_plan_operation_status    operation_id=${operation_id}    delta_plan_id=${plan_id}
    ...    timeout=${timeout}
    Should Be True    "${out["status"]}"=="${expected_status}"

vDU Activate Delta Plan
    [Arguments]    ${plan_id}    ${force_reset}=${True}    ${auto_lock_cells}=${True}    ${timeout}=60
    ...            ${vdu_index}=vDU_0    ${cu_index}=CU_0
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${tmp_file_id}    Get Unique ID    prefix=delta_plan
    ${delta_scf_fullpath}    vdu.save_delta_plan_file
    ...    local_path=${TEST_LOGS_DIR_PATH}    local_filename=${tmp_file_id}.xml
    ${out}    vdu.activate_delta_plan    delta_plan_id=${plan_id}
    ...    force_reset=${force_reset}    auto_lock_cells=${auto_lock_cells}    timeout=${timeout}
    Wait until keyword succeeds    600    30s
    ...    vDU Check Activate Delta Plan Status    operation_id=${out['id']}    plan_id=${plan_id}
    ...    expected_status=success
    [Teardown]    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU Search And Check Parameter Of Current Plan
    [Arguments]     ${dist_name}    ${para_dict}    ${timeout}=30
    ${para_name_list}    Get Dictionary Keys    ${para_dict}
    ${get_value_dict}    Create Dictionary
    FOR    ${para_name}    IN    @{para_name_list}
        ${out}    vdu.search_parameter_of_current_plan    mo_dn=${dist_name}
        ...    para_name=${para_name}    timeout=${timeout}
        Set To Dictionary    ${get_value_dict}    ${para_name}=${out}
        Should Be True    "${out}"=="${para_dict["${para_name}"]}"
    END

vDU Check Update Parameter Value
    [Arguments]     ${update_paras_dict}    ${timeout}=30    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${dn_list}    Get Dictionary Keys    ${update_paras_dict}
    FOR    ${dist_name}    IN    @{dn_list}
        vDU Search And Check Parameter Of Current Plan
        ...    dist_name=${dist_name}    para_dict=${update_paras_dict["${dist_name}"]}    timeout=${timeout}
    END
    [Teardown]    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU Multi Parameters Recommission By Delta Plan
    [Arguments]    ${vdu_delta_json}    ${timeout}=300    ${vdu_index}=vDU_0    ${cu_index}=CU_0
#    [Documentation]    Example:
#    ...    ${update_paras_dict}={"dist_name1": {'para_name1':'para_value1', 'para_name2':'para_value2', ...}, ...}
#    ${timeout}    convert to integer    ${timeout}
#    vDU Delete Delta Plan If Reach Max    vdu_index=${vdu_index}    cu_index=${cu_index}
#    ${delta_plan_name}    Get Unique ID    prefix=${cu_index}_${vdu_index}
#    ${plan_id}    ${action_id}    vDU Generate Delta Plan    plan_name=${delta_plan_name}    plan_description=TA
#    ...    vdu_index=${vdu_index}    cu_index=${cu_index}
#    ${dn_list}    Get Dictionary Keys    ${update_paras_dict}
#    ${du_state_bef}    vCU Get vDU State    cu_index=${cu_index}
#    ${available_du_count_bef}    Set Variable    ${du_state_bef["f1_link_status"]["available"]}
#    FOR    ${dist_name}    IN    @{dn_list}
#        ${out}    vDU Update Parameter Of Delta Plan    plan_id=${planid}    dist_name=${dist_name}
#        ...    updated_paras_dict=${update_paras_dict["${dist_name}"]}    operation=${operation}
#        ...    vdu_index=${vdu_index}    cu_index=${cu_index}
#    END
#    ${validation_id}    vDU Validate Delta Plan    plan_id=${planid}
#    vDU Activate Delta Plan    plan_id=${plan_id}    force_reset=${force_reset}
#    ...    auto_lock_cells=${auto_lock_cells}    timeout=${timeout}
#    Sleep    10s
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${vdu_para_status}    vdu.perform_delta_recommissioning    ${vdu_delta_json}
    ...    wait_for_completion=True    timeout=${timeout}
    Should Be True    "${vdu_para_status["status"]}"=="success"
#    ${du_state_aft}    vCU Get vDU State    cu_index=${cu_index}
#    ${available_du_count_aft}    Set Variable    ${du_state_aft["f1_link_status"]["available"]}
#    ${compare_value}    Evaluate    ${available_du_count_bef}-1
#    Run Keyword If    "${recommission_type}"=="site_reset"    Should Be True
#    ...    "${available_du_count_aft}"=="${compare_value}"
    Wait For All Cells Onair In All vDUs
#    vDU Check Update Parameter Value    ${update_paras_dict}    vdu_index=${vdu_index}    cu_index=${cu_index}
    Wait For All Cells Onair In All CUs
    [Teardown]    Run Keyword And Ignore Error    Logout To vDU By Rest

Connect SSH To VDU
    [Arguments]    ${vdu}    ${alias}=default
    ${vdu_info_dict}    Get SSH Connection Infor For Multiple vDUs K8s Master
    csn.connect to    hostname=${vdu_info_dict["${vdu}"]["addr"]}
    ...               username=${vdu_info_dict["${vdu}"]["username"]}
    ...               password=${vdu_info_dict["${vdu}"]["password"]}
    ...               alias=${alias}

Disconnect SSH To VDU
    [Arguments]    ${connection}=default
    csn.disconnect    connection=${connection}

Update VDU Password
    [Arguments]    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    ${gnb_index}    Fetch From Right    ${cu_index}    _
    ${vdu_index}    Fetch From Right    ${vdu_index}    _
    ${oam_httpaddr}    set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${oam_web_ip}    set variable if    ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=${EMPTY}
    ...  username=Nemuadmin
    ...  password=nemuuser
    ...  secure=True
#    vdu.update_expired_password
#    ...    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    [Teardown]    Run Keyword And Ignore Error    vdu.disconnect

Multi VDUs Clear Configuration With Kuafu
    FOR    ${vdu}    IN    @{VDU_LIST}
        VDU Clear Configuration With Kuafu    ${vdu}
    END

VDU Clear Configuration With Kuafu
    [Arguments]    ${vdu}
    Connect SSH To VDU    ${vdu}    alias=vdu_kuafu
    ${kuafu_dir}    csn.execute    ls -l | grep "kuafu*" | grep "^d" | awk '{print $9}'    connection=vdu_kuafu
    ${kuafu_dir}    Strip String    ${kuafu_dir}    characters=\r\n
    ${conenction_kuafu}    csn.get connection by alias    alias=vdu_kuafu
    ${channel} =    Call Method    ${conenction_kuafu}    invoke_shell
    sleep   10s
    Call Method    ${channel}    recv      ${65535}
    Call Method    ${channel}    send    cd ${kuafu_dir}\n
    sleep    1s
    Call Method    ${channel}    recv      ${65535}
    Call Method    ${channel}    send    . ./10-vdu-l3call-test.sh\n
    Sleep    10s
    ${ret}    Call Method    ${channel}    recv      ${65535}
    ${ret}    Convert To String    ${ret}
    Should Contain    ${ret}    20-delete-vdu.sh
    Should Contain    ${ret}    21-create-vdu.sh
    Call Method    ${channel}    send    ./20-delete-vdu.sh\n
    Wait Cmd End    Delete vDU successfully    ${channel}
    Cycle Send Cmd And Check    kubectl get pod -n ran-nic-sw-controller   ongoing    ${channel}
    ...    count=4     wait_time=30s    wait_cont=20
    Call Method    ${channel}    send    ./21-create-vdu.sh\n
    Wait Cmd End    Create vDU successfully    ${channel}    wait_time=30s    wait_cont=30
    ${cu_index}    ${vdu_index}    Split String    ${vdu}    -
    Call Method    ${channel}    close
    Update VDU Password    ${cu_index}    ${vdu_index}
    [Teardown]    Disconnect SSH To VDU    connection=vdu_kuafu

Wait Cmd End
    [Arguments]    ${eof}    ${channel}    ${wait_time}=10s    ${wait_cont}=10    ${timeout}=10 min
    [Timeout]    ${timeout}
    ${end_flag}    Set Variable    ${False}
    FOR    ${i}   IN RANGE    ${wait_cont}
        ${ret}    Call Method    ${channel}    recv      ${65535}
        ${ret}    Convert To String    ${ret}
        ${status}    Run Keyword And Return Status    Should Contain    ${ret}    ${eof}
        ${end_flag}    Set Variable If    ${status}    ${True}    ${False}
        Exit For Loop If     ${status}
        Sleep    ${wait_time}
    END
    Should Be True    ${end_flag}

Cycle Send Cmd And Check
    [Arguments]    ${command}    ${eof}    ${channel}    ${count}=1    ${wait_time}=10s    ${wait_cont}=10
    ${end_flag}    Set Variable    ${False}
    FOR    ${i}   IN RANGE    ${wait_cont}
        Call Method    ${channel}    send    ${command}\n
        sleep    10s
        ${ret}    Call Method    ${channel}    recv      ${65535}
        ${ret}    Convert To String    ${ret}
        ${status}    Run Keyword And Return Status    Should Contain X times   ${ret}    ${eof}    ${count}
        ${end_flag}    Set Variable If    ${status}    ${True}    ${False}
        Exit For Loop If     ${status}
        Sleep    ${wait_time}
    END
    Should Be True    ${end_flag}

vDU Startup With Delayed RF Link
    [Arguments]    ${timeout}=${ONAIR_TIME}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    ${vdu_cfg}    Set Variable    ${NODE_CFG['${cu_index}']['${vdu_index}']}
    ${fr_sn_list}    Set Variable    ${vdu_cfg['fr_sn_list']}
    ${teardown}    Set Variable    ${True}
    PDU Turn Off All Devices From Serial Number List    ${fr_sn_list}    ${BTS_CONFIG}    FR
    vDU Reset VDU    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    Sleep    30s
    Wait Until Keyword Succeeds    ${timeout}    10 sec    Check Expected Alarms Is Appear In vDU
    ...    expected_fault_id=10    vdu_index=${vdu_index}    cu_index=${cu_index}
    Wait Until Keyword Succeeds    ${timeout}    10 sec    Check Expected Alarms Is Appear In CU
    ...    expected_fault_id=7104    cu_index=${cu_index}
	Sleep    30s
    PDU Turn On All Devices From Serial Number List    ${fr_sn_list}    ${BTS_CONFIG}    FR
    ${teardown}    Set Variable    ${False}
    Wait Until Keyword Succeeds   300 sec    10 sec   Check Alarms In vDUs
    Wait Until Keyword Succeeds   300 sec    10 sec   Check Alarms In CUs
    Wait For All Cells Onair In All CUs    timeout=${ONAIR_TIME}
    [Teardown]    Run Keyword If    ${teardown}    Run Keywords
    ...    PDU Turn On All Devices From Serial Number List    ${fr_sn_list}    ${BTS_CONFIG}    FR
    ...    AND    Wait For All Cells Onair In All CUs    timeout=${ONAIR_TIME}

vDU Delete Delta Plan MO
    [Arguments]  ${delta_plan_id}   ${mo_dn}    ${timeout}=${60}
    ${out}  vdu.delete_mo_of_delta_plan   delta_plan_id=${delta_plan_id}  mo_dn=${mo_dn}   timeout=${timeout}
    ${action_id}  set variable  ${out["action_id"]}
    ${out}     vDU Check Delete Delta Plan MO Status   plan_id=${delta_plan_id}   action_id=${action_id}
    [Return]  ${out}

vDU Check Delete Delta Plan MO Status
    [Arguments]  ${delta_plan_id}   ${action_id}
    ${rtn}  wait until keyword succeeds  20   2
    ...   _vDU Check Delta Plan Delete MO Status   plan_id=${delta_plan_id}   action_id=${action_id}   expected_status=success
    [Return]  ${rtn}

_vDU Check Delta Plan Delete MO Status
    [Arguments]   ${delta_plan_id}   ${action_id}   ${expected_status}
    ${out}   vdu.get_deleting_mo_action_state_of_delta_plan      delta_plan_id=${delta_plan_id}  action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

vDU Update Delta Plan Parameter
    [Arguments]    ${plan_id}    ${mo_dn}    ${updated_paras_dict}    ${operation}=replace
    ...    ${mo_uuid}=${None}    ${timeout}=30
    ${timeout}    convert to integer    ${timeout}
    ${out}    vdu.update_vdu_parameter_of_delta_plan    plan_id=${plan_id}    mo_dn=${mo_dn}
    ...    updated_paras_dict=${updated_paras_dict}    operation=${operation}    mo_uuid=${mo_uuid}
    ...    timeout=${timeout}
    Wait Until Keyword Succeeds    20    2    vDU Check Update Parameter Status
    ...    plan_id=${plan_id}    action_id=${out["action_id"]}    expected_status=success
    [Return]  ${out}

Delete vDU Cell
    [Arguments]    ${plan_id}    ${nrcell_info}
    ${bts_id}    Set Variable     ${nrcell_info["btsId"]}
    vDU Delete Delta Plan MO    delta_plan_id=${plan_id}
    ...    mo_dn=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${nrcell_info["cellId"]}
    vDU Delete Delta Plan MO    delta_plan_id=${plan_id}
    ...    mo_dn=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELLGRP-${nrcell_info["nrCellGRP"]}
    vDU Delete Delta Plan MO    delta_plan_id=${plan_id}
    ...    mo_dn=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${nrcell_info["cellId"]}
    ${value}    vdu.search_parameter_of_current_plan    mo_dn=MRBTS-${bts_id}/NRBTS-${bts_id}/NRDU-1
    ...    para_name=refNrCellGroup
    ${index}    Get Index From List    ${value}    ${nrcell_info["nrCellGRP"]}
    ${paras}=   Create Dictionary   /refNrCellGroup/${index}=${empty}
    vDU Update Delta Plan Parameter    plan_id=${plan_id}    mo_dn=MRBTS-${bts_id}/NRBTS-${bts_id}/NRDU-1
    ...    updated_paras_dict=${paras}    operation=remove

Delete Cells In vDU
    [Arguments]    ${nrcell_list}   ${vdu_index}=vDU_0    ${cu_index}=CU_0   ${check_cell_status}=True    ${timeout}=60
    vDU Delete Delta Plan If Reach Max    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${delta_plan_name}    Get Unique ID    prefix=${cu_index}_${vdu_index}
    ${plan_id}    ${action_id}    vDU Generate Delta Plan    plan_name=${delta_plan_name}    plan_description=TA
    ...    vdu_index=${vdu_index}    cu_index=${cu_index}
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    FOR    ${nrcell_info}    IN    @{nrcell_list}
        Delete vDU Cell    ${plan_id}    ${nrcell_info}
    END
    ${validation_id}    vDU Validate Delta Plan    plan_id=${planid}
    vDU Activate Delta Plan    plan_id=${plan_id}    timeout=${timeout}
    Run Keyword If    ${check_cell_status}    vDU Verify All Cells OnAir    vdu_index=${vdu_index}    cu_index=${cu_index}
    [Teardown]    Run Keyword And Ignore Error    Logout To vDU By Rest

Create Cell Vdu Dictionary
    [Arguments]    ${cells}
    ${cells}    Split String    ${cells}    :
    ${cell_vdu_dict}    Create Dictionary
    FOR    ${pci}    IN    @{cells}
        ${cu_index}    ${vdu_index}    Get CU vDU Index    cell    ${pci}
        ${cell_info}    Get Cell Info With PCI    ${ALL_CELL_LIST}    ${pci}
        ${status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${cell_vdu_dict}    ${cu_index}-${vdu_index}
        ${tmp_list}    Create List    ${cell_info}
        Run Keyword If    ${status}    Append To List    ${cell_vdu_dict["${cu_index}-${vdu_index}"]}    ${cell_info}
        ...    ELSE    Set To Dictionary    ${cell_vdu_dict}    ${cu_index}-${vdu_index}=${tmp_list}
    END
    [Return]    ${cell_vdu_dict}

Add Cells In vDU
    [Arguments]    ${nrcell_list}    ${vdu_index}=vDU_0    ${cu_index}=CU_0    ${check_cell_status}=${True}    ${timeout}=60
    vDU Delete Delta Plan If Reach Max    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${delta_plan_name}    Get Unique ID    prefix=${cu_index}_${vdu_index}
    ${plan_id}    ${action_id}    vDU Generate Delta Plan    plan_name=${delta_plan_name}    plan_description=TA
    ...    vdu_index=${vdu_index}    cu_index=${cu_index}
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    vDU Check Maximum Plan Number And Delete One If Reach Maximum Number
    ${scf_file}    Set Variable    ${NODE_CFG["${cu_index}"]["${vdu_index}"]["scfc"]}
    ${source_plan_id}   ${source_action_id}    ${source_validation_id}  vDU Upload Plan And Validate And Activate
    ...    plan_file=${scf_file}    vdu_index=${vdu_index}    active=${False}
    ${bts_id}    Set Variable    ${nrcell_list[0]['btsId']}
    ${value}    vdu.search_parameter_of_current_plan    mo_dn=MRBTS-${bts_id}/NRBTS-${bts_id}/NRDU-1
    ...    para_name=refNrCellGroup
    ${refNrCellGroup_index}    Get Length    ${value}
    FOR    ${nrcell_info}    IN    @{nrcell_list}
        Add vDU Cell     ${nrcell_info}    ${plan_id}    ${source_plan_id}    ${refNrCellGroup_index}
        ${refNrCellGroup_index}    Evaluate    ${refNrCellGroup_index}+1
    END
    ${validation_id}    vDU Validate Delta Plan    plan_id=${planid}
    vDU Activate Delta Plan    plan_id=${plan_id}    timeout=${timeout}
    Run Keyword If    ${check_cell_status}    Wait Until Keyword Succeeds    5 min    10s    vDU Verify All Cells OnAir
    ...    vdu_index=${vdu_index}    cu_index=${cu_index}
    [Teardown]    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU Copy MO Into Delta Plan
    [Arguments]  ${plan_id}   ${source_plan_id}   ${parent_mo_uuid}   ${mo_uuid}  ${new_instance_id}
    ...   ${include_children_objects}  ${timeout}=30
    ${rtf}    vdu.copy_managed_objects_into_delta_plan
    ...    plan_id=${plan_id}
    ...    source_plan_id=${source_plan_id}
    ...    parent_mo_uuid=${parent_mo_uuid}
    ...    mo_uuid=${mo_uuid}
    ...    new_instance_id=${new_instance_id}
    ...    include_children_objects=${include_children_objects}
    ...    timeout= ${timeout}
#    wait until keyword succeeds   10x   2s
#    ...   _vDU Copy MO Into Delta Plan Should Be Successful   plan_id=${plan_id}   action_id=${rtf['action_id']}   expected_status=success

_vDU Copy MO Into Delta Plan Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}  ${expected_status}
    ${out}   vdu.get_copy_managed_objects_into_delta_plan_status    plan_id=${plan_id}  action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

Add vDU Cell
    [Arguments]    ${nrcell_info}    ${plan_id}    ${source_plan_id}    ${refNrCellGroup_index}
    ${bts_id}    Set Variable     ${nrcell_info["btsId"]}
    ${plan_info_list}   vdu.get_tree_of_staged_plan    plan_id=${source_plan_id}
    ${parent_plan_info_list}    vdu.get_tree_of_delta_plan    plan_id=${plan_id}
    ${nrcell_mo_uuid}    get_value_from_plan_tree_info     info_list=${plan_info_list}
    ...   dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${nrcell_info["cellId"]}   key=mo_uuid
    ${parent_mo_uuid}    get_value_from_plan_tree_info     info_list=${parent_plan_info_list}
    ...   dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}   key=mo_uuid
    ${nrcellgrp_mo_uuid}    get_value_from_plan_tree_info    info_list=${plan_info_list}
    ...    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELLGRP-${nrcell_info["nrCellGRP"]}   key=mo_uuid
    ${lcelnr_mo_uuid}    get_value_from_plan_tree_info     info_list=${plan_info_list}
    ...   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${nrcell_info["cellId"]}    key=mo_uuid
    ${lcelnr_parent_mo_uuid}    get_value_from_plan_tree_info     info_list=${parent_plan_info_list}
    ...   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1   key=mo_uuid

    vDU Copy MO Into Delta Plan    plan_id=${plan_id}   source_plan_id=${source_plan_id}   parent_mo_uuid=${parent_mo_uuid}
    ...    mo_uuid=${nrcell_mo_uuid}   new_instance_id=${nrcell_info["cellId"]}    include_children_objects=${True}
    ${updated_paras_dict}   create dictionary    lcrId=${nrcell_info['lcrId']}
    vDU Update Delta Plan Parameter    plan_id=${plan_id}
    ...    mo_dn=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${nrcell_info["cellId"]}
    ...    updated_paras_dict=${updated_paras_dict}    operation=replace

    vDU Copy MO Into Delta Plan   plan_id=${plan_id}   source_plan_id=${source_plan_id}   parent_mo_uuid=${parent_mo_uuid}
    ...    mo_uuid=${nrcellgrp_mo_uuid}   new_instance_id=${nrcell_info["nrCellGRP"]}    include_children_objects=${True}

    vDU Copy MO Into Delta Plan   plan_id=${plan_id}   source_plan_id=${source_plan_id}   parent_mo_uuid=${lcelnr_parent_mo_uuid}
    ...    mo_uuid=${lcelnr_mo_uuid}   new_instance_id=${nrcell_info["cellId"]}    include_children_objects=${True}

    ${updated_paras_dict}   create dictionary   /refNrCellGroup/${refNrCellGroup_index}=${nrcell_info['nrCellGRP']}
    vDU Update Delta Plan Parameter    plan_id=${plan_id}    mo_dn=MRBTS-${bts_id}/NRBTS-${bts_id}/NRDU-1
    ...    updated_paras_dict=${updated_paras_dict}    operation=add

#---------------------CU--------------------------------------------------------------------------
Login To CU By Rest
    [Arguments]   ${cu_index}=CU_0   ${alias}=${None}    ${timeout}=120
    ${gnb_index}    Fetch From Right    ${cu_index}    _
    ${host}    set variable  ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    run keyword and ignore error    Logout To CU By Rest
    cu.connect to    host=${host}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    secure=${True}
    ...    alias=${alias}
    ...    timeout=${timeout}
    [Return]  ${alias}

Login To Specify Resource vCU
    [Arguments]    ${resource_type}    ${resource_id}
    ${cu_index}    ${vdu_index}    Get CU vDU Index    ${resource_type}    ${resource_id}
    ${cu_version}    Set Variable    ${NOFG_CFG["${cu_index}"]["cu_version"]}
    Login To CU By Rest    cu_index=${cu_index}    restapi_version=${cu_version}

Logout To CU By Rest
    [Arguments]    ${connection}=${None}
    cu.disconnect    connection=${connection}

Wait For All Cells Onair In All CUs
    [Arguments]    ${timeout}=${ONAIR_TIME}
    Wait Until Keyword Succeeds    ${timeout}    30 sec    vCU Verify All Cells Onair For All CUs

Reset CUs Until All Cells Onair In All CUs
    [Arguments]    ${cu_list}=${CU_LIST}    ${timeout}=${ONAIR_TIME}
    FOR    ${cu_index}    IN    @{cu_list}
        Login To CU By Rest    cu_index=${cu_index}
        ${out}    vdu.reset_cu
    END
    Wait For All Cells Onair In All CUs    timeout=${timeout}
    [Teardown]    Logout To CU By Rest

Get CU Current SCFC
    [Arguments]    ${cu_index}=CU_0
    ${date}    Get Current Date    result_format=%Y%m%d%H%M%S
    Login To CU By Rest    cu_index=${cu_index}
    ${cu_current_scfc}=    cu.get_current_plan_file    path=${TEST_LOGS_DIR_PATH}/SCFC_${cu_index}_${date}.xml
    ...    include_runtime_data=${True}
    [Return]    ${TEST_LOGS_DIR_PATH}/SCFC_${cu_index}_${date}.xml
    [Teardown]    Logout To CU By Rest

Template File Commissioning In Multi CUs
    [Arguments]    ${cu_list}=${CU_LIST}
    FOR    ${cu_index}    IN    @{cu_list}
        ${cu_scf}    Set Variable    ${NODE_CFG["${cu_index}"]["scfc"]}
        CU Full Commssion By Rest    ${cu_scf}    ${cu_index}
    END

CU Full Commssion By Rest
    [Arguments]    ${path_of_commission_file}    ${cu_index}=CU_0    ${timeout}=300
    log to console  Full Commission SCF On VCU ${cu_index}
    Login To CU By Rest    cu_index=${cu_index}
    cu.perform_commissioning     ${path_of_commission_file}   timeout=${timeout}
    ...    wait_for_completion=True
#    log to console   \n*** Start plan upload operation ***
#    CU Check Maximum Plan Number And Delete One If Reach Maximum Number
#    ${upload_operation_info}=   cu.upload_plan_file     ${path_of_commission_file}   timeout=${timeout}
#    log to console   \n*** Wait plan upload operation success ***
#    wait until keyword succeeds    60s   5s  CU Check Plan Upload Status As Expected
#    ...    ${upload_operation_info["action_id"]}    success
#    log to console   \n*** Start plan validate operation ***
#    ${validate_operaition_info}=  cu.plan_validation    ${upload_operation_info["plan_id"]}
#    log to console   \n*** Wait plan validate operation success ***
#    wait until keyword succeeds    180s   10s  CU Check Plan Validate Status As Expected
#    ...    ${upload_operation_info["plan_id"]}   ${validate_operaition_info["action_id"]}    success
#    log to console   \n*** Start plan activate operation ***
#    ${activate_operaition_info}=  cu.plan_activation   ${upload_operation_info["plan_id"]}
#    log to console   \n*** Wait plan activate operation success in 10 mins ***
#    wait until keyword succeeds    600s   30s  CU Check Plan Activate Status As Expected
#    ...    ${upload_operation_info["plan_id"]}  ${activate_operaition_info["id"]}    success
    [Teardown]    run keyword and ignore error    Logout To CU By Rest

CU Check Maximum Plan Number And Delete One If Reach Maximum Number
    ${all_plans}   cu.get_staged_plans_list
    Should Be True  ${all_plans.__len__()}<=3
    Run Keyword If  ${all_plans.__len__()}==3   Log To Console  ${all_plans[0]["plan_name"]}/${all_plans[0]["plan_id"]} will be deleted!
    Run Keyword If  ${all_plans.__len__()}==3   cu.plan_delete   plan_id=${all_plans[0]["plan_id"]}

CU Check Plan Upload Status As Expected
    [Arguments]  ${operation_id}   ${expected_status}    ${connection}=${None}
    ${operation_response}=  cu.get_operation_state_of_uploading_plan    ${operation_id}    connection=${connection}
    should be true    "${operation_response["status"]}"=="${expected_status}"

CU Check Plan Validate Status As Expected
   [Arguments]   ${plan_id}  ${operation_id}  ${expected_status}  ${connection}=${None}
   ${operation_response}=  cu.get_operation_state_of_validating_plan     ${plan_id}    ${operation_id}    connection=${connection}
   should be true    "${operation_response["status"]}"=="${expected_status}"

CU Check Plan Activate Status As Expected
    [Arguments]   ${plan_id}  ${operation_id}  ${expected_status}  ${connection}=${None}
    ${operation_response}=  cu.get_operation_state_of_activating_plan    ${plan_id}   ${operation_id}    connection=${connection}
    should be true    "${operation_response["status"]}"=="${expected_status}"

Check Expected Alarms Is Appear In CUs
    [Arguments]    ${expected_fault_id}    ${cu_list}=${CU_LIST}
    FOR    ${cu_index}    IN    @{CU_LIST}
        Run Keyword And Continue On Failure    Check Expected Alarms Is Appear In CU    ${expected_fault_id}    ${cu_index}
    END

Check Expected Alarms Is Appear In CU
    [Arguments]  ${expected_fault_id}    ${cu_index}=CU_0    ${timeout}=120
    Login To CU By Rest
    ${out}    cu.get_active_alarms    timeout=${timeout}
    ${status}=   set variable   False
    FOR    ${alarm}    IN    @{out['alarms']}
        ${fault_id}    Set Variable    ${alarm['fault_id']}
        ${status}=    set variable if    ${fault_id}==${expected_fault_id}    True
        exit for loop if    ${fault_id}==${expected_fault_id}
    END
    should be equal    ${status}    True    expected fault id in ${cu_index} is not appear!
    [Teardown]    run keyword and ignore error    Logout To CU By Rest

Check Alarms In CUs
    [Arguments]    ${cu_list}=${CU_LIST}
    FOR    ${cu_index}    IN    @{cu_list}
        CU Alarms Get And Check    allowed=${GLO_CU_ALLOWED_ALARM}    cu_index=${cu_index}
    END

CU Alarms Get And Check
    [Arguments]    ${allowed}=${EMPTY}    ${mandatory}=${EMPTY}    ${cu_index}=CU_0    ${timeout}=120
    Login To CU By Rest    cu_index=${cu_index}
    ${active_alarm_list}=    cu.get_active_alarms    page_number=${1}    items_per_page=${1000}    timeout=${timeout}
    Admin Alarms Check    available=${active_alarm_list["alarms"]}    allowed=${allowed}    mandatory=${mandatory}    allowed_key=fault_name
    [Teardown]    Run keyword and ignore error    Logout To CU By Rest

Check Historical Alarms In CUs
    [Arguments]    ${additional_allowed_alarms}=${EMPTY}    ${origin_history_alarms}=${CU_ORIGIN_HISTORICAL_ALARMS}
    ${additional_allowed_alarm_list}    split_string    ${additional_allowed_alarms}    :
    ${allowed_alarm_list}     combine_lists    ${GLO_CU_ALLOWED_ALARM}    ${additional_allowed_alarm_list}
    Remove Values From List    ${allowed_alarm_list}    ${empty}
    FOR    ${cu_index}    IN    @{CU_LIST}
        ${orgin_history_alarm}    Get From Dictionary    ${origin_history_alarms}    ${cu_index}
        ${target_history_alarm}    Get Historical Alarm In CU    ${cu_index}
        Remove Values From List    ${target_history_alarm}    @{orgin_history_alarm}
        Admin Alarms Check    available=${target_history_alarm}    allowed=${allowed_alarm_list}
        ...    allowed_key=fault_name
    END

Get Historical Alarm In CUs
    [Arguments]    ${cu_list}=${CU_LIST}
    ${cu_historical_alarms}    Create Dictionary
    FOR    ${cu_index}    IN    @{cu_list}
        ${historical_alarm_list}    Get Historical Alarm In CU    ${cu_index}
        Set To Dictionary    ${cu_historical_alarms}    ${cu_index}=${historical_alarm_list}
    END
    [Return]    ${cu_historical_alarms}

Get Historical Alarm In CU
    [Arguments]    ${cu_index}=CU_0    ${timeout}=120
    Login To CU By Rest    cu_index=${cu_index}
    ${historical_alarm_list}=   cu.get_historical_alarms   page_number=${1}   items_per_page=${1000}  timeout=${timeout}
    [Return]    ${historical_alarm_list["alarms"]}
    [Teardown]    Run keyword and ignore error    Logout To CU By Rest

Get CU vDU Index
    [Arguments]    ${resource_type}    ${resource_id}
    FOR    ${vdu}    IN    @{VDU_LIST}
        ${cu_index}    ${vdu_index}    Split String    ${vdu}    -
        ${resource}    Set Variable    ${CU_VDU_RESOURCE_MAPPING["${cu_index}"]["${vdu_index}"]["${resource_type}"]}
        ${status}    Run Keyword And Return Status    Resource Should Contain Id    ${resource}    ${resource_id}
        Return From Keyword If    ${status}    ${cu_index}    ${vdu_index}
    END
    Fail

Resource Should Contain Id
    [Arguments]    ${resource}    ${resource_id}
    ${type}    Evaluate    type($resource).__name__
    Run Keyword If    "${type}"=="list"
    ...    List Should Contain Value    ${resource}    ${resource_id}
    ...    ELSE    Should Be Equal    ${resource}    ${resource_id}

vCU Verify All Cells Onair
    [Arguments]    ${cu_index}=CU_0    ${timeout}=60
    Login To CU By Rest    cu_index=${cu_index}
    ${cells_summary}=    cu.get_cells_summary    timeout=${timeout}
    Run Keyword And Continue On Failure    Should Be Equal As Integers
    ...    ${cells_summary["basic_cells_summary"]["administrative_state"]["shutting_down"]}    0
    ...    Some cells are shutting down!
    Run Keyword And Continue On Failure    Should Be Equal As Integers
    ...    ${cells_summary["basic_cells_summary"]["administrative_state"]["locked"]}    0    Some cells are locked!
    Run Keyword And Continue On Failure    Should Be Equal As Integers
    ...    ${cells_summary["basic_cells_summary"]["operational_state"]["disabled"]}    0    Some cells are disabled!
    [Teardown]    Run Keyword And Ignore Error    Logout To CU By Rest

vCU Verify All Cells Onair For All CUs
    [Arguments]    ${cu_list}=${CU_LIST}
    FOR    ${cu_index}    IN    @{cu_list}
        vCU Verify All Cells Onair    cu_index=${cu_index}
    END

vCU Get vDU State
    [Arguments]    ${cu_index}=CU_0
    Login To CU By Rest    cu_index=${cu_index}
    ${du_state}    cu.get_du_state
    [Teardown]    Run Keyword And Ignore Error    Logout To CU By Rest
    [Return]    ${du_state}

vCU Check vDU State
    [Arguments]    ${expected_available_count}    ${cu_index}=CU_0
    ${du_state}    vCU Get vDU State    cu_index=${cu_index}
    Should Be True    "${du_state["f1_link_status"]["available"]}"=="${expected_available_count}"

vCU Get vDU And Check
    [Arguments]    ${du_id}    ${expected_state}=unlocked    ${cu_index}=CU_0
    Login To CU By Rest    cu_index=${cu_index}
    ${du_info}=    cu.get_du    du_id=${du_id}
    ${administrative_state}    Convert To Lowercase    ${du_info["administrative_state"]}
    Should Be True    "${administrative_state}"=="${expected_state}"
    [Teardown]    Run Keyword And Ignore Error    Logout To CU By Rest

vCU Get vDU ID List
    [Arguments]    ${cu_index}=CU_0
    Login To CU By Rest    cu_index=${cu_index}
    ${du_id_list}    Create List
    ${dus_info}    cu.get_dus_diff
    FOR    ${info}    IN    @{dus_info["created"]}
        Append To List    ${du_id_list}    ${info["id"]}
    END
    [Return]    ${du_id_list}
    [Teardown]    Run Keyword And Ignore Error    Logout To CU By Rest

vCU Get Lock vDU Opeartion State
    [Arguments]    ${operation_id}    ${expect_result}=success
    ${opt_info}    cu.get_opeartion_state_of_locking_du    operation_id=${operation_id}
    Should Be True    "${opt_info["status"]}"=="${expect_result}"

vCU Lock vDU
    [Arguments]    ${du_id_list}    ${cu_index}=CU_0
    Login To CU By Rest    cu_index=${cu_index}
    ${return_info}=    cu.lock_du    ${du_id_list}
    Wait Until Keyword Succeeds    60s    3s    vCU Get Lock vDU Opeartion State    ${return_info["id"]}
    [Teardown]    Run Keyword And Ignore Error    Logout To CU By Rest

vCU Unlock vDU
    [Arguments]    ${du_id_list}    ${cu_index}=CU_0
    Login To CU By Rest    cu_index=${cu_index}
    ${return_info}=    cu.unlock_du    ${du_id_list}
    Wait Until Keyword Succeeds    60s    3s    vCU Get Lock vDU Opeartion State    ${return_info["id"]}
    [Teardown]    Run Keyword And Ignore Error    Logout To CU By Rest

vCU Lock vDU And Check Result
    [Arguments]    ${du_id_list}    ${cu_index}=CU_0
    vCU Lock vDU    ${du_id_list}    cu_index=${cu_index}
    FOR   ${du_id}   IN   @{du_id_list}
        Wait Until Keyword Succeeds    120s    5s    vCU Get vDU And Check
        ...    ${du_id}    expected_state=locked    cu_index=${cu_index}
    END

vCU Unlock vDU And Check Result
    [Arguments]    ${du_id_list}    ${cu_index}=CU_0
    vCU Unlock vDU    ${du_id_list}    cu_index=${cu_index}
    FOR   ${du_id}   IN   @{du_id_list}
        Wait Until Keyword Succeeds    120s    5s    vCU Get vDU And Check
        ...    ${du_id}    expected_state=unlocked    cu_index=${cu_index}
    END

vCU Lock All vDU And Check Result For All CUs
    [Arguments]    ${cu_list}=${CU_LIST}
    FOR    ${cu_index}    IN    @{cu_list}
        ${du_id_list}=    vCU Get vDU ID List    cu_index=${cu_index}
        vCU Lock vDU And Check Result    ${du_id_list}    cu_index=${cu_index}
    END
    vDU Check All Cells Status    expected_operational_state=disabled    expected_availability_status=off line

vCU Unlock All vDU And Check Result For All CUs
    [Arguments]    ${cu_list}=${CU_LIST}
    FOR    ${cu_index}    IN    @{cu_list}
        ${du_id_list}=    vCU Get vDU ID List    cu_index=${cu_index}
        vCU Unlock vDU And Check Result    ${du_id_list}    cu_index=${cu_index}
    END
    vDU Check All Cells Status    expected_availability_status=on line

vCU Get Cells Statuses
    [Arguments]    ${cu_index}=CU_0    ${timeout}=120
    Login To CU By Rest    cu_index=${cu_index}
    ${cells_statuses}    cu.get_cells_statuses    timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    Logout To CU By Rest

vCU Reset CU
    [Arguments]    ${cu_index}=CU_0
    Login To CU By Rest    cu_index=${cu_index}
    ${out}    cu.reset_cu
    Should Be True    "${out["status"]}"=="ongoing"
    [Teardown]    Run Keyword And Ignore Error    Logout To CU By Rest

vCU Reset All CUs And Check Onair
    FOR    ${vdu_index}    IN    @{VDU_LIST}
        ${vdu_index}    ${cu_index}    Split String    ${vdu_index}    -
        ${cell_id_list}    Get Cell ID List    vdu_index=${vdu_index}    cu_index=${cu_index}
        vCU Reset CU    cu_index=${cu_index}
        Wait Until Keyword Succeeds    120s    5s
        ...    vDU Check Cells Status    cell_id_list=${cell_id_list}    expected_availability_status=off line
        ...    expected_operational_state=disabled   vdu_index=${vdu_index}    cu_index=${cu_index}
    END
    Wait Until Keyword Succeeds    ${ONAIR_TIME}    10s   vCU Verify All Cells Onair For All CUs

vCU Check Generate Delta Plan Operation State
    [Arguments]    ${action_id}
    ${res}    cu.get_action_state_of_generating_delta_plan    ${action_id}
    Should Be Equal As Strings    ${res['status']}    success

vCU Generate Delta Plan
    [Arguments]    ${cu_index}=CU_0
    Login To CU By Rest    cu_index=${cu_index}
    ${delta_plan_list}    cu.get_delta_plan_list
    Run Keyword If    ${delta_plan_list}    cu.delete_delta_plan    ${delta_plan_list[0]['plan_id']}
    ${delta_plan_name}    Get Unique ID    prefix=${cu_index}
    ${delta_res}=    cu.generate_delta_plan    plan_name=${delta_plan_name}
    ${delta_plan_id}=    set variable    ${delta_res['plan_id']}
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    3x    2s
    ...  vCU Check Generate Delta Plan Operation State    ${delta_res['action_id']}
    [Return]    ${delta_plan_id}
    [Teardown]    Run Keyword And Ignore Error    Logout To CU By Rest

vCU Get Specifical MO UUID via Dn Name
    [Arguments]    ${plan_id}    ${dist_name}    ${cu_index}=CU_0
    Login To CU By Rest    cu_index=${cu_index}
    &{delta_plan_tree}    cu.get_delta_plan_tree_diff    plan_id=${plan_id}
    @{plan_tree}=    Set Variable    ${delta_plan_tree["created"]}
    FOR    ${mo_info}    IN    @{plan_tree}
       Run Keyword If    '${dist_name[:5]}'=='MRBTS' and '${mo_info["name"]}'=='${dist_name}'
       ...   Run Keywords    Set Test Variable    ${parent_mouuid}    ${mo_info["mo_uuid"]}    AND    Exit For Loop
       Run Keyword If    '${mo_info["parent_mo_uuid"]}'=='${parent_mouuid}' and '${mo_info["name"]}'=='${dist_name}'
       ...   Run Keywords    Set Test Variable    ${parent_mouuid}    ${mo_info["mo_uuid"]}    AND    Exit For Loop
    END
    [Return]    ${parent_mouuid}
    [Teardown]    Run Keyword And Ignore Error    Logout To CU By Rest

vCU Get Specifical MO UUID
    [Arguments]    ${plan_id}    ${dist_name}    ${cu_index}=CU_0
    @{name_list}=    split_string    ${dist_name}    /
    Set Test Variable    ${parent_mouuid}    ${EMPTY}
    FOR    ${name}    IN    @{name_list}
        ${mouuid}    vCU Get Specifical MO UUID via Dn Name    ${plan_id}    ${name}    cu_index=${cu_index}
    END
    [Return]    ${mouuid}

vCU Check Update Parameters Operation State
    [Arguments]    ${plan_id}    ${action_id}
    ${res}=    cu.get_action_state_of_updating_parameters_of_delta_plan    plan_id=${plan_id}    action_id=${action_id}
    Should Be Equal As Strings    ${res['status']}    success

vCU Update Parameters Of Delta Plan
    [Arguments]    ${delta_plan_id}    ${uuid}    ${para_list}    ${cu_index}=CU_0
    Login To CU By Rest    cu_index=${cu_index}
    ${update_res}=    cu.update_parameters_of_delta_plan    plan_id=${delta_plan_id}    mo_uuid=${uuid}
    ...    parameter_change_list=${para_list}
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    5x    5s
    ...  vCU Check Update Parameters Operation State    plan_id=${delta_plan_id}   action_id=${update_res['action_id']}
    [Teardown]    Run Keyword And Ignore Error    Logout To CU By Rest

vCU Check Validate Delta Plan Operation State
    [Arguments]    ${plan_id}    ${action_id}
    ${res}=    cu.get_action_state_of_validating_delta_plan   ${plan_id}  ${action_id}
    should be equal as strings  ${res['status']}  success

vCU Check Activate Delta Plan Operation State
    [Arguments]    ${plan_id}    ${operation_id}
    ${res}=    cu.get_operation_state_of_activating_delta_plan    ${plan_id}    ${operation_id}
    should be equal as strings    ${res['status']}    success

vCU Validate Delta Plan
    [Arguments]    ${delta_plan_id}    ${cu_index}=CU_0
    Login To CU By Rest    cu_index=${cu_index}
    ${validate_res}=    cu.validate_delta_plan    plan_id=${delta_plan_id}
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds  5x  5s
    ...    vCU Check Validate Delta Plan Operation State
    ...    plan_id=${delta_plan_id}    action_id=${validate_res['action_id']}
    ${errors}    cu.get_latest_validation_result_of_delta_plan    plan_id=${delta_plan_id}
    ${error_num}    Set Variable    ${errors["total"]}
    Should Be True    ${error_num}<=0
    [Teardown]    Run Keyword And Ignore Error    Logout To CU By Rest

vCU Activate Delta Plan
    [Arguments]    ${delta_plan_id}    ${force_reset}=${True}    ${cu_index}=CU_0
    Login To CU By Rest    cu_index=${cu_index}
    ${active_res}=    cu.activate_delta_plan    plan_id=${delta_plan_id}    force_reset=${force_reset}
    Run Keyword And Continue On Failure    Wait until keyword succeeds    3x    30s
    ...    vCU Check Activate Delta Plan Operation State
    ...    plan_id=${delta_plan_id}    operation_id=${active_res['operation_id']}
    [Teardown]    Run Keyword And Ignore Error    Logout To CU By Rest

vCU Search And Check Parameters Of Current Plan
    [Arguments]    ${delta_para_dict}    ${dist_name}
    ${para_name}    Split String    ${delta_para_dict["parameter_path"]}    /
    ${paras_info}    cu.search_parameters_of_current_plan    parameter_name=${para_name[-1]}
    FOR    ${info}    IN    @{paras_info["items"]}
        ${para_dict}    Set Variable    ${info["parameter"]}
        Exit For Loop If    "${info["distname"]}"=="${dist_name}"
    END
    Should Be True    "${para_dict["simple_parameter"]["value"]}"=="${delta_para_dict["value"]}"

vCU Check Multi Parameters Value
    [Arguments]    ${delta_para_list}    ${dist_name}
    FOR    ${para_dict}    IN    @{delta_para_list}
        vCU Search And Check Parameters Of Current Plan    ${para_dict}    ${dist_name}
    END

vCU Check Update Parameter Value
    [Arguments]    ${multi_para_list}    ${cu_index}=CU_0
    [Documentation]    ${multi_para_list} = [{"MRBTS-37046/NRBTS-37046/NRCELL-1":
    ...    [{"operation_type":"replace", "parameter_path":"/e1NbSetupRetryForFault","value":"4"}]}]
    Login To CU By Rest    cu_index=${cu_index}
    FOR    ${para_dict}    IN    @{multi_para_list}
        ${dn_list}    Get Dictionary Keys    ${para_dict}
        ${dist_name}    Set Variable    ${dn_list[0]}
        vCU Check Multi Parameters Value    ${para_dict["${dist_name}"]}    ${dist_name}
    END
    [Teardown]    Run Keyword And Ignore Error    Logout To CU By Rest

#vCU Single Parameters Recommission
#    [Arguments]    ${para_list}    ${dist_name}    ${force_reset}=${True}    ${cu_index}=CU_0
#    [Documentation]    ${para_list} = [{"operation_type":"add", "parameter_path":"/lssConfig/lssPortNo",
#    ...    "value":"some_value"}]
#    ${para_list}    Evaluate    ${para_list}
#    ${delta_plan_id}=    vCU Generate Delta Plan    cu_index=${cu_index}
#    ${uuid}    vCU Get Specifical MO UUID    plan_id=${delta_plan_id}    dist_name=${dist_name}    cu_index=${cu_index}
#    vCU Update Parameters Of Delta Plan    ${delta_plan_id}    ${uuid}    ${para_list}    cu_index=${cu_index}
#    vCU Validate Delta Plan    ${delta_plan_id}    cu_index=${cu_index}
#    vCU Activate Delta Plan    ${delta_plan_id}    force_reset=${force_reset}    cu_index=${cu_index}
#    Wait until keyword succeeds    ${ONAIR_TIME}    10s    vCU Verify All Cells Onair For All CUs
#    FOR    ${para_dict}    IN    @{para_list}
#        vCU Search And Check Parameters Of Current Plan    ${para_dict}    ${dist_name}    cu_index=${cu_index}
#    END

vCU Multi Parameters Recommission
    [Arguments]    ${cu_delta_json}    ${timeout}=300    ${cu_index}=CU_0
#    [Documentation]    ${multi_para_list} = [{"MRBTS-37046/NRBTS-37046/NRCELL-1":
#    ...    [{"operation_type":"replace", "parameter_path":"/e1NbSetupRetryForFault","value":"4"}]}]
#    ${delta_plan_id}=    vCU Generate Delta Plan    cu_index=${cu_index}
#    FOR    ${para_list}    IN    @{multi_para_list}
#        ${dn_list}    Get Dictionary Keys    ${para_list}
#        ${dist_name}    Set Variable    ${dn_list[0]}
#        ${uuid}    vCU Get Specifical MO UUID    plan_id=${delta_plan_id}    dist_name=${dist_name}    cu_index=${cu_index}
#        vCU Update Parameters Of Delta Plan
#        ...    ${delta_plan_id}    ${uuid}    ${para_list["${dist_name}"]}    cu_index=${cu_index}
#    END
#    vCU Validate Delta Plan    ${delta_plan_id}    cu_index=${cu_index}
#    vCU Activate Delta Plan    ${delta_plan_id}    force_reset=${force_reset}    cu_index=${cu_index}
    Login To CU By Rest    cu_index=${cu_index}
    ${cu_para_status}    cu.perform_delta_recommissioning    ${cu_delta_json}
    ...    wait_for_completion=True    timeout=${timeout}
    Should Be True    "${cu_para_status["status"]}"=="success"
    Wait For All Cells Onair In All CUs
#    vCU Check Update Parameter Value    ${multi_para_list}    cu_index=${cu_index}
    Wait For All Cells Onair In All vDUs
    [Teardown]    Run Keyword And Ignore Error    Logout To CU By Rest

vDU Reset Rannic And Check Onair For All CUs
    [Arguments]    ${mrbts_id}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    ${rannic_list}    vdu.get_rnic_info_from_plan    ${mrbts_id}
    FOR    ${rannic}    IN    @{rannic_list}
        ${rannic_status}    vdu.reset_rannic    ${rannic["r_nic_mod_dist_name"]}
        Wait Until Keyword Succeeds    120    5s
        ...    vDU Get Rannic Reset Opeartion State   ${rannic_status["id"]}
        Wait Until Keyword Succeeds    ${ONAIR_TIME}    10s
        ...    vDU Verify All Cells OnAir    vdu_index=${vdu_index}    cu_index=${cu_index}
    END
    [Teardown]    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU Get Rannic Reset Opeartion State
    [Arguments]    ${operation_id}    ${expect_result}=success
    ${operation_status}    vdu.get_rnic_reset_operation    operation_id=${operation_id}
    Should Be True    "${operation_status["status"]}"=="${expect_result}"
    vdu.delete_rnic_rest_operation    operation_id=${operation_id}
