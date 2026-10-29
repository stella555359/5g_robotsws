# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    AP   CRT   SBTS00   RAN_5G_TDD  RAN_5G  owner_zhang	SBTS23R1
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# 
# #test with 100M:
# #${SCFC_NAME}      SCFC_8360_B_case5_1208_100M.xml
# #${AIRPHONE_NAME}    IPHY_AEQB_1CELL_2subcell_case5.xml
# 
# #test with 20M:(in use)
# ${SCFC_NAME}      SCFC_8360_B_case6_1208_20M_AL1_4UE.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL_2subcell_case6.xml
# 
# #common for 100M and 20M
# ${L1BYP_XML}    L1By_8360_B_case5.xml
# ${WTS_NAME}    wts_8360_B_case5.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# *** Test Cases ***
# CB008360_B_B3b_case06_four_rank1_SA_NSA_Ues_Max_4Layer_with_retransmission_without_tapering
#     Upload airphone l1bypass to iphy	
# 	Prepare gnb onair
# 
# 	check no bler before bler testmode US1
# 	Start capture gnb and ap syslog in '1' file
# 	trigger ul bler 4 rank1 pair_234		#OK
# 	run keyword and continue on failure	   Stop capture gnb and ap syslog in '1' file
# 
# 	check no bler before bler testmode US2
# 	Start capture gnb and ap syslog in '2' file
# 	trigger ul bler SA rank2 and NSA rank2		#OK
# 	run keyword and continue on failure	   Stop capture gnb and ap syslog in '2' file
# 
# 	check no bler before bler testmode US3
# 	Start capture gnb and ap syslog in '3' file
# 	trigger ul bler SA 2 rank1 and NSA rank2		#OK
# 	run keyword and continue on failure	   Stop capture gnb and ap syslog in '3' file
# 
# 	check no bler before bler testmode US4
# 	Start capture gnb and ap syslog in '4' file
# 	trigger ul bler SA rank2 and NSA 2 rank1		#OK
# 	run keyword and continue on failure	   Stop capture gnb and ap syslog in '4' file
# 
# *** Keywords ***
# #SA		UE:1~4  (rank1)		5~10 (rank2)
# #NSA	UE:11~12(rank2)		13~14(rank1)
# 
# check tti no bler
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti'
# 
# 	Log To Console   ${\n}---check tti---
# 	Set test Variable    ${tti_title_tag}		tti_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_check_no_bler.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# check no bler before bler testmode US1
#     UE from '1' to '2' SA Register and check
#     UE from '13' to '14' NSA Attach and check
#     run keyword and continue on failure	   Wait Until Keyword Succeeds    30s    2s   check throughput from SA UE '1' to '2' with tp '23'
#     run keyword and continue on failure	   Wait Until Keyword Succeeds    30s    2s   check throughput from NSA UE '13' to '14' with tp '23'
#     run keyword and continue on failure	   check tti no bler
#     DeRegister UE from '1' to '2'
#     Dettach UE from '13' to '14'
# 
# #1
# trigger ul bler 4 rank1 pair_234
#     Log To Console   ${\n}<<US1-----SA_R1_R1 + NSA_R1_R1-----Pair_123>>
# 	#airphone_cleanup_egate_console_log
# 	UE from '1' to '2' SA Register and check
# 	UE from '13' to '14' NSA Attach and check
# 
# 	Log To Console   ${\n}---bler 4 UE---
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=500,500
# 	Wait '1s' for stabible
# 	#airphone_execute_egate_command	ue_testmode_set_nr id\=1,2 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	#airphone_execute_egate_command	ue_testmode_set_nr id\=13,14 scell\=8 testmode\=bler profile_id\=1 action\=activate
# 	#airphone_execute_egate_command	ue_testmode_set_nr id\=14 scell\=8 testmode\=bler profile_id\=1 action\=activate
# 	
# 	Start collect ttitrace
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=13,14 scell\=8 testmode\=bler profile_id\=1 action\=activate
# 	Wait for '2s' to stop ttitrace with name'tti_bler_rank1_UE_1_2_13_14'
# 	
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1,2 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=13,14 scell\=8 testmode\=bler profile_id\=1 action\=deactivate
# 
# 	DeRegister UE from '1' to '2'
# 	Dettach UE from '13' to '14'
# 	#airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_1   unzip=TRUE
# 	
# 	Log To Console   ${\n}---check tti---
# 	Set test Variable    ${tti_title_tag}		tti_bler_rank1_UE_1_2_13_14_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_case5_simple_reTx_pair_234UE.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# check no bler before bler testmode US2
# 	UE from '5' to '5' SA Register and check
# 	UE from '11' to '11' NSA Attach and check
# 	run keyword and continue on failure	   Wait Until Keyword Succeeds    30s    2s   check throughput from SA UE '5' to '5' with tp '23'
#      run keyword and continue on failure	   Wait Until Keyword Succeeds    30s    2s   check throughput from NSA UE '11' to '11' with tp '23'
#      run keyword and continue on failure	   check tti no bler
#      DeRegister UE from '5' to '5'
# 	Dettach UE from '11' to '11'
# 	
# #2
# trigger ul bler SA rank2 and NSA rank2
#     Log To Console   ${\n}<<US3-----SA_R2 + NSA_R2----->>
# 	#airphone_cleanup_egate_console_log
# 	UE from '5' to '5' SA Register and check
# 	UE from '11' to '11' NSA Attach and check	
# 	
# 	Log To Console   ${\n}---bler 2 UE---
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=400,400
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=5 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=11 scell\=8 testmode\=bler profile_id\=1 action\=activate
# 	Wait '1s' for stabible	
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_bler_Rank2_UE_5_11'	
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=5 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=11 scell\=8 testmode\=bler profile_id\=1 action\=deactivate
# 	DeRegister UE from '5' to '5'
# 	Dettach UE from '11' to '11'
# 	#airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_3   unzip=TRUE
# 	
# 	Log To Console   ${\n}---check tti ---
# 	Set test Variable    ${tti_title_tag}		tti_bler_Rank2_UE_5_11_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_case5_simple_reTx_pair_rank22.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# check no bler before bler testmode US3
# 	UE from '1' to '2' SA Register and check
# 	UE from '11' to '11' NSA Attach and check
# 	run keyword and continue on failure	   Wait Until Keyword Succeeds    30s    2s   check throughput from SA UE '1' to '2' with tp '23'
#      run keyword and continue on failure	   Wait Until Keyword Succeeds    30s    2s   check throughput from NSA UE '11' to '11' with tp '23'
#      run keyword and continue on failure	   check tti no bler
#      DeRegister UE from '1' to '2'
# 	Dettach UE from '11' to '11'
# 	
# #3
# trigger ul bler SA 2 rank1 and NSA rank2
#     Log To Console   ${\n}<<US4-----SA_R1_R1 + NSA_R2----->>
# 	#airphone_cleanup_egate_console_log
# 	UE from '1' to '2' SA Register and check
# 	UE from '11' to '11' NSA Attach and check
# 	
# 	Log To Console   ${\n}---bler 3 UE---
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=400,400	
# 	Wait '1s' for stabible	
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1,2 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=11 scell\=8 testmode\=bler profile_id\=1 action\=activate
# 	Wait '1s' for stabible	
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_bler_SA_r11_NSA_r2'	
# 	
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1,2 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=11 scell\=8 testmode\=bler profile_id\=1 action\=deactivate
# 	DeRegister UE from '1' to '2'
# 	Dettach UE from '11' to '11'
# 	#airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_4   unzip=TRUE
# 
# 	Log To Console   ${\n}---check tti ---
# 	Set test Variable    ${tti_title_tag}		tti_bler_SA_r11_NSA_r2_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_case6_simple_reTx_pair_rank_112.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# check no bler before bler testmode US4
# 	UE from '5' to '5' SA Register and check
# 	UE from '13' to '14' NSA Attach and check
# 	run keyword and continue on failure	   Wait Until Keyword Succeeds    30s    2s   check throughput from SA UE '5' to '5' with tp '23'
# 	run keyword and continue on failure	   Wait Until Keyword Succeeds    30s    2s   check throughput from NSA UE '13' to '14' with tp '23'
# 	run keyword and continue on failure	   check tti no bler
# 	DeRegister UE from '5' to '5'
# 	Dettach UE from '13' to '14'
# 	
# #4
# trigger ul bler SA rank2 and NSA 2 rank1
#     Log To Console   ${\n}<<US5-----SA_R2 + NSA_R1_R1----->>
# 	#airphone_cleanup_egate_console_log
# 	UE from '5' to '5' SA Register and check
# 	UE from '13' to '14' NSA Attach and check
# 
# 	Log To Console   ${\n}---bler 3 UE ---
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=400,400	
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
# 	#airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_5   unzip=TRUE
# 
# 	Log To Console   ${\n}---check tti ---
# 	Set test Variable    ${tti_title_tag}		tti_bler_SA_r2_NSA_r11_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_case6_simple_reTx_pair_rank_112.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# #================SA Register==============
# UE from '${lo}' to '${hi}' SA Register and check
#     : FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}--Register SA UE ${num} --
#     \   Airphone SA Attach    ue_id=${num}
#        #set_pdu_param ue=1 pdu=1 trf_type=internal
#        #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     \   Airphone Set Traffic Type    ${num}    ${num}    internal
#     \   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
#     \   Wait '3s' for stabible
#     \   UL data to '${num}'
#     #\   get UE '${num}' rnti in RRC log
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
# 
# UL data to '${UE_ID}'
#     Airphone SA Start Data Traffic    ${UE_ID}    UL   30M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     #Airphone SA Start Data Traffic    ${UE_ID}    UL   175M   pdu_id=${UE_ID}   duration=7200   trf_id=2
#     Wait '2s' for stabible
#      ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pusch    tput_type=ave
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console    UE${UE_ID}_ul ${ul_tput_Mb}M
# 
# #================NSA attach==========
# UE from '${lo}' to '${hi}' NSA Attach and check
# 	: FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
# 	\    Log To Console   ${\n}--Attach NSA UE ${num} --
# 	\   airphone_cleanup_egate_console_log
# 	\	Airphone Nsa Attach     ${num}    profile_id=None
# 	\	Wait '2s' for stabible
# 	\	NSA send ue '${num}' mutiple trf '1' for each '30M' UL data
# 	\	Wait '2s' for stabible
# 	\	${pcell_tp}	Get cell ul throught	${num}    8
# 	\	${ul_tput_Mb}    evaluate    ${pcell_tp}/1000
# 	\	Log To Console    UE${num}_ul_tp ${ul_tput_Mb}M--
# 	#\   get UE '${num}' rnti in RRC log
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
