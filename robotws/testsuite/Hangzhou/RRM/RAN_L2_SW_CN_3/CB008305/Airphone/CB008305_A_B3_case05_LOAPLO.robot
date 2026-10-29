# *** Settings ***
# Suite Setup    Common Suite Setup
# #Suite Teardown  Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# Force Tags        CRT    SBTS00   SBTS23R1   RAN_5G_TDD    RAN_5G   owner_l3gao
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  DL_mumimo
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# Documentation
# ...     check 0 5 10 15 20 five SE
# ...     owner_l3gao
# ...     check DMRS enable
# ...     check bler and retransmission
# ...     ptrs off /srs power reduced
# ...     tapering enable dueo default
# ...     PR674081
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID1}          1
# ${UE_ID2}          2
# ${SCFC_NAME}     SCFC_8305_case05_APLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_2CELL_APLO_8DL4UL.xml
# ${WTS_NAME}      WTS_SANSA_n78_8SA_32NSA_8DL4UL_2CELL_MU_APLO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog    sosreport
# @{Rdparameter}    0x340000:15  0x580542:0   #0x580264:03
# ${UE_NUM}  2
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='false'
# ...    L2HI_MIRRORING='false'   L2RT_MIRRORING='false'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
# ${SE_threshold}   20    #20 default   0 for ivan case
# ${par_of_bsr_name}       AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
# 
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=40 srs_transmit_power_per_port\=-300,-300,-280,-280
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-0 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-280,-280
# 
# 
# *** Test Cases ***
# CB008305_A_B3_case05_two_rank2_Ues_paired_with_SE checking_based2200
#     gnb prepare
#     Set 2UE different DOA and enhence SRS power
#     Attach '${UE_NUM}' SA UEs
#     Data buffer send to '${UE_NUM}' SA UE
#     Wait '20s' for stable
#     run keyword and continue on failure    Fix 2UE to rank2
#     run keyword and continue on failure    Online change SE and check    throughput=310    #330
#     DeRegister ‘${UE_NUM}’ SA UEs
#     run keyword and continue on failure    online change modulation and check    256qam
#     DeRegister ‘${UE_NUM}’ SA UEs
# 
# *** Keywords ***
# Attach '${UE_NUM}' SA UEs
# #    Create SRS_pos profile
#     Start capture gnb and ap syslog in 'SA_${UE_NUM}_ue_rrc' file
#     Start collect 'attach_f1ap_logs' tcpdump
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${num} ------
#     \   Airphone SA Attach    ue_id=${num}
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id=${num}    type=internal
#     \   Airphone Pdu Session Setup   ue_id=${num}    pdu_id=${num}   nwslice_id=1    gw_id=${num}
#     \   Wait '3s' for stabible
#     \   Collect AP egate log    UE_${num}_rrc
#     \   run keyword and continue on failure     Check_rrc   UE_${num}_rrc
#     Stop collect 'attach_f1ap_logs' tcpdump
#     Stop capture gnb and ap syslog in 'SA_${UE_NUM}_ue_rrc' file
# #    set '${UE_NUM}' SA UEs Pos
# 
# Create SRS_pos profile
#     : FOR    ${num}    IN RANGE    2    ${UE_NUM}+2
#     \    airphone_execute_egate_command    ${PROFILE${num}}
# 
# set '${UE_NUM}' SA UEs Pos
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${num_r}    evaluate    ${num}+1
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num_r}
# 
# gnb prepare
#     Get and Update BSR File    ${par_of_bsr_name}
#     Add GNB swconfig    @{Rdparameter}
# #    Active GNB L2 feature debug traces
#     Prepare gnb onair
# 
# Set 2UE different DOA and enhence SRS power
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=1 init_pos\=0 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=1
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=2 init_pos\=2 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ue_srs_beam_pos action\=activate profile_id\=2
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=100 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=5
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=5
# 
# online change modulation and check
#     [Arguments]    ${DMRS_tag}
#     Online recommissioning with delta json file   ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_8305_${DMRS_tag}.json
#     Set 2UE different DOA and enhence SRS power
#     Attach '${UE_NUM}' SA UEs
#     Data buffer send to '${UE_NUM}' SA UE
#     Wait '20s' for stable
#     run keyword and continue on failure    Fix 2UE to rank2
#     Wait '20s' for stable
#     Wait until keyword succeeds    48s    8s     Check ue tput is correct    410
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti_${DMRS_tag}_enable'
#     run keyword and continue on failure    check TP and bler with ttitrace   410    1
#     ...    tti_${DMRS_tag}_enable   8305_case05_ttitrace_TP
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=2 dl_bler\=10,2,3,4,5   #add bler
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=2 action\=activate
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=2 action\=activate
#     Wait '20s' for stable
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'tti_${DMRS_tag}_enable_addBler'
#     Wait '5s' for stable
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti_${DMRS_tag}_enable_addBler'
#     run keyword and continue on failure    check TP and bler with ttitrace   370    1
#     ...    tti_${DMRS_tag}_enable_addBler   8305_case05_ttitrace_TP_Bler
#     Wait '10s' for stable
#     Wait until keyword succeeds    48s    8s     Check ue tput is correct    370
# 
# 
# 
# 
# DeRegister ‘${UE_NUM}’ SA UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   Airphone SA Stop Data Traffic     ${num}     BI    ${num}
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '2s' for stabible
# 
# Data buffer send to '${UE_NUM}' SA UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   SA send mutiple trf dl data    ${num}    5   150M    ${num}
#     \   SA send mutiple trf ul data    ${num}    3   20M    ${num}
# 
# Check_rrc
#     [Arguments]    ${EGATE_TAG}
#     check_log_with_au2anlysis    ${CURDIR}/ini/8305_SA_RRC_2200.ini    p
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Fix 2UE to rank2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=1
# 
# Online change SE and check
#     [Arguments]    ${throughput}
#     Start capture gnb and ap syslog in 'online_change_se' file
#     : FOR    ${se_ret}    IN RANGE    ${SE_threshold}    -5    -5     #check 0 5 10 15 20 five SE
#     \    log to console  check SE_${se_ret}
#     \    set global variable    ${se_ret}
#     \    ${se}    Convert To Integer   ${se_ret}
#     \    Online recommissioning with delta json file   ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_8305_case05_SE_${se}_APLO.json
#     \    Wait '30s' for stable
#     \    ${throughput_re}   evaluate   ${throughput}-30
#     \    Start collect ttitrace
#     \    Wait for '2s' to stop ttitrace with name'tti_se${se}'
#     \    Start collect bip log
#     \    Wait for '1s' to stop bip log with name'bip_se${se}'
#     \    run keyword if  ${se}>14   check TP and bler with ttitrace   ${throughput_re}/2    1    tti_se${se}   8305_case05_ttitrace_TP_SE2
#     \    run keyword if  ${se}<16    check TP and bler with ttitrace   ${throughput_re}    1    tti_se${se}   8305_case05_ttitrace_TP
#     \    Wait '10s' for stable
#     \    run keyword if  ${se}>14    Wait until keyword succeeds    48s    8s     Check ue tput is correct    ${throughput}/2
#     \    run keyword if  ${se}<16    Wait until keyword succeeds    48s    8s     Check ue tput is correct    ${throughput}
#     Stop capture gnb and ap syslog in 'online_change_se' file
# 
# 
# Check ue tput is correct
#     [Arguments]    ${throughput}
#     ${dl_tput1}    airphone_get_throughput_on_specific_scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tput2}    airphone_get_throughput_on_specific_scell    ue_id=2    scell_id=0    type=pdsch    tput_type=ave
#     should be true    (${dl_tput1}/1000)>${throughput}
#     should be true    (${dl_tput2}/1000)>${throughput}
#     log to console  UE TP result ${dl_tput1} and ${dl_tput2}
# 
# check TP and bler with ttitrace
#     [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}
#     ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
#     ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
#     @{keys}  Get Dictionary Keys   ${a}
#     : FOR      ${key}     IN     @{keys}
#     \    ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
#     \    log to console   actually TP is ${result}
#     \    log to console   target result TP is ${throughput}
#     \    should be true  ${result}>${throughput}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti
