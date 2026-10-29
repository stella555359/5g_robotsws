# *** Settings ***
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
# Force Tags    owner_menzheng    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# Test Timeout      60 minutes
# Resource          ../../resources/KISS/robot/common_resource.robot
# Resource          ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_87957_case06_APLO_AQQL.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_2ABIL_1CELL.xml
# ${WTS_NAME}       wts_87957_case06.cfg
# ${COMAVALUE}    ${CURDIR}/coma/8701_coma_dft.txt
# ${UE_ID1}         1
# ${UE_ID2}         2
# ${UE_ID3}         3
# ${UE_ID4}         4
# ${UE_ID5}         5
# ${UE_ID6}         6
# ${UE_ID7}         7
# ${UE_ID8}         8
# ${UE_ID9}         9
# ${UE_ID10}         10
# ${UE_ID11}         11
# ${UE_ID12}         12
# ${UE_ID13}         13
# ${UE_ID14}         14
# ${UE_ID15}         15
# ${UE_ID16}         16
# ${GW_ID1}         1
# ${GW_ID2}         2
# ${GW_ID3}         3
# ${GW_ID4}         4
# ${GW_ID5}        5
# ${GW_ID6}         6
# ${GW_ID7}         7
# ${GW_ID8}         8
# ${GW_ID9}         9
# ${GW_ID10}        10
# ${GW_ID11}     11
# ${GW_ID12}     12
# ${GW_ID13}      13
# ${GW_ID14}       14
# ${GW_ID15}     15
# ${GW_ID16}     16
# ${PDU_ID}         1
# ${SLICE_ID}       1
# ${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
# ...    NUMBER_OF_FILES=30
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1-2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=3-4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=5-6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=7-8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=9-10 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE6}    ue_testmode_set_nr id\=11-12 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# ${SET_PROFILE7}    ue_testmode_set_nr id\=13-14 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
# ${SET_PROFILE8}    ue_testmode_set_nr id\=15-16 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
# 
# *** Test Cases ***
# CB0087957_Case06_18UEs_8Pos_rank2_pairing_SA_bandwith100_semistatic37
#     Modify Swconfig
#     Modify l1bypass
#     Active GNB L2 feature debug traces
#     Prepare gnb onair    
# 	run keyword and continue on failure    Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     #Set UE Pos
# 	Attach SA UEs
#     #run keyword and continue on failure    Check rrc log
#     Airphone override to rank2
#     run keyword and continue on failure    Send DL data to UE and check throughput
#     Start collect ttitrace    name=tti_16UE_8Pos
#     run keyword and continue on failure    Wait for '2s' to stop ttitrace with name'tti_16UE_8Pos'
#     #Check mupair in ttitrace
# 	Get 87957 counter
#     Send DL data to UE and check throughput-2
#     Start collect ttitrace    name=tti_16UE_8Pos-2
#     run keyword and continue on failure    Wait for '2s' to stop ttitrace with name'tti_16UE_8Pos-2'
# 	Get 87957 counter
#     #Check mupair in ttitrace-2
#     #Detach SA UEs
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords **
# Set UE Pos
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${SET_PROFILE1}
#     airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${SET_PROFILE2}
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${SET_PROFILE3}
#     airphone_execute_egate_command    ${PROFILE4}
#     airphone_execute_egate_command    ${SET_PROFILE4}
#     airphone_execute_egate_command    ${PROFILE5}
#     airphone_execute_egate_command    ${SET_PROFILE5}
#     airphone_execute_egate_command    ${PROFILE6}
#     airphone_execute_egate_command    ${SET_PROFILE6}
#     airphone_execute_egate_command    ${PROFILE7}
#     airphone_execute_egate_command    ${SET_PROFILE7}
#     airphone_execute_egate_command    ${PROFILE8}
#     airphone_execute_egate_command    ${SET_PROFILE8}
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=9 sinr_target_srs\=35 sinr_target_pucch\=-300 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-16 testmode\=ul_sinr action\=activate profile_id\=9
# 
# Internal send DL data
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone SA Start Data Traffic    ${num}    DL    100M    pdu_id=1    duration=6000s
#     \    ...    trf_id=${num}
#     \    Wait '3s ' to stable
# 
# Wait '${time} ' to stable
#     sleep    ${time}
# 
# Send DL data to UE and check throughput-2
#     SEND DL data to 18UE-2
#     Wait '20s ' to stable
#     Check throughput-2
# 
# SEND DL data to 18UE-2
#     : FOR    ${ue_id}    IN RANGE    1    19
# 	\   SEND data to '${ue_id}'
# 	
# SEND data to '${ue_id}'
# 	: FOR    ${num}    IN RANGE    1    2	
# 	\   Airphone SA Start Data Traffic    ${ue_id}    DL    175M    pdu_id=1    duration=6000s    trf_id=${num}   protocol=tcp
# 
# Detach SA UEs
#     : FOR    ${num}    IN RANGE    1    19
#     \    airphone_sa_detach    ue_id=${num}
#     \    Wait '3s' for stabible
# 
# Attach SA UEs
#     : FOR    ${num}    IN RANGE    1    19
#     \    Airphone Set Traffic Type    ${num}    ${PDU_ID}    internal
#     \    Airphone SA Attach    ue_id=${num}
#     \    Airphone Pdu Session Setup    ${num}    ${PDU_ID}    ${SLICE_ID}    ${num}
#     
# Check mupair in ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case20-1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check throughput-2
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Check rrc log
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate    unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/rrc_8305.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate
# 
# Verify throughput-2
#     : FOR    ${num}    IN RANGE    1    19
#     \    ${dl_throughput_ue}=    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    log to console    ${dl_throughput_ue}
#     \    should_be_true    ${dl_throughput_ue}>100000 
# 
# Send DL data to UE and check throughput
#     SEND DL data to 18UE
#     Wait '20s ' to stable
#     Check throughput
# 
# SEND DL data to 18UE
#     airphone_execute_egate_command    trf_data_start ue\=1-8 pdu\=1 dir\=dl trf_id\=1 mbps\=175 seconds\=6000s protocol\=tcp
#     airphone_execute_egate_command    trf_data_start ue\=9-16 pdu\=1 dir\=dl trf_id\=1 mbps\=50 seconds\=6000s protocol\=tcp
#     airphone_execute_egate_command    trf_data_start ue\=17-18 pdu\=1 dir\=dl trf_id\=1 mbps\=175 seconds\=6000s protocol\=tcp
# 	
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Verify throughput
#     : FOR    ${num}    IN RANGE    1    19
#     \    ${dl_throughput_ue}=    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    log to console    ${dl_throughput_ue}
#     \    should_be_true    ${dl_throughput_ue}>10000 
# 
# Check mupair in ttitrace-2
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case20-2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex13}    ${Vindex7}    ${Hindex13}    ${Vindex7}
#     ...    ${Hindex10}    ${Vindex8}    ${Hindex10}    ${Vindex8}
#     ...    ${Hindex6}    ${Vindex7}    ${Hindex6}    ${Vindex7}
#     ...    ${Hindex2}    ${Vindex8}    ${Hindex2}    ${Vindex8}
#     ...    ${Hindex25}    ${Vindex7}    ${Hindex25}    ${Vindex7}
#     ...    ${Hindex21}    ${Vindex8}     ${Hindex21}    ${Vindex8}
#     ...    ${Hindex17}    ${Vindex7}     ${Hindex17}    ${Vindex7}
#     ...    ${Hindex14}    ${Vindex8}     ${Hindex14}    ${Vindex8}
# 
# Airphone override to rank2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-18 testmode\=csi_override action\=activate profile_id\=1
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=9 sinr_target_srs\=35 sinr_target_pucch\=-300 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-18 testmode\=ul_sinr action\=activate profile_id\=9
# 
# Modify Swconfig
#     Add GNB swconfig    0x580450:4
#     Add GNB swconfig    0x5801c8:0
#     Add GNB swconfig    0x580587:16	
# 	Add GNB swconfig    0x340000:15
# 	
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode    name=${tti_tag}
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti
# 	
# Get 87957 counter
#     Wait '40s' for stable
#     ${PRB_DL_SU_MIMO_LAYER_list}   create list
#     ${PRB_DL_MU_MIMO_LAYER_list}   create list
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     log to console    ${remaining_time}
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
#     : FOR    ${num}    IN RANGE    1    5
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C3400${num}    cell_id=1
#     \    set suite variable     ${PRB_DL_SU_MIMO_${num}LAYER}     ${result}
#     \    append to list    ${PRB_DL_SU_MIMO_LAYER_list}    ${PRB_DL_SU_MIMO_${num}LAYER}
#     \    log to console    ${PRB_DL_SU_MIMO_LAYER_list}
#     : FOR    ${num}    IN RANGE    5    10
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C3400${num}    cell_id=1
#     \    ${num_layer}   evaluate   ${num}-3
#     \    set suite variable     ${PRB_DL_MU_MIMO_${num_layer}LAYER}     ${result}
#     \    append to list    ${PRB_DL_MU_MIMO_LAYER_list}    ${PRB_DL_MU_MIMO_${num_layer}LAYER}
#     \    log to console    ${PRB_DL_MU_MIMO_LAYER_list}
#     : FOR    ${num}    IN RANGE    10    12
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C340${num}    cell_id=1
#     \    ${num_layer}   evaluate   ${num}-3
#     \    set suite variable     ${PRB_DL_MU_MIMO_${num_layer}LAYER}     ${result}
#     \    append to list    ${PRB_DL_MU_MIMO_LAYER_list}    ${PRB_DL_MU_MIMO_${num_layer}LAYER}
#     \    log to console    ${PRB_DL_MU_MIMO_LAYER_list}
#     : FOR    ${num}    IN RANGE    16    24
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C340${num}    cell_id=1
#     \    ${num_layer}   evaluate   ${num}-7
#     \    set suite variable     ${PRB_DL_MU_MIMO_${num_layer}LAYER}     ${result}
#     \    log to console    ${PRB_DL_MU_MIMO_${num_layer}LAYER}
#     \    append to list    ${PRB_DL_MU_MIMO_LAYER_list}    ${PRB_DL_MU_MIMO_${num_layer}LAYER}
#     \    log to console    ${PRB_DL_MU_MIMO_LAYER_list}
#     log to console    SUlayer 1_2_3_4 ${PRB_DL_SU_MIMO_LAYER_list}
#     log to console    MUlayer 2_3_4_5_6_7_8_9_10_11_12_13_14_15_16 ${PRB_DL_MU_MIMO_LAYER_list}
# 
#     ${MAC_DTCH_CELL_THP_DL_MAX}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55309C12001    cell_id=1
#     ${Cell1_TP_total}    evaluate    ${MAC_DTCH_CELL_THP_DL_MAX}*8/1024/1024
#     log to console    ${Cell1_TP_total}     
