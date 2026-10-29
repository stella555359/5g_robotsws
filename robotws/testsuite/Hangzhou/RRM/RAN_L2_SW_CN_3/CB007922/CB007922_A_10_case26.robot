# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        owner_ningyang    AP    SBTS22R2    SBTS00
# ...   CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_26.xml
# ${AIRPHONE_NAME}    IPHY_AEQN_AEHC_4CELL.xml
# ${WTS_NAME}       SANSA7922_interband_ho.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${HO_CMD1}        ue_enb_param id\=11 drx_config\=off measurement_gap\=gp0:20 gap_trigger\=enb_and_gnb_triggered mgta\=ms0dot50 gap_purpose\=perUE
# ${HO_CMD2}        ue_measurement_send_nr event\=A2 id\=11 meas_id\=2 rs_type\=ssb srsrp_nr\=30
# ${STABLETIME}     3s
# ${UE_ID}          11
# ${EGATE_TAG}      ADD
# ${EGATE_GAP_TAG}    GAP
# 
# *** Test Cases ***
# CB007922_case26_A_10_LTE_enforced_MGAP_configuration_for_TDD_FR1_CA_UE_by_SgNB_Modification
# 
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Execute AP Command before attach
#     Attach LTE UE
#     NSA send ue '${UE_ID}' mutiple trf '3' for each '175M' DL data
#     Collect AP egate log    ${EGATE_TAG}
#     Analyse scelladd in rrclog
#     Check throughput
#     ${remote info}=         Create Dictionary
#     ...   host=192.168.255.1
#     ...   user=toor4nsn
#     ...   password=oZPS0POrRieRtu
#     Start Tcpdump      remote_info=${remote info}     options=-i any -s 0 -v    name=remote
#     Trigger gap and modify ENDC
#     Collect AP egate log    ${EGATE_GAP_TAG}
#     Analyse gap setup dtx release in rrclog
#     Wait time to stable
#     stop tcpdump    name=remote
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
#     should_be_true    ${dl_throughput_pcell}>40000
#     should_be_true    ${dl_throughput_scell1}>80000
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
# Wait time to stable
#     sleep    ${STABLETIME}
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Trigger gap and modify ENDC
#     airphone_execute_egate_command    ${HO_CMD1}
#     airphone_execute_egate_command    ${HO_CMD2}
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Attach LTE UE
#     Airphone Nsa Attach    ${UE_ID}
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# UE send A1 event
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=50
