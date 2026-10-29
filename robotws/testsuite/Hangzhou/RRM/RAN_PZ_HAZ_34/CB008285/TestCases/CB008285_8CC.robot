# *** Settings ***
# Resource    ./../Resources/CB008285_keywords.robot
# Resource    ./../../CB008294/Resources/CB008294_keywords.robot
# 
# Force Tags      5G_RRM    PY36
# Suite Setup     8285_change_to_8CC_suite_prepare
# Suite Teardown  run keyword and ignore error    Common suite recovery    is_log_required=${True}
# 
# *** Test Cases ***
# [1]CB008285_B_053_5GC001732_1CC_CSI_Report_Multiplexig_Max_UL_Tput_coderate_0.15_max_bits_27
#     [Tags]    CIT_TRUNK
#     [Documentation]    Author: Fang Ludan
#     ...     1. UE attach and collect tcpdump
#     ...     2. start UL and DL data and check evaluate average tput
#     ...     3. check CSI report
#     [Setup]    Common case setup   nidd_modify_via_api=${DICT_ENABLE_1732_15}    timeout_restapi=8min   NSA_SA=SA
# #    ${case_start_time_info}    Prepare for counter log
#     #start X2log capture
# #    Start capture F1AP log    tcpdump_collector_name=15_log    options=-i any sctp
# #    log to console    \n... CPE SA attach and check status with aasyslog ...
# #    attach CPE UE for FR2 SA
# #     #check log
# #    ${ute_log_path_f1ap}    Stop tcpdump log collection    tcpdump_collector_name=15_log
#     log to console    \n... CPE SA attach and check status with aasyslog ...
#     ${ute_log_path_f1ap}    CPE UE attach and collect tcpdump log    tcpdump_log_name=8CCDL_4CCUL   nr_cell_id=${pcell_nrCellIdentity}
#      ...   prepare_ue_needed=${True}
#     Run keyword and continue on failure    Start traffic and verify tput for CPE    cell_index=0,1,2,3,4,5,6,7
#     ...    ul_tput=${UL_TPUT_COMMON}   dl_tput=${DL_TPUT_COMMON}
#     ...    exp_ul=${EXP_UL}    exp_dl=${EXP_DL}
#     ...    log_duration=30s    ignore_time=10s    target_avg_percent=${target_avg_percent}  appserver_num=2
#     run keyword and continue on failure
#     ...   check CSI report with pucchF2MaxCodeRate from rrc reconfiguration msg   log_file_path=${ute_log_path_f1ap}
#     ...   CQI_EXP=${11}  beam_reprot_EXP=${12}
# 
#     CPE UE detach
# 
# #    Cpe_operation.stop_ul_data_transfer
# #    ...   hostname=${UE_PC_IP}
# #    ...   username=${UE_PC_USERNAME}
# #    ...   password=${UE_PC_PASSWD}
# #    ...   port=${APPSERVER_PORT}
# #    ...   ue_sn=${UE_SN}
# #    ute_ue.Release PDU session   AT_BASED_UE
# #    ute_ue.Detach Ue   AT_BASED_UE
# 
#     coam_gnb_classical.COAM Update several parameters via rest api
#     ...    parameters_to_update_via_api=${DICT_ENABLE_1732_25}    timeout=${300}
#     Wait until cluster ready based on NSA_SA type        NSA_SA=SA
#     #start X2log capture
#     ${case_start_time_info}    Prepare for counter log
#     ${ute_log_path_f1ap}    CPE UE attach and collect tcpdump log    tcpdump_log_name=8CCDL_4CCUL     nr_cell_id=${pcell_nrCellIdentity}
# 
#     Run keyword and continue on failure    Start traffic and verify tput for CPE    cell_index=0,1,2,3,4,5,6,7
#     ...    ul_tput=${UL_TPUT_COMMON}   dl_tput=${DL_TPUT_COMMON}
#     ...    exp_ul=${EXP_UL}    exp_dl=${EXP_DL}
#     ...    log_duration=30s    ignore_time=10s    target_avg_percent=${target_avg_percent}   appserver_num=2
#     run keyword and continue on failure       check counter M55306C06001 M55306C03001
#     ...      starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}
#     ...      counter_expected_number=${1}
#     check CSI report with pucchF2MaxCodeRate from rrc reconfiguration msg   log_file_path=${ute_log_path_f1ap}
# 
#     [Teardown]    run keyword and ignore error    8294 case teardown
# 
# 
# [1]CB008285_B_010_CNI_94156_RRC_Setup_and_RRC_Reestablishment_FR2_SA_Cell
#     [Tags]    CRT_TRUNK
#     [Documentation]    Author: Zhou Charlie/ludan change to 8CC
#     ...     1. CPE attach, start bi-direction data, check CPE tput ok
#     ...     2. enable CNI-94156
#     ...     3. CPE attach, start bi-direction data, check CPE tput ok.
#     [Setup]    Common case setup    NSA_SA=SA
#     log to console    \n ... do base SCF commission and check PDL error ...
#     COAM Create log directory
# #    ${template_for_process}    scfpro.SCFProcess    scf_template_path=${SCF_DEFAULT_FILE_PATH}
# #    ...     scf_process_folder=${TS_CASE_LOG_PATH}
# #    coam_gnb_classical.connect to gnb coam via ssl
# #    Do commission and return PDL validation result for classical
# #    ...    is_pdl_checking_needed=${True}    scf_template_path=${template_for_process}
#     Wait until cluster is on cell on air status    is_all_cells_checking_needed=${True}
#     ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
# 
#     log to console    \n... CPE SA attach, start bi-dir data transmission and check tput ...
#     ${tcpdump_log_name}    set variable    CPE_attach_1
# #    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}   options=-i any sctp
# #    attach CPE UE for FR2 SA
# #    sleep    10s
# #    ${CPE_attach_log}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}
# #    Start both traffic FR2 SA for CPE    tput_duration=180s    dl_length=1400B    process_num=1
# #    verify throughput as expect FR2 SA for CPE    pcell_nrCellIdentity=${pcell_nrCellIdentity}
#     ${CPE_attach_log}    CPE UE attach and collect tcpdump log    tcpdump_log_name=8CCDL_4CCUL   nr_cell_id=${pcell_nrCellIdentity}
#      ...   prepare_ue_needed=${True}
#     Run keyword and continue on failure    Start traffic and verify tput for CPE    cell_index=0,1,2,3,4,5,6,7
#     ...    ul_tput=${UL_TPUT_COMMON}   dl_tput=${DL_TPUT_COMMON}
#     ...    exp_ul=${EXP_UL}    exp_dl=${EXP_DL}
#     ...    log_duration=30s    ignore_time=10s    target_avg_percent=${target_avg_percent}  appserver_num=2
#     Verify RRC SETUP configuring BWP using initial BWP profile    log_path_pcap=${CPE_attach_log}    isUsedInitialBwp=${False}
#     CPE UE detach
# 
#     log to console    \n... enable CNI-94156 ...
#     coam_gnb_classical.COAM Update several parameters via rest api
#     ...    parameters_to_update_via_api=${MODIFY_ENABLE_CNI_94156}   timeout=${300}
#     Wait cell onair classical cloud
# 
#     log to console    \n... CPE SA attach again, start bi-dir data transmission and check tput ...
#     ${tcpdump_log_name}    set variable    CPE_attach_2
# #    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}   options=-i any sctp
# #    attach CPE UE for FR2 SA    require_UE=${False}
# #    sleep    10s
# #    ${CPE_attach_log}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}
# #    Start both traffic FR2 SA for CPE    tput_duration=180s    dl_length=1400B    process_num=1
# #    verify throughput as expect FR2 SA for CPE    pcell_nrCellIdentity=${pcell_nrCellIdentity}
#     ${CPE_attach_log}    CPE UE attach and collect tcpdump log    tcpdump_log_name=8CCDL_4CCUL     nr_cell_id=${pcell_nrCellIdentity}
#     Run keyword and continue on failure    Start traffic and verify tput for CPE    cell_index=0,1,2,3,4,5,6,7
#     ...    ul_tput=${UL_TPUT_COMMON}   dl_tput=${DL_TPUT_COMMON}
#     ...    exp_ul=${EXP_UL}    exp_dl=${EXP_DL}
#     ...    log_duration=30s    ignore_time=10s    target_avg_percent=${target_avg_percent}   appserver_num=2
#     Verify RRC SETUP configuring BWP using initial BWP profile    log_path_pcap=${CPE_attach_log}    isUsedInitialBwp=${True}
# 
#     [Teardown]    run keywords    run keyword and ignore error    Stop tcpdump log collection
#     ...    tcpdump_collector_name=${tcpdump_log_name}    AND    run keyword and ignore error    8294 case teardown
# 
# 
# *** Keywords ***
# 8285_change_to_8CC_suite_prepare
#     [Documentation]    author:ludan fang
#     8294 suite preparation
#     fix with 24R1
# 
# 
# 
# fix with 24R1
#     [Documentation]    author:ludan fang
#     Run keyword if    '${PROGRAM}'<'24R1' or '${PROGRAM}'!='master'   run keywords
#     ...   coam_gnb_classical.COAM Update several parameters via rest api
#     ...   parameters_to_update_via_api=${disable_8294_8CC}    timeout=${300}
#     ...   AND   Wait until cluster ready based on NSA_SA type    NSA_SA=SA
#     ...   AND   set suite variable    ${UL_TPUT_COMMON}    ${UL_TPUT_COMMON}
#     ...   AND   set suite variable    ${DL_TPUT_COMMON}    ${DL_TPUT_COMMON}
#     ...   AND   set suite variable    ${EXP_UL}    ${EXP_UL_COMMON}
#     ...   AND   set suite variable    ${EXP_DL}    ${EXP_DL_COMMON}
#     ...   AND   set suite variable    ${target_avg_percent}    ${1CC_PERCENT}
#     ...   ELSE   run keywords   set suite variable    ${UL_TPUT_COMMON}    ${8CC_tput_UL}
#     ...   AND   set suite variable    ${DL_TPUT_COMMON}    ${8CC_tput_DL}
#     ...   AND   set suite variable    ${EXP_UL}    ${8CC_tput_UL_EXP}
#     ...   AND   set suite variable    ${EXP_DL}    ${8CC_tput_DL_EXP}
#     ...   AND   set suite variable    ${target_avg_percent}    ${8CC_PERCENT}
