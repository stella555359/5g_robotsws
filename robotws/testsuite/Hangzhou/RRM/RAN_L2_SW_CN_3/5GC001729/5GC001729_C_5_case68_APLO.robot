# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_sasun    AP   SBTS22R4    SBTS23R1
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# 
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      SCFC_68_LO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_4CELL.xml
# ${WTS_NAME}       WTS_1729_LO_8450.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${EGATE_TAG}    ADD
# ${PCELL_THRESHOLD}    300000
# ${SCELL_THRESHOLD}    0
# 
# *** Test Cases ***
# 5GC001729_Case68_C5_overheeting_blindactivation_nonBF_MixedBW
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     Set traffic type to internal
#     Airphone SA Attach    ${UE_ID}
# 	Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     Internal send mutiple trf '15' for each '175M' DL data
#     Collect AP egate log    ${EGATE_TAG}
#     analyse scelladd in rrclog
#     Check Scell active
#     Override Scell CQI trigger overheating threshold
#     Wait until keyword succeeds    60s    5s    Check SA ue '${ue_id}' 'pcell' dl throught should '> ${PCELL_THRESHOLD}'
#     Wait until keyword succeeds    60s    5s    Check SA ue '${ue_id}' 'scell' dl throught should '== ${SCELL_THRESHOLD}'
#     Stop data transfer
#     Detach UE
# 
# *** Keywords ***
# Wait time to check throughput
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait '${remaining_time}s' for stabible
# 
# Wait reach threshold
#     [Arguments]    ${check_point}
#     Wait Until Keyword Succeeds    200s    10s    ${check_point}
# 
# Override Scell CQI trigger overheating threshold
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=1
# 
# Check Scell active
#     wait_for_message_in_syslog_file    SCellIndex 1 activated successfully    timeout=30    alias=collect_ap
# 
# Check PM counter scell have throughput
#      Wait until keyword succeeds    200s    20s   Check pm counter M55310C01006 in cell 2 is expected > 0
# 
# Check Pcell throughput
#     ${sa_dl_tput}=    Airphone SA Get Throughput    ${UE_ID}    DL    ${PDU_ID}
#     run keyword and continue on failure    Should be true    ${sa_dl_tput}>100000
# 
# Stop data transfer
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}    direction=dl
# 
# Detach UE
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
