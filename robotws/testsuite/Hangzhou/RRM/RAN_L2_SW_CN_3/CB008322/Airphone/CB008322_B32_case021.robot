# *** Settings ***
# Test Timeout    180 minutes
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
# ${SCFC_NAME}      SCFC_CB008322_8D4U_1070_80M_SBsize8_case21.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO.xml
# ${WTS_NAME}    wts_SA_NSA_case21.cfg
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
# @{titles_3}    DlData_CsiRsResource_t.patternId_item
# #&{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# #...    NUMBER_OF_FILES=30
# 
# ${UE_NUM_SA}         4
# ${UE_NUM_NSA}        4
# ${UE_SA_ID}         1
# ${UE1_SA_ID}         1
# ${UE2_SA_ID}         2
# ${UE3_SA_ID}         3
# ${UE4_SA_ID}         4
# ${UE_NSA_ID}        11
# 
# ${BIP_TAG}          bip
# ${BIP_TAG1}          bip1
# ${BIP_TAG2}          bip2
# ${BIP_TAG3}          bip3
# ${BIP_TAG4}          bip4
# ${EGATE_TAG}       egate
# ${TTI_TAG}           tti
# ${TTI_TAG2}           tti2
# ${TTI_TAG3}           tti3
# 
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
# ${PROFILE40_POWER_BAD}    ul_mimo_srs_beam_pos_nr profile_id\=40 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=58 zenith\=22 srs_transmit_power_per_port\=-650,-600,-650,-600
# 
# ${SET_PROFILE40_POWER_BAD}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=40
# 
# 
# ${PROFILE43}    ul_mimo_srs_beam_pos_nr profile_id\=43 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=58 zenith\=-10 srs_transmit_power_per_port\=-200,-200,-200,-200
# 
# ${SET_PROFILE43}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=43
# 
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# 
# *** Test Cases ***
# CB008322_B32_case021_4UE_T2R4_80Mhz_SubBandSize8_RANK4_2_SRSperiod160_CLoseLoopMimo_frame1070
#    # Active GNB L2 feature debug traces
# 	Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
# 
# 	#step1
# 	Start capture gnb and ap syslog in 'after_onair' file
# #	Set UE '${UE_SA_ID}' position1
# 
# 	Attach '${UE_NUM_SA}' SA UEs
# 	${ue1_rnti}    Get SA '${UE1_SA_ID}' crnti in RRC log
# 	set suite variable     ${ue1_rnti}
# 	${ue2_rnti}    Get SA '${UE2_SA_ID}' crnti in RRC log
# 	set suite variable     ${ue2_rnti}
# 	${ue3_rnti}    Get SA '${UE3_SA_ID}' crnti in RRC log
# 	set suite variable     ${ue3_rnti}
# 	${ue4_rnti}    Get SA '${UE4_SA_ID}' crnti in RRC log
# 	set suite variable     ${ue4_rnti}
# 	Set UE good power
# 
# 	#step2
#     SA send data '${UE_NUM_SA}' UEs
# 	Wait '5s' for stabible
# 	run keyword and continue on failure	   Check SA UE throughput
#     #Start collect bip log
#     #Wait for '1s' to stop bip log with name'${BIP_TAG1}'
# 	Start collect ttitrace
#     Wait for '4s' to stop ttitrace with name'${TTI_TAG}_rt'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_rt_dl.csv
#     run keyword and continue on failure	   Check ttitrace'tti_rt_case21.ini'
# 
#     #step3
#     SA UE '${UE1_SA_ID}' fix RANK2
#     wait '1s' for stable
#     Start collect ttitrace
#     Wait for '4s' to stop ttitrace with name'${TTI_TAG}_rt_2'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_rt_2_dl.csv
#     run keyword and continue on failure	   Check ttitrace'tti_rt2_case21.ini'
# 
#     #step4
# #    wait '60min' for stabible
#     Start collect ttitrace
#     Wait for '4s' to stop ttitrace with name'${TTI_TAG}_rt_2'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_rt_2_dl.csv
#     run keyword and continue on failure	   Check ttitrace'tti_rt2_case21.ini'
# 
#      #step 5
# #    Set UE '${UE1_SA_ID}' low
#   #  Set UE bad power
#    # Wait '10s' for stabible
#    # Start collect bip log
#    # Wait for '1s' to stop bip log with name'${BIP_TAG}_dft'
#   #  Start collect ttitrace
#    # Wait for '3s' to stop ttitrace with name'${TTI_TAG}_dft'
#    # split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_dft_dl.csv
#     #run keyword and continue on failure	   Check ttitrace'tti_dft_rt_case21.ini'
#    # Resume UE good power
# 
#     #step6
#    # Start collect bip log
#    # Start collect ttitrace
#    # Set UE '${UE_SA_ID}' position2
#    # Wait '4s' for stabible
#   #  ${pcap}=    Stop GNB Ttitrace With Streaming Mode    ${TEST_LOG_DIRECTORY()}/All
#    # Wait for '0s' to stop bip log with name'${BIP_TAG}_mov'
#    # Decoder Tttirace From Pcap To Csv    ${pcap}    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_mov
#    # split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_mov_dl.csv
#     #check
# 
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Add RD
# 	Add GNB swconfig    0x580789:1
# 	Add GNB swconfig    0x5901E6:0xA0    #rdMinSrsUePeriodicity  default=80   slot160
# #    Add GNB swconfig	0x580717:0
#     Wts Execute Aashell Command
#     ...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
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
# Attach SA UEs from '${low_id}' to '${high_id}'
#     : FOR    ${num}    IN RANGE    ${low_id}    ${high_id}+1
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
#     \   Wait '2s' for stabible
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \   Wait '2s' for stabible
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
# 
# 
# SA send data UEs from '${low_id}' to '${high_id}'
#     : FOR    ${num}    IN RANGE    ${low_id}    ${high_id}+1
#     \    SA send mutiple trf dl data    ${num}    5   175M   ${num}    tcp
# 
# Attach '${UE_NUM_NSA}' NSA UEs
#     : FOR    ${num}    IN RANGE    11    ${UE_NSA_ID}+${UE_NUM_NSA}
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   Wait '10s' for stable
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
# 
# NSA send data '${UE_NUM_NSA}' UEs
#     : FOR    ${num}    IN RANGE    11    ${UE_NSA_ID}+${UE_NUM_NSA}
#     \   NSA send mutiple trf dl data    ${num}    6    175M    tcp
# #    \   NSA send mutiple trf ul data    ${num}    1    175M
# 
# SA send small data to ‘${UE_ID}’ UE
#     SA send mutiple trf dl data    ${UE_ID}    1   10M   ${UE_ID}
# 
# 
# NSA send small data '${UE_ID}' UE
#     NSA send mutiple trf dl data    ${UE_ID}    1    10M
# 
# 
# Airphone NSA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    11    ${UE_NSA_ID}+${UE_NUM_NSA}
#     \    Airphone NSA Stop Data Traffic   ${num}    DL
#     \    Airphone NSA Detach    ${num}
# 
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
# #    \    should_be_true    ${dl_throughput_pcell}>210000
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
# Set UE '${UE_ID}' good sinr
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=10 sinr_target_srs\=35 sinr_target_pucch\=-300 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_sinr action\=activate profile_id\=10
# 
# Set UE '${UE_ID}' bad sinr
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=11 sinr_target_srs\=-35 sinr_target_pucch\=-300 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_sinr action\=activate profile_id\=11
# 
# Override '${UE_ID}' CQI trigger good threshold
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=15 cqi\=15
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=1
# 
# Override '${UE_ID}' CQI trigger bad threshold
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=16 cqi\=5
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=16 scell\=1
# 
# NSA UE '${UE_ID}' fix RANK2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=20 ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=20 scell\=8
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
# Overide UE '${UE_ID}' bler
#    airphone_execute_egate_command    bler_testmode_nr profile_id\=1 dl_bler\=100,2,3,4
#    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=0 testmode\=bler profile_id\=1 action\=activate
# 
# Set UE '${UE_ID}' position1
#     airphone_execute_egate_command    ul_mimo_srs_beam_pos_nr profile_id\=43 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=43
# 
# Set UE '${UE_ID}' position2
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${SET_PROFILE43}
# 
# Set UE good power
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${PROFILE4}
#     airphone_execute_egate_command    ${SET_PROFILE1}
#     airphone_execute_egate_command    ${SET_PROFILE2}
#     airphone_execute_egate_command    ${SET_PROFILE3}
#     airphone_execute_egate_command    ${SET_PROFILE4}
# 
# Set UE bad power
#     airphone_execute_egate_command    ${PROFILE40_POWER_BAD}
#     airphone_execute_egate_command    ${SET_PROFILE40_POWER_BAD}
# 
# 
# Resume UE good power
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${SET_PROFILE1}
# 
# Get SA '${ue_id}' crnti in RRC log
#     Log To Console   check UE RRC log to get all ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_${ue_id}_egate/egate_console.log.001   crnti: (\\d+)
#     [return]     ${rnti_list[0]}
# 
# Get NSA '${ue_id}' crnti in RRC log
#     Log To Console   check UE RRC log to get all ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_${ue_id}_egate/egate_console.log.001   newUE-Identity (\\d+)
#     [return]     ${rnti_list[0]}
# 
# Collect and convert '${bip_tag}' BIP
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'BIP_ue_${bip_tag}'
#     Log To Console   convert bip to csv
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${bip_tag}/bip_pdcch.csv    ${FILTER_1}    ${titles_1}
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${bip_tag}/bip_pdsch.csv    ${FILTER_2}    ${titles_2}
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${bip_tag}/bip_csi.csv    ${FILTER_3}    ${titles_3}
# 
# 
# 
