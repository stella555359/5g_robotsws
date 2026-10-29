*** Settings ***
Documentation
...    SISO Common Resource files


#Library  ute_admin
#Library  ute_admin_infomodel
#Library  ute_syslog
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    csn

*** Keywords ***

Logging Restart
    [Arguments]   ${logs_dir_path}    ${release}    ${host_ip}=${EMPTY}
    ...    ${test_status}=PASS    ${host_ip}=${EMPTY}    ${alias}=default    ${save_log}=ALWAYS
    [Documentation]  ADDS SUITE VARIABLES: ${TEST_LOGS_DIR_PATH}
    Logging Stop  logs_dir_path=${logs_dir_path}
    ...           test_status=${test_status}
    ...           alias=${alias}
    ...           save_log=${save_log}
    Logging Start    ${logs_dir_path}    ${release}    host_ip=${host_ip}    alias=${alias}

Logging Save
    [Arguments]    ${logs_dir_path}    ${test_status}=PASS  ${save_log}=ALWAYS    ${alias}=default
    ${date}    Get Current Date    result_format=%Y%m%d%H%M%S
    Run Keyword If  ("${test_status}"=="FAIL" and "${save_log}"=="FAIL") or "${save_log}"=="ALWAYS"
    ...   Run Keyword And Continue On Failure   Logging Save Snapshot    ${logs_dir_path}/${CASE_NAME}_${date}       alias=${alias}
    Run Keyword If    ("${test_status}"=="FAIL" and "${save_log}"=="FAIL") or "${save_log}"=="ALWAYS"
    ...   Run Keyword And Continue On Failure  core.collect_collectors    names=${alias}    target_dir=${logs_dir_path}/${CASE_NAME}_${date}

Logging Stop
    [Arguments]    ${logs_dir_path}    ${test_status}=PASS  ${save_log}=ALWAYS    ${alias}=default
    core.stop_collectors      names=${alias}
    Logging Save    ${logs_dir_path}    test_status=${test_status}  save_log=${save_log}    alias=${alias}
    core.teardown_collectors      names=${alias}
    coam.Teardown              ${alias}

Logging Save Snapshot
    [Arguments]    ${logs_dir_path}     ${alias}=default    ${coverage}=Full
    ${year}    ${month}    ${day}    ${hour}    ${min}    ${sec}    Get Time    year month day hour min sec
    ${target_file_name}    Set Variable
    ...    ${logs_dir_path}/Snapshot_${alias}_${year}-${month}-${day}-${hour}-${min}-${sec}.zip
    ${snapshot_succeeded}=
    ...    Run Keyword And Return Status  coam.Collect Snapshot
    ...    target_file_name=${target_file_name}
    ...    coverage=${coverage}
    ...    timeout=600
    ...    alias=${alias}
    Run Keyword If    not ${snapshot_succeeded}    Log    Snapshot could not be saved!    ERROR    console=True
    [Return]    ${target_file_name}
Is Logging Restart Needed
    [Arguments]  ${alias}=default
    ${admin_is_active}=     Run Keyword And Return Status  Assert Any   BTS        alias=${alias}
    ${logging_stop_and_start_needed}=  Evaluate   not ${im_is_active} or not ${admin_is_active}
    [Return]   ${logging_stop_and_start_needed}

Logging Cleanup
    [Arguments]  ${alias}=${EMPTY}
    Run Keyword If  "${alias}"  Run Keywords
    ...    coam.Teardown     ${alias}
#    Teardown All Aliases For Syslog
    Run    sudo pkill -f NodeManagers*

Logging Start
    [Arguments]    ${logs_dir_path}    ${release}    ${host_ip}=${EMPTY}    ${tools_to_setup}=syslog_ADMIN    ${timeout}=120
    ...    ${alias}=default    ${update_interval}=5000
#    Run Keyword If  "syslog" in "${tools_to_setup}" and "${host_ip}"=="${EMPTY}"   Run Keyword
#    ...    Create And Start Local Btslog Collector    ${logs_dir_path}     ${timeout}    ${alias}    # AND
##    ...    Start Btslog Collector    ${timeout}    ${alias}
#    ...    ELSE IF   "syslog" in "${tools_to_setup}" and "${host_ip}"!="${EMPTY}"    Run Keyword
#    ...    Create And Start Remote Btslog Collector    ${logs_dir_path}     ${host_ip}    ${timeout}    ${alias}    #AND
#    ...    Start Btslog Collector    ${timeout}    ${alias}
    Run Keyword If  "syslog" in "${tools_to_setup}" and "${host_ip}"=="${EMPTY}"
    ...  Create And Start Local Btslog Collector     {logs_dir_path}     ${timeout}    ${alias}
    ...  ELSE IF    "syslog" in "${tools_to_setup}" and "${host_ip}"!="${EMPTY}"
    ...  Create And Start Remote Btslog Collector    ${logs_dir_path}     ${host_ip}    ${timeout}    ${alias}
    Run Keyword If  "ADMIN" in "${tools_to_setup}" and "${host_ip}"=="${EMPTY}" and "${release}"=="SBTS00"
    ...  coam.Setup Admin         bts_host=${BTS_HOST}
    ...                      bts_port=443
    ...                      update_interval=${update_interval}
    ...                      admin_api_log_dir=${logs_dir_path}/Admin_logs/
    ...                      timeout=${timeout}
    ...                      alias=${alias}
    ...  ELSE IF   "ADMIN" in "${tools_to_setup}" and "${host_ip}"!="${EMPTY}" and "${release}"=="SBTS00"
    ...  coam.Setup Admin         bts_host=${BTS_HOST}
    ...                      bts_port=443
    ...                      update_interval=${update_interval}
    ...                      admin_api_log_dir=${logs_dir_path}/Admin_logs/
    ...                      remote_host=${host_ip}
    ...                      timeout=${timeout}
    ...                      alias=${alias}
    ...  ELSE IF   "ADMIN" in "${tools_to_setup}" and "${host_ip}"=="${EMPTY}" and "${release}"!="SBTS00"
    ...  coam.Setup Admin         bts_host=${BTS_HOST}
    ...                      bts_port=443
    ...                      update_interval=${update_interval}
    ...                      admin_api_log_dir=${logs_dir_path}/Admin_logs/
    ...                      timeout=${timeout}
    ...                      alias=${alias}
    ...                      release=${release}
    ...  ELSE IF   "ADMIN" in "${tools_to_setup}" and "${host_ip}"!="${EMPTY}" and "${release}"!="SBTS00"
    ...  coam.Setup Admin         bts_host=${BTS_HOST}
    ...                      bts_port=443
    ...                      update_interval=${update_interval}
    ...                      admin_api_log_dir=${logs_dir_path}/Admin_logs/
    ...                      remote_host=${host_ip}
    ...                      timeout=${timeout}
    ...                      alias=${alias}
    ...                      release=${release}

Logging Start KPI
    [Arguments]    ${logs_dir_path}    ${release}    ${host_ip}=${EMPTY}    ${tools_to_setup}=syslog_ADMIN
    ...    ${timeout}=120    ${alias}=default
    Run Keyword If  "ADMIN" in "${tools_to_setup}" and "${host_ip}"=="${EMPTY}" and "${release}"=="SBTS00"
    ...  coam.Setup Admin         bts_host=${BTS_HOST}
    ...                      bts_port=443
    ...                      admin_api_log_dir=${logs_dir_path}/Admin_logs/
    ...                      timeout=${timeout}
    ...                      alias=${alias}
    ...  ELSE IF   "ADMIN" in "${tools_to_setup}" and "${host_ip}"!="${EMPTY}" and "${release}"=="SBTS00"
    ...  coam.Setup Admin         bts_host=${BTS_HOST}
    ...                      bts_port=443
    ...                      admin_api_log_dir=${logs_dir_path}/Admin_logs/
    ...                      remote_host=${host_ip}
    ...                      timeout=${timeout}
    ...                      alias=${alias}
    ...  ELSE IF   "ADMIN" in "${tools_to_setup}" and "${host_ip}"=="${EMPTY}" and "${release}"!="SBTS00"
    ...  coam.Setup Admin         bts_host=${BTS_HOST}
    ...                      bts_port=443
    ...                      admin_api_log_dir=${logs_dir_path}/Admin_logs/
    ...                      timeout=${timeout}
    ...                      alias=${alias}
    ...                      release=${release}
    ...  ELSE IF   "ADMIN" in "${tools_to_setup}" and "${host_ip}"!="${EMPTY}" and "${release}"!="SBTS00"
    ...  coam.Setup Admin         bts_host=${BTS_HOST}
    ...                      bts_port=443
    ...                      admin_api_log_dir=${logs_dir_path}/Admin_logs/
    ...                      remote_host=${host_ip}
    ...                      timeout=${timeout}
    ...                      alias=${alias}
    ...                      release=${release}

Create And Start Local Btslog Collector
    [Documentation]   Keyword start logging syslog using TAF method collectors.
    ...  Author:  piotr.korczynski@nokia.com
    [Arguments]    ${logs_dir_path}    ${timeout}    ${alias}
    Log    ${logs_dir_path}
    Log    ${timeout}
    btslog.create_btslog_collector
    ...   name=${alias}
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   target_file_name=${alias}_syslog
    core.setup_collectors      names=${alias}
    core.start_collectors      names=${alias}
    btslog.Set Suite Alias     ${alias}
    [Return]    ${alias}

Create And Start Remote Btslog Collector
    [Documentation]   Keyword start logging syslog using TAF method collectors on remote node.
    ...  Author:  piotr.korczynski@nokia.com
    [Arguments]    ${logs_dir_path}    ${host_ip}    ${timeout}    ${alias}
    Log    ${logs_dir_path}
    Log    ${timeout}
    ${executor_test_vm}=  Create Dictionary
    ...  host=${host_ip}
    ...  user=ute
    ...  password=ute
    btslog.create_btslog_collector
    ...   name=${alias}
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   executor=${executor_test_vm}
    ...   target_file_name=${alias}_syslog
    core.setup_collectors      names=${alias}
    core.start_collectors      names=${alias}
    btslog.Set Suite Alias     ${alias}

Stop Btslog Collector
    [Documentation]   Keyword stop logging syslog and save its files using TAF method collectors.
    ...  Author:  piotr.korczynski@nokia.com
    [Arguments]        ${logs_dir_path}    ${alias}
    core.stop_collectors      names=${alias}
    core.collect_collectors
    ...    names=${alias}
    ...    target_dir=${logs_dir_path}
    core.teardown_collectors      names=${alias}

Close Btslog Process
    [Arguments]    ${host_ip}    ${username}=ute    ${password}=ute
    csn.connect_to    hostname=${host_ip}    username=${username}    password=${password}    port=22    alias=close_btslog
    ${btslog_process}    csn.execute    ps -ef|grep btslog|grep -v grep|awk '{print $2}'|xargs kill -9    connection=close_btslog
#    ${btslog_process}    Strip String    ${btslog_process}
#    ${btslog_process_list}    Split String    ${btslog_process}    \r\n
#    FOR    ${process}    IN    @{btslog_process_list}
#        ${status}    Run Keyword And Return Status    Should Match Regexp    ${process}    /opt/btslog
#        Continue For Loop If    not ${status}
#        ${process_list}    Split String    ${process}
#        Run Keyword And Ignore Error    csn.execute    kill -9 ${process_list[1]}    connection=close_btslog
#    END
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=close_btslog

Close Node Process
    [Arguments]    ${host_ip}    ${username}=ute    ${password}=ute
    csn.connect_to    hostname=${host_ip}    username=${username}    password=${password}    port=22    alias=close_node
    csn.execute    killall node    connection=close_node
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=close_node
