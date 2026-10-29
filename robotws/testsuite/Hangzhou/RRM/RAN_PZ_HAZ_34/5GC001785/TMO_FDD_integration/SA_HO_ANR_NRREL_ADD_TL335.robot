# *** Settings ***
# Documentation
# ...    author: Ming Shi
# ...    contact:ming.shi@nokia-sbell.com
# ...    squad group: 5G_PZ_HZ_3_SG
# ...    feature : TMO_Non_Feature
# 
# Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup    AND
# ...                            check SA or NSA suite name    AND
# ...                            FDD_TMO_common_keyword_new.Common Suite Setup for COAM    AND
# ...                            Prepare the gnb commission for SFE two testline    cell_type=${cell_type}
# 
# Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown    AND
# ...                               Run Keyword If Any Tests Failed    Teardown for case failure
# 
# 
# Resource    ../Resources/FDD_TMO_common_keyword_new.robot
# Resource    ../Resources/TDD_FDD_HO_common_keyword_new.robot
# Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/HBTE_PA_setting_335.py
# 
# 
# *** Variables ***
# @{pm_all_list}
# ${atten_ip}    ${tl.attenuator[0].ip_addr}     #atten1
# ${atten_ip2}    ${tl.attenuator[1].ip_addr}    #atten2
# ${att_api_port}    ${tl.attenuator[0].port}
# ${max_attenuation_value}    ${127}
# ${vendor}    ${tl.attenuators[0].vendor}
# ${interval}    12
# ${pa_settime}    0.6
# ${paerror_counter}    0
# ${ho_times}    4
# ${traffic_direction}    DL
# ${cell_type}    SA
# 
# *** Test Cases ***
# [1]CB007835_5G_A_SA_ANR_NRREL_ADD_FOR_ALL_HO_SCENARIO
#     [Documentation]    CELL1-CELL3 Intra F (FDD-FDD) intra gnb HO
#     [Timeout]    10 hour
#     [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_23R3    CRT_23R4
#     [Setup]
#     robot_common_operations.Common Case Setup
#     set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
#     make multi ues network with single pc    control_pc_ip=${control_pc_ip3352}    action_index=${0}
#     Adjust_HBTE_PA with loop    pa_name=${gnb1_cell3_pa_info}    s_value=${gnb1_cell3_pa_value}[setup][1]
#     ...    e_value=${gnb1_cell3_pa_value}[setup][2]    step=${gnb1_cell3_pa_info}[step][0]    ho_times=${ho_times}
# 
#     set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
#     Adjust_HBTE_PA with loop    pa_name=${gnb1_cell302_pa_info }    s_value=${gnb1_cell302_pa_value}[setup][1]
#     ...    e_value=${gnb1_cell302_pa_value}[setup][2]    step=${gnb1_cell302_pa_info}[step][0]    ho_times=${ho_times}
# 
#     set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
#     Adjust_HBTE_PA with loop    pa_name=${gnb1_cell301_pa_info}    s_value=${gnb1_cell301_pa_value}[setup][1]
#     ...    e_value=${gnb1_cell301_pa_value}[setup][2]    step=${gnb1_cell301_pa_info}[step][0]    ho_times=${ho_times}
# 
#     set all PA ports and one cell set designated value    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][0]
#     Adjust_HBTE_PA with loop    pa_name=${gnb1_cell302_pa_info }    s_value=${gnb1_cell302_pa_value}[setup][1]
#     ...    e_value=${gnb1_cell302_pa_value}[setup][2]    step=${gnb1_cell302_pa_info}[step][0]    ho_times=${ho_times}
# 
#     set all PA ports and one cell set designated value    pa_name=${gnb1_cell2_pa_info}    value=${gnb1_cell2_pa_value}[setup][0]
#     Adjust_HBTE_PA with loop    pa_name=${gnb1_cell302_pa_info }    s_value=${gnb1_cell302_pa_value}[setup][1]
#     ...    e_value=${gnb1_cell302_pa_value}[setup][2]    step=${gnb1_cell302_pa_info}[step][0]    ho_times=${ho_times}
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#     ...    multi_all_ues_network_operate    action_index=${1}    AND
# #    ...    sleep    1min    AND
#     ...    PA recover
# 
# *** Keywords ***
