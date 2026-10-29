# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         100 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
# 
# Documentation
# ...    Author: zhihao shi
# ...    Contact: zhihao.shi@nokia-sbell.com
# ...    squad group:SG_04
# ...    Feature 5GC002367-B in 5G20B program
# 
# Force Tags            5G_RAN_TDD    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEQY
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1][1.0] 5GC002367_B_AEQY_eCPRI_General_SiSo_E2E_system_setup_with_data_transfer_conducted_100m_Fiber_80MHz
#     [Tags]    CRT_TRUNK    SBTS00    master_classicalbts_all    CRT_UTE
#     General_SiSo_Peak_with_Given_Information    band=80    frame_structure=1116_3ms_GP1_A5
#     ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}
# 
# #[1][1.0] 5GC002367_B_AEQY_eCPRI_General_SiSo_E2E_system_setup_with_data_transfer_conducted_100m_Fiber_20MHz
# #    General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1116_0ms_GP2_A7
# #
# #[1][1.0] 5GC002367_B_AEQY_eCPRI_General_SiSo_E2E_system_setup_with_data_transfer_conducted_100m_Fiber_40MHz
# #    General_SiSo_Peak_with_Given_Information    band=40    frame_structure=1208_GP1_A1
# #
# #[1][1.0] 5GC002367_B_AEQY_eCPRI_General_SiSo_E2E_system_setup_with_data_transfer_conducted_100m_Fiber_60MHz
# #    General_SiSo_Peak_with_Given_Information    band=60    frame_structure=1116_3ms_GP1_B5
# #
# #[1][1.0] 5GC002367_B_AEQY_eCpri_Configurable_TDD_Frame_Structure_1208-A1_beamset2_90_100M
# #    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1    prach_index=157
# #
# #[1][1.0] 5GC002367_B_AEQY_eCpri_5GC001991_FGCR-6469_SCF parameter tiltOffset migration check
# #    General_SiSo_SCF_parameter_tiltOffset_migration_check    basicBeamSet=beamSet_6_2
# #    ...    numberOfTransmittedSsBlocks=8 beams    tiltOffset=${0}
# #
# #[1][1.0] 5GC002367_B_AEQY_eCpri_5GC001991_FGCR-6469_Fault 4598 EFaultId_TiltOffsetOutOfRangeAl raise
# #    General_SiSo_Fault_4598_EFaultId_TiltOffsetOutOfRangeAl_raise    basicBeamSet=beamSet_5_3
# #    ...    numberOfTransmittedSsBlocks=8 beams    tiltOffset=${5}
# #
# #[1][1.0] 5GC002367_B_AEQY_eCpri_5GC001991_FGCR-6469_Cell locked when change tiltOffset parameter
# #    General_SiSo_Cell_locked_when_change_tiltOffset_parameter    basicBeamSet=beamSet_5_3
# #    ...    numberOfTransmittedSsBlocks=8 beams    tiltOffset=${-3}
# #
# #[1][1.0] 5GC002367_B_AEQY_eCpri_5GC001991_FGCR-6469_Cell OnAir with tiltOffset value
# #    General_SiSo_Cell_OnAir_with_tiltOffset_value    basicBeamSet=beamSet_6
# #    ...    numberOfTransmittedSsBlocks=6 beams    tiltOffset=${3}
# 
# *** Keywords ***
