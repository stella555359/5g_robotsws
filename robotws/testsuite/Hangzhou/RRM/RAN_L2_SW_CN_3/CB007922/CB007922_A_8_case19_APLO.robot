# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    #Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     #Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD   CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_ningyang     SBTS22R4    SBTS23R1
# ...               AP
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_19_ABIO_lo.xml
# ${AIRPHONE_NAME}    IPHY_AEQN_AEHC_2CELL_ABIO_case19.xml
# ${WTS_NAME}       SANSA7922_interband_ho_10ue_ABIO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${HO_CMD1}        ue_enb_param id\=11 drx_config\=off measurement_gap\=gp0:20 gap_trigger\=gnb_triggered mgta\=ms0dot50 gap_purpose\=perUE
# ${HO_CMD2}        ue_measurement_send_nr event\=A2 id\=1 meas_id\=1 rs_type\=ssb srsrp_nr\=30
# ${HO_CMD3}        ue_enb_param id\=11 measurement_gap\=off
# ${HO_CMD4}        ue_measurement_send_nr id\=1 meas_id\=4 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=51 nrsrp_nr\=20 nrsrq_nr\=20
# ${HO_CMD5}        ue_measurement_send_nr id\=1 meas_id\=8 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=50 nrsrp_nr\=50 nrsrq_nr\=20
# ${HO_CMD6}        ue_measurement_send_nr event\=A2 id\=1 meas_id\=5 rs_type\=ssb srsrp_nr\=30
# ${STABLETIME}     3s
# #${UE_ID}          11
# ${EGATE_TAG}      ADD
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# *** Test Cases ***
# CB007922_case19_A_8a_intraL2RT_interBand_Intra_gNB_Inter_frequency_handover_for_blind_SCell_addition_NSA
#     Prepare gnb onair
# 	Online change dlMimoMode
# 	 #Start WTS And Wait BTS Until Onair   ${WTS_NAME}  reload=${False}
#     Start capture gnb and ap syslog in 'after_onair' file
# 	Set traffic type to internal
#     Attach '1' ue to 5g cell
#     Internal send mutiple trf '8' for each '175M' DL data
# 	run keyword and continue on failure    check throughput
#     run keyword and continue on failure    Trigger intra gnb interband handover
#     run keyword and continue on failure    check throughput
#     airphone_cleanup_egate_console_log
#     run keyword and continue on failure    Trigger intra gnb interband handover back
#     Check throughput again
#     #Start collect ttitrace
#     #Wait for '2s' to stop ttitrace with name'tti'
#     #Check ttitrace
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     #Airphone NSA Detach    ${UE_ID}
# 
# *** Keywords ***
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# Attach '${uenum}' ue to 5g cell
#     : FOR    ${num}    IN RANGE    1    ${uenum}+1
#     \    Airphone SA Attach    ue_id=${num}
#     \    Wait '2s' for stabible
#     \    Airphone Pdu Session Setup    ${num}    ${num}    ${SLICE_ID}    ${num}
#     \    Wait '3s' for stabible
# Attach LTE UE
#     Airphone Nsa Attach    ${UE_ID}
# 
# UE send A1 Event
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# Send DL data to UE and check throughput
#     NSA send ue '${UE_ID}' mutiple trf '2' for each '175M' DL data
#     Wait time to stable
#     Verify throughput
# 
# Check throughput again
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Verify throughput
#         ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#         ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=1   scell_id=1    type=pdsch    tput_type=ave
#         should_be_true    ${dl_throughput_pcell}>500000
#         should_be_true    ${dl_throughput_scell1}>500000
# 
# Check scell add succesfully
#     airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All    unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_scelladd.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Trigger intra gnb interband handover
#     #airphone_execute_egate_command    ${HO_CMD1}
#     airphone_execute_egate_command    ${HO_CMD2}
# 	Wait time to stable
#     #airphone_execute_egate_command    ${HO_CMD3}
#     airphone_execute_egate_command    ${HO_CMD4}
#     Wait time to stable
#     check handover sucessfully
# 
# Trigger intra gnb interband handover back
#     #airphone_execute_egate_command    ${HO_CMD1}
#     airphone_execute_egate_command    ${HO_CMD6}
# 	Wait time to stable
#     #airphone_execute_egate_command    ${HO_CMD3}
#     airphone_execute_egate_command    ${HO_CMD5}
#     Wait time to stable
#     check handoverback sucessfully
# 
# check handover sucessfully
#     airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/ho1    unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/intra_lo.ini    log_need_to_check=u    save_log_directory=${TEST_LOG_DIRECTORY()}/All/ho1
# 
# check handoverback sucessfully
#     airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/ho2    unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/intrab_lo.ini    log_need_to_check=u    save_log_directory=${TEST_LOG_DIRECTORY()}/All/ho2
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Wait time to stable
#     sleep    ${STABLETIME}
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# Online change dlMimoMode
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-2/NRCELL-1    dlMimoMode    2x2 Closed Loop Spatial Multiplexing    online
#     Perform online change value    MRBTS-1/NRBTS-2/NRCELL-2    dlMimoMode    2x2 Closed Loop Spatial Multiplexing    online	
#     Wait '2s' for stabible
#     TAF_ADMIN.teardown admin    connection=online