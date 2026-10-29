# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_changyli    AP    SBTS23R1
# ...   CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# #${GNB_SWCONFIG_NAME}    gnb_swconfig.txt
# #${AP_SWCONFIG_NAME}    ap_swconfig.txt
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}          11
# ${SCFC_NAME}      SCFC_CNI70851_CASE07.xml
# ${AIRPHONE_NAME}    IPHY_AEHC_CASE07.xml
# ${WTS_NAME}       WTS_70851_CASE07.cfg
# ${EGATE_TAG}      RLQ
# ${SYSLOG_TAG}     after_onair
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${A1_CMD1}        ue_measurement_send_nr id\=11 meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=50
# ${A1_CMD2}        ue_measurement_send_nr id\=11 meas_id\=4 event\=A1 rs_type\=ssb srsrp_nr\=50
# ${A2_CMD1}        ue_measurement_send_nr id\=11 meas_id\=3 event\=A2 rs_type\=ssb scell\=9 scell_rsrp\=30
# ${STABLETIME}     5s
# 
# *** Test Cases ***
# CNI70851_case07_interL2RT_NSA_5GC002200_DRX_Scellonly
#     Enable RD syslog in AP Swconfig
#     Add counter timer in gnb Swconfig
#     Prepare gnb onair
#     Start capture gnb and ap syslog in '${SYSLOG_TAG}' file
#     airphone_cleanup_egate_console_log
#     Execute AP Command before attach
#     Attach LTE UE
#     UE_SEND_A1_EVENT
#     Wait time to stable
#     Collect AP egate log    ${EGATE_TAG}
#     Analyse scelladd in rrclog
#     Check drx setup in rrclog
#     Send DL data to UE and check throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti'
#     Check ttitrace
#     Check DRX Active Sleep
#     UE_SEND_A2_EVENT
#     Wait time to stable
#     Check Scell release
#     Check Pcell throughput
#     UE_SEND_A1_EVENT_AGAIN
#     Collect AP egate log    ${EGATE_TAG}
#     Analyse scelladd in rrclog
#     Send DL data to UE and check throughput
#     Airphone NSA Stop Data Traffic    ${UE_ID}    DL
#     Detach LTE UE
#     Stop capture gnb and ap syslog in '${SYSLOG_TAG}' file
# 
# *** Keywords ***
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
#     Wait time to stable
# 
# Attach LTE UE
#     Airphone NSA Attach    ${UE_ID}
#     Wait time to stable
# 
# Detach LTE UE
#     Airphone NSA Detach    ${UE_ID}
# 
# UE_SEND_A1_EVENT
#     airphone_execute_egate_command    ${A1_CMD1}
# 
# UE_SEND_A1_EVENT_AGAIN
#     airphone_execute_egate_command    ${A1_CMD2}
#     airphone_execute_egate_command    ${A1_CMD1} #different branch has different meas_id
#     Wait time to stable
# 
# UE_SEND_A2_EVENT
#     airphone_execute_egate_command    ${A2_CMD1}
# 
# Send DL data to UE and check throughput
#     NSA send ue '${UE_ID} ' mutiple trf '6' for each '175M' DL data
#     ${pcell_tp}=    airphone_get_throughput_on_specific_scell    11    8    type=pdsch    tput_type=ave
#     ${scell_tp}=    airphone_get_throughput_on_specific_scell    11    9    type=pdsch    tput_type=ave
#     should be true    ${pcell_tp}>0
#     should be true    ${scell_tp}>0
# 
# check throughput
#     ${pcell_tp}=    airphone_get_throughput_on_specific_scell    11    8    type=pdsch    tput_type=ave
#     ${scell_tp}=    airphone_get_throughput_on_specific_scell    11    9    type=pdsch    tput_type=ave
#     should be true    ${pcell_tp}>0
#     should be true    ${scell_tp}>0
# 
# Check throughput equal
#     [Arguments]    ${scell_id}=9    ${throughput}=0
#     ${dl_throughput_scell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=${scell_id}    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_scell}==${throughput}
# 
# Check Pcell throughput
#     [Arguments]    ${scell_id}=8    ${throughput}=200000
#     ${dl_throughput}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=${scell_id}    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput}>${throughput}
# 
# Wait time to stable
#     sleep    ${STABLETIME}
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check Scell release
#     airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/release    unzip=TRUE
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scell_release.ini    u    save_log_directory=${TEST_LOG_DIRECTORY()}/All/release
# 
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd_NSA.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Check drx setup in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/drx_setup.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Wait '${time} ' to check log
#     sleep    ${time}
# 
# Wait time to check DRX
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait '${remaining_time}s' for stabible
#     Wait '70s' for stabible
# 
# Check DRX Active Sleep
#     Wait time to check DRX
#     Check pm counter M55308C11001 in cell 1 is expected > 0
#     Check pm counter M55308C11001 in cell 2 is expected > 0
#     Check pm counter M55308C11002 in cell 1 is expected == 0
#     Check pm counter M55308C11002 in cell 2 is expected == 0
# 
# Add counter timer in gnb Swconfig
#         Add GNB swconfig    0x340000:15
# 
# Enable RD syslog in AP Swconfig
#         Modify AP swconfig    0x10041:1
# 
# 
