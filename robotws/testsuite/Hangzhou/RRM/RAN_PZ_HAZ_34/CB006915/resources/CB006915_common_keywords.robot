*** Settings ***
Documentation     author: Chen Helen
...               contact: helen.1.chen@nokia-sbell.com
...               squad group: MMW_02

Library      taf.selenium.sbts    WITH NAME    selenium_coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Library    ./CB006915_TTI_Trace_Analysis.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library      taf.hw.rf_attenuator.attenuator    WITH NAME    att

*** Variables ***
@{cpe_ue_index}    0    1    2    3    4
@{pci}    92    92    93    93    94
@{2mimocell_ids}    185663489    185663490
@{cell_id}    185663491
${ul_process_num}    5
@{counter_id}   M55308C10002    M55308C10006    M55308C35005    M55308C35007    M55308C10004
@{full_path}    CELLS/NRCELL-1/NCELA/PRB_USED_PUSCH
...             CELLS/NRCELL-1/NCELA/PRB_AVAIL_PUSCH_BB_POOL
...             CELLS/NRCELL-1/NCELA/PRB_UL_MU_MIMO_4LAYER
...             CELLS/NRCELL-1/NCELA/PRB_UL_MU_MIMO_2PAIR_UE
...             CELLS/NRCELL-1/NCELA/PRB_AVAIL_PUSCH
${ul_tp}    ${230}
${dl_tp}    ${1500}
${gnb_index}    0

*** Keywords ***
Case_Setup
    Log To Console    \n *** Case setup
    robot_common_operations.Common Case Setup
    ${connection}=    Set Variable If    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}

Case_Teardown
    Log To Console    \n *** Case teardown
    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    Run Keyword And Ignore Error    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    CI interface.Common Case Teardown
    Run Keyword And Ignore Error    Multi CPE Call Teardown    ue_index=1    cpe_ue_index=${cpe_ue_index}
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    Run Keyword And Ignore Error    ssh.send command    command=rm ${tti_script_path}/BTS-11332_${gnb_ip}_*_TTI
    ...    connection=ute
    Run Keyword And Ignore Error    ssh.send command    command=rm ${new_dir}/BTS-11332_${gnb_ip}_*_TTI
    ...    connection=ute
    Run Keyword And Ignore Error    ssh.disconnect    connection=ute

CPE prepare
    [Arguments]  ${ue_index}
    log to console    \nPrepare UE
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}

CPE attach and verify
    [Arguments]  ${ue_index}    ${pci}
    log to console    \nAttach UE
    ${5Grach_ed_0}    power_ue.UE Attach
    ...    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Iperf    pci=${pci}
    sleep    6s

CPE detach
    [Arguments]  ${ue_index}
    log to console    \nDetach UE
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}

CPE start dl ul traffic
    [Arguments]  ${ue_index}    ${dl_tp}    ${ul_tp}    ${duration}=${3600}    ${protocol}=udp
    log to console    \nUe Start DL UL Traffic
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=${protocol}    duration=${duration}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=${protocol}    duration=${duration}    ue_index=${ue_index}    process_num=${ul_process_num}

CPE start dl traffic
    [Arguments]  ${ue_index}    ${dl_tp}    ${duration}=${3600}    ${protocol}=udp
    log to console    \nUe Start DL UL Traffic
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=${protocol}    duration=${duration}    ue_index=${ue_index}

CPE stop dl ul traffic
    [Arguments]    ${ue_index}    ${protocol}=udp
    log to console    \nUe Stop DL UL Traffic
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    ...    ue_index=${ue_index}    protocol=${protocol}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
    ...    ue_index=${ue_index}    protocol=${protocol}

CPE stop dl traffic
    [Arguments]    ${ue_index}    ${protocol}=udp
    log to console    \nUe Stop DL UL Traffic
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    ...    ue_index=${ue_index}    protocol=${protocol}

CPE verify throughput
    [Arguments]  ${ue_index}    ${dl_exp}=1    ${ul_exp}=1    ${target_avg_percent}=0.80    ${min_percent}=0.60
    ...    ${log}=${TS_CASE_LOG_PATH}    ${check_source}=Iperf
    log to console    \nUE Verify Peak Throughput
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    ue_index=${ue_index}
    ...    direction=dl    target_throughput=${dl_exp}
    ...    log=${log}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    check_source=${check_source}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    ue_index=${ue_index}
    ...    direction=ul    target_throughput=${ul_exp}
    ...    log=${log}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    check_source=${check_source}

Call Teardown
    [Arguments]    ${ue_index}
    Run Keyword And Ignore Error    CPE stop dl ul traffic    ue_index=${ue_index}
    Run Keyword And Ignore Error    CPE detach    ue_index=${ue_index}

Single CPE DL Traffic
    [Arguments]    ${ue_index}
    CPE prepare    ue_index=${ue_index}
    CPE attach and verify    ue_index=${ue_index}    pci=${pci}[${ue_index}]
    CPE start dl traffic    ue_index=${ue_index}    dl_tp=${dl_tp}

Single CPE verify dl throughput
    [Arguments]    ${ue_index}    ${dl_exp}=1    ${target_avg_percent}=0.80
    ...    ${check_source}=aasyslog    ${cells}=1
    log to console    \nUE Verify Peak Throughput
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Collect Tput    ue_type=${ue_type}    duration=120    check_source=aasyslog
    power_ue.Check Tput    ue_type=${ue_type}    ue_index=${ue_index}
    ...    direction=dl    target_throughput=${dl_exp}
    ...    target_avg_percent=${target_avg_percent}    cells=${cells}
    ...    check_source=${check_source}

Multi CPE Call Teardown
    [Arguments]  ${ue_index}    ${cpe_ue_index}
    FOR    ${ue_index}    IN    @{cpe_ue_index}
    Call Teardown    ue_index=${ue_index}
    END

Multi CPE prepare
    [Arguments]  ${ue_index}    ${cpe_ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    FOR    ${ue_index}    IN    @{cpe_ue_index}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}
    END

Multi CPE attach and verify
    [Arguments]    ${ue_index}    ${cpe_ue_index}    ${pci}
    FOR    ${ue_index}    IN    @{cpe_ue_index}
    CPE attach and verify    ue_index=${ue_index}    pci=${pci}[${ue_index}]
    END

Multi CPE dl ul traffic
    [Arguments]  ${ue_index}    ${cpe_ue_index}    ${dl_tp}    ${ul_tp}
    FOR    ${ue_index}    IN    @{cpe_ue_index}
    CPE start dl ul traffic    ue_index=${ue_index}    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    END

Multi CPE dl traffic
    [Arguments]  ${ue_index}    ${cpe_ue_index}    ${dl_tp}
    FOR    ${ue_index}    IN    @{cpe_ue_index}
    CPE start dl traffic    ue_index=${ue_index}    dl_tp=${dl_tp}
    END

Multi CPE diff dl traffic
    [Arguments]  ${ue_index}    ${cpe_ue_index}    ${dl_tp}
    ${index}=    Set Variable    ${0}
    FOR    ${ue_index}    IN    @{cpe_ue_index}
        CPE start dl traffic    ue_index=${ue_index}    dl_tp=${dl_tp}[${index}]
        ${index}=    Evaluate    ${index} + 1
    END

Multi CPE stop dl ul traffic
    [Arguments]  ${ue_index}    ${cpe_ue_index}
    FOR    ${ue_index}    IN    @{cpe_ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    CPE stop dl ul traffic    ue_index=${ue_index}
    END

Multi CPE stop dl traffic
    [Arguments]  ${ue_index}    ${cpe_ue_index}
    FOR    ${ue_index}    IN    @{cpe_ue_index}
    CPE stop dl traffic    ue_index=${ue_index}
    END

Multi CPE verify throughput
    [Arguments]  ${ue_index}    ${cpe_ue_index}    ${dl_exp}    ${ul_exp}
    FOR    ${ue_index}    IN    @{cpe_ue_index}
    CPE verify throughput    ue_index=${ue_index}    dl_exp=${dl_exp}    ul_exp=${ul_exp}
    END

Multi_UEs_Check_Tput
    [Arguments]    ${cell_ids}    ${ultarget_throughput}    ${dltarget_throughput}
    log to console    check tput
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m    check_source=aasyslog
    ${length}      get length    ${cell_ids}
    FOR    ${index}    IN RANGE    ${length}
    @{cell_id}    Create List    ${cell_ids[${index}]}
    ${all1_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=@{cell_id}
    ...    ultarget_throughput=${ultarget_throughput}    dltarget_throughput=${dltarget_throughput}
    ...    actCarrierAggregation=${True}    target_avg_percent=0.8    min_percent=0.6
    END

Multi_UEs_Check_Tput_CAdisable
    [Arguments]    ${cell_ids}    ${ultarget_throughput}    ${dltarget_throughput}
    log to console    check tput
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m    check_source=aasyslog
    ${length}      get length    ${cell_ids}
    FOR    ${index}    IN RANGE    ${length}
    @{cell_id}    Create List    ${cell_ids[${index}]}
    ${all1_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=@{cell_id}
    ...    ultarget_throughput=${ultarget_throughput}    dltarget_throughput=${dltarget_throughput}
    ...    actCarrierAggregation=${False}    target_avg_percent=0.8    min_percent=0.6
    END

Muti_CPE_UEs_UL_DL_Traffic
   [Arguments]    ${ue_index}    ${cpe_ue_index}
    Multi CPE prepare    ue_index=${ue_index}    cpe_ue_index=${cpe_ue_index}
    Multi CPE attach and verify    ue_index=${ue_index}    cpe_ue_index=${cpe_ue_index}    pci=${pci}
    Multi CPE dl ul traffic    ue_index=${ue_index}    cpe_ue_index=${cpe_ue_index}
    ...    dl_tp=${dl_tp}    ul_tp=${ul_tp}

Muti_CPE_UEs_DL_Traffic
   [Arguments]    ${ue_index}    ${cpe_ue_index}    ${dl_tp}
    Multi CPE prepare    ue_index=${ue_index}    cpe_ue_index=${cpe_ue_index}
    Multi CPE attach and verify    ue_index=${ue_index}    cpe_ue_index=${cpe_ue_index}    pci=${pci}
    Multi CPE dl traffic    ue_index=${ue_index}    cpe_ue_index=${cpe_ue_index}    dl_tp=${dl_tp}

Muti_CPE_UEs_Different_DL_Traffic
   [Arguments]    ${ue_index}    ${cpe_ue_index}    ${dl_tp}
    Multi CPE prepare    ue_index=${ue_index}    cpe_ue_index=${cpe_ue_index}
    Multi CPE attach and verify    ue_index=${ue_index}    cpe_ue_index=${cpe_ue_index}    pci=${pci}
    Multi CPE diff dl traffic    ue_index=${ue_index}    cpe_ue_index=${cpe_ue_index}    dl_tp=${dl_tp}

Catch_Logs_Filter_dlFdSchedData_with_gnb_logs
    [Arguments]
    ...            ${duration}=4
    ...            ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=TTI
    log to console    --- start gnb_logs collection---
    ${log_type_to_command_mapping}    Create Dictionary    TTI=t    BIP=b   m=m
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ${cell_index}    Set Variable    1
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    ssh.send command    command=cd ${gnb_logs_script_path}&&sudo rm *${log_type}.zip   connection=ute
    ${start_capture_command}     Catenate
    ...    sudo ./gnb_logs ${gnb_ip} -C ${cell_index} -${log_type_to_command_mapping['${log_type}']} ${duration}
    ...    tti_Raw_logs_only = no Tti_decoding_filter_events = dlFdSchedData
    ssh.send command    command=cd ${gnb_logs_script_path}&&${start_capture_command}   connection=ute
    ${stop_capture}    ssh.read output until    finished    timeout=6000   connection=ute
    Run Keyword And Ignore Error    ssh.disconnect    connection=ute

Catch_Logs_with_gnb_logs
    [Arguments]
    ...            ${duration}=3
    ...            ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=TTI
    log to console    --- start gnb_logs collection---
    ${log_type_to_command_mapping}    Create Dictionary    TTI=t    BIP=b   m=m
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ${cell_index}    Set Variable    1
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    ssh.send command    command=cd ${gnb_logs_script_path}&&sudo rm *${log_type}.zip   connection=ute
    ${start_capture_command}     Catenate
    ...    sudo ./gnb_logs ${gnb_ip} -C ${cell_index} -${log_type_to_command_mapping['${log_type}']} ${duration}
    ...    tti_Raw_logs_only = no
    ssh.send command    command=cd ${gnb_logs_script_path}&&${start_capture_command}   connection=ute
    ${stop_capture}    ssh.read output until    finished    timeout=6000   connection=ute
    Run Keyword And Ignore Error    ssh.disconnect    connection=ute

Get_and_Unzip_Tti_Log
    [Arguments]
    ...    ${tti_script_path}=/home/ute/gnb_logs
    ...    ${new_dir}=/home/ute/output_log/
    ...    ${gnb_index}=0
    ...    ${du_index}=0
    log to console    get tti trace to Case_Logs file...
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ssh.send command    command=rm ${new_dir}/BTS-*_${gnb_ip}_*_TTI
    ...    connection=ute
    @{ttitrace_files}    List Files In Directory    ${tti_script_path}       BTS-*_${gnb_ip}_*_TTI.zip
    ssh.send command     command=unzip ${tti_script_path}/${ttitrace_files}[0] -d ${new_dir}
    ...    connection=ute
    sleep    40s
    ${tti_file_name}    Set Variable    ${ttitrace_files}[0]
    ${file_name}    Set Variable    ${tti_file_name.split('.zip')[0]}
    ${file_filter}    Set Variable    *_ttiTrace
    ${tti_file}    List Directories In Directory    ${new_dir}/${file_name}/tti/
    ...                                             ${file_filter}
    ...                                             absolute=${True}
    ${specific_ttitrace_file}    List Files In Directory    ${tti_file}[0]
    ...                                                     *.dlAndUl__all.csv
    ...                                                     absolute=${True}
    log to console    specific ttitrace file list : ${specific_ttitrace_file}
    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
    [Return]    ${specific_ttitrace_file}

Check_ZAB_Value
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    Run Keyword And Ignore Error    ssh.send command    command=rm -rf /home/ute/output_log/*
    ...    connection=ute
    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
    ${specific_ttitrace_file}    Get_and_Unzip_Tti_Log
    ${ZAB_result}    read_ZAB_privilege_value
    ...    csv_file=${specific_ttitrace_file}[0]
    ...    filter_name=hasZabPrivilege
    should be True    ${ZAB_result}

Check_2UE_Mumimo_Paired
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    Log to console     \n***check Mumimo paired***
    Run Keyword And Ignore Error    ssh.send command    command=rm -rf /home/ute/output_log/*
    ...    connection=ute
    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
    ${specific_ttitrace_file}    Get_and_Unzip_Tti_Log
    ${dl_mumimo}    check_dl_muStatus
    ...    csv_file=${specific_ttitrace_file}[0]
    ...    filter_name=muStatus
    should be True    ${dl_mumimo}
    ${ul_mumimo}    check_ul_muStatus
    ...    csv_file=${specific_ttitrace_file}[0]
    ...    filter_name=ulMuStatus
    should be True    ${ul_mumimo}

Check_PM_Counter
    Log to console    "Check M55308C10002 is almost equal to M55308C10006/M55308C10004"
    ${PM_counter_PRB_pusch}    Check PM counter from webui
    ...    counter_id=${counter_id}[0]    full_path=${full_path}[0]
    ${PM_counter_PRB_BB_pool}    Check PM counter from webui
    ...    counter_id=${counter_id}[1]     full_path=${full_path}[1]
    ${PM_counter_PRB_Avail_pusch}    Check PM counter from webui
    ...    counter_id=${counter_id}[4]     full_path=${full_path}[4]
    ${PM_counter_Sum_PRB_pusch}    Sum the list value    counter_result=${PM_counter_PRB_pusch}
    ${PM_counter_Sum_PRB_BB_pool}    Sum the list value    counter_result=${PM_counter_PRB_BB_pool}
    ${PM_counter_Sum_PRB_Avail_pusch}    Sum the list value    counter_result=${PM_counter_PRB_Avail_pusch}
    ${diff}    Evaluate
    ...    abs((${PM_counter_Sum_PRB_BB_pool}-${PM_counter_Sum_PRB_pusch})/${PM_counter_Sum_PRB_BB_pool})
    should be true    ${diff}< 0.01
    ${diff}    Evaluate
    ...    abs((${PM_counter_Sum_PRB_BB_pool}-${PM_counter_Sum_PRB_Avail_pusch})/${PM_counter_Sum_PRB_BB_pool})
    should be true    ${diff}< 0.01

Check_2UEs_not_Paired_counter
    Log to console    "Check M55308C35005 and M55308C35007 Values"
    ${PM_counter_PRB_UL_MU_MIMO_4LAYER}    Check PM counter from webui
    ...    counter_id=${counter_id}[2]    full_path=${full_path}[2]
    ${PM_counter_PRB_UL_MU_MIMO_2PAIR_UE}    Check PM counter from webui
    ...    counter_id=${counter_id}[3]    full_path=${full_path}[3]
    ${PM_counter_Sum_PRB_UL_MU_MIMO_4LAYER}    Sum the list value
    ...    counter_result=${PM_counter_PRB_UL_MU_MIMO_4LAYER}
    ${PM_counter_PRB_UL_MU_MIMO_2PAIR_UE}    Sum the list value
    ...    counter_result=${PM_counter_PRB_UL_MU_MIMO_2PAIR_UE}
    should be true    ${PM_counter_Sum_PRB_UL_MU_MIMO_4LAYER} == 0
    should be true    ${PM_counter_PRB_UL_MU_MIMO_2PAIR_UE} == 0

Check PM counter from webui
    [Arguments]    ${counter_id}    ${full_path}
    Selenium Login And Disable Screen Lock
    ${counter_value}     selenium_coam.get_bts_counters_info
    ...     counter_id=${counter_id}     full_path=${full_path}
    run keyword and ignore error    selenium_coam.refresh_page
    [Return]    ${counter_value}
    [Teardown]    Selenium Logout And Close Browser

Sum the list value
    [Arguments]    ${counter_result}
    ${length}    Get Length    ${counter_result}
    ${sum_result}    set variable    ${0}
    ${counter_result_value}    Get Dictionary Values    ${counter_result}
    log to console    ${counter_result_value}
    FOR  ${i}  IN RANGE   ${length}
        ${sum_result}    Evaluate    ${sum_result} + ${counter_result_value[${i}]}
    END
    [Return]      ${sum_result}

Check_Retx_Rat_Type_with_Init
    ${sfn}    set variable    ${0}
    ${slot}    set variable    ${0}
    ${hard_process_index}    set variable    ${0}
    ${rat0Bitmap_value}    set variable    ${0}
    ${specific_ttitrace_file}    Get_and_Unzip_Tti_Log
    ${sfn_info}    get_retx_sfn_info
    ...    csv_file=${specific_ttitrace_file}[0]
    ...    filter_name1=rat0Bitmap
    ...    filter_name2=txNumber
    ...    expect_name=sfn
    ${hard_process_info}    get_retx_hard_process_info
    ...    csv_file=${specific_ttitrace_file}[0]
    ...    filter_name1=rat0Bitmap
    ...    filter_name2=txNumber
    ...    expect_name=dlHarqProcessIndex
    ${hard_process_index}    get_retx_hard_process_index
    ...    csv_file=${specific_ttitrace_file}[0]
    ...    filter_name1=rat0Bitmap
    ...    filter_name2=txNumber
    ...    expect_name=dlHarqProcessIndex
    ${init_trans_sfn}    get_intial_Tx_info
    ...    csv_file=${specific_ttitrace_file}[0]
    ...    filter_name1=dlHarqProcessIndex
    ...    filter_name2=txNumber
    ...    filter_name3=rat0Bitmap
    ...    expect_name1=${hard_process_info}
    ...    expect_name2=${hard_process_index}
    ...    target_name3=sfn
    Should Be True    ${init_trans_sfn}
