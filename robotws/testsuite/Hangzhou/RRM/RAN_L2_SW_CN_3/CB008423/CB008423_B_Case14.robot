# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown  Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    CRT    RAN_5G_TDD    RAN_5G    owner_menzheng
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}         11
# ${SCFC_NAME}      SCFC_14.xml
# ${AIRPHONE_NAME}    iphy-AZHA_2cells.xml
# ${WTS_NAME}       TDD_CPRI_2cells.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${STABLETIME}    10s
# ${TTITRACE_TAG}    tti
# ${SYSLOG_TAG}     after_onair
# ${UE_A1_EVENT}    ue_measurement_send_nr id\=11 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
# ${UE_A2_EVENT}    ue_measurement_send_nr event\=A2 id\=11 meas_id\=2 rs_type\=ssb scell\=9 scell_rsrp\=30
# 
# *** Test Cases ***
# CB008423_B_Case14_13_intraL2RT_interBand_NSA_Overwrite_PUCCH_F3_max_code_rate_when_Scelll_is_added_or_released
#     Prepare gnb onair
#     Start capture gnb and ap syslog in '${SYSLOG_TAG}' file
#     Execute AP Command before attach
#     Attach LTE UE
#     Check coderate to zeroDot08
#     UE send A1 Event
#     Check coderate to zeroDot15
#     Send DL data to UE and check throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'${TTITRACE_TAG}'
#     Check ttitrace
#     UE send A2 Event trigger scell release
#     Check coderate to zeroDot08 again
#     Airphone NSA Detach    ue_id=11
#     Stop capture gnb and ap syslog in '${SYSLOG_TAG}' file
# 
# *** Keywords ***
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Attach LTE UE
#     Airphone Nsa Attach     ${UE_ID}    profile_id=None
#     Wait time to stable
# 
# UE send A1 Event
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    ${UE_A1_EVENT}
# 
# Send DL data to UE and check throughput
#     NSA send ue '${UE_ID}' mutiple trf '2' for each '175M' DL data
#     Wait time to stable
#      ${pcell_tp}=    airphone_get_throughput_on_specific_scell    11    8    type=pdsch    tput_type=ave
#      ${scell_tp}=    airphone_get_throughput_on_specific_scell    11    9    type=pdsch    tput_type=ave
#      should be true    ${pcell_tp}>140000
#      should be true    ${scell_tp}>140000
# 
# UE send A2 Event trigger scell release
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    ${UE_A2_EVENT}
# 
# Check scell add succesfully
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_scelladd.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Wait time to stable
#     sleep    ${STABLETIME}
# 	
# check throughput
#      ${pcell_tp}=    airphone_get_throughput_on_specific_scell    11    8    type=pdsch    tput_type=ave
#      should be true    ${pcell_tp}>140000
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check coderate to zeroDot08
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/coderate1   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_coderate_zeroDot08.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/coderate1
# 
# Check coderate to zeroDot15
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/coderate2   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_coderate_zeroDot15.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/coderate2
# 
# Check coderate to zeroDot08 again
#     check throughput
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/coderate3   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_coderate_zeroDot08_again.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/coderate3
