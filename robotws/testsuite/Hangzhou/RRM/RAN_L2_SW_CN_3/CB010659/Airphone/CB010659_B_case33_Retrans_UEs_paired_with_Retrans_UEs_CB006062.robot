# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    AP   CRT   SBTS00   RAN_5G_TDD  RAN_5G  owner_zhang   SBTS23R1
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# 
# #test with 80M:
# ${SCFC_NAME} 	    SCFC_10659_1070_80M_B_case33_LOAPLO.xml
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
# &{GNBMIRRORINGCONFIGS}    NUMBER_OF_FILES=30	FILE_SIZE_MBYTES=200
# #23 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# #33
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# #00 
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# #10
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# #23 
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# #33
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# #00 
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# #10
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# ${SET_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
# ${SET_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
# ${deactive_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=1
# ${deactive_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2
# ${deactive_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=3
# ${deactive_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=4
# ${deactive_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=5
# ${deactive_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=6
# ${deactive_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=7
# ${deactive_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=8
# ${delete_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 delete\=true
# ${delete_PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 delete\=true
# ${delete_PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 delete\=true
# ${delete_PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 delete\=true
# *** Test Cases ***
# CB010659_B_case33_TDD_Retrans_UEs_paired_with_Retrans_UEs_CB006062
# 	add_RD_MCS_fix_26
# 	Get and Update BSR File		par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001 
# 	Prepare gnb onair
# 	D_4UE_data_diff	
# 		
# *** Keywords ***
# add_RD_MCS_fix_26
# 	#rdActUlAdaptiveReTxResMcsWithMuMimo   
# 	Add GNB swconfig	 0x58061A:1
# 	#rdSupportedUl256QamMcs RAD param MCS=26
# 	Add GNB swconfig	 0x580367:0x4000000
# 
# D_4UE_data_diff
# 	Start capture gnb and ap syslog in 'sys' file
# 	Register_UE1
# 	Register_UE2
# 	Register_UE3
# 	Register_UE4
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    10s    2s   check throughput from UE '1' to '4' with tp '240'
# 	run keyword and continue on failure 	check tti no bler_with_passratio_'1'
# 	run keyword and continue on failure 	Stop capture gnb and ap syslog in 'sys' file
# 	
# 	Start capture gnb and ap syslog in 'sys_bler' file
# 	trigger ul bler
# 	trigger DTX
# 	check tti after bler
# 	run keyword and continue on failure	   Stop capture gnb and ap syslog in 'sys_bler' file
# 	
# 	deactive ul bler
# 	deactive DTX
# 	DeRegister UE from '1' to '4'
# 	delete profile_1_4
# 	#deactive profile_1_4
# 	
# trigger ul bler
# 	Log To Console   ${\n}---trigger ul bler---
# 	Airphone Execute Egate Command	ul_sinr_testmode_nr profile_id\=1 sinr_target_pusch\=-370
# 	Airphone Execute Egate Command	ue_testmode_set_nr id\=1-4 testmode\=ul_sinr profile_id\=1 action\=activate
# 	Wait '3s' for stabible
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    10s    2s   check throughput from UE '1' to '4' with tp '70'
# 
# deactive ul bler
# 	Airphone Execute Egate Command	ue_testmode_set_nr id\=1-4 testmode\=ul_sinr profile_id\=1 action\=deactivate
# trigger DTX
# 	Log To Console   ${\n}---FDD ul DTX---
# 	airphone_execute_egate_command	forced_dtx_testmode_nr profile_id\=1 force_dtx_pusch\=3000:5
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1-4 testmode\=forced_dtx profile_id\=1 action\=activate
# 	Wait '2s' for stabible
# deactive DTX
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1-4 testmode\=forced_dtx profile_id\=1 action\=deactivate
# 	  
# check tti after bler
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_B_case33'
# 	
# 	Log To Console   ${\n}---check tti----
# 	Set test Variable    ${tti_title_tag}	  tti_B_case33_ul.csv
# 	Set test Variable    ${reserved_MCS}	31
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_case33.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# 	run keyword and continue on failure   check_reTx_status_and_reservedMCS   ${TEST_LOG_DIRECTORY()}/All/tti_B_case33_ul.csv   0.75   0.5
# 	run keyword and continue on failure   check_maxCodeRatePRB   ${TEST_LOG_DIRECTORY()}/All/tti_B_case33_ul.csv   1.3
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
# 
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
# 
# delete profile_1_4
# 	Airphone Execute Egate Command    ${delete_PROFILE1}
# 	Airphone Execute Egate Command    ${delete_PROFILE2}
# 	Airphone Execute Egate Command    ${delete_PROFILE3}
# 	Airphone Execute Egate Command    ${delete_PROFILE4}
# deactive profile_1_4
# 	Airphone Execute Egate Command    ${deactive_PROFILE1}
# 	Airphone Execute Egate Command    ${deactive_PROFILE2}
# 	Airphone Execute Egate Command    ${deactive_PROFILE3}
# 	Airphone Execute Egate Command    ${deactive_PROFILE4}
# 	Wait '2s' for stabible	    
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1  
#     \   Log To Console		=====deRegister UE${num}======
#     \   run keyword and continue on failure 	airphone_sa_detach    ue_id=${num}    timeout=10
#     \   Wait '2s' for stabible
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
#     run keyword if    ${UE_ID}==1		Airphone SA Start Data Traffic    ${UE_ID}    UL   120M	pdu_id=${UE_ID}   duration=7200   trf_id=1
#     run keyword if    ${UE_ID}==2		Airphone SA Start Data Traffic    ${UE_ID}    UL   40M	pdu_id=${UE_ID}   duration=7200   trf_id=1
#     run keyword if    ${UE_ID}==3		Airphone SA Start Data Traffic    ${UE_ID}    UL   40M	pdu_id=${UE_ID}   duration=7200   trf_id=1
#     run keyword if    ${UE_ID}==4		Airphone SA Start Data Traffic    ${UE_ID}    UL   40M	pdu_id=${UE_ID}   duration=7200   trf_id=1   
#     Wait '3s' for stabible
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
