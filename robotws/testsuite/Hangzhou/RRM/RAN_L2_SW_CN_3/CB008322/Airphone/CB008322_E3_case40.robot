# *** Settings ***
# Test Timeout    600 minutes
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_menzheng    AP    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_MP_AP_LOOO    CRT
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8322_E3_case40_ABIP.xml
# ${AIRPHONE_NAME}    IPHY_4T.xml
# ${WTS_NAME}    WTS_8322_E3_case40_NSA.cfg
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
# ${UE_ID}      11
# ${BIP_TAG}    8322_bip
# ${BIP_TAG_1}    8322_bip_1
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
# ...    NUMBER_OF_FILES=30
# ${PROFILE1}    ue_measurement_send_nr id\=1 meas_id\=6 event\=A6 srsrp_nr\=11 srsrq_nr\=11 scell\=1 scell_rsrp\=20 scell_rsrq\=20 phycell_id\=52 
# ...    nrsrp_nr\=63 nrsrq_nr\=20
# ${PROFILE2}    ue_measurement_send_nr id\=1 meas_id\=9 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=53 nrsrp_nr\=80 nrsrq_nr\=80
# 
# 
# *** Test Cases ***
# CB008322_E3_case40_subbandBeam_interwork_TDD_TDD_DL_3CC_NSA_scell_swap_TAS_SRS
#     set sctp rto time
#     #Add RD
#     rdEnableNidd For 8322
#     #Add RD for CB009496
#     #Active GNB L2 feature debug traces
#     Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'SA_ue' file
#     Attach LTE UE
#     UE from '1' to '2' SA Register
#     DL and UL data to '1' for dl_trf '4'
#     DL and UL data to '2' for dl_trf '4'
#     scell A1 addition
#     run keyword and continue on failure     Verify throughput
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti'
#     split_8322_tti        ${TEST_LOG_DIRECTORY()}/All/tti_dl.csv
#     Check pcell beamtype for wideband and fake drx
#     UE1 TDD scell swap
#     UE2 UE11 scell release
#     #Start collect bip log for LOOO
#     #Wait for '1s' to stop bip log with name'bip'
#     UE1 send bad CQI
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
# scell A1 addition
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=1-2 meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=3 event\=A1 srsrp_nr\=120
#     Wait '3s' for stabible
#     airphone_execute_egate_command    ue_measurement_send_nr id\=2 meas_id\=3 event\=A1 srsrp_nr\=120
#     Wait '20s' for stabible
# 	
# UE1 TDD scell swap
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
#     airphone_execute_egate_command    ${PROFILE1}
#     Wait '3s' for stabible	
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti1'
#     split_8322_tti        ${TEST_LOG_DIRECTORY()}/All/tti1_dl.csv
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_scell_swap   unzip=TRUE
#     Check TDD scell swap
#     Check pcell beamtype for wideband 1st
# 	
# UE2 UE11 scell release
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=2 meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement_send_nr id\=2 meas_id\=4 event\=A2 rs_type\=ssb srsrp_nr\=100 scell\=1
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=11 meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=3 event\=A2 rs_type\=ssb srsrp_nr\=100 scell\=9
#     Wait '10s' for stabible
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti2'
#     split_8322_tti        ${TEST_LOG_DIRECTORY()}/All/tti2_dl.csv
#     Check pcell beamtype for wideband 2nd
# 	
# UE1 send bad CQI
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=3 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2 scell\=0-2
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=csi_override action\=activate profile_id\=2 scell\=8-9
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=1 cqi_mode\=fixed ri\=3 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=3 scell\=0-2
#     Wait '10s' for stabible
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti3'
#     split_8322_tti        ${TEST_LOG_DIRECTORY()}/All/tti3_dl.csv
#     Check pcell beamtype for subband and normal drx
# 	
# UE7 DeRegister and Register
#     DeRegister UE from '7' to '7'
#     UE from '7' to '7' SA Register
#     DL and UL data to '7' for dl_trf '1'
# 
# #==========NSA=======================
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Attach LTE UE
#     Execute AP Command before attach
#     Airphone Nsa Attach    ${UE_ID}    profile_id=None
#     NSA send ue '${UE_ID}' mutiple trf '4' for each '175M' DL data
#     Wait '3s' for stabible
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=2 event\=A1 srsrp_nr\=120
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_data_UE_${UE_ID}   unzip=TRUE		
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
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_1/egate_console.log.001   crnti: (\\d+)
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
# 	
# Check pcell beamtype for wideband and fake drx
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/8322_E3_case40.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#      run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/fakedrx_on_case40.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_data_UE_1
#      run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/fakedrx_on_case40.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_data_UE_2
#      run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/fakedrx_on_case40_NSA.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_data_UE_11
# 
# Check pcell beamtype for subband and normal drx
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_1_badCQI   unzip=TRUE
#     ${ue1_rnti}    Get SA '1' crnti in RRC log
#     set suite variable     ${ue1_rnti}
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/8322_E3_case40_3.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/fakedrx_off_case40.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_1_badCQI
# 
# Check TDD scell swap
#      run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/swap_case40.ini    log_need_to_check=u
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_scell_swap
# 	
# Check pcell beamtype for wideband 1st	
# 	    run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/8322_E3_case40_1.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# Check pcell beamtype for wideband 2nd	
# 	    run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/8322_E3_case40_2.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Verify throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     ${ue1_tp_pcell}    airphone_get_throughput_on_specific_scell    1    0    type=pdsch    tput_type=ave
#     ${ue1_tp_scell1}    airphone_get_throughput_on_specific_scell    1    1    type=pdsch    tput_type=ave
#     ${ue1_tp_scell2}    airphone_get_throughput_on_specific_scell    1    2    type=pdsch    tput_type=ave
#     ${ue2_tp_pcell}    airphone_get_throughput_on_specific_scell    2    0    type=pdsch    tput_type=ave
#     ${ue2_tp_scell1}    airphone_get_throughput_on_specific_scell    2    1    type=pdsch    tput_type=ave
#     ${ue2_tp_scell2}    airphone_get_throughput_on_specific_scell    2    2    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>150000
#     should_be_true    ${dl_throughput_scell1}>150000
#     should be true    ${ue1_tp_pcell}>100000
#     should be true    ${ue1_tp_scell1}>100000
#     should be true    ${ue1_tp_scell2}>120000
#     should be true    ${ue2_tp_pcell}>100000
#     should be true    ${ue2_tp_scell1}>100000
#     should be true    ${ue2_tp_scell2}>120000
# 
