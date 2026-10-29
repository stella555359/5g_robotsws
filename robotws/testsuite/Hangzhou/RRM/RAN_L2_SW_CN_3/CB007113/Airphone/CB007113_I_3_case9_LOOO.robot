# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# #Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G   owner_zhang		SBTS23R1
# #...   CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}    SCFC_7113_I_3_1208_60M_case9_LOOO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_3CELL_ABIO.xml	
# ${WTS_NAME}    wts_7113_I_3.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# @{VENDOR_PARAMETER_C32}	maxNumLayerPrbL1Sp:170	   maxNumStreamPrbL1Sp:340	  maxNumWbStreamPrbL1Sp:340
# @{VENDOR_PARAMETER_C64}	maxNumLayerPrbL1Sp:340	   maxNumStreamPrbL1Sp:680	  maxNumWbStreamPrbL1Sp:680
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id\=13 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# ${SET_PROFILE9}    ue_testmode_set_nr id\=9 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=9
# ${SET_PROFILE10}    ue_testmode_set_nr id\=10 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10
# ${SET_PROFILE13}    ue_testmode_set_nr id\=13 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=13
# 
# ${delete_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 delete\=true
# ${delete_PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 delete\=true
# ${delete_PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 delete\=true
# ${delete_PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 delete\=true
# ${delete_PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 delete\=true
# ${delete_PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 delete\=true
# ${delete_PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 delete\=true
# ${delete_PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 delete\=true
# ${delete_PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id\=13 delete\=true
# *** Test Cases ***
# CB007113_I_3_case9_MUMIMO_4layers_with_UL_PRB_pooling_8DL8UL_2rank2_4rank1_Artificial_with_retran
# 	Add RD param
# 	Get and Update BSR File		par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
# 	Modify vendor file and full commission for onair
# 	Change UE'7-9' to cell'2'
# 	Change UE'10-11' to cell'3'
# 	
# 	rank1_4UE_cell1_after_BG_UE	
# 	run keyword and continue on failure 	check_PRB_US1
# 	run keyword and continue on failure 	check_PRB_US2
# 	
# 	rank2_2UE_cell1_after_BG_UE
# 	run keyword and continue on failure 	check_PRB_US3
# 	run keyword and continue on failure 	check_PRB_US4
# *** Keywords ***
# check_PRB_US1
# 	#US4:thr<X<X_max,Y > rrmAvailablePrbForMu*ratio, full UE pairing use 2 subcells
# 	7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/tti_5xR1_reTx_ul.csv       50      19	
# check_PRB_US2
# 	#US2: X<thr, Y > rrmAvailableSubcellPRbForMu*ratio, Rank1 pair on primary subcell only
#     7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/tti_5xR1_reTx_after_BG_ul.csv       50      19	
# 
# check_PRB_US3
# 	#US4:thr<X<X_max,Y > rrmAvailablePrbForMu*ratio, full UE pairing use 2 subcells
#     7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/tti_2xR2_reTx_ul.csv       50      19
# check_PRB_US4
# 	#US2: X<thr, Y > rrmAvailableSubcellPRbForMu*ratio, Rank1 pair on primary subcell only
#     7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/tti_2xR2_reTx_after_BG_ul.csv       50      19
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
# 	check TP for '@{SA_UE_list}' with '130'
# check_tp_US2
# 	check TP for '@{SA_UE_list}' with '60'
# check_tp_US3
# 	check TP for '@{SA_UE_list}' with '130'
# check_tp_US4
# 	check TP for '@{SA_UE_list}' with '70'
# 		
# rank1_4UE_cell1_after_BG_UE
# 	Start capture gnb and ap syslog in 'sys_5xR1_reTx' file	
# 	Register_UE1
# 	Register_UE2
# 	Register_UE3
# 	Register_UE4
# 	Register_UE13
# 	Set test Variable	@{SA_UE_list}		1	2	3	4	13
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    30s    2s   check_tp_US1
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=100,100
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1,2 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=3 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=4 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	#trigger pusch bler
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_5xR1_reTx'
# 	
# 	Set test Variable    ${tti_title_tag}		tti_5xR1_reTx_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_case9_5xR1_US4.ini   i
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# 	Stop capture gnb and ap syslog in 'sys_5xR1_reTx' file
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    120s    10s   check_counter_US1
# 
# 	Start capture gnb and ap syslog in 'sys_5xR1_reTx_after_BG' file
# 	Register_UE9
# 	Register_UE10
# 	Wait '5s' for stabible
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    30s    2s   check_tp_US2
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_5xR1_reTx_after_BG'
# 
# 	Set test Variable    ${tti_title_tag}		tti_5xR1_reTx_after_BG_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_case9_5xR1_after_BG_US2.ini   i
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# 	Stop capture gnb and ap syslog in 'sys_5xR1_reTx_after_BG' file
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    120s    10s   check_counter_US2
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1-4 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
# 	#deactive pusch bler	
# 	DeRegister UE from '1' to '4'
# 	DeRegister UE from '13' to '13'
# 	DeRegister UE from '9' to '10'
# 	delete profile_1_4_9_10_13
# 	
# rank2_2UE_cell1_after_BG_UE
#      Start capture gnb and ap syslog in 'sys_2xR2' file
# 	Register_UE5
# 	Register_UE6	
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=100,100
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=5,6 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	Set test Variable	@{SA_UE_list}		5	6
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    30s    2s   check_tp_US3
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_2xR2_reTx'
# 
# 	Set test Variable    ${tti_title_tag}		tti_2xR2_reTx_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_case9_5xR1_US4.ini   i
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    120s    10s   check_counter_US3
# 	Stop capture gnb and ap syslog in 'sys_2xR2' file
# 
# 	Start capture gnb and ap syslog in 'sys_2xR2_after_BG' file
# 	Register_UE9
# 	Register_UE10
# 	Wait '5s' for stabible
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    30s    10s   check_tp_US4
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_2xR2_reTx_after_BG'
# 
# 	Set test Variable    ${tti_title_tag}		tti_2xR2_reTx_after_BG_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_case9_2xR2_after_BG_US2.ini   i
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# 	Stop capture gnb and ap syslog in 'sys_2xR2_after_BG' file
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    120s    10s   check_counter_US4	
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    120s    10s   check PM counter of 2Rank2_after_BG
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=5,6 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
# 	DeRegister UE from '5' to '6'
# 	DeRegister UE from '9' to '10'
# 	delete profile_5_6_9_10
# 
# trigger pusch bler
# 	Log To Console   ${\n}---trigger ul bler---
# 	Airphone Execute Egate Command	ul_sinr_testmode_nr profile_id\=1 sinr_target_pusch\=-370
# 	Airphone Execute Egate Command	ue_testmode_set_nr id\=1-4 testmode\=ul_sinr profile_id\=1 action\=activate
# 	Wait '5s' for stabible
# 	#run keyword and continue on failure 	Wait Until Keyword Succeeds    10s    2s   check throughput from UE '1' to '4' with tp '30'
# 
# deactive pusch bler
# 	Airphone Execute Egate Command	ue_testmode_set_nr id\=1-4 testmode\=ul_sinr profile_id\=1 action\=deactivate
# 	Wait '2s' for stabible
# trigger DTX
# 	Log To Console   ${\n}---FDD ul DTX---
# 	airphone_execute_egate_command	forced_dtx_testmode_nr profile_id\=1 force_dtx_pusch\=3000:10
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1-4 testmode\=forced_dtx profile_id\=1 action\=activate
# 	Wait '2s' for stabible
# deactive DTX
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1-4 testmode\=forced_dtx profile_id\=1 action\=deactivate
# 
# delete profile_1_4_9_10_13
# 	Airphone Execute Egate Command    ${delete_PROFILE1}
# 	Airphone Execute Egate Command    ${delete_PROFILE2}
# 	Airphone Execute Egate Command    ${delete_PROFILE3}
# 	Airphone Execute Egate Command    ${delete_PROFILE4}
# 	Airphone Execute Egate Command    ${delete_PROFILE9}
# 	Airphone Execute Egate Command    ${delete_PROFILE10}
# 	Airphone Execute Egate Command    ${delete_PROFILE13}
# delete profile_5_6_9_10
# 	Airphone Execute Egate Command    ${delete_PROFILE5}
# 	Airphone Execute Egate Command    ${delete_PROFILE6}
# 	Airphone Execute Egate Command    ${delete_PROFILE9}
# 	Airphone Execute Egate Command    ${delete_PROFILE10}
# Register_UE1	
# 	UE from '1' to '1' SA Register
# 	Set UE1 position
# 	send ul data from UE '1' to '1'	
# Register_UE2	
# 	UE from '2' to '2' SA Register
# 	Set UE2 position
# 	send ul data from UE '2' to '2'
# Register_UE3	
# 	UE from '3' to '3' SA Register
# 	Set UE3 position
# 	send ul data from UE '3' to '3'	
# Register_UE4	
# 	UE from '4' to '4' SA Register
# 	Set UE4 position
# 	send ul data from UE '4' to '4'  
# Register_UE5	
# 	UE from '5' to '5' SA Register
# 	Set UE5 position
# 	send ul data from UE '5' to '5'	
# Register_UE6	
# 	UE from '6' to '6' SA Register
# 	Set UE6 position
# 	send ul data from UE '6' to '6'
# Register_UE9	
# 	UE from '9' to '9' SA Register
# 	Set UE9 position
# 	send ul data from UE '9' to '9'	
# Register_UE10	
# 	UE from '10' to '10' SA Register
# 	Set UE10 position
# 	send ul data from UE '10' to '10'
# Register_UE13	
# 	UE from '13' to '13' SA Register
# 	Set UE13 position
# 	send ul data from UE '13' to '13'
# Set UE1 position
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Wait '2s' for stabible
# Set UE2 position
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}
#     Wait '2s' for stabible
# Set UE3 position
#     Airphone Execute Egate Command    ${PROFILE3}
#     Airphone Execute Egate Command    ${SET_PROFILE3}
#     Wait '2s' for stabible
# Set UE4 position
#     Airphone Execute Egate Command    ${PROFILE4}
#     Airphone Execute Egate Command    ${SET_PROFILE4}
#     Wait '2s' for stabible 
# Set UE5 position
#     Airphone Execute Egate Command    ${PROFILE5}
#     Airphone Execute Egate Command    ${SET_PROFILE5}
#     Wait '2s' for stabible
# Set UE6 position
#     Airphone Execute Egate Command    ${PROFILE6}
#     Airphone Execute Egate Command    ${SET_PROFILE6}
#     Wait '2s' for stabible
# Set UE9 position
#     Airphone Execute Egate Command    ${PROFILE9}
#     Airphone Execute Egate Command    ${SET_PROFILE9}
#     Wait '2s' for stabible
# Set UE10 position
#     Airphone Execute Egate Command    ${PROFILE10}
#     Airphone Execute Egate Command    ${SET_PROFILE10}
#     Wait '2s' for stabible 
# Set UE13 position
#     Airphone Execute Egate Command    ${PROFILE13}
#     Airphone Execute Egate Command    ${SET_PROFILE13}
#     Wait '2s' for stabible  
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
# Add RD param	
# 	#counter 1min
# 	Add GNB swconfig	 0x9D0000:15
# 	
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
# UE from '${lo}' to '${hi}' SA Register 
#     : FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     #\   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}--register UE ${num} --
#     \   Airphone SA Attach    ue_id=${num}
#        #set_pdu_param ue=1 pdu=1 trf_type=internal
#        #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     \   Airphone Set Traffic Type    ${num}    ${num}    internal
#     \   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
#     \   Wait '3s' for stabible
# 
# send ul data from UE '${lo}' to '${hi}'  
# 	: FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     \   DL and UL data to '${num}'    
# DL and UL data to '${UE_ID}'
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   5M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     run keyword if    ${UE_ID}<5		Airphone SA Start Data Traffic    ${UE_ID}    UL   70M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     run keyword if    ${UE_ID}>4		Airphone SA Start Data Traffic    ${UE_ID}    UL   140M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     Wait '4s' for stabible
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${UE_ID}  	pdu_id= ${UE_ID}
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console		UE${UE_ID}_ul ${ul_tput_Mb} 
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
