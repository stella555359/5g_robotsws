*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: SG05 internal
...              Contact: yue.2.liu@nokia-sbell.com
...              Squard: HZ SG5


Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/get_case_variables.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/obtain_information.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/coam_parameter.py  WITH NAME  coam_parameter
Library    generate_theoretical_peak.py
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot

Library     taf.ue    WITH NAME    taf_ue
*** Keywords ***
Get UE From Init File and Make call with cpe 3_2 for 687 60M
    [Documentation]  cell_list: [1] or [1,2],
    ...              if cell list not mapping ue in init file, ue_index=0
    [Arguments]  ${cell_list}  ${ue_num_each_call}=1  ${4G_check}=${False}    ${dl_tp}=300M  ${ul_tp}=20M    ${duration}=${300}
    ...    ${dl_exp}=300    ${ul_exp}=20    ${actual_rate}=0.1    ${random_access}=${False}    ${check_wait_time}=30
    ...    ${loop_times}=${2}    ${with_peak}=${False}    ${target_avg_percent}=0.1    ${min_percent}=0.05
    ...    ${connection}=GNB_OAM    ${ue_ul_layer}=1    ${suite_name}=default    ${test_name}=default
    ${ue_index_list}    ${cell_list}    Get UE List for Given Cell List    cell_list=${cell_list}    ue_num_each_call=${ue_num_each_call}
    ${target_avg_percent}    set variable if    ${with_peak}    ${None}     ${target_avg_percent}
    ${min_percent}    set variable if    ${with_peak}    ${None}     ${min_percent}
    ${testline_name}    Get Testline Name
    ${path}    ${scf_name}    split path    path=${SCF_Path}
    ${ue_ul_layer}     get_ue_ul_layer_from_ue_mapping_file    testline_name=${testline_name}    ue_ul_layer=${ue_ul_layer}
    ...    scf_name=${scf_name}
    ${cell_and_peak_info}    run keyword if    ${with_peak}    generate peak information for 687     cell_list=${cell_list}
    ...    connection=${connection}    ue_ul_layer=${ue_ul_layer}    duration=${duration}
    ...    l3_avg_rate=${target_avg_percent}    l3_min_rate=${min_percent}    suite_name=${suite_name}    test_name=${test_name}
    ...    ELSE    set variable    ${None}
    run keyword if  ${ue_index_list}!=${None}  L3 call with Check Throughput with cpe 3_2    ue_index_list=${ue_index_list}  cell_list=${cell_list}
    ...    4G_check=${4G_check}    dl_tp=${dl_tp}    ul_tp=${ul_tp}   duration=${duration}
    ...    dl_exp=${dl_exp}    ul_exp=${ul_exp}    actual_rate=${actual_rate}    random_access=${random_access}
    ...    loop_times=${loop_times}    check_wait_time=${check_wait_time}    cell_and_peak_info=${cell_and_peak_info}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    ELSE  log to console  no ue on ${cell_list}!!!

Get UE From Init File and Make call with cpe 3_2
    [Documentation]  cell_list: [1] or [1,2],
    ...              if cell list not mapping ue in init file, ue_index=0
    [Arguments]  ${cell_list}  ${ue_num_each_call}=1  ${4G_check}=${False}    ${dl_tp}=300M  ${ul_tp}=20M    ${duration}=${300}
    ...    ${dl_exp}=300    ${ul_exp}=20    ${actual_rate}=0.1    ${random_access}=${False}    ${check_wait_time}=30
    ...    ${loop_times}=${2}    ${with_peak}=${False}    ${target_avg_percent}=0.1    ${min_percent}=0.05
    ...    ${connection}=GNB_OAM    ${ue_ul_layer}=1    ${suite_name}=default    ${test_name}=default
    ${ue_index_list}    ${cell_list}    Get UE List for Given Cell List    cell_list=${cell_list}    ue_num_each_call=${ue_num_each_call}
    ${target_avg_percent}    set variable if    ${with_peak}    ${None}     ${target_avg_percent}
    ${min_percent}    set variable if    ${with_peak}    ${None}     ${min_percent}
    ${testline_name}    Get Testline Name
    ${path}    ${scf_name}    split path    path=${SCF_Path}
    ${ue_ul_layer}    get_ue_ul_layer_from_ue_mapping_file    testline_name=${testline_name}    ue_ul_layer=${ue_ul_layer}
    ...    scf_name=${scf_name}
    ${cell_and_peak_info}    run keyword if    ${with_peak}    generate peak information     cell_list=${cell_list}
    ...    connection=${connection}    ue_ul_layer=${ue_ul_layer}    duration=${duration}
    ...    l3_avg_rate=${target_avg_percent}    l3_min_rate=${min_percent}    suite_name=${suite_name}    test_name=${test_name}
    ...    ELSE    set variable    ${None}
    run keyword if  ${ue_index_list}!=${None}  L3 call with Check Throughput with cpe 3_2    ue_index_list=${ue_index_list}  cell_list=${cell_list}
    ...    4G_check=${4G_check}    dl_tp=${dl_tp}    ul_tp=${ul_tp}   duration=${duration}
    ...    dl_exp=${dl_exp}    ul_exp=${ul_exp}    actual_rate=${actual_rate}    random_access=${random_access}
    ...    loop_times=${loop_times}    check_wait_time=${check_wait_time}    cell_and_peak_info=${cell_and_peak_info}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    ELSE  log to console  no ue on ${cell_list}!!!

L3 call with Check Throughput with cpe 3_2
    [Arguments]  ${ue_index_list}=${None}  ${cell_list}=${None}   ${4G_check}=${False}    ${dl_tp}=300M  ${ul_tp}=20M    ${duration}=${600}
    ...    ${dl_exp}=300    ${ul_exp}=20    ${actual_rate}=0.1    ${random_access}=${False}    ${protocol}=udp
    ...    ${loop_times}=${2}    ${cell_and_peak_info}=${None}    ${check_wait_time}=30    ${iperf_type}=${None}
    ...    ${target_avg_percent}=0.95    ${min_percent}=0.85   ${bip_log_path}=${SAVE LOG DIRECTORY}
    log to console    \n***L3 call with Check Throughput***
    log to console    ${check_wait_time}
    ${status}    set variable  ${True}
    FOR    ${i}    IN RANGE    ${loop_times}
        ${bip_log}   set variable if  ${status}  ${False}  ${True}
        ${status}  run keyword and return status  UE L3 Call And Throughput with cpe 3_2  dl_tp=${dl_tp}  ul_tp=${ul_tp}
        ...        duration=${duration}  dl_exp=${dl_exp}  ul_exp=${ul_exp}   actual_rate=${actual_rate}
        ...        ue_index_list=${ue_index_list}  cell_list=${cell_list}  4G_check=${4G_check}    protocol=${protocol}
        ...        random_access=${random_access}  cell_and_peak_info=${cell_and_peak_info}    iperf_type=${iperf_type}
        ...        target_avg_percent=${target_avg_percent}    min_percent=${min_percent}   bip_log=${bip_log}     bip_log_path=${bip_log_path}
        exit for loop if    ${status}
    END
    run keyword if      not ${status}    FAIL
UE L3 Call And Throughput with cpe 3_2
    [Arguments]    ${ue_index_list}=${None}    ${cell_list}=${None}   ${4G_check}=${False}    ${dl_tp}=300M  ${ul_tp}=100M
    ...    ${duration}=${600}    ${dl_exp}=60    ${ul_exp}=20    ${actual_rate}=0.1    ${protocol}=udp    ${random_access}=${False}
    ...    ${interval}=10s    ${du_index}=0    ${connection}=GNB_OAM    ${is_need_to_capture_log}=${False}
    ...    ${cell_and_peak_info}=${None}    ${check_wait_time}=30    ${iperf_type}=${None}
    ...    ${target_avg_percent}=0.95    ${min_percent}=0.85  ${bip_log}=${False}   ${bip_log_path}=${SAVE LOG DIRECTORY}
    ${iperf_type}    Get Iperf Type    iperf_type=${iperf_type}    protocol=${protocol}
    ${ui_version}    Get UE UI Version
    ${ue_index_list}    run keyword if    '${ue_index_list}'=='${None}'    create list    ${0}
    ...    ELSE    set variable    ${ue_index_list}
    ${cell_list}    run keyword if    '${cell_list}'=='${None}'    create list    ${1}
    ...    ELSE    set variable    ${cell_list}
    ${ue_and_cell}    Ue Attach and Start DL UL Traffic with cpe 3_2    ue_index_list=${ue_index_list}    dl_tp=${dl_tp}
    ...    ul_tp=${ul_tp}
    ...    duration=${duration}    cell_and_peak_info=${cell_and_peak_info}    protocol=${protocol}    connection=${connection}
    ...    check_wait_time=${check_wait_time}    iperf_type=${iperf_type}   ui_version=${ui_version}    4G_check=${4G_check}
    ...    bip_log_path=${bip_log_path}   bip_log=${bip_log}
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
Ue Attach and Start DL UL Traffic with cpe 3_2
    [Arguments]  ${ue_index_list}    ${dl_tp}=300M  ${ul_tp}=100M  ${duration}=${600}  ${cell_and_peak_info}=${None}   ${protocol}=udp
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${check_wait_time}=30    ${iperf_type}=via_command   ${ui_version}=default
    ...    ${4G_check}=${False}    ${bip_log_path}=${SAVE LOG DIRECTORY}  ${bip_log}=${False}
    log to console    \nUe Attach and Start DL UL Traffic
    ${ue_number}  get length  ${ue_index_list}
    ${ue_and_cell}    create dictionary
    ${process_num}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        run keyword if   ${bip_log}   run keyword and ignore error   Start BIP Logs Capture
        run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}   ui_version=${ui_version}
        #taf_ue.get_current_access_technology    UE_${ue_index}
        #run keyword and ignore error    taf_ue.set_access_technology    UE_${ue_index}    technology=NR5GSA    preferred=NR5GSA
        ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    	run keyword if   ${bip_log}   run keyword and ignore error   Stop BIP Logs Capture And DownLoad Logs   bip_log_path=${bip_log_path}
        ${4G_check_input}    set variable    ${4G_check}
        ${4G_check}    run keyword if    '${ue_type}'=='mtk'    set variable    ${4G_check}    ELSE    set variable    ${False}
        power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}    5Grach_ed=${5Grach_ed}    4G_check=${4G_check}
        ${4G_check}    set variable    ${4G_check_input}
        Connect to Common Unit Master  alias=${alias}
        connect to gnb coam via ssl    connection=${connection}
        ${time}  get time  epoch
        ${attach_log}    set variable    /tmp/5Grach.txt
        ${local_dir}    set variable    ${SAVE LOG DIRECTORY}/attach_ue_${ue_index}/${time}
        run keyword and ignore error    run keywords    Create directory    ${local_dir}    AND
        ...    csn.download file    remote_path=${attach_log}    local_path=${local_dir}/5Grach.txt   connection=${alias}
        ${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=${attach_log}
        ...    alias=${alias}    connection=${connection}
        run keyword and ignore error    csn.Execute    rm ${attach_log}   connection=${alias}
        set to dictionary  ${ue_and_cell}  ${ue_index}  ${cell_id}
        ${dl_tp}  ${ul_tp}  ${duration_call}  get_start_traffic_information    cell_id=${cell_id}    ue_number=${ue_number}
        ...    dl_tp=${dl_tp}
        ...    ul_tp=${ul_tp}    duration=${duration}    cell_and_peak_info=${cell_and_peak_info}
        ...    check_wait_time=${check_wait_time}
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
        ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${process_num}
        Start traffic with cpe 3_2     ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
        ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}
        ...    data_amount=2M
    END
    [Return]  ${ue_and_cell}
Start traffic with cpe 3_2
    [Arguments]    ${ue_type}    ${direction}   ${throughput}=10   ${apn_address}=wap1nokiacom
    ...            ${duration}=10   ${protocol}=udp    ${ue_index}=${0}    ${ue_mode}=SA
    ...            ${cap_index}=${0}   ${dt_index}=${0}    ${iperf_port}=default
    ...            ${interval}=1    ${buffer_size}=1400B    ${dt_name}=DT_1
    ...            ${ue_alias}=UE_${ue_index}    ${multidrb_QoS_dest}=${None}    ${appserver}=APPserver    ${iperf_type}=via_app
    ...            ${data_amount}=1M    ${connection_type}=app    ${process_num}=default
    ...            ${seg_size}=1180    ${window}=2M
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  dt_index: The new data transfer index alias.
    ...  :param  iperf_port: port number used for traffic start via iperf.
    ...  :param  dt_name: alias name for created data transfer.
    ...  :param  ue_alias: <str> store ue by ue_alias
    ...  :param  multidrb_QoS_dest: <optional> default None,
    ...                             multidrb_QoS_dest is a optional input,
    ...                             Setup UL traffic dest ip address for multidrb testing,
    ...                             Normal UL traffic ignore this param.
    ...  :param  cap_index: The list index from ue.capabilities[], will use the index capability for reserve.
    ...  :param  iperf_type: Traffic use iperf command or iperf app type.
    ...  :param  connection_type: net connection type, "app" or "current", "app" default.
    ...  :param  process_num: the number of process which are used for tcp data transfer, the more the better.
    ...  :param  seg_size: set TCP maximum segment size (MTU - 40 bytes)
    ...  :param  window: set TCP window size. eg, default value is 2M
    ${direction}=    Convert To Lowercase    ${direction}
    # If process_num was given by user, use the users value.
    # If not given, set default value by protocal, udp -> ${1} | tcp -> ${5}
    ${process_num}    run keyword if
    ...               '${process_num}'!='default'    set variable    ${process_num}
    ...               ELSE                           set variable if
    ...                                              '${protocol}'=='udp'    ${5}
    ...                                                                      ${5}
    ${output}    run keyword    ${ue_type}.Start traffic    direction=${direction}
    ...                                                     ue_index=${ue_index}
    ...                                                     dt_index=${dt_index}
    ...                                                     duration=${duration}
    ...                                                     throughput=${throughput}
    ...                                                     protocol=${protocol}
    ...                                                     iperf_port=${iperf_port}
    ...                                                     interval=${interval}
    ...                                                     buffer_size=${buffer_size}
    ...                                                     dt_name=${dt_name}
    ...                                                     ue_alias=${ue_alias}
    ...                                                     multidrb_QoS_dest=${multidrb_QoS_dest}
    ...                                                     cap_index=${cap_index}
    ...                                                     appserver=${appserver}
    ...                                                     iperf_type=${iperf_type}
    ...                                                     data_amount=${data_amount}
    ...                                                     apn_address=${apn_address}
    ...                                                     ue_mode=${ue_mode}
    ...                                                     connection_type=${connection_type}
    ...                                                     process_num=${process_num}
    ...                                                     seg_size=${seg_size}
    ...                                                     window=${window}
    [Return]    ${output}
Simple UE L3 Call And Throughput with cpe 3_2
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    ...    should add ue mapping in commissionings/HGZ/{testline_name}}/__init__.py
    [Arguments]    ${cell_list}=${None}    ${ue_num_for_call_per_cell}=1    ${dl_tp}=128  ${ul_tp}=12
    ...    ${duration}=${60}    ${protocol}=udp    ${check_wait_time}=30    ${log}=${CASE_LOG_PATH}
    ...    ${target_avg_percent}=0.95    ${min_percent}=0.85    ${scf_path}=${Golden_SCF_Path}
    ...    ${allowed_no_ue}=${False}
    ${cell_list}    run keyword if    '${cell_list}'=='${None}'    create list    ${1}
    ...    ELSE    set variable    ${cell_list}
    ${ue_index_list}    create list
    FOR    ${cell_id}    IN    @{cell_list}
        ${ue_list}    Simple Get UE List for Given Cell    cell_id=${cell_id}    ue_num_for_call_per_cell=${ue_num_for_call_per_cell}
        ...    scf_path=${scf_path}
        ${ue_index_list}    combine lists    ${ue_index_list}    ${ue_list}
    END
    ${ue_num}    get length    ${ue_index_list}
    run keyword if    not ${allowed_no_ue}    should not be empty    ${ue_index_list}
    ...    msg=Please add ue mapping in __init__.py under robotws/commissionings/HGZ/{testline_name}}, refer to 7_5_UTE5G402T319
    ...    ELSE IF    ${allowed_no_ue} and ${ue_num}==0    run keywords    log to console    no ue on cell ${cell_list}!!!    AND
    ...    return from keyword
    Simple Ue Prepare and transfer technology to LTE    ue_index_list=${ue_index_list}
    ${ue_num}    get length    ${ue_index_list}
    ${start_traffic_duration}    evaluate    ${duration}+${ue_num}*240
    ${start_traffic_dl}    evaluate    ${dl_tp}*1.25
    ${start_traffic_ul}    evaluate    ${ul_tp}*1.5
    Simple Ue Attach    ue_index_list=${ue_index_list}    scf_path=${scf_path}
    Simple Ue Start DL UL Traffic with cpe 3_2    ue_index_list=${ue_index_list}    dl_tp=${start_traffic_dl}    ul_tp=${start_traffic_ul}
    ...    duration=${start_traffic_duration}     protocol=${protocol}    scf_path=${scf_path}
    Simple Ue Collect Tput    ue_index_list=${ue_index_list}    duration=${duration}    ignore_time=${check_wait_time}
    Simple Ue Stop DL UL Traffic    ue_index_list=${ue_index_list}    protocol=${protocol}
    Simple UE Verify Peak Throughput    ue_index_list=${ue_index_list}    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    log=${log}
    Simple Ue Detach    ue_index_list=${ue_index_list}
Simple Ue Start DL UL Traffic with cpe 3_2
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ue_index_list}    ${dl_tp}=300    ${ul_tp}=10    ${duration}=${300}    ${protocol}=udp
    ...    ${scf_path}=${Golden_SCF_Path}
    log to console    \nUe Start DL UL Traffic
    log to console    ${scf_path}
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
        ...    protocol=${protocol}    duration=${duration}    ue_index=${ue_index}
        Start traffic with cpe 3_2    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
        ...    protocol=${protocol}    duration=${duration}    ue_index=${ue_index}
    END
Simple Ue Prepare and transfer technology to LTE
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ue_index_list}    ${mobile_network_system}=LTE     ${scf_path}=${Golden_SCF_Path}
    log to console    \nUe Prepare
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
        run keyword and ignore error    taf_ue.set_access_technology    UE_${ue_index}    technology=LTE    preferred=LTE
        Modify UE Capatibility to Given Params    ue_index=${ue_index}    mobile_network_system=${mobile_network_system}
        ...    scf_path=${scf_path}
    END
Restart CBRS via cygwin
    [Arguments]    ${filepath}=/cygdrive/c/Users/nokia5G/Desktop/CBRS/SASSim_0906
    ...    ${connection}=GNB_OAM
    Wait until keyword succeeds    4x    20s   Connect to control pc via cygwin    hostname=10.71.205.245
    ...    username=nokia5G
    ...    password=noki@123
    csn.send_command    command=taskkill /IM python.exe /F    connection=cygwin
    sleep    5s
    csn.send_command    command=cd ${filepath}&&python SAS_Sim.py   connection=cygwin
    sleep    10s
    csn.send_command    command=cd ${filepath}&&cmd.exe /c fastmile_server.bat   connection=cygwin
    sleep    5s
    Connect to gnb coam via ssl    connection=${connection}
    Wait until keyword succeeds    20 min    15 sec   Check all cells info should be onair    connection=${connection}
CB008952 Suite Level Setup
    #Restart CBRS via cygwin
    sleep    1s
    SISO Coam Suite Setup
CB008952 Case Level Setup
    run keyword and ignore error   SISO Coam Test Setup
    sleep    1s
    #Restart CBRS via cygwin
Manual_SiSo_SM_LTE_RAT_reset_with_CBRS
    [Arguments]  ${with_call}=${True}  ${with_peak}=${False}  ${call_duration}=${60}
    log to console    ${with_call}
    log to console    ${with_peak}
    log to console    ${call_duration}
    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}
    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}
    selenium_coam.reset_lte    cancel=True
    Verify all cells should be onair    cell_type=lte
    selenium_coam.reset_lte
    Wait Until Keyword Succeeds    5min    3s    Cell Status Info Should Be Disabled    bs_blocked=Unblocked
    #Restart CBRS via cygwin
    Wait Until Keyword Succeeds    30min    30s    Verify all cells should be onair    cell_type=lte
    Wait Until Keyword Succeeds    30min    30s    Verify all cells should be onair    cell_type=nr
    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}
    [Teardown]   Selenium Logout And Close Browser
Generate Peak Information for 687
    [Arguments]  ${cell_list}    ${connection}=GNB_OAM    ${ue_dl_layer}=4    ${ue_ul_layer}=1    ${duration}=${600}
    ...    ${l3_avg_rate}=${None}    ${l3_min_rate}=${None}    ${suite_name}=default    ${test_name}=default
    ${release}    Get program version based on gNB active version
    ${avg_expect_rate}    get_l3_avg_rate    suite_name=${suite_name}    test_name=${test_name}    release=${release}
    ...    l3_avg_rate=${l3_avg_rate}
    ${min_expect_rate}    get_l3_min_rate    suite_name=${suite_name}    test_name=${test_name}    release=${release}
    ...    l3_min_rate=${l3_min_rate}
    ${scf_path}    download scf download via rest api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    ${cell_and_peak_info}    create dictionary
    FOR    ${cell_id}    IN    @{cell_list}
        ${nband}    Get Cell Nband    cell_id=${cell_id}    connection=${connection}
        ${bbname}    Get bbmod name    cell_id=${cell_id}    connection=${connection}
        ${bbname}    set variable if    '${bbname}'=='${None}'    ABIO AirScale Capacity    ${bbname}
        ${peak_info}    generate_theoretical_peak.generate_real_peak_info_687    cell_id=${cell_id}    scf_path=${scf_path}
        ...    ue_dl_layer=${ue_dl_layer}
        ...    ue_ul_layer=${ue_ul_layer}    avg_expect_rate=${avg_expect_rate}    min_expect_rate=${min_expect_rate}
        ...    duration=${duration}    nband=${nband}    productName=${bbname}    release=${release}
        ${cell_id}    convert to string    ${cell_id}
        set to dictionary    ${cell_and_peak_info}    ${cell_id}    ${peak_info}
    END
    log to console    ${cell_and_peak_info}
    [Return]    ${cell_and_peak_info}
