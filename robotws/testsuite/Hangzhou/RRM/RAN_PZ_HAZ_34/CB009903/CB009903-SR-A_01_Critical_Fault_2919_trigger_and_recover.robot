# *** Settings ***
# Documentation
# ...    author: Li Ying
# ...    contact: ying.15.li@nokia-sbell.com
# 
# Suite Setup    #Common Suite Setup
# Suite Teardown    #Common Suite Teardown
# 
# Resource          ./Resources/CB009903_Common_Keywords.robot
# 
# Test Timeout      60 min
# 
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1]CB009903-SR-A_01_Critical_Fault_2919_trigger_and_recover
#     [Setup]    Case Setup
#     Configure alVoltHighThreshold to 115
#     Configure alVoltHighThresholdMinor to 105
#     Set RU Voltage to 58
#     wait until keyword succeeds    30s    10s   Check fault report
#     ...    fault_ID=2919      alarm_filter=7115
#     Set RU Voltage to 59
#     wait until keyword succeeds    60s    10s   Check fault report
#     ...    fault_ID=2919    alarm_filter=7100
#     Set RU Voltage to 53
#     sleep      3min
#     wait until keyword succeeds    6min    1min    Check fault clear
#     ...    fault_ID=2919    alarm_filter=7100
#     Configure alVoltLowThreshold to -115
#     Configure alVoltLowThresholdMinor to -105
#     Set RU Voltage to 36
#     wait until keyword succeeds    60s    10s   Check fault report
#     ...    fault_ID=2920    alarm_filter=7100
#     Set RU Voltage to 38
#     sleep     3min
#     wait until keyword succeeds    6min    1min    Check fault clear
#     ...    fault_ID=2920    alarm_filter=7100
#     wait until keyword succeeds    60s    10s   Check fault report
#     ...    fault_ID=2920    alarm_filter=7115
#     Set RU Voltage to 53
#     wait until keyword succeeds    6min    1min    Check fault clear
#     ...    fault_ID=2920    alarm_filter=7115
#     [teardown]     Run Keyword And Ignore error     Case Teardown
# 
