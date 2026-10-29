# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Test Teardown
# Force Tags        CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_sasun    AP    SBTS22R2    SBTS22R4    SBTS23R1
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# #${GNB_SWCONFIG_NAME}    gnb_swconfig.txt
# #${AP_SWCONFIG_NAME}    ap_swconfig.txt
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}          11
# ${SCFC_NAME}      SCFC_CASE10_APLO.xml
# ${AIRPHONE_NAME}    IPHY_LO_CASE10.xml
# ${WTS_NAME}       SANSA7922_LO_case06.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${EGATE_TAG}      RLQ
# ${SYSLOG_TAG}     after_onair
# ${B_S}            beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=0,1,2,3 csirs_bestbeam\=2 csirs_rsrp_best\=-44 csirs_rsrp_avg\=-50
# ${BS_MODE}        ue_testmode_set_nr id\=11 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=8
# ${BS_MODE1}       ue_testmode_set_nr id\=11 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=9
# 
# *** Test Cases ***
# CB007922_case10_A_4c_intraL2RT_interBand_Single_UE_A1_Scell_addition_and_RLQ_deactivation_A2_Scell_release_refineBF_NSA
#     Prepare gnb onair
#     Start capture gnb and ap syslog in '${SYSLOG_TAG}' file
#     Execute AP Command before attach
#     Set Refine Beam
#     Attach LTE UE
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=50
# 	airphone_execute_egate_command    ${BS_MODE1}
#     NSA send ue '${UE_ID}' mutiple trf '15' for each '175M' DL data
#     Collect AP egate log    ${EGATE_TAG}
#     Analyse scelladd in rrclog
#     Check throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti1'
#     Check ttitrace    tti_dl_refine_1.ini
#     Override Scell CQI trigger bad threshold
#     Override Scell CQI trigger good threshold and scell resume
#     Override Scell CQI trigger bad threshold
#     Check Scell deactive
#     Override Scell CQI trigger good threshold and scell not resume
#     UE send A2 event
#     Check Scell release
#     Check Pcell throughput
#     UE send A1 event again
#     airphone_execute_egate_command    ${BS_MODE1}
#     Check throughput
#     Airphone NSA Stop Data Traffic    ${UE_ID}    DL
#     Airphone NSA Detach    ${UE_ID}
# 
# *** Keywords ***
# Set Refine Beam
#     airphone_execute_egate_command    ${B_S}
#     airphone_execute_egate_command    ${BS_MODE}
# 
# Verify throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>200000
#     should_be_true    ${dl_throughput_scell1}>200000
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Attach LTE UE
#     Airphone Nsa Attach    ${UE_ID}    profile_id=None
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# Override Scell CQI trigger bad threshold
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=2 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=csi_override action\=activate profile_id\=2 scell\=9
#     Wait until keyword succeeds    60s    5s    Verify Pcell throughput
#     Wait until keyword succeeds    60s    5s    Verify Scell throughput=0
# 
# Override Scell CQI trigger good threshold and scell resume
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=csi_override action\=activate profile_id\=1 scell\=9
#     Check throughput
# 
# UE send A1 event again
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=50
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=50
# 	airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
# Check Scell deactive
#     wait_for_message_in_syslog_file    SCellIndex 9 deactivated successfully    timeout=300    alias=collect_ap
#     wait_for_message_in_syslog_file    ModifType:DEACTIVATE    timeout=300    alias=collect_gnb
# 
# UE send A2 event
#     airphone_execute_egate_command    ue_measurement_send_nr event\=A2 id\=11 meas_id\=3 rs_type\=ssb scell\=9 scell_rsrp\=30
# 
# Override Scell CQI trigger good threshold and scell not resume
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=csi_override action\=activate profile_id\=1 scell\=9
#     Wait until keyword succeeds    60s    5s    Verify Pcell throughput
#     Wait until keyword succeeds    60s    5s    Verify Scell throughput=0
# 
# Check Pcell throughput
#     Wait until keyword succeeds    60s    5s    Verify Pcell throughput
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd_NSA_1.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Test Teardown
#     Common Test Teardown
#     Stop capture gnb and ap syslog in '${SYSLOG_TAG}' file
# 
# Verify Pcell throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>200000
# 
# Verify Scell throughput=0
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_scell1}==0
# 
# Check Scell release
#     wait '5s ' to check log
#     airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/release    unzip=TRUE
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scell_release.ini    u    save_log_directory=${TEST_LOG_DIRECTORY()}/All/release
# 
# Wait '${time} ' to check log
#     sleep    ${time}
# 
# Check ttitrace
#     [Arguments]    ${tti_ini}=tti_dl_refine_0.ini
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${tti_ini}    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
