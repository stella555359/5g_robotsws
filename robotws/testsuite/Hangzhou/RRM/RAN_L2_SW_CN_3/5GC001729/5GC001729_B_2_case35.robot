# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    SBTS22R2    SBTS22R4
# ...   CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# Library           ta_a2a
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_NUM}         10
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      SCFC_1729_MultiUE.xml
# ${AIRPHONE_NAME}    IPHY_AEHC.xml
# ${WTS_NAME}       WTS_1729_multiue.cfg
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'    L2HI_L2LO_MIRRORING='true'
# @{LOG_NAME_LIST}    egatelog
# ${MSG1}           itf_l2_ps_peerctrl_scellueschedulingreq
# ${MSG2}           itf_l2_ps_peerctrl_scellueschedulingresp
# ${FILTER1}        itf_l2_ps_peerctrl_ScellUeSchedulingReq.modifType.modifType_item_0
# ${FILTER2}        itf_l2_ps_peerctrl_ScellUeSchedulingResp.modifType.modifType_item_0
# ${PMCOUNTERTIME}    120s
# ${TTITRACE_TAG}    tti
# ${STABLETIME}     3s
# @{Rdparameter}    0x10041:1
# 
# *** Test Cases ***
# 5GC001729_Case35_B_2_mutileUE_A1addition_BufferActivation_BF_FDM_withBler
#     Modify Swconfig for AP
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Set multiue traffic type to internal
#     Attach '10' ue with '2x2_2cc'capability to 5g cell
#     MultiUE send A1 Event
#     Internal send DL data
#     Check throughput
#     Send bler to UE
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'${TTITRACE_TAG}'
#     Check ttitrace
#     Stop data transfer
#     Detach '10' UE
#     Stop capture gnb and ap syslog in 'after_onair' file
#     
# 
# *** Keywords ***
# Modify Swconfig for AP
#     Modify AP swconfig    @{Rdparameter}
# 
# Internal send DL data
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone SA Start Data Traffic    ${num}    DL    100M    pdu_id=${num}    duration=6000s
#     \    ...    trf_id=${num}
#     \    Wait time to stable
# 
# Check throughput
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Get and verify DL throughput average per ue    ${num}
# 
# analyse scelladd in rrclog
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_scelladd.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Send bler to UE
#     Airphone Bler Testmode Nr    profile_id=1    dl_bler=100
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-10 testmode\=bler action\=activate profile_id\=1
#     Check throughput
# 
# Set multiue traffic type to internal
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone Set Traffic Type    ${num}    ${num}    internal
# 
# MultiUE send A1 Event
#     airphone_cleanup_egate_console_log
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    airphone_execute_egate_command    ue_measurement_send_nr id\=${num} meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
#     \    Wait time to stable
#     \    Check scell add successfully
# 
# Wait time to stable
#     sleep    ${STABLETIME}
# 
# Check scell add successfully
#     airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All    unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_scelladd.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_bler.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Get and verify DL throughput average per ue
#     [Arguments]    ${num}
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=1    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>0
#     should_be_true    ${dl_throughput_scell1}>0
