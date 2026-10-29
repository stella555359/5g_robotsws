# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    AP   CRT   SBTS00   RAN_5G_TDD  RAN_5G  owner_zhang   SBTS23R1
# ...   CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# 
# #test with 80M:
# ${SCFC_NAME} 	    SCFC_8360_D_1070_80M_case3_MOAPLO.xml
# #deltasinrmax=0, for high bler cause low sinr
# ${AIRPHONE_NAME}    IPHY_AEQE_1CELL_8D8U_LOAPLO.xml
# ${WTS_NAME}    wts_8360_C_case2_LOAPLO.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# 
# #filter:CRC_NOK
# ${FILTER_1}	(uldata_puschreceiverespharqu) && (UlData_UePuschReceiveRespHarqU_t.crc == 1)
# @{titles_1}	UlData_UePuschReceiveRespHarqU_t.dtx
# 
# #23 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# #33
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# #00 
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# #10
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# #23 
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# #33
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# #00 
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# #10
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# ${SET_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
# ${SET_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
# ${delete_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 delete\=true
# ${delete_PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 delete\=true
# ${delete_PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 delete\=true
# ${delete_PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 delete\=true
# ${delete_PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 delete\=true
# ${delete_PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 delete\=true
# ${delete_PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 delete\=true
# ${delete_PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 delete\=true
# ${deactive_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=1
# ${deactive_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2
# ${deactive_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=3
# ${deactive_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=4
# ${deactive_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=5
# ${deactive_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=6
# ${deactive_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=7
# ${deactive_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=8
# *** Test Cases ***
# CB008360_D_B2b_case03_Retrans_UEs_paired_with_Retrans_UEs_CB006062
# 	Get and Update BSR File		par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001 
# 	Prepare gnb onair
# 	D_8UE_data_diff	
# 		
# *** Keywords ***
# D_8UE_data_diff
# 	Start capture gnb and ap syslog in 'sys' file
# 	Register_UE1
# 	Register_UE2
# 	Register_UE3
# 	Register_UE4
# 	Register_UE5
# 	Register_UE6
# 	Register_UE7
# 	Register_UE8	
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '1' to '8' with tp '430'
# 	run keyword and continue on failure 	check tti no bler_with_passratio_'1'
# 	run keyword and continue on failure 	Stop capture gnb and ap syslog in 'sys' file
# 	
# 	Start capture gnb and ap syslog in 'sys_bler' file
# 	bler_1
# 	run keyword and continue on failure	   Stop capture gnb and ap syslog in 'sys_bler' file
# 	
# 	DeRegister UE from '1' to '8'
# 	delete profile_1_8
# 
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
# Register_UE7	
# 	UE from '7' to '7' SA Register
# 	Set UE7 position
# 	send ul data from UE '7' to '7'
# Register_UE8	
# 	UE from '8' to '8' SA Register
# 	Set UE8 position
# 	send ul data from UE '8' to '8'
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
# Set UE7 position
#     Airphone Execute Egate Command    ${PROFILE7}
#     Airphone Execute Egate Command    ${SET_PROFILE7}
#     Wait '2s' for stabible
# Set UE8 position
#     Airphone Execute Egate Command    ${PROFILE8}
#     Airphone Execute Egate Command    ${SET_PROFILE8}
#     Wait '2s' for stabible
# delete profile_1_8
# 	Airphone Execute Egate Command    ${delete_PROFILE1}
# 	Airphone Execute Egate Command    ${delete_PROFILE2}
# 	Airphone Execute Egate Command    ${delete_PROFILE3}
# 	Airphone Execute Egate Command    ${delete_PROFILE4}
#     Airphone Execute Egate Command    ${delete_PROFILE5}
# 	Airphone Execute Egate Command    ${delete_PROFILE6}
# 	Airphone Execute Egate Command    ${delete_PROFILE7}
# 	Airphone Execute Egate Command    ${delete_PROFILE8}
# deactive profile_1_8
# 	Airphone Execute Egate Command    ${deactive_PROFILE1}
# 	Airphone Execute Egate Command    ${deactive_PROFILE2}
# 	Airphone Execute Egate Command    ${deactive_PROFILE3}
# 	Airphone Execute Egate Command    ${deactive_PROFILE4}
# 	Airphone Execute Egate Command    ${deactive_PROFILE5}
# 	Airphone Execute Egate Command    ${deactive_PROFILE6}
# 	Airphone Execute Egate Command    ${deactive_PROFILE7}
# 	Airphone Execute Egate Command    ${deactive_PROFILE8}
# 	Wait '2s' for stabible	    
# 	
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     
#     #\   airphone_execute_egate_command	   ue_pdu_session_release ue\=${num} pdu\=${num}
#     #\   Wait '2s' for stabible
#     \   Log To Console		=====deRegister UE${num}======
#     \   run keyword and continue on failure 	airphone_sa_detach    ue_id=${num}    timeout=10
#     \   Wait '2s' for stabible
# 	
# #position
# #UE1_4;5_8(0,0),(8,0)(19,0)(0,7)   al rank2
# bler_1
# 	Log To Console   ${\n}---trigger ul bler 100_100---
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=300,300
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1-8 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	Wait '1s' for stabible
# 	check tti ReRe and CDMgroup
# 	
# 	Log To Console   ${\n}---dellete bler testmode---
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1-8 scell\=0 testmode\=bler profile_id\=1 action\=deactivate	
# 	#airphone_execute_egate_command    bler_testmode_nr profile_id\=1 delete\=yes 
# 
# check tti no bler_with_passratio_'${pass_ratio}'
# 	Start collect ttitrace
# 	Wait for '4s' to stop ttitrace with name'tti'
# 	
# 	Log To Console   ${\n}---check tti---
# 	Set test Variable    ${tti_title_tag}		tti_ul.csv
# 	Set test Variable    ${pass_ratio_ini}		${pass_ratio}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_check_bler_ratio.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_D_case3_GroupParing.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# check tti ReRe and CDMgroup
# 	Log To Console   ${\n}---check tti ReRe_pair---
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_ReRe'
# 	
# 	Set test Variable    ${tti_title_tag}		tti_ReRe_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_D_case3_ReRe_pair.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     
# UE from '${lo}' to '${hi}' SA Register
# 	#Start collect bip log
#     : FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     #\   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}--Register SA UE ${num} --
#     \   Airphone SA Attach    ue_id=${num}
#        #set_pdu_param ue=1 pdu=1 trf_type=internal
#        #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     \   Airphone Set Traffic Type    ${num}    ${num}    internal
#     \   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
#     \   Wait '3s' for stabible
# send ul data from UE '${lo}' to '${hi}'  
# 	: FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     \   DL and UL data to '${num}'    
# DL and UL data to '${UE_ID}'
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   5M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     run keyword if    (${UE_ID}==1)|(${UE_ID}==5)	Airphone SA Start Data Traffic    ${UE_ID}    UL   160M   pdu_id=${UE_ID}   
#    ...    duration=7200   trf_id=1
#     run keyword if    (${UE_ID}!=1)&(${UE_ID}!=5)	Airphone SA Start Data Traffic    ${UE_ID}    UL   40M   pdu_id=${UE_ID}   
#    ...    duration=7200   trf_id=1
#     Wait '4s' for stabible
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${UE_ID}  	pdu_id= ${UE_ID}
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
# 
# #SA	: UE 1~8 rank2	
# 	
# #check throughput
# check throughput from UE '${low}' to '${hi}' with tp '${ul_cell_tp}'
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
# 
# get UE '${ue_id}' rnti in RRC log
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
