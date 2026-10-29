*** Settings ***
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009311/Resources/CB009311_keywords.robot
Documentation    Suite description
...   author: ludan.fang
...   contact: ludan.fang@nokia-sbell.com
...   squad group: MMW_SG1
...   Feature CB009311
Force Tags      5G_RRM    PY36    RF50
Suite Setup     9311 Suite preparation
Suite Teardown  run keyword and ignore error    9311 Suite teardown

*** Variables ***
${IS_UTE_ENV}                        ${False}

*** Test Cases ***
[1]CB009311_A_B1_01_Sorting_candidate_Pscells_based_on_Available_DlResources_weightForPsCellSelection
    [Tags]    CRT_TRUNK
    [Documentation]    Author: Fang ludan
    ...    The purpose of this test case is to verify that cells are ordered by the available DL Resources of each candidate PSCell
    ...    setup:CB009311 disabled ,weightofpcellselection cell1:10, cell2:60
    ...    step1:UE attach to cell1
    ...    step2:CB009311 enabled
    ...    step3:UE attach to cell2
    ...    step4:act 9311 CA on cell1/cell2,change weightofpcellselection cell1 :30
    ...    step3:UE attach to cell2
    [Setup]    Common case setup    NSA_SA=NSA

    Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${CELL_list_CA_T1_F4}  pcell_id=${1}
    ...    exp_ul_indiv=${EXP_UL_CA_T1_F4}    exp_dl_indiv=${EXP_DL_CA_T1_F4}    tput_duration=60s
    ...    scell_index_ul=${None}  scell_index_dl=${2}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}   NSA_SA=NSA
    COAM Update several parameters via rest api    parameters_to_update_via_api=${REST_API_ACT_9311}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
    Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${CELL_list_CA_F4_T1}  pcell_id=${2}
    ...    exp_ul_indiv=${EXP_UL_CA_F4_T1}    exp_dl_indiv=${EXP_DL_CA_F4_T1}    tput_duration=60s
    ...    scell_index_ul=${None}  scell_index_dl=${1}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    NSA_SA=NSA
    COAM Update several parameters via rest api    parameters_to_update_via_api=${REST_API_ACT_9311_CA_T1_F4}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
#    ${case_start_time_info}    Prepare for counter log
    Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${CELL_list_CA_F4_T1}  pcell_id=${2}
    ...    exp_ul_indiv=${EXP_UL_CA_F4_T1}    exp_dl_indiv=${EXP_DL_CA_F4_T1}    tput_duration=60s
    ...    scell_index_ul=${None}  scell_index_dl=${1}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}  NSA_SA=NSA
#    enable -C best rsrp is cell2
     ${case_start_time_info}    Prepare for counter log
        COAM Update several parameters via rest api    parameters_to_update_via_api=${REST_API_ACT_9311_C}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
    Initialize attenuator values for testline     pa_values_mapping=${INIT_PA_T1_F1_20}

    Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${CELL_list_CA_F4_T1}  pcell_id=${2}
    ...    exp_ul_indiv=${EXP_UL_CA_F4_T1}    exp_dl_indiv=${EXP_DL_CA_F4_T1}    tput_duration=60s
    ...    scell_index_ul=${None}  scell_index_dl=${1}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}  NSA_SA=NSA
    check counter M55114C00505 M55114C00506 M55114C00507    cell_list_ca=${CELL_list_CA_T1_F4}
    ...      starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}

    [Teardown]  run keyword and ignore error    run keywords
    ...   nidd_modify.online_modify_nidd_parameters_via_restapi   params_modify_dict=${REST_API_ACT_9311_A01_TEARDOWN}   timeout=3min  AND
    ...   Common case teardown    detach_ue=${True}


[1]CB009311_B_B1_11_Load_Balancing_in_FR1_PScell_Replacementcell_with_higher_channel_BW_is_prioritized
    [Tags]    CRT_TRUNK
    [Documentation]    Author: Zhang Yuan
    ...    The purpose of this test case is to verify that report cells are ordered by the available DL Resources of each candidate PSCell and
    ...    replacement cells are sorted correction and the pscell is select through CA,ccload,rsrp/rsrq,and RAC,conditions check in replacement cell
    ...    BW:T1(60)=T2(60)=T3(60)>F4(20)>F5(10), weight: T1(1)<T2=T3=F4=F5=100, report cell is T1 T2
    ...    CA Relation: T1_F4_2CC_CA_T1_F5_T2_T3_NonCA_GROUP, F4_T1_2CC_CA_GROUP, T2_T1_NonCA_GROUP, F5_T1_NonCA_GROUP, T3_T1_NonCA_GROUP
    ...    Ordered: T1(cell1): F4(cell2 is report cell),T2(cell4),T3(cell5),F5(cell3)  T2(cell4):T1(cell1)
    ...    check counters update, M55114C00505: SGNB_NSA_LB_LOADED_FR1, M55114C00506: SGNB_NSA_LB_REQ_FR1, M55114C00507: SGNB_NSA_LB_SUCC_FR1
    [Setup]    Common case setup    NSA_SA=NSA

    log to console    disable 9311, UEattach the max frequency cell1 and report cell list:cell1 cell2
    Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${CELL_list_CA_T1_F4}  pcell_id=${1}
    ...    exp_ul_indiv=${EXP_UL_CA_T1_F4}    exp_dl_indiv=${EXP_DL_CA_T1_F4}    tput_duration=60s
    ...    scell_index_ul=${None}  scell_index_dl=${2}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    tcpdump_log_name=basic_l3_call_1     NSA_SA=NSA

    log many    Step1:  T1(cell1):F4(cell2),T2(cell4),T3(cell5),F5(cell3)
    ...    Modify params:   REST_API_ACT_9311 + REST_API_ACT_9311_B_T1 + REST_API_ENABLE_A_CA_T1_T2_T3_F5 + REST_API_ENABLE_B_CA_T1_F4
    ...    Expect selected:     T1(cell1) + F4(cell2)
    ...    WHY?     Wight F4>T1, but F4 no -A CA, and T1 not overload
    ...    Counters:    no cell overload, so no counter updated
    Run keyword and continue on failure  COAM Update several parameters via rest api  parameters_to_update_via_api=${CB009311_B_B1_11_MODIFY_PARAMS}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
    Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${CELL_list_CA_T1_F4}  pcell_id=${1}
    ...    exp_ul_indiv=${EXP_UL_CA_T1_F4}    exp_dl_indiv=${EXP_DL_CA_T1_F4}    tput_duration=60s
    ...    scell_index_ul=${None}  scell_index_dl=${2}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    tcpdump_log_name=basic_l3_call_2  NSA_SA=NSA

    log many   Step2: T1(cell1):F4(cell2),T2(cell4),T3(cell5),F5(cell3)
    ...    Modify params: Step1 modify params + REST_API_T1_T2_OVERLOAD
    ...    Expect selected: F4(cell2) + T1(cell1)
    ...    WHY? cell2(F4) not overload and replace cell2(F4) CA check ok(eblRplCellSelectionWithCA on T1 is true)
    ...    Counters: T1(cell1) M55114C00506: 1, F4(cell2) M55114C00507: 1
    Run keyword and continue on failure  COAM Update several parameters via rest api
    ...   parameters_to_update_via_api=${REST_API_T1_T2_OVERLOAD}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
    &{case_start_time_info}    Prepare for counter log
    Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${CELL_list_CA_F4_T1}  pcell_id=${2}
    ...    exp_ul_indiv=${EXP_UL_CA_F4_T1}    exp_dl_indiv=${EXP_DL_CA_F4_T1}    tput_duration=60s
    ...    scell_index_ul=${None}  scell_index_dl=${1}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    tcpdump_log_name=basic_l3_call_3      NSA_SA=NSA
    @{cell_list}    create list    1    2
    @{cell1_couter}    create list    0    1    0
    @{cell2_couter}    create list    0    0    1
    ${counter_expected_number}  Create Dictionary  ${cell_list}[0]=${cell1_couter}  ${cell_list}[1]=@{cell2_couter}
    Run keyword and continue on failure     check counter CB009311-B     cell_list=${cell_list}
    ...  counter_expected_number_rusult=${counter_expected_number}
    ...  starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}

    log many   Step3: T1(cell1):F4(cell2),T2(cell4),T3(cell5),F5(cell3)
    ...    Modify params: Step1 + Step2 modify params + F4(cell2) rsrp < minrsrp
    ...    Modify params: T1(cell1) RAC reject and eblRplCellSelectionWithCA change to false will not check replace cell CA
    ...    Expect selected: T3(cell5)
    ...    WHY? T1, T2 overload, F4 rsrp not ok, choose T3(cell5)(CHBW:T3>F5) due to -B CA disable on T1(no CA limitation)
    ...    Counters: T4(cell1) M55114C00506: 1(cell1/cell2 not first cell->cell1: maxuser=0, cell2 not overload), T3(cell5) M55114C00507: 1
    Run keyword and continue on failure    COAM Update several parameters via rest api
    ...   parameters_to_update_via_api=${REST_API_ACT_T1_RAC_REJECT_MODIFY_F4_MIN_RSRP}
    ...   timeout=${TIMER_FOR_MODIFY_VIA_API}
    &{case_start_time_info}    Prepare for counter log
    Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${5}  pcell_id=${5}
    ...    exp_ul_indiv=${EXP_UL_T60M}    exp_dl_indiv=${EXP_DL_T60M}    tput_duration=60s
    ...    scell_index_ul=${None}  scell_index_dl=${None}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    tcpdump_log_name=basic_l3_call_4    NSA_SA=NSA
    @{cell_list}    create list    4    5
    @{cell4_couter}    create list    0    1    0
    @{cell5_couter}    create list    0    0    1
    ${counter_expected_number}  Create Dictionary  ${cell_list}[0]=${cell1_couter}  ${cell_list}[1]=@{cell2_couter}
    ${pm_files_local_path}    Run keyword and continue on failure     check counter CB009311-B     cell_list=${cell_list}
    ...  counter_expected_number_rusult=${counter_expected_number}
    ...  starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}
    check counter RAC REJ    cell_list_ca=${CELL_list_CA_T1_F4}    log_path=${pm_files_local_path}
    ...      starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}

    [Teardown]    run keyword and ignore error    run keywords
    ...    COAM Update several parameters via rest api    parameters_to_update_via_api=${REST_API_ACT_9311_B_T11_TEARDOWN}    AND
    ...    Common case teardown    detach_ue=${True}


[1]CB009311_B_B1_05_Preselected_cell loaded_Configured_replacement_cell_selected_as PS-Cell
    [Tags]    CRT_TRUNK
    [Documentation]    Author: Zhang Yuan
    ...    The purpose of this test case is to verify that report cells are ordered by the available DL Resources of each candidate PSCell and
    ...    replacement cells are sorted correction and the pscell is select through CA,ccload,rsrp/rsrq,and RAC,conditions check in replacement cell
    ...    BW:T1(60)=T2(60)=T3(60)>F4(20)>F5(10), weight: T1(1)<T2=T3=F4=F5=100, report cell is T1
    ...    CA Relation: T1_F4_2CC_CA_T1_F5_T2_T3_NonCA_GROUP, F4_T1_2CC_CA_GROUP, T2_T1_NonCA_GROUP, F5_T1_NonCA_GROUP, T3_T1_NonCA_GROUP
    ...    Ordered: T1(cell1):T2(cell4),T3(cell5),F4(cell2),F5(cell3) only one report cell
    ...    check counters update, M55114C00505: SGNB_NSA_LB_LOADED_FR1, M55114C00506: SGNB_NSA_LB_REQ_FR1, M55114C00507: SGNB_NSA_LB_SUCC_FR1
    [Setup]    Common case setup    NSA_SA=NSA

    change B1 on enb side     parameters_to_update_via_api=${Only_report_one_cell_B1}

    log many   Step1: T1(cell1):T2(cell4),T3(cell5),F4(cell2),F5(cell3)
    ...    Modify params: REST_API_ACT_9311 + REST_API_ACT_9311_B_T1 + REST_API_T1_T2_OVERLOAD
    ...    Expect selected: T3(cell5)
    ...    WHY? T1,T2 overload, T3 not ovreload and eblRplCellSelectionWithCA disabled on T1(cell1)
    ...    Counters: M55114C00506 update on T1(cell1), M55114C00507 update on T3(cell5)
    Run keyword and continue on failure   COAM Update several parameters via rest api
    ...     parameters_to_update_via_api=${CB009311_B_B1_05_MODIFY_PARAMS}
    ...     timeout=${TIMER_FOR_MODIFY_VIA_API}
    ${case_start_time_info}    Prepare for counter log
    Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${5}  pcell_id=${5}
    ...    exp_ul_indiv=${EXP_UL_T60M}    exp_dl_indiv=${EXP_DL_T60M}    tput_duration=60s
    ...    scell_index_ul=${None}  scell_index_dl=${None}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}  NSA_SA=NSA
    @{cell_list}    create list    1    5
    @{cell1_couter}    create list    0    1    0
    @{cell5_couter}    create list    0    0    1
    ${counter_expected_number}  Create Dictionary  ${cell_list}[0]=${cell1_couter}  ${cell_list}[1]=@{cell5_couter}
    Run keyword and continue on failure     check counter CB009311-B     cell_list=${cell_list}
    ...  counter_expected_number_rusult=${counter_expected_number}
    ...  starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}

    log many   Step2:T1(cell1):T2(cell4),T3(cell5),F4(cell2),F5(cell3) and eblRplCellSelectionWithCA=false on T1
    ...    Modify params: Step1 params + REST_API_T1_T3_RAC_REJECT_F5_OVERLOAD_MODIFY_F4_MIN_RSRP
    ...    Expect selected: T3(cell5)
    ...    WHY? T1 T2 F5 overload, F4 rsrp < minRsrpRplCellForPSCell, so select minload T2(cell4) as pscell
    ...    Counters: M55114C00505 M55114C00506 update on T2(cell4), T1 T3 not first cell(T1 T3 RAC reject(maxuser=0)), so T2 is first cell
    Run keyword and continue on failure    COAM Update several parameters via rest api
    ...   parameters_to_update_via_api=${REST_API_T1_T3_RAC_REJECT_F5_OVERLOAD_MODIFY_F4_MIN_RSRP}
    ...   timeout=${TIMER_FOR_MODIFY_VIA_API}
    ${case_start_time_info}    Prepare for counter log
    Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${4}  pcell_id=${4}
    ...    exp_ul_indiv=${EXP_UL_T60M}    exp_dl_indiv=${EXP_DL_T60M}    tput_duration=60s
    ...    scell_index_ul=${None}  scell_index_dl=${None}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}  NSA_SA=NSA
    @{cell_list}    create list    4
    @{cell4_couter}    create list    1    1    0
    ${counter_expected_number}  Create Dictionary  ${cell_list}[0]=@{cell4_couter}
    Run keyword and continue on failure     check counter CB009311-B     cell_list=${cell_list}
    ...  counter_expected_number_rusult=${counter_expected_number}
    ...  starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}

    [Teardown]    run keyword and ignore error    run keywords
    ...    COAM Update several parameters via rest api    parameters_to_update_via_api=${REST_API_ACT_9311_B_T05_TEARDOWN}    AND
    ...    Restore B1 on enb side    parameters_to_update_via_api=${REST_API_RESTORE_MEASCONF}    AND
    ...    Common case teardown    detach_ue=${True}
