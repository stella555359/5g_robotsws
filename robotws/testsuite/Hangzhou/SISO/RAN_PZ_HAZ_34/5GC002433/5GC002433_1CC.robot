*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         600 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Cell_OnAir_with_tiltOffset_value.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Link_Diagnostic_and_Monitoring.robot
# Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource    ${BASIC_PATH_5G}/General_Power_Consumption_and_Power_Saving_percentage_measured_in_Idle_Load.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
# Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
# Resource    ${BASIC_PATH_5G}/5GC000561/PTP_Failure_configuration_with_PTP_only.robot
# Resource    ${BASIC_PATH_5G}/Snapshot_Full_level_showing_reason_for_a_failure_after_radio_has_been_re-started_made2.robot

Documentation
...    Author:tingting zhong
...    contact:tingting.zhong@nokia-sbell.com
...    squad group:SG_04
...    Feature 5GC002433 in trunk program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEQQ_ENB
...   PY310

*** Test Cases ***
[1]5GC002433_EB_01_AQQY_5GC000430-B_02_03_Power_Consumption_and_Power_Saving_percentage_measured_in_Idle_Load
    [Tags]    CRT_22R4    CRT_22R3    CRT_TRUNK    RF50    1S-1CC-8D-4U_CHT
    General_Power_Consumption_and_Power_Saving_percentage_measured_in_Idle_Load

# # TL581 1S-1CC-8D-4U
# [1]5GC002433_EP_01_AQQY_5GC001991_01_07_Cell_OnAir_with_tiltOffset_value
#     General_SiSo_Cell_OnAir_with_tiltOffset_value    frame_structure=1208_GP1_A1    prach_index=98
#     ...    basicBeamSet=beamSet_2    numberOfTransmittedSsBlocks=2 beams
#
# [1]5GC002433_EJ_01_AQQY_Link_Diagnostic_monitoring
#     General_SiSo_Link_Diagnostic_and_Monitoring
#
# [1]5GC002433_BB_02_AQQY_L3call_with_chbw_20Mhz_NSA
#     General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1208_GP1_A1    prach_index=160
#
# [1]5GC002433_BF_01_AQQY_L3call_with_chbw_30Mhz
#     General_SiSo_Peak_with_Given_Information    band=30    frame_structure=1116_0ms_GP2_B7    prach_index=9
#
# [1]5GC002433_BJ_01_AQQY_L3call_with_chbw_70Mhz
#     General_SiSo_Peak_with_Given_Information    band=70    frame_structure=1116_0ms_GP1_A8    prach_index=195
#     ...    basicBeamSet=beamSet_4    beamset=4 beams
#
# [1]5GC002433_DB_02_AQQY_General_SiSo_E2E_system_setup_with_data_transfer_8DL4UL
#     [Tags]    1S-1CC-4D-4U    CRT_22R4    CRT_22R3    CRT_TRUNK
#     General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1070_GP1_A3    prach_index=17
#
# [1]5GC002433_AC_03_AQQY_General_SiSo_RU_lock_and_unlock_4x4_BFC
#     General_SiSo_RU_lock_unlock
#
# [1]5GC002433_AE_09_AQQY_General_SiSo_Cell_block_and_unblock_4x4_BFC
#     ${fault_list}    Create List    49
#     Allowed Watchdog additional alarms    fault_list=${fault_list}
#     E2E_SiSo_Cell_block_and_unblock_gNB
#
# [1][1.0] 5GC002433_EE_01_AQQY_PTP_Failure_configuration_with_PTP_only
#     ${fault_list}    Create List    16    4298    1899
#     Allowed Watchdog additional alarms    fault_list=${fault_list}
#     PTP_Failure_configuration_with_PTP_only
#
# [1]5GC002433_EQ_02_AQQY_Snapshot_Full_level_showing_reason_for_a_failure_after_radio_has_been_re-started
#     [Tags]    CRT_22R4    CRT_22R3    CRT_TRUNK
#     Snapshot_Full_level_showing_reason_for_a_failure_after_radio_has_been_re-started_made2
#
# [1]5GC002433_AQQY_call_with_data_transfer_1UE
#    ${cell_list}  create list  ${1}
#    Get UE From Init File and Make call  cell_list=${cell_list}  with_peak=${True}  duration=${300}