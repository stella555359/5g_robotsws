# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags        CRT    SBTS00     RAN_5G_TDD    RAN_5G    SBTS23R1
# ...   CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# ${UE_ID}                 1
# ${PDU_ID}           1
# ${GW_ID}            1
# ${SLICE_ID}          1
# ${SCFC_NAME}     SCFC_1729_A_4.xml
# ${AIRPHONE_NAME}    IPHY_AEHC.xml
# ${WTS_NAME}       WTS_1729.cfg
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# @{LOG_NAME_LIST}    egatelog
# ${MSG1}    itf_l2_ps_peerctrl_scellueschedulingreq
# ${MSG2}    itf_l2_ps_peerctrl_scellueschedulingresp
# ${FILTER1}    itf_l2_ps_peerctrl_ScellUeSchedulingReq.modifType.modifType_item_0
# ${FILTER2}    itf_l2_ps_peerctrl_ScellUeSchedulingResp.modifType.modifType_item_0
# ${BIP_TAG}    bip
# ${TTITRACE_TAG}    tti
# @{Rdparameter}    0x10041:1
# 
# *** Test Cases ***
# 5GC001729_Case4_A_6a_abil_A1daddition_nonBF
#     Modify Swconfig for AP
#     #used for PM counter
#     Add GNB swconfig	0x340000:15
#     
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Set traffic type to internal
#     airphone_cleanup_egate_console_log
#     Attach ue with '2x2_2cc'capability to 5g cell
#     UE send A1 Event
#     Internal send DL data
#     collect AP egate log
#     analyse scelladd in rrclog
#     Stop capture gnb and ap syslog in 'after_onair' file
#     Stop data transfer
#     Detach UE
# 
# 5GC001729_Case7_A_4b_Pusch_multiplex_abil_blindActivation_A1addition
# 
#     Start capture gnb and ap syslog in 'after_onair' file
#     Set traffic type to internal
#     airphone_cleanup_egate_console_log
#     #Start collect ttitrace
#     Attach ue with '2x2_2cc'capability to 5g cell
#     UE send A1 Event
#     Internal send DL data
#     Internal send UL data
#     #Wait for '2s' to stop ttitrace with name'${TTITRACE_TAG}'
#     collect AP egate log
#     analyse scelladd in rrclog
#     Check throughput
#     #check DTX in ttitrace
#     Stop capture gnb and ap syslog in 'after_onair' file
#     Stop data transfer
#     Detach UE
# 
# *** Keywords ***
# collect AP egate log
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All   unzip=TRUE
# 
# Modify Swconfig for AP
#     Modify AP swconfig    @{Rdparameter}
# analyse scelladd in rrclog
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_scelladd_51.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# 
# Internal send DL data
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    165M    pdu_id=${PDU_ID}    duration=6000s    trf_id=1
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    165M    pdu_id=${PDU_ID}    duration=6000s    trf_id=2
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    165M    pdu_id=${PDU_ID}    duration=6000s    trf_id=3
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    165M    pdu_id=${PDU_ID}    duration=6000s    trf_id=4
# 
# 
# check scell activate in bip log
#     Check bip message'${MSG1}' with ${FILTER1} is equal to value'0'
# 
# Internal send UL data
#     Airphone SA Start Data Traffic    ${UE_ID}    UL    10M    pdu_id=${PDU_ID}    duration=6000s    trf_id=1
# 
# check DTX in ttitrace
#     check_log_with_au2anlysis    ini_path=${CONFIG_DIR_PATH}/ini/DTX.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check throughput
#     Airphone Cqi Param    scell_id=0-1    nr_cqi=15
#     Check PM counter pcell have throughput
#     Check PM counter scell have throughput
# 
# 
# Check PM counter scell have throughput
#      Wait until keyword succeeds    200s    20s   Check pm counter M55310C01006 in cell 2 is expected > 0
# 
# Check PM counter pcell have throughput
#      Wait until keyword succeeds    200s    20s   Check pm counter M55310C01006 in cell 1 is expected > 0
# 
