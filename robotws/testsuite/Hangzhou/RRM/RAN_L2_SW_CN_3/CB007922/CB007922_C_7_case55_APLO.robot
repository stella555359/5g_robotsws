# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags        CRT    SBTS00    RAN_5G_TDD    owner_zhang    SBTS23R1
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}         11
# ${UE1_ID}        11
# ${UE2_ID}        12
# ${SCFC_NAME}      SCFC_case55_LO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_AEHC_2CELL_case55_LO.xml
# ${WTS_NAME}       WTS_case55_LO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${ENB_CELL_PARAM1}    enb_cell_param enb\=1 id\=1 allow_endc\=on
# ${ENDC_CMD}    ue_dc_enb_start ue\=11 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
# ${FILTER}      dldata_ssblocksendreq||dldata_pdschsendreq||dldata_csirssendreq
# @{COLUMN_NAME}                   DlData_PdschSendReq.PdschSendReq.sfn    DlData_PdschSendReq.PdschSendReq.slot
# ...                              DlData_SsBlockSendReq.SsBlockSendReq.sfn    DlData_SsBlockSendReq.SsBlockSendReq.slot
# ...                              DlData_CsiRsSendReq.CsiRsSendReq.sfn    DlData_CsiRsSendReq.CsiRsSendReq.slot
# @{titles}   3gpp.sfn    3gpp.slot
# ${STABLETIME}    10s
# ${bip_tag}    bip
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# ...    NUMBER_OF_FILES=30
# ${outputcsv}  bip.csv
# 
# *** Test Cases ***
# CB007922_case55_C_7_Multiple_UE_in_NSA_different_SSB_configuration
# 
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     #Execute AP Command before attach
#     Attach LTE UE
#     MultiUE send A1 Event
#     Send DL data to UE and check throughput
#     
#     online enable actPdschAtSsbSlots and actPdschRmCsirsForTracking
#     Detach UE and Attach UE again
#     Send DL data to UE and check throughput again
#     
#     Start collect bip log
#     Wait for '3s' to stop bip log with name'${bip_tag}'
#     Verify Multi UE PDSCH Schedule In SSB and TRS Slot
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti'
#     Check ttitrace
#     Airphone NSA Detach    ue_id=11
#     Wait '2s' for stabible
#     Airphone NSA Detach    ue_id=12
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# 
# *** Keywords ***
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Attach LTE UE
#    : FOR    ${num}    IN RANGE    ${UE_ID}    ${UE_ID}+2
#     \    Airphone Nsa Attach     ${num}    profile_id=None
#     \    Wait time to stable
# 
# Detach UE and Attach UE again
#     Airphone NSA Detach    ue_id=11
#     Airphone NSA Detach    ue_id=12
#     Attach LTE UE
#     MultiUE send A1 Event
# 
# 
# 
# MultiUE send A1 Event
#     airphone_cleanup_egate_console_log
#     : FOR    ${num}    IN RANGE    ${UE_ID}    ${UE_ID}+2
#     \    Airphone Measurement Send Nr    id=${num}    meas_id=1    event=A1    rs_type=ssb    srsrp_nr=50
#     \    Wait time to stable
# 
# 
# Send DL data to UE and check throughput
#     NSA send ue '${UE1_ID} ' mutiple trf '6' for each '150M' DL data    
#     NSA send ue '${UE2_ID} ' mutiple trf '6' for each '150M' DL data
#     Wait '10s' for stabible
#     run keyword and continue on failure    Wait Until Keyword Succeeds    120s    2s   check_tp
# 	
# check_tp
#     Set test Variable    ${Pcell_total}    0
#     Set test Variable    ${Scell_total}    0
#     Set test Variable    ${P+S}    0
#     : FOR    ${num}    IN RANGE    ${UE_ID}    ${UE_ID}+2
#     \	Log To Console    ${\n}---UE_${num}---
#     \	${pcell_tp}=    airphone_get_throughput_on_specific_scell    ${num}    8    type=pdsch    tput_type=ave
#     \	${scell_tp}=    airphone_get_throughput_on_specific_scell    ${num}    9    type=pdsch    tput_type=ave
#     \	Log To Console   ${\n}---Pcell_tp_${pcell_tp}
#     \	Log To Console   ${\n}---Scell_tp_${scell_tp}
#     \	${Pcell_total}    evaluate    ${Pcell_total}+${pcell_tp}
#     \	${Scell_total}    evaluate    ${Scell_total}+${scell_tp}
# 	${P+S}    evaluate    (${Pcell_total}+${Scell_total})/1000
#     Log To Console    ---P+S_${P+S}---
#     should be true		${P+S}>1400
# 
# Send DL data to UE and check throughput again
#     NSA send ue '${UE1_ID} ' mutiple trf '6' for each '150M' DL data    
#     NSA send ue '${UE2_ID} ' mutiple trf '6' for each '150M' DL data
#     Wait '10s' for stabible
#     Set test Variable    ${Pcell_total}    0
#     Set test Variable    ${Scell_total}    0
#     Set test Variable    ${P+S}    0
#     : FOR    ${num}    IN RANGE    ${UE_ID}    ${UE_ID}+2
#     \	Log To Console    ${\n}---UE_${num}---
#     \	${pcell_tp}=    airphone_get_throughput_on_specific_scell    ${num}    8    type=pdsch    tput_type=ave
#     \	${scell_tp}=    airphone_get_throughput_on_specific_scell    ${num}    9    type=pdsch    tput_type=ave
#     \	Log To Console   ${\n}---Pcell_tp_${pcell_tp}
#     \	Log To Console   ${\n}---Scell_tp_${scell_tp}
#     \	should be true    ${pcell_tp}>${scell_tp}
#     \	${Pcell_total}    evaluate    ${Pcell_total}+${pcell_tp}
#     \	${Scell_total}    evaluate    ${Scell_total}+${scell_tp}
#     
# 	${P+S}    evaluate    ${Pcell_total}+${Scell_total}
#     Log To Console    ---P+S_${P+S}---
#    
#     
# 
# Wait time to stable
#     sleep    ${STABLETIME}
# 
# online enable actPdschAtSsbSlots and actPdschRmCsirsForTracking
#     Log To Console    enable actPdschAtSsbSlots and actPdschRmCsirsForTracking...
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=actPdschAtSsbSlots
#     ...    operation=update    value=true    skip_parameter_relation_errors=True    should_activate=True    connection=online
#         TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=actPdschRmCsirsForTracking
#     ...    operation=update    value=true    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '60s' for stabible
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Verify Multi UE PDSCH Schedule In SSB and TRS Slot
#     run keyword and continue on failure    Convert BIP To CSV    ${test_log_directory()}/All/${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${test_log_directory()}/All/${outputcsv}    ${FILTER}    ${titles}
#     
#     run keyword and continue on failure    Check Log With Au2anlysis    ini_path=${CURDIR}/ini/bip.ini     log_need_to_check=i      
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
