# *** Settings ***
# Suite Setup       AiC Common Suite Setup
# Suite Teardown    AiC Common Suite Teardown
# Test Setup        AiC Common Test Setup
# Test Teardown     AiC Common Test Teardown
# Force Tags        CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH    SBTS00
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# ${DU_SCF}        SCFC_VDU_CB007922_case15.xml
# ${CU_SCF}        SCFC_VCU_CB007922_case15.xml
# ${AIRPHONE_NAME}    iphy_2aeqe_case2.xml
# ${WTS_CFG}       CB007922_case15.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog
# ${EGATE_TAG}    ADD
# ${CSI_CMD1}    csi_override_testmode_nr profile_id\=2 cqi\=15 ri_mode\=fixed ri\=1
#                ...     pmi_mode\=fixed pmi\=124 cri_mode\=fixed cri\=0 li_mode\=fixed li\=1
# ${CSI_CMD2}   ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2
# ${UE1_A1_EVENT}    ue_measurement_send_nr id\=1 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
# @{Rdparameter}    0x10041:5
# 
# ${UE_ID}          11
# ${UE_ID_2}        16
# ${EGATE_TAG}      ADD
# ${UE_COUNT}       5    # number of each ue
# ${STABLETIME}     1s
# 
# *** Test Cases ***
# CB007922_case15_A_6b_interL2RT_intraBand_Multiple_UE_DL_UL_data_scheduling_NSA_and_blind_SCell_addition_10ue
#     AIC Perform Full Commission And Reach Onair    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${DU_SCF}
# 	...    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/WTS/${WTS_CFG}     ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${CU_SCF}
# 
# 	Start capture gnb and ap syslog in 'after_onair' File
#     Execute AP Command before attach
#     Attach LTE CAUE
#     Attach LTE NCAUE
#     NSA send data
#     Collect AP egate log    ${EGATE_TAG}
#     run keyword and continue on failure    Analyse scelladd in rrclog
#     run keyword and continue on failure    Check throughput
#     Capture ttitrace and Check log
# 
#     Airphone NSA Stop Data Traffic And Detach UE
#     Collect AP egate log    ${EGATE_TAG}
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# *** Keywords ***
# Check throughput
#     wait '10s' for stable
#     Wait until keyword succeeds    60s    5s    Verify CAUE throughput
#     Wait until keyword succeeds    60s    5s    Verify NCAUE throughput
#     ${total_tput}    evaluate    ${caue_tput}+${ncaue_tput}
#     Log To Console    total_tput:${total_tput}
# 
# Attach LTE CAUE
#     :FOR    ${num}    IN RANGE    ${UE_ID}    ${UE_ID}+${UE_COUNT}
#     \   Airphone Nsa Attach    ${num}
#     \   Wait time to stable
# #    \   airphone_execute_egate_command    ue_measurement_send_nr id\=${num} meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# Attach LTE NCAUE
#     :FOR    ${num}    IN RANGE    ${UE_ID_2}    ${UE_ID_2}+${UE_COUNT}
#     \   Wait time to stable
#     \   Airphone Nsa Attach    ${num}
# 
# NSA send data
#     :FOR    ${num}    IN RANGE    ${UE_ID}    ${UE_ID}+${UE_COUNT}*2
#     \   NSA send ue '${num}' mutiple trf '4' for each '175M' DL data
# 
# Airphone NSA Stop Data Traffic And Detach UE
#     :FOR    ${num}    IN RANGE    ${UE_ID}    ${UE_ID}+${UE_COUNT}*2
#     \   Airphone NSA Stop Data Traffic    ${num}    DL
#     \   Airphone NSA Detach    ${num}
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Verify CAUE throughput
#     wait '10s' for stable
#     ${caue_tput}    set variable    ${0}
#     :FOR    ${num}    IN RANGE    ${UE_ID}    ${UE_ID}+${UE_COUNT}
#     \   ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=1    type=pdsch    tput_type=ave
#     \   ${dl_throughput_scell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=2    type=pdsch    tput_type=ave
#     \   ${caue_tput}    evaluate    (${caue_tput}+${dl_throughput_pcell}+${dl_throughput_scell})
#     \   set test variable    ${caue_tput}
#     \   Log To Console    pcell_tput:${dl_throughput_pcell}
#     \   Log To Console    scell_tput:${dl_throughput_scell}
#     \   should_be_true    ${dl_throughput_pcell}>20000
#     \   should_be_true    ${dl_throughput_scell}>20000
#     Log To Console    caue_tput:${caue_tput}
# 
# Verify NCAUE throughput
#     wait '10s' for stable
#     ${ncaue_tput}    set variable    ${0}
#     set test variable    ${ncaue_tput}
#     :FOR    ${num}    IN RANGE    ${UE_ID_2}    ${UE_ID_2}+${UE_COUNT}
#     \   ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=1    type=pdsch    tput_type=ave
#     \   ${ncaue_tput}    evaluate    (${ncaue_tput}+${dl_throughput_pcell})
#     \   set test variable    ${ncaue_tput}
#     \   Log To Console    pcell_tput:${dl_throughput_pcell}
#     \   should_be_true    ${dl_throughput_pcell}>50000
#     Log To Console    ncaue_tput:${ncaue_tput}
# 
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd_NSA_case15.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# NSA send ue '${ue_id}' mutiple trf '${number}' for each '${ul_data}' UL data
#     :FOR    ${num}    IN RANGE    1    ${number}+1
#     \   Airphone NSA Start Data Traffic    ${ue_id}    DL    ${ul_data}    duration=6000s    trf_id=${num}
#     Wait Throughput Timer    5s
# 
# Capture ttitrace and Check log
#     ${id}    VDU Start TTiTrace Log
#     Wait '2s' for stable
#     VDU Stop TTiTrace Log    ${id}
#     VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}/All/tti
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_no_bler_case15.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Wait time to stable
#     sleep    ${STABLETIME}
# 
# Enable RD syslog in AP Swconfig
#         Modify AP swconfig    0x10041:5
