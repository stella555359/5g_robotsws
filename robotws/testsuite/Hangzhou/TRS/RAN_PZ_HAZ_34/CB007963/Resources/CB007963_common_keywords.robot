*** Settings ***
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    String
Library    taf.transport.ssh    WITH NAME    ssh
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Variables    testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/CB007963/Resources/CB007963_variables.py
Resource    testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/CB005740/Resources/CB005740_coam_keyword.robot
Resource    testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/CB005740/Resources/CB005740_common_keywords.robot

Documentation
...   author: Yu lu
...   contact: lu.1.yu@nokia-sbell.com
...   squad group: SG_02

*** Variables ***

${switch_user}            cli
${switch_auth_user}       admin\r
${switch_auth_passwd}     Admin@1830\r
${yes_cmd}                Y\r
${switch_alias}           switch
${echo_cmd}               echo\r

${port1_up_cmd}       config sync 1 ptp clock1 port2 adminState up\r
${port1_down_cmd}     config sync 1 ptp clock1 port2 adminState down\r

${port2_up_cmd}      config sync 1 ptp clock1 port4 adminState up\r
${port2_down_cmd}    config sync 1 ptp clock1 port4 adminState down\r

${apn1}    ${tl.core.pdns[0].apn}

*** Keywords ***
CB007963 Case Setup
    robot_common_operations.Common Case Setup    allowed_faults_ids=61631,16,4298
    COAM Create log directory for 561
    COAM Wait for gnb ready and cell setup and sync status
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    ${exist_fault}    COAM Get active alarms
    Set test variable    ${exist_fault}
    COAM Wait for gnb ready and cell setup    timeout=20 min
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${exist_fault}
    COAM Navigate to login page via webUI    download_dir=${vm_tmp_log_dir}
    ${backup_scf_file}    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    COAM selenium close browser
    Set Test Variable    ${backup_scf_file}
    Connect to Common Unit Master
    Connect to gnb coam via ssl
    ${ru_info}   COAM get ru detial info by ru index  ru_index=${1}
    ${ru_type}   set variable  ${ru_info}[productName]
    run keyword if     '${ru_type}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}

CB007963 Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=${faults_list}
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    SG2_Common_setup_teardown.COAM commission scf and wait cell setup    scf_file_path=${backup_scf_file}
    Run keyword and ignore error    COAM Teardown gnb connections
    Run keyword and ignore error    ssh.Disconnect    connection=ASIK Master
    CI_interface.Common Case Teardown

Check PDL verification
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    Coam Input Parameter value via webUI   param_data=${PARAM_7963_PDL_CHECK[0]}
    ...                                    node_index=${0}
    selenium_coam.validate_plan
    ${result}    Run Keyword And Return Status    COAM verify validation errors are empty from webui
    ${result}    Convert To String     ${result}
    Should Be Equal     ${result}    False
    selenium_coam.undo_changes
    COAM selenium logout

Configuration paramter
    [Arguments]   ${param_data}    ${index_num}   ${is_need_to_check_validation_errors}=${True}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    Coam Input Parameter value via webUI   param_data=${param_data}
    ...                                    node_index=${index_num}
    selenium_coam.validate_plan
    COAM check validation errors from webui    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    COAM selenium logout

Check all expect alarms recover
    Check expect alarm not exist      expect_alarm=${61631}
    Check expect alarm not exist      expect_alarm=${16}
    Check expect alarm not exist      expect_alarm=${4298}

Check expect alarm not exist
    [Arguments]    ${expect_alarm}    ${connection}=GNB_OAM
    ${active_alarms_list}    coam.get_active_alarms    connection=${connection}
    ${exist_alarms}    Create List
    FOR  ${alarm}  IN  @{active_alarms_list}
       Append To List    ${exist_alarms}   ${alarm['faultId']}
    END
    Should Not Contain        ${exist_alarms}     ${expect_alarm}

Check expect faultName for 7963
    [Arguments]    ${state}    ${connection}=GNB_OAM
    ${active_alarms_list}    coam.get_active_alarms    connection=${connection}
    ${exist_alarms_faultName}    Create List
    FOR  ${alarm}  IN  @{active_alarms_list}
       Append To List     ${exist_alarms_faultName}     ${alarm['faultName']}
    END
    Run Keyword If    ${state}==${3}
    ...          Should Contain        ${exist_alarms_faultName}     ToP master service RU eCPRI port #1 unusable
    ...          Should Contain        ${exist_alarms_faultName}     ToP master service RU eCPRI port #2 unusable
    Run Keyword If    ${state}==${1}
    ...          Should Contain        ${exist_alarms_faultName}     ToP master service RU eCPRI port #1 unusable
    Run Keyword If    ${state}==${2}
    ...          Should Contain        ${exist_alarms_faultName}     ToP master service RU eCPRI port #2 unusable

Check TOPP_R
    [Arguments]  ${PortNumber_used}
    Check Structure count    expect_count=${1}
    Check status and port used for 7963    PortNumber=${PortNumber_used}     is_or_not_used=used    ClockState=MASTER_CLOCK_OK    index_num=${0}

Check Structure count
    [Arguments]  ${expect_count}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${status_result}    Run Keyword And Return Status    _Get_parameter_values  dist_name=${GET_ELEMENTS_7963[0]}[dist_name]
    ...                                            filter_param=${GET_ELEMENTS_7963[0]}[filter_param]
    ...                                            abbr=${GET_ELEMENTS_7963[0]}[abbr]
    ...                                            node_index=${expect_count}
    ${status_result}    Convert To String     ${status_result}
    Should Be Equal     ${status_result}    False
    COAM selenium logout

Check status and port used for 7963
    [Arguments]   ${PortNumber}  ${is_or_not_used}   ${ClockState}   ${index_num}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${topMasterClockState}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_7963[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_7963[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_7963[0]}[abbr]
    ...                                            node_index=${index_num}
    Should Be Equal     ${topMasterClockState}      ${ClockState}
    ${topMasterUsed}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_7963[1]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_7963[1]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_7963[1]}[abbr]
    ...                                            node_index=${index_num}
    Should Be Equal     ${topMasterUsed}       ${is_or_not_used}
    ${topSlavePortNumber}   _Get_parameter_values  dist_name=${GET_PARAMETER_PORTNUMBER[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_PORTNUMBER[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_PORTNUMBER[0]}[abbr]
    ...                                            node_index=${index_num}
    ${topSlavePortNumber}       Convert To Integer      ${topSlavePortNumber}
    Should Be Equal     ${topSlavePortNumber}       ${PortNumber}
    COAM selenium logout

COAM Update TOPP parameters via rest api
    [Arguments]    ${parameters_to_add_via_api}    ${timeout}=${60}    ${connection}=GNB_OAM
    ${para_file}    coam_parameter.create_add_parameters_delta_with_exist_values
    ...    parameters=${parameters_to_add_via_api}
    ...    connection=${connection}
    ${update_via_api_status}    coam_parameter.perform_scf_delta_commission
    ...    delta_file=${para_file['updated']}
    ...    timeout=${timeout}
    ...    connection=${connection}
    Should contain    ${update_via_api_status}    PASS
    ...    msg=parameters do not update successfully.    ignore_case=${True}
    [Return]   ${update_via_api_status}

Configuration two topMasterList
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Connect to gnb coam via ssl    connection=gnb_modify
    ${topmaster_list}    Set Variable If
    ...     '${stream}'=='SBTS25R3'        ${CB007963_TOPMASTER_LIST_TRUNK}
    ...     ${CB007963_TOPMASTER_LIST}
    COAM Update TOPP parameters via rest api    parameters_to_add_via_api=${topmaster_list}    connection=gnb_modify
    COAM Teardown gnb connections    connection=gnb_modify

Check ClockState and MaterUsed for 7963
    [Arguments]  ${ok_num_expect}  ${index_begin}   ${index_end}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${ok_num}    Count param according to expect values     index_begin=${index_begin}
    ...                                                       index_end=${index_end}
    ...                                                       expect_values=MASTER_CLOCK_OK
    ...                                                       dist_name=${GET_PARAMETER_VALUES_7963[0]}[dist_name]
    ...                                                       filter_param=${GET_PARAMETER_VALUES_7963[0]}[filter_param]
    ...                                                       abbr=${GET_PARAMETER_VALUES_7963[0]}[abbr]
    Should Be Equal     ${ok_num}    ${ok_num_expect}
    ${used_num}    Count param according to expect values     index_begin=${index_begin}
    ...                                                       index_end=${index_end}
    ...                                                       expect_values=used
    ...                                                       dist_name=${GET_PARAMETER_VALUES_7963[1]}[dist_name]
    ...                                                       filter_param=${GET_PARAMETER_VALUES_7963[1]}[filter_param]
    ...                                                       abbr=${GET_PARAMETER_VALUES_7963[1]}[abbr]
    Should Be Equal     ${used_num}      ${1}
    COAM selenium logout

Start DLUL traffic and Caculate Tput when change localPriority
    [Arguments]     ${data_transfer_dl}     ${data_transfer_ul}     ${Expected_Throughput_DL}     ${Expected_Throughput_UL}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    power_ue.Prepare UE     ue_type=${ue_type}    ui_version=${tl.ues[${0}].capabilities[${1}]}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}    cap_index=${2}
    Run keyword and ignore error    power_ue.Verify attach     ue_type=${ue_type}     4G_check=False     5Grach_ed=${5Grach_ed}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${data_transfer_ul}     duration=3600    ue_mode=SA
    ...                        apn_address=${apn1}
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${data_transfer_dl}     duration=3600    ue_mode=SA
    ...                        apn_address=${apn1}    cap_index=${2}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=8m
    ${list_of_cell_ids}    Create list    160481
    run keyword and continue on failure    power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${Expected_Throughput_UL}
    run keyword and continue on failure    power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${Expected_Throughput_DL}
    Configuration paramter    param_data=${PARAM_7963_LOCALPRIORITY[0]}    index_num=${0}
    Sleep    10min
    ${tput_log_newlocalpriority}    power_ue.Collect Tput    ue_type=${ue_type}    duration=8m
    ${list_of_cell_ids_newlocalpriority}    Create list    160481
    run keyword and continue on failure    power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul     cells=${list_of_cell_ids_newlocalpriority}    log=${tput_log_newlocalpriority}
    ...                     target_throughput=${Expected_Throughput_UL}
    run keyword and continue on failure    power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl     cells=${list_of_cell_ids_newlocalpriority}    log=${tput_log_newlocalpriority}
    ...                     target_throughput=${Expected_Throughput_DL}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul

Start DLUL traffic and Caculate Tput when change TPS switch
    [Arguments]     ${data_transfer_dl}     ${data_transfer_ul}     ${Expected_Throughput_DL}     ${Expected_Throughput_UL}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    power_ue.Prepare UE     ue_type=${ue_type}    ui_version=${tl.ues[${0}].capabilities[${1}]}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}    cap_index=${2}
    Run keyword and ignore error    power_ue.Verify attach     ue_type=${ue_type}     4G_check=False     5Grach_ed=${5Grach_ed}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${data_transfer_ul}     duration=3600    ue_mode=SA
    ...                        apn_address=${apn1}
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${data_transfer_dl}     duration=3600    ue_mode=SA
    ...                        apn_address=${apn1}    cap_index=${2}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=8m
    ${list_of_cell_ids}    Create list    160481
    run keyword and continue on failure    power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${Expected_Throughput_UL}
    run keyword and continue on failure    power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${Expected_Throughput_DL}
    Disable or enable port by TPS switch and check port
    sleep    10min
    ${tput_log_newport}    power_ue.Collect Tput    ue_type=${ue_type}    duration=8m
    ${list_of_cell_ids_newport}    Create list    160481
    run keyword and continue on failure    power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul     cells=${list_of_cell_ids_newport}    log=${tput_log_newport}
    ...                     target_throughput=${Expected_Throughput_UL}
    run keyword and continue on failure    power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl     cells=${list_of_cell_ids_newport}    log=${tput_log_newport}
    ...                     target_throughput=${Expected_Throughput_DL}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul

Disable or enable port by TPS switch and check port
    Disable or enable port1 by TPS switch and check port
    Disable or enable port2 by TPS switch and check port

Disable or enable port1 by TPS switch and check port
    Disable or enable port    cmd=${port1_down_cmd}   switch_ip=${tl.optical_switches[0].addr}
    Run Keyword And Continue On Failure    Check status and port used for 7963    PortNumber=${1}
    ...                                                                           is_or_not_used=not used
    ...                                                                           ClockState=MASTER_CLOCK_DISABLED
    ...                                                                           index_num=${0}
    Run Keyword And Continue On Failure    Check status and port used for 7963    PortNumber=${2}
    ...                                                                           is_or_not_used=used
    ...                                                                           ClockState=MASTER_CLOCK_OK
    ...                                                                           index_num=${1}
    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Check expect alarm exist     expect_alarm=${61631}
    Run Keyword And Continue On Failure    Check expect faultName for 7963    state=${1}
    Disable or enable port    cmd=${port1_up_cmd}   switch_ip=${tl.optical_switches[0].addr}

Disable or enable port2 by TPS switch and check port
    Disable or enable port    cmd=${port2_down_cmd}   switch_ip=${tl.optical_switches[1].addr}
    Run Keyword And Continue On Failure    Check status and port used for 7963    PortNumber=${1}
    ...                                                                           is_or_not_used=used
    ...                                                                           ClockState=MASTER_CLOCK_OK
    ...                                                                           index_num=${0}
    Run Keyword And Continue On Failure    Check status and port used for 7963    PortNumber=${2}
    ...                                                                           is_or_not_used=not used
    ...                                                                           ClockState=MASTER_CLOCK_DISABLED
    ...                                                                           index_num=${1}
    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Check expect alarm exist     expect_alarm=${61631}
    Run Keyword And Continue On Failure    Check expect faultName for 7963    state=${2}
    Disable or enable port    cmd=${port2_up_cmd}   switch_ip=${tl.optical_switches[1].addr}

Disable or enable port
    [Arguments]  ${cmd}   ${switch_ip}
    ${switch_con}   ${channel}   Connect To Switch     switch_ip=${switch_ip}
    Send Command and Recv Results   channel=${channel}    command=${cmd}
    Disconnect Switch    channel=${channel}     switch_con=${switch_con}

Check alarms when change TPS switch
    Connect to gnb coam via ssl
    Disable or enable port    cmd=${port1_down_cmd}   switch_ip=${tl.optical_switches[0].addr}
    Sleep    3s
    Check expect alarm exist     expect_alarm=${61631}
    Check expect faultName for 7963    state=${1}
    Disable or enable port    cmd=${port2_down_cmd}   switch_ip=${tl.optical_switches[1].addr}
    Sleep    3s
    Check expect alarm exist     expect_alarm=${61631}
    Check expect faultName for 7963    state=${3}
    Sleep    30s
    Check expect alarm exist     expect_alarm=${16}
    Check expect alarm exist     expect_alarm=${4298}
    Check expect alarm not exist      expect_alarm=${61631}

Recover by enable port and check alarms
    Connect to gnb coam via ssl
    Disable or enable port    cmd=${port1_up_cmd}   switch_ip=${tl.optical_switches[0].addr}
    Disable or enable port    cmd=${port2_up_cmd}   switch_ip=${tl.optical_switches[1].addr}
    Sleep    40s
    Check all expect alarms recover

Send Command and Recv Results
    [Arguments]  ${channel}    ${command}
	${results}    Call Method    ${channel}    send     ${command}
	Sleep    3 sec
	Log To Console    ${results}
	Call Method    ${channel}    recv     ${65535}
    [Return]  ${results}

Connect To Switch
    [Arguments]  ${switch_ip}
    ${switch_con}    ssh.Connect To     hostname=${switch_ip}     username=${switch_user}     alias=${switch_alias}
	${channel}        Call Method     ${switch_con}     invoke_shell
    Call Method    ${channel}    recv     ${65535}
	Call Method    ${channel}    send     ${switch_auth_user}
	Sleep    3 sec
	Call Method    ${channel}    recv     ${65535}
	Call Method    ${channel}    send     ${switch_auth_passwd}
	Sleep    3 sec
	Call Method    ${channel}    recv     ${65535}
	Call Method    ${channel}    send     ${yes_cmd}
	Sleep    3 sec
	Call Method    ${channel}    recv     ${65535}
	[Return]   ${switch_con}      ${channel}

Disconnect Switch
    [Arguments]   ${channel}     ${switch_con}
	Call Method    ${channel}    close
	ssh.Disconnect    connection=${switch_con}
