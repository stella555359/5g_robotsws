# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         12h
# 
# 
# Resource    ./resource/CB006293_common_resource.robot
# 
# Library    ./library/6293.py
# Documentation
# ...    Author: liu yue
# ...    contact: yue.2.liu@nokis-sbell.com
# ...    squad group:SG_05
# ...    Feature CB006293 in 22R3 program
# ...    add new step for EDA03794851
# ...    Note: TL configuration needs 2CC and multi RU
# ...    This script used on TL260, if change to other TL, need modify RF scan function parameters
# 
# Force Tags     RAN_5G   RAN_5G_TDD   CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE   STATE_SW_UPLOADED    SBTS00
# ...    PY36
# 
# *** Variables ***
# ${if_commissioning}   False
# ${if_teardown_commissioning}   False
# ${if_pdl_check}       False
# ${ue_index}   0
# ${ru_type_init}   AEQE
# ${url}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
# 
# *** Test Cases ***
# [1]CB006293_5G_AEQE_09_Initiate_RF_Statistics_diagnostic_test_withL3call
#     [Tags]    master_classicalbts_all   CRT_UTE   CRT_TRUNK    CRT_22R3
#     #### add new step for EDA03794851
#     RF_Diagnostic_and_RF_scan_Test_For_notReadyGNB
#     log to console   ${if_commissioning} ${if_teardown_commissioning} ${if_pdl_check}    
#     General_SiSo_Initiate_RF_Statistics_diagnostic_test_withL3call_AEQE
#     ...   min_temperature=40   max_temperature=100   rf_port_id=0
# 
# 
# [1]CB006293_5G_AEQE_03_Initiate_RF_diagnostic_test_RSSI_test_withL3call
#     [Tags]    master_classicalbts_all   CRT_UTE   CRT_TRUNK    CRT_22R3
#     General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call_AEQE
# 
# [1][1.0]General_SiSo_Auto_RF_Module_Stability_Run
#     [Tags]   master_classicalbts_all   CRT_UTE    CRT_TRUNK    CRT_22R3    CRT_22R4
#     General_SiSo_Auto_RF_Module_Stability_Run
# 
# 
# *** Keywords ***
# 
