# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    AP    owner_changyli
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD    CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# #${AP_SWCONFIG_NAME}    ap_swconfig.txt
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      8423_SCFC_CASE01.xml
# ${AIRPHONE_NAME}    iphy-AZHA_2cells.xml
# ${WTS_NAME}       TDD_CPRI_2cells.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${EGATE_TAG}    ADD
# 
# 
# *** Test Cases ***
# CB008423_B_Case01_A_5c_2CC_CA_blindaddtion_BufferActivation_deactivation
#     Prepare gnb onair
# 	#Online change to blind addition active
#     Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     SA Attach UE
#     Internal send DL data
#     Collect AP egate log    ${EGATE_TAG}
#     analyse scelladd in rrclog
#     Check throughput
# 	Stop data to trigger deactive
# 	Check Scell deactive
# 	resume data to trigger good threshold and scell resume
# 	Check Scell active
#     Stop data transfer
#     Detach UE
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# SA Attach UE
#     Set traffic type to internal
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
# 
# Verify throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>100000
#     should_be_true    ${dl_throughput_scell1}>0
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Stop data to trigger deactive
#     Airphone SA Stop Data Traffic     ${UE_ID}     dl    ${PDU_ID}
#     Wait until keyword succeeds    60s    15s    Verify Pcell throughput
#     Wait until keyword succeeds    60s    15s    Verify Scell throughput=0
# 
# Verify Pcell throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>100000
# 
# Verify Scell throughput=0
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_scell1}==0
# 	
# resume data to trigger good threshold and scell resume
#     Internal send DL data
# 	
# Check Scell RLQ deactive    
#     wait_for_message_in_syslog_file    ModifType:DEACTIVATE    timeout=300    alias=collect_gnb_1
#     wait_for_message_in_syslog_file    SCellIndex 1 deactivated successfully    timeout=300    alias=collect_ap_1
# 
# Check Scell deactive
#     wait_for_message_in_syslog_file    SCellIndex 1 deactivated successfully    timeout=300    alias=collect_ap
#     wait_for_message_in_syslog_file    ModifType:DEACTIVATE    timeout=300    alias=collect_gnb
# 
# Check Scell active
#     wait_for_message_in_syslog_file    SCellIndex 1 activated successfully    timeout=30    alias=collect_ap
#     Check throughput
# 
# Internal send DL data
#     Internal send mutiple trf '4' for each '175M' DL data
# 
# Detach UE
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Online change to blind addition active
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-2/NRCELL-1/NRREL-0    sCellAdditionMethod    blind    online
#     Wait '2s' for stabible
#     Perform online change value    MRBTS-1/NRBTS-2    actMeasBasedSCellAddition    false    online
#     Wait '2s' for stabible
#     Perform online change value    MRBTS-1/NRBTS-2    actMeasBasedSCellAdditionNsa    false    online
#     Wait '5s' for stabible
#     TAF_ADMIN.teardown admin    connection=online
