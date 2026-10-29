# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# #Suite Teardown       SISO Coam Suite Teardown
# Suite Teardown     Run keywords    SISO Coam Suite Teardown    AND    Suite Teardown with SCF
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         100 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
# Resource    Resources/CB007378-keyword.robot
# 
# 
# Documentation
# ...    Author:shangyu.xu
# ...    contact:shangyu.xu@nokia-sbell.com
# ...    squad group:mmw_HZ_SG_03
# ...    Feature CB007378 in TRUNK program
# 
# Force Tags    CIT_22R4
# ...    PY36
# 
# *** Variables ***
# ${testline_name}    7_5_UTE5G402T920
# ${scf_file_path}    ${commissionings_path}/HGZ/${testline_name}
# ${scf_file}    SCF_TL920_ASIB_ABIN_3AZQG_20MHz_non_subsector_4D4U.xml
# 
# *** Test Cases ***
# [1]CB007378-C_01_TDD_SiSo_commission_without_Beamforming_4DL4UL_20M
#     [Tags]    CIT_22R4
#     Commissioning SCF And Check On Air    scf_path=${scf_file_path}/${scf_file}
#     Precondition    ChBw_except=20MHz
# 
# [1]CB007378-C_05_TDD_SiSo_Cell_lock_and_unlock_without_Beamforming_4DL4UL_60M
#     [Tags]    CIT_22R4
#     Precondition    ChBw_except=60MHz
#     General_SiSo_Cell_lock_and_unlock    with_call=${False}
# 
# [1]CB007378-C_06_TDD_SiSo_RU_lock_and_unlock_without_Beamforming_4DL4UL_70M
#     [Tags]    CIT_22R4
#     Precondition    ChBw_except=70 MHz
#     General_SiSo_RU_lock_unlock    with_call=${False}
# 
# 
# *** Keywords ***
