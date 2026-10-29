# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    AP   CRT   SBTS00   RAN_5G_TDD  RAN_5G  owner_zhang
# ...   CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_B_case6_1208_20M_AL1_4UE_MPAPLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_1CELL_8D8U_LOAPLO_case6_CNI104041_puschBeamForming.xml
# ${WTS_NAME}    wts_8360_B_case5_LOAPLO.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# 
# #23 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# #33
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# #00
# ${PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id\=13 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# #10
# ${PROFILE14}    ul_mimo_srs_beam_pos_nr profile_id\=14 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# #23
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# #00
# ${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE13}    ue_testmode_set_nr id\=13 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=13
# ${SET_PROFILE14}    ue_testmode_set_nr id\=14 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=14
# ${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE11}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=11
# ${delete_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 delete\=true
# ${delete_PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 delete\=true
# ${delete_PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id\=13 delete\=true
# ${delete_PROFILE14}    ul_mimo_srs_beam_pos_nr profile_id\=14 delete\=true
# ${delete_PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 delete\=true
# ${delete_PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 delete\=true
# 
# ${deactive_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=1
# ${deactive_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2
# ${deactive_PROFILE13}    ue_testmode_set_nr id\=13 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=13
# ${deactive_PROFILE14}    ue_testmode_set_nr id\=14 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=14
# ${deactive_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=5
# ${deactive_PROFILE11}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=11
# *** Test Cases ***
# CNI104041_CB008360_B_B3b_case06_four_rank1_SA_NSA_Ues_Max_4Layer_with_retransmission_without_tapering
# 	Get and Update BSR File		par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001   
# 	Prepare gnb onair 
# 
# 	check no bler before bler testmode US1
# 	run keyword and continue on failure   Wait Until Keyword Succeeds    300s    10s   trigger ul bler 4 rank1 pair_234
# 
# 	check no bler before bler testmode US2
# 	run keyword and continue on failure   Wait Until Keyword Succeeds    300s    10s   trigger ul bler SA rank2 and NSA rank2	
# 
# 	# check no bler before bler testmode US3
# 	# Wait Until Keyword Succeeds    300s    10s   trigger ul bler SA 2 rank1 and NSA rank2		#OK~NOK	
# 
# 	# check no bler before bler testmode US4
# 	# Wait Until Keyword Succeeds    300s    10s   trigger ul bler SA rank2 and NSA 2 rank1		#OK	
# 	
# *** Keywords ***
# #SA		UE:1~4  (rank1)		5~10 (rank2)
# #NSA	UE:11~12(rank2)		13~14(rank1)
# Add RD param
# 	#The UL CoMa log enabling flag(rdUlSrsCoMaLogEnabled)
# 	Add GNB swconfig	 0x580477:1
# 
# set_pusch_power_for_CNI104041
# 	airphone_execute_egate_command   ul_sinr_testmode_nr profile_id\=1 pusch_tx_power\=-500 pathloss\=28
# 	airphone_execute_egate_command   ue_testmode_set_nr id\=1,2,5 testmode\=ul_sinr profile_id\=1 action\=activate
# 	airphone_execute_egate_command   ue_testmode_set_nr id\=11,13,14 testmode\=ul_sinr profile_id\=1 action\=activate
# 
# test_NSA_1314
# 	Attach_UE13
# 	Attach_UE14   
# 	run keyword and continue on failure	   Wait Until Keyword Succeeds    20s    2s   check throughput from NSA UE '13' to '14' with tp '10'
# 	run keyword and continue on failure	   check tti no bler_with_passratio_'1'
# 	Dettach UE from '13' to '14'
# 	delete profile_13_14
# #1    
# check no bler before bler testmode US1
# 	set_pusch_power_for_CNI104041
# 	Register_UE1
# 	Register_UE2
# 	Attach_UE13
# 	Attach_UE14   
# 	Log To Console   ${\n}----*---*---*---stop---*---*---
# 	run keyword and continue on failure	   Wait Until Keyword Succeeds    10s    2s   check throughput from SA UE '1' to '2' with tp '10'
# 	run keyword and continue on failure	   Wait Until Keyword Succeeds    10s    2s   check throughput from NSA UE '13' to '14' with tp '10'
# 	run keyword and continue on failure	   check tti no bler_with_passratio_'1'
# 	DeRegister UE from '1' to '2'
# 	Dettach UE from '13' to '14'
# 	delete profile_1_2
# 	delete profile_13_14
# #trigger 1	
# trigger ul bler 4 rank1 pair_234
#     Log To Console   ${\n}<<US1-----SA_R1_R1 + NSA_R1_R1-----Pair_123>>
#     Start capture gnb and ap syslog in '1' file
# 	set_pusch_power_for_CNI104041
# 	Register_UE1
# 	Register_UE2
# 	Attach_UE13
# 	Attach_UE14
# 	Log To Console   ${\n}---bler 4 UE---
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=400,400
# 	Wait '1s' for stabible
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1,2 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=13,14 scell\=8 testmode\=bler profile_id\=1 action\=activate
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_bler_rank1_UE_1_2_13_14'
# 	
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1,2 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=13,14 scell\=8 testmode\=bler profile_id\=1 action\=deactivate
# 
# 	DeRegister UE from '1' to '2'
# 	Dettach UE from '13' to '14'
# 	Stop capture gnb and ap syslog in '1' file
# 	delete profile_1_2
# 	delete profile_13_14
# 	
# 	Log To Console   ${\n}---check tti---
# 	Set test Variable    ${tti_title_tag}		tti_bler_rank1_UE_1_2_13_14_ul.csv
# 	run keyword and ignore error    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_case5_simple_reTx_pair_234UE.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# #2
# check no bler before bler testmode US2
# 	set_pusch_power_for_CNI104041
# 	Register_UE5
# 	Attach_UE11
# 	run keyword and continue on failure	   Wait Until Keyword Succeeds    30s    2s   check throughput from SA UE '5' to '5' with tp '10'
# 	run keyword and continue on failure	   Wait Until Keyword Succeeds    30s    2s   check throughput from NSA UE '11' to '11' with tp '10'
# 	run keyword and continue on failure	   check tti no bler_with_passratio_'1'
# 	DeRegister UE from '5' to '5'
# 	Dettach UE from '11' to '11'
# 	delete profile_5_11
# #trigger 2
# trigger ul bler SA rank2 and NSA rank2
#     Log To Console   ${\n}<<US2-----SA_R2 + NSA_R2----->>
# 	Start capture gnb and ap syslog in '2' file
# 	set_pusch_power_for_CNI104041
# 	Register_UE5
# 	Attach_UE11	
# 	Log To Console   ${\n}---bler 2 UE---
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=200,200	
# 	Wait '1s' for stabible	
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=11 scell\=8 testmode\=bler profile_id\=1 action\=activate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=5 scell\=0 testmode\=bler profile_id\=1 action\=activate	
# 	Wait '1s' for stabible
# 	Start collect ttitrace	
# 	Wait for '2s' to stop ttitrace with name'tti_bler_Rank2_UE_5_11'	
# 	
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=5 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=11 scell\=8 testmode\=bler profile_id\=1 action\=deactivate
# 	DeRegister UE from '5' to '5'
# 	Dettach UE from '11' to '11'
# 	Stop capture gnb and ap syslog in '2' file
# 	delete profile_5_11
# 	
# 	Log To Console   ${\n}---check tti ---
# 	Set test Variable    ${tti_title_tag}		tti_bler_Rank2_UE_5_11_ul.csv
# 	run keyword and ignore error    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_case5_simple_reTx_pair_rank22.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# #3
# check no bler before bler testmode US3
# 	Register_UE1
# 	Register_UE2
# 	Attach_UE11
# 	run keyword and continue on failure	   Wait Until Keyword Succeeds    30s    2s   check throughput from SA UE '1' to '2' with tp '10'
#      run keyword and continue on failure	   Wait Until Keyword Succeeds    30s    2s   check throughput from NSA UE '11' to '11' with tp '10'
#      run keyword and continue on failure	   check tti no bler_with_passratio_'1'
#      DeRegister UE from '1' to '2'
# 	Dettach UE from '11' to '11'
# 	delete profile_1_2_11
# #trigger 3	
# trigger ul bler SA 2 rank1 and NSA rank2
#     Log To Console   ${\n}<<US3-----SA_R1_R1 + NSA_R2----->>
# 	Start capture gnb and ap syslog in '3' file
# 	Register_UE1
# 	Register_UE2
# 	Attach_UE11	
# 	Log To Console   ${\n}---bler 3 UE---
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=100,100
# 	Wait '1s' for stabible	
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=11 scell\=8 testmode\=bler profile_id\=1 action\=activate	
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1,2 scell\=0 testmode\=bler profile_id\=1 action\=activate	
# 	Wait '1s' for stabible			
# 	Start collect ttitrace	
# 	Wait for '2s' to stop ttitrace with name'tti_bler_SA_r11_NSA_r2'	
# 		
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=11 scell\=8 testmode\=bler profile_id\=1 action\=deactivate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1,2 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
# 	DeRegister UE from '1' to '2'
# 	Dettach UE from '11' to '11'
# 	Stop capture gnb and ap syslog in '3' file
# 	delete profile_1_2_11
# 
# 	Log To Console   ${\n}---check tti ---
# 	Set test Variable    ${tti_title_tag}		tti_bler_SA_r11_NSA_r2_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_case6_simple_reTx_pair_rank_112.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     
# #4
# check no bler before bler testmode US4
# 	Register_UE5
# 	Attach_UE13
# 	Attach_UE14
# 	run keyword and continue on failure	   Wait Until Keyword Succeeds    30s    2s   check throughput from SA UE '5' to '5' with tp '10'
#      run keyword and continue on failure	   Wait Until Keyword Succeeds    30s    2s   check throughput from NSA UE '13' to '14' with tp '10'
#      run keyword and continue on failure	   check tti no bler_with_passratio_'1'
#      DeRegister UE from '5' to '5'
# 	Dettach UE from '13' to '14'
# 	delete profile_5_13_14
# #trigger 4	
# trigger ul bler SA rank2 and NSA 2 rank1
#     Log To Console   ${\n}<<US4-----SA_R2 + NSA_R1_R1----->>
# 	Start capture gnb and ap syslog in '4' file
# 	Register_UE5
# 	Attach_UE13
# 	Attach_UE14
# 	Log To Console   ${\n}---bler 3 UE ---
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=100,100	
# 	Wait '1s' for stabible	
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=5 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=13,14 scell\=8 testmode\=bler profile_id\=1 action\=activate
# 	Wait '1s' for stabible	
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_bler_SA_r2_NSA_r11'	
# 	
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=5 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=13,14 scell\=8 testmode\=bler profile_id\=1 action\=deactivate
# 	DeRegister UE from '5' to '5'
# 	Dettach UE from '13' to '14'
# 	Stop capture gnb and ap syslog in '4' file
# 	delete profile_5_13_14
# 
# 	Log To Console   ${\n}---check tti ---
# 	Set test Variable    ${tti_title_tag}		tti_bler_SA_r2_NSA_r11_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_case6_simple_reTx_pair_rank_112.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     
# #================SA Register==============
# UE from '${lo}' to '${hi}' SA Register
#     : FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     #\   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}--Register SA UE ${num} --
#     \   Airphone SA Attach    ue_id=${num}
# 	\   Wait '2s' for stabible
#        #set_pdu_param ue=1 pdu=1 trf_type=internal
#        #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     \   Airphone Set Traffic Type    ${num}    ${num}    internal
#     \   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
#     \   Wait '3s' for stabible
#     #\   get UE '${num}' rnti in RRC log
# 
# send ul data from UE '${lo}' to '${hi}'  
# 	: FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     \   DL and UL data to '${num}'    
# DL and UL data to '${UE_ID}'
#     #Airphone SA Start Data Traffic    ${UE_ID}    DL   5M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Airphone SA Start Data Traffic    ${UE_ID}    UL   30M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     Wait '3s' for stabible
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${UE_ID}  	pdu_id= ${UE_ID}
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
# 
# #================NSA attach==========
# UE from '${lo}' to '${hi}' NSA Attach and check
# 	: FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
# 	\    Log To Console   ${\n}--Attach NSA UE ${num} --
# 	#\   airphone_cleanup_egate_console_log
# 	\	Airphone Nsa Attach     ${num}    profile_id=None
# 	\	Wait '2s' for stabible
# 	
# NSA send ul data to UE'${UE_ID}'
# 	NSA send ue '${UE_ID}' mutiple trf '1' for each '30M' UL data
# 	Wait '2s' for stabible
# 	${pcell_tp}	Get cell ul throught	${UE_ID}    8
# 	${ul_tput_Mb}    evaluate    ${pcell_tp}/1000
# 	Log To Console    UE${UE_ID}_ul_tp ${ul_tput_Mb}M--
# 
# delete profile_1_2
# 	Airphone Execute Egate Command    ${delete_PROFILE1}
# 	Airphone Execute Egate Command    ${delete_PROFILE2}
# delete profile_13_14
# 	Airphone Execute Egate Command    ${delete_PROFILE13}
# 	Airphone Execute Egate Command    ${delete_PROFILE14}	
# delete profile_5_11
# 	Airphone Execute Egate Command    ${delete_PROFILE5}
# 	Airphone Execute Egate Command    ${delete_PROFILE11}
# delete profile_1_2_11
# 	Airphone Execute Egate Command    ${delete_PROFILE1}
# 	Airphone Execute Egate Command    ${delete_PROFILE2}
# 	Airphone Execute Egate Command    ${delete_PROFILE11}
# delete profile_5_13_14
# 	Airphone Execute Egate Command    ${delete_PROFILE5}
# 	Airphone Execute Egate Command    ${delete_PROFILE13}
# 	Airphone Execute Egate Command    ${delete_PROFILE14}
# 	
# deactive profile_12_1314
# 	Airphone Execute Egate Command    ${deactive_PROFILE1}
# 	Airphone Execute Egate Command    ${deactive_PROFILE2}
# 	Airphone Execute Egate Command    ${deactive_PROFILE13}
# 	Airphone Execute Egate Command    ${deactive_PROFILE14}
# 	Wait '2s' for stabible
# deactive profile_5_11
# 	Airphone Execute Egate Command    ${deactive_PROFILE5}
# 	Airphone Execute Egate Command    ${deactive_PROFILE11}
# 	Wait '2s' for stabible
# deactive profile_1_2_11
# 	Airphone Execute Egate Command    ${deactive_PROFILE1}
# 	Airphone Execute Egate Command    ${deactive_PROFILE2}
# 	Airphone Execute Egate Command    ${deactive_PROFILE11}
# 	Wait '2s' for stabible
# deactive profile_5_1314
# 	Airphone Execute Egate Command    ${deactive_PROFILE5}
# 	Airphone Execute Egate Command    ${deactive_PROFILE13}
# 	Airphone Execute Egate Command    ${deactive_PROFILE14}
# 	Wait '2s' for stabible
# deactive profile_1_2
# 	Airphone Execute Egate Command    ${deactive_PROFILE1}
# 	Airphone Execute Egate Command    ${deactive_PROFILE2}
# 	Wait '2s' for stabible
# deactive profile_13_14
# 	Airphone Execute Egate Command    ${deactive_PROFILE13}
# 	Airphone Execute Egate Command    ${deactive_PROFILE14}
# 	Wait '2s' for stabible
# Register_UE1	
# 	UE from '1' to '1' SA Register
# 	Set UE1 position
# 	send ul data from UE '1' to '1'	
# Register_UE2	
# 	UE from '2' to '2' SA Register
# 	Set UE2 position
# 	send ul data from UE '2' to '2'
# Register_UE5	
# 	UE from '5' to '5' SA Register
# 	Set UE5 position
# 	send ul data from UE '5' to '5'
# Attach_UE13
# 	UE from '13' to '13' NSA Attach and check
# 	Set UE13 position
# 	NSA send ul data to UE'13'
# Attach_UE14
# 	UE from '14' to '14' NSA Attach and check
# 	Set UE14 position
# 	NSA send ul data to UE'14'
# Attach_UE11
# 	UE from '11' to '11' NSA Attach and check
# 	Set UE11 position
# 	NSA send ul data to UE'11'
# 	
# Set UE1 position
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Wait '2s' for stabible
# Set UE2 position
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}
#     Wait '2s' for stabible
# Set UE5 position
#     Airphone Execute Egate Command    ${PROFILE5}
#     Airphone Execute Egate Command    ${SET_PROFILE5}
#     Wait '2s' for stabible
# Set UE11 position
#     Airphone Execute Egate Command    ${PROFILE11}
#     Airphone Execute Egate Command    ${SET_PROFILE11}
#     Wait '2s' for stabible
# Set UE13 position
#     Airphone Execute Egate Command    ${PROFILE13}
#     Airphone Execute Egate Command    ${SET_PROFILE13}
#     Wait '2s' for stabible
# Set UE14 position
#     Airphone Execute Egate Command    ${PROFILE14}
#     Airphone Execute Egate Command    ${SET_PROFILE14}
#     Wait '2s' for stabible
# 
# check tti no bler_with_passratio_'${pass_ratio}'
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti'
# 	
# 	Log To Console   ${\n}---check tti---
# 	Set test Variable    ${tti_title_tag}		tti_ul.csv
# 	Set test Variable    ${pass_ratio_ini}		${pass_ratio}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_check_bler_ratio.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# 
# 
# #check throughput
# check throughput from SA UE '${low}' to '${hi}' with tp '${ul_cell_tp}'
# 	Wait '3s' for stabible
# 	${cell_tp_ul}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   Log To Console    Check throughput UE${num}
#     \      ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pusch    tput_type=ave
#     \      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     \      Log To Console		ul ${ul_tput_Mb}
#     \      ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}
#     Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
#     run keyword and continue on failure    should be true    ${cell_tp_ul}>=${ul_cell_tp}
# 
# check throughput from NSA UE '${low}' to '${hi}' with tp '${ul_cell_tp}'
#     Wait '3s' for stabible
#     ${cell_tp_ul}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \	${pcell_tp}	Get cell ul throught	${num}    8
# 	\	${ul_tput_Mb}    evaluate    ${pcell_tp}/1000
# 	\	Log To Console    UE${num}_ul_tp ${ul_tput_Mb}M--
# 	\   ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}
# 	Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
# 	run keyword and continue on failure    should be true    ${cell_tp_ul}>=${ul_cell_tp}
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
# 
# Dettach UE from '${low}' to '${hi}'
# 	: FOR    ${num}    IN RANGE    ${low}    ${hi}+1
# 	\	Airphone NSA Detach    ue_id= ${num}
# 	\   Wait '3s' for stabible
# 
# 
# get UE '${ue_id}' rnti in RRC log
#     Log To Console   ${\n}===get UE'${ue_id}' rnti===
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
# 
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001   crnti: (\\d+)
#     run keyword if    ${ue_id}==1   Set test Variable	 ${rnti_1} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==1	  Log To Console    --rnti ${rnti_1}--
#     run keyword if    ${ue_id}==2   Set test Variable	 ${rnti_2} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==2	  Log To Console    --rnti ${rnti_2}--
#     run keyword if    ${ue_id}==3   Set test Variable	 ${rnti_3} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==3	  Log To Console    --rnti ${rnti_3}--
#     run keyword if    ${ue_id}==4   Set test Variable	 ${rnti_4} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==4	  Log To Console    --rnti ${rnti_4}--
#     run keyword if    ${ue_id}==5   Set test Variable	 ${rnti_5} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==5	  Log To Console    --rnti ${rnti_5}--
#     run keyword if    ${ue_id}==6   Set test Variable	 ${rnti_6} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==6	  Log To Console    --rnti ${rnti_6}--
#     run keyword if    ${ue_id}==7   Set test Variable	 ${rnti_7} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==7	  Log To Console    --rnti ${rnti_7}--
#     run keyword if    ${ue_id}==8   Set test Variable	 ${rnti_8} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==8	  Log To Console    --rnti ${rnti_8}--
#     run keyword if    ${ue_id}==9   Set test Variable	 ${rnti_9} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==9	  Log To Console    --rnti ${rnti_9}--
#     run keyword if    ${ue_id}==10   Set test Variable	 ${rnti_10} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==10	  Log To Console    --rnti ${rnti_10}--
#     run keyword if    ${ue_id}==11   Set test Variable	 ${rnti_11} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==11   Log To Console    --rnti ${rnti_11}--
#     run keyword if    ${ue_id}==12   Set test Variable	 ${rnti_12} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==12   Log To Console    --rnti ${rnti_12}--
#     run keyword if    ${ue_id}==13   Set test Variable	 ${rnti_13} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==13   Log To Console    --rnti ${rnti_13}--
#     run keyword if    ${ue_id}==14   Set test Variable	 ${rnti_14} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==14   Log To Console    --rnti ${rnti_14}--
# #===================US not in use =====================
# #US 6
# trigger ul bler 2 rank1 UE
#     Log To Console   ${\n}<<US1-----SA_R1_R1 + NSA_R1_R1-----Pair_2>>
# 	airphone_cleanup_egate_console_log
# 	UE from '1' to '2' SA Register and check
# 	UE from '13' to '14' NSA Attach and check
#     #run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s    check throughput from UE '4' to '5' with tp '30'
# 
# 	Log To Console   ${\n}---trigger ul bler: bler_2_rank1---
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=40,40
# 	Wait '1s' for stabible
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=13 scell\=8 testmode\=bler profile_id\=1 action\=activate
# 	Wait '1s' for stabible
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_bler_rank1_UE_1_13'
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=13 scell\=8 testmode\=bler profile_id\=1 action\=deactivate
# 
# 	DeRegister UE from '1' to '2'
# 	Dettach UE from '13' to '14'
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_6   unzip=TRUE
# 
# 	Log To Console   ${\n}---check tti ---
# 	Set test Variable    ${tti_title_tag}		tti_bler_rank1_UE_1_13_ul.csv
# 
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_case5_simple_reTx_pair_2UE.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# #US 7
# trigger ul bler SA rank1 and NSA rank2
#      Log To Console   ${\n}<<US7-----SA_R1 + NSA_R2----->>
# 	airphone_cleanup_egate_console_log
# 	UE from '1' to '1' SA Register and check
# 	UE from '11' to '11' NSA Attach and check
# 	#run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s    check throughput from UE '4' to '5' with tp '30'
# 
# 	Log To Console   ${\n}---trigger ul bler: SA rank1 and NSA rank2---
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=40,40
# 	Wait '1s' for stabible
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=11 scell\=8 testmode\=bler profile_id\=1 action\=activate
# 	Wait '1s' for stabible
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_bler_rank1_UE1_rank2_UE11'
# 
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=11 scell\=8 testmode\=bler profile_id\=1 action\=deactivate
# 	DeRegister UE from '1' to '1'
# 	Dettach UE from '11' to '11'
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_7   unzip=TRUE
# 
# 	Log To Console   ${\n}---check tti ---
# 	Set test Variable    ${tti_title_tag}		tti_bler_rank1_UE1_rank2_UE11_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_case5_simple_reTx_pair_rank12.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# check no bler before trigger by AP command
# 	Log To Console   ${\n}<<---check no bler before trigger by AP command--->>
# 	Start capture gnb and ap syslog in '0' file
# 	#airphone_cleanup_egate_console_log
# 	Set test Variable	${SA_lo}		1
# 	Set test Variable	${SA_hi}		1
# 	Set test Variable	${NSA_lo}		13
# 	Set test Variable	${NSA_hi}		13
# 	Start collect bip log
# 
# 	UE from '${SA_lo}' to '${SA_hi}' SA Register and check	#SA   rank1 + rank2
# 	UE from '${NSA_lo}' to '${NSA_hi}' NSA Attach and check	#NSA  rank1 + rank2
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti'
# 	Wait for '0s' to stop bip log with name'gnb_BIP'
# 
# 	DeRegister UE from '${SA_lo}' to '${SA_hi}'
# 	Dettach UE from '${NSA_lo}' to '${NSA_hi}'
# 	#airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_0   unzip=TRUE
# 	Log To Console   ${\n}---check tti---
# 	Set test Variable    ${tti_title_tag}		tti_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_check_no_bler.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     run keyword and continue on failure	   Stop capture gnb and ap syslog in '0' file
