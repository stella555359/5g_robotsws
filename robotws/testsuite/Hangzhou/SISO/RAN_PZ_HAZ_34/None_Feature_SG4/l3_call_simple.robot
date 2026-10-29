# *** Settings ***
# Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
# Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# 
# Documentation
# ...    Author:tingting zhong
# ...    contact:tingting.zhong@nokia-sbell.com
# ...    squad group:SG_04
# 
# Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]l3_call
#     test l3 call
# 
# *** Keywords ***
# test l3 call
#     [Arguments]    ${ue_index}=${0}    ${dl_tp}=100    ${ul_tp}=10    ${duration}=30    ${target_avg_percent}=0.5
#     log to console    \n***Prepare UE***
#     ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
#     log to console    \n***UE Attach***
#     power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}     log_type=Iperf
#     log to console    \n***start traffic***
#     ${start_traffic_duration}    evaluate    ${duration}+${120}
#     power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
#     ...    duration=${start_traffic_duration}    ue_index=${ue_index}
#     power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
#     ...    duration=${start_traffic_duration}    ue_index=${ue_index}
#     power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}    check_source=Iperf
#     log to console    \n***Stop traffic ***
#     power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
#     power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
#     log to console    \n***check log***
#     power_ue.Check Tput    ue_type=${ue_type}    direction=dl    target_throughput=${dl_tp}
#     ...    target_avg_percent=${target_avg_percent}    ue_index=${ue_index}
#     power_ue.Check Tput    ue_type=${ue_type}    direction=ul    target_throughput=${ul_tp}
#     ...    target_avg_percent=${target_avg_percent}    ue_index=${ue_index}
#     log to console    \n***UE Detach ***
#     power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
