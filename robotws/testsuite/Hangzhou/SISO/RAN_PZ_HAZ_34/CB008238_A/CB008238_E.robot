# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# #Test Setup           SISO Coam Test Setup
# #Test Teardown        SISO Coam Test Teardown
# Test Timeout         50 min
# 
# Resource    ./resource/CB008238_Common_KW.robot
# 
# Documentation
# ...    Author: Zhang Xuewen
# ...    Contact: xuewen.zhang@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature CB008238 in 5G22R4 program
# 
# Force Tags    5G_RAN_TDD
# 
# *** Variables ***
# ${change_interval}    15min
# 
# *** Test Cases ***
# [1]CB008238-5G-E_02_01_Micro-DTX_optimized_scheduler_PM_counter_update_M55308C33000_ACC_UE_MICRO_DTX_OPTIMIZED
# #CB008238-5G-E_02_02_Micro-DTX_optimized_scheduler_PM_counter_update_M55308C33001_ACC_UE_MICRO_DTX_NO_DATA_BUNDLING
#     [Tags]    master_classicalbts_all    CRT_TRUNK    CDRT_TRUNK    CRT_22R4
#     [Setup]    SISO Coam Test Setup
#     Selenium Login And Disable Screen Lock
#     Modify actDtxOptimizedScheduler Parameter    true
#     Modify miNrCellUtilization Parameter    ${change_interval}
#     Start L3Call and DL small packet    throughput=1M
#     Sleep    ${log_capture_time}
#     Stop L3Call and DL Traffic
#     sleep    11min
#     connect to common unit master
#     ${M55308C33000}    Get PM Counter via Webem    counter_id=M55308C33000    interval=${change_interval}    counter_type=BTS
#     ${M55308C33000_value}    convert to integer     ${M55308C33000}
#     ${M55308C33001}    Get PM Counter via Webem    counter_id=M55308C33001    interval=${change_interval}    counter_type=BTS
#     ${M55308C33001_value}    convert to integer     ${M55308C33001}
#     Should Be True    ${M55308C33000_value} >0
#     Should Be True    ${M55308C33001_value} >0
#     [Teardown]    Run keywords     Selenium Logout And Close Browser    AND   SISO Coam Test Teardown
# 
# 
# *** Keywords ***
