# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags    owner_changyli    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Test Timeout      180 minutes
# Resource          ../../resources/KISS/robot/common_resource.robot
# Resource          ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_92510_case05_APLO.xml
# ${AIRPHONE_NAME}    IPHY_AEHC_1CELL_APLO.xml
# ${WTS_NAME}       wts_aehc_92510_case05_aplo.cfg
# ${COMAVALUE}    ${CURDIR}/coma/8701_coma_dft.txt
# ${UE_ID1}         1
# ${UE_ID2}         2
# ${UE_ID3}         3
# ${UE_ID4}         4
# ${UE_ID5}         5
# ${UE_ID6}         6
# ${UE_ID7}         7
# ${UE_ID8}         8
# ${UE_ID9}         9
# ${UE_ID10}         10
# ${GW_ID1}         1
# ${GW_ID2}         2
# ${GW_ID3}         3
# ${GW_ID4}         4
# ${GW_ID5}        5
# ${GW_ID6}         6
# ${GW_ID7}         7
# ${GW_ID8}         8
# ${GW_ID9}         9
# ${GW_ID10}        10
# ${PDU_ID}         1
# ${SLICE_ID}       1
# ${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
# ...    NUMBER_OF_FILES=30
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# ${SET_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
# ${SET_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
# ${SET_PROFILE9}    ue_testmode_set_nr id\=9 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=9
# ${SET_PROFILE10}    ue_testmode_set_nr id\=10 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10
# 
# *** Test Cases ***
# CNI92510_case05_EDA_10UE_DL_pairing_10bler_KPI_NR_5108d_checking_with_CB008701
#    Prepare on air and case check
# 
# CNI92510_case03_EDA_10UE_DL_pairing_10bler_KPI_NR_5108d_checking_with_CB008701_qam256
#    ${SCFC_NAME}      set variable    SCFC_92510_case05_APLO_qam256.xml
#    set test variable    ${SCFC_NAME}
# 
#    Prepare on air and case check
# 
# *** Keywords **
# Prepare on air and case check
#     Get and Update BSR File    ${par_of_bsr_name}
#     Modify Swconfig
#     Prepare gnb onair
#     run keyword and continue on failure    Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     UE attach and add bler'1'
# 
#     ${KPI_value_disable}    Get NR_5108d counter
#     log to console   dlmumimo disable KPI=${KPI_value_disable}
#     Detach SA UEs
# 
#     Online change actDlMuMimoEnh enabled
#     UE attach and add bler'2'
#     ${KPI_value_enable}    Get NR_5108d counter
#     log to console   dlmumimo enable KPI=${KPI_value_enable}
# 
#     should be true    ${KPI_value_disable}<=${KPI_value_enable}
# 
#     Detach SA UEs
# 
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# UE attach and add bler'${num}'
#     Set UE Pos
# 	Attach SA UEs
# 	Fix UE rank
#     run keyword and continue on failure    Send DL data to UE and check throughput
#     Run Keyword If    ${num} == 1     set 64qam bler
#     Run Keyword If    ${num} == 2     set 256qam bler
# 
#     Start collect ttitrace    name=tti_${num}
#     run keyword and continue on failure    Wait for '2s' to stop ttitrace with name'tti_${num}'
# 
#     run keyword and continue on failure    check_cdm_group_and_dmrs_port_by_antenna_port_value    
#    ...    ${TEST_LOG_DIRECTORY()}/All/tti_${num}/tti_dl.csv
# 
# 
# Set UE Pos
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
#     airphone_execute_egate_command    ${PROFILE9}
#     airphone_execute_egate_command    ${SET_PROFILE9}
#     airphone_execute_egate_command    ${PROFILE10}
#     airphone_execute_egate_command    ${SET_PROFILE10}
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=30 sinr_target_srs\=35 sinr_target_pucch\=-300 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-10 testmode\=ul_sinr action\=activate profile_id\=30
# 
# set 64qam bler
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=20 dl_bler\=95,2,3,4
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-2 scell\=0 testmode\=bler action\=activate profile_id\=20
#     airphone_execute_egate_command    ue_testmode_set_nr id\=5-8 scell\=0 testmode\=bler action\=activate profile_id\=20
# #    airphone_execute_egate_command    ue_testmode_set_nr id\=4 scell\=0 testmode\=bler action\=activate profile_id\=20
# #    airphone_execute_egate_command    ue_testmode_set_nr id\=10 scell\=0 testmode\=bler action\=activate profile_id\=20
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=21 dl_bler\=200,100,50
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=22 dl_bler\=150,100
#     airphone_execute_egate_command    ue_testmode_set_nr id\=3 scell\=0 testmode\=bler action\=activate profile_id\=21
#     airphone_execute_egate_command    ue_testmode_set_nr id\=9 scell\=0 testmode\=bler action\=activate profile_id\=22
# 
# 
# set 256qam bler
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=20 dl_bler\=95,2,3,4
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-2 scell\=0 testmode\=bler action\=activate profile_id\=20
#     airphone_execute_egate_command    ue_testmode_set_nr id\=5-8 scell\=0 testmode\=bler action\=activate profile_id\=20
# #    airphone_execute_egate_command    ue_testmode_set_nr id\=4 scell\=0 testmode\=bler action\=activate profile_id\=20
# #    airphone_execute_egate_command    ue_testmode_set_nr id\=10 scell\=0 testmode\=bler action\=activate profile_id\=20
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=21 dl_bler\=300,200,50
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=22 dl_bler\=200,100
#     airphone_execute_egate_command    ue_testmode_set_nr id\=3 scell\=0 testmode\=bler action\=activate profile_id\=21
#     airphone_execute_egate_command    ue_testmode_set_nr id\=9 scell\=0 testmode\=bler action\=activate profile_id\=22
# 
# Internal send DL data
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone SA Start Data Traffic    ${num}    DL    100M    pdu_id=1    duration=6000s
#     \    ...    trf_id=${num}
#     \    Wait '3s ' to stable
# 
# Wait '${time} ' to stable
#     sleep    ${time}
# 
# Send DL data to UE and check throughput-2
#     SEND DL data to 10UE-2
#     Wait '20s ' to stable
#     Check throughput-2
# 
# SEND DL data to 10UE-2
#     : FOR    ${ue_id}    IN RANGE    1    11
# 	\   SEND data to '${ue_id}'
# 	
# SEND data to '${ue_id}'
# 	: FOR    ${num}    IN RANGE    1    2	
# 	\   Airphone SA Start Data Traffic    ${ue_id}    DL    175M    pdu_id=1    duration=6000s    trf_id=${num}   protocol=tcp
# 
# Detach SA UEs
#     : FOR    ${num}    IN RANGE    1    11
#     \    airphone_sa_detach    ue_id=${num}
#     \    Wait '3s' for stabible
# 
# Attach SA UEs
#     : FOR    ${num}    IN RANGE    1    11
#     \    Airphone Set Traffic Type    ${num}    ${PDU_ID}    internal
#     \    Airphone SA Attach    ue_id=${num}
#     \    Airphone Pdu Session Setup    ${num}    ${PDU_ID}    ${SLICE_ID}    ${num}
#     
# Check mupair in ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case20-1.ini    log_need_to_check=i    
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check throughput-2
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Check rrc log
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate    unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/rrc_8305.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate
# 
# Verify throughput-2
#     : FOR    ${num}    IN RANGE    1    11
#     \    ${dl_throughput_ue}=    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    log to console    ${dl_throughput_ue}
#     \    should_be_true    ${dl_throughput_ue}>100000
# 
# Send DL data to UE and check throughput
#     Send DL data to 10UE
#     Wait '20s ' to stable
#     Check throughput
# 
# Send DL data to 10UE
#     airphone_execute_egate_command    trf_data_start ue\=1-10 pdu\=1 dir\=dl trf_id\=1 mbps\=175 seconds\=6000s protocol\=tcp
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Verify throughput
#     : FOR    ${num}    IN RANGE    1    11
#     \    ${dl_throughput_ue}=    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    log to console    ${dl_throughput_ue}
# #    \    should_be_true    ${dl_throughput_ue}>10000
# 
# Check mupair in ttitrace-2
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case20-2.ini    log_need_to_check=i    
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Fix UE rank
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=11 cqi\=15 ri\=0
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=12 cqi\=15 ri\=1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=13 cqi\=15 ri\=2
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-2 testmode\=csi_override action\=activate profile_id\=11
#     airphone_execute_egate_command    ue_testmode_set_nr id\=3-4 testmode\=csi_override action\=activate profile_id\=12
#     airphone_execute_egate_command    ue_testmode_set_nr id\=5-6 testmode\=csi_override action\=activate profile_id\=13
# 
# 
# Modify Swconfig
# 	Add GNB swconfig    0x340000:15
# 	
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode    name=${tti_tag}
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti
# 	
# Get NR_5108d counter
#     Wait '40s' for stable
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     log to console    ${remaining_time}
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
# 
#     # M55304C02000-M55304C02031  All value
#     ${M55304C0200X}    set variable    0
#     : FOR    ${num}    IN RANGE    0    10
#     \    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0200${num}    cell_id=1
#     \    log to console    M55304C0200${num}=${result}
#     \    ${M55304C0200X}    Evaluate    ${M55304C0200X}+${result}
#     log to console    M55304C02000-9=${M55304C0200X}
# 
#     : FOR    ${num}    IN RANGE    10    32
#     \    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C020${num}    cell_id=1
#     \    log to console    M55304C020${num}=${result}
#     \    ${M55304C0200X}    Evaluate    ${M55304C0200X}+${result}
#     log to console    M55304C02000-32=${M55304C0200X}
# 
#     # M55304C06000-M55304C06031 All value
#     ${M55304C0600X}    set variable    0
#     : FOR    ${num}    IN RANGE    0    10
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0600${num}    cell_id=1
#     \    ${M55304C0600X}    Evaluate    ${M55304C0600X}+${result}
#     \    log to console    M55304C0600${num}=${result}
#     log to console    M55304C06000-9=${M55304C0600X}
# 
#     : FOR    ${num}    IN RANGE    10    32
#     \    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C060${num}    cell_id=1
#     \    ${M55304C0600X}    Evaluate    ${M55304C0600X}+${result}
#     \    log to console    M55304C0600${num}=${result}
#     log to console    M55304C06010-31=${M55304C0600X}
# 
# 
#     ${top_counter}    Evaluate    (${M55304C0200X}+${M55304C0600X})*8
#     log to console    top_counter=${top_counter}
# 
#     ${M55308C03005}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C03005    cell_id=1
#     ${M55308C10001}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C10001    cell_id=1
#     ${M55308C00008}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00008    cell_id=1
#     ${M55308C00016}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00016    cell_id=1
#     ${M55308C00018}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00018    cell_id=1
# 
#     log to console    M55308C03005=${M55308C03005}
#     log to console    M55308C10001=${M55308C10001}
#     log to console    M55308C00008=${M55308C00008}
#     log to console    M55308C00016=${M55308C00016}
#     log to console    M55308C00018=${M55308C00018}
# 
#     ${bottom_counter}    Evaluate    ${M55308C03005}*180*(float(${M55308C10001})/(${M55308C00008}+${M55308C00016}+${M55308C00018}))
#     log to console    bottom_counter=${bottom_counter}
# 
#     ${SE_KPI_Value}    Evaluate    float(${top_counter}/${bottom_counter})
#     log to console    SE_KPI_Value=${SE_KPI_Value}
#     [Return]    ${SE_KPI_Value}
# 
# 
# Online change actDlMuMimoEnh enabled
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1    actDlMuMimoEnh    true    online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '60s' for stable
