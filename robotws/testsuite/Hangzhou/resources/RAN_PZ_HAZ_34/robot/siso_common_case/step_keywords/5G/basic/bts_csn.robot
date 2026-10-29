*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/csn.robot
Resource   taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot

*** Keywords ***
Check quantity of RD files on BTS
    csn.connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
    csn.Send Command    ls /tmp |grep RD.BTS    connection=ASIK Master
    ${files}=    csn.read_output    connection=ASIK Master
    @{files_list}=    Split String    ${files}    \n
    ${num_of_files}    Get Length    ${files_list}
    Should Be True    ${num_of_files}>1
    [Teardown]    csn.disconnect    connection=ASIK Master

Check Alarm Exist in RawAlarmHistory
    [Arguments]    ${alarm_filter}
    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=ASIK
    csn.send_command    command=cat /tmp/RawAlarmHistory.txt | grep ${alarm_filter}    connection=ASIK
    sleep    2s
    ${alarms_string}    csn.read output    connection=ASIK
    csn.disconnect    connection=ASIK
    Should Contain    ${alarms_string}    ${alarm_filter}

Get RU Uptime Result
    [Arguments]    ${ru_alias}=RU
    ${server_time}    csn.execute    uptime head |awk '{print $1}'    connection=${ru_alias}
    ${time_temp}   csn.execute    uptime    connection=${ru_alias}
    ${pattern}   Set Variable    up\\s{1,2}(.*),\\s{2}
    ${up_time}    Get Regexp Matches     ${time_temp}    ${pattern}    1
    ${uptime}   Set Variable    ${up_time}[0]
    [Return]      ${server_time}    ${uptime}

Get cpri Link State from BTSOM
    connect to common unit master
    ${cmd_grep}   Set Variable   startup_BTSOM.log | grep "API_L1SW_CPRI_STATE_IND_MSG received for link"
    ${status}   get cpri online
    run keyword if    '${status}'=='False'    get cpri offline
    ${output_links}   Run Keyword If   ${status}   csn.Execute   command=cat /tmp/${cmd_grep}   connection=ASIK Master
    ...   ELSE   OperatingSystem.Run   cat ${SAVE LOG DIRECTORY}/${cmd_grep}
    [Teardown]   csn.Disconnect   connection=ASIK Master
    [Return]   ${output_links}

get cpri online
    ${file_path}   csn.Execute   command=find /tmp/ -name startup_BTSOM.log   connection=ASIK Master    timeout=60s
    ${status}   Run Keyword and Return Status   Should Not Be Empty   ${file_path}
    [Return]   ${status}

get cpri offline
    ${file_path}   csn.Execute   command=find /ffs/run/ -name startup_BTSOM.log.xz   connection=ASIK Master    timeout=60s
    Should Not Be Empty   ${file_path}
    csn.Download File   remote_path=${file_path.splitlines()[0]}   local_path=${SAVE LOG DIRECTORY}/startup_BTSOM.log.xz
    ...    connection=ASIK Master
    OperatingSystem.Run   xz -dvf ${SAVE LOG DIRECTORY}/startup_BTSOM.log.xz

Download SW
    [Arguments]    ${SW}=${Active_SW_version}    ${package_store_path}=${SAVE LOG DIRECTORY}
    ${sw_name}    ${sw_full_url}    get sw name    SW=${SW}
    ${status}          run keyword and return status    file should exist  ${package_store_path}/${sw_name}
    run keyword if      ${status}    remove file    ${package_store_path}/${sw_name}
    ${sw_url}          Catenate    sudo wget ${sw_full_url} -nv -P ${package_store_path}
    ${res}             Run         ${sw_url}
    ${status}          run keyword and return status    file should exist  ${package_store_path}/${sw_name}
    should be true    ${status}
    [Return]    ${sw_name}

Remove Downloaded Content
    [Arguments]    ${NEW_SW_PKG}    ${OLD_SW_PKG}    ${package_store_path}=${SAVE LOG DIRECTORY}
    ${RM1}=         Catenate    rm -rf ${package_store_path}/${NEW_SW_PKG}
    ${RM2}=         Catenate    rm -rf ${package_store_path}/${OLD_SW_PKG}
    ${RM3}=         catenate    rm -rf ${package_store_path}/index.html
    Run Process     ${RM1}      timeout=5min    shell=True
    Run Process     ${RM2}      timeout=5min    shell=True
    Run Process     ${RM3}      timeout=5min    shell=True

delete Downloaded
    [Arguments]    ${SW_PKG}    ${package_store_path}=${SAVE LOG DIRECTORY}
    ${RM}=         Catenate    rm -rf ${package_store_path}/${SW_PKG}
    Run Process     ${RM}      timeout=5min    shell=True

Change active partition
    log to console  start Change active partition
    Connect to Common Unit Master
    ${active_partition}=    csn.execute     uboot_env get active_partition    connection=ASIK Master
    ${partition_nr1}=        Fetch From Right    ${active_partition}    =
    ${partition_nr2}=        fetch from left     ${partition_nr1}       \r
    ${wanted_partition}=    Set Variable If
    ...     ${partition_nr2}==1        2
    ...     ${partition_nr2}==2        1
    ${new_partition}=       Catenate    uboot_env set active_partition=${wanted_partition}
    csn.execute     ${new_partition}    connection=ASIK Master
    csn.disconnect    connection=ASIK Master

Download luashark from Artifactory and Extract
    [Arguments]   ${SW}=${Active_SW_version}    ${package_store_path}=${SAVE LOG DIRECTORY}
    ${sw_url}=    Catenate     sudo wget ${arti}${SW}/luashark-${SW}.zip  -nv -P ${package_store_path}
    log to console  download luashark-${SW}.zip from artifactory
    ${res}=       Run         ${sw_url}
    Run  unzip ${package_store_path}/luashark-${SW}.zip -d ${package_store_path}/luashark-${SW}
    ${lua_script_path}    set variable    ${package_store_path}/luashark-${SW}/generated_luashark/luashark.lua
    [Return]  ${lua_script_path}

Check fault Exist in faultlog in snapshot
    [Arguments]    ${ru_log_path_in_snapshot}    ${fault_filter}
    ${snapshot_alarms_string}    Run    command=cat ${ru_log_path_in_snapshot}/snapshot_status.txt
    sleep    2s
    Should Contain    ${snapshot_alarms_string}    ${fault_filter}
    [Return]    ${snapshot_alarms_string}

Check reset cause in snapshot
    [Arguments]    ${ru_log_path_in_snapshot}    ${fault_filter}=reset cause
    Extract Zip File    ${ru_log_path_in_snapshot}/1/1.zip
    ...                 ${ru_log_path_in_snapshot}/1/1
    Extract Zip File    ${ru_log_path_in_snapshot}/1/1/1011_startup.zip
    ...                 ${ru_log_path_in_snapshot}/1/1/1011_startup
    Run    command=cd ${ru_log_path_in_snapshot}/1/1/1011_startup;unxz startup_DEFAULT.log.xz
    ${reset_info}    Run    command=cat ${ru_log_path_in_snapshot}/1/1/1011_startup/startup_DEFAULT.log | grep "${fault_filter}"
    Should Contain    ${reset_info}    ${fault_filter}

get RFSW version from TargetBD
    [Arguments]   ${radio_type}   ${Radio_Protocol_Type}   ${active_version}
    ${TargetBD_FileName}   ${save_path}    check TargetBD exist and match    active_version=${active_version}
    set test variable    ${resBuild_key}    LTX_${radio_type}
    ${cmd_grep}   set variable   cat '${save_path}/${TargetBD_FileName}'|grep 'hwResource resourceBuildKey="${resBuild_key}'
    ${result}=    Run Process    ${cmd_grep}    shell=True   timeout=30s   alias=myproc
    ${output_resBuildKey}=    Get Process Result     myproc
    @{ru_version}    Get Regexp matches    ${output_resBuildKey.stdout}    resourceSWVersion="(.*)"    1
    ${version_length}    get length    ${ru_version}
    ${ruSW_TargetBD}    set variable if    ${version_length}==${1} or '${Radio_Protocol_Type}'=='CPRI'    ${ru_version}[0]
    ...    ${ru_version}[1]
    [Return]    ${ruSW_TargetBD}

check TargetBD exist and match
    [Arguments]   ${active_version}
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}   alias=gNB_target
    sleep   2s
    csn.send command    command=cd /ffs/run/;ls TargetBD_*.xml    connection=gNB_target
    ${TargetBD_FileName}=    csn.read output    connection=gNB_target
    run keyword and ignore error    csn.download file
    ...    /ffs/run/TargetBD_${active_version}.xml    ${SAVE LOG DIRECTORY}/TargetBD_${active_version}.xml
    ...    connection=gNB_target
    csn.disconnect    connection=gNB_target
    @{TargetBD_FileName}    string.split string    ${TargetBD_FileName}    separator=\
    ${TargetBD_FileName}    set variable    ${TargetBD_FileName}[0]
    should be equal as strings    '${TargetBD_FileName}'   'TargetBD_${active_version}.xml'
    ${save_path}    set variable    ${SAVE LOG DIRECTORY}
    [Return]    ${TargetBD_FileName}    ${save_path}

Extract fault logs from snapshot
    [Arguments]    ${snapshot_file}    ${fault_id}=1247
    ${timestamp}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    ${zipout}    Set Variable    zipout_${timestamp}
    Extract Zip File    ${snapshot_file}    ${TS_CASE_LOG_PATH}/${zipout}
    ${faurt_log_path}    Run    command=cd ${TS_CASE_LOG_PATH}/${zipout};ls -l | grep faultLogs | awk '{print $9}'
    Extract Zip File    ${TS_CASE_LOG_PATH}/${zipout}/${faurt_log_path}
    ...                 ${TS_CASE_LOG_PATH}/${zipout}/${faurt_log_path.split(".zip")[0]}
    ${snapshot_alarms_string}    Check fault Exist in faultlog in snapshot
    ...    ru_log_path_in_snapshot=${TS_CASE_LOG_PATH}/${zipout}/${faurt_log_path.split(".zip")[0]}
    ...    fault_filter=${fault_id}
    ${status}    Run Keyword And Return Status    Check reset cause in snapshot
    ...    ru_log_path_in_snapshot=${TS_CASE_LOG_PATH}/${zipout}/${faurt_log_path.split(".zip")[0]}
    Run Keyword If    ${status}==${False}
    ...    log to console  \n Fail to check reset cause in snapshot
    [Return]    ${snapshot_alarms_string}

Extract fault logs from snapshot RF7
    [Arguments]    ${snapshot_file}    ${fault_id}=1247   ${ru_index}=1
    &{ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}   connection=GNB_OAM
    ${serial_number}    Set Variable    ${ru_info['serialNumber']}
    ${timestamp}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    ${zipout}    Set Variable    zipout_${timestamp}
    Extract Zip File    ${snapshot_file}    ${TS_CASE_LOG_PATH}/${zipout}
    ${faurt_log_path}    Run    command=cd ${TS_CASE_LOG_PATH}/${zipout};ls -l | grep faultLogs | awk '{print $9}'
    ${faurt_log_not_in_btspart}  Run Keyword And Return Status   Should Not Be Empty   ${faurt_log_path}
    ${output}   OperatingSystem.get file    ${TS_CASE_LOG_PATH}/${zipout}/snapshot_file_list.txt
    ${pattern}   Set Variable    BTS_part(\\d+).zip:[^:]*BTS_${serial_number}_RMOD_L_${ru_index}_faultLogs.zip
    ${btspart_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${faurt_log_in_btspart}  Run Keyword And Return Status   Should Not Be Empty   ${btspart_list}
    ${btspart}  Set Variable If   ${faurt_log_in_btspart}  BTS_part${btspart_list}[0]
#    ${faurt_log_path}  Run Keyword And Return Status   Should Not Be Empty   ${btspart_list}
    Run Keyword If  ${faurt_log_not_in_btspart}   Extract Zip File    ${TS_CASE_LOG_PATH}/${zipout}/${faurt_log_path}
    ...                 ${TS_CASE_LOG_PATH}/${zipout}
    ...   ELSE IF  ${faurt_log_in_btspart}    Run Keywords  Extract Zip File    ${TS_CASE_LOG_PATH}/${zipout}/${btspart}.zip
    ...                 ${TS_CASE_LOG_PATH}/${zipout}  AND
    ...               Extract Zip File    ${TS_CASE_LOG_PATH}/${zipout}/BTS_${serial_number}_RMOD_L_${ru_index}_faultLogs.zip
    ...                 ${TS_CASE_LOG_PATH}/${zipout}
    ${snapshot_alarms_string}    Check fault Exist in faultlog in snapshot
    ...    ru_log_path_in_snapshot=${TS_CASE_LOG_PATH}/${zipout}
    ...    fault_filter=${fault_id}
#    ${status}    Run Keyword And Return Status    Check reset cause in snapshot
#    ...    ru_log_path_in_snapshot=${TS_CASE_LOG_PATH}/${zipout}/${faurt_log_path.split(".zip")[0]}
#    Run Keyword If    ${status}==${False}
#    ...    log to console  \n Fail to check reset cause in snapshot
    [Return]    ${snapshot_alarms_string}
