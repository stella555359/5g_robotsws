# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# #Force Tags    owner_zhang    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# #...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_frame_1208_case11.xml
# #${SCFC_NAME}      SCFC_8360_frame_1116_0_case11.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL.xml
# 
# ${L1BYP_XML}    L1By_H8V0_H19V0_case11_m0_SINR_5.xml
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
# # for Oscillating
# ${phr_override_profile_3_CMD}    phr_override_testmode_nr profile_id\=3 phr_mode\=Oscillating phr_start\=2
# ...    phr_min\=2 phr_max\=5 phr_step_size\=3 phr_period\=10 pc_max\=30
# 
# ${phr_activate_p3_CMD}    ue_testmode_set_nr id\=1-2 scell\=primary testmode\=phr_override profile_id\=3 action\=activate
# 
# ${phr_deactivate_p3_CMD}    ue_testmode_set_nr id\=1-2 scell\=primary testmode\=phr_override profile_id\=3 action\=deactivate
# 
# *** Test Cases ***
# CB008360_case11_ATB_MPR_n78
#     Upload airphone l1bypass to iphy
#     Add GNB swconfig    0x58037C:1    #enable pusch report SINR
#     Modify_Swconfig_8360_MPR_not_MCS_switching_point
# 	#Active GNB L2 feature debug traces
#     Prepare gnb onair    
#     #Start capture gnb and ap syslog in 'SYSLOG' file
# 
# 	UE from '1' to '1' SA Register
# 	run keyword and continue on failure	check throughput from UE '1' to '1'
# 
# 	phr override Oscillating
# 
# 	Start collect ttitrace
#      
# 	Airphone SA Start Data Traffic    1    UL   50M   pdu_id=1   duration=7200   trf_id=2
# 	#Airphone SA Start Data Traffic    2    UL   80M   pdu_id=2   duration=7200   trf_id=2
# 	#Airphone SA Start Data Traffic    3    UL   80M   pdu_id=3   duration=7200   trf_id=2
# 	#Airphone SA Start Data Traffic    4    UL   80M   pdu_id=4   duration=7200   trf_id=2
# 	Wait for '3s' to stop ttitrace with name'tti_MPR_+80M'
#     	
# 	DeRegister UE from '1' to '1'
# 	#run keyword and continue on failure    Stop capture gnb and ap syslog in 'SYSLOG' file
# 
# *** Keywords ***
# Modify_Swconfig_8360_MPR_not_MCS_switching_point
# 	#rdMprDisableBandsFr1:act for FR1 band (used for n41)
# 	#Add GNB swconfig    0x58023e:0
# 
# 	#rdMprActiveFdm:0: deactivated;1:activated
#     Add GNB swconfig    x58023d:1
# 
# 	#rdMprActiveFddTdd:FDD+TDD
# 	Add GNB swconfig    0x58023f:3
# 
# 	#rdMPRActive: 1:SA+NSA; 2:SA; 0:deactive
# 	Add GNB swconfig    0x580240:1
# 
# 	#rdMprQam256ActiveFddTdd: 0:disabled; 1:for FDD; 2:for TDD; 3: FDD+TDD
# 	Add GNB swconfig    0x580478:3
# 
# 	#rdPhrThreshold:This parameter is PHR threshold when to start considering MPR limitation.default=0;[-10..10]
# 	#bigger = easier to be power limited(compared to the "rescaled.Phr")
# 	Add GNB swconfig    0x580244:10
# 	#rrmPhrresaceled<10, = power limited
# 
# 	#rdMcsStartConsiderMpr: MCS switching point, default=MCS2.
# 	#if you want to observe MPR compensation in phr,set this para as default.
# 	#bigger= esier to achieve MCS switching point
#     #Add GNB swconfig    0x580243:10
# 
# phr override Fixed MCS
# 	Log To Console    --phr_set_phr_override_profile 1--
# 	airphone_execute_egate_command   ${phr_override_profile_2_CMD}
# 	Log To Console    --phr_override_activate 1--
# 	airphone_execute_egate_command   ${phr_activate_p2_CMD}	
# 	Wait '3s' for stabible
# 	run keyword and continue on failure	check throughput from UE '1' to '4'
# 	
# 	Start collect ttitrace
#      Wait for '3s' to stop ttitrace with name'tti_MU-SINR_2M'
#      
# 	#Log To Console    --phr_override_deactivate 1--
# 	#airphone_execute_egate_command   ${phr_deactivate_p2_CMD}
# 	#Wait '2s' for stabible
# 	#run keyword and continue on failure	check throughput from UE '1' to '4'
# phr override Oscillating
# 	Log To Console    --phr_set_phr_override_Oscillating--
# 	airphone_execute_egate_command   ${phr_override_profile_3_CMD}
# 	Log To Console    --phr_override_Oscillating--
# 	airphone_execute_egate_command   ${phr_activate_p3_CMD}
# 	Wait '2s' for stabible
# 	#Log To Console    --phr_override_deactivate 3--
# 	#airphone_execute_egate_command   ${phr_deactivate_p3_CMD}
# 	Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti_Phr_comp_5M'
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
#     Airphone SA Start Data Traffic    ${UE_ID}    UL   5M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     Wait '3s' for stabible
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${UE_ID}  	pdu_id= ${UE_ID}
#      #\      ${dl_tput_Mb}    evaluate    ${dl_tput_kb}//1000
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#      #\      Log To Console		dl ${dl_tput_Mb}
#     Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
# 
# #check throughput
# check throughput from UE '${low}' to '${hi}'
# 	Wait '2s' for stabible
# 	${cell_tp_ul}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   Log To Console    ${\n}======Check throughput UE${num}======
#     \      ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${num}  	pdu_id= ${num}
#     \      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     \      Log To Console	ul ${ul_tput_Mb}    
#     \      ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}    
#     Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
#     #run keyword and continue on failure    should be true    ${cell_tp_ul}>135
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
