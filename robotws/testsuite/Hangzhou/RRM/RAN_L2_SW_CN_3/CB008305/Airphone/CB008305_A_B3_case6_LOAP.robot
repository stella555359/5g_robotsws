# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    owner_yuqq    AP    SBTS00     SBTS23R1     CRT     RAN_5G_TDD    RAN_5G
# Test Timeout      60 minutes
# Resource          ../../resources/KISS/robot/common_resource.robot
# Resource          ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8305_case6_aplo.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL_case6_aplo.xml
# #${L1BYP_XML}      L1ByPTestModeConfiguration_case10.xml
# ${WTS_NAME}       wts_1086_7_TAS_case6_aplo.cfg
# ${UE_ID1}         1
# ${UE_ID2}         2
# ${GW_ID1}         1
# ${GW_ID2}         2
# ${PDU_ID}         1
# ${SLICE_ID}       1
# ${SA_UE_NUM}         8
# ${NSA_UE_NUM}         2
# 
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog    Tcpdump
# 
# *** Test Cases ***
# CB008305_A_B3_case06_two_rank1_Ues_paired_with_SE checking
#     Prepare gnb onair
#     run keyword and continue on failure    Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     Set UE1 and UE2 Pos
#     Airphone Set Traffic Type    ${UE_ID1}    ${PDU_ID}    internal
#     Airphone Set Traffic Type    ${UE_ID2}    ${PDU_ID}    internal
#     Airphone SA Attach    ue_id=${UE_ID1}
#     Airphone Pdu Session Setup    ${UE_ID1}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID1}
#     Airphone SA Attach    ue_id=${UE_ID2}
#     Airphone Pdu Session Setup    ${UE_ID2}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID2}
# #    Set UE1 and UE2 Pos
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-2 testmode\=csi_override action\=activate profile_id\=1
#     run keyword and continue on failure     Send DL data to UE and check throughput
#     Start collect ttitrace
#     run keyword and continue on failure    Wait for '5s' to stop ttitrace with name'tti'
# 	run keyword and continue on failure    Check ttitrace
# 	
# 	online change dlMuMimoSpectralEffThd to 10
#     run keyword and continue on failure    Send DL data to UE and check throughput
#     Start collect ttitrace
#     run keyword and continue on failure    Wait for '5s' to stop ttitrace with name'tti-1'
# 	run keyword and continue on failure    Check ttitrace-1
# 
# 	online change dlMuMimoSpectralEffThd to 20
# 	Send DL data to UE
#     sleep     30s
# 	Start collect ttitrace
#     run keyword and continue on failure    Wait for '5s' to stop ttitrace with name'tti-2'
#     run keyword and continue on failure    Check ttitrace-2
# 	
#     Detach SA UEs
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Set UE1 and UE2 Pos
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=1 init_pos\=1 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=1
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=2 init_pos\=3 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ue_srs_beam_pos action\=activate profile_id\=2
# 
# 
# Attach '${SA_UE_NUM}' SA UE and data buffer sent
# 	: FOR    ${num}    IN RANGE    1    ${SA_UE_NUM}+1
#     \   airphone_cleanup_egate_console_log
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \   Wait '3s' for stabible
#     \   SA send mutiple trf dl data    ${num}    3    175M   ${num}
#     \   SA send mutiple trf ul data    ${num}    1    20M   ${num}
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
#     SA send mutiple trf dl data    ${UE_ID1}    4    175M
#     SA send mutiple trf dl data    ${UE_ID2}    4    175M
#     Wait '20s ' to stable
# 
# Send DL data to UE and check throughput
#     SA send mutiple trf dl data    ${UE_ID1}    4    175M
#     SA send mutiple trf dl data    ${UE_ID2}    4    175M
#     Wait '20s ' to stable
#     Check throughput
# 
# Detach SA UEs
#     : FOR    ${num}    IN RANGE    1    3
#     \    airphone_sa_detach    ue_id=${num}
#     \    Wait '3s' for stabible
# 
# Set UEs Pos
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=1 init_pos\=1 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=1
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ue_srs_beam_pos action\=activate profile_id\=1
# 	
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=2 init_pos\=3 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ue_srs_beam_pos action\=activate profile_id\=2
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=ue_srs_beam_pos action\=activate profile_id\=2
# 
# 	airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=3 init_pos\=0 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=5 testmode\=ue_srs_beam_pos action\=activate profile_id\=3
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=6 testmode\=ue_srs_beam_pos action\=activate profile_id\=3
# 
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=4 init_pos\=2 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=7 testmode\=ue_srs_beam_pos action\=activate profile_id\=4
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=8 testmode\=ue_srs_beam_pos action\=activate profile_id\=4
# 
# 
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
#     should_be_true    ${dl_throughput_ue1}>140000
#     should_be_true    ${dl_throughput_ue2}>140000
# 	
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case6_tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check ttitrace-1
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case6_tti_dl_1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# Check ttitrace-2
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case6_tti_dl_2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
