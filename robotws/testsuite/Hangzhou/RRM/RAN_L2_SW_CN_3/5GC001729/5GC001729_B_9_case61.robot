# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Test Teardown
# Force Tags        CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS22R1    owner_menzheng    
# ...   CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# ...               AP
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      SCFC_1729_case61.xml
# ${AIRPHONE_NAME}    IPHY_AEHC.xml
# ${WTS_NAME}       WTS_1729.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${BEAM_SET}     beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=0,1,2,3,4,5,6,7 csirs_bestbeam\=2 csirs_rsrp_best\=-44
#                 ...    csirs_rsrp_avg\=-50
# ${SYSLOG_TAG}     after_onair
# ${TTITRACE_TAG}    tti
# 
# *** Test Cases ***
# 5GC001729_Case61_B_9_refine_beam_4X4_peak
#     Prepare gnb onair
#     Start capture gnb and ap syslog in '${SYSLOG_TAG}' file
#     airphone_cleanup_egate_console_log
#     Set traffic type to internal
#     Set SSB Beam
#     Attach ue with '4x4_2cc'capability to 5g cell
#     Internal send mutiple trf '6' for each '175M' DL data
#     Check pcell and scell have throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'${TTITRACE_TAG}'
#     Check ttitrace
#     Stop data transfer
# 
# *** Keywords ***
# Check pcell and scell have throughput
#      Wait '10s' for stabible
#      ${pcell_tp}=    airphone_get_throughput_on_specific_scell    1    0    type=pdsch    tput_type=ave
#      ${scell_tp}=    airphone_get_throughput_on_specific_scell    1    1    type=pdsch    tput_type=ave
#      should be true    ${pcell_tp}>0
#      should be true    ${scell_tp}>0
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
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_beam.ini    log_need_to_check=i
#    ..    save_log_directory=${TEST_LOG_DIRECTORY()}/All
