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
# #${SCFC_NAME}      SCFC_8322_4D4U_1070_80M_2cell_8x4.xml
# ${SCFC_NAME}      SCFC_8322_8D4U_AQQL_1116_0_80M_2cell_8x4.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_2CELL_APLO_8x4.xml
# ${WTS_NAME}    wts_8322_2cell_SA_NSA.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog
# 
# ${FILTER_f1ap}    (f1ap) && (nr-rrc.supportedSRS_TxPortSwitch)
# @{titles_f1ap}    nr-rrc.supportedSRS_TxPortSwitch
# ${FILTER_1}    (dldata_pdcchsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_2}    (uldata_srsreceiverespps || uldata_srsreceivereq || uldata_srsreceiverespbwvps || uldata_puschreceiverespps || dldata_pdschsendreq ||
# ...    dldata_csirssendreq)
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# @{titles_1}    DlData_DciInfo.patternId_item
# @{titles_2}    3gpp.sfn    3gpp.slot    3gpp.rnti    UlData_srsReceiveReqSubcell_t.srsBwvEnable    UlData_srsBwvReport_t.bwvReportId
# ...    UlData_srsBwvReport_t.result
# #UlData_srsBwvReport_t.numBwvPerSubband    UlData_srsBwvReport_t.startPatternId    DlData_PdschGrant.patternId_item
# #...    DlData_PdschGrant.numOfLayers
# @{titles_3}    DlData_CsiRsResource_t.patternId_item
# &{GNBMIRRORINGCONFIGS}    NUMBER_OF_FILES=10
# 
# ${FILTER_DU_ID}    f1ap||e1ap||rrc
# @{titles_du_id}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID
# 
# ${UE_NUM_SA}         5
# ${UE_NUM_NSA}        4
# ${UE_SA_ID}         1
# ${UE1_SA_ID}         1
# ${UE2_SA_ID}         2
# ${UE3_SA_ID}         3
# ${UE4_SA_ID}         4
# ${UE5_SA_ID}         5
# ${UE_NSA_ID}        11
# 
# ${BIP_TAG}          bip_5UE
# ${BIP_TAG1}          bip_4UE
# ${BIP_TAG2}          bip_3UE
# ${BIP_TAG3}          bip_drx_off
# ${BIP_TAG4}          bip4
# ${EGATE_TAG}         egate
# ${EGATE_TAG_5UE}        egate_5ue
# ${EGATE_TAG_UE1_DETACH}        egate_ue1_detach
# ${EGATE_TAG_DRX_ON}        egate_drx_on
# ${EGATE_TAG_UE3_LOW}        egate_ue3_low
# ${EGATE_TAG_DRX_OFF}        egate_drx_off
# ${EGATE_TAG_SWTICH}        egate_switch
# ${TTI_TAG}           tti_5UE
# ${TTI_TAG1}           tti_4UE
# ${TTI_TAG2}           tti_3UE
# ${TTI_TAG3}           tti_3UE_drx_off
# 
# ${FILTER_SRS_REQ}    uldata_srsreceivereq
# @{titles_bfsubbandid}   3gpp.sfn    3gpp.slot    3gpp.rnti    UlData_srsBwvReportRequest_t.bfSubbandId_item
# ${CH_BW}              217
# ${SUB_BAND_SIZE}      32
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=58 zenith\=22 srs_transmit_power_per_port=-200,-200,-200,-200
# 
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-18 zenith\=22 srs_transmit_power_per_port=-200,-200,-200,-200
# 
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-58 zenith\=-2 srs_transmit_power_per_port=-200,-200,-200,-200
# 
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=18 zenith\=-2 srs_transmit_power_per_port=-200,-200,-200,-200
# 
# 
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-200,-200,-200,-200
# 
# 
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# 
# 
# *** Test Cases ***
# CB008322_E6_case003_subband_BF_interaction_with_8port_CSI-RS_PMI_and_DRX_MGap
#     #Active GNB L2 feature debug traces
# 	Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
# 	Start capture gnb and ap syslog in 'after_onair' file
# 
#     #step1
# 	Attach 5SA UEs with t2r4 and check logs
# 	#step2
#     Send 5SA UEs full data and check logs
#     #step3
# #    Detach UE1 and check logs
# #    #step4
# #    Detach UE2 and check logs
#     Detach UE1-2 and check logs
#     #step5
#     Send small data to UE3 and check logs
#     #step6
#     Change actcdrx false and check logs
# 
#     Detach all SA UEs
#     Collect AP egate log    ${EGATE_TAG}_all
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# *** Keywords ***
# Add RD
# 	#Add GNB swconfig    0x580789:1  
#      Add GNB swconfig    0x580265:1   #rdNumberOfUeCsirsSymbol
#     # Add GNB swconfig	0x580717:0
#     Wts Execute Aashell Command
#     ...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
#      
# 
# Attach 5SA UEs with t2r4 and check logs
#     Log To Console    ’Attach 5SA UEs with t2r4 and check logs‘
#     Attach '${UE_NUM_SA}' SA UEs with '${EGATE_TAG}'
#     Set UE good power 
# 	${rnti_list}    Get SA UE crnti in RRC log'${EGATE_TAG}'
# 	Log To Console    rnti_list=${rnti_list}
# 	${ue1_rnti}    set variable    ${rnti_list[0]}
# 	Log To Console    ue1_rnti=${ue1_rnti}
# 	set suite variable     ${ue1_rnti}
# 	${ue2_rnti}    set variable    ${rnti_list[1]}
# 	set suite variable     ${ue2_rnti}
# 	${ue3_rnti}    set variable    ${rnti_list[2]}
# 	set suite variable     ${ue3_rnti}
# 	${ue4_rnti}    set variable    ${rnti_list[3]}
# 	set suite variable     ${ue4_rnti}
# 	${ue5_rnti}    set variable    ${rnti_list[4]}
# 	set suite variable     ${ue5_rnti}
# 
# 	run keyword and continue on failure	   Check ue specific CSI RS multiplexing in rrclog‘${EGATE_TAG}_egate’
# 	run keyword and continue on failure	   Check cell specific CSI RS multiplexing in rrclog‘${EGATE_TAG}_egate’
# 
# Send 5SA UEs full data and check logs
#     Log To Console    'Send 5SA UEs full data and check logs'
#     airphone_cleanup_egate_console_log
#     SA send data '${UE_NUM_SA}' UEs
# 	Wait '5s' for stabible
# 	Collect AP egate log    ${EGATE_TAG_SWTICH}
# 	run keyword and continue on failure	   Check SA UE throughput
#     #Start collect bip log
#     #Wait for '1s' to stop bip log with name'${BIP_TAG}'
# 	Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'${TTI_TAG}'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_dl.csv
#     #check UE specific Csirs patternid
#     run keyword and continue on failure	   check_csirs_pattern_id_for_ue_specific_csirs    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_dl.csv
#     ...    ${ue1_rnti}    ${CH_BW}    ${SUB_BAND_SIZE}
#     run keyword and continue on failure	   check_csirs_pattern_id_for_ue_specific_csirs    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_dl.csv
#     ...    ${ue2_rnti}    ${CH_BW}    ${SUB_BAND_SIZE}
#     #check bler  beamtype rank and cell specific Csirs patternid
#     run keyword and continue on failure	   Check ttitrace'tti_5UE_mix_E6_case003.ini'
#     #run keyword and continue on failure	   Convert '${BIP_TAG}' BIP and check bfsunbbandid
#     run keyword and continue on failure	   Check fake drx in rrclog‘${EGATE_TAG_SWTICH}_egate’
# 
# Detach UE1-2 and check logs
#     Log To Console    'Detach UE1 and check logs'
#     Collect AP egate log    ${EGATE_TAG_5UE}
#     airphone_cleanup_egate_console_log
# 
#     Detach '${UE1_SA_ID} ' SA UEs
#     Detach '${UE2_SA_ID} ' SA UEs
#     Wait '61s' for stabible
# 
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'${TTI_TAG2}'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG2}_dl.csv
#     Collect AP egate log    ${EGATE_TAG_DRX_ON}
# 
#     #check bler  beamtype rank and cell specific Csirs patternid
#     run keyword and continue on failure	   Check ttitrace'tti_3UE_mix_E6_case003.ini'
# 
#     run keyword and continue on failure	   Check rrc reconfig no ue specific csi rs in rrclog‘${EGATE_TAG_DRX_ON}_egate’
# 
# 
# Detach UE2 and check logs
#      Log To Console    'Detach UE2 and check logs'
# #    airphone_cleanup_egate_console_log
# 
#     Detach '${UE2_SA_ID} ' SA UEs
#     Wait '61s' for stabible
# #    Start collect bip log
# #    Wait for '1s' to stop bip log with name'${BIP_TAG2}'
#     Start collect ttitrace
#     Wait for '4s' to stop ttitrace with name'${TTI_TAG2}'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG2}_dl.csv
# #    Collect AP egate log    ${EGATE_TAG_UE1_DETACH}
# 
#     #check bler  beamtype rank and cell specific Csirs patternid
#     run keyword and continue on failure	   Check ttitrace'tti_3UE_mix_E6_case003.ini'
# 
# Send small data to UE3 and check logs
#     Log To Console    'Send small data to UE3 and check logs'
#     airphone_cleanup_egate_console_log
#     Stop data transfer'${UE3_SA_ID}'
#     SA send small data to ‘${UE3_SA_ID}’ UE
#     wait '30s' for stable
#     Start collect ttitrace
#     Wait for '4s' to stop ttitrace with name'${TTI_TAG2}_low'
# #    Start collect bip log
# #    Wait for '1s' to stop bip log with name'${BIP_TAG2}'
#     Collect AP egate log    ${EGATE_TAG_UE3_LOW}
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG2}_low_dl.csv
# 
#     #check bler  beamtype rank and cell specific Csirs patternid
#     run keyword and continue on failure	   Check ttitrace'tti_3UE_low_E6_case003.ini'
#     run keyword and continue on failure	   Check rrc reconfig no ue specific csi rs in rrclog‘${EGATE_TAG_UE3_LOW}_egate’
# 
# Change actcdrx false and check logs
#     Log To Console    'Change actcdrx false and check logs'
#     airphone_cleanup_egate_console_log
#     Detach all SA UEs
#     Online change actCDrx 'false'
# #    Detach all SA UEs
#     Attach 5SA UEs with t2r4 and check logs
#     SA send data '${UE_NUM_SA}' UEs
#     wait '3s' for stable
# 
#     Start collect ttitrace
#     Detach '${UE1_SA_ID} ' SA UEs
#     Detach '${UE2_SA_ID} ' SA UEs
# 
#     Wait '1s' for stabible
#     ${pcap}=    Stop GNB Ttitrace With Streaming Mode    ${TEST_LOG_DIRECTORY()}/All
#     Decoder Tttirace From Pcap To Csv    ${pcap}    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG3}
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG3}_dl.csv
# 
#     Collect AP egate log    ${EGATE_TAG_DRX_OFF}
# 
#     #check bler  beamtype rank and cell specific Csirs patternid
#     run keyword and continue on failure	   Check ttitrace'tti_3UE_drx_off_E6_case003.ini'
#     run keyword and continue on failure	   check rrc reconfig to ue specific csi rs in rrclog‘${EGATE_TAG_DRX_OFF}_egate’
#     run keyword and continue on failure	   check_csirs_pattern_id_for_ue_specific_csirs    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG3}_dl.csv
#     ...    ${ue3_rnti}    ${CH_BW}    ${SUB_BAND_SIZE}
#     run keyword and continue on failure	   check_csirs_pattern_id_for_ue_specific_csirs    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG3}_dl.csv
#     ...    ${ue4_rnti}    ${CH_BW}    ${SUB_BAND_SIZE}
# 
# 
# Detach '${UE_SA_ID} ' SA UEs
#     airphone_sa_detach    ue_id=${UE_SA_ID}    timeout=30
# 
# Detach all SA UEs
#     airphone_sa_detach    ue_id=${UE3_SA_ID}    timeout=30
#     airphone_sa_detach    ue_id=${UE4_SA_ID}    timeout=30
#     airphone_sa_detach    ue_id=${UE5_SA_ID}    timeout=30
# 
# Attach '${UE_NUM_SA}' SA UEs with '${egate_tag}'
#     airphone_cleanup_egate_console_log
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
#     \   Wait '2s' for stabible
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \   Wait '2s' for stabible
#     Collect AP egate log    ${egate_tag}
# 
# SA send data '${UE_NUM_SA}' UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    SA send mutiple trf dl data    ${num}    5   175M   ${num}    tcp
#     \    SA send mutiple trf ul data    ${num}    1    10M   ${num}
#     \    Wait '10s' for stabible
# 
# Airphone SA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    Airphone SA Detach    ue_id=${num}
# 
# Stop data transfer'${UE_ID}'
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}    pdu_id=${UE_ID}    direction=dl
# 
# SA send small data to ‘${UE_ID}’ UE
#     SA send mutiple trf dl data    ${UE_ID}    1   10M   ${UE_ID}
# 
# 
# SA send full data to ‘${UE_ID}’ UE
#     SA send mutiple trf dl data    ${UE_ID}    5   175M   ${UE_ID}
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
# #    \    should_be_true    ${dl_throughput_pcell}>210000
# 
# 
# Check ttitrace'${ini_file}'
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case19.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# 
# SA UE '${UE_ID}' fix RANK3
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=40 ri\=2 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=40 scell\=0
# 
# SA UE '${UE_ID}' fix RANK2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=30 ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=30 scell\=0
# 
# SA UE '${UE_ID}' fix RANK1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=20 ri\=0 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=20 scell\=0
# 
# Set UE '${UE_ID}' pos and move
#     airphone_execute_egate_command    ul_mimo_srs_beam_pos_nr profile_id\=30 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=5
#     ...    trigger_puxch_update\=0 azimuth\=30 zenith\=10 test_type=SRS
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# 
# Set UE '${UE_ID}' low power
#     ${cmd}   Catenate    ul_mimo_srs_beam_pos_nr profile_id\=40 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
#     ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-70 zenith\=40 srs_transmit_power_per_port\=-650,-600,-650,-600
#     airphone_execute_egate_command    ${cmd}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=40
# 
# Set UE '${UE_ID}' power deactivate
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=40
# 
# Set UE '${UE_ID}' position1
#     airphone_execute_egate_command    ul_mimo_srs_beam_pos_nr profile_id\=43 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=43
# 
# Set UE '${UE_ID}' position2
#     airphone_execute_egate_command    ul_mimo_srs_beam_pos_nr profile_id\=43 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=43
# 
# 
# Get SA UE crnti in RRC log'${EGATE_TAG}'
#     Log To Console   check UE RRC log to get all ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate/egate_console.log.001   crnti: (\\d+)
#     [return]     ${rnti_list}
# 
# Get NSA UE crnti in RRC log'${EGATE_TAG}'
#     Log To Console   check UE RRC log to get all ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate/egate_console.log.001   newUE-Identity (\\d+)
#     [return]     ${rnti_list}
# 
# 
# Online change actCDrx '${state}'
# 	TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-2/NRCELL-1   actCDrx    ${state}    online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
# 
# 
# Check cell specific CSI RS not multiplexing in rrclog‘${egate_dir}’
#     check_log_with_au2anlysis    ${CURDIR}/ini/cell_specific_csirs.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${egate_dir}
# 
# Check ue specific CSI RS not multiplexing in rrclog‘${egate_dir}’
#     check_log_with_au2anlysis    ${CURDIR}/ini/ue_specific_csirs.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${egate_dir}
# 
# Check all cell specific CSI RS multiplexing in rrclog‘${egate_dir}’
#     check_log_with_au2anlysis    ${CURDIR}/ini/all_cell_specific_csirs_multiplex.ini    p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${egate_dir}
# 
# Check cell specific CSI RS multiplexing in rrclog‘${egate_dir}’
#     check_log_with_au2anlysis    ${CURDIR}/ini/cell_specific_csirs_multiplex_E6_case03.ini    p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${egate_dir}
# 
# Check ue specific CSI RS multiplexing in rrclog‘${egate_dir}’
#     check_log_with_au2anlysis    ${CURDIR}/ini/ue_specific_csirs_multiplex.ini    p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${egate_dir}
# 
# Check rrc reconfig to ue specific csi rs in rrclog‘${egate_dir}’
#     check_log_with_au2anlysis    ${CURDIR}/ini/reconfig_ue_specific_csirs.ini    p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${egate_dir}
# 
# Check rrc reconfig no ue specific csi rs in rrclog‘${egate_dir}’
#     check_log_with_au2anlysis    ${CURDIR}/ini/reconfig_no_ue_specific_csirs.ini    p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${egate_dir}
# 
# 
# 
# 
# Check fake drx in rrclog‘${egate_dir}’
#     check_log_with_au2anlysis    ${CURDIR}/ini/fake_drx.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${egate_dir}
# 
# 
# Convert '${bip_tag}' BIP and check bfsunbbandid
#     Log To Console   convert bip to csv
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
#      ...    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/bip_bfsubbandid.csv    ${FILTER_SRS_REQ}    ${titles_bfsubbandid}
#      check_srsreceivereq_bfSubbandId_item    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/bip_bfsubbandid.csv    item_index=0    min_value=0
#      ...    max_value=7
# 
# Set UE good power
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${PROFILE4}
#     airphone_execute_egate_command    ${PROFILE5}
#     airphone_execute_egate_command    ${SET_PROFILE1}
#     airphone_execute_egate_command    ${SET_PROFILE2}
#     airphone_execute_egate_command    ${SET_PROFILE3}
#     airphone_execute_egate_command    ${SET_PROFILE4}
#     airphone_execute_egate_command    ${SET_PROFILE5}
# 
# 
# 
# 
# 
