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
# ${SCFC_NAME}      SCFC_10695_case29_1208_100M_MPAPLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_1CELL_8D8U_LOAPLO.xml
# ${WTS_NAME}    wts_8360_B_case5_LOAPLO.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# ...    NUMBER_OF_FILES=30
# ${FILTER_2}    (uldata_puschreceivereq) && !(3gpp.rnti == 65535)
# @{titles_2}    3gpp.sfn	  3gpp.slot	3gpp.rnti   UlData_puschReceiveReqGrant_t.numOfLayers	3gpp.subcellid	UlData_puschReceiveReqGrant_t.pairedUe
# ...	UlData_puschReceiveReqGrant_t.numOfPrb		UlData_puschReceiveReqGrant_t.startPrb		UlData_eCpriConfigStruct_t.patternId_item
# ...	UlData_eCpriFcpSectionConfig_t.fcpAddPatternId_item
# 
# #23 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# #33
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# #00 
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# #10
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# #33
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# #23
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# 
# ${deactive_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=1
# ${deactive_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2
# ${deactive_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=3
# ${deactive_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=4
# ${deactive_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=5
# ${deactive_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=6
# ${delete_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 delete\=true
# ${delete_PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 delete\=true
# ${delete_PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 delete\=true
# ${delete_PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 delete\=true
# ${delete_PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 delete\=true
# ${delete_PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 delete\=true
# 
# *** Test Cases ***
# #corrthd>0.3(default=0.15,set 0.35)
# #sinrdiffThd>0(default=-10,set 0)
# CB010659_B_case29_TDD_four_rank1_Ues_Max_4Layer_with_retransmission_without_tapering   
# 	Add RD param MCS20
# 	Get and Update BSR File		par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001 
# 	Prepare gnb onair
# 	
# 	check no bler before bler testmode US1	
# 	run keyword and continue on failure 	trigger ul bler 4 rank1 UE
#   
# *** Keywords ***	
# Add RD param MCS20
# 	#rdActUlAdaptiveReTxResMcsWithMuMimo   
# 	Add GNB swconfig	 0x58061A:1
# 	#rdSupportedUlMCS RAD param MCS=20
# 	Add GNB swconfig	 0x580010:0x100000
# 	#rdUlMuReceiverBeamUsedOverlappingPRB
# 	Add GNB swconfig	 0x58058c:1
# #1:R1111
# check no bler before bler testmode US1
# 	Start capture gnb and ap syslog in '1' file
# 	Register_UE1
# 	Register_UE2
# 	Register_UE3
# 	Register_UE4
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '1' to '4' with tp '170'
# 	run keyword and continue on failure		check tti no bler_with_passratio_'1'	
# 	Stop capture gnb and ap syslog in '1' file
# trigger ul bler 4 rank1 UE
# 	Log To Console   ${\n}<<US1-----UE1234_bler_SA_R1111----->>
# 	Start capture gnb and ap syslog in '2' file
# 	trigger DTX
# 	trigger mix bler		
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_4R1_bler'
# 	deactive mix bler
# 	deactive DTX
# 	DeRegister UE from '1' to '4'
# 	delete profile_1_4
# 	#deactive profile_1_4
# 	Stop capture gnb and ap syslog in '2' file
# 	
# 	Log To Console   ${\n}---check tti-234xR1--
# 	Set test Variable    ${tti_title_tag}	  tti_4R1_bler_ul.csv
# 	Set test Variable    ${reserved_MCS}	31
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_case29.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     
# 	#run keyword and continue on failureÂ Â Â Â Check reserved mcs in ttitrace is correct Â  Â tti_4R1_bler
# 	run keyword and continue on failure   check_reTx_status_and_reservedMCS   ${TEST_LOG_DIRECTORY()}/All/tti_4R1_bler_ul.csv   0.8   0.5
# 	run keyword and continue on failure   check_maxCodeRatePRB   ${TEST_LOG_DIRECTORY()}/All/tti_4R1_bler_ul.csv   1.3
# 
# 	reorder_csv_CB010659	${TEST_LOG_DIRECTORY()}/All/tti_4R1_bler_ul.csv
# trigger mix bler
# 	Log To Console   ${\n}---trigger ul bler---
# 	#sinr=-470 at l1 knife
# 	Airphone Execute Egate Command	ul_sinr_testmode_nr profile_id\=1 sinr_target_pusch\=-380
# 	Airphone Execute Egate Command	ue_testmode_set_nr id\=1-4 testmode\=ul_sinr profile_id\=1 action\=activate
# 	Wait '5s' for stabible
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    10s    2s   check throughput from UE '1' to '4' with tp '30'
# 
# deactive mix bler
# 	Airphone Execute Egate Command	ue_testmode_set_nr id\=1-4 testmode\=ul_sinr profile_id\=1 action\=deactivate
# 	Wait '2s' for stabible
# trigger DTX
# 	Log To Console   ${\n}---FDD ul DTX---
# 	airphone_execute_egate_command	forced_dtx_testmode_nr profile_id\=1 force_dtx_pusch\=3000:10
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1-4 testmode\=forced_dtx profile_id\=1 action\=activate
# 	Wait '2s' for stabible
# deactive DTX
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1-4 testmode\=forced_dtx profile_id\=1 action\=deactivate
# 
# delete profile_1_4
# 	Airphone Execute Egate Command    ${delete_PROFILE1}
# 	Airphone Execute Egate Command    ${delete_PROFILE2}
# 	Airphone Execute Egate Command    ${delete_PROFILE3}
# 	Airphone Execute Egate Command    ${delete_PROFILE4}
#   
# deactive profile_1_4
# 	Airphone Execute Egate Command    ${deactive_PROFILE1}
# 	Airphone Execute Egate Command    ${deactive_PROFILE2}
# 	Airphone Execute Egate Command    ${deactive_PROFILE3}
# 	Airphone Execute Egate Command    ${deactive_PROFILE4}
# 	Wait '2s' for stabible	
# deactive profile_4_5
# 	Airphone Execute Egate Command    ${deactive_PROFILE4}
# 	Airphone Execute Egate Command    ${deactive_PROFILE5}
# 	Wait '2s' for stabible
# deactive profile_5_6
# 	Airphone Execute Egate Command    ${deactive_PROFILE5}
# 	Airphone Execute Egate Command    ${deactive_PROFILE6}
# 	Wait '2s' for stabible
# deactive profile_1_2
# 	Airphone Execute Egate Command    ${deactive_PROFILE1}
# 	#Airphone Execute Egate Command    ${deactive_PROFILE2}
# 	Wait '2s' for stabible
# deactive profile_3_5
# 	Airphone Execute Egate Command    ${deactive_PROFILE3}
# 	Airphone Execute Egate Command    ${deactive_PROFILE4}
# 	Airphone Execute Egate Command    ${deactive_PROFILE5}
# 	Wait '2s' for stabible
# Register_UE1	
# 	UE from '1' to '1' SA Register
# 	Set UE1 position
# 	send ul data from UE '1' to '1'	
# Register_UE2	
# 	UE from '2' to '2' SA Register
# 	Set UE2 position
# 	send ul data from UE '2' to '2'	
# Register_UE3	
# 	UE from '3' to '3' SA Register
# 	Set UE3 position
# 	send ul data from UE '3' to '3'	
# Register_UE4	
# 	UE from '4' to '4' SA Register
# 	Set UE4 position
# 	send ul data from UE '4' to '4'
# Register_UE5	
# 	UE from '5' to '5' SA Register
# 	Set UE5 position
# 	send ul data from UE '5' to '5'
# Register_UE6	
# 	UE from '6' to '6' SA Register
# 	Set UE6 position
# 	send ul data from UE '6' to '6'	
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
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   5M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     run keyword if    ${UE_ID}<5		Airphone SA Start Data Traffic    ${UE_ID}    UL   80M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     run keyword if    ${UE_ID}>4		Airphone SA Start Data Traffic    ${UE_ID}    UL   160M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     Wait '4s' for stabible
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${UE_ID}  	pdu_id= ${UE_ID}
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
# 
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
#     run keyword and continue on failure    should be true    ${cell_tp_ul}>=${ul_cell_tp}
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
# 
# #5
# test_rdUlMuReceiverBeamUsedOverlappingPRB_in_MUreceiver
#     #UE3,UE4 are in MU receiver(in one subcell)UE3 will have additional patternid=UE4's 2nd best patternid.
#     #If this RD parameter is set to true, the beam of unused prb for UE with smaller prb in the MU-IRC receiver will
#     #set as 2nd best beam of UE with larger prb. If this RD parameter is set to false, the beam of unused prb for
#     #UE with smaller prb in the MU-IRC receiver will set as 1st best beam of UE with smaller prb.
# 	Log To Console   ${\n}<<US5-----rdUlMuReceiverBeamUsedOverlappingPRB--rank1x2_rank2x1--->>
# 	Register_UE3_overlapping
# 	Register_UE4_overlapping
# 	Register_UE5_overlapping
# 
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_UE345_R112'
# 
# 	#get big PRB UE4's 2ndBestBeam
#     ${val}    read_csv_columns    ${TEST_LOG_DIRECTORY()}/All/tti_UE345_R112_ul.csv
#     ...     rnti    ulBeamData.ulSrsBm2ndBestBeamPatternId    filter=rnti=${rnti_4}
#     ${UE4_2nd_patternid_str}    set variable    ${val}[1][0]
#     ${UE4_2nd_patternid}    Evaluate    int(${UE4_2nd_patternid_str})
#     Log To Console   ${\n}---UE4_2nd_patternid_${UE4_2nd_patternid}---
# 
#     ${val_1}    read_csv_columns    ${TEST_LOG_DIRECTORY()}/All/tti_UE345_R112_ul.csv
#     ...     rnti    ulBeamData.ulSrsBm2ndBestBeamPatternId    filter=rnti=${rnti_3}
#     ${UE3_2nd_patternid_str}    set variable    ${val_1}[1][0]
#     ${UE3_2nd_patternid}    Evaluate    int(${UE3_2nd_patternid_str})
#     Log To Console   ${\n}---UE3_2nd_patternid_${UE3_2nd_patternid}---
# 
# 	Start collect bip log
#     Wait for '1s' to stop bip log with name'BIP'
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdump_L2L1_bip_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_pusch.csv    ${FILTER_2}    ${titles_2}
# 
#     DeRegister UE from '3' to '5'
#     deactive profile_3_5
# 
# #though UE3 has smaller ul data, but UE3 not always has smaller PRB.
# #so when UE3 has smaller PRB, UE3 will has additional patternid= UE4's 2nd patternid.
# #so when UE4 has smaller PRB, UE4 will has additional patternid= UE3's 2nd patternid.
# 	Log To Console   ${\n}---check bip_pusch---
# 	Set test Variable    ${tti_title_tag}		${TEST_LOG_DIRECTORY()}/All/BIP/bip_pusch.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_case5_PRBoverlapping.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Register_UE3_overlapping	
# 	UE from '3' to '3' SA Register and check_1
# 	Set UE3 position
# 	UL data to '3'_1	
# Register_UE4_overlapping	
# 	UE from '4' to '4' SA Register and check_1
# 	Set UE4 position
# 	UL data to '4'_1
# Register_UE5_overlapping	
# 	UE from '5' to '5' SA Register and check_1
# 	Set UE5 position
# 	UL data to '5'_1
# 	
# UE from '${lo}' to '${hi}' SA Register and check_1
# 	: FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
# 	\   airphone_cleanup_egate_console_log
# 	\   Log To Console   ${\n}--register UE ${num} --
# 	\   Airphone SA Attach    ue_id=${num}
# 	  #set_pdu_param ue=1 pdu=1 trf_type=internal
# 	  #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
# 	\   Airphone Set Traffic Type    ${num}    ${num}    internal
# 	\   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
# 	\   Wait '3s' for stabible
# 	\   get UE '${num}' rnti in RRC log
# 
# UL data to '${UE_ID}'_1
#     run keyword if   ${UE_ID}==3		 Airphone SA Start Data Traffic    ${UE_ID}    UL   30M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     run keyword if   ${UE_ID}==4		 Airphone SA Start Data Traffic    ${UE_ID}    UL   35M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     run keyword if   ${UE_ID}==5		 Airphone SA Start Data Traffic    ${UE_ID}    UL   70M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     Wait '4s' for stabible
#     ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pusch    tput_type=ave
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
# 	
# check tti no bler_with_passratio_'${pass_ratio}'
# 	Start collect ttitrace
# 	Wait for '5s' to stop ttitrace with name'tti'
# 	
# 	Log To Console   ${\n}---check tti---
# 	Set test Variable    ${tti_title_tag}		tti_ul.csv
# 	Set test Variable    ${pass_ratio_ini}		${pass_ratio}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_check_bler_ratio.ini   i
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
#     run keyword if    ${ue_id}==5   Set test Variable	 ${rnti_5} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==6   Set test Variable	 ${rnti_6} 	${rnti_list[0]}
# 
# 
