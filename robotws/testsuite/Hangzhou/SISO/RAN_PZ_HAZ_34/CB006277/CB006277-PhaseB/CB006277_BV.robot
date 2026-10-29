# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         100 min
# Variables    TestData/variables.py
# Resource     ../../common/siso_resource.robot
# Resource    ./Resource/resources_2cc.robot
# Resource     ../resource/resources_l3call.robot
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
# # ${L3call}=Not_Test_Throughput without l3call by default
# # ${L3call}=And_Test_Throughput with l3call
# [1]CB006277_BV_01_AQQL_eCPRI_cell_setup_with_Dual_carrier_100+60Mhz
#     [Tags]    master_classicalbts_all    CRT_TRUNK    CRT_22R3    1S-2CC-8D-4U
#     ${bandlist}    create list    ${100}    ${60}
#     General_SiSo_E2E_system_setup_with_data_transfer_multi_cc_with_different_bandwith_AQQL    bandlist=${bandlist}
#     ...    ue_num_each_call=1
# 
# *** Keywords ***
