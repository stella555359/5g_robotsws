*** Settings ***
Documentation     author: Wu Pengliang
...               contact: pengliang.wu@nokia.com
...               squad group: HAZ7


Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008927/Resources/common_keyword.robot
Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008927-N/Resources/CB008927_common_keyword.robot
Library      ./CB014474_A_TTI_Trace_Analysis_FDD.py


*** Variables ***
${iperf_port_list}               ${tl.ues[0].iperf_details.ports}
${14474_FDD_scf_extend_name}    _14474_FDD   #full name is SCF_${version_scf}${scf_name}.xml


*** Keywords ***
CB014474_168_Suit_Setup
    Setup Commission SCF    scf_name=${14474_FDD_scf_extend_name}    timeout=600
    Append to list    ${allowed_alarm_list}    ${7311}
    Check GNB on air And alarm    bts_host=${gNB_ip}    allowed_list=${allowed_alarm_list}    time=20min    interval=180
    ${cell_list}    Create List    2752513
    ${non_dyn_ue_list}    Create List    1   2
    Set Suite Variable    ${cell_list}
    Set Suite Variable    ${dynamic_ue_index}    0
    Set Suite Variable    ${m90_dynamic_ue_index}    3
    Set Suite Variable    ${non_dyn_ue_list}
    ${dynamic_ue_type}    translate_power_ue_type_from_testline    ue_index=${dynamic_ue_index}
    Set Suite Variable    ${dynamic_ue_type}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=1
    Set Suite Variable    ${ue_type}
    ${nr_phy_cell_ids}    set variable    56
    Set Suite Variable    ${nr_phy_cell_ids}

CB014474_168_Case_Teardown
    SISO_common_operation.Common Case Teardown    bts_host=${gNB_ip}  # if failed will collect snapshot
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Setup Commission SCF    scf_name=${14474_FDD_scf_extend_name}    timeout=600
    Append to list    ${allowed_alarm_list}    ${7311}
    Run Keyword And Ignore Error    Check GNB on air And alarm    bts_host=${gNB_ip}
    ...    allowed_list=${allowed_alarm_list}    time=20min    interval=180

M90 Dyn 10M UE L3 Call and Start Traffic
    [Arguments]    ${dl_tput}=100Mbits/sec    ${ue_index}=${m90_dynamic_ue_index}
    Log to console    \nM90 Dyn 10M UE Attach
    MTK UE Click on airplane mode    ue_mode=Attach   ue_index=${ue_index}
    Log to console    M90 Dyn 10M UE Start Traffic ${dl_tput}
    power_ue.Start traffic    ue_type=samsung    direction=dl    throughput=${dl_tput}    ue_index=${ue_index}
    ...   protocol=udp    duration=1200    iperf_port=${iperf_port_list[${-2}]}
    log to console    M90 10M dynamic UE start dl traffic
    [Teardown]

### M90 ###
MTK UE Click on airplane mode
    [Documentation]   click AIRPLANE
    ...    :param  ue_mode: Attach  or  Dettach
    [Arguments]   ${ue_mode}    ${ue_index}=${3}
    Connect to control pc via cygwin    ue_index=${ue_index}
    Run Keyword If    '${ue_mode}'=='Dettach'    Dettach UE By Adb Command    ue_index=${ue_index}
    Run Keyword If    '${ue_mode}'=='Attach'    Run Keywords    Dettach UE By Adb Command    ue_index=${ue_index}    AND
    ...    Attach UE By Adb Command    ue_index=${ue_index}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect      connection=cygwin

Dettach UE By Adb Command
    [Arguments]    ${ue_index}=${0}
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} root    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} shell settings put global airplane_mode_on 1
    ...    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command
    ...    command=adb -s ${serial_number} shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true    connection=cygwin
    sleep   4s

Attach UE By Adb Command
    [Arguments]    ${ue_index}=${0}
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} root    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} shell settings put global airplane_mode_on 0
    ...    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command
    ...    command=adb -s ${serial_number} shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false    connection=cygwin
    sleep   4s



### other UE ###
MTP Dyn UE L3 Call and Start Traffic
    [Arguments]    ${dl_tput}=100Mbits/sec
    Log to console    \nMTP Dyn UE Attach
    power_ue.Prepare UE    ue_index=${dynamic_ue_index}    ue_type=${dynamic_ue_type}
    sleep    5s
    ${dynamic_ue_ip}    MTP attach and verify    ue_index=${dynamic_ue_index}    ue_type=${dynamic_ue_type}    apn=${apn0}
	log to console      dynamic ue ip: ${dynamic_ue_ip}
    sleep    5s
    Log to console    MTP Dyn UE Start Traffic ${dl_tput}
    power_ue.Start traffic    ue_type=${dynamic_ue_type}    direction=dl    throughput=${dl_tput}    apn_address=${apn0}
    ...   protocol=udp    duration=1200    ue_index=${dynamic_ue_index}    iperf_port=${iperf_port_list[${-1}]}
    log to console    dynamic UE start dl traffic
    [Teardown]

Spark Non-Dyn UE L3 Call and Start Traffic
    [Arguments]    ${if_check}=${False}    ${ue1_dl_tput}=10Mbits/sec    ${ue2_dl_tput}=100Mbits/sec
    &{ues_tput}    Create Dictionary    1=${ue1_dl_tput}    2=${ue2_dl_tput}
    &{ues_exp}    Create Dictionary    1=8    2=90
    Log to console    Spark Non-Dyn UE Attach And Start Traffic &{ues_tput}
    MultiUE L3 call DL and check throughput    ue_list=${non_dyn_ue_list}    apn=${apn0}    ues_tput=${ues_tput}    ues_exp=${ues_exp}
    ...    if_check=${if_check}    get_spark_license=${True}
    [Teardown]

All UE Stop traffic and detach
    [Arguments]    ${if_MTP}=${True}    ${if_spark_UE}=${True}    ${if_M90}=${True}
    Run Keyword if    ${if_MTP}    MTP Dyn UE Stop traffic and detach
    Run Keyword if    ${if_spark_UE}    Spark Non-Dyn UE Stop traffic and detach
    Run keyword if    ${if_M90}    M90 UE Stop traffic and detach

Spark Non-Dyn UE Stop traffic and detach
    Log to console    spark non-dyn UE Stop traffic and detach
    Run Keyword And Ignore Error    MultiUE Stop dl traffic    ue_list=${non_dyn_ue_list}    apn=${apn0}
    Run Keyword And Ignore Error    common_keyword.MultiUE Detach    ue_list=${non_dyn_ue_list}

MTP Dyn UE Stop traffic and detach
    Log to console    MTP dyn UE Stop traffic and detach
    Run Keyword And Ignore Error    power_ue.Stop traffic    direction=dl    ue_index=${dynamic_ue_index}
    ...    ue_type=${dynamic_ue_type}    apn_address=${apn0}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${dynamic_ue_index}    ue_type=${dynamic_ue_type}

M90 UE Stop traffic and detach
    Log to console    M90 dyn UE Stop traffic and detach
    Run Keyword And Ignore Error    power_ue.Stop traffic    direction=dl    ue_index=${m90_dynamic_ue_index}
    ...    ue_type=samsung    iperf_port=${iperf_port_list[${-2}]}
    Run Keyword And Ignore Error    MTK UE Click on airplane mode    ue_mode=Dettach    ue_index=${m90_dynamic_ue_index}

Check DL Throught From Asslog
    [Arguments]    ${dl_list}=${cell_list}    ${dl_tp}=500
    ...    ${target_avg_percent}=0.98   ${log_time}=60s    ${min_percent}=0.85    ${ignore_time}=10s
    ${log_path}    power_ue.Collect Tput   ue_type=samsung    duration=${log_time}    ignore_time=${ignore_time}
    ${dl_result}    run keyword and continue on failure    power_ue.Check Tput    ue_type=samsung
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${dl_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=${min_percent}
    Log to console    ${dl_result}

Check TTI Trace
    [Arguments]    ${dl_tti_path}    ${target_prb_count}=${106}    ${prb_ratio}=${0.9}    ${required_slot_for_dyn_rat0}=0,5
    Log to console    Start to check TTI Trace
    ${current_time}    DateTime.Get Current Date    result_format=%Y_%m_%d_%H_%M_%S
    ${output_path}    set variable    ${case_log}/extracted_columns_${current_time}.csv
    extract_csv_columns    input_file_path=${dl_tti_path}    output_file_path=${output_path}
    ${aggregated_data}    aggregate_data_by_group    input_file_path=${dl_tti_path}
    ${aggregated_data_output_path}    set variable    ${case_log}/aggregated_data_${current_time}.csv
    ${export_success}    export_aggregated_data_to_csv    aggregated_data=${aggregated_data}
    ...    output_file_path=${aggregated_data_output_path}
    ${prb_check}    check_prb_ratio    aggregated_data=${aggregated_data}    target_prb_count=${target_prb_count}
    ...    threshold=${prb_ratio}
    ${slot_check}    check_rat0bitmap_slot_coverage    aggregated_data=${aggregated_data}
    ...    required_slots_str=${required_slot_for_dyn_rat0}
    Should be True    ${prb_check}    msg=target_prb_count:${target_prb_count} check failed, ratio<${prb_ratio}
    Should be True    ${slot_check}    msg=dynamic rat0 slot:${slot_check} check failed
    Log to console    TTI Check PASS
