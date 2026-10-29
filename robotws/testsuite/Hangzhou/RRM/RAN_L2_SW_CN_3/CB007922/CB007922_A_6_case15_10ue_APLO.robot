# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00   SBTS23R1   RAN_5G_TDD    RAN_5G   AP    owner_changyli
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# #${GNB_SWCONFIG_NAME}    gnb_swconfig.txt
# #${AP_SWCONFIG_NAME}    ap_swconfig.txt
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_CASE15_APLO.xml
# ${AIRPHONE_NAME}    IPHY_2AEQE_CASE15_APLO.xml
# ${WTS_NAME}       WTS_2AEQE_CASE15_APLO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${UE_ID}          11
# ${UE_ID_2}        16
# ${EGATE_TAG}      ADD
# ${UE_COUNT}       5    # number of each ue
# ${STABLETIME}     1s
# 
# *** Test Cases ***
# CB007922_case15_A_6b_interL2RT_intraBand_Multiple_UE_DL_UL_data_scheduling_NSA_and_blind_SCell_addition_10ue
#     Enable RD syslog in AP Swconfig
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Execute AP Command before attach
#     Attach LTE CAUE
#     Attach LTE NCAUE
#     NSA send data
#     Collect AP egate log    ${EGATE_TAG}
#     Analyse scelladd in rrclog
#     Check throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti'
#     Check ttitrace
#     Airphone NSA Stop Data Traffic And Detach UE
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Check throughput
#     wait '10s' for stable
#     Wait until keyword succeeds    60s    5s    Verify CAUE throughput
#     Wait until keyword succeeds    60s    5s    Verify NCAUE throughput
#     ${total_tput}    evaluate    ${caue_tput}+${ncaue_tput}
#     Log To Console    total_tput:${total_tput}
# 
# Attach LTE CAUE
#     :FOR    ${num}    IN RANGE    ${UE_ID}    ${UE_ID}+${UE_COUNT}
#     \   Airphone Nsa Attach    ${num}
#     \   Wait time to stable
#     \   airphone_execute_egate_command    ue_measurement_send_nr id\=${num} meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# Attach LTE NCAUE
#     :FOR    ${num}    IN RANGE    ${UE_ID_2}    ${UE_ID_2}+${UE_COUNT}
#     \   Wait time to stable
#     \   Airphone Nsa Attach    ${num}
# 
# NSA send data
#     :FOR    ${num}    IN RANGE    ${UE_ID}    ${UE_ID}+${UE_COUNT}*2
#     \   NSA send ue '${num}' mutiple trf '4' for each '175M' DL data
# 
# Airphone NSA Stop Data Traffic And Detach UE
#     :FOR    ${num}    IN RANGE    ${UE_ID}    ${UE_ID}+${UE_COUNT}*2
#     \   Airphone NSA Stop Data Traffic    ${num}    DL
#     \   Airphone NSA Detach    ${num}
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Verify CAUE throughput
#     wait '10s' for stable
#     ${caue_tput}    set variable    ${0}
#     :FOR    ${num}    IN RANGE    ${UE_ID}    ${UE_ID}+${UE_COUNT}
#     \   ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
#     \   ${dl_throughput_scell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=9    type=pdsch    tput_type=ave
#     \   ${caue_tput}    evaluate    (${caue_tput}+${dl_throughput_pcell}+${dl_throughput_scell})
#     \   set test variable    ${caue_tput}
#     \   Log To Console    pcell_tput:${dl_throughput_pcell}
#     \   Log To Console    scell_tput:${dl_throughput_scell}
#     \   should_be_true    ${dl_throughput_pcell}>20000
#     \   should_be_true    ${dl_throughput_scell}>20000
#     Log To Console    caue_tput:${caue_tput}
# 
# Verify NCAUE throughput
#     wait '10s' for stable
#     ${ncaue_tput}    set variable    ${0}
#     set test variable    ${ncaue_tput}
#     :FOR    ${num}    IN RANGE    ${UE_ID_2}    ${UE_ID_2}+${UE_COUNT}
#     \   ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
#     \   ${ncaue_tput}    evaluate    (${ncaue_tput}+${dl_throughput_pcell})
#     \   set test variable    ${ncaue_tput}
#     \   Log To Console    pcell_tput:${dl_throughput_pcell}
#     \   should_be_true    ${dl_throughput_pcell}>50000
#     Log To Console    ncaue_tput:${ncaue_tput}
# 
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd_NSA_case15.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# NSA send ue '${ue_id}' mutiple trf '${number}' for each '${ul_data}' UL data
#     :FOR    ${num}    IN RANGE    1    ${number}+1
#     \   Airphone NSA Start Data Traffic    ${ue_id}    DL    ${ul_data}    duration=6000s    trf_id=${num}
#     Wait Throughput Timer    5s
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Wait time to stable
#     sleep    ${STABLETIME}
# 
# Enable RD syslog in AP Swconfig
#         Modify AP swconfig    0x10041:5
