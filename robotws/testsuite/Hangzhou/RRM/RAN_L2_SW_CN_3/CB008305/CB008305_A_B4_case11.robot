# *** Settings ***
# Suite Setup       Qualcomm Common Suite Setup
# #Suite Teardown    Qualcomm Common Suite Teardown
# Test Setup        Qualcomm Common Test Setup
# #Test Teardown     Qualcomm Common Test Teardown
# Force Tags        qualcomm    owner_l3gao
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# Library           taf.sbts.oam.coam.admin
# Library           taf.pdu
# 
# Documentation     gNB10316  inter-l2RT case
# ...     beamform_beamset6 8mhz_80mhz refinebeam_false 4DL4UL dlmimo_4X4 SA frame_1208_2symbol_4DL1UL
# ...     actPdschAtSsbSlots_P_enable_S_enable prach_148
# ...     peak downlink_1120_1120  uplink 115
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# @{LOG_NAME_LIST}    gnb_snapshot
# ${UE1_ID}         95fe0e6e
# ${UE2_ID}         f19fafe0
# ${UE3_ID_8450}    ca3e3465
# ${UE1_DL_PORT}    5001
# ${UE2_DL_PORT}    5002
# ${UE3_DL_PORT}    5003
# ${UE1_UL_PORT}    5004
# ${UE2_UL_PORT}    5005
# ${UE3_UL_PORT}    5006
# ${DL_LOG}    /tmp/iperf_server_on_ue_log.txt
# ${UL_LOG}    /tmp/iperf_server_on_pc_log.txt
# ${DL_SEND_DATA_CMD}    -u -t 800 -i 1 -P 1 -f m -b 1400.00M -l 1400B -T 64
# ${UL_SEND_DATA_CMD}    -u -c 192.168.255.1 -P 1 -i 1 -f m -w 4M -b 200M -t 600
# ${EXPORT_GRID_TP}    Common Displays;Events and Debug Msgs vs. Time
# ${EXPORT_GRID}    ${None}
# ${SCFC_NAME}     CB008305_case11_SCFC.xml
# ${GNB_SWCONFIG_QUAL_NAME}     qual_swconfig_QC_codebook.txt
# ${GNB_SWCONFIG_QUAL_NAME_127}    qual_swconfig_127.txt
# ${TTITRACE_TAG}    ttitrace
# ${4G_S1_local_IP}    10.108.175.74
# ${ATT_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/UE1_UE2_UE3_peak_rank1_4_4_att.csv
# ${PHASE_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/UE1_UE2_UE3_peak_rank1_4_4_phase.csv
# 
# *** Test Cases ***
# CB008305_A_B4_case11_rank1_Ue_paire_with_rank4_Ue_and_SCID_and_power_check_with_codebook
#     Prepare for nsa env
# #    switch to gNB10316_ABIO
# #    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
# #    Qualcomm prepare gnb onair
# #    Set Mcs Channel Phase And Attenuation    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}
# #    Attach two qualcomm ue and make call stable
#     ${ue1_logs_path}   ${ue3_logs_path}   Capture two Qualcomm UE RRC logs   ${UE1_ID}   ${UE3_ID_8450}
#     Wait '20s' for stabible
#     Download qualcomm log    ${ue1_logs_path}.hdf    ${EXPORT_GRID}   ${UE1_ID}_rrc_raw.txt
#     Download qualcomm log    ${ue3_logs_path}.hdf    ${EXPORT_GRID}   ${UE3_ID_8450}_rrc_raw.txt
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     Qualcomm Start DL Data    ${UE3_ID_8450}    ${UE3_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     Qualcomm Start UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${UL_LOG}    ${UL_SEND_DATA_CMD}
#     Qualcomm Start UL Data    ${UE3_ID_8450}    ${UE3_UL_PORT}    ${UL_LOG}    ${UL_SEND_DATA_CMD}
#     Wait '60s' for stabible
# #    Start collect ttitrace
# #    Wait for '5s' to stop ttitrace with name'tti'
# 	${ue1_logs_path}    Get qualcomm log    ${UE1_ID}
# 	${ue3_logs_path}    Get qualcomm log    ${UE3_ID_8450}
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT}
#     Qualcomm Stop DL Data    ${UE3_ID_8450}    ${UE3_DL_PORT}
#     Download qualcomm log    ${ue1_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE1_ID}_raw.txt
#     Download qualcomm log    ${ue3_logs_path}.hdf    ${EXPORT_GRID}    Throughput_${UE3_ID_8450}_raw.txt
#     run keyword and continue on failure    filter_qcat_message
#     ...       ${test_log_directory()}${/}${UE1_ID}_rrc_raw.txt      ::=    ${test_log_directory()}${/}RRC_UE1.txt
#     run keyword and continue on failure    filter_qcat_message
#     ...       ${test_log_directory()}${/}${UE3_ID_8450}_rrc_raw.txt      ::=    ${test_log_directory()}${/}RRC_UE3.txt
#     run keyword and continue on failure    check_log_with_au2anlysis    ${CURDIR}/ini/qcat_UE1.ini    p    
#    ...    save_log_directory=${test_log_directory()}
#     run keyword and continue on failure    check_log_with_au2anlysis    ${CURDIR}/ini/qcat_UE3.ini    p    
#    ...    save_log_directory=${test_log_directory()}
#     ${cell_tput}       ${cell_bler}      ${ul_tput}     ${ul_bler}     Get ue throughput and bler    Throughput_${UE1_ID}_raw.txt
#     run keyword and continue on failure    should_be_true    ${cell_tput} > 120000
#     run keyword and continue on failure    should_be_true    ${cell_bler} < 3
#     ${cell_tput}       ${cell_bler}      ${ul_tput}     ${ul_bler}     Get ue throughput and bler    
#    ...    Throughput_${UE3_ID_8450}_raw.txt
#     run keyword and continue on failure    should_be_true    ${cell_tput} > 120000
#     run keyword and continue on failure    should_be_true    ${cell_bler} < 3
# #    Swconfig back to manual
# 
# *** Keywords ***
# Attach two qualcomm ue and make call stable
#     Qualcomm detach ue    ${UE1_ID}
#     Qualcomm attach ue    ${UE1_ID}
#     Qualcomm detach ue    ${UE2_ID}
#     Qualcomm attach ue    ${UE2_ID}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     Qualcomm Start DL Data    ${UE2_ID}    ${UE2_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     Wait '60s' for stabible
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT}
#     Qualcomm Stop DL Data    ${UE2_ID}    ${UE2_DL_PORT}
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
# online change pcell CSIbundling enable
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-10316/NRBTS-10316/NRCELL-1    actPerCsiReportBundlingTddFr1    true    online
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
# switch to gNB10316_ABIO
#     taf.pdu.setup pdu  FACOM   host=10.108.134.48  alias=gnb
#     taf.pdu.get port status   1   gnb
#     taf.pdu.power off  port=1   pdu_device=gnb
#     Wait '5s' for stabible
#     taf.pdu.get port status   1   gnb
#     taf.pdu.get port status   2   gnb
#     taf.pdu.power on   port=2   pdu_device=gnb
#     taf.pdu.get port status   2   gnb
#     comment   power off 10317
#     comment   taf.pdu.setup pdu  FACOM   host=10.108.163.177  alias=gnb1
#     comment   taf.pdu.get port status   4   gnb1
#     comment   taf.pdu.power off  port=4   pdu_device=gnb1
#     comment   Wait '2s' for stabible
# 
# Prepare for nsa env
# #    Unblock one 4G cell    287    ${4G_S1_local_IP}
#     Wait '10s' for stabible
#     Set ue to NSA    ${UE1_ID}
#     Wait '5s' for stabible
#     Set ue to NSA    ${UE2_ID}
#     Wait '5s' for stabible
#     Set ue to NSA    ${UE3_ID_8450}
# 
# Prepare for sa env
#     Set ue to SA    ${UE1_ID}
#     Wait '5s' for stabible
#     Set ue to SA    ${UE2_ID}
#     Wait '5s' for stabible
#     Set ue to SA    ${UE3_ID_8450}
# 
# Set ue to NSA
#     [Arguments]    ${ue_id}
#     ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
#     Wait '5s' for stabible
#     Qualcomm Write Nvitem    ${ue_id}    80000    80
#     Wait '5s' for stabible
#     Qualcomm Write Nvitem    ${ue_id}    74213    1099511627776
#     Qualcomm Write Nvitem    ${ue_id}    74087    0
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
#     Wait '30s' for stabible
#     Qualcomm Set Apn    ${ue_id}    NSA     stdata1
#     Wait '5s' for stabible
# 
# 
# 
# Set ue to SA
#     [Arguments]    ${ue_id}
#     ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
#     Wait '5s' for stabible
#     Qualcomm Write Nvitem    ${ue_id}    80000    64
#     Wait '5s' for stabible
#     Qualcomm Write Nvitem    ${ue_id}    74213    0
#     Qualcomm Write Nvitem    ${ue_id}    74087    1099511627776
#     Qualcomm Write Nvitem    ${ue_id}    67218    1
#     Qualcomm Write Nvitem    ${ue_id}    73991    0
#     Wait '2s' for stabible
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
#     Wait '30s' for stabible
#     Qualcomm Set Apn    ${ue_id}    SA    stdata1
#     Wait '5s' for stabible
# 
# Unblock one 4G cell
#     [Arguments]    ${phy_cell_id}    ${bts_id}=192.168.255.129    ${alias}=block
#     TAF_ADMIN.connect to    bts_host=${bts_id}    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}    TAF_ADMIN.Get Parameters For All    LNCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.blockingState}'=='Unblocked'    TAF_ADMIN.block cell   ${nrcel.id}    
#    ...    timeout=60    connection=${alias}
#     Wait '5s' for stabible
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.phyCellId}'=='${phy_cell_id}'    TAF_ADMIN.unblock cell    ${nrcel.id}    
#    ...    timeout=60    connection=${alias}
#     \    Run Keyword If    '${nrcel.phyCellId}'=='${phy_cell_id}+1'    TAF_ADMIN.unblock cell    ${nrcel.id}    
#    ...    timeout=60    connection=${alias}
#     TAF_ADMIN.teardown    connection=${alias}
# 
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
# 
# Download qualcomm log
#     [Arguments]    ${UE_trace_file}    ${export_grid}    ${name}    ${txt_file_path}=${TXT_DEF_PATH}
#     ${qc_log}    qualcomm export to txt with qcat    ${UE_trace_file}    ${txt_file_path}    filter=${export_grid}
#     sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${UE_trace_file}    ${test_log_directory()}/
#     sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${qc_log}
#     ...              ${test_log_directory()}/${name}
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
