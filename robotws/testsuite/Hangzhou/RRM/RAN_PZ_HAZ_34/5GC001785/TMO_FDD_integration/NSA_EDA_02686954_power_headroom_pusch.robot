# *** Settings ***
# Documentation
# ...    author: Ming Shi
# ...    contact:ming.shi@nokia-sbell.com
# ...    squad group: 5G_PZ_HZ_3_SG
# ...    feature : TMO_Non_Feature
# 
# Suite Setup    Run Keywords     robot_common_operations.Common Suite Setup    AND
# ...                             check SA or NSA suite name    AND
# ...                             FDD_TMO_common_keyword_new.Common Suite Setup for COAM    AND
# ...                             PA preparation    cell_type=NSA    AND
# ...                             sleep    1min    AND
# ...                             Prepare all online UE with UL data start    cell_type=NSA    AND
# ...                             Prepare with PM counter time caculate    period=start
# 
# Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown    AND
# ...                               Add time list NSA    AND    Add counters list NSA    AND
# ...                               Prepare with PM counter time caculate    period=end    AND
# ...                               Get all the counters and add in excel    celltype=NSA    timeout=600    AND
# ...                               backup NSA counter excel    celltype=NSA    AND
# ...                               set redundant value to 0    celltype=NSA    AND
# #...                               upload_kpi_to_compass    celltype=NSA    AND
# ...                               multi_all_ues_network_operate    action_index=${1}    AND
# ...                               PA recover    AND
# ...                               Run Keyword If Any Tests Failed    Teardown for case failure
# 
# Resource    ../Resources/FDD_TMO_common_keyword_new.robot
# Resource    ../Resources/TDD_FDD_HO_common_keyword_new.robot
# Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/HBTE_PA_setting_375.py
# 
# 
# *** Variables ***
# @{pm_all_list}
# ${atten_ip}    ${tl.attenuator[0].ip_addr}     #atten1
# ${atten_ip2}    ${tl.attenuator[1].ip_addr}    #atten2
# ${att_api_port}    ${tl.attenuator[0].port}
# ${max_attenuation_value}    ${127}
# ${vendor}    ${tl.attenuators[0].vendor}
# ${interval}    9
# ${pa_settime}    0.6
# ${paerror_counter}    0
# #${ho_times}    10
# 
# *** Test Cases ***
# [1]CB007835_5G_A_015_NSA_EDA_02686954_ power_headroom_pusch
#     [Documentation]    CELL1
#     [Timeout]    10 hour
#     [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R1
#     [Setup]
#     robot_common_operations.Common Case Setup
#     ${time7_start}=    Get Time
#     check actual UE num and which ue is not available
#     set PA port on one cell    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][1]
#     set PA port on one cell    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[max]
#     sleep    20min
#     ${time7_end}=    Get Time
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#     ...    Add the PM counter list    pm_counters=${NSA_EDA_02686954}    AND
#     ...    get_counter_name_per_scenario    pm_counters=${NSA_EDA_02686954}    index=${7}    AND
#     ...    Set Suite Variable    ${time7_start}    AND
#     ...    Set Suite Variable    ${time7_end}
# 
# *** Keywords ***
# 
