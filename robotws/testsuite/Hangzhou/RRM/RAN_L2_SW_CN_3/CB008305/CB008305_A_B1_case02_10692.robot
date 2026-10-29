# *** Settings ***
# Suite Setup       Qualcomm Common Suite Setup
# #Suite Teardown    Qualcomm Common Suite Teardown
# Test Setup        Qualcomm Common Test Setup
# #Test Teardown    Qualcomm Common Test Teardown
# Force Tags        qualcomm    owner_menzheng
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
# ${DL_SEND_DATA_CMD}    -u -t 8000 -i 1 -P 1 -f m -b 800.00M -l 1400B -T 64
# ${UL_SEND_DATA_CMD}    -u -c 192.168.255.1 -P 1 -i 1 -f m -w 4M -b 20M -t 600
# ${EXPORT_GRID}    ${None}
# ${TXT_LOG_NAME}    qualcomm_rrc_raw
# ${SCFC_NAME}      CB008305_case2_SCFC.xml
# ${GNB_SWCONFIG_QUAL_NAME}    qual_swconfig_case2_muMIMO.txt
# ${GNB_SWCONFIG_QUAL_NAME_127}    qual_swconfig_127.txt
# ${TTITRACE_TAG}    ttitrace
# ${4G_S1_local_IP}    10.108.175.74
# ${MCS_FREQUENCY}    3550
# ${ATT_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/UE1_UE2_peak_rank1_1_att.csv
# ${PHASE_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/UE1_UE2_peak_rank1_1_phase.csv
# ${ATT_FILE_PATH_1}    ${CONFIG_DIR_PATH}/qualcomm_config/UE1_UE2_peak_rank1_1_samepos_att.csv
# ${PHASE_FILE_PATH_1}    ${CONFIG_DIR_PATH}/qualcomm_config/UE1_UE2_peak_rank1_1_samepos_phase.csv
# ${ATT_FILE_PATH_2}    ${CONFIG_DIR_PATH}/qualcomm_config/UE1_UE2_peak_rank1_1_closepos_att.csv
# ${PHASE_FILE_PATH_2}    ${CONFIG_DIR_PATH}/qualcomm_config/UE1_UE2_peak_rank1_1_closepos_phase.csv
# ${FIX_RANK2}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x02
# ${FIX_RANK1}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x01
# ${CELL_TPUT}      50000
# 
# *** Test Cases ***
# CB008305_A_B1_case02_two_rank1_UEs_blindly_paired_mumimo_enable_pdsch_power_DMRS_check
#     #Prepare for sa env
#     #Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
#     #Qualcomm prepare gnb onair
#     #Start capture only gnb syslog in 'after_onair' file
#     #Set Mcs3 Channel Phase And Attenuation    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}
#     Attach two qualcomm ue and make call stable
#     ${ue1_logs_path}   ${ue2_logs_path}   Capture two Qualcomm UE RRC logs   ${UE1_ID}   ${UE2_ID}
#     Wait '20s' for stabible
#     Download qualcomm log    ${ue1_logs_path}.hdf    ${EXPORT_GRID}   ${UE1_ID}_rrc_raw.txt
#     Download qualcomm log    ${ue2_logs_path}.hdf    ${EXPORT_GRID}   ${UE2_ID}_rrc_raw.txt
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     Qualcomm Start DL Data    ${UE2_ID}    ${UE2_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     Qualcomm Start UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${UL_LOG}    ${UL_SEND_DATA_CMD}
#     Qualcomm Start UL Data    ${UE2_ID}    ${UE2_UL_PORT}    ${UL_LOG}    ${UL_SEND_DATA_CMD}
#     Wait '60s' for stabible
#     #Start collect ttitrace
#     #Wait for '5s' to stop ttitrace with name'tti'
#     #Start collect bip log
#     #Wait for '5s' to stop bip log with name'bip'
#     ${ue1_logs_path}    Get qualcomm log    ${UE1_ID}
#     ${ue2_logs_path}    Get qualcomm log    ${UE2_ID}
#     Set Mcs3 Channel Phase And Attenuation    ${ATT_FILE_PATH_1}    ${PHASE_FILE_PATH_1}
#     Download qualcomm log    ${ue1_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE1_ID}_raw.txt
#     Download qualcomm log    ${ue2_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE2_ID}_raw.txt
#     Wait '10s' for stabible
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti_1'
#     ${ue1_logs_path}    Get qualcomm log    ${UE1_ID}
#     ${ue2_logs_path}    Get qualcomm log    ${UE2_ID}
#     Set Mcs3 Channel Phase And Attenuation    ${ATT_FILE_PATH_2}    ${PHASE_FILE_PATH_2}
#     Download qualcomm log    ${ue1_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE1_ID}_raw1.txt
#     Download qualcomm log    ${ue2_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE2_ID}_raw1.txt
#     Wait '10s' for stabible
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti_2'
#     ${ue1_logs_path}    Get qualcomm log    ${UE1_ID}
#     ${ue2_logs_path}    Get qualcomm log    ${UE2_ID}
#     Set Mcs3 Channel Phase And Attenuation    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}
#     qualcomm_send_qxdm_command   ${UE1_ID}    ${FIX_RANK2}
#     Download qualcomm log    ${ue1_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE1_ID}_raw2.txt
#     Download qualcomm log    ${ue2_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE2_ID}_raw2.txt
#     Wait '10s' for stabible
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti_3'
#     ${ue1_logs_path}    Get qualcomm log    ${UE1_ID}
#     ${ue2_logs_path}    Get qualcomm log    ${UE2_ID}
#     Download qualcomm log    ${ue1_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE1_ID}_raw3.txt
#     Download qualcomm log    ${ue2_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE2_ID}_raw3.txt
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT}
#     Qualcomm Stop DL Data    ${UE2_ID}    ${UE2_DL_PORT}
#     Qualcomm Stop UL Data    ${UE1_ID}    ${UE1_UL_PORT}
#     Qualcomm Stop UL Data    ${UE2_ID}    ${UE2_UL_PORT}
#     run keyword and continue on failure    filter_qcat_message    ${test_log_directory()}${/}${UE1_ID}_rrc_raw.txt      ::=
#     ...    ${test_log_directory()}${/}RRC_UE1.txt
#     run keyword and continue on failure    filter_qcat_message    ${test_log_directory()}${/}${UE2_ID}_rrc_raw.txt      ::=
#     ...    ${test_log_directory()}${/}RRC_UE2.txt
#     run keyword and continue on failure    check_log_with_au2anlysis    ${CURDIR}/ini/case2_UE1.ini    p
#     ...    save_log_directory=${test_log_directory()}
#     run keyword and continue on failure    check_log_with_au2anlysis    ${CURDIR}/ini/case2_UE2.ini    p
#     ...    save_log_directory=${test_log_directory()}
#     ${cell_tput}       ${cell_bler}      ${ul_tput}     ${ul_bler}     Get ue throughput and bler    Throughput_${UE1_ID}_raw.txt
#     run keyword and continue on failure    should_be_true    ${cell_tput} > 300000
#     run keyword and continue on failure    should_be_true    ${cell_bler} < 15
#     ${cell_tput}       ${cell_bler}      ${ul_tput}     ${ul_bler}     Get ue throughput and bler    Throughput_${UE2_ID}_raw.txt
#     run keyword and continue on failure    should_be_true    ${cell_tput} > 300000
#     run keyword and continue on failure    should_be_true    ${cell_bler} < 15
#     ${cell_tput}       ${cell_bler}      ${ul_tput}     ${ul_bler}     Get ue throughput and bler    Throughput_${UE1_ID}_raw1.txt
#     run keyword and continue on failure    should_be_true    ${cell_tput} > 140000
#     run keyword and continue on failure    should_be_true    ${cell_bler} < 15
#     ${cell_tput}       ${cell_bler}      ${ul_tput}     ${ul_bler}     Get ue throughput and bler    Throughput_${UE2_ID}_raw1.txt
#     run keyword and continue on failure    should_be_true    ${cell_tput} > 140000
#     run keyword and continue on failure    should_be_true    ${cell_bler} < 15
#     ${cell_tput}       ${cell_bler}      ${ul_tput}     ${ul_bler}     Get ue throughput and bler    Throughput_${UE1_ID}_raw2.txt
#     run keyword and continue on failure    should_be_true    ${cell_tput} > 15000
#     run keyword and continue on failure    should_be_true    ${cell_bler} < 15
#     ${cell_tput}       ${cell_bler}      ${ul_tput}     ${ul_bler}     Get ue throughput and bler    Throughput_${UE2_ID}_raw2.txt
#     run keyword and continue on failure    should_be_true    ${cell_tput} > 15000
#     run keyword and continue on failure    should_be_true    ${cell_bler} < 15
#     ${cell_tput}       ${cell_bler}      ${ul_tput}     ${ul_bler}     Get ue throughput and bler    Throughput_${UE1_ID}_raw3.txt
#     run keyword and continue on failure    should_be_true    ${cell_tput} > 600000
#     run keyword and continue on failure    should_be_true    ${cell_bler} < 15
#     ${cell_tput}       ${cell_bler}      ${ul_tput}     ${ul_bler}     Get ue throughput and bler    Throughput_${UE2_ID}_raw3.txt
#     run keyword and continue on failure    should_be_true    ${cell_tput} > 300000
#     run keyword and continue on failure    should_be_true    ${cell_bler} < 15
#     run keyword and continue on failure    Check ttitrace
#     #Swconfig back to manual
#     Stop capture only gnb syslog in 'after_onair' file
# 
# *** Keywords ***
# Attach two qualcomm ue and make call stable
#     Qualcomm detach ue    ${UE1_ID}
#     Qualcomm detach ue    ${UE2_ID}
#     Qualcomm detach ue    ${UE3_ID}
#     Qualcomm attach ue    ${UE1_ID}
#     Wait '10s' for stabible
#     Qualcomm attach ue    ${UE2_ID}
#     Wait '60s' for stabible
# 	
# Check ue dl throughput and bler
#     [Arguments]    ${txt_file_name}    ${pcell_tput_expect}=50000    ${pcell_bler_expect}=9
#     ${pcell_tput}    ${pcell_bler}    Get ue DL throughput and bler    ${txt_file_name}
#     #    run keyword and continue on failure    should_be_true    ${pcell_tput} > ${pcell_tput_expect}
#     #    run keyword and continue on failure    should_be_true    ${pcell_bler} < ${pcell_bler_expect}
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
#     Wait '5s' for stabible
#     Set ue to SA    ${UE3_ID}
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
# Capture two Qualcomm UE RRC logs
#     [Arguments]    ${ue1_id}    ${ue2_id}    ${log_path}=${TXT_DEF_PATH}
#     qualcomm_send_qxdm_command   ${UE1_ID}    ${FIX_RANK1}
#     qualcomm_send_qxdm_command   ${UE2_ID}    ${FIX_RANK1}
#     Qualcomm Start Qxdm Trace    ${ue1_id}
#     Qualcomm Start Qxdm Trace    ${ue2_id}
#     Qualcomm detach ue    ${ue1_id}
#     Wait '2s' for stabible
#     Qualcomm detach ue    ${ue2_id}
#     Wait '2s' for stabible
#     Qualcomm attach ue    ${ue1_id}
#     Wait '2s' for stabible
#     Qualcomm attach ue    ${ue2_id}
#     Wait '2s' for stabible
#     ${ue1_absolutely_path}    Qualcomm Stop Qxdm Trace    ${ue1_id}    ${log_path}   quit_app=false
#     ${ue2_absolutely_path}    Qualcomm Stop Qxdm Trace    ${ue2_id}    ${log_path}
#     [Return]    ${ue1_absolutely_path}     ${ue2_absolutely_path}
# 	
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
