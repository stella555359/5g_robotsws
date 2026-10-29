*** Settings ***
Documentation    :copyright: Nokia
...              :contact: I_NSB_MN_RAN_RD_VRF_HAZ4_13@internal.nsn.com


*** Variables ***


${f}    /home/ute/

*** Keywords ***
Start capture gnb and ap syslog in '${file_name}' file
    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/All/syslog_${file_name}
    ...    log_name=${file_name}_gnb    ip=${GNB_SYSLOG.ip}    alias=collect_gnb
    ute_syslog.Start Syslog    file_limit=${AP_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/All/syslog_${file_name}
    ...    log_name=${file_name}_ap    ip=${AP_SYSLOG.ip}    alias=collect_ap

Stop capture gnb and ap syslog in '${file_name}' file
    run keyword and continue on failure    check_err_wrn_in_btslog    ${TEST_LOG_DIRECTORY()}${/}All${/}syslog_${file_name}${/}    ${file_name}
    ute_syslog.Collect Syslog Results    alias=collect_gnb    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}All${/}syslog_${file_name}${/}${file_name}_gnb.tar.gz
    ute_syslog.Collect Syslog Results    alias=collect_ap    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}All${/}syslog_${file_name}${/}${file_name}_ap.tar.gz


Stop capture gnb and ap syslog in '${file_name}' file '${custom_error}'
    run keyword and continue on failure    check_err_wrn_in_btslog    ${TEST_LOG_DIRECTORY()}${/}All${/}syslog_${file_name}${/}    ${file_name}
    ...    ${custom_error}
    ute_syslog.Collect Syslog Results    alias=collect_gnb    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}All${/}syslog_${file_name}${/}${file_name}_gnb.tar.gz
    ute_syslog.Collect Syslog Results    alias=collect_ap    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}All${/}syslog_${file_name}${/}${file_name}_ap.tar.gz


Start capture only gnb syslog in '${file_name}' file
    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/All/syslog_${file_name}
    ...    log_name=${file_name}_gnb    ip=${GNB_SYSLOG.ip}    alias=collect_gnb

Stop capture only gnb syslog in '${file_name}' file
    run keyword and continue on failure    check_err_wrn_in_btslog    ${TEST_LOG_DIRECTORY()}${/}All${/}syslog_${file_name}${/}    ${file_name}
    ute_syslog.Collect Syslog Results    alias=collect_gnb    unzip=${False}
   ...    destination=${TEST_LOG_DIRECTORY()}${/}All${/}syslog_${file_name}${/}${file_name}_gnb.tar.gz

Start collect bip log
    log to console    start collect bip log
    Get BIP Scripts Files    ${test_log_directory()}/bip_config
    ${status}    ${msg}    Run Keyword And Ignore Error    Variable Should Exist    ${GNBMIRRORINGCONFIGS}
    Run Keyword If    '${status}'=='PASS'    Modify File List Paramters
    ...    ${test_log_directory()}/bip_config/gnbMirroringConfig.sh    ${GNBMIRRORINGCONFIGS}
    Start GNB BIP Log    ${test_log_directory()}/bip_config

Wait for '${time}' to stop bip log with name'${bip_tag}'
    sleep   ${time}
    Stop GNB BIP Log    ${test_log_directory()}/All/${bip_tag}

Start collect bip log for LOOO
    log to console    start collect bip log
    Get BIP Scripts Files    ${test_log_directory()}/bip_config
    ${status}    ${msg}    Run Keyword And Ignore Error    Variable Should Exist    ${GNBMIRRORINGCONFIGS}
    Run Keyword If    '${status}'=='PASS'    Modify File List Paramters
    ...    ${test_log_directory()}/bip_config/gnbMirroringConfig.sh    ${GNBMIRRORINGCONFIGS}
    Start GNB BIP Log    ${test_log_directory()}/bip_config    bip_use_admin_api=true
Start collect ttitrace
    [Arguments]    ${lcr_cell_id}=All    ${up_sw}=L2Ps     ${name}=l2stream3
    log to console    start collect ttitrace
    Start GNB Ttitrace With Streaming Mode    ${lcr_cell_id}    ${up_sw}    ${name}

Wait for '${time}' to stop ttitrace with name'${tti_tag}'
    sleep   ${time}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}


Decode ttitrace
    [Arguments]    ${pcap_path}
    Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}

Collect AP egate log
    [Arguments]    ${tag}
    Wait '2s' for stabible
    airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/${tag}_egate    unzip=TRUE

NSA get ue '${ue_id}' dl throughput
    ${nsa_dl_tput}    Airphone NSA Get Throughput    ${ue_id}     DL
    [Return]   ${nsa_dl_tput}

Start collect '${name}' tcpdump
    ${executor_oam_vm}    Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
    Start Tcpdump    name=${name}    options=-i any    remote_info=${executor_oam_vm}

Stop collect '${name}' tcpdump
    common_logs_operate.Stop Tcpdump    ${name}    ${TEST_LOG_DIRECTORY()}/All

Stop egate log and unzip with name'${egate_tag}'
    Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_${egate_tag}    unzip=TRUE

Start LOAPLO Sos Report
    [Arguments]    ${check_time}=2min    ${wts_dir}=/opt/wts/latest/sosReport_ASIL    ${tmp_dir}=/tmp
    [Documentation]    This keyword is to use script 'startTest_ASIL.sh'
    ...    to start capture Airphone SosReport log in LOAPLO.
    ...    | Input Parameters | Description
    ...    | ${check_time} |check log all time,change it as needed
    ...    | ${wts_dir} |startTest_ASIL.sh dir
    ...    | ${tmp_dir} |start_stdout.txt dir, the output of startTest_ASIL.sh saved in start_stdout.txt

    Run    chmod 777 ${wts_dir}${/}startTest_ASIL.sh
    Log To Console    Start startTest_ASIL.sh Sosreport...
    ${start_sosreport_cmd}    Set Variable    .${/}startTest_ASIL.sh
    ${result}    Process.Start Process    ${start_sosreport_cmd}    shell=True    cwd=${wts_dir}
    ...    stdout=${tmp_dir}${/}start_stdout.txt
    ${success_msg}    Set Variable    You can now start your tests in egate
    Wait Until Keyword Succeeds    ${check_time}    10s    Check Suscess Msg Exist    ${tmp_dir}${/}start_stdout.txt    ${success_msg}


Stop LOAPLO Sos Resport
    [Arguments]    ${check_time}=15min    ${wts_dir}=/opt/wts/latest/sosReport_ASIL    ${tmp_dir}=/tmp
    [Documentation]    This keyword is to use script 'stopTest_ASIL.sh'
    ...    to stop capture Airphone SosReport log in LOAPLO. If "Check Suscess Msg Exist" fail
    ...    means stoping sos log not finish, please wait for a moment, then check the last line until contains
    ...    "_UEAPP1.tgz created" in stop_stdout.txt.
    ...    | Input Parameters | Description
    ...    | ${check_time} |check log all time,change it as needed
    ...    | ${wts_dir} |stopTest_ASIL.sh dir
    ...    | ${tmp_dir} |stop_stdout.txt dir, the output of stopTest_ASIL.sh saved in stop_stdout.txt
    ...      the full name of *_UEAPP1.tgz in it.

    Run    chmod 777 ${wts_dir}${/}/stopTest_ASIL.sh
    Log To Console    Stop stopTest_ASIL.sh Sosreport...
    ${stop_sosreport_cmd}    Set Variable    .${/}stopTest_ASIL.sh
    ${result}    Process.Start Process    ${stop_sosreport_cmd}    shell=True    cwd=${wts_dir}
    ...    stdout=${tmp_dir}${/}stop_stdout.txt
    ${success_msg}    Set Variable    _UEAPP1.tgz created
    Wait Until Keyword Succeeds    ${check_time}    10s    Check Suscess Msg Exist    ${tmp_dir}${/}stop_stdout.txt    ${success_msg}


Start collect ttitrace by gnb tool
    [Arguments]    ${command}
    ${exist}    List Directory    /home/ute
    Run keyword if    'gnb_logs-tool' not in ${exist}    OperatingSystem.Run
    ...     cd ${f};git clone https://gitlabe1.ext.net.nokia.com/p5li/gnb_logs-tool;unzip -d ${f}gnb_logs-tool ${f}gnb_logs-tool/gnb_logs.zip
    OperatingSystem.Run    rm /home/ute/gnb_logs-tool/gnb_logs/stop_mon.log
    TAF_SSH.Connect To    127.0.0.1    ute    ute    alias=bsh
    TAF_SSH.Execute    chmod 777 /home/ute/gnb_logs-tool/gnb_logs/gnb_logs    connection=bsh
    TAF_SSH.Send Command    cd /home/ute/gnb_logs-tool/gnb_logs;${command}    connection=bsh
    TAF_SSH.Read Output Until    (Q)uit    connection=bsh

Wait for '${time}' to stop collect ttitrace by gnb tool
    Wait '${time}' for stable
    OperatingSystem.Run    touch /home/ute/gnb_logs-tool/gnb_logs/stop_mon.log
    Wait Until Keyword Succeeds    300    10    file should contain
    ...    /home/ute/gnb_logs-tool/gnb_logs/tool.log    Tool finished running

Start collect f1ap
    [Arguments]     ${log_file}
    Log To Console    Start collect '${log_file}' tcpdump for f1ap
    ${executor_oam_vm}    Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
    Start Tcpdump    name=${log_file}    options= -i any -C 300    remote_info=${executor_oam_vm}

Stop collect f1ap
    [Arguments]     ${log_file}
    Log To Console    Stop collect '${log_file}' tcpdump for f1ap
    Stop Tcpdump    ${log_file}    ${TEST_LOG_DIRECTORY()}/All/${log_file}

Start Collecting GNB Syslog in '${file_name}' File
    [Documentation]    This keyword is to start GNB and AP Syslog
    ...    Examples:
    ...    | Start Collect GNB and AP Syslog in 'syslog' File|
    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/${file_name}
    ...    log_name=${file_name}_gnb    ip=${GNB_SYSLOG.ip}    alias=collect_gnb

Stop Collecting GNB Syslog in '${file_name}' File
    [Documentation]    This keyword is to stop GNB and AP Syslog
    ...    Examples:
    ...    | Stop Collect GNB and AP Syslog in 'syslog' File |
    ute_syslog.Collect Syslog Results    alias=collect_gnb    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}${file_name}${/}${file_name}_gnb.tar.gz

Start Capture Gnb Syslogs in '${file_name}' file
    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/All/syslog_${file_name}
    ...    log_name=${file_name}_gnb    ip=${GNB_SYSLOG.ip}    alias=collect_gnb

Stop Capture Gnb Syslogs in '${file_name}' file
    run keyword and continue on failure    check_err_wrn_in_btslog    ${TEST_LOG_DIRECTORY()}${/}All${/}syslog_${file_name}${/}    ${file_name}
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${TEST_LOG_DIRECTORY()}${/}All${/}syslog_${file_name}${/}      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=1
    ...       Fail_Case=${False}       Clear_log=${False}
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
   ute_syslog.Collect Syslog Results    alias=collect_gnb    unzip=${False}
   ...    destination=${TEST_LOG_DIRECTORY()}${/}All${/}syslog_${file_name}${/}${file_name}_gnb.tar.gz
   OperatingSystem.Run      command=cd ${UTE_logs_path}; tar zcvf ${UTE_logs_path}/ERR_WRN_analysisafteronair.tgz *
   OperatingSystem.Run      command=cp ${UTE_logs_path}/ERR_WRN_analysisafteronair.tgz ${TEST_LOG_DIRECTORY()}${/}All${/}