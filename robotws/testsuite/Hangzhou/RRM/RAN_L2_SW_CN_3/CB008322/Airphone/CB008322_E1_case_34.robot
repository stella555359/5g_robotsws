# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_yuqq    AP    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8322_case34.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_MUMIMO.xml
# ${WTS_NAME}    wts_8322_B32_SA_NSA_32UEs.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog    
# 
# ${FILTER_f1ap}    (f1ap) && (nr-rrc.supportedSRS_TxPortSwitch)
# @{titles_f1ap}    nr-rrc.supportedSRS_TxPortSwitch
# ${FILTER_1}    (dldata_pdcchsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_2}    (dldata_pdschsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# @{titles_1}    DlData_DciInfo.patternId_item
# @{titles_2}    DlData_PdschGrant.patternId_item
# @{titles_3}    DlData_CsiRsResource_t.patternId_item
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# ...    NUMBER_OF_FILES=30
# ${UE_NUM}      4 
# ${UE1}     1
# ${UE2}     2
# ${UE3}     3
# ${UE4}     4
# ${EGATE_TAG}       egate
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=50 zenith\=40 srs_transmit_power_per_port\=-270,-270,-230,-230
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-20 zenith\=40 srs_transmit_power_per_port\=-270,-270,-230,-230
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-50 zenith\=-30 srs_transmit_power_per_port\=-270,-270,-230,-230
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=20 zenith\=-30 srs_transmit_power_per_port\=-270,-270,-230,-230
# 
# 
# ${SET_UE1_SA}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_UE2_SA}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_UE3_SA}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_UE4_SA}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_UE2_SA_as UE1}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_UE3_SA_as UE1}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_UE4_SA_as UE1}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# 
# 
# *** Test Cases ***
# CB008322_E1_case034_subbandBeam_interwork_8layerMUMIMO_DLMIMO8X4_non_tapering
# 	Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# #    Active GNB L2 feature debug traces
# 	Prepare gnb onair
# 	Start capture gnb and ap syslog in 'after_onair' file
# 	
# 	Attach '${UE1}' RANK4 SA UE
# 	${ue1_rnti}    Get SA '${UE1}' crnti in RRC log
# 	set suite variable     ${ue1_rnti}
# 	
# 	Attach '${UE2}' RANK4 SA UE
# 	${ue2_rnti}    Get SA '${UE2}' crnti in RRC log
# 	set suite variable     ${ue2_rnti}
# 	
# 	Attach '${UE3}' RANK4 SA UE
# 	${ue3_rnti}    Get SA '${UE3}' crnti in RRC log
# 	set suite variable     ${ue3_rnti}
# 	
#     Attach '${UE4}' RANK4 SA UE
# 	${ue4_rnti}    Get SA '${UE4}' crnti in RRC log
# 	set suite variable     ${ue4_rnti}
# 
#     Set SA UEs Pos
# 	
# 	#step1
# 	Send '${UE_NUM}' full buffer data
# 	Wait '5s' for stabible
# 	run keyword and continue on failure    Check '${UE_NUM}' SA UE throughput
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'Step1_fullbuffer'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/Step1_fullbuffer_dl.csv
# #	run keyword and continue on failure	   Check ttitrace'tti_rt_dft_case34_1.ini'
# 	
# 	#step2
#     Override RANK1 for UE1
# 	Wait '2s' for stabible
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'Step2_UE1Rank1'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/Step2_UE1Rank1_dl.csv	
# 	run keyword and continue on failure	   Check ttitrace'tti_rt_dft_case34_2.ini'
# 	
# 	#step3
# 	Override RANK4 for UE1 and UE2
# 	Override RANK2 for UE3 and UE4
# 	Wait '2s' for stabible
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'Step3_overrideRank'
# 	split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/Step3_overrideRank_dl.csv
# 	run keyword and continue on failure	   Check ttitrace'tti_rt_dft_case34_3.ini'
# 
# 	#step4
# 	Add bler on UE1UE2
# 	Wait '2s' for stabible
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'Step4_UE1UE2bler'
# 	split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/Step4_UE1UE2bler_dl.csv
# 	run keyword and continue on failure    Check ReservedMcs in ttitrace
# 
#     #step5    
#     Set UEs same position 
# 	Override RANK4 for UE3 and UE4
#     Wait '10s' for stabible
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'Step5_samePosition'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/Step5_samePosition_dl.csv
#     run keyword and continue on failure    Check ttitrace'tti_rt_dft_case34_5.ini'
# 	
# *** Keywords ***
# Add RD
# 	#rdMinSrsUePeriodicity,default=80 slot(0x50)
#     Add GNB swconfig    0x580789:0x1   #The maximum distance between startPRB of each PDSCH PRB and mid-PRB 
#     Add GNB swconfig     0x5901E8:1        #CPRT rdActCB009496 (enable pattern id allocation and rtBeamConfig validation.)
#     Add GNB swconfig     0x600013:1        #BOAM_RAT_ADAPT ()
#     Add GNB swconfig     0x19040F:1        #BOAM_FRONTHAUL
#     Add GNB swconfig     0x42008E:1        #BOAM DCS
#     Add GNB swconfig     0x88004B:0        #L1 FH, rdEnableSktMvp
#     Add GNB swconfig     0x880031:14      #L1 FH, rdBwvTxOpportunities (symbols/slot for sending BWV)
#     Add GNB swconfig     0x580556:65535  #rdStartPatternId  (default 5000 for SKT MVP, 65535 for 9496)
#     Add GNB swconfig     0x580776:1   #rdDlMuSbBfMode
# 
# Attach '${NSA_UE_NUM}' NSA UE and data buffer sent
#     : FOR    ${num}    IN RANGE    11    ${NSA_UE_NUM}+11
#     \   airphone_cleanup_egate_console_log
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   Wait '3s' for stabible
# #    \   Collect AP egate log    ${EGATE_TAG}_${num}
# #    \   run keyword and continue on failure     check_SRS_resource_and_PDSCH_scramblingID   ${EGATE_TAG}_${num}
#     \   NSA send ue '${num}' mutiple trf '3' for each '170M' DL data
# #    \   NSA send ue '${num}' mutiple trf '1' for each '15M' UL data
# 	
# Get SA '${ue_id}' crnti in RRC log
#     Log To Console   check SA UE RRC log to get all ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_${ue_id}_egate/egate_console.log.001   crnti: (\\d+)
#     [return]     ${rnti_list[0]}
# 	
# Check '${UE_NUM}' SA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify '${UE_NUM}' SA UEs throughput
# 	
# Verify '${SA_UE_NUM}' SA UEs throughput
#     : FOR    ${num}    IN RANGE    1    ${SA_UE_NUM}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>500000
# 	
# Set UE '${UE_ID}' low power
#     ${cmd}   Catenate    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
#     ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-70 zenith\=40 srs_transmit_power_per_port\=-650,-600,-650,-600
#     airphone_execute_egate_command    ${cmd}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10
# 	
# Set SA UEs Pos
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${PROFILE2}
# 	airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${PROFILE4}
# 	airphone_execute_egate_command    ${SET_UE1_SA}
#     airphone_execute_egate_command    ${SET_UE2_SA}
#     airphone_execute_egate_command    ${SET_UE3_SA}
#     airphone_execute_egate_command    ${SET_UE4_SA}
# 	
# Set UEs same position
# 	airphone_execute_egate_command    ${PROFILE1}	
# 	airphone_execute_egate_command    ${SET_UE2_SA_as UE1}
#     airphone_execute_egate_command    ${SET_UE3_SA_as UE1}	
#     airphone_execute_egate_command    ${SET_UE4_SA_as UE1}
# 
# Check ReservedMcs in ttitrace
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case34_reservedMCS.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 	
# Attach '${UE_NUM}' RANK4 SA UE
#     : FOR    ${num}    IN RANGE    ${UE_NUM}    ${UE_NUM}+1
#     \   airphone_cleanup_egate_console_log
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \   Wait '3s' for stabible
#     \   UE '${num}' send RANK4
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
# 
# Decrease two ports power
# 	airphone_execute_egate_command     ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
#     ...        multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0 srs_transmit_power_per_port\=-350,-500,-350,-500
# 	airphone_execute_egate_command     ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
# 
# Override RANK1 for UE1
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=0 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=0
# 	
# Override RANK4 for UE1 and UE2
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=10 cqi\=15 cqi_mode\=fixed ri\=3 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=10 scell\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=10 scell\=0
# 	
# Override RANK4 for UE3 and UE4
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=10 cqi\=15 cqi_mode\=fixed ri\=3 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=csi_override action\=activate profile_id\=10 scell\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=csi_override action\=activate profile_id\=10 scell\=0
# 	
# Override RANK2 for UE3 and UE4
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=9 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=csi_override action\=activate profile_id\=9 scell\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=csi_override action\=activate profile_id\=9 scell\=0
# 	
# Add bler on UE1UE2
# 	airphone_execute_egate_command    bler_testmode_nr profile_id\=8 dl_bler\=100,2,3,4 
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=8 action\=activate 
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=8 action\=activate 
# 
# Stop bler on UE1UE2
# 	airphone_execute_egate_command    bler_testmode_nr profile_id\=12 dl_bler\=100,0,0,0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=12 action\=activate 
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=12 action\=activate 
# 
# Analyse odftbeam in rrclog
# 	check_log_with_au2anlysis    ${CURDIR}/ini/odftbeam.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${RRC_Attach}_egate
# 		
# UE '${num}' send RANK4
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=3 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=1 scell\=0	
# 
# Stop '${SA_UE_NUM}' little buffer data
# 	 : FOR    ${num}    IN RANGE    1    ${SA_UE_NUM}+1
# 	 \    airphone_sa_stop_data_traffic    ue_id=${num}    direction=dl
# 	
# Check ttitrace'${ini_file}'
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 	
# Send '${SA_UE_NUM}' full buffer data
# 	: FOR    ${num}    IN RANGE    1    ${SA_UE_NUM}+1
# #    \   airphone_cleanup_egate_console_log
# #    \   Airphone SA Attach    ue_id=${num}
# #    \   Wait '2s' for stabible
# #    \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
# #    \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
# #    \   Wait '3s' for stabible
#     \   SA send mutiple trf dl data    ${num}    3    175M   ${num}
# #    \   SA send mutiple trf ul data    ${num}    1    20M   ${num}
# 	
# Send '${SA_UE_NUM}' little buffer data
#     : FOR    ${num}    IN RANGE    1    ${SA_UE_NUM}+1
# #    \   airphone_cleanup_egate_console_log
# #    \   Airphone SA Attach    ue_id=${num}
# #    \   Wait '2s' for stabible
# #    \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
# #    \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
# #    \   Wait '3s' for stabible
#     \   SA send mutiple trf dl data    ${num}    1     5M   ${num}
# #    \   SA send mutiple trf ul data    ${num}    1    20M   ${num}
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 	
# Verify throughput
#     ${dl_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_ue1}>140000
#     should_be_true    ${dl_throughput_ue2}>140000
# 
# collect and check '${ue_id}' BIP
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'BIP_ue_${ue_id}'
# 
#     #   Check PatternId in bip
#     Log To Console   Check PatternId in bip
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/bip_pdcch.csv    ${FILTER_1}    ${titles_1}
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/bip_pdsch.csv    ${FILTER_2}    ${titles_2}
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/bip_csi.csv    ${FILTER_3}    ${titles_3}
#     
#     Set test Variable    ${pdcch_patternId}    101
#     #rank 3/4 UE
#     Set test Variable    ${csi_patternid}     1375,1375,1052,1052
#     #2022_7_22_patternid_changed to 1051,1401
#     Run Keyword If   '${SW_BRANCH}'!='SBTS22R3'   Set test Variable   ${csi_patternid}   1051,1051,1401,1401   
#     Set test Variable    ${pdsch_patternid}    1375,1052
#     Run Keyword If   '${SW_BRANCH}'!='SBTS22R3'   Set test Variable   ${pdsch_patternid}   1051,1401
#     #rank 1/2 UE
#     Run Keyword If    '${ue_id}'=='1' or '${ue_id}'=='5' or '${ue_id}'=='6'    Set test Variable    ${pdsch_patternid}   1024
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pdcch_patternId_1024_case3.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pdsch_patternId_1024_case3.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_csi_patternId_1024_case3.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}
# 
#     Log To Console   Check PatternId in bip finisged
# 
# 
