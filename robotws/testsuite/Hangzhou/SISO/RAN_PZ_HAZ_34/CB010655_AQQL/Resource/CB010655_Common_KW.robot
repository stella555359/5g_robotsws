*** Settings ***
Documentation     author: Zhang Xuewen
...               Group: HGZ_SG5
...               contact: xuewen.zhang@nokia-sbell.com

Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource  ../../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Library    ../lib/check_snapshot.py

*** Keywords ***
Check_RU_Black_Box_contents_in_snapshot_with_most_important_files
    Log to console    \n********* check snapshot Minor level's BBOX5 file ***********
    Check_RU_Minimum_information_in_Black_Box

support_NVM_updating_for_controlled_radio_reset
    Log to console    \n********* check controlled radio reset ***********
    Check_support_NVM_updating_for_controlled_radio_reset

support_fault_history
    Log to console    \n********* check support fault history ***********
    Check_support_fault_history

Check_RU_Minimum_information_in_Black_Box
    [Arguments]
    ${BBOX5_file}    Get BBOX5 on Minor Level Snapshot
    Log to console    \n********* check BBOX5 items info *********
    ${bbox5_content}    Run    command=cat ${BBOX5_file}
    ${BBOX5_file_ru}    Get BBOX5 File Contents From RU
    ${bbox5_content_ru}    Run    command=cat ${BBOX5_file_ru}
    Should Be Equal As Strings   ${bbox5_content}    ${bbox5_content_ru}
    ${pattern}    Set Variable    Last write: ([^T]*)T
    ${last_write_time}    Get Regexp Matches    ${bbox5_content}    ${pattern}    1
    ${today}    DateTime.Get Current Date    result_format=%Y-%m-%d
    ${yesterday}    DateTime.Subtract Time From Date    ${today}    1 day    result_format=%Y-%m-%d
    ${latest_date}    Evaluate    max(${last_write_time})
    Should Contain Any    ${latest_date}    ${today}    ${yesterday}

Check_support_NVM_updating_for_controlled_radio_reset
    [Arguments]    ${resets}=Item type: NvmFlushCounter
    RU_module_reset_from_GUI
    ${BBOX5_file}   Get BBOX5 on Full Level Snapshot
    Log to console    \n********* check BBOX5 items info *********
    ${reset_info_snapshot}   get_resets_info    item=${resets}    filepath=${BBOX5_file}
    ${BBOX5_file}    Get BBOX5 File Contents From RU
    ${reset_info_ru}   get_resets_info    item=${resets}    filepath=${BBOX5_file}
    Should Be Equal As Strings   ${reset_info_snapshot}    ${reset_info_ru}

Check_support_fault_history
    [Arguments]    ${fault_event}=Item type: BtsAlarmHistory
    Trigger fault 1904 In RU
    ${BBOX5_file}    Get BBOX5 on Full Level Snapshot
    Log to console    \n********* check BBOX5 items info *********
    # ${events}    check RF internal faults
    ${events_snapshot}    get_events    item=${fault_event}    filepath=${BBOX5_file}
    ${BBOX5_file}    Get BBOX5 File Contents From RU
    ${events_ru}   get_events    item=${fault_event}    filepath=${BBOX5_file}
    Sort List    ${events_snapshot}
    Sort List    ${events_ru}
    Should Be Equal    ${events_snapshot}    ${events_ru}

RU_module_reset_from_GUI
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/15 21:14
    [Arguments]    ${ru_index}=${1}
    Selenium Login And Disable Screen Lock
    selenium_coam.reset_ru    ru_index=${ru_index}
    Selenium Logout And Close Browser
    Wait Until Keyword Succeeds    5min    20s    RU Should Be Offline    ru_index=${ru_index}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
Get BBOX5 File Contents From RU
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    ${local_path}    Run keyword If
    ...     '${stream}'<='SBTS25R3'    Wait Until Keyword Succeeds    6min    120s    Get BBOX5 File Contents From RU with branch
    ...    ELSE    Wait Until Keyword Succeeds    6min    120s    Get BBOX5 File Contents From RU with truck
    [Return]   ${local_path}
Get BBOX5 File Contents From RU with branch
    [Arguments]    ${ru_index}=1    ${blackbox5}=BBOX5    ${download_dir}=${TS_CASE_LOG_PATH}    ${remote_path}=/mnt/runtime/BBOX5
    Connect to Common Unit Master
    Log to console    \n********* check RU online access to BlackBox BBOX5 *********
    Connect to RU With Allocated IP    ru_alias=RU_${ru_index}
    csn.send command    command=cd /mnt/runtime/;ls    connection=RU_${ru_index}
    Sleep    2s
    ${result}    csn.read output    connection=RU_${ru_index}
    Should contain     ${result}    ${blackbox5}
    csn.Download file    remote_path=${remote_path}    local_path=${download_dir}/BBOX5    connection=RU_${ru_index}
    Log to console    \n************ get BBOX5 file content *************
    ${bbox5_content}    Run    command=cat ${download_dir}/BBOX5
    ${local_path}    set variable   ${download_dir}/BBOX5
    csn.Disconnect    connection=RU_${ru_index}
    [Return]   ${local_path}

Get BBOX5 File Contents From RU with truck
    [Arguments]    ${ru_index}=1    ${blackbox5}=BBOX5    ${download_dir}=${TS_CASE_LOG_PATH}    ${remote_path}=/mnt/runtime/BBOX5
    ...    ${gnb_index}=${0}    ${du_index}=${0}
    ...    ${asik_alias}=ASIK Master    ${connection}=GNB_OAM
    ...    ${ru_username}=${tl.gnbs[${gnb_index}].dus[${du_index}0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...    ${ru_password}=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].default_ssh_connection_details.password}
    #Connect to Common Unit Master
    Log to console    \n********* check RU online access to BlackBox BBOX5 *********
    #Connect to RU With Allocated IP    ru_alias=RU_${ru_index}
    #csn.send command    command=cd /mnt/runtime/;ls    connection=RU_${ru_index}
    ###use new keyword due to issue connect fhnet_host_ip failed
    Connect to Common Unit Master    gnb_index=${gnb_index}    du_index=${du_index}    alias=${asik_alias}
  	${container_id}    Get FHNET Container ID    asik_alias=${asik_alias}
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${ru_ip_addr}  Coam Get RU IP via RMOD object  ru_serial_number=${ru_info['serialNumber']}  connection=${connection}

    ${smod_connection}    csn.get_connection_by_alias    alias=${asik_alias}
    ${channel}    Call Method    ${smod_connection}    invoke_shell
    ${output}    csn.execute    lxc-ls    connection=${asik_alias}
    ${feature_1834_opened}    Run Keyword And Return Status    Should Contain    ${output}    ${container_id}
    IF    ${feature_1834_opened}
        Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
        Sleep    1 sec
        Call Method    ${channel}    recv    ${65535}
    END
    Call Method    ${channel}    send    ssh ${ru_username}@${ru_ip_addr} -o StrictHostKeyChecking\=no\n
    Sleep    1 sec
    ${password_prompt_output}    Call Method    ${channel}    recv    ${65535}
    IF    "password:" in """${password_prompt_output}"""
        Call Method    ${channel}    send    ${ru_password}\n
        Sleep    1 sec
        Call Method    ${channel}    recv    ${65535}
    END
    Call Method    ${channel}    send    cd /mnt/runtime/;ls\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${result}    Convert To String    ${output}
    ####finished with connect fhnet_host_ip failed
    Sleep    2s
    #${result}    csn.read output    connection=RU_${ru_index}
    Should contain     ${result}    ${blackbox5}
    #csn.Download file    remote_path=${remote_path}    local_path=${download_dir}/BBOX5    connection=RU_${ru_index}
    #Call Method    ${channel}    send    scp ${ru_username}@${ru_ip_addr}:${remote_path} /tmp/BBOX5 -o StrictHostKeyChecking\=no\n
    #${output}    Call Method    ${channel}    recv    ${65535}
    sleep    1min
    #csn.Download file    remote_path=/tmp/BBOX5    local_path=${download_dir}/BBOX5    connection=${asik_alias}
    #csn.Disconnect    connection=RU_${ru_index}
    Call Method    ${channel}    close
    ${smod_connection}    csn.get_connection_by_alias    alias=${asik_alias}
    ${channel}    Call Method    ${smod_connection}    invoke_shell
    ${output}    csn.execute    lxc-ls    connection=${asik_alias}
    ${feature_1834_opened}    Run Keyword And Return Status    Should Contain    ${output}    ${container_id}
    IF    ${feature_1834_opened}
        Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
        Sleep    1 sec
        Call Method    ${channel}    recv    ${65535}
    END
    Call Method    ${channel}    send    scp ${ru_username}@${ru_ip_addr}:${remote_path} /ffs/run/config/toor4nsn\n
    Sleep    1 sec
    ${password_prompt_output}    Call Method    ${channel}    recv    ${65535}
    IF    "password:" in """${password_prompt_output}"""
        Call Method    ${channel}    send    ${ru_password}\n
        Sleep    1 sec
        Call Method    ${channel}    recv    ${65535}
    END
    Call Method    ${channel}    send    cd /ffs/run/config/toor4nsn;ls\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${result}    Convert To String    ${output}
    Should contain     ${result}    ${blackbox5}
    Call Method    ${channel}    close
    Connect to Common Unit Master    gnb_index=${gnb_index}    du_index=${du_index}    alias=${asik_alias}
    csn.Download file    remote_path=/ffs/run/config/toor4nsn/BBOX5    local_path=${download_dir}/BBOX5    connection=${asik_alias}
    csn.Disconnect    connection=${asik_alias}
    Log to console    \n************ get BBOX5 file content *************
    ${bbox5_content}    Run    command=cat ${download_dir}/BBOX5
    ${local_path}    set variable   ${download_dir}/BBOX5
    [Return]   ${local_path}

Connect to Made1 via RU
    [Arguments]  ${ru_index}=1   ${node_ip}=192.168.101.2
    ${connection}    csn.get_connection_by_alias    alias=RU_${ru_index}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    ssh ${node_ip}\n
    Sleep    5 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String   ${output}
    Should Contain Any    ${output}    DFE1    Node1    made    ignore_case=${TRUE}
    Set Test Variable  ${channel}
    Run Keyword If   "DFE1" in '''${output}'''     Set Test Variable
    ...   ${made1_interface}   arb0p1
    ...   ELSE    Set Test Variable
    ...   ${made1_interface}   arb0p0

Get command output from Made1
    [Arguments]  ${cmd}  ${match}=None
    Call Method    ${channel}    send    ${cmd}\n
    Sleep    3 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    ${output}  Convert To String    ${output}
    Run Keyword If    '${match}'!='None'  Should Contain    ${output}    ${match}
    [Return]    ${output}

Trigger fault 1904 In RU
    [Arguments]    ${ru_index}=1
    Connect to Common Unit Master
    Log to console    \n********* Trigger fault 1904 In RU *********
    Connect to RU With Allocated IP    ru_alias=RU_${ru_index}
    ${status}  Run Keyword And Return Status  Wait Until Keyword Succeeds    3min    30s  Connect to Made1 via RU
    ${cmd}   Set Variable   sudo su -c "ifconfig ${made1_interface} down"
    Run Keyword If    ${status}     Get command output from Made1  cmd=${cmd}
    Call Method    ${channel}    close
    sleep    2s
    csn.Disconnect    connection=RU_${ru_index}
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    # Selenium Login And Disable Screen Lock
    add fault to the allowed fault list    faultId=${1904}
    Wait Until Keyword Succeeds   360 sec   15 sec    Expect Fault Should Present In Active or History Alarms
    ...                                                     faultId=${1904}
    ...                                                     source=${None}
    ...                                                     connection=GNB_OAM
    ...                                                     du_index=${0}
    ...                                                     is_need_to_setup_gnb_connection=${True}
    ...                                                     timeout=${300}
    ...                                                     severity=${None}
    Wait Until Keyword Succeeds    5min    20s    RU Should Be Offline    ru_index=${ru_index}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    # Selenium Logout And Close Browser

Expect Fault Should Present In Active or History Alarms
    [Documentation]    Auther: xuewen.zhang@nokia-sbell.com
    ...               Description: check expect alarm exist,add severity checkpoint by journey.jin@nokia-sbell.com
    ...               :param severity<str>: optional,value:Critical,Major,Minor,Warning
    ...               add checkpoint alarm id and fault id should be mapped by zheng.4.liu@nokia-sbell.com
    ...               add ${alarm['configObjectName']} due to some object don't have runtime object by zheng.4.liu@nokia-sbell.com
    ...               add ${alarm['supplAlarmInfo']} for checking supplAlarmInfo by catherine.cheng@nokia-sbell.com
    ...               add ${supplementary_not_contain} for checking supplAlarmInfo by catherine.cheng@nokia-sbell.com
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=GNB_OAM    ${severity}=${None}    ${alarmId}=${None}
    ...            ${configObjectName}=${None}     ${supplementary}=${None}    ${supplementary_not_contain}=${None}
    ...            ${du_index}=0    ${is_need_to_setup_gnb_connection}=${True}    ${timeout}=10

    log to console     ${alarmId},${configObjectName},${supplementary}
    ${present_status}    Run Keyword And Return Status    Expect Fault Should Present
    ...      faultId=${faultId}
    ...      source=${source}
    ...      connection=${connection}
    ...      du_index=${du_index}
    ...      is_need_to_setup_gnb_connection=${is_need_to_setup_gnb_connection}
    ...      timeout=${timeout}
    ...      severity=${severity}
    return from keyword if    ${present_status}      log to console  Expect Fault:${1904} Present In Active Alarms

    ${present_status}    Run Keyword And Return Status    Expect Fault Should Present In History Alarms
    ...      faultId=${faultId}
    ...      source=${source}
    ...      connection=${connection}
    ...      du_index=${du_index}
    ...      is_need_to_setup_gnb_connection=${is_need_to_setup_gnb_connection}
    ...      timeout=${timeout}
    ...      severity=${severity}
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.

Expect Fault Should Present In History Alarms
    [Documentation]    Auther: xuewen.zhang@nokia-sbell.com
    ...               Description: check expect alarm exist,add severity checkpoint by journey.jin@nokia-sbell.com
    ...               :param severity<str>: optional,value:Critical,Major,Minor,Warning
    ...               add checkpoint alarm id and fault id should be mapped by zheng.4.liu@nokia-sbell.com
    ...               add ${alarm['configObjectName']} due to some object don't have runtime object by zheng.4.liu@nokia-sbell.com
    ...               add ${alarm['supplAlarmInfo']} for checking supplAlarmInfo by catherine.cheng@nokia-sbell.com
    ...               add ${supplementary_not_contain} for checking supplAlarmInfo by catherine.cheng@nokia-sbell.com
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=GNB_OAM    ${severity}=${None}    ${alarmId}=${None}
    ...            ${configObjectName}=${None}     ${supplementary}=${None}    ${supplementary_not_contain}=${None}
    ...            ${du_index}=0    ${is_need_to_setup_gnb_connection}=${True}    ${timeout}=100
    ${faultId}    Convert To Integer    ${faultId}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${connection}    Set variable if  '${du_index}'=='0'    ${connection}    ${connection}_du${du_index}
    Run keyword if    ${has_cbts} and ${is_need_to_setup_gnb_connection}
    ...    Cloud DU connect to gnb coam via ssl
    ...        connection=${connection}    du_index=${du_index}
    ...    ELSE IF    '${has_cbts}'=='${False}' and ${is_need_to_setup_gnb_connection}
    ...      Connect to gnb coam via ssl    connection=${connection}
    @{alarms}    coam.get_historic_alarms    connection=${connection}    timeout=${timeout}    load_history=${True}
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
       Exit For Loop If    ${alarm_num}==${0}
       ${present_status}    Run Keyword And Return Status    Run Keywords
                  ...                      Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
                  ...                      Run Keyword If    '${source}'!='${None}'
                  ...                      Should Contain     ${alarm['notifier']}    ${source}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${severity}'!='${None}'
                  ...                      Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${alarmId}'!='${None}'
                  ...                      Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}    AND
                  ...                      Run Keyword If    '${config_object_name}'!='${None}'
                  ...                      Should Contain    ${alarm['configObjectName']}    ${config_object_name}    AND
                  ...                      Run Keyword If    '${Supplementary}'!='${None}'
                  ...                      Should Contain   ${alarm['supplAlarmInfo']}    ${Supplementary}    AND
                  ...                      Run Keyword If    '${supplementary_not_contain}'!='${None}'
                  ...                      Should not Contain   ${alarm['supplAlarmInfo']}    ${supplementary_not_contain}
      Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.

Get BBOX5 on Minor Level Snapshot
    [Arguments]    ${str}=BBOX5    ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${serial_number}  Set Variable    ${ru_info['serialNumber']}
    ${snapshot_unzip_file_path_minor}    Save Minor Level Snapshot
    Log to console    \n************ check BBOX5 if exist in Minor level snapshot **************
    ${BBOX5_appear_times}    get_str_appeared_times_in_file     str=${str}
    ...    filepath=${snapshot_unzip_file_path_minor}/snapshot_file_list.txt
    should not be equal    ${BBOX5_appear_times}    '0'
    ${output}    OperatingSystem.get file    ${snapshot_unzip_file_path_minor}/snapshot_file_list.txt
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable    ${split_version}[0]
    ${pattern}    Set Variable if    '${stream}' >= 'SBTS25R2'
    ...    BTS_part(\\d+).zip:[^:]*BTS(\\d+)_${serial_number}_RMOD_L_\\d+_BBOX5
    ...    BTS_part(\\d+).zip:[^:]*BTS_${serial_number}_RMOD_L_\\d+_BBOX5
    ${bts_part_list}    Get Regexp Matches    ${output}    ${pattern}    1
    ${bts_part}    Set Variable    BTS_part${bts_part_list}[0]
    ${BBOX5_zip_filepath}    Join path    ${snapshot_unzip_file_path_minor}    ${bts_part}
    extract zip file    ${snapshot_unzip_file_path_minor}/${bts_part}.zip    ${BBOX5_zip_filepath}
    ${bbox5_files}    Run    command=cd ${BBOX5_zip_filepath}; ls BTS*_${serial_number}_RMOD_L_*_BBOX5.xz
    ${BBOX5_file}   Run Keyword If   "No such file" in "${bbox5_files}"     Get BBOX5 file path from zip
    ...   ${BBOX5_zip_filepath}   ${serial_number}
    ...   ELSE    Get BBOX5 file path from xz
    ...   ${BBOX5_zip_filepath}   ${bbox5_files}

    [Return]    ${BBOX5_file}

Get BBOX5 file path from zip
    [Arguments]    ${BBOX5_zip_filepath}   ${serial_number}
    ${bbox5_file}    Run    command=cd ${BBOX5_zip_filepath}; ls BTS*_${serial_number}_RMOD_L_*_BBOX5_all.zip
    Run    command=cd ${BBOX5_zip_filepath}; unzip ${bbox5_file}
    ${bbox5_content}    Run    command=cat ${BBOX5_zip_filepath}/BBOX5
    ${BBOX5_original_file}    Join path    ${BBOX5_zip_filepath}    BBOX5
    # ${BBOX5_file}    file_replace    filepath=${BBOX5_original_file}
    [Return]    ${BBOX5_original_file}

Get BBOX5 file path from xz
    [Arguments]    ${BBOX5_zip_filepath}   ${bbox5_file}
    Run    command=cd ${BBOX5_zip_filepath}; unxz ${bbox5_file}
    ${bbox5_content}    Run    command=cat ${BBOX5_zip_filepath}/${bbox5_file[:-3]}
    ${BBOX5_original_file}    Join path    ${BBOX5_zip_filepath}    ${bbox5_file[:-3]}
    [Return]    ${BBOX5_original_file}

Get BBOX5 on Full Level Snapshot
    [Arguments]    ${str}=BBOX5    ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${serial_number}  Set Variable    ${ru_info['serialNumber']}
    ${snapshot_unzip_file_path_full}    Save Full Level Snapshot
    Log to console    \n************ check BBOX5 if exist in full level snapshot **************
    ${BBOX5_appear_times}    get_str_appeared_times_in_file     str=${str}
    ...    filepath=${snapshot_unzip_file_path_full}/snapshot_file_list.txt
    should not be equal    ${BBOX5_appear_times}    '0'
    ${output}    OperatingSystem.get file    ${snapshot_unzip_file_path_full}/snapshot_file_list.txt
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable    ${split_version}[0]
    ${pattern}    Set Variable if    '${stream}' >= 'SBTS25R2'
    ...    BTS_part(\\d+).zip:[^:]*BTS(\\d+)_${serial_number}_RMOD_L_\\d+_BBOX5
    ...    BTS_part(\\d+).zip:[^:]*BTS_${serial_number}_RMOD_L_\\d+_BBOX5
    ${bts_part_list}    Get Regexp Matches    ${output}    ${pattern}    1
    ${bts_part}    Set Variable    BTS_part${bts_part_list}[0]
    ${BBOX5_zip_filepath}    Join path    ${snapshot_unzip_file_path_full}    ${bts_part}
    extract zip file    ${snapshot_unzip_file_path_full}/${bts_part}.zip    ${BBOX5_zip_filepath}
    ${bbox5_file}    Run    command=cd ${BBOX5_zip_filepath}; ls BTS*_${serial_number}_RMOD_L_*_BBOX5.xz

    ${BBOX5_file}   Run Keyword If   "No such file" in "${bbox5_file}"     Get BBOX5 file path from zip
    ...   ${BBOX5_zip_filepath}   ${serial_number}
    ...   ELSE    Get BBOX5 file path from xz
    ...   ${BBOX5_zip_filepath}   ${bbox5_file}
    [Return]    ${BBOX5_file}

check RF internal faults
    [Arguments]    ${ru_index}=${1}    ${blackbox5}=BBOX5
    log to console    ${blackbox5}
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_alias=RU_${ru_index}
    csn.send command    command=cd /run/;cat fault_history_log.txt|tail -n +24|cut -d ' ' -f 3    connection=RU_${ru_index}
    Sleep    2s
    ${result_RF_internal_faults}    csn.read output    connection=RU_${ru_index}
    ${RF_internal_faults}    Create List    ${result_RF_internal_faults}
    ${str_faults}    Convert to string    ${RF_internal_faults}
    ${events}    duplicate_removal_list    str=${str_faults}
    csn.Disconnect    connection=RU_${ru_index}
    [Return]    ${events}

Save Full Level Snapshot
    [Arguments]    ${snapshot_path}=${TS_CASE_LOG_PATH}    ${connection}=GNB_OAM
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    ${snapshot_zip_file_full}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
    coam.get_snapshot    target_file_name=${snapshot_zip_file_full}    coverage=Full    timeout=1500    connection=${connection}
    ${snapshot_unzip_file_path_full}    Join Path    ${snapshot_path}    snapshot_${timestamp}
    extract zip file    ${snapshot_zip_file_full}    ${snapshot_unzip_file_path_full}
    [Return]    ${snapshot_unzip_file_path_full}

Save Minor Level Snapshot
    [Arguments]    ${snapshot_path}=${TS_CASE_LOG_PATH}    ${connection}=GNB_OAM
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    ${snapshot_zip_file_minor}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
    coam.get_snapshot    target_file_name=${snapshot_zip_file_minor}    coverage=Minor    timeout=1500    connection=${connection}
    ${snapshot_unzip_file_path_minor}    Join Path    ${snapshot_path}    snapshot_${timestamp}
    extract zip file    ${snapshot_zip_file_minor}    ${snapshot_unzip_file_path_minor}
    [Return]    ${snapshot_unzip_file_path_minor}