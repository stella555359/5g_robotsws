# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    owner_yuqq    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G     SBTS23R2
# Test Timeout      60 minutes
# Resource          ../../resources/KISS/robot/common_resource.robot
# Resource          ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8305_case12_mplo.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_2CELL_APLO_8DL4UL_MP.xml
# ${WTS_NAME}      WTS_2cell_SA_NSA.lua
# ${UE_ID1}         1
# ${UE_ID2}         2
# ${GW_ID1}         1
# ${GW_ID2}         2
# ${PDU_ID}         1
# ${SLICE_ID}       1
# ${codebook}       codebook
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${par_of_bsr_name}       BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# ${FILTER_f1ap_srsModify}    itf_l2_ps_user_reconfigurationrequiredind||rrc||f1ap||itf_l2_ps_user_usermodifyreq
# @{titles_tasSrsResourceInd}    3gpp.sfn    3gpp.slot    3gpp.rnti    itf_l2_ps_user_ReconfigurationRequiredInd_t.tasSrsResourceInd
# ...    itf_l2_ps_user_ReconfigurationRequiredInd_t.ueIdDu
# ${FILTER_f1ap_rrc_itl_l2ps}    f1ap||e1ap||rrc
# ...    ||itf_l2_ps_user_reconfigurationrequiredind||itf_l2_ps_user_usermodifyreq||itf_l2_ps_user_usersetupreq
# @{titles_duID_Crnti}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID
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
# CB008305_A_B4_case12_rank2_Ue_pair_with_rank3_Ue_and_SCID_and_power_check_with_codebook
# #    Upload airphone l1bypass to iphy
#     Get and Update BSR File     par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
#     Prepare gnb onair
#     run keyword and continue on failure    Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
# 	Set UE1 and UE2 Pos
#     Airphone Set Traffic Type    ${UE_ID1}    ${PDU_ID}    internal
#     Airphone Set Traffic Type    ${UE_ID2}    ${PDU_ID}    internal
#     Airphone SA Attach    ue_id=${UE_ID1}
#     Airphone Pdu Session Setup    ${UE_ID1}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID1}
#     Airphone SA Attach    ue_id=${UE_ID2}
#     Airphone Pdu Session Setup    ${UE_ID2}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID2}
# 	Collect AP egate log     ${codebook}
# 	Analyse codebook in rrclog
# 	
# #    run keyword and continue on failure    Check rrc log
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=1
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=2
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2
#     run keyword and continue on failure     Send DL data to UE and check throughput
#     Start collect ttitrace
#     run keyword and continue on failure    Wait for '5s' to stop ttitrace with name'tti'
# 	run keyword and continue on failure    Check ttitrace	
# 	
#     Detach SA UEs
#     Stop capture gnb and ap syslog in 'after_onair' file
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
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Check rrc log
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate    unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/rrc_8305.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate
# 
# online change dlMuMimoSpectralEffThd to 10
# 	TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    dlMuMimoSpectralEffThd    10    online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
# 
# online change dlMuMimoSpectralEffThd to 20
# 	TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    dlMuMimoSpectralEffThd    20    online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
# 
# Verify throughput
#     ${dl_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_ue1}>300000
#     should_be_true    ${dl_throughput_ue2}>450000
# 	
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case12_tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Analyse codebook in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_case12_codebook.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${codebook}_egate
