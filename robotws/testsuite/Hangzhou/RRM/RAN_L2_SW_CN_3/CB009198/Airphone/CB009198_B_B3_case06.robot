# *** Settings ***
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_BLLL_AP_LOO    AP    CRT
# ...    SBTS00    RAN_5G_TDD    RAN_5G
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${NSA_UE_NUM}         1
# ${SCFC_NAME}      SCFC_9198_case6.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_ASIL_1CELL.xml
# ${WTS_NAME}      wts_9198_AEQE_intergnbHo.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog
# ${A1_CMD1}      ue_measurement_send_nr id\=1 meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=50
# ${A1_CMD2}      ue_measurement_send_nr id\=1 meas_id\=6 event\=A1 rs_type\=ssb srsrp_nr\=50
# ${HO_CMD1}     ue_measurement_send_nr id\=11 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=54 nrsrp_nr\=50 nrsrq_nr\=50
# ${HO_CMD2}     ue_measurement_send_nr id\=11 meas_id\=2 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=50 nrsrp_nr\=50 nrsrq_nr\=50
# ${HO_CMD3}     ue_measurement_send_nr id\=11 meas_id\=5 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=54 nrsrp_nr\=50 nrsrq_nr\=50
# ${HO_CMD4}     ue_measurement_send_nr id\=11 meas_id\=3 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=54 nrsrp_nr\=50 nrsrq_nr\=50
# 
# 
# ${handover}     handover
# ${handover_back}    handover_back
# 
# #ue_measurement_send_nr id=11 meas_id=2 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=50 nrsrq_nr=50
# #ue_measurement_send_nr id=11 meas_id=5 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=54 nrsrp_nr=50 nrsrq_nr=50
# 
# ${STABLETIME}    10s
# ${handover}     handover
# ${handover_back}     handover_back
# ${num}    5
# 
# *** Test Cases ***
# CB009198_B_B3_case06_SA_intergnb_handover_To_Judge_RadioConditions_And_Decide_Initial_TransMode _UL_Rank_2
#     Prepare gnb onair
#     Wait '10s' for stable
# 	Start capture gnb and ap syslog in 'after_onair' file
# 	Execute AP Command before attach
# 	Attach '${NSA_UE_NUM}' NSA UE and data buffer sent
#     Wait '5s' for stable
# 
# 
# 
#     Trigger inter gnb intraband handover one
#     Add pathloss110 to UE
#     Trigger inter gnb intraband handover back one
# 	
# 	Trigger inter gnb intraband handover two
# 	Stop pathloss110 to UE 
#     Trigger inter gnb intraband handover back two
# 	
# #	Handover robustness for '${num}' times
# 	
# 	:For    ${id}    IN RANGE   1   11
# 	\    Trigger inter gnb intraband handover three
# 	\    Add pathloss110 to UE
#     \    Trigger inter gnb intraband handover back one
# #	\    Wait '5s' for stabible	
# 	\    Trigger inter gnb intraband handover two
# 	\    Stop pathloss110 to UE 
#     \    Trigger inter gnb intraband handover back two
# #    \    Wait '5s' for stabible	
# 	
# 
# #    Airphone NSA Detach    ue_id=11
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# *** Keywords ***
# Handover robustness for '${NUM}' times
# 	: FOR    ${num}    IN RANGE    1    ${NUM}+1
# 	\    airphone_cleanup_egate_console_log
#     \    airphone_execute_egate_command    ${HO_CMD1}
#     \    Wait time to stable
# #    Check inter gnb handover one
#     \    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/handover_${num}   unzip=TRUE
#     \    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/handover.ini    log_need_to_check=p
#     \    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover_${num}
# 
# 	\    Add pathloss110 to UE
# 	
# 	\    airphone_cleanup_egate_console_log
#     \    airphone_execute_egate_command     ${HO_CMD2}
#     \    Wait time to stable
# #    Check inter gnb handover back one
# 	\    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/handover1_${num}   unzip=TRUE
#     \    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/handover_back.ini    log_need_to_check=p
#     \    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover1_${num}
#     \    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/dftsofdm.ini    log_need_to_check=p
#     \    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover1_${num}
# 
# 	\    airphone_cleanup_egate_console_log
#     \    airphone_execute_egate_command    ${HO_CMD3}
#     \    Wait time to stable
# #    Check inter gnb handover two
# 	\    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/handover2_${num}   unzip=TRUE
#     \    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/handover.ini    log_need_to_check=p
#     \    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover2_${num}
# 	
# 	\    Stop pathloss110 to UE
# 	
# 	\    airphone_cleanup_egate_console_log
#     \    airphone_execute_egate_command     ${HO_CMD2}
#     \    Wait time to stable
# #    Check inter gnb handover back two
#     \    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/handover3_${num}   unzip=TRUE
#     \    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/handover_back.ini    log_need_to_check=p
#     \    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover3_${num}
#     \    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/cpofdm2.ini    log_need_to_check=p
#     \    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover3_${num}
# 
# Handover robustness f0r '${NUM}' times
#     : FOR    ${num}    IN RANGE    1    ${NUM}+1
# 	\   airphone_cleanup_egate_console_log
#     \   airphone_execute_egate_command    ${HO_CMD1}
#     \   Wait time to stable
# 	\   Collect AP egate log    ${handover}_${num}
# 	\   check_log_with_au2anlysis    ${CURDIR}/ini/handover.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${handover_TAG}_${num}
# #    Check inter gnb handover one 
# 	\   Add pathloss110 to UE
# 	\   airphone_cleanup_egate_console_log
#     \   airphone_execute_egate_command     ${HO_CMD2}
#     \   Wait time to stable
# 	\   Collect AP egate log    ${handover_back}_${num}
# 	\   check_log_with_au2anlysis    ${CURDIR}/ini/handover_back.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${handover_TAG}_${num}
# 	\   check_log_with_au2anlysis    ${CURDIR}/ini/dftsofdm.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${handover_TAG}_${num}
# #	Collect AP egate log    ${handover_back}
# 
# Trigger inter gnb intraband handover one
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    ${HO_CMD1}
#     Wait time to stable
#     Check inter gnb handover one
# 
# Check inter gnb handover one
#    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/handover   unzip=TRUE
#    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/handover.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover
#    
# Trigger inter gnb intraband handover three
# 	airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    ${HO_CMD3}
#     Wait time to stable
#     Check inter gnb handover one
# 	
# Trigger inter gnb intraband handover back one
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command     ${HO_CMD2}
#     Wait time to stable
# #	Collect AP egate log    ${handover_back}
#     Check inter gnb handover back one
#     
# Check inter gnb handover back one
#    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/handover1   unzip=TRUE
#    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/handover_back.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover1
#    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/dftsofdm.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover1
# 
# Trigger inter gnb intraband handover two
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    ${HO_CMD3}
#     Wait time to stable
#     Check inter gnb handover two
# 
# Check inter gnb handover two
#    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/handover2   unzip=TRUE
#    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/handover.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover2
# 
# Trigger inter gnb intraband handover back two
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command     ${HO_CMD2}
#     Wait time to stable
# #    Collect AP egate log    ${handover_back2}
#     Check inter gnb handover back two
# 
# Check inter gnb handover back two
#    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/handover2   unzip=TRUE
#    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/handover_back.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover2
#    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/cpofdm2.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover2
# 
# 
# Add pathloss110 to UE
# 	airphone_cleanup_egate_console_log
# 	airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 delete\=1
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=110
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=ul_sinr action\=activate profile_id\=1 scell\=8
# 
# Stop pathloss110 to UE
# 	airphone_cleanup_egate_console_log
# #	airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 delete\=1
# #    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=110
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=ul_sinr action\=deactivate profile_id\=1 scell\=8
# 	
# Check rrc log for precoder CP
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_${egate tag}    unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/cpofdm.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_${egate tag}
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
# Attach '${NSA_UE_NUM}' NSA UE and data buffer sent
#     : FOR    ${num}    IN RANGE    11    ${NSA_UE_NUM}+11
#     \   airphone_cleanup_egate_console_log
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   Wait '3s' for stabible
# #    \   Collect AP egate log    ${EGATE_TAG}_${num}
# #    \   run keyword and continue on failure     check_SRS_resource_and_PDSCH_scramblingID   ${EGATE_TAG}_${num}
# #    \   NSA send ue '${num}' mutiple trf '3' for each '150M' DL data
#     \   NSA send ue '${num}' mutiple trf '1' for each '15M' UL data
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
#     Airphone Setup X2 Connection    gnb_id=3
# 
# Send DL data to UE and check throughput
#     NSA send ue '${UE_ID} ' mutiple trf '6' for each '175M' DL data
#     ${pcell_tp}=    airphone_get_throughput_on_specific_scell    11    8    type=pdsch    tput_type=ave
#     ${scell_tp}=    airphone_get_throughput_on_specific_scell    11    9    type=pdsch    tput_type=ave
#     should be true    ${pcell_tp}>0
#     should be true    ${scell_tp}>0
# 
# 
# 
# check throughput
#     ${pcell_tp}=    airphone_get_throughput_on_specific_scell    11    8    type=pdsch    tput_type=ave
#     ${scell_tp}=    airphone_get_throughput_on_specific_scell    11    9    type=pdsch    tput_type=ave
#     should be true    ${pcell_tp}>0
#     should be true    ${scell_tp}>0
# 
# Wait time to stable
#     sleep    ${STABLETIME}
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
