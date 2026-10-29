# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1    owner_jinxiao
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Library           ta_a2a
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_NUM}         10
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      8423_SCFC_RLQ_SANSA.xml
# ${AIRPHONE_NAME}    iphy-AZHA_2cells.xml
# ${WTS_NAME}       TDD_CPRI_2cells.cfg
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'    L2HI_L2LO_MIRRORING='true'
# @{LOG_NAME_LIST}    egatelog
# ${MSG1}           itf_l2_ps_peerctrl_scellueschedulingreq
# ${MSG2}           itf_l2_ps_peerctrl_scellueschedulingresp
# ${FILTER1}        itf_l2_ps_peerctrl_ScellUeSchedulingReq.modifType.modifType_item_0
# ${FILTER2}        itf_l2_ps_peerctrl_ScellUeSchedulingResp.modifType.modifType_item_0
# ${TTITRACE_TAG}    tti
# 
# *** Test Cases ***
# CB008423_B_Case03_2CC_CA_Mutilue_A1addtion_BufferActivation
#     Modify AP swconfig    0x10041:1
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Set multiue traffic type to internal
#     Attach '10' ue with ''capability to 5g cell
#     MultiUE send A1 Event
#     Internal send DL data
#     run keyword and continue on failure    Check throughput
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti'
#     Check ttitrace
#     Stop data transfer
#     Detach '10' UE
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Internal send DL data
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone SA Start Data Traffic    ${num}    DL    35M    pdu_id=${num}    duration=6000s
#     \    ...    trf_id=${num}
#     \    Wait '3s ' to stable
# 
# Check throughput
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${sa_dl_tput}=    Airphone SA Get Throughput    ${num}    DL    ${num}
#     \    run keyword and continue on failure    Should be true    ${sa_dl_tput}>10000
#     : FOR    ${num}    IN RANGE    1    5+1
#     \    Get and verify DL throughput average per ue    ${num}
# 
# analyse scelladd in rrclog
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_scelladd.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Set multiue traffic type to internal
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone Set Traffic Type    ${num}    ${num}    internal
# 
# MultiUE send A1 Event
#     airphone_cleanup_egate_console_log
#     : FOR    ${num}    IN RANGE    1    5+1
#     \    airphone_measurement_send_nr    id=${num}    meas_id=1    event=A1    rs_type=ssb srsrp_nr=50
#     \    Wait '3s ' to stable
# 
# Wait '${time} ' to stable
#     sleep    ${time}
# 
# Check scell add successfully
#     airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All    unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_scelladd.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Get and verify DL throughput average per ue
#     [Arguments]    ${num}
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=1    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>5000
#     should_be_true    ${dl_throughput_scell1}>5000
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
