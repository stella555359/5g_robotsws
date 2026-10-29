*** Settings ***
Documentation     author: y63li
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: ying.15.li@nokia-sbell.com

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
#Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/siso_resource.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002056-BGAN/Resources/Prepare_IWK_TestLine.robot
Library           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/get_bts_info.py   WITH NAME    lib
Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library           taf.transport.ssh    WITH NAME    csn
Library           OperatingSystem
Library           Collections
Library           taf.pdu
Library           String
Library           Process
Library           taf.pdu    WITH NAME    pdu
Library           DateTime
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB006443/Resources/All_KW_Interface.robot


*** Variables ***
${DU_OAM_IP}            ${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.addr}
${CU_OAM_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${bts_ssh_u}     ${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.username}
${bts_ssh_p}     ${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.password}
${WEBUI_URL}        https://${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.addr}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${mrbtsId}          ${tl.gnbs[0].instance_id}
${nrbtsId}       ${tl.gnbs[0].global_bts_id}
${dist_name}    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
${scf_name}    scf_CB007582.xml
${tmp_log_dir}    /home/ute/log
${testline}  7_5_UTE5G402T919
${alarm_filter}   Cell problem due to unavailability of associated links
#@{SCF_IWK}                      SCF_IWK_Trunk.xml
#${SCF_IWK_Trunk}                commissionings/HGZ/7_5_UTE5G402T926/SCF_IWK/
#${SCF_IWK_Trunk}                ${commissionings_path}/HGZ/${testline_name}/SCF_IWK/
@{allow_fault_list}    7107    7305    7308    7304    4282    7101    7330

*** Keywords ***

CB007582.Common Suite Setup
    Set Global Variable    ${trunk_rolll_needed}    ${False}
    Run Keyword And Ignore Error    robot_common_operations.Common Suite Setup
    Run Keyword And Ignore Error    CI_interface.Common Suite Setup
    Set Suite Variable    ${TS_LOG_PATH_BASE}    ${tmp_log_dir}
    COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${tmp_log_dir}    ${LOG_PATH}/${time_stamp}
    Create directory    ${tmp_log_dir}
    ${mrbtsId}    Set variable    ${tl.gnbs[0].instance_id}
    ${nrbtsId}    Set variable    ${tl.gnbs[0].global_bts_id}
    ${connection}    Connect to gnb coam via ssl by gnb index    gnb_index=${0}
    admin_cli.get_current_scf_file    local_dir_path=${tmp_log_dir}    file_name=${scf_name}    connection=${connection}
    ${commission_file}    set variable    ${tmp_log_dir}/${scf_name}
    ${BTS_NAME}   lib.Get_BTS_name    scf_path=${commission_file}
    Set Suite Variable     ${dist_name}    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    Set Suite Variable     ${commission_file}
    Set Suite Variable     ${BTS_NAME}
    Run Keyword And Ignore Error    Prepare IWK testline to cell onair
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

CB007582.Common Suite Teardown
    Run Keyword And Ignore Error    Prepare IWK testline to cell onair
    Run Keyword And Ignore Error    AdminCli disconnection and Test teardown
    Run Keyword And Ignore Error    robot_common_operations.Common Suite teardown

CB007582.Case Setup
    Log To Console    \n *** Case Setup
    Run Keyword And Ignore Error    robot_common_operations.Common Case Setup
    Run Keyword And Ignore Error      AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    wait until keyword succeeds    5min    10s     COAM Wait for gnb ready and cell setup

Check X2 Status_Dropped
    Log To Console     \n *** Check X2 Status
    ${connection}    Connect to gnb coam via ssl by gnb index    gnb_index=${0}
    ${X2linkstatus}    selenium_coam.get_parameter_value    dist_name=${dist_name}/LTEENB-0
    ...    filter_param=X2C link status
    Should be equal    ${X2linkstatus}    available

Check X2 Status
    Log To Console     \n *** Check X2 Status
    @{parameterList}    Create List     x2LinkStatus
    ${connection}    Connect to gnb coam via ssl by gnb index    gnb_index=${0}
    ${X2linkstatus}    admin_cli.get_parameter_value    dist_name=${dist_name}/LTEENB-0
    ...    parameterList=${parameterList}
    set suite variable    ${X2linkstatus}
    [Return]    ${X2linkstatus}
    [Teardown]     admin_cli.teardown    connection=${connection}

Check parameter value
    [Arguments]  ${dist_name}    ${parameterList}     ${gnb_index}=${0}
    Log To Console     \n *** Check parameter value
    ${connection}    Connect to gnb coam via ssl by gnb index    gnb_index=${gnb_index}
    ${parameter_value}    admin_cli.get_parameter_by_distname   dist_name=${dist_name}
    ...    parameter_list=${parameterList}      connection=${connection}
    set suite variable    ${parameter_value}
    [Return]    ${parameter_value}
    [Teardown]     admin_cli.teardown    connection=${connection}

AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    admin_cli.teardown    connection=${connection}

CB007582.Case Teardown
    Log To Console    \n *** Case Teardown
    [Arguments]  ${cell_idx}
    Run Keyword And Ignore Error	wait until keyword succeeds     8min    30s
    ...      Perform X2 link update   value=unlocked
	Run Keyword And Ignore Error    wait until keyword succeeds    8min    30s
	...      Perform NG link update    value=Unlocked
	Run Keyword And Ignore Error      wait until keyword succeeds    8min    30s
	...      Perform NG-U link update   value=Unlocked
    Run Keyword And Ignore Error    Unlock cell    cell_idx=${cell_idx}
    Run Keyword And Ignore Error    admin_cli.teardown    connection=${connection}
    Run Keyword And Ignore Error    wait until keyword succeeds    8min    30s
    ...      Configure nsaCellActivationAlarmTimer to 600
    Run Keyword And Ignore Error    wait until keyword succeeds    8min    30s
    ...      Configure saCellActivationAlarmTimer to 600
    Run Keyword And Ignore Error    wait until keyword succeeds    8min    30s
    ...      Configure ngInducedCellDeactDelayTimer to 1800
    Run Keyword And Ignore Error      AlarmWatchdog.remove_allow_alarms       fault_id=${allow_fault_list}
    Run Keyword And Ignore Error     robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown

Disconnect from cOAM
    [Arguments]  ${connection}=cOAM_serviceuser
    ssh.disconnect  ${connection}


Configure ${parameter} to ${value}
    Log    \n****Configure ${parameter} to ${value}   console=yes
    ${connection}    Connect to gnb coam via ssl by gnb index    gnb_index=${0}
    admin_cli.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    ...    connection=${connection}
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Perform NG link update
    Log    \n****Modify NG link to ${value}   console=yes
    [Arguments]    ${value}     ${timeout}=600      ${gnb_index}=0
    ${connection}    Connect to gnb coam via ssl by gnb index    gnb_index=${gnb_index}
    admin_cli.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}/SERVEDAMF-1
    ...    parameter=administrativeState
    ...    value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    ...    connection=${connection}
    ...    timeout=${timeout}
    [Teardown]     Run keyword and ignore error
    ...     COAM Teardown gnb connections    connection=${connection}

Perform NG-U link update
    Log    \n****Modify NG link to ${value}   console=yes
    [Arguments]    ${value}     ${gnb_index}=0
    ${connection}    Connect to gnb coam via ssl by gnb index    gnb_index=${gnb_index}
    admin_cli.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}/SNSSAI-1
    ...    parameter=administrativeState
    ...    value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    ...    connection=${connection}
    [Teardown]     Run keyword and ignore error
    ...     COAM Teardown gnb connections    connection=${connection}

Perform X2 link update
    Log    \n****Modify X2 link to ${value}    console=yes
    [Arguments]    ${value}     ${timeout}=600      ${gnb_index}=0
    ${connection}    Connect to gnb coam via ssl by gnb index    gnb_index=${gnb_index}
    admin_cli.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}/LTEENB-0
    ...    parameter=x2LinkLock
    ...    value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    ...    connection=${connection}
    ...    timeout=${timeout}
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check Fault and cell State
    Log    \n****Check Fault and cell State   console=yes
    [Arguments]    ${severity}    ${operational}    ${availability}    ${cell_idx}
    Check fault report    severity=${severity}    cell_idx=${cell_idx}
    Check cell state    operational=${operational}    availability=${availability}    cell_idx=${cell_idx}


Check fault report
    Log    \n****Check fault report    console=yes
    [Arguments]    ${severity}    ${cell_idx}
    ${connection}    wait until keyword succeeds     5min    1min
    ...     Connect to gnb coam via ssl by gnb index    gnb_index=${0}
    ${active_alarms_list}        wait until keyword succeeds
    ...      5min    5s      admin_cli.get_active_alarms      connection=${connection}
    ${7107_flag}     Set Variable     False
    ${cell_dist}     Set Variable     MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_idx}
    ${cell_7107}     Set Variable     False
    ${7107_num}      Set Variable     0
    set suite variable    ${7107_num}
    set suite variable    ${7107_flag}
    FOR    ${alarm}    IN    @{active_alarms_list}
        ${cell_7107}      Run Keyword And Return Status
        ...      Should Contain     ${alarm["configObjectName"]}      ${cell_dist}
        ${7107_flag}=  Set Variable If  "${alarm["additionalFaultID"]}"=="7107" and "${cell_7107}"=="True"  True  False
        set suite variable    ${7107_flag}
        ${alarmName}    Set Variable    CELL SERVICE PROBLEM
        Run Keyword If    "${7107_flag}"=="True"
        ...      Run Keywords      Run Keyword and Continue on Failure
        ...      Should Be True     ${alarm["alarmId"]}     7114
        ...      AND      Run Keyword and Continue on Failure
        ...      Should be equal as strings     ${alarm["alarmName"]}     ${alarmName}
        ...      ignore_case=True
        ...      AND      Run Keyword and Continue on Failure
        ...      Should be equal as strings      ${alarm["severity"]}     ${severity}
        ...      ignore_case=True
        ...      AND      Run Keyword and Continue on Failure
        ...      Should be equal as strings      ${alarm["alarmDetail"]}     ${alarm_filter}
        ...      ignore_case=True
        ${7107_num}      Run Keyword If      "${7107_flag}"=="True"     Evaluate    ${7107_num}+1
        ...    ELSE      Evaluate    ${7107_num}+0
        set suite variable    ${7107_num}
    END
    Run Keyword and Continue on Failure
    ...       Should be equal as strings      ${7107_num}      1
    [Teardown]     admin_cli.teardown    connection=${connection}


Check cell state
    Log    \n****Check cell state    console=yes
    [Arguments]    ${operational}     ${availability}=None    ${cell_idx}=${1}
    ${connection}    Connect to gnb coam via ssl by gnb index    gnb_index=${0}
    ${cell_info}    coam.get_cell_specific_info   cell_id=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_idx}    connection=${connection}
    log to console    parameter availability ${availability} is not used
    ${cell_operational_status}    Set variable  ${cell_info['status']['operationalState']}
    Should be equal as strings    ${cell_operational_status}    ${operational}
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    [Return]        ${cell_operational_status}

TL926.reset_cell
    Log    \n****reset cell    console=yes
    [Arguments]        ${timeout}=600
    ${connection}    Connect to gnb coam via ssl by gnb index    gnb_index=${0}
    RUN KEYWORD AND CONTINUE ON FAILURE      coam.reset_all_cells
    ...      technology=NR    timeout=${timeout}   connection=${connection}
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}


TL926.wait_cell_energySavingState
    [Arguments]    ${energySavingState}
    ...        ${retry_times}=160     ${expected_num}=${1}
    log to console     wait_cell_energySavingState
    ${connection}    Connect to gnb coam via ssl by gnb index    gnb_index=${0}
    DU_WebEM.Get NR Cell distname and id      connection=${connection}
    FOR    ${i}    IN RANGE    ${retry_times}
          sleep      2s
         ${cell_energySavingState_list}      TL926.get_all_cell_status
         ...      cell_id_list=${cell_id_list}    connection=${connection}
         ${expected_flag}      TL926.check_cell_status_is_expected
         ...      cell_status_list=${cell_energySavingState_list}
         ...      expected_status=${energySavingState}
         Exit for loop if       '${expected_flag}'>='${expected_num}'
    END
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    [Return]    ${expected_flag}

TL926.wait_for_X2_status
    [Arguments]    ${expected_x2_status}       ${LTE_id}=${0}
    ...         ${retry_times}=120
    Log To Console     \n *** Check X2 Status
    @{parameterList}    Create List     x2LinkStatus
    ${connection}    Connect to gnb coam via ssl by gnb index    gnb_index=${0}
    FOR    ${i}    IN RANGE    ${retry_times}
         ${X2linkstatus}    admin_cli.get_parameter_by_class   class_name=${dist_name}/LTEENB-${LTE_id}
         ...    parameter_list=@{parameterList}
         ...    connection=${connection}
         set suite variable    ${X2linkstatus}
         sleep       5s
         Exit for loop if       '${X2linkstatus}'=='${expected_x2_status}'
    END
    Log To Console     \n *** X2 Status is ${X2linkstatus}
    [Return]    ${X2linkstatus}
    [Teardown]     admin_cli.teardown    connection=${connection}

TL926.get_all_cell_status
    [Arguments]     ${cell_id_list}     ${connection}
    log to console     get all cell status
    ${cell_energySavingState_list}     create list
    FOR    ${cell_id}    IN    @{cell_id_list}
         ${cell_info}    RUN KEYWORD AND CONTINUE ON FAILURE     coam.get_cell_specific_info
         ...     cell_id=${cell_id['internal']}      connection=${connection}
         ${cell_energySavingState}    Set variable  ${cell_info['energySavingState']}
         Append To List    ${cell_energySavingState_list}    ${cell_energySavingState}
         sleep     2s
    END
    [Return]    ${cell_energySavingState_list}


TL926.check_cell_status_is_expected
    [Arguments]     ${cell_status_list}    ${expected_status}
    log to console     check_cell_status_is_expected
    ${expected_flag}    Set variable      ${0}
    FOR    ${cell_status}    IN       @{cell_status_list}
          log to console      cell status is ${cell_status}
          ${expected_flag}        Run Keyword If      '${cell_status}'=='${expected_status}'
          ...    Evaluate    ${expected_flag}+${1}
          ...    ELSE      Set variable       ${expected_flag}
    END
    [Return]    ${expected_flag}

TL926.CB007582_IWK_with_energySaving
     [Arguments]      ${expected_num}=${1}
     Run Keyword And Ignore Error       Configure ngInducedCellDeactDelayTimer to 1800
     TL926.reset_cell    timeout=600
     ${onair_status}      Run Keyword And Return Status      Check all cells Should Be On Air
	...       wait_time=6min
    log to console     after reset cell cell_operational_status is ${onair_status}
     #TL926.wait_for_X2_status     expected_x2_status=available      LTE_id=${LTE_id}
     ${cell_energySavingState}       TL926.wait_cell_energySavingState
     ...     energySavingState=switchingOff      expected_num=${expected_num}
     log to console     cell_energySavingState is ${cell_energySavingState}
     ${wait_time}=    Evaluate    random.randint(1, 15)    random
     sleep       ${wait_time}s
     Run Keyword If
    ...      '${cell_energySavingState}'>='${expected_num}'
    ...      TL926.trigger_both_link_unstable
    log to console     end trigger_both_link_unstable
    ${cell_energySavingState}        TL926.wait_cell_energySavingState
     ...     energySavingState=energySaving       expected_num=${expected_num}
     ...     retry_times=200
    RUN KEYWORD AND CONTINUE ON FAILURE      Should be true   ${cell_energySavingState} >= ${expected_num}
    sleep      10s
     log to console     reset cell start
     Run keyword and ignore error        TL926.reset_cell    timeout=180
     ${onair_status}      Run Keyword And Return Status      Check all cells Should Be On Air
	...       wait_time=6min
	 Run keyword and ignore error        TL926.reset_cell    timeout=5
     log to console     start trigger_both_link_unstable
     RUN KEYWORD AND CONTINUE ON FAILURE      TL926.trigger_both_link_unstable
     ...     retry_times=5
	${onair_status}      Run Keyword And Return Status      Check all cells Should Be On Air
	...       wait_time=6min
    log to console     cell_operational_status is ${onair_status}
     RUN KEYWORD AND CONTINUE ON FAILURE
     ...      Should be equal as strings    ${onair_status}    True
    [Teardown]    Run Keyword and Ignore Error      TL926.recovery_link


TL926.CB007582_IWK_with_energySaving_loop
    [Arguments]    ${retry_times}=1
    log to console     commission SCF with energy saving and both cell
    Prepare IWK testline to cell onair      file_index=${1}
    FOR    ${i}    IN RANGE    ${retry_times}
        BtsLog.StartBTSlogCollection
        ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
        ${referrence_time}      convert date    ${timestamp_log}    epoch
        ${IWK_status}       Run Keyword And Return Status      TL926.CB007582_IWK_with_energySaving
        log to console   IWK_status is ${IWK_status}
        ${snapshot_file}    Run Keyword If    '${IWK_status}'=='False'
        #${snapshot_file}        RUN KEYWORD AND CONTINUE ON FAILURE
        ...      wait until keyword succeeds   2x   1min    WEBUI.Collect snapshot
        ...      timeout=${3600}
        ${BTS_syslog}       Run Keyword And Ignore error
         ...      Stop BTSlogs Collection and get logs for every loop    loop=${timestamp_log}
        RUN KEYWORD AND CONTINUE ON FAILURE
        ...      Should be equal as strings    ${IWK_status}    True
    END
    log to console     commission SCF with energy saving and NSA cell
    Prepare IWK testline to cell onair      file_index=${2}
    FOR    ${i}    IN RANGE    ${retry_times}
        BtsLog.StartBTSlogCollection
        ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
        ${referrence_time}      convert date    ${timestamp_log}    epoch
        ${IWK_status}       Run Keyword And Return Status      TL926.CB007582_IWK_with_energySaving
        log to console   IWK_status is ${IWK_status}
        ${snapshot_file}    Run Keyword If    '${IWK_status}'=='False'
        #${snapshot_file}        RUN KEYWORD AND CONTINUE ON FAILURE
        ...      wait until keyword succeeds   2x   1min    WEBUI.Collect snapshot
        ...      timeout=${3600}
        ${BTS_syslog}       Run Keyword And Ignore error
         ...      Stop BTSlogs Collection and get logs for every loop    loop=${timestamp_log}
        RUN KEYWORD AND CONTINUE ON FAILURE
        ...      Should be equal as strings    ${IWK_status}    True
    END
    log to console     commission SCF with energy saving and SA cell
    Prepare IWK testline to cell onair      file_index=${3}
    FOR    ${i}    IN RANGE    ${retry_times}
        BtsLog.StartBTSlogCollection
        ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
        ${referrence_time}      convert date    ${timestamp_log}    epoch
        ${IWK_status}       Run Keyword And Return Status      TL926.CB007582_IWK_with_energySaving
        log to console   IWK_status is ${IWK_status}
        ${snapshot_file}    Run Keyword If    '${IWK_status}'=='False'
        #${snapshot_file}        RUN KEYWORD AND CONTINUE ON FAILURE
        ...      wait until keyword succeeds   2x   1min    WEBUI.Collect snapshot
        ...      timeout=${3600}
        ${BTS_syslog}       Run Keyword And Ignore error
         ...      Stop BTSlogs Collection and get logs for every loop    loop=${timestamp_log}
        RUN KEYWORD AND CONTINUE ON FAILURE
        ...      Should be equal as strings    ${IWK_status}    True
    END
    [Teardown]    RUN KEYWORD AND CONTINUE ON FAILURE      Prepare IWK testline to cell onair
     ...      file_index=${0}

TL926.trigger_both_link_unstable
    [Arguments]    ${server_IP}=${DU_OAM_IP}       ${server_user}=${bts_ssh_u}
    ...      ${server_password}=${bts_ssh_p}
    ...      ${retry_times}=10
    csn.Connect to    hostname=${server_IP}    username=${server_user}    password=${server_password}      alias=server
    FOR    ${i}    IN RANGE    ${retry_times}
          csn.Execute    command=ip route add blackhole 10.101.51.164/32
          ...    connection=server
          csn.Execute    command=ip route add blackhole 10.71.209.100/32
          ...    connection=server
          csn.Execute    command=ip route add blackhole 10.110.133.68/32
          ...    connection=server
          csn.Execute    command=ip route add blackhole 10.110.133.102/32
          ...    connection=server
         ${wait_time}=    Evaluate    random.randint(5, 18)    random
         log to console     broken both link and sleep ${wait_time}
         sleep      ${wait_time}s
          csn.Execute    command=ip route del blackhole 10.101.51.164/32
          ...    connection=server
          csn.Execute    command=ip route del blackhole 10.71.209.100/32
          ...    connection=server
          csn.Execute    command=ip route del blackhole 10.110.133.68/32
          ...    connection=server
          csn.Execute    command=ip route del blackhole 10.110.133.102/32
          ...    connection=server
         ${wait_time1}=    Evaluate    random.randint(3, 10)    random
         sleep      ${wait_time1}s
         log to console     recovery both link and sleep ${wait_time}
    END
    [Teardown]      Run Keyword and Ignore Error      csn.Disconnect     connection=server


TL926.trigger_NSA_link_unstable
    [Arguments]    ${server_IP}=${DU_OAM_IP}       ${server_user}=${bts_ssh_u}
    ...      ${server_password}=${bts_ssh_p}
    ...      ${retry_times}=10
    csn.Connect to    hostname=${server_IP}    username=${server_user}    password=${server_password}     alias=server
    FOR    ${i}    IN RANGE    ${retry_times}
          csn.Execute    command=ip route add blackhole 10.101.51.164/32
          ...    connection=server
         ${wait_time}=    Evaluate    random.randint(5, 20)    random
         sleep      ${wait_time}s
          csn.Execute    command=ip route del blackhole 10.101.51.164/32
          ...    connection=server
         ${wait_time1}=    Evaluate    random.randint(2, 9)    random
         sleep      ${wait_time1}s
    END
    [Teardown]      Run Keyword and Ignore Error      csn.Disconnect     connection=server


TL926.recovery_link
    [Arguments]    ${server_IP}=${DU_OAM_IP}       ${server_user}=${bts_ssh_u}
    ...      ${server_password}=${bts_ssh_p}
    log to console     case end, recovery both link
    csn.Connect to    hostname=${server_IP}    username=${server_user}     password=${server_password}    alias=server
    csn.Execute    command=ip route del blackhole 10.101.51.164/32
    ...    connection=server
    csn.Execute    command=ip route del blackhole 10.71.209.100/32
    ...    connection=server
    csn.Execute    command=ip route del blackhole 10.110.133.68/32
    ...    connection=server
    csn.Execute    command=ip route del blackhole 10.110.133.102/32
    ...    connection=server
    [Teardown]      Run Keyword and Ignore Error      csn.Disconnect     connection=server

Check fault clear
    Log    \n****Check fault7107 Cancelled on WebEM    console=yes
    [Arguments]    ${cell_idx}=${1}
    ${connection}     wait until keyword succeeds    10min    20s
    ...     Connect to gnb coam via ssl by gnb index    gnb_index=${0}
    ${active_alarms_list}        wait until keyword succeeds
    ...      5min    5s      admin_cli.get_active_alarms      connection=${connection}
    ${7107_flag}     Set Variable     False
    ${cell_dist}     Set Variable     MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_idx}
    FOR    ${alarm}    IN    @{active_alarms_list}
        ${7107_flag}     Run Keyword If      "${alarm["additionalFaultID"]}"=="7107"
        ...      Set Variable     True
        ...      ELSE     Set Variable     False
    END
    Run Keyword and Continue on Failure      Should be equal as strings    ${7107_flag}     False
    [Teardown]     Run keyword and ignore error      admin_cli.teardown    connection=${connection}

Check No Other Fault Raise
    Log    \nCheck No Other Fault Raise    console=yes
    Recored Current Active Alarm
    Check No New Active Alarm Exist

Recored Current Active Alarm
    Log    \n****Recored Current Active Alarm   console=yes
    ${connection}    Connect to gnb coam via ssl by gnb index    gnb_index=${0}
    @{alarm_list_details}    admin_cli.get_active_alarms    connection=${connection}
    ${alarm_length}    admin_cli.get_active_alarms_number    connection=${connection}
    @{alarm_ID_list}    Create List
    FOR    ${alarm}    IN    @{alarm_list_details}
        Append To List    ${alarm_ID_list}    ${alarm["alarmId"]}
    END
    set suite variable    @{alarm_ID_list}
    set suite variable    ${alarm_length}
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check No New Active Alarm Exist
    Log    \n****Check No New Active Alarm Exist   console=yes
    ${connection}    Connect to gnb coam via ssl by gnb index    gnb_index=${0}
    ${current_alarm_length}    admin_cli.get_active_alarms_number    connection=${connection}
    @{current_alarm_list_details}    admin_cli.get_active_alarms    connection=${connection}
    FOR    ${alarm}    IN    @{current_alarm_list_details}
        Should be true    ${alarm["alarmId"]} in ${alarm_ID_list}
    END
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Lock cell
    Log    \n****cell state update to lock    console=yes
    [Arguments]    ${cell_idx}
    ${connection}    Connect to gnb coam via ssl by gnb index    gnb_index=${0}
    Perform cell lock via rest api    connection=${connection}    cell_idx=${cell_idx}
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Unlock cell
    Log    \n****cell state update to unlock    console=yes
    [Arguments]    ${cell_idx}
    ${connection}    Connect to gnb coam via ssl by gnb index    gnb_index=${0}
    Perform cell unlock via rest api    connection=${connection}    cell_idx=${cell_idx}
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
