# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_zhang    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G   SBTS23R1
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_frame_1208_case1.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL_L1bypass.xml
# 
# ${L1BYP_XML}    L1By_H3V0_H8V0_switch_case1.xml	
# ${WTS_NAME}    wts_8360_case1.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# 
# @{titles_1}    DlData_DciInfo.patternId_item    3gpp.rnti
# @{titles_2}    DlData_PdschGrant.patternId_item     3gpp.rnti
# @{titles_3}    DlData_CsiRsResource_t.patternId_item    DlData_CsiRsResource_t.density
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# ...    NUMBER_OF_FILES=30
# *** Test Cases ***
# CB008360_A_B2a_case01_two_rank1_Ues_paired_with_correlation_checking
#     Upload airphone l1bypass to iphy
# 	#Active GNB L2 feature debug traces
# 	
#     Prepare gnb onair   
#     Start capture gnb and ap syslog in 'SYSLOG_1' file
# 
# #UE 1,2：switch between 10° and 30°
# 	UE from '1' to '2' SA Register and check
# 	run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '1' to '2' with tp '140'
# 
# 	Start collect ttitrace
# 	Wait for '3s' to stop ttitrace with name'tti_UE12_corrThd_05'
# 	# UE1,UE2, pair ratio=1,cell_tp=136M
# 	run keyword and continue on failure   Check tti_UE12_corrThd_0.5
# 	Stop capture gnb and ap syslog in 'SYSLOG_1' file
# 
#     Start capture gnb and ap syslog in 'SYSLOG_2' file
# 	online change corrThd '0.05'
# 	run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '1' to '2' with tp '70'
# 	
# 	#Set test Variable	 ${rnti_1}	55559
# 	#Set test Variable	 ${rnti_2}	53719
# 	#Set test Variable	 ${rnti_3}	20031
# 	#Set test Variable	 ${rnti_4}	51879
# 	Start collect ttitrace
# 	Wait for '3s' to stop ttitrace with name'tti_UE12_corrThd_005'
# 	# UE1,UE2, pair ratio<1,cell_tp=132M, when UE1 and UE2 10°， won't pair
# 	#when 30°，pair ratio=1; when 10°，pair ratio <1
# 	run keyword and continue on failure   Check tti_UE12_corrThd_0.05
# 	DeRegister UE from '1' to '2'
#     Stop capture gnb and ap syslog in 'SYSLOG_2' file
#     
#     Start capture gnb and ap syslog in 'SYSLOG_3' file
# #UE 3,4：30°， coma not switch	
# 	UE from '3' to '4' SA Register and check
# 	
# 	run keyword and continue on failure	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '3' to '4' with tp '140'
# 	
# 	Start collect ttitrace
# 	Wait for '3s' to stop ttitrace with name'tti_UE34_corrThd_005'	
# 	# UE3,UE4, 30° not switch; pair ratio=1,cell_tp=137M,
# 	run keyword and continue on failure   Check tti_UE34_corrThd_0.05
# 	
# 	DeRegister UE from '3' to '4'
# 		
# 	Stop capture gnb and ap syslog in 'SYSLOG_3' file
# 
# *** Keywords ***
# #UE_id: 1-2
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
#     Log To Console    UL 100M data  to UE ${UE_ID}   
#     Airphone SA Start Data Traffic    ${UE_ID}    UL   100M   pdu_id=${UE_ID}   duration=3600   trf_id=1
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
#     run keyword and continue on failure    should be true    ${cell_tp_ul}>${ul_cell_tp}
#      
# #check tti
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
