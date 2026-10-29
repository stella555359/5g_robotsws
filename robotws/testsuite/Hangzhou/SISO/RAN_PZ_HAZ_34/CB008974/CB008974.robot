# *** Settings ***
# Suite Setup           SISO 8712 Suite Setup
# Suite Teardown       SISO 8712 Suite Teardown
# Test Setup           SISO 8712 Test Setup
# Test Teardown        SISO 8712 Test Teardown
# Test Timeout         600 min
# 
# Documentation
# ...    Author:Frank Luo
# ...    contact:frank.s.luo@nokia-sbell.com
# ...    squad group:SG_01
# ...    Feature CB008445 in 5G22R4 program
# 
# Force Tags            5G_RAN    5G_RAN_TDD    STATE_SW_UPLOADED  SBTS00
# 
# Resource  Resource/CB008974_Resource.robot
# 
# *** Variables ***
# 
# *** Test Cases ***
# TC.Manual_SiSo_SM_RF_Module_lock_unlock
#     [Tags]     Mytest
#     [Timeout]  60min
#     CommonCase.Manual_SiSo_SM_RF_Module_lock_unlock   scf_file=${CFGFILE_PATH}/${casescf}
# 
# TC.Manual_SiSo_SM_RF_Module_lock_unlock_2cc_100m
#     [Tags]     Mytest
#     [Timeout]  60min
#     CommonCase.Manual_SiSo_SM_RF_Module_lock_unlock    scf_file=${CFGFILE_PATH}/${casescf_2cc_100m}
# 
# TC.Manual_SiSo_SM_NR_RAT_reset
#     [Tags]
#     [Timeout]  60min
#     CommonCase.Manual_SiSo_SM_NR_RAT_reset   scf_file=${CFGFILE_PATH}/${casescf}
# 
# #TC.Manual_SiSo_SM_NR_RAT_reset_2cc_20m
# #    [Tags]
# #    [Timeout]  60min
# #    CommonCase.Manual_SiSo_SM_NR_RAT_reset   scf_file=${CFGFILE_PATH}/${casescf_2cc_20m}
# 
# TC.Manual_SiSo_SM_NR_RAT_reset_2cc_100m
#     [Tags]
#     [Timeout]  60min
#     CommonCase.Manual_SiSo_SM_NR_RAT_reset   scf_file=${CFGFILE_PATH}/${casescf_2cc_100m}
# 
# TC.Manual_SiSo_CM_Commissioning_Configuration_reset
#     [Tags]    NR
#     [Timeout]  60min
#     CommonCase.Manual_SiSo_CM_Commissioning_Configuration_reset   scf_file=${CFGFILE_PATH}/${casescf}
# 
# #TC.Manual_SiSo_CM_Commissioning_Configuration_reset_2cc_20m
# #    [Tags]    NR
# #    [Timeout]  60min
# #    CommonCase.Manual_SiSo_CM_Commissioning_Configuration_reset   scf_file=${CFGFILE_PATH}/${casescf_2cc_20m}
# 
# TC.Manual_SiSo_CM_Commissioning_Configuration_reset_2cc_100m
#     [Tags]    NR
#     [Timeout]  60min
#     CommonCase.Manual_SiSo_CM_Commissioning_Configuration_reset   scf_file=${CFGFILE_PATH}/${casescf_2cc_100m}
# 
# TC.General_SiSo_Static_HW_Capabilities_Validation_001
#     [Tags]    NR
#     [Timeout]  60min
#     CommonCase.General_SiSo_Static_HW_Capabilities_Validation_001
# 
# TC_LTE.Manual_SiSo_CM_Recommissioning
#     [Tags]    LTE
#     [Timeout]  60min
#     CommonCase.Manual_SiSo_CM_Recommissioning   scf_file=${CFGFILE_PATH}/${casescf}
# 
# #TC_LTE.Manual_SiSo_CM_Recommissioning_2cc_20m
# #    [Tags]    LTE
# #    [Timeout]  60min
# #    CommonCase.Manual_SiSo_CM_Recommissioning   scf_file=${CFGFILE_PATH}/${casescf_2cc_20m}
# 
# TC_LTE.Manual_SiSo_CM_Recommissioning_2cc_100m
#     [Tags]    LTE
#     [Timeout]  60min
#     CommonCase.Manual_SiSo_CM_Recommissioning   scf_file=${CFGFILE_PATH}/${casescf_2cc_100m}
# 
# [1]Peak throughput with DL 256QAM Modulation on different bandwidth_256QAM_100M
#     [Tags]
#     [Timeout]  60min
#     TC.Peak throughput with DL 256QAM Modulation on different bandwidth    TCID=TP_256QAM_100M   ul=150   dl=1000
# 
# 
# [1]Peak throughput with UL 256QAM Modulation on different bandwidth_256QAM_100M
#     [Tags]
#     [Timeout]  60min
#     TC.Peak throughput with UL 256QAM Modulation on different bandwidth    TCID=TP_256QAM_100M   ul=150   dl=1000
# 
# [1]Peak throughput with DL 256QAM Modulation on different bandwidth_256QAM_40M
#     [Tags]
#     [Timeout]  60min
#     TC.Peak throughput with DL 256QAM Modulation on different bandwidth    TCID=TP_256QAM_40M   ul=38   dl=380
# 
# 
# [1]Peak throughput with UL 256QAM Modulation on different bandwidth_256QAM_40M
#     [Tags]
#     [Timeout]  60min
#     TC.Peak throughput with UL 256QAM Modulation on different bandwidth    TCID=TP_256QAM_40M   ul=50   dl=380
# 
# 
# 
# ######################################################################################################
# #TC.Manual_SiSo_SM_LTE_cell_lock_unlock_(administrative_state_change)_from_GUI_1CC
# #    [Tags]
# #    [Timeout]  60min
# #    CommonCase.Manual_SiSo_SM_LTE_cell_lock_unlock_(administrative_state_change)_from_GUI_1CC
# #
# #TC.General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
# #    [Tags]
# #    [Timeout]  60min
# #    CommonCase.General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
# #
# #TC.General_SiSo_Cell_block_and_unblock
# #    [Tags]
# #    [Timeout]  60min
# #    CommonCase.General_SiSo_Cell_block_and_unblock
# #
# #TC.Manual_SiSo_SM_BTS_Site_Reset
# #    [Tags]
# #    [Timeout]  60min
# #    CommonCase.Manual_SiSo_SM_BTS_Site_Reset
# #
# #TC.General_SiSo_RU_module_reset_from_GUI
# #    [Tags]
# #    [Timeout]  60min
# #    CommonCase.General_SiSo_RU_module_reset_from_GUI
# #
# 
# #
# #TC.Manual_SiSo_STARTUP_BTS_Power_Reset
# #    [Tags]
# #    [Timeout]  60min
# #    CommonCase.Manual_SiSo_STARTUP_BTS_Power_Reset
# #
# #TC.BS-RF__LTE_cell_graceful_shutdown_from_WebEm
# #    [Tags]
# #    [Timeout]  60min
# #    CommonCase.BS-RF__LTE_cell_graceful_shutdown_from_WebEm
# #
# 
# 
# #TC.BS-RF__LTE_Transmitted_carrier_power_min_max_allowed_power
# #    [Tags]    NR
# #    [Timeout]  60min
# #    CommonCase.BS-RF__LTE_Transmitted_carrier_power_min_max_allowed_power
# #
# #TC.General_SiSo_RU_capabilities_advertisement_towards_OAM
# #    [Tags]    NR
# #    [Timeout]  60min
# #    CommonCase.General_SiSo_RU_capabilities_advertisement_towards_OAM
# #
# #TC.General_SiSo_Snapshot_Showing_Radio_Last_Reset_Cause
# #    [Tags]    NR
# #    [Timeout]  60min
# #    CommonCase.General_SiSo_Snapshot_Showing_Radio_Last_Reset_Cause
# #    #KW.RestartSAS
# #
# #TC.General_SiSo_Snapshot_Showing_RU_Logs_For_a_Failure_After_Radio_Reset
# #    [Tags]    NR     CRT
# #    [Timeout]  60min
# #    CommonCase.General_SiSo_Snapshot_Showing_RU_Logs_For_a_Failure_After_Radio_Reset
# #
# 
# 
# #TC.Initiate_RF_Statistics_diagnostic_test_withoutL3call
# #    [Tags]    NR
# #    [Timeout]  60min
# #    CommonCase.Initiate_RF_Statistics_diagnostic_test_withoutL3call
# #
# #TC.LTE_Verify_CBSD_registration_From_TS1_to_TS2
# #    [Tags]    NR
# #    [Timeout]  60min
# #    CommonCase.LTE_Verify_CBSD_registration_From_TS1_to_TS2
# #
# #TC.LTE_Verify_the_AirScale_CBRS_L3_call_successfully_with_CBSD_TS2
# #    [Tags]    NR
# #    [Timeout]  60min
# #    CommonCase.LTE_Verify_the_AirScale_CBRS_L3_call_successfully_with_CBSD_TS2
# #
# #TC.Manual_SiSo_CM_Recommissioning
# #    [Tags]    NR
# #    [Timeout]  60min
# #    CommonCase.Manual_SiSo_CM_Recommissioning
# #
# #TC_LTE.Manual_SiSo_CM_Commissioning_Configuration_reset
# #    [Tags]    LTE    TEST
# #    [Timeout]  60min
# #    CommonCase.Manual_SiSo_CM_Commissioning_Configuration_reset
# #    ...    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}
# #
# #SWM_Software_Upgrade
# #    [Tags]    LTE    TEST
# #    [Timeout]  120min
# #    TC.S[1][1.0] Manual_SiSo_CM_RecommissioningWM_Software_Upgrade
# #
# #TC_LTE.BS-RF__LTE_Transmitted_carrier_power_min_max_allowed_power
# #    [Tags]    LTE
# #    [Timeout]  60min
# #    CommonCase.BS-RF__LTE_Transmitted_carrier_power_min_max_allowed_power
# #    ...    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}
# #    ...    celltype=LTE
# #
# #TC_LTE.General_SiSo_RU_capabilities_advertisement_towards_OAM
# #    [Tags]    LTE
# #    [Timeout]  60min
# #    CommonCase.General_SiSo_RU_capabilities_advertisement_towards_OAM
# #    ...    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}
# #
# #TC_LTE.General_SiSo_Snapshot_Showing_Radio_Last_Reset_Cause
# #    [Tags]    LTE
# #    [Timeout]  60min
# #    CommonCase.General_SiSo_Snapshot_Showing_Radio_Last_Reset_Cause
# #    ...    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}
# #    #KW.RestartSAS
# #
# #TC_LTE.General_SiSo_Static_HW_Capabilities_Validation_001
# #    [Tags]    LTE
# #    [Timeout]  60min
# #    CommonCase.General_SiSo_Static_HW_Capabilities_Validation_001
# #    ...    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}
# #
# #TC_LTE.Initiate_RF_Statistics_diagnostic_test_withoutL3call
# #    [Tags]    LTE
# #    [Timeout]  60min
# #    CommonCase.Initiate_RF_Statistics_diagnostic_test_withoutL3call
# #    ...    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}
# #    ...    celltype=LTE
# #
# #TC_LTE.LTE_Verify_CBSD_registration_From_TS1_to_TS2
# #    [Tags]    LTE
# #    [Timeout]  60min
# #    CommonCase.LTE_Verify_CBSD_registration_From_TS1_to_TS2
# #    ...    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}
# #    ...    celltype=LTE
# #
# #TC_LTE.LTE_Verify_the_AirScale_CBRS_L3_call_successfully_with_CBSD_TS2
# #    [Tags]    LTE
# #    [Timeout]  60min
# #    CommonCase.LTE_Verify_the_AirScale_CBRS_L3_call_successfully_with_CBSD_TS2
# #    ...    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}
# #    ...    celltype=LTE
# #
# 
# 
# #TC_LTE.General_SiSo_Snapshot_Showing_RU_Logs_For_a_Failure_After_Radio_Reset
# #    [Tags]
# #    [Timeout]  60min
# #    CommonCase.General_SiSo_Snapshot_Showing_RU_Logs_For_a_Failure_After_Radio_Reset
# #    ...    scf=${CFGFILE_PATH}/${TL_BASE_SCF_LTE}
# 
# 
