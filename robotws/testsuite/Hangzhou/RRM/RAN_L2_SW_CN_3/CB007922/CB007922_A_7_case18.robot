# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags        CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G     SBTS22R4
# ...   CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}         11
# ${SCFC_NAME}      SCFC_7922_case18.xml
# ${AIRPHONE_NAME}    IPHY_AEHC_4CELL.xml
# ${WTS_NAME}      WTS_7922_4cell_intergnbho.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${A1_CMD1}      ue_measurement_send_nr id\=11 meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=50
# ${A1_CMD2}      ue_measurement_send_nr id\=11 meas_id\=6 event\=A1 rs_type\=ssb srsrp_nr\=50
# ${HO_CMD1}     ue_measurement_send_nr id\=11 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=54 nrsrp_nr\=30 nrsrq_nr\=30
# ${HO_CMD2}     ue_measurement_send_nr id\=11 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=50 nrsrp_nr\=50 nrsrq_nr\=50
# ${STABLETIME}    10s
# 
# *** Test Cases ***
# CB007922_case18_A_7b_interL2RT_Inter_gNB_Intra_frequency_handover_for_A1_SCell_addition_NSA
# 
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Execute AP Command before attach
#     Attach LTE UE
#     UE_SEND_A1_EVENT
#     Send DL data to UE and check throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti'
#     Check ttitrace
#     Trigger inter gnb intraband handover
#     Trigger inter gnb intraband handover back
#     UE_SEND_A1_EVENT_AGAIN
#     check throughput
#     Airphone NSA Detach    ue_id=11
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# 
# *** Keywords ***
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
#     Airphone Setup X2 Connection    gnb_id=3
# 
# Attach LTE UE
#     Airphone Nsa Attach     ${UE_ID}    profile_id=None
#     Wait time to stable
# 
# UE_SEND_A1_EVENT
#     airphone_execute_egate_command    ${A1_CMD1}
# 
# UE_SEND_A1_EVENT_AGAIN
#     airphone_execute_egate_command    ${A1_CMD2}
#     Wait time to stable
# 
# Send DL data to UE and check throughput
#     NSA send ue '${UE_ID} ' mutiple trf '6' for each '175M' DL data
#     ${pcell_tp}=    airphone_get_throughput_on_specific_scell    11    8    type=pdsch    tput_type=ave
#     ${scell_tp}=    airphone_get_throughput_on_specific_scell    11    9    type=pdsch    tput_type=ave
#     should be true    ${pcell_tp}>0
#     should be true    ${scell_tp}>0
# 
# 
# Trigger inter gnb intraband handover
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    ${HO_CMD1}
#     Wait time to stable
#     Check inter gnb handover successfully
# 
# Check inter gnb handover successfully
#    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/handover   unzip=TRUE
#    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_hoscelladd.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover
# 
# Trigger inter gnb intraband handover back
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command     ${HO_CMD2}
#     Wait time to stable
#     Check inter gnb handover successfully again
# 
# Check inter gnb handover successfully again
#    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/handover1   unzip=TRUE
#    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_hoscelladd1.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover1
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
