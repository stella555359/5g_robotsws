# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    AP    owner_changyli
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD    CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# #${AP_SWCONFIG_NAME}    ap_swconfig.txt
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      8423_SCFC_CASE11.xml
# ${AIRPHONE_NAME}    iphy-AZHA_2cells.xml
# ${WTS_NAME}       TDD_CPRI_2cells_intergnb.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${HO_CMD1}     ue_enb_param id\=11 drx_config\=off measurement_gap\=gp0:20 gap_trigger\=gnb_triggered mgta\=ms0dot50 gap_purpose\=perUE
# ${HO_CMD3}     ue_enb_param id\=11 measurement_gap\=off
# ${UE_ID}          11
# ${EGATE_TAG}      ADD
# 
# *** Test Cases ***
# CB008423_B_Case11_8b_interBand_Inter_gNB_Inter_frequency_handover_for_A1_SCell_addition_NSA
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Execute AP Command before attach
#     Attach LTE UE
#     UE send A1 event
#     NSA send ue '${UE_ID}' mutiple trf '5' for each '175M' DL data
#     Collect AP egate log    ${EGATE_TAG}
#     Analyse scelladd in rrclog
#     Check throughput
#     Trigger inter gnb interband handover
#     Trigger inter gnb interband handover back
#     Check throughput
#     Stop capture gnb and ap syslog in 'after_onair' file
#     Airphone NSA Stop Data Traffic    ${UE_ID}    DL
#     Airphone NSA Detach    ${UE_ID}
# 	
# *** Keywords ***	
# Check scell add succesfully
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_scelladd.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Trigger inter gnb interband handover
#     airphone_execute_egate_command     ${HO_CMD1}
#     Wait '2s' for stabible
#     airphone_measurement_send_nr    id=11    meas_id=2    event=A2    rs_type=ssb srsrp_nr=30
#     Wait '4s' for stabible
#     airphone_execute_egate_command     ${HO_CMD3}
#     Wait '2s' for stabible
#     airphone_measurement_send_nr    id=11    meas_id=1    event=A3    srsrp_nr=11 srsrq_nr=11 phycell_id=52 nrsrp_nr=20 nrsrq_nr=20
#     Wait '4s' for stabible
#     Collect AP egate log    ho1
#     check handovertotarget sucessfully
# 
# Trigger inter gnb interband handover back
#     airphone_measurement_send_nr    id=11    meas_id=1    event=A3    srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=50 nrsrq_nr=20
#     Wait '4s' for stabible
#     Collect AP egate log    ho2
#     check handovertosource sucessfully
# 	
# check handovertotarget sucessfully
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/ho1   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/totarget.ini    log_need_to_check=u    save_log_directory=${TEST_LOG_DIRECTORY()}/All/ho1
# 
# check handovertosource sucessfully
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/ho2   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tosource.ini   log_need_to_check=u    save_log_directory=${TEST_LOG_DIRECTORY()}/All/ho2
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     run keyword and continue on failure    airphone_setup_x2_connection
#     Airphone Setup X2 Connection    gnb_id=3
# 
# Verify throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>70000
#     should_be_true    ${dl_throughput_scell1}>70000
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Attach LTE UE
#     Airphone Nsa Attach    ${UE_ID}    profile_id=None
# 
# UE send A1 event
#     airphone_measurement_send_nr    id=11    meas_id=3    event=A1    rs_type=ssb srsrp_nr=50
#     Wait '2s' for stabible
# 
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd_NSA.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
