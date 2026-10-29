# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Case Test Teardown
# Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS23R1
# ...   SBTS23R2
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_A_B4a_case05_LOAPLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_8360_A_b4a_case05_LOAPLO.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${WTS_NAME}    wts_8360_A_b4a_case05_LOAPLO.cfg
# ${BIP_TAG}    srs
# ${X2_CMD}         enb_x2_link_up enb\=1 target\=2
# ${ue_id_1}    1
# ${ue_id_2}    2
# @{Rdparameter}
#     ...    0x580550:7
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=2 trigger_puxch_update\=0
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=3 trigger_puxch_update\=0
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 step\=4 trigger_puxch_update\=0
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=12 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# 
# *** Test Cases ***
# CB008360_A_B4a_case05_4_rank1_SA_and_NSA_Ues_paired_without_power_limit
#     [Documentation]
#     ...    this UE1's Coma value
#     #Prepare test
#     Get and Update BSR File    par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Prepare gnb onair
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
# 
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    ${ue_id_1}    PDU_ID=${ue_id_1}    GW_ID=${ue_id_1}
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     SA send ue '1' mutiple trf '1' for each '70M' UL data
#     run keyword and continue on failure    check SA UE'1' dl tput range is '0' to '100' and ul tput range is '52' to '54'
#     ${rnti} =    Get SA 'UE1' crnti in RRC log
#     Set test Variable    ${rnti_1}    ${rnti}
#     airphone_cleanup_egate_console_log
# 
#     Attach one NSA UE'11'
#     Airphone Execute Egate Command    ${PROFILE3}
#     Airphone Execute Egate Command    ${SET_PROFILE3}
#     NSA send ue '11' mutiple trf '1' for each '70M' UL data
#     run keyword and continue on failure    check SA UE'1' dl tput range is '0' to '100' and ul tput range is '52' to '54'
#     run keyword and continue on failure    check NSA UE'11' dl tput range is '0' to '100' and ul tput range is '52' to '54'
#     run keyword and continue on failure    Start collect ttitrace
#     run keyword and continue on failure    Wait for '2s' to stop ttitrace with name'tti2_2ue'
#     ${rnti} =    Get NSA 'UE11' crnti in RRC log
#     Set test Variable    ${rnti_2}    ${rnti}
#     Check 2ue bler and pair ratio in tti tti2_2ue_ul.csv
# 
#     airphone_cleanup_egate_console_log
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    ${ue_id_2}    PDU_ID=${ue_id_2}    GW_ID=${ue_id_2}
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}
#     SA send ue '2' mutiple trf '1' for each '70M' UL data
#     ${rnti} =    Get SA 'UE2' crnti in RRC log
#     Set test Variable    ${rnti_3}    ${rnti}
# 
#     airphone_cleanup_egate_console_log
#     Attach one NSA UE'12'
#     Airphone Execute Egate Command    ${PROFILE4}
#     Airphone Execute Egate Command    ${SET_PROFILE4}
#     NSA send ue '12' mutiple trf '1' for each '70M' UL data
#     run keyword and continue on failure    check SA UE'1' dl tput range is '0' to '100' and ul tput range is '25' to '30'
#     run keyword and continue on failure    check SA UE'2' dl tput range is '0' to '100' and ul tput range is '25' to '30'
#     run keyword and continue on failure    check NSA UE'11' dl tput range is '0' to '100' and ul tput range is '25' to '30'
#     run keyword and continue on failure    check NSA UE'12' dl tput range is '0' to '100' and ul tput range is '25' to '30'
#     run keyword and continue on failure    Start collect ttitrace
#     run keyword and continue on failure    Wait for '4s' to stop ttitrace with name'tti3_4ue'
#     Check 4ue bler and pair ratio in tti tti3_4ue_ul.csv
#     ${rnti} =    Get NSA 'UE12' crnti in RRC log
#     Set test Variable    ${rnti_4}    ${rnti}
# 
#     Detach SA UE'2'
#     Airphone NSA Detach    12
#     run keyword and continue on failure    Start collect ttitrace
#     run keyword and continue on failure    Wait for '4s' to stop ttitrace with name'tti4_nsa_2ue'
#     Set test Variable    ${rnti_2}    ${rnti_4}
#     Check 2ue bler and pair ratio in tti tti4_nsa_2ue_ul.csv
#     Detach SA UE'1'
#     Airphone NSA Detach    11
# 
# 
# *** Keywords ***
# Prepare test
#     Active GNB L2 feature debug traces
#     Add GNB swconfig    @{Rdparameter}
# 
# Set ue position
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Wait '2s' for stabible
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}
#     Wait '2s' for stabible
#     Airphone Execute Egate Command    ${PROFILE3}
#     Airphone Execute Egate Command    ${SET_PROFILE3}
#     Wait '2s' for stabible
#     Airphone Execute Egate Command    ${PROFILE4}
#     Airphone Execute Egate Command    ${SET_PROFILE4}
#     Wait '2s' for stabible
# 
# Prepare X2 link
#     #airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    ${X2_CMD}
# 
# Detach SA UE'${UE_ID}'
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 
# Attach one NSA UE'${ue_id}'
#     #airphone_cleanup_egate_console_log
#     Log To Console   ${\n}-----Attach NSA UE ${ue_id} ------
#     Airphone Nsa Attach    ${ue_id}     profile_id=None
# 
# SA UE'${ue_id}' send '${dl_data_size}' with trf num'${dl_trf_num}' dl data and '${ul_data_size}' with trf num'${ul_trf_num'} ul data
#     SA send mutiple trf dl data    ${ue_id}    number='${ul_data_size}'   ul_data=${dl_data_size}    pdu_id=${ue_id}
#     SA send mutiple trf ul data    ${ue_id}    number='${ul_data_size}'   ul_data=${ul_data_size}    pdu_id=${ue_id}
# 
# SA send ue '${ue_id}' mutiple trf '${number}' for each '${ul_data}' UL data
#     SA send mutiple trf ul data    ${ue_id}    number=${number}   ul_data=${ul_data}    pdu_id=${ue_id}
#     Wait Throughput Timer    10s
# 
# NSA UE'${ue_id}' send '${dl_data_size}' with trf num'${dl_trf_num}' dl data and '${ul_data_size}' with trf num'${ul_trf_num'} ul data
#    NSA send ue '${ue_id}' mutiple trf '${dl_trf_num}' for each '${dl_data_size}' DL data
#    NSA send ue '${ue_id}' mutiple trf '${ul_trf_num}' for each '${ul_data_size}' UL data
# 
# collect ‘${tti_duration}' ttitrace with name'${tti_tag}'
#     Start collect ttitrace
#     Wait for '${tti_duration}' to stop ttitrace with name'${tti_tag}'
# 
# Multi UE NSA Attach with start ue id '${start_ue_id}' and ue num '${NSA_UE_NUM}'
#     : FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${NSA_UE_NUM}+1
# 
#     #\   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${ue_id} ------
# 
#     \   Airphone Nsa Attach    ${ue_id}
#     \    SA send dl and ul data    ${ue_id}    number=3    dl_data=175M    ul_data=20M    pdu_id=${ue_id}
#     \    Wait '3s' for stabible
# 
# Attach one SA UE'${ue_id}'
#     Log To Console   ${\n}-----register SA UE ${ue_id} ------
#     Attach SA ue to 5g cell    SRS_Ports_PerResource2    ${ue_id}    PDU_ID=${ue_id}    GW_ID=${ue_id}
# 
# 
# check SA UE'${ue_id}' dl tput range is '${dl_low_Mb}' to '${dl_high_Mb}' and ul tput range is '${ul_low_Mb}' to '${ul_high_Mb}'
#     Log To Console    ..Check throughput UE${ue_id}
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${ue_id}   pdu_id= ${ue_id}
#     ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console    dl ${dl_tput_Mb}
#     Log To Console    ul ${ul_tput_Mb}
#     should be true    ${dl_tput_Mb}>=${dl_low_Mb}
#     should be true    ${ul_tput_Mb}>=${ul_low_Mb}
# 
# check NSA UE'${UE_ID}' dl tput range is '${dl_low_Mb}' to '${dl_high_Mb}' and ul tput range is '${ul_low_Mb}' to '${ul_high_Mb}'
#     Wait '10s' for stabible
#     Log To Console    ..Check throughput UE${UE_ID}
#     ${dl_pcell_kb}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${ul_pcell_kb}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pusch    tput_type=ave
#     ${dl_tput_Mb}    evaluate    ${dl_pcell_kb}/1000
#     ${ul_tput_Mb}    evaluate    ${ul_pcell_kb}/1000
#     Log To Console    dl ${dl_tput_Mb}
#     Log To Console    ul ${ul_tput_Mb}
#     should be true    ${dl_tput_Mb}>=${dl_low_Mb}
#     should be true    ${ul_tput_Mb}>=${ul_low_Mb}
# 
# check ue ${ue_id} ${dl_tput} range is ${dl_low} to ${dl_high} ${ul_tput} range is ${ul_low} to ${ul_high}
#     log to console    start to check throughput ${ue_id}
#     should be true    ${dl_tput}>${dl_low}
#     should be true    ${dl_tput}<${dl_high}
#     should be true    ${ul_tput}>${ul_low}
#     should be true    ${ul_tput}<${ul_high}
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}
# 
# 
# Check 2ue bler and pair ratio in tti ${tti_tag}
#     Log To Console   ---check tti ---${\n}
#     Set test Variable    ${tti_title_tag}    ${tti_tag}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_A_B4a_case05_2ue_ul.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check 3ue bler and pair ratio in tti ${tti_tag}
#     Log To Console   ---check tti ---${\n}
#     Set test Variable    ${tti_title_tag}    ${tti_tag}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_A_B4a_case05_3ue_ul.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check 4ue bler and pair ratio in tti ${tti_tag}
#     Log To Console   ---check tti ---${\n}
#     Set test Variable    ${tti_title_tag}    ${tti_tag}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_A_B4a_case05_4ue_ul.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Get SA '${ue_id}' crnti in RRC log
#     Log To Console   check UE RRC log to get all ue crnti
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001   crnti: (\\d+)
#     [return]     ${rnti_list[0]}
# 
# Get NSA '${ue_id}' crnti in RRC log
#     Log To Console   check UE RRC log to get all ue crnti
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001   newUE-Identity (\\d+)
#     [return]     ${rnti_list[0]}
# 
# Case Test Teardown
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     Common Test Teardown