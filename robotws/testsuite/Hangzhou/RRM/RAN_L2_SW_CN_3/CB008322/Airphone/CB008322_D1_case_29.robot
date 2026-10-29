# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# #Force Tags    owner_zhang   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8322_D1_4D4U_AQQL_1208_100M_SBsize8_case29_1RF.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_1RF.xml
# ${WTS_NAME}    wts_8322_D1_SA_NSA_case29.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog    
# 
# ${FILTER_f1ap}    (f1ap) && (nr-rrc.supportedSRS_TxPortSwitch)
# @{titles_f1ap}    nr-rrc.supportedSRS_TxPortSwitch
# ${FILTER_1}    (dldata_pdcchsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_2}    (dldata_pdschsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# 
# ${filter_csv}   (uldata_puschreceivereq||uldata_srsreceivereq||uldata_srsreceiverespbmps||dldata_pdschsendreq) && !(3gpp.rnti == 65535)
# 
# @{tiltle_srsreceivereq}	3gpp.sfn   3gpp.slot   3gpp.rnti   UlData_srsReceiveReqSubcell_t.srsBwvEnable   
#    ...    UlData_srsReceiveReqSubcell_t.srsBmEnable   
# ...   Length   UlData_srsBwvReportRequest_t.bwvReportId
# ...   UlData_srsBwvReportRequest_t.numBwvPerSubband   UlData_srsBwvReportRequest_t.symbolPosition   UlData_srsBwvReportRequest_t.operation
# ...   UlData_srsBwvReportRequest_t.sinr   UlData_srsBwvReportRequest_t.rho   UlData_srsBwvReportRequest_t.numSrsPorts
# ...   UlData_srsBwvReportRequest_t.bfSubbandId_item
# ...   UlData_srsBwvReportRequest_t.srsResourceIdentity   UlData_srsBwvReportRequest_t.startPatternId   UlData_srsBwvReportRequest_t.numPatternId
# ...   UlData_srsCyclicShifts_t.transmissionCombId    UlData_srsCyclicShifts_t.cyclicShift   UlData_srsCyclicShifts_t.portIndex
# 
# @{tilte_srsreceiverespbwvps}	3gpp.sfn   3gpp.slot   3gpp.rnti   UlData_srsBwvReport_t.result  UlData_srsBwvReport_t.numBwvPerSubband    
# ...   UlData_srsReceiveRespBwvPsSubcell_t.fhTransDelay   UlData_srsBwvReport_t.bwvReportId   UlData_srsBwvReport_t.portPower_item 
# ...   UlData_srsBwvReport_t.startPatternId   
# 
# @{title_pdschsendreq}   3gpp.sfn   3gpp.slot   3gpp.rnti   3gpp.subcellid   DlData_PdschGrant.patternId_item   DlData_PdschGrant.numOfLayers   
# ...   DlData_PdschGrant.antPort   DlData_PdschGrant.numStreamIndex   DlData_PdschGrant.streamIndex_item   DlData_PdschGrant.mcs
# ...   DlData_PdschGrant.modulationOrder   DlData_PdschGrant.polarizationSelection   DlData_PdschGrant.closedLoop3gppCodebook 
# ...   DlData_PdschGrant.openLoopScheme   DlData_PdschGrant.bestBeamPowerOffset    DlData_PdschGrant.pdschTbTransmitPower
# 
# @{title_csirssendreq}   3gpp.sfn   3gpp.slot   3gpp.rnti   DlData_CsiRsResource_t.patternId_item   DlData_CsiRsResource_t.density   
# ...   DlData_CsiRsResource_t.csiRsConfig    DlData_CsiRsResource_t.numCeAxCIndex   DlData_CsiRsResource_t.ceAxCIndex_item   
# ...   DlData_CsiRsResource_t.csiBestBeamPowerOffset
# 
# @{title_all}   3gpp.sfn   3gpp.slot   3gpp.rnti   3gpp.subcellid
# ...   UlData_srsReceiveReqSubcell_t.srsBwvEnable   UlData_srsReceiveReqSubcell_t.srsBmEnable   
# ...   Length   UlData_srsBwvReportRequest_t.bwvReportId
# ...   UlData_srsBwvReportRequest_t.numBwvPerSubband   UlData_srsBwvReportRequest_t.symbolPosition   UlData_srsBwvReportRequest_t.operation
# ...   UlData_srsBwvReportRequest_t.sinr   UlData_srsBwvReportRequest_t.rho   UlData_srsBwvReportRequest_t.numSrsPorts   
# ...   UlData_srsBwvReportRequest_t.bfSubbandId_item
# ...   UlData_srsBwvReportRequest_t.srsResourceIdentity   UlData_srsBwvReportRequest_t.startPatternId   UlData_srsBwvReportRequest_t.numPatternId
# ...   UlData_srsCyclicShifts_t.transmissionCombId    UlData_srsCyclicShifts_t.cyclicShift   UlData_srsCyclicShifts_t.portIndex
# ...   UlData_srsBwvReport_t.result  UlData_srsBwvReport_t.numBwvPerSubband    
# ...   UlData_srsReceiveRespBwvPsSubcell_t.fhTransDelay   UlData_srsBwvReport_t.bwvReportId   UlData_srsBwvReport_t.portPower_item 
# ...   UlData_srsBwvReport_t.startPatternId   DlData_PdschGrant.patternId_item   DlData_PdschGrant.numOfLayers   
# ...   DlData_PdschGrant.antPort   DlData_PdschGrant.numStreamIndex   DlData_PdschGrant.streamIndex_item   DlData_PdschGrant.mcs
# ...   DlData_PdschGrant.modulationOrder   DlData_PdschGrant.polarizationSelection   DlData_PdschGrant.closedLoop3gppCodebook 
# ...   DlData_PdschGrant.openLoopScheme   DlData_PdschGrant.bestBeamPowerOffset    DlData_PdschGrant.pdschTbTransmitPower
# ...   DlData_CsiRsResource_t.patternId_item   DlData_CsiRsResource_t.density   
# ...   DlData_CsiRsResource_t.csiRsConfig    DlData_CsiRsResource_t.numCeAxCIndex   DlData_CsiRsResource_t.ceAxCIndex_item   
# ...   DlData_CsiRsResource_t.csiBestBeamPowerOffset
# 
# @{title_comb4}   3gpp.sfn   3gpp.slot   3gpp.rnti   UlData_srsReceiveReqSubcell_t.srsBmEnable   UlData_srsReceiveReqSubcell_t.srsBwvEnable
# ...   UlData_srsBmResource_t.srsResourceIdentity   UlData_srsBmResource_t.srsBmSubbandId   UlData_srsBmResource_t.transmissionCombId 
# ...   UlData_srsBmResource_t.bmCyclicShift   UlData_srsBmResource_t.startPrb
# ...   DlData_PdschGrant.patternId_item   DlData_PdschGrant.numOfLayers
# ...   UlData_srsRespBmPsResources_t.srsResourceIdentity   UlData_srsRespBmPsResources_t.srsBmSubbandId
# ...   UlData_srsRespBmPsResources_t.transmissionCombId   UlData_srsRespBmPsResources_t.bmCyclicShift   UlData_SrsReceiveRespBmPs_t.polarization
# ...   UlData_eCpriConfigStruct_t.patternId_item   UlData_eCpriConfigStruct_t.numCeAxCIndex
# 
# #UlData_srsBmResource_t.srsBmSubbandId
# #UlData_srsBmResource_t.transmissionCombId
# #UlData_srsBmResource_t.bmCyclicShift
# #UlData_srsBmResource_t.srsResourceIdentity
# #UlData_srsBmResource_t.startPrb
# 
# #UlData_srsRespBmPsResources_t.srsBmSubbandId
# #UlData_srsRespBmPsResources_t.transmissionCombId
# #UlData_srsRespBmPsResources_t.bmCyclicShift
# #UlData_srsRespBmPsResources_t.srsResourceIdentity
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=false num_of_nlos_paths\=1 azimuth\=0 zenith\=-14 srs_transmit_power_per_port\=-250,-250,-250,-250
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=-14 srs_transmit_power_per_port\=-250,-250,-250,-250
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=-14 srs_transmit_power_per_port\=-250,-250,-250,-250
# 
# ${PROFILE3_new}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS 
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=-14 srs_transmit_power_per_port\=-250,-250,-250,-250
# ${SET_PROFILE3}   ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# 
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=-14 srs_transmit_power_per_port\=-250,-250,-250,-250
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=-14 srs_transmit_power_per_port\=-250,-250,-250,-250
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=-14 srs_transmit_power_per_port\=-250,-250,-250,-250
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=-14 srs_transmit_power_per_port\=-150,-150,-150,-150
# 
# ${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS 
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=-14 srs_transmit_power_per_port\=-250,-250,-250,-250
# 
# ${PROFILE11_pos2}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS 
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=-14 srs_transmit_power_per_port\=-250,-250,-250,-250
# 
# ${PROFILE11_power_bad}   ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS 
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=-14 srs_transmit_power_per_port\=--350,-350,-350,-350
# 
# ${PROFILE5_power_bad}   ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS 
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=-14 srs_transmit_power_per_port\=--350,-350,-350,-350
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1-7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# 
# ${SET_PROFILE11}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=11
# ${deactive_P11}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=11
# ${deactive_P1}    ue_testmode_set_nr id\=1-7 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=1
# ${delete_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 delete\=true
# 
# *** Test Cases ***
# CB008322_D1_case029_Comb4_legacy_BF_1086_8247_multiple_UEs_SRS_config_SBsize8
# 	Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
# 
# 	Set UE1_7_P1
# 	
# 	SA Register UE '2'	#t1r4
# 	SA Register UE '3'	#t2r4
# 	
# 	#SA Register UE '1'	#t1r2
# 	#SA Register UE '4'	#t1r4-t2r4
# 	#SA Register UE '5'	#t1r1
# 	#SA Register UE '6'	#t2r2
# 	#SA Register UE '7'	#t4r4(~t2r4)
# 	
# *** Keywords ***
# Add RD		
# 	Add GNB swconfig    0x580434:0		#pdcch use best beam	
# 	#Add GNB swconfig    0x580264:3		#rdDlSrsLogControl,3:productH
# 
# Set UE1_7_P1
# 	Airphone Execute Egate Command    ${PROFILE1}
# 	Airphone Execute Egate Command    ${PROFILE2}
# 	Airphone Execute Egate Command    ${PROFILE3}
# 	Airphone Execute Egate Command    ${PROFILE4}
# 	Airphone Execute Egate Command    ${PROFILE5}
# 	Airphone Execute Egate Command    ${PROFILE6}
# 	Airphone Execute Egate Command    ${PROFILE7}
# 
# deactive p1
# 	Airphone Execute Egate Command    ${deactive_P1}
# 
# # UE1-6: check patternid 1,2
# check_tti_UE'${UE_ID}'
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_UE${UE_ID}'
# 	run keyword and continue on failure   reorder_csv_CB008247   ${TEST_LOG_DIRECTORY()}/All/tti_UE${UE_ID}_dl.csv
# 	run keyword and continue on failure   check_stable_DFT_patternid   ${TEST_LOG_DIRECTORY()}/All/tti_UE${UE_ID}_dl.csv
# 	
# 
# # t4r4: check best patternid only
# check_tti_t4r4_UE'${UE_ID}'
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_UE${UE_ID}'
# 	run keyword and continue on failure   reorder_csv_CB008247   ${TEST_LOG_DIRECTORY()}/All/tti_UE${UE_ID}_dl.csv
# 	
# 	Set test Variable    ${tti_title_tag}		tti_UE${UE_ID}_dl.csv
# 	Set test Variable    ${beam_type}    DFTNONTAPERING
# 	
# 	Set test Variable    ${patternId1}    1397
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/tti_dl_8322_D1_case29_t4r4_patternId.ini    log_need_to_check=i
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
# get_tti_UE'${ue_id}'
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_${ue_id}'
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_${ue_id}_dl.csv
# #==========SA=======================
# active position for UE_'${UE_ID}'
# 	Airphone Execute Egate Command   ue_testmode_set_nr id\=${UE_ID} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${UE_ID}
# deactive_profile_'${UE_ID}'
# 	Airphone Execute Egate Command   ue_testmode_set_nr id\=${UE_ID} testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=${UE_ID}
# 
# SA Register UE '${UE_ID}'
# 	Log To Console   ${\n}-----register UE ${UE_ID} ------
# 	airphone_cleanup_egate_console_log
# 	Start capture gnb and ap syslog in 'UE${UE_ID}' file
# 	Airphone SA Attach    ue_id=${UE_ID}
# 	
# 	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
# 	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
# 	Wait '2s' for stabible
# 	active position for UE_'${UE_ID}'
# 	
# 	DL and UL data to '${UE_ID}' for dl_trf '2'		# dlx165M; ulx165M
# 	run keyword and continue on failure    
# 	...   Wait Until Keyword Succeeds    20s    2s   check dl throughput from SA UE '${UE_ID}' to '${UE_ID}' with tp '300'
# 	
# 	check_tti_UE'${UE_ID}'		# check patternid in tti stable
# 
# 	Set test Variable    ${bip_tag}   BIP_UE${UE_ID}
# 	get_bip_UE'${bip_tag}'
# 
# 	run keyword and continue on failure   Stop capture gnb and ap syslog in 'UE${UE_ID}' file
# 	Run Keyword And Ignore Error   DeRegister UE from '${UE_ID}' to '${UE_ID}'
# 	deactive_profile_'${UE_ID}'
# 	get_egate_log_UE'${UE_ID}'
# 
# 	# check comb4 in bip
# 	Set test Variable    ${file_title_tag}		${bip_tag}_0.csv
# 		
# 	Run Keyword If    ${UE_ID}<3	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/bip_csv_D1_case29_comb4_UE2_t1r4.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_tag}/
# 	
# 	Run Keyword If    ${UE_ID}>2	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/bip_csv_D1_case29_comb4_UE3_t2r4.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_tag}/
# 
# get_bip_UE'${bip_tag}'
# 	Start collect bip log
# 	Wait for '1s' to stop bip log with name'${bip_tag}'
# 	
# 	Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/${bip_tag}_0.csv    ${filter_csv}    ${title_comb4}
# 
# 	##Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap1
# 	##...    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/${bip_tag}_1.csv    ${filter_csv}    ${title_comb4}
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
#     \   Airphone SA Start Data Traffic    ${UE_ID}   DL   160M   pdu_id=${UE_ID}   duration=3600   trf_id=${i}     
#     \   Airphone SA Start Data Traffic    ${UE_ID}   UL   5M    pdu_id=${UE_ID}   duration=3600   trf_id=${i}
#     #Wait '3s' for stabible
# 
# check dl throughput from SA UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
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
# check ul throughput from SA UE '${low}' to '${hi}' with tp '${ul_cell_tp}'
# 	${cell_tp_ul}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   Log To Console    Check throughput UE${num}
#     \      ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pusch    tput_type=ave
#     \      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     \      Log To Console		ul ${ul_tput_Mb}
#     \      ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}
#     Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
#     run keyword and continue on failure    should be true    ${cell_tp_ul}>=${ul_cell_tp}
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
# 
# #check RRC
# check UE '${ue_id}' SRS in RRC log
#     Log To Console   check UE ${ue_id} SRS in RRC log
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_ue${ue_id}_case3.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
