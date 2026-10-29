*** Settings ***
Documentation
...  author: Jing Shengyuan

Library     String
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME   csn
Library     taf.collectors.core      WITH NAME   core
Library     taf.collectors.btslog    WITH NAME   btslog

#　Library     testsuite/Hangzhou/OAM/RAN_FRSMZ_ET/branches/22R4/CommonKeywords/btslog_collecting.robot

Resource   ../../common/taf_env.robot
Resource    ../../common/taf_coam.robot
Variables   ../../libraries/global_vars.py
Resource   ../CaseResource/5GC001196-E_5GC001542-GA_cases.robot


*** Variables ***
${test_vm_ip}   ${tl.test_pc.default_ssh_connection_details.addr}
${test_vm_user}   ${tl.test_pc.default_ssh_connection_details.username}
${test_vm_password}   ${tl.test_pc.default_ssh_connection_details.password}
&{executor_test_vm}   host=${test_vm_ip}   user=${test_vm_user}   password=${test_vm_password}
${MRBTS_ID}   ${tl.gnbs[0].instance_id}
${NRBTS_ID}   ${tl.gnbs[0].global_bts_id}
${MRBTS}   MRBTS-${MRBTS_ID}
${NRBTS}   NRBTS-${NRBTS_ID}
*** Keyword ***
Get Parameter Value from SCF
    [Arguments]  ${xpath}
    ${curr_date}   DateTime.Get Current Date   result_format=%Y%m%d_%H%M   exclude_millis=True
    ${SCF_name}   Set Variable   SCF_${curr_date}.xml
    ${alias}   COAM Login
    COAM Backup SCF   file_name=${SCF_name}
    ${xml}   XML.Parse XML   ${OUTPUT_DIR}/${SCF_name}
    ${value}   XML.Get Element Text   ${xml}   xpath=${xpath}
    [Return]  ${value}
    [Teardown]  Run keyword And Ignore Error   COAM Logout   connection=${alias}

Check Parameter Value from SCF
    [Arguments]  ${xpath}   ${expected_value}
    ${value}   Get Parameter Value from SCF   xpath=${xpath}
    Should Be Equal   ${expected_value}   ${value}

Modify Parameter via COAM Admin
    [Arguments]   ${dist_name}   ${parameter}   ${value}
    COAM Login
    COAM Update Parameter   dist_name=${dist_name}   parameter=${parameter}   value=${value}
    [Teardown]  Run keyword And Ignore Error   COAM Logout

Perform Delta Recommission via COAM Admin
    [Arguments]  ${delta_plan}
    COAM Login
    COAM Perform Delta Recommission   delta_file=${delta_plan}
    [Teardown]  Run keyword And Ignore Error   COAM Logout

Configure Common configuration And Activate it in Debug Trace
    [Arguments]  ${source_ip}   ${DSCP}   ${UPlane_destination}
    coam.configure_logging_agent   source_ip=${source_ip}   dscp=${DSCP}   uplane_destination=${UPlane_destination}

Start BTS Syslog Collection
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


Stop BTS Syslog Collection
	Run Keyword And Ignore Error   core.stop_collectors   names=btslog
    ${curr_date}   DateTime.Get Current Date
    ${datetime}   DateTime.Convert Date   ${curr_date}   datetime
    Set Suite Variable   ${date_str}   ${datetime.year}${datetime.month}${datetime.day}_${datetime.hour}${datetime.minute}
    csn.Connect To   hostname=${test_vm_ip}   username=${test_vm_user}   password=${test_vm_password}   alias=TestVM
    csn.Execute   command=cd /tmp/btslog2 ; ls -al; cat SYSLOG_*.LOG > SYSLOG_combine_${date_str}.LOG   connection=TestVM
    csn.Download File
    ...   remote_path=/tmp/btslog2/SYSLOG_combine_${date_str}.LOG
    ...   local_path=${OUTPUT_DIR}/SYSLOG_combine_${date_str}.LOG
    ...   connection=TestVM
    csn.Execute   command=rm -rf /tmp/btslog2/SYSLOG_*   connection=TestVM
    [Return]   ${date_str}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=TestVM


Remove Syslog From TestVM
	Run Keyword And Ignore Error   core.stop_collectors   names=btslog
    csn.Connect To   hostname=${test_vm_ip}   username=${test_vm_user}   password=${test_vm_password}   alias=TestVM
    csn.Execute   command=mkdir /tmp/btslog2   connection=TestVM
    csn.Execute   command=cd /tmp/btslog2;rm -rf BTSLOG_TRACE_*.bin;rm -rf SYSLOG_*.LOG   connection=TestVM
    csn.Execute   command=rm -rf /tmp/BTSLogCommandsLocalServer   connection=TestVM
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=TestVM

Save gNB Snapshot
    [Arguments]  ${host}=${WEBUI_ADDR}   ${alias}=gNB
    log to console    Save Snapshot logs
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    COAM Login   bts_host=${host}   alias=${alias}
    Run Keyword And Ignore Error   taf_coam.Catch Snapshot COAM   local_file_path=${OUTPUT_DIR}/snapshot_${curr_data}.zip    connection=${alias}
    [Teardown]   run keyword and ignore error    COAM Logout   connection=${alias}
