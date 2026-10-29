*** Settings ***
Test Timeout    60 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}   SCF_6cell_AEQY_8D4U_8x4_1208_MP_LOOO_case2_set3_p40slot.xml
${AIRPHONE_NAME}    iphy_AEQY_6cell_8D4U.xml
${WTS_NAME}    basic_setup_6cell_actdlsrsbm.cfg
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog

${filter_csv}	(dldata_csirssendreq||dldata_pdschsendreq) && !(3gpp.rnti == 65535) 
@{title_12269}   3gpp.sfn   3gpp.slot   3gpp.rnti
...   DlData_CsiRsSendReq_t.csiRsResources.Length	DlData_CsiRsResource_t.csiRsConfig	  DlData_CsiRsResource_t.startSymbol
...   DlData_CsiRsResource_t.density	DlData_CsiRsResource_t.trsInfo   DlData_CsiRsResource_t.csiRsScramblingSequenceInt
...   DlData_CsiRsResource_t.startPrb   DlData_CsiRsResource_t.numOfPrb   DlData_CsiRsResource_t.patternId_item
...   3gpp.dmrsScramblingSequenceInt	DlData_PdschGrant.startSymbol	DlData_PdschGrant.numOfPdschSymbols
...   DlData_PdschGrant.numOfPrb

*** Test Cases ***
CB012269_A1_B2_case2_Subband_TRS_and_Cell_CSI-RS_allocation_frame_structure_1208_CSI-RS_set3_40
	Add RD param
	Prepare gnb onair
	print_all_cell_specific_and_csiIM_slot
	get_phscellId_'${TEST_LOG_DIRECTORY()}/All/syslog_before_onair/before_onair_gnb.tar.gz'
	## get_phscellId_'${CURDIR}/before_onair_gnb.tar.gz'
	
	test_L1pool_10
	test_NSA_L1pool_10

*** Keywords ***
Add RD param
	#Add GNB swconfig	 0x58012b:1		#rd1116Shift3msForCanadaBell
	Add GNB swconfig	 0x1003F:1		#AaSysLogInputLevel=debug

test_L1pool_10
	Change UE'1,2,3' to cell'${l1pool_10_csiGroup0_cell}'
	Change UE'4,5,6' to cell'${l1pool_10_csiGroup1_cell}'
	Change UE'7,8,9' to cell'${l1pool_10_csiGroup2_cell}'
	
	Start capture gnb and ap syslog in 'case1_L1pool_10' file
	
	UE from '1' to '9' SA Register and check
	
	run keyword and continue on failure   Wait Until Keyword Succeeds   90s   2s   check throughput from UE '1' to '9' with tp '1000'
	
	Set test Variable	${tti_tag}    tti_case1_L1pool_10
	get_and_check_tti'${tti_tag}'
	check_tti_muting_'False'_'${tti_tag}'								  
	
	get_and_check_bip_L1pool_10_p40
	
	DeRegister UE from '1' to '9'

	run keyword and continue on failure    Stop capture gnb and ap syslog in 'case1_L1pool_10' file

get_and_check_bip_L1pool_10_p40
	Set test Variable	${BIP_tag}    BIP_case1_L1pool_10
	Start collect bip log
	Wait for '1s' to stop bip log with name'${BIP_tag}'
	
	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv    ${filter_csv}    ${title_12269}
	
	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_10_csiGroup0_physcell}   csirs_set3_period=40   set_3_slot=25   set_2_slot=36   set_1_slot=116
    
	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_10_csiGroup1_physcell}   csirs_set3_period=40   set_3_slot=26   set_2_slot=76   set_1_slot=156
    
	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_10_csiGroup2_physcell}   csirs_set3_period=40   set_3_slot=27   set_2_slot=117   set_1_slot=37
    
	run keyword and continue on failure   check_12269_TRS_nonTRS_diff_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   csirs_set3_period=40
	
	## check_12269_subTRS_same_slot_in_same_L1Pool(bip_csv, *physcell_in_this_L1pool)
	
	run keyword and continue on failure   check_12269_subTRS_same_slot_in_same_L1Pool   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   ${l1pool_10_csiGroup0_physcell}   ${l1pool_10_csiGroup1_physcell}	  ${l1pool_10_csiGroup2_physcell}
	
	## check_12269_subTRS_diff_RB_allocation_for_cells(bip_csv, numRB_TRS, *startRB)
	
	run keyword and continue on failure   check_12269_subTRS_diff_RB_allocation_for_cells   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   52   0   0	80	 80   160	160
	
	run keyword and continue on failure   check_TRS_slot_allocation   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   csirsTrackingPeriod_ms=80   frame_structure=semi_static_14
	
	run keyword and continue on failure   check_TRS_slot_with_pdsch   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   TRS_slot_pdsch=False

test_NSA_L1pool_10
	Change UE'11,12,13' to cell'${l1pool_10_csiGroup0_cell}'
	Change UE'14,15,16' to cell'${l1pool_10_csiGroup1_cell}'
	Change UE'17,18,19' to cell'${l1pool_10_csiGroup2_cell}'
	NSA_UE'11'_attach_to_cell'${l1pool_10_csiGroup0_cell}'
	NSA_UE'12'_attach_to_cell'${l1pool_10_csiGroup0_cell}'
	NSA_UE'13'_attach_to_cell'${l1pool_10_csiGroup0_cell}'
	NSA_UE'14'_attach_to_cell'${l1pool_10_csiGroup1_cell}'
	NSA_UE'15'_attach_to_cell'${l1pool_10_csiGroup1_cell}'
	NSA_UE'16'_attach_to_cell'${l1pool_10_csiGroup1_cell}'
	NSA_UE'17'_attach_to_cell'${l1pool_10_csiGroup2_cell}'
	NSA_UE'18'_attach_to_cell'${l1pool_10_csiGroup2_cell}'
	NSA_UE'19'_attach_to_cell'${l1pool_10_csiGroup2_cell}'
	run keyword and continue on failure   Wait Until Keyword Succeeds   90s   2s   check throughput from NSA UE '11' to '19' with tp '1000'
	get_and_check_tti'tti_case1_L1pool_10_NSA'
	get_and_check_bip_L1pool_10_NSA
	Dettach UE from '11' to '19'

get_and_check_bip_L1pool_10_NSA
	Set test Variable	${BIP_tag}    BIP_case1_L1pool_10_NSA
	Start collect bip log
	Wait for '1s' to stop bip log with name'${BIP_tag}'
	
	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv    ${filter_csv}    ${title_12269}
	
	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_10_csiGroup0_physcell}   csirs_set3_period=40   set_3_slot=25   set_2_slot=36   set_1_slot=116
    
	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_10_csiGroup1_physcell}   csirs_set3_period=40   set_3_slot=26   set_2_slot=76   set_1_slot=156
    
	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_10_csiGroup2_physcell}   csirs_set3_period=40   set_3_slot=27   set_2_slot=117   set_1_slot=37

	run keyword and continue on failure   check_12269_TRS_nonTRS_diff_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   csirs_set3_period=40
	
	## check_12269_subTRS_same_slot_in_same_L1Pool(bip_csv, *physcell_in_this_L1pool)
	
	run keyword and continue on failure   check_12269_subTRS_same_slot_in_same_L1Pool   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   ${l1pool_10_csiGroup0_physcell}   ${l1pool_10_csiGroup1_physcell}	 ${l1pool_10_csiGroup2_physcell}
	
	## check_12269_subTRS_diff_RB_allocation_for_cells(bip_csv, numRB_TRS, *startRB)
	
	run keyword and continue on failure   check_12269_subTRS_diff_RB_allocation_for_cells   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   52   0   0	80	 80   160	160

get_and_check_tti'${tti_tag}'
	# Set test Variable	  ${tti_tag}    tti_case1
	Start collect ttitrace
	Wait for '2s' to stop ttitrace with name'${tti_tag}'
	
	Set test Variable	${ratio}	1
	Set test Variable	${tti_title_tag}	${tti_tag}_dl.csv
	run keyword and continue on failure     check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tti_dl_bler_ratio.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

UE from '${lo}' to '${hi}' SA Register and check 
    FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
    #   airphone_cleanup_egate_console_log
       Log To Console   ${\n}--register UE ${num} --
       Airphone SA Attach    ue_id=${num}
       #set_pdu_param ue=1 pdu=1 trf_type=internal
       #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
       Airphone Set Traffic Type    ${num}    ${num}    internal
       Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
       Wait '3s' for stabible
       send data to '${num}'
    #   Wait '3s' for stabible
    #   get UE '${num}' rnti in RRC log
	END
    
send data to '${UE_ID}'  
    #Airphone SA Start Data Traffic    ${UE_ID}    UL   5M   pdu_id=${UE_ID}   duration=7200   trf_id=1

    FOR    ${num}    IN RANGE    1    3
    	Airphone SA Start Data Traffic    ${UE_ID}    DL   160M   pdu_id=${UE_ID}   duration=7200   trf_id=${num}
    END
    Wait '4s' for stabible
	
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
	
UE from '${lo}' to '${hi}' NSA Attach and check
	FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
	    Log To Console   ${\n}--Attach NSA UE ${num} --
	   airphone_cleanup_egate_console_log
		Airphone Nsa Attach     ${num}    profile_id=None
		Wait '2s' for stabible
		run keyword if   (${num}==15)|(${num}==16) 	 NSA send ue '${num}' mutiple trf '1' for each '70M' UL data
		run keyword if   (${num}==17)|(${num}==18) 	 NSA send ue '${num}' mutiple trf '1' for each '140M' UL data
		Wait '2s' for stabible
		${pcell_tp}	Get cell ul throught	${num}    8
		${ul_tput_Mb}    evaluate    ${pcell_tp}/1000
		Log To Console    UE${num}_ul_tp ${ul_tput_Mb}M--
    END

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

get_phscellId_'${before_onair_path}'
	get_12269_l1pool_info_from_sys   ${before_onair_path}
	
	${tmp1}   get_12269_cellId	${before_onair_path}	L1pool_ID_index=0	csirsPoolingGroup_ID=0
	${tmp2}   get_12269_cellId	${before_onair_path}	L1pool_ID_index=0	csirsPoolingGroup_ID=1
	${tmp3}   get_12269_cellId	${before_onair_path}	L1pool_ID_index=0	csirsPoolingGroup_ID=2
	${tmp4}   get_12269_cellId	${before_onair_path}	L1pool_ID_index=1	csirsPoolingGroup_ID=0
	${tmp5}   get_12269_cellId	${before_onair_path}	L1pool_ID_index=1	csirsPoolingGroup_ID=1
	${tmp6}   get_12269_cellId	${before_onair_path}	L1pool_ID_index=1	csirsPoolingGroup_ID=2
	
	Set Global Variable   ${l1pool_10_csiGroup0_physcell}	 ${tmp1}
	Set Global Variable   ${l1pool_10_csiGroup1_physcell}	 ${tmp2}
	Set Global Variable   ${l1pool_10_csiGroup2_physcell}	 ${tmp3}
	Set Global Variable   ${l1pool_13_csiGroup0_physcell}	 ${tmp4}
	Set Global Variable   ${l1pool_13_csiGroup1_physcell}	 ${tmp5}
	Set Global Variable   ${l1pool_13_csiGroup2_physcell}	 ${tmp6}
	
	${tmp1}	 evaluate   ${l1pool_10_csiGroup0_physcell}-49
	${tmp2}	 evaluate   ${l1pool_10_csiGroup1_physcell}-49
	${tmp3}	 evaluate   ${l1pool_10_csiGroup2_physcell}-49
	${tmp4}	 evaluate   ${l1pool_13_csiGroup0_physcell}-49
	${tmp5}	 evaluate   ${l1pool_13_csiGroup1_physcell}-49
	${tmp6}	 evaluate   ${l1pool_13_csiGroup2_physcell}-49
	
	Set Global Variable   ${l1pool_10_csiGroup0_cell}	${tmp1}
	Set Global Variable   ${l1pool_10_csiGroup1_cell}	${tmp2}
	Set Global Variable   ${l1pool_10_csiGroup2_cell}	${tmp3}
	Set Global Variable   ${l1pool_13_csiGroup0_cell}	${tmp4}
	Set Global Variable   ${l1pool_13_csiGroup1_cell}	${tmp5}
	Set Global Variable   ${l1pool_13_csiGroup2_cell}	${tmp6}
	
	Log To Console   ${\n}
	Log To Console   --- l1pool_10_csiGroup0_physcell: ${l1pool_10_csiGroup0_physcell} - cell ${l1pool_10_csiGroup0_cell}
	Log To Console   --- l1pool_10_csiGroup1_physcell: ${l1pool_10_csiGroup1_physcell} - cell ${l1pool_10_csiGroup1_cell}
	Log To Console   --- l1pool_10_csiGroup2_physcell: ${l1pool_10_csiGroup2_physcell} - cell ${l1pool_10_csiGroup2_cell}
	Log To Console   --- l1pool_13_csiGroup0_physcell: ${l1pool_13_csiGroup0_physcell} - cell ${l1pool_13_csiGroup0_cell}
	Log To Console   --- l1pool_13_csiGroup1_physcell: ${l1pool_13_csiGroup1_physcell} - cell ${l1pool_13_csiGroup1_cell}
	Log To Console   --- l1pool_13_csiGroup2_physcell: ${l1pool_13_csiGroup2_physcell} - cell ${l1pool_13_csiGroup2_cell}

check_tti_muting_'${True_False}'_'${tti_tag}'
	run keyword and continue on failure   check_csirsMuting_tti   ${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
	...   pdsch_muting_physcell_Id=${l1pool_10_csiGroup0_physcell}   csi_other_csirsGroup_physcell=${l1pool_10_csiGroup1_physcell}
	...   csirsMuting=${True_False}
	
	run keyword and continue on failure   check_csirsMuting_tti   ${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
	...   pdsch_muting_physcell_Id=${l1pool_10_csiGroup0_physcell}   csi_other_csirsGroup_physcell=${l1pool_10_csiGroup2_physcell}
	...   csirsMuting=${True_False}
	
	run keyword and continue on failure   check_csirsMuting_tti   ${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
	...   pdsch_muting_physcell_Id=${l1pool_10_csiGroup1_physcell}   csi_other_csirsGroup_physcell=${l1pool_10_csiGroup0_physcell}
	...   csirsMuting=${True_False}
	
	run keyword and continue on failure   check_csirsMuting_tti   ${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
	...   pdsch_muting_physcell_Id=${l1pool_10_csiGroup1_physcell}   csi_other_csirsGroup_physcell=${l1pool_10_csiGroup2_physcell}
	...   csirsMuting=${True_False}
	
	run keyword and continue on failure   check_csirsMuting_tti   ${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
	...   pdsch_muting_physcell_Id=${l1pool_10_csiGroup2_physcell}   csi_other_csirsGroup_physcell=${l1pool_10_csiGroup0_physcell}
	...   csirsMuting=${True_False}
	
	run keyword and continue on failure   check_csirsMuting_tti   ${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
	...   pdsch_muting_physcell_Id=${l1pool_10_csiGroup2_physcell}   csi_other_csirsGroup_physcell=${l1pool_10_csiGroup1_physcell}
	...   csirsMuting=${True_False}
