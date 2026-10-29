# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         200 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
# Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
# Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
# 
# Documentation
# ...    Author:zhihao shi
# ...    contact:zhihao.shi@nokia-sbell.com
# ...    squad group:SG_04
# ...    Feature 5GC002035-G in 5G21A program
# 
# Force Tags            5G_RAN    5G_RAN_TDD    STATE_GNB_COMMISSIONED    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEQY_ENB
# ...   PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1][1.0] 5GC002035-G-10_03_General_SiSo_RU_lock_unlock_with_BF
#     [Tags]    1S-2CC-4D-2U    CRT_22R4    CRT_TRUNK
#     General_SiSo_RU_lock_unlock
# 
# [1][1.0] 5GC002035-G-10_02_General_SiSo_Cell_block_and_unblock_with_BF
#     [Tags]    1S-2CC-4D-2U    CRT_TRUNK
#     ${fault_list}    Create List    49
#     Allowed Watchdog additional alarms    fault_list=${fault_list}
#     E2E_SiSo_Cell_block_and_unblock_gNB
# 
# [1][1.0] 5GC002035-G-10_04_General_SiSo_E2E_system_setup_with_data_transfer_conducted_with_BF_20+20Mhz
#     [Tags]    1S-2CC-4D-2U    CRT_TRUNK
#     ${status}    Run Keyword And Return Status     General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1116_3ms_GP1_A5
#     ...    ue_num_each_call=2    suite_name=${SUITE NAME}    test_name=${TEST NAME}
#     Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#     ${status2}    Run Keyword And Return Status     General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1116_3ms_GP1_A5
#     ...    cell_id=1    suite_name=${SUITE NAME}    test_name=${TEST NAME}
#     Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#     ${status3}    Run Keyword And Return Status     General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1116_3ms_GP1_A5
#     ...    cell_id=2    suite_name=${SUITE NAME}    test_name=${TEST NAME}
#     should be true    ${status} and ${status2} and ${status3}
# 
# [1][1.0] 5GC002035-G-10_11_General_SiSo_E2E_system_setup_with_data_transfer_conducted_with_BF_50+50Mhz
#     [Tags]    1S-2CC-4D-2U    CRT_TRUNK
#     ${status}    Run Keyword And Return Status     General_SiSo_Peak_with_Given_Information    band=50    frame_structure=1116_0ms_GP2_A7
#     ...    ue_num_each_call=2    suite_name=${SUITE NAME}    test_name=${TEST NAME}
#     Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#     ${status2}    Run Keyword And Return Status     General_SiSo_Peak_with_Given_Information    band=50    frame_structure=1116_0ms_GP2_A7
#     ...    cell_id=1    suite_name=${SUITE NAME}    test_name=${TEST NAME}
#     Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#     ${status3}    Run Keyword And Return Status     General_SiSo_Peak_with_Given_Information    band=50    frame_structure=1116_0ms_GP2_A7
#     ...    cell_id=1    suite_name=${SUITE NAME}    test_name=${TEST NAME}
#     should be true    ${status} and ${status2} and ${status3}
# 
# #[1][1.0] 5GC002035-G-10_10_General_SiSo_E2E_system_setup_with_data_transfer_conducted_with_BF_40+40Mhz
# #    [Tags]    1S-2CC-4D-2U
# #    ${status}    Run Keyword And Return Status     General_SiSo_Peak_with_Given_Information    band=40    frame_structure=1208_GP1_A1
# #    ...    ue_num_each_call=2
# #    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
# #    ${status2}    Run Keyword And Return Status     General_SiSo_Peak_with_Given_Information    band=40    frame_structure=1208_GP1_A1
# #    ...    cell_id=1
# #    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
# #    ${status3}    Run Keyword And Return Status     General_SiSo_Peak_with_Given_Information    band=40    frame_structure=1208_GP1_A1
# #    ...    cell_id=1
# #    should be true    ${status} and ${status2} and ${status3}
# #
# #[1][1.0] 5GC002035-G-10_01_General_SiSo_Commissioning_BTS_Template_Commissioning_with_BF
# #    General_SiSo_Commissioning_BTS_Template_Commissioning
# #
# #[1][1.0] 5GC002035-G-10_06_General_SiSo_Automatic_RAT_SW_upgrade_with_BF
# #    General_SiSo_Auto_Automatic_RAT_SW_upgrade
# #
# #[1][1.0] 5GC002035-G-10_05_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_BF
# #    [Tags]    stability
# #    [Timeout]    8h
# #    Set Log Level    INFO
# #    General_Stability_Test_Case    case_name=General_SiSo_Auto_BTS_site_reset    times=${20}    pass=${19}
# 
# *** Keywords ***
