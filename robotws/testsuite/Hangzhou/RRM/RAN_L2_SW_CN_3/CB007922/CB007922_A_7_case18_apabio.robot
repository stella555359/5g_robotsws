# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags        CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}         11
# ${SCFC_NAME}      SCFC_APABIO_case18_rank4.xml
# ${AIRPHONE_NAME}    iphy_2aeqe_case18.xml
# ${WTS_NAME}      wts_2cell_AEQE.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog
# ${A1_CMD1}      ue_measurement_send_nr id\=11 meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=50
# ${A1_CMD2}      ue_measurement_send_nr id\=11 meas_id\=6 event\=A1 rs_type\=ssb srsrp_nr\=50
# ${HO_CMD1}     ue_measurement_send_nr id\=11 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=52 nrsrp_nr\=30 nrsrq_nr\=30
# ${HO_CMD3}     ue_measurement_send_nr id\=11 meas_id\=5 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=52 nrsrp_nr\=30 nrsrq_nr\=30
# ${HO_CMD2}     ue_measurement_send_nr id\=11 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=50 nrsrp_nr\=50 nrsrq_nr\=50
# ${STABLETIME}    10s
# 
# *** Test Cases ***
# CB007922_case18_A_7b_interL2RT_Inter_gNB_Intra_frequency_handover_for_A1_SCell_addition_NSA
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Execute AP Command before attach
#     Attach LTE UE
#     UE_SEND_A1_EVENT
#     Send DL data to UE and check throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti'
#     Check ttitrace
#     Trigger inter gnb intraband handover    1
#     Trigger inter gnb intraband handover back    1
#     UE_SEND_A1_EVENT_AGAIN
#     Wait Until Keyword Succeeds    20s    2s   check throughput
#     : FOR    ${num}    IN RANGE    2    20+1
#     \    Trigger inter gnb intraband handover more times    ${num}
#     \    Trigger inter gnb intraband handover back    ${num}
#     \    UE_SEND_A1_EVENT_AGAIN
#     \    Wait Until Keyword Succeeds    20s    2s   check throughput
#     Airphone NSA Detach    ue_id=11
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# 
# *** Keywords ***
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
#     Wait time to stable
#     Airphone Setup X2 Connection    gnb_id=3
#     Wait time to stable
# 
# Attach LTE UE
#     #Airphone Nsa Attach     ${UE_ID}    profile_id=None
#     airphone_execute_egate_command     ue_attach id\=11
#     Wait time to stable
#     airphone_execute_egate_command     ue_dc_enb_start ue\=11 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
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
#     NSA send ue '${UE_ID} ' mutiple trf '10' for each '175M' DL data
#     Wait Until Keyword Succeeds    20s    2s   check throughput
# 
# 
# Trigger inter gnb intraband handover
#     [Arguments]    ${num}
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    ${HO_CMD1}
#     Wait time to stable
#     Check inter gnb handover successfully    ${num}
# 
# Trigger inter gnb intraband handover more times
#     [Arguments]    ${num}
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    ${HO_CMD3}
#     Wait time to stable
#     Check inter gnb handover successfully    ${num}
# Check inter gnb handover successfully
#    [Arguments]    ${num}
#    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/handover_${num}    unzip=TRUE
#    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_hoscelladd_aplo.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover_${num}
# 
# Trigger inter gnb intraband handover back
#     [Arguments]    ${num}
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command     ${HO_CMD2}
#     Wait time to stable
#     Check inter gnb handover successfully again    ${num}
# 
# Check inter gnb handover successfully again
#    [Arguments]    ${num}
#    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/handoverback_${num}   unzip=TRUE
#    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_hoscelladd1.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handoverback_${num}
# 
# 
# check throughput
#     ${pcell_tp}=    airphone_get_throughput_on_specific_scell    11    8    type=pdsch    tput_type=ave
#     ${scell_tp}=    airphone_get_throughput_on_specific_scell    11    9    type=pdsch    tput_type=ave
#     should be true    ${pcell_tp}>600000
#     should be true    ${scell_tp}>600000
# 
# Wait time to stable
#     sleep    ${STABLETIME}
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
