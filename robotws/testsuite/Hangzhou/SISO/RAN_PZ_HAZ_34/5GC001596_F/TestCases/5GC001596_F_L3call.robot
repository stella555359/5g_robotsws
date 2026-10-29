# *** Settings ***
# Resource    ../Resources/5GC001596_F_Keywords.robot
# Variables   ../Resources/5GC001596_F_L3call.py
# 
# Documentation
# ...   author: Cui Lingxue
# ...   contact: lingxue.cui@nokia-sbell.com
# ...   squad group: SG_04
# ...   Feature 5GC001596 in 5G19B program, RU type:AEWD
# 
# Force Tags      5G_SISO         7.1816  0.816  1596
# ...    PY36
# 
# Suite Setup     Suite preparation
# 
# Suite Teardown  Run Keyword And Ignore Error    Suite env recovery
# 
# 
# *** Test Cases ***
# #[1]5GC001596_F_010_General_SiSo_E2E_system_setup_with_data_transfer
# #    [Tags]    CRT_19B    CRT_20B
# #    [Documentation]    author: Cui Lingxue
# #    [Setup]    Case preparation with btslog collection for L3call
# #    Call case with QCOM UE and record throughput info for many cells many times    para_update_timeout=${TIMEOUT_MODIFY_PARA}
# #    ...    repeat_times=${TEST_REPEAT_TIMES}    verify_duration=${VERIFY_DURATION}
# #    ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}
# #    [Teardown]    Run Keyword And Ignore Error    Case env recovery with btslog collection for L3call
# 
# #[1]5GC001596_F_016_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
# #    [Tags]  debug
# #    [Documentation]    author: Cui Lingxue
# #    [Setup]    Case preparation with btslog collection for L3call
# #    Call case with QCOM UE and record throughput info for many cells many times    para_update_timeout=${TIMEOUT_MODIFY_PARA}
# #    ...   repeat_times=${TEST_REPEAT_TIMES}    duration_time=${DURATION_TIME}    verify_duration=${VERIFY_DURATION}
# #    ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}
# #    Connect to Common Unit Master    alias=ASIK Master
# #    @{RUS_ALIAS}    Connect to all rus with allocated IP
# #    Set suite variable    ${RUS_ALIAS}
# #    Verify RFSW Log Include In Snapshot    ru_alias=RU_1    timeout=900
# #    [Teardown]    Run Keyword And Ignore Error    Case env recovery with btslog collection for L3call
# 
# #[1]5GC001596_F_008_General_SiSo_RU_block_unblock
# #    [Tags]  debug
# #    [Documentation]    author: Cui Lingxue
# #    [Setup]    Case preparation with btslog collection for L3call
# #    Perform ru lock unlock and check throughput for many ru many times    ru_index_list=${RU_INDEX_LIST}
# #    ...    para_update_timeout=${TIMEOUT_MODIFY_PARA}    duration_time=${DURATION_TIME}    verify_duration=${VERIFY_DURATION}
# #    ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}    repeat_times=${TEST_REPEAT_TIMES}    connection=GNB_OAM
# #   [Teardown]   Run Keyword And Ignore Error    Case env recovery with btslog collection for L3call    operation=ru_unlock
# 
# [1]5GC001596_F_007_General_SiSo_Cell_lock_and_unlock
#     [Tags]  CIT_19B    CIT_20B    CIT_21A    CIT_21B    CIT_22R1    CRT_22R1    CIT_22R3    CIT_22R4    CDRT_22R3
#     [Documentation]    author: Cui Lingxue
#     [Setup]  run keywords   Case preparation with btslog collection for L3call   AND   run keyword and ignore error
#     ...    Start X2 log capture from eNB
#     Perform cell lock unlock and check throughput for many cells many times    cell_index_list=${CELL_INDEX_LIST}
#     ...    repeat_times=${TEST_REPEAT_TIMES}    verify_duration=${VERIFY_DURATION}
#     [Teardown]     Run Keyword And Ignore Error    run keywords  Stop X2 log capture from eNB
#      ...   AND    Case env recovery with btslog collection for L3call    operation=cell_unlock
# 
# [1]5GC001596_F_017_General_SiSo_Cell_group_lock_and_unlock
#     [Tags]    CIT_20B    CIT_21A    CIT_21B    CIT_22R1    CRT_22R1
#     [Documentation]    author: Liu Zheng
#     [Setup]    Case preparation with btslog collection for L3call
#     Perform cell group lock unlock and check throughput for many cell group many times    cellgrp_index_list=${CELLGRP_INDEX_LIST}
#     ...    para_update_timeout=${TIMEOUT_MODIFY_PARA}    repeat_times=${TEST_REPEAT_TIMES}    verify_duration=${VERIFY_DURATION}
#     ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}    connection=GNB_OAM
#     [Teardown]   Run Keyword And Ignore Error    Case env recovery with btslog collection for L3call    operation=cell_group_unlock
# 
# [1]5GC001596_F_018_cell_addtion_deletion_on_WebUI
#     [Tags]    CIT_19B    CIT_20B    CIT_21A    CIT_21B    CIT_22R1    CRT_22R1    CIT_22R3   CIT_22R4    CDRT_22R3
#     [Setup]   run keywords   Case preparation with btslog collection for L3call   AND   run keyword and ignore error
#     ...    Start X2 log capture from eNB
#     Run keyword if    '${program}'!='21B'    Enable CB007462 parameters and cell on air
#     ${cell_info_8}    Get Cell Parameters    cell_id=8
#     ${cell_info_7}    Get Cell Parameters    cell_id=7
#     Remove Cell From Configuration    cell_id=8    cell_group_id=0
#     Remove Cell From Configuration    cell_id=7    cell_group_id=0
#     Wait until keyword succeeds    1min    20s    Cell number should be as expected    expect_cell_number=${6}
#     Verify all cells should be onair
#     Call case with QCOM UE and record throughput info for many cells many times
#     ...   para_update_timeout=${TIMEOUT_MODIFY_PARA}    repeat_times=${TEST_REPEAT_TIMES}
#     ...   verify_duration=${VERIFY_DURATION}    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}
#     gnbcombinedcell.Add New Cell Based On Existing Cell To Configuration    cell_parameters=${cell_info_7}
#     ...    cell_id_to_copy_from=${6}    nrcell_include_subobject=${True}    activate_plan_despite_errors=${True}
#     gnbcombinedcell.Add New Cell Based On Existing Cell To Configuration    cell_parameters=${cell_info_8}
#     ...    cell_id_to_copy_from=${6}    nrcell_include_subobject=${True}    activate_plan_despite_errors=${True}
#     Wait until keyword succeeds    1min    20s    Cell number should be as expected    expect_cell_number=${8}
#     Wait Until Keyword Succeeds    1min    5s    Verify all cells should be onair
#     Call case with QCOM UE and record throughput info for many cells many times
#     ...    para_update_timeout=${TIMEOUT_MODIFY_PARA}   verify_duration=${VERIFY_DURATION}
#     ...    repeat_times=${TEST_REPEAT_TIMES}     ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}
#     [Teardown]   Run Keyword And Ignore Error   run keywords   Stop X2 log capture from eNB
#      ...   AND   Case env recovery with btslog collection for L3call
# 
# *** Keywords ***
# Suite preparation
#     [Documentation]    author: Cui Lingxue
#     [Timeout]    20 min
#     COAM Create log directory    is_set_to_test_case_level=${False}
#     set suite variable     ${PARAMS_TO_DELETE}    ${ABIL_8CC_ABIO_0CC_DEL}
#     set suite variable     ${PARAMS_TO_MODIFY}    ${ABIL_UL2CC_MODIFY}
#     Suite common setup preparation    is_pdl_checking_needed=${False}      enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH}
#     Get the ru index list and cell index list and cell group index list and set to suite variable
#     ${ue_type}    ue.translate_power_ue_type_from_testline    ue_index=${0}
#     set suite variable    ${UE_TYPE}    ${ue_type}
#     power_ue.Prepare UE    ue_type=${UE_TYPE}
#     ${program}    gnb_classical_hangzhou.Get program version based on stream version
#     set suite variable    ${PROGRAM}    ${program}
#     Verify SIM card state and reboot UE if SIM not loaded
# 
# 
# Enable CB007462 parameters and cell on air
#     [Documentation]   author: wang liya
#     ...    update parameters
#     [Arguments]     ${timeout_restapi}=3 min    ${timeout_onair}=3 min     ${connection}=GNB_OAM
#     coam_gnb_classical.COAM Update several parameters via rest api
#     ...    parameters_to_update_via_api=${MODIFY_CB007462_CONFIGURATION}
#     ...    timeout=${timeout_restapi}    connection=${connection}
#     Wait until cluster is on cell on air status    timeout=${timeout_onair}
# 
