*** Settings ***
Library     OperatingSystem
Library     random
Library     taf.sbts.oam.coam.admin    WITH NAME   TAF_ADMIN
Library     taf.transport.ssh    WITH NAME    ssh
Library     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012170_AQQQA/common_resource/python/DeltaStore.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/admin_sbts.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/counters.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/gnb_sync.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot

Documentation
...    Author: Yang Di
...    Contact: di.yang@nokia-sbell.com
...    Group: HGZ_SG5

*** Variables ***
${dltp}              10
${kill_btslog}       timeout 5 sudo kill -9 $(ps -ef|grep btslog|grep -v grep|awk '{print $2}') 1>/dev/null 2>&1
${Retry_count}       4
${ue_id}             ${2}
${WEBUI_ADDR}        ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_COAM}        https://${WEBUI_ADDR}

*** Keywords ***
Clean Up Env
    [Arguments]    ${host_ip}=localhost
    [Documentation]    This keyword is to clean up testline process such as btslog and so on.
    ...    Examples:
    ...    | Clean Up Env |
	Run Keyword If     '${host_ip}'=='127.0.0.1' or '${host_ip}'=='localhost'    Run Keywords    Run     ${kill_btslog}
	...     AND     Run    rm /tmp/admin_api_*.txt -f
	...     AND     Run    rm /tmp/disconnect*.ims2 -f
	...     AND     Run    rm /tmp/*.pcap* -rf
	...     AND     Run    sudo rm /tmp/*.pcap* -rf
	...     ELSE    Run keywords    ssh.Connect To    ${host_ip}    ute    ute    alias=remote_connection
	...     AND     ssh.Execute    ${kill_btslog}    connection=remote_connection
    ...     AND     ssh.Disconnect    connection=remote_connection

Get Host IP
    [Documentation]    This keyword is to get testline control host intranet IP.
    ...    Examples:
    ...    | ${host_ip} | Get Host IP |
    ${command}    Set Variable    sudo ifconfig eth0|awk -F "[ :]+" 'NR==2 {print $3}'
    ${rc}    ${output}=    OperatingSystem.Run and Return RC and Output    ${command}
    Log    [TL] Host IP:${output}
    Set Suite Metadata    Host IP    ${output}
    [Return]    ${output}

CB012170 Common Suite Setup
    [Documentation]    This keyword is common Suite Setup.
    CI_interface.Common Suite Setup
    Clean Up Env
    Get Host IP
    robot_common_operations.Common Suite Setup
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    @{result}    string.split string    ${Active_SW_version}    separator=_
    ${stream}     convert to string    ${result}[-5]
    set suite variable    ${stream}
    ${UE_TYPE}    translate_power_ue_type_from_testline    ue_index=${ue_id}
    Set Suite Variable    ${UE_TYPE}

CB012170 Common Suite Teardown
    [Documentation]    This keyword is common Suite Teardown.
    Check Alarm and stop robot testing when unexpected alarm raised
    robot_common_operations.Common Suite Teardown
    Unbarred NR Cells

CB012170 Common Test Setup
    [Documentation]    This keyword is common Test Setup. will start btslog.
    CI_interface.Common Case Setup
    robot_common_operations.Common Case Setup
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${case_log_path}    Join path    ${OUTPUT_DIR}    ${TEST_NAME}_${timestamp}
    set test variable    ${TEST_LOG_DIRECTORY}    ${case_log_path}
    OperatingSystem.create directory    ${TEST_LOG_DIRECTORY}/All
    Run Keyword And Ignore Error    Start Btslog With Path Check

Backup Scf
    [Arguments]    ${log_dir}    ${backup_name}=scfc.xml    ${connection}=GNB_OAM
    [Documentation]    This keyword is to back up SCF file
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the folder directory to store the scf file |
    ...    | ${backup_name} | No | the saved SCF file name. default:scfc.xml |
    ...    Examples:
    ...    | Backup Scf | /tmp | before_suite |
    ...    | ${scfc_full_path}= | Backup Scf | /tmp | before_suite |
    Connect to gnb coam via ssl
    TAF_ADMIN.Get Current Scf File    local_dir_path=${log_dir}    file_name=${backup_name}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    [Return]    ${log_dir}/${backup_name}

CB012170 Common Test Teardown
    [Arguments]    ${connection}=GNB_OAM
    [Documentation]    This keyword is common Test Teardown. will stop btslog and collect config files
    CI_interface.Common Case Teardown
    OperatingSystem.create directory    ${test_log_directory}/All/
    Run Keyword And Ignore Error    Backup Scf                 ${test_log_directory}/All/
    Run Keyword And Ignore Error    Stop Btslog With Path Check    target_dir=${TEST_LOG_DIRECTORY}
    Connect to gnb coam via ssl
    Run Keyword If Test Failed    Save Coam Snapshot    target_dir=${TEST_LOG_DIRECTORY}    connection=${connection}
    Run Keyword And Ignore Error    Stop UE data and detach UE
    robot_common_operations.Common Case Teardown

Nokia UE Attach
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${scf_file}  scf.Get real SCF From BTS
    ${pci}  Get Parameter Value from SCF  parameter=physCellId
    ...  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${random_cell_id}  scf_file_path=${scf_file}
    ${arfcnSsbPbch}  Get Parameter Value from SCF  parameter=arfcnSsbPbch
    ...  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${random_cell_id}  scf_file_path=${scf_file}
    nokia_fastmile.Modify UE Capatibility  ue_index=${ue_index}  pci=${pci}    arfcn=${arfcnSsbPbch}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    pci=${pci}
    Run keyword and ignore error    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}
    ...    4G_check=False

Nokia UE Send DL Traffic
    [Arguments]     ${send_duration}=360    ${send_traffic}=50M    ${ue_index}=${0}
    power_ue.Start traffic  ue_type=${UE_TYPE}  direction=dl  throughput=${send_traffic}  duration=${send_duration}
    ...    ue_index=${ue_index}    iperf_type=via_command
    Verify traffic

Check cell EnergySaving state via COAM
    [Arguments]    ${cellID}=1    ${class_name}=NRCELL_R    ${connection}=GNB_OAM
    ...         ${expect_energySavingState}=notEnergySaving
    ${managed_objects}   coam.get_managed_objects   class_name=${class_name}   connection=${connection}
    FOR  ${cellinfo}   IN  @{managed_objects}
         ${nrcell_r}    Run Keyword If   ${cellinfo['distName'].count('NRCELL_R-${cellID}')} > 0
         ...   set variable    ${cellinfo['distName']}
         exit for loop if   ${cellinfo['distName'].count('NRCELL_R-${cellID}')} > 0
    END
    ${cell_specific_info}   coam.get_cell_specific_info   cell_id=${nrcell_r}   connection=${connection}
    ${energy_State}   set variable   ${cell_specific_info['energySavingState']}
    Should Be Equal As Strings    ${energy_State}   ${expect_energySavingState}

Nokia UE Detach
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${ue_index}

Stop UE data and detach UE
    Log To Console   \n-------------Stop UE data and detach UE---------------
    power_ue.Stop traffic    direction=dl    ue_index=${ue_id}    ue_type=${UE_TYPE}
    Nokia UE Detach    ue_index=${ue_id}

Unbarred NR Cells
    [Arguments]  ${ru_index}=1
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${cell_list}    Get All Cell Id    ru_index=${ru_index}
    FOR     ${cell}    IN     @{cell_list}
        run keyword if  ${cell}!=${random_cell_id}    Modify Parameter On BTS With Activate
        ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell}    parameter=cellBarred    value=notBarred
    END

get CB012170 counters value
    [Arguments]   ${connection}=GNB_OAM   ${timeout}=${60}
    _Get Counter Time
    ${count_path}    Set Variable   BTS/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${random_cell_id}/NREIRP
    ${value_list}    Create List
    ${convert_counters}    Catenate    SEPARATOR=,    @{EIRP_counters_list}
    ${counter_groups}     Wait Until Keyword Succeeds    ${Retry_count} times    60    coam.get_pm_counters
    ...    counter_ids=${convert_counters}    connection=${connection}    timeout=${timeout}
    ${counter_group_keys} =    Split String    ${count_path}    /
    FOR    ${group}    IN     @{counter_group_keys}
        ${counter_groups} =    Get From Dictionary    ${counter_groups}    ${group}
    END
    Set test variable    ${counter_groups}
    FOR    ${counter_name}    IN    @{EIRP_counters_list}
        ${counter_value}   get CB012170 counter Recent value   counter_name=${counter_name}
        append to list    ${value_list}    ${counter_value}
    END
    log to console    EIRP PM counters are ${value_list}
    [return]    ${value_list}

get CB012170 counter Recent value
    [Arguments]   ${counter_name}
    ${counter_values} =    Get From Dictionary    ${counter_groups}    ${counter_name}
    ${key_list} =     Get Dictionary Keys    ${counter_values}
    ${latest_value} =    Get From Dictionary    ${counter_values}    ${key_list[-1]}
    [return]    ${latest_value}

Get The NR Cell ID
    [Arguments]    ${cell_idx}=${1}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}   version=${stream}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error
    ...    selenium_coam.close_start_up_view_window
    ${info_cell}    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    ${cell_id_nr}    set variable    ${info_cell['NR cell ID']}
    Run Keyword And Ignore Error    selenium_coam.logout
    [Return]    ${cell_id_nr}
    [teardown]    Run Keyword And Ignore Error    selenium_coam.logout

Wait for next pm period
    [Documentation]     This keyword first get the time in second from gNB. It
    ...                 then calculate how long time to wait to be some seconds before or after
    ...                 the next pm period. It then sleeps for this value
    [Arguments]     ${counter_period}=5     ${guardtime}=30     ${before}=${False}
    ${counter_second}=                  Evaluate                60 * ${counter_period}
    ssh.connect_to     hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}     alias=OAM-conn
    ${stdout}=                      ssh.execute                 command=date -u +"%s"     connection=OAM-conn
    ${basetime}=                    Run Keyword if          ${before}
    ...                             Evaluate                (${stdout} + ${guardtime})
    ...                             ELSE
    ...                             Evaluate                (${stdout} - ${guardtime})
    ${timetowait}=                  Evaluate                ${counter_second} - (${basetime} % ${counter_second})
    log                             time to wait : ${timetowait}
    sleep    ${timetowait}
    [Return]  (${stdout} - ${counter_second})

Verify traffic
    [Arguments]    ${cell_idx}=${random_cell_id}
    ${log}    power_ue.Collect Tput  check_source=Aasyslog  ue_type=${UE_TYPE}    duration=1m
    ${cell_id}    Get The NR Cell ID  cell_idx=${cell_idx}
    ${cell_list}  create list
    Append To List  ${cell_list}  ${cell_id}
    ${all_tp}    power_ue.Check Tput    ue_type=${UE_TYPE}    log=${log}    cells=${cell_list}    direction=DL
    ...    target_throughput=${dltp}    check_source=Aasyslog

Verify traffic And Stop UE
    Verify traffic
    Stop UE data and detach UE

_Get Counter Time
    [Arguments]   ${counter_period}=5
    Connect to gnb coam via ssl
    Log to console    Wait Until Next Counter Update
    Wait for next pm period
    ${start_time}    Wait for next pm period    ${counter_period}
    Wait Until Keyword Succeeds    5min    30s    Check Time for Counter    start_time=${start_time}

Check Time for Counter
    [Arguments]   ${connection}=GNB_OAM     ${start_time}=${None}   ${timeout}=${60}
    ${counter_groups}     coam.get_pm_counters    counter_ids=M55324C00400    connection=${connection}
    ...    timeout=${timeout}
    ${counters}    Set Variable
    ...  ${counter_groups['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-${random_cell_id}']['NREIRP']}
    ${values}    Get From Dictionary    ${counters}    M55324C00400
    ${key_list} =     Get Dictionary Keys    ${values}
    Should be True   ${key_list[-1]} > ${start_time}

