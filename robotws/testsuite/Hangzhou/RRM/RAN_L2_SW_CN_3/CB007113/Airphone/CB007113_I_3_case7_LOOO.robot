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
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}    SCFC_7113_I_3_1116_0ms_100M_case7_LOOO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_3CELL_ABIO.xml	
# ${WTS_NAME}    wts_7113_I_3.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# @{VENDOR_PARAMETER_C32}	maxNumLayerPrbL1Sp:230	   maxNumStreamPrbL1Sp:460	  maxNumWbStreamPrbL1Sp:460
# @{VENDOR_PARAMETER_C64}	maxNumLayerPrbL1Sp:460	   maxNumStreamPrbL1Sp:920	  maxNumWbStreamPrbL1Sp:920
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE15}    ul_mimo_srs_beam_pos_nr profile_id\=15 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# ${PROFILE16}    ul_mimo_srs_beam_pos_nr profile_id\=16 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE17}    ul_mimo_srs_beam_pos_nr profile_id\=17 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE15}    ue_testmode_set_nr id\=15 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=15
# ${SET_PROFILE16}    ue_testmode_set_nr id\=16 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=16
# ${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
# ${SET_PROFILE10}    ue_testmode_set_nr id\=10 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10
# ${SET_PROFILE17}    ue_testmode_set_nr id\=17 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=17
# 
# ${deactive_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=1
# ${deactive_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2
# ${deactive_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=3
# ${deactive_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=4
# ${deactive_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=5
# ${deactive_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=6
# ${delete_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 delete\=true
# ${delete_PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 delete\=true
# ${delete_PROFILE15}    ul_mimo_srs_beam_pos_nr profile_id\=15 delete\=true
# ${delete_PROFILE16}    ul_mimo_srs_beam_pos_nr profile_id\=16 delete\=true
# ${delete_PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 delete\=true
# ${delete_PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 delete\=true
# ${delete_PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 delete\=true
# ${delete_PROFILE17}    ul_mimo_srs_beam_pos_nr profile_id\=17 delete\=true
# *** Test Cases ***
# CB007113_I_3_case7_MUMIMO_4layers_with_UL_PRB_pooling_8DL8UL_2rank2_4rank1_Artificial
# 	ADD RD counter
# 	Get and Update BSR File		par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
# 	Modify vendor file and full commission for onair
# 	Change UE'7-9' to cell'2'
# 	Change UE'10-12' to cell'3'
# 	
# 	rank1_4UE_cell1			
# 	run keyword and continue on failure 	check_PRB_US1
# 	run keyword and continue on failure 	check_PRB_US2
# 
# 	rank2_2UE_cell1
# 	run keyword and continue on failure 	check_PRB_US3
# 	run keyword and continue on failure 	check_PRB_US4	
# 	
# *** Keywords ***
# rank1_4UE_cell1
# 	Start capture gnb and ap syslog in '4R1' file
# 	Register_UE1
# 	Register_UE2
# 	Attach_UE15
# 	Attach_UE16
# 	Set test Variable	@{SA_UE_list}		1	2
# 	Set test Variable	@{NSA_UE_list}		15	16
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    30s    2s   check_tp_US1
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_4xR1'
# 	
# 	Set test Variable    ${tti_title_tag}		tti_4xR1_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_case7_4xRank1_before_BG.ini   i
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}/All	
# 	Stop capture gnb and ap syslog in '4R1' file
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    120s    10s   check_counter_US1
# 	
# 	Start capture gnb and ap syslog in '4R1_after_BG' file
# 	Register_UE10
# 	Wait '5s' for stabible
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    30s    2s   check_tp_US2
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_4xR1_after_BG'
# 	
# 	Set test Variable    ${tti_title_tag}		tti_4xR1_after_BG_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_case7_4xRank1_after_BG.ini   i
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# 	Stop capture gnb and ap syslog in '4R1_after_BG' file
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    120s    10s   check_counter_US2
# 	DeRegister UE from '1' to '2'
# 	Dettach UE from '15' to '16'
# 	DeRegister UE from '10' to '10'
# 	delete profile_1_2_15_16_10
# 	
# rank2_2UE_cell1
# 	Start capture gnb and ap syslog in '2R2' file
# 	Register_UE5
# 	Attach_UE17
# 	Set test Variable	@{SA_UE_list}		5
# 	Set test Variable	@{NSA_UE_list}		17
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    30s    2s   check_tp_US3
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_2xR2'
# 	
# 	Set test Variable    ${tti_title_tag}		tti_2xR2_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_case7_2xRank2_before_BG.ini   i
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	Stop capture gnb and ap syslog in '2R2' file	
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    120s    10s   check_counter_US3
# 	
# 	Start capture gnb and ap syslog in '2R2_after_BG' file
# 	Register_UE10
# 	Wait '5s' for stabible
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    30s    2s   check_tp_US4
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_2xR2_after_BG'
# 	
# 	Set test Variable    ${tti_title_tag}		tti_2xR2_after_BG_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_case7_2xRank2_after_BG.ini   i
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# 	Stop capture gnb and ap syslog in '2R2_after_BG' file
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    120s    10s   check_counter_US4
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    120s    10s   check PM counter of 2Rank2_after_BG
# 	DeRegister UE from '5' to '5'
# 	Dettach UE from '17' to '17'
# 	DeRegister UE from '10' to '10'
# 	delete profile_5_17_10
# 	
# delete profile_1_2_15_16_10
# 	Airphone Execute Egate Command    ${delete_PROFILE1}
# 	Airphone Execute Egate Command    ${delete_PROFILE2}
# 	Airphone Execute Egate Command    ${delete_PROFILE15}
# 	Airphone Execute Egate Command    ${delete_PROFILE16}
# 	Airphone Execute Egate Command    ${delete_PROFILE10}
# delete profile_5_17_10
# 	Airphone Execute Egate Command    ${delete_PROFILE5}
# 	Airphone Execute Egate Command    ${delete_PROFILE17}
# 	Airphone Execute Egate Command    ${delete_PROFILE10}
# Register_UE1	
# 	UE from '1' to '1' SA Register
# 	Set UE1 position
# 	send ul data from UE '1' to '1'	
# Register_UE2	
# 	UE from '2' to '2' SA Register
# 	Set UE2 position
# 	send ul data from UE '2' to '2'	
# Attach_UE15	
# 	UE from '15' to '15' NSA Attach and check
# 	Set UE15 position
# 	send data NSA from '15' to '15'
# Attach_UE16	
# 	UE from '16' to '16' NSA Attach and check
# 	Set UE16 position
# 	send data NSA from '16' to '16'
# Register_UE5	
# 	UE from '5' to '5' SA Register
# 	Set UE5 position
# 	send ul data from UE '5' to '5'	
# Register_UE7	
# 	UE from '7' to '7' SA Register
# 	Set UE7 position
# 	send ul data from UE '7' to '7'
# Register_UE10	
# 	UE from '10' to '10' SA Register
# 	Set UE10 position
# 	send ul data from UE '10' to '10'	
# Attach_UE17
# 	UE from '17' to '17' NSA Attach and check
# 	Set UE17 position
# 	send data NSA from '17' to '17'
# Set UE1 position
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Wait '2s' for stabible
# Set UE2 position
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}
#     Wait '2s' for stabible
# Set UE15 position
#     Airphone Execute Egate Command    ${PROFILE15}
#     Airphone Execute Egate Command    ${SET_PROFILE15}
#     Wait '2s' for stabible
# Set UE16 position
#     Airphone Execute Egate Command    ${PROFILE16}
#     Airphone Execute Egate Command    ${SET_PROFILE16}
#     Wait '2s' for stabible
# Set UE5 position
#     Airphone Execute Egate Command    ${PROFILE5}
#     Airphone Execute Egate Command    ${SET_PROFILE5}
#     Wait '2s' for stabible
# Set UE7 position
#     Airphone Execute Egate Command    ${PROFILE7}
#     Airphone Execute Egate Command    ${SET_PROFILE7}
#     Wait '2s' for stabible
# Set UE10 position
#     Airphone Execute Egate Command    ${PROFILE10}
#     Airphone Execute Egate Command    ${SET_PROFILE10}
#     Wait '2s' for stabible
# Set UE17 position
#     Airphone Execute Egate Command    ${PROFILE17}
#     Airphone Execute Egate Command    ${SET_PROFILE17}
#     Wait '2s' for stabible
# send ul data from UE '${lo}' to '${hi}'  
# 	: FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     \   DL and UL data to '${num}'    
# DL and UL data to '${UE_ID}'
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   5M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     run keyword if    ${UE_ID}<5		Airphone SA Start Data Traffic    ${UE_ID}    UL   80M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     run keyword if    ${UE_ID}>4		Airphone SA Start Data Traffic    ${UE_ID}    UL   160M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     Wait '4s' for stabible
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${UE_ID}  	pdu_id= ${UE_ID}
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
# 
# check_PRB_US1
#     7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/tti_4xR1_ul.csv       50      15
# check_PRB_US2
#     7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/tti_4xR1_after_BG_ul.csv       50      15
# check_PRB_US3
#     7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/tti_2xR2_ul.csv       50      15
# check_PRB_US4
#     7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/tti_2xR2_after_BG_ul.csv       50      15
# 
# check_tp_US1
# 	check TP for '@{SA_UE_list}' and '@{NSA_UE_list}' with '220'
# check_tp_US2
# 	check TP for '@{SA_UE_list}' and '@{NSA_UE_list}' with '160'
# check_tp_US3
# 	check TP for '@{SA_UE_list}' and '@{NSA_UE_list}' with '225'
# check_tp_US4
# 	check TP for '@{SA_UE_list}' and '@{NSA_UE_list}' with '160'
# 	
# check TP for '@{SA_UE_list}' and '@{NSA_UE_list}' with '${target_tp}'
# 	${TP}	evaluate    0	
# 	: FOR    ${UE_ID}    IN 	@{SA_UE_list}
# 	\	${ul_tput_kb}=	  airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pusch    tput_type=ave
# 	\	${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
# 	#\	Log To Console    UE${UE_ID}_ul_tp ${ul_tput_Mb}M--
# 	\	${TP}	evaluate    ${TP}+${ul_tput_Mb}
# 
# 	: FOR    ${UE_ID}    IN 	@{NSA_UE_list}
# 	\	${ul_tput_kb}=	  airphone_get_throughput_on_specific_scell    ${UE_ID}    8    type=pusch    tput_type=ave	
# 	\	${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
# 	#\	Log To Console    UE${UE_ID}_ul_tp ${ul_tput_Mb}M--
# 	\	${TP}	evaluate    ${TP}+${ul_tput_Mb}
# 	
# 	Log To Console		${\n}---cell TP:${TP}
# 	should be true		${TP}>=${target_tp}
# 
# ADD RD counter
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
# UE from '${lo}' to '${hi}' SA Register
#     : FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     #\   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}--register UE ${num} --
#     \   Airphone SA Attach    ue_id=${num}
#        #set_pdu_param ue=1 pdu=1 trf_type=internal
#        #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     \   Airphone Set Traffic Type    ${num}    ${num}    internal
#     \   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
#     \   Wait '2s' for stabible
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
# 	
# 	${ul_tput_kb}=    Wait Until Keyword Succeeds    10s    1s   
# 	...		airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pusch    tput_type=ave   
# 	${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
# 	Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
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
# #================NSA attach==========
# UE from '${lo}' to '${hi}' NSA Attach and check
# 	: FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
# 	\    Log To Console   ${\n}--Attach NSA UE ${num} --
# 	\   airphone_cleanup_egate_console_log
# 	\	Airphone Nsa Attach     ${num}    profile_id=None
# 	\	Wait '2s' for stabible
# send data NSA from '${lo}' to '${hi}'
# 	: FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
# 	\	run keyword if   (${num}==15)|(${num}==16) 	 NSA send ue '${num}' mutiple trf '1' for each '70M' UL data
# 	\	run keyword if   (${num}==17)|(${num}==18) 	 NSA send ue '${num}' mutiple trf '1' for each '140M' UL data
# 	\	Wait '2s' for stabible
# 	\	${pcell_tp}	Get cell ul throught	${num}    8
# 	\	${ul_tput_Mb}    evaluate    ${pcell_tp}/1000
# 
# check throughput from NSA UE '${low}' to '${hi}' with tp '${ul_cell_tp}'
# 	Wait '3s' for stabible
# 	${cell_tp_ul}	  evaluate	0
# 	: FOR    ${num}    IN RANGE    ${low}    ${hi}+1
# 	\	${pcell_tp}	Get cell ul throught	${num}    8
# 	\	${ul_tput_Mb}    evaluate    ${pcell_tp}/1000
# 	\	Log To Console    UE${num}_ul_tp ${ul_tput_Mb}M--
# 	\   ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}
# 	Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
# 	run keyword and continue on failure    should be true    ${cell_tp_ul}>${ul_cell_tp}
# 	
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \	Log To Console   ${\n}deRegister UE${num}
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '4s' for stabible
# 
# Dettach UE from '${low}' to '${hi}'
# 	: FOR    ${num}    IN RANGE    ${low}    ${hi}+1
# 	\	Log To Console   ${\n}detach UE${num}
# 	\	Airphone NSA Detach    ue_id= ${num}
# 	\   Wait '3s' for stabible
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
