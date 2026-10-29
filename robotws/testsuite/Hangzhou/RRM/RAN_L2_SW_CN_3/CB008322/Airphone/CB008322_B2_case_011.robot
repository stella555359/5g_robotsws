# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# #Force Tags    owner_zhang    AP    SBTS00    RAN_5G_TDD    RAN_5G
# #...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}     SCFC_8322_B_4D4U_1116_3ms_100M_case11_1RF.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_1RF_9496.xml
# ${WTS_NAME}    wts_8322_B2_SA_NSA_case11.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog    
# 
# ${FILTER_f1ap}    (f1ap) && (nr-rrc.supportedSRS_TxPortSwitch)
# @{titles_f1ap}    nr-rrc.supportedSRS_TxPortSwitch
# ${FILTER_1}    (dldata_pdcchsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_2}    (dldata_pdschsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# 
# @{titles_1}    DlData_DciInfo.patternId_item
# @{titles_2}    DlData_PdschGrant.patternId_item
# @{titles_3}    DlData_CsiRsResource_t.patternId_item
# 
# ${filter_csv}   uldata_srsreceivereq || uldata_srsreceiverespbwvps ||((dldata_csirssendreq) && (DlData_CsiRsResource_t.csiRsConfig == 4))
# ...   ||((dldata_pdschsendreq) && !(3gpp.rnti == 65535))
# 
# @{tiltle_srsreceivereq}	3gpp.sfn   3gpp.slot   3gpp.rnti   UlData_srsReceiveReqSubcell_t.srsBwvEnable   UlData_srsReceiveReqSubcell_t.srsBmEnable   
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
# @{title_all}   3gpp.sfn   3gpp.slot   3gpp.rnti   
# ...   UlData_srsReceiveReqSubcell_t.srsBwvEnable     
# ...   UlData_srsBwvReport_t.result   UlData_srsBwvReport_t.numBwvPerSubband   UlData_srsBwvReport_t.portPower_item
# ...   UlData_srsBwvReport_t.startPatternId   UlData_srsReceiveRespBwvPsSubcell_t.fhTransDelay
# ...   DlData_PdschGrant.numStreamIndex   DlData_PdschGrant.numOfLayers	 DlData_PdschGrant.patternId_item
# ...   UlData_srsBwvReportRequest_t.srsResourceIdentity   UlData_srsBwvReportRequest_t.startPatternId
# ...   DlData_CsiRsResource_t.patternId_item
# ...   DlData_CsiRsResource_t.csiRsConfig   
# ...   DlData_PdschGrant.openLoopScheme
# ...   UlData_srsBwvReportRequest_t.bwvReportId
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-300,-300,-300,-300
# ${PROFILE1_1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 
# ...   test_type\=SRS multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0 srs_transmit_power_per_port\=-300,-300,-300,-300
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0
# ...   test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-300,-300,-300,-300
# 
# #path1=(q3,sq0)=(18,92)=1397;  path2=(0degre,0degree)=1344(but got 1373)
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1-8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# ${SET_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
# ${SET_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
# ${SET_PROFILE11}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=11
# ${deactive_p11}	ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=11
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
# ${phr_override_profile_1_CMD}    phr_override_testmode_nr profile_id\=1 phr_mode\=Fixed phr_start\=-23
# ...    phr_min\=-23 phr_max\=40 phr_step_size\=1 phr_period\=20 pc_max\=30
# 
# ${phr_activate_p1_CMD}    ue_testmode_set_nr id\=1-3 scell\=primary testmode\=phr_override profile_id\=1 action\=activate
# 
# ${phr_deactivate_p1_CMD}    ue_testmode_set_nr id\=1-3 scell\=primary testmode\=phr_override profile_id\=1 action\=deactivate
# 
# *** Test Cases ***
# # TWB=20; TSB=80
# CB008322_B2_case011_SRS_TRANS_and_waitingWbSrsUeList
# 	Wts Execute Aashell Command   
# 	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
# 
# 	Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
# 	online act CB08322 debug flag
# 	
# 	Set position1
# 	test_single_UE_switch
# 	test_8UE_t2r4
# 
# *** Keywords ***
# Add RD	
# 	Add GNB swconfig    0x5805b3:100	
# 	#rdSrsSwitchProhibitTimer(default=1000 slot)trigger 7 UEs added to waitingWbSrsUeList， not online change
# 
# test_single_UE_switch
# 	Set test Variable    ${i}   1  
# 	Start capture gnb and ap syslog in 'attach_UE${i}' file	
# 	airphone_cleanup_egate_console_log
# 	SA Register UE '${i}'
# 	DL and UL data to '${i}' for dl_trf '2'	# 1x165M
# 	get_egate_log_UE'attach_${i}'
# 	Stop capture gnb and ap syslog in 'attach_UE${i}' file
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    10s    2s   check throughput from SA UE '${i}' to '${i}' with tp '330'
# 	run keyword and continue on failure	check_singleUE_SB_WB_from_sys	${TEST_LOG_DIRECTORY()}/All/syslog_attach_UE1/attach_UE1_gnb.tar.gz
# 
# 	Start capture gnb and ap syslog in 'rank_bad' file
# 	Wait '1s' for stabible
# 	RANK'0'_cqi'15'_override_to_UE'${i}'
# 	Wait '2s' for stabible
# 	Stop capture gnb and ap syslog in 'rank_bad' file
# 	run keyword and continue on failure	check_singleUE_WB_SB_from_sys	${TEST_LOG_DIRECTORY()}/All/syslog_rank_bad/rank_bad_gnb.tar.gz
# 	
# 	Start capture gnb and ap syslog in 'rank_good' file
# 	Wait '1s' for stabible	#wait for srsSwitchProhibitTimer timeout print
# 	RANK'3'_cqi'15'_override_to_UE'${i}'
# 	Wait '2s' for stabible
# 	Stop capture gnb and ap syslog in 'rank_good' file
# 	run keyword and continue on failure	check_singleUE_SB_WB_from_sys	${TEST_LOG_DIRECTORY()}/All/syslog_rank_good/rank_good_gnb.tar.gz
# 	
# 	DeRegister UE from '${i}' to '${i}'
# #t2r4: UE1-9
# test_8UE_t2r4
# 	Set test Variable    ${ue_num}   9
# 	: FOR    ${i}    IN RANGE    1   ${ue_num}+1
# 	\	Start capture gnb and ap syslog in 'attach_UE${i}' file	
# 	\	airphone_cleanup_egate_console_log
# 	\	SA Register UE '${i}'
# 	\	DL and UL data to '${i}' for dl_trf '1'	# 1x165M
# 	\	get_egate_log_UE'attach_${i}'
# 	\	Stop capture gnb and ap syslog in 'attach_UE${i}' file
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    30s    2s   check throughput from SA UE '1' to '${ue_num}' with tp '1260'
# 	
# 	Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'tti_case11'
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_case11_dl.csv
# 	
# 	Wait '3s' for stabible
# 	
# 	Start capture gnb and ap syslog in '${ue_num}_UE' file
# 	Wait '4s' for stabible
# 	Stop capture gnb and ap syslog in '${ue_num}_UE' file
# 	run keyword and continue on failure   check_waitingWbSrsUeList   ${TEST_LOG_DIRECTORY()}/All/syslog_${ue_num}_UE/${ue_num}_UE_gnb.tar.gz
# 	...   target_max_length=7
# 	
# 	DeRegister UE from '1' to '${ue_num}'
# 
# DL and UL data to '${UE_ID}' for dl_trf '${num}'
#     : FOR    ${i}    IN RANGE    1    ${num}+1
#     \	Airphone SA Start Data Traffic    ${UE_ID}   DL   165M   pdu_id=${UE_ID}   duration=3600   trf_id=${i}     
#     #Airphone SA Start Data Traffic    ${UE_ID}   UL   5M    pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Wait '3s' for stabible
# 
# check_tti_UE'${UE_ID}'
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_${UE_ID}'
# 	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_${UE_ID}_dl.csv
# 
# 	Set test Variable    ${tti_title_tag}		tti_${UE_ID}_dl.csv
# 	Set test Variable    ${beam_type}   SUBBAND
# 	
# 	Set test Variable    ${ping_patternid_1}    5000
# 	Set test Variable    ${ping_patternid_2}    5071
# 	Set test Variable    ${ping_csi_patternid_1}    5072
# 	Set test Variable    ${ping_csi_patternid_2}    5073
# 	Set test Variable    ${ping_csi_patternid_3}    5074
# 	Set test Variable    ${ping_csi_patternid_4}    5075
# 	
# 	Set test Variable    ${pong_patternid_1}    5076
# 	Set test Variable    ${pong_patternid_2}    5147
# 	Set test Variable    ${pong_csi_patternid_1}    5148
# 	Set test Variable    ${pong_csi_patternid_2}    5149
# 	Set test Variable    ${pong_csi_patternid_3}    5150
# 	Set test Variable    ${pong_csi_patternid_4}    5151
# 		
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/tti_dl_8322_B2_case8.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# RANK'${rank}'_cqi'${cqi}'_override_to_UE'${ue_id}'
# 	Run Keyword If   ${ue_id}>10   Set test Variable    ${scell}	  8
# 	Run Keyword If   ${ue_id}<11   Set test Variable    ${scell}	  0
# 	Airphone Execute Egate Command	csi_override_testmode_nr profile_id\=${ue_id} cqi\=${cqi} cqi_mode\=fixed ri\=${rank} ri_mode\=fixed
# 	Airphone Execute Egate Command	ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=${ue_id} scell\=${scell}
# 
# deactive_rank_overide_UE'${ue_id}'
# 	Run Keyword If   ${ue_id}>10   Set test Variable    ${scell}	  8
# 	Run Keyword If   ${ue_id}<11   Set testVariable    ${scell}	  0
# 	Airphone Execute Egate Command	ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=deactivate profile_id\=${ue_id} scell\=${scell}
# 
# delete_Rank_override_UE'${ue_id}'
# 	Airphone Execute Egate Command	csi_override_testmode_nr profile_id\=${ue_id} delete\=true
# 
# Set position1
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
# Set UE1 position2
#     Airphone Execute Egate Command    ${PROFILE1_1}
#     #Airphone Execute Egate Command    ${SET_PROFILE1}
#     #Wait '2s' for stabible
# Set UE11 position
#     Airphone Execute Egate Command    ${PROFILE11}
#     Airphone Execute Egate Command    ${SET_PROFILE11}
#     Wait '2s' for stabible
# delete profile_1
# 	Airphone Execute Egate Command    ${delete_PROFILE1}
# delete profile_11
# 	Airphone Execute Egate Command    ${delete_PROFILE11}
# deactive_p11
# 	Airphone Execute Egate Command    ${deactive_p11}
# 
# get_tti_UE'${ue_id}'
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_${ue_id}'
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_${ue_id}_dl.csv
# 
# get_egate_log_UE'${ue_id}'
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
# 
# get_bip_UE'${ue_id}'
# 	Start collect bip log
# 	Wait for '2s' to stop bip log with name'BIP_${ue_id}'
# 	
# 	Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_${ue_id}/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_${ue_id}/bip_8322.csv    ${filter_csv}    ${title_all}
# 
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
# 	#\    Log To Console   ${\n}--Attach NSA UE ${ue} --
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
