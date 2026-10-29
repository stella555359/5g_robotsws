# *** Settings ***
# Test Timeout      60 minutes
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        owner_yuqq    AP     SBTS22R4    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# ...   CLOUD_5G_KLL_AP_SA_L1B_ECPRI_CMWV
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_NUM}         10
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      SCFC_1729_case50.xml
# ${AIRPHONE_NAME}    IPHY_AEHC.xml
# ${WTS_NAME}       WTS_1729_multiue.cfg
# @{LOG_NAME_LIST}    egatelog
# ${EGATE_gap}    gap
# 
# 
# *** Test Cases ***
# 5GC001729_Case50_B_5b_MeasureGP_withDRX_BF
# 
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
# 	Set traffic type to internal 
# 	Airphone Cleanup Egate Console Log
# 	Airphone Sa Attach    ${UE_ID}
# 	Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
# 	Internal send mutiple trf '12' for each '175M' DL data
# 	Run Keyword And Continue On Failure    Check throughput
# 	UE send A2 Event
# 	UE send A1 Event
# 	Collect AP egate log    ${EGATE_gap}
# 	Analyse drxoff in rrclog
# 	Analyse drxon in rrclog
# 	Detach UE
# 	Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# *** Keywords ***
# UE send A1 Event
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=95
#     Wait '3s' for stabible
# 
# UE send A2 Event
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=1 event\=A2 rs_type\=ssb srsrp_nr\=75
#     Wait '3s' for stabible
# 
# Wait reach threshold
#     [Arguments]    ${check_point}
#     Wait Until Keyword Succeeds    200s    10s    ${check_point}
# 	
# Analyse drxoff in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/drx_off.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_gap}_egate
# 
# Analyse drxon in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/drx_on.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_gap}_egate
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 	
# Verify throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>200000
#     should_be_true    ${dl_throughput_scell1}>200000