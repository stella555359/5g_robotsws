*** Settings ***
Documentation    CB011117 case
Test Timeout    120 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    CLOUD_5G_I_LO_AP_LOOO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCFC_DMRS_VONR_AEQEx2_AQQL_AEHC_case01_MP_LOOO.xml
${AIRPHONE_NAME}    iphy_AEQEx2_AQQL_AEHC_MP_SRS.xml
${WTS_NAME}    wts_config_ASIB_ABIO_G13.cfg

@{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog

${UE_ID}     1


${filter_csv}   uldata_srsreceivereq || uldata_srsreceiverespbwvps || dldata_pdschsendreql1sw || dldata_csirssendreql1sw

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
...   UlData_srsBwvReport_t.startPatternId   DlData_PdschGrantL1sw.pdschScramblingSeqInit   DlData_PdschGrantL1sw.patternId_item
...   DlData_PdschGrantL1sw.numOfLayers   DlData_PdschGrantL1sw .numOfPrb
...   DlData_PdschGrantL1sw.antPort   DlData_PdschGrantL1sw.numStreamIndex   DlData_PdschGrantL1sw.streamIndex_item   DlData_PdschGrantL1sw.mcs
...   DlData_PdschGrantL1sw.modulationOrder   DlData_PdschGrantL1sw.polarizationSelection   DlData_PdschGrantL1sw.closedLoop3gppCodebook
...   DlData_PdschGrantL1sw.openLoopScheme   DlData_PdschGrantL1sw.bestBeamPowerOffset    DlData_PdschGrantL1sw.pdschTbTransmitPower
...   DlData_CsiRsResourceL1sw_t.patternId_item   DlData_CsiRsResourceL1sw_t.density
...   DlData_CsiRsResourceL1sw_t.csiRsConfig    DlData_CsiRsResourceL1sw_t.numCeAxCIndex   DlData_CsiRsResourceL1sw_t.ceAxCIndex_item
...   DlData_CsiRsResourceL1sw_t.csiBestBeamPowerOffset

@{title_short}   3gpp.sfn   3gpp.slot   3gpp.rnti
...   UlData_srsReceiveReqSubcell_t.srsBwvEnable
...   UlData_srsBwvReport_t.result   UlData_srsBwvReport_t.numBwvPerSubband   UlData_srsBwvReport_t.portPower_item
...   UlData_srsBwvReport_t.startPatternId   UlData_srsReceiveRespBwvPsSubcell_t.fhTransDelay
...   DlData_PdschGrantL1sw.numStreamIndex   DlData_PdschGrant.numOfLayers	 DlData_PdschGrant.patternId_item
...   UlData_srsBwvReportRequest_t.srsResourceIdentity   UlData_srsBwvReportRequest_t.startPatternId
...   DlData_CsiRsResourceL1sw_t.patternId_item
...   DlData_CsiRsResourceL1sw_t.csiRsConfig
...   DlData_PdschGrantL1sw.openLoopScheme
...   UlData_srsBwvReportRequest_t.bwvReportId

#${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
#${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
#${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
#${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=4 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
#${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0 test_type\=SRS
#...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-14 zenith\=0 srs_transmit_power_per_port\=-240,-240,-250,-250
#${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
#${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
#${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS

${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-14 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250

${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250

${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=20 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250

${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250

${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250

${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250

${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250

${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250

${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250

${PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=4 init_sub_quad_pos\=2 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250


${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
${SET_PROFILE2}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5

${SET_PROFILE6}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
${SET_PROFILE7}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
${SET_PROFILE8}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
${SET_PROFILE9}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=9
${SET_PROFILE10}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10

${SET_PROFILE11}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=11
${deactive_P11}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=11
${deactive_P5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=5
${delete_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 delete\=true
${delete_PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 delete\=true
${delete_PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 delete\=true
${delete_PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 delete\=true
${delete_PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 delete\=true
${delete_PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 delete\=true
${delete_PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 delete\=true
${delete_PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 delete\=true
${delete_PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 delete\=true

*** Test Cases ***
CB011117_E1b_case001_DMRS_switch_monitor
    Step1:add RD and Gnb prepare onair
	Step2:attach UE and check logs
	Step3:send traffic and check logs
	Step4:Move UE pos and check logs
	Stop capture gnb and ap syslog in 'after_onair' file

*** Keywords ***

Step1:add RD and Gnb prepare onair
    ADD RD
	Wts Execute Aashell Command
	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
#
	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
	Get and Update BSR File		par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
	Get and Update BSR File		par_of_bsr_name=BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#
	Prepare gnb onair
	Start capture gnb and ap syslog in 'after_onair' file
	Wait '120s' for stabible

ADD RD
#	Add GNB swconfig	0x59026B:1		# rdActHoWithSbBf
	Add GNB swconfig	0x59026C:1		# rdEnable6CsForComb4
	#Add GNB swconfig	0x59026A:1       #rdActNoAddDlDmrsSwitch
	Add GNB swconfig	0x58096f:0x63       #rdWbSrsNoAddDlDmrsCorrThreshold
	Add GNB swconfig	0x580970:0x62     #rdWbSrsAddDlDmrsCorrThreshold
	Add GNB swconfig    0x58076a:1		# rdNumWbSrsMeas, default=5;
	#The minimum number of correlation metric before correlation is used for measure radio link variety,set to 1 ,corrAvg=current average.
	Add GNB swconfig 	0x58077b:1		# rdNumSbSrsCorrCal, default=5
	Add GNB swconfig    0x580971:10     # rdNoAddDlDmrsConstraintTimer, default=60s
	Add GNB swconfig    0x580972:50    #rdNoAddDlDmrsReleaseProhibitTimer  , default=500 slot
	Add GNB swconfig    0x580973:50    #rdNoAddDlDmrsConfigProhibitTimer, default=500 slot

Step2:attach UE and check logs
    airphone_cleanup_egate_console_log
    SA Register UE '${UE_ID}'
    Set UE'${UE_ID}' position
    Wait '5s' for stabible
    get_egate_log_UE'attach'
    run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/DMRS_pos1.ini    log_need_to_check=p
   ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_attach

Step3:send traffic and check logs
#    airphone_cleanup_egate_console_log
#    Start collect bip log
    Start collect ttitrace
    SA send mutiple trf dl data    ${UE_ID}    5   175M   ${UE_ID}    tcp
#    Wait for '1s' to stop bip log with name'bip_traffic'
    Wait for '1s' to stop ttitrace with name'tti_traffic'

    get_egate_log_UE'traffic'
	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_traffic_dl.csv

#	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
#	...    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv    ${filter_csv}    ${title_all}
    get_egate_log_UE'traffic'
    run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/DMRS_pos0.ini    log_need_to_check=p
   ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_traffic

Step4:Move UE pos and check logs
    airphone_cleanup_egate_console_log
    Start collect ttitrace
    Airphone Execute Egate Command    ${PROFILE6}
    Airphone Execute Egate Command    ${SET_PROFILE6}
    Wait for '1s' to stop ttitrace with name'tti_move'
    Start collect ttitrace
    Move UE pos for '10'
#    Move UE pos for '${times}'

    Wait for '0s' to stop ttitrace with name'tti_move_10'
    Start collect ttitrace
    Wait for '3s' to stop ttitrace with name'tti_move_after'
    get_egate_log_UE'ue1_move'
    run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/DMRS_pos1.ini    log_need_to_check=p
   ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_ue1_move

Move UE pos for '${times}'
    FOR    ${num}    IN RANGE    1    ${times}+1
#        airphone_cleanup_egate_console_log
#        Start collect ttitrace
        Airphone Execute Egate Command    ${PROFILE1}
        Airphone Execute Egate Command    ${SET_PROFILE1}
        Wait '0.5s' for stabible
        Airphone Execute Egate Command    ${PROFILE2}
        Airphone Execute Egate Command    ${SET_PROFILE2}
	END

Attach '${UE_NUM_SA}' SA UE
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
       airphone_cleanup_egate_console_log
       Airphone SA Attach    ue_id=${num}
       Wait '2s' for stabible
       Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
       Wait '2s' for stabible
       Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
       Wait '2s' for stabible
       Collect AP egate log    ${EGATE_TAG}_${num}
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

Set UE'${UE_ID}' position
    Airphone Execute Egate Command    ${PROFILE${UE_ID}}
    Airphone Execute Egate Command    ${SET_PROFILE${UE_ID}}

test_Cell4_multiple_UE_t1r4
	Set test Variable   ${UE_id_lo}   11
	Set test Variable   ${UE_id_hi}   14
	Start capture gnb and ap syslog in 'sys_4UE' file
	airphone_cleanup_egate_console_log
	Change UE'11-18' to cell'4'

	FOR    ${ue}    IN RANGE    ${UE_id_lo}    ${UE_id_hi}+1
		SA Register UE from '${ue}' to '${ue}'
		DL and UL data to '${ue}' for dl_trf '5'
    END
	run keyword and continue on failure
	...   Wait Until Keyword Succeeds    60s    2s  check throughput from SA UE '${UE_id_lo}' to '${UE_id_hi}' with tp '700'

	Set test Variable   ${BIP_tag}   BIP_com4_CS6_physcell_53_t1r4_x4
	get_bip_'${BIP_tag}'
	run keyword and continue on failure   check_3UE_bwv_calc_per_slot   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   surpport_3UE_bwv_calc=False

	DeRegister UE from '${UE_id_lo}' to '${UE_id_hi}'
	get_egate_log_UE'cell4_4UE'
	run keyword and continue on failure   Stop capture gnb and ap syslog in 'sys_4UE' file

test_comb4_CS6
	Start capture gnb and ap syslog in 'sys_comb4_CS6' file
	airphone_cleanup_egate_console_log
	Change UE'1' to cell'1'
	Change UE'2' to cell'2'
	Change UE'3' to cell'3'
	SA Register UE from '1' to '3'
	DL and UL data to '1' for dl_trf '5'
	DL and UL data to '2' for dl_trf '5'
	DL and UL data to '3' for dl_trf '5'
	run keyword and continue on failure   Wait Until Keyword Succeeds    60s    2s  check throughput from SA UE '1' to '3' with tp '700'

	Set test Variable   ${BIP_tag}   BIP_com4_CS6_physcell_50_51_52
	get_bip_'${BIP_tag}'
	run keyword and continue on failure   check_comb4_CS6_in_bip_csv   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv   comb4_CS6=True

	run keyword and continue on failure   check_additional_BWV_calculation_in_bip   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell_ID=50   additional_BWV_cal=True

	run keyword and continue on failure   check_additional_BWV_calculation_in_bip   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell_ID=51   additional_BWV_cal=True

	run keyword and continue on failure   check_additional_BWV_calculation_in_bip   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell_ID=52   additional_BWV_cal=True

	DeRegister UE from '1' to '3'
	get_egate_log_UE'123'
	run keyword and continue on failure   Stop capture gnb and ap syslog in 'sys_comb4_CS6' file

test_11117_interFreq_HO_and_back
	Start capture gnb and ap syslog in 'sys_HO' file
	airphone_cleanup_egate_console_log
	Change UE'1' to cell'1'
	SA Register UE from '1' to '1'
	DL and UL data to '1' for dl_trf '5'
	run keyword and continue on failure   Wait Until Keyword Succeeds    60s    2s  check throughput from SA UE '1' to '1' with tp '700'
    get_bip_'UE1'
	A2_into_GAP_cell_1_CRITERION1_RT
	GAP_rank41_WB_to_SB
	GAP_rank14_SB_can_NOT_switch_to_WB

	interFreqHO_cell_2
	A2_into_GAP_cell_2_CRITERION2_fallback_DFT
	interFreqHO_back_cell_1

	get_egate_log_UE'1'
	DeRegister UE from '1' to '1'
	#RANK'3'_CQI'15'_override_to_UE'1'
	run keyword and continue on failure   Stop capture gnb and ap syslog in 'sys_HO' file

A2_into_GAP_cell_1_CRITERION1_RT
	Log To Console   ${\n}--A2---
	Start collect ttitrace
	Wait '1s' for stabible
	Airphone Execute Egate Command
	...   ue_measurement_send_nr id\=1 meas_id\=1 event\=A2 srsrp_nr\=11

	Set test Variable    ${tti_tag}   tti_cell1_GAP_CRITERION1
#	get_bip_'CRITERION1_RT'
	Wait for '2s' to stop ttitrace with name'${tti_tag}'
	get_bip_'CRITERION1_RT'
	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv

	Set test Variable    ${tti_title_tag}		${tti_tag}_dl_split.csv
    run keyword and continue on failure     check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tti_dl_GAP_cell_1_CRITERION1_RT.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

	run keyword and continue on failure   Wait Until Keyword Succeeds    60s    2s  check throughput from SA UE '1' to '1' with tp '700'

GAP_rank41_WB_to_SB
	Log To Console   ${\n}--GAP_rank41_WB_to_SB---
	Set test Variable    ${tti_tag}   GAP_rank41_WB_to_SB
	Start collect ttitrace
	RANK'0'_CQI'15'_override_to_UE'1'
	Wait for '2s' to stop ttitrace with name'${tti_tag}'
	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv

	Set test Variable    ${tti_title_tag}		${tti_tag}_dl_split.csv
    run keyword and continue on failure     check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tti_dl_GAP_rank41_WB_to_SB.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

GAP_rank14_SB_can_NOT_switch_to_WB
	Log To Console   ${\n}--GAP_rank14_SB_can_NOT_switch_to_WB---
	Set test Variable    ${tti_tag}   GAP_rank14_SB_can_NOT_switch_to_WB
	Start collect ttitrace
	RANK'3'_CQI'15'_override_to_UE'1'
	Wait for '2s' to stop ttitrace with name'${tti_tag}'
	## run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
	Set test Variable    ${tti_title_tag}		${tti_tag}_dl.csv
    run keyword and continue on failure     check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tti_dl_GAP_rank14_SBSRS_DFT_cannot_switch_WBSRS_RT.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

interFreqHO_cell_2
	Log To Console   ${\n}--inter Freq HO to cell 51---
	#Start collect ttitrace
	#Wait '1s' for stabible
	run keyword and continue on failure   Airphone Execute Egate Command
	...   ue_measurement_send_nr id\=1 meas_id\=4 event\=A3 srsrp_nr\=11 phycell_id\=51 nrsrp_nr\=80
	...   pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
	#Wait for '2s' to stop ttitrace with name'tti_HO'
	#run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_HO_dl.csv
	run keyword and continue on failure   Wait Until Keyword Succeeds    60s    2s  check throughput from SA UE '1' to '1' with tp '700'

A2_into_GAP_cell_2_CRITERION2_fallback_DFT
	Log To Console   ${\n}--A2 back---
	Start collect ttitrace
	Wait '1s' for stabible
	Airphone Execute Egate Command
	...   ue_measurement_send_nr id\=1 meas_id\=5 event\=A2 srsrp_nr\=11
	Set test Variable    ${tti_tag}   tti_cell2_GAP_CRITERION2
	Wait for '2s' to stop ttitrace with name'${tti_tag}'
	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
	get_bip_'CRITERION2'
	Set test Variable    ${tti_title_tag}		${tti_tag}_dl_split.csv
    run keyword and continue on failure     check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tti_dl_GAP_cell_2_CRITERION2_fall_back_DFT.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
	run keyword and continue on failure   Wait Until Keyword Succeeds    60s    2s  check throughput from SA UE '1' to '1' with tp '700'

interFreqHO_back_cell_1
	Log To Console   ${\n}--inter Freq HO back to cell 50---
	run keyword and continue on failure   Airphone Execute Egate Command
	...   ue_measurement_send_nr id\=1 meas_id\=8 event\=A3 srsrp_nr\=30 phycell_id\=50 nrsrp_nr\=80
	...   pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed

	Wait '1s' for stabible
	run keyword and continue on failure   Wait Until Keyword Succeeds    60s    2s  check throughput from SA UE '1' to '1' with tp '700'

test_GAP_SRS_no_overlap
	online change gapoffset '0' cell'1'
	airphone_cleanup_egate_console_log
	Change UE'1' to cell'1'
	SA Register UE from '1' to '1'
	DL and UL data to '1' for dl_trf '5'
	run keyword and continue on failure   Wait Until Keyword Succeeds    60s    2s  check throughput from SA UE '1' to '1' with tp '700'
	A2_into_GAP_cell_1_NONE_overlap
	DeRegister UE from '1' to '1'
	get_egate_log_UE'NONE'

A2_into_GAP_cell_1_NONE_overlap
	Log To Console   ${\n}--A2---
	Set test Variable    ${tti_tag}   tti_cell1_GAP_NONE_overlap
	Start collect ttitrace
	Wait '1s' for stabible
	Airphone Execute Egate Command
	...   ue_measurement_send_nr id\=1 meas_id\=1 event\=A2 srsrp_nr\=11

	Wait for '1s' to stop ttitrace with name'${tti_tag}'
	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv

	Set test Variable    ${tti_title_tag}		${tti_tag}_dl_split.csv
    run keyword and continue on failure     check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tti_dl_GAP_cell_1_NONE_RT.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
	run keyword and continue on failure   Wait Until Keyword Succeeds    20s    2s  check throughput from SA UE '1' to '1' with tp '650'

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



deactive p11
	Airphone Execute Egate Command    ${deactive_P11}

delete profile_11
	Airphone Execute Egate Command    ${delete_PROFILE11}
	#=====end====NSA=====t1r4=============================

test_SA_UE1_t1r4
	Start capture gnb and ap syslog in 'UE1' file
	airphone_cleanup_egate_console_log
	SA Register UE '1'
	#Set UE1 position
	DL and UL data to '1' for dl_trf '10'
	run keyword and continue on failure    Wait Until Keyword Succeeds    30s    2s   check throughput from SA UE '1' to '1' with tp '1280'
	get_bip_UE'1'
	get_tti_UE'1'
	DeRegister UE from '1' to '1'

	get_egate_log_UE'1'
	Stop capture gnb and ap syslog in 'UE1' file

check_tti_UE'${UE_ID}'
	Set test Variable    ${tti_title_tag}		tti_${UE_ID}_dl.csv
	Set test Variable    ${beam_type}   SUBBAND
	Set test Variable    ${ping_patternid_1}    2100
	Set test Variable    ${ping_patternid_2}    2171
	Set test Variable    ${ping_csi_patternid_1}    2172
	Set test Variable    ${ping_csi_patternid_2}    2173
	Set test Variable    ${ping_csi_patternid_3}    2174
	Set test Variable    ${ping_csi_patternid_4}    2175

	Set test Variable    ${pong_patternid_1}    2176
	Set test Variable    ${pong_patternid_2}    2247
	Set test Variable    ${pong_csi_patternid_1}    2248
	Set test Variable    ${pong_csi_patternid_2}    2249
	Set test Variable    ${pong_csi_patternid_3}    2250
	Set test Variable    ${pong_csi_patternid_4}    2251
	run keyword and continue on failure     check_log_with_au2anlysis
	...    ini_path=${CURDIR}/ini/tti_dl_8322_B2_case8.ini    log_need_to_check=i
	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

RANK'${rank}'_CQI'${cqi}'_override_to_UE'${ue_id}'
	Run Keyword If   ${ue_id}>10   Set test Variable    ${scell}	  8
	Run Keyword If   ${ue_id}<11   Set test Variable    ${scell}	  0
	Airphone Execute Egate Command	csi_override_testmode_nr profile_id\=${ue_id} cqi\=${cqi} cqi_mode\=fixed ri\=${rank} ri_mode\=fixed
	Airphone Execute Egate Command	ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=${ue_id} scell\=${scell}

deactive_rank_overide_UE'${ue_id}'
	Run Keyword If   ${ue_id}>10   Set test Variable    ${scell}	  8
	Run Keyword If   ${ue_id}<11   Set test Variable    ${scell}	  0
	Airphone Execute Egate Command	ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=deactivate profile_id\=${ue_id} scell\=${scell}

delete_Rank_override_UE'${ue_id}'
	Airphone Execute Egate Command	csi_override_testmode_nr profile_id\=${ue_id} delete\=true

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
	${gw_pdu_r}    evaluate    ${UE_ID}%10
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
    END

#check tti
Check '${UE_ID}' PatternId and Bler in ttiTrace
    Log To Console    Check PatternId and Bler in ttiTrace: UE ${UE_ID}
    check dft_beam and bler in tti

check dft_beam and bler in tti
    Log To Console    Check ttitrace DL
    run keyword and continue on failure     check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tti_dl_dft_1024_case3.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

    Log To Console    Check ttitrace UL
    run keyword and continue on failure     check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tti_ul_dft_1024_case3.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

#check RRC
check UE '${ue_id}' SRS in RRC log
    Log To Console   check UE ${ue_id} SRS in RRC log
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
    run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/RRC_ue${ue_id}_case3.ini    log_need_to_check=p
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}

online change gapoffset '${gapoffset}' cell'${cell_id}'
    Log To Console    ${\n}=======online_change_gapOffset_${gapoffset} cell${cell_id}========
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-2/NRCELL-${cell_id}   parameter=gapOffset
    ...    operation=update    value=${gapoffset}    skip_parameter_relation_errors=True    should_activate=True    connection=online

    TAF_ADMIN.teardown admin    connection=online
    Wait '10s' for stabible
		# gapOffset from 31 to 0
