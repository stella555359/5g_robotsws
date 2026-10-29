# *** Settings ***
# Resource    ../Resources/5GC002033_Keywords.robot
# Resource    ../Resources/5GC002033_Variables.robot
# Resource    ../../5GC001596_D/Resources/5GC001596_D_Keywords.robot
# 
# 
# 
# Documentation
# ...   author: Zhang Ningning
# ...   contact: ningning.zhang@nokia-sbell.com
# ...   squad group: SG_04
# ...   Feature 5GC002033 in 22R2 program, RU type:AEWB
# 
# Force Tags      5G_SISO
# ...    PY36
# 
# Suite Setup     Suite preparation for 4cc   ${SCF_DEFAULT_FILE_PATH}
# 
# Suite Teardown  Run Keyword And Ignore Error      Suite env recovery
# 
# 
# 
# *** Test Cases ***
# 
# [1]5GC002033_A_010_General_SiSo_RU_block_unblock_config_4cc_2dl_2ul_ASIK
#     [Tags]  CIT_TRUNK     CIT_22R2    CIT_22R3    CDRT_22R2    CIT_22R4    CDRT_22R3
#     [Documentation]    author: Zhang Ningning
#     [Setup]    run keywords   Common case setup    is_log_required=${True}   is_pdl_checking_needed=${True}  AND   run keyword and ignore error
#     ...    Start X2 log capture from eNB
#     run keyword and continue on failure    Should be true    ${PDL_VALIDATION_RESULT}!=${False}
#     ...    msg=Commissioned with error exists, pdl validation result is not in OK status.
#     2033 Perform ru lock unlock and check throughput for many ru many times    ru_index_list=${RU_1}
#     ...    para_update_timeout=${TIMEOUT_MODIFY_PARA}    verify_duration=${VERIFY_DURATION}    ignore_time=${90}
#     ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}    repeat_times=${TEST_REPEAT_TIMES}    connection=GNB_OAM
#    [Teardown]   run Keyword and ignore Error   run keywords  Stop X2 log capture from eNB
#    ...   AND  Common case teardown   is_log_required=${True}  detach_ue=${True}
# 
# [1]5GC002033_A_003_General_SiSo_E2E_system_setup_with_data_transfer_with_4Cell_2dl_2ul_ASIK
#     [Tags]    CRT_TRUNK
#     [Documentation]    author: fang ludan
#     [Setup]    Common case setup    is_log_required=${True}
#     2033 Call case with QCOM UE and record throughput info for many cells many times
#     ...    repeat_times=${TEST_REPEAT_TIMES}     verify_duration=${VERIFY_DURATION}    ignore_time=${90}
#     ...    ul_exp_tput=${UL_EXPECT_PEAK}    dl_exp_tput=${DL_EXPECT_PEAK}    exp_tput_percentage=${EXP_TPUT_PERCENTAGE}
#     [Teardown]    run Keyword and ignore Error    Common case teardown   is_log_required=${True}  detach_ue=${True}
# 
# [1]5GC002033_A_012_cell_addtion_deletion_on_WebUI_config_4cc_2dl_2ul_ASIK
#     [Tags]    CRT_TRUNK
#     [Documentation]    author: fang ludan
#     [Setup]    Common case setup    is_log_required=${True}
#     ${cell_info_4}    Get Cell Parameters    cell_id=4
#     ${cell_info_3}    Get Cell Parameters    cell_id=3
#     Remove Cell From Configuration    cell_id=4    cell_group_id=0
#     Remove Cell From Configuration    cell_id=3    cell_group_id=0
#     Cell number should be as expected    expect_cell_number=${2}
#     Verify all cells should be onair
#     2033 Call case with QCOM UE and record throughput info for many cells many times
#     ...   para_update_timeout=${TIMEOUT_MODIFY_PARA}    repeat_times=${TEST_REPEAT_TIMES} cell_index_list=${CELL_INDEX_DELET}
#     ...   verify_duration=${VERIFY_DURATION}    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}
#     ...    ignore_time=${90}
#     gnbcombinedcell.Add New Cell Based On Existing Cell To Configuration    cell_parameters=${cell_info_3}
#     ...    cell_id_to_copy_from=${2}    nrcell_include_subobject=${True}    activate_plan_despite_errors=${True}
#     gnbcombinedcell.Add New Cell Based On Existing Cell To Configuration    cell_parameters=${cell_info_4}
#     ...    cell_id_to_copy_from=${2}    nrcell_include_subobject=${True}    activate_plan_despite_errors=${True}
#     Cell number should be as expected    expect_cell_number=${4}
#     Verify all cells should be onair
#     2033 Call case with QCOM UE and record throughput info for many cells many times
#     ...    para_update_timeout=${TIMEOUT_MODIFY_PARA}   verify_duration=${VERIFY_DURATION}  cell_index_list=${GNB_PS_CELL_INDEX_LIST}
#     ...    repeat_times=${TEST_REPEAT_TIMES}     ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}
#     ...    ignore_time=${90}
#     [Teardown]   Run Keyword And Ignore Error    Common case teardown   is_log_required=${True}  detach_ue=${True}
# 
