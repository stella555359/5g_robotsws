# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_sasun    AP    SBTS22R2    SBTS22R4    SBTS23R1
# ...   CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# #${GNB_SWCONFIG_NAME}    gnb_swconfig.txt
# #${AP_SWCONFIG_NAME}    ap_swconfig.txt
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_14.xml
# ${AIRPHONE_NAME}    IPHY_AEQN_AEHC_4CELL.xml
# ${WTS_NAME}       SANSA7922_case14.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${UE_ID}          11
# ${UE_ID_2}        12
# ${EGATE_TAG}      ADD
# ${B_S}            beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=0,1,2,3 csirs_bestbeam\=2 csirs_rsrp_best\=-44 csirs_rsrp_avg\=-50
# ${BS_MODE1_P}        ue_testmode_set_nr id\=11 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=8
# ${BS_MODE1_S}       ue_testmode_set_nr id\=11 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=9
# ${BS_MODE2_P}        ue_testmode_set_nr id\=12 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=8
# ${BS_MODE2_S}       ue_testmode_set_nr id\=12 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=9
# 
# *** Test Cases ***
# CB007922_case14_A_6a_intraL2RT_intraBand_Multiple_UE_DL_data_scheduling_NSA_with_refineBF_and_blind_SCell_addition
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Execute AP Command before attach
#     Set Refine Beam
#     Attach LTE UE1
#     Attach LTE UE2
#     airphone_execute_egate_command    ${BS_MODE1_S}
#     airphone_execute_egate_command    ${BS_MODE2_S}
#     NSA send ue '${UE_ID}' mutiple trf '2' for each '175M' DL data
#     NSA send ue '${UE_ID_2}' mutiple trf '2' for each '175M' DL data
#     NSA send ue '${UE_ID}' mutiple trf '1' for each '50M' UL data
#     NSA send ue '${UE_ID_2}' mutiple trf '1' for each '50M' UL data
#     Collect AP egate log    ${EGATE_TAG}
#     Analyse scelladd in rrclog
#     Check throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti1'
#     Airphone NSA Stop Data Traffic    ${UE_ID}    DL
#     Airphone NSA Stop Data Traffic    ${UE_ID}    UL
#     Airphone NSA Stop Data Traffic    ${UE_ID_2}    DL
#     Airphone NSA Stop Data Traffic    ${UE_ID_2}    UL
#     Airphone NSA Detach    ${UE_ID}
#     Airphone NSA Detach    ${UE_ID_2}
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Set Refine Beam
#     airphone_execute_egate_command    ${B_S}
#     airphone_execute_egate_command    ${BS_MODE1_P}
#     airphone_execute_egate_command    ${BS_MODE2_P}
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Attach LTE UE1
#     Airphone Nsa Attach    ${UE_ID}
# 
# Attach LTE UE2
#     Airphone Nsa Attach    ${UE_ID_2}    profile_id=None
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Verify throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>100000
#     should_be_true    ${dl_throughput_scell1}>100000
#     ${dl_throughput_pcell_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID_2}    scell_id=8    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID_2}    scell_id=9    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell_ue2}>100000
#     should_be_true    ${dl_throughput_scell1_ue2}>100000
# 
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd_NSA_1.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# NSA send ue '${ue_id}' mutiple trf '${number}' for each '${ul_data}' UL data
#     : FOR    ${num}    IN RANGE    1    ${number}+1
#     \    Airphone NSA Start Data Traffic    ${ue_id}    DL    ${ul_data}    duration=6000s    trf_id=${num}
#     Wait Throughput Timer    5s
# 
# Check ttitrace
#     [Arguments]    ${tti_ini}=tti_dl_refine_0.ini
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${tti_ini}    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
