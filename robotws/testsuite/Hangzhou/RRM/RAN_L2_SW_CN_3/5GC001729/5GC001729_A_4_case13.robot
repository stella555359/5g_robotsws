# *** Settings ***
# Suite Setup       Qualcomm Common Suite Setup
# Suite Teardown    Qualcomm Common Suite Teardown
# Test Setup        Qualcomm Common Test Setup
# #Test Teardown     Qualcomm Common Test Teardown
# Force Tags        qualcomm    owner_l3gao    SBTS22R2   SBTS22R4   SBTS00    SBTS23R1
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# Library           taf.sbts.oam.coam.admin
# Library           taf.pdu
# 
# Documentation     beamform_beamset6 100mhz_80mhz refinebeam_true 4DL4UL dlmimo_open4X4 SA frame_1106_0ms_6symbol
# ...     actPdschAtSsbSlots_P_enable_S_disable prach_96
# ...     peak downlink 1330+985 uplink 134
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport
# ${UE1_ID}         10a5c6e6
# ${UE1_DL_PORT_1}    5001
# ${UE1_DL_PORT_2}    5002
# ${UE1_UL_PORT}    5003
# ${UE1_DL_SERVER_LOG}    /tmp/iperf_server_on_ue_log.txt
# ${UE1_UL_SERVER_LOG}    /tmp/iperf_server_on_pc_log.txt
# ${UE1_DL_CLIENT_EXTRA_CMD}    -u -t 800 -i 1 -P 1 -f m -b 1400.00M -l 1400B -T 64
# ${UE1_UL_CLIENT_EXTRA_CMD}    -u -c 192.168.255.1 -P 1 -i 1 -f m -w 4M -b 200M -t 600
# ${EXPORT_GRID}    Common Displays;Events and Debug Msgs vs. Time
# ${SCFC_NAME}      1729_CASE13_SCFC.xml
# ${dmc_file}    ${CONFIG_DIR_PATH}/qualcomm_config/NR5G_Debugging_TP.dmc
# ${GNB_SWCONFIG_QUAL_NAME}    qual_swconfig_126.txt
# ${TTITRACE_TAG}    ttitrace
# 
# *** Test Cases ***
# 5GC001729_Case13_A_4e_Period_CSI_RS_Transmission_and_reception_onPucch_BF
#     Qualcomm prepare gnb onair
#     Start capture only gnb syslog in 'after_onair' file
#     Attach one qualcomm ue and make call stable
#     Qualcomm detach ue    ${UE1_ID}
#     Qualcomm attach ue    ${UE1_ID}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Qualcomm Start UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${UE1_UL_SERVER_LOG}    ${UE1_UL_CLIENT_EXTRA_CMD}
#     Wait '60s' for stable
#     ${log_path_dl_ul}    Get qualcomm log    ${UE1_ID}
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}
#     Qualcomm Stop UL Data    ${UE1_ID}    ${UE1_UL_PORT}
#     Download qualcomm log    ${log_path_dl_ul}.hdf    ${export_grid}    Throughput_${UE1_ID}_raw.txt
#     #re_active TP check
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Qualcomm Start UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${UE1_UL_SERVER_LOG}    ${UE1_UL_CLIENT_EXTRA_CMD}
#     ${log_path_reactive}    Get qualcomm log    ${UE1_ID}
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}
#     Qualcomm Stop UL Data    ${UE1_ID}    ${UE1_UL_PORT}
#     Qualcomm detach ue    ${UE1_ID}
#     Download qualcomm log    ${log_path_reactive}.hdf    ${export_grid}    Throughput_${UE1_ID}_raw_reacitve.txt
#     ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    Get ue DL throughput and bler
#     ...   Throughput_${UE1_ID}_raw.txt
#     ${pcell_tput_ul}    ${pcell_bler_ul}    Get ue UL throughput and bler    Throughput_${UE1_ID}_raw.txt
#     run keyword and continue on failure    should_be_true    ${pcell_tput} > 1300000
#     run keyword and continue on failure    should_be_true    ${scell_tput} > 980000
#     run keyword and continue on failure    should_be_true    ${pcell_bler} < 3
#     run keyword and continue on failure    should_be_true    ${scell_bler} < 3
#     run keyword and continue on failure    should_be_true    ${pcell_tput_ul} > 116000
#     run keyword and continue on failure    should_be_true    ${pcell_bler_ul} < 5
#     #re_active TP check
#     ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    Get ue DL throughput and bler    
#     ...    Throughput_${UE1_ID}_raw_reacitve.txt
#     ${pcell_tput_ul}    ${pcell_bler_ul}    Get ue UL throughput and bler    Throughput_${UE1_ID}_raw_reacitve.txt
#     run keyword and continue on failure    should_be_true    ${pcell_tput} > 1300000
#     run keyword and continue on failure    should_be_true    ${scell_tput} > 980000
#     run keyword and continue on failure    should_be_true    ${pcell_bler} < 3
#     run keyword and continue on failure    should_be_true    ${scell_bler} < 3
#     run keyword and continue on failure    should_be_true    ${pcell_tput_ul} > 116000
#     run keyword and continue on failure    should_be_true    ${pcell_bler_ul} < 5
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
# Get qualcomm log
#     [Arguments]    ${ue_id}    ${log_path}=${TXT_DEF_PATH}
#     Qualcomm Start Qxdm Trace    ${ue_id}    ${dmc_file}
#     Wait '15s' for stabible
#     ${absolutely_path}    Qualcomm Stop Qxdm Trace    ${ue_id}    ${log_path}
#     [Return]    ${absolutely_path}
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti
# 
# check TP and bler with ttitrace
#     [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}
#     ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
#     ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
#     @{keys}  Get Dictionary Keys   ${a}
#     : FOR      ${key}     IN     @{keys}
#     \    ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
#     \    should be true  ${result}>${throughput}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/
