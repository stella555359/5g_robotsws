# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
# Force Tags    owner_menzheng    AP    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Test Timeout      60 minutes
# Resource          ../../resources/KISS/robot/common_resource.robot
# Resource          ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_87957_case05_APLO_AEHC.xml
# ${AIRPHONE_NAME}    IPHY_AEHC_1CELL_APLO.xml
# ${WTS_NAME}       wts_aehc_87957_aplo.cfg
# ${COMAVALUE}    ${CURDIR}/coma/8305.txt
# ${UE_ID1}         1
# ${UE_ID2}         2
# ${UE_ID3}         3
# ${UE_ID4}         4
# ${GW_ID1}         1
# ${GW_ID2}         2
# ${GW_ID3}         3
# ${GW_ID4}         4
# ${PDU_ID}         1
# ${SLICE_ID}       1
# ${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
# ...    NUMBER_OF_FILES=30
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# 
# *** Test Cases ***
# CB0087957_Case05_4UEs_2Pos_rank2_pairing_SA_bandwith100_semistatic37
#     Modify Swconfig
#     Active GNB L2 feature debug traces
#     Get and Update BSR File    ${par_of_bsr_name}
# 	Prepare gnb onair    
# 	run keyword and continue on failure    Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     Set UE Pos
#     Airphone Set Traffic Type    ${UE_ID1}    ${PDU_ID}    internal
#     Airphone Set Traffic Type    ${UE_ID2}    ${PDU_ID}    internal
#     Airphone Set Traffic Type    ${UE_ID3}    ${PDU_ID}    internal
#     Airphone Set Traffic Type    ${UE_ID4}    ${PDU_ID}    internal
#     Airphone SA Attach    ue_id=${UE_ID1}
#     Airphone Pdu Session Setup    ${UE_ID1}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID1}
#     Airphone SA Attach    ue_id=${UE_ID2}
#     Airphone Pdu Session Setup    ${UE_ID2}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID2}
#     Airphone SA Attach    ue_id=${UE_ID3}
#     Airphone Pdu Session Setup    ${UE_ID3}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID3}
#     Airphone SA Attach    ue_id=${UE_ID4}
#     Airphone Pdu Session Setup    ${UE_ID4}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID4}
#     #run keyword and continue on failure    Check rrc log
#     Airphone override to rank2
#     run keyword and continue on failure    Send DL data to UE and check throughput
#     Start collect ttitrace    name=tti_4UE_2Pos
#     run keyword and continue on failure    Wait for '2s' to stop ttitrace with name'tti_4UE_2Pos'
#     #Check mupair in ttitrace
# 	Get 87957 counter
#     run keyword and continue on failure    Send DL data to UE and check throughput-2
#     Start collect ttitrace    name=tti_4UE_2Pos-2
#     run keyword and continue on failure    Wait for '2s' to stop ttitrace with name'tti_4UE_2Pos-2'
# 	Get 87957 counter
#     #Check mupair in ttitrace-2
#     #Detach SA UEs
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords **
# Set UE Pos
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${SET_PROFILE1}
#     airphone_execute_egate_command    ${PROFILE4}
#     airphone_execute_egate_command    ${SET_PROFILE2}
#     airphone_execute_egate_command    ${SET_PROFILE3}
#     airphone_execute_egate_command    ${SET_PROFILE4}
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=35 sinr_target_pucch\=-300 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-4 testmode\=ul_sinr action\=activate profile_id\=5
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
# Send DL data to UE and check throughput
#     SA send mutiple trf dl data    ${UE_ID1}    2    150M    protocol=tcp
#     SA send mutiple trf dl data    ${UE_ID2}    1    50M    protocol=tcp
#     SA send mutiple trf dl data    ${UE_ID3}    2    150M    protocol=tcp
#     SA send mutiple trf dl data    ${UE_ID4}    1    50M    protocol=tcp
#     Wait '20s ' to stable
#     Check throughput
# 
# Detach SA UEs
#     : FOR    ${num}    IN RANGE    1    5
#     \    airphone_sa_detach    ue_id=${num}
#     \    Wait '3s' for stabible
# 
# Check mupair in ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case20-1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Check rrc log
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate    unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/rrc_8305.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate
# 
# Verify throughput
#     ${dl_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_ue3}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID3}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_ue4}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID4}    scell_id=0    type=pdsch    tput_type=ave
#     log to console    ${dl_throughput_ue1}
#     log to console    ${dl_throughput_ue2}
#     log to console    ${dl_throughput_ue3}
#     log to console    ${dl_throughput_ue4}
#     should_be_true    ${dl_throughput_ue1}>210000
#     should_be_true    ${dl_throughput_ue2}>45000
#     should_be_true    ${dl_throughput_ue3}>210000
#     should_be_true    ${dl_throughput_ue4}>45000
# 
# Send DL data to UE and check throughput-2
#     SA send mutiple trf dl data    ${UE_ID1}    2    150M    protocol=tcp
#     SA send mutiple trf dl data    ${UE_ID2}    2    150M    protocol=tcp
#     SA send mutiple trf dl data    ${UE_ID3}    2    150M    protocol=tcp
#     SA send mutiple trf dl data    ${UE_ID4}    2    150M    protocol=tcp
#     Wait '20s ' to stable
#     Check throughput-2
# 
# Check throughput-2
#     Wait until keyword succeeds    60s    5s    Verify throughput-2
# 
# Verify throughput-2
#     ${dl_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_ue3}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID3}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_ue4}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID4}    scell_id=0    type=pdsch    tput_type=ave
#     log to console    ${dl_throughput_ue1}
#     log to console    ${dl_throughput_ue2}
#     log to console    ${dl_throughput_ue3}
#     log to console    ${dl_throughput_ue4}
#     should_be_true    ${dl_throughput_ue1}>200000
#     should_be_true    ${dl_throughput_ue2}>200000
#     should_be_true    ${dl_throughput_ue3}>200000
#     should_be_true    ${dl_throughput_ue4}>200000
# 
# Check mupair in ttitrace-2
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case20-2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     Modify airphone l1bypass coma value for eight ue    ${Hindex10}    ${Vindex10}    ${Hindex0}    ${Vindex0}    ${Hindex17}    ${Vindex5}
#     ...    ${Hindex8}    ${Vindex0}    ${Hindex17}    ${Vindex6}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex8}    ${Vindex0}    ${Hindex24}    ${Vindex9}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex24}    ${Vindex9}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex8}    ${Vindex0}    
# 
# Airphone override to rank2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=6 cqi\=15 ri\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-4 testmode\=csi_override action\=activate profile_id\=6
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
#    