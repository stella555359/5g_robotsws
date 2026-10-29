*** Settings ***
Documentation    Author: xiaofei.li@nokia-sbell.com
Library     taf.collectors.btslog       WITH NAME    btslog
Library     taf.collectors.core         WITH NAME    core
Library     DateTime
Library    taf.analyzer.pcap   WITH NAME   wireshark
Resource   ../../common/taf_coam.robot
Resource   ../../common/taf_env.robot
Resource   ../../common/L3_Call.robot
Resource   coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/symptom_collectors_hangzhou.robot
Variables   ../../libraries/global_vars.py

*** Variables ***
${ue_index}   0

*** Keywords ***
Generate Log Path
    [Documentation]     Generate log path
    [Arguments]   ${log_dir_name}=${EMPTY}
    ${log_path}  Set Variable   ${OUTPUT_DIR}
    ${case_log_path}   Run Keyword If  '${log_dir_name}'==''   Set Variable   ${log_path}
    ...   ELSE   Join path    ${Log_PATH}    ${log_dir_name}
    ${timestamp}    DateTime.Get current date    result_format=%Y%m%d_%H%M%S
    ${case_log_path}    Join path    ${case_log_path}    ${timestamp}
    Create directory   ${case_log_path}
    set suite variable   ${TS_CASE_LOG_PATH}    ${case_log_path}

Start BTS Log Collection
    ${cmd_prefix}   Get Super Command Startup
    run keyword and ignore error    run    command=mkdir /tmp/btslog2
    run keyword and ignore error    run    command=cd /tmp/btslog2;${cmd_prefix}rm -rf BTSLOG_TRACE_*.bin;${cmd_prefix}rm -rf SYSLOG_*.LOG
    run keyword and ignore error    run    command=${cmd_prefix}rm -rf /tmp/BTSLogCommandsLocalServer
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    btslog.Set Global Alias     btslog
    core.setup_collectors      names=btslog
    core.start_collectors      names=btslog

Stop BTS Log Collection
    [Documentation]  Stop BTSlogs Collection and get logs
    core.stop_collectors      names=btslog
    ${curr_date}   DateTime.Get Current Date
    ${datetime}   DateTime.Convert Date   ${curr_date}   datetime
    ${date_str}   Set Variable   ${datetime.year}${datetime.month}${datetime.day}_${datetime.hour}${datetime.minute}
    run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine_${date_str}.LOG
    run    command=cd /tmp/btslog2 ; cp SYSLOG_combine_${date_str}.LOG ${TS_CASE_LOG_PATH}
    run    command=cd /tmp/btslog2 ; rm -rf SYSLOG_*

Delete BTS log in VM
    [Documentation]  Delete BTSlogs in VM
    run keyword and ignore error   core.stop_collectors      names=btslog
    run    command=cd /tmp/btslog2 ; rm -rf SYSLOG_*

Start Catch Relative Log
    [Arguments]   ${log_dir_name}=${SUITE_NAME.replace(" ", "_")}
    Generate Log Path   log_dir_name=${log_dir_name}
    run keyword and ignore error   Start BTS Log Collection

Collect Relative Log
    run keyword and ignore error   Capature Sreenshot COAM
    run keyword and ignore error   Stop BTS Log Collection
    Run Keyword and Ignore Error   COAM Logout
    COAM Login
    run keyword and return status   Catch Snapshot COAM   local_file_path=${TS_CASE_LOG_PATH}/snapshot.zip

Prepare Power UE
    [Arguments]   ${ue_index}=${ue_index}
    UE precondition   ue_index=${ue_index}
    run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

Start Save Tcpdump
    [Arguments]   ${ipadd}    ${tcpdumpfile}
    asik_handler.connect                i_ipAddr=${ipadd}
    log to console    start tcpdump
    asik_handler.general_tcpdump_ASIB        ${remote_dir_path}      ${tcpdumpfile}

Stop Save Tcpdump
    [Arguments]   ${ipadd}   ${tcpdumpfile}
    asik_handler.connect                i_ipAddr=${ipadd}
    log to console    stop tcpdump
    asik_handler.kill_tcpdump
    asik_handler.download_file_from_Asik	${remote_dir_path}/${tcpdumpfile} 	 ${Log_directory}/${tcpdumpfile}
    Run keyword and Ignore error  asik_handler.close

Create Btslog log collection on remote machine for PCMD
    [Arguments]    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog
    ...             ${btslog_launcher_path}=/opt/btslog/btslog_launcher          ${log_dir}=/tmp/
    ...             ${host}=${tl.test_pc.default_ssh_connection_details.addr}
    ...             ${user}=${tl.test_pc.default_ssh_connection_details.username}
    ...             ${password}=${tl.test_pc.default_ssh_connection_details.password}
    [Documentation]    create btslog log collector on testvm.
    ...                name: name of the collector. Ex: btslog
    ...                btslog_path: (optional) path of the ‘btslog’ executable default value:”/opt/btslog/btslog”
    ...                btslog_launcher_path: (optional) path of ‘btslog_launcher’
    ...                executable default value:”/opt/btslog/btslog_launcher”
    ...                log_dir: path from where to get btslog files default value: “/tmp/btslog2”
    run keyword and ignore error   Clean BTSlog on Remote Machine   host=${host}   user=${user}   password=${password}
    &{executor}=    create dictionary    host=${host}
    ...                                  user=${user}
    ...                                  password=${password}
    btslog.create_btslog_collector       name=${name}          btslog_path=${btslog_path}
    ...                                  btslog_launcher_path=${btslog_launcher_path}
    ...                                  executor=${executor}    log_dir=${log_dir}
    btslog.Set Suite Alias               ${name}
    core.setup_collectors                names=${name}
    core.start_collectors                names=${name}

Clean BTSlog on Remote Machine
    [Arguments]  ${host}   ${user}   ${password}
    ${cmd_prefix}   Set Variable If   '${user}'=='root'   ${EMPTY}   sudo${SPACE}
    csn.Connect to   hostname=${host}   username=${user}   password=${password}  alias=testpc
    csn.Execute   command=${cmd_prefix}pkill -9 -f -x '/opt/btslog/btslog -NOGUI'   connection=testpc
    csn.Execute   command=${cmd_prefix}rm -rf /tmp/BTSLogCommandsLocalServer    connection=testpc
    [Teardown]   csn.Disconnect   connection=testpc

Stop And Download And Remove BTS LOG Collection
    [Arguments]    ${dir}   ${name}=btslog   ${host}=${tl.test_pc.default_ssh_connection_details.addr}   ${user}=ute   ${password}=ute
    log to console    Stop And Download And Remove BTS LOG Collection On Gnb And Rus
    ${collect_status}   run keyword and return status   Collect_logs    names=${name}
    run keyword if  not ${collect_status}   Log   Collect logs failed on ${host}   WARN
    ${download_status}   run keyword and return status   Download Btslog To Log Path    dir=${dir}    TAF_ADDR=${host}
    ...   TAF_USERNAME=${user}    TAF_PASSWORD=${password}
    run keyword if  not ${download_status}   Log   Download logs failed on ${host}   WARN
    ${remove_status}   run keyword and return status   Remove Btslog From Temp Folder    TAF_ADDR=${host}
    ...   TAF_USERNAME=${user}    TAF_PASSWORD=${password}
    run keyword if  not ${remove_status}   Log   Remove logs failed on ${host}  WARN

Stop And Remove BTS LOG Collection
    [Arguments]    ${dir}   ${name}=btslog   ${host}=${tl.test_pc.default_ssh_connection_details.addr}   ${user}=ute   ${password}=ute
    LOG    ${dir}
    log to console    Stop And Download And Remove BTS LOG Collection On Gnb And Rus
    ${collect_status}   run keyword and return status   Collect_logs    names=${name}
    run keyword if  not ${collect_status}   Log   Collect logs failed on ${host}   WARN
    ${remove_status}   run keyword and return status   Remove Btslog From Temp Folder    TAF_ADDR=${host}
    ...   TAF_USERNAME=${user}    TAF_PASSWORD=${password}
    run keyword if  not ${remove_status}   Log   Remove logs failed on ${host}  WARN

Download Btslog To Log Path
    [Arguments]   ${dir}   ${TAF_ADDR}   ${TAF_USERNAME}    ${TAF_PASSWORD}
    ${connection_asik}=  csn.connect_to    hostname=${TAF_ADDR}    username=${TAF_USERNAME}    password=${TAF_PASSWORD}    alias=taf
    run keyword and ignore error   csn.Execute    command=cd /tmp/btslog2;tar -cvf btslog_${TAF_ADDR}.tar SYSLOG*   connection=taf
    run keyword and ignore error   csn.Download File    remote_path=/tmp/btslog2/btslog_${TAF_ADDR}.tar
    ...    local_path=${dir}/btslog_${TAF_ADDR}.tar   connection=taf
    sleep   3s
    csn.disconnect    connection=taf

Remove Btslog From Temp Folder
    [Arguments]   ${TAF_ADDR}   ${TAF_USERNAME}    ${TAF_PASSWORD}
    ${connection_asik}=  csn.connect_to    hostname=${TAF_ADDR}    username=${TAF_USERNAME}    password=${TAF_PASSWORD}    alias=taf
    run keyword and ignore error   csn.Execute    command=rm -rf /tmp/btslog2/btslog_${TAF_ADDR}.tar   connection=taf
    run keyword and ignore error   csn.Execute    command=ll /tmp/btslog2/;rm -rf /tmp/btslog2/SYSLOG*   connection=taf
    run keyword and ignore error   csn.Execute    command=rm -rf /tmp/btslog2/BTSLOG_TRACE*   connection=taf
    csn.disconnect    connection=taf
