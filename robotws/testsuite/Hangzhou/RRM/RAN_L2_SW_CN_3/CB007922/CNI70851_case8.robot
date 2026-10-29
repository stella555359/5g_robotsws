# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CIT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS22R3    owner_jinxiao    SBTS23R1
# ...               SBTS22R4    AP    CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}          11
# ${SCFC_NAME}      CNI70851_case8_scfc.xml
# ${AIRPHONE_NAME}    IPHY_AEHC_2CELLs.xml
# ${WTS_NAME}       SANSA_CNI_70851.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${EGATE_TAG}      RLQ
# ${SYSLOG_TAG}     after_onair
# ${CSI_override_1}    csi_override_testmode_nr profile_id\=2 cqi\=15 ri_mode\=fixed ri\=1
#                      ...    pmi_mode\=fixed pmi\=909 cri_mode\=fixed cri\=1 li_mode\=fixed li\=1
# ${CSI_override_2}    csi_override_testmode_nr profile_id\=3 cqi\=15 ri_mode\=fixed ri\=1
#                      ...    pmi_mode\=fixed pmi\=648 cri_mode\=fixed cri\=1 li_mode\=fixed li\=1
# 
# *** Test Cases ***
# CNI70851_case08_intraL2RT_NSA_5GC002200_DRX_PMIbeam_switch
#     Modify AP swconfig    0x10041:1
#     Prepare gnb onair
#     Start capture gnb and ap syslog in '${SYSLOG_TAG}' file
#     Execute AP Command before attach
#     Attach LTE UE
#     NSA send ue '${UE_ID}' mutiple trf '5' for each '175M' DL data
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15
#     Collect AP egate log    ${EGATE_TAG}
#     run keyword and continue on failure    Analyse scelladd in rrclog
#     Check throughput
#     Override PMI-1
#     Start collect ttitrace
#     Wait for '10s' to stop ttitrace with name'tti'
#     run keyword and continue on failure    Check ttitrace
#     Override PMI-2
#     Start collect ttitrace
#     Wait for '10s' to stop ttitrace with name'tti-2'
#     run keyword and continue on failure    Check ttitrace-2
#     Airphone NSA Stop Data Traffic    ${UE_ID}    DL
#     Airphone NSA Detach    ${UE_ID}
#     Collect AP egate log    all
# 
# *** Keywords ***
# Verify throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>200000
#     should_be_true    ${dl_throughput_scell1}>200000
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Attach LTE UE
#     Airphone Nsa Attach    ${UE_ID}    profile_id=None
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# Override PMI-1
#     airphone_execute_egate_command    ${CSI_override_1}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=csi_override action\=activate profile_id\=2 scell\=8-9
# 
# Override PMI-2
#     airphone_execute_egate_command    ${CSI_override_2}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=csi_override action\=activate profile_id\=3 scell\=8-9
# 
# UE send A1 event again
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# UE send A2 event
#     airphone_execute_egate_command    ue_measurement_send_nr event\=A2 id\=11 meas_id\=2 rs_type\=ssb scell\=9 scell_rsrp\=30
# 
# Check ttitrace -2
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_pmi-2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check Pcell throughput
#     Wait until keyword succeeds    60s    5s    Verify Pcell throughput
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd_NSA_1.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Test Teardown
#     Common Test Teardown
#     Stop capture gnb and ap syslog in '${SYSLOG_TAG}' file
# 
# Wait '${time} ' to check log
#     sleep    ${time}
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_pmi-1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
