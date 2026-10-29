# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags        CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD    AP    CRT    SBTS00    RAN_5G    owner_zhang
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_10659_case45_FDD.xml
# ${AIRPHONE_NAME}    IPHY_AHLOA_ASIB_ABIL_FDD.xml 
# ${WTS_NAME}       WTS_ASIB_ABIL_FDD_CPRI_SANSA_FS_case45.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${bler_testmode_nr_profile_1}    bler_testmode_nr profile_id\=1 ul_bler_bit_error\=100,80,80,80,0,0,0,0 ul_bler_bit_error_periodicity\=3 
# ...        ul_bler_bit_error_duration\=0
# 
# *** Test Cases ***
# #The parameter rdCutOffMcsAdaptiveReTx64Qam defines the Cutt-Off MCS for adaptive retransmission if the 64QAM MCS index table is used. 
# #The adaptive retransmission is only allowed if the initial transmission used a MCS lower or equal to the rdCutOffMcsAdaptiveReTx64Qam
# CB010659_A_case45_FDD_rdCutOffMcsAdaptiveReTx64Qam
# 	Add RD param MCS16
# 	Prepare gnb onair
# 	trigger cell ul bler for 64QAM_target100_fixMCS16_reservedMCS30_at_RachSlot1
# 	
# *** Keywords ***
# Add RD param MCS16
# 	#rdCutOffMcsAdaptiveReTx64Qam
# 	Add GNB swconfig	 0x58053a:16
# 	#rdSupportedUlMCS RAD param MCS=16，reserved MCS=30
# 	Add GNB swconfig	 0x580010:0x10000
# 
# Trigger ul bler
# 	Log To Console   ${\n}---FDD ul bler---
#     airphone_execute_egate_command	${bler_testmode_nr_profile_1}
#     airphone_execute_egate_command	ue_testmode_set_nr id\=1 testmode\=bler profile_id\=1 action\=activate
#     Wait '2s' for stabible
# deactive ul bler
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1 testmode\=bler profile_id\=1 action\=deactivate    
# 
# trigger cell ul bler for 64QAM_target100_fixMCS16_reservedMCS30_at_RachSlot1
# 	Start capture gnb and ap syslog in 'sys_case45' file
# 	Register_UE1
# 	check tti no bler_with_passratio_'1'
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    20s    2s   check throughput from UE '1' to '1' with tp range '33' to '40'
# 
# 	Trigger ul bler
# 	
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    20s    2s   check throughput from UE '1' to '1' with tp range '24' to '30'
# 	check tti after bler
# 	deactive ul bler
# 	DeRegister UE from '1' to '1'
# 	run keyword and continue on failure    Stop capture gnb and ap syslog in 'sys_case45' file
# 	
# Register_UE1	
# 	UE from '1' to '1' SA Register
# 	send ul data '40M' from UE '1' to '1' 	
# 	
# check tti after bler
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_bler_case45'
# 	
# 	Log To Console   ${\n}---check tti after bler---
# 	Set test Variable    ${tti_title_tag}		tti_bler_case45_ul.csv
# 	#(0-9)-29;(10-16)-30;(17-28)-31
# 	Set test Variable    ${reserved_MCS}	30
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_case45.ini   i	
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}/All	
# 	
# 	run keyword and continue on failure    Check reserved mcs in ttitrace is correct   tti_bler_case45
# 	run keyword and continue on failure   check_reTx_status_and_reservedMCS   ${TEST_LOG_DIRECTORY()}/All/tti_bler_case45_ul.csv   1   0.5
# 	run keyword and continue on failure   check_maxCodeRatePRB   ${TEST_LOG_DIRECTORY()}/All/tti_bler_case45_ul.csv   0.97
# 	
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
# send ul data '${ul_data}' from UE '${lo}' to '${hi}'  
# 	: FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     \   DL and UL data '${ul_data}' to '${num}'    
# DL and UL data '${ul_data}' to '${UE_ID}'
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   5M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Airphone SA Start Data Traffic    ${UE_ID}    UL   ${ul_data}   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     Wait '3s' for stabible
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${UE_ID}  	pdu_id= ${UE_ID}
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
# 
# #check throughput
# check throughput from UE '${low}' to '${hi}' with tp range '${ul_cell_tp_lo}' to '${ul_cell_tp_hi}'
# 	Wait '3s' for stabible
# 	${cell_tp_ul}	  evaluate	0
# 	: FOR    ${num}    IN RANGE    ${low}    ${hi}+1
# 	\   Log To Console    Check throughput UE${num}
# 	\      ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pusch    tput_type=ave
# 	\      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
# 	\      Log To Console		ul ${ul_tput_Mb}    
# 	\      ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}    
# 	Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
# 	should be true    ${cell_tp_ul}>=${ul_cell_tp_lo}
# 	should be true    ${cell_tp_ul}<=${ul_cell_tp_hi}
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
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
# get UE '${ue_id}' rnti in RRC log
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
# 	
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001   crnti: (\\d+)
#     Log To Console   ${\n}===get UE'${ue_id}' rnti===${rnti_list[0]}
#     run keyword if    ${ue_id}==1   Set test Variable	 ${rnti_1} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==2   Set test Variable	 ${rnti_2} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==3   Set test Variable	 ${rnti_3} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==4   Set test Variable	 ${rnti_4} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==5   Set test Variable	 ${rnti_5} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==6   Set test Variable	 ${rnti_6} 	${rnti_list[0]}
