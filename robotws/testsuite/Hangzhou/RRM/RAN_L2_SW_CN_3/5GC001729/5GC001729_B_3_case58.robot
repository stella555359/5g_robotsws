# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Test Teardown
# Force Tags        CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    SBTS22R2    SBTS22R4
# ...   CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      SCFC_1729_case58.xml
# ${AIRPHONE_NAME}    IPHY_AEHC.xml
# ${WTS_NAME}       WTS_1729.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${BEAM_SET}     beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=0,1,2,3,4,5,6,7 csirs_bestbeam\=2 csirs_rsrp_best\=-44
#                 ...    csirs_rsrp_avg\=-50
# ${EGATE_TAG}      RLQ
# ${SYSLOG_TAG}     after_onair
# ${TTITRACE_TAG}    tti
# @{Rdparameter}    0x10041:1
# *** Test Cases ***
# 5GC001729_Case58_B_3_refine_beamTracking_RLQ_based_SCell_deactivation
#     Modify Swconfig for AP
#     Prepare gnb onair
#     Start capture gnb and ap syslog in '${SYSLOG_TAG}' file
#     airphone_cleanup_egate_console_log
#     Set traffic type to internal
#     Set SSB Beam
#     Attach ue with '2x2_2cc'capability to 5g cell
#     UE send A1 event
#     Internal send mutiple trf '6' for each '175M' DL data
#     Check pcell and scell have throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'${TTITRACE_TAG}'
#     Check ttitrace
#     Override Scell CQI trigger bad threshold
#     Override Scell CQI trigger good threshold and scell resume
#     Override Scell CQI trigger bad threshold
#     Check Scell deactive
#     Override Scell CQI trigger good threshold and scell not resume
#     Stop data transfer
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# *** Keywords ***
# Modify Swconfig for AP
#     Modify AP swconfig    @{Rdparameter}
# 
# Check pcell and scell have throughput
#      Wait '10s' for stabible
#      ${pcell_tp}=    airphone_get_throughput_on_specific_scell    1    0    type=pdsch    tput_type=ave
#      ${scell_tp}=    airphone_get_throughput_on_specific_scell    1    1    type=pdsch    tput_type=ave
#      should be true    ${pcell_tp}>0
#      should be true    ${scell_tp}>0
# 
# 
# Override Scell CQI trigger bad threshold
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=2
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=1
#     Wait until keyword succeeds    60s    15s    Check Pcell throughput
# 
# 
# Override Scell CQI trigger good threshold and scell resume
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=1
#     Wait '30s' for stabible
#     Check pcell and scell have throughput
# 
# Check Scell deactive
#     wait_for_message_in_syslog_file    SCellIndex 1 deactivated successfully    timeout=300    alias=collect_ap
#     wait_for_message_in_syslog_file    ModifType:DEACTIVATE    timeout=300    alias=collect_gnb
# 
# Check Scell active
#     wait_for_message_in_syslog_file    SCellIndex 1 activated successfully    timeout=30    alias=collect_ap
# 
# Override Scell CQI trigger good threshold and scell not resume
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=1
#     Wait until keyword succeeds    60s    15s    Check Pcell throughput
# 
# 
# Check PM counter scell have throughput
#     Wait until keyword succeeds    200s    20s    Check pm counter M55310C01006 in cell 2 is expected > 0
# 
# Check Pcell throughput
#      ${pcell_tp}=    airphone_get_throughput_on_specific_scell    1    0    type=pdsch    tput_type=ave
#      ${scell_tp}=    airphone_get_throughput_on_specific_scell    1    1    type=pdsch    tput_type=ave
#      should be true    ${pcell_tp}>0
#      should be true    ${scell_tp}==0
# 
# Set SSB Beam
#     airphone_execute_egate_command    ${BEAM_SET}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach
# 
# Test Teardown
#     Common Test Teardown
#     Detach UE
#     Stop capture gnb and ap syslog in '${SYSLOG_TAG}' file
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_beam.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
