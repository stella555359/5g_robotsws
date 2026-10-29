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
# ${SCFC_NAME}      SCFC_8322_D2_8D4U_AQQL_1208_100M_SBsize128_case31_1RF.xml
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
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5
#    ...     trigger_puxch_update\=0 test_type\=SRS
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
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-350,-350,-350,-350
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
# ${deactive_P4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=4
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
# # from B2_case8,9
# # 1)NIDD deltacqi=0 for cqi trigger;
# # 2)for power trigger:if gainCorrection=12,set srsQualityThreshold=-90,badThd=-95
# CB008322_D2_case031_Comb4_TAS_SRS_Switch_between_WB_SB_ BfSubbandSize_128
# 	Wts Execute Aashell Command   
# 	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
# 
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
# 	online act CB08322 debug flag
# 	
# 	attach_UE4
# 	attach_UE5
# 	check_2UE_bip_RT
# 	
# 	WB_to_SB_UE45
# 	check_2UE_bip_DFT
# 	
# 	SB_to_WB_UE45
# 	check_2UE_bip_RT_again
# 	
# 	deactive p4
# 	deactive p5
# 	DeRegister UE from '4' to '5'
# *** Keywords ***
# #===================SA===UE4:t1r4=====UE5:t2r4=========
# attach_UE4
# 	Log To Console   ${\n}--SA_t2r4---US1---buffer_lo_to_hi-----
# 	Start capture gnb and ap syslog in 'UE4' file
# 	
# 	airphone_cleanup_egate_console_log
# 	SA Register UE '4'
# 	Set UE4 P4
# 	Start collect ttitrace
# 	DL and UL data to '4' for dl_trf '2'	# 2x165M
# 	Wait for '1s' to stop ttitrace with name'tti_UE4'
# 	get_egate_log_UE'4_buffer_lo2hi'
# 	Stop capture gnb and ap syslog in 'UE4' file
# 
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_UE4_dl.csv
# 	
# 	run keyword and continue on failure    check_SB_to_WB_tti   ${TEST_LOG_DIRECTORY()}/All/tti_UE4_dl_split.csv
# 	...    ${TEST_LOG_DIRECTORY()}/All/syslog_UE4/UE4_gnb.tar.gz   rdNumSrsCheck=5   rdSrsRlqGoodPercent=60   rdSrsBufPercent=60
# 
# 	Wait '5s' for stabible
# 
# attach_UE5
# 	Start capture gnb and ap syslog in 'UE4_5' file
# 	airphone_cleanup_egate_console_log
# 	SA Register UE '5'
# 	Set UE5 P5
# 	Start collect ttitrace
# 	DL and UL data to '5' for dl_trf '2'	# 2x165M
# 	Wait for '1s' to stop ttitrace with name'tti_UE45'
# 	
# 	check_UE45_tti
# 	
# 	get_egate_log_UE'5_buffer_lo2hi'
# 	Stop capture gnb and ap syslog in 'UE4_5' file
# 	
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    20s    2s   check throughput from SA UE '4' to '5' with tp '660'
# 
# check_UE45_tti
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_UE45_dl.csv
# 	
# 	Set test Variable    ${tti_title_tag}		tti_UE45_dl_split.csv
# 	
# 	Set test Variable    ${UE1_ping_start_patternid_1}   1431
# 	Set test Variable    ${UE1_ping_start_patternid_2}   1442
# 	Set test Variable    ${UE1_pong_start_patternid_1}   1447
# 	Set test Variable    ${UE1_pong_start_patternid_2}   1458
# 	Set test Variable    ${UE2_ping_start_patternid_1}   1463
# 	Set test Variable    ${UE2_ping_start_patternid_2}   1474
# 	Set test Variable    ${UE2_pong_start_patternid_1}   1479
# 	Set test Variable    ${UE2_pong_start_patternid_2}   1490
# 
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/tti_D2_case31_comb4.ini    log_need_to_check=i   save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# WB_to_SB_UE45
# 	Log To Console   ${\n}----WB_to_SB_UE45----
# 	Set test Variable    ${tti_tag}   tti_2UE_to_SB
# 	
# 	Start collect ttitrace
# 	RANK'0'_CQI'15'_override_to_UE'4'
# 	RANK'0'_CQI'15'_override_to_UE'5'
# 	Wait for '1s' to stop ttitrace with name'${tti_tag}'
# 
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
# 	Set test Variable    ${tti_title_tag}		${tti_tag}_dl_split.csv
# 	
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/tti_D2_case31_UE45_to_SB.ini    log_need_to_check=i   save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# SB_to_WB_UE45
# 	Log To Console   ${\n}----SB_to_WB_UE45----
# 	Set test Variable    ${tti_tag}   tti_2UE_to_WB
# 	Start collect ttitrace
# 	RANK'3'_CQI'15'_override_to_UE'4'
# 	RANK'3'_CQI'15'_override_to_UE'5'
# 	Wait for '1s' to stop ttitrace with name'${tti_tag}'
# 
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
# 	Set test Variable    ${tti_title_tag}		${tti_tag}_dl_split.csv
# 	
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/tti_D2_case31_UE45_to_WB.ini    log_need_to_check=i   save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# check_UE45_tti_DFT
# 	Set test Variable    ${tti_tag}   tti_2UE_DFT
# 	Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'${tti_tag}'
# 
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
# 	Set test Variable    ${tti_title_tag}		${tti_tag}_dl_split.csv
# 
# 	Set test Variable   ${srsState}    'SBSRS'
# 	Set test Variable   ${beam_type}    DFTNONTAPERING
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/tti_D2_case31_2UE_beam.ini    log_need_to_check=i   save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# check_UE45_tti_RT
# 	Set test Variable    ${tti_tag}   tti_2UE_RT
# 	Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'${tti_tag}'
# 
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
# 	Set test Variable    ${tti_title_tag}		${tti_tag}_dl_split.csv
# 
# 	Set test Variable   ${srsState}    'WBSRS'
# 	Set test Variable   ${beam_type}    SUBBAND
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/tti_D2_case31_2UE_beam.ini    log_need_to_check=i   save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# check_UE4_bip
# 	Set Global Variable   ${bip_tag}   BIP_UE4
# 	get_bip_UE'${bip_tag}'
# 
# 	Set test Variable    ${file_title_tag}		${bip_tag}_0.csv
# 	Set test Variable    ${combId}   3,3
# 
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/bip_csv_D2_case31_comb4_WB_SRS.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_tag}/
# 
# check_UE5_bip
# 	Set Global Variable   ${bip_tag}   BIP_UE5
# 	get_bip_UE'${bip_tag}'
# 
# 	Set test Variable    ${file_title_tag}		${bip_tag}_0.csv
# 	Set test Variable    ${combId}   3,3
# 
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/bip_csv_D2_case31_comb4_WB_SRS.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_tag}/
# 
# check_2UE_bip_RT
# 	Set Global Variable   ${bip_tag}   BIP_UE45
# 	get_bip_UE'${bip_tag}'
# 
# 	Set test Variable    ${file_title_tag}		${bip_tag}_0.csv
# 	Set test Variable    ${combId}   3,3
# 
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/bip_csv_D2_case31_comb4_WB_SRS.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_tag}/
# 
# check_2UE_bip_RT_again
# 	Set Global Variable   ${bip_tag}   BIP_UE45_agian
# 	get_bip_UE'${bip_tag}'
# 
# 	Set test Variable    ${file_title_tag}		${bip_tag}_0.csv
# 	Set test Variable    ${combId}   3,3
# 
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/bip_csv_D2_case31_comb4_WB_SRS.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_tag}/
# 
# check_2UE_bip_DFT
# 	Set Global Variable   ${bip_tag}   BIP_UE45_DFT
# 	get_bip_UE'${bip_tag}'
# 
# 	Set test Variable    ${file_title_tag}		${bip_tag}_0.csv
# 
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/bip_csv_D2_case31_comb4_SB_SRS.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_tag}/
# #===========================SA======t2r4===================
# test_SA_UE5_t2r4
# 	UE5_get_tti_buffer_lo_hi
# 
# 	UE5_get_tti_rank4_2			# US2: rank 4-2
# 	RANK'3'_CQI'15'_override_to_UE'5'
# 	#Wait '5s' for stabible
# 	#UE5_get_tti_rank2_4			# US3: rank 2-4
# 
# 	#UE5_get_tti_cqi_3			# US4: cqi 15-4
# 	
# 	#UE5_get_tti_cqi_15			# US5: cqi 4-15
# 	
# 	#UE5_get_tti_power_bad		# US6: port power 85 - 100
# 	#UE5_get_tti_power_good		# US7: port power 100 - 85
# 	
# 	#UE5_get_bip_rank4_2
# 	#UE5_get_bip_cqi_3
# 	#UE5_get_bip_power_bad
# 	#Set UE5 power_good
# 	deactive p5
# 	DeRegister UE from '5' to '5'
# #us1
# UE5_get_tti_buffer_lo_hi
# 	Log To Console   ${\n}--SA_t2r4---US1---buffer_lo_to_hi-----
# 	Start capture gnb and ap syslog in 'UE5_US1' file
# 	airphone_cleanup_egate_console_log
# 	SA Register UE '5'
# 	Set UE5 P5
# 	Start collect ttitrace
# 	DL and UL data to '5' for dl_trf '3'	# 3x165M
# 	Wait for '1s' to stop ttitrace with name'tti_UE5_buffer_lo_2_hi'
# 	get_egate_log_UE'5_buffer_lo2hi'
# 	Stop capture gnb and ap syslog in 'UE5_US1' file
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    20s    2s   check throughput from SA UE '5' to '5' with tp '495'
# 	
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_UE5_buffer_lo_2_hi_dl.csv
# 	
# 	run keyword and continue on failure    check_SB_to_WB_tti   ${TEST_LOG_DIRECTORY()}/All/tti_UE5_buffer_lo_2_hi_dl_split.csv
# 	...    ${TEST_LOG_DIRECTORY()}/All/syslog_UE5_US1/UE5_US1_gnb.tar.gz   rdNumSrsCheck=5   rdSrsRlqGoodPercent=60   rdSrsBufPercent=60
# 
# 	Set test Variable    ${tti_title_tag}		tti_UE5_buffer_lo_2_hi_dl.csv
# 	Set test Variable    ${ratio}    0.999	
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/tti_dl_bler_ratio.ini    log_need_to_check=i   save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# 	Set Global Variable   ${bip_tag}   BIP_UE5_buffer_lo_hi
# 	get_bip_UE'${bip_tag}'
# 
# 	run keyword and continue on failure   check_D2_SB_WB_SRS_align_with_bip
# 	...   ${TEST_LOG_DIRECTORY()}/All/syslog_before_onair/before_onair_gnb.tar.gz
# 	...   ${TEST_LOG_DIRECTORY()}/All/egate_UE_5_buffer_lo2hi/egate_console.log.001
# 	...   ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/${bip_tag}_0.csv
# 	##...   ${CURDIR}/before_onair_gnb.tar.gz
# 
# 	Set test Variable    ${file_title_tag}		${bip_tag}_0.csv
# 	Set test Variable    ${combId}   3,3
# 	Set test Variable    ${start_patternid_1}   5000,65535
# 	Set test Variable    ${start_patternid_2}   5144,65535
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/bip_csv_D2_case30_comb4_WB_SRS.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_tag}/
# 	
# 	Wait '3s' for stabible
# #us2	
# UE5_get_tti_rank4_2
# 	Log To Console   ${\n}--t2r4---US2---rank4---2-----
# 	Start capture gnb and ap syslog in 'UE5_US2' file
# 	Start collect ttitrace
# 	airphone_cleanup_egate_console_log
# 	RANK'1'_CQI'15'_override_to_UE'5'
# 	Wait for '1s' to stop ttitrace with name'tti_UE5_rank42'
# 	get_egate_log_UE'5_rank42'
# 	Stop capture gnb and ap syslog in 'UE5_US2' file
# 
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_UE5_rank42_dl.csv
# 
# 	# check ACK ration 0.999
# 	Set test Variable    ${tti_title_tag}		tti_UE5_rank42_dl.csv
# 	Set test Variable    ${ratio}    0.999	
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/tti_dl_bler_ratio.ini    log_need_to_check=i   save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 	
# 	# check WB-SB in tti
# 	run keyword and continue on failure    check_tti_single_UE_bad_RLQ   ${TEST_LOG_DIRECTORY()}/All/tti_UE5_rank42_dl_split.csv   target=ri
# 	...   gainCorrection=${gainCorrection}   rdNumSrsCheck=5   rdSrsRlqBadPercent=50   rdSrsBufPercent=60
# 
# 	# check DFT patternid in tti 
# 	run keyword and continue on failure   check_stable_DFT_patternid   ${TEST_LOG_DIRECTORY()}/All/tti_UE5_rank42_dl.csv
# 	...   target_patternid_1=1397   target_patternid_2=1397
# 
# 	# cehck bip SB SRS allocaiton
# 	Set Global Variable   ${bip_tag}   BIP_UE5_rank4_2
# 	get_bip_UE'${bip_tag}'
# 
# 	Set test Variable    ${file_title_tag}		${bip_tag}_0.csv
# 	Set test Variable    ${combId}   2
# 	Set test Variable    ${DFT_patternid}   1397,1397
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/bip_csv_D2_case30_comb4_SB_SRS.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_tag}/
# 	
# 	Wait '5s' for stabible
# 
# #us3
# UE5_get_tti_rank2_4
# 	Log To Console   ${\n}--t2r4---US3----rank2----4------
# 	Start capture gnb and ap syslog in 'UE5_US3' file
# 	Start collect ttitrace
# 	airphone_cleanup_egate_console_log
# 	RANK'3'_CQI'15'_override_to_UE'5'
# 	Wait for '2s' to stop ttitrace with name'tti_UE5_rank24'
# 	get_egate_log_UE'5_rank24'
# 	Stop capture gnb and ap syslog in 'UE5_US3' file
# 	
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_UE5_rank24_dl.csv
# 	run keyword and continue on failure    check_SB_to_WB_tti   ${TEST_LOG_DIRECTORY()}/All/tti_UE5_rank24_dl_split.csv
# 	...    ${TEST_LOG_DIRECTORY()}/All/syslog_UE5_US3/UE5_US3_gnb.tar.gz   rdNumSrsCheck=5   rdSrsRlqGoodPercent=60   rdSrsBufPercent=60
# 	
# 	Wait '5s' for stabible
# 
# UE5_get_bip_rank4
# # bad power thd=--100-5=-105
# 	Log To Console   ${\n}--t2r4---US8:--rank4 BIP---
# 	Start capture gnb and ap syslog in 'UE5_rank4' file
# 	airphone_cleanup_egate_console_log
# 	Start collect bip log
# 	RANK'3'_CQI'15'_override_to_UE'5'
# 	Wait for '1s' to stop bip log with name'BIP_rank4'
# 	
# 	get_egate_log_UE'5_rank4'
# 	Stop capture gnb and ap syslog in 'UE5_rank4' file
# 	
# 	
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_rank4/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_rank4/BIP_rank4_0.csv    ${filter_csv}    ${title_comb4}
# 
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_rank4/tcpdump_L2L1_bip_filtering_off.pcap1
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_rank4/BIP_rank4_1.csv    ${filter_csv}    ${title_comb4}
# 
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_rank4/tcpdump_L2L1_bip_filtering_off.pcap2
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_rank4/BIP_rank4_2.csv    ${filter_csv}    ${title_comb4}
# 
# 
# #us4		
# UE5_get_tti_cqi_3
# 	Log To Console   ${\n}--t2r4---US4----cqi_3-----
# 	Start capture gnb and ap syslog in 'UE5_US4' file
# 	Start collect ttitrace
# 	airphone_cleanup_egate_console_log
# 	RANK'3'_CQI'3'_override_to_UE'5'
# 	Wait for '2s' to stop ttitrace with name'tti_UE5_cqi_3'
# 	get_egate_log_UE'5_cqi_3'
# 	Stop capture gnb and ap syslog in 'UE5_US4' file
# 	
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_UE5_cqi_3_dl.csv
# 	run keyword and continue on failure    check_tti_single_UE_bad_RLQ   ${TEST_LOG_DIRECTORY()}/All/tti_UE5_cqi_3_dl_split.csv   target=SE
# 	...   gainCorrection=${gainCorrection}   rdNumSrsCheck=5   rdSrsRlqBadPercent=50   rdSrsBufPercent=60
# 
# 	run keyword and continue on failure   check_stable_DFT_patternid   ${TEST_LOG_DIRECTORY()}/All/tti_UE5_cqi_3_dl.csv
# 	...   target_patternid_1=1397   target_patternid_2=1373
# 
# 	Wait '5s' for stabible
# #us5
# UE5_get_tti_cqi_15
# 	Log To Console   ${\n}--t2r4---US5----cqi 15----
# 	Start capture gnb and ap syslog in 'UE5_US5' file
# 	Start collect ttitrace
# 	airphone_cleanup_egate_console_log
# 	RANK'3'_CQI'15'_override_to_UE'5'
# 	Wait for '2s' to stop ttitrace with name'tti_UE5_cqi_15'
# 	get_egate_log_UE'5_cqi_15'
# 	Stop capture gnb and ap syslog in 'UE5_US5' file
# 	
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_UE5_cqi_15_dl.csv
# 	run keyword and continue on failure    check_SB_to_WB_tti   ${TEST_LOG_DIRECTORY()}/All/tti_UE5_cqi_15_dl_split.csv
# 	...    ${TEST_LOG_DIRECTORY()}/All/syslog_UE5_US5/UE5_US5_gnb.tar.gz   rdNumSrsCheck=5   rdSrsRlqGoodPercent=60   rdSrsBufPercent=60
# 	
# 	Wait '5s' for stabible
# 
# 
# 
# UE5_get_tti_power_bad
# 	Log To Console   ${\n}--t2r4---US6----power--bad-----
# 	Start capture gnb and ap syslog in 'UE5_US6' file
# 	Start collect ttitrace
# 	airphone_cleanup_egate_console_log
# 	Set UE5 power_bad
# 	Wait for '2s' to stop ttitrace with name'tti_UE5_power_bad'
# 	get_egate_log_UE'5_power_bad'
# 	Stop capture gnb and ap syslog in 'UE5_US6' file
# 	
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_UE5_power_bad_dl.csv
# 	run keyword and continue on failure    check_tti_single_UE_bad_RLQ   ${TEST_LOG_DIRECTORY()}/All/tti_UE5_power_bad_dl_split.csv   target=power
# 	...   gainCorrection=${gainCorrection}   rdNumSrsCheck=5   rdSrsRlqBadPercent=50   
# 	# bad_power_thd_dbm=-95   rdSrsBufPercent=60
# 	run keyword and continue on failure   check_stable_DFT_patternid   ${TEST_LOG_DIRECTORY()}/All/tti_UE5_power_bad_dl.csv
# 	...   target_patternid_1=1397   target_patternid_2=1373
# 
# 	Wait '5s' for stabible
# 
# UE5_get_bip_rank4_2
# 	Log To Console   ${\n}--t2r4---US8:--rank4_2 BIP---
# 	Start capture gnb and ap syslog in 'UE5_rank4' file
# 	airphone_cleanup_egate_console_log
# 	Set Global Variable    ${bip_tag}    BIP_t2r4_rank4_2
# 	
# 	Start collect bip log
# 	RANK'1'_CQI'15'_override_to_UE'5'
# 	Wait for '1s' to stop bip log with name'${bip_tag}'
# 	
# 	get_egate_log_UE'5_rank4_2'
# 	Stop capture gnb and ap syslog in 'UE5_rank4' file
# 	
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/${bip_tag}_0.csv    ${filter_csv}    ${title_comb4}
# 
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap1
# 	...    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/${bip_tag}_1.csv    ${filter_csv}    ${title_comb4}
# 
# 	RANK'3'_CQI'15'_override_to_UE'5'
# 	
# 	check_RT_beam_aging_in_bip   ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/${bip_tag}_0.csv   WB_SRS_period=20   rdSubbandBeamAgingConstant=5
# 	Wait '5s' for stabible
# 
# UE5_get_bip_cqi_3
# 	Log To Console   ${\n}--t2r4---US8:--cqi_3 BIP---
# 	Start capture gnb and ap syslog in 'UE5_rank4' file
# 	airphone_cleanup_egate_console_log
# 	Set Global Variable    ${bip_tag}    BIP_t2r4_cqi_3
# 	
# 	Start collect bip log
# 	RANK'3'_CQI'3'_override_to_UE'5'
# 	Wait for '1s' to stop bip log with name'${bip_tag}'
# 	
# 	get_egate_log_UE'5_rank4_2'
# 	Stop capture gnb and ap syslog in 'UE5_rank4' file
# 	
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/${bip_tag}_0.csv    ${filter_csv}    ${title_comb4}
# 
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap1
# 	...    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/${bip_tag}_1.csv    ${filter_csv}    ${title_comb4}
# 
# 	RANK'3'_CQI'15'_override_to_UE'5'
# 	
# 	check_RT_beam_aging_in_bip   ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/${bip_tag}_0.csv   WB_SRS_period=20   rdSubbandBeamAgingConstant=5
# 	Wait '5s' for stabible
# 
# UE5_get_bip_power_bad
# # bad power thd=--100-5=-105
# 	Log To Console   ${\n}--t2r4---US8:--power bad BIP---
# 	Start capture gnb and ap syslog in 'UE5_power_bad_bip' file
# 	Set Global Variable    ${bip_tag}    BIP_t2r4_power_bad
# 	airphone_cleanup_egate_console_log
# 	Start collect bip log
# 	Wait '0.1s' for stabible
# 	Set UE5 power_bad
# 	Wait for '1s' to stop bip log with name'${bip_tag}'
# 	
# 	get_egate_log_UE'5_power_bad'
# 	Stop capture gnb and ap syslog in 'UE5_power_bad_bip' file
# 	
# 	Set UE5 power_good
# 	
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/${bip_tag}_0.csv    ${filter_csv}    ${title_comb4}
# 
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap1
# 	...    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/${bip_tag}_1.csv    ${filter_csv}    ${title_comb4}
# 
# 	check_RT_beam_aging_in_bip   ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/${bip_tag}_0.csv   WB_SRS_period=20   rdSubbandBeamAgingConstant=5
# 	
# 	#Wait '3s' for stabible
# #us7
# UE5_get_tti_power_good
# 	Log To Console   ${\n}--t2r4---US7----power--good-----
# 	Start capture gnb and ap syslog in 'UE5_US7' file
# 	Start collect ttitrace
# 	airphone_cleanup_egate_console_log
# 	Set UE5 power_good
# 	Wait for '2s' to stop ttitrace with name'tti_UE5_power_good'
# 	get_egate_log_UE'5_power_good'
# 	Stop capture gnb and ap syslog in 'UE5_US7' file
# 	
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_UE5_power_good_dl.csv
# 	run keyword and continue on failure    check_SB_to_WB_tti   ${TEST_LOG_DIRECTORY()}/All/tti_UE5_power_good_dl_split.csv
# 	...    ${TEST_LOG_DIRECTORY()}/All/syslog_UE5_US7/UE5_US7_gnb.tar.gz   rdNumSrsCheck=5   rdSrsRlqGoodPercent=60   rdSrsBufPercent=60
# 	
# 	Wait '5s' for stabible
# 
# Set UE5 P5
# 	Airphone Execute Egate Command    ${PROFILE5}
# 	Airphone Execute Egate Command    ${SET_PROFILE5}
# Set UE4 P4
# 	Airphone Execute Egate Command    ${PROFILE4}
# 	Airphone Execute Egate Command    ${SET_PROFILE4}
# Set UE5 power_bad
# 	Airphone Execute Egate Command    ${PROFILE5_power_bad}
# 	Airphone Execute Egate Command    ${SET_PROFILE5}
# Set UE5 power_good
# 	Airphone Execute Egate Command    ${PROFILE5}
# 	#Airphone Execute Egate Command    ${SET_PROFILE5}
# deactive p5
# 	Airphone Execute Egate Command    ${deactive_P5}
# deactive p4
# 	Airphone Execute Egate Command    ${deactive_P4}
# #===================end=====t2r4=================================
# 
# #==============NSA=====t1r4======================================
# test_NSA_UE11_t1r4
# 	UE11_get_tti_buffer_lo_hi
# 	
# 	#UE11_get_tti_rank4_2		# US2: rank 4-2
# 	#UE11_get_tti_rank2_4		# US3: rank 2-4
# 	
# 	UE11_get_tti_cqi_3			# US4: cqi 15-4
# 	UE11_get_tti_cqi_15			# US5: cqi 4-15
# 	
# 	#UE11_get_tti_power_bad		# US6: port power 85 - 100
# 	#UE11_get_tti_power_good		# US7: port power 100 - 85
# 
#     #run keyword and continue on failure    UE11_get_bip_power_bad
# 	#Set UE11 power_good
# 	deactive p11
# 	Dettach UE from '11' to '11'	
# #us1
# UE11_get_tti_buffer_lo_hi
# 	Log To Console   ${\n}-----US1---buffer_lo_to_hi-----
# 	Start capture gnb and ap syslog in 'UE11_US1' file
# 	airphone_cleanup_egate_console_log
# 	NSA Attach UE from '11' to '11'
# 	Set UE11 P11
# 	Start collect ttitrace
# 	NSA send ue '11' mutiple trf '4' for each '150M' DL data
# 	Wait for '1s' to stop ttitrace with name'tti_buffer_lo_2_hi'
# 	get_egate_log_UE'11_buffer_lo2hi'
# 	Stop capture gnb and ap syslog in 'UE11_US1' file
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    20s    2s   check throughput from NSA UE '11' to '11' with tp '520'
# 	
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_buffer_lo_2_hi_dl.csv
# 	run keyword and continue on failure    check_SB_to_WB_tti   ${TEST_LOG_DIRECTORY()}/All/tti_buffer_lo_2_hi_dl_split.csv
# 	...    ${TEST_LOG_DIRECTORY()}/All/syslog_UE11_US1/UE11_US1_gnb.tar.gz   rdNumSrsCheck=5   rdSrsRlqGoodPercent=60   rdSrsBufPercent=60
# 		
# 	Wait '5s' for stabible
# #us2	
# UE11_get_tti_rank4_2
# 	Log To Console   ${\n}-----US2---rank4---2-----
# 	Start capture gnb and ap syslog in 'UE11_US2' file
# 	Start collect ttitrace
# 	airphone_cleanup_egate_console_log
# 	RANK'1'_CQI'15'_override_to_UE'11'
# 	Wait for '1s' to stop ttitrace with name'tti_UE11_rank42'
# 	get_egate_log_UE'11_rank42'
# 	Stop capture gnb and ap syslog in 'UE11_US2' file
# 	
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_UE11_rank42_dl.csv
# 	run keyword and continue on failure   check_tti_single_UE_bad_RLQ   ${TEST_LOG_DIRECTORY()}/All/tti_UE11_rank42_dl_split.csv   target=ri	
# 	...   gainCorrection=${gainCorrection}   rdNumSrsCheck=5   rdSrsRlqBadPercent=50   rdSrsBufPercent=60
# 
# 	run keyword and continue on failure   check_stable_DFT_patternid   ${TEST_LOG_DIRECTORY()}/All/tti_UE11_rank42_dl.csv   
# 	...   target_patternid_1=1397   target_patternid_2=1397
# 
# 	Wait '5s' for stabible
# 
# UE11_get_bip_rank4_2
# 	Start capture gnb and ap syslog in 'UE11_US2' file
# 	airphone_cleanup_egate_console_log
# 	Start collect bip log	
# 	RANK'1'_CQI'15'_override_to_UE'11'
# 	Wait for '2s' to stop bip log with name'BIP_11_rank42'
# 	
# 	get_egate_log_UE'11_rank42'
# 	
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_11_rank42/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_11_rank42/BIP_11_rank42_0.csv    ${filter_csv}    ${title_comb4}
# 
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_11_rank42/tcpdump_L2L1_bip_filtering_off.pcap1
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_11_rank42/BIP_11_rank42_1.csv    ${filter_csv}    ${title_comb4}
# 
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/ALL/BIP_11_rank42/tcpdump_L2L1_bip_filtering_off.pcap2
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_11_rank42/BIP_11_rank42_2.csv    ${filter_csv}    ${title_comb4}
# 
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_11_rank42/tcpdump_L2L1_bip_filtering_off.pcap3
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_11_rank42/BIP_11_rank42_3.csv    ${filter_csv}    ${title_comb4}
# 	Stop capture gnb and ap syslog in 'UE11_US2' file
# 	Wait '3s' for stabible
# #us3
# UE11_get_tti_rank2_4
# 	Log To Console   ${\n}-----US3----rank2----4------
# 	Start capture gnb and ap syslog in 'UE11_US3' file
# 	Start collect ttitrace
# 	airphone_cleanup_egate_console_log
# 	RANK'3'_CQI'15'_override_to_UE'11'	
# 	Wait for '2s' to stop ttitrace with name'tti_UE11_rank24'
# 	get_egate_log_UE'11_rank24'	
# 	Stop capture gnb and ap syslog in 'UE11_US3' file
# 	
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_UE11_rank24_dl.csv
# 	run keyword and continue on failure    check_SB_to_WB_tti   ${TEST_LOG_DIRECTORY()}/All/tti_UE11_rank24_dl_split.csv
# 	...    ${TEST_LOG_DIRECTORY()}/All/syslog_UE11_US3/UE11_US3_gnb.tar.gz   rdNumSrsCheck=5   rdSrsRlqGoodPercent=60   rdSrsBufPercent=60
# 	
# 	Wait '5s' for stabible
# 	
# #us4		
# UE11_get_tti_cqi_3
# 	Log To Console   ${\n}-----US4----cqi_3-----
# 	Start capture gnb and ap syslog in 'UE11_US4' file
# 	Start collect ttitrace
# 	airphone_cleanup_egate_console_log
# 	RANK'3'_CQI'3'_override_to_UE'11'
# 	Wait for '2s' to stop ttitrace with name'tti_UE11_cqi_3'
# 	get_egate_log_UE'11_cqi_3'
# 	Stop capture gnb and ap syslog in 'UE11_US4' file
# 	
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_UE11_cqi_3_dl.csv
# 	run keyword and continue on failure    check_tti_single_UE_bad_RLQ   ${TEST_LOG_DIRECTORY()}/All/tti_UE11_cqi_3_dl_split.csv   target=SE
# 	...   gainCorrection=${gainCorrection}	   rdNumSrsCheck=5   rdSrsRlqBadPercent=50   rdSrsBufPercent=60
# 
# 	run keyword and continue on failure   check_stable_DFT_patternid   ${TEST_LOG_DIRECTORY()}/All/tti_UE11_cqi_3_dl.csv   
# 	...   target_patternid_1=1397   target_patternid_2=1373
# 
# 	Wait '5s' for stabible
# #us5
# UE11_get_tti_cqi_15
# 	Log To Console   ${\n}-----US5----cqi 15----
# 	Start capture gnb and ap syslog in 'UE11_US5' file
# 	Start collect ttitrace
# 	airphone_cleanup_egate_console_log
# 	RANK'3'_CQI'15'_override_to_UE'11'
# 	Wait for '2s' to stop ttitrace with name'tti_UE11_cqi_15'
# 	get_egate_log_UE'11_cqi_15'
# 	Stop capture gnb and ap syslog in 'UE11_US5' file
# 	
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_UE11_cqi_15_dl.csv
# 	run keyword and continue on failure    check_SB_to_WB_tti   ${TEST_LOG_DIRECTORY()}/All/tti_UE11_cqi_15_dl_split.csv
# 	...    ${TEST_LOG_DIRECTORY()}/All/syslog_UE11_US5/UE11_US5_gnb.tar.gz   rdNumSrsCheck=5   rdSrsRlqGoodPercent=60   rdSrsBufPercent=60
# 	
# 	Wait '5s' for stabible
# 
# #us6
# UE11_get_tti_power_bad
# 	Log To Console   ${\n}-----US6----power--bad-----
# 	Start capture gnb and ap syslog in 'UE11_US6' file
# 	Start collect ttitrace
# 	airphone_cleanup_egate_console_log
# 	Set UE11 power_bad
# 	Wait for '2s' to stop ttitrace with name'tti_UE11_power_bad'
# 	get_egate_log_UE'11_power_bad'
# 	Stop capture gnb and ap syslog in 'UE11_US6' file
# 	
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_UE11_power_bad_dl.csv
# 	run keyword and continue on failure    check_tti_single_UE_bad_RLQ   ${TEST_LOG_DIRECTORY()}/All/tti_UE11_power_bad_dl_split.csv   target=power
# 	...   gainCorrection=${gainCorrection}   bad_power_thd_dbm=-95   rdNumSrsCheck=5   rdSrsRlqBadPercent=50   rdSrsBufPercent=60
# 
# 	run keyword and continue on failure   check_stable_DFT_patternid   ${TEST_LOG_DIRECTORY()}/All/tti_UE11_power_bad_dl.csv   
# 	...   target_patternid_1=1397   target_patternid_2=1373
# 	
# 	Wait '5s' for stabible
# 
# UE11_get_bip_power_bad
# # bad power thd=--100-5=-105
# 	Log To Console   ${\n}-----US8:--power bad BIP---
# 	Start capture gnb and ap syslog in 'UE11_power_bad_bip' file
# 	airphone_cleanup_egate_console_log
# 	Start collect bip log
# 	Wait '0.1s' for stabible
# 	Set UE11 power_bad
# 	Wait for '1s' to stop bip log with name'BIP_11_power_bad'
# 	
# 	get_egate_log_UE'11_power_bad'
# 	Stop capture gnb and ap syslog in 'UE11_power_bad_bip' file
# 	
# 	Set UE11 power_good
# 	
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_11_power_bad/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_11_power_bad/bip_11_power_bad_0.csv    ${filter_csv}    ${title_comb4}
# 
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_11_power_bad/tcpdump_L2L1_bip_filtering_off.pcap1
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_11_power_bad/bip_11_power_bad_1.csv    ${filter_csv}    ${title_comb4}
# 
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_11_power_bad/tcpdump_L2L1_bip_filtering_off.pcap2
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_11_power_bad/bip_11_power_bad_2.csv    ${filter_csv}    ${title_comb4}
# 
# 
# 	#run keyword and continue on failure   check_power_bad_bip     ${TEST_LOG_DIRECTORY()}/All/BIP_11_power_bad/bip_11_power_bad_1.csv   
#    ...    WB_SRS_period=80
# 	#run keyword and continue on failure   check_power_bad_bip     ${TEST_LOG_DIRECTORY()}/All/BIP_11_power_bad/bip_11_power_bad_2.csv   
#    ...    WB_SRS_period=80
# 	Wait '3s' for stabible
# #us7
# UE11_get_tti_power_good
# 	Log To Console   ${\n}-----US7----power--good-----
# 	Start capture gnb and ap syslog in 'UE11_US7' file
# 	Start collect ttitrace
# 	airphone_cleanup_egate_console_log
# 	Set UE11 power_good
# 	Wait for '2s' to stop ttitrace with name'tti_UE11_power_good'
# 	get_egate_log_UE'11_power_good'
# 	Stop capture gnb and ap syslog in 'UE11_US7' file
# 	
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_UE11_power_good_dl.csv
# 	run keyword and continue on failure    check_SB_to_WB_tti   ${TEST_LOG_DIRECTORY()}/All/tti_UE11_power_good_dl_split.csv
# 	...    ${TEST_LOG_DIRECTORY()}/All/syslog_UE11_US7/UE11_US7_gnb.tar.gz   rdNumSrsCheck=5   rdSrsRlqGoodPercent=60   rdSrsBufPercent=60
# 	
# 	Wait '5s' for stabible
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
# test_SA_UE1_t1r4
# 	Start capture gnb and ap syslog in 'UE1' file
# 	airphone_cleanup_egate_console_log
# 	SA Register UE '1'
# 	#Set UE1 position
# 	DL and UL data to '1' for dl_trf '10'
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    30s    2s   check throughput from SA UE '1' to '1' with tp '1280'
# 	get_bip_UE'1'
# 	get_tti_UE'1'
# 	DeRegister UE from '1' to '1'
# 	#delete profile_1
# 	
# 	get_egate_log_UE'1'
# 	Stop capture gnb and ap syslog in 'UE1' file
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
# 	#Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap1
# 	#...    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/${bip_tag}_1.csv    ${filter_csv}    ${title_comb4}
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
#     Wait '2s' for stabible
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
