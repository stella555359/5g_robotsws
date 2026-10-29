# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BLLL_AP_LOO    owner_yuqq    SBTS22R4    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      CNI70851_SCFC_case3_LOO.xml
# ${AIRPHONE_NAME}    IPHY_2AEQE_case54_LOO.xml
# ${WTS_NAME}       WTS_case54_2AEQE.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog
# ${EGATE_TAG}    ADD
# ${CSI_CMD1}    csi_override_testmode_nr profile_id\=1 cqi_mode\=fixed cqi\=15 ri_mode\=fixed ri\=1 pmi_mode\=fixed pmi\=124
#                ...    cri_mode\=fixed cri\=1 li_mode\=fixed li\=1
# ${CSI_CMD2}   ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
# ${UE1_A1_EVENT}    ue_measurement_send_nr id\=1 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
# ${EGATE_gap}    gap
# 
# *** Test Cases ***
# CNI70851_case03_intraL2RT_SA_5GC002200_DRX_MG
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     Set traffic type to internal
#     sleep     60s
#     Attach SA UE
#     Internal send mutiple trf '8' for each '175M' DL data 
# 	Run Keyword And Continue On Failure    Check throughput
# 	UE send A2 Event
# 	UE send A1 Event
# 	Collect AP egate log    ${EGATE_gap}
# 	Analyse drxoff in rrclog
# #	Analyse drxon in rrclog
# 	Detach UE
# 	Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Attach SA UE
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     Wait '5s' for stabible
# Override CSI For UE
#     airphone_execute_egate_command    ${CSI_CMD1}
#     airphone_execute_egate_command    ${CSI_CMD2}
# Release VONR
#     airphone_execute_egate_command    ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_del\=2
# 	Wait '5s' for stabible
# 
# 
# Wait time to check throughput
#     ${remaining_time}    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait '${remaining_time}s' for stabible
# 	
# Check Scell active
#     wait_for_message_in_syslog_file    SCellIndex 1 activated successfully    timeout=30    alias=collect_ap
# 
# Check Pcell throughput
#     ${sa_dl_tput}=    Airphone SA Get Throughput    ${UE_ID}    DL    ${PDU_ID}
#     run keyword and continue on failure    Should be true    ${sa_dl_tput}>0
# 
# 	
# Check throughput
#      ${pcell_tp}=    airphone_get_throughput_on_specific_scell    1    0    type=pdsch    tput_type=ave
#      ${scell_tp}=    airphone_get_throughput_on_specific_scell    1    1    type=pdsch    tput_type=ave
#      should be true    ${pcell_tp}>0
#      should be true    ${scell_tp}>0
# 
# Stop data transfer
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}    direction=dl
# 
# Detach UE
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# UE send A1 Event
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=95
#     Wait '3s' for stabible
# 
# UE send A2 Event
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=1 event\=A2 rs_type\=ssb srsrp_nr\=50
#     Wait '3s' for stabible
#  
# Analyse drxoff in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/drx_off.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_gap}_egate
# 
# Analyse drxon in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/drx_on.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_gap}_egate
# 
# 
# Wait reach threshold
#     [Arguments]    ${check_point}
#     Wait Until Keyword Succeeds    200s    10s    ${check_point}
# 
