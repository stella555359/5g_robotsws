# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CRT   SBTS00    RAN_5G_TDD    RAN_5G    owner_zhang    SBTS23R1
# ...   AP    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# 
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}         11
# #test1:CA inter LOKI,
# #${SCFC_NAME}      7922_SCFC_case17_n78_tp1.28G.xml
# #${AIRPHONE_NAME}    iphy_AEQE_4cell.xml
# 
# #CA intra LOKI , similar with APoABIL_intra_L2RT
# ${SCFC_NAME}     7922_SCFC_Case17_CA_intra_LOKI.xml
#                  
# ${AIRPHONE_NAME}    iphy_AEQE_4cell_CA_intra_LOKI.xml
# 
# ${WTS_NAME}      wts_4cell_AEQE_case17_LO.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# 
# ${ENDC_CMD}    ue_dc_enb_start ue\=11 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
# ${HO_CMD1}     ue_measurement_send_nr id\=11 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=52 nrsrp_nr\=30 nrsrq_nr\=30
# ${HO_CMD2}     ue_measurement_send_nr id\=11 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=50 nrsrp_nr\=50 nrsrq_nr\=50
# ${STABLETIME}    8s
# 
# #SA can peak;NSA skylake_1.8G;others_1.5G
# ${target_throughput}    2566
# ${test_throughput}    1500
# 
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# ...    NUMBER_OF_FILES=30
# 
# *** Test Cases ***
# CB007922_case17_A_7a_intraL2RT_intraBand_Intra_gNB_Intra_frequency_handover_for_blind_SCell_addition_NSA
# 
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Execute AP Command before attach
#     Attach LTE UE
#     Send DL data to UE and check throughput
# 
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti'
#     run keyword and continue on failure    Check ttitrace
# 
#     Trigger intra gnb intraband handover
#     Trigger intra gnb intraband handover back
#     Airphone NSA Detach    ue_id=11
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
# 
# Attach LTE UE
# 	Log To Console    Attach NSA UE
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/cell_setup   unzip=TRUE
#     
#     Airphone Nsa Attach     ${UE_ID}    profile_id=None
#     Wait time to stable
# 
# Send DL data to UE and check throughput
#     Log To Console    send DL data 160Mx16
#     NSA send ue '${UE_ID} ' mutiple trf '16' for each '160M' DL data
#     Wait '8s' for stabible
#     run keyword and continue on failure    Wait Until Keyword Succeeds   120s   2s    check throughput
# 
# Trigger intra gnb intraband handover
#     Log To Console    HO
#     airphone_cleanup_egate_console_log
#     #Airphone Measurement Send Nr    id=11    meas_id=1    event=A3    srsrp_nr=11   srsrq_nr=11
#     #...     phycell_id=51   nrsrp_nr=30    nrsrq_nr=30
#     # KW above can't work.
#     airphone_execute_egate_command    ${HO_CMD1}
#     
#     Wait '10s' for stabible
#     run keyword and continue on failure    Check intra gnb handover successfully
# 
# Check intra gnb handover successfully
#    Log To Console    check HO
#    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/handover   unzip=TRUE
#    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_HO_case17_APoABIO.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover
#    run keyword and continue on failure    Wait Until Keyword Succeeds   120s   2s    check throughput
# 
# Trigger intra gnb intraband handover back
#     Log To Console    HO back
#     airphone_cleanup_egate_console_log
#     #Airphone Measurement Send Nr    id=11    meas_id=1    event=A3    srsrp_nr=11   srsrq_nr=11
#     #...     phycell_id=50   nrsrp_nr=50    nrsrq_nr=50
#     # KW above can't work.
#     airphone_execute_egate_command    ${HO_CMD2}
#     Wait '10s' for stabible
#     run keyword and continue on failure    Check intra gnb handover successfully again
# 
# Check intra gnb handover successfully again
#    Log To Console    check HO back
#    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/handover1   unzip=TRUE
#    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_HOback_case17_APoABIO.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover1
#    run keyword and continue on failure    Wait Until Keyword Succeeds   120s   2s    check throughput
# 
# check throughput
#     Log To Console    check throuput:
#     Set test Variable    ${P+S}    0
#     ${pcell_tp}=    airphone_get_throughput_on_specific_scell    11    8    type=pdsch    tput_type=ave
#     ${scell_tp}=    airphone_get_throughput_on_specific_scell    11    9    type=pdsch    tput_type=ave
#     Log To Console    pcell_tp:${pcell_tp}
#     Log To Console    scell_tp:${scell_tp}
#     ${P+S}    evaluate    (${pcell_tp}+${scell_tp})/1000
#     Log To Console    P+S:${P+S}M
#     should be true    ${P+S}>${test_throughput}
# 
# Wait time to stable
#     sleep    ${STABLETIME}
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
