# *** Settings ***
# Suite Setup       Qualcomm Common Suite Setup
# Suite Teardown    Qualcomm Common Suite Teardown
# Test Setup        Qualcomm Common Test Setup
# Test Teardown     Qualcomm Common Test Teardown
# Force Tags        qualcomm    owner_l3gao    SBTS22R2   SBTS22R4   SBTS00    SBTS23R1
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
# ${UE1_DL_PORT_1}    5001
# ${UE1_DL_PORT_2}    5002
# ${UE1_UL_PORT}    5003
# ${UE1_DL_SERVER_LOG}    /tmp/iperf_server_on_ue_log.txt
# ${UE1_UL_SERVER_LOG}    /tmp/iperf_server_on_pc_log.txt
# ${UE1_DL_CLIENT_EXTRA_CMD}    -u -t 800 -i 1 -P 1 -f m -b 1400.00M -l 1400B -T 64
# ${UE1_UL_CLIENT_EXTRA_CMD}    -u -c 192.168.255.1 -P 1 -i 1 -f m -w 4M -b 200M -t 600
# ${EXPORT_GRID}    Common Displays;Events and Debug Msgs vs. Time
# ${SCFC_NAME}     7922_CASE53_SCFC.xml
# ${GNB_SWCONFIG_QUAL_NAME}    qual_swconfig_126.txt
# ${TTITRACE_TAG}    ttitrace
# ${ATT_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/CA_Mumimo_att_10db.csv
# ${PHASE_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/CA_Mumimo_phase_10db.csv
# ${FIX_RANK4}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x04
# 
# 
# *** Test Cases ***
# CB007922_case53_C_5b_intraL2RT_SA_CA_SSBBF_interwork_with_pCSI_multiplexing_on_pucch_4RX_actPerCsi_scell
#     Qualcomm prepare gnb onair
#     Start capture only gnb syslog in 'after_onair' file
#     Attach one qualcomm ue and make call stable
#     Qualcomm detach ue    ${UE1_ID}
#     Qualcomm attach ue    ${UE1_ID}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Qualcomm Start UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${UE1_UL_SERVER_LOG}    ${UE1_UL_CLIENT_EXTRA_CMD}
# #    qualcomm_send_qxdm_command    ${UE1_ID}    ${FIX_RANK4}
#     Wait '60s' for stabible
#     ${log_path_dl_ul}    Get qualcomm log    ${UE1_ID}
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}
#     Qualcomm Stop UL Data    ${UE1_ID}    ${UE1_UL_PORT}
#     Download qualcomm log    ${log_path_dl_ul}.hdf    ${export_grid}    Throughput_${UE1_ID}_raw.txt
#     Qualcomm detach ue    ${UE1_ID}
#     ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    Get ue DL throughput and bler    Throughput_${UE1_ID}_raw.txt
#     ${pcell_tput_ul}    ${pcell_bler_ul}    Get ue UL throughput and bler    Throughput_${UE1_ID}_raw.txt
#     run keyword and continue on failure    should_be_true    ${pcell_tput} > 1080000
#     run keyword and continue on failure    should_be_true    ${scell_tput} > 1080000
#     run keyword and continue on failure    should_be_true    ${pcell_bler} < 3
#     run keyword and continue on failure    should_be_true    ${scell_bler} < 3
#     run keyword and continue on failure    should_be_true    ${pcell_tput_ul} > 90000
#     run keyword and continue on failure    should_be_true    ${pcell_bler_ul} < 10
# 
#     Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_7922_case53_1.json
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     Wait '120s' for stabible
#     Attach one qualcomm ue and make call stable
#     Qualcomm detach ue    ${UE1_ID}
#     Qualcomm attach ue    ${UE1_ID}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Qualcomm Start UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${UE1_UL_SERVER_LOG}    ${UE1_UL_CLIENT_EXTRA_CMD}
#     Wait '60s' for stabible
#     ${log_path_dl_ul}    Get qualcomm log    ${UE1_ID}
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}
#     Qualcomm Stop UL Data    ${UE1_ID}    ${UE1_UL_PORT}
#     Download qualcomm log    ${log_path_dl_ul}.hdf    ${export_grid}    Throughput_${UE1_ID}_raw.txt
#     Qualcomm detach ue    ${UE1_ID}
#     ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    Get ue DL throughput and bler    Throughput_${UE1_ID}_raw.txt
#     ${pcell_tput_ul}    ${pcell_bler_ul}    Get ue UL throughput and bler    Throughput_${UE1_ID}_raw.txt
#     run keyword and continue on failure    should_be_true    ${pcell_tput} > 1080000
#     run keyword and continue on failure    should_be_true    ${scell_tput} > 1080000
#     run keyword and continue on failure    should_be_true    ${pcell_bler} < 3
#     run keyword and continue on failure    should_be_true    ${scell_bler} < 3
#     run keyword and continue on failure    should_be_true    ${pcell_tput_ul} > 90000
#     run keyword and continue on failure    should_be_true    ${pcell_bler_ul} < 10
#     Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_7922_case53.json
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     Attach one qualcomm ue and make call stable
#     Qualcomm detach ue    ${UE1_ID}
#     Qualcomm attach ue    ${UE1_ID}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Qualcomm Start UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${UE1_UL_SERVER_LOG}    ${UE1_UL_CLIENT_EXTRA_CMD}
#     Wait '60s' for stabible
#     ${log_path_dl_ul}    Get qualcomm log    ${UE1_ID}
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}
#     Qualcomm Stop UL Data    ${UE1_ID}    ${UE1_UL_PORT}
#     Download qualcomm log    ${log_path_dl_ul}.hdf    ${export_grid}    Throughput_${UE1_ID}_raw.txt
#     Qualcomm detach ue    ${UE1_ID}
#     ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    Get ue DL throughput and bler    Throughput_${UE1_ID}_raw.txt
#     ${pcell_tput_ul}    ${pcell_bler_ul}    Get ue UL throughput and bler    Throughput_${UE1_ID}_raw.txt
#     run keyword and continue on failure    should_be_true    ${pcell_tput} > 1080000
#     run keyword and continue on failure    should_be_true    ${scell_tput} > 1000000
#     run keyword and continue on failure    should_be_true    ${pcell_bler} < 3
#     run keyword and continue on failure    should_be_true    ${scell_bler} < 3
#     run keyword and continue on failure    should_be_true    ${pcell_tput_ul} > 90000
#     run keyword and continue on failure    should_be_true    ${pcell_bler_ul} < 10
#     Stop capture only gnb syslog in 'after_onair' file
# 
# *** Keywords ***
# Attach one qualcomm ue and make call stable
#     Qualcomm detach ue    ${UE1_ID}
#     Qualcomm attach ue    ${UE1_ID}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Wait '60s' for stabible
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
# online change pcell CSIbundling enable
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-10316/NRBTS-10316/NRCELL-1    actPerCsiReportBundlingTddFr1    true    online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible