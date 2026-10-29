# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown   # Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown    # Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD   CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_ningyang     SBTS22R4    SBTS23R1
# ...               AP
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_16_ABIO.xml
# ${AIRPHONE_NAME}    IPHY_AEQN_AEHC_2CELL_ABIO.xml
# ${WTS_NAME}       SANSA7922_interband_ho_10ue_ABIO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${UE_ID}          11
# ${UE_ID_2}        12
# ${EGATE_TAG}      ADD
# ${UE_TOTALNUM}    10
# ${UE_NUM}         15
# ${STABLETIME}     1s
# ${RI}            csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=1 
# *** Test Cases ***
# CB007922_case16_A_6c_intraL2RT_intraBand_Multiple_UE_DL_UL_data_scheduling_NSA_SSBBF_and_A1_Scell_addition
#     Prepare gnb onair
# 	#Start WTS And Wait BTS Until Onair   ${WTS_NAME}  reload=${False}
#     Start capture gnb and ap syslog in 'after_onair' file
#     Execute AP Command before attach
#     Attach LTE CAUE
#     NSA send data
#     Collect AP egate log    ${EGATE_TAG}
#     Check throughput
#     run keyword and continue on failure    Start collect ttitrace
#     run keyword and continue on failure    Wait for '2s' to stop ttitrace with name'tti'
#     run keyword and continue on failure    Check ttitrace
#     Airphone NSA Stop Data Traffic And Detach UE
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Set '${uenum}' RI
#     airphone_execute_egate_command    ${RI}
# 	: FOR    ${num}    IN RANGE    1    ${uenum}+1
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=1 scell\=8-9
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify CAUE throughput
# Attach LTE CAUE
#     : FOR    ${num}    IN RANGE    11    21
#     \    Airphone Nsa Attach    ${num}
#     \    Wait time to stable
#     \    airphone_execute_egate_command    ue_measurement_send_nr id\=${num} meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=50	
# 	
# Attach LTE NCAUE
#     : FOR    ${num}    IN RANGE    16    ${UE_NUM}+6
#     \    Wait time to stable	
#     \    Airphone Nsa Attach    ${num}
# 
# NSA send data
#     : FOR    ${num}    IN RANGE    11    21
#     \    NSA send ue '${num}' mutiple trf '1' for each '175M' DL data	
#   	\    NSA send 2rd ue '${num}' mutiple trf '2' for each '25M' DL data	
#     \    NSA send ue '${num}' mutiple trf '1' for each '1M' UL data	
# Airphone NSA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    11    ${UE_NUM}+6
#     \    Airphone NSA Stop Data Traffic   ${num}    DL
#     \    Airphone NSA Detach    ${num}
# 	
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Verify CAUE throughput
#     : FOR    ${num}    IN RANGE    11    ${UE_NUM}+6
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
#     \    ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=9    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}+${dl_throughput_scell1}>100000
# 	
# Verify NCAUE throughput
#     : FOR    ${num}    IN RANGE    16    ${UE_NUM}+5
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>50000
# 	
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd_NSA_1.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# NSA send ue '${ue_id}' mutiple trf '${number}' for each '${ul_data}' UL data
#     : FOR    ${num}    IN RANGE    1    ${number}+1
#     \    Airphone NSA Start Data Traffic    ${ue_id}    UL    ${ul_data}    duration=6000s    trf_id=${num}
# NSA send ue '${ue_id}' mutiple trf '${number}' for each '${dl_data}' DL data
#     : FOR    ${num}    IN RANGE    1    ${number}+1
#     \    Airphone NSA Start Data Traffic    ${ue_id}    DL    ${dl_data}    duration=6000s    trf_id=${num}
#     Wait Throughput Timer    1s
# NSA send 2rd ue '${ue_id}' mutiple trf '${number}' for each '${dl_data}' DL data
#     : FOR    ${num}    IN RANGE    2    ${number}+1
#     \    Airphone NSA Start Data Traffic    ${ue_id}    DL    ${dl_data}    duration=6000s    trf_id=${num}
#     Wait Throughput Timer    1s
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Online change dlMimoMode
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-2/NRCELL-1    dlMimoMode    4x4 or 4x2 Closed Loop Spatial Multiplexing   online
#     Perform online change value    MRBTS-1/NRBTS-2/NRCELL-2    dlMimoMode    4x4 or 4x2 Closed Loop Spatial Multiplexing   online	
#     Wait '2s' for stabible
#     TAF_ADMIN.teardown admin    connection=online
# Wait time to stable
#     sleep    ${STABLETIME}	
# 	
