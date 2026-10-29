# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags    owner_menzheng    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${GNB_SWCONFIG_NAME}    gnb_swconfig_LO.txt
# ${SCFC_NAME}      SCFC_22_MO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_2CELL.xml
# ${WTS_NAME}    WTS_1729_LO.cfg
# ${UE1_ID}          1
# ${UE2_ID}          2
# ${UE3_ID}          3
# ${UE4_ID}          4
# ${PDU_ID}         1
# ${SLICE_ID}       1
# ${hi}	5
# ${SYSLOG_TAG}     after_onair
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_1='true'    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'
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
# *** Test Cases ***
# 5GC001729_Case22_A_5d_2CC_CA_abil_A1daddition_BufferActivation
#     Prepare gnb onair
#     Start capture gnb and ap syslog in '${SYSLOG_TAG}' file
#     Wait for 1st counters
#     Multi UE SA Register
#     #Set sinr
#     SEND DL data to UE
#     Check UE throughput
#     Check counters
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti'
#     Check ttitrace
#     DeRegister UEs
#     Stop capture only gnb syslog in '${SYSLOG_TAG}' file
# 	
# *** Keywords ***
# 
# Set sinr
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 sinr_target_pucch\=-300
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-4 testmode\=ul_sinr action\=activate profile_id\=1 
# 
# Multi UE SA Register
#     : FOR    ${num}    IN RANGE    1    ${hi}
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${num} ------
#     \   Airphone SA Attach    ue_id=${num}
#     \   Airphone Set Traffic Type    ${num}    1    internal
#     \   Airphone Pdu Session Setup    ${num}    1    1    ${num}
#     \   UE '${num}' send A1 event	
#     \   Wait '3s' for stabible
#     \   check UE '${num}' scelladd in RRC log
# 
# check UE '${ue_id}' scelladd in RRC log
#     Log To Console   check UE ${ue_id} scelladd in RRC log
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
#     run keyword if    ${ue_id}<3   run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_scelladd_LO.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
#     run keyword if    ${ue_id}>2   run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_scelladd_fail.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
# 
# UE '${ue_id}' send A1 event
#     Log To Console   UE '${ue_id}' send A1 event
#     run keyword if    ${ue_id}==1   run keyword and continue on failure    UE 1 send A1 event
#     run keyword if    ${ue_id}==2   run keyword and continue on failure    UE 2 send A1 event
#     run keyword if    ${ue_id}==3   run keyword and continue on failure    UE 3 send A1 event
#     run keyword if    ${ue_id}==4   run keyword and continue on failure    UE 4 send A1 event
# 
# UE 1 send A1 event
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
# 	
# UE 2 send A1 event	
#     airphone_execute_egate_command    ue_measurement_send_nr id\=2 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
# 	
# UE 3 send A1 event
#     airphone_execute_egate_command    ue_measurement_send_nr id\=3 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
# 	
# UE 4 send A1 event	
#     airphone_execute_egate_command    ue_measurement_send_nr id\=4 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50	
# 
# Check UE throughput
#      Wait '30s' for stabible
#      ${ue1_tp_pcell}=    airphone_get_throughput_on_specific_scell    1    0    type=pdsch    tput_type=ave
#      ${ue1_tp_scell}=    airphone_get_throughput_on_specific_scell    1    1    type=pdsch    tput_type=ave
#      ${ue2_tp_pcell}=    airphone_get_throughput_on_specific_scell    2    0    type=pdsch    tput_type=ave
#      ${ue2_tp_scell}=    airphone_get_throughput_on_specific_scell    2    1    type=pdsch    tput_type=ave
#      ${ue3_tp}=    airphone_get_throughput_on_specific_scell    3    0    type=pdsch    tput_type=ave
#      ${ue4_tp}=    airphone_get_throughput_on_specific_scell    4    0    type=pdsch    tput_type=ave
#      should be true    ${ue1_tp_pcell}>200000
#      should be true    ${ue1_tp_scell}>400000
#      should be true    ${ue2_tp_pcell}>200000
#      should be true    ${ue2_tp_scell}>400000
#      should be true    ${ue3_tp}>300000
#      should be true    ${ue4_tp}>300000
# 
# SEND DL data to UE
#     : FOR    ${ue_id}    IN RANGE    1    5
# 	\   SEND data to '${ue_id}'
# 	
# SEND data to '${ue_id}'
#     SA send mutiple trf dl data    ${ue_id}    5    175M    ${pdu_id}
# 
# DeRegister UEs
#     : FOR    ${num}    IN RANGE    1    ${hi}
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '4s' for stabible
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# Check counters
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
# 	${PM_counter_value_M55138C01501}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55138C01501    cell_id=1
# 	${PM_counter_value_M55138C01502}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55138C01502    cell_id=1
# 	${PM_counter_value_M55138C01503}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55138C01503    cell_id=1
# 	${result}=    evaluate    ${PM_counter_value_M55138C01502}+${PM_counter_value_M55138C01503}
# 	should be true     ${result} == ${PM_counter_value_M55138C01501}
# 	should be true     ${PM_counter_value_M55138C01501} > 0
# 	should be true     ${PM_counter_value_M55138C01502} > 0
# 	should be true     ${PM_counter_value_M55138C01503} > 0	
# 	
# Wait for 1st counters
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
