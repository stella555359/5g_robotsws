*** Settings ***
Documentation    CB011117 case
Test Timeout    120 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags      CLOUD_5G_I_MP_AP_LOOO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCFC_AEQEx2_AQQL_AEHC_intraHO_MP.xml
${AIRPHONE_NAME}    iphy_AEQEx2_AQQL_AEHC_8X4_MP.xml
${WTS_NAME}    wts_config_A2a_case01.cfg

@{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog
${UE_ID}     1
${UE_NUM_SA}    2
${UE_ID2}     2
${UE_ID_NSA}     21

${EGATE_TAG}    egate

${filter_csv}   uldata_srsreceivereq || uldata_srsreceiverespbwvps || dldata_pdschsendreq || dldata_csirssendreq

@{title_all}   3gpp.sfn   3gpp.slot   3gpp.rnti   3gpp.subcellid
...   UlData_srsBwvStruct_t.srsBwvReportRequests.Length   UlData_srsReceiveReqSubcell_t.srsBwvEnable   UlData_srsReceiveReqSubcell_t.srsBmEnable
...   UlData_srsBwvReportRequest_t.bwvReportId
...   UlData_srsBwvReportRequest_t.numBwvPerSubband   UlData_srsBwvReportRequest_t.symbolPosition   UlData_srsBwvReportRequest_t.operation
...   UlData_srsBwvReportRequest_t.sinr   UlData_srsBwvReportRequest_t.rho   UlData_srsBwvReportRequest_t.numSrsPorts
...   UlData_srsBwvReportRequest_t.bfSubbandId_item
...   UlData_srsBwvReportRequest_t.srsResourceIdentity   UlData_srsBwvReportRequest_t.startPatternId
...   UlData_srsCyclicShifts_t.transmissionCombId    UlData_srsCyclicShifts_t.cyclicShift   UlData_srsCyclicShifts_t.portIndex
...   UlData_srsBmStruct_t.srsBmResource.Length
...   UlData_srsBmResource_t.srsBmSubbandId   UlData_srsBmResource_t.transmissionCombId   UlData_srsBmResource_t.bmCyclicShift
...   UlData_srsBmResource_t.srsResourceIdentity
...   UlData_srsBwvReport_t.result  UlData_srsBwvReport_t.numBwvPerSubband
...   UlData_srsReceiveRespBwvPsSubcell_t.fhTransDelay   UlData_srsBwvReport_t.bwvReportId   UlData_srsBwvReport_t.portPower_item
...   UlData_srsBwvReport_t.startPatternId   DlData_PdschGrant.pdschScramblingSeqInit   DlData_PdschGrant.patternId_item
...   DlData_PdschGrant.numOfLayers   DlData_PdschGrant.numOfPrb
...   DlData_PdschGrant.antPort   DlData_PdschGrant.numStreamIndex   DlData_PdschGrant.streamIndex_item   DlData_PdschGrant.mcs
...   DlData_PdschGrant.modulationOrder   DlData_PdschGrant.polarizationSelection   DlData_PdschGrant.closedLoop3gppCodebook
...   DlData_PdschGrant.openLoopScheme   DlData_PdschGrant.bestBeamPowerOffset    DlData_PdschGrant.pdschTbTransmitPower
...   DlData_CsiRsResource_t.patternId_item   DlData_CsiRsResource_t.density
...   DlData_CsiRsResource_t.csiRsConfig    DlData_CsiRsResource_t.numCeAxCIndex   DlData_CsiRsResource_t.ceAxCIndex_item
...   DlData_CsiRsResource_t.csiBestBeamPowerOffset

@{title_short}   3gpp.sfn   3gpp.slot   3gpp.rnti
...   UlData_srsReceiveReqSubcell_t.srsBwvEnable
...   UlData_srsBwvReport_t.result   UlData_srsBwvReport_t.numBwvPerSubband   UlData_srsBwvReport_t.portPower_item
...   UlData_srsBwvReport_t.startPatternId   UlData_srsReceiveRespBwvPsSubcell_t.fhTransDelay
...   DlData_PdschGrantL1sw.numStreamIndex   DlData_PdschGrantL1sw.numOfLayers	 DlData_PdschGrantL1sw.patternId_item
...   UlData_srsBwvReportRequest_t.srsResourceIdentity   UlData_srsBwvReportRequest_t.startPatternId
...   DlData_CsiRsResourceL1sw_t.patternId_item
...   DlData_CsiRsResourceL1sw_t.csiRsConfig
...   DlData_PdschGrantL1sw.openLoopScheme
...   UlData_srsBwvReportRequest_t.bwvReportId

${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS

${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-14 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250

${PROFILE11_pos2}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250


${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
${delete_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 delete\=true


*** Test Cases ***
CB011117_A2a_case001_RT_beam_UE_trigger_intra_Freq_handover_and_targer_cell_have_RT_beam_resource
   [Documentation]
    ...    - [TEST PURPOSE] This case will verify that when intra-frequency HO happens, UE will have SRS for SB BF be configured
    ...    for target cell if a)this UE has SRS for SB BF configured in source cell and b) target cell has available SRS for SB BF resources.
    ...    - [TEST PARAMETERS] cell1-cell4 actHoWithSbBf=true, cell1 cell3 cell4 maxNumUeSrs=4, cell2 maxNumUeSrs=1,
    ...    cell1 cell2 cell3 same frequency,cell4 different frequency

   Step1:add RD and Gnb prepare onair
   Step2:attach UE send traffic and check logs
   Step3:Trigger UE2 HO from cell1 to cell2
   Step4:Trigger UE1 HO from cell1 to cell2
#   Step5:Trigger UE2 HO from cell2 to cell3
#   Step6:check UE1 switch to RT



*** Keywords ***
ADD RD
#	Add GNB swconfig	0x59026B:1		# rdActHoWithSbBf
#	Add GNB swconfig	0x59026C:1		# rdEnable6CsForComb4
	Add GNB swconfig	0x59026A:1       #rdActNoAddDlDmrsSwitch

Step1:add RD and Gnb prepare onair
    Log To Console    -----Step1:add RD and Gnb prepare onair-----
    ADD RD
	Wts Execute Aashell Command
	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5

	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
	Get and Update BSR File		par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
	Get and Update BSR File		par_of_bsr_name=BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001

	Prepare gnb onair

    Wait '120s' for stabible


Step2:attach UE send traffic and check logs
    Log To Console    -----Step2:attach UE send traffic and check logs-------
    Start capture gnb and ap syslog in 'step2_ue_attach_check_logs' file
    airphone_cleanup_egate_console_log
    Attach '${UE_NUM_SA}' SA UE

    Get UE '${UE_ID}' rnti from rrc log

    SA send data '${UE_NUM_SA}' UEs
    Wait '3s' for stabible
    Start collect ttitrace
    Set test Variable    ${tti_tag}   step2_tti_traffic
    Wait for '2s' to stop ttitrace with name'${tti_tag}'

    run keyword and continue on failure     check_log_with_au2anlysis
	...    ini_path=${CURDIR}/ini/tti_A2a_intraHO_step2_RT.ini    log_need_to_check=i
	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv

    get_egate_log_UE'step2_ue_traffic'
    [Teardown]    Stop capture gnb and ap syslog in 'step2_ue_attach_check_logs' file

Step3:Trigger UE2 HO from cell1 to cell2
    Log To Console    -----Step3:Trigger UE2 HO from cell1 to cell2-----
    Start capture gnb and ap syslog in 'step3_ue2_ho_from_cell1_to_cell2' file
    airphone_cleanup_egate_console_log

    Start collect ttitrace
    Wait '1s' for stabible

	Airphone Execute Egate Command
	...    ue_measurement_send_nr id\=2 meas_id\=2 event\=A3 srsrp_nr\=11 phycell_id\=51 nrsrp_nr\=80
	...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed

	Set test Variable    ${tti_tag}   step3_tti_ue2_ho_cell1_2
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/All
    Wait '2s' for stabible
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/${tti_tag}

    Set test variable    ${egate_dir}    step3_egate_ue2_ho_cell1_2
    Wait '15s' for stabible
    Airphone Set Log Flush
	Collect AP egate log    ${egate_dir}
	Get UE rnti from rrc log'${egate_dir}'

	run keyword and continue on failure     check_log_with_au2anlysis
	...    ini_path=${CURDIR}/ini/tti_A2a_intraHO_step3_RT.ini    log_need_to_check=i
	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
	[Teardown]    Stop capture gnb and ap syslog in 'step3_ue2_ho_from_cell1_to_cell2' file

Step4:Trigger UE1 HO from cell1 to cell2
    Log To Console    -----Step4:Trigger UE1 HO from cell1 to cell2-----
    Start capture gnb and ap syslog in 'step4_ue1_ho_from_cell1_to_cell2' file
    airphone_cleanup_egate_console_log

    Start collect ttitrace
    Wait '1s' for stabible

	Airphone Execute Egate Command
	...    ue_measurement_send_nr id\=1 meas_id\=2 event\=A3 srsrp_nr\=11 phycell_id\=51 nrsrp_nr\=80
	...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed

	Set test Variable    ${tti_tag}   step4_tti_ue1_ho_cell1_2
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/All
    Wait '2s' for stabible
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/${tti_tag}

    Set test variable    ${egate_dir}    step4_egate_ue1_ho_cell1_2
    Wait '15s' for stabible
    Airphone Set Log Flush
	Collect AP egate log    ${egate_dir}
#	Get UE rnti from rrc log'${egate_dir}'

	run keyword and continue on failure     check_log_with_au2anlysis
	...    ini_path=${CURDIR}/ini/tti_A2a_intraHO_step4_NON_RT.ini    log_need_to_check=i
	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
	[Teardown]    Stop capture gnb and ap syslog in 'step4_ue1_ho_from_cell1_to_cell2' file

Step5:Trigger UE2 HO from cell2 to cell3
    Log To Console    -----Step5:Trigger UE2 HO from cell2 to cell3-----
    Start capture gnb and ap syslog in 'step5_ue2_ho_from_cell2_to_cell3' file
    airphone_cleanup_egate_console_log

    Start collect ttitrace
    Wait '1s' for stabible

	Airphone Execute Egate Command
	...    ue_measurement_send_nr id\=2 meas_id\=2 event\=A3 srsrp_nr\=11 phycell_id\=52 nrsrp_nr\=80
	...    pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.3 performed

	Set test Variable    ${tti_tag}   step5_tti_ue2_ho_cell1_2
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/All
    Wait '2s' for stabible
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/${tti_tag}

    Set test variable    ${egate_dir}    step5_egate_ue2_ho_cell1_2
    Wait '15s' for stabible
    Airphone Set Log Flush
	Collect AP egate log    ${egate_dir}
	Get UE rnti from rrc log'${egate_dir}'

	run keyword and continue on failure     check_log_with_au2anlysis
	...    ini_path=${CURDIR}/ini/tti_A2a_intraHO_step5_RT.ini    log_need_to_check=i
	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
	[Teardown]    Stop capture gnb and ap syslog in 'step5_ue2_ho_from_cell2_to_cell3' file

Step6:check UE1 switch to RT
    Log To Console    -----Step6:check UE1 switch to RT-------

    Start collect ttitrace
    Set test Variable    ${tti_tag}   step6_tti_traffic
    Wait for '2s' to stop ttitrace with name'${tti_tag}'

    run keyword and continue on failure     check_log_with_au2anlysis
	...    ini_path=${CURDIR}/ini/tti_A2a_intraHO_step2_RT.ini    log_need_to_check=i
	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv

Get UE rnti from rrc log'${egate_dir}'
    ${ret}     file match all       ${TEST_LOG_DIRECTORY()}/All/${egate_dir}_egate/egate_console.log    .*crnti: (\\d+)
    set suite variable     ${ue_rnti}    ${ret[0]}

Get UE '${num}' rnti from rrc log
    Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}    unzip=TRUE
    ${ret}     file match all       ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}/egate_console.log    .*crnti: (\\d+)
    set suite variable     ${ue${num}_rnti}    ${ret[0]}

Attach '${UE_NUM_SA}' SA UE
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
       Airphone SA Attach    ue_id=${num}
       Wait '2s' for stabible
       Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
       Wait '2s' for stabible
       Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
       Wait '2s' for stabible
       Wait '3s' for stabible
    END


Detach '${UE_NUM_SA}' SA UE
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        airphone_sa_detach    ue_id=${num}    timeout=30
    END


SA send data '${UE_NUM_SA}' UEs
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        SA send mutiple trf dl data    ${num}    5   175M   ${num}    tcp
        SA send mutiple trf ul data    ${num}    1    10M   ${num}
    END

SA send data UE'${UE_ID}'
    SA send mutiple trf dl data    ${UE_ID}    5   175M   ${UE_ID}    tcp
    SA send mutiple trf ul data    ${UE_ID}    1    10M   ${UE_ID}

get_tti_'${tti_tag}'
	Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti_${tti_tag}'
	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_${tti_tag}_dl.csv

get_bip_'${BIP_tag}'
	Start collect bip log
	Wait for '1s' to stop bip log with name'${BIP_tag}'

	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv    ${filter_csv}    ${title_all}

Change UE'${ue_id}' to cell'${cell_id}'
    airphone_execute_egate_command      ue_change_location cell\=${cell_id} id\=${ue_id}

RANK'${rank}'_CQI'${cqi}'_override_to_UE'${ue_id}'
	Run Keyword If   ${ue_id}>10   Set test Variable    ${scell}	  8
	Run Keyword If   ${ue_id}<11   Set test Variable    ${scell}	  0
	Airphone Execute Egate Command	csi_override_testmode_nr profile_id\=${ue_id} cqi\=${cqi} cqi_mode\=fixed ri\=${rank} ri_mode\=fixed
	Airphone Execute Egate Command	ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=${ue_id} scell\=${scell}

Set UE1 position
    Airphone Execute Egate Command    ${PROFILE1}
    Airphone Execute Egate Command    ${SET_PROFILE1}
    Wait '2s' for stabible

delete profile_1
	Airphone Execute Egate Command    ${delete_PROFILE1}

get_egate_log_UE'${ue_id}'
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE

get_bip_UE'${ue_id}'
	Start collect bip log
	Wait for '1s' to stop bip log with name'BIP_${ue_id}'
	Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_${ue_id}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/BIP_${ue_id}/bip_8322.csv    ${filter_csv}    ${title_short}

get_tti_UE'${ue_id}'
	Start collect ttitrace
	Wait for '2s' to stop ttitrace with name'tti_${ue_id}'
	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_${ue_id}_dl.csv
#==========SA=======================
SA Register UE '${UE_ID}'
	Log To Console   ${\n}-----register UE ${UE_ID} ------
	Airphone SA Attach    ue_id=${UE_ID}
	Wait '2s' for stabible
	${gw_pdu_r}    evaluate    ${UE_ID}%10+1
	Airphone Set Traffic Type    ${UE_ID}    ${gw_pdu_r}    internal
	Airphone Pdu Session Setup   ${UE_ID}    ${gw_pdu_r}    1    ${gw_pdu_r}
	Wait '2s' for stabible

SA Register UE from '${lo}' to '${hi}'
	FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
	 	SA Register UE '${ue}'
    END

DL and UL data to '${UE_ID}' for dl_trf '${num}'
    ${gw_pdu_r}    evaluate    ${UE_ID}%10+1
    FOR    ${i}    IN RANGE    1    ${num}+1
    	Airphone SA Start Data Traffic    ${UE_ID}   DL   165M   pdu_id=${gw_pdu_r}   duration=3600   trf_id=${i}
    END
    Airphone SA Start Data Traffic    ${UE_ID}   UL   1M    pdu_id=${gw_pdu_r}   duration=3600   trf_id=1
    Wait '5s' for stabible

check throughput from SA UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
	${cell_tp_dl}	  evaluate	0
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
       Log To Console    Check throughput UE${num}
          ${dl_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pdsch    tput_type=ave
          ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
          Log To Console		dl ${dl_tput_Mb}
          ${cell_tp_dl}    evaluate    ${cell_tp_dl}+${dl_tput_Mb}
    END
    Log To Console		=====dl_cell_tp ${cell_tp_dl}=====
    run keyword and continue on failure    should be true    ${cell_tp_dl}>=${dl_cell_tp}

DeRegister UE from '${low}' to '${hi}'
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
       airphone_sa_detach    ue_id=${num}    timeout=5
       Wait '3s' for stabible
    END

#===========NSA======================
NSA Attach UE from '${lo}' to '${hi}'
	FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
	    Log To Console   ${\n}--Attach NSA UE ${ue} --
	#    airphone_cleanup_egate_console_log
		Airphone Nsa Attach     ${ue}    profile_id=None
		Wait '2s' for stabible
	#\	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}_attach   unzip=TRUE
    END

check throughput from NSA UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
    ${cell_tp_dl}	  evaluate	0
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
		${pcell_tp}	Get cell dl throught	${num}    8
		${dl_tput_Mb}    evaluate    ${pcell_tp}/1000
		Log To Console    UE${num}_ul_tp ${dl_tput_Mb}M--
	   ${cell_tp_dl}    evaluate    ${cell_tp_dl}+${dl_tput_Mb}
    END
	Log To Console		=====ul_cell_tp ${cell_tp_dl}=====
	run keyword and continue on failure    should be true    ${cell_tp_dl}>=${dl_cell_tp}

Dettach UE from '${low}' to '${hi}'
	FOR    ${num}    IN RANGE    ${low}    ${hi}+1
		Airphone NSA Detach    ue_id= ${num}
	   Wait '3s' for stabible
