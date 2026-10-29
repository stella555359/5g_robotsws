# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown  Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags        CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G   owner_l3gao
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    2TDD_CA
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# Documentation    beamform_beamset6 8mhz_80mhz refinebeam_false 8DL4UL dlmimo_8X4 SA frame_1208_2symbol_4DL2UL
# ...     actPdschAtSsbSlots_P_enable_S_disable prach_98
# ...     peak downlink_112_102  uplink 114
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID1}          1
# ${UE_ID2}          2
# ${SCFC_NAME}     7922_CASE12_SCFC_APLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_2CELL_LO_AP_LO.xml
# ${WTS_NAME}      WTS_LO_AP_LO_SANSA_n78_8SA_32NSA_2Cell.cfg
# #@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog    sosreport
# @{LOG_NAME_LIST}    gnb_snapshot
# 
# *** Test Cases ***
# CB007922_case12_A_5b_interL2RT_intraBand_SA_Single_UE_DL_UL_data_scheduling_with_5GC002200
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'attach_without_data' file
#     airphone_cleanup_egate_console_log
#     Start collect bip log
#     Attach SA UE    UE_ID=1     PDU_ID=1   SLICE_ID=1    GW_ID=1
#     Wait for '2s' to stop bip log with name'attach_without_data_bip'
#     Collect AP egate log    rrc_logs
#     run keyword and continue on failure    Analyse scelladd in rrclog    rrc_logs     RRC_scelladd_and_2200_APLO_cell12.ini
#     Stop capture gnb and ap syslog in 'attach_without_data' file
#     Start capture gnb and ap syslog in 'attach_with_data' file
#     SA send dl and ul data    ${UE_ID1}    number=16    dl_data=175M    ul_data=35M    pdu_id=1
#     run keyword and continue on failure    Check Scell active
#     Stop capture gnb and ap syslog in 'attach_with_data' file
#     Start collect bip log
#     Wait for '2s' to stop bip log with name'fullbuffer_bip'
#     Wait '20s' for stable
#     Start capture gnb and ap syslog in 'fullbuffer' file
#     run keyword and continue on failure     Check throughput    ${UE_ID1}     Pcell_TP=1000000   Scell_TP=1000000
#     run keyword and continue on failure     tti trace ACK check    tti_log_check
#     Stop capture gnb and ap syslog in 'fullbuffer' file
#     Start capture gnb and ap syslog in 'bacdCondition_resume_data' file
#     run keyword and continue on failure     Override Scell CQI trigger bad threshold    ${UE_ID1}     Pcell_TP=1000000
#     Override Scell CQI trigger good threshold and scell resume    ${UE_ID1}    Pcell_TP=1000000   Scell_TP=1000000
#     Stop capture gnb and ap syslog in 'bacdCondition_resume_data' file
#     Start capture gnb and ap syslog in 'resend_data' file
#     Stop data transfer    ${UE_ID1}
#     run keyword and continue on failure    Check Scell deactive
#     SA send dl and ul data    ${UE_ID1}   number=16    dl_data=175M    ul_data=35M    pdu_id=1
#     run keyword and continue on failure    Check Scell active
#     Wait '20s' for stable
#     run keyword and continue on failure    Check throughput    ${UE_ID1}     Pcell_TP=1000000   Scell_TP=1000000
#     tti trace ACK check    tti_log_check
#     Stop capture gnb and ap syslog in 'resend_data' file
#     Start capture gnb and ap syslog in 'rank2_check' file
#     Override Scell CQI trigger bad threshold    ${UE_ID1}     Pcell_TP=1000000
#     Check Scell deactive
#     Override Scell CQI trigger good threshold and scell not resume   ${UE_ID1}   Pcell_TP=1000000
#     Stop data transfer    ${UE_ID1}
#     Detach UE     ${UE_ID1}
#     airphone_cleanup_egate_console_log
#     Attach SA UE    UE_ID=1     PDU_ID=1   SLICE_ID=1    GW_ID=1
#     Collect AP egate log    rrc_logs
#     run keyword and continue on failure    Analyse scelladd in rrclog    rrc_logs     RRC_scelladd_and_2200_APLO_cell12.ini
#     SA send dl and ul data    ${UE_ID1}    number=16    dl_data=175M    ul_data=35M    pdu_id=1
#     run keyword and continue on failure    Check Scell active
#     rank2 peak check TP   ${UE_ID1}
#     Detach UE     ${UE_ID1}
#     Stop capture gnb and ap syslog in 'rank2_check' file
# 
# 
# 
# *** Keywords ***
# rank2 peak check TP
#     [Arguments]    ${UE_ID}=1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 ri\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=3 scell\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=3 scell\=1
#     Wait '15s' for stable
#     Check throughput    ${UE_ID1}     Pcell_TP=500000   Scell_TP=500000
# 
# Attach SA UE
#     [Arguments]    ${UE_ID}=1     ${PDU_ID}=1    ${SLICE_ID}=1   ${GW_ID}=1
#     Airphone Setup X2 Connection
#     Airphone Set Traffic Type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=1
#     Wait '5s' for stable
# 
# Verify throughput
#     [Arguments]    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    
#    ...    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    
#    ...    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>${Pcell_TP}
#     should_be_true    ${dl_throughput_scell1}>${Scell_TP}
# 
# tti trace ACK check
#     [Arguments]     ${tti_tag}
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'${tti_tag}'
#     Check ttitrace    ${tti_tag}
# 
# Override Scell CQI trigger bad threshold
#     [Arguments]    ${UE_ID}    ${Pcell_TP}
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=1 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=2 scell\=1
#     Wait until keyword succeeds    60s    6s    Verify Pcell throughput    ${UE_ID}    ${Pcell_TP}
#     Wait until keyword succeeds    60s    6s    Verify Scell throughput=0    ${UE_ID}
# 
# Override Scell CQI trigger good threshold and scell resume
#     [Arguments]    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=1
#     Check throughput    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}
# 
# UE send A1 event again
#     [Arguments]    ${UE_ID}
#     airphone_execute_egate_command    ue_measurement_send_nr id\=${UE_ID} meas_id\=4 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# Check Scell deactive
#     wait_for_message_in_syslog_file    SCellIndex 1 deactivated successfully    timeout=300    alias=collect_ap
#     wait_for_message_in_syslog_file    ModifType:DEACTIVATE    timeout=300    alias=collect_gnb
# 
# Check Scell active
#     wait_for_message_in_syslog_file    SCellIndex 1 activated successfully    timeout=300    alias=collect_ap
# 
# UE send A2 event
#     [Arguments]    ${UE_ID}
#     airphone_execute_egate_command    ue_measurement_send_nr event\=A2 id\=${UE_ID} meas_id\=3 rs_type\=ssb scell\=1 scell_rsrp\=30
# 
# Override Scell CQI trigger good threshold and scell not resume
#     [Arguments]    ${UE_ID}    ${Pcell_TP}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=1
#     Wait until keyword succeeds    60s    6s    Verify Pcell throughput    ${UE_ID}    ${Pcell_TP}
#     Wait until keyword succeeds    60s    6s    Verify Scell throughput=0    ${UE_ID}
# 
# Check throughput
#     [Arguments]    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}
#     Wait until keyword succeeds    60s    6s    Verify throughput    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}
# 
# Analyse scelladd in rrclog
#     [Arguments]    ${EGATE_TAG}    ${ini}
#     check_log_with_au2anlysis    ${CURDIR}/ini/${ini}    p
#     ...  save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Analyse non CA in rrclog
#     [Arguments]    ${EGATE_TAG}    ${ini}
#     check_log_with_au2anlysis    ${CURDIR}/ini/${ini}    p
#     ...  save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Wait '${time} ' to check log
#     sleep    ${time}
# 
# 
# Verify Pcell throughput
#    [Arguments]    ${UE_ID}    ${Pcell_TP}
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    
#    ...    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>${Pcell_TP}
# 
# Verify Scell throughput=0
#     [Arguments]    ${UE_ID}
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    
#    ...    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_scell1}==0
# 
# Check Scell release
#     [Arguments]    ${scell_release_egate_log}
#     wait '5s ' to check log
#     airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/${scell_release_egate_log}/    unzip=TRUE
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scell_release.ini    u    
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${scell_release_egate_log}
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti
# 
# Check ttitrace
#     [Arguments]    ${tti_file}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/
# 
# SA send dl and ul data
#     [Arguments]    ${ue_id}    ${number}=4    ${dl_data}=175M    ${ul_data}=20M    ${pdu_id}=1
#     SA send mutiple trf dl data    ${ue_id}    ${number}    ${dl_data}    ${pdu_id}
#     SA send mutiple trf ul data    ${ue_id}    ${number}    ${ul_data}    ${pdu_id}
# 
# Send ue '${ue_id}' A1 event
#     airphone_execute_egate_command    ue_measurement_send_nr id\=${ue_id} meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# 
# 
# Stop data transfer
#     [Arguments]    ${UE_ID}
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}   pdu_id=${UE_ID}   direction=dl
# #    airphone_sa_stop_data_traffic    ue_id=${UE_ID}   pdu_id=${UE_ID}   direction=ul
# 
# Detach UE
#     [Arguments]    ${UE_ID}
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
