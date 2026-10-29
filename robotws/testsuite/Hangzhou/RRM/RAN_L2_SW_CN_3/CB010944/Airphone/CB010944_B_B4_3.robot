*** Settings ***
Test Timeout    120 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
#Force Tags    owner_zhang   CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot
Library    ute_admin_infomodel

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCF_10944_B_B4_3.xml
${AIRPHONE_NAME}    IPHY_AVQC_1CELL_APLO_1RF_8D4U_8192.xml
${WTS_NAME}    wts_10944_A_B5_SA_NSA.cfg

@{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog

${FILTER_f1ap}    (f1ap) && (nr-rrc.supportedSRS_TxPortSwitch)
@{titles_f1ap}    nr-rrc.supportedSRS_TxPortSwitch

${filter_csv}   (uldata_srsreceivereq||uldata_srsreceiverespbmps||uldata_srsreceiverespbwvps||dldata_pdschsendreq) && !(3gpp.rnti == 65535)

@{title_comb4}   3gpp.sfn   3gpp.slot   3gpp.rnti
...   UlData_srsReceiveReqSubcell_t.srsSuMimoEnable
...   UlData_srsBwvReport_t.result   UlData_srsBwvReport_t.startPatternId   UlData_srsBwvReport_t.portPower_item
...   UlData_srsBwvReport_t.correlation_item   UlData_srsBwvReport_t.numBwvPerSubband
...   UlData_srsReceiveReqSubcell_t.srsBmEnable   UlData_srsBmStruct_t.transmissionComb
...   UlData_srsBmCsInfo_t.srsResourceIdentity   UlData_srsBmCombShiftPairs_t.transmissionCombId   UlData_srsBmCsInfo_t.bmCyclicShift
...   UlData_srsBmSubbands_t.srsBmSubbandId   UlData_SrsReceiveRespBmPs_t.polarization
...   UlData_srsReceiveReqSubcell_t.srsBwvEnable   UlData_srsBwvStruct_t.transmissionComb
...   UlData_srsBwvReportRequest_t.srsResourceIdentity   UlData_srsCyclicShifts_t.transmissionCombId   UlData_srsCyclicShifts_t.cyclicShift
...   UlData_srsBwvReportRequest_t.bfSubbandId_item
...   DlData_PdschGrant.patternId_item   DlData_PdschGrant.numOfLayers
...   UlData_eCpriConfigStruct_t.patternId_item   UlData_eCpriConfigStruct_t.numCeAxCIndex

${PROFILE5_31}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250

${PROFILE5_13}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250

${SET_PROFILE5}   ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5

${deactive_P5}   ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=5

${PROFILE678}	ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250

${SET_PROFILE678}	ue_testmode_set_nr id\=6,7,8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6

${deactive_P678}	ue_testmode_set_nr id\=6,7,8 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=6

*** Test Cases ***
# from D2_Case30
CB010944-B_B3_3_Verify_load_generation_iwk_with_CB008247_and_5GC002200
	Get and Update BSR File		par_of_bsr_name=BSR_AVQC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
	Prepare gnb onair
	Check Gain
	online change emfAzimuth
	Reset cell    50    gnb


*** Keywords ***
Check Gain
    ute_admin_infomodel.setup_infomodel
    ute_admin_infomodel.connect_infomodel
    &{emf1}=    ute_admin_infomodel.get_infomodel_object      //NRBEAM_EMF_A-1
    @{fx}=    Split String    ${emf1}[gainConfDirection]    ,
    @{max}=    Split String    ${emf1}[maxGainAndDirection]    ,
    @{min}=    Split String    ${emf1}[minGainAndDirection]    ,
    @{tmp1}=    Split String    ${max}[0]    :
    ${tmp2}=    Remove String     ${tmp1}[1]    [
    ${maxgain}=    Remove String     ${tmp2}     dBi]
    @{tmp3}=    Split String    ${min}[0]    :
    ${tmp4}=    Remove String     ${tmp3}[1]    [
    ${mingain}=    Remove String     ${tmp4}     dBi]
    ${gaindiff}=    Evaluate     ${maxgain}-${mingain}
    should be true    ${gaindiff}<10
    ute_admin_infomodel.disconnect_infomodel
    ute_admin_infomodel.teardown_infomodel

online change emfAzimuth
    Log To Console    online change emfAzimuth...
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=emfAzimuth
    ...    operation=update    value=-70    skip_parameter_relation_errors=True    should_activate=True    connection=online
    TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=emfElevation
    ...    operation=update    value=7    skip_parameter_relation_errors=True    should_activate=True    connection=online
    TAF_ADMIN.teardown admin    connection=online
    Wait '50s' for stabible

lock cell
    [Arguments]    ${phy_cell_id}    ${alias}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.administrativeState}'=='Unlocked'    Run Keywords
        ...    TAF_ADMIN.block    ${nrcel.id}    timeout=60    connection=${alias}
        ...    AND    sleep    60
    END
    TAF_ADMIN.teardown    connection=${alias}

Unblock cell
    [Arguments]    ${phy_cell_id}    ${alias}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}'    Run Keywords    TAF_ADMIN.unblock    ${nrcel.id}    timeout=60
        ...    connection=${alias}
        ...    AND    sleep    60
    END
    TAF_ADMIN.teardown    connection=${alias}

Reset cell
    [Arguments]    ${phy_cell_id}    ${alias}
    Log To Console    Fack cell reset...if fail report F U C K pr
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${onair1}=    TAF_ADMIN.Get Bts Statuses    timeout=30    connection=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}'    Run Keywords    TAF_ADMIN.reset_cell    ${nrcel.id}    timeout=60
        ...    connection=${alias}
        ...    AND    sleep    200
    END
    ${onair2}=    TAF_ADMIN.Get Bts Statuses    timeout=30    connection=${alias}
    TAF_ADMIN.teardown    connection=${alias}
    should be equal    ${onair1}    ${onair2}

RD_G14
	Add GNB swconfig   	0x58053e:1		# rdIncludeHighVolatileUe, default=false
	Add GNB swconfig	0x58077a:1		# rdIncludeSrsVolatilityStatusMetric	# NIDD:enableSbSrsVolatilityCheck
	#Add GNB swconfig	0x580717:0		# rdPdcchApplyToSeparateStreams, default=true,attach issue WA

	Add GNB swconfig    0x58076a:1		# rdNumWbSrsMeas, default=5;
	#The minimum number of correlation metric before correlation is used for measure radio link variety,set to 1 ,corrAvg=current average.
	Add GNB swconfig 	0x58077b:1		# rdNumSbSrsCorrCal, default=5
	#Add GNB swconfig 	0x5805b6:400	#rdSrsToL3Timer, default=500 slot

online_change_CorrThd
	Execute Aashell Command    rad -mw 0x58077c 80		#rdSbSrsVolatCorrThreshold,default=0.8
	Execute Aashell Command    rad -mw 0x58077d 90		#rdWbSrsVolatCorrThreshold,default=0.9
online_change_CorrThd_1
	Execute Aashell Command    rad -mw 0x58077c 80
	Execute Aashell Command    rad -mw 0x58077d 100
online_change_CorrThd_2
	Execute Aashell Command    rad -mw 0x58077c 100
	Execute Aashell Command    rad -mw 0x58077d 90
#==US3=============1UE=========rdSbSrsVolatCorrThreshold===rdWbSrsVolatCorrThreshold
test_rdWbSrsVolatCorrThreshold_100
	online_change_CorrThd_1
	Start capture gnb and ap syslog in 'test_rdWBthd100' file

	Start collect ttitrace
	SA Register UE '5'
	Airphone Execute Egate Command    ${PROFILE5_31}
	Airphone Execute Egate Command    ${SET_PROFILE5}
	DL and UL data to '5' for dl_trf '1'
	Wait '2s' for stabible
	Airphone Execute Egate Command    trf_data_stop ue\=5 pdu\=5 dir\=dl trf_id\=1
	Wait '2s' for stabible
	airphone_sa_detach    ue_id=5    timeout=5
	Wait for '0s' to stop ttitrace with name'tti_SB_WB_SB_rdWB100'

	Stop capture gnb and ap syslog in 'test_rdWBthd100' file

	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_SB_WB_SB_rdWB100_dl.csv

	Set test Variable    ${tti_title_tag}		tti_SB_WB_SB_rdWB100_dl_split.csv
    run keyword and continue on failure     check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tti_G14_rdWB_100.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

test_rdSbSrsVolatCorrThreshold_100
	online_change_CorrThd_2
	Start capture gnb and ap syslog in 'test_rdSBthd100' file

	Start collect ttitrace
	SA Register UE '5'
	Airphone Execute Egate Command    ${PROFILE5_31}
	Airphone Execute Egate Command    ${SET_PROFILE5}
	DL and UL data to '5' for dl_trf '1'
	Wait '2s' for stabible
	Airphone Execute Egate Command    trf_data_stop ue\=5 pdu\=5 dir\=dl trf_id\=1
	Wait '2s' for stabible
	DL and UL data to '5' for dl_trf '1'
	Wait '2s' for stabible
	airphone_sa_detach    ue_id=5    timeout=5
	Wait for '0s' to stop ttitrace with name'tti_SB_WB_SB_WB_rdSB100'

	Stop capture gnb and ap syslog in 'test_rdSBthd100' file

	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_SB_WB_SB_WB_rdSB100_dl.csv

	Set test Variable    ${tti_title_tag}		tti_SB_WB_SB_WB_rdSB100_dl_split.csv
    run keyword and continue on failure     check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tti_G14_rdSB_100.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

#==US2=============2 UE=========t2r4=================
test_2UE_for_highVolatile_lowest_priority
	Log To Console   ${\n}----US2: test_2UE_for_highVolatile_lowest_priority-----
	Start capture gnb and ap syslog in 'G14_case1_US2' file
	airphone_cleanup_egate_console_log

	SA Register UE '5'
	Airphone Execute Egate Command    ${PROFILE5_31}
	Airphone Execute Egate Command    ${SET_PROFILE5}
	SA Register UE '6'
	##SA Register UE '7'
	Airphone Execute Egate Command    ${PROFILE678}
	Airphone Execute Egate Command    ${SET_PROFILE678}

	RANK'0'_CQI'15'_override_to_UE'5'_profile'5'
	RANK'0'_CQI'9'_override_to_UE'6,7'_profile'6'

	DL and UL data to '5' for dl_trf '1'
	DL and UL data to '6' for dl_trf '1'
	##DL and UL data to '7' for dl_trf '1'

	Start collect ttitrace
	RANK'3'_CQI'15'_override_to_UE'5'_profile'5'
	RANK'3'_CQI'9'_override_to_UE'6,7'_profile'6'
	FOR    ${i}    IN RANGE    1    100
		Airphone Execute Egate Command    ${PROFILE5_13}
		Airphone Execute Egate Command    ${PROFILE5_31}
    END
	Wait for '0s' to stop ttitrace with name'tti_G14_case1_US2'

	get_egate_log_UE'G14_case1_US2'
	Stop capture gnb and ap syslog in 'G14_case1_US2' file
	run keyword and continue on failure    Wait Until Keyword Succeeds    20s    2s   check throughput from SA UE '5' to '6' with tp '120'

	DeRegister UE from '5' to '6'
	RANK'3'_CQI'15'_override_to_UE'5,6,7'_profile'1'

	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_G14_case1_US2_dl.csv

	run keyword and continue on failure		check_G14_rdIncludeHighVolatileUe_true_multiple_UE
	...   ${TEST_LOG_DIRECTORY()}/All/syslog_G14_case1_US2/G14_case1_US2_gnb.tar.gz
    ...   ${TEST_LOG_DIRECTORY()}/All/tti_G14_case1_US2_dl_split.csv
    ...   numUE=2	maxNumUeSrs=1	numWbSrsConfigSample=5	rlqGoodPercentage=100	prbSampleHighLowPercentage=60

#=======US1========single UE===================
test_SA_UE5_t2r4
	Log To Console   ${\n}-----US1---single UE-----
	Start capture gnb and ap syslog in 'UE5_US1_case1' file
	airphone_cleanup_egate_console_log

	SA Register UE '5'
	Airphone Execute Egate Command    ${PROFILE5_31}
	Airphone Execute Egate Command    ${SET_PROFILE5}

	RANK'0'_CQI'15'_override_to_UE'5'_profile'5'

	DL and UL data to '5' for dl_trf '2'	# 2x165M

	Start collect ttitrace
	FOR    ${i}    IN RANGE    1    100
		Airphone Execute Egate Command    ${PROFILE5_31}
		Airphone Execute Egate Command    ${PROFILE5_13}
		Run Keyword If   ${i}==1 	RANK'3'_CQI'15'_override_to_UE'5'_profile'5'
    END
	Wait for '0s' to stop ttitrace with name'G14_case1_tti_UE5_to_WB'

	get_egate_log_UE'tti_UE5_to_WB'
	Stop capture gnb and ap syslog in 'UE5_US1_case1' file
	run keyword and continue on failure    Wait Until Keyword Succeeds    20s    2s   check throughput from SA UE '5' to '5' with tp '120'

	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/G14_case1_tti_UE5_to_WB_dl.csv

	DeRegister UE from '5' to '5'
	deactive p5

	run keyword and continue on failure    check_G14_rdIncludeHighVolatileUe_single_UE
	...   ${TEST_LOG_DIRECTORY()}/All/syslog_UE5_US1_case1/UE5_US1_case1_gnb.tar.gz
    ...   ${TEST_LOG_DIRECTORY()}/All/G14_case1_tti_UE5_to_WB_dl_split.csv
    ...   rdIncludeHighVolatileUe=1   numWbSrsConfigSample=5
    ...   rlqGoodPercentage=100   prbSampleHighLowPercentage=60

Set UE5 P5
	Airphone Execute Egate Command    ${PROFILE5}
	Airphone Execute Egate Command    ${SET_PROFILE5}
Set UE5 power_bad
	Airphone Execute Egate Command    ${PROFILE5_power_bad}
	Airphone Execute Egate Command    ${SET_PROFILE5}
Set UE5 power_good
	Airphone Execute Egate Command    ${PROFILE5}
	#Airphone Execute Egate Command    ${SET_PROFILE5}
deactive p5
	Airphone Execute Egate Command    ${deactive_P5}
#===================end=====t2r4=================================
RANK1_4UE
	Airphone Execute Egate Command	csi_override_testmode_nr profile_id\=4 cqi\=${cqi} cqi_mode\=fixed ri\=${rank} ri_mode\=fixed
	Airphone Execute Egate Command	ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=${ue_id} scell\=${scell}

RANK'${rank}'_CQI'${cqi}'_override_to_UE'${ue_id}'_profile'${profileId}'
	Run Keyword If   ${ue_id}>10   Set test Variable    ${scell}	  8
	Run Keyword If   ${ue_id}<11   Set test Variable    ${scell}	  0
	Airphone Execute Egate Command	csi_override_testmode_nr profile_id\=${profileId} cqi\=${cqi} cqi_mode\=fixed ri\=${rank} ri_mode\=fixed
	Airphone Execute Egate Command	ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=${profileId} scell\=${scell}

deactive_rank_overide_UE'${ue_id}'_profile'${profileId}'
	Run Keyword If   ${ue_id}>10   Set test Variable    ${scell}	  8
	Run Keyword If   ${ue_id}<11   Set test Variable    ${scell}	  0
	Airphone Execute Egate Command	ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=deactivate profile_id\=${profileId} scell\=${scell}

delete_Rank_override_UE'${ue_id}'
	Airphone Execute Egate Command	csi_override_testmode_nr profile_id\=${ue_id} delete\=true



get_egate_log_UE'${ue_id}'
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE

get_bip_UE'${bip_tag}'
	Start collect bip log
	Wait for '1s' to stop bip log with name'${bip_tag}'

	Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/${bip_tag}_0.csv    ${filter_csv}    ${title_comb4}

	Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap1
	...    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/${bip_tag}_1.csv    ${filter_csv}    ${title_comb4}

get_tti_UE'${ue_id}'
	Start collect ttitrace
	Wait for '2s' to stop ttitrace with name'tti_${ue_id}'
	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_${ue_id}_dl.csv
#==========SA=======================
SA Register UE '${UE_ID}'
	Log To Console   ${\n}-----register UE ${UE_ID} ------
	Airphone SA Attach    ue_id=${UE_ID}
	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
	Wait '2s' for stabible

SA Register UE from ${lo} to ${hi}
	FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
	#\	airphone_cleanup_egate_console_log
     	Log To Console   ${\n}-----register UE ${ue} ------
     	SA Register UE ${ue}
     #\	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}   unzip=TRUE
	END

DL and UL data to '${UE_ID}' for dl_trf '${num}'
    FOR    ${i}    IN RANGE    1    ${num}+1
    	Airphone SA Start Data Traffic    ${UE_ID}   DL   60M   pdu_id=${UE_ID}   duration=3600   trf_id=${i}
    END
    Airphone SA Start Data Traffic    ${UE_ID}   UL   1M    pdu_id=${UE_ID}   duration=3600   trf_id=1
    #Wait '2s' for stabible

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


