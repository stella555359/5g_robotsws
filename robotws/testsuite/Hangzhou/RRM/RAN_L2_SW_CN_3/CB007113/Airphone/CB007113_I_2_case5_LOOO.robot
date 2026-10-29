# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G   owner_yuqq
# ...   CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}    SCFC_CB007113_case5_LOOO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_3CELL_ABIO_case5.xml	
# ${WTS_NAME}    wts_7113_case5.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog
# ${SA_UE_NUM}         3
# ${UE_NUM}        6
# ${UE_ID1}          1
# ${UE_ID2}          2
# ${EGATE_TAG}      MUmimo
# ${BIP_TAG}    mumumo_bip
# ${tti_tag}    ttitrace
# ${sys_tag}    sys
# ${tti_bler}   startdlber
# ${tti_stopbler}    stopdlbler
# @{VENDOR_PARAMETER_C32}	maxNumLayerPrbL1Sp:230	   maxNumStreamPrbL1Sp:460	  maxNumWbStreamPrbL1Sp:460
# @{VENDOR_PARAMETER_C64}	maxNumLayerPrbL1Sp:460	   maxNumStreamPrbL1Sp:920	  maxNumWbStreamPrbL1Sp:920
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# #${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# ${SET_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
# ${SET_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
# 
# 
# *** Test Cases ***
# CB007113_I_2_case5_MUMIMO_3layers_with_UL_PRB_pooling_activated_3rank1ue_with_retran
# 	Get and Update BSR File		par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
# 	Modify vendor file and full commission for onair
# 	Execute AP Command before attach
#     Start capture gnb and ap syslog in '${sys_tag}' file
#     Attach '${SA_UE_NUM}' RANK1 SA UE
# #    Wait '25s' for stable
# 	
# 	Set 1-3UEs different pos
# 
# 	UE send ul bler
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti1'
# 	
#     Attach UE '5' to cell '2'
#     Attach UE '6' to cell '3'
# 	
# 	Set 5-6UEs different pos
# 	
# 	Start collect ttitrace
# 	Wait for '3s' to stop ttitrace with name'tti2'
# 
#     Attach UE '7' to cell '2'
#     Attach UE '8' to cell '3'
# 	
# 	Set 7-8UEs different pos
# 
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti3'
# 	
# 	run keyword and continue on failure 	check pair in ttitrace
# 	
# #	Airphone NSA Stop Data Traffic And Detach UE
#     Stop capture gnb and ap syslog in '${sys_tag}' file
# 
# 	
# *** Keywords ***
# 
# Set 1-3UEs different pos
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${SET_PROFILE1}
#      airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${SET_PROFILE2}
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${SET_PROFILE3}
# 
# Set 5-6UEs different pos
#     airphone_execute_egate_command    ${PROFILE5}
#     airphone_execute_egate_command    ${SET_PROFILE5}
#     airphone_execute_egate_command    ${PROFILE6}
#     airphone_execute_egate_command    ${SET_PROFILE6}
# 
# Set 7-8UEs different pos
#     airphone_execute_egate_command    ${PROFILE7}
#     airphone_execute_egate_command    ${SET_PROFILE7}
#     airphone_execute_egate_command    ${PROFILE8}
#     airphone_execute_egate_command    ${SET_PROFILE8}
# 
# Add RD param
# 	Add GNB swconfig	 0x420068:6
# 	#act inter subpool
# 	Add GNB swconfig	 0x580612:1
# 
# 	#enable ADMIN developer
# 	Add GNB swconfig	 0x450027:1
# 	# Admin developement account
# 	Add GNB swconfig	 0x45000A:1
# 	Add GNB swconfig    0x340000:15
# 
# 	#enable AP log
# 	Add AP swconfig    0x1003F:2
# 	Add AP swconfig    0x10042:0xC0A8C87E
# 
# 
# check pair in ttitrace                   
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_CB007113_case5_bler.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/tti1_ul.csv       50      19	
# 	7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/tti2_ul.csv       50      19
# 	7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/tti3_ul.csv       50      19	
# 	
# UE send ul bler
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=10 ul_bler\=100,100
#     airphone_execute_egate_command    ue_testmode_set_nr scell\=0 testmode\=bler profile_id\=10 action\=activate id\=1
#     airphone_execute_egate_command    ue_testmode_set_nr scell\=0 testmode\=bler profile_id\=10 action\=activate id\=2
#     airphone_execute_egate_command    ue_testmode_set_nr scell\=0 testmode\=bler profile_id\=10 action\=activate id\=3
# 	
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Attach '${UE_NUM}' RANK1 SA UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   airphone_cleanup_egate_console_log
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \   Wait '3s' for stabible
#     \   UE '${num}' send RANK1
# 	\   Airphone SA Start Data Traffic    ${num}    UL   160M   pdu_id=${num}   duration=7200   trf_id=1
#     \   Airphone SA Start Data Traffic    ${num}    UL   160M   pdu_id=${num}   duration=7200   trf_id=2
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
# 	
# UE '${num}' send RANK1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=0 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=1 scell\=0	
# 	
# Airphone NSA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    15    ${NSA_UE_NUM}+15
#     \    Airphone NSA Stop Data Traffic   ${num}    BI
#     \    Airphone NSA Detach    ${num}
# 
# Set multiue traffic type to internal
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone Set Traffic Type    ${num}    ${num}    internal
# 
# Attach UE '${ue_id}' to cell '${cell_id}'
#     airphone_execute_egate_command	ue_change_location cell\=${cell_id} id\=${ue_id}
#     Airphone SA Attach    ue_id=${ue_id}
#     Airphone Set Traffic Type    ${ue_id}    ${ue_id}    internal
#     Airphone Pdu Session Setup   ${ue_id}    ${ue_id}    1    ${ue_id}
#     Wait '3s' for stabible
#     Airphone SA Start Data Traffic    ${ue_id}    UL   160M   pdu_id=${ue_id}   duration=7200   trf_id=1
#     Airphone SA Start Data Traffic    ${ue_id}    UL   160M   pdu_id=${ue_id}   duration=7200   trf_id=2
#     #Airphone SA Start Data Traffic    ${ue_id}    DL   50M   pdu_id=${ue_id}   duration=7200   trf_id=1
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${ue_id}    scell_id=0    type=pusch    tput_type=ave
# 	
# Verify throughput
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pusch    tput_type=ave
# test_BG_UE
# 	Start capture gnb and ap syslog in '1' file
# 	Bachgroud UE '8' SA Register to cell '2' 
# 	Start collect ttitrace
#      Wait for '2s' to stop ttitrace with name'tti_BG_UE8_cell2'
#      Stop capture gnb and ap syslog in '1' file
#      
# 	Bachgroud UE '9' SA Register to cell '3' 
# 	Start collect ttitrace
#      Wait for '2s' to stop ttitrace with name'tti_BG_UE8_cell2_UE9_cell3'
# Internal send data
#     : FOR    ${num}    IN RANGE    1    3
#     \    Airphone SA Start Data Traffic    ${num}    UL    160M    pdu_id=${num}    duration=6000s
#     \    ...    trf_id=${num}
#     #\    Wait '5s' for stabible
# #1
# 
# 
# UE from '${lo}' to '${hi}' SA Register and check 
#     : FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}--register UE ${num} --
#     \   Airphone SA Attach    ue_id=${num}
#        #set_pdu_param ue=1 pdu=1 trf_type=internal
#        #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     \   Airphone Set Traffic Type    ${num}    ${num}    internal
#     \   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
#     \   Wait '3s' for stabible
#     \   UL data to '${num}'
#     #\   get UE '${num}' rnti in RRC log
# 
# Bachgroud UE '${ue_id}' SA Register to cell '${cell_id}'      
#     Log To Console   ${\n}--register UE ${ue_id} to cell${cell_id} --
#     
#     airphone_execute_egate_command	ue_change_location cell\=${cell_id} id\=${ue_id}
#     Airphone SA Attach    ue_id=${ue_id}
#     #set_pdu_param ue=1 pdu=1 trf_type=internal
#     #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     Airphone Set Traffic Type    ${ue_id}    ${ue_id}    internal
#     Airphone Pdu Session Setup   ${ue_id}    ${ue_id}    1    ${ue_id}
#     Wait '3s' for stabible
#     Airphone SA Start Data Traffic    ${ue_id}    UL   160M   pdu_id=${ue_id}   duration=7200   trf_id=1
#     Airphone SA Start Data Traffic    ${ue_id}    UL   160M   pdu_id=${ue_id}   duration=7200   trf_id=2
#     #Airphone SA Start Data Traffic    ${ue_id}    DL   50M   pdu_id=${ue_id}   duration=7200   trf_id=1
#     Wait '3s' for stabible  
#     ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${ue_id}    0    type=pusch    tput_type=ave   
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console		UE${ue_id}_ul ${ul_tput_Mb}    
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
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
#     
# check tti'${tti_title}' no bler		
# 	Log To Console   ${\n}---check tti---
# 	Set test Variable    ${tti_title_tag}		${tti_title}_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_check_no_bler.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
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
