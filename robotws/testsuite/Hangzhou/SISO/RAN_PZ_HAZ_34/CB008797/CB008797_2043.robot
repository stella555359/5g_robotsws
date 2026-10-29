# # @Time    : 2022/2/18 13:47
# # @Author  : Jian.1.Chen
# # @Email   : jian.1.chen@nokia-sbell.com
# # @File    : CB008797_2043.robot
# # @Software: PyCharm
# # @Doc     : Some Description
# *** Settings ***
# Documentation
# ...    author: Chen Jian
# ...    contact: jian.1.chen@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_3_SG05
# ...    Feature CB008797-SR-B-B32
# 
# Resource    CB008797_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup          Run Keywords    robot_common_operations.Common Suite Setup
# ...    AND     SISO Coam Suite Setup
# Suite Teardown       Run Keywords    robot_common_operations.Common Suite Teardown
# ...    AND     SISO Coam Suite Teardown
# Test Setup           robot_common_operations.Common Case Setup 
# Test Teardown        robot_common_operations.Common Case Teardown
# Force Tags        5G_SISO    5G_RAN_TDD    CRT_TRUNK    CRT_22R3    CRT_22R4    CRT_23R1    CRT_23R2
# 
# *** Variables ***
# ${if_commissioning}    True
# # case008 variables
# ${SSH_MAX_AUTH_ATTEMPTS_VALUE}    ${4}
# &{BAND_RF_TEST_THRESHOLDS_DICT}    bandClass=${1}    totalRFPowerHighThreshold=${120}    totalRFPowerLowThreshold=${10}
# @{BAND_RF_TEST_THRESHOLDS_LIST}    &{BAND_RF_TEST_THRESHOLDS_DICT}
# # case115 variables
# @{L3_CALL_CELLS_INDEX}    5
# # case124 variables
# @{CASE124_L3_CALL_CELLS_INDEX}    5    21
# # case125 variables
# ${LOCAL_CELL_22R3}    NRCELL-5(cell1)
# ${LOCAL_CELL_AFTER_22R4}    NRCELL-5 (cell1)
# ${FRC_INDEX}    G-FR2-A1-2
# ${REPORT_TIME_INTERVAL}    1
# ${TEST_MODEL}    NR-FR2-TM1.1
# ${P_MAX}    14
# 
# *** Test Cases ***
# CB008797_B_114_NIDD_parameters_and_PDL_rule_verification_under_EQM_and_MNL
#     [Tags]    case114
#     "Step1" check the EQM/APEQM/CABINET/SMOD-prodCodePlanned
#     "Step2" check the EQM/APEQM/FHS-radioProtSearchOrder
#     "Step3" change radioProtSearchOrder to value 2:CPRI
#     "Step4" check the EQM/APEQM/RMOD-radioMasterDN
#     "Step5" check the MNL-productVariantPlanned
#     "Step6" change eCpriMasterStatisticsInterval to value 5min --- PDL verification should be passed
#     "Step7" check the MNL/MNLENT/SECADM-sshMaxAuthAttempts
#     "Step8" change sshMaxAuthAttempts to value 4 --- PDL verification should be passed
# 
# CB008797_B_115_NSA_TDD_mmW_eCPRI_ASIK_single_core_NR_RAT_reset_and_multiple_cells_block_unblock
#     [Tags]    case115
#     "Step1" All services within tested cell are verified
#     "Step2" NR RAT reset is triggered via ADMIN
#     "Step3" All services within tested cell are verified
#     "Step4" NR multiple cells block triggered from WebEM
#     "Step5" NR multiple cells unblock triggered from WebEM
#     "Step6" All services within tested cell are verified
# 
# CB008797_B_118_NSA_TDD_mmW_eCPRI_ASIK_dual_core_RF_diagonistic_monitoring_ and_SFP_monitoring
#     [Tags]    case118
#     "Step1" Run RF Diagnostic Test on Webem And Check
#     "Step2" Check SFP_R related Diagnostic data on Detailed Site View/Configuration Management
# 
# CB008797_B_119_NSA_TDD_mmW_eCPRI_ASIK_dual_core_exploratory_lock_x2_with_lock_cell
#     [Tags]    case119
#     "Step1" Lock all NR cells from both cores
#     "Step2" Set x2LinkLock value to lock
#     "Step3" Unlock NR cells from primary core
#     "Step4" Set x2LinkLock value to unlock
#     "Step5" Unlock remain NR cells from secondary core
#     "Step6" Make L3 call for one cell from each core
# 
# CB008797_B_120_General_SiSo_Auto_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     [Tags]    case120
#     "Step1" Check content of Radio Unit logs in snapshot
#     "Step2" Create new snapshot and cancel it during creation
#     "Step3" Check content of Radio Unit logs in snapshot with Most important log files option
# 
# CB008797_B_121_NSA_TDD_mmW_eCPRI_ASIK_dual_core_NIDD_PDL_Webem_online
#     [Tags]    case121
#     "Step1" check the MNL-productVariantPlanned
#     "Step2" create SMOD_EXT, set eutraTDDSupport to true, set nrcnOfChnBnd=1
#     "Step3" create object LCELC
#     "Step4" create productVariantPlanned to tetraBTS
# 
# CB008797_B_124_NSA_TDD_mmW_eCPRI_ASIK_dual_core_RF_lock_unlock_with_BTS_site_block_unblock
#     [Tags]    case124
#     "Step1" Lock all radios of both cores
#     "Step2" SBTS block is triggered from WebEM. Faults and states are checked
#     "Step3" SBTS unblock is triggered from WebEM. Faults and states are checked
#     "Step4" Unlock all radios of both cores
#     "Step5" Make L3 call for one cell from each core
# 
# CB008797_B_125_NSA_TDD_mmW_eCPRI_ASIK_dual_core_Test_Dedicated_State_Initiation_and_Exiting
#     [Tags]    case125
#     CI_interface.Common Suite Setup    gnb_index=0
#     "Step1" From webem select "reset to test dedicated state", click "Enable" button
#     "Step2" From Webem, select "TestModels", into UL or DL TestModels state
#     "Step3" From webem select "reset to test dedicated state",click "Disable" button
# 
# CB008797_B_126_NSA_TDD_mmW_eCPRI_ASIK_dual_core_Robustness_Online_Cell_addition_deletion
#     [Tags]    case126
#     CI_interface.Common Suite Setup    gnb_index=0
#     "Step1" Delete cells deployed on secondary core and activate plan
#     "Step2" Add cells deleted in step1 and activate plan
#     "Step3" All services within tested cell are verified
