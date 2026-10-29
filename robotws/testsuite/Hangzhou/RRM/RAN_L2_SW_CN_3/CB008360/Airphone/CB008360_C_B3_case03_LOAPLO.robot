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
# ${SCFC_NAME}      SCFC_8360_C_b3_case03_LOAPLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_1CELL_8D8U_LOAPLO.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${WTS_NAME}    wts_8360_C_b3_case03_LOAPLO.cfg
# ${BIP_TAG}    srs
# ${X2_CMD}         enb_x2_link_up enb\=1 target\=2
# ${ue_id_1}    1
# ${ue_id_2}    2
# ${ue_id_3}    3
# ${ue_id_4}    4
# ${ue_id_5}    5
# ${ue_id_6}    6
# ${ue_id_7}    7
# ${ue_id_8}    8
# @{Rdparameter}
#     ...    0x340000:15
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=2 trigger_puxch_update\=0
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=2 trigger_puxch_update\=0
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=2 trigger_puxch_update\=0
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=2 trigger_puxch_update\=0
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=2 trigger_puxch_update\=0
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=2 trigger_puxch_update\=0
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=2 trigger_puxch_update\=0
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE6}    ue_testmode_set_nr id\=12 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# ${SET_PROFILE7}    ue_testmode_set_nr id\=13 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
# ${SET_PROFILE8}    ue_testmode_set_nr id\=14 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
# 
# *** Test Cases ***
# CB008360_C_B3_case03_CB006062_8_SA_NSA_UEs_UL256QAM_with_Aperiodic_CSI_TypeA
#     [Documentation]
#     ...
#     Prepare test and start capture syslog
#     attach 4 SA UE
#     attach 4 NSA UE
#     Get all ue's rnti
#     check all UE's tput
#     check 8 UE's bler and cdm with ttitrace
#     #check ulMuMimoCorrThd2
#     detach 4 SA UE
#     send data to 4 NSA UE and check tput
#     check 4 NSA UE's subcell and dmrsfdm with ttitrace
#     detach 4 NSA UE
# 
# 
# *** Keywords ***
# Prepare test and start capture syslog
#     Active GNB L2 feature debug traces
#     Add GNB swconfig    @{Rdparameter}
#     Get and Update BSR File    par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Prepare gnb onair
#     Prepare X2 link
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
# 
# check ulMuMimoCorrThd2
#     Online change ulMuMimoCorrThd2 50
#     Wait '120s' for stabible
#     ${ulMUmimoPairUePusch_value1}    Get PM counter TOT_MU_MIMO_PAIR_UE_PUSCH M55308C35010 value in cell 1
#     Log To Console   -----ulMUmimoPairUePusch_value1-${ulMUmimoPairUePusch_value1}
#     Online change ulMuMimoCorrThd2 1
#     Wait '120s' for stabible
#     ${ulMUmimoPairUePusch_value2}    Get PM counter TOT_MU_MIMO_PAIR_UE_PUSCH M55308C35010 value in cell 1
#     Log To Console   -----ulMUmimoPairUePusch_value2-${ulMUmimoPairUePusch_value2}
#     should be true    ${ulMUmimoPairUePusch_value1} > ${ulMUmimoPairUePusch_value2}
#     Online change ulMuMimoCorrThd2 15
#     Wait '60s' for stabible
# 
# Online change ulMuMimoCorrThd2 ${ulMuMimoCorrThd2_value}
#     Log To Console   ${\n}Online change ulMuMimoCorrThd2 to ${ulMuMimoCorrThd2_value} ------
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0    ulMuMimoCorrThd2    ${ulMuMimoCorrThd2_value}    online
#     TAF_ADMIN.teardown admin    connection=online
# 
# Get PM counter ${COUNTER_NAME} ${counter_id} value in cell ${cell_id}
#     Wait '60s' for stabible
#     ${cpath}    set variable    ${test_log_directory()}/All/counter_${counter_id}/
#     ${counter_value}    Get pm counter value    ${counter_id}    ${cell_id}    ${cpath}
#     [return]    ${counter_value}
# 
# attach 4 SA UE
#     Attach SA ue to 5g cell    t2r4_n2    ${ue_id_1}    PDU_ID=${ue_id_1}    GW_ID=${ue_id_1}
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     SA send ue '1' mutiple trf '1' for each '150M' UL data
#     run keyword and continue on failure    check SA UE'1' dl tput range is '0' to '100' and ul tput range is '140' to '144'
#     run keyword and continue on failure    Start collect ttitrace
#     run keyword and continue on failure    Wait for '3s' to stop ttitrace with name'tti1_1ue'
#     run keyword and continue on failure    Check one ue's subcell and mustats with tti1_1ue_ul.csv
# 
#     Attach SA ue to 5g cell    t2r4_n2    ${ue_id_2}    PDU_ID=${ue_id_2}    GW_ID=${ue_id_2}
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}
#     run keyword and continue on failure    SA send ue '2' mutiple trf '1' for each '20M' UL data
#     run keyword and continue on failure    check SA UE'2' dl tput range is '0' to '100' and ul tput range is '19' to '21'
# 
#     Attach SA ue to 5g cell    t2r4_n2    ${ue_id_3}    PDU_ID=${ue_id_3}    GW_ID=${ue_id_3}
#     Airphone Execute Egate Command    ${PROFILE3}
#     Airphone Execute Egate Command    ${SET_PROFILE3}
#     SA send ue '3' mutiple trf '1' for each '20M' UL data
#     run keyword and continue on failure    check SA UE'3' dl tput range is '0' to '100' and ul tput range is '19' to '21'
# 
#     Attach SA ue to 5g cell    t2r4_n2    ${ue_id_4}    PDU_ID=${ue_id_4}    GW_ID=${ue_id_4}
#     Airphone Execute Egate Command    ${PROFILE4}
#     Airphone Execute Egate Command    ${SET_PROFILE4}
#     SA send ue '4' mutiple trf '1' for each '20M' UL data
#     run keyword and continue on failure    check SA UE'4' dl tput range is '0' to '100' and ul tput range is '19' to '21'
# 
# attach 4 NSA UE
#     Attach one NSA UE'11'
#     Airphone Execute Egate Command    ${PROFILE5}
#     Airphone Execute Egate Command    ${SET_PROFILE5}
#     NSA send ue '11' mutiple trf '1' for each '20M' UL data
#     run keyword and continue on failure    check NSA UE'11' dl tput range is '0' to '100' and ul tput range is '19' to '21'
# 
#     Attach one NSA UE'12'
#     Airphone Execute Egate Command    ${PROFILE6}
#     Airphone Execute Egate Command    ${SET_PROFILE6}
#     NSA send ue '12' mutiple trf '1' for each '20M' UL data
#     run keyword and continue on failure    check NSA UE'12' dl tput range is '0' to '100' and ul tput range is '19' to '21'
# 
#     Attach one NSA UE'13'
#     Airphone Execute Egate Command    ${PROFILE7}
#     Airphone Execute Egate Command    ${SET_PROFILE7}
#     NSA send ue '13' mutiple trf '1' for each '20M' UL data
#     run keyword and continue on failure    check NSA UE'13' dl tput range is '0' to '100' and ul tput range is '11' to '16'
# 
#     Attach one NSA UE'14'
#     Airphone Execute Egate Command    ${PROFILE8}
#     Airphone Execute Egate Command    ${SET_PROFILE8}
#     NSA send ue '14' mutiple trf '1' for each '20M' UL data
#     run keyword and continue on failure    check NSA UE'14' dl tput range is '0' to '100' and ul tput range is '11' to '12'
# 
# detach 4 SA UE
#     Detach SA UE'1'
#     Detach SA UE'2'
#     Detach SA UE'3'
#     Detach SA UE'4'
# 
# check all UE's tput
#     run keyword and continue on failure    check SA UE'1' dl tput range is '0' to '100' and ul tput range is '22' to '26'
#     run keyword and continue on failure    check SA UE'2' dl tput range is '0' to '100' and ul tput range is '19' to '21'
#     run keyword and continue on failure    check SA UE'3' dl tput range is '0' to '100' and ul tput range is '19' to '21'
#     run keyword and continue on failure    check SA UE'4' dl tput range is '0' to '100' and ul tput range is '19' to '21'
#     run keyword and continue on failure    check NSA UE'11' dl tput range is '0' to '100' and ul tput range is '11' to '12'
#     run keyword and continue on failure    check NSA UE'12' dl tput range is '0' to '100' and ul tput range is '11' to '12'
#     run keyword and continue on failure    check NSA UE'13' dl tput range is '0' to '100' and ul tput range is '11' to '12'
#     run keyword and continue on failure    check NSA UE'14' dl tput range is '0' to '100' and ul tput range is '11' to '12'
# 
# check 8 UE's bler and cdm with ttitrace
#     run keyword and continue on failure    Start collect ttitrace
#     run keyword and continue on failure    Wait for '3s' to stop ttitrace with name'tti1_dmrsfdm_true_8ue'
#     run keyword and continue on failure    Check bler and cdm with tti1_dmrsfdm_true_8ue_ul.csv
# 
# send data to 4 NSA UE and check tput
#     NSA send ue '11' mutiple trf '1' for each '150M' UL data
#     NSA send ue '12' mutiple trf '1' for each '150M' UL data
#     NSA send ue '13' mutiple trf '1' for each '150M' UL data
#     NSA send ue '14' mutiple trf '1' for each '150M' UL data
#     run keyword and continue on failure    check NSA UE'11' dl tput range is '0' to '100' and ul tput range is '19' to '21'
#     run keyword and continue on failure    check NSA UE'12' dl tput range is '0' to '100' and ul tput range is '19' to '21'
#     run keyword and continue on failure    check NSA UE'13' dl tput range is '0' to '100' and ul tput range is '19' to '21'
#     run keyword and continue on failure    check NSA UE'14' dl tput range is '0' to '100' and ul tput range is '19' to '21'
# 
# check 4 NSA UE's subcell and dmrsfdm with ttitrace
#     run keyword and continue on failure    Start collect ttitrace
#     run keyword and continue on failure    Wait for '4s' to stop ttitrace with name'tti2_dmrsfdm_true_4_nsaue'
#     run keyword and continue on failure    Check 4 nsa ue subcell with tti2_dmrsfdm_true_4_nsaue_ul.csv
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
#     Airphone Execute Egate Command    ${PROFILE5}
#     Airphone Execute Egate Command    ${SET_PROFILE5}
#     Wait '2s' for stabible
#     Airphone Execute Egate Command    ${PROFILE6}
#     Airphone Execute Egate Command    ${SET_PROFILE6}
#     Wait '2s' for stabible
#     Airphone Execute Egate Command    ${PROFILE7}
#     Airphone Execute Egate Command    ${SET_PROFILE7}
#     Wait '2s' for stabible
#     Airphone Execute Egate Command    ${PROFILE8}
#     Airphone Execute Egate Command    ${SET_PROFILE8}
#     Wait '2s' for stabible
# 
# detach 4 NSA UE
#     Airphone NSA Detach    11
#     Airphone NSA Detach    12
#     Airphone NSA Detach    13
#     Airphone NSA Detach    14
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
#     Wait Throughput Timer    3s
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
# Multi UE SA Register with start ue id '${start_ue_id}' and ue num '${SA_UE_NUM}'
#     : FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${SA_UE_NUM}+1
# 
#     #\   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register SA UE ${ue_id} ------
# 
#     \    Attach SA ue to 5g cell    SRS_Ports_PerResource2    ${ue_id}    PDU_ID=${ue_id}    GW_ID=${ue_id}
#     \    SA send dl and ul data    ${ue_id}    number=3    dl_data=175M    ul_data=20M    pdu_id=${ue_id}
#     \    Wait '3s' for stabible
# 
# 
# check SA UE'${ue_id}' dl tput range is '${dl_low_Mb}' to '${dl_high_Mb}' and ul tput range is '${ul_low_Mb}' to '${ul_high_Mb}'
#     Wait '10s' for stabible
#     Log To Console    ..Check throughput UE${ue_id}
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${ue_id}   pdu_id= ${ue_id}
#     ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console    dl ${dl_tput_Mb}
#     Log To Console    ul ${ul_tput_Mb}
#     should be true    ${dl_tput_Mb}>=${dl_low_Mb}
#     should be true    ${dl_tput_Mb}<=${dl_high_Mb}
#     should be true    ${ul_tput_Mb}>=${ul_low_Mb}
#     should be true    ${ul_tput_Mb}<=${ul_high_Mb}
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
# Online change actUlMuMimoTapering ${tapering_switch}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0    actUlMuMimoTapering    ${tapering_switch}    online
#     TAF_ADMIN.teardown admin    connection=online
# 
# Online change ulMaxMuMimoLayer${maxlaynum}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0    ulMaxMuMimoLayer    ${maxlaynum}    online
#     TAF_ADMIN.teardown admin    connection=online
# 
# 
# Check bler and cdm with ${tti_tag}
#     Log To Console   ${\n}---check tti ---
#     Set test Variable    ${tti_title_tag}    ${tti_tag}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_C_b3_case03_ul.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check 4 nsa ue subcell with ${tti_tag}
#     Log To Console   ${\n}---check tti ---
#     Set test Variable    ${tti_title_tag}    ${tti_tag}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_C_b3_case03_nsa_subcell_ul.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check one ue's subcell and mustats with ${tti_tag}
#     Log To Console   ${\n}---check tti ---
#     Set test Variable    ${tti_title_tag}    ${tti_tag}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_C_b3_case03_oneue_mustatas_ul.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# Get all ue's rnti
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_all   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_all/egate_console.log.001   crnti: (\\d+)
#     Set test Variable    ${rnti_1}    ${rnti_list[0]}
#     Set test Variable    ${rnti_2}    ${rnti_list[1]}
#     Set test Variable    ${rnti_3}    ${rnti_list[2]}
#     Set test Variable    ${rnti_4}    ${rnti_list[3]}
#     Set test Variable    ${rnti_5}    ${rnti_list[4]}
#     Set test Variable    ${rnti_6}    ${rnti_list[5]}
#     Set test Variable    ${rnti_7}    ${rnti_list[6]}
#     Set test Variable    ${rnti_8}    ${rnti_list[7]}
# 
# Case Test Teardown
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     Common Test Teardown