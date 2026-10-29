# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}       SCFC_9235_16D8U_1070_100M_8x4_mulibwp_case09.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_8x4_case09.xml
# ${WTS_NAME}       wts_SA_NSA_case09.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog
# ${UE_NUM_SA}         14
# ${EGATE_TAG}      MUmimo
# ${BIP_TAG}    mumumo_bip
# ${TTI_TAG}      tti
# 
# ${UE1_SA_ID}        1
# ${UE2_SA_ID}        2
# ${UE3_SA_ID}        3
# ${UE4_SA_ID}        4
# ${UE5_SA_ID}        5
# ${UE6_SA_ID}        6
# ${UE7_SA_ID}        7
# ${UE8_SA_ID}        8
# ${UE9_SA_ID}        9
# ${UE10_SA_ID}        10
# ${UE11_SA_ID}        11
# ${UE12_SA_ID}        12
# 
# ${filter_cell_setup}    itf_l2_ps_cell_cellsetupreq
# @{titles_muaware}    itf_DlMuMimoEnhConfig.actMuAwareTdSch    itf_DlMuMimoEnhConfig.dlMuAwareCorrThd    itf_DlMuMimoEnhConfig.dlMuAwarePrbRatio
# ...    itf_DlMuMimoEnhConfig.dlMuPairingPrbRatio
# 
# ${filter_cell_reconfiguration_req}     itf_l2_ps_cell_cellreconfigurationreq
# 
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-14 zenith\=8 srs_transmit_power_per_port=-320,-320,-280,-280
# 
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-30 zenith\=8 srs_transmit_power_per_port=-320,-320,-280,-280
# 
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-40 zenith\=6 srs_transmit_power_per_port=-320,-320,-280,-280
# 
# 
# 
# 
# *** Test Cases ***
# CB009235_A_B102_CASE09_getAnUeForCheck_BlockUeList_nonCorrCheckUeList_should_be_merged_tobescheduled
#     #Active GNB L2 feature debug traces
#     step1:gnb ready for onair and check cellsetup log
#     step2:attach UEs with Pos and check send full buffer for UEs
#     step3:stop UE1 non-GBR and send small data
#     step4:send UE1 full non-GBR data
#    # step5:detach all UEs
#     Stop capture gnb and ap syslog in 'after_onair' file
# #    Stop capture gnb and ap syslog in 'after_onair' file '${check_info}'
# 
# 
# *** Keywords ***
# step1:gnb ready for onair and check cellsetup log
#     Log To Console   \n-------------step1:get ready for gnb---------------
# 	Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# #	${check_info}    create list    WRN/L2-PS    WRN/.uplane/L2-PS    ERR/ctrlNrUlSrs    ERR/ctrlCommon    ERR/ctrlNrDlCsiRs    ERR/l1_application_rt
# #	set suite variable   ${check_info}
# 	Prepare gnb onair
# 	Start capture gnb and ap syslog in 'after_onair' file
# 	Airphone Cleanup Egate Console Log
# 
# 
# step2:attach UEs with Pos and check send full buffer for UEs
#     Log To Console   \n-------------step2:attach UEs with Pos and check send full buffer for UEs--------------
# 	Attach '${UE_NUM_SA}' SA UE
# 	Set UEs pos
# 	Get all UEs rnti
# 	run keyword and continue on failure    Check Srs Resource
#     SA send data '${UE_NUM_SA}' UEs
#     Wait '10s' for stabible
#     Check SA UE throughput
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti_no_bler'
#     reorder_csv_CB009235    ${TEST_LOG_DIRECTORY()}/All/tti_no_bler_dl.csv
#     #check ttitrace
#     run keyword and continue on failure    check_ue_in_block_list_non_corr_check_list_be_scheduled
#     ...    ${TEST_LOG_DIRECTORY()}/All/tti_no_bler_dl.csv
#     run keyword and continue on failure    check_uncheck_ue_in_cs2list_add_into_non_corr_check_list_and_scheduled
#     ...    ${TEST_LOG_DIRECTORY()}/All/tti_no_bler_dl.csv
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_no_bler_case09.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# step3:stop UE1 non-GBR and send small data
#     Log To Console   \n-------------step3:stop UE1 non-GBR and send small data--------------
#     Stop UE'${UE1_SA_ID}' data
#     SA send mutiple trf dl data    ${UE1_SA_ID}    1   100k   ${UE1_SA_ID}    tcp
#     Wait '5s' for stabible
# #    Check SA UE throughput
#     Start collect ttitrace
#     Wait for '0.5s' to stop ttitrace with name'tti_ue1_small'
#     reorder_csv_CB009235    ${TEST_LOG_DIRECTORY()}/All/tti_ue1_small_dl.csv
#         #check ttitrace
#     run keyword and continue on failure    check_ue_in_block_list_non_corr_check_list_be_scheduled
#     ...    ${TEST_LOG_DIRECTORY()}/All/tti_no_bler_dl.csv
#     run keyword and continue on failure    check_uncheck_ue_in_cs2list_add_into_non_corr_check_list_and_scheduled
#     ...    ${TEST_LOG_DIRECTORY()}/All/tti_no_bler_dl.csv
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ue1_small_case09.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# step4:send UE1 full non-GBR data
#     Log To Console   \n-------------step4:send UE1 full non-GBR data--------------
#     airphone_sa_stop_data_traffic    ue_id=${UE1_SA_ID}    pdu_id=${UE1_SA_ID}    direction=dl
#     SA send mutiple trf dl data    ${UE1_SA_ID}    1   175M   ${UE1_SA_ID}    tcp
#     Wait '5s' for stabible
#     Check SA UE throughput
#     Start collect ttitrace
#     Wait for '0.5s' to stop ttitrace with name'tti_ue1_full'
#     reorder_csv_CB009235    ${TEST_LOG_DIRECTORY()}/All/tti_ue1_full_dl.csv
#     run keyword and continue on failure    check_ue_in_block_list_non_corr_check_list_be_scheduled
#     ...    ${TEST_LOG_DIRECTORY()}/All/tti_no_bler_dl.csv
#     run keyword and continue on failure    check_uncheck_ue_in_cs2list_add_into_non_corr_check_list_and_scheduled
#     ...    ${TEST_LOG_DIRECTORY()}/All/tti_no_bler_dl.csv
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ue1_full_case09.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# step5:detach all UEs
#     Log To Console   \n-------------step5:detach all UEs ---------------
#     Detach '${UE_NUM_SA}' SA UE
# 
# Convert cellsetup bip and check
#     Log To Console   Convert cellsetup bip and check
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/cellsetup.pcap
#      ...    ${TEST_LOG_DIRECTORY()}/All/cellsetup.csv    ${filter_cell_setup}    ${titles_muaware}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/cellsetup_bip.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# Attach '${UE_NUM_SA}' SA UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   airphone_cleanup_egate_console_log
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
#     \   Wait '2s' for stabible
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \   Wait '2s' for stabible
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
#     \   Wait '3s' for stabible
# 
# 
# Detach '${UE_NUM_SA}' SA UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    airphone_sa_detach    ue_id=${num}    timeout=30
# 
# 
# Create UE pos profile
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    airphone_execute_egate_command    ${PROFILE${num}}
# 
# Set UEs pos
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${PROFILE3}
# #    airphone_execute_egate_command    ${PROFILE4}
# 
# #    : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
# #    \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num}
# 
#     :FOR    ${num}    IN RANGE    1    1+4
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     :FOR    ${num}    IN RANGE    5    5+2
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
#     :FOR    ${num}    IN RANGE    7    7+4
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# 
# 
# 
# SA send data '${UE_NUM_SA}' UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    SA send mutiple trf dl data    ${num}    1   175M   ${num}    tcp
#     \    SA send mutiple trf ul data    ${num}    1    10M   ${num}
# 
# 
# SA send data to UEs'${UE_ID_LOW}' to '${UE_ID_HIGH}'
#     : FOR    ${num}    IN RANGE    ${UE_ID_LOW}    ${UE_ID_HIGH}+1
#     \    SA send mutiple trf dl data    ${num}    5   175M   ${num}    tcp
#     \    SA send mutiple trf ul data    ${num}    1    10M   ${num}
# 
# Check Srs Resource
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_peridicSRS_case01.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_1_egate
# 
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_AperidicSRS_case01.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_13_egate
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_AperidicSRS_case01.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_14_egate
# 
# Get all UEs rnti
#     ${rnti_list}    create list
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    ${rnti}    Get SA UE crnti in RRC log'${EGATE_TAG}_${num}'
#     \    Log To Console   UE${num} rnti=${rnti}
# 	\    set suite variable     ${ue${num}_rnti}    ${rnti}
#     \    append to list    ${rnti_list}    ${rnti}
#     Log To Console    rnti_list=${rnti_list}
# 
# Get SA UE crnti in RRC log'${EGATE_TAG}'
#     Log To Console   check UE RRC log to get all ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate/egate_console.log.001   crnti: (\\d+)
#     [return]     ${rnti_list[0]}
# 
# Get NSA UE crnti in RRC log'${EGATE_TAG}'
#     Log To Console   check UE RRC log to get all ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate/egate_console.log.001   newUE-Identity (\\d+)
#     [return]     ${rnti_list}
# 
# Add GBR and Send GBR data to SA UE'${UE_low}' to '${UE_high}'
#     : FOR    ${num}    IN RANGE    ${UE_low}    ${UE_high}+1
#     \    airphone_execute_egate_command    ue_pdu_session_modify ue\=${num} pdu\=${num} qosflows_to_add\=2 by\=amf
#     \    Wait '3s' for stabible
#     \    airphone_execute_egate_command    ue_pdu_session_modify ue\=${num} pdu\=${num} qosflows_to_add\=4 by\=amf
#     \    Wait '3s' for stabible
#     \    airphone_execute_egate_command    trf_data_start ue\=${num} pdu\=${num} qfi\=3 trf_id\=1 mbps\=50 dir\=dl
#     \    Wait '3s' for stabible
# 
# 
# Stop UE'${UE_ID}' data
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}    pdu_id=${UE_ID}    direction=dl
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}    pdu_id=${UE_ID}    direction=ul
# 
# Check SA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput
# 
# Verify multi SA UEs throughput
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#     \    Log To Console		UE:${num} dl_tput= ${dl_throughput_pcell}
#     \    Log To Console		UE:${num} ul_tput= ${ul_throughput_pcell}
#     \    should_be_true    ${dl_throughput_pcell}>50000
# 
# 
# Add RD
#     Add GNB swconfig    0x58077e:1   #rdEnableMuAwareTdSchTtiTrace
#     Add GNB swconfig    0x580539:10   #Num UE threshold,to collect trace
#     #Add GNB swconfig    0x58075a:4  #rdNumberOfCorrelationCalculationUe  default:0x19
#     Add GNB swconfig    0x58075b:5  #rdNumberOfCorrelationCalculationTotal  default: 0x12c
# 
# Add dl bler to UE'${UE_ID}'
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=${30+${UE_ID}} dl_bler\=100,2,3,4
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=0 testmode\=bler profile_id\=${30+${UE_ID}} action\=activatee
