# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# #Force Tags    CLOUD_5G_I_BLLL_AP_LOO   owner_zhang	
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_10659_1cell_TDD_case47.xml
# ${AIRPHONE_NAME}    IPHY_1cell_AEQE_TDD.xml
# ${WTS_NAME}    wts_10659_A_TDD_1cell_case47.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# #&{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# #...    NUMBER_OF_FILES=30
# ${FILTER_2}    (uldata_puschreceivereq) && !(3gpp.rnti == 65535)
# @{titles_2}    3gpp.sfn	  3gpp.slot	3gpp.rnti
# 
# *** Test Cases ***
# CB010659_A_case47_TDD_rdCutOffMcsAdaptiveReTx64QamDftsOfdm   
# 	Add RD param MCS8
# 	Prepare gnb onair	
# 	trigger cell ul bler for 64QAM_target75_fixMCS8_reservedMCS29_1UE
# 	online change targetPctUl '100'
# 	trigger cell ul bler for 64QAM_target100_fixMCS8_reservedMCS29_RachSlot_2UE
# 	
# 	#kill_egate
# 	#Add RD param MCS1
# 	#Prepare gnb onair	
# 	#trigger_q2_MCS1
# 	#online change UlTransPrecodePi2Bpsk true
# 	#trigger_q1_MCS1
# 
# *** Keywords ***	
# Add RD param MCS8
# 	#rdCutOffMcsAdaptiveReTx64QamDftsOfdm
# 	Add GNB swconfig	 0x58053c:9
# 	#rdSupportedUlMCS RAD param MCS=8
# 	Add GNB swconfig	 0x580010:0x100
# Add RD param MCS1
# 	#rdSupportedUlMCS RAD param MCS=1
# 	Add GNB swconfig	 0x580010:0x2
# trigger mix bler '${pathloss}'
# 	Log To Console   ${\n}---ul bler---	
# 	Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=1 pathloss\=${pathloss}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=1-2 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
# 	
# deactive mix bler
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=1-2 testmode\=ul_sinr action\=deactivate profile_id\=1 scell\=0
# 	Wait '2s' for stabible
# 
# # US1	
# trigger cell ul bler for 64QAM_target75_fixMCS8_reservedMCS29_1UE
# 	Start capture gnb and ap syslog in 'sys_case47_US1' file
# 	Log To Console   ${\n}---US1----
# 	airphone_cleanup_egate_console_log
# 	UE from '1' to '1' SA Register
# 	send ul data '80M' from UE '1' to '1' 
# 	check tti no bler_with_passratio_'1'
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    10s    2s   check throughput from UE '1' to '1' with tp range '30' to '80'
# 	
# 	trigger mix bler '110'
# 	Wait '3s' for stabible
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    10s    2s   check throughput from UE '1' to '1' with tp range '5' to '15'
# 	check RRC OFDM enabled
# 	check tti US1
# 	
# 	deactive mix bler
# 	DeRegister UE from '1' to '1'
# 	run keyword and continue on failure    Stop capture gnb and ap syslog in 'sys_case47_US1' file
# # US2		
# trigger cell ul bler for 64QAM_target100_fixMCS8_reservedMCS29_RachSlot_2UE
# 	Start capture gnb and ap syslog in 'sys_case47_US2' file
# 	Log To Console   ${\n}---US2----
# 	airphone_cleanup_egate_console_log
# 	UE from '1' to '2' SA Register
# 	send ul data '160M' from UE '1' to '2' 
# 	check tti no bler_with_passratio_'1'
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    10s    2s   check throughput from UE '1' to '2' with tp range '30' to '80'
# 	
# 	trigger mix bler '115'
# 	Wait '5s' for stabible
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    10s    2s   check throughput from UE '1' to '2' with tp range '5' to '10'
# 	check RRC OFDM enabled
# 	check tti US2
# 	deactive mix bler
# 	DeRegister UE from '1' to '2'	
# 	run keyword and continue on failure    Stop capture gnb and ap syslog in 'sys_case47_US2' file	
# # US3
# trigger_q2_MCS1
# 	airphone_cleanup_egate_console_log
# 	Start capture gnb and ap syslog in 'sys_case47_US3' file
# 	UE from '1' to '1' SA Register
# 	send ul data '80M' from UE '1' to '1' 
# 	check tti no bler_with_passratio_'1'
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    10s    2s   check throughput from UE '1' to '1' with tp range '8' to '20'
# 	
# 	trigger mix bler '160'
# 	Wait '4s' for stabible
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    10s    2s   check throughput from UE '1' to '1' with tp range '3' to '10'
# 	check RRC OFDM enabled
# 	check tti US3
# 	deactive mix bler
# 	DeRegister UE from '1' to '1'
# 	run keyword and continue on failure    Stop capture gnb and ap syslog in 'sys_case47_US3' file
# # US4
# trigger_q1_MCS1
# 	airphone_cleanup_egate_console_log
# 	Start capture gnb and ap syslog in 'sys_case47_US4' file
# 	UE from '1' to '1' SA Register
# 	send ul data '80M' from UE '1' to '1' 
# 	check tti no bler_with_passratio_'1'
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    10s    2s   check throughput from UE '1' to '1' with tp range '8' to '20'
# 	
# 	trigger mix bler '150'
# 	Wait '4s' for stabible
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    10s    2s   check throughput from UE '1' to '1' with tp range '2' to '10'
# 	check RRC OFDM enabled
# 	check tti US4
# 	deactive mix bler
# 	DeRegister UE from '1' to '1'
# 	run keyword and continue on failure    Stop capture gnb and ap syslog in 'sys_case47_US4' file
# 
# check RRC OFDM enabled
# 	Log To Console   ${\n}---check RRC OFDM enabled---	
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate   unzip=TRUE
# 	
# 	run keyword and continue on failure	check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_transformPrecoder_enabled_case47.ini
#      ...	 log_need_to_check=p	save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate
#      
# check tti US1
# 	Start collect ttitrace
# 	Wait for '3s' to stop ttitrace with name'tti_US1'
# 	
# 	Log To Console   ${\n}---check tti after bler---
# 	Set test Variable    ${tti_title_tag}		tti_US1_ul.csv
# 	Set test Variable    ${reserved_MCS}	  29
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_case47_US1.ini   i
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}/All	
# 
# 	run keyword and continue on failure	check_235_rule	 ${TEST_LOG_DIRECTORY()}/All/tti_US1_ul.csv
# 	run keyword and continue on failure	check_reTx_status_and_reservedMCS   ${TEST_LOG_DIRECTORY()}/All/tti_US1_ul.csv   0.75   0.7   1   0
# 	run keyword and continue on failure	check_maxCodeRatePRB    ${TEST_LOG_DIRECTORY()}/All/tti_US1_ul.csv    0.97
# 
# check tti US2
# 	Start collect ttitrace
# 	Wait for '3s' to stop ttitrace with name'tti_US2'
# 	
# 	Log To Console   ${\n}---check tti after bler---
# 	Set test Variable    ${tti_title_tag}		tti_US2_ul.csv
# 	Set test Variable    ${reserved_MCS}	  29
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_case47_US2.ini   i
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# 	run keyword and continue on failure	check_235_rule	 ${TEST_LOG_DIRECTORY()}/All/tti_US2_ul.csv
# 	run keyword and continue on failure	check_reTx_status_and_reservedMCS   ${TEST_LOG_DIRECTORY()}/All/tti_US2_ul.csv   1   0.7   1   0
# 	run keyword and continue on failure	check_maxCodeRatePRB    ${TEST_LOG_DIRECTORY()}/All/tti_US2_ul.csv    0.97   1   0
# 
# check tti US3
# 	Start collect ttitrace
# 	Wait for '3s' to stop ttitrace with name'tti_US3'
# 	
# 	Log To Console   ${\n}---check tti after bler---
# 	Set test Variable    ${tti_title_tag}		tti_US3_ul.csv
# 	Set test Variable    ${reserved_MCS}	  29
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_case47_US1.ini   i
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}/All	
# 
# 	run keyword and continue on failure	check_235_rule	 ${TEST_LOG_DIRECTORY()}/All/tti_US3_ul.csv
# 	run keyword and continue on failure	check_reTx_status_and_reservedMCS   ${TEST_LOG_DIRECTORY()}/All/tti_US3_ul.csv   0.75   0.7   1   0
# 	run keyword and continue on failure	check_maxCodeRatePRB    ${TEST_LOG_DIRECTORY()}/All/tti_US3_ul.csv    0.97   1   0
# 
# check tti US4
# 	Start collect ttitrace
# 	Wait for '3s' to stop ttitrace with name'tti_US4'
# 	
# 	Log To Console   ${\n}---check tti after bler---
# 	Set test Variable    ${tti_title_tag}		tti_US4_ul.csv
# 	Set test Variable    ${reserved_MCS}	  29
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_reservedMCS_not_apply.ini   i
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}/All	
# 
# 	run keyword and continue on failure	check_235_rule	 ${TEST_LOG_DIRECTORY()}/All/tti_US4_ul.csv
# 	
# online change targetPctUl '${targetPctUl}'
#     Log To Console    ${\n}=======online_change_targetPct_${targetPctUl}========
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=targetPctResourceReservedMcsUl
#     ...    operation=update    value=${targetPctUl}    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
# 
# online change UlTransPrecodePi2Bpsk true
# 	Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/10659_case47_pi2Bpsk.json
#      Wait '40s' for stabible
# 
# kill_egate 
# 	OperatingSystem.Run   sudo pkill egate
# 	OperatingSystem.Run   sudo pkill deaemon
# 	Wait '3s' for stabible
# get bip
# 	Start collect bip log
# 	Wait for '4s' to stop bip log with name'BIP'
# 	#Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdump_L2L1_bip_filtering_off.pcap00
# 	#...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_pusch.csv    ${FILTER_2}    ${titles_2}
# 
# Register_UE1	
# 	UE from '1' to '1' SA Register
# 	send ul data '160M' from UE '1' to '1' 	
# Register_UE2	
# 	UE from '2' to '2' SA Register
# 	send ul data '1M' from UE '2' to '2' 
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
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   50M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Airphone SA Start Data Traffic    ${UE_ID}    UL   ${ul_data}   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     #Airphone SA Start Data Traffic    ${UE_ID}    UL   160M   pdu_id=${UE_ID}   duration=7200   trf_id=2
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
# 	Wait for '3s' to stop ttitrace with name'tti'
# 	
# 	Log To Console   ${\n}---check tti---
# 	Set test Variable    ${tti_title_tag}		tti_ul.csv
# 	Set test Variable    ${pass_ratio_ini}		${pass_ratio}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_check_bler_ratio.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
