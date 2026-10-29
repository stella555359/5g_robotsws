# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_zhang    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G   SBTS23R1
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_frame_1208_case1_LOAPLO.xml
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
# ${SET_PROFILE1_2}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${deactive_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=1
# ${deactive_PROFILE1_2}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2
# ${deactive_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2
# ${deactive_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=3
# ${deactive_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=4
# ${delete_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 delete\=true
# ${delete_PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 delete\=true
# ${PROFILR_position_switch}	ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=sweep init_quad_pos\=0 init_sub_quad_pos\=2 
# ...		final_quad_pos\=1 final_sub_quad_pos\=2 step\=5 trigger_puxch_update\=5
# ${SET_PROFILR_position_switch}	ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=9
# 
# *** Test Cases ***
# CB008360_A_B2a_case01_two_rank1_Ues_paired_with_correlation_checking
# 	Get and Update BSR File		par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001   
# 	Prepare gnb onair   
# 	US1_UE12_diff_pos_corrThd_05	
# 	US2_UE12_same_pos_corrThd_05
# 	US3_UE12_diff_pos_corrThd_005
# 	
# *** Keywords ***
# US1_UE12_diff_pos_corrThd_05
# 	Start capture gnb and ap syslog in 'SYSLOG_1' file
# 	Register_UE1	
# 	Register_UE2
# 	run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '1' to '2' with tp '140'
# 	Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'tti_UE12_diff_pos'	
# 	Stop capture gnb and ap syslog in 'SYSLOG_1' file
# 	Check tti_US1
# 	
# US2_UE12_same_pos_corrThd_05
# 	Start capture gnb and ap syslog in 'SYSLOG_2' file
# 	Set UE1 position_2
# 	run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '1' to '2' with tp '70'
# 	Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'tti_UE12_same_pos'
# 	DeRegister UE from '1' to '2'	
# 	Stop capture gnb and ap syslog in 'SYSLOG_2' file
# 	delete profile_1_2
# 	Check tti_US2
# 
# US3_UE12_diff_pos_corrThd_005
# 	Start capture gnb and ap syslog in 'SYSLOG_3' file
# 	online change corrThd '0.05'
# 	Register_UE1	
# 	Register_UE2
# 	run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '1' to '2' with tp '140'
# 	Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'tti_UE12_diff_pos_corrThd_005'
# 	DeRegister UE from '1' to '2'	
# 	Stop capture gnb and ap syslog in 'SYSLOG_3' file
# 	delete profile_1_2
# 	Check tti_US3	
# 	
# Register_UE1
# 	UE from '1' to '1' SA Register
# 	Set UE1 position_1
# 	Wait '2s' for stabible
# 	send ul data from UE '1' to '1'
# 	
# Register_UE2	
# 	UE from '2' to '2' SA Register
# 	Set UE2 position
# 	Wait '2s' for stabible
# 	send ul data from UE '2' to '2'
# 	
# Register_UE3	
# 	UE from '3' to '3' SA Register
# 	Set UE3 position
# 	Wait '2s' for stabible
# 	send ul data from UE '3' to '3'	
# 
# Register_UE1_switch	#only 1 position
# 	Wait '2s' for stabible
# 	send ul data from UE '1' to '1'
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_UE1_switch'
# 	DeRegister UE from '1' to '1'
# 	
# Set UE1 position_1
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Wait '2s' for stabible
# Set UE1 position_2
# 	Log To Console   ${\n}-----Set UE1 position_2
#     #Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE1_2}
#     Wait '10s' for stabible
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
# Set UE1 position_switch	
# 	Airphone Execute Egate Command    ${PROFILR_position_switch}
# 	Airphone Execute Egate Command    ${SET_PROFILR_position_switch}
# 	Wait '2s' for stabible
# delete profile_1_2
# 	Airphone Execute Egate Command    ${delete_PROFILE1}
# 	Airphone Execute Egate Command    ${delete_PROFILE2}
# deactive profile_1_2
# 	Airphone Execute Egate Command    ${deactive_PROFILE1}
# 	Airphone Execute Egate Command    ${deactive_PROFILE2}
# 	Wait '2s' for stabible		
# #UE_id: 1-2
# UE from '${lo}' to '${hi}' SA Register
#     : FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     #\   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${num} ------
# 
#     \   Airphone SA Attach    ue_id=${num}
#        #set_pdu_param ue=1 pdu=1 trf_type=internal
#        #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     \   Airphone Set Traffic Type    ${num}    ${num}    internal
#     \   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
#     \   Wait '2s' for stabible
#     #\   get UE '${num}' rnti in RRC log
# 
# send ul data from UE '${lo}' to '${hi}'  
# 	: FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     \   DL and UL data to '${num}'    
#     
# DL and UL data to '${UE_ID}'
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   10M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Airphone SA Start Data Traffic    ${UE_ID}    UL   80M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     Wait '4s' for stabible
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${UE_ID}  	pdu_id= ${UE_ID}
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
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
#     run keyword and continue on failure    should be true    ${cell_tp_ul}>${ul_cell_tp}
#      
# #check tti
# Check tti_US1
# 	Log To Console    ${\n}--check_tti_US1--
# 	Set test Variable    ${tti_title_tag}		tti_UE12_diff_pos_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_A_case1_US1.ini   i
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check tti_US2
# 	Log To Console    ${\n}--check_tti_US2--
# 	Set test Variable    ${tti_title_tag}		tti_UE12_same_pos_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_A_case1_US2.ini   i
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check tti_US3
# 	Log To Console    ${\n}--check_tti_US3--
# 	Set test Variable    ${tti_title_tag}		tti_UE12_diff_pos_corrThd_005_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_A_case1_US1.ini   i
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# 
# #0.5-50;   0.1-10;   0.05-5
# online change corrThd '${corrThd}'
# 	${corrthd_scf}     evaluate    ${corrThd}*100
#     Log To Console    ${\n}=======online_change_corrThd_${corrThd}========
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0    parameter=ulMuMimoCorrThd
#     ...    operation=update    value=${corrthd_scf}    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '4s' for stabible
