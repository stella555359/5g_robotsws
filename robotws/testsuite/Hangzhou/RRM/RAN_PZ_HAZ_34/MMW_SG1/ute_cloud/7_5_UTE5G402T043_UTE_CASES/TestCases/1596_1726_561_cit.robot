# *** Settings ***
# Resource    ./../Resources/1596_1726_561_Keywords.robot
# Resource    ./../Resources/CB007723_keywords.robot
# 
# Documentation
# ...   author:
# ...   contact:
# ...   squad group: MMW_SG1
# ...   Feature 5GC001596 in 5G19B program, RU type:AEWD
# 
# Force Tags    RAN_5G    RAN_5G_TDD
# ...    PY39
# ...           5G_RAN_TDD     STATE_SW_UPLOADED     5G_RAN    CLOUD_5G_CLASSICAL_ASIBL_ABILB1_AEWB_ENB
# ...           master_classicalbts_all    20Bb1_classicalbts    21A_classicalbts    SBTS00
# 
# 
# Suite Setup     run keyword and ignore error    log   Suite common setup preparation ute cloud
# 
# Suite Teardown  run keyword and ignore error    log   Common suite recovery
# 
# *** Variables ***
# @{CELL_INDEX_LIST}    1    2
# ${GP}    6Symbols
# ${UL_TPUT_EXPECT}    10M
# ${NR_CELL_ID_MAPPING}   None
# 
# *** Test Cases ***
# 
# #[1]5GC001596_F_002_OAM_report_alarm_while_configuration_error
# #    [Tags]    CIT
# #    [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
# #    ${status}    run keyword and return status
# #    ...    1596_OAM_report_alarm_while_configuration_error
# #    [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${False}
# #
# #[1]5GC001596_D_016_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
# #    [Tags]    CIT
# #    [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
# #    ${status}    run keyword and return status
# #    ...    D_016_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
# #    [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${False}
# 
# [1]5GC001596_D_008_General_SiSo_RU_block_unblock
#     [Tags]
#     [Setup]    run keyword and ignore error    robot_common_operations.Common Case Setup
#     ${status}    run keyword and return status   log
#     ...    Perform ru lock unlock and check throughput for many ru many times
#     [Teardown]    run keyword and ignore error    log   Common case teardown
# 
# [1]5GC001596_F_007_General_SiSo_Cell_lock_and_unlock
#     [Tags]
#     [Setup]    run keyword and ignore error    log   Common case setup
#     ${status}    run keyword and return status   log
#     ...    Perform cell lock unlock and check throughput for many cells many times
#     [Teardown]    run keyword and ignore error    log  Common case teardown
# 
# #[1]5GC001596_F_017_General_SiSo_Cell_group_lock_and_unlock
# #    [Tags]    CIT
# #    [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
# #    ${status}    run keyword and return status
# #    ...    Perform cell group lock unlock and check throughput for many cell group many times    cellgrp_index_list=${CELLGRP_INDEX_LIST}
# #    ...    para_update_timeout=${TIMEOUT_MODIFY_PARA}    repeat_times=${TEST_REPEAT_TIMES}    verify_duration=${VERIFY_DURATION}
# #    ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}    connection=GNB_OAM
# #    [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${False}
# 
# [1]5GC001596_F_018_cell_addtion_deletion_on_WebUI
#     [Tags]
#     [Setup]    run keyword and ignore error    log  Common case setup
#     ${status}    run keyword and return status   log
#     ...    F_018_cell_addtion_deletion_on_WebUI
#     [Teardown]    run keyword and ignore error    log  Common case teardown
# 
# #[1]CB007459-A-7_Proactive_UL_scheduling_for_a_selected_UE_performing_ping_request
# #    [Tags]    CIT
# #    [Setup]    run keyword and ignore error    log   Common case setup
# #    ${status}    run keyword and return status   log
# #    ...    Proactive_UL_scheduling_for_a_selected_UE_performing_ping_request
# #    [Teardown]    run keyword and ignore error    log   Common case teardown
# 
# [1]5GC001726_GA_142_GNB-8CCDL_2CCUL_maxScell7DL1UL_non_contiguous_freq_IWK_5GC000772_DRX_enable_SRB3
#     [Tags]
#     [Setup]    run keyword and ignore error    log   Common case setup
#     ${status}    run keyword and return status   log
#     ...    GA_142_GNB-8CCDL_2CCUL_maxScell7DL1UL_non_contiguous_freq_IWK_5GC000772_DRX_enable_SRB3
#     [Teardown]    run keyword and ignore error    log   Common case teardown
# 
# [1][1.0]5GC001726_GE_502_GNB-8CCDL_2CCUL_maxScell7DL1UL_non-contiguous_UE8DL2UL_1UE_LowThroughput_HighThroughput_LowThroughput
#     [Tags]
#     [Setup]    run keyword and ignore error    log   Common case setup
#     ${status}    run keyword and return status   log
#     ...    GE_502_GNB-8CCDL_2CCUL_maxScell7DL1UL_non-contiguous_UE8DL2UL_1UE_LowThroughput_HighThroughput_LowThroughput
#     [Teardown]    run keyword and ignore error    log  Common case teardown
# 
# [1]5GC002033_A_010_General_SiSo_RU_block_unblock_config_4cc_2dl_2ul_ASIK
#     [Tags]
#     [Documentation]    author: Zhang Ningning
#     [Setup]    run keyword and ignore error    log   Common case setup
#     ${status}    run keyword and return status   log   A_010_General_SiSo_RU_block_unblock_config_4cc_2dl_2ul_ASIK
#    [Teardown]   run Keyword and ignore Error    log   Common case teardown
# 
# [1]5GC002033_B_002_General_SiSo_Cell_lock_and_unlock_with_4Cell_2dl_2ul_and_4cell_2dl_0ul
#     [Tags]
#     [Documentation]    author: Zhang Ningning
#     [Setup]    run keyword and ignore error   log   Common case setup
#     ${status}    run keyword and return status   log
#     ...    B_002_General_SiSo_Cell_lock_and_unlock_with_4Cell_2dl_2ul_and_4cell_2dl_0ul
#     [Teardown]     Run Keyword And Ignore Error   log    common case teardown with 2033
# 
# #[1]5GC002033_B_008_General_SiSo_RU_block_unblock_with_4cc_2dl_2ul_4cc_2dl_0ul
# #    [Tags]  CIT
# #    [Documentation]    author: Zhang Ningning
# #    [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
# #    ${status}    run keyword and return status
# #    ...    B_008_General_SiSo_RU_block_unblock_with_4cc_2dl_2ul_4cc_2dl_0ul
# #   [Teardown]   run Keyword and ignore Error  common case teardown with 2033   operation=ru_unlock
# #
# #[1]5GC002033_B_018_cell_addtion_deletion_on_WebUI_with_4cc_2dl_2ul_4cc_2dl_0ul
# #    [Tags]    CIT
# #    [Documentation]    author: Zhang Ningning
# #    [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
# #    ${status}    run keyword and return status
# #    ...    B_018_cell_addtion_deletion_on_WebUI_with_4cc_2dl_2ul_4cc_2dl_0ul
# #    [Teardown]  run Keyword and ignore Error    Common case teardown   is_log_required=${False}  detach_ue=${True}
# CB007723-A-0101-PRACH_format_B4_4cc_2GPSymbols_regularCellOnly
#     [Tags]
#     [Documentation]    Author: wang liya
#     ...    check prach format B4 in regular and extend cell
#     ...    immediatel without any alarm or service interruption.
#     [Setup]    run keyword and ignore error   log   Common case setup
#     #...    scf_template_path=SCF_0.800_4cc.xml
#     ${status}    run keyword and return status   log   Modify all B4 configuration index and L3 Call
#     [Teardown]    run keyword and ignore error   log   Common case teardown
# 
# CB007723-B-0110-4CC-Random_Access_by_UE_to_multiple_cells_configuration_with_mixed_GP_symbols
#     [Tags]
#     [Documentation]    Author: wang liya
#     ...    check different GP attach for B4 format
#     ...    immediatel without any alarm or service interruption.
#     [Setup]    run keyword and ignore error   log   Common case setup
#     #...    scf_template_path=SCF_0.800_4cc.xml
#     ${status}    run keyword and return status    log   Modify GP parameter via rest api and wait onair and L3call
#     ${status}    run keyword and return status    log   Modify GP parameter via rest api and wait onair and L3call
#     #...    cell_index_for_attach=${2}    GP=${GP}
#     [Teardown]    run keyword and ignore error    log   Common case teardown
# 
# CB007723-C-0105-4CC-Cells_configurations_with_mixed_range_and_different_GP_symbols
#     [Tags]
#     [Documentation]    Author: wang liya
#     ...    check different GP adn different range attach for B4 format
#     ...    immediatel without any alarm or service interruption.
#     [Setup]    run keyword and ignore error   log   Common case setup
#     #...    scf_template_path=SCF_0.800_4cc.xml
#     ${status}    run keyword and return status   log
#     ...    Modify Mixed GP and RANGE parameter via rest api and wait onair and L3call
#     ${status}    run keyword and return status   log
#     ...    Modify Mixed GP and RANGE parameter via rest api and wait onair and L3call
#     #...    cell_index_for_attach=${2}    GP=${GP}
#     [Teardown]    run keyword and ignore error   log   Common case teardown
# 
# *** Keywords ***
# Suite common setup preparation ute cloud
#     Set Suite Variable    ${brand}   samsung
#     CI_interface.Common Suite Setup
#     Suite common setup preparation    scf_template_path=SCF_0.800_8cc.xml    prepare_ue=${True}
# 
