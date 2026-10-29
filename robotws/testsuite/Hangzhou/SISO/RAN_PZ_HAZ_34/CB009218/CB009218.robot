*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
#Test Setup           SISO Coam Test Setup
#Test Teardown        SISO Coam Test Teardown
Test Timeout         100 min

Resource     ../CB006277/resource/resources_l3call.robot
#Resource     ../../common/siso_resource.robot
Resource    ./resource/CB009218_Common_KW.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB009218 in 5G23R1 program

Force Tags    5G_RAN_TDD

*** Variables ***

*** Test Cases ***

[1]CB009218-A_09_Activation of Enhanced PDSCH scheduling on special slot
    [Tags]    2S-1CC_CB009218-A    master_classicalbts_all    CRT_TRUNK    CRT_22R4
    [Setup]    SISO Coam Test Setup
    ${special_slots}    create list    ${3}   ${7}   ${13}   ${17}
#    ${expected_SLIVs}    create list    ${53}   ${96}   ${53}   ${96}
    ${expected_SLIVs}    create list    ${57}   ${96}   ${57}   ${96}
    Modify actEnhancedPDSCHSchSplSlot Parameter    actEnhancedPDSCHSchSplSlot=true
    sleep    5s
    ${cell_list}    create list    ${1}
    Set Test Variable     ${ue_type}    nokia_cpe
    CB009218_Common_KW.Start L3Call and DL small packet    throughput=1000M
    Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
    Sleep    ${log_capture_time}
    ${tti_trace}=    Stop TTI Traces in Streaming mode
    ...  tti_trace_path=${TS_CASE_LOG_PATH}
    Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
    ...   options=-d dl
    set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv

    CB009218_Common_KW.Stop L3Call and DL Traffic
    ${tti_ana}   get_tti_analyzer    ${local_csv_file_path}
    ${check}=   Call Method    ${tti_ana}    check_SLIV_in_dlFdSchedData
    ...   special_slots=${special_slots}   expected_SLIVs=${expected_SLIVs}
    Should be True   ${check}
    Modify actEnhancedPDSCHSchSplSlot Parameter    actEnhancedPDSCHSchSplSlot=false
    CB009218_Common_KW.Start L3Call and DL small packet    throughput=1000M

    Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
    Sleep    ${log_capture_time}
    ${tti_trace}=    Stop TTI Traces in Streaming mode
    ...  tti_trace_path=${TS_CASE_LOG_PATH}
    Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
    ...   options=-d dl
    set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv
    CB009218_Common_KW.Stop L3Call and DL Traffic
    
    ${tti_ana}   get_tti_analyzer    ${local_csv_file_path}
    ${check}=   Call Method    ${tti_ana}    check_SLIV_in_dlFdSchedData
    ...   special_slots=${special_slots}   expected_SLIVs=${expected_SLIVs}
    Should be True   '${check}'=='False'
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown
[1]CB009218-A_06_L3call_with_PrachConifigIndex_Format_A2_100MHz
    [Tags]    master_classicalbts_all    CRT_TRUNK    CRT_22R4
    [Setup]    SISO Coam Test Setup
#    General_gnb_can_be_on_air_with_Given_Information    frame_structure=1116_3ms_GP2_A6    prach_index=98
#	...    band=40
	Modify prachConfigurationIndex Parameter    prachConfigurationIndex=98
    sleep    5s
    ${cell_list}    create list    ${1}
    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
    [Teardown]    SISO Coam Test Teardown
[1]CB009218-A_07_L3call_with_PrachConifigIndex_Format_C2_100MHz
    [Tags]    master_classicalbts_all    CRT_TRUNK    CRT_22R4
    [Setup]    SISO Coam Test Setup
    Modify prachConfigurationIndex Parameter    prachConfigurationIndex=191
    sleep    5s
    ${cell_list}    create list    ${1}
    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
    [Teardown]    SISO Coam Test Teardown
[1]CB009218-A_03_L3call_with_PrachConifigIndex_Format_B4_100MHz_A9_2cc
    [Tags]    master_classicalbts_all    CRT_TRUNK    CRT_22R4    1S-2CC_CB009218-A
    [Setup]    SISO Coam Test Setup
    Modify prachConfigurationIndex Parameter    prachConfigurationIndex=160
    sleep    5s
    ${cell_list}    create list    ${1}
    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
    [Teardown]    SISO Coam Test Teardown

*** Keywords ***
