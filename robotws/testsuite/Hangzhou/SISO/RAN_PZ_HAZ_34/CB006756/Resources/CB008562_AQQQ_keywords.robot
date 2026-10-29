*** Settings ***
Documentation    This is for CB008562 keywords
...              Author: Gao melinda
...              Contact: melinda.gao@nokia-sbell.com
...              squad: 5G_PZ_HZ_8_SG


Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006502_CB007833/Resources/CB006502_Keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot
Library    taf.ul.oam.selenium_coam    WITH NAME    selenium_coam
Library    taf.selenium.sbts    WITH NAME    selenium_sbts
Library    ../TestData/variables_AQQQ_8562.py
Library    DateTime
Library    taf.transport.ssh    WITH NAME    csn
Variables    ../TestData/variables_AQQQ_8562.py

*** Variables ***
${cell_id1}    ${1}
*** Keywords ***

General_SiSo_Auto_Antenna_Online_Monitoring_using_WebEM_with_call_AQQQ
    ${CSV_path}    set variable    /home/ute/MonitoringFile
    create directory    ${CSV_path}
    Run Keyword And Ignore Error    detach UE
    Selenium Login And Disable Screen Lock    download_dir=${CSV_path}
    selenium_sbts.select_antenna_lines_for_monitoring
    selenium_sbts.start_antenna_line_monitoring
    ${monitor_start_time}    DateTime.Get Current Date    result_format=timestamp
#    Start Btslog With Path Check
    ${UEs_attach_time}    ${UEs_detach_time}    Module_UE_spark_call    ue_index_list=${ue_list}    tput_expect=${peak_info}
    ...    duration=20    duration_call=60    target_avg_percent=${0.5}     min_percent=${0.5}
    ${UE_attach_time_list}    Get Dictionary Values    ${UEs_attach_time}
    ${UE0_attach_time}    Get From List    ${UE_attach_time_list}    0
    ${UE1_attach_time}    Get From List    ${UE_attach_time_list}    1
    ${UE_detach_time_list}    Get Dictionary Values    ${UEs_detach_time}
    ${UE0_detach_time}    Get From List    ${UE_detach_time_list}    0
    ${UE1_detach_time}    Get From List    ${UE_detach_time_list}    1
    selenium_sbts.stop_antenna_line_monitoring
    ${CSV_path_file}     selenium_sbts.export_monitored_value_to_csv
    ${UE_0_elapsed_call_time}    DateTime.Subtract Date From Date    ${UE0_detach_time}    ${UE0_attach_time}
    ${UE_1_elapsed_call_time}    DateTime.Subtract Date From Date    ${UE1_detach_time}    ${UE1_attach_time}
    log    ${UE_0_elapsed_call_time}
    log    ${UE_1_elapsed_call_time}
    ${UEs_elapsed_call_time}    evaluate    ${UE_0_elapsed_call_time}+${UE_1_elapsed_call_time}
    log    ${UEs_elapsed_call_time}
    ${call_times}    Evaluate    ${UEs_elapsed_call_time}/10+1
    ${call_times_integer}    get_integer    number=${call_times}
    ${RSSI_value}    ${RSSI_value_dict}    ${ETP_value}    ${ETP_value_dict}    ${lenth_RSSI_value}    ${lenth_char_RSSI}
    ...    ${lenth_integer_RSSI}    ${integer_RSSI}    ${character_RSSI}    get_AQQQ_CSV_content    file=${CSV_path_file}
    log to console    check RSSI's value...
    log    ${RSSI_value_dict}
    should be true    ${lenth_integer_RSSI}>=${0}
    should be true    ${call_times_integer}>=${lenth_integer_RSSI}
    ${judge_call_value}    judge value    list=${integer_RSSI}
    should be equal    ${judge_call_value}    True
    log to console    check ETP's value...
    log    ${ETP_value_dict}
    ${judge_result}    judge_value    list=${ETP_value}
    should be equal    ${judge_result}    True
    [Teardown]    Selenium Logout And Close Browser

Module_UE_spark_call
    [Arguments]    ${ue_index_list}    ${tput_expect}    ${ue_type}=huawei_sigspark    ${duration}=300    ${protocol}=udp
    ...    ${attach_mode}=5G_NSA    ${gnb_index}=${0}    ${du_index}=0    ${iperf_type}=via_command
    ...    ${target_avg_percent}=0.4    ${min_percent}=0.4    ${duration_call}=300
    ${ue_cell_mapping}    create dictionary
    ${ue_tput_mapping}    create dictionary
    ${UEs_attach_time}    Create Dictionary
    ${UEs_detach_time}    Create Dictionary
    FOR    ${ue_index}    IN    @{ue_index_list}
        log to console    \n***Prepare for UE_${ue_index}***
        Wait Until Keyword Succeeds    5min    30s    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
        Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
        Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
        Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt
        log to console    \n***Attach for UE_${ue_index}***
        ${UE_attach}    set variable    UE_${ue_index}_attach_time
        ${UE_attach_time}    DateTime.Get Current Date    result_format=timestamp
        power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=${attach_mode}
        set to dictionary    ${UEs_attach_time}    ${UE_attach}    ${UE_attach_time}
#        Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
#        Connect to Common Unit Master
#        ${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=/tmp/5Grach.txt
#        ...    alias=ASIK Master
#        csn.Disconnect  connection=ASIK Master
#        log to console    UE_${ue_index} attached to cell ${cell_id}
#        set to dictionary    ${ue_cell_mapping}    ${ue_index}    ${cell_id}
#        ${ue_mode}    Replace String    ${attach_mode}    5G_    ${EMPTY}
#        log to console    \n***Start traffic for UE_${ue_index}***
##        ${duration_call}    Evaluate    ${duration}+${600}
#        ${dl_tp}    set variable    ${tput_expect['${cell_id}']['dl_tp']}
#        ${ul_tp}    set variable    ${tput_expect['${cell_id}']['ul_tp']}
#        power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=${dl_tp}/sec
#        ...    duration=${duration_call}    protocol=${protocol}    ue_mode=${ue_mode}
#        power_ue.Start traffic    ue_type=Samsung    ue_index=${ue_index}    direction=ul    throughput=${ul_tp}
#        ...    duration=${duration_call}    protocol=${protocol}    iperf_type=${iperf_type}
    END
#    log to console    \n***Start Collect Throughput for UE***
#    ${tput_log}    power_ue.Collect Tput    ue_type=Samsung    duration=${duration}
#    FOR    ${ue_index}    IN    @{ue_index_list}
#        ${cell_id}     Get From Dictionary    ${ue_cell_mapping}     ${ue_index}
#        ${dl_exp}    set variable    ${tput_expect['${cell_id}']['dl_exp']}
#        ${ul_exp}    set variable    ${tput_expect['${cell_id}']['ul_exp']}
#        ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
#        ${cell_id}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
#        ${cell_id}    Create List    ${cell_id}
#        log to console    \n***Check tput for UE_${ue_index}***
#        power_ue.Check Bi Tput    ue_type=huawei    log=${tput_log}    cells=${cell_id}    ultarget_throughput=${ul_exp}
#        ...    dltarget_throughput=${dl_exp}   target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
#    END
    FOR    ${ue_index}    IN    @{ue_index_list}
        log to console    \n***Stop traffic and Detach for UE_${ue_index}***
#        run keyword and ignore error  power_ue.Stop traffic   ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
#        run keyword and ignore error  power_ue.Stop traffic   ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
        ${UE_detach}    set variable    UE_${ue_index}_detach_time
        run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_type}    ue_index=${ue_index}
        ${UE_detach_time}    DateTime.Get Current Date    result_format=timestamp
        set to dictionary    ${UEs_detach_time}    ${UE_detach}    ${UE_detach_time}
    END
    [Return]    ${UEs_attach_time}    ${UEs_detach_time}

detach UE
    [Arguments]    ${ue_type}=huawei_sigspark    ${ue_index_list}=${ue_list}
    FOR    ${ue_index}    IN    @{ue_index_list}
        log to console    \n***Prepare for UE_${ue_index}***
        Wait Until Keyword Succeeds    5min    30s    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
        log to console    \n***Detach for UE_${ue_index}***
        run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_type}    ue_index=${ue_index}
    END
