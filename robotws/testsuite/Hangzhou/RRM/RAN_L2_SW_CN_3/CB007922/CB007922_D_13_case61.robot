# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        owner_yuqq    AP    SBTS22R2    SBTS23R1
# Library           ta_a2a
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_NUM}         4
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      SCFC_7922_case61.xml
# ${AIRPHONE_NAME}    2AEQE_1AEQA.xml
# ${WTS_NAME}       SANSA7922-F.cfg
# ${GNB_SWCONFIG_NAME}    swconfig_OL_g.txt
# ${AP_SWCONFIG_NAME}    swconfig_OL_a.txt
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'    L2HI_L2LO_MIRRORING='true'
# @{LOG_NAME_LIST}    egatelog
# ${MSG1}           itf_l2_ps_peerctrl_scellueschedulingreq
# ${MSG2}           itf_l2_ps_peerctrl_scellueschedulingresp
# ${FILTER1}        itf_l2_ps_peerctrl_ScellUeSchedulingReq.modifType.modifType_item_0
# ${FILTER2}        itf_l2_ps_peerctrl_ScellUeSchedulingResp.modifType.modifType_item_0
# ${PMCOUNTERTIME}    120s
# ${TTITRACE_TAG}    tti
# 
# *** Test Cases ***
# CB007922_case61_D_13_Multiple_UE_DL_UL_SA_BF_and_blind_SCell_addition_on_mixture_of_ABIL_ABIO_NSA    
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Set multiue traffic type to internal
#     Attach '4' UEs
#     Internal send DL data
#     run keyword and continue on failure    Check throughput
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti'
#     run keyword and continue on failure    Check ttitrace
#     Stop data transfer
#     Detach '4' UE
# 
# *** Keywords ***
# Internal send DL data
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone SA Start Data Traffic    ${num}    DL    150M    pdu_id=${num}    duration=6000s
#     \    ...    trf_id=${num}
#     \    Wait '5s ' to stable
#     : FOR    ${num}    IN RANGE    1    2+1
#     \    Airphone SA Start Data Traffic    ${num}    DL    150M    pdu_id=${num}    duration=6000s
#     \    ...    trf_id=3
#     \    Wait '5s ' to stable
# 
# Check throughput
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${sa_dl_tput}=    Airphone SA Get Throughput    ${num}    DL    ${num}
#     \    run keyword and continue on failure    Should be true    ${sa_dl_tput}>30000
#     : FOR    ${num}    IN RANGE    1    2+1
#     \    Get and verify DL throughput average per ue    ${num}
# 
# analyse scelladd in rrclog
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_scelladd.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Set multiue traffic type to internal
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone Set Traffic Type    ${num}    ${num}    internal
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
#     should_be_true    ${dl_throughput_pcell}>10000
#     should_be_true    ${dl_throughput_scell1}>10000
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Attach '${uenum}' UEs
#     : FOR    ${num}    IN RANGE    1    ${uenum}+1
#     \    Airphone SA Attach    ue_id=${num}
#     \    Wait '2s' for stabible
#     \    Airphone Pdu Session Setup    ${num}    ${num}    ${SLICE_ID}    ${num}
#     \    Wait '3s' for stabible
