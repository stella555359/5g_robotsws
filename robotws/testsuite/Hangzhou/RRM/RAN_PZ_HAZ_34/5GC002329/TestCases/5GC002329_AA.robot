# *** Settings ***
# Resource    ./../Resources/5GC002329_keywords.robot
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_Common_New/Check_CA_via_tcpdump_log.robot
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_Common_New/ca_specifical_step.robot
# 
# Documentation    Suite description
# ...   Author: Ding Binmei
# ...   contact: binmei.ding@nokia-sbell.com
# ...   squad group: MMW_SG1
# ...   Feature 5GC002329 T+F CA
# 
# Force Tags        5G_RRM
# ...    PY36
# Suite Setup       2329 Suite preparation
# Suite Teardown    run keyword and ignore error    CA Suite teardown
# 
# *** Variables ***
# ${REPEAT_TIME}    1   # Define the repreat time for doing Add/remove NRREL MO
# 
# 
# *** Test Cases ***
# 5GC002329-AA_011_B1_feature_act_and_deact_with_defined_CA_relation_for_SA_Option_2_with_BF_100M_0ms_multi-Ues_robust_test_5_times
#     [Documentation]    Author: Ding Binmei
#     ...    Repeat for 2 times with bellow steps:
#     ...    1. Check L3 call before doing any oprations
#     ...    2. Remove ca_Fr1Tdd_Fdd_Sa from carrierAggregationSupportList and verify PDL error
#     ...    3. Remove NRREL MO and ca_Fr1Tdd_Fdd_Sa from carrierAggregationSupportList and verify no CA
#     ...    4. Add NRREL MO and ca_Fr1Tdd_Fdd_Sa from carrierAggregationSupportList and verify with CA
#     [Tags]    CIT_22R1    CRT_TRUNK    CIT_22R2    CRT_22R1    CRT_22R3    CDRT_22R2    CRT_22R4    CRT_23R1
#     [Setup]    Run keyword and continue on failure    Common case setup    NSA_SA=${NSA_SA}
#     FOR    ${index}    IN RANGE    ${REPEAT_TIME}
#         Log to console    -----------------Repeat_time: ${REPEAT_TIME}
#         Log to console    1. Check L3 call before doing any oprations
#         Run keyword and continue on failure    CA L3 call tput check with UL rank1 issue ignored for T+F TDD cell
#         ...    tcpdump_log_name=l3call_ca_initial_${index}    bip_log_name=bip_l3call_ca_initial_${index}_tput_check_failed
#         ...    is_need_to_stop_traffic=${False}
#         Log to console    2. Remove ca_Fr1Tdd_Fdd_Sa from carrierAggregationSupportList and verify PDL error
#         Run keyword and continue on failure    Remove ca_Fr1Tdd_Fdd_Sa from carrierAggregationSupportList and verify PDL error
#         Log to console    3. Remove NRREL MO and ca_Fr1Tdd_Fdd_Sa from carrierAggregationSupportList and verify no CA
#         Run keyword and continue on failure    Remove NRREL MO and ca_Fr1Tdd_Fdd_Sa from carrierAggregationSupportList and verify no CA
#         ...    log_index=${index}
#         Log to console    4. Add NRREL MO and ca_Fr1Tdd_Fdd_Sa from carrierAggregationSupportList and verify with CA
#         Run keyword and continue on failure    Add NRREL MO and ca_Fr1Tdd_Fdd_Sa from carrierAggregationSupportList and verify with CA
#         ...    log_index=${index}
#     END
#     [Teardown]    run keyword and ignore error    Common case teardown    detach_ue=${True}    is_scf_restore=${False}
# 
# 
# *** Keywords ***
# Remove ca_Fr1Tdd_Fdd_Sa from carrierAggregationSupportList and verify PDL error
#     [Documentation]  Author: Ding Binmei
#     ...    Remove ca_Fr1Tdd_Fdd_Sa from carrierAggregationSupportList and Verify bellow PDL error reported
#     ...    PDL error: If current NRCELL supports FR1 TDD, and there is a NRREL with sCellAdditionMethod defined and NRCELL corresponding to
#     ...        this NRREL supports FDD, then NRBTS/NRDU.carrierAggregationSupportList must support ca_Fr1Tdd_Fdd_Sa
#     [Arguments]    ${connection}=GNB_OAM
#     ${param_update_result}    COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_DEACTIVE_T_F_2329_RESTAPI}
#     ...    should_activate=${False}    connection=${connection}    timeout=${TIMER_FOR_MODIFY_VIA_API}
#     ${msg_exp_pdl_error}    Catenate    If current NRCELL supports FR1 TDD, and there is a NRREL with sCellAdditionMethod defined and
#     ...    NRCELL corresponding to this NRREL supports FDD, then NRBTS/NRDU.carrierAggregationSupportList must support ca_Fr1Tdd_Fdd_Sa
#     ${pdl_validation}    Evaluate    str(${param_update_result['validationResult']['pdlValidationResult']['logs']['relationErrors']})
#     Should contain    ${pdl_validation}    ${msg_exp_pdl_error}
# 
# Remove NRREL MO and ca_Fr1Tdd_Fdd_Sa from carrierAggregationSupportList and verify no CA
#     [Documentation]  Author: Ding Binmei
#     ...    1. Change both pcell and scell status to notBarred: In case UE attach to other GNBs when pcell lock unlock after remove NRREL MO
#     ...    2. Capture F1AP while doing remove NRREL MO:
#     ...       a). Verify Pcell lock unlock happened
#     ...       b). Verify scell is not added during ue attach via F1AP
#     ...       c). Verify no dl tput for scell
#     [Arguments]    ${connection}=GNB_OAM        ${log_index}=${0}
#     ${file_name_f1ap_lock_unlock}    Set variable    tcpdum_f1ap_lock_unlock_${log_index}
#     run keyword and continue on failure    Remove NRREL and verify pcell lock unlock happened
#     ...    file_name_f1ap_lock_unlock=${file_name_f1ap_lock_unlock}    connection=${connection}
#     ...    scell_list=${SCELL_ID}
#     Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${PCELL_ID}    connection=${connection}
#     Run keyword and ignore error    Stop data transfer and detach UE
#     Sleep    30s    reason=Wait for cell status stable for attach
# 
#     ${file_name_f1ap_check_ca}    Set variable    tcpdump_f1ap_check_CA_remove_NRREL_${log_index}
#     run keyword and continue on failure  L3 call tput check without CA with UL rank1 issue ignored for T+F TDD cell
#     ...    tcpdump_log_name=${file_name_f1ap_check_ca}    bip_log_name=bip_${file_name_f1ap_check_ca}__tput_check_failed
#     ...    is_need_to_stop_traffic=${True}
#     [Teardown]    run keyword and ignore error    Run keywords  Stop Tcpdump via collector  tcpdump_collector_name=${fil
# ...e_name_f1ap_lock_unlock}  AND
#     ...    Delete pdml log file    tcpdump_log_file_path=${tcpdump_log_file_path_f1ap}    AND
#     ...    Stop data transfer and detach UE
# 
# Add NRREL MO and ca_Fr1Tdd_Fdd_Sa from carrierAggregationSupportList and verify with CA
#     [Documentation]  Author: Ding Binmei
#     ...    1. Add NRREL MO and add ca_Fr1Tdd_Fdd_Sa to carrierAggregationSupportList and do re-attach
#     ...        a) Verify CA is added
#     ...        b) Verify dl tput exists on both pcell and scell
#     [Arguments]    ${connection}=GNB_OAM    ${log_index}=${0}
# 
#     ${add_MO_nrrel}    coam_gnb_classical.get_nrrel_add_param_for_online_update    source_cell_id=${PCELL_ID}    neighbor_cell_id=${SCELL_ID}
#     ...    scell_addition_method=blind    scell_operational_mode=${None}    program=${PROGRAM}
#     COAM add several MOs via rest api     objects_to_add_via_api=${add_MO_nrrel}    connection=${connection}
#     ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
#     COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_ACTIVE_T_F_2329_RESTAPI}
#     ...    should_activate=${True}    connection=${connection}    timeout=${TIMER_FOR_MODIFY_VIA_API}
#     Wait until cluster ready based on NSA_SA type   NSA_SA=${NSA_SA}    is_need_to_setup_gnb_connection=${False}
#     ${file_name_f1ap_check_ca}    Set variable    tcpdump_f1ap_check_CA_add_NRREL_${log_index}
#     run keyword and continue on failure  CA L3 call tput check with UL rank1 issue ignored for T+F TDD cell
#     ...    tcpdump_log_name=${file_name_f1ap_check_ca}    bip_log_name=bip_${file_name_f1ap_check_ca}__tput_check_failed
#     ...    is_need_to_stop_traffic=${True}
# 
# 
# 
# 
# 
# 
