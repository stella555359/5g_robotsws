*** Settings ***
Documentation    Author: xiaofei.li@nokia-sbell.com
Resource   ./taf_coam.robot
Resource   ./taf_env.robot
Resource   ./L3_Call.robot

Library   taf.collectors.btslog   WITH NAME   btslog
Library   taf.collectors.core   WITH NAME   core
Library   DateTime
Variables   ../libraries/global_vars.py

*** Variables ***
${call_port}   ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
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
    run keyword and ignore error   run  command=ps -ef |grep btslog |grep -v grep |awk '{print $2}' |xargs kill -9
    BuiltIn.sleep   1s
    run keyword and ignore error   run   command=mkdir /tmp/btslog2
    BuiltIn.sleep   1s
    run keyword and ignore error   run   command=cd /tmp/btslog2;${cmd_prefix}rm -rf BTSLOG_TRACE_*.bin;${cmd_prefix}rm -rf SYSLOG_*.LOG
    BuiltIn.sleep   2s
    run keyword and ignore error   run   command=${cmd_prefix}rm -rf /tmp/BTSLogCommandsLocalServer
    BuiltIn.sleep   2s
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    btslog.Set Global Alias     btslog
    core.setup_collectors      names=btslog
    core.start_collectors      names=btslog
    BuiltIn.sleep   3s
    ${case_syslog}   run   command=ls -l /tmp/btslog2/SYSLOG_*.LOG |awk '{print $5}'
    Should Be True   ${case_syslog} > 0

Stop and Save BTS Log Collection
    [Documentation]  Stop BTSlogs Collection and get logs
    ${cmd_prefix}   Get Super Command Startup
    core.Teardown Collectors      names=btslog
    ${curr_date_str}   DateTime.Get Current Date
    ${curr_date}   DateTime.Convert Date   ${curr_date_str}   datetime
    ${date_str}   Set Variable   ${curr_date.year}${curr_date.month}${curr_date.day}_${curr_date.hour}${curr_date.minute}
    run   command=cd /tmp/btslog2;ls -al;${cmd_prefix}cat SYSLOG_*.LOG > SYSLOG_combine_${date_str}.LOG
    BuiltIn.sleep  3s
    ${tmpsyslogs}   run   command=ls -l /tmp/btslog2/SYSLOG_combine_${date_str}.LOG|awk '{print $5}'
    BuiltIn.sleep  1s
    run    command=cd /tmp/btslog2;${cmd_prefix}cp SYSLOG_combine_${date_str}.LOG ${TS_CASE_LOG_PATH}
    BuiltIn.sleep  3s
    ${casesyslogs}   run   command=ls -l /tmp/btslog2/SYSLOG_combine_${date_str}.LOG ${TS_CASE_LOG_PATH}|awk '{print $5}'
#    BuiltIn.sleep  1s
#    Run Keyword If   ${tmpsyslogs}>${casesyslogs}  Run   command=cd /tmp/btslog2; ${cmd_prefix}cp SYSLOG_combine_${date_str}.LOG ${TS_CASE_LOG_PATH}
#    BuiltIn.sleep  1s
    Run   command=cd /tmp/btslog2; ${cmd_prefix}rm -rf SYSLOG_*.LOG
    [Return]   ${TS_CASE_LOG_PATH}/SYSLOG_combine_${date_str}.LOG

Stop and Delete BTS log in VM
    [Documentation]  Delete BTSlogs in VM
    ${cmd_prefix}   Get Super Command Startup
    run keyword and ignore error   core.Teardown Collectors      names=btslog
    run    command=cd /tmp/btslog2 ; ${cmd_prefix}rm -rf SYSLOG_*

Case Common Setup
    Wait Until Keyword Succeeds   3 times   2m   COAM Login
    Wait Until Keyword Succeeds   3 times   2m   COAM WEBUI Login
    Close Web Startup View Window
    Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir   connection=COAM
    run keyword and ignore error   Start Catch Relative Log   log_dir_name=${TEST NAME}
    run keyword and ignore error   Remove Cell Trace Object
#    Make L3 Call

Case Common Teardown
    run keyword if test failed  Collect Relative Log
    run keyword if test passed   Delete BTS log in VM
    COAM WEBUI Logout
    COAM Logout
#
#Make L3 Call
#    ${ue_return}   Call Setup and check tput   band=100   port=${call_port}   tput_expect=0

Start Catch Relative Log
    [Arguments]   ${log_dir_name}=${SUITE_NAME.replace(" ", "_")}
    Generate Log Path   log_dir_name=${log_dir_name}
    run keyword and ignore error   Start BTS Log Collection

Collect Relative Log
    run keyword and ignore error   Stop and Save BTS Log Collection
    run keyword and ignore error   Catch Snapshot COAM   local_file_path=${TS_CASE_LOG_PATH}/snapshot.zip    connection=COAM

Prepare Power UE
    [Arguments]   ${ue_index}=${ue_index}
    UE precondition   ue_index=${ue_index}
    run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}




