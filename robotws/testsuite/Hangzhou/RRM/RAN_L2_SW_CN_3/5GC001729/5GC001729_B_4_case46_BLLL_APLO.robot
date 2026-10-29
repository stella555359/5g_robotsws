# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_changyli    AP    SBTS23R1
# ...   CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# #${GNB_SWCONFIG_NAME}    gnb_swconfig.txt
# #${AP_SWCONFIG_NAME}    ap_swconfig.txt
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      SCFC_case46_BLLL_AP_LO.xml
# ${AIRPHONE_NAME}    IPHY_2AEQE_CASE20_LO.xml
# ${WTS_NAME}       WTS_2AEQE_CASE20_LO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${EGATE_TAG}    ADD
# ${B_S}     beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=5,0,1,2,3,4 ssbeam_bestbeam\=0 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-50
# 
# *** Test Cases ***
# 5GC001729_Case_46_B_4a_2CC_CA_Single_CAUE_blindadd_bufferactive_Data_transfermation_with_DRX_SA
#     Enable RD syslog in AP Swconfig
#     Add counter timer in gnb Swconfig
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'case46' file
#     airphone_cleanup_egate_console_log
#     Set traffic type to internal
# 	Set SSB Beam
# #    Attach ue with '2x2_2cc'capability to 5g cell
#     Set traffic type to internal
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     Internal send DL data
#     Collect AP egate log    ${EGATE_TAG}
#     analyse scelladd in rrclog
# 	Check Scell active
#     Check throughput
#     Stop data transfer
#     Check DRX Active Sleep
# 	Internal send DL data	
#     Check throughput
#     Collect AP egate log    ${EGATE_TAG}	
#     Detach UE
#     Stop capture gnb and ap syslog in 'case46' file
# 
# *** Keywords ***
# Set SSB Beam
#     airphone_execute_egate_command    ${B_S}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach
# 	
# Wait time to check throughput
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait '${remaining_time}s' for stabible
# 	
# Wait time to check DRX
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait '${remaining_time}s' for stabible
# 	Wait '70s' for stabible
# 
# Add counter timer in gnb Swconfig
#         Add GNB swconfig    0x340000:15
# 
# Enable RD syslog in AP Swconfig
#         Modify AP swconfig    0x10041:1
# 	
# Override Scell CQI trigger bad threshold
#     Airphone Cqi Param    nr_cqi=5
#     Check Pcell throughput
#     Wait time to check throughput
#     Check PM counter scell no throughput
# 	
# Override Scell CQI trigger morebad threshold
#     Airphone Cqi Param
#     Check PM counter scell no throughput
# 	
# Override Scell CQI trigger good threshold and scell resume
#     Airphone Cqi Param    nr_cqi=15
#     Check Pcell throughput
#     Wait time to check throughput
#     Check PM counter scell have throughput
# 
# Check PM counter scell no throughput
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${CURDIR}${/}
#     ${PM_counter_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55310C01006    cell_id=2
#     run keyword if    ${PM_counter_value}>0    Check PM counter scell no throughput again
# 
# Check Scell deactive
#     wait_for_message_in_syslog_file    SCellIndex 1 deactivated successfully    timeout=300    alias=collect_ap
#     wait_for_message_in_syslog_file    ModifType:DEACTIVATE    timeout=300    alias=collect_gnb
# 
# Check Scell active
#     wait_for_message_in_syslog_file    SCellIndex 1 activated successfully    timeout=30    alias=collect_ap
# 
# Override Scell CQI trigger good threshold and scell not resume
#     Airphone Cqi Param    nr_cqi=15
#     Check Pcell throughput
#     Wait time to check throughput
#     Check PM counter scell no throughput
# 	
# Check Pcell DRX counter
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${CURDIR}${/}
#     ${PM_counter_pact}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11001    cell_id=1
#     ${PM_counter_psleep}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11002    cell_id=1
#     ${value}    Evaluate    float(${PM_counter_psleep})/float(${PM_counter_pact})
#     should be true    ${value}>14.97
#     should be true    ${value}<15.03
# 	
# Check Scell DRX counter
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${CURDIR}${/}
#     ${PM_counter_pact}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11001    cell_id=2
#     ${PM_counter_psleep}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11002    cell_id=2
#     ${value}    Evaluate    float(${PM_counter_psleep})/float(${PM_counter_pact})
#     should be true    ${value}>14.97
#     should be true    ${value}<15.03	
# 	
# Check PM counter scell have throughput
#      Wait until keyword succeeds    200s    20s   Check pm counter M55310C01006 in cell 2 is expected > 0
# 
# Internal send DL data
#     Internal send mutiple trf '4' for each '175M' DL data
# 
# Check Pcell throughput
#     ${sa_dl_tput}=    Airphone SA Get Throughput    ${UE_ID}    DL    ${PDU_ID}
#     run keyword and continue on failure    Should be true    ${sa_dl_tput}>100000
# 
# Check throughput
#     Airphone Cqi Param    scell_id=0-1    nr_cqi=15
#     Check PM counter scell have throughput
#     Wait until keyword succeeds    60s    15s    Check Pcell throughput
# 	
# Check DRX Active Sleep
#     Wait time to check DRX
#     Check Pcell DRX counter 
# 	Check Scell DRX counter 
# 	
# Check PM counter scell no throughput again
#     Wait '60s' for stabible
#     Check pm counter M55310C01006 in cell 2 is expected == 0
# 
# Stop data transfer
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}    direction=dl
# 
# Detach UE
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
