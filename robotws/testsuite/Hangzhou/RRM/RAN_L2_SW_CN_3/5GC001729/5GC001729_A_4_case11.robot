# *** Settings ***
# Suite Setup       Qualcomm Common Suite Setup
# Suite Teardown    Qualcomm Common Suite Teardown
# Test Setup        Qualcomm Common Test Setup
# Test Teardown     Qualcomm Common Test Teardown
# Force Tags        qualcomm    owner_l3gao     SBTS22R4   SBTS00    SBTS23R1
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# Library           taf.sbts.oam.coam.admin
# Library           taf.pdu
# 
# Documentation     beamform_beamset1 80mhz_80mhz refinebeam_false 4DL4UL dlmimo_closed4X4 SA
# ...       frame_1106_0ms_6symbol actPdschAtSsbSlots_enable
# ...       peak downlink 628+628 uplink 101
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# @{LOG_NAME_LIST}    gnb_snapshot     sosreport
# ${UE1_ID}         10a5c6e6
# ${UE1_DL_PORT_1}    5001
# ${UE1_DL_PORT_2}    5002
# ${UE1_UL_PORT}    5003
# ${UE1_DL_SERVER_LOG}    /tmp/iperf_server_on_ue_log.txt
# ${UE1_UL_SERVER_LOG}    /tmp/iperf_server_on_pc_log.txt
# ${UE1_DL_CLIENT_EXTRA_CMD}    -u -t 800 -i 1 -P 1 -f m -b 1400.00M -l 1400B -T 64
# ${UE1_UL_CLIENT_EXTRA_CMD}    -u -c 192.168.255.1 -P 1 -i 1 -f m -w 4M -b 200M -t 600
# ${EXPORT_GRID}    Common Displays;Events and Debug Msgs vs. Time
# ${SCFC_NAME}      1729_CASE11_SCFC.xml
# ${GNB_SWCONFIG_QUAL_NAME}    qual_swconfig_126.txt
# ${TTITRACE_TAG}    ttitrace
# ${ATT_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/CA_Mumimo_att_10db.csv
# ${PHASE_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/CA_Mumimo_phase_10db.csv
# ${FIX_RANK2}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x02
# ${4G_S1_local_IP}   10.108.175.74
# 
# *** Test Cases ***
# 5GC001729_Case11_A_4d_Period_k1_caculation_sameBW
# #    Qualcomm prepare gnb onair
# #    Start capture only gnb syslog in 'after_onair' file
# #    Prepare for sa env
# #    Set Mcs Channel Phase And Attenuation    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}
# #    Attach one qualcomm ue and make call stable
# #    Qualcomm detach ue    ${UE1_ID}
# #    Qualcomm attach ue    ${UE1_ID}
# #    Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
# #    Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
# #    Qualcomm Start UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${UE1_UL_SERVER_LOG}    ${UE1_UL_CLIENT_EXTRA_CMD}
# #    Wait '10s' for stabible
# #    ${log_path_dl_ul}    Get qualcomm log    ${UE1_ID}
# #    Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}
# #    Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}
# #    Qualcomm Stop UL Data    ${UE1_ID}    ${UE1_UL_PORT}
# #    Qualcomm detach ue    ${UE1_ID}
# #    Download qualcomm log    ${log_path_dl_ul}.hdf    ${export_grid}    Throughput_${UE1_ID}_raw.txt
#     ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    Get ue DL throughput and bler    
#     ...    Throughput_${UE1_ID}_raw.txt
# #    ${pcell_tput_ul}    ${pcell_bler_ul}    Get ue UL throughput and bler    Throughput_${UE1_ID}_raw.txt
# #    run keyword and continue on failure    should_be_true    ${pcell_tput} > 609000
# #    run keyword and continue on failure    should_be_true    ${scell_tput} > 609000
# #    run keyword and continue on failure    should_be_true    ${pcell_bler} < 3
# #    run keyword and continue on failure    should_be_true    ${scell_bler} < 3
# #    run keyword and continue on failure    should_be_true    ${pcell_tput_ul} > 97000
# #    run keyword and continue on failure    should_be_true    ${pcell_bler_ul} < 5
# #    Stop capture only gnb syslog in 'after_onair' file
# 
#     Prepare for nsa env
# 
# *** Keywords ***
# Attach one qualcomm ue and make call stable
#     Qualcomm detach ue    ${UE1_ID}
#     Qualcomm attach ue    ${UE1_ID}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Wait '20s' for stabible
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}
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
# switch to gNB10316_ABIL
#     taf.pdu.setup pdu  FACOM   host=10.108.134.48  alias=gnb
# #    power off 10316_ASIB_ABIO
#     taf.pdu.get port status   1   gnb
#     taf.pdu.get port status   2   gnb
#     taf.pdu.get port status   3   gnb
#     taf.pdu.get port status   4   gnb
#     taf.pdu.power off  port=2   pdu_device=gnb
#     taf.pdu.power off  port=3   pdu_device=gnb
#     taf.pdu.power off  port=4   pdu_device=gnb
#     taf.pdu.power on  port=1   pdu_device=gnb
# 
# 
# Block gNB
#     [Arguments]    ${alias}
#     TAF_ADMIN.connect to    bts_host=10.108.175.81    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If  '${nrcel.administrativeState}'=='Unlocked'
#          ...    Run Keywords    TAF_ADMIN.lock    ${nrcel.id}    timeout=60    connection=${alias}  AND    sleep    60
#     TAF_ADMIN.teardown    connection=${alias}
# 
# Prepare for nsa env
#     Unblock one 4G cell    287    ${4G_S1_local_IP}
#     Wait '10s' for stabible
#     Set ue to NSA    ${UE1_ID}
# 
# Prepare for sa env
#     Set ue to SA    ${UE1_ID}
#     Wait '5s' for stabible
# 
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
