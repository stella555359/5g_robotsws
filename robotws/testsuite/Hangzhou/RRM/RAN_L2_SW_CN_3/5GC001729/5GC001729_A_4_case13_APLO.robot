# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown  Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags        CRT    SBTS00   SBTS23R2   RAN_5G_TDD    RAN_5G   owner_l3gao
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    2TDD_CA
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# Documentation
# ...     non-beamform 80mhz_80mhz 4DL2UL dlmimo_4X2 SA frame_1/4 radio_2symbol
# ...     actPdschAtSsbSlots_P_enable_S_false prach_97
# ...     peak downlink_1.g_1.g  uplink 120mbps
# ...     uldata push stop due to [Precheck][CB007922[SBTS00][LOAPLO]When send ul data the rank will drop to rank1
# ...     tti check shutdown due to NACK
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID1}          1
# ${UE_ID2}          2
# ${SCFC_NAME}     1729_CASE13_SCFC_APLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_2CELL_LO_AP_LO.xml
# ${WTS_NAME}      WTS_LO_AP_LO_SANSA_n78_8SA_32NSA_8DL4UL.cfg
# ${EGATE_TAG_1}      CA_before_block
# ${EGATE_TAG_2}      CA_after_block
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport
# 
# *** Test Cases ***
# 5GC001729_Case13_A_4e_Period_CSI_RS_Transmission_and_reception_onPucch_BF
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'attach_without_data' file
#     log to console    ...attach_without_data...
#     airphone_cleanup_egate_console_log
#     Attach SA UE    UE_ID=1     PDU_ID=1   SLICE_ID=1    GW_ID=1
#     Send ue '1' A1 event
#     Collect AP egate log    rrc_logs
#     Analyse scelladd in rrclog    rrc_logs     RRC_scelladd_LO_AP_LO_cell52.ini
#     Stop capture gnb and ap syslog in 'attach_without_data' file
#     Start capture gnb and ap syslog in 'attach_with_data' file
#     SA send dl and ul data    ${UE_ID1}    number=16    dl_data=175M    ul_data=35M    pdu_id=1
#     Check Scell active
#     Stop capture gnb and ap syslog in 'attach_with_data' file
#     Wait '20s' for stable
#     Start capture gnb and ap syslog in 'scell_add_with_data' file
#     Check throughput    ${UE_ID1}     Pcell_TP=1100000   Scell_TP=1100000
#     tti trace ACK check    scell_add_with_data_wtti
# #    Start collect bip log
# #    Wait for '1s' to stop bip log with name'scell_add_with_data_bip'
#     Stop capture gnb and ap syslog in 'scell_add_with_data' file
# 
#     Start capture gnb and ap syslog in 'scellrelease' file
#     log to console    ...scellrelease...
#     Wait '12s' for stable
#     UE send A2 event    ${UE_ID1}
#     Check Scell release    scell_release_egate_log
#     Wait '5s' for stable
#     tti trace ACK check    scell_release_tti
#     Check pcell throughput    ${UE_ID1}    Pcell_TP=1100000
# #    Start collect bip log
# #    Wait for '1s' to stop bip log with name'scell_release_bip'
#     UE send A1 event again     ${UE_ID1}
#     Check throughput    ${UE_ID1}     Pcell_TP=1100000   Scell_TP=1100000
#     Stop capture gnb and ap syslog in 'scellrelease' file
# 
#     Start capture gnb and ap syslog in 'bacdCondition_resume_data' file
#     log to console    ...bacdCondition_resume_data...
#     Override Scell CQI trigger bad threshold    ${UE_ID1}     Pcell_TP=1100000
#     Override Scell CQI trigger good threshold and scell resume    ${UE_ID1}    Pcell_TP=1100000   Scell_TP=1100000
#     Stop capture gnb and ap syslog in 'bacdCondition_resume_data' file
# 
#     Start capture gnb and ap syslog in 'resend_data' file
#     log to console    ...resend_data...
#     Stop data transfer    ${UE_ID1}
#     Wait '10s' for stable
#     SA send dl and ul data    ${UE_ID1}   number=16    dl_data=175M    ul_data=35M    pdu_id=1
#     Wait '20s' for stable
#     Check throughput    ${UE_ID1}     Pcell_TP=1100000   Scell_TP=1100000
#     tti trace ACK check    tti_log_check
#     Detach UE     ${UE_ID1}
#     Stop capture gnb and ap syslog in 'resend_data' file
# 
#     Start capture gnb and ap syslog in 'rank2_check' file
#     log to console    ...rank2_check...
#     airphone_cleanup_egate_console_log
#     Attach SA UE    UE_ID=1     PDU_ID=1   SLICE_ID=1    GW_ID=1
#     Send ue '1' A1 event
#     Collect AP egate log    rrc_logs
#     run keyword and continue on failure    Analyse scelladd in rrclog    rrc_logs     
#    ...    RRC_scelladd_LO_AP_LO_cell52.ini
#     SA send dl and ul data    ${UE_ID1}    number=16    dl_data=175M    ul_data=35M    pdu_id=1
#     run keyword and continue on failure    Check Scell active
#     rank2 peak check TP   ${UE_ID1}
#     Detach UE     ${UE_ID1}
#     Stop capture gnb and ap syslog in 'rank2_check' file
# 
# *** Keywords ***
# Attach SA UE
#     [Arguments]    ${UE_ID}=1     ${PDU_ID}=1    ${SLICE_ID}=1   ${GW_ID}=1
#     Airphone Setup X2 Connection
#     Airphone Set Traffic Type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override 
#    ...    action\=activate profile_id\=1 scell\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override 
#    ...    action\=activate profile_id\=1 scell\=1
#     Wait '5s' for stable
# 
# tti trace ACK check
#     [Arguments]     ${tti_tag}
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'${tti_tag}'
#     Check ttitrace    ${tti_tag}
# 
# Override Scell CQI trigger bad threshold
#     [Arguments]    ${UE_ID}    ${Pcell_TP}
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=1 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override 
#    ...    action\=activate profile_id\=2 scell\=1
#     Wait until keyword succeeds    60s    6s    Verify Pcell throughput    ${UE_ID}    ${Pcell_TP}
#     Wait until keyword succeeds    60s    6s    Verify Scell throughput=0    ${UE_ID}
# 
# Override Scell CQI trigger good threshold and scell resume
#     [Arguments]    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override 
#    ...    action\=activate profile_id\=1 scell\=1
#     Check throughput    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}
# 
# UE send A1 event again
#     [Arguments]    ${UE_ID}
#     airphone_execute_egate_command    ue_measurement_send_nr id\=${UE_ID} meas_id\=4 event\=A1 
#    ...    rs_type\=ssb srsrp_nr\=50
# 
# Check Scell deactive
#     wait_for_message_in_syslog_file    SCellIndex 1 deactivated successfully    timeout=300    alias=collect_ap
#     wait_for_message_in_syslog_file    ModifType:DEACTIVATE    timeout=300    alias=collect_gnb
# 
# UE send A2 event
#     [Arguments]    ${UE_ID}
#     airphone_execute_egate_command    ue_measurement_send_nr event\=A2 id\=${UE_ID} meas_id\=3 
#    ...    rs_type\=ssb scell\=1 scell_rsrp\=30
# 
# Override Scell CQI trigger good threshold and scell not resume
#     [Arguments]    ${UE_ID}    ${Pcell_TP}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override 
#    ...    action\=activate profile_id\=1 scell\=1
#     Wait until keyword succeeds    60s    6s    Verify Pcell throughput    ${UE_ID}    ${Pcell_TP}
#     Wait until keyword succeeds    60s    6s    Verify Scell throughput=0    ${UE_ID}
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
# Verify Scell throughput=0
#     [Arguments]    ${UE_ID}
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    
#    ...    scell_id=1    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_scell1}==0
# 
# Check Scell release
#     [Arguments]    ${scell_release_egate_log}
#     wait '5s ' to check log
#     airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/${scell_release_egate_log}/    unzip=TRUE
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scell_release.ini    u    
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${scell_release_egate_log}
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
# SA send dl and ul data_2
#     [Arguments]    ${ue_id}    ${number}=4    ${dl_data}=175M    ${ul_data}=20M    ${pdu_id}=1
#     SA send mutiple trf dl data    ${ue_id}    ${number}    ${dl_data}    ${pdu_id}
#     SA send mutiple trf ul data    ${ue_id}    ${number}    ${ul_data}    ${pdu_id}
# 
# Send ue '${ue_id}' A1 event
#     airphone_execute_egate_command    ue_measurement_send_nr id\=${ue_id} meas_id\=2 
#    ...    event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti
# 
# Stop data transfer
#     [Arguments]    ${UE_ID}
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}   pdu_id=${UE_ID}   direction=dl
# 
# Detach UE
#     [Arguments]    ${UE_ID}
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 
# Check Scell active
#     wait_for_message_in_syslog_file    SCellIndex 1 activated successfully    timeout=300    alias=collect_ap
# 
# rank2 peak check TP
#     [Arguments]    ${UE_ID}=1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 ri\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override 
#    ...    action\=activate profile_id\=3 scell\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override 
#    ...    action\=activate profile_id\=3 scell\=1
#     Wait '15s' for stable
#     Check throughput    ${UE_ID1}     Pcell_TP=500000   Scell_TP=500000
#     log to console  check rank2 peak TP
# 
# Check pcell throughput
#     [Arguments]    ${UE_ID}    ${Pcell_TP}
#     Wait until keyword succeeds    60s    6s    Verify Pcell throughput    ${UE_ID}    ${Pcell_TP}
# 
# Verify Pcell throughput
#    [Arguments]    ${UE_ID}    ${Pcell_TP}
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    
#    ...    scell_id=0    type=pdsch    tput_type=ave
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    
#    ...    scell_id=0    type=pusch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>${Pcell_TP}
#     log to console    result is Pcell_${dl_throughput_pcell}
#     log to console    target is Pcell_${Pcell_TP}
#     log to console    uplink tp is Pcell_${ul_throughput_pcell}
# 
# Check throughput
#     [Arguments]    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}
#     Wait until keyword succeeds    60s    6s    Verify throughput    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}
# 
# Verify throughput
#     [Arguments]    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    
#    ...    scell_id=0    type=pusch    tput_type=ave
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    
#    ...    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    
#    ...    scell_id=1    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>${Pcell_TP}
#     should_be_true    ${dl_throughput_scell1}>${Scell_TP}
#     log to console    result is Pcell_${dl_throughput_pcell} Scell_${dl_throughput_scell1}
#     log to console    target is Pcell_${Pcell_TP} Scell_${Scell_TP}
#     log to console    uplink tp is Pcell_${ul_throughput_pcell}
