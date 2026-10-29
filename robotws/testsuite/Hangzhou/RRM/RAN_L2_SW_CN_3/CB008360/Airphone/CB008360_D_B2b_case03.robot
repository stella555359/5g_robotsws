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
# ${SCFC_NAME} 	    SCFC_8360_D_1070_80M_case3.xml
# #deltasinrmax=0, for high bler cause low sinr
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL_2subcell_case5.xml
# 
# #for nomal pair
# #${L1BYP_XML}    L1By_8360_D_case3.xml
# #for UE group
# ${L1BYP_XML}	  L1By_8360_B_case5.xml
# ${WTS_NAME}    wts_8360_C_case2.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# 
# #filter:CRC_NOK
# ${FILTER_1}	(uldata_puschreceiverespharqu) && (UlData_UePuschReceiveRespHarqU_t.crc == 1)
# @{titles_1}	UlData_UePuschReceiveRespHarqU_t.dtx
# 
# &{GNBMIRRORINGCONFIGS}    NUMBER_OF_FILES=30	FILE_SIZE_MBYTES=200
# *** Test Cases ***
# CB008360_D_B2b_case03_Retrans_UEs_paired_with_Retrans_UEs_CB006062
#     Upload airphone l1bypass to iphy
# 	#Add RD param
# 	#Active GNB L2 feature debug traces		
# 	Prepare gnb onair
# 	D_8UE_data_diff	
# 		
# *** Keywords ***
# D_8UE_data_diff
# 	airphone_cleanup_egate_console_log
# 	Start capture gnb and ap syslog in 'sys' file
# 	UE from '1' to '8' SA Register and check	
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    60s    2s   check throughput from UE '1' to '8' with tp '405'
# 	check tti no bler
# 	run keyword and continue on failure 	Stop capture gnb and ap syslog in 'sys' file
# 	
# 	Start capture gnb and ap syslog in 'sys_bler' file
# 	bler_1
# 	run keyword and continue on failure	   Stop capture gnb and ap syslog in 'sys_bler' file
# 	
# 	DeRegister UE from '1' to '8'
# 	#airphone_execute_egate_command    bler_testmode_nr profile_id\=1 delete\=yes
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate   unzip=TRUE
# 	
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_cleanup_egate_console_log
#     \   airphone_execute_egate_command	   ue_pdu_session_release ue\=${num} pdu\=${num}
#     \   Wait '2s' for stabible
#     \   Log To Console		=====deRegister UE${num}======
#     \   run keyword and continue on failure 	airphone_sa_detach    ue_id=${num}    timeout=10
#     \   airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_${num}   unzip=TRUE
#     #\   Wait '2s' for stabible
#     	
# Add RD param
# 	#-D
# 	Add GNB swconfig	 0x580550:7
# 	#UE group
# 	Add GNB swconfig	 0x58054f:1
# 	
# #position
# #UE1_4;5_8(0,0),(8,0)(19,0)(0,7)   al rank2
# bler_1
# 	Log To Console   ${\n}---trigger ul bler 100_100---
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=40,40
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=2,8 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	Wait '1s' for stabible
# 	#run keyword and continue on failure 	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '1' to '8' with tp '405'
# 	#check tti no DTX	
# 	#check bip no DTX
# 	#Start collect bip log
#    	#Wait for '2s' to stop bip log with name'bip'
#    	
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    90s    5s   check tti ReRe and CDMgroup
# 	
# 	Log To Console   ${\n}---dellete bler testmode---
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=2,8 scell\=0 testmode\=bler profile_id\=1 action\=deactivate	
# 	#airphone_execute_egate_command    bler_testmode_nr profile_id\=1 delete\=yes 
# 
# check tti no bler
# 	Log To Console   ${\n}---check tti no bler---
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti'
# 	
# 	Set test Variable    ${tti_title_tag}		tti_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_check_no_bler.ini   i
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
# UE from '${lo}' to '${hi}' SA Register and check
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
#     #82,27
#     \   run keyword if    (${num}==1)|(${num}==5)	Airphone SA Start Data Traffic    ${num}    UL  160M   pdu_id=${num}   duration=7200   trf_id=1
#     #\   run keyword if    (${num}==1)|(${num}==5)	Airphone SA Start Data Traffic    ${num}    UL  160M   pdu_id=${num}   duration=7200   trf_id=2
#     \   run keyword if    (${num}!=1)&(${num}!=5)	Airphone SA Start Data Traffic    ${num}    UL  40M   pdu_id=${num}   duration=7200   trf_id=1
#     \   Wait '3s' for stabible  
#     #\   get UE '${num}' rnti in RRC log
#     \   get UL data of UE'${num}' 
# 	#Wait for '0s' to stop bip log with name'gnb_BIP'
# 	
# get UL data of UE'${UE_ID}'   
#     ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pusch    tput_type=ave
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console    UE${UE_ID}_ul ${ul_tput_Mb}M
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
#     run keyword and continue on failure    should be true    ${cell_tp_ul}>${ul_cell_tp}
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
