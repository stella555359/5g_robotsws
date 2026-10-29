# *** Settings ***
# Test Timeout      60 minutes
# Suite Setup       Qualcomm Common Suite Setup
# Suite Teardown    Qualcomm Common Suite Teardown
# Test Setup        Qualcomm Common Test Setup
# Test Teardown     Qualcomm Common Test Teardown
# Force Tags    qualcomm10316    owner_pennwang    SBTS22R2    SBTS23R1
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# @{LOG_NAME_LIST}    gnb_snapshot
# ${DL_PORT}    5005
# ${UL_PORT}    5002
# ${DL_LOG}    /tmp/dl_tput.txt
# ${UL_LOG}    /tmp/ul_tput.txt
# ${SEND_DATA_CMD}    -u -t 8000 -i 1 -p 5001 -P 1 -f m -b 1400.00M -l 1400B -T 64
# ${UL_SEND_DATA_CMD}    -u -c 192.168.255.1 -P 1 -i 1 -f m -w 4M -b 200M -t 6000
# ${SCFC_NAME}    SCFC_7922_case43.xml
# ${ATT}    ${CONFIG_DIR_PATH}/qualcomm_config/att_case42.csv
# ${PHASE}    ${CONFIG_DIR_PATH}/qualcomm_config/phase_case42.csv
# 
# *** Test Cases ***
# CB007922_case43_C_1b_intraL2RT_Single_UE_DL_UL_peak_SA_with_5GC001070_guardSy_2_mixBandWith
#     Prepare for sa env
#     Qualcomm prepare gnb onair
#     Attach ue with name and make call stable    ue1_name    ${DL_PORT}    ${DL_LOG}    ${SEND_DATA_CMD}
#     Start capture only gnb syslog in 'after_onair' file
#     ${tput_file}    Attach qualcomm ue with dlul data and download qualcomm log    ue1_name    ${DL_PORT}    ${UL_PORT}
#     ...    ${DL_LOG}    ${UL_LOG}    ${SEND_DATA_CMD}    ${UL_SEND_DATA_CMD}    first
#     ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    ${ul_tput}    ${ul_bler}    Get ue throughput and bler    ${tput_file}
#     run keyword and continue on failure    should_be_true    ${pcell_tput} > 1060000
#     run keyword and continue on failure    should_be_true    ${scell_tput} > 840000
#     run keyword and continue on failure    should_be_true    ${pcell_bler} == 0
#     run keyword and continue on failure    should_be_true    ${scell_bler} == 0
#     run keyword and continue on failure    should_be_true    ${ul_tput} > 0
#     run keyword and continue on failure    should_be_true    ${ul_bler} < 10
#     Stop capture only gnb syslog in 'after_onair' file
# 
# 
# 
# *** Keywords ***
# Get ue throughput and bler
#     [Arguments]    ${txt_file_name}
#     log to console    start to get ue throughput and bler
#     ${pcell_tput}    get_dl_pcell_tput    ${test_log_directory()}/${txt_file_name}
#     ${scell_tput}    get_dl_scell_tput    ${test_log_directory()}/${txt_file_name}
#     ${pcell_bler}    get_dl_pcell_bler    ${test_log_directory()}/${txt_file_name}
#     ${scell_bler}    get_dl_scell_bler    ${test_log_directory()}/${txt_file_name}
#     ${ul_tput}    get_ul_pcell_tput    ${test_log_directory()}/${txt_file_name}
#     ${ul_bler}    get_ul_pcell_bler    ${test_log_directory()}/${txt_file_name}
#     [Return]    ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    ${ul_tput}    ${ul_bler}
# 
# 
# Prepare for sa env
#     Set attenuation    ${ATT}
#     Set phase    ${PHASE}
#     Set ue to SA    ${UE1_ID}