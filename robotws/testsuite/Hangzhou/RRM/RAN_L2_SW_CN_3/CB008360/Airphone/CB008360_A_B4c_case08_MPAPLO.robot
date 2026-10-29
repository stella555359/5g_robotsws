# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# Force Tags    owner_sasun    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
# ...   CLOUD_5G_I_MP_AP_LO
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# #source          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_A_B4c_case08_MPAPLO.xml
# ${AIRPHONE_NAME}    IPHY_A_B4c_case08.xml
# ${WTS_NAME}    wts_8360_B4c_case08_MPAPLO.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# ...    NUMBER_OF_FILES=30
# ${FILTER_2}    (uldata_puschreceivereq) && !(3gpp.rnti == 65535)
# @{titles_2}    3gpp.rnti	UlData_eCpriConfigStruct_t.patternId_item		UlData_puschReceiveReqGrant_t.pairedUe
# ...	UlData_puschReceiveReqGrant_t.numOfPrb		UlData_eCpriFcpSectionConfig_t.fcpAddPatternId_item
# 
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# 
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# 
# 
# ${deactive_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=1
# ${deactive_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2
# ${deactive_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=3
# ${deactive_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=4
# 
# *** Test Cases ***
# CB008360_A_B4c_case08_4_rank1_Mix_Ues_withGBR_paired_based_on_MU_SINR_estimation
#     Get and Update BSR File		par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
# 	Prepare gnb onair
# 	Active GNB L2 feature debug traces
# 	Register_UE1 to UE3
# 	Set UE1 to UE3 position
#     Add GBR to UE2
#     Send UL data to 3UEs
#     check bler and pair is correct in ttitrace
#     
# *** Keywords ***
# 
# Add RD param
# #rdUlMuReceiverBeamUsedOverlappingPRB
# 	Add GNB swconfig	 0x58058c:1
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
# Register_UE1 to UE3
# 	Attach SA ue with capability to 5g cell    3    vonr_n78_pusch_1layer
# 
# 
# Set UE1 to UE3 position
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0	
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3 scell\=0
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=9 scell\=0	
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
# 	${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
# 	Set test Variable	 ${rnti_1} 	${rnti_list[0]}
# 	Set test Variable	 ${rnti_2} 	${rnti_list[1]}
# 	Set test Variable	 ${rnti_3} 	${rnti_list[2]}
# 
# Add GBR to UE2
#     Start Collect GNB and AP Syslog in 'AddGBR' File
#     airphone_execute_egate_command    ue_pdu_session_modify ue\=2 pdu\=1 qosflows_to_add\=2 by\=amf
#     ...    pass_regexp=Created FiveQi:Qfi mapping fiveQi 5 qfi 2
#     Wait Throughput Timer    5
#     airphone_execute_egate_command    ue_pdu_session_modify ue\=2 pdu\=1 qosflows_to_add\=3 by\=amf
#     ...    pass_regexp=Created FiveQi:Qfi mapping fiveQi 1 qfi 3
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}AddGBR${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}AddGBR${/}tti
#     [Teardown]    Stop Collect GNB and AP Syslog in 'AddGBR' File
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
# Send UL data to 3UEs
#     Start Collect GNB and AP Syslog in 'check_pair' File
#     Airphone SA Start Data Traffic    1    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    3    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
#     airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=2 trf_id\=1 mbps\=70 dir\=ul protocol\=tcp seconds\=3600
#     airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=3 trf_id\=1 mbps\=70 dir\=ul protocol\=tcp seconds\=3600
# 	Wait Throughput Timer    5
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3 scell\=0
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=9 scell\=0
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    8
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}check_pair${/}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}check_pair${/}tti
#     Stop Collect GNB and AP Syslog in 'check_pair' File
# send ul data from UE '${lo}' to '${hi}'
# 	: FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     \   DL and UL data to '${num}'
# DL and UL data to '${UE_ID}'
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   5M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     run keyword if    ${UE_ID}==1		Airphone SA Start Data Traffic    ${UE_ID}    UL   100M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     run keyword if    ${UE_ID}>1		Airphone SA Start Data Traffic    ${UE_ID}    UL   20M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     Wait '4s' for stabible
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${UE_ID}  	pdu_id= ${UE_ID}
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
# 
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
# 
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
# 	Wait for '2s' to stop ttitrace with name'tti'
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
# #UE_id: 1-4
# Attach one SA UE'${ue_id}'
#     Log To Console   ${\n}-----register SA UE ${ue_id} ------
#     Attach SA ue to 5g cell    t1r2_n1    ${ue_id}    PDU_ID=${ue_id}    GW_ID=${ue_id}
# 
# SA send ue '${ue_id}' mutiple trf '${number}' for each '${ul_data}' UL data
#     SA send mutiple trf ul data    ${ue_id}    number=${number}   ul_data=${ul_data}    pdu_id=${ue_id}
#     Wait Throughput Timer    3s
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
#     \   UL data to '${num}'
#     \   get UE '${num}' rnti in RRC log
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
#     
# UL data to '${UE_ID}'
#     Log To Console    UL 20M data  to UE ${UE_ID}
#     Airphone SA Start Data Traffic    ${UE_ID}    UL   20M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Wait '4s' for stabible
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${UE_ID}  	pdu_id= ${UE_ID}   
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
# 
# 
# #check throughput
# check throughput from UE '${low}' to '${hi}' with tp '${ul_cell_tp}'
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
# #check tti
# check bler and pair is correct in ttitrace1
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_C_case01_1.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# 
# Check tti_UE12_corrThd_0.5
#     Log To Console    ${\n}--tti_UE12_corrThd_0.5--
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_ul_UE12_corrThd_05_case1.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check tti_UE12_corrThd_0.05
#     Log To Console    ${\n}--tti_UE12_corrThd_0.05--
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_ul_UE12_corrThd_005_case1.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check tti_UE34_corrThd_0.05
#     Log To Console    ${\n}--tti_UE34_corrThd_0.05--
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_ul_UE34_corrThd_005_case1.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# 
# #0.5-50;   0.1-10;   0.05-5
# online change corrThd '${corrThd}'
# 	${corrthd_scf}     evaluate    ${corrThd}*100
#     Log To Console    ${\n}=======online_change_corrThd_${corrThd}========
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0    parameter=ulMuMimoCorrThd
#     ...    operation=update    value=${corrthd_scf}    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '4s' for stabible
# 
# 
# check bler and pair is correct in ttitrace
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_A_B4c_case08.ini
# 	...    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}check_pair${/}