# *** Settings ***
# Documentation    Auther:xiaoxia.hao@nokia-sbell.com
# Suite Setup    Suite Setup For CB009058
# Suite Teardown    Suite TearDown For CB009058
# Resource    Resources/CB009058_Case_Step.robot
# 
# *** Variables ***
# ${pcell_index}    3
# 
# *** Test Cases ***
# [1]CB009058_B_01_three_TDD_cells_each_L2_subpool_one_cell_on_half_ABIO
#     [Tags]    Classical    CRT_24R3
#     [Timeout]    90m
#     [Setup]  Case SetUp For CB009058
#     CB009058_B_01_three_TDD_cells_each_L2_subpool_one_cell_on_half_ABIO    pcell_index=${pcell_index}
#     [Teardown]   Case TearDown For CB009058
# 
# 
