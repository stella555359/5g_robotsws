# *** Settings ***
# Resource   ../../Resources/5GC001726_keywords.robot
# Library    ../../Resources/check_counter.py
# 
# Documentation    Suite description
# ...   author: Ren Biyao
# ...   contact: biyao.ren@nokia-sbell.com
# ...   squad group: MMW_SG1
# ...   Feature 5GC001726-GA in 5G19B program
# 
# Force Tags    5G_RRM        7.1816  1726-GA
# ...    PY36
# Suite Setup    run keywords   Import NIDD variables    AND    Counter suite preparation
# Suite Teardown  Run keyword and ignore error    5GC001726_Keywords.Common Suite Teardown
# 
# *** Test Cases ***
# [1]5GC001726_GA_122_M55118C02008_M55118C03008
#     [Tags]    CRT_20B    CRT_21A    CRT_21B    CRT_22R1    CRT_22R3    CRT_22R4    CRT_23R1
#     [Documentation]    Author: Ren Biyao
#     ...    Terminal is qcom ue. Verify the PM counters M55118C02008 and M55118C03008 can work correctly.
#     [Setup]    Test case preparation
#     ${parameters_to_update_via_api}    combine lists    ${MODIFY_maxNumScellsDL_5_VIA_API}   ${MODIFY_maxNumScellsUl_0_VIA_API}
#     COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update_via_api}
#     ${local_counter_file_path}    Attach to pcells and collect counter logs
#     @{all_check_value_status}    create list
#     FOR  ${cur_counter_file}  IN  @{local_counter_file_path}
#         log to console    ${cur_counter_file}
#         ${cur_check_value_status}    run keyword and return status     run keywords
#         ...    Expect one counter works while other counters remain idle
#         ...    local_counter_log_path=${cur_counter_file}    list_all_interested_counter_ids=${LIST_RRC_RECONF_x_SCELL_ATT_COUNTER}
#         ...    expect_work_counter_value=${SCELL_ATT_NUMBER}    expect_work_counter_id=M55118C02008
#         ...    cell_id=1-8      num_cells_with_expected_counter_work=1    AND
#         ...    Expect one counter works while other counters remain idle
#         ...    local_counter_log_path=${cur_counter_file}    list_all_interested_counter_ids=${LIST_RRC_RECONF_x_SCELL_SUCC_COUNTER}
#         ...    expect_work_counter_value=${SCELL_SUCC_NUMBER}   expect_work_counter_id=M55118C03008
#         ...    cell_id=1-8      num_cells_with_expected_counter_work=1
#         append to list   ${all_check_value_status}    ${cur_check_value_status}
#         exit for loop if    ${cur_check_value_status}
#     END
#     list should contain value     ${all_check_value_status}    ${True}
#     [Teardown]    Run keyword and ignore error    Test Case Teardown
# 
# #[1]5GC001726_GA_123_M55118C02010_M55118C03010
# #    [Tags]    CRT_20B    CRT_21B
# #    [Documentation]    Author: Ren Biyao
# #    ...    Terminal is qcom ue. Verify the PM counters M55118C02010 and M55118C03010 can work correctly.
# #    [Setup]    Test case preparation
# #    ${parameters_to_update_via_api}    combine lists    ${MODIFY_maxNumScellsDL_6_VIA_API}   ${MODIFY_maxNumScellsUl_0_VIA_API}
# #    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update_via_api}
# #    @{local_counter_file_path}    Attach to pcells and collect counter logs
# #    @{all_check_value_status}    create list
# #    FOR  ${cur_counter_file}  IN  @{local_counter_file_path}
# #        ${cur_check_value_status}    run keyword and return status     run keywords
# #        ...    Expect one counter works while other counters remain idle
# #        ...    local_counter_log_path=${cur_counter_file}    list_all_interested_counter_ids=${LIST_RRC_RECONF_x_SCELL_ATT_COUNTER}
# #        ...    expect_work_counter_value=${SCELL_ATT_NUMBER}    expect_work_counter_id=M55118C02010
# #        ...    cell_id=1-8      num_cells_with_expected_counter_work=1    AND
# #        ...    Expect one counter works while other counters remain idle
# #        ...    local_counter_log_path=${cur_counter_file}    list_all_interested_counter_ids=${LIST_RRC_RECONF_x_SCELL_SUCC_COUNTER}
# #        ...    expect_work_counter_value=${SCELL_SUCC_NUMBER}    expect_work_counter_id=M55118C03010
# #        ...    cell_id=1-8      num_cells_with_expected_counter_work=1
# #        append to list   ${all_check_value_status}    ${cur_check_value_status}
# #        exit for loop if    ${cur_check_value_status}
# #    END
# #    list should contain value     ${all_check_value_status}    ${True}
# #
# #    [Teardown]    Run keyword and ignore error    Test Case Teardown
# 
# #[1]5GC001726_GA_129_M55118C04012_M55118C05012
# #    [Documentation]    Author: Ren Biyao
# #    ...    Terminal is qcom ue. Verify the PM counters M55118C04012 and M55118C05012 can work correctly.
# #    ...    The contiguous frequency type is 2+2+1+1+1+1.
# #    ...    The case needs to check the counter which can record a period of attach time.
# #    ...    The design idea is to make ue attach for more than 5min, and the counter will be generated every 5min. Then the
# #    ...    last file generated will record number 300 in representative of attach 5min. But in the current bts version,
# #    ...    299, 301 may also happen and can be regard as correct value.
# #    [Tags]     CRT_20B    CRT_21B
# #    [Setup]    Test case preparation
# #    ${parameters_to_update_via_api}    combine lists    ${MODIFY_maxNumScellsDL_7_VIA_API}   ${MODIFY_maxNumScellsUl_0_VIA_API}
# #    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update_via_api}
# #    Connect to Capacity Unit Master case
# #    @{local_counter_file_path}    Attach to pcells and collect counter logs
# #    ...    is_need_to_keep_ue_attach=${True}     duration_of_ue_attach=10min
# #    @{all_check_value_status}    create list
# #    FOR  ${cur_counter_file}  IN  @{local_counter_file_path}
# #         log to console    ${cur_counter_file}
# #         ${cur_check_value_status}    run keyword and return status     run keywords
# #         ...    Expect one counter works while other counters remain idle
# #         ...    local_counter_log_path=${cur_counter_file}    list_all_interested_counter_ids=${LIST_UE_PSCELL_X_CONF_SCELL_COUNTER}
# #         ...    expect_work_counter_value=299,300,301    expect_work_counter_id=M55118C04012
# #         ...    cell_id=1-8      num_cells_with_expected_counter_work=1    AND
# #         ...    Expect one counter works while other counters remain idle
# #         ...    local_counter_log_path=${cur_counter_file}    list_all_interested_counter_ids=${LIST_UE_SCELL_X_CONF_SCELL_COUNTER}
# #         ...    expect_work_counter_value=299,300,301    expect_work_counter_id=M55118C05012
# #         ...    cell_id=1-8      num_cells_with_expected_counter_work=7
# #         append to list   ${all_check_value_status}    ${cur_check_value_status}
# #         exit for loop if    ${cur_check_value_status}
# #    END
# #    list should contain value     ${all_check_value_status}    ${True}
# #    [Teardown]    Run keyword and ignore error    Test Case Teardown
# 
# [1]5GC001726_GA_126_M55118C04006_M55118C05006
#     [Documentation]    Author: Ren Biyao
#     ...    Terminal is qcom ue. Verify the PM counters M55118C04006 and M55118C05006 can work correctly.
#     [Tags]   CRT_20B    CRT_21A    CRT_21B    CRT_22R1    CRT_22R3    CRT_22R4    CRT_23R1
#     [Setup]    Test case preparation
#     ${parameters_to_update_via_api}    combine lists    ${MODIFY_maxNumScellsDL_4_VIA_API}    ${MODIFY_maxNumScellsUl_0_VIA_API}
#     Update parameters which will cause bts restart via api    parameters_to_update_via_api=${parameters_to_update_via_api}
#     @{local_counter_file_path}    Attach to pcells and collect counter logs
#     ...    is_need_to_keep_ue_attach=${True}    duration_of_ue_attach=10min
#     @{all_check_value_status}    create list
#     FOR  ${cur_counter_file}  IN  @{local_counter_file_path}
#          log to console    ${cur_counter_file}
#          ${cur_check_value_status}    run keyword and return status     run keywords
#          ...    Expect one counter works while other counters remain idle
#          ...    local_counter_log_path=${cur_counter_file}    list_all_interested_counter_ids=${LIST_UE_PSCELL_X_CONF_SCELL_COUNTER}
#          ...    expect_work_counter_value=299,300,301    expect_work_counter_id=M55118C04006
#          ...    cell_id=1-8      num_cells_with_expected_counter_work=1    AND
#          ...    Expect one counter works while other counters remain idle
#          ...    local_counter_log_path=${cur_counter_file}    list_all_interested_counter_ids=${LIST_UE_SCELL_X_CONF_SCELL_COUNTER}
#          ...    expect_work_counter_value=299,300,301    expect_work_counter_id=M55118C05006
#          ...    cell_id=1-8      num_cells_with_expected_counter_work=4
#          append to list   ${all_check_value_status}    ${cur_check_value_status}
#          exit for loop if    ${cur_check_value_status}
#     END
#     list should contain value     ${all_check_value_status}    ${True}
#     [Teardown]    Run keyword and ignore error    Test Case Teardown
# 
# 
