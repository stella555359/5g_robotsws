# *** Settings ***
# Suite Setup       Qualcomm Common Suite Setup
# Suite Teardown    Qualcomm Common Suite Teardown
# Test Setup        Qualcomm Common Test Setup
# Test Teardown     Qualcomm Common Test Teardown
# Force Tags        qualcomm    owner_l3gao    SBTS00   SBTS22R4   CRT
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# Library           taf.sbts.oam.coam.admin
# Library           taf.pdu
# 
# 
# Documentation     gNB10316  @{Rdparameter}
# ...    PMcounter 0x340000:15     log print 0x580264:3    powerbalance enable 0x580396:1
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
# ${DL_LOG}    /tmp/iperf_server_on_ue_log.txt
# ${UL_LOG}    /tmp/iperf_server_on_pc_log.txt
# ${DL_SEND_DATA_CMD}    -u -t 3600 -i 1 -P 1 -f m -b 1400.00M -l 1400B -T 64
# ${UL_SEND_DATA_CMD}    -u -c 192.168.255.1 -P 1 -i 1 -f m -w 4M -b 200M -t 1800
# ${EXPORT_GRID}    ${None}
# &{GNBMIRRORINGCONFIG}     L2HI_MIRRORING='true'   L2RT_MIRRORING='true'     NUMBER_OF_FILES=17    FILE_SIZE_MBYTES=200
# ${SCFC_NAME}     CNI-84878_SCFC_case01.xml
# ${GNB_SWCONFIG_QUAL_NAME}     qual_swconfig_10316_modified.txt
# ${GNB_SWCONFIG_QUAL_NAME_before}  qual_swconfig_10316.txt
# ${TTITRACE_TAG}    ttitrace
# ${4G_S1_local_IP}    10.108.175.74
# @{Rdparameter}    0x340000:15   0x580264:3   0x580477:1   0x580396:1
# ${ATT_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/8305_case23_22att_10db.csv
# ${PHASE_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/8305_case23_22phase_10db.csv
# ${FIX_RANK4}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x04
# ${FIX_RANK3}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x03
# ${FIX_RANK2}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x02
# ${FIX_RANK1}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x01
# ${dmc_file}    ${CONFIG_DIR_PATH}/qualcomm_config/NR5G_Debugging_TP_powersaving.dmc
# 
# *** Test Cases ***
# CNI84878_case01_A_B1_Beam_power_balancing_optimizations_for_CB008305_with_varible_rank_without_tapering
#     Add GNB swconfig    @{Rdparameter}
# #    Qualcomm prepare gnb onair
#     Start capture only gnb syslog in 'attach_rrc' file
#     Set Mcs Channel Phase And Attenuation    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}
#     Attach two qualcomm ue and make call stable    ${UE1_ID}   ${UE3_ID}
#     Qualcomm detach ue    ${UE2_ID}
#     ${ue1_logs_path}   ${ue3_logs_path}   Capture two Qualcomm UE RRC logs   ${UE1_ID}   ${UE3_ID}   ${dmc_file}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     Qualcomm Start DL Data    ${UE3_ID}    ${UE3_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     Wait '30s' for stable
#     Download qualcomm log    ${ue1_logs_path}.hdf    ${EXPORT_GRID}   ${UE1_ID}_rrc_raw.txt
#     Download qualcomm log    ${ue3_logs_path}.hdf    ${EXPORT_GRID}   ${UE3_ID}_rrc_raw.txt
#     log to console     check RRC logs
#     run keyword and continue on failure    filter_qcat_message
#     ...       ${test_log_directory()}${/}${UE1_ID}_rrc_raw.txt      ::=    ${test_log_directory()}${/}RRC_UE1.txt
#     run keyword and continue on failure    filter_qcat_message
#     ...       ${test_log_directory()}${/}${UE3_ID}_rrc_raw.txt      ::=    ${test_log_directory()}${/}RRC_UE3.txt
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...        ${CURDIR}/ini/84878_case01_rrclog_UE1.ini  p    save_log_directory=${test_log_directory()}
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...        ${CURDIR}/ini/84878_case01_rrclog_UE3.ini   p    save_log_directory=${test_log_directory()}
#     Wait '10s' for stable
#     run keyword and continue on failure    Stop capture only gnb syslog in 'attach_rrc' file
# 
#     Start capture only gnb syslog in 'rank4_rank4' file
#     qualcomm_send_qxdm_command    ${UE1_ID}    ${FIX_RANK4}
#     qualcomm_send_qxdm_command    ${UE3_ID}    ${FIX_RANK4}
#     Wait '1s' for stable
# #    Start collect bip log
# #    run keyword and continue on failure   Wait for '2s' to stop bip log with name'bip_rank4_rank4'
#     Start collect ttitrace
#     run keyword and continue on failure   Wait for '2s' to stop ttitrace with name'tti_rank4_rank4'
#     run keyword and continue on failure   check TP and bler with ttitrace   600   600    2    tti_rank4_rank4   tti_case22_bwpdisable
#     run keyword and continue on failure    Stop capture only gnb syslog in 'rank4_rank4' file
# 
#     Start capture only gnb syslog in 'rank1_rank4' file
#     qualcomm_send_qxdm_command    ${UE1_ID}    ${FIX_RANK1}
#     qualcomm_send_qxdm_command    ${UE3_ID}    ${FIX_RANK4}
#     Wait '1s' for stable
# #    Start collect bip log
# #    run keyword and continue on failure   Wait for '2s' to stop bip log with name'bip_rank1_rank4'
#     Start collect ttitrace
#     run keyword and continue on failure   Wait for '2s' to stop ttitrace with name'tti_rank1_rank4'
#     run keyword and continue on failure   check TP and bler with ttitrace   600   150    2    tti_rank1_rank4   tti_case22_bwpdisable
#     run keyword and continue on failure    Stop capture only gnb syslog in 'rank1_rank4' file
# 
#     Start capture only gnb syslog in 'rank2_rank4' file
#     qualcomm_send_qxdm_command    ${UE1_ID}    ${FIX_RANK2}
#     qualcomm_send_qxdm_command    ${UE3_ID}    ${FIX_RANK4}
#     Wait '1s' for stable
# #    Start collect bip log
# #    run keyword and continue on failure   Wait for '2s' to stop bip log with name'bip_rank2_rank4'
#     Start collect ttitrace
#     run keyword and continue on failure   Wait for '2s' to stop ttitrace with name'tti_rank2_rank4'
#     run keyword and continue on failure   check TP and bler with ttitrace   600   300    2    tti_rank2_rank4   tti_case22_bwpdisable
#     run keyword and continue on failure    Stop capture only gnb syslog in 'rank2_rank4' file
# 
#     Start capture only gnb syslog in 'rank3_rank4' file
#     qualcomm_send_qxdm_command    ${UE1_ID}    ${FIX_RANK3}
#     qualcomm_send_qxdm_command    ${UE3_ID}    ${FIX_RANK4}
#     Wait '1s' for stable
# #    Start collect bip log
# #    run keyword and continue on failure   Wait for '2s' to stop bip log with name'bip_rank3_rank4'
#     Start collect ttitrace
#     run keyword and continue on failure   Wait for '2s' to stop ttitrace with name'tti_rank3_rank4'
#     run keyword and continue on failure   check TP and bler with ttitrace   600   450    2    tti_rank3_rank4   tti_case22_bwpdisable
#     run keyword and continue on failure    Stop capture only gnb syslog in 'rank3_rank4' file
# 
#     Start capture only gnb syslog in 'rank4_rank4' file
#     qualcomm_send_qxdm_command    ${UE1_ID}    ${FIX_RANK4}
#     qualcomm_send_qxdm_command    ${UE3_ID}    ${FIX_RANK4}
#     Wait '1s' for stable
# #    Start collect bip log
# #    run keyword and continue on failure   Wait for '2s' to stop bip log with name'bip_rank4_rank4_2'
#     Start collect ttitrace
#     run keyword and continue on failure   Wait for '2s' to stop ttitrace with name'tti_rank4_rank4_2'
#     run keyword and continue on failure   check TP and bler with ttitrace   600   600    2    tti_rank4_rank4_2   tti_case22_bwpdisable
#     run keyword and continue on failure    Stop capture only gnb syslog in 'rank4_rank4' file
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT}
#     Qualcomm Stop DL Data    ${UE3_ID}    ${UE3_DL_PORT}
# 
# 
# *** Keywords ***
# Attach two qualcomm ue and make call stable
#     [Arguments]    ${UE1_ID}    ${UE2_ID}
#     Qualcomm detach ue    ${UE1_ID}
#     Qualcomm attach ue    ${UE1_ID}
#     Qualcomm detach ue    ${UE2_ID}
#     Qualcomm attach ue    ${UE2_ID}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     Qualcomm Start DL Data    ${UE2_ID}    ${UE2_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     Wait '20s' for stabible
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT}
#     Qualcomm Stop DL Data    ${UE2_ID}    ${UE2_DL_PORT}
# 
# switch to gNB10316_ABIO
#     taf.pdu.setup pdu  FACOM   host=10.108.134.48  alias=gnb
#     taf.pdu.get port status   1   gnb
#     taf.pdu.power off  port=1   pdu_device=gnb
#     Wait '2s' for stabible
#     taf.pdu.get port status   1   gnb
#     taf.pdu.get port status   3   gnb
#     taf.pdu.power off  port=3   pdu_device=gnb
#     Wait '2s' for stabible
#     taf.pdu.get port status   3   gnb
#     taf.pdu.get port status   4   gnb
#     taf.pdu.power off  port=4   pdu_device=gnb
#     Wait '2s' for stabible
#     taf.pdu.get port status   4   gnb
#     taf.pdu.get port status   2   gnb
#     taf.pdu.power on   port=2   pdu_device=gnb
#     taf.pdu.get port status   2   gnb
# 
# Prepare for nsa env
#     [Arguments]    ${UE1_ID}    ${UE2_ID}
#     Unblock one 4G cell    287    ${4G_S1_local_IP}
#     Wait '10s' for stabible
#     Set ue to SA    ${UE1_ID}
#     Wait '5s' for stabible
#     Set ue to SA    ${UE2_ID}
# #    Wait '5s' for stabible
# #    Set ue to NSA    ${UE3_ID_8450}
# 
# Prepare for sa env
#     [Arguments]    ${UE1_ID}    ${UE2_ID}
#     lock one 4G cell    287     ${4G_S1_local_IP}
#     Set ue to SA    ${UE1_ID}
#     Wait '5s' for stabible
#     Set ue to SA    ${UE2_ID}
#     Wait '5s' for stabible
# #    Set ue to SA    ${UE3_ID_8450}
# #    Wait '5s' for stabible
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
#     Wait '50s' for stabible
#     Qualcomm Set Apn    ${ue_id}    NSA     stdata3
#     Wait '5s' for stabible
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
#     Wait '50s' for stabible
#     Qualcomm Set Apn    ${ue_id}    SA    stdata3
#     Wait '5s' for stabible
# 
# Unblock one 4G cell
#     [Arguments]    ${phy_cell_id}    ${bts_id}=192.168.255.129    ${alias}=block
#     TAF_ADMIN.connect to    bts_host=${bts_id}    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}    TAF_ADMIN.Get Parameters For All    LNCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.phyCellId}'=='${phy_cell_id}' and '${nrcel.blockingState}'=='blocked'
#     ...  TAF_ADMIN.unblock cell    ${nrcel.id}    timeout=60    connection=${alias}
#     TAF_ADMIN.teardown    connection=${alias}
# 
# lock one 4G cell
#     [Arguments]    ${phy_cell_id}    ${bts_id}=192.168.255.129    ${alias}=block
#     TAF_ADMIN.connect to    bts_host=${bts_id}    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}    TAF_ADMIN.Get Parameters For All    LNCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.phyCellId}'=='${phy_cell_id}' and '${nrcel.blockingState}'=='unblocked'
#     ...   TAF_ADMIN.block cell    ${nrcel.id}    timeout=60    connection=${alias}
#     TAF_ADMIN.teardown    connection=${alias}
# 
# 
# Capture two Qualcomm UE RRC logs
#     [Arguments]    ${ue1_id}    ${ue2_id}     ${dmc}   ${log_path}=${TXT_DEF_PATH}
#     Qualcomm Start Qxdm Trace    ${ue1_id}    dmc_file=${dmc}
#     Qualcomm Start Qxdm Trace    ${ue2_id}    dmc_file=${dmc}
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
# 
# check TP and bler with ttitrace
#     [Arguments]    ${big_throughput}   ${samill_throughput}   ${time_avg}    ${tti_file}    ${ini_file}
#     ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
#     ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
#     @{keys}  Get Dictionary Keys   ${a}
#     : FOR      ${key}     IN     @{keys}
#     \    ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
#     \    log to console     ${result}
#     \    Run Keyword If  ${result}>(${big_throughput}+${samill_throughput})/2  should be true   ${result}>${big_throughput}
#     \    Run Keyword If  ${result}<(${big_throughput}+${samill_throughput})/2  should be true   ${result}>${samill_throughput}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/
# 
# check TP and bler with ttitrace rnti
#     [Arguments]    ${big_throughput}   ${samill_throughput}   ${time_avg}    ${tti_file}    ${ini_file}     ${rnti_list}
#     ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
#     ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
#     @{keys}  Get Dictionary Keys   ${a}
#     : FOR      ${key}     IN     @{rnti_list}
#     \    ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
#     \    log to console     ${result}
#     \    Run Keyword If  ${result}>(${big_throughput}+${samill_throughput})/2  should be true   ${result}>${big_throughput}
#     \    Run Keyword If  ${result}<(${big_throughput}+${samill_throughput})/2  should be true   ${result}>${samill_throughput}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/
# 
# Modify GNB swconfig
#     [Arguments]    @{Rdparameter}
#     Backup Swconfig    ${CURDIR}     gnb_swconfig.txt
#     setup_txt    src_file=${CURDIR}/gnb_swconfig.txt    save_path=${CURDIR}/gnb_swconfig_modify.txt
#     :FOR    ${parameter}    IN    @{Rdparameter}
#     \    modify txt node        ${parameter}
#     teardown txt
#     GNB Upload Swconfig    ${CURDIR}/gnb_swconfig_modify.txt
# 
# Add GNB swconfig
#     [Arguments]    @{Rdparameter}
#     Backup Swconfig    ${CURDIR}    gnb_swconfig.txt
#     setup_txt    src_file=${CONFIG_DIR_PATH}/${SW_BRANCH}/SWCONFIG/${GNB_SWCONFIG_QUAL_NAME_before}
#     ...     save_path=${CONFIG_DIR_PATH}/${SW_BRANCH}/SWCONFIG/${GNB_SWCONFIG_QUAL_NAME}
#     :FOR    ${parameter}    IN    @{Rdparameter}
#     \    run keyword and ignore error    delete txt node    ${parameter}
#     \    add txt node       ${parameter}
#     teardown txt
# 
# Capture two Qualcomm UE traffic logs
#     [Arguments]    ${ue1_id}    ${ue2_id}       ${log_path}=${TXT_DEF_PATH}
#     Qualcomm Start Qxdm Trace    ${ue1_id}    dmc_file=None
#     Qualcomm Start Qxdm Trace    ${ue2_id}    dmc_file=None
#     Wait '15s' for stabible
#     ${ue1_absolutely_path}    Qualcomm Stop Qxdm Trace    ${ue1_id}    ${log_path}   quit_app=false
#     ${ue2_absolutely_path}    Qualcomm Stop Qxdm Trace    ${ue2_id}    ${log_path}
#     [Return]    ${ue1_absolutely_path}     ${ue2_absolutely_path}
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti
# 
# Ping powersaving UE
#     [Arguments]    ${device_id}
#     ${ue_ip}=    Qualcomm Get Ip With Adb    ${device_id}
#     csn.connect to  10.108.183.187   username=ute  password=%EjvHVvvkQD6  alias=serve
#     ${ret}   csn.send command   /usr/bin/nohup ping ${ue_ip} -s 128 1>nul 2>&1 0</dev/null &    connection=serve
#     ${ret}   csn.execute  ps -ef | grep ping   connection=serve