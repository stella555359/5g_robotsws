# *** Settings ***
# Suite Setup       Qualcomm Common Suite Setup
# Suite Teardown    Qualcomm Common Suite Teardown
# Test Setup        Qualcomm Common Test Setup
# Test Teardown     Qualcomm Common Test Teardown
# Force Tags    qualcomm    owner_yuqq    SBTS22R2    SBTS23R1
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport
# ${UE1_ID}         95fe0e6e
# ${UE1_DL_PORT}    5001
# ${UE1_UL_PORT}    5002
# ${UE1_DL_SERVER_LOG}    /tmp/iperf_server_on_ue_log.txt
# ${UE1_UL_SERVER_LOG}    /tmp/iperf_server_on_pc_log.txt
# ${UE1_DL_CLIENT_EXTRA_CMD}    -u -t 600 -i 1 -p 5001 -P 1 -f m -b 1400.00M -l 1400B -T 64
# ${UE1_UL_CLIENT_EXTRA_CMD}    -u -t 600 -i 1 -p 5002 -P 1 -f m -b 140.00M -l 1400B -T 64
# ${export_grid}    Common Displays;Events and Debug Msgs vs. Time
# ${SCFC_NAME}    SCFC_qualcomm.xml
# ${ATT_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/att.csv
# 
# *** Test Cases ***
# 5GC001729_Case16_A_4h_SINR_adaptation_during_slots_by_the_UCI_added_to_PUSCH    
# 
#     Set attenuation    ${ATT_FILE_PATH}
#     Qualcomm prepare gnb onair
#     Qualcomm detach ue    ${UE1_ID}
#     Start capture only gnb syslog in 'after_onair' file
#     Qualcomm attach ue    ${UE1_ID}
#     Qualcomm Start UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${UE1_UL_SERVER_LOG}    ${UE1_UL_CLIENT_EXTRA_CMD}
#     Wait '20s' for stabible
#     ${log_path}    Get qualcomm log    ${UE1_ID}    ${UE1_UL_PORT}
#     Qualcomm Stop UL Data    ${UE1_ID}    ${UE1_UL_PORT}
#     Qualcomm detach ue    ${UE1_ID}
#     Download qualcomm log    ${log_path}.hdf    ${export_grid}    Throughput_${UE1_ID}_raw.txt
#     ${pcell_tput}    ${pcell_bler}    Get ue throughput and bler    Throughput_${UE1_ID}_raw.txt
#     run keyword and continue on failure    should_be_true    ${pcell_tput} > 100000
#     run keyword and continue on failure    should_be_true    ${pcell_bler} < 10
# 
# 
# *** Keywords ***
# Get ue throughput and bler
#     [Arguments]    ${txt_file_name}
#     log to console    start to get ue throughput and bler
#     ${UE1_pcell_tput}    get_ul_pcell_tput    ${test_log_directory()}/${txt_file_name}
#     ${UE1_pcell_bler}    get_ul_pcell_bler    ${test_log_directory()}/${txt_file_name}
#     [Return]    ${UE1_pcell_tput}    ${UE1_pcell_bler} 
