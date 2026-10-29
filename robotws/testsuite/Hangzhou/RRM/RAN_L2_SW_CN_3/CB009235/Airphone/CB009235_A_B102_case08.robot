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
# ${SCFC_NAME}      SCFC_9235_16D8U_1070_100M_case08.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_case08.xml
# ${WTS_NAME}       wts_SA_NSA_case08.cfg
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
# ${UE13_SA_ID}        13
# ${UE14_SA_ID}        14
# 
# ${filter_cell_setup}    itf_l2_ps_cell_cellsetupreq
# @{titles_muaware}    itf_DlMuMimoEnhConfig.actMuAwareTdSch    itf_DlMuMimoEnhConfig.dlMuAwareCorrThd    itf_DlMuMimoEnhConfig.dlMuAwarePrbRatio
# ...    itf_DlMuMimoEnhConfig.dlMuPairingPrbRatio
# 
# ${filter_cell_reconfiguration_req}     itf_l2_ps_cell_cellreconfigurationreq
# 
# 
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=50 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-280,-280
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=48 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-280,-280
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=45 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-280,-280
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=42 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-280,-280
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=39 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-280,-280
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=36 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-280,-280
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=33 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-280,-280
# ${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-280,-280
# ${PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=27 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-280,-280
# ${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=24 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-280,-280
# ${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id\=12 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=21 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-280,-280
# ${PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id\=13 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=18 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-280,-280
# ${PROFILE14}    ul_mimo_srs_beam_pos_nr profile_id\=14 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-280,-280
# ${PROFILE15}    ul_mimo_srs_beam_pos_nr profile_id\=15 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=12 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-280,-280
# ${PROFILE16}    ul_mimo_srs_beam_pos_nr profile_id\=16 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=9 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-280,-280
# ${PROFILE17}    ul_mimo_srs_beam_pos_nr profile_id\=17 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=6 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-280,-280
# 
# 
# *** Test Cases ***
# CB009235_A_B102_CASE08_getAnUeForCheck_CorrelationCheckNeeded_with_Mu_nonMu_retransUE_mixed_always_selected
# #    Active GNB L2 feature debug traces
#     step1:gnb ready for onair and check cellsetup log
#     step2:attach UEs with Pos and check send full buffer for UEs
#     step3:Add dl bler to UE1-UE4 and check logs
#     step4:Add dl bler to UE13 and check logs
#     step5:Add dl bler to all mueligible UEs and check logs
#     #step6:detach all UEs
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# *** Keywords ***
# step1:gnb ready for onair and check cellsetup log
#     Log To Console   \n-------------step1:get ready for gnb---------------
# 	Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
# 	Start capture gnb and ap syslog in 'after_onair' file
# 	Airphone Cleanup Egate Console Log
# #	Convert cellsetup bip and check
# 
# step2:attach UEs with Pos and check send full buffer for UEs
#     Log To Console   \n-------------step2:attach UEs with Pos and check send full buffer for UEs--------------
# 	Attach '${UE_NUM_SA}' SA UE
# #	Set UEs pos
#     Set SA UEs Pos
# 	Get all UEs rnti
# 	run keyword and continue on failure    Check Srs Resource
#     SA send data '${UE_NUM_SA}' UEs
#     Wait '10s' for stabible
#     Check SA UE throughput
# 
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti_no_bler'
#     #check ttitrace
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_no_bler_case08.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
#     reorder_csv_CB009235    ${TEST_LOG_DIRECTORY()}/All/tti_no_bler_dl.csv
# 
# 
# step3:Add dl bler to UE1-UE4 and check logs
#     Add dl bler to UE'${UE1_SA_ID}'
#     Add dl bler to UE'${UE2_SA_ID}'
#     Add dl bler to UE'${UE3_SA_ID}'
#     Add dl bler to UE'${UE4_SA_ID}'
#     Wait '5s' for stabible
#     Start collect ttitrace
#     Wait for '0.5s' to stop ttitrace with name'tti_UE1_4_bler'
# 
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_UE1_4_bler_case08.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
#     run keyword and continue on failure    check_9235_ue_list_in_per_slot
#     ...    ${TEST_LOG_DIRECTORY()}/All/tti_UE1_4_bler_dl.csv
#     run keyword and continue on failure    check_retx_ue_not_in_blocklist_and_noncorrelation_list
#     ...    ${TEST_LOG_DIRECTORY()}/All/tti_UE1_4_bler_dl.csv
#     reorder_csv_CB009235    ${TEST_LOG_DIRECTORY()}/All/tti_UE1_4_bler_dl.csv
#     run keyword and continue on failure    check_cdm_group_and_dmrs_port_by_antenna_port_value
#     ...    ${TEST_LOG_DIRECTORY()}/All/tti_UE1_4_bler_dl.csv
# 
# step4:Add dl bler to UE13 and check logs
#     Add dl bler to UE'${UE13_SA_ID}'
#     Wait '5s' for stabible
#     Start collect ttitrace
#     Wait for '0.5s' to stop ttitrace with name'tti_part_UE_bler'
#     reorder_csv_CB009235    ${TEST_LOG_DIRECTORY()}/All/tti_part_UE_bler_dl.csv
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_UE1_4_13_bler_case08.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
#     ${rnti_dict}    get_ue_scheduled_times     ${TEST_LOG_DIRECTORY()}/All/tti_part_UE_bler_dl.csv
#     ${ue_13}    Convert To Integer    ${ue13_rnti}
#     ${ue_14}    Convert To Integer    ${ue14_rnti}
#     #should_be_true    ${rnti_dict[${ue_13}]}>=${rnti_dict[${ue_14}]}
#     run keyword and continue on failure    check_cdm_group_and_dmrs_port_by_antenna_port_value
#     ...    ${TEST_LOG_DIRECTORY()}/All/tti_part_UE_bler_dl.csv
# 
# step5:Add dl bler to all mueligible UEs and check logs
#     Add dl bler to UE'${UE5_SA_ID}'
#     Add dl bler to UE'${UE6_SA_ID}'
#     Add dl bler to UE'${UE7_SA_ID}'
#     Add dl bler to UE'${UE9_SA_ID}'
#     Add dl bler to UE'${UE10_SA_ID}'
#     Add dl bler to UE'${UE11_SA_ID}'
#     Add dl bler to UE'${UE12_SA_ID}'
#     Wait '5s' for stabible
#     Start collect ttitrace
#     Wait for '0.5s' to stop ttitrace with name'tti_mueligible_bler'
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_mueligible_bler_case08.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
#     run keyword and continue on failure    check_ue_if_scheduled    ${TEST_LOG_DIRECTORY()}/All/tti_mueligible_bler_dl.csv    ${ue14_rnti}
#     run keyword and continue on failure    check_cdm_group_and_dmrs_port_by_antenna_port_value
#     ...    ${TEST_LOG_DIRECTORY()}/All/tti_mueligible_bler_dl.csv
#     reorder_csv_CB009235    ${TEST_LOG_DIRECTORY()}/All/tti_mueligible_bler_dl.csv
# 
# step6:detach all UEs
#     Log To Console   \n-------------step7:detach all UEs ---------------
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
#     \   ${gw_pdu_r}    evaluate    ${num}%10+1
#     \   airphone_cleanup_egate_console_log
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${gw_pdu_r}    type=internal
#     \   Wait '2s' for stabible
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${gw_pdu_r}   nwslice_id=1   gw_id=${num}
#     \   Wait '2s' for stabible
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
#     \   Wait '3s' for stabible
# 
# 
# SA UE '${UE_ID}' fix RANK2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=30 ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=30 scell\=0
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
# #    airphone_execute_egate_command    ${PROFILE3}
# #    airphone_execute_egate_command    ${PROFILE4}
# 
# #    : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
# #    \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num}
# 
#     :FOR    ${num}    IN RANGE    1    1+8
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     :FOR    ${num}    IN RANGE    9    9+8
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# 
# 
# Create SRS_pos profile
#     : FOR    ${num}    IN RANGE    2    36    #35pos
#     \    airphone_execute_egate_command    ${PROFILE${num}}
# 
# Set SA UEs Pos  #per position 2ues
#   : FOR    ${num}    IN RANGE    2    18
#     \    airphone_execute_egate_command    ${PROFILE${num}}
# 
#     log to console    ste ues pos
#     : FOR    ${num}    IN RANGE    1    17
#     \    ${num_r}    evaluate    ${num}+1
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num_r}
# 
# SA send data '${UE_NUM_SA}' UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   ${gw_pdu_r}    evaluate    ${num}%10+1
#     \    SA send mutiple trf dl data    ${num}    5   175M   ${gw_pdu_r}    tcp
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
# Online change actMuAwareTdSch '${state}' and check bip logs
#     Start collect 'actMuAwareTdSch_${state}' tcpdump
# 	TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1   actMuAwareTdSch    ${state}    online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     TAF_ADMIN.teardown admin    connection=online
#     Stop collect 'actMuAwareTdSch_${state}' tcpdump
#     Wait '30s' for stabible
#     #check bip logs
#     set suite variable     ${9235_state}    ${state}
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/actMuAwareTdSch_${state}.pcap
#      ...    ${TEST_LOG_DIRECTORY()}/All/actMuAwareTdSch_${state}.csv    ${filter_cell_setup}    ${titles_muaware}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/actmuaware_state_bip.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# Online change dlMuPairingPrbRatio '${value}' and check bip logs
#     Start collect 'dlMuPairingPrbRatio_${value}'
#     ${prb_value}    set variable    ${value}*100
# 	TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1   dlMuPairingPrbRatio    ${state}    online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     TAF_ADMIN.teardown admin    connection=online
#     Stop collect 'dlMuPairingPrbRatio_${prb_value}' tcpdump
#     Wait '30s' for stabible
#     #check bip logs
#     set suite variable     ${dlMuPairingPrbRatio_value}    ${prb_value}
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/dlMuPairingPrbRatio_${value}.pcap
#      ...    ${TEST_LOG_DIRECTORY()}/All/dlMuPairingPrbRatio_${dlMuPairingPrbRatio_value}.csv    ${filter_cell_reconfiguration_req}
#      ...    ${titles_muaware}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/dlMuPairingPrbRatio_value_bip.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
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
# #    \    should_be_true    ${dl_throughput_pcell}>210000
# 
# 
# Add RD
#     Add GNB swconfig    0x58077e:1   #rdEnableMuAwareTdSchTtiTrace
#     Add GNB swconfig    0x580539:10   #Num UE threshold,to collect trace
# 
# 
# Add dl bler to UE'${UE_ID}'
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=${30+${UE_ID}} dl_bler\=50,2,3,4
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=0 testmode\=bler profile_id\=${30+${UE_ID}} action\=activate
# 
