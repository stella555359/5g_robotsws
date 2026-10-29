# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008360_C_B2_case_135_IWK with MultipleDedicatedBWPs
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_xueminm
# Test Timeout      60 minutes
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      CB008360_case135_scfc.xml
# ${AIRPHONE_NAME}    CB008360_case135_ap.xml
# ${WTS_NAME}    wts_config_case135.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog\
# 
# ${pattern}    CA_P2_8x4_t2r4_n2_pusch_1layer
# *** Test Cases ***
# CB008360_C_B2_case_135_IWK with MultipleDedicatedBWPs
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 4 SA UEs,1UE's capability is restricted in small bwp
#     Step3:Push full buffer in UL
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Get and Update BSR File    par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Prepare gnb onair
# 
# 
# Step2:Attach 4 SA UEs,1UE's capability is restricted in small bwp
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
# 	airphone_execute_egate_command
#     ...    csi_override_testmode_nr profile_id\=1 cqi_mode\=fixed cqi\=15 ri_mode\=fixed ri\=1 pmi_mode\=fixed pmi\=0
#     Wait Throughput Timer    3
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=0
#     Wait Throughput Timer    3
#     Airphone SA Attach    ue_id=1
#     airphone_set_traffic_type    1    1    internal
#     Airphone Pdu Session Setup    1    1    1    1
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
# 
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=1 scell\=0
#     Wait Throughput Timer    3
#     Airphone SA Attach    ue_id=2
#     airphone_set_traffic_type    2    1    internal
#     Airphone Pdu Session Setup    2    1    1    2    
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0	
#     
# 	airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=3 testmode\=csi_override action\=activate profile_id\=1 scell\=0
# 	Airphone SA Attach    ue_id=3
#     airphone_set_traffic_type    3    1    internal
#     Airphone Pdu Session Setup    3    1    1    3 	
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10 scell\=0
#     
# 	airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=4 testmode\=csi_override action\=activate profile_id\=1 scell\=0
# 	Airphone SA Attach    ue_id=4
#     airphone_set_traffic_type    4    1    internal
#     Airphone Pdu Session Setup    4    1    1    4 	
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5 scell\=0	
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
# 	${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
# 	Set test Variable	 ${rnti_1} 	${rnti_list[0]}
# 	Set test Variable	 ${rnti_2} 	${rnti_list[1]}
# 	Set test Variable	 ${rnti_3} 	${rnti_list[2]}
# 	Set test Variable	 ${rnti_4} 	${rnti_list[3]}
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case135_rrc_small_bwp.ini
#     ...    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer in UL
#     Start Collect GNB and AP Syslog in 'Step3_data' File
#     Start GNB BIP Log
#     : FOR    ${u_id}    IN RANGE   1    5
#     \    Airphone SA Start Data Traffic    ${u_id}    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${u_id}    UL    170M    trf_id=2    pdu_id=1    duration=${3600}
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_data${/}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_data${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_data${/}tti_135
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case135_tti_small_bwp_FS.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step3_data${/}
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3_data${/}
#     Set Suite Variable    ${PM_counter_file}
# 	${PM_counter_value_M55308C28004}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C28004    cell_id=1
#     ${PM_counter_value_M55308C28008}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C28008    cell_id=1
#     should be true     ${PM_counter_value_M55308C28004} == 1
#     should be true     ${PM_counter_value_M55308C28008} == 3
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_data' File
