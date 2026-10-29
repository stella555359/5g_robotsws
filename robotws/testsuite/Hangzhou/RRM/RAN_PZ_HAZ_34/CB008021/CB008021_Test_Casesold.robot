# *** Settings ***
# Documentation     author: Yan Xin
# ...               contact: xin.yan@nokia-sbell.com
# ...               squad group: I_NSB_MN_5GSC_MMW_SC_PZ_HZ_02_GMS <I_NSB_MN_5GSC_MMW_SC_PZ_HZ_02@internal.nsn.com>
# Suite Setup       Test Suite Setup
# Suite Teardown    Test Suite Teardown
# Resource          Resources/CB008021_Common_Keywords.robot
# 
# *** Test Cases ***
# [1]CB008021-5G-A_15_Verification_PM_Countesr_with_Different_BW_Cells
#     [Documentation]    The purpose of this test is to verify pm counters are normal in range.
#     [setup]    Run Keywords    robot_common_operations.Common Case Setup
#     ...                 AND    Perform RU lock via rest api
#     ...                        connection=${gnb_undertest_connection}    gnb_id=${tl_undertest_index}    timeout=${300}
#     ...                 AND    Ue attach and Make traffic for TL
#     ...                        throughput=${throughput_multi_cell}
#     ...                        tl_index=${tl_noise_index}    direction=ul
#     : FOR    ${var}    IN RANGE    ${file_count}
#     \    Sleep to wait for counter generate    interval=${period}
#     \    ${avg_counter_list}    ${max_counter_list}    Get sorted list from PM counter list
#     ...                                                interval=${period}
#     ...                                                mrbtsid=${gnb_noise_mrbtsid}
#     \    Check counter max value in range    ${avg_counter_list}    ${max_counter_list}
#     [teardown]    Run Keywords    Stop traffic and Detach UE for TL    direction=ul    tl_index=${tl_noise_index}
#     ...                    AND    Perform RU unlock via rest api
#     ...                           connection=${gnb_undertest_connection}     gnb_id=${tl_undertest_index}    timeout=${300}
# 
# [1]CB008021-5G-A_01_PM_Counters_Disabled
#     [Documentation]    The purpose of this test is to verify pm counters stop collecting when feature disable
#     [setup]    robot_common_operations.Common Case Setup
#     Ue attach and Make traffic for TL    direction=ul
#     Sleep to wait for counter generate    interval=${period}
#     ${avg_counter_value}    ${max_counter_value}    Get PM counter avg value    interval=${period}
#     Should Not Be Equal    ${avg_counter_value}    ${0}
#     Should Not Be Equal    ${max_counter_value}    ${0}
#     COAM Update several parameters via rest api    parameters_to_update_via_api=${PARAMETERS_ULRIP_DISABLE}
#     ...                                            connection=${gnb_undertest_connection}
#     ...                                            timeout=${wait_parameter_update_time}
#     Wait Until Keyword Succeeds    10min    20s    COAM Check GNB cell on air    connection=${gnb_undertest_connection}
#     Sleep to wait for counter generate    interval=${period}    is_add_one_period=True
#     ${avg_counter_value}    ${max_counter_value}    Get PM counter avg value    interval=${period}
#     Should Be Equal    ${avg_counter_value}    ${0}
#     Should Be Equal    ${max_counter_value}    ${0}
#     [teardown]    Run Keywords    Stop traffic and Detach UE for TL
# 
# [1]CB008021-5G-A_06_PM_Counters_Enabled_With_PRACH_PUCCH_F1
#     [Documentation]    The purpose of this test is to verify pm counters can collect
#     ...                correct interference value of all uplink channel in long pucch mode
#     [setup]    Run Keywords    robot_common_operations.Common Case Setup
#     ...                 AND    COAM Update several parameters via rest api
#     ...                        parameters_to_update_via_api=${PARAMETERS_ULRIP_ENABLE_WITH_PRACH_PUCCH_F1}
#     ...                        connection=${gnb_undertest_connection}
#     ...                        timeout=${wait_parameter_update_time}
#     ...                 AND    Wait Until Keyword Succeeds    10min    20s    COAM Check GNB cell on air
#     ...                        connection=${gnb_undertest_connection}
#     Ue attach and Make traffic for TL    direction=ul
#     Sleep to wait for counter generate    interval=${period}
#     ${avg_counter_value_begin}    ${max_counter_value_begin}    Get PM counter avg value    interval=${period}
#     Ue attach and Make traffic for TL    throughput=${throughput_noise}    tl_index=${tl_noise_index}    direction=ul
#     Sleep to wait for counter generate    interval=${period}    is_add_one_period=True
#     ${avg_counter_value_end}    ${max_counter_value_end}    Get PM counter avg value    interval=${period}
#     Should Be True    ${avg_counter_value_begin} < ${avg_counter_value_end}
#     Should Be True    ${max_counter_value_begin} < ${max_counter_value_end}
#     Should Be True    ${avg_counter_value_begin} < ${max_counter_value_begin}
#     Should Be True    ${avg_counter_value_end} < ${max_counter_value_end}
#     [teardown]    Run Keywords    Stop traffic and Detach UE for TL    direction=ul    tl_index=${tl_noise_index}
#     ...                    AND    Stop traffic and Detach UE for TL
# 
# [1]CB008021-5G-A_11_Verification_PM_Counters_for_Ghost_Preambles_which_Lead_to_DTX_or_DTXes
#     [Documentation]    The purpose of this test is to verify pm counters can collect
#     ...                correct interference value of PRACH and PUSCH channel in DTX scenario
#     [setup]    robot_common_operations.Common Case Setup
#     COAM Update several parameters via rest api
#     ...    parameters_to_update_via_api=${PARAMETERS_TRIGGER_DTX}
#     ...    connection=${gnb_undertest_connection}
#     ...    timeout=${wait_parameter_update_time}
#     Wait Until Keyword Succeeds    10min    20s    COAM Check GNB cell on air    connection=${gnb_undertest_connection}
#     Sleep to wait for counter generate    interval=${period}    is_add_one_period=True
#     ${avg_counter_value}    ${max_counter_value}    Get PM counter avg value    interval=${period}
#     ...                                                                     avg_counter_list=${AVG_DTX_COUNTER_LIST}
#     ...                                                                     max_counter_list=${MAX_DTX_COUNTER_LIST}
#     Should Not Be Equal    ${avg_counter_value}    ${0}
#     Should Not Be Equal    ${max_counter_value}    ${0}
#     COAM Update several parameters via rest api
#     ...    parameters_to_update_via_api=${PARAMETERS_RECOVERY_FOR_DTX_CASE}
#     ...    connection=${gnb_undertest_connection}
#     ...    timeout=${wait_parameter_update_time}
#     Wait Until Keyword Succeeds    10min    20s    COAM Check GNB cell on air    connection=${gnb_undertest_connection}
# 
# [1]CB008021-5G-A_13_Verification_PM_Counters_for_Different_Interference_Locations
#     [Documentation]    The purpose of this test is to verify pm counters can
#     ...                be different in different interference level zoon
#     [setup]    Run Keywords    robot_common_operations.Common Case Setup
#     ...                 AND    Ue attach and Make traffic for TL    direction=ul
#     Ue attach and Make traffic for TL    throughput=${throughput_noise}    tl_index=${tl_noise_index}    direction=ul
#     Sleep to wait for counter generate    interval=${period}    is_add_one_period=True
#     Stop traffic and Detach UE for TL    tl_index=${tl_noise_index}
#     ${avg_counter_value}    ${max_counter_value}    Get PM counter avg value    interval=${period}
#     ${avg_whole_bw_overlap}    Set Variable    ${avg_counter_value}
#     ${max_whole_bw_overlap}    Set Variable    ${max_counter_value}
# 
#     COAM Update several parameters via rest api
#     ...    parameters_to_update_via_api=${PARAMETERS_MOVE_NOISE_NRARFCN_HALF}
#     ...    connection=${gnb_noise_connection}
#     ...    timeout=${wait_parameter_update_time}
#     Wait Until Keyword Succeeds    10min    20s    COAM Check GNB cell on air    connection=${gnb_noise_connection}
#     Ue attach and Make traffic for TL    throughput=${throughput_noise}    tl_index=${tl_noise_index}    direction=ul
#     Sleep to wait for counter generate    interval=${period}    is_add_one_period=True
#     Stop traffic and Detach UE for TL    tl_index=${tl_noise_index}
#     ${avg_counter_value}    ${max_counter_value}    Get PM counter avg value    interval=${period}
#     ${avg_half_bw_overlap}    Set Variable    ${avg_counter_value}
#     ${max_half_bw_overlap}    Set Variable    ${max_counter_value}
# 
#     Should Be True    ${avg_half_bw_overlap}<${avg_whole_bw_overlap}
#     Should Be True    ${max_half_bw_overlap}<${max_whole_bw_overlap}
#     [teardown]    Run Keywords    Stop traffic and Detach UE for TL
#     ...                    AND    COAM Update several parameters via rest api
#     ...                           parameters_to_update_via_api=${PARAMETERS_RECOVERY_NOISE_NRARFCN}
#     ...                           timeout=${wait_parameter_update_time}
#     ...                           connection=${gnb_noise_connection}
#     ...                    AND    Wait Until Keyword Succeeds    10min    20s    COAM Check GNB cell on air
#     ...                           connection=${gnb_noise_connection}
# 
# [1]CB008021-5G-A_02_PM_Counters_Enabled_Without_PRACH_PUCCH_F1
#     [Documentation]    The purpose of this test is to verify pm counters can collect
#     ...                correct interference value of all uplink channel in short pucch mode
#     [setup]    robot_common_operations.Common Case Setup
#     ${short_pucch_scf_path}    Get SCF path as stream
#     log to console    ${short_pucch_scf_path}
#     COAM Commission with scf file    scf_file_path=${short_pucch_scf_path}    connection=${gnb_undertest_connection}
#     Wait Until Keyword Succeeds    10min    20s    COAM Check GNB cell on air    connection=${gnb_undertest_connection}
#     Sleep to wait for counter generate    interval=${period}
#     Ue attach and Make traffic for TL    direction=ul
#     Sleep to wait for counter generate    interval=${period}
#     ${avg_value_begin}    ${max_value_begin}    Get PM counter avg value    interval=${period}
#     Ue attach and Make traffic for TL    throughput=${throughput_noise}    tl_index=${tl_noise_index}    direction=ul
#     Sleep to wait for counter generate    interval=${period}    is_add_one_period=True
#     ${avg_value_end}    ${max_value_end}    Get PM counter avg value    interval=${period}
#     Should Be True    ${avg_value_begin} < ${avg_value_end}
#     Should Be True    ${max_value_begin} < ${max_value_end}
#     Should Be True    ${avg_value_begin} < ${max_value_begin}
#     Should Be True    ${avg_value_end} < ${max_value_end}
#     [teardown]    Run Keywords    Stop traffic and Detach UE for TL    direction=ul    tl_index=${tl_noise_index}
#     ...                    AND    Stop traffic and Detach UE for TL
# 
# [1]CB008021-5G-A_09_Verification_PM_Counters_for_Scheduled_and_Non-scheduled_PRB_values
#     [Documentation]    The purpose of this test is to verify pm counters has no value when PRBs are not scheduled
#     [setup]    robot_common_operations.Common Case Setup
#     Ue attach and Make traffic for TL    direction=ul
#     Sleep to wait for counter generate    interval=${period}
#     ${avg_counter_value}    ${max_counter_value}    Get PM counter avg value    interval=${period}
#     Should Not Be Equal    ${avg_counter_value}    ${0}
#     Should Not Be Equal    ${max_counter_value}    ${0}
#     Stop traffic and Detach UE for TL
#     Sleep to wait for counter generate    interval=${period}    is_add_one_period=True
#     ${avg_counter_value}    ${max_counter_value}    Get PM counter avg value    interval=${period}
#     Should Be Equal    ${avg_counter_value}    ${0}
#     Should Be Equal    ${max_counter_value}    ${0}
