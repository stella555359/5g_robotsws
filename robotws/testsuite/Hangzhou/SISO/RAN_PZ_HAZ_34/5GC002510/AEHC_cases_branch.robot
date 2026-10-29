# *** Settings ***
# Documentation      Author: xiaoxia.hao@nokia-sbell.com
# Suite Setup    702 Suite Setup For UTE
# Suite Teardown    702 Suite TearDown For UTE
# Resource    Resources/5GC002510_case_step.robot
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002056_CFAM/Resources/5GC002056_case_common.robot
# 
# *** Variables ***
# @{swconfig_enable_rdNewTddCellSlotModel}    0x420062=1    #modify swconfig,enable_rdNewTddCellSlotModel of CB008940
# ${cell_index}    ${1}
# 
# *** Test Cases ***
# [1]CB006915_D_01_L3call_test_2S_1CC_8D4U
#     [Documentation]    L3 call for 100M 8DL4UL 1CC,1116 0ms
#     ...                CHBW:100MHz
#     ...                Feature_ID:CB006915-D
#     [Tags]    CRT_23R1
#     [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_8x4_2S1CC_${stream}
#     CB006915_D_01_L3call_test_2S_1CC_8D4U
#     [Teardown]   702 Case TearDown For UTE    case_contain_special_operation=${True}
# 
# [1]CB009403_01_06_General_SiSo_RU_lock_unlock
#     [Documentation]   Sub-feature:5GC009403-A,L3 call DL TP expect value is 10% bler
#     ...               CHBW:100MHz
#     [Timeout]    60m
#     [Tags]    CRT_23R1
#     [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_CB009403_${stream}
#     @{cellid_list}    create list    1
#     CB009403_01_06_General_SiSo_RU_lock_unlock    cell_list=${cellid_list}
#     [Teardown]   702 Case TearDown For UTE    case_contain_special_operation=${True}
# 
# [1]CB009403_01_07_General_SiSo_E2E_system_setup_with_data_transfer_conducted
#     [Documentation]   Sub-feature:5GC009403-A,L3 call DL TP expect value is 10% bler
#     ...               CHBW:60MHz
#     [Timeout]    60m
#     [Tags]    CDRT_23R1    CRT_23R1
#     [Setup]  702 Case SetUp For UTE
#     CB009403_01_07_General_SiSo_E2E_system_setup_with_data_transfer_conducted
#     [Teardown]   702 Case TearDown For UTE    case_contain_special_operation=${True}
# 
# [1]CB006915_I_03_L3call_3S_1CC_8D4U_1fiber
#     [Documentation]    L3 call for 100M 8DL4UL 1CC,1116 0ms
#     ...                CHBW:100MHz
#     ...                Feature_ID:CB006915-I
#     [Tags]    CDRT_23R1    CRT_23R1
#     [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_8x4_3S1CC_${stream}
#     CB006915_I_03_L3call_3S_1CC_8D4U_1fiber
#     [Teardown]   702 Case TearDown For UTE    case_contain_special_operation=${True}
# 
