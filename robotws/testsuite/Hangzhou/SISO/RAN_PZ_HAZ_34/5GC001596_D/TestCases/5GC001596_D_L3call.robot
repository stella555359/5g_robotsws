# *** Settings ***
# Resource    ../Resources/5GC001596_D_Keywords.robot
# 
# Documentation
# ...   author: Liu Zheng
# ...   contact: zheng.4.liu@nokia-sbell.com
# ...   squad group: SG_04
# ...   Feature 5GC001596 in 5G19B program, RU type:AEWD
# 
# Force Tags      5G_SISO         7.1816  0.816  1596
# ...    PY36
# 
# Suite Setup     Suite preparation
# 
# Suite Teardown  Run Keyword And Ignore Error      Suite env recovery
# 
# 
# 
# *** Test Cases ***
# #[1]5GC001596_D_010_General_SiSo_E2E_system_setup_with_data_transfer
# #    [Tags]    CRT_19B    CRT_20B
# #    [Documentation]    author: Liu Zheng
# #    [Setup]    Case preparation with btslog collection for L3call
# #    Call case with QCOM UE and record throughput info for many cells many times
# #    ...    repeat_times=${TEST_REPEAT_TIMES}     verify_duration=${VERIFY_DURATION}
# #    ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}    exp_tput_percentage=${EXP_TPUT_PERCENTAGE}
# #    [Teardown]    Run Keyword And Ignore Error    Case env recovery with btslog collection for L3call
# 
# [1]5GC001596_D_016_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     [Tags]  CIT_19B    CIT_20B    CIT_21A    CIT_21B    CIT_22R1    CRT_TRUNK    CRT_22R1    CRT_22R4    CRT_23R1
#     [Documentation]    author: Liu Zheng
#     [Setup]    Case preparation with btslog collection for L3call       if_create_ru_alias_needed=${True}
#     Call case with QCOM UE and record throughput info for many cells many times    para_update_timeout=${TIMEOUT_MODIFY_PARA}
#     ...    repeat_times=${TEST_REPEAT_TIMES}     verify_duration=${VERIFY_DURATION}
#     ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}
#     Create alias for case setup temp
#     Verify RFSW Log Include In Snapshot    ru_alias=RU_1    is_get_snapshot_via_selenium=${True}
#     [Teardown]    Run Keyword And Ignore Error    Case env recovery with btslog collection for L3call
# 
# [1]5GC001596_D_008_General_SiSo_RU_block_unblock
#     [Tags]  CIT_19B    CIT_20B    CIT_21A    CIT_21B    CIT_22R1    CRT_22R1    CIT_22R3    CIT_22R4    CDRT_22R3
#     [Documentation]    author: Liu Zheng
#     [Setup]    Case preparation with btslog collection for L3call
#     # becuase no cell configured on RU2(RU2 no need to be check), ru_index_list just only point to RU1
#     Perform ru lock unlock and check throughput for many ru many times    ru_index_list=${RU_1}
#     ...    para_update_timeout=${TIMEOUT_MODIFY_PARA}    verify_duration=${VERIFY_DURATION}
#     ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}    repeat_times=${TEST_REPEAT_TIMES}    connection=GNB_OAM
#    [Teardown]   Run Keyword And Ignore Error    Case env recovery with btslog collection for L3call    operation=ru_unlock
# 
# #[1]5GC001596_D_007_General_SiSo_Cell_lock_and_unlock
# #    [Tags]  debug
# #    [Documentation]    author: Liu Zheng
# #    [Setup]    Case preparation with btslog collection for L3call
# #    Perform cell lock unlock and check throughput for many cells many times    cell_index_list=${CELL_INDEX_LIST}
# #    ...    repeat_times=${TEST_REPEAT_TIMES}    duration_time=${DURATION_TIME}    verify_duration=${VERIFY_DURATION}
# #    [Teardown]     Run Keyword And Ignore Error    Case env recovery with btslog collection for L3call    operation=cell_unlock
# #
# #[1]5GC001596_D_017_General_SiSo_Cell_group_lock_and_unlock
# #    [Tags]  debug
# #    [Documentation]    author: Liu Zheng
# #    [Setup]    Case preparation with btslog collection for L3call
# #    Perform cell group lock unlock and check throughput for many cell group many times    cellgrp_index_list=${CELLGRP_INDEX_LIST}
# #    ...    para_update_timeout=${TIMEOUT_MODIFY_PARA}    repeat_times=${TEST_REPEAT_TIMES}    duration_time=${DURATION_TIME}
# #    ...    verify_duration=${VERIFY_DURATION}    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}    connection=GNB_OAM
# #    [Teardown]   Run Keyword And Ignore Error    Case env recovery with btslog collection for L3call    operation=cell_group_unlock
# 
# *** Keywords ***
# Suite preparation
#     [Documentation]    author: Liu Zheng
#     [Timeout]    20 min
#     COAM Create log directory    is_set_to_test_case_level=${False}
#     set suite variable     ${PARAMS_TO_DELETE}    ${ABIL_4CC_ABIO_0CC_DEL}
#     set suite variable     ${PARAMS_TO_MODIFY}    ${ABIL_UL2CC_MODIFY}
#     Suite common setup preparation    is_pdl_checking_needed=${False}      enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH}
#     Get the ru index list and cell index list and cell group index list and set to suite variable
#     ${ue_type}    ue.translate_power_ue_type_from_testline    ue_index=${0}
#     set suite variable    ${UE_TYPE}    ${ue_type}
#     power_ue.Prepare UE    ue_type=${UE_TYPE}
#     ${program}    gnb_classical_hangzhou.Get program version based on stream version
#     set suite variable    ${PROGRAM}    ${program}
