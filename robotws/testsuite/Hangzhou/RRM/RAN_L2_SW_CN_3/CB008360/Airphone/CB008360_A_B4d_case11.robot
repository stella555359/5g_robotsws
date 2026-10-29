# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_zhang    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_frame_1208_case11.xml
# #${SCFC_NAME}      SCFC_8360_frame_1116_0_case11.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL_L1bypass.xml
# 
# ${L1BYP_XML}    L1By_H8V0_H19V0_case11_m0.xml
# ${WTS_NAME}    wts_8360_case1.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# 
# @{titles_1}    DlData_DciInfo.patternId_item    3gpp.rnti
# @{titles_2}    DlData_PdschGrant.patternId_item     3gpp.rnti
# @{titles_3}    DlData_CsiRsResource_t.patternId_item    DlData_CsiRsResource_t.density
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
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
# *** Test Cases ***
# CB008360_A_B4d_case11_4_rank1_Mix_Ues_paired_MCS_compensate
#     Upload airphone l1bypass to iphy    	
# 	#Active GNB L2 feature debug traces
# 	
#     Prepare gnb onair    
#     Start capture gnb and ap syslog in 'SYSLOG' file
# 
# 	UE from '1' to '4' SA Register
# 	
# 	run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '1' to '4' with tp '140'
# 
# 	phr override Fixed MCS
# 
# 	 #Set test Variable	 ${rnti_1}	15407
# 	 #Set test Variable	 ${rnti_2}	47255
# 	 #Set test Variable	 ${rnti_3}	13567
# 	 #Set test Variable	 ${rnti_4}	45415
# 	Check ttiTrace 
#     	
# 	DeRegister UE from '1' to '4'
# 	run keyword and continue on failure    Stop capture gnb and ap syslog in 'SYSLOG' file
# 
# *** Keywords ***
# 
# phr override Fixed MCS
# 	Log To Console    --phr_set_phr_override_profile 1--
# 	airphone_execute_egate_command   ${phr_override_profile_2_CMD}
# 	Log To Console    --phr_override_activate 1--
# 	airphone_execute_egate_command   ${phr_activate_p2_CMD}	
# 	Wait '3s' for stabible
# 	run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '1' to '4' with tp '140'
# 	
# 	Start collect ttitrace
#      Wait for '3s' to stop ttitrace with name'tti_MCS'
#      
# 	Log To Console    --phr_override_deactivate 1--
# 	airphone_execute_egate_command   ${phr_deactivate_p2_CMD}
# 	Wait '2s' for stabible
# 	run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '1' to '4' with tp '140'
# 
# 
# UE from '${lo}' to '${hi}' SA Register
#     : FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
# 
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${num} ------
# 
#     \   Airphone SA Attach    ue_id=${num}
#        #set_pdu_param ue=1 pdu=1 trf_type=internal
#        #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     \   Airphone Set Traffic Type    ${num}    ${num}    internal
#     \   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
#     \   Wait '3s' for stabible
#     \   DL and UL data to '${num}'
#     \   get UE '${num}' rnti in RRC log
# 
# DL and UL data to '${UE_ID}'
#     Log To Console    UL 50M data  to UE ${UE_ID}
#     #Airphone SA Start Data Traffic    ${UE_ID}    DL   20M   pdu_id=${UE_ID}   duration=3600   trf_id=1
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
#     run keyword and continue on failure    should be true    ${cell_tp_ul}>${ul_cell_tp}
# 
# #check tti
# Check ttiTrace
#     Log To Console    ${\n}--Check ttitrace UL--
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_ul_case11.ini    log_need_to_check=i
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
