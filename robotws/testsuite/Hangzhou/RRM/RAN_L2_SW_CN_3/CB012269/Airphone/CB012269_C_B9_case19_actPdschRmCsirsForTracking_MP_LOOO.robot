*** Settings ***
Test Timeout    120 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
#owner_zhang	CLOUD_5G_I_MP_AP_LOOO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}   SCF_C_B9_5GC002538_actPdschRmCsirsForTracking_case19.xml
${AIRPHONE_NAME}    iphy_AEQY_6cell_8D4U.xml
${WTS_NAME}    basic_setup_6cell_actdlsrsbm_Canada_case1.cfg
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog

${HO_to_cell_52}     ue_measurement_send_nr id\=1-3 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=52 nrsrp_nr\=30 nrsrq_nr\=30
${HO_to_cell_50}     ue_measurement_send_nr id\=1-3 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=50 nrsrp_nr\=50 nrsrq_nr\=50

${filter_csv}	(dldata_csirssendreq||dldata_pdschsendreq||dldata_ssblocksendreq) && !(3gpp.rnti == 65535)
@{title_12269}   3gpp.sfn   3gpp.slot   3gpp.rnti
...   DlData_CsiRsSendReq_t.csiRsResources.Length	DlData_CsiRsResource_t.csiRsConfig	  DlData_CsiRsResource_t.startSymbol
...   DlData_CsiRsResource_t.density	DlData_CsiRsResource_t.trsInfo   DlData_CsiRsResource_t.csiRsScramblingSequenceInt
...   DlData_CsiRsResource_t.startPrb   DlData_CsiRsResource_t.numOfPrb
...   3gpp.dmrsScramblingSequenceInt	DlData_PdschGrant.startSymbol	DlData_PdschGrant.numOfPdschSymbols
...   DlData_PdschGrant.numOfPrb   DlData_PdschGrant.rateMatchingOption   DlData_PdschGrant.symbolRateMatchingPositions
*** Test Cases ***
CB012269_C_B9_case19_IWK_5GC002538
	Add RD param
	Prepare gnb onair
	print_all_cell_specific_and_csiIM_slot
	get_phscellId_'${TEST_LOG_DIRECTORY()}/All/syslog_before_onair/before_onair_gnb.tar.gz'
	## get_phscellId_'${CURDIR}/before_onair_gnb.tar.gz'
	
	Change UE'1' to cell'1'		#RS4
	Change UE'2' to cell'2'		#RS2
	Change UE'3' to cell'3'		#RS1
	Start capture gnb and ap syslog in 'case19' file
	UE from '1' to '3' SA Register and check
	
	run keyword and continue on failure   
	...   Wait Until Keyword Succeeds    60s    2s   check throughput from UE '1' to '3' with tp '900'
	
	get_and_check_bip_case19
	get_and_check_tti'tti_C9'
	
	DeRegister UE from '1' to '3'
	run keyword and continue on failure    Stop capture gnb and ap syslog in 'case19' file

*** Keywords ***
Add RD param
	Add GNB swconfig	 0x58012b:1		#rd1116Shift3msForCanadaBell
	##Add GNB swconfig	 0x580911:1		# rdDynamicScheduling=true(default=false)
	##Add GNB swconfig	 0x580912:1600	# rdspectralEfficiencyThd(default=1600,0-5000)(0-50)x100
	
get_and_check_bip_case19
	Set test Variable	${BIP_tag}    BIP_C9
	Start collect bip log
	Wait for '2s' to stop bip log with name'${BIP_tag}'
	
	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv    ${filter_csv}    ${title_12269}
	
	run keyword and continue on failure   check_TRS_slot_allocation   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   csirsTrackingPeriod_ms=40   frame_structure=tdlte_3ms_Canada
	
## cell1:PDSCH could be scheduled on TRS symbols for the ZAB cells which follow the legacy algorithm in 5GC002538.pdsch in ssb slot.
	
	run keyword and continue on failure   check_bip_12269_TRS_ratematch   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcellId=50   actPdschRmCsirsForTracking=True   actPdschAtSsbSlots=True   actSubTrsRateMatch=False
	
## cell2:PDSCH could NOT be scheduled on all of DL symbols in TRS slots for the ZAB cells which follow 5GC002538.pdsch not in ssb slot.
	
	run keyword and continue on failure   check_bip_12269_TRS_ratematch   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcellId=51   actPdschRmCsirsForTracking=False   actPdschAtSsbSlots=False   actSubTrsRateMatch=False
	
## cell3:PDSCH shall be scheduled on non-TRS symbols in subTRS slot, pdsch in ssb slot.
	
	run keyword and continue on failure   check_bip_12269_TRS_ratematch   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcellId=52   actPdschRmCsirsForTracking=False   actPdschAtSsbSlots=True   actSubTrsRateMatch=True

US_HO_triggger_DCI_10
	#Start capture gnb and ap syslog in 'case9_HO' file
	Change UE'1,2,3' to cell'${l1pool_0_csiGroup0_cell}'
	UE from '1' to '3' SA Register and check
	
	get_and_check_tti_HO
	
	#Set test Variable	${BIP_tag}    BIP_case9_UE1
	#Start collect bip log
	#Wait for '1s' to stop bip log with name'${BIP_tag}'
	
	DeRegister UE from '1' to '3'
	#run keyword and continue on failure    Stop capture gnb and ap syslog in 'case9_HO' file
	
get_and_check_tti_HO
	Set test Variable	${tti_tag}    tti_case9_HO
	Start collect ttitrace
	airphone_execute_egate_command   ${HO_to_cell_52}
	Wait '2s' for stabible
	airphone_execute_egate_command   ${HO_to_cell_50}
	Wait '2s' for stabible
	airphone_execute_egate_command   ${HO_to_cell_52}
	Wait for '1s' to stop ttitrace with name'${tti_tag}'
	
	Set test Variable	${ratio}	0.98
	Set test Variable	${tti_title_tag}	${tti_tag}_dl.csv
	run keyword and continue on failure     check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tti_dl_bler_ratio.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
	
	run keyword and continue on failure   
	...   check_tti_DCI_10_not_in_TRS_slot   ${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv   20	21	22	23   csirsTrackingPeriod_ms=80
	
	run keyword and continue on failure   reorder_csv_CB012269   ${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv

get_and_check_tti'${tti_tag}'
	# Set test Variable	${tti_tag}    tti_case9
	Start collect ttitrace
	Wait for '2s' to stop ttitrace with name'${tti_tag}'
	
	Set test Variable	${ratio}	1
	Set test Variable	${tti_title_tag}	${tti_tag}_dl.csv
	run keyword and continue on failure     check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tti_dl_bler_ratio.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
	
	run keyword and continue on failure   reorder_csv_CB012269   ${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv

UE from '${lo}' to '${hi}' SA Register and check 
    FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
    #   airphone_cleanup_egate_console_log
       Log To Console   ${\n}--register UE ${num} --
       Airphone SA Attach    ue_id=${num}
	   Wait '2s' for stabible
       #set_pdu_param ue=1 pdu=1 trf_type=internal
       #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
       Airphone Set Traffic Type    ${num}    ${num}    internal
       Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
       Wait '3s' for stabible
       UL data to '${num}'
    #   Wait '3s' for stabible
    #   get UE '${num}' rnti in RRC log
	END
    
UL data to '${UE_ID}'  
    Airphone SA Start Data Traffic    ${UE_ID}    UL   5M   pdu_id=${UE_ID}   duration=7200   trf_id=1
	
    FOR    ${num}    IN RANGE    1    3
    	Airphone SA Start Data Traffic    ${UE_ID}    DL   160M   pdu_id=${UE_ID}   duration=7200   trf_id=${num}
    END

    Wait '3s' for stabible
	
	${ul_tput_kb}=    Wait Until Keyword Succeeds    10s    1s   
	...		airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pusch    tput_type=ave 
		
	${dl_tput_kb}=    Wait Until Keyword Succeeds    10s    1s   
	...		airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pdsch    tput_type=ave 
	
	${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
	${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
	Log To Console		UE${UE_ID}_dl ${dl_tput_Mb}
	Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}

#check throughput
check throughput from UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
	Wait '3s' for stabible
	${cell_tp_dl}	  evaluate	0
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
       Log To Console    Check throughput UE${num}
          ${dl_tput_kb}=    Wait Until Keyword Succeeds    10s    1s   
	...		airphone_get_throughput_on_specific_scell    ${num}    0    type=pdsch    tput_type=ave
          ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
          Log To Console		dl ${dl_tput_Mb}  
          ${cell_tp_dl}    evaluate    ${cell_tp_dl}+${dl_tput_Mb}   
	END

    Log To Console		=====dl_cell_tp ${cell_tp_dl}=====
    run keyword and continue on failure    should be true    ${cell_tp_dl}>${dl_cell_tp}

#================NSA attach==========
NSA_UE'${UE_ID}'_attach_to_cell'${cell_ID}'
	Log To Console   ${\n}---NSA_UE'${UE_ID}'_attach_to_cell_'${cell_ID}' ---
	airphone_execute_egate_command   ue_attach id\=${UE_ID}
	Wait '2s' for stabible
	airphone_execute_egate_command   enb_ue_dc_start ue\=${UE_ID} target_gnb\=2 target_cells\=${cell_ID} bearer\=2 type\=split_scg
	Wait '2s' for stabible
	
	FOR    ${num}    IN RANGE    1    3
		airphone_execute_egate_command   trf_data_start ue\=${UE_ID} id\=2 dir\=dl mbps\=150 trf_id\=${num}
    END
	Wait '3s' for stabible
	${pcell_tp}	  Get cell dl throught	 ${UE_ID}    8
	${dl_tput_Mb}    evaluate    ${pcell_tp}/1000
	Log To Console    UE${UE_ID}_dl_tp ${dl_tput_Mb}M--

check throughput from NSA UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
	Wait '3s' for stabible
	${cell_tp_dl}	  evaluate	0
	FOR    ${num}    IN RANGE    ${low}    ${hi}+1
		${pcell_tp}	Get cell dl throught	${num}    8
		${dl_tput_Mb}    evaluate    ${pcell_tp}/1000
		Log To Console    UE${num}_dl_tp ${dl_tput_Mb}M--
	   ${cell_tp_dl}    evaluate    ${cell_tp_dl}+${dl_tput_Mb}
    END
	Log To Console		=====dl_cell_tp ${cell_tp_dl}=====
	run keyword and continue on failure    should be true    ${cell_tp_dl}>${dl_cell_tp}

DeRegister UE from '${low}' to '${hi}'
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
    	Log To Console   ${\n}deRegister UE${num}
       airphone_sa_detach    ue_id=${num}    timeout=5
       Wait '3s' for stabible
    END

Dettach UE from '${low}' to '${hi}'
	FOR    ${num}    IN RANGE    ${low}    ${hi}+1
		Log To Console   ${\n}detach UE${num}
		Airphone NSA Detach    ue_id= ${num}
	   Wait '3s' for stabible
    END

Change UE'${ue_id}' to cell'${cell_id}'
    airphone_execute_egate_command      ue_change_location cell\=${cell_id} id\=${ue_id}
	Wait '2s' for stabible

online change csirsMuting '${csirsMuting}' cell'${cell_id}'
    Log To Console    ${\n}=======online_change_csirsMuting_${csirsMuting} cell${cell_id}========
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}   parameter=actCsiRsMuting
    ...    operation=update    value=${csirsMuting}    skip_parameter_relation_errors=True    should_activate=True    connection=online

    TAF_ADMIN.teardown admin    connection=online
    Wait '10s' for stabible

get_phscellId_'${before_onair_path}'
	get_12269_l1pool_info_from_sys   ${before_onair_path}
	
	${tmp1}   get_12269_cellId	${before_onair_path}	L1pool_ID_index=0	csirsPoolingGroup_ID=0
	${tmp2}   get_12269_cellId	${before_onair_path}	L1pool_ID_index=0	csirsPoolingGroup_ID=1
	${tmp3}   get_12269_cellId	${before_onair_path}	L1pool_ID_index=0	csirsPoolingGroup_ID=2
	${tmp4}   get_12269_cellId	${before_onair_path}	L1pool_ID_index=1	csirsPoolingGroup_ID=0
	${tmp5}   get_12269_cellId	${before_onair_path}	L1pool_ID_index=1	csirsPoolingGroup_ID=1
	${tmp6}   get_12269_cellId	${before_onair_path}	L1pool_ID_index=1	csirsPoolingGroup_ID=2
	
	Set Global Variable   ${l1pool_0_csiGroup0_physcell}	 ${tmp1}
	Set Global Variable   ${l1pool_0_csiGroup1_physcell}	 ${tmp2}
	Set Global Variable   ${l1pool_0_csiGroup2_physcell}	 ${tmp3}
	Set Global Variable   ${l1pool_1_csiGroup0_physcell}	 ${tmp4}
	Set Global Variable   ${l1pool_1_csiGroup1_physcell}	 ${tmp5}
	Set Global Variable   ${l1pool_1_csiGroup2_physcell}	 ${tmp6}
	
	${tmp1}	 evaluate   ${l1pool_0_csiGroup0_physcell}-49
	${tmp2}	 evaluate   ${l1pool_0_csiGroup1_physcell}-49
	${tmp3}	 evaluate   ${l1pool_0_csiGroup2_physcell}-49
	${tmp4}	 evaluate   ${l1pool_1_csiGroup0_physcell}-49
	${tmp5}	 evaluate   ${l1pool_1_csiGroup1_physcell}-49
	${tmp6}	 evaluate   ${l1pool_1_csiGroup2_physcell}-49
	
	Set Global Variable   ${l1pool_0_csiGroup0_cell}	${tmp1}
	Set Global Variable   ${l1pool_0_csiGroup1_cell}	${tmp2}
	Set Global Variable   ${l1pool_0_csiGroup2_cell}	${tmp3}
	Set Global Variable   ${l1pool_1_csiGroup0_cell}	${tmp4}
	Set Global Variable   ${l1pool_1_csiGroup1_cell}	${tmp5}
	Set Global Variable   ${l1pool_1_csiGroup2_cell}	${tmp6}
	
	Log To Console   ${\n}
	Log To Console   --- l1pool_0_csiGroup0_physcell: ${l1pool_0_csiGroup0_physcell} - cell ${l1pool_0_csiGroup0_cell}
	Log To Console   --- l1pool_0_csiGroup1_physcell: ${l1pool_0_csiGroup1_physcell} - cell ${l1pool_0_csiGroup1_cell}
	Log To Console   --- l1pool_0_csiGroup2_physcell: ${l1pool_0_csiGroup2_physcell} - cell ${l1pool_0_csiGroup2_cell}
	Log To Console   --- l1pool_1_csiGroup0_physcell: ${l1pool_1_csiGroup0_physcell} - cell ${l1pool_1_csiGroup0_cell}
	Log To Console   --- l1pool_1_csiGroup1_physcell: ${l1pool_1_csiGroup1_physcell} - cell ${l1pool_1_csiGroup1_cell}
	Log To Console   --- l1pool_1_csiGroup2_physcell: ${l1pool_1_csiGroup2_physcell} - cell ${l1pool_1_csiGroup2_cell}

RANK'${rank}'_CQI'${cqi}'_override_to_UE'${ue_id}'
	Run Keyword If   ${ue_id}>10   Set test Variable    ${scell}	  8
	Run Keyword If   ${ue_id}<11   Set test Variable    ${scell}	  0
	Airphone Execute Egate Command	csi_override_testmode_nr profile_id\=${ue_id} cqi\=${cqi} cqi_mode\=fixed ri\=${rank} ri_mode\=fixed
	Airphone Execute Egate Command	ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=${ue_id} scell\=${scell}
