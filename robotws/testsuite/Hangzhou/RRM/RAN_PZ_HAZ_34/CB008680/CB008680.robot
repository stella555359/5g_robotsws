# # # @Time    : 2022/10/
# # # @Author  : xudong.1.li
# # # @Email   : xudong.1.li@nokia-sbell.com
# # # @File    : CB008680.robot
# # # @Software: PyCharm
# # # @Doc     : Some Description
# # 
# # *** Settings ***
# # Documentation     author: Li Xudong
# # ...               contact: xudong.1.li@nokia-sbell.com
# # ...               squad group: mmW_05
# # ...               feature : CB008680-E
# # ...               UE:Qualcomm Mobile 8250
# # 
# # *** Settings ***
# # Resource             CB008680_Keywords.robot
# # Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# # 
# # Suite Setup          Run Keywords    robot_common_operations.Common Suite Setup
# # ...    AND     CI_interface.Common Suite Setup
# # Suite Teardown       robot_common_operations.Common Suite Teardown
# # Test Setup           Run Keywords    robot_common_operations.Common Case Setup
# # ...    AND     Connect to gnb coam via ssl
# # Test Teardown        Run Keywords    robot_common_operations.Common Case Teardown
# # ...    AND     Unlock BTS All 5G Cells
# # ...    AND     Modify Parameter On BTS With Activate    dist_name=${NR_AMF_Dist}    parameter=administrativeState
# # ...    value=Unlocked    connection=GNB_OAM
# # ...    AND     Run Keyword And Ignore Error    COAM Teardown gnb connections
# # Force Tags      CRT_TRUNK    CRT_23R1    PY36
# # 
# # *** Variables ***
# # ${if_commissioning}            True
# # ${UL_TP}                       50M
# # ${UL_TP_THRESHOLD}              1
# # ${DL_TP}                       300M
# # ${DL_TP_THRESHOLD}              1
# # ${GLOBAL_CELL1_ID}              1
# # ${GLOBAL_CELL2_ID}              2
# # ${ue_index}                     0
# # ${cell1_dist}                  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
# # ${cell2_dist}                  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
# # ${NR_AMF_Dist}                 MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-1
# # ${lte_cell2_dist}              MRBTS-${ENB_MRBTS_ID}/LNBTS-${ENB_LNBTS_ID}/LNCEL-2
# # ${E_1_DELTA}                   ${CURDIR}/json/E1.json
# # ${E_2_DELTA}                   ${CURDIR}/json/E2.json
# # ${E_3_DELTA}                   ${CURDIR}/json/E3.json
# # ${E_4_DELTA}                   ${CURDIR}/json/E4.json
# # ${E_5_DELTA}                   ${CURDIR}/json/E5.json
# # ${E_6_DELTA}                   ${CURDIR}/json/E6.json
# # ${E_7_DELTA}                   ${CURDIR}/json/E7.json
# # ${E_8_DELTA}                   ${CURDIR}/json/E8.json
# # ${E_9_DELTA}                   ${CURDIR}/json/E9.json
# # ${E_10_DELTA}                  ${CURDIR}/json/E10.json
# # ${E_11_DELTA}                  ${CURDIR}/json/E11.json
# # ${E_12_DELTA}                  ${CURDIR}/json/E12.json
# # ${E_13_DELTA}                  ${CURDIR}/json/E13.json
# # ${E_14_DELTA}                  ${CURDIR}/json/E14.json
# # ${E_15_DELTA}                  ${CURDIR}/json/E15.json
# # 
# # *** Test Cases ***
# # [1]CB008680-E_1_attach SR on different Prach configuration recommison - frame structure 5GC001208 - prach format C2
# #     [Documentation]    Author: xudong.1.li@nokia-sbell.com
# #     ...   prachConfigurationIndex_list is 190+NSA+C-band(BWP-Index5-51)   CBAND 40   DOD 40
# #     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# #     coam.perform_delta_recommissioning    delta_file=${E_1_DELTA}
# #     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# #     Lock Unlock lte Cell    dist_name=${lte_cell2_dist}    if_lock=unlocked
# #     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# #     Reset UE First
# #     power_ue.Prepare UE    ue_type=qct_dx50
# #     Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
# #     ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=NSA
# #     ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
# #     ...    global_cell_id=${GLOBAL_CELL1_ID}
# # 
# # [1]CB008680-E_12_attach SR on different Prach configuration recommison - frame structure 5GC001070 - prach format C2
# #     [Documentation]    Author: xudong.1.li@nokia-sbell.com
# #     ...   prachConfigurationIndex_list is 196+NSA+C-band(BWP-Index6-65)   CBAND 80   DOD 30
# #     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# #     coam.perform_delta_recommissioning    delta_file=${E_12_DELTA}
# #     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# #     Lock Unlock lte Cell    dist_name=${lte_cell2_dist}    if_lock=unlocked
# #     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# #     Reset UE First
# #     power_ue.Prepare UE    ue_type=qct_dx50
# #     Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
# #     ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=NSA
# #     ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
# #     ...    global_cell_id=${GLOBAL_CELL1_ID}
# # 
# # [1]CB008680-E_6_attach SR on different Prach configuration recommison - frame structure 5GC001116 with 3ms shift - prach format A2
# #     [Documentation]    Author: xudong.1.li@nokia-sbell.com
# #     ...   prachConfigurationIndex_list is 88+SA+DOD-band(BWP-Index8-80)   CBAND 100   DOD 20
# #     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# #     coam.perform_delta_recommissioning    delta_file=${E_6_DELTA}
# #     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# #     Lock Unlock lte Cell    dist_name=${lte_cell2_dist}    #if_lock=unlocked
# #     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# #     Modify Parameter On BTS With Activate
# #     ...    dist_name=${cell1_dist}    parameter=administrativeState    value=Locked
# #     Reset UE First
# #     power_ue.Prepare UE    ue_type=qct_dx50
# #     Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
# #     ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=SA
# #     ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
# #     ...    global_cell_id=${GLOBAL_CELL2_ID}
# # 
# # [1]CB008680-E_11_attach SR on different Prach configuration recommison - frame structure 5GC001116 with 0ms shift - prach format F0
# #     [Documentation]    Author: xudong.1.li@nokia-sbell.com
# #     ...   prachConfigurationIndex_list is 9+SA+DOD-band(BWP-Index7-71)   CBAND 20   DOD 40
# #     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# #     coam.perform_delta_recommissioning    delta_file=${E_11_DELTA}
# #     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# #     Lock Unlock lte Cell    dist_name=${lte_cell2_dist}    #if_lock=unlocked
# #     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# #     Modify Parameter On BTS With Activate
# #     ...    dist_name=${cell1_dist}    parameter=administrativeState    value=Locked
# #     Reset UE First
# #     power_ue.Prepare UE    ue_type=qct_dx50
# #     Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
# #     ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=SA
# #     ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
# #     ...    global_cell_id=${GLOBAL_CELL2_ID}
# # 
# # #----------------PZ3_SG5 trunk case optimization 2022-12-28-------------------------------------------------------#
# # #[1]CB008680-E_2_attach SR on different Prach configuration recommison - frame structure 5GC001208 - prach format B4
# # #    [Documentation]    Author: xudong.1.li@nokia-sbell.com
# # #    ...   prachConfigurationIndex_list is 147+SA+DOD-band(BWP-Index5-51)   CBAND 40   DOD 40
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    coam.perform_delta_recommissioning    delta_file=${E_2_DELTA}
# # #    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# # #    Lock Unlock lte Cell    dist_name=${lte_cell2_dist}    #if_lock=unlocked
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    Modify Parameter On BTS With Activate
# # #    ...    dist_name=${cell1_dist}    parameter=administrativeState    value=Locked
# # #    Reset UE First
# # #    power_ue.Prepare UE    ue_type=qct_dx50
# # #    Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
# # #    ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=SA
# # #    ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
# # #    ...    global_cell_id=${GLOBAL_CELL2_ID}
# # #
# # #[1]CB008680-E_3_attach SR on different Prach configuration recommison - frame structure 5GC001208 - prach format A2
# # #    [Documentation]    Author: xudong.1.li@nokia-sbell.com
# # #    ...   prachConfigurationIndex_list is 93+NSA+c-band(BWP-Index5-51)   CBAND 40   DOD 40
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    coam.perform_delta_recommissioning    delta_file=${E_3_DELTA}
# # #    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# # #    Lock Unlock lte Cell    dist_name=${lte_cell2_dist}    if_lock=unlocked
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    Reset UE First
# # #    power_ue.Prepare UE    ue_type=qct_dx50
# # #    Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
# # #    ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=NSA
# # #    ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
# # #    ...    global_cell_id=${GLOBAL_CELL1_ID}
# # #
# # #[1]CB008680-E_13_attach SR on different Prach configuration recommison - frame structure 5GC001070 - prach format B4
# # #    [Documentation]    Author: xudong.1.li@nokia-sbell.com
# # #    ...   prachConfigurationIndex_list is 160+SA+DOD-band(BWP-Index6-60)   CBAND 40   DOD 20
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    coam.perform_delta_recommissioning    delta_file=${E_13_DELTA}
# # #    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# # #    Lock Unlock lte Cell    dist_name=${lte_cell2_dist}    #if_lock=unlocked
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    Modify Parameter On BTS With Activate
# # #    ...    dist_name=${cell1_dist}    parameter=administrativeState    value=Locked
# # #    Reset UE First
# # #    power_ue.Prepare UE    ue_type=qct_dx50
# # #    Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
# # #    ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=SA
# # #    ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
# # #    ...    global_cell_id=${GLOBAL_CELL2_ID}
# # #
# # #[1]CB008680-E_14_attach SR on different Prach configuration recommison - frame structure 5GC001070 - prach format A2
# # #    [Documentation]    Author: xudong.1.li@nokia-sbell.com
# # #    ...   prachConfigurationIndex_list is 89+SA+DOD-band(BWP-Index6-61)   CBAND 100   DOD 40
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    coam.perform_delta_recommissioning    delta_file=${E_14_DELTA}
# # #    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# # #    Lock Unlock lte Cell    dist_name=${lte_cell2_dist}    #if_lock=unlocked
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    Modify Parameter On BTS With Activate
# # #    ...    dist_name=${cell1_dist}    parameter=administrativeState    value=Locked
# # #    Reset UE First
# # #    power_ue.Prepare UE    ue_type=qct_dx50
# # #    Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
# # #    ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=SA
# # #    ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
# # #    ...    global_cell_id=${GLOBAL_CELL2_ID}
# # #
# # #[1]CB008680-E_15_attach SR on different Prach configuration recommison - frame structure 5GC001070 - prach format F0
# # #    [Documentation]    Author: xudong.1.li@nokia-sbell.com
# # #    ...   prachConfigurationIndex_list is 17+NSA+c-band(BWP-Index6-65)   CBAND 80   DOD 30
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    coam.perform_delta_recommissioning    delta_file=${E_15_DELTA}
# # #    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# # #    Lock Unlock lte Cell    dist_name=${lte_cell2_dist}    if_lock=unlocked
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    Reset UE First
# # #    power_ue.Prepare UE    ue_type=qct_dx50
# # #    Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
# # #    ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=NSA
# # #    ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
# # #    ...    global_cell_id=${GLOBAL_CELL1_ID}
# # #
# # #[1]CB008680-E_4_attach SR on different Prach configuration recommison - frame structure 5GC001116 with 3ms shift - prach format C2
# # #    [Documentation]    Author: xudong.1.li@nokia-sbell.com
# # #    ...   prachConfigurationIndex_list is 202+NSA+C-band(BWP-Index8-83)   CBAND 60   DOD 40
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    coam.perform_delta_recommissioning    delta_file=${E_4_DELTA}
# # #    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# # #    Lock Unlock lte Cell    dist_name=${lte_cell2_dist}    if_lock=unlocked
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    Reset UE First
# # #    power_ue.Prepare UE    ue_type=qct_dx50
# # #    Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
# # #    ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=NSA
# # #    ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
# # #    ...    global_cell_id=${GLOBAL_CELL1_ID}
# # #
# # #[1]CB008680-E_5_attach SR on different Prach configuration recommison - frame structure 5GC001116 with 3ms shift - prach format B4
# # #    [Documentation]    Author: xudong.1.li@nokia-sbell.com
# # #    ...   prachConfigurationIndex_list is 146+SA+DOD-band(BWP-Index8-81)   CBAND 60   DOD 40
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    coam.perform_delta_recommissioning    delta_file=${E_5_DELTA}
# # #    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# # #    Lock Unlock lte Cell    dist_name=${lte_cell2_dist}    #if_lock=unlocked
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    Modify Parameter On BTS With Activate
# # #    ...    dist_name=${cell1_dist}    parameter=administrativeState    value=Locked
# # #    Reset UE First
# # #    power_ue.Prepare UE    ue_type=qct_dx50
# # #    Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
# # #    ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=SA
# # #    ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
# # #    ...    global_cell_id=${GLOBAL_CELL2_ID}
# # #
# # #[1]CB008680-E_7_attach SR on different Prach configuration recommison - frame structure 5GC001116 with 3ms shift - prach format F0
# # #    [Documentation]    Author: xudong.1.li@nokia-sbell.com
# # #    ...   prachConfigurationIndex_list is 2+NSA+C-band(BWP-Index8-87)   CBAND 100   DOD 20
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    coam.perform_delta_recommissioning    delta_file=${E_7_DELTA}
# # #    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# # #    Lock Unlock lte Cell    dist_name=${lte_cell2_dist}    if_lock=unlocked
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    Reset UE First
# # #    power_ue.Prepare UE    ue_type=qct_dx50
# # #    Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
# # #    ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=NSA
# # #    ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
# # #    ...    global_cell_id=${GLOBAL_CELL1_ID}
# # #
# # #[1]CB008680-E_8_attach SR on different Prach configuration recommison - frame structure 5GC001116 with 0ms shift - prach format C2
# # #    [Documentation]    Author: xudong.1.li@nokia-sbell.com
# # #    ...   prachConfigurationIndex_list is 194+NSA+c-band(BWP-Index7-75)   CBAND 80   DOD 20
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    coam.perform_delta_recommissioning    delta_file=${E_8_DELTA}
# # #    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# # #    Lock Unlock lte Cell    dist_name=${lte_cell2_dist}    if_lock=unlocked
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    Reset UE First
# # #    power_ue.Prepare UE    ue_type=qct_dx50
# # #    Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
# # #    ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=NSA
# # #    ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
# # #    ...    global_cell_id=${GLOBAL_CELL1_ID}
# # #
# # #[1]CB008680-E_9_attach SR on different Prach configuration recommison - frame structure 5GC001116 with 0ms shift - prach format B4
# # #    [Documentation]    Author: xudong.1.li@nokia-sbell.com
# # #    ...   prachConfigurationIndex_list is 150+NSA+c-band(BWP-Index7-70)   CBAND 20   DOD 40
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    coam.perform_delta_recommissioning    delta_file=${E_9_DELTA}
# # #    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# # #    Lock Unlock lte Cell    dist_name=${lte_cell2_dist}    if_lock=unlocked
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    Reset UE First
# # #    power_ue.Prepare UE    ue_type=qct_dx50
# # #    Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
# # #    ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=NSA
# # #    ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
# # #    ...    global_cell_id=${GLOBAL_CELL1_ID}
# # #
# # #[1]CB008680-E_10_attach SR on different Prach configuration recommison - frame structure 5GC001116 with 0ms shift - prach format A2
# # #    [Documentation]    Author: xudong.1.li@nokia-sbell.com
# # #    ...   prachConfigurationIndex_list is 92+SA+DOD-band(BWP-Index7-70)   CBAND 80   DOD 20
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    coam.perform_delta_recommissioning    delta_file=${E_10_DELTA}
# # #    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# # #    Lock Unlock lte Cell    dist_name=${lte_cell2_dist}    #if_lock=unlocked
# # #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# # #    Modify Parameter On BTS With Activate
# # #    ...    dist_name=${cell1_dist}    parameter=administrativeState    value=Locked
# # #    Reset UE First
# # #    power_ue.Prepare UE    ue_type=qct_dx50
# # #    Wait Until Keyword Succeeds    3x    10s    UE Attach And Check Throughput With Detach bk
# # #    ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=SA
# # #    ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
# # #    ...    global_cell_id=${GLOBAL_CELL2_ID}
# # #----------------PZ3_SG5 trunk case optimization 2022-12-28-------------------------------------------------------#
# # 
# # 
# # 
# # [1]Verify MRC or IRC function
# #     #scf commission and wait for on-air
# #     #Power UE L3 Call Huawei
# #     Log To Console     Verify_MRC_or_IRC_function_successful
# # 
# # 
# # 
# # *** Keywords ***
# # Power UE L3 Call Huawei
# #     [Arguments]  ${call_time}=200       ${log_time}=3m      ${cell_id}=0    ${actCarrierAggregation}=${False}
# #     ...   ${tput_UL}=10M      ${tput_DL}=100M
# #     power_ue.Prepare UE    ue_type=${ue_type}     ue_index=${ue_index}
# #     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
# #     power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False   ue_index=${ue_index}
# # 
# #     power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=${tput_UL}    duration=${call_time}    ue_type=${ue_type}
# #   	...   iperf_type=via_app  #iperf_type=via_command                       #iperf_type=via_app   huawei
# #     ...    protocol=udp
# #     sleep    1s
# #     power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=${tput_DL}    duration=${call_time}    ue_type=${ue_type}
# #   	...    protocol=udp    buffer_size=1400B    process_num=${1}    seg_size=1350    window=16M
# #     sleep    2s
# # 
# #     ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${log_time}    filter=L2Lo   ue_index=${ue_index}
# # 
# #     Connect to gnb coam via ssl
# #     ${list_of_cell_ids}    Get List of NR Cell ID
# # 
# #     ${cell_list}    create list
# #     Run Keyword If    ${actCarrierAggregation} == ${False}      Run Keywords
# #     ...        Append To List    ${cell_list}    ${list_of_cell_ids}[${cell_id}]    AND
# #     ...   set suite variable      ${list_of_cell_ids}       ${cell_list}
# # 
# # 
# #     ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}   ue_index=${ue_index}
# #     ...    ultarget_throughput=0.3    dltarget_throughput=0.3    actCarrierAggregation=${actCarrierAggregation}   min_percent=0
# # 
# #     power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}    iperf_type=via_app     #iperf_type=via_command
# #     power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}
# # 
# #     power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}
# # 
# # scf commission and wait for on-air
# #     [Arguments]   ${scf_name}=SCF_SBTS00.xml
# #     Connect to gnb coam via ssl
# #     COAM Commission with scf file    scf_file_path=${SCF_PATH}/${scf_name}    timeout=${600}    is_pdl_checking_needed=${False}
# #     sleep    3min
# #     Wait Until Keyword Succeeds    15min    20s    COAM Check GNB cell on air
# #     COAM Teardown gnb connections
