# *** Settings ***
# Suite Setup       Qualcomm Common Suite Setup
# Suite Teardown    Qualcomm Common Suite Teardown
# Test Setup        Qualcomm Common Test Setup
# Test Teardown     Qualcomm Common Test Teardown
# Force Tags        qualcomm    owner_l3gao     SBTS00    CRT
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# Library           taf.sbts.oam.coam.admin
# Library           taf.pdu
# 
# 
# Documentation     gNB10316  @{Rdparameter}
# ...    PMcounter 0x340000:15
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
# ${DL_SEND_DATA_CMD}    -u -t 800 -i 1 -P 1 -f m -b 1400.00M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_50kbps}    -u -t 800 -i 1 -P 1 -f m -b 0.05M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_100Mbps}    -u -t 800 -i 1 -P 1 -f m -b 100M -l 1400B -T 64
# ${UL_SEND_DATA_CMD}    -u -c 192.168.255.1 -P 1 -i 1 -f m -w 4M -b 200M -t 600
# ${UL_SEND_DATA_CMD_50kbps}    -u -c 192.168.255.1 -P 1 -i 1 -f m -w 4M -b 0.05M -t 600
# ${EXPORT_GRID_TP}    Common Displays;Events and Debug Msgs vs. Time
# ${EXPORT_GRID}    ${None}
# &{GNBMIRRORINGCONFIG}     L2HI_MIRRORING='true'   L2RT_MIRRORING='true'     NUMBER_OF_FILES=17    FILE_SIZE_MBYTES=200
# ${SCFC_NAME}     CB008305_case23.xml
# ${GNB_SWCONFIG_QUAL_NAME}     qual_swconfig_10316_modified.txt
# ${GNB_SWCONFIG_QUAL_NAME_before}  qual_swconfig_10316.txt
# ${TTITRACE_TAG}    ttitrace
# ${4G_S1_local_IP}    10.108.175.74
# @{Rdparameter}    0x340000:15
# ${ATT_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/8305_case23_22att.csv
# ${PHASE_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/8305_case23_22phase.csv
# ${FIX_RANK4}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x04
# ${FIX_RANK3}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x03
# ${FIX_RANK1}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x01
# ${dmc_file}    ${CONFIG_DIR_PATH}/qualcomm_config/NR5G_Debugging_TP_powersaving.dmc
# 
# *** Test Cases ***
# CB008305_C_B2_case23_rank4_Powersaving_CA
# #    Add GNB swconfig    @{Rdparameter}
# #    Qualcomm prepare gnb onair
#     Start capture only gnb syslog in 'rrc_attach_btslog' file
# #    Set Mcs Channel Phase And Attenuation    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}
#     Attach two qualcomm ue and make call stable    ${UE1_ID}   ${UE3_ID}
#     Qualcomm detach ue    ${UE2_ID}
#     ${ue1_logs_path}   ${ue3_logs_path}   Capture two Qualcomm UE RRC logs   ${UE1_ID}   ${UE3_ID}   ${dmc_file}
#     Wait '20s' for stabible
# 
#     Download qualcomm log    ${ue1_logs_path}.hdf    ${EXPORT_GRID}   ${UE1_ID}_rrc_raw.txt
#     Download qualcomm log    ${ue3_logs_path}.hdf    ${EXPORT_GRID}   ${UE3_ID}_rrc_raw.txt
#     log to console     check RRC logs
#     run keyword and continue on failure    filter_qcat_message
#     ...       ${test_log_directory()}${/}${UE1_ID}_rrc_raw.txt      ::=    ${test_log_directory()}${/}RRC_UE1.txt
#     run keyword and continue on failure    filter_qcat_message
#     ...       ${test_log_directory()}${/}${UE3_ID}_rrc_raw.txt      ::=    ${test_log_directory()}${/}RRC_UE3.txt
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...        ${CURDIR}/ini/8305_case22_rrclog_UE1.ini    p    save_log_directory=${test_log_directory()}
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...        ${CURDIR}/ini/8305_case22_rrclog_UE3.ini    p    save_log_directory=${test_log_directory()}
#     Wait '10s' for stabible
#     Stop capture only gnb syslog in 'rrc_attach_btslog' file
#     qualcomm_send_qxdm_command    ${UE1_ID}    ${FIX_RANK4}
#     qualcomm_send_qxdm_command    ${UE3_ID}    ${FIX_RANK4}
# 
# 
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     Ping powersaving UE    ${UE3_ID}
#     Wait '40s' for stable
#     Start capture only gnb syslog in 'btslog_1_bwp_enable_1g_and_ping' file
#     Start collect bip log
#     Start collect ttitrace
#     run keyword and continue on failure   Wait for '3s' to stop ttitrace with name'tti_1_bwp_enable_1g_and_ping'
#     run keyword and continue on failure   Wait for '3s' to stop bip log with name'bip_1_bwp_enable_1g_and_ping'
#     run keyword and continue on failure   check TP and bler with ttitrace    1000    0     2    tti_1_bwp_enable_1g_and_ping   tti_case22_bwpenable
#     kill ping all UE
#     Stop capture only gnb syslog in 'btslog_1_bwp_enable_1g_and_ping' file
# 
#     Qualcomm Start DL Data    ${UE3_ID}    ${UE3_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
# 
#     Start capture only gnb syslog in 'btslog_2_bwp_disable_1g_and_1g' file
#     Start collect bip log
#     Start collect ttitrace
#     run keyword and continue on failure   Wait for '3s' to stop ttitrace with name'tti_2_bwp_disable_1g_and_1g'
#     run keyword and continue on failure   Wait for '3s' to stop bip log with name'bip_2_bwp_disable_1g_and_1g'
#     run keyword and continue on failure   check TP and bler with ttitrace    1000   1000   2    tti_2_bwp_disable_1g_and_1g   tti_case22_bwpdisable
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT}
#     Qualcomm Stop DL Data    ${UE3_ID}    ${UE3_DL_PORT}
#     kill ping all UE
#     Stop capture only gnb syslog in 'btslog_2_bwp_disable_1g_and_1g' file
# 
#     Ping powersaving UE    ${UE1_ID}
#     Ping powersaving UE    ${UE3_ID}
#     Start capture only gnb syslog in 'btslog_3_bwp_enable_ping_and_ping' file
#     Start collect bip log
#     Start collect ttitrace
#     run keyword and continue on failure   Wait for '3s' to stop ttitrace with name'tti_3_bwp_enable_ping_and_ping'
#     run keyword and continue on failure   Wait for '3s' to stop bip log with name'bip_3_bwp_enable_ping_and_ping'
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case22_bwpdisable.ini    log_need_to_check=i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/tti_3_bwp_enable_ping_and_ping/
#     kill ping all UE
#     Stop capture only gnb syslog in 'btslog_3_bwp_enable_ping_and_ping' file
# 
# 
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     Qualcomm Start DL Data    ${UE3_ID}    ${UE3_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD_100Mbps}
#     Wait '40s' for stable
#     Start capture only gnb syslog in 'btslog_4_bwp_enable_1g_and_100mbps' file
#     Start collect bip log
#     Start collect ttitrace
#     run keyword and continue on failure   Wait for '3s' to stop ttitrace with name'tti_4_bwp_enable_1g_and_100mbps'
#     run keyword and continue on failure   Wait for '3s' to stop bip log with name'bip_4_bwp_enable_1g_and_100mbps'
#     run keyword and continue on failure   check TP and bler with ttitrace   1000     100    2    tti_4_bwp_enable_1g_and_100mbps   tti_case23_100m
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT}
#     Qualcomm Stop DL Data    ${UE3_ID}    ${UE3_DL_PORT}
#     wait '60s' for stabible
#     Stop capture only gnb syslog in 'btslog_4_bwp_enable_1g_and_100mbps' file
# 
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
#     comment   power off 10317
#     comment   taf.pdu.setup pdu  FACOM   host=10.108.163.177  alias=gnb1
#     comment   taf.pdu.get port status   4   gnb1
#     comment   taf.pdu.power off  port=4   pdu_device=gnb1
#     comment   Wait '2s' for stabible
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
# 
# kill ping all UE
#     csn.connect to  10.108.183.187   username=ute  password=%EjvHVvvkQD6  alias=serve
#     ${ret}   csn.execute  ps -ef | grep ping   connection=serve
#     ${ret}   csn.send command   pkill -9 ping    connection=serve
#     ${ret}   csn.execute  ps -ef | grep ping   connection=serve