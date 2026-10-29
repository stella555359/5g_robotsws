# *** Settings ***
# Suite Setup          Run Keywords    7914 SISO Coam Suite Setup
# Suite Teardown       7914 SISO Coam Suite Teardown
# Test Setup           7914 SISO Coam Test Setup
# Test Teardown        7914 SISO Coam Test Teardown
# Test Timeout         200 min
# 
# Resource    Resource/CB007914_common.robot
# Library    taf.sbts.oam.coam.admin       WITH NAME    coam
# Library      taf.pdu    WITH NAME    pdu
# Library      String
# Library     Resource/get_time.py
# Library     taf.transport.ssh      WITH NAME    csn
# Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/webui_coam.robot
# 
# Documentation
# ...    Author:chun.tian@nokia-sbell.com
# ...    contact:chun.tian@nokia-sbell.com
# ...    squad group:mmw04
# ...    Feature CB007914 in 5G21B program
# 
# Force Tags            5G_RAN    5G_RAN_TDD    STATE_GNB_COMMISSIONED    5G_CLASSICAL_ASIB_ABIL_AWHHD
# ...    PY36
# 
# *** Variables ***
# ${WEBUI_URL}        ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${ssh_user}        ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
# ${ssh_password}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
# ${current_name}     calibration_dlpath1
# ${new_name}         calibration_dlpatha
# ${fault_filter}     1247
# ${ru_index}     1
# ${type}     gNB
# ${package_21B}    SBTS21B_ENB_0000_000542_000000
# ${package_22R1}      SBTS00_ENB_9999_210713_000002
# ${21B_release}     000542
# ${22R1_release}    210713
# 
# 
# *** Test Cases ***
# [1]5GC007914-5G-A_001_Number_of_failure_logs_reported_in_snapshot_for_one_RU_during_1h
#      [Tags]    CRT_21B    CRT_TRUNK    CRT_22R1   CRT_22R2   1S-4D-2U
#      Modify RU SnapshotTimeoutS    SnapshotTimeoutS=3600
#      Trigger Alarm 1901     current_name=${current_name}    new_name=${new_name}    ru_index=${ru_index}
#      ${return_time}   ${retrun_fault}    Check fault Exist in snapshot
#      Check time in Snapshot and Web     retrun_fault=${retrun_fault}    return_time=${return_time}
#      Recovery Alarm 1901    current_name=${new_name}    new_name=${current_name}    ru_index=${ru_index}
#      [Teardown]   Run Keyword If Test Failed    Recovery Alarm 1901
#      ...    current_name=${new_name}    new_name=${current_name}    ru_index=${ru_index}
# 
# [1]5GC007914-5G-A_003_Snapshot_ Minor_level_showing_reason_for_a_failure_after_radio_has_been_had_a_power_break
#     [Tags]    CRT_21B    CRT_TRUNK    CRT_22R4    CRT_22R2    1S-4D-2U   CRT_22R3
#      Modify RU SnapshotTimeoutS      SnapshotTimeoutS=3600    new_timeout=160
#       Trigger Alarm 1901     current_name=${current_name}    new_name=${new_name}    ru_index=${ru_index}
#       Perform RU Power off
#       sleep    10s
#       Perform RU Power on
#       sleep    10min
#       ${searchName}     Get bts version
#       set suite variable   ${searchName}
#       ${return_time}   ${retrun_fault}    Check fault Exist in snapshot     searchName=${searchName}
#       Check time in Snapshot and Web     retrun_fault=${retrun_fault}    return_time=${return_time}
#       Recovery Alarm 1901    current_name=${new_name}    new_name=${current_name}    ru_index=${ru_index}
#      [Teardown]   Run Keyword If Test Failed    Recovery Alarm 1901
#      ...    current_name=${new_name}    new_name=${current_name}    ru_index=${ru_index}
# 
# [1]5GC007914-5G-A_004_Snapshot_Full_level_showing_reason_for_a_failure_after_radio_has_been_re-started
#     [Tags]    CRT_21B    CRT_TRUNK    CRT_22R4   CRT_22R2    1S-4D-2U
#      Modify RU SnapshotTimeoutS      SnapshotTimeoutS=3600    new_timeout=160
#      Trigger Alarm 1901     current_name=${current_name}    new_name=${new_name}    ru_index=${ru_index}
#      Perform RU Reset    ru_index=${ru_index}
#      sleep     10min
#      ${searchName}     Get bts version
#      set suite variable   ${searchName}
#      ${return_time}   ${retrun_fault}    Check fault Exist in snapshot     searchName=${searchName}
#      Check time in Snapshot and Web     retrun_fault=${retrun_fault}    return_time=${return_time}
#      Recovery Alarm 1901    current_name=${new_name}    new_name=${current_name}    ru_index=${ru_index}
#     [Teardown]   Run Keyword If Test Failed    Recovery Alarm 1901
#     ...    current_name=${new_name}    new_name=${current_name}    ru_index=${ru_index}
# 
# #[1]CB007914-5G-A_005_Snapshot_includes_RU_log_related_to_critical_failures_raise_any_time_early
# #    [Tags]    CRT_21B       1S-4D-2U    CRT_22R2      CRT_22R1
# #    Modify RU SnapshotTimeoutS    SnapshotTimeoutS=180
# #    Trigger Alarm 1901     current_name=${current_name}    new_name=${new_name}    ru_index=${ru_index}
# #    ${versiontitle}    Get Version
# #    log to console     ${versiontitle}
# #    ${if_21B}    run keyword and return status    should contain    ${versiontitle}    SBTS21B
# #    ${upgrade_version}    run keyword if    ${if_21B}    set variable    ${package_21B}
# #    ...    ELSE    set variable    ${package_22R1}
# #    webui_coam.COAM Upgrade package      package=${upgrade_version}   ip=${WEBUI_URL}   username=${WEBUI_USER}
# #    ...     password=${WEBUI_PASSWORD}
# #    sleep    10min
# #    ${target_version}    Get target Version
# #    log to console    \n target_version
# #    should contain      ${upgrade_version}    ${target_version}
# #    sleep    2s
# #    log to console   \n Check Alarm 1901 Still Appear On WebEM
# #    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=1901
# #    ${ru_alarms_string}    Wait until keyword succeeds    5min   30s    Check fault Exist in faultlog in RU
# #    ...    fault_filter=${fault_filter}   ru_index=${ru_index}   ru_fault_log_path=/run/fault_history_log.txt
# #    Recovery Alarm 1901    current_name=${new_name}    new_name=${current_name}    ru_index=${ru_index}
# #    [Teardown]   Run Keyword If Test Failed    Recovery Alarm 1901
# #     ...    current_name=${new_name}    new_name=${current_name}    ru_index=${ru_index}
# 
# 
# *** Keywords ***
# Get target Version
#     Log To Console    Get Target Version
#     ${connection}    coam.connect_to    bts_host=${WEBUI_URL}     name=GNB_OAM
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${version_list}    split string    ${version}    _
#     ${target_version}    set variable    ${version_list[3]}
#     [Return]    ${target_version}
#     [Teardown]    coam.Teardown    connection=${connection}
# 
# #WEBEM Login
# #    [Arguments]  ${url}=${WEBUI_URL}    ${user}=${WEBUI_USER}    ${password}=${WEBUI_PASSWORD}
# #    run keyword and ignore error  Run   killall firefox
# #    selenium_coam.login    url=${url}    username=${user}    password=${password}   timeout=${120}
# #    run keyword and ignore error    selenium_coam.disable_message_box
# #    run keyword and ignore error    selenium_coam.disable_screen_lock
# #
# #WEBEM Logout
# #    selenium_coam.logout
# 
# Get Version
#     Log To Console    Get Version
#     ${connection}    coam.connect_to    bts_host=${WEBUI_URL}     name=GNB_OAM
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${version_list}    split string    ${version}    _
#     ${versiontitle}    set variable    ${version_list[0]}
#     [Return]    ${versiontitle}
#     [Teardown]    coam.Teardown  connection=${connection}
# 
# Check fault Exist in snapshot
#     [Arguments]  ${ru_index}=1    ${fault_filter}=1247
#     ${snapshot_file_path}    COAM Save snapshot via rest api    timeout=1500
#     ${return_time}  ${retrun_fault}    Extract fault logs from snapshot    searchName=${searchName}
#     ...    snapshot_file=${snapshot_file_path}    fault_id=${fault_filter}
#     [Return]  ${return_time}  ${retrun_fault}
# 
# Perform RU Reset
#     [Documentation]   Auther: Stella.lin@nokia-sbell.com
#     [Arguments]    ${ru_index}=${1}
#     ${ru_index}  Convert To Integer    ${ru_index}
#     COAM Navigate to login page via webUI
#     Log To Console    Reset RU
#     selenium_coam.reset_ru  ru_index=${ru_index}
#     [Teardown]  COAM selenium logout
# 
# COAM Navigate to login page via webUI
#     [Documentation]  Author: Ding Binmei HGZ_SG4
#     ...              Description: If case failed, the snapshot from webUI will be stored in the ${download_dir} folder
#     [Arguments]  ${download_dir}=${TS_CASE_LOG_PATH}    ${timeout}=${60}    ${url}=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
#     ...    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
#     selenium_coam.enable_virtual_display
#     selenium_coam.login    url=${url}
#     ...                    username=${username}
#     ...                    password=${password}
#     ...                    download_dir=${download_dir}
#     ...                    timeout=${timeout}
#     selenium_coam.disable_message_box
# 
# Modify Calibration File On RU Unit side
#     [Arguments]    ${current_name}    ${new_name}    ${ru_index}=1
#     ${cd_cmd}   Set Variable    cd /mnt/factory/configs/unit;
#     ${ru_ip_addr}    wait until keyword succeeds    5min    10s   Get RU IP Address    ru_index=${ru_index}
#     Connect to Common Unit Master
#     Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
#     sleep    2s
#     csn.send_command    command=${cd_cmd}ls -l | grep ${current_name}*.bin | awk '{print $9}'     connection=RU_${ru_index}
#     sleep    2s
#     ${result}    csn.read_output    connection=RU_${ru_index}
#     ${status}    Run Keyword And Return Status    should match regexp    ${result}    ${current_name}
#     sleep    1s
#     Run Keyword If    '${status}' == 'True'    csn.send_command
#     ...     command=${cd_cmd}mv ${current_name}.bin ${new_name}.bin     connection=RU_${ru_index}
#     sleep    2s
#     Run Keyword If    '${status}' == 'True'    csn.send_command
#     ...     command=${cd_cmd}mv ${current_name}.bin.md5 ${new_name}.bin.md5     connection=RU_${ru_index}
#     sleep    2s
#     Perform RU Reset     ru_index=${ru_index}
#     Run Keyword If    '${status}' == 'True'    sleep    120s
#     csn.disconnect    connection=RU_${ru_index}
#    [Teardown]    csn.disconnect    connection=ASIK Master
# 
# Connect to ASOD
#     [Arguments]  ${ip_address}=${WEBUI_URL}  ${alias}=cOAM_toor4nsn
#     ...         ${user}=${ssh_user}     ${password}=${ssh_password}
#     ${connection}=  csn.Connect to  hostname=${ip_address}
#     ...                             username=${user}
#     ...                             password=${password}
#     ...                             alias=${alias}
#     csn.Send command     command=cat /rom/config/FRIps.txt     connection=${connection}
#     csn.Send command     command=lxc-attach -n 0x1018     connection=${connection}
#     csn.Send command     command=ssh root@172.16.73.129    connection=${connection}
#     csn.Send command     command=cd /mnt/factory/configs/unit/    connection=${connection}
#     ${cmd_temp}   Set Variable
#     ...    mv ${current_name} ${new_name}
#     sleep    2s
#     csn.Send command  command=${cmd_temp}    connection=${connection}
#     sleep    2s
#     csn.Send command    command=reboot    connection=${connection}
#     sleep    2s
#     [Return]    ${connection}
#     [Teardown]    csn.disconnect    connection=${connection}
# 
# Recovery Alarm 1901
#     [Arguments]  ${current_name}      ${new_name}     ${ru_index}
#     Modify Calibration File On RU Unit side     current_name=${current_name}   new_name=${new_name}    ru_index=${ru_index}
#     sleep   5min
#     log to console    \n Check Fault 1901 Absent on WebUI
#     Wait until keyword succeeds    5min    30s    Expect Fault Should Absent    faultId=1901
#     log to console    \n Check GNB cell on air
#     Wait Until Keyword Succeeds    10min    30s    COAM Wait for gnb ready and cell setup
# 
# 
# Check time in Snapshot and Web
#      [Arguments]    ${retrun_fault}    ${return_time}
#      ${conn}    connect to admin
#      ${appear_time_list}    ${fault_id_list}    Get Alarm Info and Check alarm       timeout=${100}    exp_alarm_id=${1901}    connection=${conn}
#      ${web_fault_number}    Get Length    ${fault_id_list}
#      ${Snap_fault_number}   Get Length    ${retrun_fault}
#      should be equal as integers    ${web_fault_number}    1
# #     should be equal as integers    ${Snap_fault_number}    1
#      should be true  ${retrun_fault[0]}    1247
#      should be true     ${return_time} <= ${appear_time_list}+1
#      run keyword and continue on failure    Disconnect from admin
# 
# RU Status Should Be Failed
#     [Arguments]  ${ru_index}=1
#     ${dict_ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}
#     should match regexp    ${dict_ru_info['status']['availabilityStatus']}    Failed
# 
# Get Alarm Info and Check alarm
#     [arguments]   ${timeout}   ${exp_alarm_id}    ${connection}=${None}
#     sleep    10s
#     @{alarms}    coam.get_active_alarms    timeout=${timeout}    connection=${connection}
#     sleep    1s
#     log     ${alarms}
#     ${fault_id_list}    create list
#     ${appear_time_list}    create list
#     :FOR    ${item}    IN    @{alarms}
#     \    ${fault_id}    get from dictionary    ${item}    faultId
#     \    ${appear_time}    get from dictionary    ${item}    btsLastUpdateTime
#     \    run keyword if     ${fault_id}==${exp_alarm_id}    append to list    ${appear_time_list}    ${appear_time}
#     \    run keyword if     ${fault_id}==${exp_alarm_id}    append to list    ${fault_id_list}    ${fault_id}
#     ${appear_time_list}=   Get Substring    ${appear_time_list[0]}    0    12
#    [Return]     ${appear_time_list}    ${fault_id_list}
# 
# connect to admin
#     [Arguments]    ${alias}=cOAM_admin
#     ${conn}=   coam.connect_to    bts_host=${WEBUI_URL}    bts_port=${443}    username=${WEBUI_USER}
#     ...   password=${WEBUI_PASSWORD}
#     ...   name=${alias}
#     [Return]    ${conn}
# 
# Disconnect from admin
#     [Arguments]    ${alias}=cOAM_admin
#     coam.teardown     connection=${alias}
# 
# Perform RU Power off
#     [Arguments]    ${ru_index}=${1}    ${model}=HBTE
#     Log    \nperform ru power off   console=yes
#     ${ru_index}    Convert to integer    ${ru_index}
#     ${ru_pdu_ip}=  set variable  ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
#     ${ru_pdu_port}=  set variable  ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
#     pdu.setup_pdu    model=${model}   host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}
#     pdu.power_off    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}
# 
# Perform RU Power on
#     [Documentation]   Auther: Stella.lin@nokia-sbell.com
#     [Arguments]    ${ru_index}=${1}    ${model}=HBTE
#     Log    \nperform ru power on    console=yes
#     ${ru_index}    Convert to integer    ${ru_index}
#     ${ru_pdu_ip}=  set variable  ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
#     ${ru_pdu_port}=  set variable  ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
#     pdu.setup_pdu    model=${model}    host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}
#     pdu.power_on    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}
# 
# 
# 7914 SISO Coam Suite Teardown
#     log to console    \n***SISO Coam Suite Teardown***
#     Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#     ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
#     ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#     COAM Teardown gnb connections
#     Run Keyword And Ignore Error    process.Terminate All Processes    kill=True
# 
# 7914 SISO Coam Test Setup
#     log to console    \n***SISO Coam Test Setup***
#     Generate test case log path
#     ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
#     set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
#     create directory   ${TS_CASE_LOG_PATH}
#     Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
#     Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#     ${ru_info}    COAM get all ru detail info
#     &{ru_info}    Set variable    ${ru_info['1']}
#     ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
#     ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#     Start Btslog With Path Check
#     Run Keyword And Ignore Error    selenium_coam.close_browser
# 
# 7914 SISO Coam Suite Setup
#     log to console    \n***SISO Coam Suite Setup***
#     Connect to gnb coam via ssl
#     ${Active_SW_version}    Get Active SW Version
#     ${gNb_CuType}   Get gNB CU type
#     set suite variable      ${gNb_CuType}
#     run keyword if     ${if_update_swconfig}    update swconfig for gNB
#     Generate suite log path
#     set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
#     Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#     ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
#     ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path}
#     log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
#     set suite variable  ${mrbtsID}
#     set suite variable  ${nrbtsID}
# 
# Trigger Alarm 1901
#     [Arguments]    ${current_name}    ${new_name}   ${ru_index}
#     log to console    \n Trigger Alarm 1901
#     Modify Calibration File On RU Unit side    current_name=${current_name}    new_name=${new_name}
#     ...  ru_index=${ru_index}
#     sleep     10min
#     log to console   \n Check Alarm 1901 Appear On WebEM
#     Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=1901
#     log to console    \n Check Alarm 1901 Exist in RawAlarmHistory
#     Wait until keyword succeeds    5min    30s    Check Alarm Exist in RawAlarmHistory    alarm_filter=1901
#     ${ru_alarms_string}    Wait until keyword succeeds    5min   30s    Check fault Exist in faultlog in RU
#     ...    fault_filter=${fault_filter}   ru_index=${ru_index}   ru_fault_log_path=/run/fault_history_log.txt
# 
# Check fault Exist in RU and snapshot
#     [Arguments]  ${ru_index}=1    ${fault_filter}=1168
#     ${ru_alarms_string}    Wait until keyword succeeds    5min   30s    Check fault Exist in faultlog in RU
#     ...    fault_filter=${fault_filter}   ru_index=${ru_index}   ru_fault_log_path=/run/fault_history_log.txt
#     ${snapshot_file_path}    COAM Save snapshot via rest api    timeout=1500
#     ${snapshot_alarms_string}    Extract fault logs from snapshot     searchName=${searchName}
#     ...    snapshot_file=${snapshot_file_path}    fault_id=${fault_filter}
# 
# Rest Login DU
#     [Arguments]    ${ip_address}=${WEBUI_URL}    ${username}=${WEBUI_USER}
#     ...    ${password}=${WEBUI_PASSWORD}    ${alias}=default
#     [Documentation]   Rest Login DU
#     Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}    connection=${alias}
#     ${conn}     set variable    ${alias}
#     [Return]    ${conn}
# 
# Disconnect from DU
#     [Arguments]    ${alias}=default
#     coam.teardown     connection=${alias}
# 
# Get bts version
#     ${connection}    Rest Login DU
#     ${version}    coam.get_sw_version     connection=${connection}
#     ${version_list}    split string    ${version}    _
#     ${if_common_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS22R4
#     ${searchName}    set variable if    ${if_common_load}    BTS_EB1944R0007_RMOD_L_2_faultLogs.zip
#     ...    BTS_EB1944R0007_RMOD_L_1_faultLogs.zip
#     [Teardown]    Run Keyword And Ignore Error   Disconnect from DU    alias=${connection}
#     [Return]    ${searchName}
# 
# Extract fault logs from snapshot
#     [Documentation]   Auther:lijian.xia@nokia-sbell.com
#     [Arguments]    ${searchName}    ${snapshot_file}    ${fault_id}=1247
#     ${timestamp}    Get Current Date    result_format=%Y-%m-%d%H:%M:%S
#     ${zipout}    Set Variable    zipout_${timestamp}
#     Extract Zip File    ${snapshot_file}    ${TS_CASE_LOG_PATH}/${zipout}
#     ${result_zip}    searchFile      filename=${TS_CASE_LOG_PATH}/${zipout}/snapshot_file_list.txt      searchName=${searchName}
#     ${return_status}    run keyword and return status   should be equal as strings    ${result_zip}   not find
#     ${faurt_log_path}     Run keyword if     ${return_status}
#     ...   Extract Zip File    ${snapshot_file}    ${TS_CASE_LOG_PATH}/${zipout}
#     ...   ELSE     Extract Zip File     ${TS_CASE_LOG_PATH}/${zipout}/${result_zip.split(":")[0]}       ${TS_CASE_LOG_PATH}/${zipout}
#     ${faurt_log_path}    Run    command=cd ${TS_CASE_LOG_PATH}/${zipout};ls | grep -i ${searchName}
#     Extract Zip File    ${TS_CASE_LOG_PATH}/${zipout}/${faurt_log_path}
#     ...                 ${TS_CASE_LOG_PATH}/${zipout}/${faurt_log_path.split(".zip")[0]}
#     ${snapshot_alarms_string}    CB007914_common.Check fault Exist in faultlog in snapshot
#     ...    ru_log_path_in_snapshot=${TS_CASE_LOG_PATH}/${zipout}/${faurt_log_path.split(".zip")[0]}
#     ...    fault_filter=${fault_id}
#     [Return]    ${snapshot_alarms_string}
