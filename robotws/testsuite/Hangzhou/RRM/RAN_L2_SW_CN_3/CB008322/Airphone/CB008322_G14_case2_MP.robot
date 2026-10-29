# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# #Force Tags    owner_zhang   CLOUD_5G_I_MP_AP_LO
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8322_G14_8D4U_AQQL_1208_100M_SBsize16_case2_MP.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_1RF_8D4U_8192.xml
# ${WTS_NAME}    wts_8322_B2_SA_NSA.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog    
# 
# ${FILTER_f1ap}    (f1ap) && (nr-rrc.supportedSRS_TxPortSwitch)
# @{titles_f1ap}    nr-rrc.supportedSRS_TxPortSwitch
# 
# ${filter_csv}   (uldata_srsreceivereq||uldata_srsreceiverespbmps||uldata_srsreceiverespbwvps||dldata_pdschsendreq) && !(3gpp.rnti == 65535)
# 
# @{title_comb4}   3gpp.sfn   3gpp.slot   3gpp.rnti   
# ...   UlData_srsReceiveReqSubcell_t.srsSuMimoEnable
# ...   UlData_srsBwvReport_t.result   UlData_srsBwvReport_t.startPatternId   UlData_srsBwvReport_t.portPower_item   
# ...   UlData_srsBwvReport_t.correlation_item   UlData_srsBwvReport_t.numBwvPerSubband
# ...   UlData_srsReceiveReqSubcell_t.srsBmEnable   UlData_srsBmStruct_t.transmissionComb
# ...   UlData_srsBmCsInfo_t.srsResourceIdentity   UlData_srsBmCombShiftPairs_t.transmissionCombId   UlData_srsBmCsInfo_t.bmCyclicShift
# ...   UlData_srsBmSubbands_t.srsBmSubbandId   UlData_SrsReceiveRespBmPs_t.polarization
# ...   UlData_srsReceiveReqSubcell_t.srsBwvEnable   UlData_srsBwvStruct_t.transmissionComb
# ...   UlData_srsBwvReportRequest_t.srsResourceIdentity   UlData_srsCyclicShifts_t.transmissionCombId   UlData_srsCyclicShifts_t.cyclicShift
# ...   UlData_srsBwvReportRequest_t.bfSubbandId_item
# ...   DlData_PdschGrant.patternId_item   DlData_PdschGrant.numOfLayers
# ...   UlData_eCpriConfigStruct_t.patternId_item   UlData_eCpriConfigStruct_t.numCeAxCIndex
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# 
# ${PROFILE5_single}    ul_mimo_srs_beam_pos_nr profile_id\=5 init_quad_pos\=3 init_sub_quad_pos\=1 final_quad_pos\=1 final_sub_quad_pos\=3 step\=8
# ...   trigger_puxch_update\=4 mode\=single test_type\=SRS
# 
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS 
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250
# 
# ${PROFILE5_30}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS 
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250
# 
# ${PROFILE5_31}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS 
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250
# 
# ${PROFILE5_32}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS 
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250
# 
# ${PROFILE5_33}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS 
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250
# 
# ${PROFILE5_13}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 test_type\=SRS 
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250
# 
# ${PROFILE5_11}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS 
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250
# 
# ${PROFILE5_00}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS 
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250
# 
# ${PROFILE5_02}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 test_type\=SRS 
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250
# 
# ${PROFILE5_20}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS 
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250
# 
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# 
# ${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS 
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250
# 
# ${PROFILE11_pos2}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS 
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250
# 
# ${PROFILE11_power_bad}   ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS 
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-350,-350,-350,-350
# 
# ${PROFILE5_power_bad}   ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS 
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-450,-450,-450,-450
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# 
# ${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# ${SET_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
# ${SET_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
# ${SET_PROFILE11}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=11
# ${deactive_P11}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=11
# ${deactive_P5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=5
# ${delete_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 delete\=true
# ${delete_PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 delete\=true
# ${delete_PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 delete\=true
# ${delete_PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 delete\=true
# ${delete_PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 delete\=true
# ${delete_PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 delete\=true
# ${delete_PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 delete\=true
# ${delete_PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 delete\=true
# ${delete_PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 delete\=true
# 
# *** Test Cases ***
# # from D2_Case30
# CB008322_G14_case2_channel_volatile_check_rdIncludeHighVolatileUe_false
# 	Wts Execute Aashell Command   
# 	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
# 
# 	RD_G14
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
# 	online act CB08322 debug flag
# 
# 	Wait Until Keyword Succeeds    600s    10s   test_SA_UE5_t2r4
# 	
# 	test_rdSbSrsVolatCorrThreshold_100_SB_high_not_switch_WB
# 	test_rdWbSrsVolatCorrThreshold_100_WB_high_not_switch_SB
# 
# *** Keywords ***
# RD_G14
# 	Add GNB swconfig   	0x58053e:0		# rdIncludeHighVolatileUe, default=false
# 	Add GNB swconfig	0x58077a:1		# rdIncludeSrsVolatilityStatusMetric	# NIDD:enableSbSrsVolatilityCheck
# 	#Add GNB swconfig	0x580717:0		# rdPdcchApplyToSeparateStreams, default=true,attach issue WA
# 
# 	Add GNB swconfig    0x58076a:1		# rdNumWbSrsMeas, default=5;
# 	#The minimum number of correlation metric before correlation is used for measure radio link variety,set to 1 ,corrAvg=current average.
# 	Add GNB swconfig 	0x58077b:1		# rdNumSbSrsCorrCal, default=5
# 
# online_change_CorrThd
# 	Execute Aashell Command    rad -mw 0x58077c 80		#rdSbSrsVolatCorrThreshold,default=0.8
# 	Execute Aashell Command    rad -mw 0x58077d 90		#rdWbSrsVolatCorrThreshold,default=0.9
# 
# #===========================SA======t2r4===================
# test_SA_UE5_t2r4
# 	Log To Console   ${\n}--SA_t2r4---US1---buffer_lo_to_hi-----
# 	Start capture gnb and ap syslog in 'UE5_US1_case2' file
# 	airphone_cleanup_egate_console_log
# 	
# 	SA Register UE '5'
# 	Airphone Execute Egate Command    ${PROFILE5_31}
# 	Airphone Execute Egate Command    ${SET_PROFILE5}
# 	
# 	RANK'0'_CQI'15'_override_to_UE'5'
# 
# 	DL and UL data to '5' for dl_trf '1'	# 2x165M
# 	
# 	Start collect ttitrace
# 	: FOR    ${i}    IN RANGE    1    100
# 	\	Airphone Execute Egate Command    ${PROFILE5_31}
# 	\	Airphone Execute Egate Command    ${PROFILE5_13}
# 	\	Run Keyword If   ${i}==1 	RANK'3'_CQI'15'_override_to_UE'5'
# 	Wait for '0s' to stop ttitrace with name'G14_case2_tti_UE5_to_WB'
# 	
# 	get_egate_log_UE'tti_UE5_to_WB'
# 	run keyword and continue on failure   Stop capture gnb and ap syslog in 'UE5_US1_case2' file
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    20s    2s   check throughput from SA UE '5' to '5' with tp '165'
# 
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/G14_case2_tti_UE5_to_WB_dl.csv
# 
# 	DeRegister UE from '5' to '5'
# 	deactive p5
# 
# 	run keyword and continue on failure    check_G14_rdIncludeHighVolatileUe_single_UE
# 	...   ${TEST_LOG_DIRECTORY()}/All/syslog_UE5_US1_case2/UE5_US1_case2_gnb.tar.gz
#     ...   ${TEST_LOG_DIRECTORY()}/All/G14_case2_tti_UE5_to_WB_dl_split.csv
#     ...   rdIncludeHighVolatileUe=0   numWbSrsConfigSample=5
#     ...   rlqGoodPercentage=100   prbSampleHighLowPercentage=60
# 
# test_rdSbSrsVolatCorrThreshold_100_SB_high_not_switch_WB
# 	Start capture gnb and ap syslog in 'test_rdSbthd100' file
# 	Execute Aashell Command    rad -mw 0x58077c 100		#rdSbSrsVolatCorrThreshold,default=0.8
# 	
# 	Start collect ttitrace
# 	SA Register UE '5'
# 	Airphone Execute Egate Command    ${PROFILE5_31}
# 	Airphone Execute Egate Command    ${SET_PROFILE5}
# 	DL and UL data to '5' for dl_trf '1'	# x165M
# 	Wait for '2s' to stop ttitrace with name'tti_case2_rdSB100'
# 	
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    20s    2s   check throughput from SA UE '5' to '5' with tp '165'
# 	
# 	DeRegister UE from '5' to '5'
# 	deactive p5
# 	run keyword and continue on failure   Stop capture gnb and ap syslog in 'test_rdSbthd100' file
# 
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_case2_rdSB100_dl.csv
# 	
# 	Set test Variable    ${tti_title_tag}	tti_case2_rdSB100_dl_split.csv
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/tti_G14_case2_rdSB_100.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# test_rdWbSrsVolatCorrThreshold_100_WB_high_not_switch_SB
# 	Start capture gnb and ap syslog in 'test_rdWbthd100' file
# 	Execute Aashell Command    rad -mw 0x58077c 80		#rdSbSrsVolatCorrThreshold,default=0.8
# 	Execute Aashell Command    rad -mw 0x58077d 100		#rdWbSrsVolatCorrThreshold,default=0.9
# 
# 	SA Register UE '5'
# 	Airphone Execute Egate Command    ${PROFILE5_31}
# 	Airphone Execute Egate Command    ${SET_PROFILE5}
# 	DL and UL data to '5' for dl_trf '1'	# x165M
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_case2_rdWB100'
# 	
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    20s    2s   check throughput from SA UE '5' to '5' with tp '165'
# 	
# 	DeRegister UE from '5' to '5'
# 	deactive p5
# 	run keyword and continue on failure   Stop capture gnb and ap syslog in 'test_rdWbthd100' file
# 
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_case2_rdWB100_dl.csv
# 	
# 	Set test Variable    ${tti_title_tag}	tti_case2_rdWB100_dl_split.csv
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/tti_G14_case2_rdWB_100.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# Set UE5 P5
# 	Airphone Execute Egate Command    ${PROFILE5}
# 	Airphone Execute Egate Command    ${SET_PROFILE5}
# Set UE5 power_bad
# 	Airphone Execute Egate Command    ${PROFILE5_power_bad}
# 	Airphone Execute Egate Command    ${SET_PROFILE5}
# Set UE5 power_good
# 	Airphone Execute Egate Command    ${PROFILE5}
# 	#Airphone Execute Egate Command    ${SET_PROFILE5}
# deactive p5
# 	Airphone Execute Egate Command    ${deactive_P5}
# #===================end=====t2r4=================================
# 
# 
# # p11
# SEt UE11 P11
# 	Airphone Execute Egate Command    ${PROFILE11}
# 	Airphone Execute Egate Command    ${SET_PROFILE11}
# 
# Set UE11 power_bad
# 	Airphone Execute Egate Command    ${PROFILE11_power_bad}
# 	Airphone Execute Egate Command    ${SET_PROFILE11}
# 
# Set UE11 power_good
# 	Airphone Execute Egate Command    ${PROFILE11}
# 	#Airphone Execute Egate Command    ${SET_PROFILE11}
# 
# deactive p11
# 	Airphone Execute Egate Command    ${deactive_P11}
# 
# delete profile_11
# 	Airphone Execute Egate Command    ${delete_PROFILE11}	
# #=====end====NSA=====t1r4=============================	 
# 
# 
# check_tti_UE'${UE_ID}'
# 	Set test Variable    ${tti_title_tag}		tti_${UE_ID}_dl.csv
# 	Set test Variable    ${beam_type}   SUBBAND
# 	
# 	Set test Variable    ${ping_patternid_1}    2100
# 	Set test Variable    ${ping_patternid_2}    2171
# 	Set test Variable    ${ping_csi_patternid_1}    2172
# 	Set test Variable    ${ping_csi_patternid_2}    2173
# 	Set test Variable    ${ping_csi_patternid_3}    2174
# 	Set test Variable    ${ping_csi_patternid_4}    2175
# 	
# 	Set test Variable    ${pong_patternid_1}    2176
# 	Set test Variable    ${pong_patternid_2}    2247
# 	Set test Variable    ${pong_csi_patternid_1}    2248
# 	Set test Variable    ${pong_csi_patternid_2}    2249
# 	Set test Variable    ${pong_csi_patternid_3}    2250
# 	Set test Variable    ${pong_csi_patternid_4}    2251
# 		
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/tti_dl_8322_B2_case8.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# RANK'${rank}'_CQI'${cqi}'_override_to_UE'${ue_id}'
# 	Run Keyword If   ${ue_id}>10   Set test Variable    ${scell}	  8
# 	Run Keyword If   ${ue_id}<11   Set test Variable    ${scell}	  0
# 	Airphone Execute Egate Command	csi_override_testmode_nr profile_id\=${ue_id} cqi\=${cqi} cqi_mode\=fixed ri\=${rank} ri_mode\=fixed
# 	Airphone Execute Egate Command	ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=${ue_id} scell\=${scell}
# 
# deactive_rank_overide_UE'${ue_id}'
# 	Run Keyword If   ${ue_id}>10   Set test Variable    ${scell}	  8
# 	Run Keyword If   ${ue_id}<11   Set test Variable    ${scell}	  0
# 	Airphone Execute Egate Command	ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=deactivate profile_id\=${ue_id} scell\=${scell}
# 
# delete_Rank_override_UE'${ue_id}'
# 	Airphone Execute Egate Command	csi_override_testmode_nr profile_id\=${ue_id} delete\=true
# 
# Set UE1 position
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Wait '2s' for stabible
# 
# delete profile_1
# 	Airphone Execute Egate Command    ${delete_PROFILE1}
# 
# get_egate_log_UE'${ue_id}'
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
# 
# get_bip_UE'${bip_tag}'
# 	Start collect bip log
# 	Wait for '1s' to stop bip log with name'${bip_tag}'
# 	
# 	Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/${bip_tag}_0.csv    ${filter_csv}    ${title_comb4}
# 
# 	Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap1
# 	...    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/${bip_tag}_1.csv    ${filter_csv}    ${title_comb4}
#     
# get_tti_UE'${ue_id}'
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_${ue_id}'
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_${ue_id}_dl.csv
# #==========SA=======================
# SA Register UE '${UE_ID}'
# 	Log To Console   ${\n}-----register UE ${UE_ID} ------
# 	Airphone SA Attach    ue_id=${UE_ID}
# 	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
# 	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
# 	Wait '2s' for stabible	
# 
# SA Register UE from ${lo} to ${hi}
# 	: FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
# 	#\	airphone_cleanup_egate_console_log
#      \	Log To Console   ${\n}-----register UE ${ue} ------
#      \	SA Register UE ${ue}
#      #\	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}   unzip=TRUE
#      
# DL and UL data to '${UE_ID}' for dl_trf '${num}'
#     : FOR    ${i}    IN RANGE    1    ${num}+1
#     \	Airphone SA Start Data Traffic    ${UE_ID}   DL   165M   pdu_id=${UE_ID}   duration=3600   trf_id=${i}     
#     Airphone SA Start Data Traffic    ${UE_ID}   UL   5M    pdu_id=${UE_ID}   duration=3600   trf_id=1
#     #Wait '2s' for stabible
# 
# check throughput from SA UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
# 	${cell_tp_dl}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   Log To Console    Check throughput UE${num}
#     \      ${dl_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pdsch    tput_type=ave
#     \      ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
#     \      Log To Console		dl ${dl_tput_Mb}
#     \      ${cell_tp_dl}    evaluate    ${cell_tp_dl}+${dl_tput_Mb}
#     Log To Console		=====dl_cell_tp ${cell_tp_dl}=====
#     run keyword and continue on failure    should be true    ${cell_tp_dl}>=${dl_cell_tp}
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
# 
# #===========NSA======================
# NSA Attach UE from '${lo}' to '${hi}'
# 	: FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
# 	\    Log To Console   ${\n}--Attach NSA UE ${ue} --
# 	#\    airphone_cleanup_egate_console_log
# 	\	Airphone Nsa Attach     ${ue}    profile_id=None
# 	\	Wait '2s' for stabible
# 	#\	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}_attach   unzip=TRUE
# 
# check throughput from NSA UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
#     ${cell_tp_dl}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
# 	\	${pcell_tp}	Get cell dl throught	${num}    8
# 	\	${dl_tput_Mb}    evaluate    ${pcell_tp}/1000
# 	\	Log To Console    UE${num}_ul_tp ${dl_tput_Mb}M--
# 	\   ${cell_tp_dl}    evaluate    ${cell_tp_dl}+${dl_tput_Mb}
# 	Log To Console		=====ul_cell_tp ${cell_tp_dl}=====
# 	run keyword and continue on failure    should be true    ${cell_tp_dl}>=${dl_cell_tp}
# 
# Dettach UE from '${low}' to '${hi}'
# 	: FOR    ${num}    IN RANGE    ${low}    ${hi}+1
# 	\	Airphone NSA Detach    ue_id= ${num}
# 	\   Wait '3s' for stabible
# 
# #check tti
# Check '${UE_ID}' PatternId and Bler in ttiTrace
#     Log To Console    Check PatternId and Bler in ttiTrace: UE ${UE_ID}
#     check dft_beam and bler in tti
# 
# check dft_beam and bler in tti
#     Log To Console    Check ttitrace DL
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_dl_dft_1024_case3.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
#     Log To Console    Check ttitrace UL
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_ul_dft_1024_case3.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# #check RRC
# check UE '${ue_id}' SRS in RRC log
#     Log To Console   check UE ${ue_id} SRS in RRC log
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_ue${ue_id}_case3.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
