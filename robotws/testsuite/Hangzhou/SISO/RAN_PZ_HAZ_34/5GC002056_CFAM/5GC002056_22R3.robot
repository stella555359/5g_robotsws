# *** Settings ***
# Documentation    Auther:xiaoxia.hao@nokia-sbell.com
# Suite Setup    702 Suite Setup For UTE
# Suite Teardown    702 Suite TearDown For UTE
# Resource    Resources/5GC002056_case_common.robot
# 
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1]5GC002540_E_10_03_AEHC_AEQE_AEQQ_peak_tput_3S_2CC_8D4U_40M60M_20M20M_40M50M_1X25G
#     [Documentation]    L3 call for 100M 8DL4UL 2CC,1116 3ms
#     ...                CHBW:100MHz
#     ...                Feature_ID:5GC002540
#     [Tags]    CRT_22R4    CRT_23R1    CDRT_23R1
#     [Setup]  702 Case SetUp For UTE
#     ${scf_file_name}    Set Variable    Configuration_8x4_2cc_${stream}
#     Recommission With Backup SCF File And Wait Gnb On Air    scf_file_name=${scf_file_name}
#     5GC002540_E_10_03_AEHC_AEQE_AEQQ_peak_tput_3S_2CC_8D4U_40M60M_20M20M_40M50M_1X25G
#     [Teardown]   702 Case TearDown For UTE    case_contain_special_operation=${True}
# 
# [1]General_SiSo_Auto_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     [Documentation]   Sub-feature:5GC002510-A
#     [Tags]    CRT_22R4
#     [Setup]    702 Case SetUp For UTE
#     RRH_common_keyword.General SiSo Collect RFSW Logs From RU Into BTS Snapshot
#     [Teardown]    702 Case TearDown For UTE
# 
# [1][1.0] 5GC002089-B_05_5GC002089-42_AEHC_RU_lock_and_unlock_L3_call_multiple_BBMODs
#     [Documentation]   Feature 5GC002089-42 with AEHC
#     [Tags]    CRT_22R4    CRT_23R1
#     [Setup]  702 Case SetUp For UTE    scf_file_name=SCF_2089-42_AEHC_${stream}
#     5GC002089-B_05_5GC002089-42_AEHC_RU_lock_and_unlock_L3_call_multiple_BBMODs    ru_index=${1}    cell_index=${1}    cell_group_idx=${1}
#     [Teardown]    702 Case TearDown For UTE
# 
# [1][1.0] 5GC002089-B_06_5GC002089-42_AEHC_RU_module_reset_from_GUI
#     [Documentation]   Feature 5GC002089-42 with AEHC
#     [Tags]    CRT_22R4    CRT_23R1
#     [Setup]    702 Case SetUp For UTE    scf_file_name=SCF_2089-42_AEHC_${stream}
#     5GC002089-B_06_5GC002089-42_AEHC_RU_module_reset_from_GUI    ru_index=${1}    cell_index=${1}
#     [Teardown]    702 Case TearDown For UTE
# 
# [1]CNI-81699_01_PDLruleverification
#     [Documentation]    validate pdl rule: Rule6Case6-1 webem
#     ...                Feature_ID:CNI-81699, no traffic, OAM feature
#     ...                actChannelMapVal: ShowAsWarning/disabled/error, cellTechnology: TDD, numberOfRxBeamforming: 4RX
#     ...                nrCellType: 8DL4UL, numOfSubSectors: 0sub-sector, actExternalAntennaBF: False,actBeamForming: True
#     ...                pdl error should be reported when Channel group1: 8Tx, 4Rx
#     [Tags]    CRT_23R1    CRT_22R4
#     [Setup]    702 Case SetUp For UTE
#     PDLruleverification
#     [Teardown]    702 Case TearDown For UTE    case_contain_special_operation=${True}
