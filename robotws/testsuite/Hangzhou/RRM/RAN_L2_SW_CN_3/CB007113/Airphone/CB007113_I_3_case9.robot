# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# #Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G   owner_zhang		SBTS23R1
# #...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}    SCFC_7113_I_3_1208_60M_case9.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_3CELL.xml
# 
# ${L1BYP_XML}    L1By_7113_I_case789.xml	
# ${WTS_NAME}    wts_7113_I_3.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# @{VENDOR_PARAMETER_C32}	maxNumLayerPrbL1Sp:170	   maxNumStreamPrbL1Sp:340	  maxNumWbStreamPrbL1Sp:340
# @{VENDOR_PARAMETER_C64}	maxNumLayerPrbL1Sp:340	   maxNumStreamPrbL1Sp:680	  maxNumWbStreamPrbL1Sp:680
# *** Test Cases ***
# CB007113_I_3_case9_MUMIMO_4layers_with_UL_PRB_pooling_8DL8UL_2rank2_4rank1_Artificial_with_retran
# 	Upload airphone l1bypass to iphy
# 	Add RD param
# 	#Prepare gnb onair
# 	Modify vendor file and full commission for onair
# 	Change UE'7-9' to cell'2'
# 	Change UE'10-11' to cell'3'
# 	
# 	rank1_4UE_cell1_after_BG_UE
# 	rank2_2UE_cell1_after_BG_UE
# 	run keyword and continue on failure 	check_PRB_US1
# 	run keyword and continue on failure 	check_PRB_US2
# 	run keyword and continue on failure 	check_PRB_US3
# 	run keyword and continue on failure 	check_PRB_US4
# *** Keywords ***
# check_PRB_US1
#      7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/tti_5xR1_reTx_ul.csv       50      19
# check_PRB_US2
#      7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/tti_5xR1_reTx_after_BG_ul.csv       50      19
# check_PRB_US3
#      7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/tti_2xR2_reTx_ul.csv       50      19
# check_PRB_US4
#      7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/tti_2xR2_reTx_after_BG_ul.csv       50      19
#      
# check TP for '@{SA_UE_list}' with '${target_tp}'
# 	${TP}	evaluate    0	
# 	: FOR    ${UE_ID}    IN 	@{SA_UE_list}
# 	\	${ul_tput_kb}=	  airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pusch    tput_type=ave
# 	\	${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
# 	#\	Log To Console    UE${UE_ID}_ul_tp ${ul_tput_Mb}M--
# 	\	${TP}	evaluate    ${TP}+${ul_tput_Mb}	
# 	Log To Console		${\n}---cell TP:${TP}
# 	should be true		${TP}>=${target_tp}
# 	
# check_tp_US1
# 	check TP for '@{SA_UE_list}' with '113'
# check_tp_US2
# 	check TP for '@{SA_UE_list}' with '84'
# check_tp_US3
# 	check TP for '@{SA_UE_list}' with '129'
# check_tp_US4
# 	check TP for '@{SA_UE_list}' with '84'
# 		
# rank1_4UE_cell1_after_BG_UE
# 	Start capture gnb and ap syslog in 'sys_5xR1_reTx' file	
# 	UE from '1' to '4' SA Register and check
# 	UE from '13' to '13' SA Register and check
# 	Set test Variable	@{SA_UE_list}		1	2	3	4	13
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    30s    2s   check_tp_US1
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=40,40
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1,2 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=3 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=4 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_5xR1_reTx'	
# 	Stop capture gnb and ap syslog in 'sys_5xR1_reTx' file
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    120s    10s   check_counter_US1
# 
# 	Start capture gnb and ap syslog in 'sys_5xR1_reTx_after_BG' file
# 	UE from '9' to '10' SA Register and check
# 	Wait '5s' for stabible
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    30s    2s   check_tp_US2
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_5xR1_reTx_after_BG'		
# 	Stop capture gnb and ap syslog in 'sys_5xR1_reTx_after_BG' file
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    120s    10s   check_counter_US2
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1-4 scell\=0 testmode\=bler profile_id\=1 action\=deactivate	
# 	DeRegister UE from '1' to '4'
# 	DeRegister UE from '13' to '13'
# 	DeRegister UE from '9' to '10'
# 
# rank2_2UE_cell1_after_BG_UE
#      Start capture gnb and ap syslog in 'sys_2xR2' file
# 	UE from '5' to '6' SA Register and check	
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=40,40
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=5,6 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	#airphone_execute_egate_command	ue_testmode_set_nr id\=5,6 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	Set test Variable	@{SA_UE_list}		5	6
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    30s    2s   check_tp_US3
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_2xR2_reTx'
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    120s    10s   check_counter_US3
# 	Stop capture gnb and ap syslog in 'sys_2xR2' file
# 
# 	Start capture gnb and ap syslog in 'sys_2xR2_after_BG' file
# 	UE from '9' to '10' SA Register and check
# 	Wait '5s' for stabible
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    30s    10s   check_tp_US4
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_2xR2_reTx_after_BG'	
# 	Stop capture gnb and ap syslog in 'sys_2xR2_after_BG' file
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    120s    10s   check_counter_US4	
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    120s    10s   check PM counter of 2Rank2_after_BG
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=5,6 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
# 	DeRegister UE from '5' to '6'
# 	DeRegister UE from '9' to '10'
#     
# check_counter_US1
# 	Log To Console		--check_counter_US1--
# 	check PM counter PRB_UL_MU_MIMO_4LAYER_M55308C35005_1
# 	check PM counter PRB_UL_MU_MIMO_4_PairUE_M55308C35009_1
# check_counter_US2
# 	Log To Console		--check_counter_US2--
# 	check PM counter PRB_UL_MU_MIMO_4LAYER_M55308C35005_0
# 	check PM counter PRB_UL_MU_MIMO_4_PairUE_M55308C35009_0
# 	check PM counter PRB_UL_MU_MIMO_3LAYER_M55308C35004_0
# 	check PM counter PRB_UL_MU_MIMO_3_PairUE_M55308C35008_0
# 	check PM counter PRB_UL_MU_MIMO_2LAYER_M55308C35003_1
# 	check PM counter PRB_UL_MU_MIMO_2_PairUE_M55308C35007_1
# check_counter_US3
# 	Log To Console		--check_counter_US3--
# 	check PM counter PRB_UL_MU_MIMO_4LAYER_M55308C35005_1
# 	check PM counter PRB_UL_MU_MIMO_2_PairUE_M55308C35007_1
# check_counter_US4
# 	Log To Console		--check_counter_US4--
# 	check PM counter PRB_UL_MU_MIMO_4LAYER_M55308C35005_0
# 	check PM counter PRB_UL_MU_MIMO_2_PairUE_M55308C35007_0	
# 
# 		
# Add RD param
# 	Add GNB swconfig	 0x420068:6
# 	#act inter subpool 
# 	Add GNB swconfig	 0x580612:1
# 	#counter 1min
# 	Add GNB swconfig	 0x340000:15
# 	#enable ADMIN developer
# 	Add GNB swconfig	 0x450027:1
# 	# Admin developement account
# 	Add GNB swconfig	 0x45000A:1
# 	#actAdaptiveReTxResMCS default=true  ???
# 	Add GNB swconfig	 0x58066f:1
# 	#enable AP log
# 	Add AP swconfig    0x1003F:2
# 	Add AP swconfig    0x10042:0xC0A8C87E
# #counter refresh per 5min	
# check PM counter PRB_UL_MU_MIMO_2LAYER_M55308C35003_1
# 	Check pm counter M55308C35003 in cell 1 is expected > 0
# 	
# check PM counter PRB_UL_MU_MIMO_4LAYER_M55308C35005_1
# 	Check pm counter M55308C35005 in cell 1 is expected > 0
# 	
# check PM counter PRB_UL_MU_MIMO_2_PairUE_M55308C35007_1
# 	Check pm counter M55308C35007 in cell 1 is expected > 0
# 	
# check PM counter PRB_UL_MU_MIMO_4_PairUE_M55308C35009_1
# 	Check pm counter M55308C35009 in cell 1 is expected > 0
# 
# check PM counter PRB_UL_MU_MIMO_2LAYER_M55308C35003_0
# 	Check pm counter M55308C35003 in cell 1 is expected == 0
# 
# check PM counter PRB_UL_MU_MIMO_3LAYER_M55308C35004_0
# 	Check pm counter M55308C35004 in cell 1 is expected == 0
# 
# check PM counter PRB_UL_MU_MIMO_4LAYER_M55308C35005_0
# 	Check pm counter M55308C35005 in cell 1 is expected == 0
# 	
# check PM counter PRB_UL_MU_MIMO_2_PairUE_M55308C35007_0
# 	Check pm counter M55308C35007 in cell 1 is expected == 0
# 
# check PM counter PRB_UL_MU_MIMO_3_PairUE_M55308C35008_0
# 	Check pm counter M55308C35008 in cell 1 is expected == 0
# 
# check PM counter PRB_UL_MU_MIMO_4_PairUE_M55308C35009_0
# 	Check pm counter M55308C35009 in cell 1 is expected == 0
# 
# check PM counter of 2Rank2_after_BG
# 	#${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
# 	${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
# 	${PM_counter_PRB_pusch}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10002    cell_id=1
# 	${PM_counter_PRB_BB_pool}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10006    cell_id=1
# 	${diff}	Evaluate   abs((${PM_counter_PRB_BB_pool}-${PM_counter_PRB_pusch})/${PM_counter_PRB_BB_pool})
# 	should be true    ${diff}< 0.01
# 	
# UE from '${lo}' to '${hi}' SA Register and check 
#     : FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     #\   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}--register UE ${num} --
#     \   Airphone SA Attach    ue_id=${num}
#        #set_pdu_param ue=1 pdu=1 trf_type=internal
#        #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     \   Airphone Set Traffic Type    ${num}    ${num}    internal
#     \   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
#     \   Wait '3s' for stabible
#     \   UL data to '${num}'
#     #\   Wait '3s' for stabible
#     #\   get UE '${num}' rnti in RRC log
#     
# UL data to '${UE_ID}'  
#     run keyword if   (${UE_ID}<5)|(${UE_ID}>6)	
# 	...	 Airphone SA Start Data Traffic    ${UE_ID}    UL   70M   pdu_id=${UE_ID}   duration=7200   trf_id=1
# 	
# 	run keyword if   (${UE_ID}==5)|(${UE_ID}==6)	
# 	...	 Airphone SA Start Data Traffic    ${UE_ID}    UL   140M   pdu_id=${UE_ID}   duration=7200   trf_id=1
# 	
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   5M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     Wait '3s' for stabible
#     #${ul_tput_kb}=    Wait Until Keyword Succeeds    10s    1s   
# 	#...		airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pusch    tput_type=ave   
#     #${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     #Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
# 
# #check throughput
# check throughput from UE '${low}' to '${hi}' with tp '${ul_cell_tp}'
# 	Wait '3s' for stabible
# 	${cell_tp_ul}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   Log To Console    Check throughput UE${num}
#     \      ${ul_tput_kb}=    Wait Until Keyword Succeeds    10s    1s   
# 	...		airphone_get_throughput_on_specific_scell    ${num}    0    type=pusch    tput_type=ave
#     \      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     \      Log To Console		ul ${ul_tput_Mb}    
#     \      ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}    
#     Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
#     run keyword and continue on failure    should be true    ${cell_tp_ul}>${ul_cell_tp}
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '4s' for stabible
#     
# check tti'${tti_title}' no bler		
# 	Log To Console   ${\n}---check tti---
# 	Set test Variable    ${tti_title_tag}		${tti_title}_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_check_no_bler.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     
# get UE '${ue_id}' rnti in RRC log
#     Log To Console   ${\n}===get UE'${ue_id}' rnti===
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
# 
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001   crnti: (\\d+)
#     run keyword if    ${ue_id}==1   Set test Variable	 ${rnti_1} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==2   Set test Variable	 ${rnti_2} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==3   Set test Variable	 ${rnti_3} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==4   Set test Variable	 ${rnti_4} 	${rnti_list[0]}
# 
# Change UE'${ue_id}' to cell'${cell_id}'
#     airphone_execute_egate_command      ue_change_location cell\=${cell_id} id\=${ue_id}
