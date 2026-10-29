# *** Settings ***
# Suite Setup       Qualcomm Common Suite Setup
# Suite Teardown    Qualcomm Common Suite Teardown
# Test Setup        Qualcomm Common Test Setup
# Test Teardown     Qualcomm Common Test Teardown
# Force Tags    qualcomm10317    owner_pennwang    SBTS22R2   SBTS22R4   SBTS00   l3gao    SBTS23R1
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport
# ${UE1_ID}         95fe0e6e
# ${DL_PORT}    5005
# ${UL_PORT}    5002
# ${DL_LOG}    /tmp/iperf_server_on_ue_log.txt
# ${UL_LOG}    /tmp/iperf_server_on_pc_log.txt
# ${SEND_DATA_CMD}    -u -t 8000 -i 1 -p 5001 -P 1 -f m -b 1400.00M -l 1400B -T 64
# ${SCFC_NAME}    7922_CASE58_SCFC.xml
# ${ATT}    ${CONFIG_DIR_PATH}/qualcomm_config/1729_case13_att.csv
# ${PHASE}    ${CONFIG_DIR_PATH}/qualcomm_config/1729_case13_phase.csv
# 
# *** Test Cases ***
# 5GC001729_Case29_A_3_Single_UE_Peak_BW80_80_closedmode44_256qam_64qam
# #    Qualcomm prepare gnb onair
#     Start capture only gnb syslog in 'after_onair' file
#     Attach ue with name and make call stable    ue1_name    ${DL_PORT}    ${DL_LOG}    ${SEND_DATA_CMD}
#     ${tput_file}    Attach qualcomm ue and download qualcomm log    ue1_name    ${DL_PORT}    ${DL_LOG}    ${SEND_DATA_CMD}    first
#     ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    Get ue throughput and bler    ${tput_file}
#     run keyword and continue on failure    should_be_true    ${pcell_tput} > 590000
#     run keyword and continue on failure    should_be_true    ${scell_tput} > 465000
#     run keyword and continue on failure    should_be_true    ${pcell_bler} == 0
#     run keyword and continue on failure    should_be_true    ${scell_bler} == 0
#     Online change to 64qam
#     Attach ue with name and make call stable    ue1_name    ${DL_PORT}    ${DL_LOG}    ${SEND_DATA_CMD}
#     ${tput_file}    Attach qualcomm ue and download qualcomm log    ue1_name    ${DL_PORT}    ${DL_LOG}    ${SEND_DATA_CMD}    second
#     ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    Get ue throughput and bler    ${tput_file}
#     run keyword and continue on failure    should_be_true    ${pcell_tput} > 440000
#     run keyword and continue on failure    should_be_true    ${scell_tput} > 345000
#     run keyword and continue on failure    should_be_true    ${pcell_bler} == 0
#     run keyword and continue on failure    should_be_true    ${scell_bler} == 0
#     Stop capture only gnb syslog in 'after_onair' file
# 
# 
# 5GC001729_Case6_A_3_Single_UE_Peak_BW100_80_open22_256qam_64qam
#     Start capture only gnb syslog in 'after_onair' file
#     Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_case06_10316.json
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     Attach ue with name and make call stable    ue1_name    ${DL_PORT}    ${DL_LOG}    ${SEND_DATA_CMD}
#     ${tput_file}    Attach qualcomm ue and download qualcomm log    ue1_name    ${DL_PORT}    ${DL_LOG}    ${SEND_DATA_CMD}    third
#     ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    Get ue throughput and bler    ${tput_file}
#     run keyword and continue on failure    should_be_true    ${pcell_tput} > 440000
#     run keyword and continue on failure    should_be_true    ${scell_tput} > 345000
#     run keyword and continue on failure    should_be_true    ${pcell_bler} == 0
#     run keyword and continue on failure    should_be_true    ${scell_bler} == 0
#     Stop capture only gnb syslog in 'after_onair' file
# 
# 
# *** Keywords ***
# Get ue throughput and bler
#     [Arguments]    ${txt_file_name}
#     log to console    start to get ue throughput and bler
#     ${UE1_pcell_tput}    get_dl_pcell_tput    ${test_log_directory()}/${txt_file_name}
#     ${UE1_scell_tput}    get_dl_scell_tput    ${test_log_directory()}/${txt_file_name}
#     ${UE1_pcell_bler}    get_dl_pcell_bler    ${test_log_directory()}/${txt_file_name}
#     ${UE1_scell_bler}    get_dl_scell_bler    ${test_log_directory()}/${txt_file_name}
#     [Return]    ${UE1_pcell_tput}    ${UE1_scell_tput}    ${UE1_pcell_bler}    ${UE1_scell_bler}
# 
# Online change to 64qam
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-10316/NRBTS-10316/NRCELL-1    actDl256Qam    false    online
#     Perform online change value    MRBTS-10316/NRBTS-10316/NRCELL-2    actDl256Qam    false    online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
# 
# Prepare for sa env
#     Set attenuation    ${ATT}
#     Set phase    ${PHASE}
#     Set ue to SA    ${UE1_ID}
