# *** Settings ***
# Documentation    Auther:xiaoxia.hao@nokia-sbell.com
# Suite Setup    702 Suite Setup For UTE
# Suite Teardown    702 Suite TearDown For UTE
# Resource    Resources/5GC002056_case_common.robot
# Force Tags            5G_RAN_TDD    STATE_SW_UPLOADED    master_classicalbts_all
# ...    PY36
# ...       CRT_UTE    CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABIOB1_AEHC_AEQE_AEQY_ENB    5G_RAN    SBTS00    SBTS22R1    SBTS22R2    RAN_5G    RAN_5G_TDD
# 
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1]5GC002548_B_117_SiSo_E2E_system_setup_with_data_transfer_conducted_2510_A_256QAM_4Layer_100M_peak_Concurrent_Mode
#     [Documentation]    L3 call for 100M 4X4, 1116 0ms
#     ...                CHBW:100MHz
#     ...                Feature_ID:5GC002056-CFAM;5GC002548
#     [Timeout]    60m
#     [Setup]  702 Case SetUp For UTE    update_param_name=${FRAME_TO_11160ms_100MHz_4Symbols}
#     5GC002548_B_117_SiSo_E2E_system_setup_with_data_transfer_conducted_2510_A_256QAM_4Layer_100M_peak_Concurrent_Mode
#     [Teardown]   702 Case TearDown For UTE
# 
# [1]5GC000657_5GC0011116_3ms_02_A2_L3_call_with peak_throughput_with_beamforming_80M
#     [Documentation]    L3 call for 80M 4X4,1116 0ms
#     ...                CHBW:80MHz
#     ...                Feature_ID:5GC000657;5GC002056-CFAB
#     [Timeout]    60m
#     [Setup]  702 Case SetUp For UTE
#     5GC000657_5GC0011116_3ms_02_A2_L3_call_with peak_throughput_with_beamforming_80M
#     [Teardown]   702 Case TearDown For UTE
# 
# 
# [1]5GC002548_B_119_SiSo_E2E_system_setup_with_data_transfer_conducted_2510_A_256QAM_4Layer_50M_peak_Concurrent_Mode
#     [Documentation]    L3 call for 50M 4x4,1070
#     ...                CHBW:50MHz
#     ...                Feature_ID:5GC002056-CFAM;5GC002548
#     [Timeout]    60m
#     [Setup]  702 Case SetUp For UTE
#     5GC002548_B_119_SiSo_E2E_system_setup_with_data_transfer_conducted_2510_A_256QAM_4Layer_50M_peak_Concurrent_Mode
#     [Teardown]   702 Case TearDown For UTE
# 
# [1]5GC002548_B_123_SiSo_E2E_system_setup_with_data_transfer_conducted_2510_A_256QAM_4Layer_40M_peak_Concurrent_Mode
#     [Documentation]    L3 call for 50M 4X4,1208
#     ...                CHBW:40MHz
#     ...                Feature_ID:5GC002056-CFAM;5GC002548
#     [Timeout]    60m
#     [Setup]  702 Case SetUp For UTE
#     5GC002548_B_123_SiSo_E2E_system_setup_with_data_transfer_conducted_2510_A_256QAM_4Layer_40M_peak_Concurrent_Mode
#     [Teardown]   702 Case TearDown For UTE
# 
# [1]5GC002548_B_118_SiSo_E2E_system_setup_with_data_transfer_conducted_2510_A_256QAM_4Layer_20M_peak_Concurrent_Mode
#     [Documentation]    L3 call for 20M 4X4,1116 3ms
#     ...                CHBW:20MHz
#     ...                Feature_ID:5GC002056-CFAM;5GC002548
#     [Timeout]    60m
#     [Setup]  702 Case SetUp For UTE
#     5GC002548_B_118_SiSo_E2E_system_setup_with_data_transfer_conducted_2510_A_256QAM_4Layer_20M_peak_Concurrent_Mode
#     [Teardown]   702 Case TearDown For UTE
# 
# [1]5GC002540_E_10_03_AEHC_AEQE_AEQQ_peak_tput_3S_2CC_8D4U_40M60M_20M20M_40M50M_1X25G
#     [Documentation]    L3 call for 100M 8DL4UL 2CC,1116 3ms
#     ...                CHBW:100MHz
#     ...                Feature_ID:5GC002540
#     [Timeout]    120m
#     [Setup]  702 Case SetUp For UTE
#     ${scf_file_name}    Set Variable    Configuration_8x4_2cc_${stream}
#     Recommission With Backup SCF File And Wait Gnb On Air    scf_file_name=${scf_file_name}
#     5GC002540_E_10_03_AEHC_AEQE_AEQQ_peak_tput_3S_2CC_8D4U_40M60M_20M20M_40M50M_1X25G
#     [Teardown]   702 Case TearDown For UTE