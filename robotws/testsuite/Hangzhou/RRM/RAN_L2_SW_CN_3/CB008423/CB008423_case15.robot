# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    AP    owner_changyli
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD    CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# #${AP_SWCONFIG_NAME}    ap_swconfig.txt
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      8423_SCFC_CASE15.xml
# ${AIRPHONE_NAME}    iphy-AZHA_2cells.xml
# ${WTS_NAME}       TDD_CPRI_2cells.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${HO_CMD1}        ue_enb_param id\=11 drx_config\=off measurement_gap\=gp0:20 gap_trigger\=enb_and_gnb_triggered mgta\=ms0dot50 gap_purpose\=perUE
# ${UE_ID}          11
# ${EGATE_TAG}      ADD
# ${EGATE_GAP_TAG}    GAP
# 
# *** Test Cases ***
# CB008423_B_Case15_10_LTE_enforced_MGAP_configuration_for_TDD_FR1_CA_UE_by_SgNB_Modification
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Execute AP Command before attach
#     Attach LTE UE
#     NSA send ue '${UE_ID}' mutiple trf '6' for each '175M' DL data
#     Collect AP egate log    ${EGATE_TAG}
#     Analyse scelladd in rrclog
#     Check throughput
#     Trigger gap and modify ENDC
#     Collect AP egate log    ${EGATE_GAP_TAG}
#     Analyse gap setup dtx release in rrclog
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti'
#     Check ttitrace
#     Stop capture gnb and ap syslog in 'after_onair' file
#     Airphone NSA Stop Data Traffic    ${UE_ID}    DL
#     Airphone NSA Detach    ${UE_ID}
# 
# *** Keywords ***
# Verify throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>70000
#     should_be_true    ${dl_throughput_scell1}>70000
# 
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd_NSA.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Analyse gap setup dtx release in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/Gap_drx.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_GAP_TAG}_egate
# 
# Trigger gap
#     airphone_execute_egate_command    ${HO_CMD1}
# 
# UE send A2 Event
#     airphone_measurement_send_nr    id=11    meas_id=2    event=A2    rs_type=ssb srsrp_nr=30
#     Wait '4s' for stabible
# 
# UE send A1 event
#     airphone_measurement_send_nr    id=11    meas_id=3    event=A1    rs_type=ssb srsrp_nr=50
#     Wait '4s' for stabible
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     airphone_setup_x2_connection
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Trigger gap and modify ENDC
#     airphone_execute_egate_command    ${HO_CMD1}
#     UE send A2 Event
#     Wait '4s' for stabible
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Attach LTE UE
#     Airphone Nsa Attach    ${UE_ID}    profile_id=None
#     UE send A1 Event
# 
