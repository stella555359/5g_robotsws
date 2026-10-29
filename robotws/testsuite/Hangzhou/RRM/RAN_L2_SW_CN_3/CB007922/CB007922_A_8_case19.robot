# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_ningyang    SBTS22R2    SBTS22R4    SBTS23R1
# ...   CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# ...               AP
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_19.xml
# ${AIRPHONE_NAME}    IPHY_AEQN_AEHC_4CELL.xml
# ${WTS_NAME}       SANSA7922_interband_muliue_intraho.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${HO_CMD1}        ue_enb_param id\=11 drx_config\=off measurement_gap\=gp0:20 gap_trigger\=gnb_triggered mgta\=ms0dot50 gap_purpose\=perUE
# ${HO_CMD2}        ue_measurement_send_nr event\=A2 id\=11 meas_id\=2 rs_type\=ssb srsrp_nr\=30
# ${HO_CMD3}        ue_enb_param id\=11 measurement_gap\=off
# ${HO_CMD4}        ue_measurement_send_nr id\=11 meas_id\=4 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=52 nrsrp_nr\=20 nrsrq_nr\=20
# ${HO_CMD5}        ue_measurement_send_nr id\=11 meas_id\=3 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=50 nrsrp_nr\=50 nrsrq_nr\=20
# ${HO_CMD6}        ue_measurement_send_nr event\=A2 id\=11 meas_id\=5 rs_type\=ssb srsrp_nr\=30
# ${STABLETIME}     3s
# ${UE_ID}          11
# ${EGATE_TAG}      ADD
# 
# *** Test Cases ***
# CB007922_case19_A_8a_intraL2RT_interBand_Intra_gNB_Inter_frequency_handover_for_blind_SCell_addition_NSA
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Execute AP Command before attach
#     Attach LTE UE
#     Send DL data to UE and check throughput
#     Trigger intra gnb interband handover
#     check throughput
#     airphone_cleanup_egate_console_log
#     Trigger intra gnb interband handover back
#     Check throughput again
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti'
#     Check ttitrace
#     Stop capture gnb and ap syslog in 'after_onair' file
#     Airphone NSA Detach    ${UE_ID}
# 
# *** Keywords ***
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Attach LTE UE
#     Airphone Nsa Attach    ${UE_ID}
# 
# UE send A1 Event
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# Send DL data to UE and check throughput
#     NSA send ue '${UE_ID}' mutiple trf '6' for each '175M' DL data
#     Wait time to stable
#     Verify throughput
# 
# Check throughput again
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Verify throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>180000
#     should_be_true    ${dl_throughput_scell1}>180000
# 
# Check scell add succesfully
#     airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All    unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_scelladd.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Trigger intra gnb interband handover
#     airphone_execute_egate_command    ${HO_CMD1}
#     airphone_execute_egate_command    ${HO_CMD2}
# 	Wait time to stable
#     airphone_execute_egate_command    ${HO_CMD3}
#     airphone_execute_egate_command    ${HO_CMD4}
#     Wait time to stable
#     check handover sucessfully
# 
# Trigger intra gnb interband handover back
#     airphone_execute_egate_command    ${HO_CMD1}
#     airphone_execute_egate_command    ${HO_CMD6}
# 	Wait time to stable
#     airphone_execute_egate_command    ${HO_CMD3}
#     airphone_execute_egate_command    ${HO_CMD5}
#     Wait time to stable
#     check handoverback sucessfully
# 
# check handover sucessfully
#     airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/handover    unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/intra.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover
# 
# check handoverback sucessfully
#     airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/handover    unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/intrab.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Wait time to stable
#     sleep    ${STABLETIME}
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
