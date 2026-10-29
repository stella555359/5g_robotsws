# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# #Test Setup           SISO Coam Test Setup
# #Test Teardown        SISO Coam Test Teardown
# Test Timeout         80 min
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
# 
# *** Test Cases ***
# [1]CB008238-5G-A_02_01_Single-UE_small_packet_timer_lower_than_dtxMaxRetentionDelay_on_SA
#     [Tags]    master_classicalbts_all    CRT_TRUNK    CRT_22R4
#     [Setup]    SISO Coam Test Setup
#     Selenium Login And Disable Screen Lock
#     Modify actDtxOptimizedScheduler Parameter    false
#     Start L3Call and DL small packet    throughput=30M
#     Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
#     Sleep    ${log_capture_time}
#     ${tti_trace}=    Stop TTI Traces in Streaming mode
#     set test variable    ${tti_trace}
#     Stop L3Call and DL Traffic
#     Check highestClassPriority and numOfPrb when CB008238 off for SA
# 
#     Modify actDtxOptimizedScheduler Parameter    true
#     Start L3Call and DL small packet    throughput=30M
#     Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
#     Sleep    ${log_capture_time}
#     ${tti_trace}=    Stop TTI Traces in Streaming mode
#     Stop L3Call and DL Traffic
#     Check highestClassPriority and numOfPrb when CB008238 on for SA
#     #Delete temp csv tti file on gnb
#     [Teardown]    Run keywords     Selenium Logout And Close Browser    AND   SISO Coam Test Teardown
# 
# #[1]test_celllock
# #    [Tags]    master_classicalbts_all    CRT_TRUNK
# #    [Setup]    SISO Coam Test Setup
# #      @{split_version}    string.split string    ${Active_SW_version}    separator=_
# #    ${stream}    set variable     @{split_version}[0]
# #    Selenium Login And Disable Screen Lock    version=${stream}
# #    ${lock_list}  Get All Cell Id
# #    Lock cells or groups and check status  lock_list=${lock_list}  is_group=${False}  check_alarm=${False}
# #        ...    gnb_type='${gNb_CuType}'
# #    log to console  \n end
# #    [Teardown]    Run keywords     Selenium Logout And Close Browser    AND   SISO Coam Test Teardown
# 
# 
# *** Keywords ***
