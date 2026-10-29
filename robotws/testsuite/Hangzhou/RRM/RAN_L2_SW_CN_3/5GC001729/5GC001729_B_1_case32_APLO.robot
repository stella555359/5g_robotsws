# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_menzheng    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP
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
# ${SCFC_NAME}      SCFC_case32_apoabio.xml
# ${AIRPHONE_NAME}    iphy_2aeqe.xml
# ${WTS_NAME}       WTS_1729_multiue_apoabio.cfg
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'    L2HI_L2LO_MIRRORING='true'
# @{LOG_NAME_LIST}    egatelog
# ${MSG1}           itf_l2_ps_peerctrl_scellueschedulingreq
# ${MSG2}           itf_l2_ps_peerctrl_scellueschedulingresp
# ${FILTER1}        itf_l2_ps_peerctrl_ScellUeSchedulingReq.modifType.modifType_item_0
# ${FILTER2}        itf_l2_ps_peerctrl_ScellUeSchedulingResp.modifType.modifType_item_0
# ${TTITRACE_TAG}    tti
# 
# *** Test Cases ***
# 5GC001729_Case32_B_1a_2CC_CA_Mutilue_A1addtion_BufferActivation_with_BF_FDM
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Wait for 1st counters
#     Set multiue traffic type to internal
#     Attach 10 UE to 5g cell
#     MultiUE send A1 Event
#     Internal send DL data
#     Check counters
#     run keyword and continue on failure    Check throughput
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti'
#     Check ttitrace
#     Stop data transfer
#     Detach '10' UE
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Attach 10 UE to 5g cell
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone SA Attach    ue_id=${num}
#     \    Wait '5s ' to stable
#     \    Airphone Pdu Session Setup    ${num}     ${num}     ${SLICE_ID}    ${num}
#     \    Wait '5s ' to stable
# Internal send DL data
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone SA Start Data Traffic    ${num}    DL    100M    pdu_id=${num}    duration=6000s
#     \    ...    trf_id=${num}
#     \    Wait '3s ' to stable
# 
# Check throughput
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${sa_dl_tput}=    Airphone SA Get Throughput    ${num}    DL    ${num}
#     \    run keyword and continue on failure    Should be true    ${sa_dl_tput}>30000
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
#     : FOR    ${num}    IN RANGE    1    10+1
#     \    airphone_execute_egate_command    ue_measurement_send_nr id\=${num} meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
#     \    Wait '5s ' to stable
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
# Check counters
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
#     ${PM_counter_value_M55139C01003}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55139C01003    cell_id=1
#     ${PM_counter_value_M55139C01004}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55139C01004    cell_id=1
#     ${PM_counter_value_M55139C01001}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55139C01001    cell_id=2
#     ${PM_counter_value_M55139C01002}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55139C01002    cell_id=2
#     ${PM_counter_value_M55316C02000}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55316C02000    cell_id=1
# 	${PM_counter_value_M55316C05001}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55316C05001    cell_id=1
#     ${PM_counter_value_M55316C05000}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55316C05000    cell_id=1
#     should be true    ${PM_counter_value_M55139C01003}== 10
#     should be true    ${PM_counter_value_M55139C01004}== 10
#     should be true    ${PM_counter_value_M55139C01001}== 10
#     should be true    ${PM_counter_value_M55139C01002}== 10
#     should be true    ${PM_counter_value_M55316C02000}>0
#     should be true    ${PM_counter_value_M55316C05001}== 10
#     should be true    ${PM_counter_value_M55316C05000}== 10
# 
# Wait for 1st counters
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
