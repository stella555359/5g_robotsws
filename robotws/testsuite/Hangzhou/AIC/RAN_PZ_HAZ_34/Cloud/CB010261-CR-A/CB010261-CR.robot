*** Settings ***
Suite Setup         Cloud Suite Setup
Suite Teardown      Cloud Suite Teardown
#Test Setup          Cloud Test Setup
#Test Teardown       Cloud Test Teardown
Test Timeout        4h

Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/cloud_analysis.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_Cloud.robot
Resource    ${BASIC_PATH_CLOUD}/Cloud_Setup_and_Teardown.robot
Resource    ${BASIC_PATH_CLOUD}/General_SiSo_RU_module_reset_from_GUI_Cloud.robot
Resource    ${BASIC_PATH_CLOUD}/Cloud_Manual_SiSo_SM_RF_Module_lock_unlock.robot
Resource    ${BASIC_PATH_CLOUD}/Cloud_Manual_SiSo_REC_Radio_Module_power_reset.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vcu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

#SISO_COMMON_BASIC_PATH = 'testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/'
#BASIC_PATH_5G = SISO_COMMON_BASIC_PATH + '5G'
#BASIC_PATH_LTE = SISO_COMMON_BASIC_PATH + 'LTE'
#BASIC_PATH_COMMON = SISO_COMMON_BASIC_PATH + 'Common'
#BASIC_PATH_CLOUD = SISO_COMMON_BASIC_PATH + 'Cloud'

Resource    Resources/CB010261_keywords.robot

Documentation
...    author: Yue 2. Liu
...    contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...
...    Feature CB010261_TDD_NR_configs_eCPRI_for_cloud_RAN_SmartNIC_-_RINLINE2 in 24R3-CR program which including:
...    CB010261-CR-A: Direct connection configuration for D-RAN
...    CB010261-CR-B: Switch fronthaul connection for D-RAN
...    CB010261-CR-D: Port CB010370 short/long buffer selection mechanism

...    Configuration:
...    CB010261-CR-A: CB010261-A configuration block #1/2/3
...    CB010261-CR-B: CB010261-B configuration block #1/2/3/4/5
...    CB010261-CR-D: CB010261-B configuration block #3 – B3

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    PY310    RF50

*** Test Cases ***
[1]3_CB010261-A_block #3–B1_General_SiSo_RU_module_reset_lock_unlock_from_GUI_and_REC_Radio_Module_power_reset
    [Tags]    3S-2CC-16D8U_CB010261-A-block3-B1    CRT_TRUNK
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    Cloud Test Setup
    log to console    \n*** Recommission with customized scf from case tags ***
    Run Keyword And Continue On Failure    Cloud Full Commission With Customized Scf
    log to console    \n*** checkpoint about RU module reset from GUI ***
    Run Keyword And Continue On Failure    General_SiSo_RU_module_reset_from_GUI
    ...                                    gnb_index=0    vdu_index=0    with_call=${False}
    log to console    \n*** checkpoint about RU module lock and unlock ***
    Run Keyword And Continue On Failure    Cloud_Manual_SiSo_SM_RF_Module_lock_unlock
    ...                                    gnb_index=0    vdu_index=0    with_call=${False}
    log to console    \n*** checkpoint about RU module power reset ***
    Run Keyword And Continue On Failure    Cloud_Manual_SiSo_REC_Radio_Module_power_reset
    ...                                    gnb_index=0    vdu_index=0    with_call=${False}
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    Cloud Test Teardown

[1]CB009140-5G_5_Antenna_TX_power_sleeping_cell_detected_snapshot_collection
    [Tags]    CRT_TRUNK
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    Cloud Test Setup
    log to console    \n*** Recommission with customized scf from case tags ***
    Run Keyword And Continue On Failure    Cloud Full Commission With Customized Scf
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    Cloud Test Teardown

[1]CB011159_SR_D_1_Verify_CellSetup_With_NR_1cc+1cc_8D8U_split_mode_64TRX
    [Tags]    CRT_TRUNK
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    Cloud Test Setup
    log to console    \n*** Recommission with customized scf from case tags ***
    Run Keyword And Continue On Failure    Cloud Full Commission With Customized Scf
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    Cloud Test Teardown

[1]CB010413-N_01_New_ SFN0_offset_management
    [Tags]    CRT_TRUNK
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    Cloud Test Setup
    log to console    \n*** Recommission with customized scf from case tags ***
    Run Keyword And Continue On Failure    Cloud Full Commission With Customized Scf
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    Cloud Test Teardown

[1]CB010411-CR-A1_3-CB008238-5G-E_02_04_Micro-DTX_optimized_scheduler_PM_counter_update_on_Cloud
    [Tags]    CRT_TRUNK
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    Cloud Test Setup
    log to console    \n*** Recommission with customized scf from case tags ***
    Run Keyword And Continue On Failure    Cloud Full Commission With Customized Scf
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    Cloud Test Teardown

[1]CB010655-B_support_NVM_updating_for_controlled_radio_reset
    [Tags]    CRT_TRUNK
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    Cloud Test Setup
    log to console    \n*** Recommission with customized scf from case tags ***
    Run Keyword And Continue On Failure    Cloud Full Commission With Customized Scf
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    Cloud Test Teardown

[1]DFE no TX Data fault activation_AEQY Amber SRM6 6.1
    [Tags]    CRT_TRUNK
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    Cloud Test Setup
    log to console    \n*** Recommission with customized scf from case tags ***
    Run Keyword And Continue On Failure    Cloud Full Commission With Customized Scf
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    Cloud Test Teardown

[1]DFE_Beamer link fault activation_AEQY Amber SRM6 6.1
    [Tags]    CRT_TRUNK
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    Cloud Test Setup
    log to console    \n*** Recommission with customized scf from case tags ***
    Run Keyword And Continue On Failure    Cloud Full Commission With Customized Scf
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    Cloud Test Teardown
