# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# Force Tags    owner_sasun    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_B_case09.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL_2subcell_case5.xml
# 
# ${L1BYP_XML}    L1By_8360_B_case5.xml	
# ${WTS_NAME}    wts_8360_B_case5.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# 
# @{titles_1}    DlData_DciInfo.patternId_item    3gpp.rnti
# @{titles_2}    DlData_PdschGrant.patternId_item     3gpp.rnti
# @{titles_3}    DlData_CsiRsResource_t.patternId_item    DlData_CsiRsResource_t.density
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# ...    NUMBER_OF_FILES=30
# 
# ${egate_set_profile_1}	bler_testmode_nr profile_id\=1 ul_bler\=100,100
# ${egate_set_profile_2}	bler_testmode_nr profile_id\=1 ul_bler\=2
# ${egate_set_profile_2}	bler_testmode_nr profile_id\=1 ul_bler\=2,3
# ${bler_act}   		ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=activate
# ${bler_deact}   	ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
# *** Test Cases ***
# CB008360_B_B3a_case04_four_rank1_Ues_8DL8UL_Max_4layer_without_retransmission_without_tapering
#     Upload airphone l1bypass to iphy
# 	Add RD param
# 	Active GNB L2 feature debug traces
# 	Prepare gnb onair
# 	Start capture gnb and ap syslog in 'after_onair' file
#     Attach one SA UE'1'
#     SA send ue '1' mutiple trf '1' for each '60M' UL data
#     Wait '3s' for stabible
# 	UE from '2' to '8' SA Register and check
# 	run keyword and continue on failure	 check throughput_without_tapering from UE '1' to '8' with tp '90'
# 	Start collect ttitrace
# 	Wait for '3s' to stop ttitrace with name'tti_8UE_rank1'
#     run keyword and continue on failure    check bler and pair is correct in ttitrace
#     Online change actUlMuMimoTapering to true
#     run keyword and continue on failure	 check throughput_with_tapering from UE '1' to '8' with tp '90'
# *** Keywords ***
# Add RD param
# 	Add GNB swconfig    0x58037C:1
# 	# enable_rdNewTddCellSlotModel of CB008940
# 	Add GNB swconfig    0x420062:1
# 	
# 
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
# 	run keyword if    ${ue_id}==5   Set test Variable	 ${rnti_5} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==6   Set test Variable	 ${rnti_6} 	${rnti_list[0]}
# 	run keyword if    ${ue_id}==7   Set test Variable	 ${rnti_7} 	${rnti_list[0]}
# 	run keyword if    ${ue_id}==8   Set test Variable	 ${rnti_8} 	${rnti_list[0]}
#     
# UL data to '${UE_ID}'
#     Log To Console    UL 7M data  to UE ${UE_ID}
#     Airphone SA Start Data Traffic    ${UE_ID}    UL   7M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Wait '4s' for stabible
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${UE_ID}  	pdu_id= ${UE_ID}   
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
# 
# 
# #check throughput
# check throughput_without_tapering from UE '${low}' to '${hi}' with tp '${ul_cell_tp}'
# 	${cell_tp_ul_without_tapering}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   Log To Console    Check throughput UE${num}
#     \      ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${num}  	pdu_id= ${num}
#     \      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     \      Log To Console		ul ${ul_tput_Mb}    
#     \      ${cell_tp_ul_without_tapering}    evaluate    ${cell_tp_ul_without_tapering}+${ul_tput_Mb}
#     Log To Console		=====cell_tp_ul_without_tapering ${cell_tp_ul_without_tapering}=====
#     run keyword and continue on failure    should be true    ${cell_tp_ul_without_tapering}>${ul_cell_tp}
# 
# check throughput_with_tapering from UE '${low}' to '${hi}' with tp '${ul_cell_tp}'
# 	${cell_tp_ul_with_tapering}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   Log To Console    Check throughput UE${num}
#     \      ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${num}  	pdu_id= ${num}
#     \      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     \      Log To Console		ul ${ul_tput_Mb}
#     \      ${cell_tp_ul_with_tapering}    evaluate    ${cell_tp_ul_with_tapering}+${ul_tput_Mb}
#     Log To Console		=====cell_tp_ul_with_tapering ${cell_tp_ul_with_tapering}=====
#     run keyword and continue on failure    should be true    ${cell_tp_ul_with_tapering}>${ul_cell_tp}
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
# copy
# 	Prepare gnb onair
#     Start capture gnb and ap syslog in 'SYSLOG_1' file
# 
# #UE 1,2：switch between 10° and 30°
# 	UE from '1' to '2' SA Register and check
# 	run keyword and continue on failure	check throughput from UE '1' to '2' with tp '130'
# 
# 	Start collect ttitrace
# 	Wait for '3s' to stop ttitrace with name'tti_UE12_corrThd_05'
# 	# UE1,UE2, pair ratio=1,cell_tp=136M
# 	run keyword and continue on failure   Check tti_UE12_corrThd_0.5
# 	Stop capture gnb and ap syslog in 'SYSLOG_1' file
# 
#     Start capture gnb and ap syslog in 'SYSLOG_2' file
# 	online change corrThd '0.05'
# 	run keyword and continue on failure	check throughput from UE '1' to '2' with tp '70'
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
# 	run keyword and continue on failure	check throughput from UE '3' to '4' with tp '130'
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
# Online change actUlMuMimoTapering to true
#     Log To Console   ${\n}-----Online change actUlMuMimoTapering to true ------
# 	TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0    actUlMuMimoTapering    true    online
#     TAF_ADMIN.teardown admin    connection=online
# 	Wait '30s' for stabible
#     Start collect ttitrace
# 	Wait for '3s' to stop ttitrace with name'actUlMuMimoTapering_true'
# 	run keyword and continue on failure    check bler and pair is correct in ttitrace2
# 
# 
# check bler and pair is correct in ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_B_case09_actUlMuMimoTapering_false.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# check bler and pair is correct in ttitrace2
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_B_case09_actUlMuMimoTapering_true.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
