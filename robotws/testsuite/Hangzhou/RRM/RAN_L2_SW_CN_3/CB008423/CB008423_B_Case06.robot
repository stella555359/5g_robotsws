# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags    CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    CRT    RAN_5G_TDD    RAN_5G    owner_menzheng
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      SCFC_06.xml
# ${AIRPHONE_NAME}    iphy-AZHA_2cells.xml
# ${WTS_NAME}       TDD_CPRI_2cells.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${EGATE_TAG}    ADD
# ${PCELL_THRESHOLD}    140000
# ${SCELL_THRESHOLD}    0
# 
# *** Test Cases ***
# CB008423_B_Case06_C5_overheeting_blindactivation_nonBF
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     Set traffic type to internal
#     UE can attach successfully to 5G cell
#     Internal send mutiple trf '2' for each '175M' DL data
#     Collect AP egate log    ${EGATE_TAG}
#     analyse scelladd in rrclog
#     Check pcell and scell have throughput
#     Override Scell CQI trigger overheating threshold
#     Wait until keyword succeeds    60s    5s    Check SA ue '${ue_id}' 'pcell' dl throught should '> ${PCELL_THRESHOLD}'
#     Wait until keyword succeeds    60s    5s    Check SA ue '${ue_id}' 'scell' dl throught should '== ${SCELL_THRESHOLD}'
#     Stop data transfer
#     Detach UE
# 
# *** Keywords ***
# Wait time to check throughput
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait '${remaining_time}s' for stabible
# 
# Wait reach threshold
#     [Arguments]    ${check_point}
#     Wait Until Keyword Succeeds    200s    10s    ${check_point}
# 
# Override Scell CQI trigger overheating threshold
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=1 cqi_mode\=fixed
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=0 ri\=1 cqi_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=1
# 
# Check pcell and scell have throughput
#      Wait '10s' for stabible
#      ${pcell_tp}=    airphone_get_throughput_on_specific_scell    1    0    type=pdsch    tput_type=ave
#      ${scell_tp}=    airphone_get_throughput_on_specific_scell    1    1    type=pdsch    tput_type=ave
#      should be true    ${pcell_tp}>140000
#      should be true    ${scell_tp}>140000
# 
# Stop data transfer
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}    direction=dl
# 
# Detach UE
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# UE can attach successfully to 5G cell
#     Airphone SA Attach  ${UE_ID}  300
#     Airphone Pdu Session Setup  ${UE_ID}  ${PDU_ID}  ${SLICE_ID}  ${GW_ID}
# 
