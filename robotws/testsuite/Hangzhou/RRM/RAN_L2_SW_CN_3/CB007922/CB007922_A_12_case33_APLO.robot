# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Test Teardown
# Force Tags        CRT    SBTS00   SBTS23R1   RAN_5G_TDD    RAN_5G   AP    owner_changyli
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# #${GNB_SWCONFIG_NAME}    gnb_swconfig.txt
# #${AP_SWCONFIG_NAME}    ap_swconfig.txt
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      SCFC_CASE33_APLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_AEHC_4CELL_LO_CASE33.xml
# ${WTS_NAME}       WTS_CASE33_LO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${EGATE_TAG}      RLQ
# ${SYSLOG_TAG}     after_onair
# ${B_S}            beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=0,1,2,3,4,5 csirs_bestbeam\=2 csirs_rsrp_best\=-44 csirs_rsrp_avg\=-50
# ${BS_MODE}        ue_testmode_set_nr id\=1 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=0
# ${BS_MODE1}       ue_testmode_set_nr id\=1 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=1
# 
# *** Test Cases ***
# CB007922_case33_A_12_intraL2RT_intraBand_Single_UE_DL_UL_refinenBF_A1_SCell_addition_RLQ_deactivation_A2_Scell_release_SA
#     Enable RD syslog in AP Swconfig
#     Prepare gnb onair
#     Start capture gnb and ap syslog in '${SYSLOG_TAG}' file
#     airphone_cleanup_egate_console_log
#     Set traffic type to internal
#     Set refinen Beam
#     #Step1
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     #Step2
#     #UE send A1 event
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=50
#     Check scell add successfully
#     airphone_execute_egate_command    ${BS_MODE1}
#     #Step3
#     Internal send mutiple trf '15' for each '175M' DL data
#     Check scell active
#     Check throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti'
#     Check ttitrace
#     #Step4
#     Override Scell CQI trigger bad threshold
#     #Step5
#     Override Scell CQI trigger good threshold and scell resume
#     #Step6
#     Override Scell CQI trigger bad threshold
#     Check Scell deactive
#     #Step7
#     Override Scell CQI trigger good threshold and scell not resume
#     #Step8
#     UE send A2 event
#     Check Scell release
#     Check Pcell throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti1'
#     Check ttitrace    tti_dl_refine_1.ini
#     #Step9
#     UE send A1 event again
#     Check throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti2'
#     Check ttitrace    tti_dl_refine_2.ini
#     #Step10
#     Stop data transfer
#     Detach UE
# 
# *** Keywords ***
# Check scell add successfully
#     Collect AP egate log    ${EGATE_TAG}
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd33_lo.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Check Scell active
#     wait_for_message_in_syslog_file    SCellIndex 1 activated successfully    timeout=300    alias=collect_ap
# 
# Check Scell deactive
#     wait_for_message_in_syslog_file    SCellIndex 1 deactivated successfully    timeout=300    alias=collect_ap
#     wait_for_message_in_syslog_file    ModifType:DEACTIVATE    timeout=300    alias=collect_gnb
# 
# Check Scell release
#     wait '5s ' to check log
#     airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/release    unzip=TRUE
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scell_release.ini    u    save_log_directory=${TEST_LOG_DIRECTORY()}/All/release
# 
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd33_lo.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Check throughput peak
#     ${pcell_throughput}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0   type=pdsch    tput_type=ave
#     Log To Console    pcell_tput:${pcell_throughput}
#     should_be_true    ${pcell_throughput}>800000
#     ${scell_throughput}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1   type=pdsch    tput_type=ave
#     Log To Console    scell_tput:${scell_throughput}
#     should_be_true    ${scell_throughput}>800000
#     ${total_tput}    evaluate    ${pcell_throughput}+${scell_throughput}
#     should_be_true    ${total_tput}>1800000
# 
# Override Scell CQI trigger bad threshold
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=2 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=1
#     Wait until keyword succeeds    60s    5s    Check big throughput
#     Wait until keyword succeeds    60s    5s    Check scell no throughput
# 
# Override Scell CQI trigger good threshold and scell resume
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=1
#     Check throughput
# 
# Override Scell CQI trigger good threshold and scell not resume
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=1
#     Wait until keyword succeeds    60s    5s    Check big throughput
#     Wait until keyword succeeds    60s    5s    Check scell no throughput
# 
# Check big throughput
#     [Arguments]    ${scell_id}=0    ${throughput}=800000
#     ${dl_throughput}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=${scell_id}    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput}>${throughput}
# 
# Check scell no throughput
#     [Arguments]    ${scell_id}=1    ${throughput}=0
#     ${dl_throughput_scell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=${scell_id}    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_scell}==${throughput}
# 
# Check Pcell throughput
#     Wait until keyword succeeds    60s    5s    Check big throughput
# 
# 
# UE send A1 event again
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=4 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# UE send A2 event
#     airphone_execute_egate_command    ue_measurement_send_nr event\=A2 id\=1 meas_id\=3 rs_type\=ssb scell\=1 scell_rsrp\=30
# 
# Set refinen Beam
#     airphone_execute_egate_command    ${B_S}
#     airphone_execute_egate_command    ${BS_MODE}
# 
# Check throughput
#     wait '10s' for stable
#     Wait until keyword succeeds    60s    5s    Check throughput peak
# 
# Check ttitrace
#     [Arguments]    ${tti_ini}=tti_dl_refine_0.ini
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${tti_ini}    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Test Teardown
#     Common Test Teardown
#     Stop capture gnb and ap syslog in '${SYSLOG_TAG}' file
# 
# Attach UE
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
# 
# Wait '${time} ' to check log
#     sleep    ${time}
# 
# Enable RD syslog in AP Swconfig
#         Modify AP swconfig    0x10041:5
