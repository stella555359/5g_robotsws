# *** Settings ***
# Test Timeout    120 minutes
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# #Force Tags    owner_zhang   CLOUD_5G_I_MP_AP_LOOO
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_AEQEx2_AQQL_AEHC_handover_case02_MP.xml
# ${AIRPHONE_NAME}    iphy_AEQEx2_AQQL_AEHC_8X4_MP.xml
# ${WTS_NAME}    wts_config_A2a_case01.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog
# ${UE_ID}     1
# ${UE_NUM_SA}    2
# ${UE_ID2}     2
# 
# ${EGATE_TAG}    egate
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
# ${filter_csv}   uldata_srsreceivereq || uldata_srsreceiverespbwvps || dldata_pdschsendreq || dldata_csirssendreq
# 
# @{tiltle_srsreceivereq}	3gpp.sfn   3gpp.slot   3gpp.rnti   UlData_srsReceiveReqSubcell_t.srsBwvEnable   
# 	...    UlData_srsReceiveReqSubcell_t.srsBmEnable   
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
# ...   UlData_srsBwvStruct_t.srsBwvReportRequests.Length   UlData_srsReceiveReqSubcell_t.srsBwvEnable   UlData_srsReceiveReqSubcell_t.srsBmEnable   
# ...   UlData_srsBwvReportRequest_t.bwvReportId
# ...   UlData_srsBwvReportRequest_t.numBwvPerSubband   UlData_srsBwvReportRequest_t.symbolPosition   UlData_srsBwvReportRequest_t.operation
# ...   UlData_srsBwvReportRequest_t.sinr   UlData_srsBwvReportRequest_t.rho   UlData_srsBwvReportRequest_t.numSrsPorts   
# ...   UlData_srsBwvReportRequest_t.bfSubbandId_item
# ...   UlData_srsBwvReportRequest_t.srsResourceIdentity   UlData_srsBwvReportRequest_t.startPatternId
# ...   UlData_srsCyclicShifts_t.transmissionCombId    UlData_srsCyclicShifts_t.cyclicShift   UlData_srsCyclicShifts_t.portIndex
# ...   UlData_srsBmStruct_t.srsBmResource.Length
# ...   UlData_srsBmResource_t.srsBmSubbandId   UlData_srsBmResource_t.transmissionCombId   UlData_srsBmResource_t.bmCyclicShift
# ...   UlData_srsBmResource_t.srsResourceIdentity
# ...   UlData_srsBwvReport_t.result  UlData_srsBwvReport_t.numBwvPerSubband    
# ...   UlData_srsReceiveRespBwvPsSubcell_t.fhTransDelay   UlData_srsBwvReport_t.bwvReportId   UlData_srsBwvReport_t.portPower_item 
# ...   UlData_srsBwvReport_t.startPatternId   DlData_PdschGrant.pdschScramblingSeqInit   DlData_PdschGrant.patternId_item
# ...   DlData_PdschGrant.numOfLayers   DlData_PdschGrant.numOfPrb
# ...   DlData_PdschGrant.antPort   DlData_PdschGrant.numStreamIndex   DlData_PdschGrant.streamIndex_item   DlData_PdschGrant.mcs
# ...   DlData_PdschGrant.modulationOrder   DlData_PdschGrant.polarizationSelection   DlData_PdschGrant.closedLoop3gppCodebook 
# ...   DlData_PdschGrant.openLoopScheme   DlData_PdschGrant.bestBeamPowerOffset    DlData_PdschGrant.pdschTbTransmitPower
# ...   DlData_CsiRsResource_t.patternId_item   DlData_CsiRsResource_t.density   
# ...   DlData_CsiRsResource_t.csiRsConfig    DlData_CsiRsResource_t.numCeAxCIndex   DlData_CsiRsResource_t.ceAxCIndex_item   
# ...   DlData_CsiRsResource_t.csiBestBeamPowerOffset
# 
# 
# @{title_short}   3gpp.sfn   3gpp.slot   3gpp.rnti   
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
# CB011117_A2a_case002_RT_beam_UE_trigger_intra_Freq_handover_after_measure_gap_trigger_with_target_cell_PRBlanking
#    Step1:add RD and Gnb prepare onair
#    Step2:attach UE send traffic and check logs
#    Step3:Trigger UE1 HO from cell1 to cell2
#    Step4:Trigger UE2 HO from cell2 to cell3
# #   Step5:Trigger UE1 HO from cell2 to cell3
# #   Step6：Trigger UE1 switch to RT
#    Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# *** Keywords ***
# ADD RD
# #	Add GNB swconfig	0x59026B:1		# rdActHoWithSbBf
# 	Add GNB swconfig	0x59026C:1		# rdEnable6CsForComb4
# 	Add GNB swconfig	0x59026A:1       #rdActNoAddDlDmrsSwitch
# 
# Step1:add RD and Gnb prepare onair
#     Log To Console    -----Step1:add RD and Gnb prepare onair-----
#     ADD RD
# 	Wts Execute Aashell Command
# 	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
# 
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Get and Update BSR File		par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
# 	Get and Update BSR File		par_of_bsr_name=BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
# 
# 	Prepare gnb onair
# #	online act CB08322 debug flag
#     Wait '120s' for stabible
#     Start capture gnb and ap syslog in 'after_onair' file
# 
# 
# Step2:attach UE send traffic and check logs
#     Log To Console    -----Step2:attach UE send traffic and check logs-------
#     airphone_cleanup_egate_console_log
#     Change UE'${UE_ID2}' to cell'2'
#     Attach '${UE_NUM_SA}' SA UE
# 
# #    SA send data UE'${UE_ID2}'
#     Get UE '${UE_ID}' rnti from rrc log
# 
#     SA send data '${UE_NUM_SA}' UEs
#     Wait '5s' for stabible
#     Start collect ttitrace
#     Set test Variable    ${tti_tag}   tti_traffic
#     Wait for '2s' to stop ttitrace with name'${tti_tag}'
# 
#     run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/tti_A2a_case01_RT.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# 	get_bip_'bip_traffic'
# 
# 	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
# 
#     get_egate_log_UE'ue_traffic'
# 
# Step3:Trigger UE1 HO from cell1 to cell2
#     Log To Console    -----Step3:Trigger UE1 HO from cell1 to cell2-----
#     airphone_cleanup_egate_console_log
#     Start collect ttitrace
# 
#     Start collect bip log
# 	Airphone Execute Egate Command
# 	...    ue_measurement_send_nr id\=1 meas_id\=2 event\=A3 srsrp_nr\=11 phycell_id\=51 nrsrp_nr\=80
# 	...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
# 
# #    Wait for '0s' to stop bip log with name'BIP_${ue_id}'
# 	Set test Variable    ${tti_tag}   tti_ho_cell1_2
# #	Wait for '0s' to stop ttitrace with name'${tti_tag}'
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/All
#     Wait '3s' for stabible
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# #    Wait for '0s' to stop bip log with name'BIP_${ue_id}'
# 
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/${tti_tag}
# 
#     Set test variable    ${egate_dir}    egate_ho_cell1_2
# 	Collect AP egate log    ${egate_dir}
# 	Get UE rnti from rrc log'${egate_dir}'
# 
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/tti_A2a_case03_ho_cell1_2.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# 	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
# 
# 
# Step4:Trigger UE2 HO from cell2 to cell3
#     Log To Console    -----Step4:Trigger UE1 HO from cell2 to cell3-----
#     airphone_cleanup_egate_console_log
#     Start collect ttitrace
# 	Airphone Execute Egate Command
# 	...    ue_measurement_send_nr id\=2 meas_id\=1 event\=A3 srsrp_nr\=11 phycell_id\=52 nrsrp_nr\=80
# 
# 	Set test Variable    ${tti_tag}   tti_ho_cell2_3
# 	Wait for '2s' to stop ttitrace with name'${tti_tag}'
# 
# 	Set test variable    ${egate_dir}    egate_ho_cell2_3
# 	Collect AP egate log    ${egate_dir}
# 	run keyword and continue on failure   Get UE rnti from rrc log'${egate_dir}'
# 
# 	run keyword and continue on failure     check_log_with_au2anlysis
# 	...    ini_path=${CURDIR}/ini/tti_A2a_case03_ho_cell2_3.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# 	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
# 
# Step6：Trigger UE1 HO from cell3 to cell4
#     Log To Console    -----Step6：Trigger UE1 switch to RT-----
#     Log To Console   Trigger UE1 switch to RT
# 
# Get UE rnti from rrc log'${egate_dir}'
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/${egate_dir}    unzip=TRUE
#     ${ret}     file match all       ${TEST_LOG_DIRECTORY()}/All/${egate_dir}/egate_console.log    .*crnti: (\\d+)
#     set suite variable     ${ue_rnti}    ${ret[0]}
# 
# Get UE '${num}' rnti from rrc log
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}    unzip=TRUE
#     ${ret}     file match all       ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}/egate_console.log    .*crnti: (\\d+)
#     set suite variable     ${ue${num}_rnti}    ${ret[0]}
# 
# Attach '${UE_NUM_SA}' SA UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
# #    \   airphone_cleanup_egate_console_log
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
#     \   Wait '2s' for stabible
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \   Wait '2s' for stabible
# #    \   Collect AP egate log    ${EGATE_TAG}_${num}
#     \   Wait '3s' for stabible
# 
# 
# Detach '${UE_NUM_SA}' SA UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    airphone_sa_detach    ue_id=${num}    timeout=30
# 
# 
# SA send data '${UE_NUM_SA}' UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    SA send mutiple trf dl data    ${num}    5   175M   ${num}    tcp
#     \    SA send mutiple trf ul data    ${num}    1    10M   ${num}
# 
# SA send data UE'${UE_ID}'
#     SA send mutiple trf dl data    ${UE_ID}    5   175M   ${UE_ID}    tcp
#     SA send mutiple trf ul data    ${UE_ID}    1    10M   ${UE_ID}
# 
# 
# test_11117_interFreq_HO_and_back
# 	Start capture gnb and ap syslog in 'sys_HO' file
# 	airphone_cleanup_egate_console_log
# 	Change UE'1' to cell'1'
# 	SA Register UE from '1' to '1'
# 	DL and UL data to '1' for dl_trf '5'
# 	run keyword and continue on failure   Wait Until Keyword Succeeds    60s    2s  check throughput from SA UE '1' to '1' with tp '700'
# 
#     get_bip_'UE1'
# 
# 	A2_into_GAP_cell_1_CRITERION1_RT
# 	GAP_rank41_WB_to_SB
# 	GAP_rank14_SB_can_NOT_switch_to_WB
# 	
# 	interFreqHO_cell_2
# 
# 	A2_into_GAP_cell_2_CRITERION2_fallback_DFT
# 	interFreqHO_back_cell_1
# 
# 	get_egate_log_UE'1'
# 	DeRegister UE from '1' to '1'
# 	#RANK'3'_CQI'15'_override_to_UE'1'
# 	run keyword and continue on failure   Stop capture gnb and ap syslog in 'sys_HO' file
# 
# A2_into_GAP_cell_1_CRITERION1_RT
# 	Log To Console   ${\n}--A2---
# 	Start collect ttitrace
# 	Wait '1s' for stabible
# 	Airphone Execute Egate Command
# 	...   ue_measurement_send_nr id\=1 meas_id\=1 event\=A2 srsrp_nr\=11
# 	
# 	Set test Variable    ${tti_tag}   tti_cell1_GAP_CRITERION1	
# 	Wait for '2s' to stop ttitrace with name'${tti_tag}'
# 	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
# 	
# 	Set test Variable    ${tti_title_tag}		${tti_tag}_dl_split.csv
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_dl_GAP_cell_1_CRITERION1_RT.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# 	run keyword and continue on failure   Wait Until Keyword Succeeds    60s    2s  check throughput from SA UE '1' to '1' with tp '700'
# 	
# GAP_rank41_WB_to_SB
# 	Log To Console   ${\n}--GAP_rank41_WB_to_SB---
# 	Set test Variable    ${tti_tag}   GAP_rank41_WB_to_SB
# 	Start collect ttitrace
# 	RANK'0'_CQI'15'_override_to_UE'1'
# 	Wait for '2s' to stop ttitrace with name'${tti_tag}'
# 	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
# 	
# 	Set test Variable    ${tti_title_tag}		${tti_tag}_dl_split.csv
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_dl_GAP_rank41_WB_to_SB.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# GAP_rank14_SB_can_NOT_switch_to_WB
# 	Log To Console   ${\n}--GAP_rank14_SB_can_NOT_switch_to_WB---
# 	Set test Variable    ${tti_tag}   GAP_rank14_SB_can_NOT_switch_to_WB
# 	Start collect ttitrace
# 	RANK'3'_CQI'15'_override_to_UE'1'
# 	Wait for '2s' to stop ttitrace with name'${tti_tag}'
# 	## run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
# 	
# 	Set test Variable    ${tti_title_tag}		${tti_tag}_dl.csv
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_dl_GAP_rank14_SBSRS_DFT_cannot_switch_WBSRS_RT.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# interFreqHO_cell_2
# 	Log To Console   ${\n}--inter Freq HO to cell 51---
# 	#Start collect ttitrace
# 	#Wait '1s' for stabible
# 	
# 	run keyword and continue on failure   Airphone Execute Egate Command
# 	...   ue_measurement_send_nr id\=1 meas_id\=4 event\=A3 srsrp_nr\=11 phycell_id\=51 nrsrp_nr\=80
# 	...   pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
# 	
# 	#Wait for '2s' to stop ttitrace with name'tti_HO'
# 	#run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_HO_dl.csv
# 
# 	run keyword and continue on failure   Wait Until Keyword Succeeds    60s    2s  check throughput from SA UE '1' to '1' with tp '700'
# 	
# A2_into_GAP_cell_2_CRITERION2_fallback_DFT
# 	Log To Console   ${\n}--A2 back---
# 	Start collect ttitrace
# 	Wait '1s' for stabible
# 	
# 	Airphone Execute Egate Command
# 	...   ue_measurement_send_nr id\=1 meas_id\=5 event\=A2 srsrp_nr\=11
# 	
# 	Set test Variable    ${tti_tag}   tti_cell2_GAP_CRITERION2
# 	Wait for '2s' to stop ttitrace with name'${tti_tag}'
# 	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
# 	get_bip_'UE1_CRITERION2'
# 
# 	Set test Variable    ${tti_title_tag}		${tti_tag}_dl_split.csv
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_dl_GAP_cell_2_CRITERION2_fall_back_DFT.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# 	run keyword and continue on failure   Wait Until Keyword Succeeds    60s    2s  check throughput from SA UE '1' to '1' with tp '700'
# 
# interFreqHO_back_cell_1
# 	Log To Console   ${\n}--inter Freq HO back to cell 50---
# 	run keyword and continue on failure   Airphone Execute Egate Command
# 	...   ue_measurement_send_nr id\=1 meas_id\=8 event\=A3 srsrp_nr\=30 phycell_id\=50 nrsrp_nr\=80
# 	...   pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
# 	
# 	Wait '1s' for stabible
# 	run keyword and continue on failure   Wait Until Keyword Succeeds    60s    2s  check throughput from SA UE '1' to '1' with tp '700'
# 
# test_GAP_SRS_no_overlap
# 	online change gapoffset '0' cell'1'
# 	airphone_cleanup_egate_console_log
# 	Change UE'1' to cell'1'
# 	SA Register UE from '1' to '1'
# 	DL and UL data to '1' for dl_trf '5'
# 	run keyword and continue on failure   Wait Until Keyword Succeeds    60s    2s  check throughput from SA UE '1' to '1' with tp '700'
# 	A2_into_GAP_cell_1_NONE_overlap
# 	DeRegister UE from '1' to '1'
# 	get_egate_log_UE'NONE'
# 	
# A2_into_GAP_cell_1_NONE_overlap
# 	Log To Console   ${\n}--A2---
# 	Set test Variable    ${tti_tag}   tti_cell1_GAP_NONE_overlap
# 	Start collect ttitrace
# 	Wait '1s' for stabible
# 	Airphone Execute Egate Command
# 	...   ue_measurement_send_nr id\=1 meas_id\=1 event\=A2 srsrp_nr\=11
# 		
# 	Wait for '1s' to stop ttitrace with name'${tti_tag}'
# 	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
# 	
# 	Set test Variable    ${tti_title_tag}		${tti_tag}_dl_split.csv
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_dl_GAP_cell_1_NONE_RT.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# 	run keyword and continue on failure   Wait Until Keyword Succeeds    20s    2s  check throughput from SA UE '1' to '1' with tp '750'
# 		
# get_tti_'${tti_tag}'
# 	Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'tti_${tti_tag}'
# 	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_${tti_tag}_dl.csv
# 
# get_bip_'${BIP_tag}'
# 	Start collect bip log
# 	Wait for '1s' to stop bip log with name'${BIP_tag}'
# 
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv    ${filter_csv}    ${title_all}
# 
# Change UE'${ue_id}' to cell'${cell_id}'
#     airphone_execute_egate_command      ue_change_location cell\=${cell_id} id\=${ue_id}
# 
# #===========================SA======t2r4===================
# test_SA_UE5_t2r4
# 	UE5_get_tti_buffer_lo_hi
# 
# 	UE5_get_tti_rank4_1			# US2: rank 4-1
# 	UE5_get_tti_rank1_4			# US3: rank 2-4
# 
# 	UE5_get_tti_cqi_3			# US4: cqi 15-4
# 	UE5_get_tti_cqi_15			# US5: cqi 4-15
# 	
# 	UE5_get_tti_power_bad		# US6: port power 85 - 100
# 	UE5_get_tti_power_good		# US7: port power 100 - 85
# 	
# 	#run keyword and continue on failure    Wait Until Keyword Succeeds    300s    60s   UE5_get_bip_power_bad
# 		
# 	deactive p5
# 	Run Keyword And Ignore Error   DeRegister UE from '5' to '5'
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
# 	run keyword and continue on failure    check_SB_to_WB_tti   ${TEST_LOG_DIRECTORY()}/All/tti_UE5_buffer_lo_2_hi_dl_split.csv
# 	...    ${TEST_LOG_DIRECTORY()}/All/syslog_UE5_US1/UE5_US1_gnb.tar.gz   rdNumSrsCheck=10   rdSrsRlqGoodPercent=60   rdSrsBufPercent=60
# 		
# 	Wait '5s' for stabible
# #us2	
# UE5_get_tti_rank4_1
# 	Log To Console   ${\n}--t2r4---US2---rank4---1-----
# 	Start capture gnb and ap syslog in 'UE5_US2' file
# 	Start collect ttitrace
# 	airphone_cleanup_egate_console_log
# 	RANK'0'_CQI'15'_override_to_UE'5'
# 	Wait for '1s' to stop ttitrace with name'tti_UE5_rank41'
# 	get_egate_log_UE'5_rank41'
# 	Stop capture gnb and ap syslog in 'UE5_US2' file
# 	
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_UE5_rank41_dl.csv
# 	run keyword and continue on failure    check_tti_single_UE_bad_RLQ   ${TEST_LOG_DIRECTORY()}/All/tti_UE5_rank41_dl_split.csv   target=ri
# 	...   gainCorrection=${gainCorrection}   rdNumSrsCheck=10   bad_Rank_thd=1	rdSrsRlqBadPercent=50   rdSrsBufPercent=60
# 
# 	
# 	run keyword and continue on failure   check_stable_DFT_patternid   ${TEST_LOG_DIRECTORY()}/All/tti_UE5_rank41_dl.csv
# 	...   target_patternid_1=1397   target_patternid_2=1397
# 
# 	Wait '5s' for stabible
# 
# #us3
# UE5_get_tti_rank1_4
# 	Log To Console   ${\n}--t2r4---US3----rank1----4------
# 	Start capture gnb and ap syslog in 'UE5_US3' file
# 	Start collect ttitrace
# 	airphone_cleanup_egate_console_log
# 	RANK'3'_CQI'15'_override_to_UE'5'
# 	Wait for '2s' to stop ttitrace with name'tti_UE5_rank14'
# 	get_egate_log_UE'5_rank14'
# 	Stop capture gnb and ap syslog in 'UE5_US3' file
# 	
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_UE5_rank14_dl.csv
# 	run keyword and continue on failure    check_SB_to_WB_tti   ${TEST_LOG_DIRECTORY()}/All/tti_UE5_rank14_dl_split.csv
# 	...    ${TEST_LOG_DIRECTORY()}/All/syslog_UE5_US3/UE5_US3_gnb.tar.gz   rdNumSrsCheck=10   rdSrsRlqGoodPercent=60   rdSrsBufPercent=60
# 	
# 	Wait '5s' for stabible
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
# 	...   gainCorrection=${gainCorrection}   rdNumSrsCheck=10   bad_SE_thd=410   rdSrsRlqBadPercent=50   rdSrsBufPercent=60
# 
# 	run keyword and continue on failure   check_stable_DFT_patternid   ${TEST_LOG_DIRECTORY()}/All/tti_UE5_cqi_3_dl.csv
# 	...   target_patternid_1=1397   target_patternid_2=1377
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
# 	...    ${TEST_LOG_DIRECTORY()}/All/syslog_UE5_US5/UE5_US5_gnb.tar.gz   rdNumSrsCheck=10   rdSrsRlqGoodPercent=60   rdSrsBufPercent=60
# 	
# 	Wait '5s' for stabible
# 
# #us6
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
# 	...   gainCorrection=${gainCorrection}   bad_power_thd_dbm=-95   rdNumSrsCheck=10   rdSrsRlqBadPercent=50   rdSrsBufPercent=60
# 	
# 	##run keyword and continue on failure   check_stable_DFT_patternid   ${TEST_LOG_DIRECTORY()}/All/tti_UE5_power_bad_dl.csv
# 	##...   target_patternid_1=1397   target_patternid_2=1377
# 
# 	Wait '5s' for stabible
# 
# UE5_get_bip_power_bad
# # bad power thd=--100-5=-105
# 	Log To Console   ${\n}--t2r4---US8:--power bad BIP---
# 	Start capture gnb and ap syslog in 'UE5_power_bad_bip' file
# 	airphone_cleanup_egate_console_log
# 	Start collect bip log
# 	Wait '0.1s' for stabible
# 	Set UE5 power_bad
# 	Wait for '1s' to stop bip log with name'BIP_5_power_bad'
# 	
# 	get_egate_log_UE'5_power_bad'
# 	Stop capture gnb and ap syslog in 'UE5_power_bad_bip' file
# 	
# 	Set UE5 power_good
# 	
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_5_power_bad/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_5_power_bad/bip_5_power_bad_0.csv    ${filter_csv}    ${title_short}
# 
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_5_power_bad/tcpdump_L2L1_bip_filtering_off.pcap1
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_5_power_bad/bip_5_power_bad_1.csv    ${filter_csv}    ${title_short}
# 
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_5_power_bad/tcpdump_L2L1_bip_filtering_off.pcap2
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_5_power_bad/bip_5_power_bad_2.csv    ${filter_csv}    ${title_short}
# 
# 	run keyword and continue on failure   check_power_bad_bip     ${TEST_LOG_DIRECTORY()}/All/BIP_5_power_bad/bip_5_power_bad_0.csv   
#    ...    WB_SRS_period=80
# 	#run keyword and continue on failure   check_power_bad_bip     ${TEST_LOG_DIRECTORY()}/All/BIP_11_power_bad/bip_11_power_bad_1.csv   
#    ...    WB_SRS_period=80
# 	#run keyword and continue on failure   check_power_bad_bip     ${TEST_LOG_DIRECTORY()}/All/BIP_11_power_bad/bip_11_power_bad_2.csv   
#    ...    WB_SRS_period=80
# 	Wait '3s' for stabible
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
# 	...    ${TEST_LOG_DIRECTORY()}/All/syslog_UE5_US7/UE5_US7_gnb.tar.gz   rdNumSrsCheck=10   rdSrsRlqGoodPercent=60   rdSrsBufPercent=60
# 	
# 	Wait '5s' for stabible
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
# #==============NSA=====t1r4======================================
# test_NSA_UE11_t1r4
# 	UE11_get_tti_buffer_lo_hi
# 	
# 	## UE11_get_tti_rank4_1		# US2: rank 4-2
# 	RANK'0'_CQI'15'_override_to_UE'11'
# 	Wait '3s' for stabible
# 
# 	UE11_get_tti_rank1_4		# US3: rank 2-4
# 	
# 	## UE11_get_tti_cqi_3			# US4: cqi 15-4
# 	RANK'3'_CQI'3'_override_to_UE'11'
# 	Wait '3s' for stabible
# 
# 	UE11_get_tti_cqi_15			# US5: cqi 4-15
# 	
# 	## UE11_get_tti_power_bad		# US6: port power 85 - 100
# 	Set UE11 power_bad
# 	Wait '3s' for stabible
# 	
# 	UE11_get_tti_power_good		# US7: port power 100 - 85
# 
# 	deactive p11
# 	Run Keyword And Ignore Error   Dettach UE from '11' to '11'	
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
# 	...    ${TEST_LOG_DIRECTORY()}/All/syslog_UE11_US1/UE11_US1_gnb.tar.gz   rdNumSrsCheck=10   rdSrsRlqGoodPercent=60   rdSrsBufPercent=60
# 		
# 	Wait '5s' for stabible
# #us2	
# UE11_get_tti_rank4_1
# 	Log To Console   ${\n}-----US2---rank4---1-----
# 	Start capture gnb and ap syslog in 'UE11_US2' file
# 	Start collect ttitrace
# 	Wait '0.1s' for stabible
# 	airphone_cleanup_egate_console_log
# 	RANK'0'_CQI'15'_override_to_UE'11'
# 	Wait for '1s' to stop ttitrace with name'tti_UE11_rank41'
# 	get_egate_log_UE'11_rank41'
# 	Stop capture gnb and ap syslog in 'UE11_US2' file
# 	
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_UE11_rank41_dl.csv
# 	run keyword and continue on failure   check_tti_single_UE_bad_RLQ   ${TEST_LOG_DIRECTORY()}/All/tti_UE11_rank41_dl_split.csv   target=ri	
# 	...   gainCorrection=${gainCorrection}   rdNumSrsCheck=10   bad_Rank_thd=1	rdSrsRlqBadPercent=50   rdSrsBufPercent=60
# 
# 	##run keyword and continue on failure   check_stable_DFT_patternid   ${TEST_LOG_DIRECTORY()}/All/tti_UE11_rank41_dl.csv   
# 	##...   target_patternid_1=1397   target_patternid_2=1397
# 
# 	Wait '5s' for stabible
# 
# UE11_get_bip_rank4_1
# 	Start capture gnb and ap syslog in 'UE11_US2' file
# 	airphone_cleanup_egate_console_log
# 	Start collect bip log	
# 	RANK'1'_CQI'15'_override_to_UE'11'
# 	Wait for '2s' to stop bip log with name'BIP_11_rank41'
# 	
# 	get_egate_log_UE'11_rank41'
# 	
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_11_rank41/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_11_rank41/BIP_11_rank41_0.csv    ${filter_csv}    ${title_short}
# 
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_11_rank41/tcpdump_L2L1_bip_filtering_off.pcap1
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_11_rank41/BIP_11_rank41_1.csv    ${filter_csv}    ${title_short}
# 
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/ALL/BIP_11_rank41/tcpdump_L2L1_bip_filtering_off.pcap2
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_11_rank41/BIP_11_rank41_2.csv    ${filter_csv}    ${title_short}
# 
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_11_rank41/tcpdump_L2L1_bip_filtering_off.pcap3
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_11_rank41/BIP_11_rank41_3.csv    ${filter_csv}    ${title_short}
# 	Stop capture gnb and ap syslog in 'UE11_US2' file
# 	Wait '3s' for stabible
# #us3
# UE11_get_tti_rank1_4
# 	Log To Console   ${\n}-----US3----rank1----4------
# 	Start capture gnb and ap syslog in 'UE11_US3' file
# 	Start collect ttitrace
# 	airphone_cleanup_egate_console_log
# 	RANK'3'_CQI'15'_override_to_UE'11'	
# 	Wait for '2s' to stop ttitrace with name'tti_UE11_rank14'
# 	get_egate_log_UE'11_rank14'	
# 	Stop capture gnb and ap syslog in 'UE11_US3' file
# 	
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_UE11_rank14_dl.csv
# 	run keyword and continue on failure    check_SB_to_WB_tti   ${TEST_LOG_DIRECTORY()}/All/tti_UE11_rank14_dl_split.csv
# 	...    ${TEST_LOG_DIRECTORY()}/All/syslog_UE11_US3/UE11_US3_gnb.tar.gz   rdNumSrsCheck=10   rdSrsRlqGoodPercent=60   rdSrsBufPercent=60
# 	
# 	Wait '5s' for stabible
# 	
# #us4		
# UE11_get_tti_cqi_3
# 	Log To Console   ${\n}-----US4----cqi_3-----
# 	Start capture gnb and ap syslog in 'UE11_US4' file
# 	Start collect ttitrace
# 	Wait '0.1s' for stabible
# 	airphone_cleanup_egate_console_log
# 	RANK'3'_CQI'3'_override_to_UE'11'
# 	Wait for '2s' to stop ttitrace with name'tti_UE11_cqi_3'
# 	get_egate_log_UE'11_cqi_3'
# 	Stop capture gnb and ap syslog in 'UE11_US4' file
# 	
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_UE11_cqi_3_dl.csv
# 	run keyword and continue on failure    check_tti_single_UE_bad_RLQ   ${TEST_LOG_DIRECTORY()}/All/tti_UE11_cqi_3_dl_split.csv   target=SE
# 	...   gainCorrection=${gainCorrection}	   rdNumSrsCheck=10   bad_SE_thd=410	rdSrsRlqBadPercent=50   rdSrsBufPercent=60
# 
# 	##run keyword and continue on failure   check_stable_DFT_patternid   ${TEST_LOG_DIRECTORY()}/All/tti_UE11_cqi_3_dl.csv   
# 	##...   target_patternid_1=1397   target_patternid_2=1373
# 
# 	#Wait '5s' for stabible
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
# 	...    ${TEST_LOG_DIRECTORY()}/All/syslog_UE11_US5/UE11_US5_gnb.tar.gz   rdNumSrsCheck=10   rdSrsRlqGoodPercent=60   rdSrsBufPercent=60
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
# 	...   gainCorrection=${gainCorrection}   bad_power_thd_dbm=-106   rdNumSrsCheck=10   rdSrsRlqBadPercent=50   rdSrsBufPercent=60
# 
# 	##run keyword and continue on failure   check_stable_DFT_patternid   ${TEST_LOG_DIRECTORY()}/All/tti_UE11_power_bad_dl.csv   
# 	##...   target_patternid_1=1397   target_patternid_2=1373
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
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_11_power_bad/bip_11_power_bad_0.csv    ${filter_csv}    ${title_short}
# 
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_11_power_bad/tcpdump_L2L1_bip_filtering_off.pcap1
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_11_power_bad/bip_11_power_bad_1.csv    ${filter_csv}    ${title_short}
# 
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_11_power_bad/tcpdump_L2L1_bip_filtering_off.pcap2
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_11_power_bad/bip_11_power_bad_2.csv    ${filter_csv}    ${title_short}
# 
# 	run keyword and continue on failure   check_power_bad_bip     ${TEST_LOG_DIRECTORY()}/All/BIP_11_power_bad/bip_11_power_bad_0.csv   
# 	...    WB_SRS_period=80
# 	#run keyword and continue on failure   check_power_bad_bip     ${TEST_LOG_DIRECTORY()}/All/BIP_11_power_bad/bip_11_power_bad_1.csv   
# 	...    WB_SRS_period=80
# 	#run keyword and continue on failure   check_power_bad_bip     ${TEST_LOG_DIRECTORY()}/All/BIP_11_power_bad/bip_11_power_bad_2.csv   
# 	...    WB_SRS_period=80
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
# 	...    ${TEST_LOG_DIRECTORY()}/All/syslog_UE11_US7/UE11_US7_gnb.tar.gz   rdNumSrsCheck=10   rdSrsRlqGoodPercent=60   rdSrsBufPercent=60
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
# get_bip_UE'${ue_id}'
# 	Start collect bip log
# 	Wait for '1s' to stop bip log with name'BIP_${ue_id}'
# 	
# 	Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_${ue_id}/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_${ue_id}/bip_8322.csv    ${filter_csv}    ${title_short}
#     
# get_tti_UE'${ue_id}'
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_${ue_id}'
# 	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_${ue_id}_dl.csv
# #==========SA=======================
# SA Register UE '${UE_ID}'
# 	Log To Console   ${\n}-----register UE ${UE_ID} ------
# 	Airphone SA Attach    ue_id=${UE_ID}
# 	Wait '2s' for stabible
# 	${gw_pdu_r}    evaluate    ${UE_ID}%10+1
# 	Airphone Set Traffic Type    ${UE_ID}    ${gw_pdu_r}    internal
# 	Airphone Pdu Session Setup   ${UE_ID}    ${gw_pdu_r}    1    ${gw_pdu_r}
# 	Wait '2s' for stabible
# 
# SA Register UE from '${lo}' to '${hi}'
# 	: FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
# 	 \	SA Register UE '${ue}'
# 
# DL and UL data to '${UE_ID}' for dl_trf '${num}'
#     ${gw_pdu_r}    evaluate    ${UE_ID}%10+1
#     : FOR    ${i}    IN RANGE    1    ${num}+1
#     \	Airphone SA Start Data Traffic    ${UE_ID}   DL   165M   pdu_id=${gw_pdu_r}   duration=3600   trf_id=${i}     
#     Airphone SA Start Data Traffic    ${UE_ID}   UL   1M    pdu_id=${gw_pdu_r}   duration=3600   trf_id=1
#     Wait '5s' for stabible
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
# 
# online change gapoffset '${gapoffset}' cell'${cell_id}'
#     Log To Console    ${\n}=======online_change_gapOffset_${gapoffset} cell${cell_id}========
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-2/NRCELL-${cell_id}   parameter=gapOffset
#     ...    operation=update    value=${gapoffset}    skip_parameter_relation_errors=True    should_activate=True    connection=online
# 
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '10s' for stabible
# 	
# 	# gapOffset from 31 to 0
