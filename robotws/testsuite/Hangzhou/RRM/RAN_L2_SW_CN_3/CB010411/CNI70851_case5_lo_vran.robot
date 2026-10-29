# *** Settings ***
# Test Timeout      60 minutes
# Suite Setup       AiC Common Suite Setup
# Suite Teardown    #AiC Common Suite Teardown
# Test Setup        AiC Common Test Setup
# Test Teardown     AiC Common Test Teardown
# Force Tags        CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH    SBTS00
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# 
# ${UE_ID}          1
# ${UE_ID2}          2
# ${PDU_ID}         1
# ${PDU_ID2}         2
# ${GW_ID}          1
# ${GW_ID2}          1
# ${SLICE_ID}       1
# ${DU_SCF}        CNI70851_case5_SCFC_VDU.xml
# ${CU_SCF}        CNI70851_case5_SCFC_VCU.xml
# 
# ${AIRPHONE_NAME}    iphy_2aeqe_case2.xml
# ${WTS_CFG}       basic_cni70851_case5.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# 
# ${EGATE_TAG}      ADD
# ${DRX_TAG}      DRX
# ${DRXV_TAG}      DRXV
# ${UE_TOTALNUM}    10
# ${UE_NUM}         10
# ${CAUE_NUM}       2
# ${STABLETIME}     10s
# ${PMI}            csi_override_testmode_nr profile_id\=2 cqi\=15 ri_mode\=fixed ri\=1 pmi_mode\=fixed
#                   ...     pmi\=13 cri_mode\=fixed cri\=0 li_mode\=fixed li\=1
# 
# *** Test Cases ***
# CNI70851_case05_interL2RT_SA_5GC002200_multiUE_DRX_VRAN
#     #Modify counter Swconfig
#     AIC Perform Full Commission And Reach Onair    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${DU_SCF}
# 	...    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/WTS/${WTS_CFG}     ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${CU_SCF}
#     airphone_cleanup_egate_console_log
#     Set multiue traffic type to internal
#     	Set '2' PMI
#     Attach '2' ue to 5g cell
#     Collect AP egate log    ${DRX_TAG}
#     run keyword and continue on failure     Analyse drx setup in rrclog
# 	Internal send 5QI8 DL data
#     Internal send ue2 5QI8 DL data
#     Add 5Q5 PDU Session
#     Add 5Q1 PDU Session
#     Collect AP egate log    ${DRXV_TAG}
#     run keyword and continue on failure     Analyse drxv setup in rrclog
#     #Set '2' PMI
#     Verify CAUE throughput
#     Check 5QI1 counter
#     #run keyword and continue on failure     Check 5QI1 tti
#     Release VONR
#     Verify CAUE throughput
#     Check 5QI1 counter release
#     ${tti}     VDU Start TTiTrace Log
#     Wait '5s' for stabible
#   	VDU Stop TTiTrace Log    ${tti} 
#     VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}/All/tti/
#     run keyword and continue on failure    Check ttitrace
#     Collect AP egate log    ${EGATE_TAG}
#     #Stop capture gnb and ap syslog in 'after_onair' file
#     Stop data transfer
#     Detach '2' UE
#     Collet VDU and VCU syslog
# *** Keywords ***
# Set '${uenum}' PMI
#     airphone_execute_egate_command    ${PMI}
# 	: FOR    ${num}    IN RANGE    1    ${uenum}+1
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=2
# 	
# Attach '${uenum}' ue to 5g cell
#     : FOR    ${num}    IN RANGE    1    ${uenum}+1
#     \    Airphone SA Attach    ue_id=${num}
#     \    Wait '2s' for stabible
#     \    Airphone Pdu Session Setup    ${num}    ${num}    ${SLICE_ID}    ${num}
#     \    Wait '3s' for stabible
# 
# Verify CAUE throughput
#     : FOR    ${num}    IN RANGE    1    ${CAUE_NUM}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=1    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}+${dl_throughput_scell1}>700000
#   
# Verify NCAUE throughput
#     : FOR    ${num}    IN RANGE    6    ${UE_NUM}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>20000
# 
# Check throughputnew
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Set multiue traffic type to internal
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone Set Traffic Type    ${num}    ${num}    internal
# 
# Release VONR
#     airphone_execute_egate_command    ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_del\=3
#     Wait '40s' for stabible
# 
# Add 5Q5 PDU Session
#     airphone_execute_egate_command    ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_add\=2 by\=amf
#     Wait '2s' for stabible
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=2 trf_id\=1 mbps\=5 dir\=dl protocol\=tcp
#     Wait '2s' for stabible
# 
# Add 5Q1 PDU Session
#     airphone_execute_egate_command    ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_add\=3 by\=amf
#     Wait '5s' for stabible
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=1 mbps\=5 dir\=dl
#     Wait '5s' for stabible
# 
# Wait time to check throughput
#     Wait '600s' for stabible
# 
# Check Scell active
#     wait_for_message_in_syslog_file    SCellIndex 1 activated successfully    timeout=30    alias=collect_ap
# 
# Check 5QI1 counter value
#     ${PM_counter_value_Pcell}     AIC Get Counter Values      M55308C23002    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     ${PM_counter_value_Scell}     AIC Get Counter Values      M55308C23002    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-2
#     should be true    ${PM_counter_value_Pcell}>0
#     should be true    ${PM_counter_value_Scell}==0
# 
# Check 5QI1 counter value0
#     ${PM_counter_value_Pcell}     AIC Get Counter Values      M55308C23002    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     ${PM_counter_value_Scell}     AIC Get Counter Values      M55308C23002    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-2
#     should be true    ${PM_counter_value_Pcell}==0
#     should be true    ${PM_counter_value_Scell}==0
# 
# Internal send 5QI8 DL data
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=1 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=2 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=3 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=4 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=5 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=6 mbps\=175 dir\=dl
# Internal send ue2 5QI8 DL data
#     airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 qfi\=1 trf_id\=7 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 qfi\=1 trf_id\=8 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 qfi\=1 trf_id\=9 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 qfi\=1 trf_id\=10 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 qfi\=1 trf_id\=11 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 qfi\=1 trf_id\=12 mbps\=175 dir\=dl	
#     Wait time to stable
# 
# Internal send DL data
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone SA Start Data Traffic    ${num}    DL    175M    pdu_id=${num}    duration=6000s
#     \    ...    trf_id=${num}
#     \    Wait time to stable
# 
# Check Pcell throughput
#     ${sa_dl_tput}=    Airphone SA Get Throughput    ${UE_ID}    DL    ${PDU_ID}
#     run keyword and continue on failure    Should be true    ${sa_dl_tput}>0
# 
# Check 5QI1 counter release
#     run keyword and continue on failure    Wait Until Keyword Succeeds    600s    30s   Check 5QI1 counter value0
# 
# 
# Check 5QI1 counter
#     run keyword and continue on failure    Wait Until Keyword Succeeds    600s    30s   Check 5QI1 counter value
# 
# Check 5QI1 tti
#     ${tti5QI1}     VDU Start TTiTrace Log
#     Wait '5s' for stabible
#   	VDU Stop TTiTrace Log    ${tti5QI1} 
#     VDU Decode TTiTrace Log     csv_dir=${TEST_LOG_DIRECTORY()}/All/tti
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_5QI1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/tti/
# Check throughput
#     Wait time to check throughput
#     Wait '60s' for stabible
#     Check Pcell throughput
#     Check PM counter scell have throughput
# 
# Stop data transfer
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}    direction=dl
# 
# Detach UE
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 
# analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Wait time to stable
#     sleep    ${STABLETIME}
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_pmi_lo.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# Modify counter Swconfig
# 	Add GNB swconfig    0x340000:15  
#     Modify GNB swconfig	   0x340000:15	
# Analyse drx setup in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/drx.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${DRX_TAG}_egate	
# 	
# Analyse drxv setup in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/drxv.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${DRXV_TAG}_egate		
