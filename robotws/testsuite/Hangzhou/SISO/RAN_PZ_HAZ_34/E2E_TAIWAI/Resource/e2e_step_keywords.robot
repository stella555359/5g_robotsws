*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot


*** Keywords ***
Fail case Log collected
    [Arguments]  ${connection}=GNB_OAM    ${gnb_index}=${0}    ${case_status}=${True}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    run keyword and ignore error   run keyword if  not ${case_status}   Collect Coam Snapshot for Fail case
    ...    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}
    run keyword and ignore error   run keyword if  not ${case_status}   Collect Coam IM Snapshot for Fail case
    ...    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}
    run keyword and ignore error   run keyword if  not ${case_status}   Capture RU logs    connection=${connection}   gnb_index=${gnb_index}
    run keyword and ignore error   COAM Teardown gnb connections    connection=${connection}


Collect Coam Snapshot for Fail case
    [Arguments]    ${target_dir}=${OUTPUT DIR}     ${coverage}=Full    ${force}=${True}     ${timeout}=1500    ${connection}=GNB_OAM
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_path}      Set Variable    ${target_dir}/Snapshot_${time_stamp}.zip
    wait until keyword succeeds    3x    15m    coam.Get Snapshot
    ...                   target_file_name=${snapshot_path}
    ...                   coverage=${coverage}
    ...                   force=${force}
    ...                   connection=${connection}
    ...                   timeout=${timeout}

Collect Coam IM Snapshot for Fail case
    [Arguments]    ${target_dir}=${OUTPUT DIR}     ${timeout}=300    ${connection}=GNB_OAM
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_path}      Set Variable    ${target_dir}/Snapshot_${time_stamp}.ims2
    wait until keyword succeeds    3x    15m    coam.collect_im_snapshot
    ...                   target_file_name=${snapshot_path}
    ...                   connection=${connection}
    ...                   timeout=${timeout}

Make Call with all ue attached RU
    [Arguments]  ${connection}=GNB_OAM   ${duration}=${100}    ${with_peak}=${True}
    ${ru_index_list}    Get All RU Index    connection=${connection}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ru_index=${ru_index}    connection=${connection}
        Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${with_peak}    duration=${duration}
        ...    connection=${connection}
    END

Keep Site Status And L3 Call
    [Arguments]   ${connection}=GNB_OAM   ${gnb_index}=${0}
    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}   connection=${connection}
    Unexpect History Alarm Should Not Exist  allowed_faults=${ALLOWED_HISTORY_FAULT}    connection=${connection}
    ${cell_list}    get all cell id    connection=${connection}
    ${ue_index_list}   ${cell_list}   Get UE List for Given Cell List   cell_list=${cell_list}
    L3 call with Check Throughput E2E   ue_index_list=${ue_index_list}   cell_list=${cell_list}   loop_times=${2}
    ...   target_avg_percent=${0.1}   min_percent=${0}
    SISO Coam Test Teardown    gnb_index=${gnb_index}   is_case_teardown=${False}

Perform Site Reset And L3 Call
    [Arguments]   ${connection}=GNB_OAM   ${gnb_index}=${0}
    Selenium Login And Disable Screen Lock   gnb_index=${gnb_index}
    selenium_coam.reset_site
    sleep    3m
    COAM Wait gnb And Cells ready   connection=${connection}   gnb_index=${gnb_index}
    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}   connection=${connection}
    Unexpect History Alarm Should Not Exist  allowed_faults=${ALLOWED_HISTORY_FAULT}    connection=${connection}
    ${cell_list}    get all cell id    connection=${connection}
    ${ue_index_list}   ${cell_list}   Get UE List for Given Cell List   cell_list=${cell_list}
    L3 call with Check Throughput E2E   ue_index_list=${ue_index_list}   cell_list=${cell_list}   loop_times=${2}
    ...   target_avg_percent=${0.1}   min_percent=${0}
    SISO Coam Test Teardown    gnb_index=${gnb_index}   is_case_teardown=${False}
    [Teardown]  Run Keyword And Ignore Error   Selenium Logout And Close Browser

RU Lock Unlock And L3 Call
    [Arguments]   ${connection}=GNB_OAM   ${gnb_index}=${0}
    ${ru_index_list}    Get All RU Index   connection=${connection}
    Get X2 link shutdown waiting time   connection=${connection}
    Selenium Login And Disable Screen Lock   gnb_index=${gnb_index}
    Lock and Unlock all RUs  lock_list=${ru_index_list}
    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}   connection=${connection}
    Unexpect History Alarm Should Not Exist  allowed_faults=${ALLOWED_HISTORY_FAULT}    connection=${connection}
    ${cell_list}    get all cell id    connection=${connection}
    ${ue_index_list}   ${cell_list}   Get UE List for Given Cell List   cell_list=${cell_list}
    L3 call with Check Throughput E2E   ue_index_list=${ue_index_list}   cell_list=${cell_list}   loop_times=${2}
    ...   target_avg_percent=${0.1}   min_percent=${0}
    SISO Coam Test Teardown    gnb_index=${gnb_index}   is_case_teardown=${False}
    [Teardown]  Run Keyword And Ignore Error   Selenium Logout And Close Browser

Modify_PCI_value_from_WEBUI_with_L3call_Check
    [Arguments]  ${connection}=GNB_OAM   ${with_call}=${True}   ${with_peak}=${False}    ${duration}=${60}    ${ru_index}=1
    ...        ${gnb_index}=${0}   ${asik_alias}=ASIK Master
    ${scf_file_backup}    COAM Download scf from cluster  scf_dir_path=${SAVE LOG DIRECTORY}   connection=${connection}
    log to console   \n back up SCF PATH:${scf_file_backup}
    ${cell_list}    get all cell id   connection=${connection}
    log     ${cell_list}
    run keyword if  ${with_call}   run keyword and ignore error   Get UE From Init File and Make call E2E  cell_list=${cell_list}
    ...    with_peak=${with_peak}  duration=${duration}   connection=${connection}
    log   ${connection}
    Create file in RU E2E    ru_index=${ru_index}   connection=${connection}   gnb_index=${0}   asik_alias=${asik_alias}
    ${random_numbers}=    Evaluate    random.sample(range(100, 999), 1)    random
    ${physCellId}    set Variable   ${random_numbers}[0]
    Modify physCellId Parameters via WebUI    physCellId=${physCellId}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'  connection=${connection}  gnb_index=${gnb_index}
    run keyword if  ${with_call}  Get UE From Init File and Make call E2E  cell_list=${cell_list}
    ...    with_peak=${with_peak}  duration=${duration}   connection=${connection}
    Check file Exist in RU E2E     ru_index=${ru_index}    connection=${connection}   gnb_index=${0}   asik_alias=${asik_alias}

Modify physCellId Parameters via WebUI
    [Arguments]  ${physCellId}=888   ${gnb_index}=${0}
    log to console  Modify physCellId Parameters via WebUI
    Wait Until Keyword Succeeds    2min    30s    COAM Navigate to login page via webUI  gnb_index=${gnb_index}
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...    filter_param=Physical cell identifier  p_name=physCellId  value=${physCellId}
    append to list  ${modify_params}  ${item}
    Modify Parameters On Webem    modify_params=${modify_params}
    [Teardown]  COAM selenium logout

Create file in RU E2E
    [Arguments]  ${log_name}=123.txt  ${ru_index}=1   ${connection}=GNB_OAM  ${gnb_index}=${0}  ${asik_alias}=ASIK Master
    connection_alias_store.Connect to Common Unit Master    gnb_index=${gnb_index}    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}   asik_alias=${asik_alias}
    ...      connection=${connection}
    ...       ru_username=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...       ru_password=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    csn.execute     cd /tmp;${sudo} touch ${log_name}    connection=RU_${ru_index}
    sleep  2
    ${output}    csn.execute    command=${sudo} ls -l /tmp/${log_name}    connection=RU_${ru_index}
    sleep  2
    log    ${output}
    Should Not Contain      ${output}      No such file or directory
    [Return]  run keywords  csn.disconnect   connection=RU_${ru_index}

Check file Exist in RU E2E
    [Arguments]  ${log_name}=123.txt  ${ru_index}=1  ${connection}=GNB_OAM  ${gnb_index}=${0}  ${asik_alias}=ASIK Master
#    connect to common unit master
    connection_alias_store.Connect to Common Unit Master   gnb_index=${gnb_index}    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}  connection=${connection}
    ...       asik_alias=${asik_alias}
    ...       ru_username=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...       ru_password=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${output}    csn.execute    command=${sudo} ls -l /tmp/${log_name}    connection=RU_${ru_index}
    sleep  2
    log to console    ${output}
    Should Not Contain      ${output}      No such file or directory
    [Return]  run keywords  csn.disconnect   connection=RU_${ru_index}

COAM Navigate to login page via webUI E2E
    [Documentation]  Author: Ding Binmei HGZ_SG4
    ...              Description: If case failed, the snapshot from webUI will be stored in the ${download_dir} folder
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}
    ...            ${timeout}=${60}
    ...            ${gnb_index}=${0}
    ...            ${url}=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}
    ...                    username=${username}
    ...                    password=${password}
    ...                    download_dir=${download_dir}
    ...                    timeout=${timeout}
    selenium_coam.disable_message_box

Cell Block Unblock And L3 Call
    [Arguments]   ${connection}=GNB_OAM   ${gnb_index}=${0}
    Get X2 link shutdown waiting time   connection=${connection}
    Selenium Login And Disable Screen Lock   gnb_index=${gnb_index}
    ${cell_list}    get all cell id    connection=${connection}
    Block all Cells    block_list=${cell_list}   connection=${connection}
    UnBlock all Cells    block_list=${cell_list}   connection=${connection}
    ${ALLOWED_HISTORY_FAULT_after_cell_block}    Copy List    ${ALLOWED_HISTORY_FAULT}
    ${fault_dic}    Create Dictionary    faultId=${49}
    Append To List     ${ALLOWED_HISTORY_FAULT_after_cell_block}    ${fault_dic}
    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}   connection=${connection}
    Unexpect History Alarm Should Not Exist  allowed_faults=${ALLOWED_HISTORY_FAULT_after_cell_block}    connection=${connection}
    ${ue_index_list}   ${cell_list}   Get UE List for Given Cell List   cell_list=${cell_list}
    L3 call with Check Throughput E2E   ue_index_list=${ue_index_list}   cell_list=${cell_list}   loop_times=${2}
    ...   target_avg_percent=${0.1}   min_percent=${0}
    SISO Coam Test Teardown    gnb_index=${gnb_index}   is_case_teardown=${False}
    [Teardown]  Run Keyword And Ignore Error   Selenium Logout And Close Browser

Block all Cells
    [Arguments]  ${block_list}    ${connection}=GNB_OAM
    connect to gnb coam via ssl    connection=${connection}
    log to console  \n***Block all cells***
    FOR    ${idx}  IN  @{block_list}
        selenium_coam.block_cell    cell_idx=${idx}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${idx}
        Wait Until Keyword Succeeds   3 min  10 sec   Cell Should Be Blocked   cell_idx=${idx}   cell_group_idx=${cellgrp_id}
    END

UnBlock all Cells
    [Arguments]  ${block_list}    ${connection}=GNB_OAM
    connect to gnb coam via ssl    connection=${connection}
    log to console  \n***unLock cells and check status***
    FOR    ${idx}  IN  @{block_list}
        selenium_coam.unblock_cell    cell_idx=${idx}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${idx}
        Wait Until Keyword Succeeds   5 min  10 sec   cell should be unblocked   cell_idx=${idx}    cell_group_idx=${cellgrp_id}
    END
    Wait Until Keyword Succeeds    20min    30s    Verify all cells should be onair   connection=${connection}

L3 call with Check Throughput E2E
    [Arguments]  ${ue_index_list}=${None}  ${cell_list}=${None}   ${4G_check}=${False}    ${dl_tp}=300M  ${ul_tp}=20M    ${duration}=${600}
    ...    ${dl_exp}=300    ${ul_exp}=20    ${actual_rate}=0.1    ${random_access}=${False}    ${protocol}=udp
    ...    ${loop_times}=${2}    ${cell_and_peak_info}=${None}    ${check_wait_time}=30    ${iperf_type}=${None}
    ...    ${target_avg_percent}=0.95    ${min_percent}=0.85   ${alias}=ASIK Master
    Log    message=\nArgument check_wait_time=${check_wait_time} is not used and will be removed in the future.
    log to console    \n***L3 call with Check Throughput***
    ${status}    set variable  ${True}
    FOR  ${i}  IN RANGE  ${loop_times}
       ${bip_log}   set variable if  ${status}  ${False}  ${True}
#       ${bip_log}   set variable   ${True}
       ${status}  run keyword and return status  UE L3 Call And Throughput E2E  dl_tp=${dl_tp}  ul_tp=${ul_tp}
       ...        duration=${duration}  dl_exp=${dl_exp}  ul_exp=${ul_exp}   actual_rate=${actual_rate}
       ...        ue_index_list=${ue_index_list}  cell_list=${cell_list}  4G_check=${4G_check}    protocol=${protocol}
       ...        random_access=${random_access}  cell_and_peak_info=${cell_and_peak_info}    iperf_type=${iperf_type}
       ...        target_avg_percent=${target_avg_percent}    min_percent=${min_percent}   alias=${alias}  bip_log=${bip_log}
       exit for loop if    ${status}
    END
    run keyword if      not ${status}    FAIL
    Check RU Beamforming Status    check_count=${True}

UE L3 Call And Throughput E2E
    [Arguments]    ${ue_index_list}=${None}    ${cell_list}=${None}   ${4G_check}=${False}    ${dl_tp}=300M  ${ul_tp}=100M
    ...    ${duration}=${600}    ${dl_exp}=60    ${ul_exp}=20    ${actual_rate}=0.1    ${protocol}=udp    ${random_access}=${False}
    ...    ${interval}=10s    ${du_index}=0    ${connection}=GNB_OAM    ${is_need_to_capture_log}=${False}
    ...    ${cell_and_peak_info}=${None}    ${check_wait_time}=30    ${iperf_type}=${None}
    ...    ${target_avg_percent}=0.95    ${min_percent}=0.85  ${alias}=ASIK Master  ${bip_log}=${True}
    Log    message=\nArgument 4G_check=${4G_check} is not used and will be removed in the future.
    ${iperf_type}    Get Iperf Type    iperf_type=${iperf_type}    protocol=${protocol}
    ${ue_index_list}    run keyword if    '${ue_index_list}'=='${None}'    create list    ${0}
    ...    ELSE    set variable    ${ue_index_list}
    ${cell_list}    run keyword if    '${cell_list}'=='${None}'    create list    ${1}
    ...    ELSE    set variable    ${cell_list}
    run keyword if   ${bip_log}  run keyword and ignore error   Bip Capture with gnbMirroring scripts with retry    connection=${alias}
    sleep   40s
    ${ue_and_cell}   run keyword and continue on failure    Ue Attach and Start DL UL Traffic    ue_index_list=${ue_index_list}
    ...    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ...    duration=${duration}    cell_and_peak_info=${cell_and_peak_info}    protocol=${protocol}    connection=${connection}
    ...    check_wait_time=${check_wait_time}    iperf_type=${iperf_type}
    ${bip_log}    run keyword if   ${bip_log}  run keyword and ignore error   Stop BIP capture on ASIK if needed and download BIP Logs to testPC
    ...    log_path=${SAVE LOG DIRECTORY}   connection=${alias}
    teardown the aasyslog save progress
    ${cell_number}  get length  ${cell_list}
    ${ue_number}  get length  ${ue_index_list}
    run keyword if  ${random_access}  should be true  ${cell_number}>=${ue_number}
    sleep    ${check_wait_time}
    UE Verify Peak Throughput    ue_index_list=${ue_index_list}    ue_and_cell=${ue_and_cell}    dl_exp=${dl_exp}    ul_exp=${ul_exp}
    ...    interval=${interval}    duration=${duration}    actual_rate=${actual_rate}    du_index=${du_index}
    ...    gnb_ssl_connection=${connection}    is_need_to_capture_log=${is_need_to_capture_log}
    ...    cell_and_peak_info=${cell_and_peak_info}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    [Teardown]    run keywords  run keyword and ignore error  csn.disconnect    connection=ASIK Master  AND  Ue Stop DL UL Traffic and Detach
    ...    ue_index_list=${ue_index_list}    iperf_type=${iperf_type}    protocol=${protocol}

Get UE From Init File and Make call E2E
    [Documentation]  cell_list: [1] or [1,2],
    ...              if cell list not mapping ue in init file, ue_index=0
    [Arguments]  ${cell_list}  ${ue_num_each_call}=1  ${4G_check}=${False}    ${dl_tp}=300M  ${ul_tp}=20M    ${duration}=${30}
    ...    ${dl_exp}=300    ${ul_exp}=20    ${actual_rate}=0.1    ${random_access}=${False}    ${check_wait_time}=30
    ...    ${loop_times}=${2}    ${with_peak}=${False}    ${target_avg_percent}=0.1    ${min_percent}=0.05    ${connection}=GNB_OAM
    ...    ${ue_ul_layer}=1    ${suite_name}=default    ${test_name}=default
    ${ue_index_list}    ${cell_list}    Get UE List for Given Cell List    cell_list=${cell_list}    ue_num_each_call=${ue_num_each_call}
    ${target_avg_percent}    set variable if    ${with_peak}    ${None}     ${target_avg_percent}
    ${min_percent}    set variable if    ${with_peak}    ${None}     ${min_percent}
    ${cell_and_peak_info}    run keyword if    ${with_peak}    generate peak information     cell_list=${cell_list}
    ...    connection=${connection}    ue_ul_layer=${ue_ul_layer}    duration=${duration}
    ...    l3_avg_rate=${target_avg_percent}    l3_min_rate=${min_percent}    suite_name=${suite_name}    test_name=${test_name}
    ...    ELSE    set variable    ${None}
    run keyword if  ${ue_index_list}!=${None}  L3 call with Check Throughput E2E    ue_index_list=${ue_index_list}  cell_list=${cell_list}
    ...    4G_check=${4G_check}    dl_tp=${dl_tp}    ul_tp=${ul_tp}   duration=${duration}
    ...    dl_exp=${dl_exp}    ul_exp=${ul_exp}    actual_rate=${actual_rate}    random_access=${random_access}
    ...    loop_times=${loop_times}    check_wait_time=${check_wait_time}    cell_and_peak_info=${cell_and_peak_info}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    ELSE  log to console  no ue on ${cell_list}!!!

COAM Save snapshot via webUI E2E
    [Documentation]  Author: Fan Kaihui
    ...              Description: Snapshot logs will be stored under the indicate download_dir
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}    ${url}=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ${temp_dir_for_save_snapshot}    Set variable    /tmp/snapshot_ta
    Create directory    ${temp_dir_for_save_snapshot}
    run keyword and ignore error  Run   killall firefox
    COAM Navigate to login page via webUI    download_dir=${temp_dir_for_save_snapshot}    url=${url}    username=${username}    password=${password}
    run keyword and ignore error    selenium_coam.disable_message_box
    run keyword and ignore error    selenium_coam.disable_screen_lock
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    run keyword and ignore error    selenium_coam.continue_after_plug_and_play_modal_appear   timeout=15
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    selenium_coam.save_screenshot   filename=Screen_${curr_data}.png    screenshot_dir=${download_dir}
    selenium_coam.snapshot_collection_settings    coverage=All log files    save_location=Local
    log to console    begain save snapshot
    ${temp_snapshot_file_path}    selenium_coam.collect_snapshot
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    selenium_coam.save_screenshot   filename=Screen_${curr_data}.png    screenshot_dir=${download_dir}
    log to console  save snapshot done
    [Return]    ${temp_snapshot_file_path}   ${temp_dir_for_save_snapshot}
    [Teardown]    Run Keyword And Ignore Error    selenium logout and close browser

COAM Save snapshot via webUI And Downfile E2E
    [Documentation]  Author: Fan Kaihui
    ...              Description: Snapshot logs will be stored under the indicate download_dir
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}    ${url}=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
#    ${temp_snapshot_file_path}    set variable  ${True}
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    ${temp_snapshot_file_path}   ${temp_dir_for_save_snapshot}   wait until keyword succeeds   3x  30s   COAM Save snapshot via webUI E2E
    ...     download_dir=${download_dir}   url=${url}    username=${username}    password=${password}
    log to console    start to downfile
    Wait until keyword succeeds    2min    2sec    File should not be empty    ${temp_snapshot_file_path}
    ${final_snapshot_file_path}    Wait until keyword succeeds    3x    200ms    Copy file and verify file exists
    ...    source_file_path=${temp_snapshot_file_path}    dest_file_folder=${download_dir}
    log to console    start to empty directory
    [Return]    ${final_snapshot_file_path}
    [Teardown]    Run keyword and ignore error    Empty directory    path=${temp_dir_for_save_snapshot}

Disconnect And Recovery Fiber Via BBMOD Type
    [Documentation]  Author: Fan Kaihui
    ...              Description: fiber disconnect and recovery fiber via BBMOD type
    [Arguments]       ${alias}=ASIK MASTER   ${bbmod_type}=ABIL   ${recovery_duration}=3s
    Connect to Common Unit Master  alias=${alias}
    ${output}   Run Keyword If  '${bbmod_type}'=='ABIL'   csn.Execute   command=bsh 1:2 syscomctl stats list client | grep sfpd   connection=${alias}
    ...    ELSE IF   '${bbmod_type}'=='ABIO'   csn.Execute   command=bsh 1:1 syscomctl stats list client | grep sfpd   connection=${alias}
    ${output_prefix}   Set Variable   ${output.split('|')[0]}
    ${output_prefix_four}   Set Variable   ${output_prefix[0:4]}
    #  disconnect fiber SFP1
    log to console   start break off fiber
    Run Keyword If   '${bbmod_type}'=='ABIL'   csn.Execute   command=bsh 1:2 sfp_tester set_tx 3 1 1 ${output_prefix_four}   connection=${alias}
    ...    ELSE IF   '${bbmod_type}'=='ABIO'   csn.Execute   command=bsh 1:1 sfp_tester set_tx 1 1 1 ${output_prefix_four}   connection=${alias}
    sleep   ${recovery_duration}
    log to console  wait for ${recovery_duration} to recovery fiber
    #  recovery fiber SFP1
    Run Keyword If   '${bbmod_type}'=='ABIL'   csn.Execute   command=bsh 1:2 sfp_tester set_tx 3 1 0 ${output_prefix_four}   connection=${alias}
    ...    ELSE IF   '${bbmod_type}'=='ABIO'   csn.Execute   command=bsh 1:1 sfp_tester set_tx 1 1 0 ${output_prefix_four}   connection=${alias}
    log to console   recovery fiber done
    [Teardown]    run keyword and ignore error   csn.disconnect    connection=ASIK Master

Start Attach And Call for UE With Try
    [Arguments]  ${ue_index_list}=${None}     ${dl_tp}=100M  ${ul_tp}=20M  ${cell_and_peak_info}=${None}   ${protocol}=udp
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${check_wait_time}=30    ${iperf_type}=via_command   ${ui_version}=default
    ...    ${4G_check}=${False}    ${bip_log_path}=${SAVE LOG DIRECTORY}   ${loop_times}=2      ${duration}=${3900}   ${bip_force_tag}=${False}
    Log    message=\nArgument check_wait_time=${check_wait_time} is not used and will be removed in the future.
    ${status}    set variable  PASS
    FOR    ${i}    IN RANGE    ${loop_times}
        ${bip_log}   set variable if  '${status}'=='PASS' and '${bip_force_tag}'=='False'  ${False}  ${True}
        ${status}    ${ue_and_cell}    run keyword and ignore error    Ue Attach and Start DL UL Traffic
        ...        ue_index_list=${ue_index_list}   dl_tp=${dl_tp}  ul_tp=${ul_tp}
        ...        duration=${duration}  4G_check=${4G_check}    protocol=${protocol}   alias=${alias}   connection=${connection}
        ...        cell_and_peak_info=${cell_and_peak_info}    iperf_type=${iperf_type}
        ...        ui_version=${ui_version}   bip_log=${bip_log}     bip_log_path=${bip_log_path}
        ${status_flag}   Run Keyword And Return Status   Should Be Equal As Strings   ${status}   PASS
        exit for loop if    ${status_flag}
    END
    run keyword if      not ${status_flag}   FAIL
    [Return]  ${ue_and_cell}

Collect_IQ_Data_on_WebEM
    [Arguments]     ${target_module}    ${target_output_file_path}
#    ...    ${lte_ul_cell_ids}    ${lte_dl_cell_ids}
    ...    ${nr_ul_subcell_list}    ${nr_dl_subcell_list}
#    ...    ${target_module}=MRBTS-586/EQM-1/APEQM-1/CABINET-1/BBMOD-1
#    ...    ${target_output_file_path}=test_iq_file.tgz
    ...    ${sfn}=${65535}    ${slot}=${79}
    ...    ${captureOnEvent}=${True}    ${capture_mode}=StartNewScheduledCapture
    ...    ${connection}=GNB_OAM
    [Documentation]  Author: Li Mengting
    ...    Description: This case is used to collect IQ data on webEM.
    ...    Example request:     "moduleDN":"MRBTS-586/EQM-1/APEQM-1/CABINET-1/BBMOD-1",
    ...                         "dlNrSubcellList": [{"nrcell_rDN": "MRBTS-586/NRBTS-586/NRCELL-1","subcellId":0}],
    ...                         "ulNrSubcellList": [{"nrcell_rDN": "MRBTS-586/NRBTS-586/NRCELL-1,"subcellId":0}],
    ...                         "dlLteCellList": [1],
    ...                         "ulLteCellList": [1],
    ...    "capture_mode":       'ScheduleSynchronousStopOfOngoingContinuousCapture', 'StartNewScheduledCapture'
    log to console   start catch IQ log by admin
    connect to gnb coam via ssl    connection=${connection}
    coam.configure_uplane_l1_iq_data    module_dn=${target_module}
    ...                                      ul_nr_subcell_list=${nr_ul_subcell_list}
    ...                                      dl_nr_subcell_list=${nr_dl_subcell_list}
#    ...                                      dl_lte_subcell_list=${lte_dl_cell_ids}
#    ...                                      ul_lte_subcell_list=${lte_ul_cell_ids}
    ...                                      capture_on_event=${captureOnEvent}
    ...                                      connection=${connection}
    coam.collect_uplane_l1_iq_data      target_output_file_path=${target_output_file_path}
    ...                                      module_dn=${target_module}
    ...                                      sfn=${sfn}
    ...                                      slot=${slot}
    ...                                      capture_mode=${capture_mode}
    ...                                      connection=${connection}
    [Teardown]     run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get Runtime FBB info
    [Arguments]     ${connection}=GNB_OAM
    ${FBB_output}=    coam.Get Fbb Info    connection=${connection}
    Log Many    ${FBB_output}
    ${runtime_bbmod_list}  create list
    FOR    ${item}    IN    @{FBB_output}
        append to list    ${runtime_bbmod_list}    ${item['id']['internal']}
    END
    [Return]    ${runtime_bbmod_list}

Get Runtime Subcell info
    [Arguments]     ${connection}=GNB_OAM
    ${Subcell_output}=    coam.get_subcells_info    connection=${connection}
    Log Many    ${Subcell_output}
    ${nrcell_list}  create list
    ${nrcell_LR_list}  create list
    ${runtime_cell_list}  create list
    ${nrcell_list}    Get Dictionary Values    ${Subcell_output}
    FOR    ${item}    IN   @{nrcell_list}
        ${val}    Get Dictionary Values    ${item}
        append to list    ${nrcell_LR_list}    ${val}
    END
    FOR    ${item}    IN    @{nrcell_LR_list}
        ${val}    set variable    ${item[0]}
        append to list    ${runtime_cell_list}    ${val['NRCELL_R']['distName']}
    END
    [Return]    ${runtime_cell_list}

Delta_Commissioning_With_actPdschAtSsbSlots_Change
    [Arguments]  ${connection}=GNB_OAM
    ${modify_params}    create list
    ${cell_list}    get all cell id via admin    connection=${connection}
    FOR    ${cell_id}    IN    @{cell_list}
        ${cell_dist_name}    get_cell_a_distname_via_admin    cell_id=${cell_id}    connection=${connection}
        ${value_list}    create list    true    false
        ${get_value}    coam.get_parameters    dist_name=${cell_dist_name}
        ...    pattern=actPdschAtSsbSlots
        ...    connection=${connection}
        ${get_value}    convert to string    ${get_value['actPdschAtSsbSlots']}
        Remove Values From List    ${value_list}    ${get_value.lower()}
        ${change_value}  evaluate  random.choice(${value_list})    modules=random
        ${new_item}    create dictionary    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
        ...    parameter=actPdschAtSsbSlots    value=${change_value}
        append to list    ${modify_params}    ${new_item}
    END
    ${delta_file}     coam_parameter.create_update_parameters_delta    parameters=${modify_params}    connection=${connection}
    coam_parameter.perform_scf_delta_commission    delta_file=${delta_file['updated']}    connection=${connection}    timeout=180s
    Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair    connection=${connection}
    FOR    ${param}    IN    @{modify_params}
        ${split}    Split String From Right     ${param}[dist_name]    -
        ${cell_id}    set variable    ${split}[-1]
        ${cell_dist_name}    get_cell_a_distname_via_admin    cell_id=${cell_id}    connection=${connection}
        ${get_value}    coam.get_parameters    dist_name=${cell_dist_name}
        ...    pattern=actPdschAtSsbSlots
        ...    connection=${connection}
        ${get_value}    convert to string    ${get_value['actPdschAtSsbSlots']}
        Should Be Equal As Strings    ${get_value.lower()}    ${param}[value]
        log to console  \nchange actPdschAtSsbSlots to ${get_value} successfully with cell ${cell_id}
    END

E2E_Get_Current_Version
    [Arguments]    ${gnb_index}=${0}    ${connection}=E2E_VERSION
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    Wait Until Keyword Succeeds    1 min    5 sec    coam.connect_to    bts_host=${bts_host}    bts_port=${443}
    ...    username=${username}    password=${password}   name=${connection}
    ${software_info}=    coam.get_software_info     connection=${connection}
    ${gnb_version}=       set variable    ${software_info['Active SW version']}

    ${IsTrunk}    run keyword and return status      Should Match Regexp    ${gnb_version}    .*_ENB_(9999|9990)_.*
    ${stream}    Fetch From Left    ${gnb_version}    _
    IF    ${IsTrunk}
        ${current_version}   Replace String    ${gnb_version}    ${stream}    SBTS00
    ELSE
        ${current_version}   set variable    ${gnb_version}
    END
    [Teardown]    Run keyword and ignore error    coam.teardown    connection=${connection}
    [Return]    ${current_version}

Get TDD cell list
    ${cell_list}    get all cell id
    ${tdd_cell_list}    create list
    FOR    ${cell_id}    IN    @{cell_list}
        ${cell_dist_name}    set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ${cellTechnology}    Get Parameter Via Webem    dist_name=${cell_dist_name}    filter_param=Cell technology
        run keyword if    '${cellTechnology.lower()}'=='tdd'    append to list    ${tdd_cell_list}    ${cell_id}
    END
    [Return]  ${tdd_cell_list}
