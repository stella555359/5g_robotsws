# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# #Test Setup           SISO Coam Test Setup
# #Test Teardown        SISO Coam Test Teardown
# Test Timeout         60 min
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
# #0x580574=0x3  5G_UP_ALG_9388:rdDtxCellNbUeCs1ThresholdHigh_percent, default: 90.
# #Defines the limit above which the DTX oriented scheduling is disabled in the DL Scheduler [0..100]
# #0x580575=0x3  5G_UP_ALG_9463:rdDtxCellNbUeCs1ThresholdLow_percent, default: 80.
# #Defines the limit below which the DTX oriented scheduling re enabling starts in the DL Scheduler [0..100]
# #0x580576=0x64 5G_UP_ALG_9390:rdDtxCellEnablingTime_ms, default: 10.
# #The time since the last heavy load detection on 5G-L2-PS to enable again DTX oriented scheduling on the cell [0..1000]
# 
# *** Test Cases ***
# [1]CB008238-5G-D_01_01_Multi-UE_Micro-DTX_optimized_scheduler_dynamic_enabled_and_disabled_based_on_the_number_of_UEs_in_the_CS1_list
#     [Tags]    master_classicalbts_all    CRT_TRUNK    CDRT_TRUNK    CRT_22R4
#     [Setup]    SISO Coam Test Setup
#     @{modify_flags}  create list    0x580574=0x3   0x580575=0x3   0x580576=0x64   0x580578=0x8
#     CB008238_Common_KW.Update SW Config file on System Module    param_list=${modify_flags}
#     Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
#     sleep    120s
#     coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
#     ${radMasterValue}    CB008238_Common_KW.Get AaShell SW Config
#     Log to console    SW config: ${radMasterValue}
#     @{modify_flags}  create list    0x580574   0x580575   0x580576   0x580578
#     CB008238_Common_KW.Update SW Config file on System Module    del_param_list=${modify_flags}
#     Selenium Login And Disable Screen Lock
#     Modify actDtxOptimizedScheduler Parameter    actDtxOptimizedScheduler=true    dtxPrbThreshold=80
#     Start L3Call and DL small packet    throughput=30M    ue_index=0
#     Start L3Call and DL small packet    throughput=30M    ue_index=1
#     Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
#     #Sleep    ${log_capture_time}
#     Stop L3Call and DL Traffic    ue_index=1
#     ${tti_trace}=    Stop TTI Traces in Streaming mode
#     ...  tti_trace_path=${TS_CASE_LOG_PATH}
#     Stop L3Call and DL Traffic    ue_index=0
#     Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
#     ...   options=-d dl
#     set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv
#     #Delete temp csv tti file on gnb
#     ${tti_ana}   get_tti_analyzer    ${local_csv_file_path}
#     ${check1}=   Call Method    ${tti_ana}    check_DtxCellNbUeCs1ThresholdHigh
#     ${check2}=   Call Method    ${tti_ana}    check_DtxCellNbUeCs1ThresholdLow
#     Should be True   ${check1} and ${check2}
#     [Teardown]    Run keywords     Selenium Logout And Close Browser    AND
#     ...    SISO Coam Test Teardown
# *** Keywords ***
