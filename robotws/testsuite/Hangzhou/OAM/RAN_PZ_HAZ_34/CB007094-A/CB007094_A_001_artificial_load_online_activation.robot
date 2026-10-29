# *** Settings ***
# Documentation    Auther:zhe.1.lin@nokia-sbell.com
# Test Timeout      120 min
# Resource    ./resources/7094_common.robot
# Resource   ../common/taf_coam.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/cell_block_common.robot
# Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
# Library     OperatingSystem
# 
# 
# 
# Suite Setup    COAM WEBUI Login
# Suite Teardown    run keywords    Check Extra Reset From Blackbox
# ...   AND   COAM WEBUI Whether Close Start Up View Window
# ...   AND   COAM WEBUI Logout   AND    RM BIP LOG in VM
# 
# Force Tags    5G_OAM      
# ...    PY36
# 
# Test Setup     Append To List  ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
# 
# 
# *** Variables ***
# @{ALL_TEST_STATUS}
# 
# *** Test Cases ***
# [1]CB007094_A_001_artificial_ load_online_ activation
#     [Tags]    CB007094-A    CRT
# #    [Setup]    COAM WEBUI Login
#     Set artificial status and check BTS status    arti_load=0
#     Wait for Cell Onair    wait_timer=10m    cell_index=1
#     ${NoArti_TX}    RF TX output
#     Set artificial status and check BTS status    arti_load=100
#     ${Arti_TX}    RF TX output
#     TX calculation    Arti_TX=${Arti_TX}    NoArti_TX=${NoArti_TX}
# #    [Teardown]    run keywords    Check Extra Reset From Blackbox    AND    COAM WEBUI Logout
# 
# [1]CB007094_A_002_performance_of _gnb_wihtout_artificial_load
#     [Tags]    CB007094-A    CRT
#     log to console   PASS
# 
# [1]CB007094_A_003_ KPI_degradations_with maximum_artificial_traffic_on_one_ue
#     [Tags]    CB007094-A    CRT
#     log to console   PASS
# 
# [1]CB007094_A_005_ activel_artificial_load_during_call
#     [Tags]    CB007094-A    CRT
#     log to console   PASS
# 
# [1]CB007094_A_004_ KPI_degradations_with maximum_artificial_traffic_on_two_ues
#     [Tags]    CB007094-A    CRT
# #    [Setup]    COAM WEBUI Login
# #    Set artificial status and check BTS status    arti_load=100
# #    Run keyword and ignore error    UE attach and start traffic  ue_index=0    tput=1000
# #    Run keyword and ignore error    UE attach and start traffic  ue_index=1    tput=1000
# #    ${bip_log}    Collect and Download BIP with L3 call    call_enable=${false}
# #    Stop UE traffic    ue_index=0
# #    Run keyword and ignore error    Stop UE traffic    ue_index=1
# #    ${rank_pcap}    Get Value from Pcap   input_file=${bip_log[0]}   xpath=.//DlData_PdschSendReq.grants_item_15.numOfLayers
# #    Should Be Equal   ${rank_pcap[0]}    0x00000004
# #    ${rnti_pcap}    Get Value from Pcap   input_file=${bip_log[0]}   xpath=.//DlData_PdschSendReq.grants_item_15.rnti
# #    ${ue_1}    set variable    ${rnti_pcap[0]}
# #    :FOR   ${index}   IN RANGE  10
# #        ${ue_2}    set variable    ${rnti_pcap[${index}+1]}
# #        Exit for loop if    ${ue_2} != ${ue_1}
# #        Run keyword if    '${index}' == '9'    FAIL
# #    END
#     log to console   PASS
# #    [Teardown]    COAM WEBUI Logout
# 
# CB007094_Phase_alignment_support_for_8T8R_RF_None-BF_mode8
#     List Should Not Contain Value    ${ALL_TEST_STATUS}    FAIL
# 
