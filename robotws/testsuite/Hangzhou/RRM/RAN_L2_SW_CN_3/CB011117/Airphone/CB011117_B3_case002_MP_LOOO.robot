*** Settings ***
Documentation    CB011117 case
Test Timeout    120 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    CLOUD_5G_I_MP_AP_LOOO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCFC_AEQEx2_AQQL_AEHC_B3_case02_MP.xml
${AIRPHONE_NAME}    iphy_AEQEx2_AQQL_AEHC_MP_B3_case02.xml
${WTS_NAME}    wts_config_ASIB_ABIO_G13.cfg

@{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog

${FILTER_f1ap}    (f1ap) && (nr-rrc.supportedSRS_TxPortSwitch)
@{titles_f1ap}    nr-rrc.supportedSRS_TxPortSwitch

${filter_csv}   uldata_srsreceivereq || uldata_srsreceiverespbwvps || dldata_pdschsendreql1sw || dldata_csirssendreql1sw
@{title_all}   3gpp.sfn   3gpp.slot   3gpp.rnti   3gpp.subcellid
...   UlData_srsBwvStruct_t.srsBwvReportRequests.Length   UlData_srsReceiveReqSubcell_t.srsBwvEnable
...   UlData_srsBwvReportRequest_t.operation       UlData_srsBwvReportRequest_t.numSrsPorts   UlData_srsBwvReportRequest_t.bfSubbandId_item
...   UlData_srsBwvReportRequest_t.srsResourceIdentity
...   UlData_srsCyclicShifts_t.transmissionCombId    UlData_srsCyclicShifts_t.cyclicShift
...   UlData_srsBwvReport_t.result  UlData_srsBwvReport_t.numBwvPerSubband
...   UlData_srsBwvReport_t.startPatternId   DlData_PdschGrantL1sw.pdschScramblingSeqInit   DlData_PdschGrantL1sw.patternId_item
...   DlData_PdschGrantL1sw.numOfLayers   DlData_PdschGrantL1sw.numOfPrb
...   DlData_CsiRsResourceL1sw_t.patternId_item   DlData_CsiRsResourceL1sw_t.csiRsConfig

${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-14 zenith\=0 srs_transmit_power_per_port\=-240,-240,-250,-250
${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS

${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-14 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250

${PROFILE11_pos2}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250


${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5

${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
${SET_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
${SET_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
${SET_PROFILE11}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=11
${deactive_P11}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=11
${deactive_P5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=5
${delete_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 delete\=true


*** Test Cases ***
CB011117_B3_case002_max_3UE_BWV_resp_per_slot_on_ABIP
    Step1:add RD and Gnb prepare onair
	Step2:test_multiple_UE_t1r4_Cell53_AEHC
	Step3:test_multiple_UE_t1r4_cell50_AEQE
	Step4:test_multiple_UE_t1r4_NSA_cell52_AQQL
	Step5:test_multiple_UE_t2r4_cell50_AEQE

*** Keywords ***
Step1:add RD and Gnb prepare onair
    Log To Console    -----Step1:add RD and Gnb prepare onair-----
    ADD RD
	Wts Execute Aashell Command
	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5

	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
	Get and Update BSR File		par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
	Get and Update BSR File		par_of_bsr_name=BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001

	Prepare gnb onair
#	online act CB08322 debug flag
    Wait '120s' for stabible

ADD RD
#	Add GNB swconfig	0x59026B:1		# rdActHoWithSbBf
#	Add GNB swconfig	0x59026C:1		# rdEnable6CsForComb4
	Add GNB swconfig	0x59026A:1       #rdActNoAddDlDmrsSwitch  -E
	Add GNB swconfig	0x590284:1       #rdEnableNewAlgForSubbandBFSrs  -B
	Add GNB swconfig	0x800098:1       #rdSrsCeToEnabledFlag

Step2:test_multiple_UE_t1r4_Cell53_AEHC
    Log To Console    -----Step2:test_multiple_UE_t1r4_Cell53-----
	Set test Variable   ${UE_id_lo}   11
	Set test Variable   ${UE_id_hi}   14
	Start capture gnb and ap syslog in 'Step2_test_multiple_UE_t1r4_Cell53' file
	airphone_cleanup_egate_console_log
	Change UE'11-14' to cell'4'

	FOR    ${ue}    IN RANGE    ${UE_id_lo}    ${UE_id_hi}+1
		SA Register UE from '${ue}' to '${ue}'
		DL and UL data to '${ue}' for dl_trf '5'
    END
	run keyword and continue on failure
	...   Wait Until Keyword Succeeds    60s    2s  check throughput from SA UE '${UE_id_lo}' to '${UE_id_hi}' with tp '600'

	Start collect ttitrace
	Set test Variable    ${tti_tag}   tti_t1r4_cell53
    Wait for '2s' to stop ttitrace with name'${tti_tag}'

    run keyword and continue on failure     check_log_with_au2anlysis
	...    ini_path=${CURDIR}/ini/tti_B3_case02_RT.ini    log_need_to_check=i
	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv

	Set test Variable   ${BIP_tag}   BIP_com4_physcell_53_t1r4_x4
	get_bip_'${BIP_tag}'

	run keyword and continue on failure   check_comb4_CS6_in_bip_csv   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv   comb4_CS6=false

	run keyword and continue on failure   check_3UE_bwv_calc_per_slot   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   surpport_3UE_bwv_calc=True

	DeRegister UE from '${UE_id_lo}' to '${UE_id_hi}'
	get_egate_log_UE'cell53_4UE_t1r4'
	[Teardown]    Stop capture gnb and ap syslog in 'Step2_test_multiple_UE_t1r4_Cell53' file

Step3:test_multiple_UE_t1r4_cell50_AEQE
    Log To Console    -----Step3:test_multiple_UE_t1r4_Cell50-----
    Start capture gnb and ap syslog in 'Step3_test_multiple_UE_t1r4_cell50' file
	Set test Variable   ${UE_id_lo}   11
	Set test Variable   ${UE_id_hi}   14
	airphone_cleanup_egate_console_log
	Change UE'11-14' to cell'1'

	FOR    ${ue}    IN RANGE    ${UE_id_lo}    ${UE_id_hi}+1
		SA Register UE from '${ue}' to '${ue}'
		DL and UL data to '${ue}' for dl_trf '5'
    END
	run keyword and continue on failure
	...   Wait Until Keyword Succeeds    60s    2s  check throughput from SA UE '${UE_id_lo}' to '${UE_id_hi}' with tp '500'

	Start collect ttitrace
	Set test Variable    ${tti_tag}   tti_t1r4_cell50
    Wait for '2s' to stop ttitrace with name'${tti_tag}'

    run keyword and continue on failure     check_log_with_au2anlysis
	...    ini_path=${CURDIR}/ini/tti_B3_case02_RT.ini    log_need_to_check=i
	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv

	Set test Variable   ${BIP_tag}   BIP_com4_physcell_50_t1r4_x4
	get_bip_'${BIP_tag}'

	run keyword and continue on failure   check_comb4_CS6_in_bip_csv   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...    comb4_CS6=false

	run keyword and continue on failure   check_3UE_bwv_calc_per_slot   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   surpport_3UE_bwv_calc=True

	DeRegister UE from '${UE_id_lo}' to '${UE_id_hi}'
	get_egate_log_UE'cell50_4UE_t1r4'
	[Teardown]    Stop capture gnb and ap syslog in 'Step3_test_multiple_UE_t1r4_cell50' file

Step3:test_multiple_UE_NSA_t1r4_cell50_AEQE
    Log To Console    -----Step3:test_multiple_UE_t1r4_Cell50-----
    Start capture gnb and ap syslog in 'Step3_test_multiple_UE_t1r4_cell50' file
	Set test Variable   ${UE_id_lo}   11
	Set test Variable   ${UE_id_hi}   14
	airphone_cleanup_egate_console_log
	Change UE'11-14' to cell'1'

	NSA Attach UE from '${UE_id_lo}' to '${UE_id_hi}'
	NSA send data UEs from '${UE_id_lo}' to '${UE_id_hi}'

	Check throughput from NSA UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
	run keyword and continue on failure
	...   Wait Until Keyword Succeeds    60s    2s  Check throughput from NSA UE '${UE_id_lo}' to '${UE_id_hi}' with tp '500'

	Start collect ttitrace
	Set test Variable    ${tti_tag}   tti_t1r4_cell50
    Wait for '2s' to stop ttitrace with name'${tti_tag}'

    run keyword and continue on failure     check_log_with_au2anlysis
	...    ini_path=${CURDIR}/ini/tti_B3_case02_RT.ini    log_need_to_check=i
	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv

	Set test Variable   ${BIP_tag}   BIP_com4_physcell_50_t1r4_x4
	get_bip_'${BIP_tag}'

	run keyword and continue on failure   check_comb4_CS6_in_bip_csv   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...    comb4_CS6=false

	run keyword and continue on failure   check_3UE_bwv_calc_per_slot   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   surpport_3UE_bwv_calc=True

	Dettach NSA UE from '${UE_id_lo}' to '${UE_id_hi}'
	get_egate_log_UE'cell50_4UE_t1r4'
	[Teardown]    Stop capture gnb and ap syslog in 'Step3_test_multiple_UE_t1r4_cell50' file

Step4:test_multiple_UE_t1r4_NSA_cell52_AQQL
    Log To Console    -----Step4:test_multiple_UE_t1r4_cell52_NSA-----
	Set test Variable   ${UE_id_lo}   21
	Set test Variable   ${UE_id_hi}   24
	Start capture gnb and ap syslog in 'Step4_test_multiple_UE_t1r4_NSA_cell52' file
	airphone_cleanup_egate_console_log
	Change UE'21-24' to cell'3'

	FOR    ${ue}    IN RANGE    ${UE_id_lo}    ${UE_id_hi}+1
		Airphone Nsa Attach    ${ue}
		NSA send mutiple trf dl data    ${ue}    6    175M    tcp
    END

	run keyword and continue on failure
	...   Wait Until Keyword Succeeds    60s    2s  check throughput from NSA UE '${UE_id_lo}' to '${UE_id_hi}' with tp '500'

	Start collect ttitrace
	Set test Variable    ${tti_tag}   tti_t1r4_cell52_NSA
    Wait for '2s' to stop ttitrace with name'${tti_tag}'

    run keyword and continue on failure     check_log_with_au2anlysis
	...    ini_path=${CURDIR}/ini/tti_B3_case02_RT.ini    log_need_to_check=i
	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv

	Set test Variable   ${BIP_tag}   BIP_com4_physcell_52_t1r4_x4_NSA
	get_bip_'${BIP_tag}'

	run keyword and continue on failure   check_comb4_CS6_in_bip_csv   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...    comb4_CS6=false

	run keyword and continue on failure   check_3UE_bwv_calc_per_slot   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   surpport_3UE_bwv_calc=true

	Dettach NSA UE from '${UE_id_lo}' to '${UE_id_hi}'
	get_egate_log_UE'cell52_4UE_t1r4_NSA'
	[Teardown]    Stop capture gnb and ap syslog in 'Step4_test_multiple_UE_t1r4_NSA_cell52' file

Step5:test_multiple_UE_t2r4_cell50_AEQE
    Log To Console    -----Step5:test_multiple_UE_t2r4_Cell50-----
	Set test Variable   ${UE_id_lo}   1
	Set test Variable   ${UE_id_hi}   4
	Start capture gnb and ap syslog in 'Step5_test_multiple_UE_t2r4_cell50' file
	airphone_cleanup_egate_console_log
	Change UE'1-4' to cell'1'

	FOR    ${ue}    IN RANGE    ${UE_id_lo}    ${UE_id_hi}+1
		SA Register UE from '${ue}' to '${ue}'
		DL and UL data to '${ue}' for dl_trf '5'
    END
	run keyword and continue on failure
	...   Wait Until Keyword Succeeds    60s    2s  check throughput from SA UE '${UE_id_lo}' to '${UE_id_hi}' with tp '450'

	Start collect ttitrace
	Set test Variable    ${tti_tag}   tti_t2r4_cell50
    Wait for '2s' to stop ttitrace with name'${tti_tag}'

    run keyword and continue on failure     check_log_with_au2anlysis
	...    ini_path=${CURDIR}/ini/tti_B3_case02_RT.ini    log_need_to_check=i
	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

	run keyword and continue on failure   split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv

	Set test Variable   ${BIP_tag}   BIP_com4_physcell_50_t2r4_x4
	get_bip_'${BIP_tag}'

	run keyword and continue on failure   check_comb4_CS6_in_bip_csv   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...    comb4_CS6=false

	run keyword and continue on failure   check_3UE_bwv_calc_per_slot   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   surpport_3UE_bwv_calc=false

	DeRegister UE from '${UE_id_lo}' to '${UE_id_hi}'
	get_egate_log_UE'cell50_4UE_t2r4'
	[Teardown]    Stop capture gnb and ap syslog in 'Step5_test_multiple_UE_t2r4_cell50' file

Step6:test_check_additional_BWV_calculation
    Log To Console    -----Step6:test_check_additional_BWV_calculation-----
	Start capture gnb and ap syslog in 'Step6_test_check_additional_BWV_calculation' file
	airphone_cleanup_egate_console_log
	Change UE'1-3' to cell'1'
	Change UE'4-6' to cell'2'
	Change UE'7-9' to cell'3'
	Change UE'10-12' to cell'4'
	SA Register UE from '1' to '12'
	DL and UL data to '1' for dl_trf '5'
	DL and UL data to '2' for dl_trf '5'
	DL and UL data to '3' for dl_trf '5'
	DL and UL data to '4' for dl_trf '5'
	DL and UL data to '5' for dl_trf '5'
	DL and UL data to '6' for dl_trf '5'
	DL and UL data to '7' for dl_trf '5'
	DL and UL data to '8' for dl_trf '5'
	DL and UL data to '9' for dl_trf '5'
	DL and UL data to '10' for dl_trf '5'
	DL and UL data to '11' for dl_trf '5'
	DL and UL data to '12' for dl_trf '5'

#	run keyword and continue on failure   Wait Until Keyword Succeeds    60s    2s  check throughput from SA UE '1' to '4' with tp '450'

	Set test Variable   ${BIP_tag}   BIP_com4_physcell_50_51_52_53
	Start collect ttitrace
	Wait for '1s' to stop ttitrace with name'tti_physcell_50_51_52_53'
	get_bip_'${BIP_tag}'

	run keyword and continue on failure   check_additional_BWV_calculation_in_bip   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell_ID=50   additional_BWV_cal=True

	run keyword and continue on failure   check_additional_BWV_calculation_in_bip   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell_ID=51   additional_BWV_cal=True

	run keyword and continue on failure   check_additional_BWV_calculation_in_bip   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell_ID=52   additional_BWV_cal=True

	run keyword and continue on failure   check_additional_BWV_calculation_in_bip   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell_ID=53   additional_BWV_cal=True

	DeRegister UE from '1' to '12'
	get_egate_log_UE'physcell_50_51_52_53'
	[Teardown]    Stop capture gnb and ap syslog in 'Step6_test_check_additional_BWV_calculation' file

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

Check throughput from NSA UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
    ${cell_tp_dl}	  evaluate	0
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
		${pcell_tp}	Get cell dl throught	${num}    8
		${dl_tput_Mb}    evaluate    ${pcell_tp}/1000
		Log To Console    UE${num}_ul_tp ${dl_tput_Mb}M--
	   ${cell_tp_dl}    evaluate    ${cell_tp_dl}+${dl_tput_Mb}
    END
	Log To Console		=====ul_cell_tp ${cell_tp_dl}=====
	run keyword and continue on failure    should be true    ${cell_tp_dl}>=${dl_cell_tp}

NSA send data UEs from '${low_id}' to '${high_id}'
    FOR    ${num}    IN RANGE    ${low_id}    ${high_id}+1
       NSA send mutiple trf dl data    ${num}    5    175M    tcp
    END

Dettach NSA UE from '${low}' to '${hi}'
	FOR    ${num}    IN RANGE    ${low}    ${hi}+1
		Airphone NSA Detach    ue_id= ${num}
	   Wait '3s' for stabible
    END


