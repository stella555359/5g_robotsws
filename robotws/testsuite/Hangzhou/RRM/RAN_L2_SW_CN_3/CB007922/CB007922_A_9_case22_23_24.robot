# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags        CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    SBTS22R2    SBTS22R4
# ...   CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}         11
# ${SCFC_NAME}      7922_SCFC_A_9.xml
# ${AIRPHONE_NAME}    IPHY_AEQN_AEHC_4CELL.xml
# ${WTS_NAME}       SANSA7922_interband_intraMeNB.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${ENB_CELL_PARAM1}    enb_cell_param enb\=1 id\=1 allow_endc\=on
# ${ENB_CELL_PARAM2}    enb_cell_param enb\=1 id\=2 allow_endc\=on
# ${HO_CMD1}     ue_ho id\=11 ho_mode\=INTRA_LTE enb\=1 cell\=2
# ${ENB_CELL_PARAM}    enb_cell_param id\=2 enb\=1 allowed_bc_list_mrdc\=2:1
# ${ENB_CELL_PARAM3}    enb_cell_param id\=1 enb\=1 allowed_bc_list_mrdc\=2:1
# ${ENB_CELL_PARAM4}    enb_cell_param id\=2 enb\=1 allowed_bc_list_mrdc\=1:1
# ${STABLETIME}    10s
# 
# *** Test Cases ***
# CB007922_case22_A_9_Intra_MeNB_LTE_HO_without_SgNB_change_without_PSCell_change_CA_UE_traffic_keep
# 
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Execute AP Command before attach
#     Attach LTE UE
#     Send DL data to UE and check throughput
#     Trigger intra enb intraband handover
#     check throughput
#     Stop capture gnb and ap syslog in 'after_onair' file
#     Airphone NSA Detach    ue_id=11
# 
# CB007922_case23_A_9_Intra_MeNB_LTE_HO_without_SgNB_change_without_PSCell_change_CA_UE_scell_release_and_addition
#     Start capture gnb and ap syslog in 'after_onair' file
#     Attach LTE UE
#     Send DL data to UE and check throughput
#     UE SET AllowedBandlist for NONCA for cell2
#     Trigger intra enb intraband handover
#     check throughput for pcell
#     Stop capture gnb and ap syslog in 'after_onair' file
#     Airphone NSA Detach    ue_id=11
# 
# CB007922_case24_A_9_Intra_MeNB_LTE_HO_without_SgNB_change_without_PSCell_change_NonCA_UE_scell_additon
#     Start capture gnb and ap syslog in 'after_onair' file
#     UE SET AllowedBandlist for NONCA for cell1
#     UE SET AllowedBandlist for CA for cell2
#     Attach LTE UE
#     Send DL data to UE and check throughput for pcell
#     Trigger intra enb intraband handover
#     check throughput
#     Stop capture gnb and ap syslog in 'after_onair' file
#     Airphone NSA Detach    ue_id=11
# *** Keywords ***
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
#     airphone_execute_egate_command    ${ENB_CELL_PARAM1}
#     airphone_execute_egate_command    ${ENB_CELL_PARAM2}
# Attach LTE UE
#     Airphone Location Change    id=11    cell_id=1    enb=1
#     Airphone Nsa Attach     ${UE_ID}    profile_id=None
# 
# UE SET AllowedBandlist for NONCA for cell1
#     airphone_execute_egate_command    ${ENB_CELL_PARAM3}
# 
# UE SET AllowedBandlist for CA for cell2
#     airphone_execute_egate_command    ${ENB_CELL_PARAM4}
# 
# UE SET AllowedBandlist for NONCA for cell2
#     airphone_execute_egate_command    ${ENB_CELL_PARAM}
# 
# Send DL data to UE and check throughput
#     NSA send ue '${UE_ID}' mutiple trf '6' for each '175M' DL data
#     Wait time to stable
#     ${pcell_tp}=    airphone_get_throughput_on_specific_scell    11    8    type=pdsch    tput_type=ave
#     ${scell_tp}=    airphone_get_throughput_on_specific_scell    11    9    type=pdsch    tput_type=ave
#     should be true    ${pcell_tp}>0
#     should be true    ${scell_tp}>0
# 
# Send DL data to UE and check throughput for pcell
#     NSA send ue '${UE_ID}' mutiple trf '6' for each '175M' DL data
#     Wait time to stable
#     ${pcell_tp}=    airphone_get_throughput_on_specific_scell    11    8    type=pdsch    tput_type=ave
#     should be true    ${pcell_tp}>0
# 
# 
# 
# Send DL data to UE
#     NSA send ue '${UE_ID}' mutiple trf '6' for each '175M' DL data
#     Wait time to stable
# ENB CELL SET Allowedbandlist
#     airphone_execute_egate_command    ${ENBCELL_CMD}
# Check scell add succesfully
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_scelladd.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Trigger intra enb intraband handover
#     airphone_execute_egate_command     ${HO_CMD1}
#     Wait time to stable
#     check handover sucessfully
# 
# check handover sucessfully
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/handover   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_handover.ini    log_need_to_check=u
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover
# 
# check throughput
#      ${pcell_tp}=    airphone_get_throughput_on_specific_scell    11    8    type=pdsch    tput_type=ave
#      ${scell_tp}=    airphone_get_throughput_on_specific_scell    11    9    type=pdsch    tput_type=ave
#      should be true    ${pcell_tp}>0
#      should be true    ${scell_tp}>0
# 
# check throughput for pcell
#     ${pcell_tp}=    airphone_get_throughput_on_specific_scell    11    8    type=pdsch    tput_type=ave
#     should be true    ${pcell_tp}>0
# 
# 
# Wait time to stable
#     sleep    ${STABLETIME}
