# *** Settings ***
# Suite Setup       AiC Common Suite Setup
# Suite Teardown    AiC Common Suite Teardown
# Test Setup        AiC Common Test Setup
# Test Teardown     AiC Common Test Teardown
# Force Tags        CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH    SBTS00
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${DU_SCF}        SCFC_VDU_CNI70851_case2.xml
# ${CU_SCF}        SCFC_VCU_CNI70851_case2.xml
# ${AIRPHONE_NAME}    iphy_2aeqe_case2.xml
# ${WTS_CFG}       basic_cni70851.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog
# ${EGATE_TAG}    ADD
# ${CSI_CMD1}    csi_override_testmode_nr profile_id\=2 cqi\=15 ri_mode\=fixed ri\=1
#                ...     pmi_mode\=fixed pmi\=124 cri_mode\=fixed cri\=0 li_mode\=fixed li\=1
# ${CSI_CMD2}   ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2
# ${UE1_A1_EVENT}    ue_measurement_send_nr id\=1 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
# @{Rdparameter}    0x10041:5
# *** Test Cases ***
# CNI70851_case02_interL2RT_SA_5GC002200_DRX_VONR_APLO
#     #Modify Swconfig for AP
#     AIC Perform Full Commission And Reach Onair    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${DU_SCF}
# 	...    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/WTS/${WTS_CFG}     ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${CU_SCF}
#     airphone_cleanup_egate_console_log
#     Set traffic type to internal
#     Override CSI For UE
#     Attach SA UE
#     UE SEND A1 EVENT
#     Internal send mutiple trf '12' for each '175M' DL data
#     Add 5Q5 PDU Session
#     Add 5Q1 PDU Session
#     Wait '20s' for stabible
#     ${id}    VDU Start TTiTrace Log
#     Wait '5s' for stable
#     VDU Stop TTiTrace Log    ${id}
#     VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}/All/tti1/
#     Check throughput
#     Check 5QI1 counter
#     Release VONR
#     Check throughput
#     Check 5QI1 counter release
#     Stop data transfer
#     Collect AP egate log    ${EGATE_TAG}
#     Detach UE
# 
# *** Keywords ***
# Modify Swconfig for AP
#     Modify AP swconfig    @{Rdparameter}
# Attach SA UE
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     Wait '5s' for stabible
# Override CSI For UE
#     airphone_execute_egate_command    ${CSI_CMD1}
#     airphone_execute_egate_command    ${CSI_CMD2}
# UE SEND A1 EVENT
#     airphone_execute_egate_command    ${UE1_A1_EVENT}
#     Wait '5s' for stabible
# Release VONR
#     Airphone Pdu Session Modify    qosflows_to_del=3
# 	Wait '5s' for stabible
# Start DL data on QFI1
# 
# Add 5Q5 PDU Session
#     Airphone Pdu Session Modify    qosflows_to_add=2    by=amf
#     Wait '2s' for stabible
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=2 trf_id\=1 mbps\=5 dir\=dl protocol\=tcp
#     Wait '2s' for stabible
# 
# Add 5Q1 PDU Session
#     Airphone Pdu Session Modify    qosflows_to_add=3    by=amf
#     Wait '5s' for stabible
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=1 mbps\=5 dir\=dl
#     Wait '5s' for stabible
# Wait time to check throughput
#     ${remaining_time}    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait '${remaining_time}s' for stabible
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
# 
# Check Pcell throughput
#     ${sa_dl_tput}=    Airphone SA Get Throughput    ${UE_ID}    DL    ${PDU_ID}
#     run keyword and continue on failure    Should be true    ${sa_dl_tput}>0
# 	
# Check 5QI1 counter release
#     run keyword and continue on failure    Wait Until Keyword Succeeds    900s    30s   Check 5QI1 counter value0
#     	
# 	
# Check 5QI1 counter
#     run keyword and continue on failure    Wait Until Keyword Succeeds    900s    30s   Check 5QI1 counter value
#     
# 	
# Check throughput
#      Wait '10s' for stabible
#      ${pcell_tp}=    airphone_get_throughput_on_specific_scell    1    0    type=pdsch    tput_type=ave
#      ${scell_tp}=    airphone_get_throughput_on_specific_scell    1    1    type=pdsch    tput_type=ave
#      #should be true    ${pcell_tp}>750000
#      #should be true    ${scell_tp}>750000
# 
# Stop data transfer
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}    direction=dl
# 
# Detach UE
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_csi.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
