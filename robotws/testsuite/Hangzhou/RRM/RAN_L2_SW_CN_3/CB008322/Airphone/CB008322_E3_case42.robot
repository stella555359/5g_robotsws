# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_l10wang    AP    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# ...   CLOUD_5G_I_BOO_AP_LOO
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# Library     taf.collectors.l1l2bip
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8322-E_case42_coderate.xml
# ${AIRPHONE_NAME}    IPHY_2AQQL_1FDD_E3_case42.xml
# ${WTS_NAME}    wts_8322_3cell_SA_NSA_case42.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog
# ${FILTER}      uldata_puschreceivereq||uldata_srsreceivereq
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# ...    NUMBER_OF_FILES=30
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=12 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=13 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=14 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${UE_ID1}    1
# ${PDU_ID1}     1
# ${SLICE_ID}    1
# ${GW_ID1}    1
# ${UE_ID2}    2
# ${PDU_ID2}     2
# ${GW_ID2}    2
# ${outputcsv}  bip.csv
# @{titles}   UlData_puschReceiveReqGrant_t.numOfPuschSymbols    3gpp.subcellid    3gpp.sfn    3gpp.slot
# 
# *** Test Cases ***
# CB008322_E3_case42_Coexistence_with_CA_TDD_FDD_DL_UL_2CC_Scell_Change_Critical_Band
# 	Add RD
# 	#Add RD for CB009496
# 	Active GNB L2 feature debug traces
#     Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
# 	Start capture gnb and ap syslog in 'after_onair' file
#     Attach SA UE1 and send DL traffic before scelladd and trigger scell change
#     Attach SA UE2 and trigger scelladd
#     Stop capture gnb and ap syslog in 'after_onair' file
#     
# *** Keywords ***
# Add RD
# 	Add GNB swconfig    0x580789:1
#     Add GNB swconfig    0x580717:0
# 
# 	
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Attach SA UE1 and send DL traffic before scelladd and trigger scell change
#      Attach SA UE1 and send DL and UL data
#      Pcell SRS changed to wideband and fakedrx enable
#      Trigger scelladdition for T_F
#      Trigger scellchange for UE1
# 
# Attach SA UE1 and send DL and UL data
#      airphone_execute_egate_command    ${PROFILE1}
#      airphone_execute_egate_command    ${SET_PROFILE1}
#      Airphone Set Traffic Type    ${UE_ID1}    ${PDU_ID1}    internal
#      Airphone SA Attach    ue_id=${UE_ID1}
#      Wait '5s' for stabible
#      Airphone Pdu Session Setup    ${UE_ID1}    ${PDU_ID1}    ${SLICE_ID}    ${GW_ID1}
#      Wait '5s' for stabible
#      UE1 send RANK2
#      SA send dl and ul data    ${UE_ID1}    number=7    dl_data=175M    ul_data=20M    pdu_id=${PDU_ID1}
#      Wait '2s' for stabible
# Pcell SRS changed to wideband and fakedrx enable
#      Start collect ttitrace
# 	 Wait for '1s' to stop ttitrace with name'tti_rank2_ue1'
# 	 split_8322_tti        ${TEST_LOG_DIRECTORY()}/All/tti_rank2_ue1_dl.csv
# 	 Check pcell beamtype for wideband
# 	 Check fake drx enable
# Trigger scelladdition for T_F
#      airphone_cleanup_egate_console_log
# 	 UE1 send A1 event
# 	 Check throughput for FDD scell
#      Start collect ttitrace
# 	 Wait for '1s' to stop ttitrace with name'tti_scell_ue1_t_f'
# 	 Check fdd pusch shorten for ue1
# 	 split_8322_tti        ${TEST_LOG_DIRECTORY()}/All/tti_scell_ue1_t_f_dl.csv
# 	 Start collect bip log for LOOO
# 	 Wait '3s' for stabible
# 	 Wait for '1s' to stop bip log with name'ue1_t_f'
# 	 run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/8322_E3_case42_t_f.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     #Check FDD pusch shorten and pcell beamtype for wideband    ${TEST_LOG_DIRECTORY()}/All/tti_scell_ue1_t_f_dl.csv
# 	#...    ${test_log_directory()}/All/ue1_t_f
# 
# Trigger scellchange for UE1
#     airphone_cleanup_egate_console_log
# 	 UE1 send A1 event for scellchange
# 	 #Check throughput for TDD scell
#      Wait '3s' for stabible
#      Start collect ttitrace
# 	 Wait for '1s' to stop ttitrace with name'tti_scell_ue1_t_t'
# 	 Check pcell beamtype for subband
# 	 Check fake drx disable
# 
# Attach SA UE2 and trigger scelladd
#     airphone_cleanup_egate_console_log
#     Airphone Set Traffic Type    ${UE_ID2}    ${PDU_ID2}    internal
#     Airphone SA Attach    ue_id=${UE_ID2}
#     Wait '5s' for stabible
#     Airphone Pdu Session Setup    ${UE_ID2}    ${PDU_ID2}    ${SLICE_ID}    ${GW_ID2}
#     Wait '5s' for stabible
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2
#     SA send dl and ul data    ${UE_ID2}    number=7    dl_data=175M    ul_data=175M    pdu_id=${PDU_ID2}
#     Wait '5s' for stabible
#     UE2 send A1 event
#     Wait '10s' for stabible
# 	Check throughput for UE2 FDD scell
# 	Check fake drx enable
# 	Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'tti_scell_ue2_t_f'
# 	Check fdd pusch shorten for ue2
#     Start collect bip log for LOOO
# 	Wait '3s' for stabible
# 	Wait for '1s' to stop bip log with name'ue2_t_f'
# 	#Check FDD pusch shorten and pcell beamtype for wideband    ${TEST_LOG_DIRECTORY()}/All/tti_scell_ue2_t_f_dl.csv
# 	#...    ${test_log_directory()}/All/ue2_t_f
# 
# Check FDD pusch shorten and pcell beamtype for wideband
#      [Arguments]    ${file}    ${bip_file_path}
#      Merge_pcaps    ${bip_file_path}
#      ${subcellid_}=    getsubcellid    ${file}   52
#      Set test Variable    ${subcellid}       ${subcellid_}
#      run keyword and continue on failure    Convert BIP To CSV    ${bip_file_path}/bip_out.pcap
#      ...    ${bip_file_path}/bip1.csv    ${FILTER}    ${titles}
#      run keyword and continue on failure    Check Log With Au2anlysis    
#    ...    ini_path=${CURDIR}/ini/fdd_pusch_shorten.ini     log_need_to_check=i
#      ...    save_log_directory=${bip_file_path}
# 
# Check pcell beamtype for wideband
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/8322_E3_case42.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# Check fdd pusch shorten for ue1
# 	run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/8322_E3_case42_ul.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# Check fdd pusch shorten for ue2
# 	run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/8322_E3_case42_ul_ue2.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check pcell beamtype for subband
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/8322_E3_case42_dft.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# UE1 send A1 event
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=1 event\=A1 srsrp_nr\=80
# 
# UE2 send A1 event
#     airphone_execute_egate_command    ue_measurement_send_nr id\=2 meas_id\=1 event\=A1 srsrp_nr\=80
# 
# UE1 send A1 event for scellchange
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=100
# Check fake drx enable
#      airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE1_1   unzip=TRUE
#      run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_ue1_fakedrx_on_case42.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE1_1
# Check fake drx disable
#      airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE1_2   unzip=TRUE
#      run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_ue1_fakedrx_off_case42.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE1_2
# Check throughput for FDD scell
#     Wait '10s' for stabible
#     ${dl_throughput_pcell}     airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=1    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>0
#     should_be_true    ${dl_throughput_scell1}>0
# Check throughput for UE2 FDD scell
#     Wait '10s' for stabible
#     ${dl_throughput_pcell}     airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=1    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>0
#     should_be_true    ${dl_throughput_scell1}>0
# 
# Check throughput for TDD scell
#     Wait '10s' for stabible
#     ${dl_throughput_pcell}     airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=1    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>0
#     should_be_true    ${dl_throughput_scell1}>0
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
# 
# 
# 
# Set UEs Pos
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${SET_PROFILE1}
#     airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${SET_PROFILE2}
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${SET_PROFILE3}
#     airphone_execute_egate_command    ${PROFILE4}
#     airphone_execute_egate_command    ${SET_PROFILE4}
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=-50 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-4 testmode\=ul_sinr action\=activate profile_id\=5
# 
# UE1 send RANK2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=3 scell\=0
# UE1 send RANK3
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=2 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=8
# UE1 send RANK1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=0 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=csi_override action\=activate profile_id\=2 scell\=8
# 
# Merge_pcaps
#     [Arguments]    ${ttitrace_path}
#     TAF_SSH.Connect To    127.0.0.1    ute    ute    alias=bsh
#     TAF_SSH.Execute    cd    connection=bsh
#     TAF_SSH.Send Command    cd ${ttitrace_path};mergecap -w bip_out.pcap *.pcap    connection=bsh
# 
# 
# 
