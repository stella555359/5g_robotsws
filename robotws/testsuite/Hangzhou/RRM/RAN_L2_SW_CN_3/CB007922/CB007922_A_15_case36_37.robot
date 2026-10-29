# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS22R1    owner_jinxiao    SBTS22R2    SBTS22R4    SBTS23R1
# ...   CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# ...               AP
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}          11
# ${SCFC_NAME}      7922_SCFC_A_15.xml
# ${AIRPHONE_NAME}    IPHY_AEQN_AEHC_4CELL.xml
# ${WTS_NAME}       SANSA7922_interband_interMeNB.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${HO_CMD1}        ue_ho id\=11 enb\=5 cell\=1
# 
# *** Test Cases ***
# CB007922_case37_A_15_Inter_MeNB_LTE_HO_without_SgNB_change_without_PSCell_change_CA_UE_traffic_keep
#     Modify AP swconfig    0x10041:1
#     Add GNB swconfig    0x340000:15
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'sys' file
#     Execute AP Command before attach
#     Attach LTE UE
#     NSA send ue '${UE_ID}' mutiple trf '2' for each '175M' DL data
#     Airphone check throughput
#     Trigger inter enb handover
#     Airphone check throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti'
#     Check ttitrace
#     Stop capture gnb and ap syslog in 'sys' file
#     Airphone NSA Detach    ue_id=11
# 
# CB007922_case36_A_15_Inter_MeNB_LTE_HO_without_SgNB_change_without_PSCell_change_CA_UE_modification_request_reject
#     Start capture gnb and ap syslog in 'sys' file
#     Attach LTE UE
#     NSA send ue '${UE_ID}' mutiple trf '2' for each '175M' DL data
#     Airphone check throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti'
#     Check ttitrace
#     airphone_execute_egate_command    enb_endc_param id\=5 ho_prep_failure_on_add_req_reject\=off
#     airphone_execute_egate_command    enb_endc_param id\=1 ho_prep_failure_on_add_req_reject\=off
#     airphone_execute_egate_command    enb_endc_param id\=5 allowed_bc_list_mrdc\=6:1
#     Trigger inter enb handover
#     Wait until keyword succeeds    200s    20s    Check pm counter M55310C01009 in cell 1 is expected == 0
#     Stop capture gnb and ap syslog in 'sys' file
#     Airphone NSA Detach    ue_id=11
# 
# *** Keywords ***
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
#     Airphone Setup X2 Connection    enb_id=5
# 
# Attach LTE UE
#     Airphone Location Change    id=11    cell_id=1    enb=1
#     Airphone Nsa Attach    ${UE_ID}    profile_id=None
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# Airphone check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Trigger inter enb handover
#     airphone_execute_egate_command    ${HO_CMD1}
#     wait '5s ' to check log
#     Check handover sucessfully
# 
# Check handover sucessfully
#     airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/ho    unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_ho_36.ini    log_need_to_check=u    save_log_directory=${TEST_LOG_DIRECTORY()}/All/ho
# 
# Verify throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>150000
#     should_be_true    ${dl_throughput_scell1}>100000
# 
# Wait '${time} ' to check log
#     sleep    ${time}
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
