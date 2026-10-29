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
# #test with 20M:(in use)
# ${SCFC_NAME} 	    SCFC_8360_C_case2_1208_20M_8UE.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL_2subcell_case6.xml
# 
# #test with 100M:
# #${SCFC_NAME}      SCFC_8360_B_case5_1208_100M.xml
# #${AIRPHONE_NAME}    IPHY_AEQB_1CELL_2subcell_case5.xml
# 
# #common for 100M and 20M
# ${L1BYP_XML}    L1By_8360_C_case2.xml
# ${WTS_NAME}    wts_8360_C_case2.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# *** Test Cases ***
# CB008360_C_B3_case02_CB006062_8_UEs_UL256QAM_with_Aperiodic_CSI_TypeB
#     Upload airphone l1bypass to iphy
# 	Add RD param
# 	Prepare gnb onair
# 	Start capture gnb and ap syslog in 'syslog' file
# 	
# 	SA attach 8 rank2 UE and check
# 
# 	run keyword and continue on failure	   Stop capture gnb and ap syslog in 'syslog' file
# 		
# *** Keywords ***
# #SA	: UE 1~8 rank2
# Add RD param
#     #control UE rank reported by pusch rather than SRS
# 	Add GNB swconfig    0x58037C:1
# 
# #check no bler before trigger by AP command
# SA attach 8 rank2 UE and check
# 	# 8 rank2 UE
# 	Set test Variable	${SA_lo}		1
# 	Set test Variable	${SA_hi}		8
# 	#Set test Variable	${NSA_lo}		13
# 	#Set test Variable	${NSA_hi}		13
#         
# 	UE from '${SA_lo}' to '${SA_hi}' SA Register and check	
# 	#UE from '${NSA_lo}' to '${NSA_hi}' NSA Attach and check	
# 	
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_disable_6062'
# 
# 	Log To Console   ${\n}---check tti---
# 	Set test Variable    ${tti_title_tag}		tti_disable_6062_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_C_6062_off.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# 	online enable CB006062 by actUlDataDmrsFdm
# 
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_act_6062'
# 	
# 	DeRegister UE from '${SA_lo}' to '${SA_hi}'
# 	#Dettach UE from '${NSA_lo}' to '${NSA_hi}'
# 
#     Log To Console   ${\n}---check tti---
# 	Set test Variable    ${tti_title_tag}		tti_act_6062_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_C_6062.ini   i
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
#     \   run keyword if    ${num}<${hi}		Airphone SA Start Data Traffic    ${num}    UL   5M   pdu_id=${num}   duration=7200   trf_id=1
#     \   run keyword if    ${num}==${hi}	Airphone SA Start Data Traffic    ${num}    UL   30M   pdu_id=${num}   duration=7200   trf_id=1
#     \   Wait '2s' for stabible  
#     \   get UE '${num}' rnti in RRC log
#     \   get UL data of UE'${num}' 
# 
# get UL data of UE'${UE_ID}'   
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${UE_ID}  	pdu_id= ${UE_ID}
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console    UE${UE_ID}_ul ${ul_tput_Mb}M
# 
# #================NSA attach======not used in this case====
# UE from '${lo}' to '${hi}' NSA Attach and check
# 	: FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
# 	\    Log To Console   ${\n}--Attach NSA UE ${num} --
# 	\   airphone_cleanup_egate_console_log
# 	\	Airphone Nsa Attach     ${num}    profile_id=None
# 	\	Wait '2s' for stabible
# 	# not the last UE, send 2M
# 	\	run keyword if    ${num}<${hi}	NSA send ue '${num}' mutiple trf '1' for each '5M' UL data
# 	# the last UE, send 15M
# 	\	run keyword if    ${num}==${hi}	NSA send ue '${num}' mutiple trf '1' for each '30M' UL data
# 	\	Wait '2s' for stabible
# 	\	${pcell_tp}	Get cell ul throught	${num}    8
# 	\	${ul_tput_Mb}    evaluate    ${pcell_tp}/1000
# 	\	Log To Console    UE${num}_ul_tp ${ul_tput_Mb}M--
# 	\   get UE '${num}' rnti in RRC log
# 	
# #check throughput
# check throughput from UE '${low}' to '${hi}' with tp '${ul_cell_tp}'
# 	Wait '3s' for stabible
# 	${cell_tp_ul}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   Log To Console    Check throughput UE${num}
#     \      ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${num}  	pdu_id= ${num}
#     \      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     \      Log To Console		ul ${ul_tput_Mb}
#     \      ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}
#     Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
#     run keyword and continue on failure    should be true    ${cell_tp_ul}>${ul_cell_tp}
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '4s' for stabible
# 
# Dettach UE from '${low}' to '${hi}'
# 	: FOR    ${num}    IN RANGE    ${low}    ${hi}+1
# 	\	Airphone NSA Detach    ue_id= ${num}
# 	\   Wait '3s' for stabible
# 
# online enable CB006062 by actUlDataDmrsFdm
#    Online recommissioning with delta json file    ${CURDIR}/JSON/delta_actUlDataDmrsFdm_true.json
#    Wait '30s' for stabible
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
