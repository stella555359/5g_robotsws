# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS22R1    owner_menzheng    SBTS22R2    SBTS22R4    SBTS23R1
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
# ${SCFC_NAME}      SCFC_22.xml
# ${AIRPHONE_NAME}    IPHY_AEHC.xml
# ${WTS_NAME}       WTS_1729.cfg
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
# ${BEAM_SET}    beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=5,0,1,2,3,4 ssbeam_bestbeam\=0 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-50
# 
# 
# 
# *** Test Cases ***
# 5GC001729_Case22_A_5d_2CC_CA_abil_A1daddition_BufferActivation
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Set traffic type to internal
#     Attach ue with '2x2_2cc'capability to 5g cell
#     UE send A1 event
#     Collect AP egate log    ${EGATE_TAG}
#     analyse scelladd in rrclog
#     Internal send mutiple trf '4' for each '175M' DL data
#     Check pcell and scell have throughput
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 	
# Check pcell and scell have throughput
#      Wait '10s' for stabible
#      ${pcell_tp}=    airphone_get_throughput_on_specific_scell    1    0    type=pdsch    tput_type=ave
#      ${scell_tp}=    airphone_get_throughput_on_specific_scell    1    1    type=pdsch    tput_type=ave
#      should be true    ${pcell_tp}>0
#      should be true    ${scell_tp}>0