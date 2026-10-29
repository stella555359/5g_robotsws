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
# #${SCFC_NAME}      SCFC_8322_8D4U_1070_80M_8X4.xml
# ${SCFC_NAME}      SCFC_8322_4D4U_AQQL_1208_100M_8x4.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_8x4.xml
# #${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_20M_8x4.xml
# ${WTS_NAME}    wts_SA_NSA_case19.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog
# 
# &{GNBMIRRORINGCONFIGS}    NUMBER_OF_FILES=10
# 
# ${FILTER_SRS_REQ}    uldata_srsreceivereq
# @{titles_bfsubbandid}   3gpp.sfn    3gpp.slot    3gpp.rnti    UlData_srsBwvReportRequest_t.bfSubbandId_item
# ${CH_BW}              272
# ${SUB_BAND_SIZE}      16
# 
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
# 
# ${UE1_NSA_ID}        11
# ${UE2_NSA_ID}        12
# ${UE3_NSA_ID}        13
# ${UE4_NSA_ID}        14
# 
# ${BIP_TAG}          bip
# ${BIP_TAG1}          bip1
# ${BIP_TAG2}          bip2
# ${BIP_TAG3}          bip3
# ${BIP_TAG4}          bip4
# ${EGATE_TAG}         egate
# ${EGATE_TAG1}        egate1
# ${TTI_TAG}           tti
# ${TTI_TAG2}           tti2
# ${TTI_TAG3}           tti3
# 
# 
# *** Test Cases ***
# CB008322_E6_case002_subband_BF_interaction_with_8port_CSI-RS_PMI_actCsirsMultiplexing_false
#     Active GNB L2 feature debug traces
# 	Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
# 
# 	#step2
#     Attach 4 NSA UEs with t1r4
# 	#step3
#     Send 4UEs full data and check logs
#     #step4
#     Fix UE1 rank1 and check logs
#     #step5
#     Change actUeCsirsCoexistCellCsirs true and reattach 4NSA UEs with t1r4 and send full data
#    #step6
#     Change UE1 UE3 power and check logs
# 
#     Detach all NSA UEs
# 
#     Collect AP egate log    ${EGATE_TAG}_all
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# *** Keywords ***
# Add RD
# 	Add GNB swconfig    0x580434:0     	#pdcch use best beam
#     Add GNB swconfig    0x580556:0x834    #rdStartPatternId 0x834=2100
# 	Add GNB swconfig    0x5901EB:0        #rdForceEnablingWidebandTasSrs
# 	Add GNB swconfig    0x5901E6:0xA0    #rdMinSrsUePeriodicity  default=80   slot160
#     Add GNB swconfig    0x5901E6:80    #rdMinSrsUePeriodicity  default=80   slot160
#     Add GNB swconfig    0x580763:2  	#rdWbSrsRankTresh
# #    Add GNB swconfig    0x5805ae:1      #rdEnableSrsSwitchScheduler
#     Add GNB swconfig    0x58076C:10   #rdWbSrsPrbTresh  buffer good thresh
# #    Add GNB swconfig    0x5805b4:20   #rdPeriodSrsCheck 5-100  60
# #    Add GNB swconfig    0x5805b5:1  #rdNumSrsCheck
#     Add GNB swconfig    0x580477:3  #UL Comma print
#     Add GNB swconfig    0x580264:3   # DL Comma print
#     Add GNB swconfig    0x580265:2   #rdNumberOfUeCsirsSymbol
#     Add GNB swconfig    0x5805b0:60  #rdSrsBufPercent
# 
# Attach 4 NSA UEs with t1r4
# 	Attach '${UE_NUM_NSA}' NSA UEs with '${EGATE_TAG}'
# 	${rnti_list}    Get NSA UE crnti in RRC log'${EGATE_TAG}'
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
# 	run keyword and continue on failure	   Check all cell specific CSI RS not multiplexing in rrclog‘${EGATE_TAG}_egate’
# #	run keyword and continue on failure	   Check cell specific CSI RS multiplexing in rrclog‘${EGATE_TAG}_egate’
# 
# Send 4UEs full data and check logs
#     NSA send data '${UE_NUM_NSA}' UEs
# 	Wait '5s' for stabible
# 	run keyword and continue on failure	   Check NSA UE throughput
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'${BIP_TAG1}'
# 	Start collect ttitrace
#     Wait for '4s' to stop ttitrace with name'${TTI_TAG}_rt'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_rt_dl.csv
#     run keyword and continue on failure	   Check ttitrace'tti_rt_E6_case002.ini'
# 
# Fix UE1 rank1 and check logs
#     NSA UE '${UE1_NSA_ID}' fix RANK1
#     wait '1s' for stable
#     Start collect ttitrace
#     Wait for '4s' to stop ttitrace with name'${TTI_TAG}_rank1'
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'bip_rank1'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_rank1_dl.csv
#     run keyword and continue on failure	   Check ttitrace'tti_rank1_E6_case002.ini'
# 
# Change actUeCsirsCoexistCellCsirs true and reattach 4NSA UEs with t1r4 and send full data
#     NSA UE '${UE1_NSA_ID}' fix RANK2
#     Online change actUeCsirsCoexistCellCsirs 'true'
#     Detach NSA ue'${UE1_NSA_ID}'
#     Detach NSA ue'${UE2_NSA_ID}'
#     Detach NSA ue'${UE3_NSA_ID}'
#     Detach NSA ue'${UE4_NSA_ID}'
# 
#     Attach '${UE_NUM_NSA}' NSA UEs with '${EGATE_TAG1}'
# 	${rnti_list}    Get NSA UE crnti in RRC log'${EGATE_TAG1}'
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
# 	run keyword and continue on failure	   Check cell specific CSI RS not multiplexing in rrclog‘${EGATE_TAG1}_egate’
#     run keyword and continue on failure	   Check ue specific CSI RS not multiplexing in rrclog‘${EGATE_TAG1}_egate’
# 
# #	run keyword and continue on failure	   Check cell specific CSI RS multiplexing in rrclog‘${EGATE_TAG1}_egate’
# #	run keyword and continue on failure	   Check ue specific CSI RS multiplexing in rrclog‘${EGATE_TAG1}_egate’
# 
#     NSA send data '${UE_NUM_NSA}' UEs
# 	Wait '5s' for stabible
# 	run keyword and continue on failure	   Check NSA UE throughput
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'${BIP_TAG1}_co'
# 	Start collect ttitrace
#     Wait for '4s' to stop ttitrace with name'${TTI_TAG}_co'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_co_dl.csv
#     run keyword and continue on failure	   Check ttitrace'tti_co_E6_case002.ini'
#     run keyword and continue on failure	   check_csirs_pattern_id_for_ue_specific_csirs    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_co_dl.csv
#     ...    ${ue1_rnti}    ${CH_BW}    ${SUB_BAND_SIZE}
#     run keyword and continue on failure	   check_csirs_pattern_id_for_ue_specific_csirs    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_co_dl.csv
#     ...    ${ue2_rnti}    ${CH_BW}    ${SUB_BAND_SIZE}
# 
# Change UE1 UE3 power and check logs
#     Set UE '${UE1_NSA_ID}' low power
#     Set UE '${UE3_NSA_ID}' low power
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'bip_power'
#     Start collect ttitrace
#     Wait for '4s' to stop ttitrace with name'${TTI_TAG}_power'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_power_dl.csv
#     run keyword and continue on failure	   Check ttitrace'tti_power_E6_case002.ini'
#     run keyword and continue on failure	   check_csirs_pattern_id_for_ue_specific_csirs    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_power_dl.csv
#     ...    ${ue1_rnti}    ${CH_BW}    ${SUB_BAND_SIZE}
#     run keyword and continue on failure	   Convert 'bip_power' BIP and check
# 
# Detach all NSA UEs
#    Detach NSA ue'${UE1_NSA_ID}'
#    Detach NSA ue'${UE2_NSA_ID}'
#    Detach NSA ue'${UE3_NSA_ID}'
#    Detach NSA ue'${UE4_NSA_ID}'
# 
# Stop NSA data transfer'${UE_ID}'
#     airphone_nsa_stop_data_traffic    ue_id=${UE_ID}    direction=dl
# 
# Detach NSA ue'${UE_ID}'
#     airphone_nsa_detach    ue_id=${UE_ID}
# 
# Attach '${UE_NUM_NSA}' NSA UEs with '${EGATE_TAG}'
#     airphone_cleanup_egate_console_log
#     : FOR    ${num}    IN RANGE    11    ${UE_NSA_ID}+${UE_NUM_NSA}
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   Wait '10s' for stable
#     Collect AP egate log    ${EGATE_TAG}
# 
# NSA send data '${UE_NUM_NSA}' UEs
#     : FOR    ${num}    IN RANGE    11    ${UE_NSA_ID}+${UE_NUM_NSA}
#     \   NSA send mutiple trf dl data    ${num}    6    175M    tcp
#     \   NSA send mutiple trf ul data    ${num}    1    10M
# 
# 
# NSA send small data to '${UE_ID}' UE
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
# Check ttitrace'${ini_file}'
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case19.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# NSA UE '${UE_ID}' fix RANK1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=20 ri\=0 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=20 scell\=8
# 
# NSA UE '${UE_ID}' fix RANK2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=40 ri\=1 cqi\=15 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=40 scell\=8
# 
# Set UE '${UE_ID}' pos and move
#     airphone_execute_egate_command    ul_mimo_srs_beam_pos_nr profile_id\=30 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=5
#     ...    trigger_puxch_update\=0 azimuth\=30 zenith\=10 test_type=SRS
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# 
# Set UE '${UE_ID}' low power
#     ${cmd}   Catenate    ul_mimo_srs_beam_pos_nr profile_id\=40 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
#     ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-70 zenith\=40 srs_transmit_power_per_port\=-660,-660,-650,-650
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
#     airphone_execute_egate_command    ul_mimo_srs_beam_pos_nr profile_id\=43 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=43
# 
# Get NSA '${ue_id}' crnti in RRC log
#     Log To Console   check UE RRC log to get all ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_${ue_id}_egate/egate_console.log.001   newUE-Identity (\\d+)
#     [return]     ${rnti_list[0]}
# 
# Get NSA UE crnti in RRC log'${EGATE_TAG}'
#     Log To Console   check UE RRC log to get all ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate/egate_console.log.001   newUE-Identity (\\d+)
#     [return]     ${rnti_list}
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
# Online change actUeCsirsCoexistCellCsirs '${state}'
# 	TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1   actUeCsirsCoexistCellCsirs    ${state}    online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
# 
# 
# Convert '${bip_tag}' BIP and check
#     Log To Console   convert bip to csv
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
#      ...    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/bip_bfsubbandid.csv    ${FILTER_SRS_REQ}    ${titles_bfsubbandid}
#      check_srsreceivereq_bfSubbandId_item    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/bip_bfsubbandid.csv    0    0     17
# 
# Check all cell specific CSI RS not multiplexing in rrclog‘${egate_dir}’
#     check_log_with_au2anlysis    ${CURDIR}/ini/all_cell_specific_csirs_nsa.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${egate_dir}
# 
# Check cell specific CSI RS not multiplexing in rrclog‘${egate_dir}’
#     check_log_with_au2anlysis    ${CURDIR}/ini/cell_specific_csirs_nsa.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${egate_dir}
# 
# Check ue specific CSI RS not multiplexing in rrclog‘${egate_dir}’
#     check_log_with_au2anlysis    ${CURDIR}/ini/ue_specific_csirs_nsa.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${egate_dir}
# 
# Check cell specific CSI RS multiplexing in rrclog‘${egate_dir}’
#     check_log_with_au2anlysis    ${CURDIR}/ini/ue_specific_csirs_multiplex.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${egate_dir}
# 
# Check ue specific CSI RS multiplexing in rrclog‘${egate_dir}’
#     check_log_with_au2anlysis    ${CURDIR}/ini/cell_specific_csirs_multiplex.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${egate_dir}
# 
# 
# 
