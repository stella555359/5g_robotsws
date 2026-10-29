# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# #Test Setup           SISO Coam Test Setup
# #Test Teardown        SISO Coam Test Teardown
# Test Timeout         100 min
# Resource    ./Resource/resources_2cc.robot
# Variables    TestData/variables.py
# Resource     ../../common/siso_resource.robot
# Resource     ../resource/resources_l3call.robot
# Resource    ${BASIC_PATH_5G}/General_gnb_can_be_on_air_with_Given_Information.robot
# Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
# 
# Documentation
# ...    Author: Liu Yue
# ...    Contact: yue.2.liu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature CB006277 in 5G22R1 program
# 
# Force Tags    RAN_5G_TDD
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB006277_BA_01_AQQL_eCPRI_GNB_cell_setup_with_Dual_carrier_100+100Mhz
#     [Tags]    master_classicalbts_all    CRT_TRUNK    CRT_22R3    1S-2CC-8D-4U
#     [Setup]    SISO Coam Test Setup
#     General_gnb_can_be_on_air_with_Given_Information    band=100   frame_structure=1116_3ms_GP1_B5   dl_ul_layer=8DL4UL
#     ...    prach_index=191
#     [Teardown]    SISO Coam Test Teardown
# [1]CB006277_BA_03_AQQL_eCPRI_cell_lock_unlock_with_Dual_carrier_100+100Mhz
#     [Tags]    master_classicalbts_all    CRT_TRUNK    1S-2CC-8D-4U
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_Cell_lock_and_unlock
#     [Teardown]    SISO Coam Test Teardown
# [1]CB006277_BA_04_AQQL_eCPRI_cell_online_addition_deletion_100+100Mhz
#     [Tags]    master_classicalbts_all    CRT_TRUNK    1S-2CC-8D-4U
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_Online_Cell_addition_deletion_AQQL
#     [Teardown]    SISO Coam Test Teardown
# *** Keywords ***
