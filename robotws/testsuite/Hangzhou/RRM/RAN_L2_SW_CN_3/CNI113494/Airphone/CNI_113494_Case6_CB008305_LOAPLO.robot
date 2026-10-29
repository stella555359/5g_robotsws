# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    owner_changyli   AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1    AP_REG
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# Resource    ${CURDIR}/Check_CNI113494_iBler.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}     SCFC_8701_case09_aplo.xml
# ${AIRPHONE_NAME}    IPHY_AEHC_1CELL_APLO.xml
# ${WTS_NAME}    wts_aehc_8701_case09_aplo.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${UE_NUM_SA}         2
# ${UE_NUM_NSA}         6
# ${EGATE_TAG}      MUmimo
# ${BIP_TAG}    mumumo_bip
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
# ...    NUMBER_OF_FILES=30
# @{Rdparameter}    0x420062:1  0x800057:0
# ${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60
# #${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# #${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# #${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# #${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# #${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# #${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# #${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# #${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-50 zenith\=-30 srs_transmit_power_per_port\=-450,-450,-280,-280
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=60 zenith\=40 srs_transmit_power_per_port\=-450,-450,-280,-280   
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=40 zenith\=-30 srs_transmit_power_per_port\=-450,-450,-280,-280
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=40 srs_transmit_power_per_port\=-450,-450,-280,-280
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=-30 srs_transmit_power_per_port\=-450,-450,-280,-280
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=40 srs_transmit_power_per_port\=-450,-450,-280,-280
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=-30 srs_transmit_power_per_port\=-450,-450,-280,-280
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-35 zenith\=40 srs_transmit_power_per_port\=-450,-450,-280,-280
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=12 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=13 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=14 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=15 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE6}    ue_testmode_set_nr id\=16 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# ${SET_PROFILE7}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
# ${SET_PROFILE8}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
# 
# 
# *** Test Cases ***
# CNI_113494_Case6_PDSCH_iBLER_counters_for_tapered_2D-DFT_beams_CB008305
#     Modify 8701 Swconfig
#     #Active GNB L2 feature debug traces
#     Get and Update BSR File    ${par_of_bsr_name}
#     Prepare gnb onair
#     Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'SA_NSA_ue' file
# #    Set 8UEs different pos
#     Attach '${UE_NUM_NSA}' NSA UE
#     Attach '${UE_NUM_SA}' SA UE
#     Set 8UEs different pos
#     SA Start DL Data Traffic
#     NSA Start DL Data Traffic
#     UE send RANK2
#     Wait '20s' for stable
#     #Start collect bip log
#    # Wait for '1s' to stop bip log with name'${BIP_TAG}'
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti'
#     run keyword and continue on failure    Check PM_counter
#     Airphone SA Stop Data Traffic And Detach UE
#     Airphone NSA Stop Data Traffic And Detach UE
#     Stop capture gnb and ap syslog in 'SA_NSA_ue' file
# 
# *** Keywords ***
# Check UE '${num}' rrc log peridic
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}    unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_peridicSRS.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}
#    
# Check UE '${num}' rrc log AperidicSRS
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}    unzip=TRUE
# 	${ret}     file match all       ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}/egate_console.log         .*crnti: (\\d+)
#     set suite variable     ${ue_rnti}    ${ret[0]}
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_AperidicSRS_SA.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}
# 
# Check mupair in ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case13_1.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# Check PM_counter
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}PM_check2
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${save_log}${/}
# 	Check_CNI113494_iBler_match_Legacy_counters_1cell    ${PM_counter_file}
# 
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex13}    ${Vindex7}    ${Hindex13}    ${Vindex7}
#     ...    ${Hindex10}    ${Vindex8}    ${Hindex10}    ${Vindex8}
#     ...    ${Hindex6}    ${Vindex7}    ${Hindex6}    ${Vindex7}
#     ...    ${Hindex2}    ${Vindex8}    ${Hindex2}    ${Vindex8}
#     ...    ${Hindex25}    ${Vindex7}    ${Hindex25}    ${Vindex7}
#     ...    ${Hindex21}    ${Vindex8}     ${Hindex21}    ${Vindex8}
#     ...    ${Hindex17}    ${Vindex7}     ${Hindex17}    ${Vindex7}
#     ...    ${Hindex14}    ${Vindex8}     ${Hindex14}    ${Vindex8}
# 
# check TP and bler with ttitrace
#     [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}
#     ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
#     ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
#     @{keys}  Get Dictionary Keys   ${a}
#     : FOR      ${key}     IN     @{keys}
#     \    ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
#     \    log to console   result is ${result}
#     \    log to console   TP is ${throughput}
#     \    should be true  ${result}>${throughput}
# #    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
# #    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case10.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Modify 8701 Swconfig
# 	Add GNB swconfig    0x9D0000:1
# 
# Attach NSA 8 UEs
#     : FOR    ${num}    IN RANGE    11    ${UE_NUM}+1
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   Wait '10s' for stable
# 
# NSA send data 8 UEs
#     : FOR    ${num}    IN RANGE    11    ${UE_NUM}+1
#     \   NSA send ue '${num}' mutiple trf '1' for each '150M' DL data
#     \   NSA send ue '${num}' mutiple trf '2' for each '150M' DL data
#     \   NSA send ue '${num}' mutiple trf '1' for each '30M' UL data
# 
# Check NSA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi NSA UEs throughput
# 
# 
# Verify multi NSA UEs throughput
#     : FOR    ${num}    IN RANGE    11    16+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>20000
# 
# 
# Check SA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput
# 
# Verify multi SA UEs throughput
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>20000
# 
# 
# Attach '${UE_NUM_NSA}' NSA UE
#     : FOR    ${num}    IN RANGE    11    16+1
#     \   airphone_cleanup_egate_console_log
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   Wait '3s' for stabible
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
# 
# Attach '${UE_NUM_SA}' SA UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   airphone_cleanup_egate_console_log
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \   Wait '3s' for stabible
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
# 
# 
# NSA Start DL Data Traffic
#     : FOR    ${num}    IN RANGE    11    16+1
#     \    NSA send mutiple trf dl data    ${num}    2    155M    tcp
# 
# SA Start DL Data Traffic
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   Airphone SA Start Data Traffic    ${num}    DL    50M    pdu_id=${num}    duration=6000s    trf_id=1   protocol=tcp
# 
# Airphone NSA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    11    16+1
#     \    Airphone NSA Stop Data Traffic   ${num}    DL
#     \    Airphone NSA Detach    ${num}
# 
# Airphone SA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    Airphone SA Stop Data Traffic     ${num}     DL    ${num}
#     \    Airphone SA Detach    ue_id=${num}
# 
# 
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# UE send RANK2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11-16 testmode\=csi_override action\=activate profile_id\=1 scell\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-2 testmode\=csi_override action\=activate profile_id\=1 scell\=0
# 
# Check Srs Resource
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_peridicSRS.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_11_egate   
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_peridicSRS.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_16_egate   
#    ${ret}     file match all       ${TEST_LOG_DIRECTORY()}/All/MUmimo_1_egate/egate_console.log         .*crnti: (\\d+)
#     set suite variable     ${ue_rnti}    ${ret[0]}
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_AperidicSRS_case11.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_1_egate
# 
# Set 8UEs different pos
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${SET_PROFILE1}
#     airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${SET_PROFILE2}
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${SET_PROFILE3}
#     airphone_execute_egate_command    ${PROFILE4}
#     airphone_execute_egate_command    ${SET_PROFILE4}
#     airphone_execute_egate_command    ${PROFILE5}
#     airphone_execute_egate_command    ${SET_PROFILE5}
#     airphone_execute_egate_command    ${PROFILE6}
#     airphone_execute_egate_command    ${SET_PROFILE6}
#     airphone_execute_egate_command    ${PROFILE7}
#     airphone_execute_egate_command    ${SET_PROFILE7}
#     airphone_execute_egate_command    ${PROFILE8}
#     airphone_execute_egate_command    ${SET_PROFILE8}
#     #airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=9 sinr_target_srs\=35 sinr_target_pucch\=-300 noise_srs\=-1053
#     #airphone_execute_egate_command    ue_testmode_set_nr id\=11-16 testmode\=ul_sinr action\=activate profile_id\=9
#     #airphone_execute_egate_command    ue_testmode_set_nr id\=1-2 testmode\=ul_sinr action\=activate profile_id\=9
