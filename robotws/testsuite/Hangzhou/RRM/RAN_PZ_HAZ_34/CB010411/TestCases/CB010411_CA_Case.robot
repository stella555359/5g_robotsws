*** Settings ***
Documentation    This is the regression test cases robot for CA function parity in cloud feature CB010411 and CB011178.

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010411/Resources/CB010411_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010411/Resources/CB011178_CR_06_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010411/Resources/CB010411_CR_05_Keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010411/Resources/CB011178_CR_08_Keywords.robot

Force Tags        5G_RRM    PY36    RF50

Suite Setup        10411 Suite preparation
Suite Teardown     run keyword and ignore error    Aic Suite teardown

*** Variables ***
${GNB_INDEX}       ${0}
${VDU_INDEX}       ${0}

# *** Test Cases ***
# CB010411_TCP
#     [Documentation]  Author: Dandan Fang
#     ...    Precondition: Scell added methed CB008311 enabled
#     ...    Step1: UE attached on Pcell without scell added, because DL traffic is zero;
#     ...       checkpoint1: attached ok, scell no added, a1 event configured;
#     ...    Step2: start DL+UL traffic with peak data
#     ...       checkpoint1: Scell added and Peak checked for each cell (DL+UL)
#     ...       checkpoint2: CU Counter(M55118C09502,M55118C09503,M55138C03001,M55138C03002)
#     ...                    DU Counter(M55139C03001,M55139C03002)
#     ...    Step3: Stop DL and UL data
#     ...       checkpoint1: CU Counter(M55118C10511,M55118C10512)
#     ...       checkpoint2: scell released successful checked through F1AP
#     [Setup]   10411 Case setup
#     Run keyword and continue on failure    ca_specifical_step.L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
#     ...    tcpdump_log_name=AIC_L3_Call_F1AP_TCP
#     ...    customized_log_name=AIC_L3_Call_DL_TCP  NSA_SA=SA
#     ...    actBufferBasedScellAddition=oneShot_Dl_Fr1        scell_addition_method=blind
#     ...    target_avg_percent=0.98    min_percent=0.85
#     ...    is_analysis_log_captured=${IS_LOG_CAPTURED_WHEN_CHECK_TPUT_FAILED}
#     ...    protocol=tcp    tput_duration=300s   process_num=${3}
#     [Teardown]   Aic Common case teardown    detach_ue=${True}
#     ...    is_log_required=${IS_LOG_CAPTURED_CASE_LEVEL}

# CB010411-CR_05_CB006137_F_F_T_T_CA_peak_DL_UL_traffic_SA
#     [Documentation]  Author: Dandan Fang
#     ...    Precondition: Scell added methed CB008311 enabled
#     ...    Step1: UE attached on Pcell without scell added, because DL traffic is zero;
#     ...       checkpoint1: attached ok, scell no added, a1 event configured;
#     ...    Step2: start DL+UL traffic with peak data
#     ...       checkpoint1: Scell added and Peak checked for each cell (DL+UL)
#     ...       checkpoint2: CU Counter(M55118C09502,M55118C09503,M55138C03001,M55138C03002)
#     ...                    DU Counter(M55139C03001,M55139C03002)
#     ...    Step3: Stop DL and UL data
#     ...       checkpoint1: CU Counter(M55118C10511,M55118C10512)
#     ...       checkpoint2: scell released successful checked through F1AP
#     [Setup]   10411 Case setup
#     Step1.UE Attach without Scell Add
#     Run keyword and continue on failure    Step2.8311 Scell Add Triggered Through DL UL Peak Data
#     Run keyword and continue on failure    Step3.8311 Scell Release Triggered Through Stop DL UL
#     [Teardown]   Aic Common case teardown    detach_ue=${True}
#     ...    is_log_required=${IS_LOG_CAPTURED_CASE_LEVEL}

# CB011178-CR_06_T_T_F_F_ULCA_deactivated_When_delete_sCellAdditionMethod_and_NRREL_object
#     [Documentation]  Author: Ding Binmei
#     ...    scell addition method: blind, and 8311 is open by default
#     [Setup]    10411 Case setup    ca_group_mapping_4cc=${T1_F1_T2_F2_4CC_CA_GROUP_COMMON}
#     ...    ca_group_mapping_6cc=${T1_F1_T2_F2_6CC_CA_GROUP_COMMON}    allowed_faults_ids=7504,7505,4405
#     Run keyword and continue on failure    ca_specifical_step.L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
#     ...    tcpdump_log_name=AIC_L3_Call_F1AP    is_need_to_stop_traffic=${True}
#     ...    customized_log_name=AIC_L3_Call_UL_DL  NSA_SA=SA
#     ...    actBufferBasedScellAddition=oneShot_Dl_Fr1        scell_addition_method=blind
#     ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
#     ...    is_analysis_log_captured=${IS_LOG_CAPTURED_WHEN_CHECK_TPUT_FAILED}
#     Run keyword and continue on failure    CB011178_CR_06_keywords.S1 Remove sCellAdditionMethod and verify no CA
#     Run keyword and continue on failure    CB011178_CR_06_keywords.S2 Add back sCellAdditionMethod and verify UL DL CA is OK
#     Run keyword and continue on failure    CB011178_CR_06_keywords.S3 Remove NRREL and verify no CA exists
#     CB011178_CR_06_keywords.S4 Add back NRREL and verify UL DL CA is OK
#     [Teardown]    Aic Common case teardown    detach_ue=${True}
#     ...    is_log_required=${IS_LOG_CAPTURED_CASE_LEVEL}

# CB011178-CR_07_T_T_F_F_Reset_On_TDD_cell_A1_ScellAddition_A2_ScellReleased
#     [Documentation]  Author: Ding Binmei
#     ...    1. L3 call with T+F CA is normal
#     ...    2. Reset TDD RU for pcell
#     ...    3. After cell on air and verify L3 call with T+F CA is normal
#     [Setup]    10411 Case setup     ca_group_mapping_4cc=${T1_F1_T2_F2_4CC_CA_GROUP_COMMON}
#     ...    ca_group_mapping_6cc=${T1_F1_T2_F2_6CC_CA_GROUP_COMMON}
#     Run keyword and continue on failure    ca_specifical_step.L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
#     ...    tcpdump_log_name=AIC_L3_Call_F1AP    is_need_to_stop_traffic=${True}
#     ...    customized_log_name=AIC_L3_Call_UL_DL  NSA_SA=SA
#     ...    actBufferBasedScellAddition=oneShot_Dl_Fr1        scell_addition_method=blind
#     ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
#     ...    is_analysis_log_captured=${IS_LOG_CAPTURED_WHEN_CHECK_TPUT_FAILED}
#     CB010411_keywords.CB011178-CR_07_S2 Reset RU for pcell and wait until status are back to normal
#     Sleep    30s    reason=wait until reset stable
#     ca_specifical_step.L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
#     ...    tcpdump_log_name=S3_DL_UL_CA_after_reset_pcell    is_need_to_stop_traffic=${True}
#     ...    customized_log_name=S3_DL_UL_CA  NSA_SA=SA
#     ...    actBufferBasedScellAddition=oneShot_Dl_Fr1        scell_addition_method=blind
#     ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
#     [Teardown]    Aic Common case teardown    detach_ue=${True}
#     ...    is_log_required=${IS_LOG_CAPTURED_CASE_LEVEL}


# CB011178-CR_08_T_T_T_F_Lock_Unlock_of_TDD_and_FDD_cell_with_Graceful_Cell_Shutdown
#     [Documentation]  Author: Wu rong
#     ...    Step1:Trigger TDD Pcell graceful shutdown, then UE handover to other cell
#     ...    Step2:Trigger FDD Scell graceful shutdown, then UE release this scell
#     [Setup]    10411 Case setup     ca_group_mapping_4cc=${T1_F1_T2_F2_4CC_CA_GROUP_covBasedA1}
#     ...    ca_group_mapping_6cc=${T1_F1_T2_F2_6CC_CA_GROUP_covBasedA1}
#     Run keyword and continue on failure    CB011178_CR_08_Keywords.Step1 Change Pcell to graceful shutdown status and HO success
#     CB011178_CR_08_Keywords.Step2 Change Scell to graceful shutdown status and scell release
#     [Teardown]    Aic Common case teardown    detach_ue=${True}
#     ...    is_log_required=${IS_LOG_CAPTURED_CASE_LEVEL}

