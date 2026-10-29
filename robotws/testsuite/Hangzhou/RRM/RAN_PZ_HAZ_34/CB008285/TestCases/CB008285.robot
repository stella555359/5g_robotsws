# *** Settings ***
# Resource    ./../Resources/CB008285_keywords.robot
# Resource    ./../Resources/Ntracer_keywords.robot
# 
# Documentation    Suite description
# ...   author: Ren Biyao
# ...   contact: biyao.ren@nokia-sbell.com
# ...   squad group: MMW_SG1
# ...   Feature CB008285
# Force Tags      5G_RRM
# ...    PY36
# Suite Setup     8285 suite preparation
# Suite Teardown  run keyword and ignore error    Common suite recovery    is_log_required=${True}
# 
# *** Test Cases ***
# [1]CB008285_A_016_single_UE_TCP_Data_Transfer_FR2_Cell_L3_call_100M_64QAM_for_SA_mode_with_32_SSB_beam_2_CELLGROUP
#     [Tags]    CIT_TRUNK
#     [Documentation]    Author: Ren Biyao
#     [Setup]    Common case setup    NSA_SA=SA
# #    set test variable    ${MRBTS_ID}    ${tl.gnbs[0].instance_id}
# #    run keyword if    "${MRBTS_ID}"=="2103"    Perform Serving Cell Block Unblock      cell_idx=${all_cell_ids[0]}
#     Run Keyword And Continue On Failure    L3 call check tput with power UE method
#     ...    nr_cell_id=${pcell_nrCellIdentity}    dl_tput=600M    ul_tput=160M    exp_ul=144    exp_dl=533    tput_check_duration=300s
#     ...    ignore_time=20s    actCarrierAggregation=${False}    data_transfer_direction=both
#     ...    traffic_duration=3000    prepare_ue_needed=${True}    target_avg_percent=0.98
# #    attach CPE UE for FR2 SA
# #    Start both traffic then verify throughput as expect FR2 SA for CPE    pcell_nrCellIdentity=${pcell_nrCellIdentity}
# #    ...                                         tput_duration=900    log_duration=5m    check_tput_ignore_time=20s
#     [Teardown]    run keyword and ignore error    8285 case teardown
# 
# 
# [1]CB008285_A_011_5GC00742_successful_activate_FR2_Cell_for_SA_mode_with_mismatch_configuration_for_OSI_with_32_SSB_beam_2_CELLGROUP
#     [Tags]    CIT_TRUNK
#     [Documentation]    Author: Ren Biyao
#     ...    1. Onair then modify OSI
#     ...    2. Check fault 7516 : EFaultId_IncorrectCellParameterSettingAl is raised in gNB-DU.
#     ...    3. with alarm ue can still attach and one cell degrade while other cells onair, check bi-dir tput not 0.
#     ...    4. Disable osi and check fault 7516 absent and cell onair
#     [Setup]    Common case setup    NSA_SA=SA
#     log to console    \n ... Enable OSI and Check fault 7516 present ...
#     coam_gnb_classical.connect to gnb coam via ssl
#     nidd_modify.online_modify_nidd_parameters_via_restapi    params_modify_dict=${DICT_ENABLE_OSI_CREATE_MISMATCH}   timeout=${300}
#     Wait For Expect Fault Present    faultId=7516    timeout=${300}
#     ${cells_info}   coam.get_cells_info    cell_type=nr    timeout=30    connection=GNB_OAM
#     FOR  ${cell}  IN  @{cells_info}
#          run keyword if    '${cell['globalCellId']}'=='251'
#          ...    Run keyword and continue on failure    Should be equal as strings    ${cell['status']['availabilityStatus']}    degraded
#          ...    ELSE    run keywords    Run keyword and continue on failure
#          ...    Should be equal as strings    ${cell['status']['operationalState']}    enabled
#          ...    AND     Run keyword and continue on failure   Dictionary Should Not Contain Value    ${cell['status']}    degraded
#     END
# #    attach CPE UE for FR2 SA
# #    Start both traffic then verify throughput as expect FR2 SA for CPE    pcell_nrCellIdentity=${pcell_nrCellIdentity}
# #    ...                                         tput_duration=900    log_duration=5m    check_tput_ignore_time=20s
# #    ...                                         target_avg_percent=0.8    min_percent=0.8
# 
#     Run Keyword And Continue On Failure    L3 call check tput with power UE method
#     ...    nr_cell_id=${pcell_nrCellIdentity}    dl_tput=${DL_TPUT_COMMON}    ul_tput=${UL_TPUT_COMMON}
#     ...    exp_ul=${EXP_UL_COMMON}    exp_dl=${EXP_DL_COMMON}    tput_check_duration=60
#     ...    ignore_time=20s    actCarrierAggregation=${False}    data_transfer_direction=both
#     ...    traffic_duration=150    prepare_ue_needed=${True}    target_avg_percent=${PERCENT_AVG}
# 
#     log    add detach step to prevent ue crash
#     run keyword and ignore error    power_ue.UE detach    ue_type=${UE_TYPE}    ue_index=${0}
#     run keyword and ignore error    taf_ue.detach ue    UE_0
# 
#     log to console    \n ... Disable OSI and Check fault 7516 absent ...
#     coam_gnb_classical.COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_DISABLE_OSI}   timeout=${300}
#     Wait For Expect Fault To Disappear    faultId=7516    timeout=${480}
#     Wait cell onair classical cloud
#     [Teardown]    run keyword and ignore error    8285 case teardown
# 
# [1]CB008285_B_013_CB006530_Successful_New_NIDD_Parameters_added_and_delete_in_FEATCADM_For_Proper_Role_based_User_modification
#     [Tags]    CIT_TRUNK
#     [Documentation]    Author: Ren Biyao
#     ...     1. Enable of FR2 SA
#     ...     2. CB006020 configuration, one SA and one NSA
#     ...     3. when configuring FEATCADM, admin user cannot online modify, but commision scf will ot be impacted
#     [Setup]    robot_common_operations.Common Case Setup
#     log to console   \n ...configure FR2 SA and CB006020 and PARAM PREVENT...
#     COAM Create log directory
#     set test variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_6020}
#     set test variable    ${PARAMS_TO_DELETE}    ${DELETE_SCF_6020}
#     ${PARAMS_TO_ADD}     combine lists     ${ADD_SCF_PARAM_PREVENT}    ${ADD_SCF_6020}
#     ${template_for_process}    scfpro.SCFProcess    scf_template_path=${SCF_DEFAULT_FILE_PATH}
#     ...     scf_process_folder=${TS_CASE_LOG_PATH}    list_para_to_delete=${PARAMS_TO_DELETE}
#     ...    list_para_to_modify=${PARAMS_TO_MODIFY}    list_para_to_add=${PARAMS_TO_ADD}
#     coam_gnb_classical.connect to gnb coam via ssl
#     Do commission and return PDL validation result for classical
#     ...    is_pdl_checking_needed=${False}    scf_template_path=${template_for_process}
#     Wait until cluster is on cell on air status    is_all_cells_checking_needed=${True}
#     ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
# #    attach CPE UE for FR2 SA
#     ${attach_result}    run keyword and return status    retry commercial ue attach if failed    ue_type=${UE_TYPE}    prepare_ue_needed=${True}
#     ...    attach_check_type=PROXY_log    cell_id=${pcell_nrCellIdentity}
#     Run Keyword And Continue On Failure    should be true     ${attach_result}==${True}
#     set test variable    ${ATTACH_RESULT}    ${attach_result}
#     Aasyslog precondition
#     Start the Aasyslog save progress    filter=L2   log_name=Prameter_verification.txt
#     log to console    \n... when configuring PARAM PREVENT, admin user cannot online modify  ...
#     coam_gnb_classical.connect to gnb coam via ssl
#     run keyword and expect error    *not allowed*    coam_gnb_classical.COAM Update several parameters via rest api
#     ...    parameters_to_update_via_api=${MOD_PARAM_PREVENT}
#     [Teardown]    run keyword and ignore error     run keywords
#     ...    Do commission and return PDL validation result for classical    is_pdl_checking_needed=${False}
#     ...    AND    Wait until cluster is on cell on air status    is_all_cells_checking_needed=${True}
#     ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
#     ...    AND    8285 case teardown
# 
# [1]CB008285_B_007_5GC000733_Paging_for_SI_Modification_Multiple_Beam_with_CB006020_Enabled
#     [Tags]    CIT_TRUNK
#     [Documentation]    Author: Ren Biyao & Jing Chen
#     ...    The purpose of this test case is to verify GNB’s supporting paging for SI modification of
#     ...    B4 PRACH for a FR2 Standalone Cell to extended cell range.
#     ...    1. Configure CB006020 and CB007732
#     ...    2. Modify qRxLevMin parameter to tirgger SIB sending
#     ...    3. After discussed with case owner, there's no need to do traffic verification in this case
# 
#     [Setup]    robot_common_operations.Common Case Setup
#     COAM Create log directory
#     ${PARAMS_TO_MODIFY}     combine lists     ${MODIFY_SCF_7723}    ${MODIFY_SCF_6020}
#     set test variable    ${PARAMS_TO_DELETE}    ${DELETE_SCF_6020}
#     ${PARAMS_TO_ADD}     combine lists    ${ADD_SCF_6020}   ${ADD_SCF_7723}
#     ${template_for_process}    scfpro.SCFProcess    scf_template_path=${SCF_DEFAULT_FILE_PATH}
#     ...     scf_process_folder=${TS_CASE_LOG_PATH}    list_para_to_delete=${PARAMS_TO_DELETE}
#     ...    list_para_to_modify=${PARAMS_TO_MODIFY}    list_para_to_add=${PARAMS_TO_ADD}
#     coam_gnb_classical.connect to gnb coam via ssl
#     Do commission and return PDL validation result for classical
#     ...    is_pdl_checking_needed=${False}    scf_template_path=${template_for_process}
#     Wait until cluster is on cell on air status    is_all_cells_checking_needed=${True}
#     ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
#     log to console   \n ... Enable 5GC000733 and set long inactivity timer ...
#     coam_gnb_classical.COAM Update several parameters via rest api    parameters_to_update_via_api=${Enable_733}   timeout=${300}
#     Start capture F1AP log    tcpdump_collector_name=paging   options=-i any sctp
# #   attach CPE UE for FR2 SA
#     ${attach_result}    run keyword and return status    retry commercial ue attach if failed    ue_type=${UE_TYPE}    prepare_ue_needed=${True}
#     ...    attach_check_type=PROXY_log    cell_id=${pcell_nrCellIdentity}
#     Run Keyword And Continue On Failure    should be true     ${attach_result}==${True}
#     set test variable    ${ATTACH_RESULT}    ${attach_result}
#     Aasyslog precondition
#     Start the Aasyslog save progress    filter=L2   log_name=paging_chekcing.txt
#     coam_gnb_classical.COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_RX_LEVEL}   timeout=${300}
#     Check messageInfo in aasyslog   messageInfo=PdcchSendReq with Paging content has been sent    timeout=90s
#     ...                             aasyslog_name=paging_chekcing.txt
#     ${paging}    Stop tcpdump log collection    tcpdump_collector_name=paging
#     [Teardown]    run keyword and ignore error    8285 case teardown
# 
# [1]CB008285_B_008_5GC000740_NG_C_link_locking_unlocking_with_One_AMF_SA_calls
#     [Tags]    CRT_TRUNK
#     [Documentation]    Author: Zhou Charlie
#     ...     1. add 2 AMF, modify counter interval, check 3 AMF status ok, check cells status ok
#     ...     2. CPE attach, start bi-direction data, check CPE tput ok
#     ...     3. lock default AMF, check other 2 AMF status ok, check cells status ok, check CPE tput ok
#     ...     4. unlock default AMF, check all 3 AMF status ok, check cells status ok, check CPE tput ok
#     ...     5. check counters M55119C00501, M55119c00001, M55119c00002.
#     [Setup]    Common case setup    NSA_SA=SA
#     log to console    \n ... modify counter interval on base SCF and do commission, then online add 2 AMF server ...
#     COAM Create log directory
#     set test variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_NG_LINK_COUNTER_INTERVAL}
#     ${template_for_process}    scfpro.SCFProcess    scf_template_path=${SCF_DEFAULT_FILE_PATH}
#     ...     scf_process_folder=${TS_CASE_LOG_PATH}    list_para_to_modify=${PARAMS_TO_MODIFY}
#     coam_gnb_classical.connect to gnb coam via ssl
#     Do commission and return PDL validation result for classical
#     ...    is_pdl_checking_needed=${False}    scf_template_path=${template_for_process}
#     Wait until cluster is on cell on air status    is_all_cells_checking_needed=${True}
#     ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
#     nidd_modify.online_modify_nidd_parameters_via_restapi    params_modify_dict=${DICT_ADD_MULTI_NG_LINK}   timeout=${300}
#     Check All NR cells On Air
#     Check All AMF ngLinkStatus Active
# 
#     log to console    \n... CPE SA attach and check status with aasyslog ...
# #    attach CPE UE for FR2 SA
# #    log to console    \n... Start bi-dir data transmission and check tput ...
# #   Start both traffic FR2 SA for CPE    tput_duration=1200s    dl_length=1400B    process_num=1
# #    verify throughput as expect FR2 SA for CPE    pcell_nrCellIdentity=${pcell_nrCellIdentity}
# #    ...    target_avg_percent=0.8   min_percent=0.8
# 
#     Run Keyword And Continue On Failure    L3 call check tput with power UE method
#     ...    nr_cell_id=${pcell_nrCellIdentity}    dl_tput=${DL_TPUT_COMMON}    ul_tput=${UL_TPUT_COMMON}
#     ...    exp_ul=${EXP_UL_COMMON}    exp_dl=${EXP_DL_COMMON}    tput_check_duration=60
#     ...    ignore_time=20s    actCarrierAggregation=${False}    data_transfer_direction=both
#     ...    traffic_duration=1200    prepare_ue_needed=${True}    target_avg_percent=0.8    min_percent=0.8
#     ...    is_need_to_stop_traffic=${False}
# 
#     ${case_start_time_info}    Prepare for counter log
# 
#     log to console    \n... Lock default NG link, then check cells and AMFs status ...
#     coam_gnb_classical.COAM Update several parameters via rest api
#     ...    parameters_to_update_via_api=${MODIFY_LOCK_SERVEDAMF1}   timeout=${300}
#     Check All NR cells On Air
#     Check Only Default AMF ngLinkStatus Inactive
# 
#     log to console    \n... Check tput after locking NG link ...
# #    verify throughput as expect FR2 SA for CPE    pcell_nrCellIdentity=${pcell_nrCellIdentity}
# #    ...    target_avg_percent=0.8   min_percent=0.8
#     ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=60    ignore_time=10s   filter=L2Lo    check_source=aasyslog
# 
#     Run Keyword And Continue On Failure    Check tput via power UE with power UE method    cell_id=${pcell_nrCellIdentity}
#     ...    exp_ul=${EXP_UL_COMMON}    exp_dl=${EXP_DL_COMMON}
#     ...    log=${tput_log}    target_avg_percent=0.8      min_percent=0.8    actCarrierAggregation=${False}
# 
#     log to console    \n ... Unlock default NG link, then check cells and AMFs status ...
#     coam_gnb_classical.COAM Update several parameters via rest api
#     ...    parameters_to_update_via_api=${MODIFY_UNLOCK_SERVEDAMF1}   timeout=${300}
#     Check All NR cells On Air
#     Check All AMF ngLinkStatus Active
# 
#     log to console    \n... Check tput after unlocking NG link ...
# #    verify throughput as expect FR2 SA for CPE    pcell_nrCellIdentity=${pcell_nrCellIdentity}
# #    ...    target_avg_percent=0.8   min_percent=0.8
#     ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=60    ignore_time=10s   filter=L2Lo    check_source=aasyslog
# 
#     Run Keyword And Continue On Failure    Check tput via power UE with power UE method    cell_id=${pcell_nrCellIdentity}
#     ...    exp_ul=${EXP_UL_COMMON}    exp_dl=${EXP_DL_COMMON}
#     ...    log=${tput_log}    target_avg_percent=0.8      min_percent=0.8    actCarrierAggregation=${False}
# 
#     log to console    \n... Check lock and unlock NG link related counters...
#     run keyword and continue on failure       Check NG Link Lock Unlock Counter
#     ...    starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}
#     [Teardown]    run keyword and ignore error    8285 case teardown
# 
# [1]CB008285_B_010_CNI_94156_ RRC_Setup_and_RRC_Reestablishment_FR2_SA_Cell
#     [Tags]    CRT_TRUNK
#     [Documentation]    Author: Zhou Charlie
#     ...     1. CPE attach, start bi-direction data, check CPE tput ok
#     ...     2. enable CNI-94156
#     ...     3. CPE attach, start bi-direction data, check CPE tput ok.
#     [Setup]    Common case setup    NSA_SA=SA
#     log to console    \n ... do base SCF commission and check PDL error ...
#     COAM Create log directory
#     ${template_for_process}    scfpro.SCFProcess    scf_template_path=${SCF_DEFAULT_FILE_PATH}
#     ...     scf_process_folder=${TS_CASE_LOG_PATH}
#     coam_gnb_classical.connect to gnb coam via ssl
#     Do commission and return PDL validation result for classical
#     ...    is_pdl_checking_needed=${True}    scf_template_path=${template_for_process}
#     Wait until cluster is on cell on air status    is_all_cells_checking_needed=${True}
#     ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
# 
#     log to console    \n... CPE SA attach, start bi-dir data transmission and check tput ...
#     ${tcpdump_log_name}    set variable    CPE_attach_1
#     Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}   options=-i any sctp
# #    attach CPE UE for FR2 SA
#     ${attach_result}    run keyword and return status    retry commercial ue attach if failed    ue_type=${UE_TYPE}    prepare_ue_needed=${True}
#     ...    attach_check_type=PROXY_log    cell_id=${pcell_nrCellIdentity}
#     Run Keyword And Continue On Failure    should be true     ${attach_result}==${True}
#     set test variable    ${ATTACH_RESULT}    ${attach_result}
#     sleep    10s
#     ${CPE_attach_log}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}
# #    Start both traffic FR2 SA for CPE    tput_duration=180s    dl_length=1400B    process_num=1
#     Run Keyword And Continue On Failure    Start data transfer based on direction    dl_tput=${DL_TPUT_COMMON}    ul_tput=${UL_TPUT_COMMON}
#     ...    duration=180    protocol=udp    data_transfer_direction=both    window=1M
# #   verify throughput as expect FR2 SA for CPE    pcell_nrCellIdentity=${pcell_nrCellIdentity}
#     ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=60    ignore_time=10s   filter=L2Lo    check_source=aasyslog
#     Run Keyword And Continue On Failure    Check tput via power UE with power UE method    cell_id=${pcell_nrCellIdentity}
#     ...    exp_ul=${EXP_UL_COMMON}    exp_dl=${EXP_DL_COMMON}    log=${tput_log}    actCarrierAggregation=${False}
# 
#     Verify RRC SETUP configuring BWP using initial BWP profile    log_path_pcap=${CPE_attach_log}    isUsedInitialBwp=${False}
#     Stop both traffic FR2 SA and detach CPE
# 
#     log to console    \n... enable CNI-94156 ...
#     coam_gnb_classical.COAM Update several parameters via rest api
#     ...    parameters_to_update_via_api=${MODIFY_ENABLE_CNI_94156}   timeout=${300}
#     Wait cell onair classical cloud
# 
#     log to console    \n... CPE SA attach again, start bi-dir data transmission and check tput ...
#     ${tcpdump_log_name}    set variable    CPE_attach_2
#     Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}   options=-i any sctp
# #   attach CPE UE for FR2 SA    require_UE=${False}
#     ${attach_result}    run keyword and return status    retry commercial ue attach if failed    ue_type=${UE_TYPE}    prepare_ue_needed=${False}
#     ...    attach_check_type=PROXY_log    cell_id=${pcell_nrCellIdentity}
#     Run Keyword And Continue On Failure    should be true     ${attach_result}==${True}
#     set test variable    ${ATTACH_RESULT}    ${attach_result}
#     sleep    10s
#     ${CPE_attach_log}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}
# #   Start both traffic FR2 SA for CPE    tput_duration=180s    dl_length=1400B    process_num=1
#     Run Keyword And Continue On Failure    Start data transfer based on direction    dl_tput=${DL_TPUT_COMMON}    ul_tput=${UL_TPUT_COMMON}
#     ...    duration=180    protocol=udp    data_transfer_direction=both    window=1M
# #   verify throughput as expect FR2 SA for CPE    pcell_nrCellIdentity=${pcell_nrCellIdentity}
# 
#     ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=60    ignore_time=10s   filter=L2Lo    check_source=aasyslog
#     Run Keyword And Continue On Failure    Check tput via power UE with power UE method    cell_id=${pcell_nrCellIdentity}
#     ...    exp_ul=${EXP_UL_COMMON}    exp_dl=${EXP_DL_COMMON}    log=${tput_log}    actCarrierAggregation=${False}
# 
#     Verify RRC SETUP configuring BWP using initial BWP profile    log_path_pcap=${CPE_attach_log}    isUsedInitialBwp=${True}
# 
#     [Teardown]    run keywords    run keyword and ignore error    Stop tcpdump log collection
#     ...    tcpdump_collector_name=${tcpdump_log_name}    AND    run keyword and ignore error    8285 case teardown
# 
# [1]CB008285_B_020_CB007516_Successful_IDLE_Mode_mobility_to_select_Pcell_based_on_configured_Priority_FR2_SA
#     [Tags]    CRT_TRUNK
#     [Documentation]    Author: Qi Xin
#     ...     1. Enable FR2 SA
#     ...     2. CB007516 configuration with non-CA aware algorithm and with mobility profiles
#     ...     3. gNB shall send RRC Release message with celReselectionPriorities IE to the UE
#     ...     4. Check counter RMOP_SA_PROFILE_SELECTED_01, NRRCC_RRC_RELEASE_IMM_NR, NRRCC_RRC_RELEASE_SENT.
# 
#     [Setup]    robot_common_operations.Common Case Setup
#     log to console   \n ...configure FR2 SA and CB007516...
#     COAM Create log directory
#     set test variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_7516}
#     set test variable    ${PARAMS_TO_ADD}    ${ADD_SCF_7516}
#     ${template_for_process}    scfpro.SCFProcess    scf_template_path=${SCF_DEFAULT_FILE_PATH}
#     ...    scf_process_folder=${TS_CASE_LOG_PATH}    list_para_to_modify=${PARAMS_TO_MODIFY}
#     ...    list_para_to_add=${PARAMS_TO_ADD}
#     coam_gnb_classical.connect to gnb coam via ssl
#     Do commission and return PDL validation result for classical
#     ...    is_pdl_checking_needed=${True}    scf_template_path=${template_for_process}
#     Wait until cluster is on cell on air status    is_all_cells_checking_needed=${True}
#     ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
# 
#     ${starting_log_timestamp}    Prepare for counter log    reporting_interval=5
# 
# #   attach CPE UE for FR2 SA
#     ${attach_result}    run keyword and return status    retry commercial ue attach if failed    ue_type=${UE_TYPE}    prepare_ue_needed=${True}
#     ...    attach_check_type=PROXY_log    cell_id=${pcell_nrCellIdentity}
#     Run Keyword And Continue On Failure    should be true     ${attach_result}==${True}
#     set test variable    ${ATTACH_RESULT}    ${attach_result}
#     run keyword and continue on failure    Check PM counter M55124C00001 M55124C05501 M55157C00033
#     ...    starting_log_timestamp=${starting_log_timestamp['log_generator_timestamp']}
#     [Teardown]    run keyword and ignore error    8285 case teardown
# 
# [1]CB008285_B_025_5GC001778_Successful_L3_call_PCMD_Cell_Trace_report_on_the_GNB_CU_DU_after_Cell_lock_unlock
#     [Tags]    CIT_TRUNK
#     [Documentation]    Author: Jing Chen
#     ...     1. Modify SCF to enable PCMD trace functionality
#     ...     2. Cell block unblock on line
#     ...     3. Ntrace setup preparation: delete old file, stop/start ntracer process
#     ...     4. Attach and start traffic, detach UE
#     ...     5. check message flow from
#     [Setup]    robot_common_operations.Common Case Setup
#     COAM Create log directory
#     set test variable    ${PARAMS_TO_MODIFY}    ${ENABLE_PCMD_CELL_TRACE_REPORT}
#     set test variable    ${PARAMS_TO_ADD}    ${ADD_SCF_PCMD_TRACE_REPORT}
#     ${template_for_process}    scfpro.SCFProcess    scf_template_path=${SCF_DEFAULT_FILE_PATH}
#     ...    scf_process_folder=${TS_CASE_LOG_PATH}    list_para_to_modify=${PARAMS_TO_MODIFY}
#     ...    list_para_to_add=${PARAMS_TO_ADD}
#     Ntrace setup preparation    trace_host=${TRACE_HOST}    trace_user=${TRACE_USER}    trace_password=${TRACE_PASSWORD}
#     ...                    emil_host=${EMIL_HOST}      emil_user=${EMIL_USER}      emil_password=${EMIL_PASSWORKD}
#     coam_gnb_classical.connect to gnb coam via ssl
#     Do commission and return PDL validation result for classical
#     ...    is_pdl_checking_needed=${False}    scf_template_path=${template_for_process}
#     Wait until cluster is on cell on air status    is_all_cells_checking_needed=${True}
#     ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
#     Perform Serving Cell Block Unblock      cell_idx=${all_cell_ids[0]}
# #   attach CPE UE for FR2 SA
# #    Start both traffic then verify throughput as expect FR2 SA for CPE    pcell_nrCellIdentity=${pcell_nrCellIdentity}
# #    ...                                         tput_duration=900    log_duration=5m    check_tput_ignore_time=20s
# #    ...                                         target_avg_percent=0.8    min_percent=0.8
#     Run Keyword And Continue On Failure    L3 call check tput with power UE method
#     ...    nr_cell_id=${pcell_nrCellIdentity}    dl_tput=${DL_TPUT_COMMON}    ul_tput=${UL_TPUT_COMMON}
#     ...    exp_ul=${EXP_UL_COMMON}    exp_dl=${EXP_DL_COMMON}    tput_check_duration=300
#     ...    ignore_time=20s    actCarrierAggregation=${False}    data_transfer_direction=both
#     ...    traffic_duration=900    prepare_ue_needed=${True}    target_avg_percent=0.8    min_percent=0.8
# 
# #    ute_ue.Release PDU session     AT_BASED_UE
# #    ute_ue.Detach Ue    AT_BASED_UE
#     Stop both traffic FR2 SA and detach CPE
#     sleep    5s
#     Convert Ntrace logs     trace_host=${TRACE_HOST}  trace_user=${TRACE_USER}  trace_password=${TRACE_PASSWORD}
#     ...                    emil_host=${EMIL_HOST}  emil_user=${EMIL_USER}  emil_password=${EMIL_PASSWORKD}
#     [Teardown]    run keyword and ignore error    Ntracer Teardown
# 
# 
# [1]CB008285_B_029_5GC001681_Successful_uplane_L2_data_flow_sherpa_trace_capture_and_decode_for_multicell_FR2_SA_Cell_with_B4_PRACH
#     [Tags]    CRT_TRUNK
#     [Documentation]    Author: Tony2 Tang
#     ...     1. The purpose of this test case is to verify GNB’s supporting of the sherpa, ttitrace, bip, IQ data
#     ...     2. Configure CB007732 and B4 PRACH for a FR2 Standalone Cell to extended cell range.
#     ...     3. Configure common configuration and sherpa configuration in debug trace on webum
#     ...     4. CPE attach, start bi-direction data, check CPE tput ok
#     ...     5. Capture sherpa trace on UTE.
#     ...     6. check sherpa trace.
#     [Setup]
#     Common case setup    NSA_SA=SA
#     coam_gnb_classical.COAM Update several parameters via rest api
#     ...    parameters_to_update_via_api=${DICT_ENABLE_B4_532}    timeout=${300}
#     Wait until cluster ready based on NSA_SA type        NSA_SA=SA
# 
#     Common Debug Trace Configure And Sherpa Enable
# #    attach CPE UE for FR2 SA
# #    Start both traffic then verify throughput as expect FR2 SA for CPE   pcell_nrCellIdentity=${pcell_nrCellIdentity}
# #    ...    exp_ul=${EXP_UL_B4}  exp_dl=${EXP_DL_B4}  target_avg_percent=0.85
# 
#     Run Keyword And Continue On Failure    L3 call check tput with power UE method
#     ...    nr_cell_id=${pcell_nrCellIdentity}    dl_tput=${DL_TPUT_COMMON}    ul_tput=${UL_TPUT_COMMON}
#     ...    exp_ul=${EXP_UL_B4}    exp_dl=${EXP_DL_B4}    tput_check_duration=60
#     ...    ignore_time=20s    actCarrierAggregation=${False}    data_transfer_direction=both
#     ...    traffic_duration=150    prepare_ue_needed=${True}    target_avg_percent=0.85
# 
# 
#     log to console   \n ... Tcpdump Sherpa log on UTE...
#     Start UTE capture
#     Stop UTE capture
#     Disable sherpa Trace
#     [Teardown]    run keyword and ignore error    8285 case teardown
