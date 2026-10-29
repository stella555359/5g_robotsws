*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         100 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_Power_Consumption_and_Power_Saving_percentage_measured_in_Idle_Load.robot
# #Resource    ${BASIC_PATH_5G}/General_Amber_Feature_parameter_actMicroDtx_migration_check.robot
# #Resource    ${BASIC_PATH_5G}/General_Power_Consumption_and_Power_Saving_percentage_measured_in_Half_Load.robot
# #Resource    ${BASIC_PATH_5G}/General_Fault_4308_EFaultId_MdtxConfigurationFailureAl_raise.robot

Documentation
...    Author:zhihao shi
...    contact:zhihao shi@nokia-sbell.com
...    squad group:SG_04
...    Feature 5GC000430-A in 5G20B program run on AZHA and AZNA

Force Tags            5G_RAN    5G_RAN_TDD    STATE_GNB_COMMISSIONED    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEQZ_ENB
...    PY36
 
*** Variables ***

*** Test Cases ***
[1]5GC000430-A_03_01_Kylin_Power_Consumption_and_Power_Saving_percentage_measured_in_Idle_Load
    [Tags]    CRT_TRUNK    RF50
    General_Power_Consumption_and_Power_Saving_percentage_measured_in_Idle_Load
# 
# #[1]5GC000430-A_01_01_Kylin_Feature_parameter_actMicroDtx_migration_check
# #    General_Amber_Feature_parameter_actMicroDtx_migration_check
# #
# #[1][1.0] 5GC000430-A_03_02_Kylin_Power_Consumption_and_Power_Saving_percentage_measured_in_Half_Load
# #    General_Power_Consumption_and_Power_Saving_percentage_measured_in_Half_Load    ul_tput=4M    dl_tput=100M
# #
# #[1]5GC000430-A_01_05_Kylin_Fault_4308_EFaultId_MdtxConfigurationFailureAl_raise
# #    General_Fault_4308_EFaultId_MdtxConfigurationFailureAl_raise
# 
# *** Keywords ***
