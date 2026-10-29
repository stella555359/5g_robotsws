# *** Settings ***
# Documentation     Author: zhaoyang.xu@nokia-sbell.com
# ...               base on CB008322_E3_case41_subbandBeam_interwork_FDD_TDD_DL_and_UL_2CC_SA_Reject_WB_TAS_Request_in_Scell
# Test Timeout    120 minutes
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_zhaoxu    AP    SBTS00    OPTION_RELATED_ARTIFACTS_5G    CLOUD_5G_I_BOO_AP_LOO
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
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   
# ...   CPRT_MIRRORING='false'    NUMBER_OF_FILES=30
# ${PROFILE1}    ue_measurement_send_nr id\=1 meas_id\=4 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=50 nrsrp_nr\=80 nrsrq_nr\=80
# ${PROFILE2}    ue_measurement_send_nr id\=1 meas_id\=9 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=53 nrsrp_nr\=80 nrsrq_nr\=80
# 
# 
# *** Test Cases ***
# CNI_113494_Case18_FDD_CPRI__PDSCH_and_PUSCH_iBLER_counters_for_SSB_and_refined beams
#     #Add RD
#     set sctp rto time
#     rdEnableNidd For 8322
#     Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'SA_ue' file	
#     UE from '1' to '1' SA Register
#     Start collect ttitrace		
#     Wait for '1s' to stop ttitrace with name'tti'	
#     DL and UL data to '1' for dl_trf '6'
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti_data'
# 	check_pm_counter_when_ue_attach_and_data_send 
#     UE1 handover TDD cell
#     check_pm_counter_when_HO_TDD
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti2'	
#     UE1 handover back to FDD cell
# 	check_pm_counter_when_HO_back_FDD
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
# rdEnableNidd For 8322
# 	Add GNB swconfig    0x580789:1		#rdEnableNidd For 8322
# 	Add GNB swconfig    0x9D0000:15		#as PM counter period update to 15/15=1min	
# 	Add GNB swconfig    0x5806B1:1		#rdActivatePmCounterMonitoring		
# 	Add GNB swconfig    0x5806B2:0xd822002b		#PDSCH_INI_TX_SSB_BEAM
# 	Add GNB swconfig    0x5806B3:0xd822002c		#PDSCH_SUC_INI_TX_SSB_BEAM
# 	Add GNB swconfig    0x5806B2:0xd822002d		#PUSCH_INI_TX_SSB_BEAM
# 	Add GNB swconfig    0x5806B3:0xd822002e		#PUSCH_SUC_INI_TX_SSB_BEAM	
# 	
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
#     Wait '120s' for stabible
#     UE send RANK4	
# 
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
# 	#Check handover
#     Wait '120s' for stabible		
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
#     #\  Start collect UE f1ap    UE${ue}_attach_f1ap
#     \  SA Register UE ${ue}
#     \  airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}   unzip=TRUE
#     #\  Stop collect UE f1ap    UE${ue}_attach_f1ap
#     #\  run keyword and continue on failure    check UE f1ap bip    UE${ue}_attach_f1ap		
# 	 
# SA Register UE ${UE_ID}
# 	Airphone SA Attach    ue_id=${UE_ID}
# 	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
# 	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
# 	Wait '2s' for stabible	
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
#     \	Airphone SA Start Data Traffic    ${UE_ID}   UL   100M   pdu_id=${UE_ID}   duration=3600   trf_id=${i} 	
#     #Airphone SA Start Data Traffic    ${UE_ID}   UL   75M    pdu_id=${UE_ID}   duration=3600   trf_id=1
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
# 
# 
# check_pm_counter_when_ue_attach_and_data_send 
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/pmcounter_1/
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/pmcounter_1${/}	
#     Check_CNI113494_iBler_match_Legacy_counters    ${PM_counter_file}
# 
# check_pm_counter_when_HO_TDD
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/pmcounter_2/
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/pmcounter_2${/}	
#     Check_CNI113494_iBler_match_Legacy_counters    ${PM_counter_file}
# 
# check_pm_counter_when_HO_back_FDD
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/pmcounter_3/
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/pmcounter_3${/}	
#     Check_CNI113494_iBler_match_Legacy_counters    ${PM_counter_file}
# 
# 
# Check_CNI113494_iBler_match_Legacy_counters
#     [Arguments]    ${PM_counter_file}	
# 	Log To Console    \n---------CNI_113494_PDSCH_initial_counter----------
# 	Log To Console    SSB_BEAM:M55330C00043,REFINED_BEAM:M55330C00047,PMI_BEAM:M55330C00030
# 	Log To Console    DFTNTAP_BEAM:M55330C00036,DFTTAP_BEAM:M55330C00032,SUBBAND_BEAM:M55330C00040
# 	${PDSCH_INI_Counter_list}    create list   M55330C00043    M55330C00047     M55330C00030   M55330C00036    M55330C00032    M55330C00040 
#     ${PDSCH_INI_All_Beam_counter_cell1}    	create list
#     ${PDSCH_INI_All_Beam_counter_cell2}    	create list
#     ${PDSCH_INI_All_Beam_counter_cell3}    	create list
#     ${PDSCH_INI_All_Beam_counter_cell4}    	create list	
#     FOR    ${counter_id}    IN    @{PDSCH_INI_Counter_list}
#     ${PDSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
#     append to list    ${PDSCH_INI_All_Beam_counter_cell1}    ${PDSCH_INI_cell1}
#     ${PDSCH_INI_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2    
#     append to list    ${PDSCH_INI_All_Beam_counter_cell2}    ${PDSCH_INI_cell2}
#     ${PDSCH_INI_cell3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=3    
#     append to list    ${PDSCH_INI_All_Beam_counter_cell3}    ${PDSCH_INI_cell3}
#     ${PDSCH_INI_cell4}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=4    
#     append to list    ${PDSCH_INI_All_Beam_counter_cell4}    ${PDSCH_INI_cell4}	
# 	END
# 	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell1:${PDSCH_INI_All_Beam_counter_cell1}
# 	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell2:${PDSCH_INI_All_Beam_counter_cell2}	
# 	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell3:${PDSCH_INI_All_Beam_counter_cell3}	
# 	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell4:${PDSCH_INI_All_Beam_counter_cell4}
# 	${PDSCH_INI_counter_Sum_cell1}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell1})
# 	${PDSCH_INI_counter_Sum_cell2}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell2})
# 	${PDSCH_INI_counter_Sum_cell3}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell3})    
# 	${PDSCH_INI_counter_Sum_cell4}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell4})	
#     Log To Console    \n----------------------end-------------------------
# 
# 
# 	Log To Console    \n---------CNI_113494_PDSCH_initial_Successful_counter----------
# 	Log To Console    SSB_BEAM:M55330C00044,REFINED_BEAM:M55330C00048,PMI_BEAM:M55330C00031
# 	Log To Console    DFTNTAP_BEAM:M55330C00037,DFTTAP_BEAM:M55330C00033,SUBBAND_BEAM:M55330C00041
# 	${PDSCH_SUC_Counter_list}    create list   M55330C00044    M55330C00048     M55330C00031   M55330C00037    M55330C00033    M55330C00041 
#     ${PDSCH_SUC_All_Beam_counter_cell1}    	create list
#     ${PDSCH_SUC_All_Beam_counter_cell2}    	create list
#     ${PDSCH_SUC_All_Beam_counter_cell3}    	create list
#     ${PDSCH_SUC_All_Beam_counter_cell4}    	create list	
#     FOR    ${counter_id}    IN    @{PDSCH_SUC_Counter_list}
#     ${PDSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
#     append to list    ${PDSCH_SUC_All_Beam_counter_cell1}    ${PDSCH_SUC_cell1}
#     ${PDSCH_SUC_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2    
#     append to list    ${PDSCH_SUC_All_Beam_counter_cell2}    ${PDSCH_SUC_cell2}
#     ${PDSCH_SUC_cell3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=3    
#     append to list    ${PDSCH_SUC_All_Beam_counter_cell3}    ${PDSCH_SUC_cell3}
#     ${PDSCH_SUC_cell4}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=4    
#     append to list    ${PDSCH_SUC_All_Beam_counter_cell4}    ${PDSCH_SUC_cell4}	
# 	END
# 	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell1:${PDSCH_SUC_All_Beam_counter_cell1}
# 	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell2:${PDSCH_SUC_All_Beam_counter_cell2}	
# 	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell3:${PDSCH_SUC_All_Beam_counter_cell3}	
# 	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell4:${PDSCH_SUC_All_Beam_counter_cell4}
# 	${PDSCH_SUC_counter_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell1})
# 	${PDSCH_SUC_counter_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell2})
# 	${PDSCH_SUC_counter_Sum_cell3}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell3})    
# 	${PDSCH_SUC_counter_Sum_cell4}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell4})	
# 	Log To Console    \n----------------------end-------------------------
# 	
# 
# 			
#     Log To Console    \n---------CNI_113494_PUSCH_initial_counter------------------
# 	Log To Console    SSB_BEAM:M55330C00045,REFINED_BEAM:M55330C00028,DFTNTAP_BEAM:M55330C00038,DFTTAP_BEAM:M55330C00034
# 	${PUSCH_INI_Counter_list}    create list   M55330C00045    M55330C00028     M55330C00038   M55330C00034
#     ${PUSCH_INI_All_Beam_counter_cell1}    	create list
#     ${PUSCH_INI_All_Beam_counter_cell2}    	create list
#     ${PUSCH_INI_All_Beam_counter_cell3}    	create list
#     ${PUSCH_INI_All_Beam_counter_cell4}    	create list	
#     FOR    ${counter_id}    IN    @{PUSCH_INI_Counter_list}
#     ${PUSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
#     append to list    ${PUSCH_INI_All_Beam_counter_cell1}    ${PUSCH_INI_cell1}
#     ${PUSCH_INI_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2    
#     append to list    ${PUSCH_INI_All_Beam_counter_cell2}    ${PUSCH_INI_cell2}
#     ${PUSCH_INI_cell3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=3    
#     append to list    ${PUSCH_INI_All_Beam_counter_cell3}    ${PUSCH_INI_cell3}
#     ${PUSCH_INI_cell4}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=4    
#     append to list    ${PUSCH_INI_All_Beam_counter_cell4}    ${PUSCH_INI_cell4}	
# 	END	
# 	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell1:${PUSCH_INI_All_Beam_counter_cell1}
# 	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell2:${PUSCH_INI_All_Beam_counter_cell2}	
# 	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell3:${PUSCH_INI_All_Beam_counter_cell3}	
# 	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell4:${PUSCH_INI_All_Beam_counter_cell4}
# 	${PUSCH_INI_counter_Sum_cell1}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell1})
# 	${PUSCH_INI_counter_Sum_cell2}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell2})
# 	${PUSCH_INI_counter_Sum_cell3}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell3})    
# 	${PUSCH_INI_counter_Sum_cell4}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell4})
#     Log To Console    \n----------------------end-------------------------
# 	
# 	Log To Console    \n---------CNI_113494_PUSCH_Successful_initial_counter------------------
# 	Log To Console    SSB_BEAM:M55330C00046,REFINED_BEAM:M55330C00029,DFTNTAP_BEAM:M55330C00039,DFTTAP_BEAM:M55330C00035
# 	${PUSCH_SUC_Counter_list}    create list   M55330C00046    M55330C00029     M55330C00039   M55330C00035
#     ${PUSCH_SUC_All_Beam_counter_cell1}    	create list
#     ${PUSCH_SUC_All_Beam_counter_cell2}    	create list
#     ${PUSCH_SUC_All_Beam_counter_cell3}    	create list
#     ${PUSCH_SUC_All_Beam_counter_cell4}    	create list	
#     FOR    ${counter_id}    IN    @{PUSCH_SUC_Counter_list}
#     ${PUSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
#     append to list    ${PUSCH_SUC_All_Beam_counter_cell1}    ${PUSCH_SUC_cell1}
#     ${PUSCH_SUC_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2    
#     append to list    ${PUSCH_SUC_All_Beam_counter_cell2}    ${PUSCH_SUC_cell2}
#     ${PUSCH_SUC_cell3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=3    
#     append to list    ${PUSCH_SUC_All_Beam_counter_cell3}    ${PUSCH_SUC_cell3}
#     ${PUSCH_SUC_cell4}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=4    
#     append to list    ${PUSCH_SUC_All_Beam_counter_cell4}    ${PUSCH_SUC_cell4}		
# 	END		
# 	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell1:${PUSCH_SUC_All_Beam_counter_cell1}
# 	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell2:${PUSCH_SUC_All_Beam_counter_cell2}	
# 	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell3:${PUSCH_SUC_All_Beam_counter_cell3}	
# 	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell4:${PUSCH_SUC_All_Beam_counter_cell4}
# 	${PUSCH_SUC_counter_Sum_cell1}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell1})
# 	${PUSCH_SUC_counter_Sum_cell2}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell2})
# 	${PUSCH_SUC_counter_Sum_cell3}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell3})    
# 	${PUSCH_SUC_counter_Sum_cell4}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell4})
#     Log To Console    \n----------------------end-------------------------
# 
# 	
# 	Log To Console    \n----Legacy_PDSCH_INITX_64TBL_MCS_00-28_and_256TBL_MCS_00-27_and_LOWSE_MCS_00-28----------
# 	Log To Console    PDSCH_INITX_64TBL_MCS_00-28:M55300C00000----M55300C00028
# 	Log To Console    PDSCH_INITX_256TBL_MCS_00-27:M55300C04000---M55300C04027
# 	Log To Console    PDSCH_INITX_LOWSE_MCS_00-28:M55366C01000----M55366C01028
#     ${PDSCH_INITX_64TBL_MCS_00_28_cell1}    	create list
#     ${PDSCH_INITX_64TBL_MCS_00_28_cell2}    	create list
#     ${PDSCH_INITX_64TBL_MCS_00_28_cell3}    	create list
#     ${PDSCH_INITX_64TBL_MCS_00_28_cell4}    	create list	
#     ${PDSCH_INITX_256TBL_MCS_00_27_cell1}    	create list
#     ${PDSCH_INITX_256TBL_MCS_00_27_cell2}    	create list
#     ${PDSCH_INITX_256TBL_MCS_00_27_cell3}    	create list
#     ${PDSCH_INITX_256TBL_MCS_00_27_cell4}    	create list	
#     ${PDSCH_INITX_LOWSE_MCS_00_28_cell1}    	create list
#     ${PDSCH_INITX_LOWSE_MCS_00_28_cell2}    	create list
#     ${PDSCH_INITX_LOWSE_MCS_00_28_cell3}    	create list
#     ${PDSCH_INITX_LOWSE_MCS_00_28_cell4}    	create list	
# 	
# 	FOR    ${i}    IN RANGE     0     29
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=1
# 	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell1}   ${64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=1
# 	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell1}   ${LOW_value}
# 	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=2
# 	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell2}   ${64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=2
# 	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell2}   ${LOW_value}	
# 	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=3
# 	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell3}   ${64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=3
# 	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell3}   ${LOW_value}
# 	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=4
# 	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell4}   ${64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=4
# 	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell4}   ${LOW_value}	
# 	END
# 
# 	FOR    ${i}    IN RANGE     0     28
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=1
# 	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell1}   ${256_value}
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=2
# 	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell2}   ${256_value}
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=3
# 	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell3}   ${256_value}	
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=4
# 	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell4}   ${256_value}
# 	END	
# 	Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell1:${PDSCH_INITX_64TBL_MCS_00_28_cell1}
#     Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell2:${PDSCH_INITX_64TBL_MCS_00_28_cell2}
#     Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell3:${PDSCH_INITX_64TBL_MCS_00_28_cell3}
#     Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell4:${PDSCH_INITX_64TBL_MCS_00_28_cell4}
#     Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell1:${PDSCH_INITX_256TBL_MCS_00_27_cell1}
#     Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell2:${PDSCH_INITX_256TBL_MCS_00_27_cell2}
#     Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell3:${PDSCH_INITX_256TBL_MCS_00_27_cell3}
#     Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell4:${PDSCH_INITX_256TBL_MCS_00_27_cell4}
#     Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell1:${PDSCH_INITX_LOWSE_MCS_00_28_cell1}
#     Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell2:${PDSCH_INITX_LOWSE_MCS_00_28_cell2}
#     Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell3:${PDSCH_INITX_LOWSE_MCS_00_28_cell3}
#     Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell4:${PDSCH_INITX_LOWSE_MCS_00_28_cell4}
# 	${PDSCH_INITX_64TBL_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell1})
# 	${PDSCH_INITX_64TBL_Sum_cell2}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell2})
# 	${PDSCH_INITX_64TBL_Sum_cell3}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell3})
# 	${PDSCH_INITX_64TBL_Sum_cell4}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell4})	
# 	${PDSCH_INITX_256TBL_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell1})
# 	${PDSCH_INITX_256TBL_Sum_cell2}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell2})
# 	${PDSCH_INITX_256TBL_Sum_cell3}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell3})
# 	${PDSCH_INITX_256TBL_Sum_cell4}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell4})		
# 	${PDSCH_INITX_LOWSE_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell1})
# 	${PDSCH_INITX_LOWSE_Sum_cell2}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell2})
# 	${PDSCH_INITX_LOWSE_Sum_cell3}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell3})
# 	${PDSCH_INITX_LOWSE_Sum_cell4}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell4})		
#     ${PDSCH_LG_INITX_Sum_cell1}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell1}+${PDSCH_INITX_256TBL_Sum_cell1}+${PDSCH_INITX_LOWSE_Sum_cell1}
#     ${PDSCH_LG_INITX_Sum_cell2}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell2}+${PDSCH_INITX_256TBL_Sum_cell2}+${PDSCH_INITX_LOWSE_Sum_cell2}	
#     ${PDSCH_LG_INITX_Sum_cell3}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell3}+${PDSCH_INITX_256TBL_Sum_cell3}+${PDSCH_INITX_LOWSE_Sum_cell3}
#     ${PDSCH_LG_INITX_Sum_cell4}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell4}+${PDSCH_INITX_256TBL_Sum_cell4}+${PDSCH_INITX_LOWSE_Sum_cell4}	
#     Log To Console    \n----------------------end-------------------------
# 
# 	Log To Console    \n----Legacy_PDSCH_SUCC_64TBL_MCS_00-28_and_256TBL_MCS_00-27_and_LOWSE_MCS_00-28----------
# 	Log To Console    PDSCH_SUC_64TBL_MCS_00-28:M55300C01000-----M55300C01028
# 	Log To Console    PDSCH_SUC_256TBL_MCS_00-27:M55300C05000---M55300C05027
# 	Log To Console    PDSCH_SUC_LOWSE_MCS_00-28:M55366C02000----M55366C02028
#     ${PDSCH_SUC_64TBL_MCS_00_28_cell1}    	create list
#     ${PDSCH_SUC_64TBL_MCS_00_28_cell2}    	create list
#     ${PDSCH_SUC_64TBL_MCS_00_28_cell3}    	create list
#     ${PDSCH_SUC_64TBL_MCS_00_28_cell4}    	create list	
#     ${PDSCH_SUC_256TBL_MCS_00_27_cell1}    	create list
#     ${PDSCH_SUC_256TBL_MCS_00_27_cell2}    	create list
#     ${PDSCH_SUC_256TBL_MCS_00_27_cell3}    	create list
#     ${PDSCH_SUC_256TBL_MCS_00_27_cell4}    	create list	
#     ${PDSCH_SUC_LOWSE_MCS_00_28_cell1}    	create list
#     ${PDSCH_SUC_LOWSE_MCS_00_28_cell2}    	create list
#     ${PDSCH_SUC_LOWSE_MCS_00_28_cell3}    	create list
#     ${PDSCH_SUC_LOWSE_MCS_00_28_cell4}    	create list	
# 	
# 	FOR    ${i}    IN RANGE     0     29
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=1
# 	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell1}   ${64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=1
# 	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell1}   ${LOW_value}
# 	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=2
# 	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell2}   ${64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=2
# 	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell2}   ${LOW_value}	
# 	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=3
# 	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell3}   ${64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=3
# 	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell3}   ${LOW_value}
# 	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=4
# 	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell4}   ${64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=4
# 	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell4}   ${LOW_value}	
# 	END
# 
# 	FOR    ${i}    IN RANGE     0     28
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=1
# 	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell1}   ${256_value}
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=2
# 	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell2}   ${256_value}
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=3
# 	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell3}   ${256_value}	
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=4
# 	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell4}   ${256_value}
# 	END	
# 	Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell1:${PDSCH_SUC_64TBL_MCS_00_28_cell1}
#     Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell2:${PDSCH_SUC_64TBL_MCS_00_28_cell2}
#     Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell3:${PDSCH_SUC_64TBL_MCS_00_28_cell3}
#     Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell4:${PDSCH_SUC_64TBL_MCS_00_28_cell4}
#     Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell1:${PDSCH_SUC_256TBL_MCS_00_27_cell1}
#     Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell2:${PDSCH_SUC_256TBL_MCS_00_27_cell2}
#     Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell3:${PDSCH_SUC_256TBL_MCS_00_27_cell3}
#     Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell4:${PDSCH_SUC_256TBL_MCS_00_27_cell4}
#     Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell1:${PDSCH_SUC_LOWSE_MCS_00_28_cell1}
#     Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell2:${PDSCH_SUC_LOWSE_MCS_00_28_cell2}
#     Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell3:${PDSCH_SUC_LOWSE_MCS_00_28_cell3}
#     Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell4:${PDSCH_SUC_LOWSE_MCS_00_28_cell4}
# 	${PDSCH_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell1})
# 	${PDSCH_SUC_64TBL_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell2})
# 	${PDSCH_SUC_64TBL_Sum_cell3}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell3})
# 	${PDSCH_SUC_64TBL_Sum_cell4}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell4})	
# 	${PDSCH_SUC_256TBL_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell1})
# 	${PDSCH_SUC_256TBL_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell2})
# 	${PDSCH_SUC_256TBL_Sum_cell3}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell3})
# 	${PDSCH_SUC_256TBL_Sum_cell4}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell4})		
# 	${PDSCH_SUC_LOWSE_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell1})
# 	${PDSCH_SUC_LOWSE_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell2})
# 	${PDSCH_SUC_LOWSE_Sum_cell3}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell3})
# 	${PDSCH_SUC_LOWSE_Sum_cell4}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell4})		
#     ${PDSCH_LG_SUC_Sum_cell1}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell1}+${PDSCH_SUC_256TBL_Sum_cell1}+${PDSCH_SUC_LOWSE_Sum_cell1}
#     ${PDSCH_LG_SUC_Sum_cell2}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell2}+${PDSCH_SUC_256TBL_Sum_cell2}+${PDSCH_SUC_LOWSE_Sum_cell2}	
#     ${PDSCH_LG_SUC_Sum_cell3}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell3}+${PDSCH_SUC_256TBL_Sum_cell3}+${PDSCH_SUC_LOWSE_Sum_cell3}
#     ${PDSCH_LG_SUC_Sum_cell4}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell4}+${PDSCH_SUC_256TBL_Sum_cell4}+${PDSCH_SUC_LOWSE_Sum_cell4}
#     Log To Console    \n----------------------end-------------------------
# 
# 
# 	Log To Console    \n----Legacy_PUSCH_CP_INI_64TBL_MCS_00-28_and_PUSCH_DFT_INI_64TBL_MCS_00-27------
# 	Log To Console    \n----Legacy_PUSCH_CP_INI_256TBL_MCS_00-27_and_PUSCH_CP_INI_LOWSE_MCS_00-28------
# 	Log To Console    \n----Legacy_PUSCH_DFT_INI_64TBL_SAG_R2_and_PUSCH_DFT_INI_64TBL_SAG_R4------	
# 	Log To Console    PUSCH_CP_INI_64TBL_MCS_00-28:M55302C00000----M55302C00028
# 	Log To Console    PUSCH_DFT_INI_64TBL_MCS_00-27:M55302C06000----M55302C06027
# 	Log To Console    PUSCH_CP_INI_256TBL_MCS_00-27:M55302C11000-----M55302C11027
# 	Log To Console    PUSCH_CP_INI_LOWSE_MCS_00-28:M55367C01000----M55367C01028
# 	Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2:M55370C00007
# 	Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4:M55370C00013	
# 	
# 	
#     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}    	create list
#     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell2}    	create list
#     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell3}    	create list
#     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell4}    	create list		
#     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}    	create list
#     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2}    	create list
#     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell3}    	create list
#     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell4}    	create list	
#     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}    	create list
#     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell2}    	create list
#     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell3}    	create list
#     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell4}    	create list			
#     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}    	create list
#     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2}    	create list
#     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell3}    	create list
#     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell4}    	create list	
# 	
# 	FOR    ${i}    IN RANGE     0     29
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=1
# 	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}   ${CP_64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=1
# 	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}   ${LOW_value}
# 	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=2
# 	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell2}   ${CP_64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=2
# 	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2}   ${LOW_value}	
# 	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=3
# 	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell3}   ${CP_64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=3
# 	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell3}   ${LOW_value}
# 	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=4
# 	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell4}   ${CP_64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=4
# 	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell4}   ${LOW_value}	
# 	END
# 
# 	FOR    ${i}    IN RANGE     0     28
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=1
# 	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}   ${DFT_64}	
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=1
# 	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}   ${256_value}
# 	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=2
# 	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2}   ${DFT_64}	
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=2
# 	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell2}   ${256_value}
# 	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=3
# 	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell3}   ${DFT_64}		
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=3
# 	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell3}   ${256_value}	
# 	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=4
# 	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell4}   ${DFT_64}	
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=4
# 	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell4}   ${256_value}
# 	END	
# 	
# 	${INI_SAG_R2_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=1	
# 	${INI_SAG_R4_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=1
# 	${INI_SAG_R2_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=2	
# 	${INI_SAG_R4_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=2
# 	${INI_SAG_R2_C3}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=3	
# 	${INI_SAG_R4_C3}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=3	
# 	${INI_SAG_R2_C4}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=4	
# 	${INI_SAG_R4_C4}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=4
# 
#     Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell1:${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}
#     Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell2:${PUSCH_CP_INI_64TBL_MCS_00_28_cell2}
#     Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell3:${PUSCH_CP_INI_64TBL_MCS_00_28_cell3}
#     Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell4:${PUSCH_CP_INI_64TBL_MCS_00_28_cell4}	
#     Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell1:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}
#     Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell2:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2}
#     Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell3:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell3}
#     Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell4:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell4}
#     Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell1:${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}
#     Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell2:${PUSCH_CP_INI_256TBL_MCS_00_27_cell2}
#     Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell3:${PUSCH_CP_INI_256TBL_MCS_00_27_cell3}
#     Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell4:${PUSCH_CP_INI_256TBL_MCS_00_27_cell4}		
#     Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell1:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}
#     Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell2:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2}
#     Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell3:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell3}
#     Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell4:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell4}
#     Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell1:${INI_SAG_R2_C1}
#     Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell2:${INI_SAG_R2_C2}
#     Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell3:${INI_SAG_R2_C3}
#     Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell4:${INI_SAG_R2_C4}
#     Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell1:${INI_SAG_R4_C1}
#     Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell2:${INI_SAG_R4_C2}
#     Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell3:${INI_SAG_R4_C3}
#     Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell4:${INI_SAG_R4_C4}
# 	${CP_INI_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell1})
# 	${CP_INI_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell2})
# 	${CP_INI_64TBL_Sum_cell3}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell3})
# 	${CP_INI_64TBL_Sum_cell4}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell4})
# 	${DFT_INI_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1})
# 	${DFT_INI_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2})
# 	${DFT_INI_64TBL_Sum_cell3}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell3})
# 	${DFT_INI_64TBL_Sum_cell4}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell4})	
# 	${CP_INI_256TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell1})
# 	${CP_INI_256TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell2})
# 	${CP_INI_256TBL_Sum_cell3}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell3})
# 	${CP_INI_256TBL_Sum_cell4}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell4})	
# 	${CP_INI_LOWSE_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1})
# 	${CP_INI_LOWSE_Sum_cell2}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2})
# 	${CP_INI_LOWSE_Sum_cell3}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell3})
# 	${CP_INI_LOWSE_Sum_cell4}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell4})
# 	
#     ${PUSCH_LG_INI_Sum_cell1_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell1}+${DFT_INI_64TBL_Sum_cell1}+${CP_INI_256TBL_Sum_cell1}
#     ${PUSCH_LG_INI_Sum_cell1}    Evaluate    ${PUSCH_LG_INI_Sum_cell1_tmp}+${CP_INI_LOWSE_Sum_cell1}+${INI_SAG_R2_C1}+${INI_SAG_R4_C1}
#     ${PUSCH_LG_INI_Sum_cell2_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell2}+${DFT_INI_64TBL_Sum_cell2}+${CP_INI_256TBL_Sum_cell2}
#     ${PUSCH_LG_INI_Sum_cell2}    Evaluate    ${PUSCH_LG_INI_Sum_cell2_tmp}+${CP_INI_LOWSE_Sum_cell2}+${INI_SAG_R2_C2}+${INI_SAG_R4_C2}	
#     ${PUSCH_LG_INI_Sum_cell3_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell3}+${DFT_INI_64TBL_Sum_cell3}+${CP_INI_256TBL_Sum_cell3}
#     ${PUSCH_LG_INI_Sum_cell3}    Evaluate    ${PUSCH_LG_INI_Sum_cell3_tmp}+${CP_INI_LOWSE_Sum_cell3}+${INI_SAG_R2_C3}+${INI_SAG_R4_C3}	
#     ${PUSCH_LG_INI_Sum_cell4_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell4}+${DFT_INI_64TBL_Sum_cell4}+${CP_INI_256TBL_Sum_cell4}
#     ${PUSCH_LG_INI_Sum_cell4}    Evaluate    ${PUSCH_LG_INI_Sum_cell4_tmp}+${CP_INI_LOWSE_Sum_cell4}+${INI_SAG_R2_C4}+${INI_SAG_R4_C4}
#     Log To Console    \n----------------------end-------------------------	
# 	
# 
# 	Log To Console    \n----Legacy_PUSCH_CP_SUCC_64TBL_MCS_00-28_and_PUSCH_DFT_SUCC_64TBL_MCS_00-27------
# 	Log To Console    \n----Legacy_PUSCH_CP_SUCC_256TBL_MCS_00-27_and_PUSCH_CP_SUCC_LOWSE_MCS_00-28------
# 	Log To Console    \n----Legacy_PUSCH_DFT_SUCC_64TBL_SAG_R2_and_PUSCH_DFT_SUCC_64TBL_SAG_R4------	
# 	Log To Console    PUSCH_CP_SUCC_64TBL_MCS_00-28:M55302C04000----M55302C04028
# 	Log To Console    PUSCH_DFT_SUCC_64TBL_MCS_00-27:M55302C08000----M55302C08027
# 	Log To Console    PUSCH_CP_SUCC_256TBL_MCS_00-27:M55302C13000---M55302C13027
# 	Log To Console    PUSCH_CP_SUCC_LOWSE_MCS_00-28:M55367C02000---M55367C02028
# 	Log To Console    PUSCH_DFT_SUCC_64TBL_SAG_R2:M55370C00009
# 	Log To Console    PUSCH_DFT_SUCC_64TBL_SAG_R4:M55370C00015
# 	
# 	
#     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}    	create list
#     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2}    	create list
#     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell3}    	create list
#     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell4}    	create list		
#     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}    	create list
#     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2}    	create list
#     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell3}    	create list
#     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell4}    	create list	
#     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}    	create list
#     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2}    	create list
#     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell3}    	create list
#     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell4}    	create list			
#     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}    	create list
#     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2}    	create list
#     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell3}    	create list
#     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell4}    	create list	
# 	
# 	FOR    ${i}    IN RANGE     0     29
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=1
# 	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}   ${CP_64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=1
# 	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}   ${LOW_value}
# 	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=2
# 	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2}   ${CP_64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=2
# 	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2}   ${LOW_value}	
# 	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=3
# 	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell3}   ${CP_64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=3
# 	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell3}   ${LOW_value}
# 	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=4
# 	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell4}   ${CP_64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=4
# 	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell4}   ${LOW_value}	
# 	END
# 
# 	FOR    ${i}    IN RANGE     0     28
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=1
# 	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}   ${DFT_64}	
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=1
# 	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}   ${256_value}
# 	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=2
# 	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2}   ${DFT_64}	
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=2
# 	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2}   ${256_value}
# 	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=3
# 	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell3}   ${DFT_64}		
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=3
# 	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell3}   ${256_value}	
# 	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=4
# 	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell4}   ${DFT_64}	
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=4
# 	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell4}   ${256_value}
# 	END	
# 	
# 	${SUC_SAG_R2_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=1	
# 	${SUC_SAG_R4_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=1
# 	${SUC_SAG_R2_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=2	
# 	${SUC_SAG_R4_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=2
# 	${SUC_SAG_R2_C3}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=3	
# 	${SUC_SAG_R4_C3}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=3	
# 	${SUC_SAG_R2_C4}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=4	
# 	${SUC_SAG_R4_C4}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=4
# 
# 
#     Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell1:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}
#     Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell2:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2}
#     Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell3:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell3}
#     Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell4:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell4}	
#     Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}
#     Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2}
#     Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell3:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell3}
#     Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell4:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell4}
#     Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell1:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}
#     Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell2:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2}
#     Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell3:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell3}
#     Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell4:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell4}		
#     Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}
#     Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2}
#     Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell3:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell3}
#     Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell4:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell4}
#     Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell1:${SUC_SAG_R2_C1}
#     Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell2:${SUC_SAG_R2_C2}
#     Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell3:${SUC_SAG_R2_C3}
#     Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell4:${SUC_SAG_R2_C4}
#     Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell1:${SUC_SAG_R4_C1}
#     Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell2:${SUC_SAG_R4_C2}
#     Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell3:${SUC_SAG_R4_C3}
#     Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell4:${SUC_SAG_R4_C4}
# 	${CP_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1})
# 	${CP_SUC_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2})
# 	${CP_SUC_64TBL_Sum_cell3}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell3})
# 	${CP_SUC_64TBL_Sum_cell4}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell4})
# 	${DFT_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1})
# 	${DFT_SUC_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2})
# 	${DFT_SUC_64TBL_Sum_cell3}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell3})
# 	${DFT_SUC_64TBL_Sum_cell4}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell4})	
# 	${CP_SUC_256TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1})
# 	${CP_SUC_256TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2})
# 	${CP_SUC_256TBL_Sum_cell3}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell3})
# 	${CP_SUC_256TBL_Sum_cell4}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell4})	
# 	${CP_SUC_LOWSE_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1})
# 	${CP_SUC_LOWSE_Sum_cell2}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2})
# 	${CP_SUC_LOWSE_Sum_cell3}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell3})
# 	${CP_SUC_LOWSE_Sum_cell4}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell4})
# 	
#     ${PUSCH_LG_SUC_Sum_cell1_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell1}+${DFT_SUC_64TBL_Sum_cell1}+${CP_SUC_256TBL_Sum_cell1}
#     ${PUSCH_LG_SUC_Sum_cell1}    Evaluate    ${PUSCH_LG_SUC_Sum_cell1_tmp}+${CP_SUC_LOWSE_Sum_cell1}+${SUC_SAG_R2_C1}+${SUC_SAG_R4_C1}
#     ${PUSCH_LG_SUC_Sum_cell2_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell2}+${DFT_SUC_64TBL_Sum_cell2}+${CP_SUC_256TBL_Sum_cell2}
#     ${PUSCH_LG_SUC_Sum_cell2}    Evaluate    ${PUSCH_LG_SUC_Sum_cell2_tmp}+${CP_SUC_LOWSE_Sum_cell2}+${SUC_SAG_R2_C2}+${SUC_SAG_R4_C2}	
#     ${PUSCH_LG_SUC_Sum_cell3_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell3}+${DFT_SUC_64TBL_Sum_cell3}+${CP_SUC_256TBL_Sum_cell3}
#     ${PUSCH_LG_SUC_Sum_cell3}    Evaluate    ${PUSCH_LG_SUC_Sum_cell3_tmp}+${CP_SUC_LOWSE_Sum_cell3}+${SUC_SAG_R2_C3}+${SUC_SAG_R4_C3}	
#     ${PUSCH_LG_SUC_Sum_cell4_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell4}+${DFT_SUC_64TBL_Sum_cell4}+${CP_SUC_256TBL_Sum_cell4}
#     ${PUSCH_LG_SUC_Sum_cell4}    Evaluate    ${PUSCH_LG_SUC_Sum_cell4_tmp}+${CP_SUC_LOWSE_Sum_cell4}+${SUC_SAG_R2_C4}+${SUC_SAG_R4_C4}
#     Log To Console    \n----------------------end-------------------------	
# 	
#     Log To Console    \n----------------------All Counter Summary-------------------------
# 	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell1--------
# 	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell1:${PDSCH_INI_counter_Sum_cell1}
# 	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell1:${PDSCH_SUC_counter_Sum_cell1}
#     Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell1:${PDSCH_LG_INITX_Sum_cell1}
#     Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell1:${PDSCH_LG_SUC_Sum_cell1}
#     run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell1}==${PDSCH_LG_INITX_Sum_cell1}   
#     run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell1}==${PDSCH_LG_SUC_Sum_cell1}   
# 
# 
# 
# 	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell2--------
# 	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell2:${PDSCH_INI_counter_Sum_cell2}
# 	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell2:${PDSCH_SUC_counter_Sum_cell2}
#     Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell2:${PDSCH_LG_INITX_Sum_cell2}
#     Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell2:${PDSCH_LG_SUC_Sum_cell2}
#     run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell2}==${PDSCH_LG_INITX_Sum_cell2}   
#     run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell2}==${PDSCH_LG_SUC_Sum_cell2} 
# 
# 
# 	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell3--------
# 	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell3:${PDSCH_INI_counter_Sum_cell3}
# 	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell3:${PDSCH_SUC_counter_Sum_cell3}
#     Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell3:${PDSCH_LG_INITX_Sum_cell3}
#     Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell3:${PDSCH_LG_SUC_Sum_cell3}
#     run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell3}==${PDSCH_LG_INITX_Sum_cell3}   
#     run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell3}==${PDSCH_LG_SUC_Sum_cell3} 
# 
# 
# 	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell4--------
# 	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell4:${PDSCH_INI_counter_Sum_cell4}
# 	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell4:${PDSCH_SUC_counter_Sum_cell4}
#     Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell4:${PDSCH_LG_INITX_Sum_cell4}
#     Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell4:${PDSCH_LG_SUC_Sum_cell4}	
#     run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell4}==${PDSCH_LG_INITX_Sum_cell4}   
#     run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell4}==${PDSCH_LG_SUC_Sum_cell4} 
# 	
# 	
# 	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell1--------	
#     Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell1:${PUSCH_INI_counter_Sum_cell1}
#     Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell1:${PUSCH_SUC_counter_Sum_cell1}		
#     Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell1:${PUSCH_LG_INI_Sum_cell1}	
#     Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell1:${PUSCH_LG_SUC_Sum_cell1}
#     run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell1}==${PUSCH_LG_INI_Sum_cell1}   
#     run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell1}==${PUSCH_LG_SUC_Sum_cell1} 	
# 	
# 	
# 	
# 	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell2--------		
#     Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell2:${PUSCH_INI_counter_Sum_cell2}
#     Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell2:${PUSCH_SUC_counter_Sum_cell2}		
#     Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell2:${PUSCH_LG_INI_Sum_cell2}	
#     Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell2:${PUSCH_LG_SUC_Sum_cell2}
#     run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell2}==${PUSCH_LG_INI_Sum_cell2}   
#     run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell2}==${PUSCH_LG_SUC_Sum_cell2} 
# 
# 	
# 	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell3--------		
#     Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell3:${PUSCH_INI_counter_Sum_cell3} 
#     Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell3:${PUSCH_SUC_counter_Sum_cell3}	
#     Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell3:${PUSCH_LG_INI_Sum_cell3}	
#     Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell3:${PUSCH_LG_SUC_Sum_cell3}
#     run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell3}==${PUSCH_LG_INI_Sum_cell3}   
#     run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell3}==${PUSCH_LG_SUC_Sum_cell3} 
# 	
# 	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell4--------		
#     Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell4:${PUSCH_INI_counter_Sum_cell4}
#     Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell4:${PUSCH_SUC_counter_Sum_cell4}	
#     Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell4:${PUSCH_LG_INI_Sum_cell4}
#     Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell4:${PUSCH_LG_SUC_Sum_cell4}	    
# 	run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell4}==${PUSCH_LG_INI_Sum_cell4}   
#     run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell4}==${PUSCH_LG_SUC_Sum_cell4}