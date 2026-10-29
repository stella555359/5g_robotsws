# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_l10wang    AP    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# ...   CLOUD_5G_I_MP_AP_LOOO
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_3T_case43_MP.xml
# ${AIRPHONE_NAME}    IPHY_3AQQL_MP.xml
# ${WTS_NAME}    wts_8322_3cell_SA_NSA_case43.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog
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
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-250,-250
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=12 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=13 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=14 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${UE_ID1}    1
# ${PDU_ID1}    1
# ${SLICE_ID}    1
# ${GW_ID1}    1
# *** Test Cases ***
# CB008322_E3_case43_Coexistence_with_CA_TDD_TDD_DL_2CC_3CC_Pcell_TAS_SRS
# 	Add RD
#     Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
# 	#online act CB08322 debug flag
# 	Start capture gnb and ap syslog in 'after_onair' file
#     Attach 3CC UE and start DL data
#     UE1 send A1 event
#     Trigger A2 release to UE
#     Stop capture gnb and ap syslog in 'after_onair' file
#     
# *** Keywords ***
# Add RD
# 	Add GNB swconfig    0x580789:1
#     Add GNB swconfig    0x580717:0
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Attach 3CC UE and start DL data
#      #airphone_execute_egate_command    ${PROFILE1}
#      #airphone_execute_egate_command    ${SET_PROFILE1}
#      Airphone Set Traffic Type    ${UE_ID1}    ${PDU_ID1}    internal
#      Airphone SA Attach    ue_id=${UE_ID1}
#      Wait '5s' for stabible
#      Airphone Pdu Session Setup    ${UE_ID1}    ${PDU_ID1}    ${SLICE_ID}    ${GW_ID1}
#      Wait '5s' for stabible
#      UE1 send RANK2
#      airphone_cleanup_egate_console_log
#      SA send dl and ul data    ${UE_ID1}    number=7    dl_data=175M    ul_data=20M    pdu_id=${PDU_ID1}
#      Wait '2s' for stabible
#      Start collect ttitrace
# 	 Wait for '1s' to stop ttitrace with name'tti_rank2_ue1'
# 	 split_8322_tti        ${TEST_LOG_DIRECTORY()}/All/tti_rank2_ue1_dl.csv
# 	 Check pcell SRS resource is wideband SRS
# 	 Check fake drx enable
# 
# Check pcell SRS resource is wideband SRS
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/8322_E3_case43_widebandsrs.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check pcell SRS resource is subband SRS
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/8322_E3_case43_subbandsrs.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
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
# UE1 send RANK2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=3 scell\=0
# 
# 
# UE1 send A1 event
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=1 event\=A1 srsrp_nr\=100
#     Wait '2s' for stabible
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti_UE1_scelladd'
#     #split_8322_tti        ${TEST_LOG_DIRECTORY()}/All/tti_UE1_scelladd_dl.csv
#     Check throughput for TDD scell
#     Check pcell SRS resource is subband SRS
#     Check fake drx disable
# 
# Check throughput for TDD scell
#     Wait '10s' for stabible
#     ${dl_throughput_pcell}     airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=1    type=pdsch    tput_type=ave
#     ${dl_throughput_scell2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=2    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>0
#     should_be_true    ${dl_throughput_scell1}>0
#     should_be_true    ${dl_throughput_scell2}>0
# Trigger A2 release to UE
# 
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=3 event\=A2 rs_type\=ssb srsrp_nr\=90 scell\=2
#     Wait '2s' for stabible
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti_UE1_scellrelease_scell2'
#     Check SRS Resurce for Subband SRS
#     airphone_cleanup_egate_console_log
# 
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=2 event\=A2 rs_type\=ssb srsrp_nr\=100 scell\=1
#     Wait '2s' for stabible
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti_UE1_scellrelease_scell1'
#     split_8322_tti        ${TEST_LOG_DIRECTORY()}/All/tti_UE1_scellrelease_scell1_dl.csv
#     Check SRS Resurce for Wideband SRS
#     Check fake drx enable for scellrelease
# 
# Check SRS Resurce for Subband SRS
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/8322_E3_case43_scellrelease2_subbandsrs.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# 
# Check SRS Resurce for Wideband SRS
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/8322_E3_case43_scellrelease1_widebandsrs.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check fake drx enable for scellrelease
#      airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_scellrelease   unzip=TRUE
#      run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_ue1_fakedrx_on_case43.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_scellrelease
# 
# DeRegister SA UE‘${UE_ID}’
#     airphone_sa_detach    ue_id=${num}    timeout=5
#     Wait '2s' for stabible
