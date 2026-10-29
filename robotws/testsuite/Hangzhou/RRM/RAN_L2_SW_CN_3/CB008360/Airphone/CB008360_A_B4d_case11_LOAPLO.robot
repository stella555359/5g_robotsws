# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_zhang    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_frame_1208_case11_LOAPLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_1CELL_8D4U_LOAPLO.xml
# ${WTS_NAME}    wts_8360_case1_LOAPLO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# 
# @{titles_1}    DlData_DciInfo.patternId_item    3gpp.rnti
# @{titles_2}    DlData_PdschGrant.patternId_item     3gpp.rnti
# @{titles_3}    DlData_CsiRsResource_t.patternId_item    DlData_CsiRsResource_t.density
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# ...    NUMBER_OF_FILES=30
# #command
# 
# ${phr_override_profile_1_CMD}    phr_override_testmode_nr profile_id\=1 phr_mode\=Fixed phr_start\=-23
# ...    phr_min\=-23 phr_max\=40 phr_step_size\=1 phr_period\=20 pc_max\=30
# 
# ${phr_activate_p1_CMD}    ue_testmode_set_nr id\=1-3 scell\=primary testmode\=phr_override profile_id\=1 action\=activate
# 
# ${phr_deactivate_p1_CMD}    ue_testmode_set_nr id\=1-3 scell\=primary testmode\=phr_override profile_id\=1 action\=deactivate
# 
# #4 UE pair  phr=2
# ${phr_override_profile_2_CMD}    phr_override_testmode_nr profile_id\=2 phr_mode\=Fixed phr_start\=2
# ...    phr_min\=2 phr_max\=40 phr_step_size\=1 phr_period\=20 pc_max\=30
# 
# ${phr_activate_p2_CMD}      ue_testmode_set_nr id\=1-3 scell\=primary testmode\=phr_override profile_id\=2 action\=activate
# ${phr_deactivate_p2_CMD}    ue_testmode_set_nr id\=1-3 scell\=primary testmode\=phr_override profile_id\=2 action\=deactivate
# 
# #02 OK
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0
# #12
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0
# #20 OK
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# #33
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${deactive_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=1
# ${deactive_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2
# ${deactive_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=3
# ${deactive_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=4
# ${delete_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 delete\=true
# ${delete_PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 delete\=true
# ${delete_PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 delete\=true
# ${delete_PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 delete\=true
# *** Test Cases ***
# CB008360_A_B4d_case11_4_rank1_Mix_Ues_paired_MCS_compensate
# 	#Active GNB L2 feature debug traces
# 	Get and Update BSR File		par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001    			
# 	Prepare gnb onair   
# 	Start capture gnb and ap syslog in 'SYSLOG' file	
# 	test_UE1
# 	test_UE2
# 	test_UE3
# 	test_UE4	
# 	run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '1' to '4' with tp '148'
# 	phr override Fixed MCS	
#      
# 	DeRegister UE from '1' to '4'
# 	delete profile_1_4
# 	#deactive profile1234
# 	run keyword and continue on failure    Stop capture gnb and ap syslog in 'SYSLOG' file
# *** Keywords ***
# phr override Fixed MCS
# 	Log To Console    --phr_set_phr_override_profile 1--
# 	airphone_execute_egate_command   ${phr_override_profile_2_CMD}
# 	Log To Console    --phr_override_activate 1--
# 	airphone_execute_egate_command   ${phr_activate_p2_CMD}	
# 	Wait '3s' for stabible
# 	run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '1' to '4' with tp '140'
# 	
# 	Check tti_4UE_2VUE
#      
# 	Log To Console    --phr_override_deactivate 1--
# 	airphone_execute_egate_command   ${phr_deactivate_p2_CMD}
# 	Wait '2s' for stabible
# 	run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '1' to '4' with tp '140'
# 	
# Check tti_4UE_2VUE
# 	Start collect ttitrace
#      Wait for '2s' to stop ttitrace with name'tti_4UE'
# 	Log To Console    ${\n}--check_tti_4UE_2VUE--
# 	Set test Variable    ${tti_title_tag}		tti_4UE_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_A_case11_LOAPLO.ini   i
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# test_UE1	
# 	UE from '1' to '1' SA Register
# 	Set ue1 position
# 	Wait '2s' for stabible
# 	send ul data from UE '1' to '1'		
# 	#run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '1' to '1' with tp '80'
# 	#Start collect ttitrace
#      #Wait for '2s' to stop ttitrace with name'tti_12'
# 	#Check ttiTrace 
# 	#Wait '3s' for stabible   		
# 	#DeRegister UE from '1' to '1'
# 	#deactive pdofile1
# 	#Wait '3s' for stabible
# test_UE2	
# 	UE from '2' to '2' SA Register
# 	Set ue2 position
# 	Wait '2s' for stabible
# 	send ul data from UE '2' to '2'		
# 	#run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '2' to '2' with tp '80'
# 	#Start collect ttitrace
#      #Wait for '2s' to stop ttitrace with name'tti_20'
# 	#Check ttiTrace 
# 	#Wait '10s' for stabible   		
# 	#DeRegister UE from '2' to '2'
# 	#deactive pdofile2
# 	#Wait '3s' for stabible
# test_UE3	
# 	UE from '3' to '3' SA Register
# 	Set ue3 position
# 	Wait '2s' for stabible
# 	send ul data from UE '3' to '3'		
# 	#run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '3' to '3' with tp '80'
# 	#Start collect ttitrace
#      #Wait for '2s' to stop ttitrace with name'tti_33'
# 	#Check ttiTrace 
# 	#Wait '10s' for stabible   		
# 	#DeRegister UE from '3' to '3'
# 	#deactive pdofile3
# 	#Wait '3s' for stabible
# 	
# test_UE4	
# 	UE from '4' to '4' SA Register
# 	Set ue4 position
# 	Wait '2s' for stabible
# 	send ul data from UE '4' to '4'		
# 	#run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '4' to '4' with tp '80'
# 	#Start collect ttitrace
#      #Wait for '2s' to stop ttitrace with name'tti_02'
# 	#Check ttiTrace 
# 	#Wait '10s' for stabible   		
# 	#DeRegister UE from '4' to '4'
# 	#deactive pdofile4
# 	#Wait '2s' for stabible
# 			
# Set ue1 position
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Wait '2s' for stabible
# Set ue2 position
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}
#     Wait '2s' for stabible
# Set ue3 position
#     Airphone Execute Egate Command    ${PROFILE3}
#     Airphone Execute Egate Command    ${SET_PROFILE3}
#     Wait '2s' for stabible
# Set ue4 position
#     Airphone Execute Egate Command    ${PROFILE4}
#     Airphone Execute Egate Command    ${SET_PROFILE4}
#     Wait '2s' for stabible
# delete profile_1_4
# 	Airphone Execute Egate Command    ${delete_PROFILE1}
# 	Airphone Execute Egate Command    ${delete_PROFILE2}
# 	Airphone Execute Egate Command    ${delete_PROFILE3}
# 	Airphone Execute Egate Command    ${delete_PROFILE4}
# deactive pdofile1
# 	Airphone Execute Egate Command    ${deactive_PROFILE1}
# deactive pdofile2
# 	Airphone Execute Egate Command    ${deactive_PROFILE2}
# deactive pdofile3
# 	Airphone Execute Egate Command    ${deactive_PROFILE3}
# deactive pdofile4
# 	Airphone Execute Egate Command    ${deactive_PROFILE4}
# deactive profile1234
# 	Airphone Execute Egate Command    ${deactive_PROFILE1}
# 	Airphone Execute Egate Command    ${deactive_PROFILE2}
# 	Airphone Execute Egate Command    ${deactive_PROFILE3}
# 	Airphone Execute Egate Command    ${deactive_PROFILE4}
# 	
# UE from '${lo}' to '${hi}' SA Register
#     : FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${num} ------
# 
#     \   Airphone SA Attach    ue_id=${num}
#        #set_pdu_param ue=1 pdu=1 trf_type=internal
#        #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     \   Airphone Set Traffic Type    ${num}    ${num}    internal
#     \   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
#     \   Wait '2s' for stabible
#     \   get UE '${num}' rnti in RRC log
#     
# send ul data from UE '${lo}' to '${hi}'  
# 	: FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     \   DL and UL data to '${num}'
#     
# DL and UL data to '${UE_ID}'
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   20M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     #Airphone SA Start Data Traffic    ${UE_ID}    DL   150M   pdu_id=${UE_ID}   duration=3600   trf_id=2
#     Airphone SA Start Data Traffic    ${UE_ID}    UL   80M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     Wait '4s' for stabible
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${UE_ID}  	pdu_id= ${UE_ID}
#      #\      ${dl_tput_Mb}    evaluate    ${dl_tput_kb}//1000
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#      #\      Log To Console		dl ${dl_tput_Mb}
#     Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
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
# #check tti，delete patternid check
# Check ttiTrace
#     Log To Console    ${\n}--Check ttitrace UL--
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_ul_case11_LOAPLO.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# get UE '${ue_id}' rnti in RRC log
#     Log To Console   ===get UE'${ue_id}' rnti===
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
# 
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001   crnti: (\\d+)
#     run keyword if    ${ue_id}==1   Set test Variable	 ${rnti_1} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==2   Set test Variable	 ${rnti_2} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==3   Set test Variable	 ${rnti_3} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==4   Set test Variable	 ${rnti_4} 	${rnti_list[0]}
#   
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '4s' for stabible
