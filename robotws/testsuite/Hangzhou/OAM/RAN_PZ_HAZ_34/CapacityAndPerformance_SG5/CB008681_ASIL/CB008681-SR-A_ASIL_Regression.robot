# *** Settings ***
# Documentation    author:Zhang Xuewen
# ...              contact: xuewen.zhang@nokia-sbell.com
# ...                History: Do some adaption for CB008681
# ...               feature : CB008681
# Suite Setup       KW.TestSuilt.Start
# Suite Teardown    KW.TestSuilt.Stop
# Force Tags        CRT_22R4
# Resource           Resources/OMKPI_KW_interface.robot
# 
# *** Test Cases ***
# [1]CB008681-SR-A-CM_01_Duration_of_Full_plan_download_validation_activation_operations
#     [Documentation]     C&P     CB008681-SR-A
#     [Tags]     CDRT_22R4
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.CM_Full_Plan_Download_Validation_Activation_Operations
# 
# [1]CB008681-SR-A-CM_03_Duration_of_delta_plan_activation_operations_Site_level_service_outage
#     [Documentation]     C&P     CB008681-SR-A
#     [Tags]     CDRT_22R4
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.CM_Delta_Plan_Validation_Activation_Operations_Site_Level_Service_Outage
# 
# 
# [1]CB008681-SR-A-CM_07_Duration_of_delta_plan_provision_operation_service_outage
#     [Documentation]    C&P     CB008681-SR-A
#     [Tags]     CDRT_22R4
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.CM_Delta_Plan_Validation_Activation_Operations_No_Service_Outage
# 
# 
# [1]CB008681-SR-A-CM_11_Duration_of_CM_change_notification
#     [Documentation]    C&P     CB008681-SR-A
#     [Tags]     CDRT_22R4
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.CM_Duration_of_CM_Change_Notification
# 
# [1]CB008681-SR-A-SWM_09_SW_Duration_Copy_SW_From_Active_to_Passive_Partition_manually_trigger
#     [Documentation]     C&P     CB008681-SR-A
#     [Tags]     CDRT_22R4
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.SWM_Duration_of_Copy_SW_from_Active_to_Passive_Partition_Manually_Triggered
# 
# 
# [1]CB008681-SR-A-Troubleshooting_01_Manually_Triggered_on-demand_Snapshot
#     [Documentation]    Troubeshooting
#     [Tags]     CDRT_22R4
#     [Setup]    SetUp Case
#     [Teardown]  Run Keywords      run keyword and ignore error    Teardown case
#                ...   AND    run keyword and ignore error  DisConnect to DU by ADMIN API
#     TC.LOG_Manual_Trigger_Snapshot
# 
# 
# #[1]CB008681-SR-A-Troubleshooting_02_Automatically_Triggered_Snapshot
# #    [Documentation]    Troubeshooting
# #    [Tags]     CDRT_22R4
# #    [Setup]    SetUp Case
# #    [Teardown]  Teardown case
# #    TC.LOG_Automatically_Triggered_Snapshot
# 
# [1]CB008681-SR-A-Troubleshooting_06_IP_Connectivity_Test_Duration
#     [Documentation]    Troubeshooting
#     [Tags]     CDRT_22R4
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.Troubleshooting_IP_connectivity_test
# 
# 
# [1]CB008681-SR-A-Troubleshooting_07_System_Module_Sanity_Checker
#     [Documentation]    Troubeshooting
#     [Tags]     CDRT_22R4
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.Troubleshooting_System_Module_Sanity_Checker
# 
# *** Keywords ***
