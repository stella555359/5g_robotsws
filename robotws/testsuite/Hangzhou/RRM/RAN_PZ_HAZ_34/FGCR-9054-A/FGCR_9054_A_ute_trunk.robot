# *** Settings ***
# Documentation
# ...   author: Eric Guo
# ...   squad group: SG_06
# ...   Feature FGCR-9054
# Suite Setup    1700 Suite SetUp
# Suite Teardown    1700 Suite TearDown
# Force Tags            5G_RAN_TDD    STATE_SW_UPLOADED    master_classicalbts_all    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_2xAZQH
# ...    PY36
# ...           CRT_UTE    SBTS00    RAN_5G    RAN_5G_TDD
# Resource    Resource/FGCR_9054_common_kwywords.robot
# 
# *** Test Cases ***
# #[1]CNI_61418_A_01_2x2_open_loop_controlling_L1_RD_parameters_removal
# #    [Timeout]    45m
# #    [Setup]    1700 Case SetUp
# #    CNI_61418_A_01_2x2_open_loop_controlling_L1_RD_parameters_removal
# #    [Teardown]    Run Keyword And Ignore Error    1700 Case TearDown
# #
# #[1]FGCR_9054_A_05_dynamic_open_loop_precoding_parameter
# #    [Timeout]    90m
# #    [Setup]    1700 Case SetUp
# #    FGCR_9054_A_05_dynamic_open_loop_precoding_parameter
# #    [Teardown]    Run Keyword And Ignore Error    9054 Case Teardown
