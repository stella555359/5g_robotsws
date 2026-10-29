*** Settings ***
Documentation    This is for SG6 common keywords for cloud
...              Author: Hao Xiaoxia
...              Squard: HZ SG6

Library             taf.gnb.oam.coam.vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu        WITH NAME    cu
#Library           taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library           taf.ul.stream.aasyslog.interface.aasyslog    WITH NAME    steam_aasyslog
Library           taf.rfrl.cbts.utilities.tl_config   WITH NAME  tl_config
Library           taf.rfrl.cbts.utilities.generic_utils   WITH NAME    generic_utils
Library           taf.rfrl.cbts.connections.ssh_connections.SSHConnExec   WITH NAME   ssh_conn
#Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
#Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/alarm_checking.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/configuration_id.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/UEs/MTK_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/check_android_ue_l3_call_process.robot
Variables         alarm_cloud.py

*** Keywords ***
Suite Setup For Cloud
    log to console    \n******Suite Setup******
    ${mrbtsID}    Set Variable     ${tl.gnbs[0].cu.instance_id}
    ${nrbtsID}    Set Variable     ${tl.gnbs[0].cu.global_bts_id}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}
    ${START_TIME}    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}
    ${SUITE_LOG_PATH}=    Get A Directory
    Set Suite Variable    ${SUITE_LOG_PATH}
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    vDU Login
    ${vdu_state_data}    vdu.get_vdu_state_data
    ${du_software_verion}    set variable   ${vdu_state_data['software_version']}
    ${stream_du}    Get Stream Version    software_verion=${du_software_verion}
    set suite variable    ${stream_du}
    CU Login
    ${cu_state_data}    cu.get_cu_state
    ${cu_software_verion}    set variable   ${cu_state_data['software_version']}
    ${stream_cu}    Get Stream Version    software_verion=${cu_software_verion}
    set suite variable    ${stream_cu}
    Do CU And DU Commission And Wait Onair
    [Teardown]    run keywords    run keyword and ignore error    vDU Logout    AND    run keyword and ignore error    CU Logout

Case Setup For Cloud
    [Arguments]    ${vdu_scf_name}=${None}    ${cu_scf_name}=${None}
    log to console    \n*****Test setup*****
    Check Alarm and stop robot testing when unexpected alarm raised
    run keyword and ignore error    Requset Configuration Id Report
    ${START_TIME}    Get time    exclude_millis=yes
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    log to console  case log path:${TS_CASE_LOG_PATH}
#    Verify All Cells Status Should Be Onair for vDU
#    ${ru_status}    run keyword and return status    Verify All Rmods Status Should Be Normal for vDU
    run keyword if    "${vdu_scf_name}" != "${None}" or "${cu_scf_name}" != "${None}"
    ...                Do CU And DU Commission And Wait Onair    vdu_scf_name=${vdu_scf_name}   cu_scf_name=${cu_scf_name}

Case Teardown For Cloud
    log to console    *****Test teardown*****
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist For Cloud    allowed_faults=${ALLOWED_FAULT_CLOUD}
    run keyword if test failed    Run Keyword And Ignore Error    Save Local Snapshot In CU
    Run Keyword And Continue On Failure   Verify All Rmods Status Should Be Normal for vDU
    Run Keyword And Continue On Failure    Verify All Cells Status Should Be Onair for vDU
    run keyword if test failed    Run Keyword And Ignore Error    Save Local Snapshot In vDU

Teardown Suite For Cloud
    log to console    *****Suite teardown*****
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

Get Stream Version
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${software_verion}
    @{sw_infor}    split string    ${software_verion}    _
    ${stream}    run keyword if    '25R2' in '${sw_infor}[0]'    String.Replace String    ${sw_infor}[0]    25R2    00    ELSE
    ...                  set variable    ${sw_infor}[0]
    [return]    ${stream}

Get SCF File Path
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    ${scf_full_path}    Get Variable Value    ${scf_full_path}
    return from keyword if    '${scf_full_path}' != 'None'
    ${SCF_Path}    ${result}    Split String From Right  ${CURDIR}    testsuite     1
    ${testline_name}  Get Variable Value    ${testline_name}
    ${TL_NAME}   set variable if    '${testline_name}' == 'None' or '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    7_5${TLNAME}[0]
    set suite variable    ${scf_full_path}    ${SCF_PATH}commissionings/HGZ/${testlinename}

Do CU And DU Commission And Wait Onair
    [Arguments]    ${vdu_scf_name}=SCF_vDUCNF00.xml    ${cu_scf_name}=SCF_vCUCNF00.xml    ${vdu_index}=0
    ...            ${gnb_index}=0   ${timeout}=300s    ${cu_connection}=CU_CON    ${vdu_connection}=DU_CON
    Get SCF File Path
    ${vdu_scf_file_full_path}    Join Path    ${scf_full_path}    vDU    ${vdu_scf_name}
    ${cu_scf_file_full_path}    Join Path    ${scf_full_path}    CU    ${cu_scf_name}
    log to console    commission scf for cu...
    CUs Login    gnb_index=${gnb_index}    connection=${cu_connection}
    log to console   \n*** Start plan upload operation ***
    cu.Perform Commissioning     scf_file=${cu_scf_file_full_path}   timeout=${timeout}    connection=${cu_connection}
    Sleep    1min
    log to console    commission scf for du...
    vDUs Login    connection=${vdu_connection}    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    vdu.Perform Commissioning     scf_file=${vdu_scf_file_full_path}    vdu_connection=${vdu_connection}    timeout=${timeout}
    log to console    check cell status should be on air for du...
    ${du_rf_status}    Run Keyword And Return Status
    ...                                        wait until keyword succeeds     12min    30s    Verify All Cells Status Should Be Onair for vDU
    wait until keyword succeeds     12min    30s    Verify All Rmods Status Should Be Normal for vDU
#    log to console    check cell status should be on air for cu...
#    wait until keyword succeeds     12min    30s    Verify All Cells Are Enabled for CU

vDUs Login
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0  ${connection}=DU_CON
    [Documentation]  login vdu webem.
    ${vdu_connection}    vdu.connect_to
    ...  host=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...  port=${EMPTY}
    ...  secure=${True}
    ...  connection_name=${connection}
    [Return]    ${vdu_connection}

vDUs Logout
    [Arguments]  ${connection}=DU_CON
    [Documentation]  vDU Rest Logout
    vdu.disconnect    vdu_connection=${connection}

CUs Login
    [Arguments]     ${gnb_index}=0   ${connection}=CU_CON
    [Documentation]    Create session to connect CU
    cu.connect to    port=${EMPTY}    secure=${True}    alias=${connection}
    ...    host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}

CUs Logout
    [Arguments]  ${connection}=CU_CON
    [Documentation]  Teardown rest session to CU.
    cu.disconnect   connection=${connection}

Verify All Cells Status Should Be Onair for vDU
    [Arguments]  ${vdu_index}=0    ${alias}=default
    vDU Login    vdu_index=${vdu_index}
    ${cells_status}=  vdu.get_vdu_cells_status     vdu_connection=${alias}
    FOR  ${cell}  IN  @{cells_status}
        Run keyword    Should be equal as strings    ${cell['operational_state']}    enabled
        ...  msg=operational_state for cell ${cell['id']} is not enabled
        Run keyword    Should be equal as strings    ${cell['availability_status']}    on line
        ...  msg=availability_status for cell ${cell['id']} is not on line
        Run keyword    Should be equal as strings    ${cell['administrative_state']}    Unlocked
        ...  msg=administrative_state for cell ${cell['id']} is not Unlocked
        Run keyword    Should be equal as strings    ${cell['procedural_status']}    configured
        ...  msg=procedural_status for cell ${cell['id']} is not configured
        Run keyword    Should be equal as strings    ${cell['blocking_state']}    Unblocked
        ...  msg=blocking_state for cell ${cell['id']} is not Unblocked
    END
    [Teardown]  vDU Logout

Verify All Rmods Status Should Be Normal for vDU
    [Arguments]    ${vdu_index}=0    ${alias}=default
    vDU Login    vdu_index=${vdu_index}
    ${rmods_status}    vdu.get_rmods_status    vdu_connection=${alias}
    FOR  ${ru}  IN  @{rmods_status}
        Run keyword    Should be equal as strings    ${ru['operational_state']}    enabled
        ...  msg=operational_state for ru ${ru['id']} is not enabled
        Run keyword    Should be equal as strings    ${ru['availability_status']}    on line
        ...  msg=availability_status for ru ${ru['id']} is not on line
        Run keyword    Should be equal as strings    ${ru['administrative_state']}    Unlocked
        ...  msg=administrative_state for ru ${ru['id']} is not Unlocked
        Run keyword    Should be equal as strings    ${ru['procedural_status']}    configured
        ...  msg=procedural_status for ru ${ru['id']} is not configured
    END
    [Teardown]  vDU Logout

Start L3 Call And Verify Throughput on Cloud
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]   ${ul_data_transfer}
    ...           ${dl_data_transfer}
    ...           ${expect_ul_tput}
    ...           ${expect_dl_tput}
    ...           ${duration}=180
    ...           ${download_dir}=${TS_CASE_LOG_PATH}
    ...           ${reset_sol}=ue_reboot
    ...           ${ue_index}=${0}
    ...           ${ignore_time}=1min
    ...           ${target_avg_percent}=0.9
    ...           ${is_do_require_ue}=${True}
    ...           ${cellid}=0
    ...           ${throuput_duration}=600
    ...           ${is_need_stop_traffic}=${True}
    ...           ${min_percent}=0.3
    ...           ${ue_iperf_path}=/data/local/tmp/iperf
    ...           ${dl_process_num}=2
    ...           ${log_type}=cloud
    ...           ${gnb_index}=0
    ...           ${vdu_index}=0
    ${duration}    Convert To Integer    ${duration}
    ${expect_ul_tput}    Convert To Number    ${expect_ul_tput}
    ${expect_dl_tput}    Convert To Number    ${expect_dl_tput}
    ${direction_component_list}=  Create List    UL_L2LO    DL_L2LO
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${attach_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${wireshark_log_path_on_testPC}   Run keyword if    '${ue_type}' == 'mtk'
    ...                      UE Attach And Start L3 Call With MTK On Cloud
    ...                                                               ul_data_transfer=${ul_data_transfer}
    ...                                                               dl_data_transfer=${dl_data_transfer}
    ...                                                               duration=${throuput_duration}
    ...                                                               ue_iperf_path=${ue_iperf_path}
    ...                                                               ue_index=${ue_index}
    ...                                                               is_do_require_ue=${is_do_require_ue}
    ...                                                               dl_process_num=${dl_process_num}
    ...             ELSE
    ...                     UE Attach And Start L3 Call With Power UE On Cloud
    ...                                                               reset_sol=${reset_sol}
    ...                                                               ue_index=${ue_index}
    ...                                                               is_do_require_ue=${is_do_require_ue}
    ...                                                               ul_data_transfer=${ul_data_transfer}
    ...                                                               dl_data_transfer=${dl_data_transfer}
    ...                                                               throuput_duration=${throuput_duration}
    ...                                                               dl_process_num=${dl_process_num}
    ...                                                               log_type=${log_type}
    Sleep    ${ignore_time}
    ${tput_log}    Cloud Collect Tput from VDU    duration=${duration}
    ...                                           gnb_index=${gnb_index}
    ...                                           vdu_index=${vdu_index}
    ...                                           log_path=${download_dir}
    Cloud UE Verify Peak Throughput    ue_index=${ue_index}
    ...                                cellid=${cellid}
    ...                                expect_ul_tput=${expect_ul_tput}
    ...                                expect_dl_tput=${expect_dl_tput}
    ...                                min_percent=${min_percent}
    ...                                target_avg_percent=${target_avg_percent}
    ...                                log=${tput_log}
    ...                                local_output_dir=${download_dir}
    [Teardown]    run keyword if    ${is_need_stop_traffic}    Run Keyword And Ignore Error    Stop Traffic In Teardown    ue_index=${ue_index}

Cloud Collect Tput from VDU
    [Documentation]  Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${gnb_index}=0     ${vdu_index}=0    ${duration}=${60}    ${log_path}=${SAVE LOG DIRECTORY}
    log to console    \nCollect Tput from VDU
    ${alias}    generic_utils.get_unique_id_string
    ${alias}    ssh_conn.connect_to_vdu_cloud_hosting    using_tenant=${True}
    ...  vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${alias}
    ${filter_text_list}    create list    UlCounterUpdate    DataPdu    L2_PS_DL_UP_.*ue.rnti    handlePrachPreamble
    ...    Pdcch Resources updated for Ue rnti    informDlOfSuccessfulMsg3Ue    Store UE    dl_awaitMsg4WithoutHiMsgTimerExpiry
    ${filter_text}    Evaluate    r"\\|".join($filter_text_list)
    ${namespace}   tl_config.get_vdu_namespace    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${pod_full_name}    ${container_full_name}    ssh_conn.get_full_pod_and_container_name    pod_abbr=logservice
    ...    container_abbr=logstorageserver    namespace=${namespace}    alias=${alias}
    ${base_command}    set variable    nohup kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${namespace} --
    ${cmd}    set variable
    ...    ${base_command} timeout ${duration} tail -f /var/log/localvolume/syslog | grep -a "${filter_text}" > /tmp/${alias}_tput.log &
    ${output}    ssh_conn.execute_normal_cmd    base_command=${cmd}    alias=${alias}
    sleep    ${duration}
    ssh_conn.download_file    remote_path=/tmp/${alias}_tput.log    local_path=${log_path}/${alias}_tput.log
    ...    alias=${alias}
    [Return]    ${log_path}/${alias}_tput.log
    [Teardown]    run keyword and ignore error    ssh_conn.disconnect_all_vdu_cloud_hosting

Cloud UE Verify Peak Throughput
    [Documentation]  Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]  ${ue_index}    ${cellid}    ${expect_ul_tput}    ${expect_dl_tput}    ${min_percent}  ${target_avg_percent}
    ...    ${log}    ${local_output_dir}=${SAVE LOG DIRECTORY}
    log to console    \nUE Verify Peak Throughput
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${ue_index}    convert to string    ${ue_index}
    ${identity}    get mapping long cell id    cell_id=${cellid}
    ${cells}    Create List    ${identity}
    run keyword and continue on failure    steam_aasyslog.check_aasyslog_throughput
    ...    direction=dl    log_path=${log}    local_output_dir=${local_output_dir}
    ...    cells=${cells}    theoretical_throughput=${expect_dl_tput}
    ...    average_tolerance=${target_avg_percent}    minimum_tolerance=${min_percent}
    run keyword and continue on failure    steam_aasyslog.check_aasyslog_throughput
    ...    direction=ul    log_path=${log}    local_output_dir=${local_output_dir}
    ...    cells=${cells}    theoretical_throughput=${expect_ul_tput}
    ...    average_tolerance=${target_avg_percent}    minimum_tolerance=${min_percent}

UE Attach And Start L3 Call With MTK On Cloud
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${is_do_require_ue}=${True}
    ...            ${ul_data_transfer}=50M
    ...            ${dl_data_transfer}=600M
    ...            ${duration}=1800
    ...            ${ue_index}=${0}
    ...            ${ue_iperf_path}=/data/local/tmp/iperf
    ...            ${dl_process_num}=2
    Log To Console    \n***start ue attach for MTK ***\n
    Start UE Attach With MTK On Cloud                                 sleep_interval=60 sec
    ...                                                               ue_index=${ue_index}
    ...                                                               is_do_require_ue=${is_do_require_ue}
    Log To Console    \n***start ue transfer traffic ***\n
    Start L3 Call Data Transfer With MTK On Cloud                     ul_data_transfer=${ul_data_transfer}
    ...                                                               dl_data_transfer=${dl_data_transfer}
    ...                                                               duration=${duration}
    ...                                                               ue_iperf_path=${ue_iperf_path}
    ...                                                               ue_index=${ue_index}
    ...                                                               dl_process_num=${dl_process_num}

Start UE Attach With MTK On Cloud
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${sleep_interval}=10 sec    ${is_do_require_ue}=${True}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    set test variable    ${ue_type}
    Run Keyword If    ${is_do_require_ue}    MTK_common_keywords.Prepare UE    ue_index=${ue_index}
    Sleep    ${sleep_interval}
    MTK_common_keywords.Do UE Attach    ue_index=${ue_index}
    Sleep    ${sleep_interval}

Start L3 Call Data Transfer With MTK On Cloud
    [Arguments]    ${ue_index}    ${dl_data_transfer}=180M    ${ul_data_transfer}=50M    ${duration}=600
    ...            ${ue_iperf_path}=iperf    ${dl_process_num}=2
    ${DL_PORT}=    Get Variable Value    ${DL_PORT}    default
    ${UL_PORT}=    Get Variable Value    ${UL_PORT}    default
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${dl_data_value}    get regexp matches    ${dl_data_transfer}    \\d+.*\\d+
    ${dl_data_unit}    get regexp matches    ${dl_data_transfer}    [^\\d+]+
    ${target_dl_data_value}    Evaluate    int(${dl_data_value}[0]/${dl_process_num})
    ${dl_data_transfer}     Set Variable     ${target_dl_data_value}${dl_data_unit}[0]
    Connect to control pc via cygwin    ue_index=${ue_index}
    Get Commercial UE IP with first UE
    Run Keyword And Continue On Failure    Start UL traffic via iperf from andriod UE    ue_index=${ue_index}
    ...                                                                                  ul_time=${DATA_TIME}
    ...                                                                                  ul_port=${UL_PORT}
    ...                                                                                  ul_throughput=${ul_data_transfer}
    ...                                                                                  ul_length=${DATA_LENGTH}
    ...                                                                                  iperf_path=${ue_iperf_path}
    wait until keyword succeeds    1 min    10 sec    Connect to APPserver
    Run Keyword And Continue On Failure    csn.send command
    ...    command=iperf -c ${UE_IP} -u -t ${duration} -i 1 -p ${DL_PORT} -P ${dl_process_num} -f m -b ${dl_data_transfer} -l ${DATA_LENGTH} -T 64 &
    ...    connection=APPserver
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=APPserver

UE Attach And Start L3 Call With Power UE On Cloud
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${ul_data_transfer}
    ...            ${dl_data_transfer}
    ...            ${throuput_duration}=1800
    ...            ${ue_index}=${0}
    ...            ${cap_index}=${0}
    ...            ${reset_sol}=none
    ...            ${log_type}=cloud
    ...            ${dl_process_num}=2
    ...            ${is_do_require_ue}=${True}
    ...            ${is_need_stop_traffic}=${True}
    ${iperf_type}    Set Variable If    '${ue_type}' == 'samsung'     via_command    via_app
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    set test variable    ${ue_type}
    Run Keyword If    ${is_do_require_ue}    power_ue.Prepare UE    ue_type=${ue_type}
    ...                                                             ue_index=${ue_index}
    ...                                                             capatibility_index=${cap_index}
    ...                                                             reset_sol=${reset_sol}
    ...                                                             detach_request=${detach_request}
    Sleep    ${sleep_interval}
    power_ue.UE Attach                    ue_type=${ue_type}
    ...                                   ue_index=${ue_index}
    ...                                   power_reset=${power_reset}
    ...                                   log_type=${log_type}
    Sleep    ${sleep_interval}
    Start L3 Call With Power UE    ul_data_transfer=${ul_data_transfer}
    ...                            dl_data_transfer=${dl_data_transfer}
    ...                            ue_index=${ue_index}
    ...                            iperf_type=${iperf_type}
    ...                            duration=${throuput_duration}
    ...                            dl_process_num=${dl_process_num}
    [Teardown]    run keyword if    ${is_need_stop_traffic}    Run Keyword And Ignore Error    Stop Traffic In Teardown    ue_index=${ue_index}

Save Local Snapshot In vDU
    [Arguments]    ${local_snapshot_location}=vdu_snapshot    ${vdu_index}=${0}
    log to console    Save vdu Local Snapshot...
    vDU Login    vdu_index=${vdu_index}
    set test variable  ${Snapshot_path}    ${SAVE LOG DIRECTORY}/${local_snapshot_location}/
    create directory   ${Snapshot_path}
    vdu.Get_Local_Snapshot    ${Snapshot_path}
    [Return]    ${Snapshot_path}
    [Teardown]    vDU Logout

Save Local Snapshot In CU
    [Arguments]    ${local_snapshot_location}=cu_snapshot    ${gnb_index}=${0}
    log to console    Save cu Local Snapshot...
    CU Login    gnb_index=${gnb_index}
    set test variable  ${Snapshot_path}    ${SAVE LOG DIRECTORY}/${local_snapshot_location}/
    create directory   ${Snapshot_path}
    cu.Get_Local_Snapshot    ${Snapshot_path}
    [Return]    ${Snapshot_path}
    [Teardown]    CU Logout

Unexpect Alarm Should Not Exist For Cloud
    [Arguments]   ${allowed_faults}    ${vdu_index}=${0}    ${file_path}=${TS_CASE_LOG_PATH}    ${alias}=default
    vDU Login    vdu_index=${vdu_index}
    ${alarms}    vdu.vdu_get_active_alarms    vdu_connection=${alias}
    ${active_alarms_list}    Get From Dictionary    ${alarms}    alarms
    ${active_alarms_num}     Get From Dictionary    ${alarms}    total
    ${unexpect_alarms}    Create List
    FOR  ${alarm}  IN  @{active_alarms_list}
       Exit For Loop If   ${active_alarms_num}==${0}
       ${status}   Run Keyword And Return Status   Check Alarm Is Allowed For Cloud
       ...                                         allowed_alarm_list=${allowed_faults}
       ...                                         check_alarm=${alarm}
       Run Keyword If   ${status}==${False}    Append To List    ${unexpect_alarms}   ${alarm}
       Run Keyword If   ${status}==${False}    Log to console    Unexpect Active Alarm : ${alarm['fault_id']}
    END
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${unexpect_alarm_file}    Set variable    ${file_path}/unexpect_active_alarms_${timestamp}.txt
    ${alarm_num}   Get Length   ${unexpect_alarms}
    Run Keyword If  ${alarm_num}!=${0}    Run   command=echo "unexpect alarm number:${alarm_num}">${unexpect_alarm_file}
    FOR  ${alarm}  IN  @{unexpect_alarms}
        Exit For Loop If  ${alarm_num}==${0}
        run    command=echo "${alarm}">>${unexpect_alarm_file}
    END
    Run Keyword If   ${alarm_num}!=${0}   fail   ${alarm_num} alarms are not allowed, details in log: ${unexpect_alarm_file}
    [Teardown]    vDU Logout

Check Alarm Is Allowed For Cloud
    [Arguments]   ${allowed_alarm_list}     ${check_alarm}
    ${allowed_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{allowed_alarm_list}
        ${allowed_status}    Run Keyword And Return Status
        ...                  Should Be Equal    ${check_alarm['fault_id']}    ${alarm['faultId']}
        Exit For Loop If   ${allowed_status}
    END
    ${msg}    set variable    fault ${check_alarm['fault_id']} report by ${check_alarm['alarming_object']} is not allow
    Run Keyword If  ${allowed_status}==${False}  Fail    ${msg}

Stop Traffic In Teardown
    [Arguments]     ${ue_index}=${0}
    run keyword if    'mtk' in '${ue_type}'    Run Keyword And Ignore Error    Stop Traffic With MTK UE    ue_index=${ue_index}
    ...    ELSE     Run Keyword And Ignore Error    Stop Traffic With Power UE    ue_index=${ue_index}

Stop Traffic With MTK UE
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    ...                  this keyword stop ul/dl traffic, never detach mtk ue!
    [Arguments]     ${ue_index}=${0}
    ...             ${iperf_type}=via_app
    ...             ${apn_address}=wap1nokiacom
    ...             ${protocol}=udp
    ${data_direction_list}    create list    ul    dl
    FOR    ${direction}    IN    @{data_direction_list}
        run keyword and continue on failure    power_ue.Stop traffic    ue_type=qct_dx50
        ...                                                             direction=${direction}
        ...                                                             dt_name=dt_${direction}
        ...                                                             protocol=${protocol}
        ...                                                             iperf_port=default
        ...                                                             iperf_type=${iperf_type}
        ...                                                             ue_index=${ue_index}
        ...                                                             apn_address=${apn_address}
    END
    MTK_common_keywords.Do UE Detach    ue_index=${ue_index}

get mapping long cell id
    [Arguments]    ${vdu_index}=0    ${cell_id}=1    ${alias}=default
    vDU Login    vdu_index=${vdu_index}
    ${cells_status}    vdu.get_vdu_cells_status    vdu_connection=${alias}
    FOR  ${cell}  IN  @{cells_status}
        return from keyword if    '${cell_id}'=='${cell['id']}'     ${cell['nr_cell_identity']}
    END
    [Return]    ${None}
    [Teardown]  vDU Logout

Verify All Cells Are Enabled for CU
    [Arguments]  ${gnb_index}=0
    CU Login  ${gnb_index}
    sleep    1s
    ${cells_status}=   cu.get_cells_statuses
    FOR  ${cell}  IN  @{cells_status}
        Run keyword    Should be equal as strings    ${cell['operational_state']}    enabled
        ...  msg=operational_state for cell ${cell['id']} is not enabled
    END
    [Teardown]   run keyword and ignore error   CU Logout
