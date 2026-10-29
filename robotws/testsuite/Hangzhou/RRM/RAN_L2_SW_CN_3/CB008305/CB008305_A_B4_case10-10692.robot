# *** Settings ***
# Suite Setup       Qualcomm Common Suite Setup
# #Suite Teardown    Qualcomm Common Suite Teardown
# Test Setup        Qualcomm Common Test Setup
# #Test Teardown    Qualcomm Common Test Teardown
# Force Tags        qualcomm    owner_changyli
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# Library           taf.sbts.oam.coam.admin
# Library           taf.pdu
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# @{LOG_NAME_LIST}    gnb_snapshot
# ${UE1_ID}         c2d07079
# ${UE2_ID}         2cdcf49b
# ${UE3_ID}         95fe0e6e
# ${UE1_DL_PORT}    5001
# ${UE2_DL_PORT}    5002
# ${UE3_DL_PORT}    5003
# ${UE1_UL_PORT}    5004
# ${UE2_UL_PORT}    5005
# ${UE3_UL_PORT}    5006
# ${DL_LOG}         /tmp/iperf_server_on_ue_log.txt
# ${UL_LOG}         /tmp/iperf_server_on_pc_log.txt
# ${DL_SEND_DATA_CMD}    -u -t 800 -i 1 -P 1 -f m -b 1300.00M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_2}    -u -t 800 -i 1 -P 1 -f m -b 300.00M -l 1400B -T 64
# ${UL_SEND_DATA_CMD}    -u -c 192.168.255.1 -P 1 -i 1 -f m -w 4M -b 200M -t 600
# ${EXPORT_GRID}    ${None}
# ${TXT_LOG_NAME}    qualcomm_rrc_raw
# ${SCFC_NAME}      CB008305_case10_SCFC.xml
# ${GNB_SWCONFIG_QUAL_NAME}    qual_swconfig_case10.txt
# ${GNB_SWCONFIG_QUAL_NAME_127}    qual_swconfig_127.txt
# ${TTITRACE_TAG}    ttitrace
# ${4G_S1_local_IP}    10.108.175.74
# ${MCS_FREQUENCY}    3550
# ${ATT_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/UE1_UE2_peak_rank4_rank1_att.csv
# ${PHASE_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/UE1_UE2_peak_rank4_rank1_phase.csv
# ${ATT_FILE_PATH_CLOSE}    ${CONFIG_DIR_PATH}/qualcomm_config/UE1_UE2_peak_rank4_rank1_notpair_att.csv
# ${PHASE_FILE_PATH_CLOSE}    ${CONFIG_DIR_PATH}/qualcomm_config/UE1_UE2_peak_rank4_rank1_notpair_phase.csv
# ${CELL_TPUT}      50000
# ${FIX_RANK4}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x04
# ${FIX_RANK1}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x01
# 
# *** Test Cases ***
# CB008305_A_B4_case10_rank1_Ue_paire_with_rank4_Ue_and_SCID_and_power_check
#     Prepare for sa env
# #    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
#     #step1
#     Qualcomm prepare gnb onair
#     Start capture only gnb syslog in 'after_onair' file
#     Set Mcs3 Channel Phase And Attenuation    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}
# #    #step2
#     Qualcomm detach ue    ${UE3_ID}
#     Qualcomm Start Qxdm Trace    ${UE1_ID}
#     Qualcomm Start Qxdm Trace    ${UE2_ID}
#     Attach qualcomm ue and start dl data    ${UE1_ID}    ${UE1_DL_PORT}
#     Attach qualcomm ue and start dl data    ${UE2_ID}    ${UE2_DL_PORT}
#     qualcomm_send_qxdm_command    ${UE1_ID}    ${FIX_RANK4}
#     qualcomm_send_qxdm_command   ${UE2_ID}    ${FIX_RANK1}
#     Wait '30s' for stabible
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT}
#     Qualcomm Stop DL Data    ${UE2_ID}    ${UE2_DL_PORT}
#     Stop and Download Qualcomm UE RRC logs    ${UE1_ID}    ${UE1_ID}_rrc_raw_mu    ${TXT_DEF_PATH}    false
#     Stop and Download Qualcomm UE RRC logs    ${UE2_ID}    ${UE2_ID}_rrc_raw_mu
#     run keyword and continue on failure    filter_qcat_message    ${test_log_directory()}${/}${UE1_ID}_rrc_raw_mu.txt    ::=
#     ...    ${test_log_directory()}${/}RRC_MU_UE1.txt
#     run keyword and continue on failure    filter_qcat_message    ${test_log_directory()}${/}${UE2_ID}_rrc_raw_mu.txt    ::=
#     ...    ${test_log_directory()}${/}RRC_MU_UE2.txt
#     run keyword and continue on failure    check_log_with_au2anlysis    ${CURDIR}/ini/case10_UE1.ini    p
#     ...    save_log_directory=${test_log_directory()}
#     run keyword and continue on failure    check_log_with_au2anlysis    ${CURDIR}/ini/case10_UE2.ini    p
#     ...    save_log_directory=${test_log_directory()}
# 
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     Qualcomm Start DL Data    ${UE2_ID}    ${UE2_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD_2}
#     Wait '60s' for stabible
# #    Start collect ttitrace
# #    Wait for '10s' to stop ttitrace with name'tti_mu'
# 
#     ${ue1_logs_path}    Get qualcomm log    ${UE1_ID}
#     ${ue2_logs_path}    Get qualcomm log    ${UE2_ID}
#     Download qualcomm log    ${ue1_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE1_ID}_raw_mu.txt
#     Download qualcomm log    ${ue2_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE2_ID}_raw_mu.txt
#     Check ue dl throughput and bler    Throughput_${UE1_ID}_raw_mu.txt    1000000
#     Check ue dl throughput and bler    Throughput_${UE2_ID}_raw_mu.txt    250000
# 
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT}
#     Qualcomm Stop DL Data    ${UE2_ID}    ${UE2_DL_PORT}
# #    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_mu_case10.ini
# #    ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
#     Set Mcs3 Channel Phase And Attenuation    ${ATT_FILE_PATH_CLOSE}    ${PHASE_FILE_PATH_CLOSE}
# 
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     Qualcomm Start DL Data    ${UE2_ID}    ${UE2_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD_2}
#     Wait '60s' for stabible
# #    Start collect ttitrace
# #    Wait for '10s' to stop ttitrace with name'tti_su'
# 
#     ${ue1_logs_path}    Get qualcomm log    ${UE1_ID}
#     ${ue2_logs_path}    Get qualcomm log    ${UE2_ID}
#     Download qualcomm log    ${ue1_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE1_ID}_raw_su.txt
#     Download qualcomm log    ${ue2_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE2_ID}_raw_su.txt
#     Check ue dl throughput and bler    Throughput_${UE1_ID}_raw_su.txt    500000
#     Check ue dl throughput and bler    Throughput_${UE2ID}_raw_su.txt    120000
# 
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT}
#     Qualcomm Stop DL Data    ${UE2_ID}    ${UE2_DL_PORT}
# #    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_su_case10.ini
# #    ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# #    Stop capture only gnb syslog in 'after_onair' file
# 
# *** Keywords ***
# Attach qualcomm ue and start dl data
#     [Arguments]    ${UE_ID}    ${UE_DL_PORT}
#     Qualcomm detach ue    ${UE_ID}
#     Qualcomm attach ue    ${UE_ID}
#     Qualcomm Start DL Data    ${UE_ID}    ${UE_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
# 
# 
# Check ue dl throughput and bler
#     [Arguments]    ${txt_file_name}    ${pcell_tput_expect}=50000    ${pcell_bler_expect}=9
#     ${pcell_tput}    ${pcell_bler}    Get ue DL throughput and bler    ${txt_file_name}
#     run keyword and continue on failure    should_be_true    ${pcell_tput} > ${pcell_tput_expect}
#     run keyword and continue on failure    should_be_true    ${pcell_bler} < ${pcell_bler_expect}
# 
# Get ue DL throughput and bler
#     [Arguments]    ${txt_file_name}
#     log to console    start to get ue throughput and bler
#     ${ue_pcell_tput}    get_dl_pcell_tput    ${test_log_directory()}/${txt_file_name}
#     ${ue_pcell_bler}    get_dl_pcell_bler    ${test_log_directory()}/${txt_file_name}
#     [Return]    ${ue_pcell_tput}    ${ue_pcell_bler}
# 
# Get ue UL throughput and bler
#     [Arguments]    ${txt_file_name}
#     log to console    start to get ue throughput and bler
#     ${UE1_pcell_tput_ul}    get_ul_pcell_tput    ${test_log_directory()}/${txt_file_name}
#     ${UE1_pcell_bler_ul}    get_ul_pcell_bler    ${test_log_directory()}/${txt_file_name}
#     [Return]    ${UE1_pcell_tput_ul}    ${UE1_pcell_bler_ul}
# 
# Get ue throughput and bler
#     [Arguments]    ${txt_file_name}
#     log to console    start to get ue throughput and bler
#     ${cell_tput}    get_dl_pcell_tput    ${test_log_directory()}/${txt_file_name}
#     ${cell_bler}    get_dl_pcell_bler    ${test_log_directory()}/${txt_file_name}
#     ${ul_tput}    get_ul_pcell_tput    ${test_log_directory()}/${txt_file_name}
#     ${ul_bler}    get_ul_pcell_bler    ${test_log_directory()}/${txt_file_name}
#     [Return]    ${cell_tput}    ${cell_bler}    ${ul_tput}    ${ul_bler}
# 
# Capture and Download Qualcomm UE RRC logs
#     [Arguments]    ${ue_id}    ${log_name}=${TXT_LOG_NAME}    ${log_path}=${TXT_DEF_PATH}
#     Qualcomm Start Qxdm Trace    ${ue_id}
#     Wait '15s' for stabible
#     ${absolutely_path}    Qualcomm Stop Qxdm Trace    ${ue_id}    ${log_path}
#     Wait '20s' for stabible
#     Download qualcomm log    ${absolutely_path}.hdf    ${EXPORT_GRID}    ${log_name}.txt
# 
# Stop and Download Qualcomm UE RRC logs
#     [Arguments]    ${ue_id}    ${log_name}=${TXT_LOG_NAME}    ${log_path}=${TXT_DEF_PATH}    ${quit_app}=true
#     #    Wait '15s' for stabible
#     ${absolutely_path}    Qualcomm Stop Qxdm Trace    ${ue_id}    ${log_path}    quit_app=${quit_app}
#     Wait '20s' for stabible
#     Download qualcomm log    ${absolutely_path}.hdf    ${EXPORT_GRID}    ${log_name}.txt
# 
# Download qualcomm log
#     [Arguments]    ${UE_trace_file}    ${export_grid}    ${name}    ${txt_file_path}=${TXT_DEF_PATH}
#     ${qc_log}    qualcomm export to txt with qcat    ${UE_trace_file}    ${txt_file_path}    filter=${export_grid}
#     sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${UE_trace_file}    ${test_log_directory()}/
#     sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${qc_log}    ${test_log_directory()}/${name}
# 
# Get qualcomm log
#     [Arguments]    ${ue_id}    ${log_path}=${TXT_DEF_PATH}
#     Qualcomm Start Qxdm Trace    ${ue_id}
#     Wait '15s' for stabible
#     ${absolutely_path}    Qualcomm Stop Qxdm Trace    ${ue_id}    ${log_path}
#     [Return]    ${absolutely_path}
# 
# Prepare for nsa env
#     Unblock one 4G cell    287    ${4G_S1_local_IP}
#     Wait '10s' for stabible
#     Set ue to NSA    ${UE1_ID}
#     Wait '5s' for stabible
#     Set ue to NSA    ${UE2_ID}
# 
# Prepare for sa env
#     Set ue to SA    ${UE1_ID}
#     Wait '5s' for stabible
#     Set ue to SA    ${UE2_ID}
# 
# Set ue to NSA
#     [Arguments]    ${ue_id}
#     ${value1}    Qualcomm Read Nvitem    ${ue_id}    80000
#     Wait '5s' for stabible
#     Qualcomm Write Nvitem    ${ue_id}    80000    80
#     Wait '5s' for stabible
#     #    Qualcomm Write Nvitem    ${ue_id}    74213    1099511627776
#     Qualcomm Write Nvitem    ${ue_id}    74213    0,8192
#     Wait '1s' for stabible
#     Qualcomm Write Nvitem    ${ue_id}    74087    0
#     Wait '1s' for stabible
#     qualcomm_execute_adb_cmd    ${ue_id}    root & adb wait-for-device
#     Wait '5s' for stabible
#     qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.radio.multisim.config ssss
#     Wait '1s' for stabible
#     qualcomm_execute_adb_cmd    ${ue_id}    shell sync
#     Wait '1s' for stabible
#     qualcomm_execute_adb_cmd    ${ue_id}    shell rm -rf /data/user_de/0/com.android.providers.telephony/databases/telephony.db
#     Wait '1s' for stabible
#     qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref 1
#     Wait '1s' for stabible
#     qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref_0 1
#     Wait '1s' for stabible
#     qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref_1 1
#     Wait '1s' for stabible
#     qualcomm_execute_adb_cmd    ${ue_id}    shell sync
#     Wait '1s' for stabible
#     qualcomm_execute_adb_cmd    ${ue_id}    reboot
#     Wait '60s' for stabible
#     Qualcomm Set Apn    ${ue_id}    NSA    stdata3
#     Wait '5s' for stabible
# 
# Set ue to SA
#     [Arguments]    ${ue_id}
#     ${value1}    Qualcomm Read Nvitem    ${ue_id}    80000
#     Wait '5s' for stabible
#     Qualcomm Write Nvitem    ${ue_id}    80000    64
#     Wait '5s' for stabible
#     Qualcomm Write Nvitem    ${ue_id}    74213    0
#     Wait '1s' for stabible
#     #    Qualcomm Write Nvitem    ${ue_id}    74087    1099511627776
#     Qualcomm Write Nvitem    ${ue_id}    74087    0,8192
#     Wait '1s' for stabible
#     Qualcomm Write Nvitem    ${ue_id}    67218    1
#     Wait '1s' for stabible
#     Qualcomm Write Nvitem    ${ue_id}    73991    0
#     Wait '5s' for stabible
#     qualcomm_execute_adb_cmd    ${ue_id}    root & adb wait-for-device
#     Wait '5s' for stabible
#     qualcomm_execute_adb_cmd    ${ue_id}    setprop persist.radio.multisim.config ssss
#     Wait '1s' for stabible
#     qualcomm_execute_adb_cmd    ${ue_id}    shell sync
#     Wait '1s' for stabible
#     qualcomm_execute_adb_cmd    ${ue_id}    shell rm -rf /data/user_de/0/com.android.providers.telephony/databases/telephony.db
#     Wait '1s' for stabible
#     qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref 2
#     Wait '1s' for stabible
#     qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref_0 2
#     Wait '1s' for stabible
#     qualcomm_execute_adb_cmd    ${ue_id}    setprop persist.vendor.radio.5g_mode_pref_1 2
#     Wait '1s' for stabible
#     qualcomm_execute_adb_cmd    ${ue_id}    shell sync
#     Wait '1s' for stabible
#     qualcomm_execute_adb_cmd    ${ue_id}    reboot
#     Wait '60s' for stabible
#     Qualcomm Set Apn    ${ue_id}    SA    stdata3
#     Wait '5s' for stabible
# 
# 
