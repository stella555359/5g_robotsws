*** Settings ***
Library      taf.collectors.btslog
Library      taf.sbts.oam.coam.admin   WITH NAME   admin_cli

Library      BuiltIn
Library      taf.collectors.core
Library      OperatingSystem
Library      DateTime



*** Variables ***
${DU_OAM_IP}              ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${Test_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
${Test_PC_username}       ${tl.test_pc.default_ssh_connection_details.username}
${Test_PC_password}       ${tl.test_pc.default_ssh_connection_details.password}
${testline_name}          null
#${CURDIR}       null
#${Base_ERR_WRN_csv_path}       ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/ERR_WRN_Base.xlsx
#${Base_ERR_WRN_csv_path}     None
${Base_ERR_WRN_csv_path}     /home/ute/kiss_files/private/ERR_WRN_Base.xlsx
${UTE_logs_path}        /home/ute/ERR_WRN_analysis
*** Keywords ***
Get SW Version From GNB By Admin
    ${coam_connection}    admin_cli.Connect To    bts_host=${DU_OAM_IP}
    ${software_info}    admin_cli.Get Sw Version    connection=${coam_connection}
    Log To Console     Software Version: ${software_info}
    Set Suite Variable    ${software_info}
    [Return]   ${software_info}
    [Teardown]    Run Keyword and Ignore Error
    ...      admin_cli.teardown   connection=${coam_connection}

Get GNB Software Versionn
    [Documentation]    This keyword is to get gNB software version including below 3 suite variables.
    ...    Examples:
    ...    | Suite variable | Example | Description |
    ...    | ${SW_VERSION} | 0.800 | get the QT config files with the related version |
    ...    | ${SW_VERSION_TOTAL} | 0.800.779 | total sw version |
    ...    | ${SW_BRANCH} | 5G20B | the folder to stort config files for case |
    ${sw_info}=    _Get Software Info
    Log    Software Version: ${sw_info}    console=${True}
    @{sw_list}    String.Split String    ${sw_info}    _
    Run Keyword If    "${sw_list[0][:4]}"=="SBTS"    _Get Software Version On Common Package    ${sw_info}
    ...    ELSE    Get Software Version On 5G Pacakge    ${sw_info}  
    Log To Console     Software Version: ${sw_info}
    Set Suite Variable    ${sw_info}
    [Return]   ${sw_info}
    
Check ERR Or WRN From Syslog
    [Arguments]    ${sys_logs_path}      ${Expected_ERR_WRN_deviation}=0.2
    ...      ${Expected_ERR_WRN_diff_number}=5
    ...      ${UTE_logs_path}=${UTE_logs_path}      ${testline}=${testline_name}
    ...      ${base_file}=None     ${Fail_Case}=False       ${Clear_log}=False     ${remove_ERR_WRN_excel}=True
    ...      ${filter_list}=None      ${ignore_list}=None      ${Delete_old_ERR_WRN}=20
    ...      ${FilesSystem}=/dev/vda2      ${Max_used_space_ratio}=0.9      ${check_diff}=True
    ...      ${timeout}=30 minutes      ${Expected_ERR_WRN_number}=0
    [Documentation]       paramer Expected_ERR_WRN_number is not used, it can be ignored
    [Timeout]     ${timeout}
    ${sw_info}     Set Variable      Unknown
    ${Case_NAME}     Remove String    ${TEST NAME}    ${SPACE}
    Set Suite Variable        ${Case_NAME}
    ${software_info_list}      Run Keyword and Ignore Error     Wait Until Keyword Succeeds    10min    30s
    ...      Get GNB Software Versionn
    ${sw_info}      Run Keyword and Ignore Error       Set Variable       ${software_info_list}[1]
    Run Keyword and Ignore Error       Set Suite Variable      ${sw_info}
    ${testline}=    Get Host Name
    ${ERR_WRN_sum}      ${ERR_WRN_differ_num}       ${case_status}      ERR_WRN_Check.Check_ERR_WRN
    ...      log_path=${sys_logs_path}     ERR_WRN_path=${UTE_logs_path}
    ...      sw_ver=${sw_info}[1]       testline=${testline}         check_diff=${check_diff}     fail_case=${Fail_Case}
    #...      sw_ver=SBTS25R2_ENB_9999_240821_000003      testline=${testline}         check_diff=${check_diff}     fail_case=${Fail_Case}
    ...      case_name=${Case_NAME}      expected_ERR_WRN_deviation=${Expected_ERR_WRN_deviation}
    ...      expected_ERR_WRN_differ=${Expected_ERR_WRN_deviation}      expected_ERR_WRN_differ=${Expected_ERR_WRN_diff_number}
    ...      filter_list=${filter_list}      ignore_list=${ignore_list}      user_base_file=${base_file}
    ...      remove_ERR_WRN_excel=${remove_ERR_WRN_excel}
    ...      enable_clear_log=${Clear_log}      keep_log_days=${Delete_old_ERR_WRN}
    ...      filesSystem=${FilesSystem}    max_used_space_ratio=${Max_used_space_ratio}
    Run Keyword And Continue On Failure       Should Be Equal      ${case_status}     Pass      msg=!!!!!!Case is failed,please check
    Log To Console      ERR and WRN print sum is : ${ERR_WRN_sum}
    Log To Console      Differ ERR and WRN number comparing with previous base file is : ${ERR_WRN_differ_num}
    [Return]   ${ERR_WRN_sum}    ${ERR_WRN_differ_num}

Start BTSlogs Collection In Log Server
    [Arguments]    ${Test_PC_IP}=${Test_PC_IP}    ${Test_PC_username}=${Test_PC_username}
    ...      ${Test_PC_password}=${Test_PC_password}
    ...      ${btslog_path}=/tmp/btslog2      ${btslog_launcher}=/opt/btslog/btslog_launcher
    ...      ${btslog_launcher_path}=/opt/btslog/btslog
    ...      ${Login_UTE}=False
    [Documentation]     Used to Start BTSlog collection in Log Server.
    Log To Console      Starting BTSLOG
    ssh.reset_cache
    BuiltIn.Sleep               3s
    ${Test_PC_IP}     Remove String    ${Test_PC_IP}    ${SPACE}
    Run Keyword If     '${Login_UTE}'=='True'      Run Keyword and Ignore Error      Connect to Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}    conn_alias=Log_Server
    Run Keyword If     '${Login_UTE}'=='True'       ssh.execute      rm -rf ${btslog_path}/*;mkdir -p "${btslog_path}"
    ...      connection=Log_Server
    ...      ELSE IF    '${Login_UTE}'=='False'
    ...       OperatingSystem.Run      command=rm -rf ${btslog_path}/*;mkdir -p "${btslog_path}"
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
    taf.collectors.core.setup_collectors    names=btslog
    taf.collectors.core.start_collectors    names=btslog
    BuiltIn.Sleep               10s
    ${syslog_file}      Run Keyword If     '${Login_UTE}'=='True'
    ...      ssh.execute      find ${btslog_path} -name "*.LOG"       connection=Log_Server
    ...      ELSE IF    '${Login_UTE}'=='False'      OperatingSystem.Run   command=cd ${btslog_path};find . -name "*.LOG"
    Run Keyword If      '${syslog_file.strip()}' != ''    Log To Console     BTSLOG started
    ...       ELSE      Log To Console   Problem occured during BTSLOG start
    BuiltIn.Set Suite Variable    ${syslog_file}

Stop BTSlogs Collection And Download Logs To Log Server
    [Arguments]         ${UTE_syslogs_path}=/home/ute/BTS_logs       ${btslog_path}=/tmp/btslog2
    ...      ${btslog_launcher}=/opt/btslog/btslog_launcher      ${btslog_launcher_path}=/opt/btslog/btslog
    ...      ${Login_UTE}=${False}
    #OperatingSystem.Run    rm -f "${UTE_syslogs_path}/*.tgz";rm -f "${UTE_syslogs_path}/*.zip";rm -f "${UTE_syslogs_path}/*.LOG";
    OperatingSystem.Run   command=rm -rf "${UTE_syslogs_path}/*"
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
    Run Keyword If      '${syslog_file.strip()}' != ''    Log To Console    BTSLOG stopped = SYSLOG_${index.strip()}.LOG
    ...                                           ELSE    Log To Console    Problem occured with BTSLOG
    ${command}          Set Variable    cd ${btslog_path}; tar zcvf ${btslog_path}/SYSLOG.tgz SYSLOG_*.LOG
    Run Keyword If     '${Login_UTE}'=='True'        ssh.execute       ${command}    connection=Log_Server
    ...      ELSE IF    '${Login_UTE}'=='False'     OperatingSystem.Run      command=${command}
    Run Keyword If     '${Login_UTE}'=='True'       OperatingSystem.Run
    ...      command=sshpass -p ${Test_PC_password} scp ${Test_PC_username}@${Test_PC_IP}:${btslog_path}/SYSLOG.tgz ${UTE_syslogs_path}
    ...      ELSE IF    '${Login_UTE}'=='False'
    ...      OperatingSystem.Run      command=cp ${btslog_path}/SYSLOG.tgz ${UTE_syslogs_path}
    #OperatingSystem.Run    cd ${UTE_logs_path};tar -xvf SYSLOG.tgz
    ${UTE_zip_logs_path}    set variable     ${UTE_syslogs_path}/SYSLOG.tgz
    Set Suite Variable    ${UTE_zip_logs_path}
    Set Suite Variable    ${UTE_syslogs_path}
    [Return]       ${UTE_zip_logs_path}      ${UTE_syslogs_path}
    [Teardown]        Run Keyword and Ignore Error       taf.collectors.core.teardown_collectors    names=btslog


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
