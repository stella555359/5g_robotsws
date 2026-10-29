# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        SBTS00    RAN_5G_TDD    RAN_5G    owner_changyli    SBTS22R2    AP    SBTS22R4    SBTS23R1
# ...   CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# #${GNB_SWCONFIG_NAME}    gnb_swconfig.txt
# #${AP_SWCONFIG_NAME}    ap_swconfig.txt
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_7922_case15.xml
# ${AIRPHONE_NAME}    IPHY_AEHC_4CELL.xml
# ${WTS_NAME}       SANSA7922_case15.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${UE_ID}          11    # 第一个UE ID
# ${UE_COUNT}       2    # UE的总数量
# ${EGATE_TAG}      ADD
# ${STABLETIME}     1s
# 
# *** Test Cases ***
# CB007922_case15_A_6b_interL2RT_intraBand_Multiple_UE_DL_UL_data_scheduling_NSA_and_blind_SCell_addition
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Execute AP Command before attach
#     Attach LTE CAUE
#     NSA send dl data
#     NSA send ul data
#     Collect AP egate log    ${EGATE_TAG}
#     Analyse scelladd in rrclog
#     Check throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti'
#     Check ttitrace
#     NSA stop data in 'ul'
#     NSA stop data in 'dl'
#     Detach LTE UE
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Attach LTE CAUE
#     :FOR    ${id}    IN RANGE    ${UE_ID}    ${UE_ID}+${UE_COUNT}
#     \   Airphone Nsa Attach    ${id}
#     \   Wait time to stable
#     \   airphone_execute_egate_command    ue_measurement_send_nr id\=${id} meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# Detach LTE UE
#     :FOR    ${id}    IN RANGE    ${UE_ID}    ${UE_ID}+${UE_COUNT}
#     \   Airphone Nsa detach    ${id}
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Verify throughput
#     :FOR    ${id}    IN RANGE    ${UE_ID}    ${UE_ID}+${UE_COUNT}
#     \   ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${id}    scell_id=8    type=pdsch    tput_type=ave
#     \   ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${id}    scell_id=9    type=pdsch    tput_type=ave
#     \   should_be_true    ${dl_throughput_pcell}>100000
#     \   should_be_true    ${dl_throughput_scell1}>100000
# 
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd_NSA.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# NSA send ue '${ue_id}' mutiple trf '${number}' for each '${ul_data}' data in '${dir}'
#     :FOR    ${num}    IN RANGE    1    ${number}+1
#     \   Airphone NSA Start Data Traffic    ${ue_id}    ${dir}    ${ul_data}    duration=6000s    trf_id=${num}
#     Wait Throughput Timer    5s
# 
# NSA send dl data
#     :FOR    ${id}    IN RANGE    ${UE_ID}    ${UE_ID}+${UE_COUNT}
#      \  NSA send ue '${id}' mutiple trf '2' for each '175M' data in 'dl'
# 
# NSA send ul data
#     :FOR    ${id}    IN RANGE    ${UE_ID}    ${UE_ID}+${UE_COUNT}
#      \  NSA send ue '${id}' mutiple trf '1' for each '50M' data in 'ul'
# 
# NSA stop data in '${dir}'
#     :FOR    ${id}    IN RANGE    ${UE_ID}    ${UE_ID}+${UE_COUNT}
#     \   Airphone NSA Stop Data Traffic    ${id}    ${dir}
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Wait time to stable
#     sleep    ${STABLETIME}
