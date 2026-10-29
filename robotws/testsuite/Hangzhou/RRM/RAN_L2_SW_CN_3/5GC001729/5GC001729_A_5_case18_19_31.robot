# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Test Teardown
# Force Tags        CRT    RAN_5G_TDD    RAN_5G    SBTS22R1    owner_jinxiao    SBTS22R2    SBTS22R4    SBTS23R1
# ...   CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# ...               AP
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      SCFC_1729.xml
# ${AIRPHONE_NAME}    IPHY_AEHC.xml
# ${WTS_NAME}       WTS_1729.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${BEAM_SET}     beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=5,0,1,2,3,4 ssbeam_bestbeam\=0 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-50
# ${EGATE_TAG}      RLQ
# ${SYSLOG_TAG}     after_onair
# 
# *** Test Cases ***
# 5GC001729_Case19_A_5b_bufferbased_activation_BufferAndRLQualityBased_Deactivation
#     Modify AP swconfig    0x10041:1
#     Add GNB swconfig    0x340000:15
#     Prepare gnb onair
#     Start capture gnb and ap syslog in '${SYSLOG_TAG}' file
#     airphone_cleanup_egate_console_log
#     Set traffic type to internal
#     Attach ue with '2x2_2cc'capability to 5g cell
#     UE send A1 event
#     Internal send mutiple trf '6' for each '175M' DL data
#     Collect AP egate log    ${EGATE_TAG}
#     Analyse scelladd in rrclog
#     Check throughput
#     Override Scell CQI trigger bad threshold
#     Override Scell CQI trigger good threshold and scell resume
#     Override Scell CQI trigger bad threshold
#     Check Scell deactive
#     Override Scell CQI trigger good threshold and scell not resume
#     Stop data transfer
# 
# 5GC001729_Case18_A_5b_Blind_activation_BufferAndRLQualityBased_Deactivation_BF
#     Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_case18.json
#     Wait '30s' for stabible
#     Start Wts And Wait Bts Until Onair    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${WTS_NAME}
#     Start capture gnb and ap syslog in '${SYSLOG_TAG}' file
#     airphone_cleanup_egate_console_log
#     Set traffic type to internal
#     Set SSB Beam
#     Attach ue with '2x2_2cc'capability to 5g cell
#     UE send A1 event
#     Internal send mutiple trf '6' for each '175M' DL data
#     Collect AP egate log    ${EGATE_TAG}
#     Analyse scelladd in rrclog
#     Check throughput
#     Override Scell CQI trigger bad threshold
#     Override Scell CQI trigger good threshold and scell resume
#     Override Scell CQI trigger bad threshold
#     Check Scell deactive
#     Override Scell CQI trigger good threshold and scell not resume
#     Stop data transfer
# 
# 5GC001729_Case31_A_5f_RLQ_based_stop_and_resume_scheduling_BF
#     Online change BadRlqCount to 0
#     Start capture gnb and ap syslog in '${SYSLOG_TAG}' file
#     Set traffic type to internal
#     Set SSB Beam
#     Attach ue with '2x2_2cc'capability to 5g cell
#     UE send A1 event
#     Internal send mutiple trf '6' for each '175M' DL data
#     Check pcell and scell have throughput
#     Override Scell CQI trigger bad threshold
#     Override Scell CQI trigger good threshold and scell resume
#     Override Scell CQI trigger bad threshold
#     Check Scell not deactive
#     Override Scell CQI trigger good threshold and scell resume
#     Stop capture gnb and ap syslog in '${SYSLOG_TAG}' file
# 
# *** Keywords ***
# Online change BadRlqCount to ${value}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-2    sCellDeactivationBadRlqCount    ${value}    online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
# 
# Check pcell and scell have throughput
#     Wait until keyword succeeds    200s    20s    Check pm counter M55310C01006 in cell 2 is expected > 0
#     Wait until keyword succeeds    60s    15s    Check Pcell throughput
# 
# Check Scell not deactive
#     Wait '300s' for stabible
# 
# Override Scell CQI trigger bad threshold
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=2 
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=1
#     Wait until keyword succeeds    60s    15s    Check Pcell throughput
#     Check PM counter scell no throughput
# 
# Override Scell CQI trigger good threshold and scell resume
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=1
#     Wait until keyword succeeds    60s    15s    Check Pcell throughput
#     Check PM counter scell have throughput
# 
# Check PM counter scell no throughput
#     Wait until keyword succeeds    240s    20s    Check pm counter M55310C01006 in cell 2 is expected == 0
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
#     Check PM counter scell no throughput
# 
# Check PM counter scell have throughput
#     Wait until keyword succeeds    200s    20s    Check pm counter M55310C01006 in cell 2 is expected > 0
# 
# Check Pcell throughput
#     ${sa_dl_tput}=    Airphone SA Get Throughput    ${UE_ID}    DL    ${PDU_ID}
#     run keyword and continue on failure    Should be true    ${sa_dl_tput}>150000
# 
# Check throughput
#     Check PM counter scell have throughput
#     Wait until keyword succeeds    60s    15s    Check Pcell throughput
# 
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Set SSB Beam
#     airphone_execute_egate_command    ${BEAM_SET}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach
# 
# Test Teardown
#     Common Test Teardown
#     Detach UE
#     Stop capture gnb and ap syslog in '${SYSLOG_TAG}' file
