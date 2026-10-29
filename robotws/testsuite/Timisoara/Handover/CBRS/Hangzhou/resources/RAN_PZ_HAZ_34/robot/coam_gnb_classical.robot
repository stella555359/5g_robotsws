*** Settings ***
Documentation    This is for COAM classical GNB, it's focus on rest api
...              Please do not modify the file without notification to author
...              Author: Ding Binmei
...              Squard: HZ SG4
Library    String
Library    OperatingSystem
Library    DateTime
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.gnb.oam.commissioning    WITH NAME    commissioning
Library    taf.config.scf    WITH NAME    scf
Library    taf.transport.ssh    WITH NAME    csn
Library    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/python/coam_parameter.py
Library    taf.rfrl.common_resources.python.SWConfig   WITH NAME    swconf
Library    ../python/coam_gnb_classical.py
Library    ../python/bts/vran40/cloud_gnb.py
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    ./coam_siso_common.robot


*** Variables ***
${TS_LOG_PATH_BASE}      ${OUTPUT DIR}/Case_Logs
@{GNB_PS_CELL_INDEX_LIST}    1

*** Keywords ***
Connect to gnb coam via ssl
    [Arguments]  ${connection}=GNB_OAM    ${gnb_index}=0
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    ${ignore_get_release_error}=${True}
    Log    message=\nArgument ignore_get_release_error=${ignore_get_release_error} is not used and will be removed in the future.
    # No more pass release after TAF-2785 Support Auto release detect in admin library.
    # Skip the 'connect_to' operation if the connection can be used normally.
    ${existing_connection}    Run Keyword And Return Status    coam.get_sw_release_name    connection=${connection}
    Run Keyword If	${existing_connection}    Log to console    Connection ${connection} already exists, skip the connection setup
    ...    ELSE    Run Keywords    Log to console    Connection ${connection} does not exist
    ...    AND    coam.connect_to    bts_host=${bts_host}    bts_port=${443}
    ...    username=${username}    password=${password}   name=${connection}

Cloud DU connect to gnb coam via ssl
    [Documentation]    Author: Wang Yixiang
    [Arguments]  ${connection}=GNB_OAM    ${gnb_index}=0    ${du_index}=0
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${username}=Nemuadmin
    ...    ${password}=nemuuser
    ...    ${ignore_get_release_error}=${True}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ...    bts_host=${bts_host}    username=${username}    password=${password}
    ...    ignore_get_release_error=${ignore_get_release_error}

COAM Teardown gnb connections
    [Arguments]    ${connection}=GNB_OAM
    coam.teardown    connection=${connection}

Generate suite log path
    [Documentation]    Author: Ding Binmei [PRIVATE]
    ...                Description: Create log directory with test suite level and open a common variable ${SUITE_LOG_PATH}
    [Arguments]    ${timeout}=1min    ${response_timeout}=10
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    Run keyword if    ${has_cbts}   wait until keyword succeeds    ${timeout}    2sec    Cloud DU connect to gnb coam via ssl
    ...    ELSE    wait until keyword succeeds    ${timeout}    2sec    Connect to gnb coam via ssl
    ${sw_version} =     coam.get_sw_version    connection=GNB_OAM    timeout=${response_timeout}
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Create directory    ${SUITE_LOG_PATH}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Generate test case log path
    [Documentation]    Author: Ding Binmei  [PRIVATE]
    ...                Description: Create log directory with test case level and open a common variable ${TS_CASE_LOG_PATH}
    ...                This keyword should be executed after Generate suite log path
    ${tc_name}=    Replace String    string=${TEST NAME}    search_for=${SPACE}    replace_with=_
    ${case_log_path}    Join path    ${SUITE_LOG_PATH}    TC_${tc_name}
    Set test variable    ${TS_CASE_LOG_PATH}    ${case_log_path}
    Create directory    ${TS_CASE_LOG_PATH}

COAM Create log directory
    [Documentation]    Author: Ding Binmei
    ...                Description: Open a common variable  ${SUITE_LOG_PATH}/ ${TS_CASE_LOG_PATH} and also create test case log path
    ...                This keyword can be executed both on suite setup and test setup; Default to use this keyword in test case setup
    ...                ${is_set_to_test_case_level}: Value can be ${True} or ${False};
    ...                  If set to ${True}, test case log path will set to test case name level;
    ...                  Otherwise, case log will set to test suite level
    ...                 ${LOG_PATH} is required in common keyword coam_parameter.py
    [Arguments]  ${is_set_to_test_case_level}=${True}    ${timeout}=1min    ${response_timeout}=10
    Generate suite log path    timeout=${timeout}    response_timeout=${response_timeout}
    Run keyword if  ${is_set_to_test_case_level}
    ...    Run keywords    Generate test case log path    AND
    ...    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
    ...    ELSE    Set suite variable    ${LOG_PATH}    ${SUITE_LOG_PATH}


COAM Check GNB ABIL status
    [Documentation]  Author: Ding Binmei
    ...              Description: Support to check multiple ABILs
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=900
    Log to console    Check GNB ABIL status
    ${sw_version}     coam.get_sw_version    connection=${connection}    timeout=${timeout}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}    timeout=${timeout}
    @{list_abils}    Set variable    ${hw_info['basebandModules']}
    ${count_abils}    Get length    ${list_abils}
    Should be true    ${count_abils}>=${1}    msg=Check ABIL status failed as total ABIL number is less than 1
    FOR  ${abil}  IN  @{list_abils}
        Run keyword and continue on failure    Should be equal as strings    ${abil['status']['administrativeState']}    ${unlocked}
                                      ...  msg=Current ABIL administrativeState is not in Unlocked status
        Run keyword and continue on failure    Should be equal as strings    ${abil['status']['operationalState']}    ${enabled}
                                      ...  msg=Current ABIL operationalState is not in Enabled status
        Run keyword and continue on failure    Should be equal as strings    ${abil['status']['proceduralStatus']}    configured
                                      ...  msg=Current ABIL proceduralStatus is not in configured status
        run keyword if  ${result}    Run keyword and continue on failure    Should be equal as strings
                                      ...  ${abil['status']['availabilityStatus']}    Online
                                      ...  msg=Current ABIL availabilityStatus is not in Online status
    END

COAM Check GNB ASIK status
    [Documentation]  Author: Ding Binmei
    ...              Description: Support to check multiple ASIKs
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=900
    Log to console    Check GNB ASIK status
    ${sw_version}     coam.get_sw_version    connection=${connection}    timeout=${timeout}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}    timeout=${timeout}
    @{list_asiks}    Set variable    ${hw_info['systemModules']}
    ${count_asiks}    Get length    ${list_asiks}
    Should be true    ${count_asiks}>=${1}    msg=Check ASIK status failed as total ASIK number is less than 1
    FOR  ${asik}  IN  @{list_asiks}
        Run keyword and continue on failure    Should be equal as strings    ${asik['status']['administrativeState']}    ${unlocked}
                                      ...  msg=Current ASIK administrativeState is not in Unlocked status
        Run keyword and continue on failure    Should be equal as strings    ${asik['status']['operationalState']}    ${enabled}
                                      ...  msg=Current ASIK operationalState is not in Enabled status
        Run keyword and continue on failure    Should be equal as strings    ${asik['status']['proceduralStatus']}    configured
                                      ...  msg=Current ASIK proceduralStatus is not in configured status
        run keyword if  ${result}    Run keyword and continue on failure    Should be equal as strings
                                      ...  ${asik['status']['availabilityStatus']}    Online
                                      ...  msg=Current ASIK availabilityStatus is not in Online status
    END

COAM Check GNB RU status
    [Documentation]  Author: Ding Binmei
    ...              Description: Support to check with multiple rmod
    ...    :ru_sn default check all ru detected, also support add RU sn number to just check this ru status.
    [Arguments]    ${connection}=GNB_OAM    ${ru_sn}=all    ${timeout}=900
    Log to console    Check RU status from GNB
    ${sw_version}     coam.get_sw_version    connection=${connection}    timeout=${timeout}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}    timeout=${timeout}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    ${ru_item}    Set variable    ${0}
    Should be true    ${count_RUs}>=${1}    msg=Check RU status failed as total RU number is less than 1
    FOR  ${ru}  IN  @{list_RUs}
        Run keyword if    '${ru_sn}'!='all' and '${ru_sn}'!='${ru['serialNumber']}'    continue for loop
        ${ru_item}=    evaluate    ${ru_item}+1
        Run keyword and continue on failure
        ...    Should be equal as strings    ${ru['status']['administrativeState']}    ${unlocked}
        ...    msg=Current RU administrativeState is not in Unlocked status
        Run keyword and continue on failure
        ...    Should be equal as strings    ${ru['status']['operationalState']}    ${enabled}
        ...  msg=Current RU operationalState is not in Enabled status
        Run keyword and continue on failure
        ...    Should be equal as strings    ${ru['status']['proceduralStatus']}    configured
        ...  msg=Current RU proceduralStatus is not in configured status
        run keyword if  ${result}    Run keyword and continue on failure
        ...    Should be equal as strings    ${ru['status']['availabilityStatus']}    Online
        ...  msg=Current RU availabilityStatus is not in Online status
    END
    should be true    ${ru_item}>${0}    msg=Check RU status failed as no RU found !!!

COAM Check X2 link status from GNB
    [Documentation]  Author: Ding Binmei
    ...              Description: Check X2 link status from GNB side. Currently only support for 1 ENB scenario
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=600
    Log to console    Check X2 link status from GNB
    @{MOs_lteenb_a}    coam.get_managed_objects    class_name=LTEENB_A    connection=${connection}    timeout=${timeout}
    @{MOs_lteenb_r}    coam.get_managed_objects    class_name=LTEENB_R    connection=${connection}    timeout=${timeout}
    &{dict_x2LinkLock}     coam.get_parameters    dist_name=${MOs_lteenb_a[0]['distName']}  pattern=x2LinkLock    connection=${connection}
    &{dict_x2LinkStatus}    coam.get_parameters    dist_name=${MOs_lteenb_r[0]['distName']}  pattern=x2LinkStatus    connection=${connection}
    should be equal as strings    ${dict_x2LinkLock['x2LinkLock']}    unlocked    msg=x2LinkLock is not in unlocked status    ignore_case=${True}
    should be equal as strings    ${dict_x2LinkStatus['x2LinkStatus']}    available    msg=x2LinkStatus is not in available status
    ...                            ignore_case=${True}

COAM Check GNB cell on air
    [Documentation]  Author: Ding Binmei
    ...              Description: Check if GNB is in cell on air status
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=900
    ${bts_status}    coam.get_bts_statuses    connection=${connection}    timeout=${timeout}
    ${gnb_cell_status}    Set variable  ${bts_status['proceduralState']}
    Should be equal as strings    ${gnb_cell_status}    OnAir    msg=GNB is not on air, Current status is ${gnb_cell_status}
    ...                      ignore_case=${True}

COAM Wait for gnb ready and cell setup
    [Documentation]  Author: Ding Binmei
    ...              Description: Wait until GNB status ready.
    ...              2020-12-9: 1. Extend this keyword to support for muli-DUs checking. if du_index is not 0, then the connection alias will
    ...              be displaed as: ${connection}_du${du_index}, if du_index is 0, connection will be ${connection},
    ...              please do remember to release your ssl connections by yourselves in case teardown
    ...              2. Support checking for ASOD
    ...              3. Support checking for ASOE. lanwen.cai    5G_PZ_HZ_8_SG
    ...              2021/03/03 Wang Yixiang: ${gnb_type} is deprecated, will get gnb_type online
    ...              2021/06/23 Cui Lingxue: Add ${is_need_to_setup_gnb_connection} and ${connection}. If ${is_need_to_setup_gnb_connection} is true,
    ...              new ssl connection to gnb will be setup; if false, connection alias will use given ${connection}.
    ...              2021/09/27 Ding Binmei: Add ${is_x2_check_from_gnb_needed} to control if x2 checking is needed from GNB
    [Timeout]  30 min
    [Arguments]  ${timeout}=10 min    ${connection}=GNB_OAM    ${gnb_type}='NSA'    ${retry_interval}=5 sec    ${du_index}=0
    ...    ${is_need_to_setup_gnb_connection}=${True}    ${is_x2_check_from_gnb_needed}=${True}    ${gnb_index}=0
    BuiltIn.Log    Start checking bts reset result.
    ${reset_check_result}    set variable    ${False}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${connection}    Set variable if  '${du_index}'=='0'    ${connection}    ${connection}_du${du_index}
    Run keyword if    ${has_cbts} and ${is_need_to_setup_gnb_connection}
    ...    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Cloud DU connect to gnb coam via ssl
    ...        connection=${connection}    du_index=${du_index}    ignore_get_release_error=${False}
    ...    ELSE IF    '${has_cbts}'=='${False}' and ${is_need_to_setup_gnb_connection}
    ...    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    ...         connection=${connection}    ignore_get_release_error=${False}
    ${is_asod_asoe_asof}    If ASOD or ASOE or ASOF or ASOG or ASOH testline    gnb_index=${gnb_index}    du_index=${du_index}
    ...    timeout=${timeout}    retry_interval=${retry_interval}
    Run keyword if    ${is_asod_asoe_asof}==${False}
    ...    Wait until keyword succeeds    ${timeout}    ${retry_interval}    COAM Check GNB ABIL status    connection=${connection}
    ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    COAM Check GNB ASIK status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    COAM Check GNB RU status    connection=${connection}
    ${gnb_type}    Get gNbType SA or NSA via rest api    connection=${connection}
    ${is_x2_check_from_gnb_needed} 	Set Variable If	  '${gnb_type}'=='SA' 	${False}    ${is_x2_check_from_gnb_needed}
    Run keyword if  ${is_x2_check_from_gnb_needed}==${True}    Run keyword if    ${has_cbts}==${False}
    ...    Wait until keyword succeeds    ${timeout}    ${retry_interval}    COAM Check X2 link status from GNB
    ...    connection=${connection}
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    COAM Check GNB cell on air    connection=${connection}
    BuiltIn.Log    BTS reset check finished, reset successfully.
    ${reset_check_result}    set variable    ${True}
    [Return]  ${connection}
    [Teardown]    Run Keyword And Ignore Error
    ...           run keyword if    '${reset_check_result}'=='${False}'
    ...           Coam get alarm and Write to alarm log file    connection=${connection}

COAM Download scf from cluster
    [Documentation]  Author: Ding Binmei
    ...              Description: Download the scf file from cluster and will return with the scf file path in local
    ...              ${scf_dir_path}: Refer to the scf folder for storing the downloaded scf file
    [Arguments]  ${scf_dir_path}=${SUITE_LOG_PATH}    ${connection}=GNB_OAM    ${timeout}=60
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${scf_default_name}    catenate  SEPARATOR=${EMPTY}    scf_backup_from_cluster    ${time_stamp}    .xml
    ${scf_file_path}    coam.get_current_scf_file    local_dir_path=${scf_dir_path}
    ...    file_name=${scf_default_name}    connection=${connection}    timeout=${timeout}
    [Return]  ${scf_file_path}

COAM Modify scf file
    [Documentation]  Author: Ding Binmei
    ...              Description: This keyword can only support for Modify SCF
    ...              ${scf_file_path}: refer to the scf file path in test pc
    ...              ${scf_parameters_list}: scf parameter list for modification,${PARAMS_TO_MODIFY_SCF} is defined in TL init file template
    ...                  Example input for the list definition can be as bellow:
    ...                    PARAMS_TO_MODIFY_SCF = [
    ...                       dict(value='TL044_ta', dist_name='MRBTS-1900', p_name='btsName'),
    ...                       dict(value='10.1.1.1', dist_name='MRBTS-1900/NRBTS-1/SERVEDAMF-1', p_name='amfIPAddress')]
    [Arguments]      ${scf_file_path}    ${scf_parameters_list}=${PARAMS_TO_MODIFY_SCF}
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${scf_dir_path}    String.Replace string    ${scf_file_path}    /${scf_file_name}    ${EMPTY}
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${scf_file_name_after_modify}    catenate  SEPARATOR=${EMPTY}    ${file_name_without_extention}    _${timestamp}_updated.xml
    ${modified_scf_file_path}    set variable    ${scf_dir_path}/${scf_file_name_after_modify}
    commissioning.Modify Scf    input_scf=${scf_file_path}
    ...                         output_scf=${modified_scf_file_path}
    ...                         parameters_lists=${scf_parameters_list}
    [Return]  ${modified_scf_file_path}

COAM Commission with scf file
    [Documentation]  Author: Ding Binmei
    ...              Description: Do commission and verify commission status
    ...                           2019-11-12, add argument ${is_pdl_checking_needed} to open interface to tester if pdl checking is needed,
    ...                                       Valid values are: ${True} or ${False}, if ${True}, then pdl validation is needed,
    ...                                       otherwise will ignore this validation. Now it's default to ${True}
    [Arguments]  ${scf_file_path}    ${connection}=GNB_OAM    ${timeout}=300    ${is_pdl_checking_needed}=${True}
                 ...      ${skip_parameter_relation_errors}=${True}    ${alias}=ASIK Master
    run keyword and ignore error    csn.disconnect    connection=${alias}
    &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${skip_parameter_relation_errors}    connection=${connection}
    Should be equal as strings    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}    Success
    ...    msg=Commissioned with error exists, activation result is not in success status.    ignore_case=${True}
    Should be equal as strings    ${result['validationResult']['niddValidationResult']['status']}    OK
    ...    msg=Commissioned with error exists, nidd validation result is not in OK status    ignore_case=${True}
    run keyword and continue on failure    Run keyword if    ${is_pdl_checking_needed}==${True}
    ...    Should be equal as strings    ${result['validationResult']['pdlValidationResult']['status']}    OK
    ...        msg=Commissioned with error exists, pdl validation result is not in OK status.    ignore_case=${True}
    BuiltIn.Log    Commission with scf file via rest API successfully.
    [Return]  ${result}

COAM Get active alarms
    [Arguments]  ${connection}=GNB_OAM    ${timeout}=900
    @{output_alarms}    coam.get_active_alarms    connection=${connection}    timeout=${timeout}
    [Return]  ${output_alarms}

COAM Verify if alarm exists
    [Documentation]    Author: Ding Binmei HGZ_SG4
    ...                Description: Collect active alarms and write the alarms to file
    [Arguments]    ${log_path_alarm}=${TS_CASE_LOG_PATH}    ${connection}=GNB_OAM
    @{output_alarms}    coam_gnb_classical.COAM Get active alarms    connection=${connection}
    ${alarm_num}    Get length    ${output_alarms}
    Run keyword and continue on failure    Should be true    ${alarm_num} == ${0}
    ...    msg=${alarm_num} alarm exist, please check manually
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Run    command=echo "Active alarm number:${alarm_num}">${log_path_alarm}/active_alarm_${timestamp}.txt
    FOR  ${alarm}  IN  @{output_alarms}
        run    command=echo "${alarm}">>${log_path_alarm}/active_alarm_${timestamp}.txt
    END

COAM Update mcs via rest api
    [Documentation]    Author: Ding Binmei HGZ_SG4
    ...                Description: Update MCS value for UL or DL from webui
    ...                ${direct}: value can be ul or dl, case is not sensitive
    ...                ${cell}: value can be NRCELL-1, NRCELL-2..., defult to use NRCELL-1
    [Arguments]    ${direct}    ${mcs_value}    ${cell}=NRCELL-1    ${connection}=GNB_OAM
    ${mcs_value}    Convert to string    ${mcs_value}
    ${direct}    Convert to uppercase    ${direct}
    ${abbr_name}    set variable if    "${direct}"=="UL"    ullaIniMcs    dllaIniMcs
    ${nr_bts_id}    Set variable    ${tl.gnbs[0].global_bts_id}
    ${update_status}=     coam_parameter.perform_scf_parameter_recommission       value=${mcs_value}
    ...       parameter=${abbr_name}    dist_name=NRBTS-${nr_bts_id}/${cell}
    ...    timeout=${60}     connection=${connection}    operation=update
    Should be equal as strings    ${update_status}    PASS
    ...         msg=MCS value is not updated successfully with new value ${mcs_value} for ${abbr_name} of ${cell}

COAM Save snapshot via rest api
    [Documentation]  Author: Ding Binmei
    ...              Description: Save snapshot via rest api, logs will be saved under the log_path folder
    [Arguments]  ${connection}=GNB_OAM    ${log_path}=${TS_CASE_LOG_PATH}     ${timeout}=${360}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_file_path}    Set variable    ${log_path}/snapshot_rest_api_${timestamp}.zip
    coam.get_snapshot    target_file_name=${snapshot_file_path}    connection=${connection}    timeout=${timeout}
    [Return]  ${snapshot_file_path}

COAM Update several parameters via rest api
    [Documentation]  Author: Ren Biyao
    ...              Description: this keyword is to add or update several parameters via rest api.
    ...    ${parameters_to_update_via_api} should be given in special format, as the following:
    ...    ${parameters_to_update_via_api}=[{'dist_name': 'NRBTS-1/NRCELL-1', 'parameter': 'actDynUlDataSplitMode',
    ...    'value': 'true'}, {'dist_name': 'NRBTS-1/NRCELL-1', 'parameter': 'pucchDataDtxNumOfSamples', 'value': '100'}]
    ...    ${update_via_api_status} will be returned, if the parameter requires the reset of bts in order to take effect,
    ...    additional check will be required.
    ...     Note: if use this keyword to modify p_name involving in list_name, then all other p_name which exist in this list_name
    ...          should be given thoroughly as well.
    [Arguments]    ${parameters_to_update_via_api}    ${timeout}=${60}    ${connection}=GNB_OAM    ${should_activate}=${True}
    ...    ${skip_parameter_relation_errors}=True
    ${para_file}    coam_parameter.create_update_parameters_delta
    ...    parameters=${parameters_to_update_via_api}
    ...    connection=${connection}
    ...    timeout=${timeout}
    ${update_via_api_status}    coam_parameter.perform_scf_delta_commission
    ...    delta_file=${para_file['updated']}
    ...    timeout=${timeout}
    ...    connection=${connection}
    ...    should_activate=${should_activate}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ${msg_for_parameter_activation_not_executed}    Catenate    Parameter update activation for ${parameters_to_update_via_api} is not executed,
    ...    due to flag should_activate is set to ${should_activate}
    Run keyword if    '${should_activate}'=='${True}'
    ...    Should contain    ${update_via_api_status}    PASS    msg=parameters do not update successfully.    ignore_case=${True}
    ...    ELSE    Log to console     ${msg_for_parameter_activation_not_executed}
    [Return]   ${update_via_api_status}

Get scf template file with release considered
    [Documentation]  Author: Ding Binmei
    ...    In order to support 1 test line run with multiple release. Will try to select SCF file with release marked firstly.
    ...    If release template file not found. Then will use the original template without release marked for SCF commission
    ...    E.G. original scf_template_file_path is /home/ute/scf/SCF_MMW1_TL10152.xml, current release is 23R2,
    ...    then will try to see if file /home/ute/scf/SCF_MMW1_TL10152_23R2.xml exist.
    ...    if yes, return with file path /home/ute/scf/SCF_MMW1_TL10152_23R2.xml
    ...    if no, return with original scf_template_file_path /home/ute/scf/SCF_MMW1_TL10152.xml
    ...    If you want to control SCF in this way, you'll need to save your scf file with different release marked
    [Arguments]  ${scf_template_file_path}    ${program}=${None}
    ${cur_program}    Run keyword if    '${program}'=='${None}'    gnb_classical_hangzhou.Get program version based on stream version
    ...    ELSE    Set variable    ${program}
    ${file_folder}    ${file_name}    Split path    path=${scf_template_file_path}
    ${file_name_without_file_type}    Fetch from left    string=${file_name}    marker=.xml
    ${file_name_with_program}    Set variable    ${file_name_without_file_type}_${cur_program}.xml
    ${scf_template_file_path_with_release}    Join path    ${file_folder}    ${file_name_with_program}
    ${is_release_template_file_exist}    Run keyword and return status    File should exist    path=${scf_template_file_path_with_release}
    ${scf_template_file_path}    Set variable if    ${is_release_template_file_exist}    ${scf_template_file_path_with_release}
    ...    ${scf_template_file_path}
    Log to console    scf_template_file_path:${scf_template_file_path}
    [Return]    ${scf_template_file_path}

Preparation with swconfig modification and comissioning
    [Documentation]  Author: Ding Binmei
    ...              Description: Do modification for swconfig file and scf file.
    ...              ${swconfig_modify}: Can be a list for the modified R&D parameters, example input with python format:
    ...                                 ['0x580002=0', '0x580121=0']
    ...              ${scf_modify}: Default to modify the IP info defined in TL config file in variable ${PARAMS_TO_MODIFY_SCF}
    ...              ${is_called_in_test_case_level}: available values: ${True} ${False},
    ...                                               default to ${False} which means keyword is called in test suite setup phase
    ...              ${SWCONFIG_DEFAULT_FILE_PATH}: refers to the template swconfig file path in test pc,
    ...                                             should be defined before calling this keyword
    ...              ${SCF_DEFAULT_FILE_PATH}: refers to the template scf file path in test pc
    ...                                        should be defined before calling this keyword
    ...              ${is_pdl_checking_needed}: Valid values are ${True} or ${False}, if ${True} then PDL validation is needed,
    ...                              otherwise will not do PDL validation. Now it's default to ${True}
    [Arguments]    ${swconfig_modify}=${None}    ${scf_modify}=${PARAMS_TO_MODIFY_SCF}    ${is_called_in_test_case_level}=${False}
    ...    ${commission_timeout}=600    ${swconfig_template_path}=${SWCONFIG_DEFAULT_FILE_PATH}    ${scf_template_path}=${SCF_DEFAULT_FILE_PATH}
    ...    ${is_pdl_checking_needed}=${True}
    ...    ${gnb_index}=${0}    ${du_index}=${0}    ${connection}=GNB_OAM    ${alias}=ASIK Master
    COAM Create log directory    is_set_to_test_case_level=${is_called_in_test_case_level}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run keyword if    ${has_cbts}   Cloud DU connect to gnb coam via ssl   gnb_index=${gnb_index}    du_index=${du_index}    connection=${connection}
    ...    ELSE    Connect to gnb coam via ssl   gnb_index=${gnb_index}    connection=${connection}
    Connect to Common Unit Master    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}
    ${local_log_file_folder}    set variable if  ${is_called_in_test_case_level}==${True}    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}
    ${default_swconfig_file_path}    Copy file    source=${swconfig_template_path}    destination=${local_log_file_folder}/swconfig.txt
    Run keyword if    ${swconfig_modify}!=${None}
    ...    Run keywords    Log to console    Swconfig file modification is needed.    AND
    ...    swconf.Modify swConfig file    parametersList=${swconfig_modify}    filePath=${default_swconfig_file_path}
    swconf.Upload swConfig file to asik and crasign    localFilePath=${default_swconfig_file_path}    asik_alias=${alias}
    ${scf_template_path}    Get scf template file with release considered    scf_template_file_path=${scf_template_path}
    csn.disconnect    connection=${alias}
    Log to console    Start to modify scf files and commission, please wait...
    ${default_scf_file_path}    Copy file    source=${scf_template_path}    destination=${local_log_file_folder}
    ${output_scf_file_path}    run keyword if    ${scf_modify}!=${None}
    ...    coam_gnb_classical.COAM Modify scf file    scf_file_path=${default_scf_file_path}
    ...    scf_parameters_list=${scf_modify}
    ...    ELSE    set variable  ${default_scf_file_path}
    ${result}    COAM Commission with scf file    scf_file_path=${output_scf_file_path}    timeout=${commission_timeout}
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}    connection=${connection}
    ${pdl_validation_result}    set variable if
    ...    ${is_pdl_checking_needed}==${True} and '${result['validationResult']['pdlValidationResult']['status']}'!='OK'    ${False}
    ...    ${is_pdl_checking_needed}==${True} and '${result['validationResult']['pdlValidationResult']['status']}'=='OK'    ${True}
    ...    ${is_pdl_checking_needed}==${False}    ${None}
    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=${alias}    AND
    ...    COAM Teardown gnb connections    connection=${connection}
    [Return]    ${pdl_validation_result}

Wait until cluster is on cell on air status
    [Timeout]    30 min
    [Documentation]    Author: Ding Binmei
    ...                Description: Wait ENB cell on air, GNB cell on air, X2 link status available.
    ...                             Wait until each single cell status in cell on air status
    ...                             ${list_cell_index}: can be a list for cell index, default to cell 1
    ...                             ${list_cell_group_index}: can be a list for cell group index, default to cell 1 group index,
    ...                                                       Should be matched with cell index field
    ...                2020/1/15 Liu Zheng: add check all cells if needed.
    ...                2020/3/12 Liu Zheng: add parameter gnb_ps_cell_list, mainly for checking the x2 link for several nrStatus
    ...                2020/12/15 Ding Binmei: 1. Extend keyword to support ENB cell on air checking for multi-ENBs
    ...    if ${is_enb_status_check_needed} set to true, then it will check for all enbs defined in tl config file.
    ...    For DU alias, need to release by tester in cases. Example alias: GNB_OAM, GNB_OAM_du1, GNB_OAM_du2
    ...    2021/03/03 Wang Yixiang: ${gnb_type} is deprecated, will get gnb_type online
    ...    2021/04/01 Ding Binmei: Extend ${enb_index}, default to ${None}. If is_enb_status_check_needed: true and it set to ${None}, which means
    ...    all ENBs will be checked. it can also support for multi enbs checking. both single value and list values are supported.
    ...    2021/06/23 Cui Lingxue: Add ${is_need_to_setup_gnb_connection} and ${connection}. If ${is_need_to_setup_gnb_connection} is true, new ssl
    ...    connection to gnb will be setup; if false, connection alias will use given ${connection}.
    [Arguments]    ${list_cell_index}=1    ${list_cell_group_index}=0      ${timeout}=20 min    ${is_all_cells_checking_needed}=${False}
    ...    ${retry_interval}=5 sec    ${gnb_ps_cell_list}=${GNB_PS_CELL_INDEX_LIST}    ${du_index}=0    ${is_x2_check_from_enb_needed}=${True}
    ...    ${is_enb_status_check_needed}=${True}  ${gnb_type}='NSA'    ${enb_index}=${None}
    ...    ${is_need_to_setup_gnb_connection}=${True}    ${connection}=GNB_OAM   ${gnb_index}=0
    ${connection}    COAM Wait for gnb ready and cell setup    timeout=${timeout}  retry_interval=${retry_interval}  du_index=${du_index}
    ...    connection=${connection}    is_need_to_setup_gnb_connection=${is_need_to_setup_gnb_connection}
    ...    is_x2_check_from_gnb_needed=${is_x2_check_from_enb_needed}    gnb_index=${gnb_index}
    ${gnb_type}    Get gNbType SA or NSA via rest api    connection=${connection}
    ${is_enb_status_check_needed} 	Set Variable If	  '${gnb_type}'=='SA'  	${False}    ${is_enb_status_check_needed}
    ${is_x2_check_from_enb_needed} 	Set Variable If	  '${gnb_type}'=='SA' 	${False}    ${is_x2_check_from_enb_needed}

    Run keyword if    ${is_all_cells_checking_needed}==${True}    Wait until keyword succeeds    ${timeout}    ${retry_interval}
    ...    Verify all cells should be onair    connection=${connection}
    ...    ELSE    Verify specific cell should be unlocked    list_cell_index=${list_cell_index}    list_cell_group_index=${list_cell_group_index}
    ...            timeout=${timeout}    connection=${connection}
    Run keyword if    ${is_enb_status_check_needed}
    ...    Wait for all ENB status are on air based on testline config file    timeout=${timeout}    enb_index=${enb_index}
    Run keyword if    ${is_x2_check_from_enb_needed}
    ...    wait until keyword succeeds    ${timeout}    ${retry_interval}     enb_lte.Check X2 link to gnb is available
    ...        gnb_ps_cell_list=${gnb_ps_cell_list}

Verify specific cell should be unlocked
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${list_cell_index}=1    ${list_cell_group_index}=0    ${timeout}=10 min    ${connection}=GNB_OAM
    ...    ${checking_interval}= 20 sec
    @{cell_index_list}    Convert to list    ${list_cell_index}
    @{cell_group_index_list}    Convert to list    ${list_cell_group_index}
    ${count_cell}    get length    ${cell_index_list}
    FOR  ${i}  IN RANGE  ${count_cell}
        Wait until keyword succeeds    ${timeout}    ${checking_interval}    Cell Should Be Unlocked
        ...    cell_idx=${cell_index_list[${i}]}    cell_group_idx=${cell_group_index_list[${i}]}    timeout=10    connection=${connection}
    END

Verify all cells should be onair
    [Documentation]    Author: Liu Zheng    HGZ_SG4
    ...                Description: verify all the cells status should be correct.
    [Arguments]    ${cell_type}=nr  ${connection}=GNB_OAM
    Log to console    Verify all cells are on air
    ${administrative_expected}    Set Variable      Unlocked      # NR
    ${administrative_expected}    Set Variable If   '${cell_type}'=='lte'    unlocked    ${administrative_expected}
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['administrativeState']}
        ...      ${administrative_expected}
        Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['operationalState']}    enabled
        Run keyword and continue on failure    Dictionary Should Not Contain Key    ${cell['status']}     availabilityStatus
        ...   msg=Cell-${cell['physicalCellId']}'s availabilityStatus present, means cell is disable or degraded, please check.
    END

Check all cells info should be onair
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=900
    Log to console    Check all NR and LTE cells should be onair
    ${nr_cells_info}   coam.get_cells_info  cell_type=nr    timeout=${timeout}    connection=${connection}
    FOR    ${cell}    IN    @{nr_cells_info}
        Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}   enabled
        Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}     unlocked
        Should Be Equal As Strings    ${cell['status']['blockingState'].lower()}   unblocked
    END
    ${lte_cells_info}   coam.get_cells_info  cell_type=lte    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{lte_cells_info}
        Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}   enabled
        Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}     unlocked
        Should Be Equal As Strings    ${cell['status']['blockingState'].lower()}   unblocked
    END

All cells in cell group should be onair
    [Documentation]    Author: Liu Zheng [PRIVATE]
    [Arguments]   ${cell_from_cellgrp}    ${connection}=GNB_OAM
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${cell_list}    Get Dictionary Keys    ${cell_from_cellgrp}
    FOR  ${cell}  IN   @{cell_list}
        ${eachcell}    Get from Dictionary    ${cell_from_cellgrp}    ${cell}
        Run keyword and continue on failure    Should Be Equal As Strings    ${eachcell['NRCELL_R']['administrativeState']}     ${unlocked}
        Run keyword and continue on failure    Should Be Equal As Strings    ${eachcell['NRCELL_R']['operationalState']}   ${enabled}
        run keyword if  ${result}    Run keyword and continue on failure
        ...    Should Be Equal As Strings    ${eachcell['NRCELL_R']['availabilityStatus']}   Online

    END

COAM Get FSM Type
    [Arguments]  ${connection}=GNB_OAM
    @{output_fsm_info}    coam.get_fsm_info    connection=${connection}
    ${FSM_TYPE}    Set Variable    ${output_fsm_info[0]['productName'].split(' ')}[0]
    [Return]    ${FSM_TYPE}

Perform cell lock via rest api
    [Documentation]   Author: Ding Binmei
    ...               Description: If selenium method is not stable can switch to this method instead
    [Arguments]    ${cell_idx}=${1}    ${connection}=GNB_OAM    ${timeout}=60    ${gnb_id}=0
    ${mr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].instance_id}
    ${nr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].global_bts_id}
    coam.lock    dist_name=MRBTS-${mr_bts_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_idx}    timeout=${timeout}    connection=${connection}

Perform cell unlock via rest api
    [Documentation]   Author: Ding Binmei
    ...               Description: If selenium method is not stable can switch to this method instead
    [Arguments]    ${cell_idx}=${1}    ${connection}=GNB_OAM    ${timeout}=60    ${gnb_id}=0
    ${mr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].instance_id}
    ${nr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].global_bts_id}
    coam.unlock    dist_name=MRBTS-${mr_bts_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_idx}    timeout=${timeout}    connection=${connection}

Perform RU lock via rest api
    [Documentation]   Author: Liu Zheng
    ...               Description: If selenium method is not stable can switch to this method instead
    [Arguments]    ${ru_idx}=${1}    ${eqm_idx}=${1}    ${apeqm_idx}=${1}    ${connection}=GNB_OAM    ${timeout}=60    ${gnb_id}=0
    ${unused_arguments_list}    Create List    eqm_idx=${eqm_idx}   apeqm_idx=${apeqm_idx}
    Log    message=\nArgument ${unused_arguments_list} is not used and will be removed in the future.
    ${mr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].instance_id}
    coam.lock    dist_name=MRBTS-${mr_bts_id}/EQM-1/APEQM-1/RMOD-${ru_idx}    timeout=${timeout}    connection=${connection}

Perform RU unlock via rest api
    [Documentation]   Author: Liu Zheng
    ...               Description: If selenium method is not stable can switch to this method instead
    [Arguments]    ${ru_idx}=${1}    ${eqm_idx}=${1}    ${apeqm_idx}=${1}   ${connection}=GNB_OAM    ${timeout}=60    ${gnb_id}=0
    ${unused_arguments_list}    Create List    eqm_idx=${eqm_idx}   apeqm_idx=${apeqm_idx}
    Log    message=\nArgument ${unused_arguments_list} is not used and will be removed in the future.
    ${mr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].instance_id}
    coam.unlock    dist_name=MRBTS-${mr_bts_id}/EQM-1/APEQM-1/RMOD-${ru_idx}    timeout=${timeout}    connection=${connection}

Perform cell group lock via rest api
    [Documentation]   Author: Liu Zheng
    ...               Description: If selenium method is not stable can switch to this method instead
    [Arguments]    ${cellgrp_idx}=${0}    ${connection}=GNB_OAM    ${timeout}=60    ${gnb_id}=0
    ${mr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].instance_id}
    ${nr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].global_bts_id}
    coam.lock_cell_group    dist_name=MRBTS_A-${mr_bts_id}/NRBTS_A-${nr_bts_id}/NRCELLGRP_A-${cellgrp_idx}     timeout=${timeout}
    ...    connection=${connection}

Perform cell group unlock via rest api
    [Documentation]   Author: Liu Zheng
    ...               Description: If selenium method is not stable can switch to this method instead
    [Arguments]    ${cellgrp_idx}=${0}    ${connection}=GNB_OAM    ${timeout}=60    ${gnb_id}=0
    ${mr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].instance_id}
    ${nr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].global_bts_id}
    coam.unlock_cell_group    dist_name=MRBTS_A-${mr_bts_id}/NRBTS_A-${nr_bts_id}/NRCELLGRP_A-${cellgrp_idx}     timeout=${timeout}
    ...    connection=${connection}

COAM add several parameters via rest api
    [Documentation]  Author: Cui Lingxue
    ...              Description: this keyword is to add several parameters under existing MO via rest api.
    ...    ${parameters_to_add_via_api} should be given in special format, as the following:
    ...        [
    ...            {'dist_name': 'MRBTS-1/NRBTS-1/NRCELL-1',
    ...             'parameter': 'a1MeasSCellAddSsbRsrp',
    ...             'value': [{'a1HysteresisSCellAddSsbRsrp': '0',
    ...                        'a1ThresholdSCellAddSsbRsrpFDD': '80',
    ...                        'a1ThresholdSCellAddSsbRsrpTDD': '80',
    ...                        'a1TimeToTriggerSCellAddSsbRsrp': '0ms'}]
    ...             },
    ...        ]
    ...    ${update_via_api_status} will be returned, if the parameter requires the reset of bts in order to take effect,
    ...    additional check will be required.
    ...     Note: if use this keyword to add p_name involving in list_name, then all other p_name which exist in this list_name
    ...          should be given thoroughly as well.
    [Arguments]    ${parameters_to_add_via_api}    ${timeout}=${60}    ${connection}=GNB_OAM
    ${para_file}    coam_parameter.create_add_parameters_delta
    ...    parameters=${parameters_to_add_via_api}
    ...    connection=${connection}
    ${update_via_api_status}    coam_parameter.perform_scf_delta_commission
    ...    delta_file=${para_file['updated']}
    ...    timeout=${timeout}
    ...    connection=${connection}
    Should contain    ${update_via_api_status}    PASS
    ...    msg=parameters do not update successfully.    ignore_case=${True}
    [Return]   ${update_via_api_status}

COAM add several MOs via rest api
    [Documentation]  Author: Cui Lingxue
    ...              Description: this keyword is to add one or several new MOs via rest api.
    ...    ${objects_to_add_via_api} should be given in special format, as the following:
    ...        [
    ...            {'dist_name': 'MRBTS-1/NRBTS-1/NRDRB_QCI-7',
    ...             'parameter': 'nrDrbDN',
    ...             'value': 'MRBTS-1/NRBTS-1/NRDRB-4',
    ...             },
    ...            {'dist_name': 'MRBTS-1/NRBTS-1/NRDRB_QCI-7',
    ...             'parameter': 'nrDrbQciId',
    ...             'value': '7',
    ...             },
    ...            {'dist_name': 'MRBTS-1/NRBTS-1/NRDRB_QCI-7',
    ...             'parameter': 'qciValueList',
    ...             'value': ['7'],
    ...             },
    ...        ]
    ...    ${update_via_api_status} will be returned, if the parameter requires the reset of bts in order to take effect,
    ...    additional check will be required.
    ...     Note: if use this keyword to add p_name involving in list_name, then all other p_name which exist in this list_name
    ...          should be given thoroughly as well.
    [Arguments]    ${objects_to_add_via_api}    ${timeout}=${60}    ${connection}=GNB_OAM
    ${para_file}    coam_parameter.create_objects_delta
    ...    parameters=${objects_to_add_via_api}
    ...    connection=${connection}
    ${update_via_api_status}    coam_parameter.perform_scf_delta_commission
    ...    delta_file=${para_file['updated']}
    ...    timeout=${timeout}
    ...    connection=${connection}
    Should contain    ${update_via_api_status}    PASS
    ...    msg=parameters do not update successfully.    ignore_case=${True}
    [Return]   ${update_via_api_status}

COAM delete objects via rest api
    [Documentation]  Author: Cui Lingxue
    ...              Description: this keyword is to delete several MOs via rest api.
    ...    ${objects_to_delete_via_api} should be given in special format, as the following:
    ...    ${objects_to_delete_via_api}=[{dist_name=NRBTS-1/NRDRB_QCI-1}, {dist_name=NRBTS-1/NRDRB-1}]
    ...    ${update_via_api_status} will be returned, if the parameter requires the reset of bts in order to take effect,
    ...    additional check will be required.
    ...     Note: if use this keyword to modify p_name involving in list_name, then all other p_name which exist in this list_name
    ...          should be given thoroughly as well.
    [Arguments]    ${objects_to_delete_via_api}    ${timeout}=${60}    ${connection}=GNB_OAM
    ${para_file}    coam_parameter.create_delete_objects_delta
    ...    parameters=${objects_to_delete_via_api}
    ...    connection=${connection}
    ${update_via_api_status}    coam_parameter.perform_scf_delta_commission
    ...    delta_file=${para_file['updated']}
    ...    timeout=${timeout}
    ...    connection=${connection}
    Should contain    ${update_via_api_status}    PASS
    ...    msg=parameters do not update successfully.    ignore_case=${True}
    [Return]   ${update_via_api_status}

COAM delete parameters via rest api
    [Documentation]  Author: Cui Lingxue
    ...              Description: this keyword is to delete several parameters via rest api.
    ...    ${parameters_to_delete_via_api} should be given in special format, as the following:
    ...    ${parameters_to_delete_via_api}=[{dist_name='NRBTS-1/NRDRB-1', parameter='schedulWeight'}]
    ...    ${update_via_api_status} will be returned, if the parameter requires the reset of bts in order to take effect,
    ...    additional check will be required.
    [Arguments]    ${parameters_to_delete_via_api}    ${timeout}=${60}    ${connection}=GNB_OAM
    ${para_file}    coam_parameter.create_delete_parameters_delta
    ...    parameters=${parameters_to_delete_via_api}
    ...    connection=${connection}
    ${update_via_api_status}    coam_parameter.perform_scf_delta_commission
    ...    delta_file=${para_file['updated']}
    ...    timeout=${timeout}
    ...    connection=${connection}
    Should contain    ${update_via_api_status}    PASS
    ...    msg=parameters do not update successfully.    ignore_case=${True}
    [Return]   ${update_via_api_status}

Coam get alarm and Write to alarm log file
    [Arguments]    ${connection}=GNB_OAM
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    ${alarm_folder}    Join path    ${OUTPUT_DIR}    tmp_CI    alarm_info
    ${alarm_log_file}    Join path    ${alarm_folder}    ${ts_name}_alarm.log
    ${current_time}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Create directory    ${alarm_folder}
    ${active_alarms}    coam_gnb_classical.COAM Get active alarms    connection=${connection}
    ${new_content}    set variable    \nCollect time:${current_time}\n${active_alarms}\n
    Append To File    ${alarm_log_file}    ${new_content}
    BuiltIn.Log    Alarm info collected and write into log file: ${alarm_log_file}\n Alarm info:\n${new_content}

If ASOD or ASOE or ASOF testline
    [Documentation]    Author: Wang Yixiang     5G_PZ_MMW_HZ_1_SG
    ...    Get info from testline and check if ASOD or ASOE or ASOF testline.
    ...    return ${True} or ${False}
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=ASIK Master    ${timeout}=5s    ${retry_interval}=1s
    Run Keyword And Ignore Error   csn.disconnect    connection=${alias}
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Connect to Common Unit Master    gnb_index=${gnb_index}
    ...    du_index=${du_index}    alias=${alias}
    ${gnb_card_info}=    csn.execute    command=ddal -s ddal_sysinfo_module_get_unit_id 0
    ...    connection=${alias}
    ${ret_asod}    run keyword and return status    should contain    ${gnb_card_info}    ASOD
    ${ret_asoe}    run keyword and return status    should contain    ${gnb_card_info}    ASOE
    ${ret_asof}    run keyword and return status    should contain    ${gnb_card_info}    ASOF
    ${ret}    Set variable if  (${ret_asod} or ${ret_asoe} or ${ret_asof})   ${True}   ${False}
    [Teardown]    run keyword and ignore error    csn.disconnect    connection=${alias}
    [Return]    ${ret}

If ASOD or ASOE or ASOF or ASOG or ASOH testline
    [Documentation]    Author: Yue Liu     5G_PZ4_HZ_5_SG
    ...    Get info from testline and check if ASOD or ASOE or ASOF or ASOG or ASOH testline.
    ...    return ${True} or ${False}
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=ASIK Master    ${timeout}=5s    ${retry_interval}=1s
    Run Keyword And Ignore Error   csn.disconnect    connection=${alias}
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Connect to Common Unit Master    gnb_index=${gnb_index}
    ...    du_index=${du_index}    alias=${alias}
    ${gnb_card_info}=    csn.execute    command=ddal -s ddal_sysinfo_module_get_unit_id 0
    ...    connection=${alias}
    ${ret_asod}    run keyword and return status    should contain    ${gnb_card_info}    ASOD
    ${ret_asoe}    run keyword and return status    should contain    ${gnb_card_info}    ASOE
    ${ret_asof}    run keyword and return status    should contain    ${gnb_card_info}    ASOF
    ${ret_asog}    run keyword and return status    should contain    ${gnb_card_info}    ASOG
    ${ret_asoh}    run keyword and return status    should contain    ${gnb_card_info}    ASOH
    ${ret}    Set variable if  (${ret_asod} or ${ret_asoe} or ${ret_asof} or ${ret_asog} or ${ret_asoh})   ${True}   ${False}
    [Teardown]    run keyword and ignore error    csn.disconnect    connection=${alias}
    [Return]    ${ret}

Get gNbType SA or NSA via rest api
    [Documentation]    Author: Wang Yixiang
    ...                Description: get gNB type by rest api, gNB type:SA,NSA,both
    [Arguments]  ${connection}=GNB_OAM    ${timeout}=600
    @{MOs_nrbts}    coam.get_managed_objects    class_name=NRBTS_A    connection=${connection}    timeout=${timeout}
    &{dict_gNbType}    coam.get_parameters    dist_name=${MOs_nrbts[0]['distName']}    pattern=gNbCuType    connection=${connection}
    ${gNbType}    Set Variable    ${dict_gNbType['gNbCuType']}
    [Return]   ${gNbType}

Get All FSM Id
    [Documentation]  Author: Zhong Tingting
    [Arguments]  ${connection}=GNB_OAM
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    ${fsm_info}    set variable    ${hw_info.systemModules}
    ${fsm_id_list}  create list
    FOR  ${fsm}  IN  @{fsm_info}
        ${fsm_id_configuration}  set variable  ${fsm.id.configuration}
        ${fsm_id}    get regexp matches    ${fsm_id_configuration}    SMOD-(\\d+)    1
        append to list    ${fsm_id_list}    ${fsm_id[0]}
    END
    Sort List   ${fsm_id_list}
    [Return]  ${fsm_id_list}

Get All FBB Id
    [Documentation]  Author: Zhong Tingting
    [Arguments]  ${connection}=GNB_OAM
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    ${fbb_info}    set variable    ${hw_info.basebandModules}
    ${fbb_id_list}  create list
    FOR  ${fbb}  IN  @{fbb_info}
        ${if_fbb_commissioned}    Run Keyword And Return Status    Set Test Variable
        ...    ${fbb_id_configuration}    ${fbb.id.configuration}
        Continue For Loop If    '${if_fbb_commissioned}'=='False'
        ${fbb_id}    get regexp matches    ${fbb_id_configuration}    BBMOD-(\\d+)    1
        append to list    ${fbb_id_list}    ${fbb_id[0]}
    END
    Sort List   ${fbb_id_list}
    [Return]  ${fbb_id_list}

Get All RU Index
    [Arguments]     ${connection}=GNB_OAM
    &{hw_info}       coam.get_detected_hw_info    connection=${connection}
    ${rmod_info}    set variable    ${hw_info.radioModules.rmod}
    ${ru_index_list}    create list
    FOR  ${ru}  IN  @{rmod_info}
        ${ru_id_configuration}  set variable  ${ru.id.configuration}
        ${ru_index}    get regexp matches    ${ru_id_configuration}    RMOD-(\\d+)    1
        append to list    ${ru_index_list}    ${ru_index[0]}
    END
    Sort List   ${ru_index_list}
    [Return]  ${ru_index_list}

Get All RU Type Mapping Index
    [Arguments]     ${connection}=GNB_OAM
    &{hw_info}       coam.get_detected_hw_info    connection=${connection}
    ${rmod_info}    set variable    ${hw_info.radioModules.rmod}
    ${ru_index_type_mapping}    create dictionary
    FOR  ${ru}  IN  @{rmod_info}
        ${ru_id_configuration}  set variable  ${ru.id.configuration}
        ${ru_type}  set variable  ${ru.productName}
        ${ru_index}    get regexp matches    ${ru_id_configuration}    RMOD-(\\d+)    1
        set to dictionary    ${ru_index_type_mapping}    ${ru_index[0]}    ${ru_type}
    END
    [Return]  ${ru_index_type_mapping}

Get All Cell Id
    [Documentation]  ru_index=None: get all gnb cells, ru_index=ru_index: get all cells under RU
    [Arguments]  ${ru_index}=${None}    ${cell_type}=nr  ${connection}=GNB_OAM
    ${output}=    coam.get_cells_info    cell_type=${cell_type}    connection=${connection}
    Log Many      ${output}    level=DEBUG
    ${cell_list}  create list
    FOR  ${cell}  IN  @{output}
        run keyword if  ${ru_index}==${None}    append to list  ${cell_list}  ${cell['globalCellId']}
        ${carrier}    set variable  ${cell['carrierList'][0]}
        ${status}  run keyword if  ${ru_index}!=${None}    run keyword and return status
                   ...    should contain  ${carrier['antennaLineId']['configuration']}    RMOD-${ru_index}/
        run keyword if    ${status}    append to list  ${cell_list}  ${cell['globalCellId']}
    END
    Sort List   ${cell_list}
    [Return]  ${cell_list}

Get All Cell Id From RU
    [Arguments]  ${ru_index}    ${connection}=GNB_OAM
    ${nr_cell_list}  Get All Cell Id    ru_index=${ru_index}    cell_type=nr    connection=${connection}
    ${lte_cell_list}  Get All Cell Id    ru_index=${ru_index}    cell_type=lte    connection=${connection}
    ${cell_list}    Combine Lists    ${nr_cell_list}    ${lte_cell_list}
    ${nr_lte_concurrent}    Set Variable If    ${{len($nr_cell_list) > 0 and len($lte_cell_list) > 0}}    ${True}    ${False}
    [Return]    ${cell_list}    ${nr_lte_concurrent}

Get All Cell Group Id
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=${20}
    @{cellgrp_list}    create list
    TRY
        ${cell_info}   coam.get_subcells_status   timeout=${timeout}    connection=${connection}
        Log Many      ${cell_info}    level=DEBUG
        ${number_of_cell_group_info}    get length    ${cell_info}
        ${tmp_cellgrp_list}    Get Dictionary Keys    ${cell_info}
        ${cellgrp_list}    Combine Lists    ${cellgrp_list}    ${tmp_cellgrp_list}
    EXCEPT
        ${list_cellgrp_info}   Get Cell Group Parameters    timeout=${timeout}    connection=${connection}
        FOR    ${cellgrp_info}    IN    @{list_cellgrp_info}
            Append to list    ${cellgrp_list}    ${cellgrp_info}[name]
        END
    END
    @{cellgrp_index_list}    create list
    FOR    ${cellgrp}    IN    @{cellgrp_list}
        ${cellgrp_index}    Fetch from right    ${cellgrp}    -
        ${cellgrp_index}  convert to integer  ${cellgrp_index}
        Append to list    ${cellgrp_index_list}    ${cellgrp_index}
    END
    Sort List   ${cellgrp_index_list}
    [Return]    ${cellgrp_index_list}

Get Cell Group From Cell
    [Arguments]    ${cell_id}    ${connection}=GNB_OAM
    ${cellgrp_index_list}    Get All Cell Group Id    connection=${connection}
    FOR   ${cellgrp_index}   IN   @{cellgrp_index_list}
        ${cell_list}   Get Cell From Cell Group   cellgrp_id=${cellgrp_index}
        ${cellgrp_id}   Get Cell Group ID from Cell ID   cell_id=${cell_id}   cellgrp_index=${cellgrp_index}   cell_list=${cell_list}
        exit for loop if  "${cellgrp_id}" != "${None}"
    END
    [Return]    ${cellgrp_id}

Get Cell From Cell Group
    [Arguments]    ${cellgrp_id}    ${connection}=GNB_OAM    ${timeout}=${20}
    @{cell_list_info}    create list
    TRY
        ${subcells_info}   coam.get_subcells_status   timeout=${timeout}    connection=${connection}
        ${cell_info}    get from dictionary    ${subcells_info}    NRCELLGRP-${cellgrp_id}\
        ${tmp_cell_list_info}    Get Dictionary Keys    ${cell_info}
        ${cell_list_info}    Combine Lists    ${cell_list_info}    ${tmp_cell_list_info}
    EXCEPT
        ${list_cellgrp_info}   Get Cell Group Parameters    timeout=${timeout}    connection=${connection}
        FOR    ${cellgrp_info}    IN    @{list_cellgrp_info}
            ${cellgrp_index}    Fetch from right    ${cellgrp_info}[name]    -
            IF    '${cellgrp_index}'=='${cellgrp_id}'
                ${cell_list_info}    Combine Lists    ${cell_list_info}    ${cellgrp_info}[nrCellList]
            END
        END
    END
    ${cell_list}  create list
    FOR  ${cell}  IN  @{cell_list_info}
        ${cell_index}    Fetch from right    ${cell}    -
        ${cell_index}    convert to integer    ${cell_index}
        append to list  ${cell_list}  ${cell_index}
    END
    Sort List   ${cell_list}
    [Return]  ${cell_list}

Get Cell Group ID from Cell ID
     [Arguments]    ${cell_id}    ${cellgrp_index}    ${cell_list}
     FOR   ${cell_index}   IN   @{cell_list}
         return from keyword if    '${cell_index}'=='${cell_id}'    ${cellgrp_index}
     END

Get nr cell id mapping if not exist
    [Documentation]  Author: Ding Binmei
    ...    Get ${NR_CELL_ID_MAPPING} if this parameter is not exist and set as suite parameter
    ...    Please use ${NR_CELL_ID_MAPPING} This parameter carefully, espencially for multi GNB envs, don't use this keyword,
    ...    Please re-generate the cell mapping for usage
    [Arguments]    ${connection}=GNB_OAM
    ${is_nr_cell_id_mapping_exist}    get_variable_value    &{NR_CELL_ID_MAPPING}
    &{NR_CELL_ID_MAPPING}    Run keyword if    ${is_nr_cell_id_mapping_exist}==${None}
    ...    get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection}
    Run keyword if    ${is_nr_cell_id_mapping_exist}==${None}    Set suite variable    ${NR_CELL_ID_MAPPING}

Change status for parameter cellBarred on GNB
    [Documentation]  Author: Ding Binmei
    ...    exp_status: supported values: barred, notBarred
    ...    list_cell_ids: can be a list for cell index, and also can be a string, like 1;
    ...                   Default to all: all cells on GNB will be updated
    ...    connection: Adapt for cloud. If cloud, then connection refers to vdu connection
    ...        Note: For cloud, this keyword is only used for generate params for update on DU
    ...    du_index: only needed if cloud bts
    ...    if partially ids are provided, then all these cells will be modified to exp_status, like (barred/notBarred)
    ...    and all the rest cells will be set as oppsite status, like (notBarred/barred)
    ...    Example output for return value in cloud:
    ...        {'param_to_upd': [{'dist_name': 'MRBTS-37180/NRBTS-37180/NRCELL-1', 'parameter': 'cellBarred', 'value': 'notBarred'},
    ...                      {'dist_name': 'MRBTS-37180/NRBTS-37180/NRCELL-2', 'parameter': 'cellBarred', 'value': 'notBarred'},
    ...                      {'dist_name': 'MRBTS-37180/NRBTS-37180/NRCELL-3', 'parameter': 'cellBarred', 'value': 'notBarred'}]
    ...        }
    [Arguments]    ${exp_status}    ${list_cell_ids}=all    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=${120}    ${du_index}=0
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${gnb_nr_cell_id_mapping}    Run keyword if    ${has_cbts}    cloud_gnb.get_relation_mapping_between_cell_and_others
    ...    vdu_connection=${connection}
    ...    ELSE    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection}
    ...                                                                                        gnb_index=${gnb_index}
    ${all_cell_ids}    Get dictionary keys    ${gnb_nr_cell_id_mapping}
    ${is_all_cellls_entered}    Run keyword and return status    Should contain    ${list_cell_ids}    all
    ${list_cell_ids}    Set variable if    ${is_all_cellls_entered}    ${all_cell_ids}    ${list_cell_ids}
    ${list_cell_ids}    Convert data type to a list    input_data=${list_cell_ids}
    ${all_cell_ids}    Evaluate    list(map(lambda x: int(x), ${all_cell_ids}))
    ${list_cell_ids}    Evaluate    list(map(lambda x: int(x), ${list_cell_ids}))
    ${rest_cell_ids}    Evaluate    list(set(${all_cell_ids})-set(${list_cell_ids}))
    ${rest_cell_barred_status}    Set variable if    '${exp_status}'=='barred'    notBarred
    ...    barred
    @{params_for_update}    Create list
    ${dn_nrbts}    Set variable if    ${has_cbts}
    ...    MRBTS-${tl.gnbs[${gnb_index}].dus[${du_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].dus[${du_index}].global_bts_id}
    ...    MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}
    Log to console    Change status to ${exp_status} for expected cells: ${list_cell_ids} on GNB: ${gnb_index}
    FOR    ${cell_index}    IN    @{list_cell_ids}
        ${dist_name}    set variable    ${dn_nrbts}/NRCELL-${cell_index}
        ${param}    create dictionary    dist_name=${dist_name}    parameter=cellBarred    value=${exp_status}
        Append to list    ${params_for_update}    ${param}
    END
    Log to console    Change status to ${rest_cell_barred_status} for rest cells: ${rest_cell_ids} on GNB: ${gnb_index}
    FOR    ${cell_index}    IN    @{rest_cell_ids}
        ${dist_name}    set variable    ${dn_nrbts}/NRCELL-${cell_index}
        ${param}    create dictionary    dist_name=${dist_name}    parameter=cellBarred    value=${rest_cell_barred_status}
        Append to list    ${params_for_update}    ${param}
    END
    Log to console    Parameters for update cellBarred status are: ${params_for_update} on GNB: ${gnb_index}
    &{dict_update_param}    Run keyword if    ${has_cbts}    Create dictionary    param_to_upd=${params_for_update}
    Run keyword if    ${has_cbts}
    ...    Log to console    For cloud, this keyword only support to generate params for update, please active in your case level
    Return from keyword if    ${has_cbts}    ${dict_update_param}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}    timeout=${timeout}
    ...        connection=${connection}

Connect to gnb coam via ssl by gnb index
    [Documentation]  Author: Ding Binmei
    [Arguments]  ${gnb_index}=0
    ${connection}    Set variable    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl
    ...    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    connection=${connection}
    [Return]  ${connection}

Change cellBarred status for all cells inside one GNB with connection released
    [Documentation]  Author: Ding Binmei
    ...    cellBarred_status: supported values: barred, notBarred
    [Arguments]    ${cellBarred_status}    ${gnb_index}=${0}
    ${gnb_connection}    Connect to gnb coam via ssl by gnb index    gnb_index=${gnb_index}
    Change status for parameter cellBarred on GNB    exp_status=${cellBarred_status}    list_cell_ids=all    connection=${gnb_connection}
    ...    gnb_index=${gnb_index}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${gnb_connection}

Connect To MultiRAT GNB Common Unit Master
    [Documentation]    Auther:li.su@nokia-sbell.com    HGZ_SG6
    ...                Description: Login MultiRAT GNB Master
    [Arguments]    ${connection}=ASIK Master    ${hostname}=fct-4a    ${alias}=MultiRAT GNB Master    ${gnb_index}=${0}    ${du_index}=${0}
    ssh.Connect to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${connection}
    ssh.Connect to    hostname=${hostname}
    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${connection}
    ...               alias=${alias}

Disconnect To MultiRAT GNB Common Unit Master
    [Documentation]    Auther:li.su@nokia-sbell.com    HGZ_SG6
    ...                Description: Logout MultiRAT GNB Master
    csn.disconnect    connection=MultiRAT GNB Master

Check If MultiRAT BTS
    [Documentation]    Auther:li.su@nokia-sbell.com    HGZ_SG6
    ...                Description: Check the current gnb if multiRAT BTS
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0
    Log to console   Check the current gnb if multiRAT BTS
#    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run keyword if    ${has_cbts}
    ...    Wait Until Keyword Succeeds    5min    30s    coam_gnb_classical.Cloud DU connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ...    ELSE    Wait Until Keyword Succeeds    5min    30s    coam_gnb_classical.Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${bts_info}    coam.get_bts_info    connection=${connection}
    ${lte_info_length}    Get Length    ${bts_info['cells']['lte']}
    ${nr_info_length}    Get Length    ${bts_info['cells']['nr']}
    ${multiRAT}     Run keyword and return status     Should Be True    ${lte_info_length}>0 and ${nr_info_length}>0
    [Return]    ${multiRAT}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

Check cells under group should be locked
    [Arguments]   ${cell_group_idx}=${0}   ${connection}=GNB_OAM
    ${cell_list}    Get Cell From Cell Group    cellgrp_id=${cell_group_idx}    connection=${connection}
    FOR    ${cell_id}    IN    @{cell_list}
            Cell Should Be Locked    cell_idx=${cell_id}   cell_group_idx=${cell_group_idx}
    END

Check cells under group should be unlocked
    [Arguments]   ${cell_group_idx}=${0}   ${connection}=GNB_OAM
    ${cell_list}    Get Cell From Cell Group    cellgrp_id=${cell_group_idx}    connection=${connection}
    FOR    ${cell_id}    IN    @{cell_list}
            Cell Should Be Unlocked    cell_idx=${cell_id}   cell_group_idx=${cell_group_idx}
    END

Check cell should be locked
    [Arguments]  ${cell_id}   ${connection}=GNB_OAM
    ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_id}    connection=${connection}
    Cell Should Be Locked   cell_idx=${cell_id}   cell_group_idx=${cellgrp_id}    connection=${connection}

Check cell should be unlocked
    [Arguments]  ${cell_id}   ${connection}=GNB_OAM
    ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_id}    connection=${connection}
    Cell Should Be Unlocked   cell_idx=${cell_id}   cell_group_idx=${cellgrp_id}    connection=${connection}

Check HW modules detection
    [Arguments]  ${timeout}=10 min    ${connection}=GNB_OAM   ${retry_interval}=5 sec    ${du_index}=0
    log to console    \n***Check HW modules detection***
    ${is_asod_asoe_asof}    If ASOD or ASOE or ASOF testline    du_index=${du_index}
    Run keyword if    ${is_asod_asoe_asof}==${False}
    ...    Wait until keyword succeeds    ${timeout}    ${retry_interval}    COAM Check GNB ABIL status    connection=${connection}
    ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF
    run keyword and ignore error   COAM Check GNB ASIK status
    run keyword and ignore error   COAM Check GNB RU status

Check All Cells In Energysaving
    [Arguments]    ${connection}=GNB_OAM    ${energy_saving_state}=reducedenergysaving   ${timeout}=900
    Log to console    Check all NR cells should be ${energy_saving_state}
    ${nr_cells_info}   coam.get_cells_info  cell_type=nr    timeout=${timeout}    connection=${connection}
    FOR    ${cell}    IN    @{nr_cells_info}
        Should Be Equal As Strings    ${cell['energySavingState'].lower()}   ${energy_saving_state}
    END

Get All Realtime NR Cell Parameters
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=${20}
    ${cell_objects}   coam.get_managed_objects   class_name=NRCELL_R    timeout=${timeout}    connection=${connection}
    ${dict_cell_paramters}    Create Dictionary
    FOR    ${cell_object}    IN    @{cell_objects}
        ${cell_index}    Fetch from right    ${cell_object}[distName]    -
        Set To Dictionary    ${dict_cell_paramters}    ${cell_index}=${cell_object}[parameters]
    END
    [Return]    ${dict_cell_paramters}

Get Cell Group Parameters
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=${20}
    ${bts_info}   coam.get_bts_info    timeout=${timeout}    connection=${connection}
    ${list_cellgrp_info}    Get From Dictionary    ${bts_info}    cellsGroup
    [Return]    ${list_cellgrp_info}
