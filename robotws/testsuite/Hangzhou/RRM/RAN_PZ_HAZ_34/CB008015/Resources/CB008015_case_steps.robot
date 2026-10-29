*** Settings ***
Documentation    Author:xiangyue.zhou@nokia-sbell.com

Resource    ./CB008015_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008360/Resources/aaslog_keywords.robot

*** Keywords ***
#---  TestCases KW  ---#
CB008015_A_03_Scell_selection_based_on_Scell_bandwidth_for_SA_call_Mixed_mode_of_F-F_and_F-T_CA
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${pcell_index}
    Log To Console    \n***Step1:Position A, Make L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               is_do_require_ue=${True}
    ...                               index_in_sorted_scell_weight_list=0
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=1500M
    ...                               target_DL_avg_percent=0.6
    ...                               target_UL_avg_percent=0.8
    ...                               is_do_scell_lock=${True}
    Log To Console    \n***Step2:Position A, Lock first TDD Scell And Make L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               index_in_sorted_scell_weight_list=1
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=800M
    ...                               target_DL_avg_percent=0.6
    ...                               target_UL_avg_percent=0.8
    ...                               is_do_scell_lock=${True}
    Log To Console    \n***Step3:Position A, Lock first and second TDD Scell And Make L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               index_in_sorted_scell_weight_list=2
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=600M
    ...                               target_DL_avg_percent=0.6
    ...                               target_UL_avg_percent=0.6
    ...                               is_do_scell_unlock=${True}
    ...                               is_do_PA_adjust_for_pcell=${True}
    ...                               pcell_position=B
    Log To Console    \n***Step4:Position B, Make L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               index_in_sorted_scell_weight_list=2
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=600M
    ...                               target_DL_avg_percent=0.5
    ...                               target_UL_avg_percent=0.5
    ...                               is_do_PA_adjust_for_pcell=${True}
    ...                               pcell_position=C
    Log To Console    \n***Step5:Position C, Make L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               check_scell_tput=${False}
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=300M
    ...                               target_DL_avg_percent=0.4
    ...                               target_UL_avg_percent=0.4


CB008015_A_08_Scell_selection_based_on_weighted_Scell_bandwidth_for_SA_call_mixed_Mode_of_F-F_and_F-T_CA
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${pcell_index}
    Modify weightForSCellSelection Value To Trigger New Weight Sorted    pcell_index=${pcell_index}
    Get All TDD-FDD Weighted Scell Bandwidth Value    pcell_index=${pcell_index}
    Log To Console    \n***Step1:Position A, Make L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               is_do_require_ue=${True}
    ...                               index_in_sorted_scell_weight_list=0
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=800M
    ...                               is_do_scell_lock=${True}
    Log To Console    \n***Step2:Position A, Lock first TDD Scell And Make L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               index_in_sorted_scell_weight_list=1
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=600M
    ...                               is_do_scell_lock=${True}
    Log To Console    \n***Step3:Position A, Lock first TDD and first FDD Scell And Make L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               index_in_sorted_scell_weight_list=2
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=500M
    ...                               is_do_scell_unlock=${True}
    ...                               is_do_PA_adjust_for_pcell=${True}
    ...                               pcell_position=B
    Log To Console    \n***Step4:Position B, Make L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               index_in_sorted_scell_weight_list=1
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=600M
    ...                               target_DL_avg_percent=0.8
    ...                               target_UL_avg_percent=0.8
    ...                               is_do_PA_adjust_for_pcell=${True}
    ...                               pcell_position=C
    Log To Console    \n***Step5:Position C, Make L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
#    ...                               is_CA_call=${False}
    ...                               check_scell_tput=${False}
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=300M
    ...                               target_DL_avg_percent=0.7
    ...                               target_UL_avg_percent=0.7

CB008015_A_12_SCell_selection_based_on_weighted_SCell_bandwidth_and_cell_load_for_SA_call_-_mixed_Mode_of_F-F_and_F-T_CA
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${pcell_index}
    Log To Console    \n***Step1:Position A, Make L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               is_do_require_ue=${True}
    ...                               index_in_sorted_scell_weight_list=0
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=800M
    ${scell_list}    Create List    2   3
    Modify maxNumOfSCellAlloc Value    cell_list=${scell_list}    value=0
    Sorted Weighted Scell Bandwidth Value After Cell Load Change    scell_list=${scell_list}
    Log To Console    \n***Step1:Position A, After set maxNumOfSCellAlloc 0 for scell-2/3,Make L3 call ***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               index_in_sorted_scell_weight_list=0
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=600M
    ...                               is_do_scell_lock=${True}
    Log To Console    \n***Step2:Position A, Lock first TDD Scell And Make L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               index_in_sorted_scell_weight_list=1
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=600M
    ...                               is_do_scell_unlock=${True}

CB008015_A_15_A1_measurement_of_PCell_based_SCell_change_for_SA_call_RSRP_for_mixed_mode_of_F_F_and_F_T_CA
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...                Check point: check scell change success
    [Arguments]    ${pcell_index}    ${ue_index}=${0}
    Log To Console    \n***Step1:Position A, Get Pcell RSRP，F+T***\n
    ${scell_index_list}     ${scell_technology}    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=2
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    ${attach_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${cpif_log_path}    Start UE Attach With Power UE    is_wireshark_log_capture=${True}
    ...                                                wireshark_log_prefix=ca_attach_${attach_timestamp}
    ...                                                4G_check=False
    ...                                                sleep_interval=30 sec
    ...                                                is_do_require_ue=${False}
    ...                                                interface=-i any -s 0 -p
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
#    Should Be Equal    ${pcell_index}    ${attach_info['attach_cell_index']}
    Log To Console    \n***Step2:Adjust PA to make UE in Position B, FDD 3CC L3 call ***\n
#    run keyword if    'SBTS22R3' in '${Active_SW_version}'    Adjust Attenuation To Trigger FDD 3CC    scell_index_list=${scell_index_list}
    ${pa_new_value}    Set Variable If    '${testline_name}'=='7_5_UTE5G402T307'    15    12
    Set PA Value For Pcell In Different Position    log_path=${cpif_log_path}
    ...                                             pcell_index=${pcell_index}
    ...                                             pcell_position=B
    ...                                             new_value=${pa_new_value}
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               index_in_sorted_scell_weight_list=2
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=1500M
    ...                               start_traffic_duration=1200
    ...                               target_DL_avg_percent=0.7
    ...                               target_UL_avg_percent=0.7
    ...                               min_DL_percent=0.5
    ...                               min_UL_percent=0.5
    ...                               is_need_stop_traffic=${False}
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
    Log To Console    \n***Step3:Adjust PA to move UE from B to A,check scell change, F+T L3 call***\n
    ${current_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Connect to Common Unit Master     alias=ASIK Master   gnb_index=0
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log    tcpdump_collector_name=cpif_adjust_PA_value_${current_timestamp}
    ...                                                                             asik_connection_alias=ASIK Master
    ...                                                                             gnb_index=0
    ...                                                                             du_index=0
    Set PA Value For Pcell In Different Position    log_path=${cpif_log_path}
    ...                                             pcell_index=${pcell_index}
    ...                                             pcell_position=A
    Sleep    20 sec
    ${cpif_adjust_PA}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...                                                          tcpdump_collector_name=cpif_adjust_PA_value_${current_timestamp}
    ...                            target_dir=${TS_CASE_LOG_PATH}    gnb_index=0    du_index=0
    Run Keyword And Continue On Failure    Check Scell Change Success    log_path=${cpif_adjust_PA}
    ${scell_index_list}    ${scell_technology}     Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=0
    ${check_pcell_tput_type}    ${check_ul_pcell_tput_type}    ${check_scell_tput_type}
    ...                    Generate All Cell Tput Type For Dss Env
    ...                    pcell_index=${pcell_index}
    ...                    scell_index_list=${scell_index_list}
    ...                    check_pcell_tput_type=peak
    ...                    check_ul_pcell_tput_type=peak
    ...                    check_scell_tput_type=peak
    Check Tput For CA Group         ue_type=${ue_type}
    ...                             duration=60
    ...                             addition_scell_index_list=${scell_index_list}
    ...                             target_DL_avg_percent=0.9
    ...                             target_UL_avg_percent=0.9
    ...                             min_DL_percent=0.8
    ...                             min_UL_percent=0.8
    ...                             check_pcell_tput_type=${check_pcell_tput_type}
    ...                             check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                             check_scell_tput_type=${check_scell_tput_type}
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}

CB008015_A_22_Online_modification_of_parameter_weightForSCellSelection
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${pcell_index}
    Log To Console    \n***Step1:Position A, Make L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               is_do_require_ue=${True}
    ...                               index_in_sorted_scell_weight_list=0
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=800M
    ...                               start_traffic_duration=1200
    ...                               is_need_stop_traffic=${False}
    Log To Console    \n***Step2:Start to online modify wegith value,check TP***\n
    Online Modification weightForSCellSelection value    scell_index=4    value=30
    ${scell_index_list}    ${scell_technology}    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=0
    Run Keyword And Continue On Failure    Check Tput For CA Group
    ...                                    duration=60
    ...                                    addition_scell_index_list=${scell_index_list}
    Run Keyword And Ignore Error    Stop Traffic With Power UE
    Get All TDD-FDD Weighted Scell Bandwidth Value    pcell_index=${pcell_index}
    Log To Console    \n***Step3:Position A with new sorted weight, Make L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               index_in_sorted_scell_weight_list=0
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=800M

CB008015_A_23_Online_modification_of_parameter_a1ThresholdSCellAddSsbRsrpTDD
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${pcell_index}    ${ue_index}=${0}
    Get a1ThresholdSCellAddSsbRsrp From SCF    pcell_index=${pcell_index}
    ${restore_a1ThresholdRsrpTDD_value}    Set Variable    ${a1ThresholdSCellAddSsbRsrpTDD}
    ${scell_index_list}     ${scell_technology}    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=2
    Log To Console    \n***Step1:Position A, Get Pcell RSRP***\n
    ${attach_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${cpif_log_path}    Start UE Attach With Power UE    is_wireshark_log_capture=${True}
    ...                                                wireshark_log_prefix=ca_attach_${attach_timestamp}
    ...                                                4G_check=False
    ...                                                sleep_interval=30 sec
#    Should Be Equal    ${pcell_index}    ${attach_info['attach_cell_index']}
    Log To Console    \n***Step2:Adjust PA to make UE in Position B, FDD 3CC L3 call***\n
#    run keyword if    'SBTS22R1' not in '${Active_SW_version}'    Adjust Attenuation To Trigger FDD 3CC    scell_index_list=${scell_index_list}
    Set PA Value For Pcell In Different Position    log_path=${cpif_log_path}
    ...                                             pcell_index=${pcell_index}
    ...                                             pcell_position=B
    Log To Console    \n***Step2:Position B, Make FDD 3CC L3 Call***\n
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               index_in_sorted_scell_weight_list=2
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=600M
    ...                               start_traffic_duration=1200
    ...                               target_DL_avg_percent=0.7
    ...                               target_UL_avg_percent=0.7
    ...                               min_DL_percent=0.5
    ...                               min_UL_percent=0.5
    ...                               is_need_stop_traffic=${False}
    Log To Console    \n***Step3:Start to online modify a1threshold value,check TP***\n
    Online Modification a1ThresholdSCellAddSsbRsrpTDD value    pcell_index=${pcell_index}    value=${rsrp_for_peak_tput}
    ...                                                        a1ThresholdSCellAddSsbRsrpFDD=${a1ThresholdSCellAddSsbRsrpFDD}
    Log To Console    \n***Step4:Start to adjust PA to new position,check no scell change, still FDD 3CC ***\n
    ${current_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start CP-IF Log Collection    tcpdump_collector_name=cpif_adjust_PA_value_${current_timestamp}
    ...                           options=-i any -s 0 -p
    Set PA Value For Pcell In Different Position    log_path=${cpif_log_path}
    ...                                             pcell_index=${pcell_index}
    ...                                             pcell_position=new_position
    ...                                             new_value=${restore_a1ThresholdRsrpTDD_value}
    Sleep    20 sec
    ${cpif_log_path}    Stop tcpdump log collection    tcpdump_collector_name=cpif_adjust_PA_value_${current_timestamp}
    ${scell_index_list}    ${scell_technology}    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=2
    Check Measurement Report Triggered But No RRC Reconfiguration Message    log_path=${cpif_log_path}
    ...                     scell_index_list=${scell_index_list}
    ${check_pcell_tput_type}    ${check_ul_pcell_tput_type}    ${check_scell_tput_type}
    ...                    Generate All Cell Tput Type For Dss Env
    ...                    pcell_index=${pcell_index}
    ...                    scell_index_list=${scell_index_list}
    ...                    check_pcell_tput_type=peak
    ...                    check_ul_pcell_tput_type=peak
    ...                    check_scell_tput_type=peak
    Check Tput For CA Group    ue_type=${ue_type}
    ...                        duration=60
    ...                        addition_scell_index_list=${scell_index_list}
    ...                        target_DL_avg_percent=0.7
    ...                        target_UL_avg_percent=0.7
    ...                        min_DL_percent=0.5
    ...                        min_UL_percent=0.5
    ...                        check_pcell_tput_type=${check_pcell_tput_type}
    ...                        check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                        check_scell_tput_type=${check_scell_tput_type}
    [Teardown]    Run Keyword And Continue On Failure     Online Modification a1ThresholdSCellAddSsbRsrpTDD value
    ...           pcell_index=${pcell_index}    value=${restore_a1ThresholdRsrpTDD_value}
    ...           a1ThresholdSCellAddSsbRsrpFDD=${a1ThresholdSCellAddSsbRsrpFDD}

CB008015_B_05_A1_measurement_of_PCell_based_SCell_change_from_FDD_to_TDD_of_T_F_CA
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                 this test case is used to perform scell change from FDD to TDD
    [Arguments]    ${pcell_index}    ${ue_index}=${0}
#    Modify weightForSCellSelection Value For T_T CA    pcell_index=${pcell_index}
    ${Frist_TDD_index_in_sorted_scell_weight_list}       ${Frist_FDD_index_in_sorted_scell_weight_list}
    ...    Get First TDD and FDD Index From Sorted Scell Weight List    pcell_index=${pcell_index}
    Log To Console    \n***Step1:Position A, Get Pcell RSRP***\n
    ${attach_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${cpif_log_path}    Start UE Attach With Power UE    is_wireshark_log_capture=${True}
    ...                                                wireshark_log_prefix=ca_attach_${attach_timestamp}
    ...                                                4G_check=False
    ...                                                sleep_interval=30 sec
    ...                                                interface=-i any -s 0 -p
#    Should Be Equal    ${pcell_index}    ${attach_info['attach_cell_index']}
    Log To Console    \n***Step2:Adjust PA to make UE in Position B, T+F L3 call ***\n
    ${testline_name} =    Get Variable Value    ${testline_name}
    ${force_set_pa_value}    Set Variable If    '${testline_name}'=='7_5_UTE5G402T307'    14    NULL
    Set PA Value For Pcell In Different Position    log_path=${cpif_log_path}
    ...                                             pcell_index=${pcell_index}
    ...                                             pcell_position=B
    ...                                             force_set_pa_value=${force_set_pa_value}
    Run Keyword If    '${stream}'=='SBTS00'    Adjust FDD Attenuation To avoid A2 PCELL switch in T_F CA
    ...    index_in_sorted_scell_weight_list=${Frist_FDD_index_in_sorted_scell_weight_list}
    ${check_pcell_tput_type_ul_layer1}    Get Pcell Tput Type For UL Layer1
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               index_in_sorted_scell_weight_list=${Frist_FDD_index_in_sorted_scell_weight_list}
    ...                               check_ul_pcell_tput_type=${check_pcell_tput_type_ul_layer1}
    ...                               ul_data_transfer=120M
    ...                               dl_data_transfer=2000M
    ...                               start_traffic_duration=1200
    ...                               target_DL_avg_percent=0.7
    ...                               target_UL_avg_percent=0.3
    ...                               min_DL_percent=0.6
    ...                               min_UL_percent=0.3
    ...                               is_need_stop_traffic=${False}
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
    Log To Console    \n***Step3:Adjust PA to move UE from B to A,check scell change from T+F to T+T***\n
    ${Frist_TDD_index_in_sorted_scell_weight_list}       ${Frist_FDD_index_in_sorted_scell_weight_list}
    ...    Get First TDD and FDD Index From Sorted Scell Weight List    pcell_index=${pcell_index}
    ${current_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start CP-IF Log Collection    tcpdump_collector_name=cpif_adjust_PA_value_${current_timestamp}
    ...                           options=-i any -s 0 -p
    Set PA Value For Pcell In Different Position    log_path=${cpif_log_path}
    ...                                             pcell_index=${pcell_index}
    ...                                             pcell_position=A
    Sleep    20 sec
    ${cpif_adjust_PA}    Stop tcpdump log collection    tcpdump_collector_name=cpif_adjust_PA_value_${current_timestamp}
    Run Keyword And Continue On Failure    Check Scell Change Success    log_path=${cpif_adjust_PA}
    ${scell_index_list}    ${scell_technology}     Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=${Frist_TDD_index_in_sorted_scell_weight_list}
    ${check_pcell_tput_type}    ${check_ul_pcell_tput_type}    ${check_scell_tput_type}
    ...                    Generate All Cell Tput Type For Dss Env
    ...                    pcell_index=${pcell_index}
    ...                    scell_index_list=${scell_index_list}
    ...                    check_pcell_tput_type=peak
    ...                    check_ul_pcell_tput_type=peak
    ...                    check_scell_tput_type=peak
    Check Tput For CA Group         ue_type=${ue_type}
    ...                             duration=60
    ...                             addition_scell_index_list=${scell_index_list}
    ...                             target_DL_avg_percent=0.9
    ...                             target_UL_avg_percent=0.9
    ...                             min_DL_percent=0.8
    ...                             min_UL_percent=0.4
    ...                             check_pcell_tput_type=${check_pcell_tput_type}
    ...                             check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                             check_scell_tput_type=${check_scell_tput_type}
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    [Teardown]    Run Keyword And Ignore Error    Stop Traffic With Power UE

CB008015_B_02_SCell_selection_based_on_weighted_SCell_bandwidth_for_SA_call_of_T_F_CA
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${pcell_index}
#    Modify weightForSCellSelection Value For T_T CA    pcell_index=${pcell_index}
    ${Frist_TDD_index_in_sorted_scell_weight_list}       ${Frist_FDD_index_in_sorted_scell_weight_list}
    ...    Get First TDD and FDD Index From Sorted Scell Weight List    pcell_index=${pcell_index}
    Log To Console    \n***Step1:Position A, Make T+T L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               is_do_require_ue=${True}
    ...                               index_in_sorted_scell_weight_list=${Frist_TDD_index_in_sorted_scell_weight_list}
    ...                               ul_data_transfer=120M
    ...                               dl_data_transfer=2000M
    ...                               target_DL_avg_percent=0.9
    ...                               target_UL_avg_percent=0.9
    ...                               min_DL_percent=0.5
    ...                               min_UL_percent=0.5
    ...                               is_do_scell_lock=${True}
    Log To Console    \n***Step2:Position A, Lock first TDD Scell And Make T+F L3 Call***\n
    ${check_pcell_tput_type_ul_layer1}    Get Pcell Tput Type For UL Layer1
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               check_ul_pcell_tput_type=${check_pcell_tput_type_ul_layer1}
    ...                               index_in_sorted_scell_weight_list=${Frist_FDD_index_in_sorted_scell_weight_list}
    ...                               ul_data_transfer=120M
    ...                               dl_data_transfer=1400M
    ...                               target_DL_avg_percent=0.9
    ...                               target_UL_avg_percent=0.9
    ...                               min_DL_percent=0.8
    ...                               min_UL_percent=0.8
    ...                               is_do_scell_unlock=${True}
    ...                               is_do_PA_adjust_for_pcell=${True}
    ...                               pcell_position=B
    ${testline_name} =    Get Variable Value    ${testline_name}
    ${force_set_pa_value}    Set Variable If    '${testline_name}'=='7_5_UTE5G402T072'    14    NULL
    Run Keyword If    '${testline_name}'=='7_5_UTE5G402T072'    Set PA Value For Pcell In Different Position    log_path=${cpif_log_path}
    ...                                             pcell_index=${pcell_index}
    ...                                             pcell_position=B
    ...                                             force_set_pa_value=${force_set_pa_value}
    Log To Console    \n***Step3:Position B, Make T+F L3 Call***\n
    Run Keyword If    '${stream}'=='SBTS00'    Adjust FDD Attenuation To avoid A2 PCELL switch in T_F CA
    ...    index_in_sorted_scell_weight_list=${Frist_FDD_index_in_sorted_scell_weight_list}
    ${check_pcell_tput_type_ul_layer1}    Get Pcell Tput Type For UL Layer1
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               check_ul_pcell_tput_type=${check_pcell_tput_type_ul_layer1}
    ...                               index_in_sorted_scell_weight_list=${Frist_FDD_index_in_sorted_scell_weight_list}
    ...                               ul_data_transfer=120M
    ...                               dl_data_transfer=1400M
    ...                               target_DL_avg_percent=0.7
    ...                               target_UL_avg_percent=0.5
    ...                               min_DL_percent=0.5
    ...                               min_UL_percent=0.4
    ...                               is_do_PA_adjust_for_pcell=${True}
    ...                               pcell_position=C
    Log To Console    \n***Step5:Position C, Make L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               check_pcell_tput_type=not_peak
    ...                               check_ul_pcell_tput_type=not_peak
    ...                               check_scell_tput=${False}
    ...                               ul_data_transfer=120M
    ...                               dl_data_transfer=1100M

CB008015_B_03_SCell_selection_based_on_weighted_SCell_bandwidth_and_cell_load_for_SA_call_of_T_F_CA
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${pcell_index}
#    Modify weightForSCellSelection Value For T_T CA    pcell_index=${pcell_index}
    ${Frist_TDD_index_in_sorted_scell_weight_list}       ${Frist_FDD_index_in_sorted_scell_weight_list}
    ...    Get First TDD and FDD Index From Sorted Scell Weight List    pcell_index=${pcell_index}
    ${high_load_scell_list}    ${scell_technology}    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=${Frist_FDD_index_in_sorted_scell_weight_list}
    Modify maxNumOfSCellAlloc Value    cell_list=${high_load_scell_list}    value=0
    set test variable    ${high_load_scell_list}
    Sorted Weighted Scell Bandwidth Value After Cell Load Change    scell_list=${high_load_scell_list}
    ${Frist_TDD_index_in_sorted_scell_weight_list}       ${Frist_FDD_index_in_sorted_scell_weight_list}
    ...    Get First TDD and FDD Index From Sorted Scell Weight List    pcell_index=${pcell_index}
    ...    is_need_to_get_weighted_scell_list=${False}
    Log To Console    \n***Step1:Position A, Make T+T L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               is_do_require_ue=${True}
    ...                               index_in_sorted_scell_weight_list=${Frist_TDD_index_in_sorted_scell_weight_list}
    ...                               ul_data_transfer=120M
    ...                               dl_data_transfer=2000M
    ...                               target_DL_avg_percent=0.9
    ...                               target_UL_avg_percent=0.9
    ...                               min_DL_percent=0.8
    ...                               min_UL_percent=0.8
    ...                               is_do_scell_lock=${True}
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
    Log To Console    \n***Step2:Position A, Lock first TDD Scell And Make T+F L3 Call***\n
    ${check_pcell_tput_type_ul_layer1}    Get Pcell Tput Type For UL Layer1
    ${force_set_pa_value}    Set Variable If    '${testline_name}'=='7_5_UTE5G402T307'    14    10
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               check_ul_pcell_tput_type=${check_pcell_tput_type_ul_layer1}
    ...                               index_in_sorted_scell_weight_list=${Frist_FDD_index_in_sorted_scell_weight_list}
    ...                               ul_data_transfer=120M
    ...                               dl_data_transfer=1400M
    ...                               is_do_scell_unlock=${True}
    ...                               target_DL_avg_percent=0.9
    ...                               target_UL_avg_percent=0.9
    ...                               min_DL_percent=0.8
    ...                               min_UL_percent=0.8
    ...                               is_do_PA_adjust_for_pcell=${True}
    ...                               pcell_position=B
    ...                               force_set_pa_value=${force_set_pa_value}
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
    Log To Console    \n***Step3:Position B, Make T+F L3 Call***\n
#    Run Keyword If    '${stream}'=='SBTS00'    Adjust FDD Attenuation To avoid A2 PCELL switch in T_F CA
#    ...    index_in_sorted_scell_weight_list=${Frist_FDD_index_in_sorted_scell_weight_list}
    ${force_set_pa_value_C}    Set Variable If    '${testline_name}'=='7_5_UTE5G402T307'    25    25
    ${check_pcell_tput_type_ul_layer1}    Get Pcell Tput Type For UL Layer1
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               check_ul_pcell_tput_type=${check_pcell_tput_type_ul_layer1}
    ...                               index_in_sorted_scell_weight_list=${Frist_FDD_index_in_sorted_scell_weight_list}
    ...                               ul_data_transfer=120M
    ...                               dl_data_transfer=1400M
    ...                               target_DL_avg_percent=0.7
    ...                               target_UL_avg_percent=0.5
    ...                               min_DL_percent=0.6
    ...                               min_UL_percent=0.4
    ...                               is_do_PA_adjust_for_pcell=${True}
    ...                               pcell_position=C
    ...                               force_set_pa_value=${force_set_pa_value_C}
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
    Log To Console    \n***Step5:Position C, Make Non-CA L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               check_pcell_tput_type=not_peak
    ...                               check_ul_pcell_tput_type=not_peak
    ...                               check_scell_tput=${False}
    ...                               ul_data_transfer=120M
    ...                               dl_data_transfer=1100M
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    [Teardown]    Modify maxNumOfSCellAlloc Value    cell_list=${high_load_scell_list}    value=250

CB008015_C_01_Mobility_based_on_rsrp_involving_two_TDD_cells_with_same_coverage_SA
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${pcell_index}    ${new_pcell_index}
    Log To Console    \n***Step1:Modify PA value for tdd cell-3,to make rsrp is lower than a1ThresholdPCellSwitchSsbRsrp***\n
    # for TL811, tdd scell3 rsrp is -62db with PA value=0
    ${ru_id}    Get RU ID from Cell id    cell_id=${new_pcell_index}
    ${low_rsrp_pa_for_tdd_scell}    Set Variable    13
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${low_rsrp_pa_for_tdd_scell}    RU_id=${ru_id}
    Log To Console    \nCheck TP before Pcell change,F+T***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               index_in_sorted_scell_weight_list=0
    ...                               is_do_require_ue=${True}
    ...                               ul_data_transfer=120M
    ...                               dl_data_transfer=1800M
    ...                               start_traffic_duration=1200
    ...                               target_DL_avg_percent=0.9
    ...                               target_UL_avg_percent=0.9
    ...                               min_DL_percent=0.5
    ...                               min_UL_percent=0.5
    ...                               is_need_stop_traffic=${False}
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
    ${scell_index_list}    ${scell_technology}   Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=0
    Log To Console    \n***Step2:Modify PA for tdd cell-3 to trigger pcell change***
    ${current_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
#    Run Keyword And Continue On Failure    Check MeasPCellSwitchSsbRsrp And MeasId During Attach     log_path=${cpif_log_path}
#    ...                                    cell_index=${new_pcell_index}
#    ...                                    pcell_change_method=A1
    @{expected_pcell_list}    create list    ${pcell_index}     ${new_pcell_index}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${expected_pcell_list}    timeout=${180}
    Connect to Common Unit Master     alias=ASIK Master   gnb_index=0
    Sleep    1min
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log    tcpdump_collector_name=cpif_pcell_change_${current_timestamp}
    ...                                                                             asik_connection_alias=ASIK Master
    ...                                                                             gnb_index=0
    ...                                                                             du_index=0
    ${pa_valuse_for_tdd}    Set Variable    0
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${pa_valuse_for_tdd}    RU_id=${ru_id}
    Sleep    20 sec
    ${cpif_log_path}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...                                                          tcpdump_collector_name=cpif_pcell_change_${current_timestamp}
    ...                            target_dir=${TS_CASE_LOG_PATH}    gnb_index=0    du_index=0
    Log To Console    \n***Step3:Check TP after Pcell change,T+T***\n
    Get All TDD-FDD Weighted Scell Bandwidth Value    pcell_index=${new_pcell_index}
    ${new_scell_list}    ${scell_technology}    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=0
    Run Keyword And Continue On Failure    Check New Added Scell Id After Pcell Change    log_path=${cpif_log_path}
    ...                                    new_scell_list=${new_scell_list}
    ${check_pcell_tput_type}    ${check_ul_pcell_tput_type}    ${check_scell_tput_type}
    ...                    Generate All Cell Tput Type For Dss Env
    ...                    pcell_index=${new_pcell_index}
    ...                    scell_index_list=${new_scell_list}
    ...                    check_pcell_tput_type=peak
    ...                    check_ul_pcell_tput_type=peak
    ...                    check_scell_tput_type=peak
    Check Tput For CA Group    ue_type=${ue_type}
    ...                        addition_scell_index_list=${new_scell_list}
    ...                        target_DL_avg_percent=0.9
    ...                        target_UL_avg_percent=0.9
    ...                        min_DL_percent=0.5
    ...                        min_UL_percent=0.5
    ...                        check_pcell_tput_type=${check_pcell_tput_type}
    ...                        check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                        check_scell_tput_type=${check_scell_tput_type}
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}

CB008015_C_03_Mobility_based_on_rsrp_involving_one_TDD_cell_SA
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${pcell_index}     ${new_pcell_index}
    Log To Console    \n***Step1:Modify weightForSCellSelection value for cell-2,Position A, Make L3 Call,T+F***\n
    ${new_weightForSCellSelection}    Set Variable    70
    Online Modification weightForSCellSelection value
    ...                             cell_index=${new_pcell_index}    value=${new_weightForSCellSelection}
    Get All TDD-FDD Weighted Scell Bandwidth Value    pcell_index=${pcell_index}
    ${check_pcell_tput_type_ul_layer1}    Get Pcell Tput Type For UL Layer1
    Log To Console    \nCheck TP before Pcell change,T+F***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               check_ul_pcell_tput_type=${check_pcell_tput_type_ul_layer1}
    ...                               index_in_sorted_scell_weight_list=0
    ...                               is_do_require_ue=${True}
    ...                               ul_data_transfer=60M
    ...                               dl_data_transfer=1400M
    ...                               start_traffic_duration=1200
    ...                               target_DL_avg_percent=0.9
    ...                               target_UL_avg_percent=0.9
    ...                               min_DL_percent=0.9
    ...                               min_UL_percent=0.9
    ...                               is_need_stop_traffic=${False}
    ${scell_index_list}    ${scell_technology}   Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=0
    Log To Console    \n***Step2:Modify PA value for tdd cell-3 to trigger pcell change,to make rsrp lower than a2ThresholdPCellSwitchSsbRsrp******
    ${current_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
#    Run Keyword And Continue On Failure    Check MeasPCellSwitchSsbRsrp And MeasId During Attach     log_path=${cpif_log_path}
#    ...                                    cell_index=${pcell_index}
#    ...                                    pcell_change_method=A2
    Start CP-IF Log Collection    tcpdump_collector_name=cpif_pcell_change_${current_timestamp}
    ...                           options=-i any -s 0 -p
    ${ru_id}    Get RU ID from Cell id    cell_id=${pcell_index}
    @{expected_pcell_list}    create list    ${pcell_index}     ${new_pcell_index}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${expected_pcell_list}    timeout=${180}
    ${low_rsrp_pa_for_tdd_scell}    Set Variable If    '${stream}'=='SBTS00'    38    20
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${low_rsrp_pa_for_tdd_scell}    RU_id=${ru_id}
    Sleep    20 sec
    ${cpif_log_path}    Run Keyword And Continue On Failure    Stop tcpdump log collection
    ...                                                 tcpdump_collector_name=cpif_pcell_change_${current_timestamp}
#    Run Keyword And Continue On Failure       Check MeasId And New Added Pcell Id    log_path=${cpif_log_path}
#    ...                                       scell_index_list=${scell_index_list}
    Log To Console    \n***Step3:Check TP after Pcell change,F+T***\n
    Get All TDD-FDD Weighted Scell Bandwidth Value    pcell_index=${new_pcell_index}
    ${new_scell_list}    ${scell_technology}    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=0
    Run Keyword And Continue On Failure    Check New Added Scell Id After Pcell Change    log_path=${cpif_log_path}
    ...                                    new_scell_list=${new_scell_list}
    ${check_pcell_tput_type}    ${check_ul_pcell_tput_type}    ${check_scell_tput_type}
    ...                    Generate All Cell Tput Type For Dss Env
    ...                    pcell_index=${new_pcell_index}
    ...                    scell_index_list=${new_scell_list}
    ...                    check_pcell_tput_type=peak
    ...                    check_ul_pcell_tput_type=peak
    ...                    check_scell_tput_type=peak
    Check Tput For CA Group    ue_type=${ue_type}
    ...                        duration=60
    ...                        addition_scell_index_list=${new_scell_list}
    ...                        target_DL_avg_percent=0.9
    ...                        target_UL_avg_percent=0.9
    ...                        min_DL_percent=0.8
    ...                        min_UL_percent=0.8
    ...                        check_pcell_tput_type=${check_pcell_tput_type}
    ...                        check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                        check_scell_tput_type=${check_scell_tput_type}
    [Teardown]    Run Keyword And Continue On Failure    Online Modification weightForSCellSelection value
    ...                               cell_index=${new_pcell_index}   value=10


CB008015_D_02_FDD_Cell_with_A1_based_scell_addition_lock_without_graceful_cell_shutdown_for_SA_call
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${pcell_index}
    Log To Console    \n***Step1:Position A, Make L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               is_do_require_ue=${True}
    ...                               index_in_sorted_scell_weight_list=0
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=800M
    ...                               start_traffic_duration=1200
    ...                               is_need_stop_traffic=${False}
    Log To Console    \n***Step2:start to online modify administrativeState of scell from Unlocked to Locked***
    ${current_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start CP-IF Log Collection    tcpdump_collector_name=cpif_online_lock_cell_${current_timestamp}
    ...                           options=-i any -s 0 -p
    Online Cell AdministrativeState Modification    cell_index=${scell_index_list[0]}
    Sleep    20 sec
    ${cpif_log_path}    Run Keyword And Ignore Error    Stop tcpdump log collection
    ...                                                 tcpdump_collector_name=cpif_online_lock_cell_${current_timestamp}
    Run Keyword And Continue On Failure        Check Tput For CA Group
    ...                                        duration=60
    ...                                        check_pcell_tput_type=no_data
    ...                                        check_scell_tput_type=no_data
    ...                                        addition_scell_index_list=${scell_index_list}
    Run Keyword And Continue On Failure    Check Bulk Release Procedure In CPIF    log_path=${cpif_log_path}
    Log To Console    \n***Step3:start to online modify administrativeState of scell from Locked to Unlocked ***
    Online Cell AdministrativeState Modification    cell_index=${scell_index_list[0]}    cell_administrativeState=Unlocked
    Wait Gnb Ready And Cell On Air    timeout=5min
    Run Keyword And Ignore Error    Stop Traffic With Power UE    is_detach=${True}
    Sleep    10 sec
    Log To Console    \n***Step4:Make L3 Call Again After Cell Unlocked***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               is_do_require_ue=${True}
    ...                               index_in_sorted_scell_weight_list=2
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=800M
    ...                               start_traffic_duration=600

CB008015_D_06_FDD_Cell_lock_with_graceful_cell_shutdown_for_SA_call_with_A1_based_scell_addition_and_cell_center_Ues
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${pcell_index}
    Log To Console    \n***Step1:PositionA Start to online modify wegith value to make T+F cell2 to be selected as scell,check TP***\n
    ${old_weightForSCellSelection}    Set Variable    10
    ${new_weightForSCellSelection}    set variable if     '${stream}'=='SBTS00'    50    30
    Online Modification weightForSCellSelection value    cell_index=2    value=${new_weightForSCellSelection}
    ${Frist_TDD_index_in_sorted_scell_weight_list}       ${Frist_FDD_index_in_sorted_scell_weight_list}
    ...    Get First TDD and FDD Index From Sorted Scell Weight List    pcell_index=${pcell_index}
    ${scell_index_list}     ${scell_technology}    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list= ${Frist_FDD_index_in_sorted_scell_weight_list}
    ${check_pcell_tput_type_ul_layer1}    Get Pcell Tput Type For UL Layer1
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               check_ul_pcell_tput_type=${check_pcell_tput_type_ul_layer1}
    ...                               index_in_sorted_scell_weight_list=${Frist_FDD_index_in_sorted_scell_weight_list}
    ...                               is_do_require_ue=${True}
    ...                               ul_data_transfer=60M
    ...                               dl_data_transfer=1500M
    ...                               start_traffic_duration=1200
    ...                               target_DL_avg_percent=0.9
    ...                               target_UL_avg_percent=0.9
    ...                               min_DL_percent=0.8
    ...                               min_UL_percent=0.8
    ...                               is_need_stop_traffic=${False}
    Log To Console    \n***Step2:PositionA start to online modify administrativeState of scell from Unlocked to Shutdown***
    ${current_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${scell_index_list}     ${scell_technology}    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=0
    Log To Console    \n***Step3:start to online modify administrativeState of scell to Shutdown  ***
    Start CP-IF Log Collection    tcpdump_collector_name=cpif_online_shutdown_cell_${current_timestamp}    options=-i any sctp -s 0 -p
    Online Cell AdministrativeState Modification    cell_index=${scell_index_list[0]}    cell_administrativeState=Shutting Down
#    Sleep    70 sec
    Wait Until Keyword Succeeds   3 min    20 sec    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds   5 min  5 sec   Cell Should Be Locked    cell_idx=${scell_index_list[0]}
    ...                                                                   cell_group_idx=${scell_index_list[0]}
    ...                                                                   timeout=10
    ...                                                                   connection=GNB_OAM
    ${cpif_log_path}    Run Keyword And Continue On Failure    Stop tcpdump log collection
    ...                                                 tcpdump_collector_name=cpif_online_shutdown_cell_${current_timestamp}
    Run Keyword And Ignore Error    Stop Traffic With Power UE    is_detach=${True}
    Run Keyword And Continue On Failure    Check Bulk Release Procedure In CPIF    log_path=${cpif_log_path}
    Log To Console    \n***Step4:start to online modify administrativeState of scell from Shutdown to Unlocked ***
    Online Cell AdministrativeState Modification    cell_index=${scell_index_list[0]}    cell_administrativeState=Unlocked
    Wait Gnb Ready And Cell On Air    timeout=5min
    Sleep    30 sec
    Log To Console    \n***Step5:Position A Make T+F L3 Call Again After Cell Unlocked***\n
    ${check_pcell_tput_type_ul_layer1}    Get Pcell Tput Type For UL Layer1
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               check_ul_pcell_tput_type=${check_pcell_tput_type_ul_layer1}
    ...                               index_in_sorted_scell_weight_list=${Frist_FDD_index_in_sorted_scell_weight_list}
    ...                               ul_data_transfer=60M
    ...                               dl_data_transfer=1500M
    ...                               start_traffic_duration=600
    ...                               target_DL_avg_percent=0.9
    ...                               target_UL_avg_percent=0.8
    ...                               min_DL_percent=0.8
    ...                               min_UL_percent=0.7
    ...                               is_need_stop_traffic=${False}
    [Teardown]    Run Keyword And Continue On Failure    Run Keywords
    ...            Online Modification weightForSCellSelection value
    ...                               cell_index=2    value=${old_weightForSCellSelection}    AND
    ...           Perfrom Scell Unlock


CB008015_D_07_FDD_Cell_lock_with_graceful_cell_shutdown_for_SA_call_when_locked_cell_with_A1_based_scell_addition_and_cell_edge_Ues
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${pcell_index}    ${ue_index}=${0}
    ${scell_index_list}     ${scell_technology}    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=2
    Log To Console    \n***Step1:Position A, Get Pcell RSRP***\n
    ${attach_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${cpif_log_path}    Start UE Attach With Power UE    is_wireshark_log_capture=${True}
    ...                                                wireshark_log_prefix=ca_attach_${attach_timestamp}
    ...                                                4G_check=False
    ...                                                sleep_interval=30 sec
#    should be equal as integers    ${pcell_index}    ${attach_info['attach_cell_index']}
    Log To Console    \n***Step2:Adjust PA to make UE in Position B, Make FDD 3CC***\n
#    run keyword if    'SBTS22R1' not in '${Active_SW_version}'    Adjust Attenuation To Trigger FDD 3CC    scell_index_list=${scell_index_list}
    Set PA Value For Pcell In Different Position    log_path=${cpif_log_path}
    ...                                             pcell_index=${pcell_index}
    ...                                             pcell_position=B
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               index_in_sorted_scell_weight_list=2
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=600M
    ...                               start_traffic_duration=1200
    ...                               target_DL_avg_percent=0.7
    ...                               target_UL_avg_percent=0.7
    ...                               min_DL_percent=0.5
    ...                               min_UL_percent=0.5
    ...                               is_need_stop_traffic=${False}
    Log To Console    \n***Step3:start to online modify administrativeState of scell from Unlocked to Shutdown***
    ${current_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${scell_index_list}     ${scell_technology}    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=2
    ${PA0_value}    Set Variable If    '${stream}'=='SBTS00'    10    50
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA0_value}   RU_id=${scell_index_list[0]}
    Sleep  2sec
    Start CP-IF Log Collection    tcpdump_collector_name=cpif_online_shutdown_cell_${current_timestamp}    options=-i any sctp -s 0 -p
    Cell AdministrativeState Modification via rest api    cell_index=${scell_index_list[0]}    cell_administrativeState=Shutting Down
#    Sleep    100 sec
    Wait Until Keyword Succeeds   3 min    20 sec    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds   5 min  5 sec   Cell Should Be Locked    cell_idx=${scell_index_list[0]}
    ...                                                                   cell_group_idx=${scell_index_list[0]}
    ...                                                                   timeout=10
    ...                                                                   connection=GNB_OAM
    ${cpif_log_path}    Run Keyword And Continue On Failure    Stop tcpdump log collection
    ...                                                 tcpdump_collector_name=cpif_online_shutdown_cell_${current_timestamp}
    ${scell_need_to_check}    Create List    ${scell_index_list[1]}
    ${check_pcell_tput_type}     ${check_ul_pcell_tput_type}    ${check_scell_tput_type}
    ...                    Generate All Cell Tput Type For Dss Env
    ...                    pcell_index=${pcell_index}
    ...                    scell_index_list=${scell_need_to_check}
    ...                    check_pcell_tput_type=peak
    ...                    check_ul_pcell_tput_type=peak
    ...                    check_scell_tput_type=peak
    Run Keyword And Continue On Failure        Check Tput For CA Group
    ...                                        ue_type=${ue_type}
    ...                                        duration=60
    ...                                        addition_scell_index_list=${scell_need_to_check}
    ...                                        target_DL_avg_percent=0.7
    ...                                        target_UL_avg_percent=0.7
    ...                                        min_DL_percent=0.5
    ...                                        min_UL_percent=0.5
    ...                                        check_pcell_tput_type=${check_pcell_tput_type}
    ...                                        check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                                        check_scell_tput_type=${check_scell_tput_type}
    Run Keyword And Ignore Error    Stop Traffic With Power UE    is_detach=${True}
    Run Keyword And Continue On Failure    Check Scell Release Success In CPIF Log  log_path=${cpif_log_path}
    ...                                    sCellIndex_in_cpif=${sCellIndex_in_cpif[0]}
    Log To Console    \n***Step4:start to online modify administrativeState of scell from Shutdown to Unlocked ***
    Run Keyword If    '${stream}'!='SBTS00'
    ...                gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=0   RU_id=${scell_index_list[0]}
    Sleep  2sec
    Cell AdministrativeState Modification via rest api    cell_index=${scell_index_list[0]}    cell_administrativeState=Unlocked
    Wait Gnb Ready And Cell On Air    timeout=5min
    Sleep    120 sec
    Log To Console    \n***Step5:Make FDD 3CC L3 Call Again After Cell Unlocked***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               index_in_sorted_scell_weight_list=2
    ...                               ul_data_transfer=50M
    ...                               dl_data_transfer=600M
    ...                               target_DL_avg_percent=0.7
    ...                               target_UL_avg_percent=0.7
    ...                               min_DL_percent=0.5
    ...                               min_UL_percent=0.5
    [Teardown]    Run Keyword And Ignore Error    Perfrom Scell Unlock

CB008015_D_08_FDD_Cell_lock_with_graceful_cell_shutdown_and_unlock_for_SA_call
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${pcell_index}
    Log To Console    \n***Step1:Position A, Make T+T L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               index_in_sorted_scell_weight_list=0
    ...                               ul_data_transfer=80M
    ...                               dl_data_transfer=1800M
    Log To Console    \n***Step2:start to online modify administrativeState of scell from Unlocked to Shutdown***
    ${current_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${scell_index_list}    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=0
    Start CP-IF Log Collection    tcpdump_collector_name=cpif_online_shutdown_cell_${current_timestamp}
    ...                           options=-i any -s 0 -p
    Online Cell AdministrativeState Modification    cell_index=${scell_index_list[0]}    cell_administrativeState=Shutting Down
    Sleep    70 sec
    ${cpif_log_path}    Run Keyword And Ignore Error    Stop tcpdump log collection
    ...                                                 tcpdump_collector_name=cpif_online_shutdown_cell_${current_timestamp}
    Run Keyword And Continue On Failure        Check Tput For CA Group
    ...                                        duration=60
    ...                                        check_pcell_tput_type=no_data
    ...                                        check_scell_tput_type=no_data
    ...                                        addition_scell_index_list=${scell_index_list}
    Run Keyword And Continue On Failure    Check Bulk Release Procedure In CPIF    log_path=${cpif_log_path}
    Log To Console    \n***Step3:start to online modify administrativeState of scell from Shutdown to Unlocked ***
    Online Cell AdministrativeState Modification    cell_index=${scell_index_list[0]}    cell_administrativeState=Unlocked
    Wait Gnb Ready And Cell On Air    timeout=5min
    Run Keyword And Ignore Error    Stop Traffic With Power UE    is_detach=${True}
    Sleep    10 sec
    Log To Console    \n***Step4:Make L3 Call Again After Cell Unlocked***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               index_in_sorted_scell_weight_list=0
    ...                               ul_data_transfer=80M
    ...                               dl_data_transfer=1800M

CB008015_D_10_reset_ABIL_and_ABIO_for_mixed_mode_CA_configuration_for_SA_call
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${pcell_index}
    Log To Console    \n***Step1:Position A, Make F+T L3 Call***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               index_in_sorted_scell_weight_list=0
    ...                               ul_data_transfer=80M
    ...                               dl_data_transfer=1500M
    Log To Console    \n***Step2: Reset ABIL via webui***
    ${current_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${scell_index_list}    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=0
    Start CP-IF Log Collection    tcpdump_collector_name=cpif_restart_abil_${current_timestamp}
    ...                           options=-i any -s 0 -p
    Perform BBMOD reset via webui    abil_index=1
    Sleep    20 sec
    ${cpif_log_path}    Run Keyword And Ignore Error    Stop tcpdump log collection    tcpdump_collector_name=cpif_restart_abil_${current_timestamp}
    Run Keyword And Continue On Failure        Check Tput For CA Group
    ...                                        duration=60
    ...                                        check_pcell_tput_type=no_data
    ...                                        check_scell_tput_type=no_data
    ...                                        addition_scell_index_list=${scell_index_list}
    Run Keyword And Continue On Failure    Check Bulk Release Procedure In CPIF    log_path=${cpif_log_path}
    COAM Wait For Gnb Ready And Cell Setup    timeout=15 min
    Log To Console    \n***Step1:Position A, Make F+T L3 Call Again***\n
    CB008015_A_Common_Test_Steps      pcell_index=${pcell_index}
    ...                               index_in_sorted_scell_weight_list=0
    ...                               ul_data_transfer=80M
    ...                               dl_data_transfer=1500M

