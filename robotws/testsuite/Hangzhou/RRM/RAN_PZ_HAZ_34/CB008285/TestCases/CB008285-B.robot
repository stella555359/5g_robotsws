# *** Settings ***
# Resource    ./../Resources/CB008285_keywords.robot
# 
# Documentation    Suite description
# ...   author: Fang ludan
# ...   contact: ludan.fang@nokia-sbell.com
# ...   squad group: MMW_SG1
# ...   Feature CB008285
# Force Tags      5G_RRM
# ...    PY36
# Suite Setup     8285 suite preparation
# Suite Teardown  run keyword and ignore error    Common suite recovery    is_log_required=${True}
# 
# *** Variables ***
# 
# *** Test Cases ***
# CB008285_B_053_5GC001732_1CC_CSI_Report_Multiplexig_Max_UL_Tput_coderate_0.15_max_bits_27
#     [Tags]    CIT_TRUNK
#     [Documentation]    Author: Fang Ludan
#     ...     1. Enable of FR2 SA
#     [Setup]    Common case setup    NSA_SA=SA
#     coam_gnb_classical.COAM Update several parameters via rest api
#     ...    parameters_to_update_via_api=${DICT_ENABLE_1732_15}    timeout=${300}
#     Wait until cluster ready based on NSA_SA type        NSA_SA=SA
# #    ${case_start_time_info}    Prepare for counter log
#     #start X2log capture
#     Start capture F1AP log    tcpdump_collector_name=15_log    options=-i any sctp
#     log to console    \n... CPE SA attach and check status with aasyslog ...
# #    attach CPE UE for FR2 SA
#     ${attach_result1}    run keyword and return status    retry commercial ue attach if failed    ue_type=${UE_TYPE}    prepare_ue_needed=${True}
#     ...    attach_check_type=PROXY_log    cell_id=${pcell_nrCellIdentity}
#      #check log
#     ${ute_log_path_f1ap}    Stop tcpdump log collection    tcpdump_collector_name=15_log
# #    Start both traffic then verify throughput as expect FR2 SA for CPE   pcell_nrCellIdentity=${pcell_nrCellIdentity}
# #    ...   exp_ul=${EXP_UL_B4}  exp_dl=${EXP_DL_B4}  target_avg_percent=0.95
#     Run Keyword And Continue On Failure    Start data transfer based on direction    dl_tput=${DL_TPUT_COMMON}    ul_tput=${UL_TPUT_COMMON}
#     ...    duration=1200    protocol=udp    data_transfer_direction=both    window=1M
#     ${tput_log1}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=60    ignore_time=10s   filter=L2Lo    check_source=aasyslog
#     run keyword and ignore error    check iperf process on appserver
#     Run Keyword And Continue On Failure    Check tput via power UE with power UE method    cell_id=${pcell_nrCellIdentity}
#     ...    exp_ul=${EXP_UL_B4}    exp_dl=${EXP_DL_B4}    log=${tput_log1}    actCarrierAggregation=${False}
# 
#     run keyword and continue on failure
#     ...   check CSI report with pucchF2MaxCodeRate from rrc reconfiguration msg   log_file_path=${ute_log_path_f1ap}
#     ...   CQI_EXP=${11}  beam_reprot_EXP=${12}
# #    Cpe_operation.stop_ul_data_transfer
# #    ...   hostname=${UE_PC_IP}
# #    ...   username=${UE_PC_USERNAME}
# #    ...   password=${UE_PC_PASSWD}
# #    ...   port=${APPSERVER_PORT}
# #    ...   ue_sn=${UE_SN}
# #    ute_ue.Release PDU session   AT_BASED_UE
# #    ute_ue.Detach Ue   AT_BASED_UE
#     Run Keyword And Continue On Failure    wait until keyword succeeds    3x    2s
#     ...     Stop data transfer based on direction   data_transfer_direction=both
#     Run Keyword And Continue On Failure    power_ue.UE detach    ue_type=${UE_TYPE}
# 
#     coam_gnb_classical.COAM Update several parameters via rest api
#     ...    parameters_to_update_via_api=${DICT_ENABLE_1732_25}    timeout=${300}
#     Wait until cluster ready based on NSA_SA type        NSA_SA=SA
#     #start X2log capture
#     ${case_start_time_info}    Prepare for counter log
#     Start capture F1AP log    tcpdump_collector_name=25_log    options=-i any sctp
#     log to console    \n... CPE SA attach and check status with aasyslog ...
# #    attach CPE UE for FR2 SA   require_UE=${false}
#     ${attach_result2}    run keyword and return status    retry commercial ue attach if failed    ue_type=${UE_TYPE}    prepare_ue_needed=${False}
#     ...    attach_check_type=PROXY_log    cell_id=${pcell_nrCellIdentity}
#     ${ATTACH_RESULT}    set variable if     ${attach_result1}==${False} or ${attach_result2}==${False}    ${False}    ${True}
#     set test variable    ${ATTACH_RESULT}
#      #check log
#     ${ute_log_path_f1ap}    Stop tcpdump log collection    tcpdump_collector_name=25_log
# #    Start both traffic then verify throughput as expect FR2 SA for CPE   pcell_nrCellIdentity=${pcell_nrCellIdentity}
# #    ...   exp_ul=${EXP_UL_B4}  exp_dl=${EXP_DL_B4}  target_avg_percent=0.95
#     Run Keyword And Continue On Failure    Start data transfer based on direction    dl_tput=${DL_TPUT_COMMON}    ul_tput=${UL_TPUT_COMMON}
#     ...    duration=1200    protocol=udp    data_transfer_direction=both    window=1M
#     ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=60    ignore_time=10s   filter=L2Lo    check_source=aasyslog
#     Run Keyword And Continue On Failure    Check tput via power UE with power UE method    cell_id=${pcell_nrCellIdentity}
#     ...    exp_ul=${EXP_UL_B4}    exp_dl=${EXP_DL_B4}    log=${tput_log}    actCarrierAggregation=${False}
# 
#     run keyword and continue on failure       check counter M55306C06001 M55306C03001
#     ...      starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}
#     ...      counter_expected_number=${1}
#     check CSI report with pucchF2MaxCodeRate from rrc reconfiguration msg   log_file_path=${ute_log_path_f1ap}
# 
#     [Teardown]    run keyword and ignore error    8285 case teardown
# 
# [1]CB008285_B_044_5GC000532_Codebook_based_2X2_MIMO_PUSCH_transmission_with_2DMRS_RANK2_counter_using_PRACH_B4
#     [Tags]    CIT_TRUNK
#     [Documentation]    Author: Fang Ludan
#     ...     1. Enable of FR2 SA, enable 5GC00532
#     ...     2. UE attach on pcell
#     ...     3. check counter
#     ...     4. check RRC reconfigration :codeboke and DMRS
#     ...     5. start DL and UL data and check tput
#     [Setup]    Common case setup    NSA_SA=SA
#     coam_gnb_classical.COAM Update several parameters via rest api
#     ...    parameters_to_update_via_api=${DICT_ENABLE_B4_532}    timeout=${300}
#     Wait until cluster ready based on NSA_SA type        NSA_SA=SA
#     ${case_start_time_info}    Prepare for counter log
#     #start X2log capture
#     Start capture F1AP log    tcpdump_collector_name=${TCPDUMP_LOG_NAME}    options=-i any sctp
#     #attach
# #    attach CPE UE for FR2 SA
# #     #check log
# #    Start both traffic then verify throughput as expect FR2 SA for CPE   pcell_nrCellIdentity=${pcell_nrCellIdentity}
# #    ...   exp_ul=${EXP_UL_B4}  exp_dl=${EXP_DL_B4}  target_avg_percent=0.85
# 
#     Run Keyword And Continue On Failure    L3 call check tput with power UE method
#     ...    nr_cell_id=${pcell_nrCellIdentity}    dl_tput=${DL_TPUT_COMMON}    ul_tput=${UL_TPUT_COMMON}
#     ...    exp_ul=${EXP_UL_B4}    exp_dl=${EXP_DL_B4}    tput_check_duration=60
#     ...    ignore_time=20s    actCarrierAggregation=${False}    data_transfer_direction=both
#     ...    traffic_duration=150    prepare_ue_needed=${True}    detach_request=${True}    target_avg_percent=0.85
# 
# 
#     run keyword and continue on failure       check counter M55303C04002 M55303C03001 M55303C03000
#     ...      starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}
#     ...      counter_expected_number=${1}
#     ${ute_log_path_f1ap}    Stop tcpdump log collection    tcpdump_collector_name=${TCPDUMP_LOG_NAME}
#     check DMRS and codebookSubset from rrc reconfiguration msg   log_file_path=${ute_log_path_f1ap}
# 
#     [Teardown]    run keyword and ignore error    8285 case teardown
# 
# 
# 
# 
