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
# [1]CB008238-5G-B_01_02_Multi-UE_Micro-DTX_optimized_scheduler_interaction_with_non-GBR_traffic
#     [Tags]    master_classicalbts_all    CRT_TRUNK    CRT_22R4
#     [Setup]    SISO Coam Test Setup
#     Selenium Login And Disable Screen Lock
#     Modify actDtxOptimizedScheduler Parameter    true
#     Start L3Call and DL small packet    throughput=30M    ue_index=0
#     Start L3Call and DL small packet    throughput=30M    ue_index=1
#     Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
#     Sleep    ${log_capture_time}
#     ${tti_trace}=    Stop TTI Traces in Streaming mode
#     ...  tti_trace_path=${TS_CASE_LOG_PATH}
#     Stop L3Call and DL Traffic    ue_index=0
#     Stop L3Call and DL Traffic    ue_index=1
#     Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
#     ...   options=-d dl
#     set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv
#     # Delete temp csv tti file on gnb
#     ${tti_ana}   get_tti_analyzer    ${local_csv_file_path}
#     @{rntis}=   Call Method    ${tti_ana}    check_cs1size_cs2size_in_event
#     Should Not Be Empty    ${rntis}
#     ${check1}=   Call Method    ${tti_ana}    check_highestClassPriority17_for_mutiUE    rnti_list=${rntis}
#     ${check2}=   Call Method    ${tti_ana}    check_dlDtxOptimData_for_mutiUE    rnti_list=${rntis}
#     ${check3}=   Call Method    ${tti_ana}    check_dlFdSchedData_for_mutiUE    rnti_list=${rntis}
#     Should be True   ${check1} and ${check2} and ${check3}
#     #[Teardown]    Run keywords     Selenium Logout And Close Browser
#     [Teardown]    Run keywords     Selenium Logout And Close Browser    AND   SISO Coam Test Teardown
# #[1]CB008238-5G-B_01_04_Multi-UE_Micro-DTX_optimized_scheduler_on_NSA
# #    [Tags]    master_classicalbts_all    CRT_TRUNK    1S-2CC-4D-4U_NSA
# #    [Setup]    SISO Coam Test Setup
# #    Selenium Login And Disable Screen Lock
# #    Modify actDtxOptimizedScheduler Parameter    true
# #    Start L3Call and DL small packet    throughput=30M    ue_index=0
# #    Start L3Call and DL small packet    throughput=30M    ue_index=1
# #    Start TTI trace log capturing
# #    Sleep    ${log_capture_time}
# #    Stop TTI trace log capturing
# #    Stop L3Call and DL Traffic    ue_index=0
# #    Stop L3Call and DL Traffic    ue_index=1
# #    &{local_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc
# #    ...    local_path=${TS_CASE_LOG_PATH}
# #    set test variable    ${local_csv_file_path}
# #    Delete temp csv tti file on gnb
# #    ${tti_ana}   get_tti_analyzer    ${local_csv_file_path['DL']}
# #    @{rntis}=   Call Method    ${tti_ana}    check_cs1size_cs2size_in_event
# #    Should Not Be Empty    ${rntis}
# #    ${check1}=   Call Method    ${tti_ana}    check_highestClassPriority17_for_mutiUE    rnti_list=${rntis}
# #    ${check2}=   Call Method    ${tti_ana}    check_dlDtxOptimData_for_mutiUE    rnti_list=${rntis}
# #    ${check3}=   Call Method    ${tti_ana}    check_dlFdSchedData_for_mutiUE    rnti_list=${rntis}
# #    Should be True   ${check1} and ${check2} and ${check3}
# #    [Teardown]    Run keywords     Selenium Logout And Close Browser    AND   SISO Coam Test Teardown
# *** Keywords ***
