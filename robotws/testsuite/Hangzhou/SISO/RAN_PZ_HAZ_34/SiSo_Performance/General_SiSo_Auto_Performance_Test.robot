# *** Settings ***
# Documentation     author: Jiang Wenwen
# ...               contact: wenwen.jiang@nokia-sbell.com
# ...               squad group: MMW_02
# Suite Setup       Test Suite Setup 
# Suite Teardown    Test Suite Teardown
# Force Tags        STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEUD_AEUB_ENB    SBTS00
# ...               RAN_5G    RAN_5G_TDD    PY39
# Resource          Resources/common_keywords.robot
# 
# 
# *** Variables ***
# ${reporting_time_interval}      1
# ${reception_slot}               1023
# ${exception_slot}               170
# ${ru_mode}                      NR_Only
# ${pucch_format}                 F0
# ${number_of_pucch_symbol}       1
# @{Beam_ID_pucch}                0
# ${prb_offset}                   0
# ${largest_prb_index}            0
# ${pucch_payload_content}        0
# ${download_dir}         /home/ute
# ${DU_addr}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
# ${WEBUI_USER}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBUI_PASSWORD}       ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${alias}                sbts
# ${log_dir}              /home/ute
# ${numPucchSymbol}               1
# ${num_payload_bit}              1
# @{Beam_ID_prach}                0
# ${prach_configuration_index}    38
# ${prach_root_sequence_index}    1
# ${prach_seq_type}               Unrestricted
# ${delay_pattern_duration}       0
# ${zero_correlation_zone_config}    0
# ${constant_offset}                 0
# ${pfa_target_prach_id}             P_None
# ${preamble_index}                  0
# ${accepted_timing_error}           100
# ${digital_output_rate}     Bitrate_115dot2K
# ${BB_selector}    0
# ${PRB_offset}    0
# ${test_type}    PUSCH
# @{Beam_ID}          0
# ${Digital_out_type}     SerialRs
# ${FRC_index}    G_FR2_A3_4
# ${ul_dmrs_mapping_type}    A
# ${timeout}    5
# 
# *** Test Cases ***
# [1][3.0] General_SiSo_Auto_PUCCH_Performance_Test
#     [Documentation]  The purpose of this Test Case is to automatically enter test mode and execute PUCCH performance test models. 
#     [Tags]    CRT_UTE
# 	[Setup]    robot_common_operations.Common Case Setup
#     API login
#     Start uplink Pucch test
#     Watch pucch test result
#     Verify result for pucch
#     [Teardown]    Case Teardown
# 
# [1][1.0] General_SiSo_Auto_PRACH_Performance_Test
#     [Documentation]  The purpose of this Test Case is to automatically enter test mode and execute PRACH performance test models. 
#     [Tags]    CRT_UTE
# 	[Setup]    robot_common_operations.Common Case Setup
#     API login
#     Start uplink Prach test
#     Watch prach test result
#     Verify result for prach
#     [Teardown]    Case Teardown
#     
# [1][1.0] General_SiSo_Auto_PUSCH_Performance_Test
#     [Documentation]  The purpose of this Test Case is to automatically enter test mode and execute PUSCH performance test models. 
#     [Tags]    CRT_UTE
# 	[Setup]    robot_common_operations.Common Case Setup
#     API login
#     Start pusch performance test
#     check pusch test result
#     Verify result for pusch
#     [Teardown]    Case Teardown
# 
# 
