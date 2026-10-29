# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# #Test Setup           SISO Coam Test Setup
# #Test Teardown        SISO Coam Test Teardown
# Test Timeout         120 min
# 
# Resource    ./resource/CB008238_Common_KW.robot
# #Resource    testsuite/Hangzhou/RRM/RAN_L3_SW_CN_1/Resource/external/gnb.robot
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
# @{rdDtxCS1SizeThreshold}=        0x580578=2    # default: 8. IntrodValue used to determinate
# #    ... if the UEs under DTX optimization are available for scheduling [0..16]
# 
# *** Test Cases ***
# [1]CB008238-5G-C_01_01_Single-UE_Micro-DTX_optimized_scheduler_when_requiredPRB_resources_higher_than_dtxPrbThreshold
#     [Tags]    master_classicalbts_all
#     [Setup]    SISO Coam Test Setup
#     Selenium Login And Disable Screen Lock
#     Modify actDtxOptimizedScheduler Parameter    actDtxOptimizedScheduler=true    dtxPrbThreshold=10
#     Start L3Call and DL small packet    throughput=30M    ue_index=0
#     Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
#     Sleep    ${log_capture_time}
#     ${tti_trace}=    Stop TTI Traces in Streaming mode
#     ...  tti_trace_path=${TS_CASE_LOG_PATH}
#     Stop L3Call and DL Traffic    ue_index=0
#     Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
#     ...   options=-d dl
#     set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv
#     #Delete temp csv tti file on gnb
#     ${tti_ana}   get_tti_analyzer    ${local_csv_file_path}
#     ${check1}=   Call Method    ${tti_ana}    check_dtxPrbThreshold_in_dlDtxOptimData    dtxPrbThreshold=${0.1}
#     Should be True   ${check1}
#     [Teardown]    Run keywords     Selenium Logout And Close Browser    AND   SISO Coam Test Teardown
# [1]CB008238-5G-C_01_08_Multi-UE_Micro-DTX_optimized_scheduler_when_CS1_list_size_larger_than_rdDtxCS1SizeThreshold
#     [Tags]    master_classicalbts_all    CRT_TRUNK    CRT_22R4
#     [Setup]    SISO Coam Test Setup
#     CB008238_Common_KW.Update SW Config file on System Module    param_list=${rdDtxCS1SizeThreshold}
#     Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
#     sleep    120s
#     coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
#     ${radMasterValue}    CB008238_Common_KW.Get AaShell SW Config    rad_param=0x580578
#     CB008238_Common_KW.Update SW Config file on System Module    del_param_list=${rdDtxCS1SizeThreshold}
# #    Log to console    rdDtxCS1SizeThreshold[0x580578] old value: ${radMasterValue}
# #    Set SW Config on Common Module    rad_param=0x580578    rad_param_value=2
# #    ${radMasterValue}    Get AaShell SW Config
# #    Log to console    rdDtxCS1SizeThreshold[0x580578] change to: ${radMasterValue}
#     Selenium Login And Disable Screen Lock
#     Modify actDtxOptimizedScheduler Parameter    actDtxOptimizedScheduler=true    dtxPrbThreshold=80
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
#     #Delete temp csv tti file on gnb
#     ${tti_ana}   get_tti_analyzer    ${local_csv_file_path}
#     ${check}=   Call Method    ${tti_ana}    check_dlDtxOptimEvent_in_dlDtxOptimData    dlDtxOptimEvent_value=CS1SIZETHRES
#     Should be True   ${check}
#     [Teardown]    Run keywords     Selenium Logout And Close Browser    AND   SISO Coam Test Teardown
# *** Keywords ***
