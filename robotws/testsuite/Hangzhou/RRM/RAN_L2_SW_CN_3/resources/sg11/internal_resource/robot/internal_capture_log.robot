*** Settings ***
Library  ../python/check_btslog.py

*** Variables ***
${f}    /home/ute/


*** Keywords ***
Start capture gnb and ap syslog in '${file_name}' file
    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/${file_name}/syslog_${file_name}
    ...    log_name=${file_name}_gnb    ip=${GNB_SYSLOG.ip}    alias=collect_gnb
    ute_syslog.Start Syslog    file_limit=${AP_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/${file_name}/syslog_${file_name}
    ...    log_name=${file_name}_ap    ip=${AP_SYSLOG.ip}    alias=collect_ap

Stop capture gnb and ap syslog in '${file_name}' file
    check_err_wrn_in_btslog    ${TEST_LOG_DIRECTORY()}${/}${file_name}${/}syslog_${file_name}${/}    syslog_${file_name}
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}${file_name}   unzip=TRUE
    ute_syslog.Collect Syslog Results    alias=collect_gnb    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}${file_name}${/}syslog_${file_name}${/}${file_name}_gnb.tar.gz
    ute_syslog.Collect Syslog Results    alias=collect_ap    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}${file_name}${/}syslog_${file_name}${/}${file_name}_ap.tar.gz

Start capture only gnb syslog in '${file_name}' file
    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/All/syslog_${file_name}
    ...    log_name=${file_name}_gnb    ip=${GNB_SYSLOG.ip}    alias=collect_gnb

Stop capture only gnb syslog in '${file_name}' file
    check_err_wrn_in_btslog    ${TEST_LOG_DIRECTORY()}${/}All${/}syslog_${file_name}${/}    ${file_name}
    ute_syslog.Collect Syslog Results    alias=collect_gnb    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}All${/}syslog_${file_name}${/}${file_name}_gnb.tar.gz

Start collect bip log
    log to console    start collect bip log
    Get BIP Scripts Files    ${test_log_directory()}/bip_config
    ${status}    ${msg}    Run Keyword And Ignore Error    Variable Should Exist    ${GNBMIRRORINGCONFIG}
    Run Keyword If    '${status}'=='PASS'    Modify File List Paramters
    ...    ${test_log_directory()}/bip_config/gnbMirroringConfig.sh    ${GNBMIRRORINGCONFIG}
    Start GNB BIP Log    ${test_log_directory()}/bip_config

Wait for '${time}' to stop bip log with name'${bip_tag}'
    sleep   ${time}
    Stop GNB BIP Log    ${test_log_directory()}/All/${bip_tag}

Start collect ttitrace
    log to console    start collect ttitrace
    Start GNB Ttitrace With Streaming Mode

Wait for '${time}' to stop ttitrace with name'${tti_tag}'
    sleep   ${time}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}

Collect AP egate log
    [Arguments]    ${tag}
    Wait '2s' for stabible
    airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/${tag}_egate    unzip=TRUE

NSA get ue '${ue_id}' dl throughput
    ${nsa_dl_tput}    Airphone NSA Get Throughput    ${ue_id}     DL
    [Return]   ${nsa_dl_tput}

#Start collect '${name}' tcpdump
    #${executor_oam_vm}    Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
    #Start Tcpdump    name=${name}    options=tcpdump -w /tmp/${name}.pcap -i any -C 500M    remote_info=${executor_oam_vm}

Start collect '${name}' tcpdump
    ${executor_oam_vm}    Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
    Start Tcpdump    name=${name}    options= -i any    remote_info=${executor_oam_vm}

Stop collect '${name}' tcpdump
    Stop Tcpdump    ${name}    ${TEST_LOG_DIRECTORY()}/All

Stop egate log and unzip with name'${egate_tag}'
    Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_${egate_tag}    unzip=TRUE

start collect sosReport
    Log To Console    \n ***start sosReport***
    OperatingSystem.Run    cd ${test_log_directory()}&& /bin/bash /opt/wts/latest/startTest.sh > /dev/null 2>\&1

stop collect sosReport
    OperatingSystem.Run    cd ${test_log_directory()}&& /bin/bash /opt/wts/latest/stopTest.sh > /dev/null 2>\&1
    Log To Console    \n ***sosReport collect finish***

Start collect log by gnb tool
    [Arguments]    ${command}
    ${exist}    List Directory    /home/ute
    Run keyword if    'gnb_logs-tool' not in ${exist}    OperatingSystem.Run
    ...     cd ${f};git clone https://gitlabe1.ext.net.nokia.com/p5li/gnb_logs-tool;unzip -d ${f}gnb_logs-tool ${f}gnb_logs-tool/gnb_logs.zip
    OperatingSystem.Run    rm /home/ute/gnb_logs-tool/gnb_logs/stop_mon.log
    TAF_SSH.Connect To    127.0.0.1    ute    ute    alias=bsh
    TAF_SSH.Execute    chmod 777 /home/ute/gnb_logs-tool/gnb_logs/gnb_logs    connection=bsh
    TAF_SSH.Send Command    cd /home/ute/gnb_logs-tool/gnb_logs;${command}    connection=bsh
    TAF_SSH.Read Output Until    (Q)uit    connection=bsh

Stop collect log by gnb tool
#    Wait '${time}' for stable
    OperatingSystem.Run    touch /home/ute/gnb_logs-tool/gnb_logs/stop_mon.log
    Wait Until Keyword Succeeds    300    10    file should contain
    ...    /home/ute/gnb_logs-tool/gnb_logs/tool.log    Tool finished running

Start collect cplane bip
    [Arguments]     ${bip_file}
    Log To Console    Start collect '${bip_file}' tcpdump
    ${executor_oam_vm}    Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
    Start Tcpdump    name=${bip_file}    options= -i any -C 300    remote_info=${executor_oam_vm}

Stop collect cplane bip
    [Arguments]     ${bip_file}    ${save_to}
    Log To Console    Stop collect '${bip_file}' tcpdump
    Stop Tcpdump    ${bip_file}    ${save_to}
