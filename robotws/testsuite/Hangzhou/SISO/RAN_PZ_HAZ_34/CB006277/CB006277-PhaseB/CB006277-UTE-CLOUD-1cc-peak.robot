# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# #Test Setup           SISO Coam Test Setup
# #Test Teardown        SISO Coam Test Teardown
# Test Timeout         300 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_gnb_can_be_on_air_with_Given_Information.robot
# Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
# Resource    ${BASIC_PATH_5G}/5GC000399/5GC000399_eCPRI_FREERUN_state_handling.robot
# Resource     ../resource/resources_l3call.robot
# Resource     ../../common/siso_resource.robot
# Resource     ../CB006277-phaseA/resource/CB006277_Common_KW.robot
# Resource     ../CB006277-PhaseE/Resources/CB006277_common_keywords.robot
# Variables    TestData/variables.py
# 
# Documentation
# ...    Author: Liu Yue
# ...    Contact: yue.2.liu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature CB006277 in 5G22R1 program
# 
# Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY36    master_classicalbts_all
# 
# *** Variables ***
# &{PARA_MODIFY}    dist_name=MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
# ...    p_name=topDomainNumber    filter_param=ToP domain number    value=43
# @{TOP_DOMAIN_NUMBER_MODIFY}    &{PARA_MODIFY}
# 
# *** Test Cases ***
# ### non-peak cases - 4 TCs ###
# [1]CB006277_BB_03_AQQL_eCPRI_cell_lock_unlock_20Mhz
#     [Tags]       1S-1CC-8D4U_A8_20M_C2-195_2089-41    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB    CRT_22R4
#     [Setup]    SISO Coam Test Setup
# #    General_gnb_can_be_on_air_with_Given_Information    band=20    beamset=2 beams
# #    ...    frame_structure=1116_0ms_GP1_A8    prach_index=195
# #    sleep    5s
#     General_SiSo_Cell_block_and_unblock    with_call=${False}
#     sleep    3s
#     ${cell_list}    create list    ${1}
#     Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
#     [Teardown]    SISO Coam Test Teardown
# 
# #[1]CB006277_AE_04_AQQL_eCPRI_U-plane_Fast_C-plane_counters
# #    [Tags]        1S-1CC-8D4U_A5_100M_C2-191_TA-3000_2089-41     CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB
# #    [Setup]    SISO Coam Test Setup
# #    General_SiSo_U-plane_Fast_C-plane_counters_AQQL
# #    [Teardown]    SISO Coam Test Teardown
# 
# [1]CB006277_AC_11_AQQL_eCPRI_FREERUN_state_handling
#     [Tags]        1S-1CC-8D4U_A5_100M_C2-191_TA-3000_2089-41     CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB   CRT_22R4
#     [Setup]    SISO Coam Test Setup
#     5GC000399_eCPRI_FREERUN_state_handling
#     [Teardown]    SISO Coam Test Teardown
# 
# [1]CB006277_EC_01_Energy_Consumption_Counter_Feature_Activate_via_WebUI
#     [Tags]        1S-1CC-8D4U_A5_100M_C2-191_TA-3000_2089-41     CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB   CRT_22R4
#     [Setup]    SISO Coam Test Setup
#     Wait for New Interval BTS counters Generate    interval=15min
#     Disable Energy Consumption Measurement Collectection    interval=15min
#     Set Power meter    power_meter=true
#     [Teardown]    SISO Coam Test Teardown
# 
# 
# ### peak cases - 5 TCs  ###
# [1]CB006277_BB_02_AQQL_eCPRI_peak_Tput_with_chbw_20Mhz
#     [Tags]      1S-1CC-8D4U_A8_20M_C2-195_2089-41    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB   CRT_22R4
#     [Setup]    SISO Coam Test Setup
#    # General_gnb_can_be_on_air_with_Given_Information    frame_structure=1116_0ms_GP1_A8    prach_index=195
#    # ...    band=20
#    # sleep    5s
#     ${cell_list}    create list    ${1}
#     Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
#     [Teardown]    SISO Coam Test Teardown
# 
# [1]CB006277_BG_02_AQQL_eCPRI_peak_Tput_with_chbw_40Mhz
#     [Tags]       1S-1CC-8D4U_A6_40M_A2-98_2089-41    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB   CRT_22R4
#     [Setup]    SISO Coam Test Setup
#    # General_gnb_can_be_on_air_with_Given_Information    frame_structure=1116_3ms_GP2_A6    prach_index=98
#    # ...    band=40
#    # sleep    5s
#     ${cell_list}    create list    ${1}
#     Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
#     [Teardown]    SISO Coam Test Teardown
# 
# [1]CB006277_BH_02_AQQL_eCPRI_peak_Tput_with_chbw_50Mhz
#     [Tags]        1S-1CC-8D4U_A3_50M_F0-7_2089-41     CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB   CRT_22R4
#     [Setup]    SISO Coam Test Setup
#    # General_gnb_can_be_on_air_with_Given_Information    frame_structure=1070_GP1_A3    prach_index=7
#    # ...    band=50
#    # sleep    5s
#     ${cell_list}    create list    ${1}
#     Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
#     [Teardown]    SISO Coam Test Teardown
# 
# [1]CB006277_BI_02_AQQL_eCPRI_peak_Tput_with_chbw_60Mhz
#     [Tags]       1S-1CC-8D4U_A8_60M_B4-156_2089-41     CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB   CRT_22R4
#     [Setup]    SISO Coam Test Setup
#    # General_gnb_can_be_on_air_with_Given_Information    frame_structure=1116_0ms_GP1_A8    prach_index=156
#    # ...    band=60
#    # sleep    5s
#     ${cell_list}    create list    ${1}
#     Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
#     [Teardown]    SISO Coam Test Teardown
# 
# [1]CB006277_AE_03_AQQL_eCPRI_peak_Tput_with_4x4MIMO
#     [Tags]        1S-1CC-8D4U_A5_100M_C2-191_TA-3000_2089-41     CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB   CRT_22R4
#     [Setup]    SISO Coam Test Setup
#    # General_gnb_can_be_on_air_with_Given_Information    frame_structure=1116_3ms_GP1_A5    prach_index=191
#    # ...    band=100
#    # sleep    5s
#     ${cell_list}    create list    ${1}
#     Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
#     [Teardown]    SISO Coam Test Teardown
# 
# *** Keywords ***
