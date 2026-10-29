*** Settings ***
Test Timeout    60 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
#owner_zhang	CLOUD_5G_I_LO_AP_LOOO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}   SCF_3cell_8D4U_8x4_AEQY_1116_3ms_Canada_LO_LOOO.xml	
${AIRPHONE_NAME}    iphy_AEQY_3cell_8D4U.xml
${WTS_NAME}    basic_setup_3cell_actdlsrsbm_Canada_case1.cfg
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog

${filter_csv}	(dldata_csirssendreq||dldata_pdschsendreq) && !(3gpp.rnti == 65535) 
@{title_12269}   3gpp.sfn   3gpp.slot   3gpp.rnti
...   DlData_CsiRsSendReq_t.csiRsResources.Length	DlData_CsiRsResource_t.csiRsConfig	  DlData_CsiRsResource_t.startSymbol
...   DlData_CsiRsResource_t.density	DlData_CsiRsResource_t.trsInfo   DlData_CsiRsResource_t.csiRsScramblingSequenceInt
...   DlData_CsiRsResource_t.startPrb   DlData_CsiRsResource_t.numOfPrb   DlData_CsiRsResource_t.patternId_item
...   3gpp.dmrsScramblingSequenceInt	DlData_PdschGrant.startSymbol	DlData_PdschGrant.numOfPdschSymbols
...   DlData_PdschGrant.numOfPrb

*** Test Cases ***
CB012269_A1_B1_case1_Subband_TRS_and_Cell_CSI-RS_allocation_1116_3ms_Canada_CSI-RS_set3_320
	Add RD param
	Prepare gnb onair
	run keyword and continue on failure   get_12269_l1pool_info_from_sys   ${TEST_LOG_DIRECTORY()}/All/syslog_before_onair/before_onair_gnb.tar.gz
	## get_12269_l1pool_info_from_sys	 ${CURDIR}/before_onair_gnb.tar.gz

	Start capture gnb and ap syslog in 'case1' file
	
	UE from '1' to '6' SA Register and check
	
	run keyword and continue on failure   Wait Until Keyword Succeeds   60s   2s   check throughput from UE '1' to '6' with tp '2070'
	
	get_and_check_bip_LO_LOOO
	
	get_and_check_tti
	
	DeRegister UE from '1' to '6'

	run keyword and continue on failure    Stop capture gnb and ap syslog in 'case1' file

*** Keywords ***
Add RD param
	Add GNB swconfig	 0x58012b:1		#rd1116Shift3msForCanadaBell

get_and_check_tti
	Set test Variable	${tti_tag}    tti_case1
	Start collect ttitrace
	Wait for '1s' to stop ttitrace with name'${tti_tag}'
	
	Set test Variable	${ratio}	1
	Set test Variable	${tti_title_tag}	${tti_tag}_dl.csv
	run keyword and continue on failure     check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tti_dl_bler_ratio.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

get_and_check_bip_LO_LOOO
	Set test Variable	${BIP_tag}    BIP_case1
	Start collect bip log
	Wait for '1s' to stop bip log with name'${BIP_tag}'
	
	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv    ${filter_csv}    ${title_12269}
	
	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=50   csirs_set3_period=320   set_3_slot=32   set_2_slot=72   set_1_slot=112
    
	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=51   csirs_set3_period=320   set_3_slot=32   set_2_slot=72   set_1_slot=112
    
	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=52   csirs_set3_period=320   set_3_slot=115   set_2_slot=35   set_1_slot=75
    
	run keyword and continue on failure   check_12269_TRS_nonTRS_diff_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   csirs_set3_period=320
	
	## check_12269_subTRS_same_slot_in_same_L1Pool(bip_csv, *physcell_in_this_L1pool)
	
	run keyword and continue on failure   check_12269_subTRS_same_slot_in_same_L1Pool   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   50   51	52
	
	## check_12269_subTRS_diff_RB_allocation_for_cells(bip_csv, numRB_TRS, *startRB)
	
	run keyword and continue on failure   check_12269_subTRS_diff_RB_allocation_for_cells   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   52   0   80   160

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
       UL data to '${num}'
    #   Wait '3s' for stabible
    #   get UE '${num}' rnti in RRC log
	END

UL data to '${UE_ID}'  
    Airphone SA Start Data Traffic    ${UE_ID}    UL   5M   pdu_id=${UE_ID}   duration=7200   trf_id=1
	
    Airphone SA Start Data Traffic    ${UE_ID}    DL   170M   pdu_id=${UE_ID}   duration=7200   trf_id=1
	Airphone SA Start Data Traffic    ${UE_ID}    DL   170M   pdu_id=${UE_ID}   duration=7200   trf_id=2
	Airphone SA Start Data Traffic    ${UE_ID}    DL   160M   pdu_id=${UE_ID}   duration=7200   trf_id=3
    Wait '5s' for stabible
	
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

check throughput from NSA UE '${low}' to '${hi}' with tp '${ul_cell_tp}'
	Wait '3s' for stabible
	${cell_tp_ul}	  evaluate	0
	FOR    ${num}    IN RANGE    ${low}    ${hi}+1
		${pcell_tp}	Get cell ul throught	${num}    8
		${ul_tput_Mb}    evaluate    ${pcell_tp}/1000
		Log To Console    UE${num}_ul_tp ${ul_tput_Mb}M--
	   ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}
    END
	Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
	run keyword and continue on failure    should be true    ${cell_tp_ul}>${ul_cell_tp}
	
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
