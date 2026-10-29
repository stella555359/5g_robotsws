# *** Settings ***
# Test Timeout      60 minutes
# Suite Setup       AiC Common Suite Setup
# Suite Teardown    AiC Common Suite Teardown
# Test Setup        AiC Common Test Setup
# Test Teardown     AiC Common Test Teardown
# #Force Tags        CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH    zhang
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${CELL_ID}        0
# ${UE_NUM}          2
# ${UE_ID1}          1
# ${UE_ID2}          2
# ${PDU_ID1}         1
# ${PDU_ID2}         2
# ${GW_ID1}          1
# ${GW_ID2}          1
# ${SLICE_ID}       1
# # ${DU_SCF}   SCF_VDU_cell1_8D4U_cell2_8D8U_8360_A_B2a_case1.xml
# 
# ${DU_SCF}	SCF_VDU_8D4U_8360_pooling.xml
# ${CU_SCF}        SCFC1cell_CU.xml
# ${AIRPHONE_NAME}    iphy_1cell_8D4U.xml
# ${WTS_CFG}      wts_1cell_t1r4_t2r4.cfg
# 
# @{LOG_NAME_LIST}    egatelog
# ${SET_PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed test_type\=SRS init_quad_pos\=0 init_sub_quad_pos\=0
# ...    dtx_start\=10 num_dtx\=255 trigger_puxch_update\=0
# ${SET_PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed test_type\=SRS init_quad_pos\=0 init_sub_quad_pos\=0
# ...    dtx_start\=10 num_dtx\=255 trigger_puxch_update\=0
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
# 
# ${delete_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 delete\=true
# ${delete_PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 delete\=true
# ${delete_PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 delete\=true
# ${delete_PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 delete\=true
# 
# # online change param
# ${MO_DN_1}    MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0
# &{UPDATED_PARAS_DICT_0}    ulMuMimoCorrThd=0.05
# @{MO_DN_LIST}      ${MO_DN_1} 
# @{UPDATED_PARAS_DICT_LIST}		${UPDATED_PARAS_DICT_0}
# 
# &{UPDATED_PARAS_DICT_1}    ulMuMimoCorrThd=0.5
# @{UPDATED_PARAS_DICT_LIST_1}		${UPDATED_PARAS_DICT_1}
# *** Test Cases ***
# CB010411_CB008360_A_B2a_case01_two_rank1_Ues_paired_with_correlation_checking
# 	## UE1,2 in cell 1, ul rank1
# 	AIC Get and Update BSR File         BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     
# 	AIC Perform Full Commission And Reach Onair    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${DU_SCF}    
# 	...    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/WTS/${WTS_CFG}     ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${CU_SCF}
# 	
# 	#VDU Online Change Parameters      ${MO_DN_LIST}     ${UPDATED_PARAS_DICT_LIST_1}
# 	US1_UE12_diff_pos_corrThd_05	
# 	
# 	US2_UE12_same_pos_corrThd_05
# 
# 	VDU Online Change Parameters      ${MO_DN_LIST}     ${UPDATED_PARAS_DICT_LIST}
# 	US3_UE12_diff_pos_corrThd_005
# 
# *** Keywords ***
# US1_UE12_diff_pos_corrThd_05
# 	Register_UE1	
# 	Register_UE2
# 	Set UE1 position_1
# 	Set UE2 position
# 	run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '1' to '2' with tp '140' to '200'
# 	
# 	#${trace_id}     VDU Start TTiTrace Log
#     #Wait '1s' for stabible
#     #VDU Stop TTiTrace Log    ${trace_id}
#     #Collet VDU and VCU syslog
#     #VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}/tti_UE12_diff_pos
# 	
# 	#DeRegister UE from '1' to '2'
# 	#delete profile_1_2
# 	#reorder_csv_CB008360	${TEST_LOG_DIRECTORY()}/tti_UE12_diff_pos_ul.csv
# 	#Check tti_US1
# 	
# US2_UE12_same_pos_corrThd_05
# 	Set UE1 position_2
# 	run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '1' to '2' with tp '70' to '90'
# 	
# 	#${trace_id}     VDU Start TTiTrace Log
#     #Wait '1s' for stabible
#     #VDU Stop TTiTrace Log    ${trace_id}
#     #Collet VDU and VCU syslog
#     #VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}/tti_UE12_same_pos
# 	#reorder_csv_CB008360	${TEST_LOG_DIRECTORY()}/tti_UE12_same_pos_ul.csv
# 	
# 	DeRegister UE from '1' to '2'
# 	delete profile_1_2
# 	#Check tti_US2
# 
# US3_UE12_diff_pos_corrThd_005
# 	Register_UE1	
# 	Register_UE2
# 	Set UE1 position_1
# 	Set UE2 position
# 	run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '1' to '2' with tp '140' to '200'
# 
# 	#${trace_id}     VDU Start TTiTrace Log
#     #Wait '1s' for stabible
#     #VDU Stop TTiTrace Log    ${trace_id}
#     #Collet VDU and VCU syslog
#     #VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}/tti_UE12_diff_pos_corrThd_005
# 	#reorder_csv_CB008360	${TEST_LOG_DIRECTORY()}/tti_UE12_diff_pos_corrThd_005_ul.csv
# 	
# 	DeRegister UE from '1' to '2'	
# 	delete profile_1_2
# 	#Check tti_US3	
# 	
# Register_UE1
# 	UE from '1' to '1' SA Register
# 	#Set UE1 position_1
# 	Wait '2s' for stabible
# 	send ul data from UE '1' to '1'
# 	
# Register_UE2	
# 	UE from '2' to '2' SA Register
# 	#Set UE2 position
# 	Wait '2s' for stabible
# 	send ul data from UE '2' to '2'
# 
# Register_UE3	
# 	UE from '3' to '3' SA Register
# 	Set UE3 position
# 	send ul data from UE '3' to '3'
# 
# Register_UE4	
# 	UE from '4' to '4' SA Register
# 	Set UE4 position
# 	send ul data from UE '4' to '4'
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
# delete profile_1_2
# 	Airphone Execute Egate Command    ${delete_PROFILE1}
# 	Airphone Execute Egate Command    ${delete_PROFILE2}
# delete profile_3_4
# 	Airphone Execute Egate Command    ${delete_PROFILE3}
# 	Airphone Execute Egate Command    ${delete_PROFILE4}
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
#     Airphone SA Start Data Traffic    ${UE_ID}    UL   160M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     Wait '4s' for stabible
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${UE_ID}  	pdu_id= ${UE_ID}
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
# 
# #check throughput
# check throughput from UE '${low}' to '${hi}' with tp '${lo_tp}' to '${hi_tp}'
# 	Wait '5s' for stabible
# 	${cell_tp_ul}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   Log To Console    Check throughput UE${num}
#     \      ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pusch    tput_type=ave
#     \      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     \      Log To Console		ul ${ul_tput_Mb}    
#     \      ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}    
#     Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
#     run keyword and continue on failure    should be true    ${cell_tp_ul}>${lo_tp}
# 	run keyword and continue on failure    should be true    ${cell_tp_ul}<${hi_tp}
#      
# #check tti
# Check tti_US1
# 	Log To Console    ${\n}--check_tti_US1--
# 	Set test Variable    ${tti_title_tag}		tti_UE12_diff_pos_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_A_case1_US1.ini   i
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}
# 
# Check tti_US2
# 	Log To Console    ${\n}--check_tti_US2--
# 	Set test Variable    ${tti_title_tag}		tti_UE12_same_pos_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_A_case1_US2.ini   i
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}
# 
# Check tti_US3
# 	Log To Console    ${\n}--check_tti_US3--
# 	Set test Variable    ${tti_title_tag}		tti_UE12_diff_pos_corrThd_005_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_A_case1_US1.ini   i
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}
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
