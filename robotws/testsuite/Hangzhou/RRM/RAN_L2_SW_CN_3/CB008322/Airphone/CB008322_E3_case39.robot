# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# Force Tags    owner_menzheng    AP    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_BOO_AP_LOO    CRT
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8322_E3_case39_MP.xml
# ${AIRPHONE_NAME}    IPHY_2T1F.xml
# ${WTS_NAME}    WTS_8322_E3_case39.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog    
# 
# ${FILTER_f1ap}    (f1ap) && (nr-rrc.supportedSRS_TxPortSwitch)
# @{titles_f1ap}    nr-rrc.supportedSRS_TxPortSwitch
# ${FILTER_1}    (dldata_pdcchsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_2}    (dldata_pdschsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# @{titles_1}    DlData_DciInfo.patternId_item
# @{titles_2}    DlData_PdschGrant.patternId_item
# @{titles_3}    DlData_CsiRsResource_t.patternId_item
# ${EGATE_TAG}      MUmimo
# ${UE_NUM_SA}      7
# ${BIP_TAG}    8322_bip
# ${BIP_TAG_1}    8322_bip_1
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
# ...    NUMBER_OF_FILES=30
# 
# 
# *** Test Cases ***
# CB008322_E3_case039_subbandBeam_interwork_TDD_TDD_DL_2CC_SA_scell_change_actSCellReleaseBadSCellRlq_release_TAS_SRS
#     Add RD
#     #Active GNB L2 feature debug traces
#     Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'SA_ue' file
#     UE from '1' to '2' SA Register
#     DL and UL data to '1' for dl_trf '7'
#     DL and UL data to '2' for dl_trf '7'
#     scell A1 addition	
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti'
#     UE1 scell change
#     UE2 scell RLQ release
#     Start collect bip log for LOOO
#     Wait for '1s' to stop bip log with name'bip'
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti2'
#     UE1 send bad CQI
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti3'	
#     Stop capture gnb and ap syslog in 'SA_ue' file
#     
# *** Keywords ***
# Add RD
# 	#rdMinSrsUePeriodicity,default=80 slot(0x50)
# 	Add GNB swconfig    0x5805b0:80
# 	Add GNB swconfig    0x5805b1:80
# 	Add GNB swconfig    0x5805b2:50
# 	Add GNB swconfig    0x58076c:0x1                                  
# 	Add GNB swconfig    0x58076d:0x50 
# 	Add GNB swconfig    0x5805b5:10                                             
# 
# scell A1 addition
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=1-2 meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=3 event\=A1 srsrp_nr\=100
#     Wait '3s' for stabible
#     airphone_execute_egate_command    ue_measurement_send_nr id\=2 meas_id\=3 event\=A1 srsrp_nr\=120
#     Wait '10s' for stabible
# 	
# UE1 scell change
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=5 event\=A1 srsrp_nr\=120
#     Wait '3s' for stabible	
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti1'
# 	
# UE2 scell RLQ release
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=3 scell\=1
#     Wait '3s' for stabible
#     #Check Scell deactive and release
# 	
# Check Scell deactive and release
#     wait_for_message_in_syslog_file    ModifType:DEACTIVATE    timeout=300    alias=collect_gnb
#     wait_for_message_in_syslog_file    SCellIndex 1 deactivated successfully    timeout=300    alias=collect_ap
# 
# UE1 send bad CQI
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=4 cqi\=15 cqi_mode\=fixed ri\=2 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=4 scell\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=4 scell\=0
# 	
# #==========SA=======================
# UE from '${lo}' to '${hi}' SA Register
# 	: FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
# 	\	airphone_cleanup_egate_console_log
#      \	Log To Console   ${\n}-----register UE ${ue} ------
#      \	SA Register UE ${ue}
#      \	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}   unzip=TRUE
# 	 
# SA Register UE ${UE_ID}
# 	Airphone SA Attach    ue_id=${UE_ID}
# 	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
# 	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
# 	Wait '3s' for stabible	
# 
# Get SA '${ue}' crnti in RRC log
#     Log To Console   check UE RRC log to get ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}/egate_console.log.001   crnti: (\\d+)
#     [return]     ${rnti_list[0]}
# 
# SA send data '${UE_NUM_SA}' UEs
#     : FOR    ${num}    IN RANGE    2    ${UE_NUM_SA}+1
#     \    SA send mutiple trf dl data    ${num}    1    20M   ${num}
#     \    SA send mutiple trf ul data    ${num}    1    30M    ${num}
#      
# DL and UL data to '${UE_ID}' for dl_trf '${num}'
#     Log To Console    DL*4 and UL*3 data  to UE ${UE_ID}
# 	airphone_cleanup_egate_console_log	
#     : FOR    ${i}    IN RANGE    1    ${num}+1
#     \	Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=${i}  
#     Airphone SA Start Data Traffic    ${UE_ID}   UL   75M    pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Wait '4s' for stabible
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_data_UE_${UE_ID}   unzip=TRUE	
# 
# DL and UL data to '${UE_ID}' little
#     Log To Console    DL*4 and UL*3 data  to UE ${UE_ID}
#     airphone_cleanup_egate_console_log	
#     Airphone SA Start Data Traffic    ${UE_ID}   DL   20M    pdu_id=${UE_ID}   duration=3600   trf_id=1  
#     Airphone SA Start Data Traffic    ${UE_ID}   UL   50M    pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Wait '4s' for stabible
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_data_UE_${UE_ID}   unzip=TRUE	
# 	
# check throughput from SA UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
# 	${cell_tp_dl}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   Log To Console    Check throughput UE${num}
#     \      ${dl_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pdsch    tput_type=ave
#     \      ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
#     \      Log To Console		dl ${dl_tput_Mb}
#     \      ${cell_tp_dl}    evaluate    ${cell_tp_dl}+${dl_tput_Mb}
#     Log To Console		=====dl_cell_tp ${cell_tp_dl}=====
#     run keyword and continue on failure    should be true    ${cell_tp_dl}>=${dl_cell_tp}
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
# 
# #check tti
# Check ttitrace
#     Log To Console    Check Bler and beamtype in ttiTrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case22.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case22_1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# #check RRC
# check UE '${ue_id}' SRS in RRC log
#     Log To Console   check UE ${ue_id} SRS in RRC log
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_ue${ue_id}_case3.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
