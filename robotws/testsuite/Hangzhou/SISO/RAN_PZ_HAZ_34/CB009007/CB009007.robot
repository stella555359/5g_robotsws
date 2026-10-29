# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# #Test Setup           SISO Coam Test Setup
# #Test Teardown        SISO Coam Test Teardown
# Test Timeout         100 min
# 
# #Resource     ../CB006277/resource/resources_l3call.robot
# #Resource     ../../common/siso_resource.robot
# Resource    ../CB009218/resource/CB009218_Common_KW.robot
# 
# Documentation
# ...    Author: Zhang Xuewen
# ...    Contact: xuewen.zhang@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature CB009007 in 5G23R1 program
# 
# Force Tags    5G_RAN_TDD
# 
# *** Variables ***
# 
# *** Test Cases ***
# 
# [1]CB009007_SR_A_01_Activation_and_Deactivation_Enhanced_PDSCH_Scheduling_on_Speical_slot_for_Frame_Structure_8406
#     [Tags]    master_classicalbts_all    CRT_TRUNK    CRT_22R4    3S-1CC-4D-2U-9007
#     [Setup]    SISO Coam Test Setup
#     ${special_slots}    create list    ${3}   ${7}   ${13}   ${17}
# #    ${expected_SLIVs}    create list    ${53}   ${96}   ${53}   ${96}
#     ${expected_SLIVs}    create list    ${57}   ${96}   ${57}   ${96}
#     Modify actEnhancedPDSCHSchSplSlot Parameter    actEnhancedPDSCHSchSplSlot=true
#     sleep    5s
#     ${cell_list}    create list    ${1}
#     CB009218_Common_KW.Start L3Call and DL small packet    throughput=1000M
#     Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
#     Sleep    ${log_capture_time}
#     ${tti_trace}=    Stop TTI Traces in Streaming mode
#     ...  tti_trace_path=${TS_CASE_LOG_PATH}
#     Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
#     ...   options=-d dl
#     set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv
#     CB009218_Common_KW.Stop L3Call and DL Traffic
#     
#     
#     ${tti_ana}   get_tti_analyzer    ${local_csv_file_path}
#     ${check}=   Call Method    ${tti_ana}    check_SLIV_in_dlFdSchedData
#     ...   special_slots=${special_slots}   expected_SLIVs=${expected_SLIVs}
#     Should be True   ${check}
#     Modify actEnhancedPDSCHSchSplSlot Parameter    actEnhancedPDSCHSchSplSlot=false
#     CB009218_Common_KW.Start L3Call and DL small packet    throughput=1000M
#     Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
#     Sleep    ${log_capture_time}
#     ${tti_trace}=    Stop TTI Traces in Streaming mode
#     ...  tti_trace_path=${TS_CASE_LOG_PATH}
#     Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
#     ...   options=-d dl
#     set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv
#     CB009218_Common_KW.Stop L3Call and DL Traffic
#     
# 
#     ${tti_ana}   get_tti_analyzer    ${local_csv_file_path}
#     ${check}=   Call Method    ${tti_ana}    check_SLIV_in_dlFdSchedData
#     ...   special_slots=${special_slots}   expected_SLIVs=${expected_SLIVs}
#     Should be True   '${check}'=='False'
#     [Teardown]    SISO Coam Test Teardown
# 
# 
# *** Keywords ***
