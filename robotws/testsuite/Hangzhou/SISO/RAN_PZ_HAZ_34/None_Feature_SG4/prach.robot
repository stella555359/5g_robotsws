# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         1200 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Modify_Prach_Online_with_Frame_Structure.robot
# 
# Documentation
# ...    Author:tingting zhong
# ...    contact:tingting.zhong@nokia-sbell.com
# ...    squad group:SG_04
# ...    https://jiradc.ext.net.nokia.com/browse/LEOPARD-762
# 
# Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]1208_GP1_A1_PRACH
#     [Tags]    CRT_Trunk
#     ${prach_index_list}    create list    100  101  149  159  191  192
#     ${ue_num_each_call}    Get Tput ue Number    given_num=2
#     General_SiSo_Modify_Prach_Online_with_Frame_Structure    prach_index_list=${prach_index_list}
#     ...    frame_structure=1208_GP1_A1    ue_num_each_call=${ue_num_each_call}
#     ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}
# 
# [1]1070_GP1_A3_PRACH
#     [Tags]    CRT_Trunk
#     ${prach_index_list}    create list    2  4  6  17  88  104  152  161  197
#     ${ue_num_each_call}    Get Tput ue Number    given_num=2
#     General_SiSo_Modify_Prach_Online_with_Frame_Structure    prach_index_list=${prach_index_list}
#     ...    frame_structure=1070_GP1_A3    ue_num_each_call=${ue_num_each_call}
#     ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}
# 
# [1]1116_3ms_GP1_A5_PRACH
#     [Tags]    CRT_Trunk
#     ${prach_index_list}    create list    3  5  7  12  87  89  93  94  98  145  146  147  148  151  157  160  162  189
#     ...  190  196  201  202  203  205
#     ${ue_num_each_call}    Get Tput ue Number    given_num=2
#     General_SiSo_Modify_Prach_Online_with_Frame_Structure    prach_index_list=${prach_index_list}
#     ...    frame_structure=1116_3ms_GP1_A5    ue_num_each_call=${ue_num_each_call}
#     ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}
# 
# [1]1116_0ms_GP2_A7_PRACH
#     [Tags]    CRT_Trunk
#     ${prach_index_list}    create list    9  14  90  92  96  97  102  150  156  158  194  195  198  206
#     ${ue_num_each_call}    Get Tput ue Number    given_num=2
#     General_SiSo_Modify_Prach_Online_with_Frame_Structure    prach_index_list=${prach_index_list}
#     ...    frame_structure=1116_0ms_GP2_A7    ue_num_each_call=${ue_num_each_call}
#     ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}
# 
# [1]verify_prach_peak
#     ${cell_list}    get all cell id
#     ${ue_num_each_call}    Get Tput ue Number    given_num=2
#     get ue from init file and make call    cell_list=${cell_list}    with_peak=${True}    duration=${200}
#     ...    ue_num_each_call=${ue_num_each_call}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
# 
# *** Keywords ***
