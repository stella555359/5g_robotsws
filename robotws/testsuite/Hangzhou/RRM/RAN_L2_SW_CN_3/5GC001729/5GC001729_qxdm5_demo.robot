# *** Settings ***
# Suite Setup       Qualcomm Common Suite Setup
# Suite Teardown    Qualcomm Common Suite Teardown
# Test Setup        Qualcomm Common Test Setup
# Test Teardown     Qualcomm Common Test Teardown
# Force Tags    qualcomm    SBTS22R2    SBTS23R1
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# @{LOG_NAME_LIST}    gnb_snapshot     sosreport
# ${DL_PORT}    5001
# ${UL_PORT}    5002
# ${DL_LOG}    /tmp/iperf_server_on_ue_log.txt
# ${UL_LOG}    /tmp/iperf_server_on_pc_log.txt
# ${SEND_DATA_CMD}    -u -t 600 -i 1 -p 5001 -P 1 -f m -b 1400.00M -l 1400B -T 64
# ${SCFC_NAME}    SCFC_qualcomm.xml
# ${ATT_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/att.csv
# 
# 
# *** Test Cases ***
# qxdm5_demo_case
# 
#     Set attenuation    ${ATT_FILE_PATH}
#     Qualcomm prepare gnb onair
#     Attach ue with name and make call stable    ue1_name    ${DL_PORT}    ${DL_LOG}    ${SEND_DATA_CMD}
#     Start capture only gnb syslog in 'after_onair' file
#     ${tput_file}    Attach qualcomm ue and download qualcomm log    ue1_name    ${DL_PORT}    ${DL_LOG}    ${SEND_DATA_CMD}    non
#     ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    Get ue throughput and bler    ${tput_file}
#     run keyword and continue on failure    should_be_true    ${pcell_tput} > 420000
#     run keyword and continue on failure    should_be_true    ${scell_tput} == 0
#     run keyword and continue on failure    should_be_true    ${pcell_bler} < 10
#     run keyword and continue on failure    should_be_true    ${scell_bler} < 10
# 
#     Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta.json
#     Wait '20s' for stabible
#     ${tput_file}    Attach qualcomm ue and download qualcomm log    ue1_name    ${DL_PORT}    ${DL_LOG}    ${SEND_DATA_CMD}    ca
#     ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    Get ue throughput and bler    ${tput_file}
#     run keyword and continue on failure    should_be_true    ${pcell_tput} > 420000
#     run keyword and continue on failure    should_be_true    ${scell_tput} > 420000
#     run keyword and continue on failure    should_be_true    ${pcell_bler} < 10
#     run keyword and continue on failure    should_be_true    ${scell_bler} < 10
#     Stop capture only gnb syslog in 'after_onair' file
# 
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
