*** Settings ***
Documentation
...         author: n5liu
...         contact: ning.4.liu@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         ERR_WRN check

Library      taf.collectors.btslog
Library      taf.sbts.oam.coam.admin   WITH NAME   admin_ERR_WRN
Library      taf.transport.ssh        WITH NAME    ssh
Library      BuiltIn
Library      taf.collectors.core
Library      OperatingSystem
Library      DateTime
Library      ../Library/ERR_WRN_Check.py
Variables    ../Library/ERR_WRN_Check_variables.py

*** Variables ***

${Base_ERR_WRN_csv_path}     ${None}
${UTE_logs_path}        /home/ute/ERR_WRN_analysis
${UTE_syslogs_path}      /home/ute/BTS_logs
${ERR_start_timestamp}      ${None}

*** Keywords ***
Get SW Version From GNB By Admin
    ${software_info}      Set Variable       sw_ver_missing
    Set Suite Variable    ${software_info}
    Log To Console     DU_OAM_IP is: ${DU_OAM_IP}
    IF    '${DU_OAM_IP}' == '${None}'
         log to console    DU_OAM_IP is not found from init file
         RETURN       ${software_info}
     END
    ${coam_connection}    admin_ERR_WRN.Connect To    bts_host=${DU_OAM_IP}
    ${software_info}    admin_ERR_WRN.Get Sw Version    connection=${coam_connection}
    Log To Console     Software Version: ${software_info}
    Set Suite Variable    ${software_info}
    [Return]   ${software_info}
    [Teardown]    Run Keyword and Ignore Error
    ...      admin_ERR_WRN.teardown   connection=${coam_connection}


Get all rmod SN by Admin
    ${coam_connection}    admin_ERR_WRN.Connect To    bts_host=${DU_OAM_IP}
    ${rmod_info}    admin_ERR_WRN.get_frm    timeout=60    connection=${coam_connection}
    @{rmod_sn_list}    create list
    FOR    ${elem}    IN    @{rmod_info}
        Append to list    ${rmod_sn_list}   ${elem['serialNumber']}
        Set Suite Variable    ${rmod_sn_list}
    END
    [Return]   ${rmod_sn_list}
    [Teardown]    Run Keyword and Ignore Error
    ...      admin_ERR_WRN.teardown   connection=${coam_connection}

Collect full snapshot by admin
    [Arguments]   ${timeout}=${960}
    Run Keyword and Ignore Error      Get mrbtsid from BTS
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${snapshot_file}    set variable    ${instance_id_MRBTS}_Snapshot_${timestamp_log}.zip
    ${coam_connection}    admin_ERR_WRN.Connect To    bts_host=${DU_OAM_IP}
    Wait Until Keyword Succeeds    2x    30s
    ...      RUN KEYWORD AND CONTINUE ON FAILURE    admin_ERR_WRN.collect_snapshot
    ...      target_file_name=${LOG_PATH}/${snapshot_file}
    ...      timeout=${timeout}    connection=${coam_connection}
    ${snapshot_file}    set variable  ${LOG_PATH}/${snapshot_file}
    set suite variable     ${snapshot_file}
    Should not contain     ${snapshot_file}     CollectSnapshotFailed     collectsnapshotfailed
    [Return]     ${snapshot_file}
    [Teardown]    Run Keyword and Ignore Error
    ...      admin_ERR_WRN.teardown   connection=${coam_connection}

Check ERR Or WRN From Syslog
    [Arguments]    ${sys_logs_path}      ${Expected_ERR_WRN_deviation}=0.2
    ...      ${Expected_ERR_WRN_diff_number}=0     ${Expected_ERR_WRN_number}=0
    ...      ${UTE_logs_path}=${UTE_logs_path}      ${testline}=${testline_name}
    ...      ${base_file}=None     ${Fail_Case}=False       ${Clear_log}=False     ${remove_ERR_WRN_excel}=True
    ...      ${filter_list}=None      ${ignore_list}=None      ${Delete_old_ERR_WRN}=20
    ...      ${FilesSystem}=/dev/vda2      ${Max_used_space_ratio}=0.9      ${check_diff}=True
    ...      ${timeout}=30 minutes
    ...      ${feature}=Regression      ${HW_Info}=None
    ...      ${snapshot_zip_path}=None    ${Check_RF_Log}=False
    ...      ${keep_log_number}=2
    ...      ${server_type}=local
    [Documentation]       paramer Expected_ERR_WRN_number and HW_Info is not used, it can be ignored
    [Timeout]     ${timeout}
    ${sys_logs_path}     Run Keyword If     '${sys_logs_path}' == '${None}'
    ...       Set Variable      ${UTE_syslogs_path}
    ...       ELSE      Set Variable      ${sys_logs_path}
    ${ERR_WRN_differ_num}       Set Variable    0
    Run Keyword and Ignore Error
    ...    log to console    paramer Expected_ERR_WRN_number ${Expected_ERR_WRN_number} is not used,you can remove it
    Run Keyword and Ignore Error
    ...    log to console    paramer HW_Info ${HW_Info} is not used,you can remove it
    ${software_info}     get_build_version_from_robot_variables
    ${Case_NAME}     Remove String    ${TEST NAME}    ${SPACE}
    Set Global Variable    ${Case_NAME}
    # ${ERR_WRN_sum}      ${ERR_WRN_differ_num}       ${case_status}    ${ERR_WRN_base_file}    ERR_WRN_Check.Check_ERR_WRN
    ${return_info}    ERR_WRN_Check.Check_ERR_WRN
    ...      log_path=${sys_logs_path}     ERR_WRN_path=${UTE_logs_path}
    ...      sw_ver=${software_info}       testline=${testline}         check_diff=${check_diff}     fail_case=${Fail_Case}
    #...      sw_ver=SBTS25R2_ENB_9999_240821_000003      testline=${testline}         check_diff=${check_diff}     fail_case=${Fail_Case}
    ...      case_name=${Case_NAME}
    ...      expected_ERR_WRN_deviation=${Expected_ERR_WRN_deviation}      expected_ERR_WRN_differ=${Expected_ERR_WRN_diff_number}
    ...      filter_list=${filter_list}      ignore_list=${ignore_list}      user_base_file=${base_file}
    ...      remove_ERR_WRN_excel=${remove_ERR_WRN_excel}
    ...      enable_clear_log=${Clear_log}      keep_log_days=${Delete_old_ERR_WRN}
    ...      filesSystem=${FilesSystem}    max_used_space_ratio=${Max_used_space_ratio}
    ...      feature=${feature}    HW_Info=${testline}     Expected_ERR_WRN_number=${Expected_ERR_WRN_number}
    ...      server_type=${server_type}
    ${ERR_WRN_sum}    Get From List    ${return_info}    0
    ${ERR_WRN_differ_num}    Get From List    ${return_info}    1
    ${case_status}    Get From List    ${return_info}    2
    ${ERR_WRN_analysis_file}       Get From List    ${return_info}    3
    ${ERR_WRN_syslog_path}      Get From List    ${return_info}    4
    ${disk_status}      Get From List    ${return_info}    5
    ${remote_log_dir}      Get From List    ${return_info}    6
    ${Compass_ID_list}      Get From List    ${return_info}    7
    ${refer_base_file}      Get From List    ${return_info}    8
    Set Suite Variable    ${Compass_ID_list}
    Run Keyword and Ignore Error
    ...    log to console      Compass_ID_list is ${Compass_ID_list}
    Run Keyword If     '${Fail_Case}'=='True'
    ...      Run Keyword And Continue On Failure
    ...      Should Be Equal      ${case_status}     Pass      msg=!!!!!!check ERR WRN failed,please check
    Log To Console      ERR and WRN print sum in syslog is : ${ERR_WRN_sum}
    Log To Console      Differ ERR and WRN number comparing with previous base file is: ${ERR_WRN_differ_num}
    ${serial_number_list}       Run Keyword If     '${Check_RF_Log}'=='True'
    ...     Run Keyword And Continue On Failure       Get all rmod SN by Admin
    ${snapshot_status}      Run Keyword And Return Status
    ...      OperatingSystem.File Should Exist    ${snapshot_zip_path}
    Run Keyword and Ignore Error
    ...    log to console      Check if collect snapshot is needed
    ${snapshot_flag}	   RUN KEYWORD AND CONTINUE ON FAILURE     Set Variable If
    ...    "${Check_RF_Log}"=="True" or "${ERR_WRN_differ_num}"!="0"
    ...    ${True}      ${False}
    ${snapshot_zip_path}       Run Keyword If
    ...      '${snapshot_flag}'=='True' and '${snapshot_status}'!='True'
    ...     Collect full snapshot by admin
    ...     ELSE      Set Variable      ${snapshot_zip_path}
    ${snapshot_status_0}      Run Keyword And Return Status
    ...      OperatingSystem.File Should Exist    ${snapshot_zip_path}
    Run Keyword If
    ...      '${Check_RF_Log}'=='False' and '${snapshot_status}'=='True'
    ...       OperatingSystem.Run   command=cp ${snapshot_zip_path} ${ERR_WRN_syslog_path}
    ${check_ru_log}      Run Keyword If      '${Check_RF_Log}'=='True'
    ...      ERR_WRN_Check.analyze_RF_LOG_ERR_WRN_From_Snapshot
    ...      snapshot_zip_path=${snapshot_zip_path}      ERR_WRN_path=${UTE_logs_path}
    ...      ERR_WRN_syslog_path=${ERR_WRN_syslog_path}
    ...      ERR_WRN_analysis_file=${ERR_WRN_analysis_file}      sw_ver=${software_info}
    ...      user_base_file=${refer_base_file}      serial_number_list=${serial_number_list}
    ...      fail_case=${Fail_Case}      case_name=${Case_NAME}      check_diff=${check_diff}
    ...      expected_ERR_WRN_deviation=${Expected_ERR_WRN_deviation}
    ...      expected_ERR_WRN_differ=${Expected_ERR_WRN_diff_number}
    ...      testline=${testline}
    ...      keep_log_number=${keep_log_number}
    ...      filesSystem=${FilesSystem}    max_used_space_ratio=${Max_used_space_ratio}
    ${RF_ERR_WRN_differ_number}    Run Keyword If      '${Check_RF_Log}'=='True'
    ...      Get From List    ${check_ru_log}    0
    ...     ELSE      Set Variable      ${0}
    ${RF_case_status}    Run Keyword If      '${Check_RF_Log}'=='True'
    ...      Get From List    ${check_ru_log}    1
    ...      ELSE      Set Variable       Pass
    Run Keyword If      '${Check_RF_Log}'=='True'
    ...     Run Keyword And Continue On Failure       Should Be Equal
    ...      ${RF_case_status}     Pass      msg=!!!!!!Case is failed,please check
    Run Keyword If
    ...      '${server_type}'=='remote' and '${snapshot_status_0}'=='True' and "${ERR_WRN_differ_num}"!="0"
    ...       Run Keyword and Ignore Error      ERR_WRN_Check.upload_file_to_remote_server
    ...       local_file=${snapshot_zip_path}
    ...       remote_dir=${remote_log_dir}
    [Return]   ${ERR_WRN_sum}    ${ERR_WRN_differ_num}
    ...      ${RF_ERR_WRN_differ_number}      ${disk_status}      ${Compass_ID_list}

Start BTSlogs Collection In Log Server
    [Arguments]    ${Test_PC_IP}=${Test_PC_IP}    ${Test_PC_username}=${Test_PC_username}
    ...      ${Test_PC_password}=${Test_PC_password}
    ...      ${btslog_path}=/tmp/btslog2      ${btslog_launcher}=/opt/btslog/btslog_launcher
    ...      ${btslog_launcher_path}=/opt/btslog/btslog
    ...      ${Login_UTE}=False
    [Documentation]     Used to Start BTSlog collection in Log Server.
    ${syslog_file}      Set Variable       /home/ute/temp_err_wrn
    Set Suite Variable    ${syslog_file}
    ${parameter_log}      Set Variable       ${None}
    ${ERR_start_timestamp}      Set Variable       ${None}
    Set Suite Variable    ${ERR_start_timestamp}
    Set Suite Variable    ${parameter_log}
    #${start_timestamp}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    #${syslog_tgz_name}    set variable    ${instance_id_MRBTS}_ERR_WRN_SYSLOG_${timestamp}.tgz
    ${ERR_btslog_dir}      Set Variable       ${btslog_path}
    Set Suite Variable    ${ERR_btslog_dir}
    ${execute_flag}      Run Keyword and Ignore Error       Check all conditions for ERR WRN
    Set Suite Variable     ${execute_flag}
    #Run Keyword If    "${execute_flag}[1][1]" == "${False}"
    #...    Pass Execution    "some condition is not meet"    WARN
    IF    "${execute_flag}[1][1]" == "${False}"
         log to console    Some condition is not met
         RETURN       ${parameter_log}
    END
    ${ERR_start_timestamp}    DateTime.Get Current Date      result_format=%Y-%m-%d %H:%M:%S
    Set Suite Variable    ${ERR_start_timestamp}
    Run Keyword and Ignore Error       Log To Console       syslog start_timestamp is ${ERR_start_timestamp}
    Log To Console      Get remote syslog config in BTS
    ${parameter_log_0}                  Run Keyword and Ignore Error       Get parameter value for MO
    ...      dist_name=${instance_id_MRBTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ${parameter_log}      set variable      ${parameter_log_0}[1]
    Run Keyword and Ignore Error       BuiltIn.Set Suite Variable    ${parameter_log}
    Run Keyword and Ignore Error       Log To Console       remote syslog config is ${parameter_log}
    Log To Console      Make remoteSyslog work for ERR WRN analysis
    Run Keyword and Ignore Error       Make remoteSyslog work for ERR WRN analysis
    ...       reconfig_flag=${parameter_log}[2]
    Log To Console      Starting BTSLOG
    ssh.reset_cache
    BuiltIn.Sleep               3s
    ${Test_PC_IP}     Remove String    ${Test_PC_IP}    ${SPACE}
    Run Keyword If     '${Login_UTE}'=='True'      Run Keyword and Ignore Error      Connect to Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}    conn_alias=Log_Server
    Run Keyword If     '${Login_UTE}'=='True'
    ...      ssh.execute      ${btslog_launcher} current_index      connection=Log_Server
    ...      ELSE IF    '${Login_UTE}'=='False'      OperatingSystem.Run    command=${btslog_launcher} current_index
    Run Keyword If     '${Login_UTE}'=='True'       ssh.execute      mkdir -p "${ERR_btslog_dir}"
    ...      connection=Log_Server
    ...      ELSE IF    '${Login_UTE}'=='False'
    ...       OperatingSystem.Run      command=mkdir -p "${ERR_btslog_dir}"
    &{executor}         Create Dictionary    host=${Test_PC_IP}
    ...                                      user=${Test_PC_username}
    ...                                      password=${Test_PC_password}
    Run Keyword If     '${Login_UTE}'=='True'      Run Keyword and Ignore Error
    ...      taf.collectors.btslog.create_btslog_collector
    ...      name=btslog    btslog_path=${btslog_launcher_path}
    ...                               btslog_launcher_path=${btslog_launcher}    executor=${executor}
    ...      ELSE IF    '${Login_UTE}'=='False'
    ...      taf.collectors.btslog.create_btslog_collector
    ...      name=btslog    btslog_path=${btslog_launcher_path}
    ...      btslog_launcher_path=${btslog_launcher}      executor=${executor}
    taf.collectors.btslog.Set Suite Alias     btslog
    wait until keyword succeeds   10x   10s     taf.collectors.core.setup_collectors    names=btslog
    wait until keyword succeeds   10x   10s     taf.collectors.core.start_collectors    names=btslog
    BuiltIn.Sleep               10s
    ${find_command}       Run Keyword If     '${ERR_start_timestamp}'!='${None}'
    ...      Set Variable     cd "${ERR_btslog_dir}";find . -name "*.LOG" -newermt "${ERR_start_timestamp}"
    ...      ELSE    Set Variable     cd "${ERR_btslog_dir}";find . -name "*.LOG"
    ${syslog_file}      Run Keyword If     '${Login_UTE}'=='True'
    ...      ssh.execute      ${find_command}       connection=Log_Server
    ...      ELSE IF    '${Login_UTE}'=='False'      OperatingSystem.Run   command=${find_command}
    ${log_flag}=      Run Keyword And Return Status     Should Contain       ${syslog_file}      .LOG
    Run Keyword If      '${log_flag}' == 'True'        Log To Console     BTSLOG started
    ...       ELSE      Log To Console   Problem occured during BTSLOG start
    BuiltIn.Set Suite Variable    ${syslog_file}
    [Return]       ${parameter_log}

Stop BTSlogs Collection And Download Logs To Log Server
    [Arguments]         ${UTE_syslogs_path}=${UTE_syslogs_path}     ${btslog_path}=/tmp/btslog2
    ...      ${btslog_launcher}=/opt/btslog/btslog_launcher
    ...      ${Login_UTE}=${False}
    ...      ${btslog_launcher_path}=/opt/btslog/btslog_launcher
    ${UTE_zip_logs_path}      Set Variable        ${UTE_syslogs_path}
    Set Suite Variable    ${UTE_syslogs_path}
    ${ERR_btslog_dir}      Set Variable       ${btslog_path}
    Set Suite Variable    ${ERR_btslog_dir}
    ${execute_flag}      Run Keyword and Ignore Error       Check all conditions for ERR WRN
    Set Suite Variable     ${execute_flag}
    IF    "${execute_flag}[1][1]" == "${False}"
         log to console    Some condition is not met
         RETURN      ${UTE_zip_logs_path}      ${UTE_syslogs_path}
    END
    Run Keyword and Ignore Error      Log To Console       Stop BTSLOG ${btslog_launcher_path}
    #OperatingSystem.Run    rm -f "${UTE_syslogs_path}/*.tgz";rm -f "${UTE_syslogs_path}/*.zip";rm -f "${UTE_syslogs_path}/*.LOG";
    Run Keyword and Ignore Error
    ...    log to console   parameter 'btslog_launcher_path' ${btslog_launcher_path} will be dropped,please don't use this
    # Safety check: Verify UTE_syslogs_path is not empty and contains expected path pattern
    ${path_check}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${UTE_syslogs_path}    ^/home/ute/.+
    Run Keyword If    '${path_check}' == 'True'
    ...    OperatingSystem.Run   command=rm -rf "${UTE_syslogs_path}"
    ...    ELSE
    ...    Log To Console    WARNING: Skipping rm -rf for unsafe path: ${UTE_syslogs_path}
    OperatingSystem.Run    command=mkdir -p "${UTE_syslogs_path}"
    ssh.reset_cache
    BuiltIn.Sleep               3s
    Run Keyword If     '${Login_UTE}'=='True'       Run Keyword and Ignore Error       Connect to Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}    conn_alias=Log_Server
    Run Keyword and Ignore Error          taf.collectors.core.stop_collectors      names=btslog
    ${index}      Run Keyword If     '${Login_UTE}'=='True'
    ...      ssh.execute      ${btslog_launcher} current_index      connection=Log_Server
    ...      ELSE IF    '${Login_UTE}'=='False'      OperatingSystem.Run    command=${btslog_launcher} current_index
    ${log_flag}=      Run Keyword And Return Status     Should Contain       ${syslog_file}      .LOG
    Run Keyword If      '${log_flag}' == 'True'      Log To Console    BTSLOG stopped = SYSLOG_${index.strip()}.LOG
    ...                                           ELSE    Log To Console    Problem occured with BTSLOG
    ${command_0}      Set Variable     cd "${ERR_btslog_dir}";
    ${command_1}      Set Variable     find . -maxdepth 1 -type f -name "*.LOG"
    ${command_2}      Set Variable     tar zcvf ${ERR_btslog_dir}/SYSLOG.tgz {} +
    ${command}      Run Keyword If     '${ERR_start_timestamp}'!='${None}'     Set Variable
    ...      ${command_0}${command_1} -newermt "${ERR_start_timestamp}" -exec ${command_2}
    ...      ELSE      Set Variable
    ...      ${command_0}${command_1} -exec ${command_2}
    Run Keyword If     '${Login_UTE}'=='True'        ssh.execute       ${command}    connection=Log_Server
    ...      ELSE IF    '${Login_UTE}'=='False'     OperatingSystem.Run      command=${command}
    Run Keyword If     '${Login_UTE}'=='True'       OperatingSystem.Run
    ...      command=sshpass -p ${Test_PC_password} scp ${Test_PC_username}@${Test_PC_IP}:${ERR_btslog_dir}/SYSLOG.tgz ${UTE_syslogs_path}
    ...      ELSE IF    '${Login_UTE}'=='False'
    ...      OperatingSystem.Run      command=cp ${ERR_btslog_dir}/SYSLOG.tgz ${UTE_syslogs_path}
    Run Keyword and Ignore Error      OperatingSystem.Run      command=cp ${ERR_btslog_dir}/SYSLOG.tgz ${OUTPUT_DIR}
    #OperatingSystem.Run    cd ${UTE_logs_path};tar -xvf SYSLOG.tgz
    ${UTE_zip_logs_path}    set variable     ${UTE_syslogs_path}/SYSLOG.tgz
    Set Suite Variable    ${UTE_zip_logs_path}
    Set Suite Variable    ${UTE_syslogs_path}
    [Return]       ${UTE_zip_logs_path}      ${UTE_syslogs_path}
    [Teardown]         Run Keyword If    "${execute_flag}[1][1]" == "${True}"
    ...      Run keywords     Run Keyword and Ignore Error
    ...      taf.collectors.core.teardown_collectors    names=btslog
    ...       AND       Run Keyword and Ignore Error       Restore remoteSyslog config in BTS
    ...       actRemoteSyslogTransmission=${parameter_log}[0]       syslog_config=${parameter_log}[1]
    ...        reconfig_flag=${parameter_log}[2]


Connect to Log Server
    [Arguments]     ${Test_PC_IP}=${Test_PC_IP}    ${Test_PC_username}=${Test_PC_username}
    ...      ${Test_PC_password}=${Test_PC_password}      ${conn_alias}=Log_Server
    ${ssh_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds    3min  20s    ssh.connect_to
    ...                 hostname=${Test_PC_IP}
    ...                 username=${Test_PC_username}
    #...                 key_path=/home/ute/.ssh/id_rsa
    ...                 password=${Test_PC_password}
    ...                 alias=${conn_alias}
    Run Keyword If  '${ssh_status}' == 'False'  Fail  !!!Warning!!! connect to ute vm failed, please check!


Config parameter by recommission online
    [Arguments]   ${dist_name}    ${parameter}
    ...      ${value}     ${operation}=update
    ${coam_connection}        Wait Until Keyword Succeeds
    ...      3x    30s      admin_ERR_WRN.Connect To    bts_host=${DU_OAM_IP}
    Wait Until Keyword Succeeds    2x    30s
    ...      RUN KEYWORD AND CONTINUE ON FAILURE    admin_ERR_WRN.perform_parameter_recommissioning
    ...      dist_name=${dist_name}
    ...      parameter=${parameter}
    ...      value=${value}
    ...      operation=${operation}
    ...      skip_parameter_relation_errors=${True}
    ...      connection=${coam_connection}
    ...      timeout=480
    [Teardown]    Run Keyword and Ignore Error
    ...      admin_ERR_WRN.teardown   connection=${coam_connection}


Get parameter value for MO_debug
    [Arguments]   ${dist_name}
    ${coam_connection}        Wait Until Keyword Succeeds
    ...      3x    30s      admin_ERR_WRN.Connect To    bts_host=${DU_OAM_IP}
    ${out_parameters_list}       Wait Until Keyword Succeeds    2x    30s
    ...      admin_ERR_WRN.get_parameter_by_distname
    ...    dist_name=${dist_name}       connection=${coam_connection}
    ${out_parameter}    Get From Dictionary    ${out_parameters_list[0]}    parameters
     ${actRemoteSyslogTransmission}    run keyword if    'actRemoteSyslogTransmission' in ${out_parameter}
     ...      Get From Dictionary    ${out_parameter}    	actRemoteSyslogTransmission
     ...      ELSE     Set Variable     0
     ${remoteSyslogConfig_data}    run keyword if    'remoteSyslogConfig' in ${out_parameter}
     ...      Get From Dictionary    ${out_parameter}    	remoteSyslogConfig
     ${remoteSyslogConfig_0}    run keyword if    'remoteSyslogConfig' in ${out_parameter}
     ...      Set Variable    ${remoteSyslogConfig_data}[0]
     ${remoteSyslogServerHost}    run keyword if    'remoteSyslogConfig' in ${out_parameter}
     ...     Get From Dictionary    ${remoteSyslogConfig_0}    	remoteSyslogServerHost
     ...      ELSE     Set Variable     0
     ${remoteSyslogTransportProtocol}    run keyword if     'remoteSyslogConfig' in ${out_parameter}
     ...     Get From Dictionary
     ...      ${remoteSyslogConfig_0}    	remoteSyslogTransportProtocol
     ...      ELSE     Set Variable     0
     ${remoteSyslogServerPortNo}    run keyword if     'remoteSyslogConfig' in ${out_parameter}
     ...     Get From Dictionary
     ...      ${remoteSyslogConfig_0}    	remoteSyslogServerPortNo
     ...      ELSE     Set Variable     0
	 ${host_flag}=      Run Keyword And Return Status      should be equal as strings
	 ...      ${remoteSyslogServerHost}    ${Test_PC_IP}
	 ${port_flag}=      Run Keyword And Return Status      should be equal as strings
	 ...      ${remoteSyslogServerPortNo}      51000
	  ${Protocol_flag}=      Run Keyword And Return Status      should be equal as strings
	 ...      ${remoteSyslogTransportProtocol}      UDP
	 ${reconfig_flag}  Run Keyword and Continue on Failure
    ...     Evaluate  ${host_flag} and ${port_flag} and ${Protocol_flag}
     &{syslog_config_original}      Create Dictionary
	  ...       remoteSyslogServerHost=${remoteSyslogServerHost}
	  ...      remoteSyslogServerPortNo=${remoteSyslogServerPortNo}
	   ...      remoteSyslogTransportProtocol=${remoteSyslogTransportProtocol}
	 ${syslog_config_list_original}  Create List  ${syslog_config_original}
    [Return]       ${actRemoteSyslogTransmission}       ${syslog_config_list_original}       ${reconfig_flag}
    [Teardown]    Run Keyword and Ignore Error
    ...      admin_ERR_WRN.teardown   connection=${coam_connection}


Get parameter value for MO
    [Arguments]   ${dist_name}
    ${remoteSyslogConfig_data}    Create Dictionary
    ${coam_connection}        Wait Until Keyword Succeeds
    ...      3x    30s      admin_ERR_WRN.Connect To    bts_host=${DU_OAM_IP}
    ${out_parameters_list}       Wait Until Keyword Succeeds    2x    30s
    ...      admin_ERR_WRN.get_parameter_by_distname
    ...    dist_name=${dist_name}       connection=${coam_connection}
    ${out_parameter}     Evaluate    ${out_parameters_list[0]}.get("parameters", {})
    ${actRemoteSyslogTransmission}    Evaluate    ${out_parameter}.get("actRemoteSyslogTransmission", ${EMPTY})
    ${remoteSyslogConfig_list}    Evaluate    ${out_parameter}.get("remoteSyslogConfig", [])
    ${status}    ${remoteSyslogConfig_data}=    Run Keyword And Ignore Error
     ...     Get From List    ${remoteSyslogConfig_list}    0
    Run Keyword If    '${status}'=='FAIL'    Log To Console     Index out of range
    ${remoteSyslogServerHost}    run keyword if     '${status}'!='FAIL'
     ...     Evaluate    ${remoteSyslogConfig_data}.get("remoteSyslogServerHost", ${EMPTY})
     ...     ELSE     Set Variable     ${EMPTY}
     ${remoteSyslogTransportProtocol}    run keyword if    '${status}'!='FAIL'
     ...     Evaluate    ${remoteSyslogConfig_data}.get("remoteSyslogTransportProtocol", 0)
     ...      ELSE     Set Variable     ${EMPTY}
     ${remoteSyslogServerPortNo}    run keyword if     '${status}'!='FAIL'
     ...     Evaluate    ${remoteSyslogConfig_data}.get("remoteSyslogServerPortNo", ${EMPTY})
     ...      ELSE     Set Variable     ${EMPTY}
	 ${host_flag}=      Run Keyword And Return Status      should be equal as strings
	 ...      ${remoteSyslogServerHost}    ${Test_PC_IP}
	 ${port_flag}=      Run Keyword And Return Status      should be equal as strings
	 ...      ${remoteSyslogServerPortNo}      51000
	  ${Protocol_flag}=      Run Keyword And Return Status      should be equal as strings
	 ...      ${remoteSyslogTransportProtocol}      UDP
	 ${reconfig_flag}  Run Keyword and Continue on Failure
    ...     Evaluate  ${host_flag} and ${port_flag} and ${Protocol_flag}
     &{syslog_config_original}      Create Dictionary
	  ...       remoteSyslogServerHost=${remoteSyslogServerHost}
	  ...      remoteSyslogServerPortNo=${remoteSyslogServerPortNo}
	   ...      remoteSyslogTransportProtocol=${remoteSyslogTransportProtocol}
	 ${syslog_config_list_original}  Create List  ${syslog_config_original}
    [Return]       ${actRemoteSyslogTransmission}       ${syslog_config_list_original}       ${reconfig_flag}
    [Teardown]    Run Keyword and Ignore Error
    ...      admin_ERR_WRN.teardown   connection=${coam_connection}


Make remoteSyslog work for ERR WRN analysis
     [Arguments]   ${reconfig_flag}
	 &{syslog_config1}     Create Dictionary
	   ...      remoteSyslogServerHost=${Test_PC_IP}     remoteSyslogServerPortNo=51000
	   ...      remoteSyslogTransportProtocol=UDP
	 ${syslog_config_list}  Create List  ${syslog_config1}
	 Get mrbtsid from BTS
	 ${commission_status}=      Run Keyword And Return Status
	 ...     Config parameter by recommission online
     ...     dist_name=${instance_id_MRBTS}/MNL-1/MNLENT-1/TRBLCADM-1
     ...      parameter=actRemoteSyslogTransmission
     ...      value=false
     # run keyword if    '${reconfig_flag}' == '${False}'
     # ...     Config parameter by recommission online
     # ...     dist_name=${instance_id_MRBTS}/MNL-1/MNLENT-1/TRBLCADM-1
     # ...      parameter=remoteSyslogConfig
     # ...      value=${syslog_config_list}
     # ...      operation=delete
     ${commission_status_1}=      run keyword if
     ...     '${reconfig_flag}' == '${True}' and '${commission_status}' == '${True}'
     ...      Set Variable     ${True}
     ...      ELSE IF   '${reconfig_flag}' == '${False}' and '${commission_status}' == '${True}'
     ...      Run Keyword And Return Status    Config parameter by recommission online
     ...      dist_name=${instance_id_MRBTS}/MNL-1/MNLENT-1/TRBLCADM-1
     ...      parameter=remoteSyslogConfig
     ...      value=${syslog_config_list}
     ...      ELSE   Set Variable     ${False}
     run keyword if
     ...    '${commission_status}' == '${True}' and '${commission_status_1}' == '${True}'
     ...     Run Keyword and Ignore Error    Config parameter by recommission online
     ...     dist_name=${instance_id_MRBTS}/MNL-1/MNLENT-1/TRBLCADM-1
     ...      parameter=actRemoteSyslogTransmission
     ...      value=true

Restore remoteSyslog config in BTS
       [Arguments]   ${actRemoteSyslogTransmission}       ${syslog_config}     ${reconfig_flag}
       ${remoteSyslogServerHost}    Get From Dictionary    ${syslog_config}[0]    	remoteSyslogServerHost
       ${remoteSyslogServerPortNo}    Get From Dictionary    ${syslog_config}[0]    	remoteSyslogServerPortNo
       ${remoteSyslogTransportProtocol}    Get From Dictionary
       ...     ${syslog_config}[0]    	remoteSyslogTransportProtocol
       ${ip_zero_flag}=      Run Keyword And Return Status      Should Not Be Equal As Strings
	   ...      ${remoteSyslogServerHost}    ${EMPTY}
	   ${port_zero_flag}=      Run Keyword And Return Status      Should Not Be Equal As Strings
	   ...      ${remoteSyslogServerPortNo}    ${EMPTY}
	   ${protocol_zero_flag}=      Run Keyword And Return Status      Should Not Be Equal As Strings
	   ...      ${remoteSyslogTransportProtocol}    ${EMPTY}
       Run Keyword and Ignore Error      Get mrbtsid from BTS
       Run Keyword and Ignore Error      Log To Console      Restore remoteSyslog config in BTS
       Run Keyword and Ignore Error      Log To Console
       ...      parameter reconfig_flag ${reconfig_flag} will be used in the future
       #run keyword if    '${reconfig_flag}' == '${False}'
       #...     Run Keyword and Ignore Error    Config parameter by recommission online
       #...     dist_name=${instance_id_MRBTS}/MNL-1/MNLENT-1/TRBLCADM-1
       #...      parameter=actRemoteSyslogTransmission
       #...      value=false
        #run keyword if    '${reconfig_flag}' == '${False}'
        # ...     Config parameter by recommission online
        # ...     dist_name=${instance_id_MRBTS}/MNL-1/MNLENT-1/TRBLCADM-1
        # ...      parameter=remoteSyslogConfig
       #  ...      value=${syslog_config}
       #  ...      operation=delete
       #run keyword if    '${reconfig_flag}' == '${False}' and '${ip_zero_flag}' == '${True}'
       # ...    Run Keyword and Ignore Error       Config parameter by recommission online
       #...     dist_name=${instance_id_MRBTS}/MNL-1/MNLENT-1/TRBLCADM-1
       #...      parameter=remoteSyslogConfig
       #...      value=${syslog_config}
       run keyword if
       ...    '${actRemoteSyslogTransmission}' == '${False}' or '${actRemoteSyslogTransmission}' == '${True}'
       ...     Run Keyword and Ignore Error      Config parameter by recommission online
       ...     dist_name=${instance_id_MRBTS}/MNL-1/MNLENT-1/TRBLCADM-1
       ...     parameter=actRemoteSyslogTransmission
       ...     value=${actRemoteSyslogTransmission}



Get mrbtsid from BTS
    ${coam_connection}        Wait Until Keyword Succeeds
    ...      3x    30s      admin_ERR_WRN.Connect To    bts_host=${DU_OAM_IP}
    ${BTS_Info}      Wait Until Keyword Succeeds    2x    30s
    ...      RUN KEYWORD AND CONTINUE ON FAILURE    admin_ERR_WRN.get_bts_info
    ...      timeout=30
    ...      connection=${coam_connection}
    Set Global Variable    ${BTS_Info}
    ${exists_requestMessage}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${BTS_Info}    requestMessage
    ${exists_mrbtsID}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${BTS_Info}    mrbtsID
    ${instance_id}      Run Keyword If    ${exists_mrbtsID}
    ...      Set Variable      ${BTS_Info}[mrbtsID]
    ...      ELSE      Set Variable      ${None}
    ${request_info}      Run Keyword If    ${exists_requestMessage}
    ...      Set Variable      ${BTS_Info}[requestMessage]
    ...      ELSE      Set Variable      ${None}
    ${exists_request_mrbtsID}     Run Keyword If    ${exists_requestMessage}
    ...    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${BTS_Info}    mrbtsID
    ...    ELSE     Set Variable      ${False}
    ${instance_id_1}      Run Keyword If    ${exists_request_mrbtsID}
    ...      Set Variable      ${requestMessage}[mrbtsID]
    ...      ELSE      Set Variable      ${None}
    ${instance_id_MRBTS}      Run Keyword If    '${instance_id}' != '${None}'
    ...      Set Variable     MRBTS-${instance_id}
    ...      ELSE IF    '${instance_id_1}' != '${None}'
    ...      Set Variable     MRBTS-${instance_id_1}
    ...      ELSE    Set Variable     MRBTS-Not-Found
    Set Suite Variable    ${instance_id_MRBTS}
    [Return]   ${instance_id_MRBTS}
    [Teardown]    Run Keyword and Ignore Error
    ...      admin_ERR_WRN.teardown   connection=${coam_connection}


Check all conditions for ERR WRN
    Run Keyword and Ignore Error       Log To Console       'Test_PC_IP' is ${Test_PC_IP},
    ...      'Test_PC_username' is ${Test_PC_username}, 'Test_PC_password' is ${Test_PC_password},
    ...      'DU_OAM_IP' is ${DU_OAM_IP}, 'instance_id_MRBTS' is ${instance_id_MRBTS}
    Run Keyword and Ignore Error      Get mrbtsid from BTS
    ${flag1}      Run Keyword And Return Status      Should Not Be Equal    ${Test_PC_IP}    ${None}
    ${flag2}      Run Keyword And Return Status      Should Not Be Equal    ${Test_PC_username}    ${None}
    ${flag3}      Run Keyword And Return Status      Should Not Be Equal    ${Test_PC_password}    ${None}
    ${flag4}      Run Keyword And Return Status      Should Not Be Equal    ${DU_OAM_IP}    ${None}
    #${flag5}      Run Keyword And Return Status      Should Not Be Equal    ${instance_id_MRBTS}    ${None}
    ${flag6}      Run Keyword And Return Status      Should Not Be Equal    ${Test_PC_IP}    0.0.0.0
    ${execute_flag}   Run Keyword and Ignore Error
    ...     Evaluate  ${flag1} and ${flag2} and ${flag3} and ${flag4} and ${flag6}
    Set Suite Variable    ${execute_flag}
    [Return]   ${execute_flag}
