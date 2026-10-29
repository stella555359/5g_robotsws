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
# ${SCFC_NAME}      SCFC_8360_frame_1208_case1.xml
# #${SCFC_NAME}      SCFC_8360_frame_1116_0_case11.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL.xml
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
# CB008360_case11_phr
#     Upload airphone l1bypass to iphy    
#     #Modify 8247 Swconfig
# 	#Add GNB swconfig    0x58037C:1
# 	#Active GNB L2 feature debug traces
# 	
#     Prepare gnb onair
#     airphone_cleanup_egate_console_log
#     #Start capture gnb and ap syslog in 'SYSLOG' file
# 
# #MU-SINR
# 	UE from '1' to '4' SA Register and check
# 	
# 	run keyword and continue on failure	check throughput from UE '1' to '4'
# 
# 	Start collect ttitrace
# 	Wait for '3s' to stop ttitrace with name'tti_MU_SINR'
# 	phr override Fixed MU_SINR
# #MCS comp
# 	Online change ulMuMimoLinkAdaptionSwitch to 'MCS compensation'
# 	run keyword and continue on failure	check throughput from UE '1' to '4'
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_MCS'
# 
# #phr override UE1,2
# 	phr override Fixed MCS
# 	   
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate   unzip=TRUE
# 	
# 	DeRegister UE from '1' to '4'
# 	#run keyword and continue on failure    Stop capture gnb and ap syslog in 'SYSLOG' file
# 
# *** Keywords ***
# phr override Fixed MU_SINR
# 	#Start collect bip log	
# 	Log To Console    --phr_set_phr_override_profile 1--
# 	airphone_execute_egate_command   ${phr_override_profile_2_CMD}
# 	Log To Console    --phr_override_activate 1--
# 	airphone_execute_egate_command   ${phr_activate_p2_CMD}	
# 	Wait '2s' for stabible
# 	run keyword and continue on failure	check throughput from UE '1' to '4'
# 	
# 	Start collect ttitrace
#      Wait for '2s' to stop ttitrace with name'tti_muSINR_phr_UE123'
#      
# 	Log To Console    --phr_override_deactivate 1--
# 	airphone_execute_egate_command   ${phr_deactivate_p2_CMD}
# 	Wait '2s' for stabible
# 	run keyword and continue on failure	check throughput from UE '1' to '4'
#      
# 
# 
# phr override Fixed MCS
# 	Log To Console    --phr_override_activate 1--
# 	airphone_execute_egate_command   ${phr_activate_p2_CMD}	
# 	Wait '3s' for stabible
# 	run keyword and continue on failure	check throughput from UE '1' to '4'
# 	
# 	Start collect ttitrace
#      Wait for '2s' to stop ttitrace with name'tti_MCS_phr_UE123'
#      
# 	Log To Console    --phr_override_deactivate 1--
# 	airphone_execute_egate_command   ${phr_deactivate_p2_CMD}
# 	Wait '2s' for stabible
# 	run keyword and continue on failure	check throughput from UE '1' to '4'
# 
# 
# UE from '${lo}' to '${hi}' SA Register and check 
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
# 
# DL and UL data to '${UE_ID}'
#     Log To Console    UL 50M data  to UE ${UE_ID}
#     #Airphone SA Start Data Traffic    ${UE_ID}    DL   20M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     #Airphone SA Start Data Traffic    ${UE_ID}    DL   150M   pdu_id=${UE_ID}   duration=3600   trf_id=2
#     Airphone SA Start Data Traffic    ${UE_ID}    UL   100M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Wait '5s' for stabible
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
#     \   Log To Console    Check throughput UE${num}
#     #\   ${pcell_tp}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pdsch    tput_type=ave
#     #\     should be true    ${pcell_tp}>300
#      \      ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${num}  	pdu_id= ${num}
#      #\      ${dl_tput_Mb}    evaluate    ${dl_tput_kb}//1000
#      \      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#      #\      Log To Console		dl ${dl_tput_Mb}
#      \      Log To Console		ul ${ul_tput_Mb}
#      
#      \      ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}
#      
#      Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
#      #\      should be true    ${dl_tput_Mb}>80
#      #\      should be true    ${ul_tput_Mb}>1
# 
# 
# #check tti
# Check patternId and bler in tti
#     Log To Console    --Check ttitrace DL
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_dl_case4.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
#     Log To Console    --Check ttitrace UL
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_ul_case4.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# 
# 
# #0.5-50;   0.1-10;   0.05-5
# online change corrThd '${corrThd}'
#     Log To Console    online_change_to_${corrThd}
#     ${corrthd_scf}     evaluate    ${corrThd}*100
#     
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0    parameter=ulMuMimoCorrThd
#     ...    operation=update    value=${corrthd_scf}    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
# 
# Online change ulMuMimoLinkAdaptionSwitch to '${value}'
#     Log To Console    ---------online_change_to_${value}----------
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0    ulMuMimoLinkAdaptionSwitch    ${value}    online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
#    
# #online change ulMuMimoLinkAdaptionSwitch '${value}'
# 
#     #Log To Console    online_change_to_${value}
#     
#     #TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     #TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0    parameter=ulMuMimoLinkAdaptionSwitch
#     #...    operation=update    value=${value}    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     
#     #TAF_ADMIN.teardown admin    connection=online
#     #Wait '30s' for stabible
#   
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '4s' for stabible
