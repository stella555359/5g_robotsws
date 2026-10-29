# *** Settings ***
# Force Tags    PY36
# Documentation
# ...    author: Jiang Hongyu
# ...    contact: hongyu.jiang@nokia-sbell.com
# ...    squad group: MMW_SG_04
# ...    feature : 5GC002637-A
# 
# Resource           ./Resources/5GC000884_common_keywords.robot
# Variables          ./Resources/5GC000884_modify_para.py
# Library            ./Resources/5GC000884_common_keywords.py
# 
# Suite Setup    Common Case Setup
# Suite Teardown
# 
# *** Test Cases ***
# [1]CB008423_5GC000884_04_Uplink_Closed_Loop_Power_Control_for_PUSCH_TDD_SA_CPRI
#     [Tags]  CRT_22R2
#     [Setup]  Case Setup_SA    flag=SA
#     Modify Value On DU    common_modify_list=${case4_common}    is_structure=${False}
#     attach multi power ue    ue_num=${1}
#     start multi power ue traffic ul and dl    ue_num=${1}    ul_throughput=100M   dl_throughput=500M    ul_duration=600    dl_duration=600
#     Case1 Adjust the HBTE attenuation    direction=UL
#     stop multi power ue traffic ul and dl    ue_num=${1}
#     [Teardown]    Commmon Case Teardown
# 
# [1]CB008423_5GC000884_05_Uplink_Closed_Loop_Power_Control_for_PUCCH_TDD_SA_CPRI
#     [Tags]  CRT_22R2    CRT_TRUNK    CRT_22R3     CRT_22R4
#     [Setup]  Case Setup_SA    flag=SA
#     Modify Value On DU    common_modify_list=${case5_common}    is_structure=${False}
#     attach multi power ue    ue_num=${1}
#     start multi power ue traffic ul and dl    ue_num=${1}    ul_throughput=100M   dl_throughput=500M    ul_duration=600    dl_duration=600
#     Case1 Adjust the HBTE attenuation    direction=DL
#     stop multi power ue traffic ul and dl    ue_num=${1}
#     [Teardown]    Commmon Case Teardown
# 
# [1]CB008423_5GC000884_01_Uplink_Closed_Loop_Power_Control_for_PUSCH_TDD_NSA_CPRI
#     [Tags]  CRT_22R2    CRT_TRUNK    CRT_22R3    CRT_22R4
#     [Setup]    Case Setup_NSA    flag=NSA
#     Modify Value On DU    common_modify_list=${case1_common}    is_structure=${False}
#     attach multi power ue    ue_num=${1}
#     start multi power ue traffic ul and dl    ue_num=${1}    ul_throughput=100M   dl_throughput=500M    ul_duration=600    dl_duration=600
#     Case1 Adjust the HBTE attenuation    direction=UL
#     stop multi power ue traffic ul and dl    ue_num=${1}
#     [Teardown]    Commmon Case Teardown
# 
# [1]CB008423_5GC000884_02_Uplink_Closed_Loop_Power_Control_for_PUCCH_TDD_NSA_CPRI
#     [Tags]  CRT_22R2
#     [Setup]  Case Setup_NSA    flag=NSA
#     Modify Value On DU    common_modify_list=${case2_common}    is_structure=${False}
#     attach multi power ue    ue_num=${1}
#     start multi power ue traffic ul and dl    ue_num=${1}    ul_throughput=100M   dl_throughput=500M    ul_duration=600    dl_duration=600
#     Case1 Adjust the HBTE attenuation    direction=DL
#     stop multi power ue traffic ul and dl    ue_num=${1}
#     [Teardown]    Commmon Case Teardown
# 
# 
# 
# 
# 
# 
