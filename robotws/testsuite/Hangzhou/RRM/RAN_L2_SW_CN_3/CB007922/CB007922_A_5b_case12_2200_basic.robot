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
# Documentation    beamform_beamset6 8mhz_80mhz refinebeam_false 8DL4UL dlmimo_8X4 SA frame_1208_2symbol_4DL1UL
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
# ${SCFC_NAME}      7922_CASE12_SCFC.xml
# ${GNB_SWCONFIG_QUAL_NAME}    qual_swconfig_126.txt
# ${TTITRACE_TAG}    ttitrace
# ${ATT_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/CA_Mumimo_att_10db.csv
# ${PHASE_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/CA_Mumimo_phase_10db.csv
# 
# *** Test Cases ***
# CB007922_case12_A_5b_interL2RT_intraBand_SA_Single_UE_DL_UL_data_scheduling_with_5GC002200
#     Qualcomm prepare gnb onair
#     Wait '20s' for stabible
#     Start capture only gnb syslog in 'after_onair' file
#     Attach one qualcomm ue and make call stable
#     Qualcomm detach ue    ${UE1_ID}
#     Qualcomm attach ue     ${UE1_ID}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_1}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT_2}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Qualcomm Start UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${UE1_UL_SERVER_LOG}    ${UE1_UL_CLIENT_EXTRA_CMD}
#     Wait '60s' for stabible
#     ${log_path}    Get qualcomm log    ${UE1_ID}
#     Download qualcomm log    ${log_path}.hdf    ${EXPORT_GRID}   Throughput_${UE1_ID}_raw.txt
#     ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    Get ue DL throughput and bler    
#    ...    Throughput_${UE1_ID}_raw.txt
#     ${pcell_tput_ul}    ${pcell_bler_ul}    Get ue UL throughput and bler    Throughput_${UE1_ID}_raw.txt
#     run keyword and continue on failure    should_be_true    ${pcell_tput} > 960000
#     run keyword and continue on failure    should_be_true    ${scell_tput} > 960000
#     run keyword and continue on failure    should_be_true    ${pcell_bler} < 3
#     run keyword and continue on failure    should_be_true    ${scell_bler} < 3
#     run keyword and continue on failure    should_be_true    ${pcell_tput_ul} > 75000
#     run keyword and continue on failure    should_be_true    ${pcell_bler_ul} < 3
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
#     \    Comment    Log to console    \n physical cell ${nrcel.phyCellId} is ${nrcel.blockingState}
#     \    Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.blockingState}'=='Unblocked'
#          ...    Run Keywords    TAF_ADMIN.lock    ${nrcel.id}    timeout=60    connection=${alias}  AND    sleep    60
#     TAF_ADMIN.teardown    connection=${alias}
# Unblock Cell
#     [Arguments]    ${alias}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Comment    Log to console    \n physical cell ${lncel.phyCellId} is ${lncel.blockingState}
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
# 
# Qualcomm attach ue hardly
#     [Arguments]    ${ue_id}
#     : FOR    ${reboot_count}    IN RANGE    1    3
#     \    ${out}    ${attach_status}     Run Keyword And Ignore Error   Qualcomm Attach With Adb    ${ue_id}
#     \    Run Keyword if    '${attach_status}'=='True'    Exit For Loop
#     \    UE Reboot    ${ue_id}
#     \    Sleep    70
#     \    ${reboot_count}    Set Variable    ${reboot_count}+1
#     \    Qualcomm Detach With Adb      ${ue_id}
