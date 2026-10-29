# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    owner_yuqq    AP    SBTS00     SBTS23R1     CRT     RAN_5G_TDD    RAN_5G
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}          11
# ${SCFC_NAME}      SCFC_case51_2AEQE_APLO.xml
# ${AIRPHONE_NAME}    IPHY_2AEQE_case51_aplo.xml
# ${WTS_NAME}       WTS_2AEQE_case51_aplo.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${DisableBeam}      Disablebeamforming
# ${EnableBeam}      Enablebeamforming
# ${SYSLOG_TAG}     after_onair
# 
# *** Test Cases ***
# CB007922_case51_C_5b_intraL2RT_SA_CA_NonBF_interwork_with_pCSI_multiplexing_on_pucch_2X2openloop
#     Prepare gnb onair
#     Start capture gnb and ap syslog in '${SYSLOG_TAG}' file
#     Execute AP Command before attach
# 	Attach LTE UE
#     sleep    3s
#     Collect AP egate log    ${DisableBeam}
#     Analyse onlyCSIreport in rrclog
#     NSA send ue '${UE_ID}' mutiple trf '12' for each '175M' DL data
#     Check throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti'
# #    Check ttitrace
# 	Airphone NSA Stop Data Traffic    ${UE_ID}    DL
#     Airphone NSA Detach    ${UE_ID}
# 
# 	Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_7922_case51.json
#     sleep    60s    
# 
# 
# #	Start capture gnb and ap syslog in '${SYSLOG_TAG}' file
#     Execute AP Command before attach
# 	Attach LTE UE
#     sleep    3s
#     Collect AP egate log     ${EnableBeam}
#     Analyse CSIBundlingreport in rrclog
#     NSA send ue '${UE_ID}' mutiple trf '12' for each '175M' DL data
#     Check throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti'
# #    Check ttitrace
#     Airphone NSA Stop Data Traffic    ${UE_ID}    DL
# 	Airphone NSA Detach    ${UE_ID}
# 
# 
# *** Keywords ***
# Online change to actbeamforming on pcell
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-2/NRCELL-1    actBeamforming    true    online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
# 
# 
# Verify throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>180000
#     should_be_true    ${dl_throughput_scell1}>180000
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    enb_x2_link_up enb\=1 target\=2
# 
# Attach LTE UE
#     Airphone Nsa Attach    ${UE_ID}    profile_id=None
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# 
# UE send A1 event again
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# UE send A2 event
#     airphone_execute_egate_command    ue_measurement_send_nr event\=A2 id\=11 meas_id\=2 rs_type\=ssb scell\=9 scell_rsrp\=30
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Analyse onlyCSIreport in rrclog
# 	check_log_with_au2anlysis    ${CURDIR}/ini/RRC_beamformingDisabled_NSA.ini    p    
# 	...     save_log_directory=${TEST_LOG_DIRECTORY()}/All/${DisableBeam}_egate
# 
# Analyse CSIBundlingreport in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_beamformingEnabled_NSA.ini    p    
# 	...     save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EnableBeam}_egate
# 
# Test Teardown
#     Common Test Teardown
#     Stop capture gnb and ap syslog in '${SYSLOG_TAG}' file
# 
# Wait '${time} ' to check log
#     sleep    ${time}
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
