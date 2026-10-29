*** Settings ***
Documentation    This is for CNI-126050
...              Author: Lin jiangjing
...              Contact: jiangjing.lin@nokia-sbell.com
...              squad: 5G_PZ_HZ_8_SG

Variables    ../TestData/variables_CNI_126050.py
Library    ../lib/CNI-126050.py
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008021/Resources/CB008021_Counter_Keywords.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/gnb_sync.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002637-A/Resources/5GC002637_common_keywords.robot

*** Variables ***
${ue_indexes}    ${0}    ${1}
${gnb_path}    /tmp
${wait_counter_generate_time}     30s

*** Keywords ***
CNI-126050_02_PM_Counters_Enabled_With_PRACH_PUCCH_F1
    [Arguments]    ${tput_info}    ${interval}
    ${local_path}    set variable    ${TS_CASE_LOG_PATH}
    set test variable    ${local_path}
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _CNI_126050.xml
    log to console    *****************step1: load scf and check all cells are on air*****************
    COAM Commission with scf file    scf_file_path=${SCF_upload}    timeout=${600}
    Wait Until Keyword Succeeds    15min    10s    verify all cells should be onair
    log to console    **************step2: ue1 attach, then make dl and ul data transfer*****************
    Set PA Value For Pointed Port    PA_Port_List=${A1B1_A4B4_RU1_UE0}   value=${10}
    ${tput_cell_1}    set variable    ${tput_info[1]}
    make_call    tput_info=${tput_cell_1}    ue_index=${0}
    Sleep to wait for counter generate    interval=${interval}
    log to console    *****************step3: check counter*****************\n
    ${filename}    Get PM counter file    mrbtsid=${mrbtsID}    interval=${interval}
    log to console    get counter value for M55360C00000……M55360C00272
    ${counters_avg_before_noise}    Get PM counter value list    target_list=${AVG_COUNTER_LIST}    pm_file=${local_path}/${filename}
    ${avg_counter_len}    Get Length    ${counters_avg_before_noise}
    log to console    get ${avg_counter_len} avg counter value
    ${avg_counter_avg_value}    Get list average value    target_list=${AVG_COUNTER_LIST}    pm_file=${local_path}/${filename}
    log to console    average value of avg counter before noise is ${avg_counter_avg_value}
    log to console    check all counter value > -140
    FOR    ${item}    IN    @{counters_avg_before_noise}
        should be true    ${item} > ${-140}
    END
    log to console    get counter value for M55360C01000…M55360C01272
    ${counters_max_before_noise}    Get PM counter value list    target_list=${MAX_COUNTER_LIST}    pm_file=${local_path}/${filename}
    ${max_counter_len}    Get Length    ${counters_max_before_noise}
    log to console    get ${max_counter_len} max counter value
    ${max_counter_avg_value}    Get list average value    target_list=${MAX_COUNTER_LIST}    pm_file=${local_path}/${filename}
    log to console    average value of max counter before noise is ${max_counter_avg_value}
    log to console    check all counter value > -140
    FOR    ${item}    IN    @{counters_max_before_noise}
        should be true    ${item} > ${-140}
    END
    log to console    check M55360C00000……M55360C00272 < M55360C01000…M55360C01272
    ${result}    compare_value_for_lists    list_s=${counters_avg_before_noise}    list_l=${counters_max_before_noise}
    should be true    ${result}==True
    log to console    **************step4: ue2 attach, then make ul data transfer to make noise*****************
    ${tput_cell_3}    set variable    ${tput_info[3]}
    make_call_ul_only    tput_info=${tput_cell_3}    ue_index=${1}
    Sleep to wait for counter generate    interval=${interval}
    log to console    *****************step5: check counter*****************\n
    ${filename}    Get PM counter file    mrbtsid=${mrbtsID}    interval=${interval}
    log to console    get counter value for M55360C00000……M55360C00272
    ${counters_avg_after_noise}    Get PM counter value list    target_list=${AVG_COUNTER_LIST}    pm_file=${local_path}/${filename}
    ${avg_counter_len}    Get Length    ${counters_avg_after_noise}
    log to console    get ${avg_counter_len} avg counter value
    ${avg_counter_avg_value}    Get list average value    target_list=${AVG_COUNTER_LIST}    pm_file=${local_path}/${filename}
    log to console    average value of avg counter after noise is ${avg_counter_avg_value}
    log to console    get counter value for M55360C01000…M55360C01272
    ${counters_max_after_noise}    Get PM counter value list    target_list=${MAX_COUNTER_LIST}    pm_file=${local_path}/${filename}
    ${max_counter_len}    Get Length    ${counters_max_after_noise}
    log to console    get ${max_counter_len} max counter value
    ${avg_counter_max_value}    Get list average value    target_list=${AVG_COUNTER_LIST}    pm_file=${local_path}/${filename}
    log to console    average value of max counter after noise is ${avg_counter_max_value}
    log to console    check M55360C00000……M55360C00272 < M55360C01000…M55360C01272
    ${result}    compare_value_for_lists     list_s=${counters_avg_after_noise}    list_l=${counters_max_after_noise}
    should be true    ${result}==True
    log to console    ****************step6: detach for ue1 and ue1*****************
    [Teardown]    run keywords    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_indexes}    AND
    ...    Save Coam Snapshot    target_dir=${TS_CASE_LOG_PATH}    connection=GNB_OAM    AND
    ...    COAM Commission with scf file    scf_file_path=${Golden_SCF_Path}    timeout=${600}    AND
    ...    wait until keyword succeeds    15min    10 sec    COAM Check GNB cell on air    connection=GNB_OAM    AND
    ...    Set PA Value For Pointed Port    PA_Port_List=${A1B1_A4B4_RU1_UE0}   value=${127}

Get PM counter file
    [Arguments]    ${mrbtsid}    ${interval}
    ${target_time}    get_pm_counter_time_for_file    interval=${interval}
    Sleep    ${wait_counter_generate_time}    # counter may not be generated on BTS when just pass target time
    ${filename}    Catenate    SEPARATOR=    PM.    BTS-    ${mrbtsid}.    ${target_time}    .ANY.xml
    log to console    counter file name is ${filename}
    ${zipfilename}    Catenate    SEPARATOR=    ${filename}    .gz
    Download and unzip counter file    zip_file=${zipfilename}
    [return]    ${filename}

Download and unzip counter file
    [Arguments]    ${zip_file}
    ...            ${hostname}=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...            ${username}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...            ${password}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    csn.Connect To    hostname=${hostname}     username=${username}    password=${password}    alias=gnb
    Wait Until Keyword Succeeds    1min    10sec    csn.download_file    remote_path=${gnb_path}/${zip_file}
    ...    local_path=${local_path}/${zip_file}    connection=gnb
    csn.Disconnect    connection=gnb
    unzip_counter_file    ${local_path}/${zip_file}

Get PM counter value list
    [Arguments]    ${target_list}    ${pm_file}
    ${counter_value_dict}    get_counter_value_from_counter_file    ${pm_file}    ${target_list}
    ${counter_value_list}    Get Dictionary Values    ${counter_value_dict}
    [return]    ${counter_value_list}

Sleep to wait for counter generate
    [Arguments]    ${interval}    ${is_add_one_period}=False
    ${sleep_time}    get_sleep_time_waiting_for_counter_create    interval=${interval}
    ${sleep_time}=    Run Keyword If    '${is_add_one_period}' == 'True'    Evaluate    ${sleep_time}+${interval}
    ...               ELSE    Evaluate    ${sleep_time}+0
    log to console    sleep ${sleep_time} mins to wait for expected counter generate...
    Sleep    ${sleep_time}min

Get list average value
    [Arguments]    ${target_list}    ${pm_file}
    ${counter_value_list}    Get PM counter value list    target_list=${target_list}    pm_file=${pm_file}
    ${average_value}    ${scheduled_number}    calculate_average_except_zero_value    value_list=${counter_value_list}
    ${average_value}    convert to string    ${average_value}
    [return]    ${average_value}
