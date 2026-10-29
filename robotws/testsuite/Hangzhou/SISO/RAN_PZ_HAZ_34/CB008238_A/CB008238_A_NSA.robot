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
# 
# *** Test Cases ***
# [1]CB008238-5G-A_03_02_Single-UE_small_packet_timer_higher_than_dtxMaxRetentionDelay_on_NSA
#     [Tags]    master_classicalbts_all    CRT_TRUNK    1S-2CC-4D-4U_NSA    CRT_22R4
#     [Setup]    SISO Coam Test Setup
#     Selenium Login And Disable Screen Lock
#     Modify actDtxOptimizedScheduler Parameter    false
#     Start L3Call and DL small packet    throughput=10K
#     Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
#     Sleep    ${log_capture_time}
#     ${tti_trace}=    Stop TTI Traces in Streaming mode
#     ...  tti_trace_path=${TS_CASE_LOG_PATH}
#     set test variable    ${tti_trace}
#     Stop L3Call and DL Traffic
#     Check highestClassPriority and numOfPrb when CB008238 off for NSA
# 
#     Modify actDtxOptimizedScheduler Parameter    true
#     Start L3Call and DL small packet    throughput=10K
#     Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
#     Sleep    ${log_capture_time}
#     ${tti_trace}=    Stop TTI Traces in Streaming mode
#     ...  tti_trace_path=${TS_CASE_LOG_PATH}
#     Stop L3Call and DL Traffic
#     Check highestClassPriority and numOfPrb when CB008238 on for NSA
#     #Delete temp csv tti file on gnb
#     [Teardown]    Run keywords     Selenium Logout And Close Browser    AND   SISO Coam Test Teardown
# 
# 
# *** Keywords ***
