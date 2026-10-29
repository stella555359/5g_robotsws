# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_jinxiao    SBTS23R1
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}          11
# ${SCFC_NAME}      7922_SCFC_A_15_LO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_AEHC_2CELL.xml
# ${WTS_NAME}       SANSA7922_interband_interMeNB_LO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${HO_CMD1}        ue_ho id\=11 enb\=5 cell\=1
# 
# *** Test Cases ***
# CB007922_case37_A_15_Inter_MeNB_LTE_HO_without_SgNB_change_without_PSCell_change_CA_UE_traffic_keep
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'sys' file
#     Execute AP Command before attach
#     Attach LTE UE
#     Execute AP Command for rank2
#     NSA send ue '${UE_ID}' mutiple trf '15' for each '175M' DL data
#     Airphone check throughput
#     run keyword and continue on failure    Trigger inter enb handover
#     Execute AP Command for rank2
#     Airphone check throughput
#     Check throughput-rank4
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti'
#     run keyword and continue on failure    Check ttitrace
#     Stop capture gnb and ap syslog in 'sys' file
#     Airphone NSA Detach    ue_id=${UE_ID}
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
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=50
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
# 
# Check throughput-rank4
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=csi_override action\=activate profile_id\=2 scell\=8-9
#     Wait until keyword succeeds    60s    5s    Verify throughput-rank4
# 
# Verify throughput-rank4
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>700000
#     should_be_true    ${dl_throughput_scell1}>700000
# 
# Execute AP Command for rank2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=csi_override action\=activate profile_id\=1 scell\=8-9
