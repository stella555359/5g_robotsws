# *** Settings ***
# Suite Setup    run keywords    SISO Coam Suite Setup    AND    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
# #Suite Setup          AENB CPRI Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
# Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
# Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_with_recovery.robot
# Resource    ./Resources/CB007833-td-cpri_Keywords.robot
# Resource    ./Resources/CB006502_Keywords.robot
# Library    ./TestData/variables_CB007833.py
# Variables    ./TestData/variables_6502_60M.py
# 
# Documentation
# ...    Author: Melinda
# ...    Contact: meinda.gao@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB006502 made, Feature CB007833-5G-A-td_cpri_Amber
# 
# Force Tags    RAN_5G_TDD    5G_RAN_TDD    master_classicalbts_all    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED
# ...    PY36
# ...    CLOUD_5G_CLASSICAL_QC_ASIKL_ABILB1_AENB_ENB    SBTS23R3
# 
# 
# *** Variables ***
# 
# *** Test Cases ***
# 
# [1]CB006502_AENB_General_SiSo_Cell_lock_and_unlock
#     [Tags]    CRT_20B    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
#     reboot_ue_except_askey_and_cpe
#     General_SiSo_Cell_lock_and_unlock
# 
# [1]CB006502_AENB_General_SiSo_E2E_system_setup_with_data_transfer_conducted_MCS27_30km_60MHz
#     [Tags]    CRT_20B    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
#     reboot_ue_except_askey_and_cpe
#     General_SiSo_Peak_with_Given_Information    band=60    frame_structure=1116_0ms_GP2_A7    iperf_type=via_command    loop_times=${3}
# 
# [1]CB006502_AENB_General_SiSo_RF_alarms_with_recovery
#     [Tags]    CRT_20B    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
#     General_SiSo_RF_alarms_with_recovery
# 
# *** Keywords ***