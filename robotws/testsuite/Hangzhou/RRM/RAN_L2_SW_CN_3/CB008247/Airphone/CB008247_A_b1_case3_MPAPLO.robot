# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_zhang    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G   SBTS23R1
# ...   CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}     SCFC_8247_case3_MPAPLO.xml
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
# CB008247_A_b1_case3_CL_4x4_8DL4UL_100M_Single_UE_with_different_TAS_and_not_reuse_codebook_SA  
# 	add_RD
# 	Prepare gnb onair
# 	Start capture gnb and ap syslog in 'after_onair' file
# 	Multi UE SA Register and check
# 	Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# add_RD
# #pdcch use best beam
# 	Add GNB swconfig    0x580434:0
# #beam select:	enum;2; 0 - sequential searching method, 1 - Joint searching method 1, 2 - Joint searching method 2
# 	#Add GNB swconfig    0x580267:2
# #The DL CoMa log enabling flag(rdDlSrsLogControl, bit0)
# 	#Add GNB swconfig    0x580264:7
# 
# set_sinr
# 	#increase SRS power to make 1st and 2nd beam stable
# 	airphone_execute_egate_command	ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=50
# 	airphone_execute_egate_command	ul_sinr_testmode_nr profile_id\=6 sinr_target_srs\=80
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=5 testmode\=ul_sinr action\=activate profile_id\=5
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1-4 testmode\=ul_sinr action\=activate profile_id\=6
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=6-7 testmode\=ul_sinr action\=activate profile_id\=6
# 
# Multi UE SA Register and check
# 	#positionH:azimuth=0,15,30,50
# 	airphone_execute_egate_command	ue_srs_beam_pos_nr profile_id\=3 init_pos\=2 srsMode\=fixed
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1-7 testmode\=ue_srs_beam_pos action\=activate profile_id\=3
# 
#     : FOR    ${num}    IN RANGE    1    8
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${num} ------ 
#     #tcpdump for f1ap:TxSwitch
#     \   Start collect UE'${num}' tcpdump
# 
#     \   Airphone SA Attach    ue_id=${num}
#        #set_pdu_param ue=1 pdu=1 trf_type=internal
#        #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     \   Airphone Set Traffic Type    ${num}    ${num}    internal
#     \   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
#     \   Wait '2s' for stabible
#     \   Stop collect UE'${num}' tcpdump    
#     \   Check UE'${num}' TxSwitch in attach_tcpdump
#     
#     \   DL and UL data to '${num}'
#     \   run keyword and continue on failure 	Wait Until Keyword Succeeds    60s    2s     check '${num}' throughput
#   
#     \   Check '${num}' PatternId and Bler in ttiTrace
#     #\   collect and check '${num}' BIP
#     
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
# 
#     \   check UE '${num}' SRS in RRC log
# 
# start collect UE'${ue_id}' attach tcpdump
#     Log To Console   start collect UE'${ue_id}' attach tcpdump
#     ${executor_oam_vm}    Create Dictionary   host=192.168.255.1   user=toor4nsn   password=oZPS0POrRieRtu
#     Start Tcpdump    name=tcpdump_UE    options=-i any -c 10000    remote_info=${executor_oam_vm}
# 
# DL and UL data to '${UE_ID}'
#     Log To Console    DL*4 and UL*3 data  to UE ${UE_ID}
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
#     Set test Variable  ${1st_patternId}	1043
#     Set test Variable  ${2nd_patternId}	1049
#     
#     Log To Console    Check ttitrace DL
#     Set test Variable    ${tti_title_tag}		tti_UE_${UE_ID}_dl.csv
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_dl_case3_H30_MOAPLO.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
#     Log To Console    Check ttitrace UL
#     Set test Variable    ${tti_title_tag}		tti_UE_${UE_ID}_ul.csv
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_ul_case3_H30_MOAPLO.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# #check RRC
# check UE '${ue_id}' SRS in RRC log
#     Log To Console   check UE ${ue_id} SRS in RRC log
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_ue${ue_id}_case3.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
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
#      Run Keyword If   '${UE_ID}'=='1' or '${UE_ID}'=='5' or '${UE_ID}'=='6'		should be true    ${dl_tput_Mb}>600
#      Run Keyword If   '${UE_ID}'!='1' and '${UE_ID}'!='5' and '${UE_ID}'!='6'	should be true    ${dl_tput_Mb}>1200
#      should be true    ${ul_tput_Mb}>50
# 
# collect and check '${ue_id}' BIP
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'BIP_ue_${ue_id}'
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
# 	Set test Variable    ${pdcch_patternId}    1313
# 	#rank 3/4 UE
# 	Set test Variable   ${csi_patternid}   1043,1043,1049,1049
# 	Set test Variable   ${csi_patternid}   1043,1043,1049,1049   
# 	Set test Variable   ${pdsch_patternid}   1043,1049
# 	#rank 1/2 UE
# 	Run Keyword If    '${ue_id}'=='1' or '${ue_id}'=='5' or '${ue_id}'=='6'    Set test Variable    ${pdsch_patternid}   1043
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pdcch_patternId_1024_case3.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}
# 
#     #run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pdsch_patternId_1024_case3.ini     i
#     #...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}
# 
#     #run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_csi_patternId_1024_case3.ini     i
#     #...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}
# 
#     Log To Console   Check PatternId in bip finisged
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
# 
# Check UE'${ue_id}' TxSwitch in attach_tcpdump
#     Log To Console   Check UE'${ue_id}' TxSwitch
#     Run Keyword And ignore error    Convert BIP To CSV
#     ...    ${TEST_LOG_DIRECTORY()}/All/tcpdump/tcp_attach_ue${ue_id}.pcap
#     ...    ${TEST_LOG_DIRECTORY()}/All/tcpdump/f1ap.csv    ${FILTER_f1ap}    ${titles_f1ap}
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tcpdump_attach_ue${ue_id}_case3.ini    i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/tcpdump
# 
# # issue test below
# UE3_attach
# 	Airphone SA Attach    ue_id=3
# 	Airphone Set Traffic Type    3    3    internal
#      Airphone Pdu Session Setup    3    3    1    3
#      DL and UL data to '3'
#      
# LO_test_sinr_srs	
# 	airphone_execute_egate_command	ue_srs_beam_pos_nr profile_id\=1 init_pos\=0 srsMode\=fixed
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1-7 testmode\=ue_srs_beam_pos action\=activate profile_id\=1
# 	
# 	airphone_execute_egate_command	ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=0 noise_srs\=-1053
# 	airphone_execute_egate_command	ul_sinr_testmode_nr profile_id\=6 sinr_target_srs\=25 noise_srs\=-1053
# 	airphone_execute_egate_command	ul_sinr_testmode_nr profile_id\=7 sinr_target_srs\=50 noise_srs\=-1053
# 	airphone_execute_egate_command	ul_sinr_testmode_nr profile_id\=8 sinr_target_srs\=75 noise_srs\=-1053
# 	airphone_execute_egate_command	ul_sinr_testmode_nr profile_id\=9 sinr_target_srs\=100 noise_srs\=-1053
# 	airphone_execute_egate_command	ul_sinr_testmode_nr profile_id\=10 sinr_target_srs\=125 noise_srs\=-1053
# 
# 	Start capture gnb and ap syslog in 'syslog_SRS_0' file
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=3 testmode\=ul_sinr action\=activate profile_id\=5
# 	UE3_attach
#      Start collect bip log
#     Wait for '2s' to stop bip log with name'BIP_SRS_0'
#     airphone_execute_egate_command	ue_testmode_set_nr id\=3 testmode\=ul_sinr action\=deactivate profile_id\=5
#     airphone_sa_detach    ue_id=3    timeout=5
#     Stop capture gnb and ap syslog in 'syslog_SRS_0' file
#     #Wait '2s' for stabible
# 
# 	Start capture gnb and ap syslog in 'syslog_SRS_25' file
#     airphone_execute_egate_command	ue_testmode_set_nr id\=3 testmode\=ul_sinr action\=activate profile_id\=6
#     UE3_attach
#     Start collect bip log
#     Wait for '2s' to stop bip log with name'BIP_SRS_25'
#     airphone_execute_egate_command	ue_testmode_set_nr id\=3 testmode\=ul_sinr action\=deactivate profile_id\=6
# 	airphone_sa_detach    ue_id=3    timeout=5
#     Wait '2s' for stabible
# 	Stop capture gnb and ap syslog in 'syslog_SRS_25' file
# 	
#     Start capture gnb and ap syslog in 'syslog_SRS_50' file
#     airphone_execute_egate_command	ue_testmode_set_nr id\=3 testmode\=ul_sinr action\=activate profile_id\=7
#     UE3_attach
#     Start collect bip log
#     Wait for '2s' to stop bip log with name'BIP_SRS_50'
#     airphone_execute_egate_command	ue_testmode_set_nr id\=3 testmode\=ul_sinr action\=deactivate profile_id\=7
#     airphone_sa_detach    ue_id=3    timeout=5
# 	Stop capture gnb and ap syslog in 'syslog_SRS_50' file
# 	
#     Start capture gnb and ap syslog in 'syslog_SRS_75' file
#     airphone_execute_egate_command	ue_testmode_set_nr id\=3 testmode\=ul_sinr action\=activate profile_id\=8
#     UE3_attach
#     Start collect bip log
#     Wait for '2s' to stop bip log with name'BIP_SRS_75'
#     airphone_execute_egate_command	ue_testmode_set_nr id\=3 testmode\=ul_sinr action\=deactivate profile_id\=8
#     airphone_sa_detach    ue_id=3    timeout=5
#     Stop capture gnb and ap syslog in 'syslog_SRS_75' file
# 
#     Start capture gnb and ap syslog in 'syslog_SRS_100' file
#     airphone_execute_egate_command	ue_testmode_set_nr id\=3 testmode\=ul_sinr action\=activate profile_id\=9
#     UE3_attach
#     Start collect bip log
#     Wait for '2s' to stop bip log with name'BIP_SRS_100'
#     airphone_execute_egate_command	ue_testmode_set_nr id\=3 testmode\=ul_sinr action\=deactivate profile_id\=9
#     airphone_sa_detach    ue_id=3    timeout=5
#     Stop capture gnb and ap syslog in 'syslog_SRS_100' file
# 
#     Start capture gnb and ap syslog in 'syslog_SRS_125' file
#     airphone_execute_egate_command	ue_testmode_set_nr id\=3 testmode\=ul_sinr action\=activate profile_id\=10
#     UE3_attach
#     Start collect bip log
#     Wait for '2s' to stop bip log with name'BIP_SRS_125'
#     airphone_execute_egate_command	ue_testmode_set_nr id\=3 testmode\=ul_sinr action\=deactivate profile_id\=10
#     airphone_sa_detach    ue_id=3    timeout=5
#     Stop capture gnb and ap syslog in 'syslog_SRS_125' file
# 
# test_L1_knife_H0	
# 	Start capture gnb and ap syslog in 'sys' file
# 	#azimuth=46,52,42,0
# 	airphone_execute_egate_command	ue_srs_beam_pos_nr profile_id\=1 init_pos\=0 srsMode\=fixed	
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1-7 testmode\=ue_srs_beam_pos action\=activate profile_id\=1
# 
# 	airphone_execute_egate_command	ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=200 noise_srs\=-1053
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=3 testmode\=ul_sinr action\=activate profile_id\=5
# 	   
# 	Airphone SA Attach    ue_id=3
# 	Airphone Set Traffic Type    3    3    internal
#      Airphone Pdu Session Setup    3    3    1    3
#      DL and UL data to '3'
#     
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti_H0_8360_LO_L1_knife'
#     Start collect bip log
#     Wait for '2s' to stop bip log with name'BIP_H0_8360'
#     
#     airphone_sa_detach    ue_id=3    timeout=5
#     Stop capture gnb and ap syslog in 'sys' file
#     
# LO_test_pos
# 	Start capture gnb and ap syslog in 'sys_sinr_200_H46' file
# 	#azimuth=46,52,42,37
# 	airphone_execute_egate_command	ue_srs_beam_pos_nr profile_id\=1 init_pos\=0 srsMode\=fixed
# 	airphone_execute_egate_command	ue_srs_beam_pos_nr profile_id\=2 init_pos\=1 srsMode\=fixed
# 	airphone_execute_egate_command	ue_srs_beam_pos_nr profile_id\=3 init_pos\=2 srsMode\=fixed
# 	airphone_execute_egate_command	ue_srs_beam_pos_nr profile_id\=4 init_pos\=3 srsMode\=fixed		
# 	Log To Console   ${\n}-----pos_0------
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1-7 testmode\=ue_srs_beam_pos action\=activate profile_id\=1
# 	
# 	airphone_execute_egate_command	ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=200 noise_srs\=-1053
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=3 testmode\=ul_sinr action\=activate profile_id\=5
# 	
# 	Airphone SA Attach    ue_id=3
# 	Airphone Set Traffic Type    3    3    internal
#      Airphone Pdu Session Setup    3    3    1    3
#      DL and UL data to '3'
#     
#     #Start collect ttitrace
#     #Wait for '2s' to stop ttitrace with name'tti_H0'
#     Start collect bip log
#     Wait for '2s' to stop bip log with name'BIP_H46'
#     Stop capture gnb and ap syslog in 'sys_sinr_200_H46' file
# 
# 
#     Start capture gnb and ap syslog in 'sys_sinr_200_H52' file
#     Log To Console   ${\n}-----pos_1------
#     airphone_execute_egate_command	ue_testmode_set_nr id\=1-7 testmode\=ue_srs_beam_pos action\=activate profile_id\=2
#     #Start collect ttitrace
#     #Wait for '2s' to stop ttitrace with name'tti_H30' 
#     Start collect bip log
#     Wait for '2s' to stop bip log with name'BIP_H52'
# 	 Stop capture gnb and ap syslog in 'sys_sinr_200_H52' file
# 
# 
# 	 Start capture gnb and ap syslog in 'sys_sinr_200_H42' file
#     Log To Console   ${\n}-----pos_2------
#     airphone_execute_egate_command	ue_testmode_set_nr id\=1-7 testmode\=ue_srs_beam_pos action\=activate profile_id\=3
#     #Start collect ttitrace
#     #Wait for '2s' to stop ttitrace with name'tti_H45'
#     Start collect bip log
#     Wait for '2s' to stop bip log with name'BIP_H42'
# 	Stop capture gnb and ap syslog in 'sys_sinr_200_H42' file
# 
# 	
# 	Start capture gnb and ap syslog in 'sys_sinr_200_H37' file
#     Log To Console   ${\n}-----pos_3------
#     airphone_execute_egate_command	ue_testmode_set_nr id\=1-7 testmode\=ue_srs_beam_pos action\=activate profile_id\=4
#     #Start collect ttitrace
#     #Wait for '2s' to stop ttitrace with name'tti_H50'
#     Start collect bip log
#     Wait for '2s' to stop bip log with name'BIP_H37'
#     Stop capture gnb and ap syslog in 'sys_sinr_200_H37' file
#     airphone_sa_detach    ue_id=3    timeout=5
