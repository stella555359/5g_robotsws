# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_sasun    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD
# ...   CLOUD_5G_I_MP_AP_LO
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# Resource    ${CURDIR}/Check_CNI113494_iBler.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}     SCFC_8247_case12_MPAPLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_case3_LO.xml
# ${WTS_NAME}    wts_1086_7_TAS_LO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# 
# ${FILTER_f1ap}    (f1ap) && (nr-rrc.supportedSRS_TxPortSwitch)
# @{titles_f1ap}    nr-rrc.supportedSRS_TxPortSwitch
# ${FILTER_1}    (dldata_pdcchsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_2}    (dldata_pdschsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# @{titles_1}    DlData_DciInfo.patternId_item
# @{titles_2}    DlData_PdschGrant.patternId_item
# @{titles_3}    DlData_CsiRsResource_t.patternId_item
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# ...    NUMBER_OF_FILES=30
# *** Test Cases ***
# CNI_113494_Case4_PDSCH_iBLER_counters_for_Non-tapered_2D-DFT_beams  
#     add_RD
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Multi UE SA Register and check
#     Stop capture gnb and ap syslog in 'after_onair' file
#   
# *** Keywords ***
# add_RD
# #beam select:	enum;2; 0 - sequential searching method, 1 - Joint searching method 1, 2 - Joint searching method 2
# 	Add GNB swconfig    0x9D0000:3        #as PM counter period update to 15/15=1min
# #The DL CoMa log enabling flag(rdDlSrsLogControl, bit0)
# 	#Add GNB swconfig    0x580264:7
# #pdcch use best beam
# 	Add GNB swconfig    0x580434:0
# 
# Multi UE SA Register and check
# 	#positionH:azimuth=0,15,30,50
# 	#airphone_execute_egate_command	ue_srs_beam_pos_nr profile_id\=1 init_pos\=0 srsMode\=fixed
# 	#airphone_execute_egate_command	ue_srs_beam_pos_nr profile_id\=2 init_pos\=1 srsMode\=fixed
# 	airphone_execute_egate_command	ue_srs_beam_pos_nr profile_id\=3 init_pos\=2 srsMode\=fixed
# 	#airphone_execute_egate_command	ue_srs_beam_pos_nr profile_id\=4 init_pos\=3 srsMode\=fixed
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=3
# 
# 	#increase SRS power to make 1st and 2nd beam stable
# 	airphone_execute_egate_command	ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=50 noise_srs\=-1053
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=5
# 	
#     : FOR    ${num}    IN RANGE    1    2
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${num} ------ 
#     #tcpdump for f1ap:TxSwitch
#     \   Start collect UE'${num}' tcpdump
# 
#     \   Airphone SA Attach    ue_id=${num}
#     \   Airphone Set Traffic Type    ${num}    ${num}    internal
#     \   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
#     \   Wait '2s' for stabible
#     \   Stop collect UE'${num}' tcpdump    
#     
#     \   DL and UL data to '${num}'
#     \   run keyword and continue on failure 	Wait Until Keyword Succeeds    60s    2s     check '${num}' throughput
#     
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}PM_check2
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${save_log}${/}
# 	Check_CNI113494_iBler_match_Legacy_counters_1cell    ${PM_counter_file}
# start collect UE'${ue_id}' attach tcpdump
#     Log To Console   start collect UE'${ue_id}' attach tcpdump
#     ${executor_oam_vm}    Create Dictionary   host=192.168.255.1   user=toor4nsn   password=oZPS0POrRieRtu
#     Start Tcpdump    name=tcpdump_UE    options=-i any -c 10000    remote_info=${executor_oam_vm}
# 
# DL and UL data to '${UE_ID}'
#     Log To Console    DL*5 and UL*3 data  to UE ${UE_ID}
#     : FOR    ${num}    IN RANGE    1    10
#     \	Airphone SA Start Data Traffic    ${UE_ID}   DL   165M   pdu_id=${UE_ID}   duration=3600   trf_id=${num}
#     Airphone SA Start Data Traffic    ${UE_ID}   UL   50M    pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Wait '3s' for stabible
# 
# #check tti
# Check '${UE_ID}' PatternId and Bler in ttiTrace
#     Log To Console    Check PatternId and Bler in ttiTrace: UE ${UE_ID}
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti_UE_${UE_ID}'
# 
#     Set test Variable  ${best_patternId}	1313
#     
#     Log To Console    Check ttitrace DL
#     Set test Variable    ${tti_title_tag}		tti_UE_${UE_ID}_dl.csv
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_dl_case12_H30_MOAPLO.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
#     Log To Console    Check ttitrace UL
#     Set test Variable    ${tti_title_tag}		tti_UE_${UE_ID}_ul.csv
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_ul_case12_H30_MOAPLO.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# #check throughput
# check '${UE_ID}' throughput
#      Log To Console    Check throughput UE${UE_ID}
#      #${pcell_tp}=    airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pdsch    tput_type=ave
#      #should be true    ${pcell_tp}>300
#      ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pusch    tput_type=ave
#      ${dl_tput_kb}=    airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pdsch    tput_type=ave
#      ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
#      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#      Log To Console		dl ${dl_tput_Mb}
#      Log To Console		ul ${ul_tput_Mb}
#      Run Keyword If   '${UE_ID}'=='1' or '${UE_ID}'=='5' or '${UE_ID}'=='6'		should be true    ${dl_tput_Mb}>300
#      Run Keyword If   '${UE_ID}'!='1' and '${UE_ID}'!='5' and '${UE_ID}'!='6'		should be true    ${dl_tput_Mb}>600
#      should be true    ${ul_tput_Mb}>40
# 
# collect and check '${ue_id}' BIP
#     Start collect bip log
#     Wait for '2s' to stop bip log with name'BIP_ue_${ue_id}'
# 
#     #   Check PatternId in bip
#     Log To Console   Check PatternId in bip
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/tcpdump_L2L1_bip_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/bip_pdcch.csv    ${FILTER_1}    ${titles_1}
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/tcpdump_L2L1_bip_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/bip_pdsch.csv    ${FILTER_2}    ${titles_2}
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/tcpdump_L2L1_bip_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/bip_csi.csv    ${FILTER_3}    ${titles_3}
#     
#     Set test Variable    ${pdcch_patternId}    1313
#     #rank 3/4 UE
#     Set test Variable    ${csi_patternid}     1313,1312,1314,1310
#     #2022_7_22_patternid_changed to 1051,1401
#     Run Keyword If   '${SW_BRANCH}'!='SBTS22R3'   Set test Variable   ${csi_patternid}   1043,1043,1049,1049   
#     Set test Variable    ${pdsch_patternid}    1043,1049
#     Run Keyword If   '${SW_BRANCH}'!='SBTS22R3'   Set test Variable   ${pdsch_patternid}   1313,1049
#     #rank 1/2 UE
#     Run Keyword If    '${ue_id}'=='1' or '${ue_id}'=='5' or '${ue_id}'=='6'    Set test Variable    ${pdsch_patternid}   1313
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pdcch_patternId_1024_case3.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pdsch_patternId_1024_case3.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_csi_patternId_1024_case3.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}
# 
#     Log To Console   Check PatternId in bip finished
# 
# #tcpdump
# Start collect UE'${ue_id}' tcpdump
#     Log To Console    Start collect UE'${ue_id}' tcpdump
#     ${executor_oam_vm}    Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
#     Start Tcpdump    name=tcp_attach_ue${ue_id}    options= -i any -C 100   remote_info=${executor_oam_vm}
# 
# Stop collect UE'${ue_id}' tcpdump
#     Log To Console    Stop collect UE'${ue_id}' tcpdump
#     Stop Tcpdump    tcp_attach_ue${ue_id}    ${TEST_LOG_DIRECTORY()}/All/tcpdump
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}PM_check
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${save_log}${/}
# 	Check_CNI113494_iBler_match_Legacy_counters_1cell    ${PM_counter_file}
# 	
# 
# Check UE'${ue_id}' TxSwitch in attach_tcpdump
#     Log To Console   Check UE'${ue_id}' TxSwitch
#     Run Keyword And ignore error    Convert BIP To CSV
#     ...    ${TEST_LOG_DIRECTORY()}/All/tcpdump/tcp_attach_ue${ue_id}.pcap
#     ...    ${TEST_LOG_DIRECTORY()}/All/tcpdump/f1ap.csv    ${FILTER_f1ap}    ${titles_f1ap}
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tcpdump_attach_ue${ue_id}_case3.ini    i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/tcpdump
