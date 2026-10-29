# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_menzheng    AP    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_BOO_AP_LOO    CRT
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8322_E3_case41_nidd.xml
# ${AIRPHONE_NAME}    IPHY_2T2F.xml
# ${WTS_NAME}    WTS_8322_E3_case41.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog    
# 
# ${FILTER_f1ap}    itf_l2_ps_user_usersetupreq
# @{titles_f1ap}    3gpp.rnti    itf_l2_ps_UeCapability.dlShortTermBeamformingCapability_item
# ${FILTER}    uldata_puschreceivereq||uldata_srsreceivereq
# @{titles}    UlData_puschReceiveReqGrant_t.numOfPuschSymbols    3gpp.subcellid    3gpp.sfn    3gpp.slot
# 
# ${EGATE_TAG}      MUmimo
# ${UE_NUM_SA}      7
# ${BIP_TAG}    8322_bip
# ${BIP_TAG_1}    8322_bip_1
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
# ...    NUMBER_OF_FILES=30
# ${PROFILE1}    ue_measurement_send_nr id\=1 meas_id\=4 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=50 nrsrp_nr\=80 nrsrq_nr\=80
# ${PROFILE2}    ue_measurement_send_nr id\=1 meas_id\=9 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=53 nrsrp_nr\=80 nrsrq_nr\=80
# 
# 
# *** Test Cases ***
# CB008322_E3_case41_subbandBeam_interwork_FDD_TDD_DL_and_UL_2CC_SA_Reject_WB_TAS_Request_in_Scell
#     #Add RD
#     set sctp rto time
#     rdEnableNidd For 8322
#     #Add RD for CB009496
#     #Active GNB L2 feature debug traces
#     Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'SA_ue' file
#     UE from '1' to '7' SA Register
#     DL and UL data to '1' for dl_trf '6'
#     SA send data '${UE_NUM_SA}' UEs
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti'
#     Start collect bip log for LOOO
#     Wait for '1s' to stop bip log with name'bip'
#     Check FDD pusch shorten and pcell beamtype for wideband   tti   bip
#     UE1 handover TDD cell
#     UE1 handover back to FDD cell
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti2'
#     Start collect bip log for LOOO
#     Wait for '1s' to stop bip log with name'bip2'
#     Check FDD pusch shorten and pcell beamtype for wideband    tti2   bip2
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
# rdEnableNidd For 8322
# 	Add GNB swconfig    0x580789:1		#rdEnableNidd For 8322
# 	Wts Execute Aashell Command   
# 	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
# 
# set sctp rto time
#     ${output}=    Run    sudo sysctl -w net.sctp.rto_min=100
#                                                                                                             
# UE1 handover TDD cell
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=1 event\=A2 srsrp_nr\=11 srsrq_nr\=11
#     Wait '3s' for stabible	
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
#     airphone_execute_egate_command    ${PROFILE1}
#     Wait '3s' for stabible	
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=7 event\=A1 srsrp_nr\=120
#     Wait '3s' for stabible
#     UE send RANK4	
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti1'
#     Start collect bip log for LOOO
#     Wait for '1s' to stop bip log with name'bip1'
#     Check FDD pusch shorten and pcell beamtype for wideband    tti1   bip1
# 	Check pcell beamtype for wideband and fake drx
# 	
# UE1 handover back to FDD cell
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=5 event\=A2 srsrp_nr\=11 srsrq_nr\=11
#     Wait '3s' for stabible	
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
#     airphone_execute_egate_command    ${PROFILE2}
#     Wait '3s' for stabible
#     UE send RANK4
# 	Check handover
# 	
# UE send RANK4
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 cqi_mode\=fixed ri\=3 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=3 scell\=0-1
# 
# UE7 DeRegister and Register
#     DeRegister UE from '7' to '7'
#     UE from '7' to '7' SA Register
#     DL and UL data to '7' for dl_trf '1'
# 	
# #==========SA=======================
# UE from '${lo}' to '${hi}' SA Register
# 	: FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
#     \  airphone_cleanup_egate_console_log
#     \  Log To Console   ${\n}-----register UE ${ue} ------
#     \  Start collect UE f1ap    UE${ue}_attach_f1ap
#     \  SA Register UE ${ue}
#     \  airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}   unzip=TRUE
#     \  Stop collect UE f1ap    UE${ue}_attach_f1ap
#     #\  run keyword and continue on failure    check UE f1ap bip    UE${ue}_attach_f1ap		
# 	 
# SA Register UE ${UE_ID}
# 	Airphone SA Attach    ue_id=${UE_ID}
# 	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
# 	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
# 	Wait '5s' for stabible	
# 
# Get SA '${ue}' crnti in RRC log
#     Log To Console   check UE RRC log to get ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}_HO/egate_console.log.001   crnti: (\\d+)
#     [return]     ${rnti_list[0]}
# 
# SA send data '${UE_NUM_SA}' UEs
#     : FOR    ${num}    IN RANGE    2    ${UE_NUM_SA}+1
#     \    SA send mutiple trf dl data    ${num}    1    20M   ${num}
#     \    SA send mutiple trf ul data    ${num}    1    50M    ${num}
#      
# DL and UL data to '${UE_ID}' for dl_trf '${num}'
#     Log To Console    DL*6 and UL*1 data  to UE ${UE_ID}
# 	  airphone_cleanup_egate_console_log	
#     : FOR    ${i}    IN RANGE    1    ${num}+1
#     \	Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=${i}  
#     Airphone SA Start Data Traffic    ${UE_ID}   UL   75M    pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Wait '4s' for stabible
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_data_UE_${UE_ID}   unzip=TRUE	
# 
# DL and UL data to '${UE_ID}' little
#     Log To Console    DL*4 and UL*3 data  to UE ${UE_ID}
#     airphone_cleanup_egate_console_log	
#     Airphone SA Start Data Traffic    ${UE_ID}   DL   50M    pdu_id=${UE_ID}   duration=3600   trf_id=1  
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
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case41.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case41_1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case41_2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# #check RRC
# check UE '${ue_id}' SRS in RRC log
#     Log To Console   check UE ${ue_id} SRS in RRC log
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_ue${ue_id}_case3.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
# 
# Start collect UE f1ap
#     [Arguments]     ${bip_file}
#     Log To Console    Start collect '${bip_file}' tcpdump
#     ${executor_oam_vm}    Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
#     Start Tcpdump    name=${bip_file}    options= -i any -C 300    remote_info=${executor_oam_vm}
# 
# Stop collect UE f1ap
#     [Arguments]     ${bip_file}
#     Log To Console    Stop collect '${bip_file}' tcpdump
#     Stop Tcpdump    ${bip_file}    ${TEST_LOG_DIRECTORY()}/All/${bip_file}
# 	
# check UE f1ap bip
#     [Arguments]     ${bip_title}		
#     Log To Console   ${\n}---check bip---
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_title}/${bip_title}.pcap
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_title}/${bip_title}.csv    ${FILTER_f1ap}    ${titles_f1ap}
#     Check Log With Au2anlysis    ${CURDIR}/ini/f1ap_case41.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}
# 	
# Check FDD pusch shorten and pcell beamtype for wideband
#     [Arguments]     ${tti_title}	${bip_title}
# 	Merge_pcaps    ${bip_title}
# 	${subcellid_}=    getsubcellid    ${TEST_LOG_DIRECTORY()}/All/${tti_title}_dl.csv    50
# 	Set test Variable    ${subcellid_tdd}    ${subcellid_}
# 	${subcellid_}=    getsubcellid    ${TEST_LOG_DIRECTORY()}/All/${tti_title}_dl.csv    53
# 	Set test Variable    ${subcellid_fdd}    ${subcellid_}
# 	run keyword and continue on failure    Convert BIP To CSV    ${test_log_directory()}/All/${bip_title}/bip_out.pcap
# 	...    ${test_log_directory()}/All/${bip_title}/bip_check.csv    ${FILTER}    ${titles}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ini_path=${CURDIR}/ini/fdd_pusch_shorten_case41.ini
# 	...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}
# 	
# Merge_pcaps
#     [Arguments]     ${bip_title}	
# 	TAF_SSH.Connect To    127.0.0.1    ute    ute    alias=bsh
# 	TAF_SSH.Execute    cd    connection=bsh
# 	TAF_SSH.Send Command    cd ${test_log_directory()}/All/${bip_title};mergecap -w bip_out.pcap *.pcap    connection=bsh
# 
# Check handover
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_1_HO_back   unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/handover_case41.ini    log_need_to_check=u
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_1_HO_back
# 	
# Check pcell beamtype for wideband and fake drx
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_1_HO   unzip=TRUE
#     ${ue1_rnti}    Get SA '1' crnti in RRC log
#     set suite variable     ${ue1_rnti}
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/8322_E3_case41.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#      run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/fakedrx_on_case41.ini    log_need_to_check=pu
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_1_HO
# 
# Check pcell beamtype for subband and normal drx
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/8322_E3_case42_dft.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#      airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE1_2   unzip=TRUE
#      run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_ue1_fakedrx_off_case42.ini    log_need_to_check=p
