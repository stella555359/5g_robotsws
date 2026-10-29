# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags        CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_zhang    SBTS23R1
# ...   CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# ...               AP
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}         11
# ${SCFC_NAME}      7922_SCFC_A7_case17.xml
# ${AIRPHONE_NAME}    IPHY_AEHC_4CELL.xml
# ${WTS_NAME}      WTS_7922_case17.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# 
# ${ENDC_CMD}    ue_dc_enb_start ue\=11 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
# ${HO_CMD1}     ue_measurement_send_nr id\=11 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=51 nrsrp_nr\=30 nrsrq_nr\=30
# ${HO_CMD2}     ue_measurement_send_nr id\=11 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=50 nrsrp_nr\=50 nrsrq_nr\=50
# ${STABLETIME}    8s
# 
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# ...    NUMBER_OF_FILES=30
# 
# *** Test Cases ***
# CB007922_case17_A_7a_intraL2RT_intraBand_Intra_gNB_Intra_frequency_handover_for_blind_SCell_addition_NSA
# 
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
# 
#     Execute AP Command before attach
#     Attach LTE UE
#     Send DL data to UE and check throughput
# 
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti'
#     Check ttitrace
# 
#     Trigger intra gnb intraband handover
#     Trigger intra gnb intraband handover back
#     Airphone NSA Detach    ue_id=11
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
# 
# Attach LTE UE
#     Airphone Nsa Attach     ${UE_ID}    profile_id=None
#     Wait time to stable
# 
# Send DL data to UE and check throughput
#     NSA send ue '${UE_ID} ' mutiple trf '4' for each '165M' DL data
#     ${pcell_tp}=    airphone_get_throughput_on_specific_scell    11    8    type=pdsch    tput_type=ave
#     ${scell_tp}=    airphone_get_throughput_on_specific_scell    11    9    type=pdsch    tput_type=ave
#     should be true    ${pcell_tp}>0
#     should be true    ${scell_tp}>0
# 
# Trigger intra gnb intraband handover
#     airphone_cleanup_egate_console_log
#     #Airphone Measurement Send Nr    id=11    meas_id=1    event=A3    srsrp_nr=11   srsrq_nr=11
#     #...     phycell_id=51   nrsrp_nr=30    nrsrq_nr=30
#     # KW above can't work.
#     airphone_execute_egate_command    ${HO_CMD1}
#     
#     Wait '3s' for stabible
#     Check intra gnb handover successfully
# 
# Check intra gnb handover successfully
#    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/handover   unzip=TRUE
#    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_hoscelladd_case17.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover
#    check throughput
# 
# Trigger intra gnb intraband handover back
#     airphone_cleanup_egate_console_log
#     #Airphone Measurement Send Nr    id=11    meas_id=1    event=A3    srsrp_nr=11   srsrq_nr=11
#     #...     phycell_id=50   nrsrp_nr=50    nrsrq_nr=50
#     # KW above can't work.
#     airphone_execute_egate_command    ${HO_CMD2}
#     Wait '3s' for stabible
#     Check intra gnb handover successfully again
# 
# Check intra gnb handover successfully again
#    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/handover1   unzip=TRUE
#    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_hoback_scelladd_case17.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover1
#    check throughput
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
# 
