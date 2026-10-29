*** Settings ***
Documentation
...         author: n5liu
...         contact: ning.4.liu@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         DCAP test

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library     taf.sw.dcap.rd		WITH NAME	DCAP
Library     robot.libraries.DateTime
Library     OperatingSystem
Library     taf.transport.ssh.interface.ssh       WITH NAME    tafssh
Library     String
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Library          testsuite.Hangzhou.OAM.RAN_PZ_HAZ_34.CNI-103148.Resources.CNI103148   WITH NAME   CNI103148_PY
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/DCAP.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB006443/Resources/All_KW_Interface.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001510-5GC001687/5GC001687/Resources/5GC001687-C_Common_Keywords.robot



*** Variables ***
&{bts}      host=${DU_OAM_IP}    username=Nemuadmin    password=nemuuser    port=443
&{bts_vdu}      host=${vdu_host}    username=${du_admin_username}     password=${du_admin_password}    port=443
&{bts_vcu}      host=${vcu_host}    username=${cu_admin_username}     password=${cu_admin_password}    port=443
${EMIL_IP}              ${tl.ues[0].ssh_connection_details.addr}
${EMIL_U}        ${tl.ues[0].ssh_connection_details.username}
${EMIL_P}        ${tl.ues[0].ssh_connection_details.password}
#${ute_host}           ${tl.test_pc[0].default_ssh_connection_details.addr}
#${ute_user}     ${tl.test_pc[0].default_ssh_connection_details.username}
#${ute_password}    ${tl.test_pc[0].default_ssh_connection_details.password}
#${bts_host}     ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${bts_ssh_u}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${bts_ssh_p}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${vdu_host}    ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
${vcu_host}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${du_admin_username}        ${tl.gnbs[0].dus[0].oam_http_connection_details.username}
${du_admin_password}        ${tl.gnbs[0].dus[0].oam_http_connection_details.password}
${cu_admin_username}        ${tl.gnbs[0].cu.oam_http_connection_details.username}
${cu_admin_password}        ${tl.gnbs[0].cu.oam_http_connection_details.password}
${CNI103148_trace_path_c}    /cygdrive/c/temp/CNI103148_trace
${CNI103148_trace_path}    C:\\\\temp\\\\CNI103148_trace
${emil_path}    C:\\\\Emil
${emil_exe_path}    /cygdrive/c/Emil
${testline_name}          null
@{allow_fault_list}    7107

*** Keywords ***
###CNI-103148#####
CNI103148.Check_SYSLOG_RFLOG_in_SISO_scenario_loop
    [Arguments]      ${case_name}  ${cell_info_dic}=None      ${retry_times}=2   ${KPI10_MAX}=${468}
    ...    ${rat_type}=NR
    ...    ${reset_typ}=Hard     ${Snapshot_loop}=True
    ...    ${max_size}=15728640    ${gap_size}=1048576
    ...    ${analyze_path}=/home/ute/syscom_trace     ${keyword}=AaTraceRecord
    ...    ${excluded_keywords}=_pm_    ${suffix}=.atr
    ...    ${filesSystem}=/dev/vda2
    ...    ${check_trace}=True
    ...     ${Check_RF_Log}=False
    ...    ${Fail_Case}=False
    ...    ${fail_loop_max}=30
    ...    ${Max_used_space_ratio}=0.92
    ...    ${test_scenario}=reset_NR_RAT
    ...    ${parallel}=False
    ...    ${server_type}=local
    KW.CaseStatusInit    retry_times=${retry_times}
    @{result_list}    create list
    ${refer_trace}      Set Variable     None
    Run Keyword And Ignore Error    log to console   CASE_TEST_RUN_LINK is ${CASE_TEST_RUN_LINK}
    ${conf_path}       RUN KEYWORD AND CONTINUE ON FAILURE
    ...      CNI103148.Get_syscom_trace_conf   analyze_path=${analyze_path}
    RUN KEYWORD AND CONTINUE ON FAILURE      set suite variable        ${refer_trace}
    FOR    ${i}    IN RANGE    ${retry_times}
        log to console    Start ${test_scenario} loop${i}
        ims_keywords.check_instance_connection    gnbbbu
	    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
        ${res}    RUN KEYWORD AND CONTINUE ON FAILURE     CNI103148.Check_SYSLOG_RFLOG    loop=${i+1}
        ...     KPI10_MAX=${KPI10_MAX}    config_path=${conf_path}
        ...     Snapshot_loop=${Snapshot_loop}
        ...     rat_type=${rat_type}     reset_typ=${reset_typ}
        ...     max_size=${max_size}    gap_size=${gap_size}
        ...     refer_trace=${refer_trace}    analyze_path=${analyze_path}     keyword=${keyword}
        ...     excluded_keywords=${excluded_keywords}     suffix=${suffix}
        ...     filesSystem=${filesSystem}
        ...     cell_info_dic=${cell_info_dic}
        ...     check_trace=${check_trace}
        ...     Check_RF_Log=${Check_RF_Log}
        ...     Fail_Case=${Fail_Case}
        ...     Max_used_space_ratio=${Max_used_space_ratio}
        ...     test_scenario=${test_scenario}
        ...     parallel=${parallel}
        ...     server_type=${server_type}
        ${reset_status}         RUN KEYWORD AND CONTINUE ON FAILURE
        ...      set variable if    '${res[0]}'=='fail'      fail    ${res[0]}
        ${duration_time_tmp}    RUN KEYWORD AND CONTINUE ON FAILURE
        ...      set variable if    '${res[0]}'=='fail'      1800    ${res[1]}
        ${refer_trace}          RUN KEYWORD AND CONTINUE ON FAILURE
        ...      set variable       ${res[2]}
        ${disk_status}          RUN KEYWORD AND CONTINUE ON FAILURE
        ...      set variable       ${res[3]}
        ${RF_err_differ}          RUN KEYWORD AND CONTINUE ON FAILURE
        ...      set variable       ${res[5]}
        RUN KEYWORD AND CONTINUE ON FAILURE      set suite variable        ${refer_trace}
        Run Keyword And Ignore error     KW.CaseStatusCaluate    duration=${duration_time_tmp}    max=${KPI10_MAX}
        log to console     Case ${test_scenario} loop ${i+1} END
        Run Keyword And Ignore error     Get common info     case_result=${reset_status}
        ...    case_name=${case_name}   loop_number=${i+1}  duration_time=${duration_time_tmp}
        Run Keyword And Ignore error      Append To List    ${result_list}    ${reset_status}
        ${fail_num}     RUN KEYWORD AND CONTINUE ON FAILURE        Count Values In List    ${result_list}     fail
        Exit for loop if    ${fail_num}>=${fail_loop_max} or '${disk_status}'=='${True}' or ${RF_err_differ}>=999999
    END

CNI103148.Check_SYSLOG_RFLOG
    [Arguments]   ${config_path}     ${cell_info_dic}=None      ${loop}=0
    ...    ${KPI10_MAX}=${468}
    ...    ${rat_type}=NR
    ...    ${reset_typ}=Hard     ${Snapshot_loop}=True
    ...    ${max_size}=15728640    ${gap_size}=1048576
    ...    ${analyze_path}=/home/ute/syscom_trace     ${keyword}=AaTraceRecord
    ...    ${excluded_keywords}=_pm_    ${suffix}=.atr
    ...    ${filesSystem}=/dev/vda2
    ...    ${refer_trace}=None
    ...    ${check_trace}=True
    ...    ${Check_RF_Log}=False
    ...    ${Fail_Case}=False
    ...    ${Max_used_space_ratio}=0.92
    ...    ${test_scenario}=reset_NR_RAT
    ...    ${parallel}=False
    ...    ${server_type}=local
    ${duration_time_tmp}    Run Keyword and Continue on Failure     Set Variable   ${0}
    ${disk_status}    Run Keyword and Continue on Failure     Set Variable   ${False}
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${start_time}    DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S.%f
    ${referrence_time}      convert date    ${timestamp_log}    epoch
    ${bin_path}        Run Keyword and Continue on Failure     Set Variable   ${analyze_path}
    wait until keyword succeeds   10x   1min    Connect to DU by ADMIN API
    Run KEYWORD IF      '${parallel}'=='True'
    ...      Run Keyword And Ignore error    KW.Collect_snapshot_for_in_parallel
    ...    min_duration=15        max_duration=19
    sleep    3s
    Timer.Start
	${reset_rat_status}      Run KEYWORD IF      '${test_scenario}'=='reset_NR_RAT'
	...      Run Keyword And Return Status     Run Keyword and Continue on Failure
	...    DU_Rest.rat_reset   rat_type=${rat_type}     reset_type=${reset_typ}
	...    timeout=900    connection=${connection}
	...    ELSE IF        '${test_scenario}'=='warm_reset_site'
	...    	Run Keyword And Return Status         Run Keyword and Continue on Failure
	...      taf.sbts.oam.coam.admin.reset      reset_without_ru=${true}
	...      timeout=1800    connection=${connection}
	...    ELSE IF        '${test_scenario}'=='warm_reset_all_ru'
	...     Run Keyword and Continue on Failure       CNI103148.reset_all_rmod
    ...    ELSE IF        '${test_scenario}'=='remote_power_reset_site'
	...     Run Keyword and Continue on Failure       taf.sbts.oam.coam.admin.power_reset
	...    reset_with_snapshot=${false}
    ...    connection=${connection}
	#${reset_rat_status}    set variable     ${True}
	sleep    60s
	${onair_status}      Run Keyword And Return Status      Check all cells Should Be On Air
	...       wait_time=7min
	${rmod_status}      Run Keyword And Return Status
	...      KW.get_and_check_rmod_status
    ${duration_time_tmp}     Timer.Stop
    #Run Keyword and Continue on Failure      CNI103148.lock_unlock_all_rmod
    #Run Keyword And Ignore Error
    #...      DU_Rest.reset_all_cells    technology=NR    timeout=600    connection=${connection}
	${onair_status}      Run Keyword And Return Status      Check all cells Should Be On Air
	...       wait_time=12min
    sleep    150s
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${loop}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms    loop=${loop}
    ...    referrence_time=${referrence_time}
    #Run Keyword And Continue On Failure    Collect IMS File  ${LOG_PATH}/loop${loop}_ims2/
    # Run Keyword And Ignore Error     Analyse IMS File   kpi_list=${kpi_list}    loop=${loop}
    # ${duration_time_tmp}    Run Keyword and Continue on Failure     Set Variable   ${kpi_avg}
    ${status}  Run Keyword and Continue on Failure
    ...     Evaluate  ${alarm_status} and ${history_alarm_status}
    ${sbts_status}  Run Keyword and Continue on Failure
    ...     Evaluate  ${onair_status} and ${rmod_status}
    ${reset_status}	   RUN KEYWORD AND CONTINUE ON FAILURE     Set Variable If
    ...    "${sbts_status}"=="True" and "${status}"=="False" and ${100}<${duration_time_tmp}<${KPI10_MAX}
    ...    pass      fail
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${reset_status}    pass
    RUN KEYWORD AND CONTINUE ON FAILURE
    ...    log to console
    ...    The testing result of this loop${loop} reset rat is ${reset_status} and KPI is ${duration_time_tmp}
    ${bin_path}          Run KEYWORD IF      '${check_trace}'=='True'
    ...      RUN KEYWORD AND CONTINUE ON FAILURE
    ...      CNI103148.Get_syscom_trace_bin     analyze_path=${analyze_path}
    Run KEYWORD IF      '${parallel}'=='True'
    ...      Run Keyword And Ignore Error    KW.cancel_Collect_snapshot_for_in_parallel
    Run KEYWORD IF      '${parallel}'=='True'
    ...      Run Keyword And Ignore Error    Run    sudo rm -rf ${snapshot_in_parallel}
    Run KEYWORD IF      '${parallel}'=='True'
    ...      run keyword and ignore error     DisConnect to DU by ADMIN API    connection_AdminApi=COAM1
    ${snapshot_file}    Run Keyword If    '${Snapshot_loop}'=='True' or '${reset_status}'=='fail'
    #${snapshot_file}    Run Keyword If     '${reset_status}'=='fail'
    ...      RUN KEYWORD AND CONTINUE ON FAILURE
    ...      wait until keyword succeeds   2x   1min    WEBUI.Collect snapshot
    ...      timeout=${3600}
    ${end_time}    DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S.%f
    ${rmod_status_1}      Run Keyword And Return Status
	...      KW.get_and_check_rmod_status
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${rmod_status_1}    ${True}
    log to console
    ...    after collect snapshot RMOD status is ${rmod_status_1}
    ${BTS_syslog}       Run Keyword And Ignore error
    ...      Stop BTSlogs Collection and get logs for every loop    loop=${timestamp_log}
    ${ERR_WRN_status}
    ...      RUN KEYWORD AND CONTINUE ON FAILURE     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${BTS_zip_path}
    ...      check_diff=True      Expected_ERR_WRN_diff_number=0
    ...      Expected_ERR_WRN_deviation=0.8      Delete_old_ERR_WRN=1
    ...      Clear_log=False     Max_used_space_ratio=${Max_used_space_ratio}
    ...      Fail_Case=${Fail_Case}
    ...      Check_RF_Log=${Check_RF_Log}
    ...      snapshot_zip_path=${snapshot_file}
    ...      server_type=${server_type}
    ${ERR_WRN_result}    Run Keyword If     '${ERR_WRN_status[0]}'=='PASS'
    ...    RUN KEYWORD AND CONTINUE ON FAILURE    set variable      ${ERR_WRN_status[1]}
    ...    ELSE    RUN KEYWORD AND CONTINUE ON FAILURE    set variable    ${ERR_WRN_status}
    ${ERR_WRN_sum}         RUN KEYWORD AND CONTINUE ON FAILURE
    ...      set variable      ${ERR_WRN_result[0]}
    ${ERR_WRN_differ_num}    RUN KEYWORD AND CONTINUE ON FAILURE
    ...      set variable       ${ERR_WRN_result[1]}
    ${RF_ERR_WRN_differ_number}          RUN KEYWORD AND CONTINUE ON FAILURE
    ...      set variable       ${ERR_WRN_result[2]}
    ${disk_status}          RUN KEYWORD AND CONTINUE ON FAILURE
    ...      set variable       ${ERR_WRN_result[3]}
    #${err_check}	   RUN KEYWORD AND CONTINUE ON FAILURE     Set Variable If
    #...    "${ERR_WRN_differ_num}"=="${0}" and "${RF_ERR_WRN_differ_number}"=="${0}"
    #...    pass      fail
    ${err_check}    set variable     pass
    ${test_and_err_status}	   RUN KEYWORD AND CONTINUE ON FAILURE     Set Variable If
    ...    "${err_check}"=="pass" and "${reset_status}"=="pass"
    ...    pass      fail
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${reset_status}    pass
    Run KEYWORD IF      '${Fail_Case}'=='True'
    ...      Run Keyword And Continue On Failure       Should Be Equal
    ...      ${test_and_err_status}     pass
    Run KEYWORD IF      '${ERR_WRN_differ_num}'!='${0}'
    ...      Run Keyword And Ignore Error
    ...    log to console
    ...    !!!!!!!!!!!!!!!New SYSLOG_ERR_WRN have ${ERR_WRN_differ_num} !!!!!!!
    Run KEYWORD IF      '${RF_ERR_WRN_differ_number}'!='${0}'
    ...    Run Keyword And Ignore Error
    ...    log to console
    ...    !!!!!!!!!!!!!New RF_SYSLOG_ERR_WRN have ${RF_ERR_WRN_differ_number} !!!!!!!
    ${check_result}    Run KEYWORD IF      '${check_trace}'=='True'
    ...      RUN KEYWORD AND CONTINUE ON FAILURE
    ...     CNI103148_PY.analyze_new_trace_loop
    ...      log_path=${snapshot_file}    max_size=${max_size}    gap_size=${gap_size}
    ...     refer_trace=${refer_trace}    analyze_path=${analyze_path}     keyword=${keyword}
    ...     excluded_keywords=${excluded_keywords}     suffix=${suffix}
    ...     filesSystem=${filesSystem}
    ${trace_path}    Run KEYWORD IF      '${check_trace}'=='True'
    ...      set variable     ${check_result[0]}
     ...     ELSE      Set Variable      ${analyze_path}
    ${file_size}    Run KEYWORD IF      '${check_trace}'=='True'
     ...      set variable     ${check_result[1]}
     ...     ELSE      Set Variable      0
    Run KEYWORD IF      '${check_trace}'=='True'
    ...      RUN KEYWORD AND CONTINUE ON FAILURE      set suite variable        ${trace_path}
    Run KEYWORD IF      '${check_trace}'=='True'
    ...      RUN KEYWORD AND CONTINUE ON FAILURE      set suite variable        ${disk_status}
    Run KEYWORD IF      '${check_trace}'=='True'
    ...      RUN KEYWORD AND CONTINUE ON FAILURE
    ...    log to console   the size of the syscom trace is ${file_size}
    Run KEYWORD IF      '${check_trace}'=='True'
    ...      Run Keyword And Continue On Failure       Should Not Be Equal
    ...      ${file_size}     fail     msg=!!!!!!Case is failed,please check
    Run Keyword If
    ...    '${file_size}'!='fail' and '${test_and_err_status}'=='pass'
    ...    Run keywords
    ...    Run Keyword And Ignore Error    Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    ...    AND    Run Keyword And Ignore Error    Run    sudo rm -rf ${LOG_PATH}/loop${loop}_ims2/
    ...    AND    Run Keyword And Ignore Error    Run    sudo rm -rf ${snapshot_file}
    #Run Keyword And Ignore Error    Run    sudo rm -rf ${snapshot_file_debug}
    Run KEYWORD IF      '${check_trace}'=='True'
    ...      RUN KEYWORD AND CONTINUE ON FAILURE
    ...      CNI103148.Get_syscom_trace_and_convert_to_json     trace_path=${trace_path}
    ...      bin_path=${bin_path}
    Run KEYWORD IF      '${check_trace}'=='True'
    ...      RUN KEYWORD AND CONTINUE ON FAILURE
    ...      CNI103148_PY.analyze_trace_and_generate_result
    ...      trace_path=${trace_path}      start_time=${start_time}       end_time=${end_time}
    ...      config_path=${config_path}      suffix=.json      cell_info_dic=${cell_info_dic}
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    #Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    #Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/*.zip
    Run Keyword And Ignore Error    Run    sudo rm -rf /home/coam/*
    [Return]    ${test_and_err_status}   ${duration_time_tmp}       ${trace_path}      ${disk_status}       ${file_size}
    ...         ${RF_ERR_WRN_differ_number}
    [Teardown]    run keywords     Run Keyword And Ignore error    ims_keywords.instance_disconnect  gnbbbu
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API    connection_AdminApi=COAM1
    ...    AND    Run Keyword And Ignore Error     COAM_WebEM.Logout


CNI103148.reset_all_rmod
    wait until keyword succeeds   10x   1min    Connect to DU by ADMIN API
    DU_WebEM.Get RMOD ID
    FOR    ${RMOD}    IN    @{RMOD_id_list}
        ${random_num}=    Evaluate    random.randint(10, 30)    random
        Run Keyword And Ignore error     DU_Rest.reset_unit
        ...    dist_name=${RMOD['internal']}    timeout= ${random_num}    connection=${connection}
    END
    [Teardown]    run keyword and ignore error     DisConnect to DU by ADMIN API

###CNI-103148#####
CNI103148.Suite setup
    [Arguments]      ${check_trace}=${True}
    Run Keyword And Ignore Error    robot_common_operations.Common Suite Setup
    Run Keyword And Ignore Error    CI_interface.Common Suite Setup
    Run Keyword If    '${check_trace}'=='${True}'
    ...      csn.Connect to   hostname=${EMIL_IP}    username=${EMIL_U}
    ...      password=${EMIL_P}    alias=Emil_decode
    Run Keyword If    '${check_trace}'=='${True}'
    ...     csn.Execute    command=rm -rf "${CNI103148_trace_path}"    connection=Emil_decode
    Run Keyword If    '${check_trace}'=='${True}'
    ...      csn.Execute    command=mkdir "${CNI103148_trace_path}"    connection=Emil_decode
    Run Keyword If    '${check_trace}'=='${True}'
    ...      csn.Disconnect    connection=Emil_decode


CNI103148.Case_setup
    Run Keyword And Ignore Error    robot_common_operations.Common case setup
    Run Keyword And Ignore Error      AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}


CNI103148.Case_teardown
    Run Keyword And Ignore Error    robot_common_operations.Common case Teardown
    Run Keyword And Ignore Error      AlarmWatchdog.remove_allow_alarms
    ...      fault_id=${allow_fault_list}
    run keyword and ignore error    admin_cli.teardown    connection=${connection}
    CI_interface.Common Case Teardown


CNI103148.lock_unlock_all_rmod
      wait until keyword succeeds   10x   1min    Connect to DU by ADMIN API
      ${return_result}      DU_WebEM.Get RMOD ID
      ${RMOD_id_list}       set variable       ${return_result[0]}
      ${RMOD_internal_list}       set variable       ${return_result[1]}
      ${lock_RF}     Run Keyword And Return Status
            ...    wait until keyword succeeds   3min   3s    taf.sbts.oam.coam.admin.lock
            ...    dist_name=${RMOD_internal_list}    timeout=600
            ...    connection=${connection}
      ${unlock_RF}     Run Keyword And Return Status
            ...    wait until keyword succeeds   3min   3s    taf.sbts.oam.coam.admin.unlock
            ...    dist_name=${RMOD_internal_list}   timeout=600
            ...    connection=${connection}
      ${onair_status}      Run Keyword And Return Status      Check all cells Should Be On Air
     log to console     cell_operational_status is ${onair_status}
     RUN KEYWORD AND CONTINUE ON FAILURE
     ...      Should be equal as strings    ${onair_status}    True
     [Teardown]    run keyword and ignore error     DisConnect to DU by ADMIN API

CNI103148.Suite teardown
    #Run Keyword And Ignore Error    DCAP.stop_trace    trace_id=${tracer_id}
    Run Keyword And Ignore Error    robot_common_operations.Common Suite teardown


CNI103148.Get_syscom_trace_and_convert_to_json
    [Arguments]    ${trace_path}          ${bin_path}
    csn.Connect to    hostname=${Test_PC_IP}    username=${Test_PC_username}    password=${Test_PC_password}    alias=ute
    csn.Execute   command=ls ${trace_path} |grep '.atr'|grep -v '_pm_' > ${trace_path}/trace_name.txt
    ...    connection=ute
    ${range}      csn.Execute   command=wc -l ${trace_path}/trace_name.txt | awk '{print $1}'
    ...    connection=ute
    csn.Connect to   hostname=${EMIL_IP}    username=${EMIL_U}    password=${EMIL_P}
    ...    alias=Emil_decode
     Run Keyword And Ignore Error       log to console     there is ${range} trace file
    ${range}    Convert To Integer    ${range}
    ${range}=    Evaluate    ${range}+1
    FOR    ${i}    IN RANGE    1    ${range}
        ${trace_log_name}    csn.Execute    command=sed -n ${i}p ${trace_path}/trace_name.txt    connection=ute
        ${trace_log_name}    strip string    ${trace_log_name}
        CNI103148.convert to json     trace_path=${trace_path}
        ...    trace_log_name=${trace_log_name}
        sleep    10s
    END
    Run Keyword And Continue On Failure       csn.Execute   command=mv ${bin_path} ${trace_path}
        ...    connection=ute
    [Teardown]      Run Keyword and Ignore Error
    ...       run keywords     csn.Disconnect    connection=Emil_decode     AND      csn.Disconnect     connection=ute


CNI103148.Get_syscom_trace_conf
    [Arguments]    ${analyze_path}
    csn.Connect to    hostname=${Test_PC_IP}    username=${Test_PC_username}    password=${Test_PC_password}    alias=ute
    OperatingSystem.Run
    ...      sshpass -p ${bts_ssh_p} scp ${bts_ssh_u}@${DU_OAM_IP}:"/tmp/AaTraceRecordFilter.txt" "${analyze_path}/"
    ${conf_path}     set variable     ${analyze_path}/AaTraceRecordFilter.txt
    [Return]      ${conf_path}
    [Teardown]      Run Keyword and Ignore Error      csn.Disconnect     connection=ute


CNI103148.Get_syscom_trace_bin
    [Arguments]    ${analyze_path}
    csn.Connect to    hostname=${Test_PC_IP}    username=${Test_PC_username}    password=${Test_PC_password}    alias=ute
    OperatingSystem.Run
    ...      sshpass -p ${bts_ssh_p} scp ${bts_ssh_u}@${DU_OAM_IP}:"/rom/logs/aaTrace/AaTraceRecord.bin" "${analyze_path}/"
    ${bin_path}     set variable     ${analyze_path}/AaTraceRecord.bin
    [Return]      ${bin_path}
    [Teardown]      Run Keyword and Ignore Error      csn.Disconnect     connection=ute

CNI103148.convert to json
    [Arguments]    ${trace_path}      ${trace_log_name}
    log to console    \n Upload convert script
    log to console     EMIL host is ${EMIL_IP}
    csn.Execute    command=rm -f "${CNI103148_trace_path}\\\\covert_to_json.bat"
    ...    connection=Emil_decode
    csn.Execute    command=mkdir -p "${CNI103148_trace_path}"
    ...    connection=Emil_decode
    csn.Execute    command=chmod -R 777 "${CNI103148_trace_path}"
    ...    connection=Emil_decode
    csn.Execute    command=mkdir -p "${CNI103148_trace_path}\\\\trace_json"
    ...    connection=Emil_decode
    csn.Execute    command=chmod -R 777 "${CNI103148_trace_path}\\\\trace_json"
    ...    connection=Emil_decode
    log to console    \n create bat command
    ${trace_json_name}     Remove String    ${trace_log_name}    .atr
    ${cmd}=    catenate
    ...      start /wait Emil.exe "${CNI103148_trace_path}\\\\${trace_log_name}" -tojson
    ...      formatted -out ${CNI103148_trace_path}\\\\trace_json\\\\${trace_json_name}.json
    set suite variable    ${cmd}
    OperatingSystem.Create File     path=${trace_path}/covert_to_json.bat    content=${cmd}
    log to console    \n convert to json
    OperatingSystem.Run
    ...     sshpass -p ${EMIL_P} scp ${trace_path}/${trace_log_name} ${EMIL_U}@${EMIL_IP}:${CNI103148_trace_path_c}/
    OperatingSystem.Run
    ...     sshpass -p ${EMIL_P} scp ${trace_path}/covert_to_json.bat ${EMIL_U}@${EMIL_IP}:${emil_exe_path}\\\\
    csn.Execute    command=cd "${emil_exe_path}"    connection=Emil_decode
    log to console    \n convert trace to json
    csn.Execute    command=cd "${emil_exe_path}";cmd.exe /c covert_to_json.bat    connection=Emil_decode
    OperatingSystem.Run
    ...      sshpass -p ${EMIL_P} scp ${EMIL_U}@${EMIL_IP}:"${CNI103148_trace_path_c}/trace_json/*" "${trace_path}/"
    ${time}    Get Time    epoch
    csn.Execute   command=rm -rf ${CNI103148_trace_path}
        ...    connection=Emil_decode
