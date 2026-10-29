*** Settings ***
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    String
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/coam_parameter.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/CB005740/Resources/CB005740_coam_keyword.robot
Variables    testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/CB005740/Resources/CB005740_variables.py
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Resource    testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/CB007963/Resources/CB007963_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/RUfile_opearte_common_keyword.robot

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

${port1_up_cmd_TPS2}       config sync 1 ptp clock1 port4 adminState up\r
${port1_down_cmd_TPS2}     config sync 1 ptp clock1 port4 adminState down\r

${port2_up_cmd_TPS2}      config sync 1 ptp clock1 port2 adminState up\r
${port2_down_cmd_TPS2}    config sync 1 ptp clock1 port2 adminState down\r

${port3_up_cmd_TPS2}       config sync 1 ptp clock1 port6 adminState up\r
${port3_down_cmd_TPS2}     config sync 1 ptp clock1 port6 adminState down\r

${port4_up_cmd_TPS3}      config sync 1 ptp clock1 port8 adminState up\r
${port4_down_cmd_TPS3}    config sync 1 ptp clock1 port8 adminState down\r

${vm_tmp_log_dir}    /tmp
${PTP_SyncE_filter}    'ether proto 0x88f7||0x8809'

${msgid}     ptp.v2.messagetype
${sync_message}        ${msgid} == 0
${announce_message}    ${msgid} == 11
${delayReq_message}    ${msgid} == 1
${delayResp_message}   ${msgid} == 9

${announce_flag}    ptp.v2.flags == 0x0000003c
${sync_flag}    ptp.v2.flags == 0x00000000

${check_ptp_sync}    ${sync_message} and
...                  ${sync_flag}

${check_ptp_announce}    ${announce_message} and
...                      ptp.v2.an.priority1 == 128 and
...                      ptp.v2.an.priority2 == 128 and
...                      ptp.v2.an.origincurrentutcoffset == 37 and
...                      ptp.v2.timesource == 32 and
...                      ${announce_flag}

${clock_class}          ptp.v2.an.grandmasterclockclass
${clock_accuracy}       ptp.v2.an.grandmasterclockaccuracy
${clock_variance}       ptp.v2.an.grandmasterclockvariance

@{status}    locked    holdover_in    holdover_out

&{eCpriMasterClockClass}    locked=6    holdover_in=7    holdover_out=150
&{eCpriMasterClockAccuracy}    locked=33    holdover_in=254    holdover_out=254
&{eCpriMasterOffsetScaledLogVariance}    locked=20061    holdover_in=65535    holdover_out=65535

${tmp_log_dir}      ${TS_LOG_PATH_BASE}

${command_template}    {tshark_path} -r {pcap_file} -T pdml

${PTP_filter}     'ether proto 0x88f7'
@{listen_port}     arb0p1   arb0p0   arb0p3    arb0p2
@{portlist}       3    4    1    2
@{faults_list}       61631    16    4298
${time_relative}     frame.time_relative

${MAX_LOOP}        20

*** Keywords ***
CB005740 Case Setup
    robot_common_operations.Common Case Setup
    COAM Create log directory for 561
    COAM Wait for gnb ready and cell setup and sync status
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    COAM Wait for gnb ready and cell setup    timeout=20 min
    Run Keyword And Continue On Failure    Check for unexpected alarms
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
    AlarmWatchdog.add_allow_alarms    fault_id=${faults_list}

BTS_site_reset for 5740
    ${ci_var_dict}    CI_commssion._Set Variables For Test
    run keyword if     '${ci_var_dict}[stream]'=='SBTS00'    BTS_site_reset accord release

BTS_site_reset accord release
    Start Btslog Collect
    Run keyword and ignore error    BTS reset many times
    Sleep     10min
    Stop Btslog Collect    target_dir=${TS_CASE_LOG_PATH}
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Connect to Common Unit Master
    Connect to gnb coam via ssl

BTS reset many times
    FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP}
        Connect to Common Unit Master
        Connect to gnb coam via ssl
        Set Global Variable    ${TEST_LOOP}
        ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
        Log To Console    \n GNB Reset Iteration ${TEST_LOOP} in progress at: ${date}
        Perform BTS Site Reset for 5740
        Run Keyword And Continue On Failure    Check expect alarm not exist      expect_alarm=${16}
        Sleep    30s
        Run Keyword And Continue On Failure    COAM Wait for gnb ready and cell setup and sync status
        Run Keyword And Continue On Failure    Check expect history alarm not exist    expect_alarm=${16}
        Run keyword and ignore error    COAM Teardown gnb connections
        Run keyword and ignore error    ssh.Disconnect    connection=ASIK Master
    END

Perform BTS Site Reset for 5740
    [Arguments]   ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI   download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    Run Keyword And Continue On Failure    selenium_coam.reset_site
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    selenium_coam.save_screenshot   filename=Screen_${curr_data}.png    screenshot_dir=${OUTPUT DIR}
    [Teardown]  COAM selenium close browser

Check expect history alarm not exist
    [Arguments]    ${expect_alarm}    ${connection}=GNB_OAM
    ${history_alarms_list}    coam.get_historic_alarms    connection=${connection}
    ${exist_alarms}    Create List
    FOR  ${alarm}  IN  @{history_alarms_list}
       Append To List    ${exist_alarms}   ${alarm['faultId']}
    END
    Should Not Contain        ${exist_alarms}     ${expect_alarm}

COAM Wait for gnb ready and cell setup and sync status
    COAM Wait for gnb ready and cell setup
    Wait until keyword succeeds    10min    20 sec    COAM Check GNB Sync status

CB005740 Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=${faults_list}
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    SG2_Common_setup_teardown.COAM commission scf and wait cell setup    scf_file_path=${backup_scf_file}
    Run keyword and ignore error    COAM Teardown gnb connections
    Run keyword and ignore error    ssh.Disconnect    connection=ASIK Master
    CI_interface.Common Case Teardown

Check for unexpected alarms
    Connect to gnb coam via ssl
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=GNB_OAM
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=${ALLOWED_HISTORY_FAULT}    connection=GNB_OAM

Start to Capture Wireshark Log
    [Arguments]    ${listen_port}     ${log_dir}     ${filename}    ${connection}
    csn.send command    command=sudo tcpdump -n -i ${listen_port} -w ${log_dir}/${filename} &>/dev/null &    connection=${connection}
    sleep    3s

Start to Capture Wireshark Log with filter
    [Arguments]    ${listen_port}     ${log_dir}     ${filename}    ${filter}    ${connection}
    csn.send command    command=sudo tcpdump -n -i ${listen_port} -w ${log_dir}/${filename} ${filter} &>/dev/null &    connection=${connection}
#    csn.send command    command=ip netns exec radions tcpdump -n -i ${listen_port} -w ${log_dir}/${filename} ${filter} &>/dev/null &
#    ...    connection=${connection}
    sleep    3s

Configuration topMasterList
    [Arguments]   ${topMasterList_parameter}
    Connect to gnb coam via ssl    connection=gnb_modify
    COAM Update TOPP parameters via rest api    parameters_to_add_via_api=${topMasterList_parameter}    connection=gnb_modify
    COAM Teardown gnb connections    connection=gnb_modify


Add one element and set value
    [Arguments]   ${start_num}      ${end_num}
    ...           ${is_need_to_check_validation_errors}=${True}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    Coam Input Parameter value via webUI   param_data=${PARAM_5740_STRUCTURE1[0]}
    ...                                    node_index=${start_num}
    Coam Input Parameter value via webUI   param_data=${PARAM_5740_STRUCTURE1[1]}
    ...                                    node_index=${start_num}
    Coam Input Parameter value via webUI   param_data=${PARAM_5740_STRUCTURE1[2]}
    ...                                    node_index=${start_num}
    Coam Input Parameter value via webUI   param_data=${PARAM_5740_STRUCTURE1[3]}
    ...                                    node_index=${start_num}
    _Add_elements   dist_name=${ADD_ELEMENTS_5740[0]}[dist_name]
    ...             filter_param=${ADD_ELEMENTS_5740[0]}[filter_param]
    ...             abbr=${ADD_ELEMENTS_5740[0]}[abbr]
    Coam Input Parameter value via webUI   param_data=${PARAM_5740_STRUCTURE2[0]}
    ...                                    node_index=${end_num}
    Coam Input Parameter value via webUI   param_data=${PARAM_5740_STRUCTURE2[1]}
    ...                                    node_index=${end_num}
    Coam Input Parameter value via webUI   param_data=${PARAM_5740_STRUCTURE2[2]}
    ...                                    node_index=${end_num}
    Coam Input Parameter value via webUI   param_data=${PARAM_5740_STRUCTURE2[3]}
    ...                                    node_index=${end_num}
    selenium_coam.validate_plan
    COAM check validation errors from webui    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
	Sleep    3s
    COAM selenium logout

Continue Add two elements and set value
    [Arguments]   ${start_num}      ${end_num}
    ...           ${is_need_to_check_validation_errors}=${True}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    _Add_elements   dist_name=${ADD_ELEMENTS_5740[0]}[dist_name]
    ...             filter_param=${ADD_ELEMENTS_5740[0]}[filter_param]
    ...             abbr=${ADD_ELEMENTS_5740[0]}[abbr]
    Coam Input Parameter value via webUI   param_data=${PARAM_5740_STRUCTURE3[0]}
    ...                                    node_index=${start_num}
    Coam Input Parameter value via webUI   param_data=${PARAM_5740_STRUCTURE3[1]}
    ...                                    node_index=${start_num}
    Coam Input Parameter value via webUI   param_data=${PARAM_5740_STRUCTURE3[2]}
    ...                                    node_index=${start_num}
    Coam Input Parameter value via webUI   param_data=${PARAM_5740_STRUCTURE3[3]}
    ...                                    node_index=${start_num}
    selenium_coam.validate_plan
    COAM check validation errors from webui    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
	Sleep    3s
    COAM selenium logout
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    _Add_elements   dist_name=${ADD_ELEMENTS_5740[0]}[dist_name]
    ...             filter_param=${ADD_ELEMENTS_5740[0]}[filter_param]
    ...             abbr=${ADD_ELEMENTS_5740[0]}[abbr]
    Coam Input Parameter value via webUI   param_data=${PARAM_5740_STRUCTURE4[0]}
    ...                                    node_index=${end_num}
    Coam Input Parameter value via webUI   param_data=${PARAM_5740_STRUCTURE4[1]}
    ...                                    node_index=${end_num}
    Coam Input Parameter value via webUI   param_data=${PARAM_5740_STRUCTURE4[2]}
    ...                                    node_index=${end_num}
    Coam Input Parameter value via webUI   param_data=${PARAM_5740_STRUCTURE4[3]}
    ...                                    node_index=${end_num}
    selenium_coam.validate_plan
    COAM check validation errors from webui    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
	Sleep    3s
    COAM selenium logout

Capture Wireshark Log for a While from RU
    [Arguments]    ${filename}     ${filter}    ${listen_port}
    Start to Capture Wireshark Log from RU    filename=${filename}    filter=${filter}    listen_port=${listen_port}
    sleep    30s
    Stop and Download Logs from RU     ${filename}

Start to Capture Wireshark Log from RU
    [Arguments]    ${filename}    ${filter}=none    ${listen_port}=arb0p0
    Connect to RU With Allocated IP
    Run Keyword If    ${filter} is None    Start to Capture Wireshark Log    listen_port=${listen_port}     log_dir=${gnb_tmp_log_dir}
    ...                                           filename=${filename}    connection=RU
    ...               ELSE    Start to Capture Wireshark Log with filter    listen_port=${listen_port}     log_dir=${gnb_tmp_log_dir}
    ...                                           filename=${filename}    filter=${filter}    connection=RU

Stop and Download Logs from RU
    [Arguments]    @{filenames}     ${container_id}=0x1018    ${asik_alias}=ASIK Master
    ...            ${ru_index}=${1}    #${gnb_index}=${0}
    ...            ${ru_username}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...            ${ru_password}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
#    ...            ${asik_addr}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
#    ...            ${asik_name}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
#    ...            ${asik_pass}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    csn.execute        command=ps -ef|grep -i tcpdump     connection=RU
    csn.send command        command=killall tcpdump     connection=RU
    csn.send command        command=sudo chmod 777 ${gnb_tmp_log_dir}    connection=RU
    FOR    ${filename}    IN    @{filenames}
        csn.send command        command=sudo chmod 777 ${gnb_tmp_log_dir}/${filename}    connection=RU
        ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
        csn.execute    command=rm /ffs/run/config/toor4nsn/.ssh/known_hosts    connection=${connection}
        ${channel}    Call Method    ${connection}    invoke_shell
        Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
        Sleep    1 sec
        Call Method    ${channel}    recv    ${65535}
        Call Method    ${channel}    send    scp ${ru_username}@${ru_ip_addr}:${gnb_tmp_log_dir}/${filename} /tmp\r
        Sleep    3 sec
        Call Method    ${channel}    recv    ${65535}
        Call Method    ${channel}    send    yes\r
        Sleep    3 sec
        Call Method    ${channel}    recv    ${65535}
        Call Method    ${channel}    send    ${ru_password}\r
        Sleep    3 sec
        Call Method    ${channel}    recv    ${65535}
        sleep    10s
        csn.download_file   remote_path=/tmp/node_FHNET00/tmp/${filename}    local_path=${tmp_log_dir}/${filename}   connection=${connection}
        sleep    2s
#        Run Keyword And Ignore Error    run process
#        ...  sudo sshpass -p ${asik_pass} scp ${asik_name}@${asik_addr}:/tmp/node_FHNET00/tmp/${filename} ${tmp_log_dir}/${filename}   shell=yes
        csn.execute    command=rm /tmp/node_FHNET00/tmp/${filename}    connection=${connection}
        csn.execute    command=sudo rm ${gnb_tmp_log_dir}/${filename}    connection=RU
    END

Check Log in Wireshark Log for SSM and PTP
    [Arguments]    ${file_name}    ${status}    ${listen_port}    ${is_have_message_status}
    Check Complete PTP messages      file_name=${file_name}    listen_port=${listen_port}    is_have_message_status=${is_have_message_status}
    Load BIP Log with Template Command    pcap_file=${tmp_log_dir}/${file_name}
    ...                                                 command_template=${command_template}
    ${expression}    Catenate    SEPARATOR=${SPACE}and${SPACE}
    ...                          ${check_ptp_announce}
    ...                          ${clock_class}==${eCpriMasterClockClass}[${status}]
    ...                          ${clock_accuracy}==${eCpriMasterClockAccuracy}[${status}]
    ...                          ${clock_variance}==${eCpriMasterOffsetScaledLogVariance}[${status}]
    Check expression in Bip Log by Name    filter_expression=${expression}    field_name=${msgid}
    Check expression in Bip Log by Name    filter_expression=${check_ptp_sync}    field_name=${msgid}

Check Message Rate
    [Arguments]    ${filename}    ${filter}    ${min_rate}    ${max_rate}
    ${msg}=    Get Frame Info Value from Wireshark Log
    ...        filename=${filename}
    ...        check_param=${time_relative}
    ...        condition_expression=${filter}
    ${cnt}=    Get Length     ${msg}
    ${time}=    Evaluate    ${msg[-1]}-${msg[0]}
    ${rate}=    Evaluate        (${cnt}-1)/${time}
    Should Be True     ${min_rate} < ${rate} < ${max_rate}

Get Frame Info Value from Wireshark Log
    [Arguments]    ${filename}    ${check_param}   ${condition_expression}=${None}
    Load BIP Log with Template Command    pcap_file=${tmp_log_dir}/${filename}
    ...                                                 command_template=${command_template}
    ${filtered_packets}    pcap.filter_packets_by_expression    filter_expression=${condition_expression}
    ${value}      pcap.get_field_value_by_name
    ...                                              field_name=${check_param}
    [Return]    ${value}

Check Complete PTP messages
    [Arguments]    ${file_name}   ${listen_port}  ${is_have_message_status}
    ${ru_ip_addr}     Auto Get RU IP Address
    Set Suite Variable       ${ru_ip_addr}       ${ru_ip_addr}
    Capture Wireshark Log for a While from RU    filename=${file_name}   filter=${PTP_SyncE_filter}   listen_port=${listen_port}
    Check Message Rate    filename=${file_name}    filter=${sync_message}     min_rate=15.9    max_rate=16.1
    Check Message Rate    filename=${file_name}    filter=${announce_message}     min_rate=7.9    max_rate=8.1
    ${result_status1}    Run Keyword And Return Status    Check Message Rate    filename=${file_name}
    ...                                                                         filter=${delayReq_message}
    ...                                                                         min_rate=15.9
    ...                                                                         max_rate=16.1
    Should Be Equal    ${result_status1}     ${is_have_message_status}
    ${result_status2}    Run Keyword And Return Status    Check Message Rate    filename=${file_name}
    ...                                                                         filter=${delayResp_message}
    ...                                                                         min_rate=15.9
    ...                                                                         max_rate=16.1
    Should Be Equal    ${result_status2}     ${is_have_message_status}

Check complete PTP messages for All ports
    [Arguments]   ${file_name}
    ${PortNumber}      Get topSlavePortNumber from topMasterClockState     index_begin=${0}       index_end=${3}
    ${port_index}    Get Index From List      ${portlist}     ${PortNumber}
    Run keyword if     ${port_index}==${0}
    ...    Check Complete PTP messages       file_name=${file_name[0]}    listen_port=${listen_port}[0]    is_have_message_status=${True}
    ...    ELSE     Run Keyword     Check Complete PTP messages      file_name=${file_name[0]}
    ...                                                              listen_port=${listen_port}[0]
    ...                                                              is_have_message_status=${False}
    Run keyword if     ${port_index}==${1}
    ...    Check Complete PTP messages      file_name=${file_name[1]}    listen_port=${listen_port}[1]    is_have_message_status=${True}
    ...    ELSE     Run Keyword     Check Complete PTP messages      file_name=${file_name[1]}
    ...                                                              listen_port=${listen_port}[1]
    ...                                                              is_have_message_status=${False}
    Run keyword if     ${port_index}==${2}
    ...    Check Complete PTP messages      file_name=${file_name[2]}    listen_port=${listen_port}[2]    is_have_message_status=${True}
    ...    ELSE     Run Keyword     Check Complete PTP messages      file_name=${file_name[2]}
    ...                                                              listen_port=${listen_port}[2]
    ...                                                              is_have_message_status=${False}
    Run keyword if     ${port_index}==${3}
    ...    Check Complete PTP messages      file_name=${file_name[3]}    listen_port=${listen_port}[3]    is_have_message_status=${True}
    ...    ELSE     Run Keyword     Check Complete PTP messages      file_name=${file_name[3]}
    ...                                                              listen_port=${listen_port}[3]
    ...                                                              is_have_message_status=${False}

Check Two Structure Log in Wireshark Log for SSM and PTP
    [Arguments]   ${file_name}
    Check Log in Wireshark Log for SSM and PTP    file_name=${file_name[0]}
    ...                                            status=${status}[0]
    ...                                            listen_port=${listen_port}[0]
    ...                                            is_have_message_status=${True}
    Check Log in Wireshark Log for SSM and PTP    file_name=${file_name[1]}
    ...                                           status=${status}[0]
    ...                                            listen_port=${listen_port}[1]
    ...                                            is_have_message_status=${True}
    Check Complete PTP messages      file_name=${file_name[2]}    listen_port=${listen_port}[2]    is_have_message_status=${False}
    Check Complete PTP messages     file_name=${file_name[3]}    listen_port=${listen_port}[3]    is_have_message_status=${False}

Check Four Structure Log in Wireshark Log for SSM and PTP
    [Arguments]  ${file_name}
    Check Log in Wireshark Log for SSM and PTP    file_name=${file_name[0]}
    ...                                            status=${status}[0]
    ...                                            listen_port=${listen_port}[0]
    ...                                            is_have_message_status=${True}
    Check Log in Wireshark Log for SSM and PTP    file_name=${file_name[1]}
    ...                                            status=${status}[0]
    ...                                            listen_port=${listen_port}[1]
    ...                                            is_have_message_status=${True}
    Check Log in Wireshark Log for SSM and PTP    file_name=${file_name[2]}
    ...                                            status=${status}[0]
    ...                                             listen_port=${listen_port}[2]
    ...                                            is_have_message_status=${True}
    Check Log in Wireshark Log for SSM and PTP    file_name=${file_name[3]}
    ...                                           status=${status}[0]
    ...                                            listen_port=${listen_port}[3]
    ...                                             is_have_message_status=${True}

Check ClockState and MaterUsed
    [Arguments]  ${ok_num_expect}  ${index_begin}   ${index_end}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${ok_num}    Count param according to expect values     index_begin=${index_begin}
    ...                                                       index_end=${index_end}
    ...                                                       expect_values=MASTER_CLOCK_OK
    ...                                                       dist_name=${GET_PARAMETER_VALUES_5740[0]}[dist_name]
    ...                                                       filter_param=${GET_PARAMETER_VALUES_5740[0]}[filter_param]
    ...                                                       abbr=${GET_PARAMETER_VALUES_5740[0]}[abbr]
    Should Be Equal     ${ok_num}    ${ok_num_expect}
    ${used_num}    Count param according to expect values     index_begin=${index_begin}
    ...                                                       index_end=${index_end}
    ...                                                       expect_values=used
    ...                                                       dist_name=${GET_PARAMETER_VALUES_5740[1]}[dist_name]
    ...                                                       filter_param=${GET_PARAMETER_VALUES_5740[1]}[filter_param]
    ...                                                       abbr=${GET_PARAMETER_VALUES_5740[1]}[abbr]
    Should Be Equal     ${used_num}      ${1}
    COAM selenium logout

Get topSlavePortNumber from topMasterClockState
   [Arguments]   ${index_begin}   ${index_end}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${ok_index}    Get Structure_index from expect_index    index_begin=${index_begin}
    ...                                                       index_end=${index_end}
    ...                                                       expect_index=MASTER_CLOCK_OK
    ...                                                       dist_name=${GET_PARAMETER_VALUES_5740[0]}[dist_name]
    ...                                                       filter_param=${GET_PARAMETER_VALUES_5740[0]}[filter_param]
    ...                                                       abbr=${GET_PARAMETER_VALUES_5740[0]}[abbr]
    ${PortNumber}       _Get_parameter_values  dist_name=${GET_PARAMETER_PORTNUMBER[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_PORTNUMBER[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_PORTNUMBER[0]}[abbr]
    ...                                            node_index=${ok_index}
    COAM selenium logout
    [Return]       ${PortNumber}

Get topSlavePortNumber from topMasterUsed
    [Arguments]   ${index_begin}   ${index_end}  ${is_or_not_used}
    ${used_index}    Get Structure_index from expect_index    index_begin=${index_begin}
    ...                                                       index_end=${index_end}
    ...                                                       expect_index=${is_or_not_used}
    ...                                                       dist_name=${GET_PARAMETER_VALUES_5740[1]}[dist_name]
    ...                                                       filter_param=${GET_PARAMETER_VALUES_5740[1]}[filter_param]
    ...                                                       abbr=${GET_PARAMETER_VALUES_5740[1]}[abbr]
    ${PortNumber}       _Get_parameter_values  dist_name=${GET_PARAMETER_PORTNUMBER[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_PORTNUMBER[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_PORTNUMBER[0]}[abbr]
    ...                                            node_index=${used_index}
    [Return]      ${PortNumber}

Set ruECpriPortNumber from topMasterUsed is used
    [Arguments]      ${is_need_to_check_validation_errors}=${True}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${PortNumber_used}   Get topSlavePortNumber from topMasterUsed    index_begin=${0}   index_end=${3}   is_or_not_used=used
    ${PortNumber_notused}   Get topSlavePortNumber from topMasterUsed    index_begin=${0}   index_end=${3}   is_or_not_used=not used
    selenium_coam.set_parameter_value    dist_name=${PARAM_5740_STRUCTURE1[2]}[dist_name]
    ...                                  filter_param=${PARAM_5740_STRUCTURE1[2]}[filter_param]
    ...                                  new_value=${PortNumber_used}
    ...                                  abbr=${PARAM_5740_STRUCTURE1[2]}[abbr]
    ...                                  node_index=${0}
    ...                                  timeout=${120}
    selenium_coam.validate_plan
    COAM check validation errors from webui    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    COAM selenium logout
    [Return]  ${PortNumber_used}     ${PortNumber_notused}

Set ruECpriPortNumber from topMasterUsed is not used
    [Arguments]    ${PortNumber_notused}     ${is_need_to_check_validation_errors}=${True}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    selenium_coam.set_parameter_value    dist_name=${PARAM_5740_STRUCTURE1[2]}[dist_name]
    ...                                  filter_param=${PARAM_5740_STRUCTURE1[2]}[filter_param]
    ...                                  new_value=${PortNumber_notused}
    ...                                  abbr=${PARAM_5740_STRUCTURE1[2]}[abbr]
    ...                                  node_index=${0}
    ...                                  timeout=${120}
    selenium_coam.validate_plan
    COAM check validation errors from webui    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    COAM selenium logout

Check status and port used
    [Arguments]   ${PortNumber}  ${is_or_not_used}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${lockState}   selenium_coam.get_parameter_value     dist_name=${PARAM_5750_LOCKSTATE[0]}[dist_name]
    ...                                            filter_param=${PARAM_5750_LOCKSTATE[0]}[filter_param]
    ...                                            abbr=${PARAM_5750_LOCKSTATE[0]}[abbr]
    Should Be Equal     ${lockState}      Locked
    ${syncStatus}   selenium_coam.get_parameter_value    dist_name=${PARAM_5750_SYNCSTATUS[0]}[dist_name]
    ...                                            filter_param=${PARAM_5750_SYNCSTATUS[0]}[filter_param]
    ...                                            abbr=${PARAM_5750_SYNCSTATUS[0]}[abbr]
    Should Be Equal     ${syncStatus}      Locked
    ${topMasterClockState}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_5740[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_5740[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_5740[0]}[abbr]
    ...                                            node_index=${0}
    Should Be Equal     ${topMasterClockState}      MASTER_CLOCK_OK
    ${topMasterUsed}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_5740[1]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_5740[1]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_5740[1]}[abbr]
    ...                                            node_index=${0}
    Should Be Equal     ${topMasterUsed}       ${is_or_not_used}
    ${topSlavePortNumber}   _Get_parameter_values  dist_name=${GET_PARAMETER_PORTNUMBER[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_PORTNUMBER[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_PORTNUMBER[0]}[abbr]
    ...                                            node_index=${0}
    Should Be Equal     ${topSlavePortNumber}       ${PortNumber}
    COAM selenium logout

Check status and port used for 5740
    [Arguments]   ${PortNumber}  ${is_or_not_used}   ${ClockState}   ${index_num}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${topMasterClockState}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_5740[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_5740[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_5740[0]}[abbr]
    ...                                            node_index=${index_num}
    Should Be Equal     ${topMasterClockState}      ${ClockState}
    ${topMasterUsed}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_5740[1]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_5740[1]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_5740[1]}[abbr]
    ...                                            node_index=${index_num}
    Should Be Equal     ${topMasterUsed}       ${is_or_not_used}
    ${topSlavePortNumber}   _Get_parameter_values  dist_name=${GET_PARAMETER_PORTNUMBER[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_PORTNUMBER[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_PORTNUMBER[0]}[abbr]
    ...                                            node_index=${index_num}
    Should Be Equal     ${topSlavePortNumber}       ${PortNumber}
    [Teardown]  COAM selenium logout

Check topMasterUsed distribution
    [Arguments]
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    &{port1_values}      Get values from different ports     ports_num=1
    &{port2_values}      Get values from different ports     ports_num=2
    &{port3_values}      Get values from different ports     ports_num=3
    &{port4_values}      Get values from different ports     ports_num=4
    @{used_list}=    Create List
    Append To List     ${used_list}     ${port1_values}[topMasterUsed]
    Append To List     ${used_list}     ${port2_values}[topMasterUsed]
    Append To List     ${used_list}     ${port3_values}[topMasterUsed]
    Append To List     ${used_list}     ${port4_values}[topMasterUsed]
    ${used_index}      Find the smallest from list and get topMasterUsed index     one_num=${port1_values}[topGMasterClockClass]
    ...                                                two_num=${port2_values}[topGMasterClockClass]
    ...                                                three_num=${port3_values}[topGMasterClockClass]
    ...                                                four_num=${port4_values}[topGMasterClockClass]
    ...                                                count=${4}
    Run Keyword If     ${used_index}==${0} or ${used_index}==${1} or ${used_index}==${2} or ${used_index}==${3}
    ...       Should Be Equal      ${used_list}[${used_index}]         used
    ${used_index}      Find the smallest from list and get topMasterUsed index     one_num=${port1_values}[localPriority]
    ...                                                two_num=${port2_values}[localPriority]
    ...                                                three_num=${port3_values}[localPriority]
    ...                                                four_num=${port4_values}[localPriority]
    ...                                                count=${4}
    Run Keyword If     ${used_index}==${0} or ${used_index}==${1} or ${used_index}==${2} or ${used_index}==${3}
    ...       Should Be Equal      ${used_list}[${used_index}]         used
    ${used_index}      Find the smallest from list and get topMasterUsed index     one_num=${port1_values}[topStepsRemoved]
    ...                                                two_num=${port2_values}[topStepsRemoved]
    ...                                                three_num=${port3_values}[topStepsRemoved]
    ...                                                four_num=${port4_values}[topStepsRemoved]
    ...                                                count=${4}
    Run Keyword If     ${used_index}==${0} or ${used_index}==${1} or ${used_index}==${2} or ${used_index}==${3}
    ...       Should Be Equal      ${used_list}[${used_index}]         used
    ${used_index}      Find the smallest from list and get topMasterUsed index     one_num=${port1_values}[topMasterClockIdentity]
    ...                                                two_num=${port2_values}[topMasterClockIdentity]
    ...                                                three_num=${port3_values}[topMasterClockIdentity]
    ...                                                four_num=${port4_values}[topMasterClockIdentity]
    ...                                                count=${4}
    Run Keyword If     ${used_index}==${0} or ${used_index}==${1} or ${used_index}==${2} or ${used_index}==${3}
    ...       Should Be Equal      ${used_list}[${used_index}]         used
    COAM selenium logout

Check topMasterUsed distribution when 2.048MHz
    [Arguments]
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    &{port1_values}      Get values from different ports     ports_num=1
    &{port2_values}      Get values from different ports     ports_num=2
    &{port3_values}      Get values from different ports     ports_num=3
    &{port4_values}      Get values from different ports     ports_num=4
    @{used_list}=    Create List
    Append To List     ${used_list}     ${port1_values}[topMasterUsed]
    Append To List     ${used_list}     ${port2_values}[topMasterUsed]
    Should Be Equal    ${port3_values}[topGMasterClockClass]     ${7}
    Should Be Equal    ${port4_values}[topGMasterClockClass]     ${7}
    ${used_index}      Find the smallest from list and get topMasterUsed index     one_num=${port1_values}[topGMasterClockClass]
    ...                                                two_num=${port2_values}[topGMasterClockClass]
    ...                                                three_num=${port3_values}[topGMasterClockClass]
    ...                                                four_num=${port4_values}[topGMasterClockClass]
    ...                                                count=${2}
    Run Keyword If     ${used_index}==${0} or ${used_index}==${1}
    ...       Should Be Equal      ${used_list}[${used_index}]         used
    ${used_index}      Find the smallest from list and get topMasterUsed index     one_num=${port1_values}[localPriority]
    ...                                                two_num=${port2_values}[localPriority]
    ...                                                three_num=${port3_values}[localPriority]
    ...                                                four_num=${port4_values}[localPriority]
    ...                                                count=${2}
    Run Keyword If     ${used_index}==${0} or ${used_index}==${1}
    ...       Should Be Equal      ${used_list}[${used_index}]         used
    ${used_index}      Find the smallest from list and get topMasterUsed index     one_num=${port1_values}[topStepsRemoved]
    ...                                                two_num=${port2_values}[topStepsRemoved]
    ...                                                three_num=${port3_values}[topStepsRemoved]
    ...                                                four_num=${port4_values}[topStepsRemoved]
    ...                                                count=${2}
    Run Keyword If     ${used_index}==${0} or ${used_index}==${1}
    ...       Should Be Equal      ${used_list}[${used_index}]         used
    ${used_index}      Find the smallest from list and get topMasterUsed index     one_num=${port1_values}[topMasterClockIdentity]
    ...                                                two_num=${port2_values}[topMasterClockIdentity]
    ...                                                three_num=${port3_values}[topMasterClockIdentity]
    ...                                                four_num=${port4_values}[topMasterClockIdentity]
    ...                                                count=${2}
    Run Keyword If     ${used_index}==${0} or ${used_index}==${1}
    ...       Should Be Equal      ${used_list}[${used_index}]         used
    COAM selenium logout

Start DLUL traffic and Caculate Tput when change TPS
    [Arguments]     ${data_transfer_dl}     ${data_transfer_ul}     ${Expected_Throughput_DL}     ${Expected_Throughput_UL}
    ...      ${ue_index}=${0}
    Reboot cpe for test    ue_index=${ue_index}
    Sleep    5min
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${5Grach_ed}     wait until keyword succeeds    2x    3s    power_ue.UE Attach     ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Verify attach     ue_type=${ue_type}     4G_check=False     5Grach_ed=${5Grach_ed}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${data_transfer_ul}     duration=15000    process_num=5
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${data_transfer_dl}     duration=15000
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=8m    check_source=Aasyslog
    ${list_of_cell_ids}    Create list    43810917
    power_ue.Check Tput     ue_type=${ue_type}     direction=ul     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${Expected_Throughput_UL}    check_source=Aasyslog
    power_ue.Check Tput     ue_type=${ue_type}     direction=dl     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${Expected_Throughput_DL}    check_source=Aasyslog
    Disable or enable port by TPS switch and check port for 5740
    Disable or enable port by TPS switch and check port for 5740
    Disable or enable port by TPS switch and check port for 5740
    sleep    10min
    ${tput_log_newport}    power_ue.Collect Tput    ue_type=${ue_type}    duration=8m    check_source=Aasyslog
    ${list_of_cell_ids_newport}    Create list    43810917
    power_ue.Check Tput     ue_type=${ue_type}     direction=ul     cells=${list_of_cell_ids_newport}    log=${tput_log_newport}
    ...                     target_throughput=${Expected_Throughput_UL}    check_source=Aasyslog
    power_ue.Check Tput     ue_type=${ue_type}     direction=dl     cells=${list_of_cell_ids_newport}    log=${tput_log_newport}
    ...                     target_throughput=${Expected_Throughput_DL}    check_source=Aasyslog
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Disable or enable port by TPS switch and check port for 5740
    Disable or enable port1 by TPS switch and check port for 5740
    Disable or enable port2 by TPS switch and check port for 5740
    Disable or enable port3 by TPS switch and check port for 5740
    Disable or enable port4 by TPS switch and check port for 5740

Disable or enable port1 by TPS switch and check port for 5740
    Disable or enable port    cmd=${port1_down_cmd_TPS2}   switch_ip=${tl.optical_switches[0].addr}
    Run Keyword And Continue On Failure    Check status and port used for 5740    PortNumber=1
    ...                                                                           is_or_not_used=not used
    ...                                                                           ClockState=MASTER_CLOCK_DISABLED
    ...                                                                           index_num=${0}
    Run Keyword And Continue On Failure    Check status and port used for 5740    PortNumber=2
    ...                                                                           is_or_not_used=not used
    ...                                                                           ClockState=MASTER_CLOCK_OK
    ...                                                                           index_num=${1}
    Run Keyword And Continue On Failure    Check status and port used for 5740    PortNumber=3
    ...                                                                           is_or_not_used=used
    ...                                                                           ClockState=MASTER_CLOCK_OK
    ...                                                                           index_num=${2}
    Run Keyword And Continue On Failure    Check status and port used for 5740    PortNumber=4
    ...                                                                           is_or_not_used=not used
    ...                                                                           ClockState=MASTER_CLOCK_OK
    ...                                                                           index_num=${3}
    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Check expect alarm exist     expect_alarm=${61631}
    Run Keyword And Continue On Failure    Check expect faultName for 5740    state=${1}
    Disable or enable port    cmd=${port1_up_cmd_TPS2}   switch_ip=${tl.optical_switches[0].addr}

Disable or enable port2 by TPS switch and check port for 5740
    Disable or enable port    cmd=${port2_down_cmd_TPS2}   switch_ip=${tl.optical_switches[0].addr}
    Run Keyword And Continue On Failure    Check status and port used for 5740    PortNumber=1
    ...                                                                           is_or_not_used=not used
    ...                                                                           ClockState=MASTER_CLOCK_OK
    ...                                                                           index_num=${0}
    Run Keyword And Continue On Failure    Check status and port used for 5740    PortNumber=2
    ...                                                                           is_or_not_used=not used
    ...                                                                           ClockState=MASTER_CLOCK_DISABLED
    ...                                                                           index_num=${1}
    Run Keyword And Continue On Failure    Check status and port used for 5740    PortNumber=3
    ...                                                                           is_or_not_used=used
    ...                                                                           ClockState=MASTER_CLOCK_OK
    ...                                                                           index_num=${2}
    Run Keyword And Continue On Failure    Check status and port used for 5740    PortNumber=4
    ...                                                                           is_or_not_used=not used
    ...                                                                           ClockState=MASTER_CLOCK_OK
    ...                                                                           index_num=${3}
    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Check expect alarm exist     expect_alarm=${61631}
    Run Keyword And Continue On Failure    Check expect faultName for 5740    state=${2}
    Disable or enable port    cmd=${port2_up_cmd_TPS2}   switch_ip=${tl.optical_switches[0].addr}

Disable or enable port3 by TPS switch and check port for 5740
    Disable or enable port    cmd=${port3_down_cmd_TPS2}   switch_ip=${tl.optical_switches[0].addr}
    Run Keyword And Continue On Failure    Check status and port used for 5740    PortNumber=1
    ...                                                                           is_or_not_used=not used
    ...                                                                           ClockState=MASTER_CLOCK_OK
    ...                                                                           index_num=${0}
    Run Keyword And Continue On Failure    Check status and port used for 5740    PortNumber=2
    ...                                                                           is_or_not_used=not used
    ...                                                                           ClockState=MASTER_CLOCK_OK
    ...                                                                           index_num=${1}
    Run Keyword And Continue On Failure    Check status and port used for 5740    PortNumber=3
    ...                                                                           is_or_not_used=not used
    ...                                                                           ClockState=MASTER_CLOCK_DISABLED
    ...                                                                           index_num=${2}
    Run Keyword And Continue On Failure    Check status and port used for 5740    PortNumber=4
    ...                                                                           is_or_not_used=used
    ...                                                                           ClockState=MASTER_CLOCK_OK
    ...                                                                           index_num=${3}
    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Check expect alarm exist     expect_alarm=${61631}
    Run Keyword And Continue On Failure    Check expect faultName for 5740    state=${3}
    Disable or enable port    cmd=${port3_up_cmd_TPS2}   switch_ip=${tl.optical_switches[0].addr}

Disable or enable port4 by TPS switch and check port for 5740
    Disable or enable port    cmd=${port4_down_cmd_TPS3}   switch_ip=${tl.optical_switches[0].addr}
    Run Keyword And Continue On Failure    Check status and port used for 5740    PortNumber=1
    ...                                                                           is_or_not_used=not used
    ...                                                                           ClockState=MASTER_CLOCK_OK
    ...                                                                           index_num=${0}
    Run Keyword And Continue On Failure    Check status and port used for 5740    PortNumber=2
    ...                                                                           is_or_not_used=not used
    ...                                                                           ClockState=MASTER_CLOCK_OK
    ...                                                                           index_num=${1}
    Run Keyword And Continue On Failure    Check status and port used for 5740    PortNumber=3
    ...                                                                           is_or_not_used=used
    ...                                                                           ClockState=MASTER_CLOCK_OK
    ...                                                                           index_num=${2}
    Run Keyword And Continue On Failure    Check status and port used for 5740    PortNumber=4
    ...                                                                           is_or_not_used=not used
    ...                                                                           ClockState=MASTER_CLOCK_DISABLED
    ...                                                                           index_num=${3}
    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Check expect alarm exist     expect_alarm=${61631}
    Run Keyword And Continue On Failure    Check expect faultName for 5740    state=${4}
    Disable or enable port    cmd=${port4_up_cmd_TPS3}   switch_ip=${tl.optical_switches[0].addr}

Check expect faultName for 5740
    [Arguments]    ${state}    ${connection}=GNB_OAM
    ${active_alarms_list}    coam.get_active_alarms    connection=${connection}
    ${exist_alarms_faultName}    Create List
    FOR  ${alarm}  IN  @{active_alarms_list}
       Append To List     ${exist_alarms_faultName}     ${alarm['faultName']}
    END
    Run Keyword If    ${state}==${1}
    ...          Should Contain        ${exist_alarms_faultName}     ToP master service RU eCPRI port #1 unusable
    Run Keyword If    ${state}==${2}
    ...          Should Contain        ${exist_alarms_faultName}     ToP master service RU eCPRI port #2 unusable
    Run Keyword If    ${state}==${3}
    ...          Should Contain        ${exist_alarms_faultName}     ToP master service RU eCPRI port #3 unusable
    Run Keyword If    ${state}==${4}
    ...          Should Contain        ${exist_alarms_faultName}     ToP master service RU eCPRI port #4 unusable

get expect faultName for 5740
    [Arguments]    ${connection}=GNB_OAM
    ${active_alarms_list}    coam.get_active_alarms    connection=${connection}
    ${exist_alarms_faultName}    Create List
    FOR  ${alarm}  IN  @{active_alarms_list}
       Append To List     ${exist_alarms_faultName}     ${alarm['faultName']}
    END
    Log to console       ${exist_alarms_faultName}

Check alarms when change TPS switch for 5740
    Connect to gnb coam via ssl
    Disable or enable port    cmd=${port1_down_cmd_TPS2}   switch_ip=${tl.optical_switches[0].addr}
    Disable or enable port    cmd=${port2_down_cmd_TPS2}   switch_ip=${tl.optical_switches[0].addr}
    Disable or enable port    cmd=${port4_down_cmd_TPS3}   switch_ip=${tl.optical_switches[0].addr}
    Disable or enable port    cmd=${port3_down_cmd_TPS2}   switch_ip=${tl.optical_switches[0].addr}
    Sleep    3s
    Check expect alarm exist     expect_alarm=${61631}
    get expect faultName for 5740
    Sleep    30s
    Check expect alarm exist     expect_alarm=${16}
    Check expect alarm exist     expect_alarm=${4298}
    Check expect alarm not exist      expect_alarm=${61631}

Recover by enable port and check alarms for 5740
    Connect to gnb coam via ssl
    Disable or enable port    cmd=${port3_up_cmd_TPS2}   switch_ip=${tl.optical_switches[0].addr}
    Disable or enable port    cmd=${port1_up_cmd_TPS2}   switch_ip=${tl.optical_switches[0].addr}
    Disable or enable port    cmd=${port2_up_cmd_TPS2}   switch_ip=${tl.optical_switches[0].addr}
    Disable or enable port    cmd=${port4_up_cmd_TPS3}   switch_ip=${tl.optical_switches[0].addr}
    Sleep    40s
    Check all expect alarms recover

Start DLUL traffic and Caculate Tput when change Priority
    [Arguments]     ${data_transfer_dl}     ${data_transfer_ul}     ${Expected_Throughput_DL}     ${Expected_Throughput_UL}
    power_ue.Prepare UE     ue_type=${ue_type}    ui_version=default
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}
    Run keyword and ignore error    power_ue.Verify attach     ue_type=${ue_type}     4G_check=False     5Grach_ed=${5Grach_ed}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${data_transfer_ul}     duration=3600
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${data_transfer_dl}     duration=3600
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=8m
    ${list_of_cell_ids}    Create list    43810917
    power_ue.Check Tput     ue_type=${ue_type}     direction=ul     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${Expected_Throughput_UL}
    power_ue.Check Tput     ue_type=${ue_type}     direction=dl     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${Expected_Throughput_DL}
    Configuration paramter for 5740    param_data=${PARAM_5740_STRUCTURE3[0]}    index_num=${0}
    sleep    10min
    ${tput_log_new_priority}    power_ue.Collect Tput    ue_type=${ue_type}    duration=8m
    ${list_of_cell_ids_priority}    Create list    43810917
    power_ue.Check Tput     ue_type=${ue_type}     direction=ul     cells=${list_of_cell_ids_priority}    log=${tput_log_new_priority}
    ...                     target_throughput=${Expected_Throughput_UL}
    power_ue.Check Tput     ue_type=${ue_type}     direction=dl     cells=${list_of_cell_ids_priority}    log=${tput_log_new_priority}
    ...                     target_throughput=${Expected_Throughput_DL}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul

Configuration paramter for 5740
    [Arguments]   ${param_data}    ${index_num}   ${is_need_to_check_validation_errors}=${True}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    Coam Input Parameter value via webUI   param_data=${param_data}
    ...                                    node_index=${index_num}
    selenium_coam.validate_plan
    COAM check validation errors from webui    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    COAM selenium logout

Check ClockState used and Port when external
    [Arguments]
    Check ClockState and MaterUsed      ok_num_expect=${4}   index_begin=${0}   index_end=${4}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    @{used_list}=    Create List
    ${topMasterUsed_port3}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_5740[1]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_5740[1]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_5740[1]}[abbr]
    ...                                            node_index=${2}
    Append To List       ${used_list}        ${topMasterUsed_port3}
    ${topMasterUsed_port4}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_5740[1]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_5740[1]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_5740[1]}[abbr]
    ...                                            node_index=${3}
    Append To List       ${used_list}        ${topMasterUsed_port4}
    ${used_num}      Get Count      ${used_list}      used
    Should Be Equal         ${used_num}        ${1}
    COAM selenium logout

Check ClockState used and Port when 2.048MHZ
    [Arguments]
    Check ClockState and MaterUsed      ok_num_expect=${2}   index_begin=${0}   index_end=${4}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    @{used_list}=    Create List
    ${topMasterUsed_port1}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_5740[1]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_5740[1]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_5740[1]}[abbr]
    ...                                            node_index=${0}
    Append To List       ${used_list}        ${topMasterUsed_port1}
    ${topMasterUsed_port2}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_5740[1]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_5740[1]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_5740[1]}[abbr]
    ...                                            node_index=${1}
    Append To List       ${used_list}        ${topMasterUsed_port2}
    ${used_num}      Get Count      ${used_list}      used
    Should Be Equal         ${used_num}        ${1}
    ${topMasterClockState_port3}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_5740[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_5740[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_5740[0]}[abbr]
    ...                                            node_index=${2}
    Should Be Equal     ${topMasterClockState_port3}      MASTER_CLOCK_NOT_OK
    ${topMasterClockState_port4}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_5740[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_5740[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_5740[0]}[abbr]
    ...                                            node_index=${3}
    Should Be Equal     ${topMasterClockState_port4}      MASTER_CLOCK_NOT_OK
    COAM selenium logout

Check expect alarm exist
    [Arguments]    ${expect_alarm}    ${connection}=GNB_OAM
    ${active_alarms_list}    coam.get_active_alarms    connection=${connection}
    ${exist_alarms}    Create List
    FOR  ${alarm}  IN  @{active_alarms_list}
       Append To List    ${exist_alarms}   ${alarm['faultId']}
    END
    Should Contain        ${exist_alarms}     ${expect_alarm}

Check expect faultName
    [Arguments]    ${connection}=GNB_OAM
    ${active_alarms_list}    coam.get_active_alarms    connection=${connection}
    ${exist_alarms_faultName}    Create List
    FOR  ${alarm}  IN  @{active_alarms_list}
       Append To List     ${exist_alarms_faultName}     ${alarm['faultName']}
    END
    Should Contain        ${exist_alarms_faultName}     ToP master service RU eCPRI port #3 unusable
    Should Contain        ${exist_alarms_faultName}     ToP master service RU eCPRI port #4 unusable

Check loss sync
    Connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${PARAM_5740_ACCEPTEDCLOCKCLASS_6}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${PARAM_5740_SYNCIN_2048}
    sleep    30s
    Check expect alarm exist     expect_alarm=${4298}
    Run Keyword And Ignore Error         COAM Update several parameters via rest api    parameters_to_update_via_api=${PARAM_5740_SYNCIN_EXTERNAL}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${PARAM_5740_ACCEPTEDCLOCKCLASS}
    sleep    5min

Reboot cpe for test
    [Arguments]    ${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=True
