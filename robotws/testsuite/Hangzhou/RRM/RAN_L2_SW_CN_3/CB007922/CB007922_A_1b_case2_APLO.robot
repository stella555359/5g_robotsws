# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_penny    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS22R4    SBTS23R1
# ...   CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# 
# ${SCFC_NAME}      SCFC_case51_2AEQE_APLO.xml
# ${AIRPHONE_NAME}    IPHY_2AEQE_case51_aplo.xml
# ${WTS_NAME}       WTS_2AEQE_case51_aplo.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${PCELL_THRESHOLD}    900000
# ${SCELL_THRESHOLD}    900000
# ${PCELL_THRESHOLD_NONCA}    1100000
# ${UE_ID}    11
# 
# *** Test Cases ***
# CB007922_case02_A_1b_intraL2RT_Feature_deactivation_mixBandWith_NSA    
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
# 	Execute AP Command before attach
#     Airphone Nsa Attach    ${UE_ID}    profile_id=None    
#     NSA send ue '${UE_ID}' mutiple trf '15' for each '175M' DL data
#     sleep    10
#     run keyword and continue on failure    Check throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti'
#     run keyword and continue on failure    Check ttitrace
#     run keyword and continue on failure    Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_A_1b_case2.json
#     Airphone NSA Detach All
#     Airphone Nsa Attach    ${UE_ID}    profile_id=None
#     NSA send ue '${UE_ID}' mutiple trf '15' for each '175M' DL data
#     run keyword and continue on failure    Check throughput after change
#     Airphone NSA Detach All
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Wait reach threshold
#     [Arguments]    ${check_point}
#     Wait Until Keyword Succeeds    200s    10s    ${check_point}
# 
# Attach ue and check throughput
#     [Arguments]    ${ue_id}    ${s}    ${p}
#     NSA attach ue '${ue_id}' with 'TDD_NSA_AP_band41' cap and 'TDD_NSA_AP_band41_eutra' eutra cap to 5g cell
#     NSA send ue '${ue_id}' mutiple trf '6' for each '175M' DL data
#     Wait reach threshold    Check NSA ue '${ue_id}' 'pcell' dl throught should '> ${p}'
#     Wait reach threshold    Check NSA ue '${ue_id}' 'scell' dl throught should '> ${s}'
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 	
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Verify throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>780000
#     should_be_true    ${dl_throughput_scell1}>780000
# 
# Check throughput after change
#     Wait until keyword succeeds    60s    5s    Verify throughput after change
# 
# Verify throughput after change
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>1000000
# 
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd_NSA.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Test Teardown
#     Common Test Teardown
#     Stop capture gnb and ap syslog in '${SYSLOG_TAG}' file
# 	
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Set ue srs sinr
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 sinr_target_srs\=35 sinr_target_pucch\=-300 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=ul_sinr action\=activate profile_id\=1
# 
# 
