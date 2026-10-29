# *** Settings ***
# Suite Setup           Run Keywords     SISO Coam Suite Setup
# ...                   AND     Case Preparation
# Suite Teardown        SISO Coam Suite Teardown
# Test Setup            SISO Coam Test Setup
# Test Teardown         SISO Coam Test Teardown
# 
# Resource    Resources/CB006277_common_keywords.robot
# 
# Documentation
# ...    author: Liu Yue
# ...    contact: yue.2.liu@nokia-sbell.com
# ...    squad group: SG_05
# ...    feature : 5GC006277-EC in 5G22R1 program
# 
# Force Tags    5G_RAN_TDD
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB006277_EC_01_Energy_Consumption_Counter_Feature_Activate_via_WebUI
#     [Tags]    CRT_TRUNK    master_classicalbts_all   CIT_22R3   CDRT_22R2   CIT_22R1    CRT_22R4
#     Wait for New Interval BTS counters Generate    interval=15min
#     Disable Energy Consumption Measurement Collectection    interval=15min
#     Set Power meter    power_meter=true
# 
# #[1]CB006277_EC_02_Energy_Consumption_Counter_Feature_Deactivate_via_WebUI
# #    Wait for New Interval BTS counters Generate    interval=15min
# #    Disable Energy Consumption Measurement Collectection    interval=15min
# #    Set Power meter    power_meter=true
