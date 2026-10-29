# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    owner_yuqq    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
# Test Timeout      90 minutes
# Resource          ../../resources/KISS/robot/common_resource.robot
# Resource          ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${COMAVALUE}    ${CURDIR}/coma/8305.txt
# ${SCFC_NAME}     SCFC_84878_case03_MP.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_2CELL_APLO.xml
# ${WTS_NAME}      WTS_2cell_SA_NSA.lua
# ${par_of_bsr_name}       BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 
# ${UE_ID1}         1
# ${UE_ID2}         2
# ${GW_ID1}         1
# ${GW_ID2}         2
# ${PDU_ID}         1
# ${SLICE_ID}       1
# ${egate_rrc}       egate_rrc
# #@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog    Tcpdump
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=51 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-250,-250
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=24 zenith\=-10 srs_transmit_power_per_port\=-300,-300,-250,-250
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-280,-280
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-45 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-280,-280
# 
# 
# *** Test Cases ***
# CNI84878_case03_A_B1_Beam_power_balancing_optimizations_for_CB008305_with_varible_rank_with_tapering_rankadaptive
# #    Upload airphone l1bypass to iphy
#     Get and Update BSR File     par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
#     Prepare gnb onair
# #    run keyword and continue on failure    Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     Airphone Set Traffic Type    ${UE_ID1}    ${PDU_ID}    internal
#     Airphone Set Traffic Type    ${UE_ID2}    ${PDU_ID}    internal
#     Airphone SA Attach    ue_id=${UE_ID1}
#     Airphone Pdu Session Setup    ${UE_ID1}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID1}
#     Airphone SA Attach    ue_id=${UE_ID2}
#     Airphone Pdu Session Setup    ${UE_ID2}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID2}
# 	
# 	Set UE1 and UE2 Pos
#     Wait '10s' for stabible
# 	Collect AP egate log     ${egate_rrc}
# #	Analyse codebook in rrclog
# 	
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2
#     run keyword and continue on failure     Send DL data to UE and check throughput
# 	Start capture gnb and ap syslog in 'syslog_step3' file
# 	Start collect bip log
#     Wait for '2s' to stop bip log with name'BIP_data_step3'
# 	Start collect ttitrace
#     run keyword and continue on failure    Wait for '5s' to stop ttitrace with name'tti-step3'
# 	run keyword and continue on failure    Check throughput
# 	Stop capture gnb and ap syslog in 'syslog_step3' file
# 	
# 	airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=3 pathloss\=30 pcmax\=-30
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=3
# 	Start capture gnb and ap syslog in 'syslog_step4' file
# 	Start collect bip log
#     Wait for '2s' to stop bip log with name'BIP_data_step4'
# 	Start collect ttitrace
#     run keyword and continue on failure    Wait for '5s' to stop ttitrace with name'tti-step4'
# #	run keyword and continue on failure    Check throughput-step4
# 	Stop capture gnb and ap syslog in 'syslog_step4' file
# 	
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=deactivate profile_id\=3	
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=deactivate profile_id\=1	
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=4 cqi\=15 ri\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=4
# 	Start capture gnb and ap syslog in 'syslog_step5' file
# 	Start collect bip log
#     Wait for '2s' to stop bip log with name'BIP_data_step5'
# 	Start collect ttitrace
#     run keyword and continue on failure    Wait for '5s' to stop ttitrace with name'tti-step5'
# 	run keyword and continue on failure    Check throughput-step5
# 	Stop capture gnb and ap syslog in 'syslog_step5' file
# 	
# 	
#     Detach SA UEs
# #    Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Set UE1 and UE2 Pos
#      airphone_execute_egate_command    ${PROFILE1}
#      airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#      airphone_execute_egate_command    ${PROFILE2}
#      airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
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
# Send DL data to UE 
#     SA send mutiple trf dl data    ${UE_ID1}    6    175M
#     SA send mutiple trf dl data    ${UE_ID2}    6    175M
#     Wait '20s ' to stable
# 
# Send DL data to UE and check throughput
#     SA send mutiple trf dl data    ${UE_ID1}    6    175M
#     SA send mutiple trf dl data    ${UE_ID2}    6    175M
#     Wait '20s ' to stable
#     Check throughput
# 
# Detach SA UEs
#     : FOR    ${num}    IN RANGE    1    3
#     \    airphone_sa_detach    ue_id=${num}
#     \    Wait '3s' for stabible
# 
# Check mupair in ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case20-1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check throughput-step4
# 	Wait until keyword succeeds    60s    5s    Verify throughput-4
# 
# Verify throughput-4
# 	${dl_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_ue1}>250000
#     should_be_true    ${dl_throughput_ue2}>1000000
# 
# Check throughput-step5
# 	Wait until keyword succeeds    60s    5s    Verify throughput-5
# 
# Verify throughput-5
#     ${dl_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_ue1}>250000
#     should_be_true    ${dl_throughput_ue2}>1000000
# 	
# Check throughput-step6
# 	Wait until keyword succeeds    60s    5s    Verify throughput-6
# 
# Verify throughput-6
#     ${dl_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_ue1}>500000
#     should_be_true    ${dl_throughput_ue2}>1000000
# 	
# Check throughput-step7
# 	Wait until keyword succeeds    60s    5s    Verify throughput-7
# 	
# Verify throughput-7
#     ${dl_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_ue1}>750000
#     should_be_true    ${dl_throughput_ue2}>1000000
# 
# Check rrc log
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate    unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/rrc_8305.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Verify throughput
#     ${dl_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_ue1}>1000000
#     should_be_true    ${dl_throughput_ue2}>1000000
# 	
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case12_tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Analyse codebook in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_case12_codebook.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${codebook}_egate
