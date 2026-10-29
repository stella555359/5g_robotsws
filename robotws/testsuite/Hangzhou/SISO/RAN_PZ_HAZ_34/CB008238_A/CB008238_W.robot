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
# 
# *** Test Cases ***
# [1]CB008238-5G-W_01_01_Single-UE_Micro-DTX_optimized_scheduler_Classical_E2E_unscheduled_ping_latency_for_TDD_FR1_5GC001208
#     [Tags]    master_classicalbts_all    CRT_TRUNK
#     [Setup]    SISO Coam Test Setup
#     General_gnb_can_be_on_air_with_Given_Information    band=100   frame_structure=1208_GP1_A1   dl_ul_layer=4DL4UL
# 	...    prach_index=${92}
#     Selenium Login And Disable Screen Lock
#     Modify actProactUlScheduling Parameter    actProactUlScheduling=false    ulSchedTimeInterval=40    ulProGrantTimer=3000
#     Modify actCDrx Parameter    actCDrx=false    drxLongCycle=160ms    drxOnDurationTimer=10ms    drxInactivityTimer=80ms
#     Modify srPeriodicity Parameter    slots80
#     Modify csiReportPeriodicity Parameter    slots320
#     Modify pucchModeSelect Parameter    longPucch
#     Start L3Call and DL small packet    throughput=30M    ue_index=0
#     #${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
#     #power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
#     #${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}
#     Connect to EPC APP    ue_index=${0}
#     ${output}    Start Ping    ue_ip=${UE_IP}    count=10   packet_size=32
#     Check Ping Latency    output=${output}    latency_target=${41.1}
#     ${output}    Start Ping    ue_ip=${UE_IP}    count=10    packet_size=1350
#     Check Ping Latency    output=${output}    latency_target=${45}
#     csn.Disconnect    connection=EPCAPP
#     #power_ue.UE Detach  ue_type=${ue_type}    ue_index=${0}
#     Stop L3Call and DL Traffic    ue_index=0
#     [Teardown]    Run keywords     Selenium Logout And Close Browser
#     ...    AND   SISO Coam Test Teardown
# 
# #[1]CB008238-5G-W_01_05_Single-UE_Micro-DTX_optimized_scheduler_Classical_E2E_scheduled_ping_latency_for_TDD_FR1_5GC001208
# #    [Tags]    master_classicalbts_all    CRT_TRUNK    1S-2CC-4D-4U
# #    [Setup]    SISO Coam Test Setup
# #    General_gnb_can_be_on_air_with_Given_Information    band=100   frame_structure=1208_GP1_A1   dl_ul_layer=4DL4UL
# #	...    prach_index=${92}
# #    Selenium Login And Disable Screen Lock
# #    Modify actProactUlScheduling Parameter    actProactUlScheduling=true    ulSchedTimeInterval=40    ulProGrantTimer=3000
# #    Modify actCDrx Parameter    actCDrx=true    drxLongCycle=320ms    drxOnDurationTimer=10ms    drxInactivityTimer=200ms
# #    Modify srPeriodicity Parameter    slots80
# #    Modify csiReportPeriodicity Parameter    slots320
# #    Modify pucchModeSelect Parameter    longPucch
# #    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
# #    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
# #    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}
# #    Connect to EPC APP    ue_index=${0}
# #    ${output}    Start Ping    ue_ip=${UE_IP}    count=10   packet_size=32
# #    Check Ping Latency    output=${output}    latency_target=${21.1}
# #    ${output}    Start Ping    ue_ip=${UE_IP}    count=10    packet_size=1350
# #    Check Ping Latency    output=${output}    latency_target=${25}
# #    csn.Disconnect    connection=EPCAPP
# #    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${0}
# #    [Teardown]    Run keywords     Selenium Logout And Close Browser
# #        AND   SISO Coam Test Teardown
# *** Keywords ***
# 
