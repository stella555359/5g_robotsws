# *** Settings ***
# Test Timeout    120 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    AP    SBTS00    RAN_5G_TDD    RAN_5G    owner_changyli    
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_CB008322_8D4U_1070_80M_SBsize128_case19.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO.xml
# ${WTS_NAME}    wts_SA_NSA_case19.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog    
# 
# ${FILTER_f1ap}    (f1ap) && (nr-rrc.supportedSRS_TxPortSwitch)
# @{titles_f1ap}    nr-rrc.supportedSRS_TxPortSwitch
# ${FILTER_1}    (dldata_pdcchsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_2}    (dldata_pdschsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# @{titles_1}    DlData_DciInfo.patternId_item
# @{titles_2}    DlData_PdschGrant.patternId_item
# @{titles_3}    DlData_CsiRsResource_t.patternId_item
# 
# ${filter_csv}   uldata_srsreceivereq || uldata_srsreceiverespbwvps || dldata_pdschsendreq || dldata_csirssendreq
# 
# @{tiltle_srsreceivereq}	3gpp.sfn   3gpp.slot   3gpp.rnti   UlData_srsReceiveReqSubcell_t.srsBwvEnable
# ...   UlData_srsReceiveReqSubcell_t.srsBmEnable    UlData_srsBwvReportRequest_t.bwvReportId
# ...   UlData_srsBwvReportRequest_t.numBwvPerSubband   UlData_srsBwvReportRequest_t.symbolPosition   UlData_srsBwvReportRequest_t.operation
# ...   UlData_srsBwvReportRequest_t.sinr   UlData_srsBwvReportRequest_t.rho   UlData_srsBwvReportRequest_t.numSrsPorts
# ...   UlData_srsBwvReportRequest_t.bfSubbandId_item
# ...   UlData_srsBwvReportRequest_t.srsResourceIdentity   UlData_srsBwvReportRequest_t.startPatternId   
# ...   UlData_srsCyclicShifts_t.transmissionCombId    UlData_srsCyclicShifts_t.cyclicShift   UlData_srsCyclicShifts_t.portIndex
# 
# ${UE_NUM_SA}         1
# ${UE_NUM_NSA}        2
# ${TTI_TAG}           tti
# ${UE_SA_ID}         1
# ${UE_NSA_ID}        11
# ${BIP_TAG1}          bip
# ${BIP_TAG}          bip
# ${EGATE_TAG}       egate
# ${UE1_NSA_ID}        11
# ${UE2_NSA_ID}        12
# ${UE3_NSA_ID}        13
# ${UE4_NSA_ID}        14
# ${chbw_prb}          217
# ${subband_size}      128
# ${start_pattern_id}    2100
# ${rank}     2
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250
# 
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250
# 
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=10 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250
# 
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-20 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250
# 
# 
# ${PROFILE40_POWER_BAD}    ul_mimo_srs_beam_pos_nr profile_id\=40 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-650,-600,-650,-600
# 
# ${PROFILE41_POWER_BAD}    ul_mimo_srs_beam_pos_nr profile_id\=41 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=0 srs_transmit_power_per_port\=-650,-600,-650,-600
# 
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=12 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=13 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=14 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# 
# 
# ${SET_PROFILE40_POWER_BAD}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=40
# ${SET_PROFILE41_POWER_BAD}    ue_testmode_set_nr id\=12 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=41
# 
# 
# *** Test Cases ***
# CB008322_B32_case019_2UE_T1R4_80Mhz_SubBandSize128_RANK2_SRSperiod320_CLoseLoopMimo_frame1070
#     #Active GNB L2 feature debug traces
# 	Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
# 	Start capture gnb and ap syslog in 'after_onair' file
# 
#     #step1
# 	Attach NSA UEs from '${UE1_NSA_ID}' to '${UE2_NSA_ID}'
# 	Set UE good power
# 	${ue1_rnti}    Get NSA '${UE1_NSA_ID}' crnti in RRC log
# 	set suite variable     ${ue1_rnti}
# 	${ue2_rnti}    Get NSA '${UE2_NSA_ID}' crnti in RRC log
# 	set suite variable     ${ue2_rnti}
# 
# 	#step2
# 	NSA send full data '${UE1_NSA_ID}' UE
# 	NSA send small data '${UE2_NSA_ID}' UE
# 	Wait '5s' for stabible
# 	#Start collect bip log
#     #Wait for '1s' to stop bip log with name'${BIP_TAG}_2'
#     Start collect ttitrace
#     Wait for '4s' to stop ttitrace with name'${TTI_TAG}_2'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_2_dl.csv
#     run keyword and continue on failure	   Check ttitrace'tti_rt_dft_case19.ini'
# 
#     #step3
#     NSA send full data '${UE2_NSA_ID}' UE
#     Wait '5s' for stabible
#     #Start collect bip log
#     #Wait for '1s' to stop bip log with name'${BIP_TAG}_rt'
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'${TTI_TAG}_rt'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_rt_dl.csv
#     run keyword and continue on failure	   Check ttitrace'tti_rt_case19.ini'
# 
#     #step 4
# #    Set UE '${UE1_NSA_ID}' low power
# #    Set UE '${UE2_NSA_ID}' low power
#     Set UE bad power
#     Wait '2s' for stabible
#     #Start collect bip log
#     #Wait for '1s' to stop bip log with name'${BIP_TAG}_dft'
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'${TTI_TAG}_dft'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_dft_dl.csv
#     run keyword and continue on failure	   Check ttitrace'tti_dft_case19.ini'
# 
#      #step 5
# #    Set UE '${UE1_NSA_ID}' power deactivate
# #    Set UE '${UE2_NSA_ID}' power deactivate
#     Set UE good power
#     Wait '2s' for stabible
#     #Start collect bip log
#     #Wait for '1s' to stop bip log with name'${BIP_TAG}_rt2'
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'${TTI_TAG}_rt2'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_rt2_dl.csv
#     run keyword and continue on failure	   Check ttitrace'tti_rt2_case19.ini'
# 
#     #step6
#     Attach NSA UEs from '${UE3_NSA_ID}' to '${UE4_NSA_ID}'
#     Set UE13-14 good power
#     ${ue3_rnti}    Get NSA '${UE3_NSA_ID}' crnti in RRC log
# 	set suite variable     ${ue3_rnti}
# 	${ue4_rnti}    Get NSA '${UE4_NSA_ID}' crnti in RRC log
# 	set suite variable     ${ue4_rnti}
#     NSA send full data '${UE3_NSA_ID}' UE
#     NSA send full data '${UE4_NSA_ID}' UE
#     Wait '5s' for stabible
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'${BIP_TAG}_4UE'
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'${TTI_TAG}_rt_4UE'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_rt_4UE_dl.csv
#     Get pattern id in ttitrace
#     run keyword and continue on failure	    Check ttitrace'tti_rt_4UE_case19.ini'
#     run keyword and continue on failure	    convert '${BIP_TAG}_4UE' bip and check
# 
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# 
#     
# *** Keywords ***
# Add RD
# 	Add GNB swconfig    0x580789:1  
# #    Add GNB swconfig	0x580717:0
#     Wts Execute Aashell Command
#     ...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
# 
# Check subband beam'${num}'
#     log to console  check subband beam ${num} times
# 	Attach '${UE_NUM_NSA}' NSA UEs
#     NSA send data '${UE_NUM_NSA}' UEs
# 	Wait '10s' for stabible
# 
# #	run keyword and continue on failure	   Check NSA UE throughput
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'${BIP_TAG1}'
# 
# 	Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'${TTI_TAG}'
# 	run keyword and continue on failure	   Check ttitrace
# 	Airphone NSA Stop Data Traffic And Detach UE
# 
# 
# 
# SA Register UE ${UE_ID}
# 	Airphone SA Attach    ue_id=${UE_ID}
# 	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
# 	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
# 	Wait '2s' for stabible
# 
# Attach '${UE_NUM_SA}' SA UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   airphone_cleanup_egate_console_log
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
#     \   Wait '2s' for stabible
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \   Wait '2s' for stabible
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
# 
# SA send data '${UE_NUM_SA}' UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    SA send mutiple trf dl data    ${num}    5   175M   ${num}    tcp
# #    \    SA send mutiple trf ul data    ${num}    1    175M   ${num}
# 
# Airphone SA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    Airphone SA Detach    ue_id=${num}
# 
# 
# Attach NSA UEs from '${low_id}' to '${high_id}'
#     : FOR    ${num}    IN RANGE    ${low_id}    ${high_id}+1
#     \   airphone_cleanup_egate_console_log
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   Wait '10s' for stable
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
# 
# NSA send data '${UE_NUM_NSA}' UEs
#     : FOR    ${num}    IN RANGE    11    ${UE_NSA_ID}+${UE_NUM_NSA}
#     \   NSA send mutiple trf dl data    ${num}    5    175M    tcp
# #    \   NSA send mutiple trf ul data    ${num}    1    175M
# 
# SA send small data to ‘${UE_ID}’ UE
#     SA send mutiple trf dl data    ${UE_ID}    1   10M   ${UE_ID}
# 
# 
# NSA send small data '${UE_ID}' UE
#     NSA send mutiple trf dl data    ${UE_ID}    1    10M    tcp
# 
# NSA send full data '${UE_ID}' UE
#     NSA send mutiple trf dl data    ${UE_ID}    5    175M    tcp
# 
# 
# Airphone NSA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    11    ${UE_NSA_ID}+${UE_NUM_NSA}
#     \    Airphone NSA Stop Data Traffic   ${num}    DL
#     \    Airphone NSA Detach    ${num}
# 
# 
# NSA stop data traffic from '${low_id}' to '${high_id}'
#     : FOR    ${num}    IN RANGE    ${low_id}   ${high_id}+1
#     \    Airphone NSA Stop Data Traffic   ${num}    DL
# 
# Check NSA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi NSA UEs throughput
# 
# 
# Verify multi NSA UEs throughput
#     : FOR    ${num}    IN RANGE    11    ${UE_NSA_ID}+${UE_NUM_NSA}
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pusch    tput_type=ave
#     \    Log To Console		UE:${num} dl_tput= ${dl_throughput_pcell}
#     \    Log To Console		UE:${num} ul_tput= ${ul_throughput_pcell}
#     \    should_be_true    ${dl_throughput_pcell}>210000
# 
# 
# Check SA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput
# 
# Verify multi SA UEs throughput
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#     \    Log To Console		UE:${num} dl_tput= ${dl_throughput_pcell}
#     \    Log To Console		UE:${num} ul_tput= ${ul_throughput_pcell}
#     \    should_be_true    ${dl_throughput_pcell}>210000
# 
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case19.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# Check ttitrace'${ini_file}'
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# 
# Set UE '${UE_ID}' good sinr
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=10 sinr_target_srs\=35 sinr_target_pucch\=-300 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_sinr action\=activate profile_id\=10
# 
# Set UE '${UE_ID}' bad sinr
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=11 sinr_target_srs\=-35 sinr_target_pucch\=-300 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_sinr action\=activate profile_id\=11
# 
# Override '${UE_ID}' CQI trigger good threshold
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=15 cqi\=15 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=1
# 
# Override '${UE_ID}' CQI trigger bad threshold
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=16 cqi\=1 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=16 scell\=1
# 
# NSA UE '${UE_ID}' fix RANK2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=20 ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=20 scell\=8
# 
# SA UE '${UE_ID}' fix RANK2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=20 ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=20 scell\=0
# 
# Set UE '${UE_ID}' pos and move
#     airphone_execute_egate_command    ul_mimo_srs_beam_pos_nr profile_id\=30 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=5
#     ...    trigger_puxch_update\=0 azimuth\=30 zenith\=10 test_type=SRS
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# 
# Set UE low power
#     ${cmd}   Catenate    ul_mimo_srs_beam_pos_nr profile_id\=40 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
#     ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-70 zenith\=40 srs_transmit_power_per_port\=-650,-600,-650,-600
#     airphone_execute_egate_command    ${PROFILE1_POWER_BAD}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=40
# 
# Set UE '${UE_ID}' power deactivate
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=40
# 
# Set UE good power
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${SET_PROFILE1}
#     airphone_execute_egate_command    ${SET_PROFILE2}
# 
# Set UE bad power
#     airphone_execute_egate_command    ${PROFILE40_POWER_BAD}
#     airphone_execute_egate_command    ${PROFILE41_POWER_BAD}
#     airphone_execute_egate_command    ${SET_PROFILE40_POWER_BAD}
#     airphone_execute_egate_command    ${SET_PROFILE41_POWER_BAD}
# 
# Set UE13-14 good power
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${PROFILE4}
#     airphone_execute_egate_command    ${SET_PROFILE3}
#     airphone_execute_egate_command    ${SET_PROFILE4}
# 
# 
# Get SA UE '${num}' rnti
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_${num}_egate    unzip=TRUE
#     ${ret}     file match all       ${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_${num}_egate/egate_console.log    .*crnti: (\\d+)
#     set suite variable     ${sa_ue_rnti}    ${ret[0]}
# 
# Get SA '${ue_id}' crnti in RRC log
#     Log To Console   check SA UE RRC log to get all ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_${ue_id}_egate /egate_console.log.001   crnti: (\\d+)
#     [return]     ${rnti_list[0]}
# 
# Get NSA '${ue_id}' crnti in RRC log
#     Log To Console   check NSA UE RRC log to get all ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_${ue_id}_egate/egate_console.log.001   newUE-Identity (\\d+)
#     [return]     ${rnti_list[0]}
# 
# Convert '${bip_tag}' BIP and check
#     Log To Console   convert bip to csv
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
#      ...    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/bip_srsreceivereq.csv    ${FILTER_csv}    ${tiltle_srsreceivereq}
# 
#     check_max_2_UEs_weight_calculated_per_each_SRS_symbol    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/bip_srsreceivereq.csv
# 
# Get pattern id in ttitrace
#     ${ue1_ping_pattern_id1}    get_ue_ping_stream_config_pattern_id1_in_tti    ${${start_pattern_id}}    ${${chbw_prb}}    ${${subband_size}}
#     ...    ue_num=1
# 	set suite variable     ${ue1_ping_pattern_id1}
# 	${ue1_pong_pattern_id1}    get_ue_pong_stream_config_pattern_id1_in_tti    ${${start_pattern_id}}    ${${chbw_prb}}    ${${subband_size}}
# 	...    ue_num=1
# 	set suite variable     ${ue1_pong_pattern_id1}
# 	${ue1_ping_pattern_id2}    get_ue_ping_stream_config_pattern_id2_in_tti    ${${start_pattern_id}}    ${${chbw_prb}}    ${${subband_size}}
# 	...    ${${rank}}    ue_num=1
# 	set suite variable     ${ue1_ping_pattern_id2}
# 	${ue1_pong_pattern_id2}    get_ue_pong_stream_config_pattern_id2_in_tti    ${${start_pattern_id}}    ${${chbw_prb}}    ${${subband_size}}
# 	...    ${${rank}}    ue_num=1
# 	set suite variable     ${ue1_pong_pattern_id2}
# 
# 
# 
# 
# 
