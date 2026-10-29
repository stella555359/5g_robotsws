*** Settings ***
Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB006277 in 5G22R1 program

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot

*** Keywords ***
Get UE info and do L3 Call
    [Documentation]  cell_list: [1] or [1,2],
    ...              if cell list not mapping ue in init file, ue_index=0
    [Arguments]  ${cell_list}  ${ue_num_each_call}=1  ${4G_check}=${False}    ${dl_tp}=300M  ${ul_tp}=20M    ${duration}=${300}
    ...    ${dl_exp}=300    ${ul_exp}=20    ${actual_rate}=0.1    ${random_access}=${False}    ${check_wait_time}=30
    ...    ${loop_times}=${2}    ${with_peak}=${False}    ${target_avg_percent}=0.5    ${min_percent}=0.1    ${connection}=GNB_OAM
    ...    ${ue_ul_layer}=1    ${suite_name}=default    ${test_name}=default
    ${ue_index_list}    ${cell_list}    Get UE List for Given Cell List    cell_list=${cell_list}    ue_num_each_call=${ue_num_each_call}
    ${target_avg_percent}    set variable if    ${with_peak}    ${None}     ${target_avg_percent}
    ${min_percent}    set variable if    ${with_peak}    ${None}     ${min_percent}
    ${path}    ${scf_name}    split path    path=${SCF_Path}
    ${testline_name}    Get Testline Name
    ${ue_ul_layer}    get_ue_ul_layer_from_ue_mapping_file    testline_name=${testline_name}    ue_ul_layer=${ue_ul_layer}
    ...    scf_name=${scf_name}
    ${cell_and_peak_info}    run keyword if    ${with_peak}    generate peak information     cell_list=${cell_list}
    ...    connection=${connection}    ue_ul_layer=${ue_ul_layer}    duration=${duration}
    ...    l3_avg_rate=${target_avg_percent}    l3_min_rate=${min_percent}    suite_name=${suite_name}    test_name=${test_name}
    ...    ELSE    set variable    ${None}
    run keyword if  ${ue_index_list}!=${None}   Do L3 call and Check Throughput    ue_index_list=${ue_index_list}  cell_list=${cell_list}
    ...    4G_check=${4G_check}    dl_tp=${dl_tp}    ul_tp=${ul_tp}   duration=${duration}
    ...    dl_exp=${dl_exp}    ul_exp=${ul_exp}    actual_rate=${actual_rate}    random_access=${random_access}
    ...    loop_times=${loop_times}    check_wait_time=${check_wait_time}    cell_and_peak_info=${cell_and_peak_info}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    ELSE  log to console  no ue on ${cell_list}!!!
Do L3 call and Check Throughput
    [Arguments]  ${ue_index_list}=${None}  ${cell_list}=${None}   ${4G_check}=${False}    ${dl_tp}=300M  ${ul_tp}=20M    ${duration}=${600}
    ...    ${dl_exp}=300    ${ul_exp}=20    ${actual_rate}=0.1    ${random_access}=${False}    ${protocol}=udp
    ...    ${loop_times}=${2}    ${cell_and_peak_info}=${None}    ${check_wait_time}=30    ${iperf_type}=${None}
    ...    ${target_avg_percent}=0.95    ${min_percent}=0.85
    log to console    \n***L3 call with Check Throughput***
    ${status}    set variable
    FOR  ${i}  IN RANGE  ${loop_times}
       ${status}  run keyword and return status    L3 Call And Traffic    dl_tp=${dl_tp}   ul_tp=${ul_tp}
       ...        duration=${duration}  dl_exp=${dl_exp}  ul_exp=${ul_exp}   actual_rate=${actual_rate}
       ...        ue_index_list=${ue_index_list}  cell_list=${cell_list}  4G_check=${4G_check}    protocol=${protocol}
       ...        random_access=${random_access}  cell_and_peak_info=${cell_and_peak_info}    iperf_type=${iperf_type}
       ...        target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
       exit for loop if    ${status}
    END
    run keyword if      not ${status}    FAIL
L3 Call And Traffic
    [Arguments]    ${ue_index_list}=${None}    ${cell_list}=${None}   ${4G_check}=${False}    ${dl_tp}=300M  ${ul_tp}=100M
    ...    ${duration}=${600}    ${dl_exp}=60    ${ul_exp}=20    ${actual_rate}=0.1    ${protocol}=udp    ${random_access}=${False}
    ...    ${interval}=10s    ${du_index}=0    ${connection}=GNB_OAM    ${is_need_to_capture_log}=${False}
    ...    ${cell_and_peak_info}=${None}    ${check_wait_time}=30    ${iperf_type}=${None}
    ...    ${target_avg_percent}=0.95    ${min_percent}=0.85
    ${iperf_type}    Get Iperf Type    iperf_type=${iperf_type}    protocol=${protocol}
    ${ui_version}    Get UE UI Version
    ${ue_index_list}    run keyword if    '${ue_index_list}'=='${None}'    create list    ${0}
    ...    ELSE    set variable    ${ue_index_list}
    ${cell_list}    run keyword if    '${cell_list}'=='${None}'    create list    ${1}
    ...    ELSE    set variable    ${cell_list}
    ${ue_and_cell}    Attach and Start Traffic    ue_index_list=${ue_index_list}    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ...    duration=${duration}    cell_and_peak_info=${cell_and_peak_info}    protocol=${protocol}    connection=${connection}
    ...    check_wait_time=${check_wait_time}    iperf_type=${iperf_type}    ui_version=${ui_version}     cell_id=${cell_list}[0]
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
Attach and Start Traffic
    [Arguments]  ${ue_index_list}    ${dl_tp}=300M  ${ul_tp}=100M  ${duration}=${600}  ${cell_and_peak_info}=${None}   ${protocol}=udp
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${check_wait_time}=30    ${iperf_type}=via_command    ${ui_version}=default
    ...    ${cell_id}=${1}
    log to console    \nUe Attach and Start DL UL Traffic
    ${ue_number}  get length  ${ue_index_list}
    ${ue_and_cell}    create dictionary
    ${process_num}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
        ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
        Connect to Common Unit Master  alias=${alias}
        connect to gnb coam via ssl    connection=${connection}
        ${time}  get time  epoch
        ${attach_log}    set variable    /tmp/5Grach.txt
        ${local_dir}    set variable    ${SAVE LOG DIRECTORY}/attach_ue_${ue_index}/${time}
        run keyword and ignore error    run keywords    Create directory    ${local_dir}    AND
        ...    csn.download file    remote_path=${attach_log}    local_path=${local_dir}/5Grach.txt   connection=${alias}
        #${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=${attach_log}
        #...    alias=${alias}    connection=${connection}
        run keyword and ignore error    csn.Execute    rm ${attach_log}   connection=${alias}
        set to dictionary  ${ue_and_cell}  ${ue_index}  ${cell_id}
        ${dl_tp}  ${ul_tp}  ${duration_call}  get_start_traffic_information    cell_id=${cell_id}    ue_number=${ue_number}  dl_tp=${dl_tp}
        ...    ul_tp=${ul_tp}    duration=${duration}    cell_and_peak_info=${cell_and_peak_info}
        ...    check_wait_time=${check_wait_time}
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
        ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${process_num}
        power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
        ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}    data_amount=2M
    END
    [Return]  ${ue_and_cell}

Samsung open screen
    [Arguments]   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${connection}=cygwin
    log to console    Samsung open screen
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep    2s
    csn.send_command   connection=${connection}
    ...   command=adb -s ${serial_number} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"
    sleep   2s
    ${output}   csn.read_output   connection=${connection}
    Run Keyword If   ${output.lower().count('mawake=false')}>0
    ...   csn.send_command   command=adb -s ${serial_number} shell input keyevent 26   connection=${connection}
    sleep   2s
    Run Keyword If   ${output.lower().count('isstatusbarkeyguard=true')}>0 or ${output.lower().count('mshowinglockscreen=true')}>0
    ...   csn.send_command   command=adb -s ${serial_number} shell input keyevent 82   connection=${connection}
    Run Keyword And Ignore Error    csn.send_command    
    ...    command=adb -s ${serial_number} shell input keyevent 3    connection=${connection}
    sleep   1s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    
    ...    command=adb -s ${serial_number} shell input swipe 500 2050 500 800     connection=${connection}
    sleep    2s
