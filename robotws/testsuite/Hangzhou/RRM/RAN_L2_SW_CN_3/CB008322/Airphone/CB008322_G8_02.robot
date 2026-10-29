# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_menzheng    AP    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_BOO_AP_LOO    CRT
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8322_G8_case02.xml
# ${AIRPHONE_NAME}    IPHY_2T2F_8x4.xml
# ${WTS_NAME}    WTS_8322_G8_case02.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog    
# 
# ${FILTER_f1ap}    itf_l2_ps_user_usersetupreq
# @{titles_f1ap}    3gpp.rnti    itf_l2_ps_UeCapability.dlShortTermBeamformingCapability_item
# ${FILTER_pusch}    uldata_puschreceivereq||uldata_srsreceivereq
# @{titles_pusch}    UlData_puschReceiveReqGrant_t.numOfPuschSymbols    UlData_srsReceiveReqSubcell_t.srsBwvEnable    3gpp.subcellid    3gpp.sfn
# ...    3gpp.slot
# ${FILTER_pdsch}    uldata_srsreceivereq||dldata_pdschsendreq
# @{titles_pdsch}    DlData_PdschGrant.numOfPdschSymbols    UlData_srsReceiveReqSubcell_t.srsBwvEnable    3gpp.subcellid    3gpp.sfn    3gpp.slot
# ...    3gpp.rnti
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
# CB008322_G8_case02_subbandBeam_interwork_Critical_band_CA_5GC001208_A1_rdSkipPdschTas_true_CA_first
#     Add RD
#     #Add RD for CB009496
#     rdEnableNidd For 8322
#     Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'SA_ue' file
#     UE1 SA Register
#     UE2 SA Register
#     Stop capture gnb and ap syslog in 'SA_ue' file
#     
# *** Keywords ***
# Add RD
# 	#rdMinSrsUePeriodicity,default=80 slot(0x50)
# 	Add GNB swconfig    0x58079f:1		#whether to skip FR1 CA UE on FDD SCell for slot (symbol 6) cb                               
# 	Add GNB swconfig	0x590179:1		# rdCsiRsReconfigCellToUE
# 	Wts Execute Aashell Command   
# 	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
# 
# rdEnableNidd For 8322
# 	Add GNB swconfig    0x580789:1		#rdEnableNidd For 8322
#  
# UE1 SA Register
#     UE from '1' to '1' SA Register
#     DL and UL data to '1' for dl_trf '7'
# 	airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=3 event\=A1 srsrp_nr\=100
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti'
#     Start collect bip log for LOOO
#     Wait for '1s' to stop bip log with name'bip'
#     Check FDD pusch shorten and pdsch shorten skip for CB UE1   tti   bip
#     SA DeRegister UE '1'
# 
# UE2 SA Register
#     UE from '2' to '2' SA Register
#     DL and UL data to '2' for dl_trf '7'
# 	airphone_execute_egate_command    ue_measurement_send_nr id\=2 meas_id\=3 event\=A1 srsrp_nr\=100
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti1'
#     Start collect bip log for LOOO
#     Wait for '1s' to stop bip log with name'bip1'
#     Check FDD pusch shorten and pdsch shorten skip for CB UE2   tti1   bip1
#     SA DeRegister UE '2'
# 	
# UE3 SA Register
#     UE from '3' to '3' SA Register
#     DL and UL data to '3' for dl_trf '13'
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti2'
#     Start collect bip log for LOOO
#     Wait for '1s' to stop bip log with name'bip2'
#     Check FDD pusch shorten and pdsch shorten skip for CB UE3   tti2   bip2
#     SA DeRegister UE '3'
# 	
# UE send RANK4
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 cqi_mode\=fixed ri\=3 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=3 scell\=0-1
# 
# SA DeRegister UE '${ue}'
#     airphone_sa_detach    ue_id=${ue}    timeout=5
# 	
# #==========SA=======================
# UE from '${lo}' to '${hi}' SA Register
# 	: FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
#     \  airphone_cleanup_egate_console_log
#     \  Log To Console   ${\n}-----register UE ${ue} ------
#     \  SA Register UE ${ue}
#     \  airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}   unzip=TRUE	
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
# 	airphone_cleanup_egate_console_log	
#     : FOR    ${i}    IN RANGE    1    ${num}+1
#     \	Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=${i}  
#     Airphone SA Start Data Traffic    ${UE_ID}   UL   100M    pdu_id=${UE_ID}   duration=3600   trf_id=1
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
# Check FDD pusch shorten and pdsch shorten skip for CB UE1
#     [Arguments]     ${tti_title}	${bip_title}
# 	Merge_pcaps    ${bip_title}
# 	${subcellid_}=    getsubcellid    ${TEST_LOG_DIRECTORY()}/All/${tti_title}_dl.csv    50
# 	Set test Variable    ${subcellid_tdd}    ${subcellid_}
# 	${subcellid_}=    getsubcellid    ${TEST_LOG_DIRECTORY()}/All/${tti_title}_dl.csv    53
# 	Set test Variable    ${subcellid_fdd}    ${subcellid_}
# 	run keyword and continue on failure    Convert BIP To CSV    ${test_log_directory()}/All/${bip_title}/bip_out.pcap
# 	...    ${test_log_directory()}/All/${bip_title}/bip_check_pdsch.csv    ${FILTER_pdsch}    ${titles_pdsch}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ini_path=${CURDIR}/ini/fdd_pdsch_shorten_G8_case02.ini
# 	...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ini_path=${CURDIR}/ini/fdd_pdsch_skip_G8_case02.ini
# 	...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/ini/beamtype_G8_ue1_case02.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/ini/beamtype_G8_ue1_ul.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check FDD pusch shorten and pdsch shorten skip for CB UE2
#     [Arguments]     ${tti_title}	${bip_title}
# 	Merge_pcaps    ${bip_title}
# 	${subcellid_}=    getsubcellid    ${TEST_LOG_DIRECTORY()}/All/${tti_title}_dl.csv    50
# 	Set test Variable    ${subcellid_tdd}    ${subcellid_}
# 	${subcellid_}=    getsubcellid    ${TEST_LOG_DIRECTORY()}/All/${tti_title}_dl.csv    53
# 	Set test Variable    ${subcellid_fdd}    ${subcellid_}
# 	run keyword and continue on failure    Convert BIP To CSV    ${test_log_directory()}/All/${bip_title}/bip_out.pcap
# 	...    ${test_log_directory()}/All/${bip_title}/bip_check_pusch.csv    ${FILTER_pusch}    ${titles_pusch}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ini_path=${CURDIR}/ini/fdd_pusch_shorten_G8_typeA.ini
# 	...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}
# 	run keyword and continue on failure    Convert BIP To CSV    ${test_log_directory()}/All/${bip_title}/bip_out.pcap
# 	...    ${test_log_directory()}/All/${bip_title}/bip_check_pdsch.csv    ${FILTER_pdsch}    ${titles_pdsch}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ini_path=${CURDIR}/ini/fdd_pdsch_not_shorten_G8_case02.ini
# 	...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ini_path=${CURDIR}/ini/fdd_pdsch_not_skip_G8_case02.ini
# 	...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/ini/beamtype_G8_ue2_case02.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/ini/beamtype_G8_ue2_ul.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
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
