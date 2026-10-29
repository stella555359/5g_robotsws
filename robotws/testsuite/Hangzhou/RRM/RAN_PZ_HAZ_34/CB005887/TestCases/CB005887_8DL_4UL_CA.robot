# *** Settings ***
# Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB005887/Resources/CB005887_Variables.robot
# Resource    ../Resources/CB005887_keywords.robot
# 
# 
# 
# Documentation
# ...   author: Zhang Ningning
# ...   contact: ningning.zhang@nokia-sbell.com
# ...   squad group: SG_04
# ...   Feature CB002033 in 22R2 program, RU type:AEWD
# 
# Force Tags      5G_RRM
# 
# Suite Setup     Suite preparation for 5887
# 
# Suite Teardown  Run Keyword And Ignore Error      Suite env recovery
# 
# 
# 
# 
# *** Test Cases ***
# 
# [1]CB005887_A_4016_GNB-8CCDL_4CCUL_maxScell7DL3UL_PM_Counter_M55118C02005_M55118C03005
#     [Tags]    CRT_TRUNK    CIT_22R2    CDRT_22R2    CRT_22R4
#     [Documentation]    author: fang ludan
#     [Setup]    run keywords   Common case setup   is_pdl_checking_needed=${True}     AND
#     ...        Make SgNBAddition on specific cell      gnb_ps_cell_index=${1}    alias=enblte       AND
#     ...        run keyword and ignore error    Start X2 log capture from eNB    interface=br1 sctp
# 
#     ${attach_counter_list_2005_3005}   create list     M55118C02005   M55118C03005
#     ${attach_counter_list_4005_5005}   create list     M55118C04005   M55118C05005
#     #prepare for counter log
#     Connect to Capacity Unit Master
#     Wait for next PM counter file is generated    reporting_interval=5
#     &{case_start_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
# 
#     #attach and bip log capture
#     Connect to gnb coam via ssl
#     ${list_log_path_local}    l3call.Retry Commercial Ue Attach If Failed  retry_time=${1}  ue_type=${ue_type}
#     ...     prepare_ue_needed=${False}  4G_check=${True}
# 
#     #counter log capture
#     log to console    Collect pm files
#     Connect to Capacity Unit Master
#     &{case_stop_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
#     sleep    ${case_stop_time_info['wait_time']} min
#     @{remote_file_path}    Wait until PM counter file is genereated    timeout=2min
#     ...    log_generate_timestamp=${case_start_time_info['log_generator_timestamp']}
# 
#     #prepare for counter log
#     &{case_start_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
# 
#     #check counter_2005_3005
#     @{local_counter_file_path_2005_3005}    counter.download_pm_counter_files_to_test_pc    remote_file_path=${remote_file_path}
#     ...    local_file_folder=${TS_CASE_LOG_PATH}
#     FOR   ${pm_file_2005_3005}    IN    @{local_counter_file_path_2005_3005}
#         ${status}    run keyword and return status   check counter 2005  attach_counter_list=${attach_counter_list_2005_3005}
#         ...    local_counter_file_path=${pm_file_2005_3005}
#         Exit For Loop if    ${status}==True
#     END
#     Should be true   ${status}==True
# 
#     #check counter_4005_5005
#     Connect to Capacity Unit Master
#     &{case_stop_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
#     sleep    ${case_stop_time_info['wait_time']} min
#     @{remote_file_path}    Wait until PM counter file is genereated    timeout=2min
#     ...    log_generate_timestamp=${case_start_time_info['log_generator_timestamp']}
#     @{local_counter_file_path_4005_5005}   counter.download_pm_counter_files_to_test_pc    remote_file_path=${remote_file_path}
#     ...    local_file_folder=${TS_CASE_LOG_PATH}
#     FOR   ${pm_file_4005_5005}    IN    @{local_counter_file_path_4005_5005}
#         ${status}    run keyword and return status   check counter 4005   attach_counter_list=${attach_counter_list_4005_5005}
#         ...    local_counter_file_path=${pm_file_4005_5005}
#         Exit For Loop if    ${status}==True
#     END
#     Should be true   ${status}==True
#     [Teardown]   run Keyword and ignore Error    common case teardown with recovery gnbindex
# 
# [1]CB005887_A_4006_GNB-8CCDL_4CCUL_maxScell7DL3UL_scell_deletion_addition
#     [Tags]    CRT_TRUNK    CIT_22R2    CDRT_22R2    CRT_22R4
#     [Documentation]    author: Zhang Ningning
#     [Setup]    run keywords   Common case setup   is_pdl_checking_needed=${False}  AND
#     ...    run keyword and ignore error    Start X2 log capture from eNB    interface=br1 sctp
#     ${cell_info_8}    Get Cell Parameters    cell_id=8
#     ${cell_info_7}    Get Cell Parameters    cell_id=7
#     Remove Cell From Configuration    cell_id=8    cell_group_id=0
#     Remove Cell From Configuration    cell_id=7    cell_group_id=0
#     Wait Until Keyword Succeeds    2 min    5 sec    Cell number should be as expected    expect_cell_number=${6}
#     Wait Until Keyword Succeeds    2 min    5 sec    Verify all cells should be onair
# #    Connect to gnb coam via ssl
#     &{NR_CELL_ID_MAPPING}    get_relation_mapping_between_cell_index_and_other_ids
#     Set test variable    ${NR_CELL_ID_MAPPING}
#     Call case with QCOM UE and record throughput info for many cells many times with protocal
#     ...    repeat_times=${REPEAT_TIME}
#     ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}
#     gnbcombinedcell.Add New Cell Based On Existing Cell To Configuration    cell_parameters=${cell_info_7}
#     ...    cell_id_to_copy_from=${6}    nrcell_include_subobject=${True}    activate_plan_despite_errors=${True}
#     gnbcombinedcell.Add New Cell Based On Existing Cell To Configuration    cell_parameters=${cell_info_8}
#     ...    cell_id_to_copy_from=${6}    nrcell_include_subobject=${True}    activate_plan_despite_errors=${True}
#     Wait Until Keyword Succeeds    2 min    5 sec    Cell number should be as expected    expect_cell_number=${8}
#     Wait Until Keyword Succeeds    2 min    5 sec    Verify all cells should be onair
# #    Connect to gnb coam via ssl
#     &{NR_CELL_ID_MAPPING}    get_relation_mapping_between_cell_index_and_other_ids
#     Set test variable    ${NR_CELL_ID_MAPPING}
#     Call case with QCOM UE and record throughput info for many cells many times with protocal
#     ...    repeat_times=${REPEAT_TIME}
#     ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}
#     [Teardown]   run Keyword and ignore Error    common case teardown with recovery gnbindex
# 
# 
# [1]CB005887_A_4007_GNB-8CCDL_4CCUL_maxScell7DL3UL_UL_tcp_load_contiguous_with_Round-robin
#     [Tags]    CRT_TRUNK    CIT_22R2    CDRT_22R2    CRT_22R4
#     [Documentation]    author: fang ludan
#     [Setup]    run keywords   Common case setup   is_pdl_checking_needed=${False}  AND
#     ...    run keyword and ignore error    Start X2 log capture from eNB    interface=br1 sctp
#     &{NR_CELL_ID_MAPPING}    get_relation_mapping_between_cell_index_and_other_ids
#     Set test variable    ${NR_CELL_ID_MAPPING}
#     ${TC_GNB_PS_CELL_INDEX_LIST}    create list    1
#     Set test variable   ${GNB_PS_CELL_INDEX_LIST}   ${TC_GNB_PS_CELL_INDEX_LIST}
#     Call case with QCOM UE and record throughput info for many cells many times with protocal
#     ...    dl_exp_tput=${DL_EXPECT}
#     ...    ul_exp_tput=${UL_EXPECT_PEAK}
#     ...    repeat_times=${REPEAT_TIME}
#     ...    data_transfer_direction=ul
#     ...    protocal=tcp
#     Stop data transfer and detach UE
#     [Teardown]   Run Keyword And Ignore Error    common case teardown with recovery gnbindex
# 
# [1]CB005887_A_4009_GNB-8CCDL_4CCUL_maxScell7DL3UL_set_maxNumScellsUL_2_with_maxNumScellsDl_7
#     [Tags]    CRT_TRUNK    CIT_22R2    CDRT_22R2    CRT_22R4
#     [Documentation]    author:Zhang Ningning
#     [Setup]    run keywords   Common case setup   is_pdl_checking_needed=${False}  AND
#     ...    run keyword and ignore error    Start X2 log capture from eNB   interface=br1 sctp
#     Set maxNumScellsUl to 2    modify_set_maxNumScellsUl_2=${modify_set_maxNumScellsUl_2}
#     &{NR_CELL_ID_MAPPING}    get_relation_mapping_between_cell_index_and_other_ids
#     Set test variable    ${NR_CELL_ID_MAPPING}
#     Check Log for UL 3CC configuration
#     Call case with QCOM UE and record throughput info for many cells many times with protocal
#     ...    repeat_times=${REPEAT_TIME}
#     ...    ul_exp_tput=${UL_EXPECT_3CC}    dl_exp_tput=${DL_EXPECT}
#     [Teardown]   Run Keyword And Ignore Error   common case teardown with recovery ul3cc
# 
# [1]CB005887_A_2002_GNB-8CCDL_4CCUL_maxScell7DL3UL_PDL_Rule_verification_Buffered_UL_deactived_1120_without_CA
#     [Tags]    CRT_TRUNK    CIT_22R2    CDRT_22R2    CRT_22R4
#     [Documentation]    author: Zhang Ningning
#     [Setup]    Common case setup   is_pdl_checking_needed=${False}
#     Set 5GC001120 deactive without CA and check alarm
#     [Teardown]   run Keyword and ignore Error    Common case teardown with recovery 4UL
