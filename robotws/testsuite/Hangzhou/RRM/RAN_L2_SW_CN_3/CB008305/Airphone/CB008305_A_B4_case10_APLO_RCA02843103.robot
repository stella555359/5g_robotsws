# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00   SBTS23R1   RAN_5G_TDD    RAN_5G   AP    owner_changyli
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Test Timeout      60 minutes
# Resource          ../../resources/KISS/robot/common_resource.robot
# Resource          ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# #${SCFC_NAME}      SCFC_8305_case10_aplo.xml
# ${SCFC_NAME}      SCFC_8305_case10_qam64_aplo_RCA.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_1CELL.xml
# ${L1BYP_XML}      L1ByPTestModeConfiguration_case10.xml
# ${WTS_NAME}       wts_case10_aplo.cfg
# ${UE_ID1}         1
# ${UE_ID2}         2
# ${UE_ID3}         3
# ${UE_ID4}         4
# ${GW_ID1}         1
# ${GW_ID2}         2
# ${PDU_ID}         1
# ${SLICE_ID}       1
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${COMAVALUE}    ${CURDIR}/coma/8305.txt
# 
# *** Test Cases ***
# CB008305_A_B4_case10_rank1_Ue_paire_with_rank4_Ue_and_SCID_and_power_check_qam64
#     Prepare on air and case check
# 
# CB008305_A_B4_case10_rank1_Ue_paire_with_rank4_Ue_and_SCID_and_power_check_qam256
#    ${SCFC_NAME}      set variable    SCFC_8305_case10_qam256_aplo_RCA.xml
#    set test variable    ${SCFC_NAME}
# 
#    Prepare on air and case check
# 
# *** Keywords ***
# Prepare on air and case check
#     Modify Swconfig
#     Prepare gnb onair
#     run keyword and continue on failure    Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     UE attach and add bler'1'
# 
#     ${KPI_value_disable}    Get NR_5108d counter
#     log to console   dlmumimo disable KPI=${KPI_value_disable}
#     Detach SA UE    ${UE_ID1}
#     Detach SA UE    ${UE_ID2}
#     Online change actDlMuMimoEnh enabled
#     UE attach and add bler'2'
#     ${KPI_value_enable}    Get NR_5108d counter
#     log to console   dlmumimo enable KPI=${KPI_value_enable}
# 
#     should be true    ${KPI_value_disable}<=${KPI_value_enable}
# 
#     Detach SA UE    ${UE_ID1}
#     Detach SA UE    ${UE_ID2}
# 
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# UE attach and add bler'${num}'
#     Set '2' UE different pos
#     UE SA Attach    ${UE_ID1}
#     UE SA Attach    ${UE_ID2}
# #    run keyword and continue on failure    Check rrc log
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=0
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2
#     Send DL data to UE and check throughput
# 
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=3 dl_bler\=95,2,3,4
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler action\=activate profile_id\=3
#     wait '20s' for stable
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti_${num}'
# 
# Set '${UE_NUM}' UE different pos
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=${num} init_pos\=${num} srsMode\=fixed
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ue_srs_beam_pos action\=activate profile_id\=${num}
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=7 sinr_target_srs\=100 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=7
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=7
# 
# 
# Set UEs close pos
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=3 init_pos\=2 srsMode\=fixed
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=4 init_pos\=3 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ue_srs_beam_pos action\=activate profile_id\=4
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=7 sinr_target_srs\=100 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=7
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=7
# 
# UE SA Attach
#     [Arguments]    ${UE_ID}
#     airphone_cleanup_egate_console_log
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Set Traffic Type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${UE_ID}
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
# Send DL data to UE and check throughput
#     SA send mutiple trf dl data    ${UE_ID1}    2   175M
#     SA send mutiple trf dl data    ${UE_ID2}    8    175M
# #    SA send mutiple trf dl data    ${UE_ID1}    2   175M    1    tcp
# #    SA send mutiple trf dl data    ${UE_ID2}    7    175M    1    tcp
#     Wait '20s ' to stable
#     Check throughput
# 
# Detach SA UE
#     [Arguments]    ${UE_ID}
#     airphone_sa_detach    ue_id=${UE_ID}
# 
# 
# Check mupair in ttitrace
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_mu_case10.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Check rrc log
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate    unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/rrc_case10_mu.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate
# 
# Verify throughput
#     ${dl_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0
#     ...    type=pdsch    tput_type=ave
#     ${dl_throughput_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0
#     ...    type=pdsch    tput_type=ave
#     log to console    dl_throughput_ue1=${dl_throughput_ue1}
#     log to console    dl_throughput_ue2=${dl_throughput_ue2}
# #    should_be_true    ${dl_throughput_ue1}>250000
# #    should_be_true    ${dl_throughput_ue2}>900000
# 
# Send DL data to UE and check throughput-2
#     SA send mutiple trf dl data    ${UE_ID1}    2    175M
#     SA send mutiple trf dl data    ${UE_ID2}    8    175M
#     Wait '20s ' to stable
#     Check throughput-2
# 
# Check throughput-2
#     Wait until keyword succeeds    60s    5s    Verify throughput-2
# 
# Verify throughput-2
#     ${dl_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0
#     ...    type=pdsch    tput_type=ave
#     ${dl_throughput_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0
#     ...    type=pdsch    tput_type=ave
#     log to console    dl_throughput_ue1=${dl_throughput_ue1}
#     log to console    dl_throughput_ue2=${dl_throughput_ue2}
# #    should_be_true    ${dl_throughput_ue1}>120000
# #    should_be_true    ${dl_throughput_ue2}>500000
# #
# Check su in ttitrace
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_su_case10.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Modify Swconfig
# #    Add GNB swconfig    0x340000:3
#     Add GNB swconfig    0x340000:15
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
#     Perform online change value    MRBTS-1/NRBTS-2/NRCELL-1    actDlMuMimoEnh    true    online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '60s' for stable
