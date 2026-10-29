# *** Settings ***
# Resource    ../Resources/5GC002033_Keywords.robot
# 
# 
# 
# Documentation
# ...   author: Zhang Ningning
# ...   contact: ningning.zhang@nokia-sbell.com
# ...   squad group: SG_04
# ...   Feature 5GC002033 in 22R2 program, RU type:AEWD
# 
# Force Tags      5G_SISO         #7.1816  0.816  1596
# ...    PY36
# 
# Suite Setup     Suite preparation for 8cc   ${SCF_DEFAULT_FILE_PATH}
# 
# Suite Teardown  Run Keyword And Ignore Error      Suite env recovery
# 
# 
# 
# *** Test Cases ***
# [1]5GC002033_B_003_General_SiSo_E2E_system_setup_with_data_transfer_with_4Cell_2dl_2ul_and_4cell_2dl_0ul
#     [Tags]    CRT_TRUNK
#     [Documentation]    author: Zhang Ningning
#     [Setup]    Common case setup    is_log_required=${True}
#     2033 Call case with QCOM UE and record throughput info for many cells many times
#     ...    repeat_times=${TEST_REPEAT_TIMES}     verify_duration=${VERIFY_DURATION}
#     ...    ul_exp_tput=${UL_EXPECT_PEAK}    dl_exp_tput=${DL_EXPECT_PEAK}    exp_tput_percentage=${EXP_TPUT_PERCENTAGE}
#     ...    ignore_time=${90}
#     [Teardown]    run Keyword and ignore Error    Common case teardown   is_log_required=${True}  detach_ue=${True}
# 
# [1]5GC002033_B_002_General_SiSo_Cell_lock_and_unlock_with_4Cell_2dl_2ul_and_4cell_2dl_0ul
#     [Tags]    CIT_TRUNK     CIT_22R2    CDRT_22R2    CIT_22R4    CDRT_22R3
#     [Documentation]    author: Zhang Ningning
#     [Setup]     run keywords   Common case setup    is_log_required=${True}   is_pdl_checking_needed=${True}  AND   run keyword and ignore error
#     ...    Start X2 log capture from eNB
#     2033 Perform cell lock unlock and check throughput for many cells many times    cell_index_list=${GNB_PS_CELL_INDEX_LIST}
#     ...    repeat_times=${TEST_REPEAT_TIMES}    verify_duration=${VERIFY_DURATION}    ignore_time=${90}
#     [Teardown]    run Keyword and ignore Error   run keywords  Stop X2 log capture from eNB
#      ...   AND     common case teardown with 2033   operation=cell_unlock
# 
# [1]5GC002033_B_008_General_SiSo_RU_block_unblock_with_4cc_2dl_2ul_4cc_2dl_0ul
#     [Tags]  CRT_TRUNK
#     [Documentation]    author: Zhang Ningning
#     [Setup]    Common case setup    is_log_required=${True}
#     Perform ru lock unlock and check throughput for many ru many times    ru_index_list=${RU_INDEX_LIST}
#     ...    para_update_timeout=${TIMEOUT_MODIFY_PARA}    verify_duration=${VERIFY_DURATION}    ignore_time=${90}
#     ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}    repeat_times=${TEST_REPEAT_TIMES}    connection=GNB_OAM
#    [Teardown]   run Keyword and ignore Error  common case teardown with 2033   operation=ru_unlock
# 
# [1]5GC002033_B_016_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot_config_4cc_2dl_2ul_ASIK
#     [Tags]  CRT_TRUNK
#     [Documentation]    author: Zhang Ningning
#     [Setup]    Common case setup    is_log_required=${True}      if_create_ru_alias_needed=${True}
#     2033 Call case with QCOM UE and record throughput info for many cells many times    para_update_timeout=${TIMEOUT_MODIFY_PARA}
#     ...    repeat_times=${TEST_REPEAT_TIMES}     verify_duration=${VERIFY_DURATION}    ignore_time=${90}
#     ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}
#     Connect to Common Unit Master    alias=ASIK Master
#     @{RUS_ALIAS}    Connect to all rus with allocated IP
#     Set suite variable    ${RUS_ALIAS}
#     Verify RFSW Log Include In Snapshot    ru_alias=RU_1    is_get_snapshot_via_selenium=${True}
#     [Teardown]    run Keyword and ignore Error    Common case teardown   is_log_required=${True}  detach_ue=${True}
# 
# [1]5GC002033_B_018_cell_addtion_deletion_on_WebUI_with_4cc_2dl_2ul_4cc_2dl_0ul
#     [Tags]    CRT_TRUNK
#     [Documentation]    author: Zhang Ningning
#     [Setup]    Common case setup    is_log_required=${True}
#     ${cell_info_8}    Get Cell Parameters    cell_id=8
#     ${cell_info_7}    Get Cell Parameters    cell_id=7
#     Remove Cell From Configuration    cell_id=8    cell_group_id=0
#     Remove Cell From Configuration    cell_id=7    cell_group_id=0
#     Cell number should be as expected    expect_cell_number=${6}
#     Verify all cells should be onair
#     2033 Call case with QCOM UE and record throughput info for many cells many times
#     ...   para_update_timeout=${TIMEOUT_MODIFY_PARA}    repeat_times=${TEST_REPEAT_TIMES}    ignore_time=${90}
#     ...   verify_duration=${VERIFY_DURATION}    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}
#     gnbcombinedcell.Add New Cell Based On Existing Cell To Configuration    cell_parameters=${cell_info_7}
#     ...    cell_id_to_copy_from=${6}    nrcell_include_subobject=${True}    activate_plan_despite_errors=${True}
#     gnbcombinedcell.Add New Cell Based On Existing Cell To Configuration    cell_parameters=${cell_info_8}
#     ...    cell_id_to_copy_from=${6}    nrcell_include_subobject=${True}    activate_plan_despite_errors=${True}
#     Cell number should be as expected    expect_cell_number=${8}
#     Verify all cells should be onair
#     2033 Call case with QCOM UE and record throughput info for many cells many times
#     ...    para_update_timeout=${TIMEOUT_MODIFY_PARA}   verify_duration=${VERIFY_DURATION}    ignore_time=${90}
#     ...    repeat_times=${TEST_REPEAT_TIMES}     ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}
#     [Teardown]  run Keyword and ignore Error    Common case teardown   is_log_required=${True}  detach_ue=${True}
