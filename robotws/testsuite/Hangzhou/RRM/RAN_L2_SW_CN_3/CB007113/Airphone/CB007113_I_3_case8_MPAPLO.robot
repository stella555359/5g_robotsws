# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CRT    SBTS00    RAN_5G_TDD    RAN_5G   owner_menzheng   CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}    SCFC_7113_case8_MPLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_3CELL_ABIO.xml
# ${COMAVALUE}    ${CURDIR}/coma/case4.txt
# ${L1BYP_XML}    L1By_7113_I_case789.xml	
# ${WTS_NAME}    wts_7113_I_3_case8.cfg
# ${PDU_ID}         1
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog
# ${par_of_bsr_name}       BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
# @{VENDOR_PARAMETER_C32}	maxNumLayerPrbL1Sp:300	   maxNumStreamPrbL1Sp:600	  maxNumWbStreamPrbL1Sp:600
# @{VENDOR_PARAMETER_C64}	maxNumLayerPrbL1Sp:600	   maxNumStreamPrbL1Sp:1200	  maxNumWbStreamPrbL1Sp:600
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
# ${SET_SAPROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_SAPROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_SAPROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_SAPROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_SAPROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_SAPROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# 
#    
# *** Test Cases ***
# CB007113_I_3_case8_MUMIMO_4layers_with_UL_PRB_pooling_8DL8UL_2virtualUE_4rank2_2rank1_Artificial
#     Add RD param
# 	Get and Update BSR File		par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001	
#     Modify vendor file and full commission for onair
#     Wait for 1st counters	
#     4rank2_2rank1_6UE_cell1
#     Check counters
# 	
# *** Keywords ***
# Prepare test
#     #Active GNB L2 feature debug traces
#     #Modify l1bypass
#     Add RD param
# 
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     ${extra_modify}    create list
#     ...    text|28|//*[@TestProfile\="Profile-1"]//SrsTestParams//ulPmiRank1Sinr
#     ...    text|28|//*[@TestProfile\="Profile-1"]//PuschTestParams//ulPmiRank1Sinr
#     ...    text|28|//*[@TestProfile\="Profile-2"]//SrsTestParams//ulPmiRank1Sinr
#     ...    text|28|//*[@TestProfile\="Profile-2"]//PuschTestParams//ulPmiRank1Sinr
#     ...    text|0|//*[@TestProfile\="Profile-1"]//PuschTestParams//puschNumCountSwitchProfile
#     ...    text|0|//*[@TestProfile\="Profile-2"]//PuschTestParams//puschNumCountSwitchProfile
#     ...    text|16|//ComaMultiplier
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex10}    ${Vindex9}    ${Hindex9}    ${Vindex8}
#     ...    ${Hindex12}    ${Vindex6}    ${Hindex8}    ${Vindex3}
#     ...    ${Hindex17}    ${Vindex6}    ${Hindex17}    ${Vindex6}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex24}    ${Vindex9}
#     ...    ${Hindex9}    ${Vindex8}    ${Hindex24}    ${Vindex9}
#     ...    ${Hindex8}    ${Vindex3}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex17}    ${Vindex6}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex8}    ${Vindex0}
#     ...    srsNumCountSwitchProfile1=0    p1_rank=2    p2_rank=2    p1_sinr=33    p2_sinr=33
#     ...    extra_modify=${extra_modify}
# 	
# Add RD param
# 	Add GNB swconfig    0x340000:15
# 
# 4rank2_2rank1_6UE_cell1
#     Log To Console   ${\n}<<----test_4_rank2_2_rank1_backgroud_6UE----->>
#     Start capture gnb and ap syslog in '1' file
# 	UE from '3' to '6' SA Register cell1
#     Set 1-6UEs different pos
#     Wait '3s' for stabible
#     UE from '1' to '2' SA Register cell1	
#     run keyword and continue on failure 	Wait Until Keyword Succeeds    20s    2s   check throughput from UE '1' to '6' with tp '280'
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti_case8_before_BG'
#     run keyword and continue on failure 	check tti'tti_case8_before_BG' no bler
#     airphone_execute_egate_command	ue_change_location cell\=2 id\=7-10
#     airphone_execute_egate_command	ue_change_location cell\=3 id\=11-14
#     UE from '7' to '14' SA Register BG
#     run keyword and continue on failure 	Wait Until Keyword Succeeds    20s    2s   check throughput from UE '1' to '6' with tp '200'
#     run keyword and continue on failure 	Wait Until Keyword Succeeds    10s    2s   check throughput from UE '7' to '10' with tp '40'
#     run keyword and continue on failure 	Wait Until Keyword Succeeds    10s    2s   check throughput from UE '11' to '14' with tp '40'	
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti_case8_after_BG_UE_attach'
#     run keyword and continue on failure 	check tti'tti_case8_after_BG_UE_attach' no bler
#     #run keyword and continue on failure 	Wait Until Keyword Succeeds    300s    10s   check_counter_US1
#     Stop capture gnb and ap syslog in '1' file
# 
# Set 1-6UEs different pos
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${SET_SAPROFILE1}
#     airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${SET_SAPROFILE2}
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${SET_SAPROFILE3}
#     airphone_execute_egate_command    ${PROFILE4}
#     airphone_execute_egate_command    ${SET_SAPROFILE4}
#     airphone_execute_egate_command    ${PROFILE5}
#     airphone_execute_egate_command    ${SET_SAPROFILE5}
#     airphone_execute_egate_command    ${PROFILE6}
#     airphone_execute_egate_command    ${SET_SAPROFILE6}
# 
# UE from '${lo}' to '${hi}' SA Register cell1
#     : FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     \   #airphone_cleanup_egate_console_log
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id=${PDU_ID}    type=internal
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${PDU_ID}   nwslice_id=1   gw_id=${num}
#     \   Wait '3s' for stabible
#     \   airphone_execute_egate_command    ${PROFILE${num}}
#     \   airphone_execute_egate_command    ${SET_SAPROFILE${num}}	
#     \   Airphone SA Start Data Traffic    ${num}    UL   100M   pdu_id=${PDU_ID}   duration=7200   trf_id=1
#     \   Airphone SA Start Data Traffic    ${num}    DL   50M   pdu_id=${PDU_ID}   duration=7200   trf_id=1
#     \   Wait '3s' for stabible	
# 
# UE from '${lo}' to '${hi}' SA Register BG
#     : FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     \   #airphone_cleanup_egate_console_log
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id=${PDU_ID}    type=internal
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${PDU_ID}   nwslice_id=1   gw_id=${num}
#     \   Wait '3s' for stabible
#     \   Airphone SA Start Data Traffic    ${num}    UL   12M   pdu_id=${PDU_ID}   duration=7200   trf_id=1
#     \   Airphone SA Start Data Traffic    ${num}    DL   50M   pdu_id=${PDU_ID}   duration=7200   trf_id=1
#    
# UL data to '${UE_ID}'  
#     Airphone SA Start Data Traffic    ${UE_ID}    UL   160M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   50M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     Wait '4s' for stabible
#     ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pusch    tput_type=ave   
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
# 
# #check throughput
# check throughput from UE '${low}' to '${hi}' with tp '${ul_cell_tp}'
#     Wait '3s' for stabible
#     ${cell_tp_ul}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   Log To Console    Check throughput UE${num}
#     \      ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pusch    tput_type=ave
#     \      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     \      Log To Console		ul ${ul_tput_Mb}    
#     \      ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}    
#     Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
#     run keyword and continue on failure    should be true    ${cell_tp_ul}>${ul_cell_tp}
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
#     
# check tti'${tti_title}' no bler		
#     Log To Console   ${\n}---check tti---
#     Set test Variable    ${tti_title_tag}		${tti_title}_ul.csv
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_check_no_bler.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/${tti_title_tag}       50      19
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
# Wait for 1st counters
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
# 	
# Check counters
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
# 	${PM_counter_value_M55308C35001}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C35001    cell_id=1	
# 	${PM_counter_value_M55308C35002}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C35002    cell_id=1
# 	${PM_counter_value_M55308C35003}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C35003    cell_id=1	
# 	${PM_counter_value_M55308C35004}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C35004    cell_id=1
# 	${PM_counter_value_M55308C35005}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C35005    cell_id=1	
# 	${PM_counter_value_M55308C35006}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C35006    cell_id=1
# 	${PM_counter_value_M55308C35007}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C35007    cell_id=1
# 	${PM_counter_value_M55308C35008}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C35008    cell_id=1	
# 	${PM_counter_value_M55308C35009}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C35009    cell_id=1
# 	should be true     ${PM_counter_value_M55308C35001} > 0
# 	should be true     ${PM_counter_value_M55308C35002} > 0
# 	should be true     ${PM_counter_value_M55308C35003} > 0
# 	should be true     ${PM_counter_value_M55308C35004} > 0
# 	should be true     ${PM_counter_value_M55308C35005} > 0
# 	should be true     ${PM_counter_value_M55308C35006} > 0
# 	should be true     ${PM_counter_value_M55308C35007} > 0
# 	should be true     ${PM_counter_value_M55308C35008} == 0
# 	should be true     ${PM_counter_value_M55308C35009} == 0	
# 
# 
