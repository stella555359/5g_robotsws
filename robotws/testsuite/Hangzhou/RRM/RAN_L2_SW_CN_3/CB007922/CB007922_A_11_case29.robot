# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Test Teardown
# Force Tags        CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    SBTS22R4    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}          11
# ${SCFC_NAME}      SCFC_7922_case29.xml
# ${AIRPHONE_NAME}    IPHY_AEHC_4CELL.xml
# ${WTS_NAME}       SANSA7922.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${SCell_add}      scelladd
# ${SCell_release}      scellrelease
# ${SYSLOG_TAG}     after_onair
# 
# *** Test Cases ***
# CB007922_case29_A_11_interL2RT_interBand_Single_UE_DL_UL_data_NSA_with_Beamrefinement_ssb8_degraded_upgrade    
#     [Tags]    QC_xxx
#     Prepare gnb onair
#     Start capture gnb and ap syslog in '${SYSLOG_TAG}' file
#     Execute AP Command before attach
#     Attach LTE UE
#     NSA send ue '${UE_ID}' mutiple trf '5' for each '175M' DL data
# 	UE send A1 event
# 	sleep     10s   
#     UE send A2 event
# 	sleep     10s
# 	Collect AP egate log    ${SCell_add}
# 	Analyse scelladd in rrclog
#     Analyse ssbeamdowngrade in rrclog
# 	
#     Check Scell release
# #    Analyse ssbeamupgrade in rrclog
# #   Check throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti'
#     Check ttitrace
# 
#     Airphone NSA Stop Data Traffic    ${UE_ID}    DL
#     Airphone NSA Detach    ${UE_ID}
# 
# *** Keywords ***
# Verify throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    
# 	...    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=9    
# 	...    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>180000
#     should_be_true    ${dl_throughput_scell1}>180000
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    enb_x2_link_up enb\=1 target\=2
# 
# Attach LTE UE
#     Airphone Nsa Attach    ${UE_ID}    profile_id=None
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# UE send A1 event again
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# Check Scell deactive
#     wait_for_message_in_syslog_file    SCellIndex 9 deactivated successfully    timeout=300    alias=collect_ap
#     wait_for_message_in_syslog_file    ModifType:DEACTIVATE    timeout=300    alias=collect_gnb
# 
# UE send A2 event
#     airphone_execute_egate_command    ue_measurement_send_nr event\=A2 id\=11 meas_id\=2 rs_type\=ssb 
# 	...    scell\=9 scell_rsrp\=30
# 
# 
# Check Pcell throughput
#     Wait until keyword succeeds    60s    5s    Verify Pcell throughput
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd_NSA.ini    p    
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${Scell_add}_egate
# 
# Analyse ssbeamdowngrade in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd_NSA_SSBdowngrade.ini    p    
# 	...     save_log_directory=${TEST_LOG_DIRECTORY()}/All/${Scell_add}_egate
# 
# Analyse ssbeamupgrade in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd_NSA_SSBupgrade.ini    p    
# 	...     save_log_directory=${TEST_LOG_DIRECTORY()}/All/${Scell_add}_egate
# 
# Test Teardown
#     Common Test Teardown
#     Stop capture gnb and ap syslog in '${SYSLOG_TAG}' file
# 
# Verify Pcell throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    
# 	...    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>180000
# 
# Verify Scell throughput=0
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=9    
# 	...    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_scell1}==0
# 
# Check Scell release
#     wait '5s ' to check log
#     airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/release    unzip=TRUE
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scell_release.ini    u    
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${Scell_add}_egate
# 
# Wait '${time} ' to check log
#     sleep    ${time}
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
