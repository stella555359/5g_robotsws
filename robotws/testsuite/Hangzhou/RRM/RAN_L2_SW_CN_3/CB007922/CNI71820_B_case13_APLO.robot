# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags    owner_l3gao    AP    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LO
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# Documentation     gNB10316  @{Rdparameter}
# ...    0x58012d=4 # k2min for Airphone
# ...    0x5800f4=4 #  k1Min_for_AirPhone
# ...    UEID 20 is the UE
# ...    PR668051 fixed
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}     71820_CASE13_SCFC_LO_AP_LO_semtic.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_4CELL_LO_AP_LO.xml
# ${WTS_NAME}      WTS_LO_AP_LO_SANSA_n78_8SA_32NSA_NSAUpdateto4layer.cfg
# @{LOG_NAME_LIST}    gnb_snapshot
# ${UE_ID}          11
# ${UE_ID_2}        12
# ${EGATE_TAG}      RRC_Check
# ${UE_NUM}         8
# ${UE_NUM_2}       1
# ${STABLETIME}     5s
# ${bip_tag}    bip
# &{GNBMIRRORINGCONFIG}    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# ...    NUMBER_OF_FILES=30
# @{Rdparameter}   0x1003F:1    0x340000:15    0x9D0000:15
# ...  0x10040:1
# ...  0x10041:1
# ...  0x590072:1
# ...  0x66001b:1
# ...  0x890001:1
# ...  0x890002:1
# ...  0x890003:1
# ...  0x890004:1
# ...  0x890005:1
# ...  0x890006:1     #cplane logs
# ...  0x58012d:1
# ...  0x5800f4:1    # k2min for Airphone
# 
# *** Test Cases ***
# CNI71820_B_case13_Aperiodic_CSI_TDD_CA_with_ULdata_NSA
#     step1:prepare gnb
#     Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/scellblind_additon.json
#     step2:check 1_NSA_UEID20_withoutDATA_blind
#     step3:check 1_NSA_UEID21_withoutDATA_blind
#     step4:check 7nsa_full_data_1nsa_littledata_blind
#     Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/scellA1_additon.json
#     step5:check 1_NSA_UEID20_withoutDATA_A1
#     step6:check 1_NSA_UEID21_withoutDATA_A1
#     step7:check 7nsa_full_data_1nsa_littledata
# 
# *** Keywords ***
# step1:prepare gnb
# #    Active GNB L2 feature debug traces
#     Add GNB swconfig    @{Rdparameter}
#     Prepare gnb onair
#     Execute AP Command before attach
# 
# step2:check 1_NSA_UEID20_withoutDATA_blind
#     Start capture gnb and ap syslog in '1_NSA_UEID20_withoutDATA_blind' file
# #    Start collect bip log
#     Run Keyword And Ignore Error    Start collect 'F1_logs_1_NSA_UEID20_blind' tcpdump
#     Attach 1 NSA '20' CAUE and check scelladdition '1_NSA_UEID20_blind'
#     Stop collect 'F1_logs_1_NSA_UEID20_blind' tcpdump
# #    Wait for '2s' to stop bip log with name'bip_logs_1_NSA_UEID20_withoutDATA_blindaddition'
#     Stop capture gnb and ap syslog in '1_NSA_UEID20_withoutDATA_blind' file
#     Start capture gnb and ap syslog in '1_NSA_UEID20_with_fullDATA_blind' file
#     NSA '20' full buffer sent
#     run keyword and continue on failure    Check NSA '20' peak throughput
#     Start collect ttitrace
#     run keyword and continue on failure    Wait for '2s' to stop ttitrace with name'tti_logs_1_NSA_UEID20_blindaddition'
#     run keyword and continue on failure    Check ttitrace 1UE'tti_logs_1_NSA_UEID20_blindaddition'
# #    Start collect bip log
# #    Wait for '2s' to stop bip log with name'bip_logs_1_NSA_UEID20_fullDATA_blindaddition'
#     Airphone NSA Stop Data Traffic And Detach 1 UE'20'
#     Stop capture gnb and ap syslog in '1_NSA_UEID20_with_fullDATA_blind' file
# 
# step3:check 1_NSA_UEID21_withoutDATA_blind
#     Start capture gnb and ap syslog in '1_NSA_UEID21_withoutDATA_blind' file
# #    Start collect bip log
#     Run Keyword And Ignore Error    Start collect 'F1_logs_1_NSA_UEID21_blind' tcpdump
#     Attach 1 NSA '21' CAUE and check scelladdition '1_NSA_UEID21_blind'
#     Stop collect 'F1_logs_1_NSA_UEID21_blind' tcpdump
# #    Wait for '2s' to stop bip log with name'bip_logs_1_NSA_UEID21_withoutDATA_blindaddition'
#     Stop capture gnb and ap syslog in '1_NSA_UEID21_withoutDATA_blind' file
#     Start capture gnb and ap syslog in '1_NSA_UEID21_with_fullDATA_blind' file
#     NSA '21' full buffer sent
#     run keyword and continue on failure    Check NSA '21' peak throughput
#     Start collect ttitrace
#     run keyword and continue on failure    Wait for '2s' to stop ttitrace with name'tti_logs_1_NSA_UEID21_blindaddition'
#     run keyword and continue on failure    Check ttitrace 1UE'tti_logs_1_NSA_UEID21_blindaddition'
# #    Start collect bip log
# #    Wait for '2s' to stop bip log with name'bip_logs_1_NSA_UEID21_fullDATA_blindaddition'
#     Airphone NSA Stop Data Traffic And Detach 1 UE'21'
#     Stop capture gnb and ap syslog in '1_NSA_UEID21_with_fullDATA_blind' file
# #    Run Keyword And Ignore Error    Collect GNB SnapShot   target_file_name=${TEST_LOG_DIRECTORY()}/All${/}gnb_comon_snapshot_blind_UEID21.zip
# 
# step4:check 7nsa_full_data_1nsa_littledata_blind
#     Start capture gnb and ap syslog in '7nsa_full_data_1nsa_littledata_blind' file
#     Attach '${UE_NUM}' NSA CAUE
#     NSA UE '${UE_NUM}' full data buffer sent
#     run keyword and continue on failure    Check NSA throughput
#     Start collect ttitrace
#     run keyword and continue on failure    Wait for '2s' to stop ttitrace with name'7nsa_full_data_1nsa_littledata_blind'
#     run keyword and continue on failure    Check ttitrace '7nsa_full_data_1nsa_littledata_blind'
#     Airphone NSA Stop Data Traffic And Detach '${UE_NUM}'UE
#     Stop capture gnb and ap syslog in '7nsa_full_data_1nsa_littledata_blind' file
#     run keyword and continue on failure    Check counter value
# 
# step5:check 1_NSA_UEID20_withoutDATA_A1
#     Start capture gnb and ap syslog in '1_NSA_UEID20_withoutDATA_A1' file
# #    Start collect bip log
#     Run Keyword And Ignore Error    Start collect 'F1_logs_1_NSA_UEID20_A1' tcpdump
#     Attach 1 NSA '20' CAUE and check scelladdition '1_NSA_UEID20_A1'
#     Stop collect 'F1_logs_1_NSA_UEID20_A1' tcpdump
# #    Wait for '2s' to stop bip log with name'1_NSA_UEID20_withoutDATA_bip_A1'
#     Stop capture gnb and ap syslog in '1_NSA_UEID20_withoutDATA_A1' file
#     Start capture gnb and ap syslog in '1_NSA_UEID20_with_fullDATA_A1' file
#     NSA '20' full buffer sent
#     run keyword and continue on failure    Check NSA '20' peak throughput
#     Start collect ttitrace
#     run keyword and continue on failure    Wait for '2s' to stop ttitrace with name'tti_logs_1_NSA_UEID20_A1addition'
#     run keyword and continue on failure    Check ttitrace 1UE'tti_logs_1_NSA_UEID20_A1addition'
# #    Start collect bip log
# #    Wait for '2s' to stop bip log with name'bip_logs_1_NSA_UEID20_fullDATA_A1addition'
#     Airphone NSA Stop Data Traffic And Detach 1 UE'20'
#     Stop capture gnb and ap syslog in '1_NSA_UEID20_with_fullDATA_A1' file
# #    Run Keyword And Ignore Error    Collect GNB SnapShot   target_file_name=${TEST_LOG_DIRECTORY()}/All${/}gnb_comon_snapshot_A1_UEID20.zip
# 
# step6:check 1_NSA_UEID21_withoutDATA_A1
#     Start capture gnb and ap syslog in '1_NSA_UEID21_withoutDATA_A1' file
# #    Start collect bip log
#     Run Keyword And Ignore Error    Start collect 'F1_logs_1_NSA_UEID21_A1' tcpdump
#     Attach 1 NSA '21' CAUE and check scelladdition '1_NSA_UEID21_A1'
#     Stop collect 'F1_logs_1_NSA_UEID21_A1' tcpdump
# #    Wait for '2s' to stop bip log with name'1_NSA_UEID21_withoutDATA_bip_A1'
#     Stop capture gnb and ap syslog in '1_NSA_UEID21_withoutDATA_A1' file
#     Start capture gnb and ap syslog in '1_NSA_UEID21_with_fullDATA_A1' file
#     NSA '21' full buffer sent
#     run keyword and continue on failure    Check NSA '21' peak throughput
#     Start collect ttitrace
#     run keyword and continue on failure    Wait for '2s' to stop ttitrace with name'tti_logs_1_NSA_UEID21_A1addition'
#     run keyword and continue on failure    Check ttitrace 1UE'tti_logs_1_NSA_UEID21_A1addition'
# #    Start collect bip log
# #    Wait for '2s' to stop bip log with name'bip_logs_1_NSA_UEID21_fullDATA_A1addition'
#     Airphone NSA Stop Data Traffic And Detach 1 UE'21'
#     Stop capture gnb and ap syslog in '1_NSA_UEID21_with_fullDATA_A1' file
# #    Run Keyword And Ignore Error    Collect GNB SnapShot   target_file_name=${TEST_LOG_DIRECTORY()}/All${/}gnb_comon_snapshot_A1_UEID21.zip
# #
# step7:check 7nsa_full_data_1nsa_littledata
#     Start capture gnb and ap syslog in '7nsa_full_data_1nsa_littledata' file
#     Attach '${UE_NUM}' NSA CAUE
#     NSA UE '${UE_NUM}' full data buffer sent
#     run keyword and continue on failure    Check NSA throughput
#     Start collect ttitrace
#     run keyword and continue on failure    Wait for '2s' to stop ttitrace with name'7nsa_full_data_1nsa_littledata'
#     run keyword and continue on failure    Check ttitrace '7nsa_full_data_1nsa_littledata'
#     Airphone NSA Stop Data Traffic And Detach '${UE_NUM}'UE
#     Stop capture gnb and ap syslog in '7nsa_full_data_1nsa_littledata' file
#     run keyword and continue on failure    Check counter value
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Attach '${UE_NUM}' NSA CAUE
#     : FOR    ${num}    IN RANGE    12    ${UE_NUM}+12
#     \   airphone_cleanup_egate_console_log
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   Wait '3s' for stabible
#     \   airphone_execute_egate_command    ue_measurement_send_nr id\=${num} meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=50
#     \   Wait '2s' for stabible
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
#     \   run keyword and continue on failure     Analyse RRC scelladd NSA AperiCSI Set in rrclog   ${EGATE_TAG}_${num}
# 
# NSA UE '${UE_NUM}' full data buffer sent
#     : FOR    ${num}    IN RANGE    12    ${UE_NUM}+12
#     \   run keyword if    ${num}<(${UE_NUM}+11)    NSA send ue '${num}' mutiple trf '2' for each '110M' DL data
#     \   run keyword if    ${num}==(${UE_NUM}+11)   NSA send ue '${num}' mutiple trf '1' for each '100' DL data
#     \   run keyword if    ${num}<(${UE_NUM}+11)    NSA send ue '${num}' mutiple trf '1' for each '18M' UL data
# 
# Attach 1 NSA '${UEID}' CAUE and check scelladdition '${egate_log_tag}'
#      airphone_cleanup_egate_console_log
#      Airphone Nsa Attach    ${UEID}    profile_id=None
#      Wait '3s' for stable
#      airphone_execute_egate_command    ue_measurement_send_nr id\=${UEID} meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=50
#      airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
#      airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=1
#      run keyword if  ${UEID}==20
#      ...   airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=8
#      run keyword if  ${UEID}==20
#      ...   airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=2 scell\=9
#      Wait '2s' for stable
#      Collect AP egate log    ${UEID}_${egate_log_tag}
#      run keyword and continue on failure     Analyse RRC scelladd NSA AperiCSI Set in rrclog   ${UEID}_${egate_log_tag}
# 
# NSA '${UEID}' full buffer sent
#     run keyword if  ${UEID}!=20    NSA send ue '${UEID}' mutiple trf '12' for each '175M' DL data
#     run keyword if  ${UEID}==20    NSA send ue '${UEID}' mutiple trf '9' for each '175M' DL data
#     NSA send ue '${UEID}' mutiple trf '1' for each '15M' UL data
# 
# Check NSA throughput
#     Wait until keyword succeeds    60s    5s    Verify fullbuffer CAUE throughput
#     Wait until keyword succeeds    60s    5s    Verify littlebuffer CAUE throughput
# 
# Check NSA '${UEID}' peak throughput
#     run keyword if  ${UEID}!=20    Wait until keyword succeeds    60s    5s
#     ...    Verify fullbuffer NSA '${UEID}' CAUE peak throughput
#     run keyword if  ${UEID}==20    Wait until keyword succeeds    60s    5s
#     ...    Verify fullbuffer NSA '${UEID}' CAUE peak throughput MAXlayer4_2
# 
# 
# Verify fullbuffer CAUE throughput
#     : FOR    ${num}    IN RANGE    12    ${UE_NUM}+11
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
#     \    ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=9    type=pdsch    tput_type=ave
#     \    ${UE1_ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pusch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}+${dl_throughput_scell1}>180000
#     \    should_be_true    ${UE1_ul_throughput_pcell}>1000
# 
# Verify fullbuffer NSA '${UEID}' CAUE peak throughput
#     ${dl_throughput_pcell_1}   airphone_get_throughput_on_specific_scell    ue_id=${UEID}    scell_id=8    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1_1}    airphone_get_throughput_on_specific_scell    ue_id=${UEID}    scell_id=9    type=pdsch    tput_type=ave
#     ${UE1_ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UEID}   scell_id=8    type=pusch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell_1}+${dl_throughput_scell1_1}>1400000
#     should_be_true   ${dl_throughput_pcell_1}>700000
#     should_be_true   ${dl_throughput_scell1_1}>700000
# 
# Verify fullbuffer NSA '${UEID}' CAUE peak throughput MAXlayer4_2
#     ${dl_throughput_pcell_1}   airphone_get_throughput_on_specific_scell    ue_id=${UEID}    scell_id=8    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1_1}    airphone_get_throughput_on_specific_scell    ue_id=${UEID}    scell_id=9    type=pdsch    tput_type=ave
#     ${UE1_ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UEID}   scell_id=8    type=pusch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell_1}+${dl_throughput_scell1_1}>1400000
#     should_be_true   ${dl_throughput_pcell_1}>800000
#     should_be_true   ${dl_throughput_scell1_1}>500000
# 
# Verify littlebuffer CAUE throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=19    scell_id=8    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=19    scell_id=9    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>100
# 
# Analyse RRC scelladd NSA AperiCSI Set in rrclog
#     [Arguments]    ${EGATE_TAG}
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd_NSA_AperiCSI_Set.ini    p
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Check ttitrace '${tti_tag}'
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_acsi.ini    log_need_to_check=i
#     ...    save_log_directory=${test_log_directory()}/All/${tti_tag}/
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_debug.ini    log_need_to_check=i
#     ...    save_log_directory=${test_log_directory()}/All/${tti_tag}/
# 
# Check ttitrace 1UE'${tti_tag}'
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i
#     ...    save_log_directory=${test_log_directory()}/All/${tti_tag}/
# 
# Wait time to stable
#     sleep    ${STABLETIME}
# 
# Send ue '${num}' A1 event
#     airphone_execute_egate_command    ue_measurement_send_nr id\=${num} meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti
# 
# DeRegister SA '${UE_NUM}' UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '2s' for stabible
# 
# Airphone NSA Stop Data Traffic And Detach 1 UE'${UEID}'
#      Airphone NSA Stop Data Traffic    ${UEID}    BI
#      Wait '1s' for stabible
#      Airphone NSA Detach    ${UEID}
#      Wait '2s' for stabible
# 
# Airphone NSA Stop Data Traffic And Detach '${UE_NUM}'UE
#     : FOR    ${num}    IN RANGE    12    ${UE_NUM}+12
#     \    Airphone NSA Stop Data Traffic   ${num}    BI
#     \   Wait '1s' for stabible
#     \    Airphone NSA Detach    ${num}
#     \   Wait '2s' for stabible
# 
# Check counter value
#     Wait until keyword succeeds    120s    30s    counter value
# 
# counter value
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
#     ${SGNB_SCELL_1_ADMISSION_SUCC}=    get_counter_value_from_counter_file
#     ...    counter_file=${PM_counter_file}    counter_id=M55114C00028    cell_id=1
# 	${SGNB_SCELL_ADMISSION_UNSUCC}=    get_counter_value_from_counter_file
# 	...    counter_file=${PM_counter_file}    counter_id=M55114C00035    cell_id=1
# 	${SGNB_SCELL_1_ADMISSION_REQ}=    get_counter_value_from_counter_file
# 	...    counter_file=${PM_counter_file}    counter_id=M55114C00021    cell_id=1
# 	${SGNB_CU_NSA_ADMISSION_UNSUCC}=    get_counter_value_from_counter_file
# 	...    counter_file=${PM_counter_file}    counter_id=M55114C00020    cell_id=1
#     ${SGNB_DU_SCELL_ADMISSION_SUCC}=    get_counter_value_from_counter_file
#     ...    counter_file=${PM_counter_file}    counter_id=M55115C00007    cell_id=3
#     ${SGNB_DU_SCELL_1_ADMISSION_REQ}=    get_counter_value_from_counter_file
#     ...    counter_file=${PM_counter_file}    counter_id=M55115C00008    cell_id=3
#     log to console    SGNB_SCELL_1_ADMISSION_SUCC is ${SGNB_SCELL_1_ADMISSION_SUCC}
#     log to console    SGNB_SCELL_ADMISSION_UNSUCC is ${SGNB_SCELL_ADMISSION_UNSUCC}
#     log to console    SGNB_SCELL_1_ADMISSION_REQ is ${SGNB_SCELL_1_ADMISSION_REQ}
#     log to console    SGNB_CU_NSA_ADMISSION_UNSUCC is ${SGNB_CU_NSA_ADMISSION_UNSUCC}
#     log to console    SGNB_DU_SCELL_ADMISSION_SUCC is ${SGNB_DU_SCELL_ADMISSION_SUCC}
#     log to console    SGNB_DU_SCELL_1_ADMISSION_REQ is ${SGNB_DU_SCELL_1_ADMISSION_REQ}
# 
# #    should be true    ${PM_counter_value_Pcell}==2
# #	should be true    ${PM_counter_value_Pcell2}==2
# #	should be true    ${PM_counter_value_Pcell3}==4
# #	should be true    ${PM_counter_value_Pcell4}==2
# #    should be true    ${PM_counter_value_Scell}==2