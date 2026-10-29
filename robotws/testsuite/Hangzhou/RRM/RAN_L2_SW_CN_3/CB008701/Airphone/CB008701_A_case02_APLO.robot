# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags    owner_l3gao    AP    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LO
# Test Timeout      600 minutes
# Resource          ../../resources/KISS/robot/common_resource.robot
# Resource          ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# Documentation
# ...    8701 APLO porting ,tapering enable ,but lowerSE ,so disable
# ...    8X4 dlmimo enable ,cell on air fail ,need raise issue
# ...    2UE two position ,one list
# ...    40mhz fail
# ...    NSA buffer not enough. but total 1.4g
# ...    tapering enable
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8701_case02_LO_AP_LO_8X4mimo.xml
# ${AIRPHONE_NAME}    IPHY_AEHC_1CELL_APLO_8X4mimo.xml
# ${WTS_NAME}       wts_aehc_8701_aplo_nsa.cfg
# ${UE_NUM}         4
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# @{LOG_NAME_LIST}    gnb_snapshot    #ap_snapshot    egatelog
# ${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60
# @{Rdparameter}    0x340000:15    0x9D0000:15
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=50 zenith\=30 srs_transmit_power_per_port=-280,-280,-280,-280
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=-30 srs_transmit_power_per_port=-280,-280,-280,-280
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-50 zenith\=30 srs_transmit_power_per_port=-280,-280,-280,-280
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=-30 srs_transmit_power_per_port=-280,-280,-280,-280
# 
# ${SET_UE1_SA}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_UE2_SA}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_UE3_SA}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_UE4_SA}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_UE41_NSA}   ue_testmode_set_nr id\=41 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_UE42_NSA}   ue_testmode_set_nr id\=42 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_UE43_NSA}   ue_testmode_set_nr id\=43 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_UE44_NSA}   ue_testmode_set_nr id\=44 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${EGATE_TAG}  egate_8701
# 
# *** Test Cases ***
# CB008701_A_B1_case02_4UEs_rank_4_4_4_4with_nonGBR_paired_with_dlMuMimoRankAdaption_Disabled_4codebook_tapering_NSA
#     step1: gNB prepare
#     step2: 4 NSA UEs 16layer pairing check
# 
# *** Keywords ***
# step1: gNB prepare
#     Log To Console    gNB prepare
#     Modify 8701 Swconfig
# #    Active GNB L2 feature debug traces
#     Get and Update BSR File    ${par_of_bsr_name}
#     Prepare gnb onair
# 
# step2: 4 NSA UEs 16layer pairing check
#     Log To Console    4 NSA UEs 16layer pairing check
#     Start capture gnb and ap syslog in 'NSA_${UE_NUM}_ue' file
#     Set NSA UEs Pos
#     Attach '${UE_NUM}' NSA UE and data buffer sent
#     Wait '10s' for stable
#     run keyword and continue on failure   Check NSA UE throughput
#     Wait '10s' for stable
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti_NSA_${UE_NUM}_ue'
#     run keyword and continue on failure    check TP and bler with ttitrace   300    1    tti_NSA_${UE_NUM}_ue   8701_case02_pair_check_NSA
#     Wait '10s' for stable
#     run keyword and continue on failure    Get 8701 counter
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'bip_NSA_${UE_NUM}_ue'
#     Airphone NSA Stop Data Traffic And Detach UE
#     Stop capture gnb and ap syslog in 'NSA_${UE_NUM}_ue' file
# 
# Attach '${UE_NUM}' SA UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${num} ------
#     \   Airphone SA Attach    ue_id=${num}
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id=${num}    type=internal
#     \   Airphone Pdu Session Setup   ue_id=${num}    pdu_id=${num}   nwslice_id=1    gw_id=${num}
#     \   SA send mutiple trf dl data    ${num}    1   100    ${num}
#     \   Wait '3s' for stable
# #    \   Collect AP egate log    ${EGATE_TAG}_${num}
# #    \   run keyword and continue on failure     check_SRS_resource_and_PDSCH_scramblingID_SA   ${EGATE_TAG}_${num}
# 
# Check mupair in ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Internal send DL data
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    SA send mutiple trf dl data    ${num}    5    175M    pdu_id=${num}
#     \    SA send mutiple trf ul data    ${num}    2   20M    ${num}
#     \    Wait '3s ' to stable
# 
# Wait '${time} ' to stable
#     sleep    ${time}
# 
# Detach SA UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    airphone_sa_detach    ue_id=${num}
#     \    Wait '3s' for stabible
# 
# 
# Check rrc log
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate    unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_peridicSRS_case1.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate
# 
# Modify 8701 Swconfig
#     Add GNB swconfig    @{Rdparameter}
# 
# Set SA UEs Pos
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${PROFILE4}
#     airphone_execute_egate_command    ${SET_UE1_SA}
#     airphone_execute_egate_command    ${SET_UE2_SA}
#     airphone_execute_egate_command    ${SET_UE3_SA}
#     airphone_execute_egate_command    ${SET_UE4_SA}
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=130 sinr_target_pucch\=-300 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-4 testmode\=ul_sinr action\=activate profile_id\=5
# 
# Set NSA UEs Pos
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${PROFILE4}
#     airphone_execute_egate_command    ${SET_UE41_NSA}
#     airphone_execute_egate_command    ${SET_UE42_NSA}
#     airphone_execute_egate_command    ${SET_UE43_NSA}
#     airphone_execute_egate_command    ${SET_UE44_NSA}
# #    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=130 sinr_target_pucch\=-300 noise_srs\=-1053
# #    airphone_execute_egate_command    ue_testmode_set_nr id\=41-44 testmode\=ul_sinr action\=activate profile_id\=5
# 
# Attach '${UE_NUM}' NSA UE and data buffer sent
#     : FOR    ${num}    IN RANGE    41    ${UE_NUM}+41
#     \   airphone_cleanup_egate_console_log
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   Wait '3s' for stabible
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
#     \   run keyword and continue on failure     check_SRS_resource_and_PDSCH_scramblingID   ${EGATE_TAG}_${num}
#     \   NSA send ue '${num}' mutiple trf '5' for each '175M' DL data
#     \   NSA send ue '${num}' mutiple trf '2' for each '20M' UL data
# 
# check_SRS_resource_and_PDSCH_scramblingID
#     [Arguments]    ${EGATE_TAG}
#     check_log_with_au2anlysis    ${CURDIR}/ini/check_SRS_resource_and_PDSCH_scramblingID_8701_case02.ini    p
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# 
# check TP and bler with ttitrace
#     [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/
# 
# Airphone NSA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    41    ${UE_NUM}+41
#     \    Airphone NSA Stop Data Traffic   ${num}    BI
#     \    Airphone NSA Detach    ${num}
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti
# 
# 
# check_SRS_resource_and_PDSCH_scramblingID_SA
#     [Arguments]    ${EGATE_TAG}
#     check_log_with_au2anlysis    ${CURDIR}/ini/check_SRS_resource_and_PDSCH_scramblingID_8701_case02.ini    p
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify '${UE_NUM}' SA UEs throughput
# 
# Verify '${UE_NUM}' SA UEs throughput
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#     \    run keyword and continue on failure     should_be_true    ${dl_throughput_pcell}>550000
#     \    log to console    downlink result UE${num} is ${dl_throughput_pcell} UE target 550000
#     \    log to console    uplink result UE${num} is ${ul_throughput_pcell}
# 
# Check NSA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi NSA UEs throughput
# 
# Verify multi NSA UEs throughput
#     ${ue_TP}   create list
#     : FOR    ${num}    IN RANGE    41    ${UE_NUM}+41
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pusch    tput_type=ave
#     \    run keyword and continue on failure    should_be_true    ${dl_throughput_pcell}>370000    #400000
#     \    append to list    ${ue_TP}    ${dl_throughput_pcell}
#     \    log to console    ${ue_TP}
# 
# Get 8701 counter
#     log to console    ${\n}---capture counter start---
#     Wait '40s' for stable
#     ${PRB_DL_SU_MIMO_LAYER_list}   create list
#     ${PRB_DL_MU_MIMO_LAYER_list}   create list
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     log to console    counter remianing time is ${remaining_time}
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
#     : FOR    ${num}    IN RANGE    1    5
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C3400${num}    cell_id=1
#     \    set suite variable     ${PRB_DL_SU_MIMO_${num}LAYER}     ${result}
#     \    append to list    ${PRB_DL_SU_MIMO_LAYER_list}    ${PRB_DL_SU_MIMO_${num}LAYER}
#     \    log to console    ${PRB_DL_SU_MIMO_LAYER_list}
#     : FOR    ${num}    IN RANGE    5    10
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C3400${num}    cell_id=1
#     \    ${num_layer}   evaluate   ${num}-3
#     \    set suite variable     ${PRB_DL_MU_MIMO_${num_layer}LAYER}     ${result}
#     \    append to list    ${PRB_DL_MU_MIMO_LAYER_list}    ${PRB_DL_MU_MIMO_${num_layer}LAYER}
#     \    log to console    ${PRB_DL_MU_MIMO_LAYER_list}
#     : FOR    ${num}    IN RANGE    10    12
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C340${num}    cell_id=1
#     \    ${num_layer}   evaluate   ${num}-3
#     \    set suite variable     ${PRB_DL_MU_MIMO_${num_layer}LAYER}     ${result}
#     \    append to list    ${PRB_DL_MU_MIMO_LAYER_list}    ${PRB_DL_MU_MIMO_${num_layer}LAYER}
#     \    log to console    ${PRB_DL_MU_MIMO_LAYER_list}
#     : FOR    ${num}    IN RANGE    16    24
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C340${num}    cell_id=1
#     \    ${num_layer}   evaluate   ${num}-7
#     \    set suite variable     ${PRB_DL_MU_MIMO_${num_layer}LAYER}     ${result}
#     \    log to console    ${PRB_DL_MU_MIMO_${num_layer}LAYER}
#     \    append to list    ${PRB_DL_MU_MIMO_LAYER_list}    ${PRB_DL_MU_MIMO_${num_layer}LAYER}
#     \    log to console    ${PRB_DL_MU_MIMO_LAYER_list}
#     log to console    SUlayer 1_2_3_4 ${PRB_DL_SU_MIMO_LAYER_list}
#     log to console    MUlayer 2_3_4_5_6_7_8_9_10_11_12_13_14_15_16 ${PRB_DL_MU_MIMO_LAYER_list}
# 
#     ${MAC_DTCH_CELL_THP_DL_MAX}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55309C12001    cell_id=1
#     ${Cell1_TP_total}    evaluate    ${MAC_DTCH_CELL_THP_DL_MAX}*8/1024/1024
#     log to console    Cell1_TP_total is ${Cell1_TP_total}