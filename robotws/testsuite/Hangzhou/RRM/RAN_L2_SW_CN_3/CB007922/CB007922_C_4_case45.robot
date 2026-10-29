# *** Settings ***
# Suite Setup       Qualcomm Common Suite Setup
# Suite Teardown    Qualcomm Common Suite Teardown
# Test Setup        Qualcomm Common Test Setup
# Test Teardown     Qualcomm Common Test Teardown
# Force Tags        qualcomm    owner_l3gao    SBTS22R2   SBTS22R4   SBTS00    SBTS23R1
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# Library           taf.sbts.oam.coam.admin
# 
# Documentation     beamform_beamset6 8mhz_80mhz refinebeam_false 8DL4UL dlmimo_8X4 SA frame_1208_2symbol_4DL1UL
# ...     actPdschAtSsbSlots_P_enable_S_disable prach_98
# ...     peak downlink_112_102  uplink 114
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
# ${SCFC_NAME}      7922_CASE45_SCFC.xml
# ${GNB_SWCONFIG_QUAL_NAME}    qual_swconfig_126.txt
# ${TTITRACE_TAG}    ttitrace
# ${ATT_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/CA_Mumimo_att_10db.csv
# ${PHASE_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/CA_Mumimo_phase_10db.csv
# ${ATT_FILE_PATH_mut_ssb2}    ${CONFIG_DIR_PATH}/qualcomm_config/att_20db_beam0_1_80_80_4layer_peak_port1_2_3_4.csv
# ${PHASE_FILE_PATH_mut_ssb2}    ${CONFIG_DIR_PATH}/qualcomm_config/phase_0db_beam0_1_80_80_4layer_peak_port1_2_3_4.csv
# 
# *** Test Cases ***
# CB007922_case45_C_4_interL2RT_Single_DL_UL_SA_with_SSB_muting_Scell_release
#     Qualcomm prepare gnb onair
#     Set Mcs Channel Phase And Attenuation    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}
#     Start capture only gnb syslog in 'after_onair' file
#     Attach one qualcomm ue and make call stable
#     Qualcomm detach ue    ${UE1_ID}
#     Qualcomm attach ue    ${UE1_ID}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Qualcomm Start UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${UE1_UL_SERVER_LOG}    ${UE1_UL_CLIENT_EXTRA_CMD}
#     Wait '60s' for stabible
#     ${log_path}    Get qualcomm log    ${UE1_ID}
#     Download qualcomm log    ${log_path}.hdf    ${EXPORT_GRID}   Throughput_${UE1_ID}_raw.txt
#     ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    Get ue DL throughput and bler    
#    ...    Throughput_${UE1_ID}_raw.txt
#     ${pcell_tput_ul}    ${pcell_bler_ul}    Get ue UL throughput and bler    Throughput_${UE1_ID}_raw.txt
#     run keyword and continue on failure    should_be_true    ${pcell_tput} > 920000
#     run keyword and continue on failure    should_be_true    ${scell_tput} > 930000
#     run keyword and continue on failure    should_be_true    ${pcell_bler} < 3
#     run keyword and continue on failure    should_be_true    ${scell_bler} < 3
#     run keyword and continue on failure    should_be_true    ${pcell_tput_ul} > 75000
#     run keyword and continue on failure    should_be_true    ${pcell_bler_ul} < 10
#     #MCS modification move to Muted ssb2
#     Set Mcs Channel Phase And Attenuation    ${ATT_FILE_PATH_mut_ssb2}    ${PHASE_FILE_PATH_mut_ssb2}
#     Wait '30s' for stabible
#     ${log_path_mut_ssb2}    Get qualcomm log    ${UE1_ID}
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}
#     Qualcomm detach ue    ${UE1_ID}
#     Download qualcomm log    ${log_path_mut_ssb2}.hdf    ${EXPORT_GRID}    Throughput_${UE1_ID}_raw_Scell_blocked.txt
#     ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    Get ue DL throughput and bler   
#    ...    Throughput_${UE1_ID}_raw_Scell_blocked.txt
#     run keyword and continue on failure    should_be_true    ${pcell_tput} > 900000
#     run keyword and continue on failure    should_be_true    ${scell_tput} == 0
#     run keyword and continue on failure    should_be_true    ${pcell_bler} < 5
#     run keyword and continue on failure    should_be_true    ${scell_bler} < 5
#     #MCS modification move back
#     Set Mcs Channel Phase And Attenuation    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}
#     Attach one qualcomm ue and make call stable
#     Qualcomm detach ue    ${UE1_ID}
#     Qualcomm attach ue    ${UE1_ID}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Qualcomm Start UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${UE1_UL_SERVER_LOG}    ${UE1_UL_CLIENT_EXTRA_CMD}
#     Wait '60s' for stabible
#     ${log_path_move_back}    Get qualcomm log    ${UE1_ID}
#     Download qualcomm log    ${log_path_move_back}.hdf    ${EXPORT_GRID}   Throughput_${UE1_ID}_raw_scell_unblocked.txt
#     ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    Get ue DL throughput and bler    
#    ...    Throughput_${UE1_ID}_raw_scell_unblocked.txt
#     run keyword and continue on failure    should_be_true    ${pcell_tput} > 920000
#     run keyword and continue on failure    should_be_true    ${scell_tput} > 930000
#     run keyword and continue on failure    should_be_true    ${pcell_bler} < 3
#     run keyword and continue on failure    should_be_true    ${scell_bler} < 3
#     run keyword and continue on failure    should_be_true    ${pcell_tput_ul} > 75000
#     run keyword and continue on failure    should_be_true    ${pcell_bler_ul} < 10
#     Stop capture only gnb syslog in 'after_onair' file
# 
# *** Keywords ***
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
# 
# Block Cell
#     [Arguments]    ${phy_cell_id}    ${alias}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Comment      Log to console    \n physical cell ${nrcel.phyCellId} is ${nrcel.blockingState}
#     \    Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.blockingState}'=='Unblocked'
#          ...    Run Keywords    TAF_ADMIN.lock    ${nrcel.id}    timeout=60    connection=${alias}  AND    sleep    60
#     TAF_ADMIN.teardown    connection=${alias}
# Unblock Cell
#     [Arguments]    ${alias}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Comment      Log to console    \n physical cell ${lncel.phyCellId} is ${lncel.blockingState}
#     \    Run Keyword If    '${nrcel.operationalState}'=='Disabled'
#          ...    Run Keywords    TAF_ADMIN.unlock     ${nrcel.id}    connection=${alias}  AND    sleep    60
# 
# Attach one qualcomm ue and make call stable
#     Qualcomm detach ue    ${UE1_ID}
#     Qualcomm attach ue    ${UE1_ID}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Wait '60s' for stabible
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}
