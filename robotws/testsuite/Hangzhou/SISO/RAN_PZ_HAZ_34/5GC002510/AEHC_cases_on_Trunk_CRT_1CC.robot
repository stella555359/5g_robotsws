# *** Settings ***
# Documentation      Author: xiaoxia.hao@nokia-sbell.com
# Suite Setup    702 Suite Setup For UTE
# Suite Teardown    702 Suite TearDown For UTE
# Force Tags            5G_RAN_TDD    master_classicalbts_all
# ...    PY39
# ...           CRT_UTE    5G_RAN    SBTS00    RAN_5G    RAN_5G_TDD
# Resource    Resources/5GC002510_case_step.robot
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002056_CFAM/Resources/5GC002056_case_common.robot
# 
# *** Variables ***
# ${cell_index}    ${1}
# ${ru_index}    ${1}
# @{swconfig_enable_rdNewTddCellSlotModel}    0x420062=1    #modify swconfig,enable_rdNewTddCellSlotModel of CB008940
# @{rdTddPoolingFeaturesEnable}    0x420068=1
# 
# *** Test Cases ***
# #[1]General_SiSo_Auto_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
# #    [Documentation]   Sub-feature:5GC002510-A
# #    [Timeout]    60m
# #    [Setup]    702 Case SetUp For UTE
# #    RRH_common_keyword.General SiSo Collect RFSW Logs From RU Into BTS Snapshot
# #    [Teardown]    702 Case TearDown For UTE
# 
# #[1]5GC002548_B_002_5GC000399_eCPRI_U-plane_Fast_C-plane_counters_ASIK
# #    [Documentation]    Sub-feature:5GC002548-BG,set miNrEcpriUpFCp=5 to trigger M55318 measurement enable
# #    [Timeout]    60m
# #    [Setup]    702 Case SetUp For UTE
# #    5GC002548_B_002_5GC000399_eCPRI_U-plane_Fast_C-plane_counters_ASIK
# #    [Teardown]    702 Case TearDown For UTE
# 
# #[1]5GC002510_A_04_SiSo_RF_module_reset_from_GUI_under_creation
# #    [Documentation]   Sub-feature:5GC002510-A,L3 call DL TP expect value is 5% bler
# #    [Timeout]    60m
# #    [Setup]    702 Case SetUp For UTE
# #    5GC002510_A_04_SiSo_RF_module_reset_from_GUI_under_creation
# #    [Teardown]    702 Case TearDown For UTE
# 
# #[1]5GC002548_B_006_5GC000399_eCPRI_FREERUN_state_handling_ASIB
# #    [Documentation]   Sub-feature:5GC002510-A,L3 call DL TP expect value is 5% bler
# #    ...               CHBW:60MHz
# #    [Timeout]    90m
# #    [Setup]    702 Case SetUp For UTE
# #    5GC002548_B_006_5GC000399_eCPRI_FREERUN_state_handling_ASIB
# #    [Teardown]    702 Case TearDown For UTE
# 
# #[1][1.0] 5GC002244-A_BF_enable_Refine_disable_Traffic_2SSB_4Rx
# #    [Documentation]
# #    ...    This test case is used to test 5GC002244 case.
# #    ...    CHBW:60MHz, Feature_ID:5GC002244-A, DL 4x4 MIMO, case used ASIB+ABIO, and not used 2244 config file
# #    [Timeout]    60m
# #    [Setup]    702 Case SetUp For UTE
# #    5GC002244-A_BF_enable_Refine_disable_Traffic_2SSB_4Rx
# #    [Teardown]    702 Case TearDown For UTE
# 
# #[1]5GC002510_A_05_SiSo_RF_module_power_reset
# #    [Documentation]
# #    ...    This test case is used to test 5GC002244 case.
# #    ...    CHBW:60MHz, Feature_ID:5GC002244-A, DL 4x4 MIMO
# #    [Timeout]    60m
# #    [Setup]    702 Case SetUp For UTE
# #    5GC002510_A_05_SiSo_RF_module_power_reset
# #    [Teardown]    702 Case TearDown For UTE
# #
# #[1]5GC002548_B_124_SiSo_E2E_system_setup_with_data_transfer_conducted_2510_A_256QAM_4Layer_100M_peak
# #    [Documentation]   Sub-feature:5GC002548-B
# #    ...               CHBW:100MHz
# #    [Timeout]    60m
# #    [Setup]  702 Case SetUp For UTE    update_param_name=${FRAME_TO_11160ms_100MHz_4Symbols}
# #    5GC002548_B_124_SiSo_E2E_system_setup_with_data_transfer_conducted_2510_A_256QAM_4Layer_100M_peak
# #    [Teardown]  702 Case TearDown For UTE
# 
# #[2][1.0] 5GC001077_B_TC05_Call_on_single_subcell_configured_in_40MHz_bandwidth_with_256QAM_mcs_27
# #    [Documentation]
# #    ...    This test case is used to test 1077 256QAM peak TP.
# #    ...    CHBW:40MHz
# #    [Timeout]    60m
# #    [Setup]    702 Case SetUp For UTE    update_param_name=${FRAME_TO_11160ms_40MHz_4Symbols_AEHC}
# #    5GC001077_B_TC05_Call_on_single_subcell_configured_in_40MHz_bandwidth_with_256QAM_mcs_27_AEHC
# #    [Teardown]    702 Case TearDown For UTE
# 
# #[1]5GC002522-CB-SyVe_TC03_NSA_PeakThrough_20MhzBW_4X4MIMO_256QAM_UDP
# #    [Documentation]
# #    ...    This test case is used to test 2522 case : 4X4MIMO 256QAM  MAX TP
# #    ...    Part DL slots were not scheduled for 20M/30M on 5G21B and later release
# #    [Timeout]    90m
# #    [Setup]    702 Case SetUp For UTE    update_param_name=${FRAME_TO_11160ms_20MHz_4Symbols_AEHC}
# #    5GC002522-CB-SyVe_TC03_NSA_PeakThrough_20MhzBW_4X4MIMO_256QAM_UDP
# #    [Teardown]    702 Case TearDown For UTE
# 
# #[1]5GC002548_B_117_SiSo_E2E_system_setup_with_data_transfer_conducted_2510_A_256QAM_4Layer_100M_peak_Concurrent_Mode
# #    [Documentation]    L3 call for 100M 4X4, 1116 0ms
# #    ...                CHBW:100MHz
# #    ...                Feature_ID:5GC002056-CFAM;5GC002548
# #    [Timeout]    60m
# #    [Setup]  702 Case SetUp For UTE    update_param_name=${FRAME_TO_11160ms_100MHz_4Symbols}
# #    5GC002548_B_117_SiSo_E2E_system_setup_with_data_transfer_conducted_2510_A_256QAM_4Layer_100M_peak_Concurrent_Mode
# #    [Teardown]   702 Case TearDown For UTE
# 
# #[1]5GC002548_B_011_5GC000561_eCPRI_sync_counters
# #    [Documentation]   Sub-feature:5GC002548-BF
# #    ...    modified: 2021-08-23 Jia Lei add fiberswitch on AEHC Trunk, it will cause about 6 hours.
# #    [Timeout]    420m
# #    [Setup]    702 Case SetUp For UTE
# #    5GC002548_B_011_5GC000561_eCPRI_sync_counters    ethlk_id=${2}
# ##    5GC002548_B_011_5GC000561_eCPRI_sync_counters_Trunk
# #    [Teardown]    702 Case TearDown For UTE
# 
# #[1]CNI-81699_01_PDLruleverification
# #    [Documentation]    validate pdl rule: Rule6Case6-1 webem
# #    ...                Feature_ID:CNI-81699, no traffic, OAM feature
# #    ...                actChannelMapVal: ShowAsWarning/disabled/error, cellTechnology: TDD, numberOfRxBeamforming: 4RX
# #    ...                nrCellType: 8DL4UL, numOfSubSectors: 0sub-sector, actExternalAntennaBF: False,actBeamForming: True
# #    ...                pdl error should be reported when Channel group1: 8Tx, 4Rx
# #    [Timeout]    60m
# #    [Setup]    702 Case SetUp For UTE
# #    PDLruleverification
# #    [Teardown]    702 Case TearDown For UTE
# 
