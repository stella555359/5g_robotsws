# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags    owner_menzheng    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS22R4    SBTS23R1
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_1729_case61_LO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_4CELL.xml
# ${WTS_NAME}    WTS_1729_LO_8450.cfg
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${hi}	5
# ${SYSLOG_TAG}     after_onair
# &{GNBMIRRORINGCONFIG}    BB_SLOT_1='true'    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'
# ...    NUMBER_OF_FILES=30    L2_L1_BIP='true'   CPRT_MIRRORING='true'
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog    btslog    ap_syslog
# ${MSG1}           itf_l2_ps_peerctrl_scellueschedulingreq
# ${MSG2}           itf_l2_ps_peerctrl_scellueschedulingresp
# ${FILTER1}        itf_l2_ps_peerctrl_UeInterCASchedulingModifyParams_t.modifType_item
# ${FILTER2}        itf_l2_ps_peerctrl_UeInterCASchedulingAck_t.modifType_item
# ${BIP_TAG}        bip
# ${TTITRACE_TAG}    tti
# ${EGATE_TAG}    ADD
# ${BEAM_SET}     beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=0,1,2,3,4,5,6,7 csirs_bestbeam\=2 csirs_rsrp_best\=-44
#                 ...    csirs_rsrp_avg\=-50
# 
# *** Test Cases ***
# 5GC001729_Case61_B_9_refine_beam_4X4_peak
#     Prepare gnb onair
#     Start capture gnb and ap syslog in '${SYSLOG_TAG}' file
#     airphone_cleanup_egate_console_log
#     Set traffic type to internal
#     Set SSB Beam
#     Airphone SA Attach    ${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     Internal send mutiple trf '15' for each '175M' DL data
#     Check throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'${TTITRACE_TAG}'
#     Check ttitrace
#     Wait '1800s' for stabible
#     Check throughput	
#     Stop data transfer
# 	
# *** Keywords ***
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
# 	
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 	
# Verify throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>1150000
#     should_be_true    ${dl_throughput_scell1}>1150000
