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
# ...                            get traffic direction and ho times    cell_type=SA    AND
# ...                            get value of control parameter    AND
# ...                            check and prepare the gnb commission for SFE two testline
# 
# Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown    AND
# #...                               check hanging resource    AND
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
# #${ho_times}    10
# 
# *** Test Cases ***
# [1]CB007835_5G_A_001_SA_intragnb_intrafre_FDD_HO_FDD_704_stability
#     [Documentation]    CELL1-CELL3 Intra F (FDD-FDD) intra gnb HO
#     [Timeout]    10 hour
#     [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_23R3    CRT_23R4
#     [Setup]
#     robot_common_operations.Common Case Setup
#     set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
#     Prepare all online UE with data start    cell_type=SA
#     Adjust_HBTE_PA with loop    pa_name=${gnb1_cell3_pa_info}    s_value=${gnb1_cell3_pa_value}[setup][1]
#     ...    e_value=${gnb1_cell3_pa_value}[setup][2]    step=${gnb1_cell3_pa_info}[step][0]    ho_times=${ho_times}
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#     ...    multi_all_ues_network_operate    action_index=${1}    AND
# #    ...    sleep    1min    AND
#     ...    PA recover
# 
# 
# [1]CB007835_5G_A_002_SA_intergnb_interfre_FDD_HO_TDD_706_stability
#     [Documentation]    CELL1-CELL441 Inter F(FDD-TDD) intra gnb HO
#     [Timeout]    10 hour
#     [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_23R3    CRT_23R4
#     [Setup]
#     robot_common_operations.Common Case Setup
#     set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][1]
#     Prepare all online UE with data start    cell_type=SA
#     Make mutil UE for EMC Setup
#     Adjust_HBTE_PA with loop    pa_name=${gnb1_cell302_pa_info }    s_value=${gnb1_cell302_pa_value}[setup][1]
#     ...    e_value=${gnb1_cell302_pa_value}[setup][2]    step=${gnb1_cell302_pa_info}[step][0]    ho_times=${ho_times}
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#     ...    hang up mutil UE for EMC Setup    AND
#     ...    multi_all_ues_network_operate    action_index=${1}    AND
# #    ...    sleep    1min    AND
#     ...    PA recover
# 
# [1]CB007835_5G_A_007_SA_intragnb_intrafre_FDD_HO_FDD_784_EC_call
#     [Documentation]    CELL1-CELL441 Inter F(FDD-TDD) inter gnb HO
#     [Timeout]    10 hour
#     [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_23R4
#     [Setup]
#     robot_common_operations.Common Case Setup
#     set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][1]
#     Prepare all online UE with data start test    cell_type=SA
# #    Make mutil UE for EMC Setup
# #    Adjust_HBTE_PA with loop    pa_name=${gnb2_cell441_pa_info}    s_value=${gnb2_cell441_pa_value}[setup][1]
# #    ...    e_value=${gnb2_cell441_pa_value}[setup][2]    step=${gnb2_cell441_pa_info}[step][0]    ho_times=${ho_times}
# #    set PA port on one cell    pa_name=${gnb2_cell441_pa_info}    value=${gnb2_cell441_pa_value}[max]
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#     ...    sleep    1min    AND
#     ...    PA recover
# 
# [1]CB007835_5G_A_003_SA_intragnb_interfre_FDD_HO_TDD_706_stability
#     [Documentation]    CELL1-CELL301 Inter F(FDD-TDD) intra gnb HO
#     [Timeout]    10 hour
#     [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_23R3    CRT_23R4
#     [Setup]
#     robot_common_operations.Common Case Setup
#     set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
#     Prepare all online UE with data start    cell_type=SA
#     Make mutil UE for VoNR Setup
#     Adjust_HBTE_PA with loop    pa_name=${gnb1_cell301_pa_info}    s_value=${gnb1_cell301_pa_value}[setup][1]
#     ...    e_value=${gnb1_cell301_pa_value}[setup][2]    step=${gnb1_cell301_pa_info}[step][0]    ho_times=${ho_times}
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#     ...    multi_all_ues_network_operate    action_index=${1}    AND
#     ...    hang up mutil UE for VoNR Setup    AND
# #    ...    sleep    1min    AND
#     ...    PA recover
# 
# [1]CB007835_5G_A_007_SA_intragnb_intrafre_FDD_HO_FDD_6112_VoNR
#     [Documentation]    CELL1-CELL3 Intra F (FDD-FDD) intra gnb HO
#     [Timeout]    10 hour
#     [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
#     [Setup]
#     robot_common_operations.Common Case Setup
#     set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
#     Prepare all online UE with data start test    cell_type=SA
# #    Prepare all online UE with data start    cell_type=SA
# #    Make mutil UE for VoNR Setup
# #    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
# #    Adjust_HBTE_PA with loop    pa_name=${gnb1_cell3_pa_info}    s_value=${gnb1_cell3_pa_value}[setup][1]
# #    ...    e_value=${gnb1_cell3_pa_value}[setup][2]    step=${gnb1_cell3_pa_info}[step][0]    ho_times=${ho_times}
# #    set PA port on one cell    pa_name=${gnb1_cell3_pa_info}    value=${gnb1_cell3_pa_value}[max]
# 
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#     ...    sleep    1min    AND
#     ...    PA recover
# 
# [1]CB007835_5G_A_004_SA_intergnb_intrafre_TDD_HO_TDD_704_stability
#     [Documentation]    CELL301-CELL441 intra F (TDD-TDD) inter gnb HO via Xn
#     [Timeout]    10 hour
#     [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_23R3    CRT_23R4
#     [Setup]
#     robot_common_operations.Common Case Setup
#     set all PA ports and one cell set designated value    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][0]
#     Prepare all online UE with data start    cell_type=SA
#     Adjust_HBTE_PA with loop    pa_name=${gnb1_cell302_pa_info }    s_value=${gnb1_cell302_pa_value}[setup][1]
#     ...    e_value=${gnb1_cell302_pa_value}[setup][2]    step=${gnb1_cell302_pa_info}[step][0]    ho_times=${ho_times}
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#     ...    multi_all_ues_network_operate    action_index=${1}    AND
# #    ...    sleep    1min    AND
#     ...    PA recover
# 
# [1]CB007835_5G_A_005_SA_intergnb_interfre_FDD_HO_TDD_NG_705_stability
#     [Documentation]    CELL2-CELL441 Inter F(FDD-TDD) inter gnb HO via NG
#     [Timeout]    10 hour
#     [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_23R3    CRT_23R4
#     [Setup]
#     robot_common_operations.Common Case Setup
#     set all PA ports and one cell set designated value    pa_name=${gnb1_cell2_pa_info}    value=${gnb1_cell2_pa_value}[setup][2]
#     Prepare all online UE with data start    cell_type=SA
#     Adjust_HBTE_PA with loop    pa_name=${gnb1_cell302_pa_info }    s_value=${gnb1_cell302_pa_value}[setup][1]
#     ...    e_value=${gnb1_cell302_pa_value}[setup][2]    step=${gnb1_cell302_pa_info}[step][0]    ho_times=${ho_times}
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#     ...    multi_all_ues_network_operate    action_index=${1}    AND
# #    ...    sleep    1min    AND
#     ...    PA recover
# 
# #[1]CB007835_5G_A_006_SA_intragnb_interfre_TDD_HO_TDD_706_stability
# #    [Documentation]    CELL5-CELL4 Inter F(TDD-TDD) intra gnb HO via Xn
# #    [Timeout]    10 hour
# #    [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
# #    [Setup]
# #    set all PA ports and one cell set designated value    pa_name=${gnb1_cell302_pa_info}    value=${gnb1_cell302_pa_value}[setup][0]
# #    Prepare all online UE with data start    cell_type=SA    ue_number=partial
# #    Adjust_HBTE_PA with loop    pa_name=${enb1_cell221_pa_info}    s_value=${enb1_cell221_pa_value}[setup][1]
# #    ...    e_value=${enb1_cell221_pa_value}[setup][2]    step=${enb1_cell221_pa_info}[step][0]    ho_times=${ho_times}
# #    set PA port on one cell    pa_name=${enb1_cell221_pa_info}    value=${enb1_cell221_pa_value}[max]
# #    [Teardown]    Run Keywords    multi_all_ues_network_operate    action_index=${1}    ue_number=partial    AND
# #    ...    PA recover
# *** Keywords ***
