# *** Settings ***
# Documentation     gNB10316 mumimo case
# Suite Setup       Qualcomm Common Suite Setup
# Test Setup        Qualcomm Common Test Setup    #Suite Teardown    Qualcomm Common Suite Teardown
# Test Teardown     Stop capture only gnb syslog in 'after_onair' file
# Force Tags        qualcomm    owner_l10wang
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# Library           taf.sbts.oam.coam.admin
# Library           taf.pdu
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# @{LOG_NAME_LIST}    gnb_snapshot
# ${UE1_ID}         10a5c6e6  #MCS B1-2-3-4
# ${UE2_ID}         f19fafe0  #MCS B5-6-7-8
# ${UE3_ID}         ca3e3465  #MCS B9-10-11-12
# ${UE1_DL_PORT}    5001
# ${UE2_DL_PORT}    5002
# ${UE3_DL_PORT}    5003
# ${UE1_UL_PORT}    5004
# ${UE2_UL_PORT}    5005
# ${UE3_UL_PORT}    5006
# ${DL_LOG}         /tmp/iperf_server_on_ue_log.txt
# ${UL_LOG}         /tmp/iperf_server_on_pc_log.txt
# ${DL_SEND_DATA_CMD}    -u -t 800 -i 1 -P 1 -f m -b 600.00M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_2}    -u -t 800 -i 1 -P 1 -f m -b 600.00M -l 1400B -T 64
# ${UL_SEND_DATA_CMD}    -u -c 192.168.255.1 -P 1 -i 1 -f m -w 4M -b 50M -t 600
# ${EXPORT_GRID}    ${None}
# ${SCFC_NAME}      CB008305_10316_SCFC_case3.xml
# #${GNB_SWCONFIG_QUAL_NAME}    qual_swconfig_8305_muMIMO.txt
# ${TTITRACE_TAG}    ttitrace
# ${4G_S1_local_IP}    10.108.175.74
# ${ATT_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/ue1_ue3_rank4_rank4_att.csv
# ${PHASE_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/ue1_ue3_rank4_rank4_phase.csv
# ${FIX_RANK2}    QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x02
# 
# 
# *** Test Cases ***
# CB008305_A_B2_case03_two_rank2_Ues_paired_with_correlation_checking
#     Prepare for sa env
#     switch to gNB10316_ABIO
#     Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
#     Qualcomm prepare gnb onair
#     Set Mcs Channel Phase And Attenuation    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}
#     qualcomm_send_qxdm_command    ${UE1_ID}    ${FIX_RANK2}
#     qualcomm_send_qxdm_command    ${UE3_ID}    ${FIX_RANK2}
#     Attach two qualcomm ue and make call stable
#     Start capture only gnb syslog in 'after_onair' file
#     ${ue1_logs_path}    ${ue3_logs_path}    Capture two Qualcomm UE RRC logs    ${UE1_ID}    ${UE3_ID}
#     Wait '20s' for stabible
#     Download qualcomm log    ${ue1_logs_path}.hdf    ${EXPORT_GRID}   ${UE1_ID}_rrc_raw.txt
#     Download qualcomm log    ${ue3_logs_path}.hdf    ${EXPORT_GRID}   ${UE3_ID}_rrc_raw.txt
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     Qualcomm Start DL Data    ${UE3_ID}    ${UE3_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     Qualcomm Start UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${UL_LOG}    ${UL_SEND_DATA_CMD}
#     Qualcomm Start UL Data    ${UE3_ID}    ${UE3_UL_PORT}    ${UL_LOG}    ${UL_SEND_DATA_CMD}
#     Wait '60s' for stabible
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti1'
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_corr1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     ${ue1_logs_path}    Get qualcomm log    ${UE1_ID}
#     ${ue3_logs_path}    Get qualcomm log    ${UE3_ID}
#     run keyword and continue on failure    Download qualcomm log    ${ue1_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE1_ID}_raw.txt
#     run keyword and continue on failure    Download qualcomm log    ${ue3_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE3_ID}_raw.txt
#     filter_qcat_message    ${test_log_directory()}${/}${UE1_ID}_rrc_raw.txt    ::=    ${test_log_directory()}${/}RRC_UE1.txt
#     filter_qcat_message    ${test_log_directory()}${/}${UE3_ID}_rrc_raw.txt    ::=    ${test_log_directory()}${/}RRC_UE3.txt
#     check_log_with_au2anlysis    ${CURDIR}/ini/qcat_UE1.ini    p    save_log_directory=${test_log_directory()}
#     check_log_with_au2anlysis    ${CURDIR}/ini/qcat_UE2.ini    p    save_log_directory=${test_log_directory()}
#     ${cell_tput}    ${cell_bler}    ${ul_tput}    ${ul_bler}    Get ue throughput and bler    Throughput_${UE1_ID}_raw.txt
#     run keyword and continue on failure    should_be_true    ${cell_tput} > 480000
#     run keyword and continue on failure    should_be_true    ${cell_bler} <= 10
#     ${cell_tput}    ${cell_bler}    ${ul_tput}    ${ul_bler}    Get ue throughput and bler    Throughput_${UE3_ID}_raw.txt
#     run keyword and continue on failure    should_be_true    ${cell_tput} > 480000
#     run keyword and continue on failure    should_be_true    ${cell_bler} <= 10
#     online change correlation to 0 and check mu status
#     online change correlation to 0.5 and check mu status
#     online change correlation to 1 and check mu status
# *** Keywords ***
# Attach two qualcomm ue and make call stable
#     Qualcomm detach ue    ${UE1_ID}
#     Qualcomm attach ue    ${UE1_ID}
#     Qualcomm detach ue    ${UE3_ID}
#     Qualcomm attach ue    ${UE3_ID}
#     Qualcomm detach ue    ${UE2_ID}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     Qualcomm Start DL Data    ${UE3_ID}    ${UE2_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     Wait '60s' for stabible
# 
# Get ue DL throughput and bler
#     [Arguments]    ${txt_file_name}
#     log to console    start to get ue throughput and bler
#     ${UE1_pcell_tput}    get_dl_pcell_tput    ${test_log_directory()}/${txt_file_name}
#     ${UE1_scell_tput}    get_dl_scell_tput    ${test_log_directory()}/${txt_file_name}
#     ${UE1_pcell_bler}    get_dl_pcell_bler    ${test_log_directory()}/${txt_file_name}
#     ${UE1_scell_bler}    get_dl_scell_bler    ${test_log_directory()}/${txt_file_name}
#     [Return]    ${UE1_pcell_tput}    ${UE1_scell_tput}    ${UE1_pcell_bler}    ${UE1_scell_bler}
# 
# Get ue UL throughput and bler
#     [Arguments]    ${txt_file_name}
#     log to console    start to get ue throughput and bler
#     ${UE1_pcell_tput_ul}    get_ul_pcell_tput    ${test_log_directory()}/${txt_file_name}
#     ${UE1_pcell_bler_ul}    get_ul_pcell_bler    ${test_log_directory()}/${txt_file_name}
#     [Return]    ${UE1_pcell_tput_ul}    ${UE1_pcell_bler_ul}
# 
# online change correlation to 0 and check mu status
#     online change correlation    0
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti2'
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_corr2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     ${ue1_logs_path}    Get qualcomm log    ${UE1_ID}
#     ${ue3_logs_path}    Get qualcomm log    ${UE3_ID}
#     run keyword and continue on failure    Download qualcomm log    ${ue1_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE1_ID}_raw.txt
#     run keyword and continue on failure    Download qualcomm log    ${ue3_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE3_ID}_raw.txt
#     ${cell_tput}    ${cell_bler}    ${ul_tput}    ${ul_bler}    Get ue throughput and bler    Throughput_${UE1_ID}_raw.txt
#     run keyword and continue on failure    should_be_true    ${cell_tput} > 250000
#     run keyword and continue on failure    should_be_true    ${cell_bler} <= 10
#     ${cell_tput}    ${cell_bler}    ${ul_tput}    ${ul_bler}    Get ue throughput and bler    Throughput_${UE3_ID}_raw.txt
#     run keyword and continue on failure    should_be_true    ${cell_tput} > 250000
#     run keyword and continue on failure    should_be_true    ${cell_bler} <= 10
# 
# 
# online change correlation to 0.5 and check mu status
#     online change correlation    50
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti3'
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_corr3.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     ${ue1_logs_path}    Get qualcomm log    ${UE1_ID}
#     ${ue3_logs_path}    Get qualcomm log    ${UE3_ID}
#     run keyword and continue on failure    Download qualcomm log    ${ue1_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE1_ID}_raw.txt
#     run keyword and continue on failure    Download qualcomm log    ${ue3_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE3_ID}_raw.txt
#     ${cell_tput}    ${cell_bler}    ${ul_tput}    ${ul_bler}    Get ue throughput and bler    Throughput_${UE1_ID}_raw.txt
#     run keyword and continue on failure    should_be_true    ${cell_tput} > 480000
#     run keyword and continue on failure    should_be_true    ${cell_bler} <= 10
#     ${cell_tput}    ${cell_bler}    ${ul_tput}    ${ul_bler}    Get ue throughput and bler    Throughput_${UE3_ID}_raw.txt
#     run keyword and continue on failure    should_be_true    ${cell_tput} > 480000
#     run keyword and continue on failure    should_be_true    ${cell_bler} <= 10
# 
# 
# online change correlation to 1 and check mu status
#     online change correlation    100
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti4'
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_corr4.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     ${ue1_logs_path}    Get qualcomm log    ${UE1_ID}
#     ${ue3_logs_path}    Get qualcomm log    ${UE3_ID}
#     run keyword and continue on failure    Download qualcomm log    ${ue1_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE1_ID}_raw.txt
#     run keyword and continue on failure    Download qualcomm log    ${ue3_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE3_ID}_raw.txt
#     ${cell_tput}    ${cell_bler}    ${ul_tput}    ${ul_bler}    Get ue throughput and bler    Throughput_${UE1_ID}_raw.txt
#     run keyword and continue on failure    should_be_true    ${cell_tput} > 480000
#     run keyword and continue on failure    should_be_true    ${cell_bler} <= 10
#     ${cell_tput}    ${cell_bler}    ${ul_tput}    ${ul_bler}    Get ue throughput and bler    Throughput_${UE3_ID}_raw.txt
#     run keyword and continue on failure    should_be_true    ${cell_tput} > 480000
#     run keyword and continue on failure    should_be_true    ${cell_bler} <= 10
# 
# online change correlation
#     [Arguments]    ${dlMuMimoCorrThd}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-10316/NRBTS-10316/NRCELL-1/NRDLMUMIMO-1   dlMuMimoCorrThd    ${dlMuMimoCorrThd}    online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
# 
# Swconfig back to manual
#     ${scfc_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SCF/${SCFC_NAME}
#     Put swconfig file to gnb    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SWCONFIG/${GNB_SWCONFIG_QUAL_NAME_127}
#     Do Full Commissioning    ${scfc_path}
#     Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
#     Log To Console    BTS is onAir now
# 
# switch to gNB10317_ABIO
#     taf.pdu.setup pdu    FACOM    host=10.108.163.177    alias=gnb
#     taf.pdu.get port status    4    gnb
#     taf.pdu.power off    port=4    pdu_device=gnb
#     Wait '5s' for stabible
#     taf.pdu.get port status    4    gnb
#     taf.pdu.get port status    7    gnb
#     taf.pdu.power on    port=7    pdu_device=gnb
#     taf.pdu.get port status    7    gnb
#     comment    power off 10317
#     comment    taf.pdu.setup pdu    FACOM    host=10.108.163.177    alias=gnb1
#     comment    taf.pdu.get port status    4    gnb1
#     comment    taf.pdu.power off    port=4    pdu_device=gnb1
#     comment    Wait '2s' for stabible
# 
# switch to gNB10316_ABIO
#     taf.pdu.setup pdu    FACOM    host=10.108.134.48    alias=gnb
#     taf.pdu.get port status    1    gnb
#     taf.pdu.power off    port=1    pdu_device=gnb
#     Wait '5s' for stabible
#     taf.pdu.get port status    1    gnb
#     taf.pdu.get port status    2    gnb
#     taf.pdu.power on    port=2    pdu_device=gnb
#     taf.pdu.get port status    2    gnb
#     comment    power off 10317
#     comment    taf.pdu.setup pdu    FACOM    host=10.108.163.177    alias=gnb1
#     comment    taf.pdu.get port status    4    gnb1
#     comment    taf.pdu.power off    port=4    pdu_device=gnb1
#     comment    Wait '2s' for stabible
# 
# Prepare for nsa env
#     Comment    Unblock one 4G cell    288    ${4G_S1_local_IP}
#     Wait '10s' for stabible
#     Set ue to NSA    ${UE1_ID}
#     Wait '5s' for stabible
#     Set ue to NSA    ${UE2_ID}
# 
# Prepare for sa env
#     Set ue to SA    ${UE1_ID}
#     Wait '5s' for stabible
#     Set ue to SA    ${UE3_ID}
# 
# Set ue to NSA
#     [Arguments]    ${ue_id}
#     ${value1}    Qualcomm Read Nvitem    ${ue_id}    80000
#     Wait '5s' for stabible
#     Qualcomm Write Nvitem    ${ue_id}    80000    80
#     Wait '5s' for stabible
#     Qualcomm Write Nvitem    ${ue_id}    74213    1099511627776
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
#     Qualcomm Write Nvitem    ${ue_id}    74087    1099511627776
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
# Unblock one 4G cell
#     [Arguments]    ${phy_cell_id}    ${bts_id}=192.168.255.129    ${alias}=block
#     TAF_ADMIN.connect to    bts_host=${bts_id}    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}    TAF_ADMIN.Get Parameters For All    LNCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.blockingState}'=='Unblocked'    TAF_ADMIN.block cell    ${nrcel.id}    timeout=60    connection=${alias}
#     Wait '5s' for stabible
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.phyCellId}'=='${phy_cell_id}'    TAF_ADMIN.unblock cell    ${nrcel.id}    timeout=60    connection=${alias}
#     \    Run Keyword If    '${nrcel.phyCellId}'=='${phy_cell_id}+1'    TAF_ADMIN.unblock cell    ${nrcel.id}    timeout=60    connection=${alias}
#     TAF_ADMIN.teardown    connection=${alias}
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
# Capture two Qualcomm UE RRC logs
#     [Arguments]    ${ue1_id}    ${ue2_id}    ${log_path}=${TXT_DEF_PATH}
#     Qualcomm Start Qxdm Trace    ${ue1_id}    dmc_file=None
#     Qualcomm Start Qxdm Trace    ${ue3_id}    dmc_file=None
#     Qualcomm detach ue    ${ue1_id}
#     Wait '2s' for stabible
#     Qualcomm detach ue    ${ue3_id}
#     Wait '2s' for stabible
#     Qualcomm attach ue    ${ue1_id}
#     Wait '2s' for stabible
#     Qualcomm attach ue    ${ue3_id}
#     Wait '10s' for stabible
#     ${ue1_absolutely_path}    Qualcomm Stop Qxdm Trace    ${ue1_id}    ${log_path}    quit_app=false
#     ${ue3_absolutely_path}    Qualcomm Stop Qxdm Trace    ${ue3_id}    ${log_path}
#     [Return]    ${ue1_absolutely_path}    ${ue3_absolutely_path}
# 
# Download qualcomm log
#     [Arguments]    ${UE_trace_file}    ${export_grid}    ${name}    ${txt_file_path}=${TXT_DEF_PATH}
#     ${qc_log}    qualcomm export to txt with qcat    ${UE_trace_file}    ${txt_file_path}    ${export_grid}
#     sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${UE_trace_file}    ${test_log_directory()}/
#     sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${qc_log}    ${test_log_directory()}/${name}
# 
# Onlinechange parameter dlMuMimoCorrThd
#     [Arguments]    ${dlMuMimoCorrThd}
#     Log To Console    set dlMuMimoCorrThd ...
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-10302/NRBTS-10302/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuMimoCorrThd
#     ...    operation=update    value=${dlMuMimoCorrThd}    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '60s' for stabible
