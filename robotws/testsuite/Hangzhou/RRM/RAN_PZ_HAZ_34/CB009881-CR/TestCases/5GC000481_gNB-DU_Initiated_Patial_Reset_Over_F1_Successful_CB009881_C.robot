# *** Settings ***
# Documentation      Author: yishuang.wang@nokia-sbell.com
# ...                squad group: SG_03
# ...                feature : CB009881
# 
# 
# Suite Setup    Common Suite Setup for Cloud
# 
# Suite Teardown
# 
# Resource    ../Resources/HO_common_keywords.robot
# 
# 
# 
# *** Variables ***
# ${cu_f1_01}          9881_cu_f1.pcap
# 
# 
# *** Test Cases ***
# [1]5GC000481_gNB-DU_Initiated_Patial_Reset_Over_F1_Successful_CB009881_C
#     [Documentation]
#     ...    intra freq intra gnb gnb1 cell1 to cell2 in intra DU
#     [Tags]
#     [Setup]
#     BTS preparation per cu    vdu_count=${1}    cu_count=${1}    gnb_index=${0}
#     PA preparation
# #    Start Capture Wireshark Logs on cu    f1log=${cu_f1_01}
#     sleep    10s
#     Precondition for power UE    ue_type=${ue_type}
#     HO_common_keywords.Attach and check power UE    ue_type=${ue_type}
#     Start traffic with power UE
# #    Stop Capture Wireshark Logs on cu    f1log=${cu_f1_01}
#     Check throughput with power UE    ultarget_throughput=25   dltarget_throughput=90
#     [Teardown]    run keywords    run keyword and ignore error      HO_common_keywords.Stop traffic with power UE   AND
#     ...    run keyword and ignore error    UE Detach with power UE
# 
# *** Keywords ***