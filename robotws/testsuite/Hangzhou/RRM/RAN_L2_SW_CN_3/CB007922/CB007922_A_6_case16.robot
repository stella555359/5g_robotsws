# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS22R1    owner_ningyang    SBTS22R2    SBTS22R4    SBTS23R1
# ...   CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# ...               AP
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_16_counter.xml
# ${AIRPHONE_NAME}    IPHY_AEQN_AEHC_4CELL.xml
# ${WTS_NAME}       SANSA7922_interband_muliue.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${UE_ID}          11
# ${UE_ID_2}        12
# ${UE_ID3}          13
# ${UE_ID4}          14
# ${EGATE_TAG}      ADD
# 
# *** Test Cases ***
# CB007922_case16_A_6c_intraL2RT_intraBand_Multiple_UE_DL_UL_data_scheduling_NSA_SSBBF_and_A1_Scell_addition
#     Enable RD syslog in AP Swconfig
# 	Modify counter Swconfig
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Execute AP Command before attach
#     Attach LTE UE1
#     Attach LTE UE2
# 	Attach LTE UE3
# 	Attach LTE UE4
#     NSA send ue '${UE_ID}' mutiple trf '3' for each '175M' DL data
#     NSA send ue '${UE_ID_2}' mutiple trf '3' for each '175M' DL data
#     NSA send ue '${UE_ID}' mutiple trf '1' for each '50M' UL data
#     NSA send ue '${UE_ID_2}' mutiple trf '1' for each '50M' UL data
# 	Check counter value
#     Collect AP egate log    ${EGATE_TAG}
#     Analyse scelladd in rrclog
#     Check throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti'
#     Check ttitrace
#     Airphone NSA Stop Data Traffic    ${UE_ID}    DL
#     Airphone NSA Stop Data Traffic    ${UE_ID}    UL
#     Airphone NSA Stop Data Traffic    ${UE_ID_2}    DL
#     Airphone NSA Stop Data Traffic    ${UE_ID_2}    UL
#     Airphone NSA Detach    ${UE_ID}
#     Airphone NSA Detach    ${UE_ID_2}
#     Airphone NSA Detach    ${UE_ID3}
#     Airphone NSA Detach    ${UE_ID4}	
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Check counter value
#     Wait until keyword succeeds    120s    30s    counter value
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# Enable RD syslog in AP Swconfig
#         Modify AP swconfig    0x10041:1
# Attach LTE UE1
#     Airphone Nsa Attach    ${UE_ID}
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# Attach LTE UE2
#     Airphone Nsa Attach    ${UE_ID_2}    profile_id=None
#     airphone_execute_egate_command    ue_measurement_send_nr id\=12 meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=50
# Attach LTE UE3
#     Airphone Nsa Attach    ${UE_ID3}
#     airphone_execute_egate_command    ue_measurement_send_nr id\=13 meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# Attach LTE UE4
#     Airphone Nsa Attach    ${UE_ID4}    profile_id=None
#     airphone_execute_egate_command    ue_measurement_send_nr id\=14 meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=50
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Verify throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>100000
#     should_be_true    ${dl_throughput_scell1}>100000
#     ${dl_throughput_pcell_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID_2}    scell_id=8    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID_2}    scell_id=9    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell_ue2}>100000
#     should_be_true    ${dl_throughput_scell1_ue2}>100000
# 
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd_NSA_1.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# NSA send ue '${ue_id}' mutiple trf '${number}' for each '${ul_data}' UL data
#     : FOR    ${num}    IN RANGE    1    ${number}+1
#     \    Airphone NSA Start Data Traffic    ${ue_id}    DL    ${ul_data}    duration=6000s    trf_id=${num}
#     Wait Throughput Timer    5s
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# counter value
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
#     ${PM_counter_value_Pcell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55114C00028    cell_id=1
# 	${PM_counter_value_Pcell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55114C00035    cell_id=1
# 	${PM_counter_value_Pcell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55114C00021    cell_id=1
# 	${PM_counter_value_Pcell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55115C00008    cell_id=1
#     ${PM_counter_value_Scell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55115C00007    cell_id=3
#     should be true    ${PM_counter_value_Pcell}==2
# 	should be true    ${PM_counter_value_Pcell2}==2
# 	should be true    ${PM_counter_value_Pcell3}==4
# 	should be true    ${PM_counter_value_Pcell4}==2
#     should be true    ${PM_counter_value_Scell}==2
# Modify counter Swconfig
# 	Add GNB swconfig    0x340000:15  
#     Modify GNB swconfig	   0x340000:15	