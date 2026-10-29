# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G   owner_zhang		SBTS23R1
# ...   CLOUD_5G_I_MP_AP_LO
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_CNI86083_case2_bsr_MPAPLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_case4_LO_bsr.xml
# ${WTS_NAME}    wts_8247_case4_LO_bsr.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# 
# @{titles_1}    DlData_DciInfo.patternId_item    3gpp.rnti
# @{titles_2}    DlData_PdschGrant.patternId_item     3gpp.rnti
# @{titles_3}    DlData_CsiRsResource_t.patternId_item    DlData_CsiRsResource_t.density
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# ${SET_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
# ${delete_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 delete\=true
# ${delete_PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 delete\=true
# ${delete_PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 delete\=true
# ${delete_PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 delete\=true
# ${delete_PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 delete\=true
# ${delete_PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 delete\=true
# ${delete_PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 delete\=true
# 
# *** Test Cases ***
# CNI86083_case02_srsTypeAllocForDlBm_antenna_switching   
# 	Add RD param
# 	Get and Update BSR File		par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001 
# 	Prepare gnb onair	
# 	Start capture gnb and ap syslog in '8247_case4' file
# 	test_6UE_t2r4
# 	Stop capture gnb and ap syslog in '8247_case4' file
# 
# *** Keywords ***
# Add RD param
# 	Add GNB swconfig    0x580434:0	#pdcch use best beam
# 	
# test_6UE_t2r4
# 	Register_UE1
# 	Register_UE2
# 	Register_UE3
# 	Register_UE4
# 	Register_UE5
# 	Register_UE6
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    10s    2s   check throughput from UE '1' to '6' with tp '1300'
# 	collect and check tti
# 	collect and check PatternId in BIP
# 	#run keyword and continue on failure		check tti no bler_with_passratio_'1'	
# 	DeRegister UE from '1' to '6'
# 	delete profile_1_6
# 
# get_bip
# 	Start collect bip log
#     Wait for '1s' to stop bip log with name'BIP'
# get_tti
# 	Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'tti'
# 	reorder_csv_CB008247	${TEST_LOG_DIRECTORY()}/All/tti_dl.csv
# 
# delete profile_1_6
# 	Airphone Execute Egate Command    ${delete_PROFILE1}
# 	Airphone Execute Egate Command    ${delete_PROFILE2}
# 	Airphone Execute Egate Command    ${delete_PROFILE3}
# 	Airphone Execute Egate Command    ${delete_PROFILE4}
# 	Airphone Execute Egate Command    ${delete_PROFILE5}
# 	Airphone Execute Egate Command    ${delete_PROFILE6}
# 
# Register_UE1	
# 	airphone_cleanup_egate_console_log
# 	UE from '1' to '1' SA Register
# 	Set UE1 position
# 	send ul data from UE '1' to '1'
# 	get UE '1' rnti in RRC log
# Register_UE2	
# 	airphone_cleanup_egate_console_log
# 	UE from '2' to '2' SA Register
# 	Set UE2 position
# 	send ul data from UE '2' to '2'	
# 	get UE '2' rnti in RRC log
# Register_UE3	
# 	airphone_cleanup_egate_console_log
# 	UE from '3' to '3' SA Register
# 	Set UE3 position
# 	send ul data from UE '3' to '3'	
# 	get UE '3' rnti in RRC log
# Register_UE4	
# 	airphone_cleanup_egate_console_log
# 	UE from '4' to '4' SA Register
# 	Set UE4 position
# 	send ul data from UE '4' to '4'
# 	get UE '4' rnti in RRC log
# Register_UE5	
# 	airphone_cleanup_egate_console_log
# 	UE from '5' to '5' SA Register
# 	Set UE5 position
# 	send ul data from UE '5' to '5'
# 	get UE '5' rnti in RRC log
# Register_UE6	
# 	airphone_cleanup_egate_console_log
# 	UE from '6' to '6' SA Register
# 	Set UE6 position
# 	send ul data from UE '6' to '6'	
# 	get UE '6' rnti in RRC log
# Register_UE7	
# 	airphone_cleanup_egate_console_log
# 	UE from '7' to '7' SA Register
# 	Set UE7 position
# 	send ul data from UE '7' to '7'
# 	get UE '7' rnti in RRC log
# Set UE1 position
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Wait '2s' for stabible
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
# Set UE5 position
#     Airphone Execute Egate Command    ${PROFILE5}
#     Airphone Execute Egate Command    ${SET_PROFILE5}
#     Wait '2s' for stabible
# Set UE6 position
#     Airphone Execute Egate Command    ${PROFILE6}
#     Airphone Execute Egate Command    ${SET_PROFILE6}
#     Wait '2s' for stabible
# Set UE7 position
#     Airphone Execute Egate Command    ${PROFILE7}
#     Airphone Execute Egate Command    ${SET_PROFILE7}
#     Wait '2s' for stabible
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
# send ul data from UE '${lo}' to '${hi}'  
# 	: FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     \   DL and UL data to '${num}'    
# DL and UL data to '${UE_ID}'
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   165M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   165M   pdu_id=${UE_ID}   duration=3600   trf_id=2
#     Airphone SA Start Data Traffic    ${UE_ID}    UL   5M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     Wait '4s' for stabible
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${UE_ID}  	pdu_id= ${UE_ID}
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
#     Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
#     Log To Console		UE${UE_ID}_dl ${dl_tput_Mb}
#     should be true		${dl_tput_Mb}>0
#     should be true		${ul_tput_Mb}>0
#     
# #check throughput
# check throughput from UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
# 	Wait '3s' for stabible
# 	${cell_tp_dl}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   Log To Console    Check throughput UE${num}
#     \      ${dl_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pdsch    tput_type=ave
#     \      ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
#     \      Log To Console		ul ${dl_tput_Mb}    
#     \      ${cell_tp_dl}    evaluate    ${cell_tp_dl}+${dl_tput_Mb}    
#     Log To Console		=====dl_cell_tp ${cell_tp_dl}=====
#     run keyword and continue on failure    should be true    ${cell_tp_dl}>${dl_cell_tp}
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
# 
# 	
# check tti no bler_with_passratio_'${pass_ratio}'
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti'
# 	reorder_csv_CB008247	${TEST_LOG_DIRECTORY()}/All/tti_dl.csv	
# 	
# 	Log To Console   ${\n}---check tti---
# 	Set test Variable    ${tti_title_tag}		tti_ul.csv
# 	Set test Variable    ${pass_ratio_ini}		${pass_ratio}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_check_bler_ratio.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
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
#     run keyword if    ${ue_id}==5   Set test Variable	 ${rnti_5} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==6   Set test Variable	 ${rnti_6} 	${rnti_list[0]}
# 	Log To Console   ${\n}UE${ue_id}_rnti_${rnti_list[0]}
# 
# 	#t4r4_n4:codebook+TAS
#     run keyword if    ${ue_id}<6   run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_ue7_case3.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
# 
#     #t4r4_n4:codebook(srstype=TAS,so no TAS, no dft beam)
#     run keyword if    ${ue_id}==6   run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_t4r4_n4_NO_TAS_SRS_case4.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
# 
# collect and check tti
# 	Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'tti'
# 	run keyword and continue on failure     reorder_csv_CB008247	${TEST_LOG_DIRECTORY()}/All/tti_dl.csv
# 	
#     Set test Variable  ${best_patternId}    1103
#     Set test Variable  ${1st_patternId}     1103
#     Set test Variable  ${2nd_patternId}     1098
#     
#     Log To Console    Check ttitrace DL
#     Set test Variable    ${tti_title_tag}		tti_dl.csv
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_dl_CNI86083_tas.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
#     Log To Console    --Check ttitrace UL
#     Set test Variable    ${tti_title_tag}		tti_ul.csv
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_ul_CNI86083_tas.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# collect and check PatternId in BIP
# 	# dft start patternid =1054
#     Set test Variable   ${pdcch_patternId}		1103
#     Set test Variable   ${pdsch_patternId}		1103
#     Set test Variable   ${SSB_patternId}     1024
# 
#     Set test Variable   ${FILTER_1}    (dldata_pdcchsendreq)&&!(3gpp.rnti == 65535)
#     Set test Variable   ${FILTER_2}    (dldata_pdschsendreq)&&!(3gpp.rnti == 65535)
# 
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'BIP'
# 
#     Log To Console   Check PatternId in bip
#     #convert csv
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_pdcch.csv    ${FILTER_1}    ${titles_1}
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_pdsch.csv    ${FILTER_2}    ${titles_2}
# 
#     #Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdump_L2L1_bip_filtering_off.pcap0
#     #...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_csi.csv    ${FILTER_3}    ${titles_3}
#     
#     #check bip
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pdcch_CNI86083_tas.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pdsch_CNI86083_tas.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
# 
#     #run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_csi_case4.ini     i
#     #...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
# 
#     Log To Console   Check PatternId in bip finisged
