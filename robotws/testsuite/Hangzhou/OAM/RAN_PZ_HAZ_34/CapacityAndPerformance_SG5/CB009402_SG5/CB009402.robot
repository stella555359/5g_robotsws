# *** Settings ***
# Documentation    author:Zhang Xuewen
# ...              contact: xuewen.zhang@nokia-sbell.com
# ...                History: Do some adaption for CB008681
# ...               feature : CB009402
# Suite Setup       KW.TestSuilt.Start
# Suite Teardown    KW.TestSuilt.Stop
# Force Tags        CRT_24R1
# Resource           Resource/CB009402_Common_KW.robot
# 
# *** Test Cases ***
# CB009402-SR-A-Troubleshooting_03_RF_Scan_data_collection_duration
#     [Documentation]    RF_Scan_data_collection_duration
#     [Tags]     CRT_24R1
#     #[Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.RF_Scan_data_collection_duration
# 
# CB009402-SR-C-16-Manual_remote_power_reset_downtime_KPI#11
#     [Documentation]    KPI11
#     [Tags]     CRT_24R1
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.remote_power_reset_downtime_KPI11
# 
# CB009402-SR-C-18-Manual_capacity_module_power_reset_KPI#14
#     [Documentation]    KPI14
#     [Tags]     CRT_24R1
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.capacity_module_power_reset_KPI14
# 
# CB009402-SR-F-Energy-Efficiency_06_Cell_switching_duration
#     [Documentation]    Cell_switching_duration
#     [Tags]     CRT_24R1
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.Cell_switching_duration
# 
# CB009402-SR-F-Energy-Efficiency_07_TRX_switching_duration
#     [Documentation]    TRX_switching_duration
#     [Tags]     CRT_24R1
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.TRX_switching_duration
# 
# CB009402-SR-F-Time_duration_wake_up_radio_module_from_Deep_sleep_mode
#     [Documentation]    Time_duration_wake_up_radio_module_from_Deep_sleep_mode
#     [Tags]     CRT_24R1
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.Time_duration_wake_up_radio_module_from_Deep_sleep_mode
# 
# 
# *** Keywords ***
