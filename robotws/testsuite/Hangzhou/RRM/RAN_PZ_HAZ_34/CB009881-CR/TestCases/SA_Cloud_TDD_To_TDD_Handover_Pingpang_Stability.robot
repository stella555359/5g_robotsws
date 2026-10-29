# *** Settings ***
# Documentation      Author: yishuang.wang@nokia-sbell.com
# ...                squad group: SG_03
# ...                feature : CB009881
# 
# 
# Suite Setup    Run keywords    Common Suite Setup for Cloud    AND
# ...                            Get golden scf path and control parameter    AND
# ...                             multi_ues_operation_exe_with_threading    action=${ue_action}[1]     AND
# ...                            Check and prepare for gnb    AND
# ...                            PA preparation    AND
# ...                            Prepare with PM counter time caculate    period=start
# 
# Suite Teardown    Run Keywords    run keyword and ignore error    Add time list    AND
# ...                               run keyword and ignore error    Add ue list    AND
# ...                               Prepare with PM counter time caculate    period=end    AND
# ...                               Get all the counters and add in excel    celltype=SA    AND
# ...                               run keyword and ignore error    upload_kpi_to_compass    celltype=SA    AND
# ...                               check_resources_leakage_aic    AND
# ...                               run keyword and ignore error    SCF recovery
# 
# 
# Resource    ../Resources/HO_common_keywords.robot
# 
# 
# *** Variables ***
# @{pm_all_list}
# ${traffic_direction}    DLUL
# ${atten_ip}    ${tl.attenuator[0].ip_addr}
# ${att_api_port}    ${tl.attenuator[0].port}
# ${max_attenuation_value}    ${127}
# ${vendor}    ${tl.attenuators[0].vendor}
# ${interval}    12
# ${pa_settime}    0.6
# ${paerror_counter}    0
# 
# *** Test Cases ***
# [1]CB009881_CR_SCE2_SA_Cloud_intrafre_intragnb_interDU_HO_704
#     [Documentation]
#     ...    intra freq intra gnb inter DU HO gnb1 cell1 to gnb1 cell3
#     [Tags]    CRT_TRUNK
#     [Setup]
#     ${time2_start}=    Get Time
#     ${ue_num_SCE2}=    Check actual UE num with pc reset
#     set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
#     Prepare all online UE with data start
#     Adjust_HBTE_PA with loop    pa_name=${gnb1_cell3_pa_info}    s_value=${gnb1_cell3_pa_value}[setup][1]
#     ...    e_value=${gnb1_cell3_pa_value}[setup][2]    step=${gnb1_cell3_pa_info}[step][1]    ho_times=${ho_times}
#     sleep    5s
# 
#     ${time2_end}=    Get Time
#     [Teardown]    Run Keywords    Add the PM counter list    pm_counters=${SA_HO_SCE2}    AND
#     ...    Set Suite Variable    ${time2_start}    AND
#     ...    Set Suite Variable    ${time2_end}   AND
#     ...    Set Suite Variable    ${ue_num_SCE2}    AND
#     ...    Stop all online UE DL data transfer    ue_num=${3}    AND
#     ...    multi_ues_operation_exe_with_threading    action=${ue_action}[1]    AND
#     ...    PA recover    AND
#     ...    run keyword and ignore error    Collect CU Snapshot Log
# 
# 
# [1]CB009881_CR_SCE3_SA_Cloud_intrafre_intergnb_HO_via_Xn_704
#     [Documentation]
#     ...    intra freq inter gnb HO gnb1 cell2 to gnb2 cell4
#     [Tags]    CRT_TRUNK
#     [Setup]
#     ${time3_start}=    Get Time
#     ${ue_num_SCE3}=    Check actual UE num with pc reset
#     set all PA ports and one cell set designated value    pa_name=${gnb1_cell2_pa_info}    value=${gnb1_cell2_pa_value}[setup][0]
#     Prepare all online UE with data start
#     Adjust_HBTE_PA with loop    pa_name=${gnb2_cell4_pa_info}    s_value=${gnb2_cell4_pa_value}[setup][1]
#     ...    e_value=${gnb2_cell4_pa_value}[setup][2]    step=${gnb2_cell4_pa_info}[step][1]    ho_times=${ho_times}
#     sleep    5s
#     ${time3_end}=    Get Time
#     [Teardown]    Run Keywords    Add the PM counter list    pm_counters=${SA_HO_SCE3}    AND
#     ...    Set Suite Variable    ${time3_start}    AND
#     ...    Set Suite Variable    ${time3_end}   AND
#     ...    Set Suite Variable    ${ue_num_SCE3}    AND
#     ...    Stop all online UE DL data transfer    ue_num=${3}    AND
#     ...    multi_ues_operation_exe_with_threading    action=${ue_action}[1]    AND
#     ...    PA recover    AND
#     ...    run keyword and ignore error    Collect CU Snapshot Log
# 
# [1]CB009881_CR_SCE4_SA_Cloud_interfre_intergnb_HO_via_Xn_706
#     [Documentation]
#     ...    inter freq inter gnb HO gnb1 cell1 to gnb2 cell4
#     [Tags]    CRT_TRUNK
#     [Setup]
#     ${time4_start}=    Get Time
#     ${ue_num_SCE4}=    Check actual UE num with pc reset
#     set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
#     Prepare all online UE with data start
#     Adjust_HBTE_PA with loop    pa_name=${gnb2_cell4_pa_info}    s_value=${gnb2_cell4_pa_value}[setup][1]
#     ...    e_value=${gnb2_cell4_pa_value}[setup][2]    step=${gnb2_cell4_pa_info}[step][1]    ho_times=${ho_times}
#     sleep    5s
#     ${time4_end}=    Get Time
#     [Teardown]    Run Keywords    Add the PM counter list    pm_counters=${SA_HO_SCE4}    AND
#     ...    Set Suite Variable    ${time4_start}    AND
#     ...    Set Suite Variable    ${time4_end}   AND
#     ...    Set Suite Variable    ${ue_num_SCE4}    AND
#     ...    Stop all online UE DL data transfer    ue_num=${3}    AND
#     ...    multi_ues_operation_exe_with_threading    action=${ue_action}[1]    AND
#     ...    PA recover    AND
#     ...    run keyword and ignore error    Collect CU Snapshot Log
# 
# 
# [1]CB009881_CR_SCE5_SA_Cloud_interfre_intragnb_interDU_HO_706
#     [Documentation]
#     ...    inter freq intra gnb inter DU HO gnb1 cell2 to gnb1 cell3
#     [Tags]    CRT_TRUNK
#     [Setup]
#     ${time5_start}=    Get Time
#     ${ue_num_SCE5}=    Check actual UE num with pc reset
#     set all PA ports and one cell set designated value    pa_name=${gnb1_cell2_pa_info}    value=${gnb1_cell2_pa_value}[setup][0]
#     Prepare all online UE with data start
#     Adjust_HBTE_PA with loop    pa_name=${gnb1_cell3_pa_info}    s_value=${gnb1_cell3_pa_value}[setup][1]
#     ...    e_value=${gnb1_cell3_pa_value}[setup][2]    step=${gnb1_cell3_pa_info}[step][1]    ho_times=${ho_times}
#     sleep    5s
#     ${time5_end}=    Get Time
#     [Teardown]    Run Keywords    Add the PM counter list    pm_counters=${SA_HO_SCE5}    AND
#     ...    Set Suite Variable    ${time5_start}    AND
#     ...    Set Suite Variable    ${time5_end}    AND
#     ...    Set Suite Variable    ${ue_num_SCE5}    AND
#     ...    Stop all online UE DL data transfer    ue_num=${3}    AND
#     ...    multi_ues_operation_exe_with_threading    action=${ue_action}[1]    AND
#     ...    PA recover    AND
#     ...    run keyword and ignore error    CU Save Snapshot
# 
# [1]CB009881_CR_SCE6_SA_Cloud_interfre_intragnb_intraDU_HO_706
#     [Documentation]
#     ...    inter freq intra gnb intra DU HO gnb1 cell1 to gnb1 cell2
#     [Tags]    CRT_TRUNK
#     [Setup]
#     ${time6_start}=    Get Time
#     set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
#     ${ue_num_SCE6}=    Check actual UE num with pc reset
#     Prepare all online UE with data start
#     Adjust_HBTE_PA with loop    pa_name=${gnb1_cell2_pa_info}    s_value=${gnb1_cell2_pa_value}[setup][1]
#     ...    e_value=${gnb1_cell2_pa_value}[setup][2]    step=${gnb1_cell2_pa_info}[step][1]    ho_times=${ho_times}
#     sleep    5s
#     ${time6_end}=    Get Time
#     [Teardown]    Run Keywords    Add the PM counter list    pm_counters=${SA_HO_SCE6}    AND
#     ...    Set Suite Variable    ${time6_start}    AND
#     ...    Set Suite Variable    ${time6_end}   AND
#     ...    Set Suite Variable    ${ue_num_SCE6}    AND
#     ...    Stop all online UE DL data transfer    ue_num=${3}    AND
#     ...    multi_ues_operation_exe_with_threading    action=${ue_action}[1]    AND
#     ...    PA recover    AND
#     ...    run keyword and ignore error    CU Save Snapshot
# 
# [1]CB009881_CR_SCE7_SA_Cloud_interfre_intergnb_HO_via_NG_705
#     [Documentation]
#     ...    inter freq inter gnb HO gnb1 cell1 to gnb2 cell4
#     [Tags]    CRT_TRUNK
#     [Setup]
#     run keyword and ignore error    CU online modify parameters    param=handoverAllowedSA
#     ...    value=XnHoNotAllowed    MO=MRBTS-${gnb1_id}/NRBTS-${gnb1_id}/NRCELL-1/NRREL-3
#     run keyword and ignore error    CU online modify parameters    param=handoverAllowedSA    value=XnHoNotAllowed
#     ...    MO=MRBTS-${gnb2_id}/NRBTS-${gnb2_id}/NRCELL-4/NRREL-1    gnb_index=${1}
#     ${time7_start}=    Get Time
#     ${ue_num_SCE7}=    Check actual UE num with pc reset
#     set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
#     Prepare all online UE with data start
#     Adjust_HBTE_PA with loop    pa_name=${gnb2_cell4_pa_info}    s_value=${gnb2_cell4_pa_value}[setup][1]
#     ...    e_value=${gnb2_cell4_pa_value}[setup][2]    step=${gnb2_cell4_pa_info}[step][1]    ho_times=${ho_times}
#     sleep    5s
#     ${time7_end}=    Get Time
#     [Teardown]    Run Keywords    Add the PM counter list    pm_counters=${SA_HO_SCE7}    AND
#     ...    Set Suite Variable    ${time7_start}    AND
#     ...    Set Suite Variable    ${time7_end}   AND
#     ...    Set Suite Variable    ${ue_num_SCE7}    AND
#     ...    Stop all online UE DL data transfer    ue_num=${3}    AND
#     ...    multi_ues_operation_exe_with_threading    action=${ue_action}[1]    AND
#     ...    PA recover    AND
#     ...    run keyword and ignore error    Collect CU Snapshot Log
# 
# [1]CB009881_CR_SCE1_SA_Cloud_intrafre_intragnb_intraDU_HO_704
#     [Documentation]
#     ...    intra freq intra gnb intra DU HO gnb1 cell1 to gnb1 cell2
#     [Tags]    CRT_TRUNK
#     [Setup]
#     run keyword and ignore error    CU online modify parameters    param=nrarfcn
#     ...    value=630700    MO=MRBTS-${gnb1_id}/NRBTS-${gnb1_id}/NRCELL-2
#     run keyword and ignore error    VDU online modify parameters    param=nrarfcn    value=630700    MO=MRBTS-${gnb1_id}/NRBTS-${gnb1_id}/NRCELL-2
#     ${time1_start}=    Get Time
#     ${ue_num_SCE1}=    Check actual UE num with pc reset
#     set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
#     Prepare all online UE with data start
#     Adjust_HBTE_PA with loop    pa_name=${gnb1_cell2_pa_info}    s_value=${gnb1_cell2_pa_value}[setup][1]
#     ...    e_value=${gnb1_cell2_pa_value}[setup][2]    step=${gnb1_cell2_pa_info}[step][1]    ho_times=${ho_times}
#     sleep    5s
#     ${time1_end}=    Get Time
#     [Teardown]    Run Keywords    Add the PM counter list    pm_counters=${SA_HO_SCE1}    AND
#     ...    Set Suite Variable    ${time1_start}    AND
#     ...    Set Suite Variable    ${time1_end}    AND
#     ...    Set Suite Variable    ${ue_num_SCE1}    AND
#     ...    Stop all online UE DL data transfer    ue_num=${3}    AND
#     ...    multi_ues_operation_exe_with_threading    action=${ue_action}[1]    AND
#     ...    PA recover    AND
#     ...    run keyword and ignore error    CU Save Snapshot
#     ...    run keyword and ignore error    Collect GNB1 vDU Snapshot Log
# 
# [1]SFE_707_711_inter-rat_handover_between_5G_and_4G
#     [Documentation]
#     ...    inter-rat handover
#     [Tags]    CRT_TRUNK
#     [Setup]
#     ${time8_start}=    Get Time
#     ${ue_num_707}=    Check actual UE num with pc reset    full_ue_num=5    partial=true
#     set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
#     Prepare all online UE with UL and DL data start    ue_number=partial
#     Adjust_HBTE_PA with loop    pa_name=${enb1_cell1_pa_info}    s_value=${enb1_cell1_pa_value}[setup][1]
#     ...    e_value=${enb1_cell1_pa_value}[setup][2]    step=${enb1_cell1_pa_info}[step][1]    ho_times=${ho_times}
#     sleep    5s
#     ${time8_end}=    Get Time
#     [Teardown]    Run Keywords    Add the PM counter list    pm_counters=${SA_HO_SCE8}    AND
#     ...    Set Suite Variable    ${time8_start}    AND
#     ...    Set Suite Variable    ${time8_end}    AND
#     ...    Set Suite Variable    ${ue_num_707}   AND
#     ...    Stop all online UE DL data transfer    ue_num=${3}    AND
#     ...    multi_ues_operation_exe_with_threading    action=${ue_action}[1]    AND
#     ...    PA recover    AND
#     ...    run keyword and ignore error    CU Save Snapshot
# 
# 
# *** Keywords ***
# Add time list
#     ${time1_start}    Get Variable Value    ${time1_start}
#     ${time1_end}    Get Variable Value    ${time1_end}
#     ${time2_start}    Get Variable Value    ${time2_start}
#     ${time2_end}    Get Variable Value    ${time2_end}
#     ${time3_start}    Get Variable Value    ${time3_start}
#     ${time3_end}    Get Variable Value    ${time3_end}
#     ${time4_start}    Get Variable Value    ${time4_start}
#     ${time4_end}    Get Variable Value    ${time4_end}
#     ${time5_start}    Get Variable Value    ${time5_start}
#     ${time5_end}    Get Variable Value    ${time5_end}
#     ${time6_start}    Get Variable Value    ${time6_start}
#     ${time6_end}    Get Variable Value    ${time6_end}
#     ${time7_start}    Get Variable Value    ${time7_start}
#     ${time7_end}    Get Variable Value    ${time7_end}
#     ${time8_start}    Get Variable Value    ${time8_start}
#     ${time8_end}    Get Variable Value    ${time8_end}
#     Append To List    ${list_}    ${time2_start}    ${time2_end}
#     ...    ${time3_start}    ${time3_end}    ${time4_start}    ${time4_end}    ${time5_start}    ${time5_end}
#     ...    ${time6_start}    ${time6_end}    ${time7_start}    ${time7_end}    ${time1_start}    ${time1_end}
#     ...    ${time8_start}    ${time8_end}
#     @{list}    replace_value_from_list    ${list_}
#     Set Suite Variable    @{list}
# 
# Add UE list
#     ${ue_num_SCE1}    Get Variable Value    ${ue_num_SCE1}
#     ${ue_num_SCE2}    Get Variable Value    ${ue_num_SCE2}
#     ${ue_num_SCE3}    Get Variable Value    ${ue_num_SCE3}
#     ${ue_num_SCE4}    Get Variable Value    ${ue_num_SCE4}
#     ${ue_num_SCE5}    Get Variable Value    ${ue_num_SCE5}
#     ${ue_num_SCE6}    Get Variable Value    ${ue_num_SCE6}
#     ${ue_num_SCE7}    Get Variable Value    ${ue_num_SCE7}
#     ${ue_num_707}    Get Variable Value    ${ue_num_707}
#     Append to list    ${ue_list_}    ${ue_num_SCE2}    ${ue_num_SCE3}    ${ue_num_SCE4}    ${ue_num_SCE5}
#     ...    ${ue_num_SCE6}    ${ue_num_SCE7}    ${ue_num_SCE1}    ${ue_num_707}
#     @{ue_num_list}    replace_value_from_list    ${ue_list_}
#     Set Suite Variable    @{ue_num_list}