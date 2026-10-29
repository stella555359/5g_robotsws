# *** Settings ***
# Suite Setup          702 Suite Setup For UTE
# Suite Teardown       702 Suite TearDown For UTE
# Test Setup           702 Case SetUp For UTE
# Test Teardown        702 Case TearDown For UTE
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# #Resource    ${BASIC_PATH_5G}/General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call.robot
# #Resource    ${BASIC_PATH_5G}/General_SiSo_Initiate_RF_Statistics_diagnostic_test_withL3call.robot
# Resource    TestData/CB006293_case_step.robot
# #Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_common_ute.robot
# 
# Documentation
# ...    Feature CB006293 in 22R3 program
# 
# Force Tags            5G_RAN_TDD    STATE_SW_UPLOADED    master_classicalbts_all
# ...    PY39    SBTS22R4    SBTS23R2
# ...           CRT_UTE    CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABIOB1B2_3xAEHC    5G_RAN    SBTS00    SBTS22R3    RAN_5G    RAN_5G_TDD
# 
# *** Variables ***
# 
# *** Test Cases ***
# #
# #[1]CB006293_5G_Chile_03_Initiate_RF_diagnostic_test_RSSI_test_withL3call
# #    [Timeout]    120m
# #    Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call
# #
# ##[1]CB006293_5G_Chile_04_Initiate_RF_diagnostic_test_SINR_per_cell_test_withL3call
# ##    [Timeout]    360m
# ##    run keyword if   'ENB_9999' in '${Active_SW_version}'
# ##    ...              RF_Module_Stability_Run
# ##    ...              ELSE
# ##    ...              Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call
# #
# #[1]CB006293_5G_Chile_09_Initiate_RF_Statistics_diagnostic_test_withL3call
# #    [Timeout]    420m
# #    Initiate_RF_Statistics_diagnostic_test_withL3call    RF_temperature_high_threshold=90    rf_port_id=0
# #    ...    max_temperature=90
# #    run keyword if   'ENB_9999' in '${Active_SW_version}'    RF_Module_Stability_Run
# 
# 
