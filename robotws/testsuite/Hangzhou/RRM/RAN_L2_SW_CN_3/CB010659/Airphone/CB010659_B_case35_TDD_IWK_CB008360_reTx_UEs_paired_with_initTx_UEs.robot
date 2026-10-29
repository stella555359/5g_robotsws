# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Case Test Teardown
# Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS23R3
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_CB010659_B_case35_LOAPLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_1CELL_8D8U_LOAPLO.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${WTS_NAME}    wts_CB010659_B_case35_LOAPLO.cfg
# ${BIP_TAG}    srs
# ${ue_id_1}    1
# ${ue_id_2}    2
# ${ue_id_3}    3
# ${ue_id_4}    4
# 
# @{Rdparameter}
#     ...    0x58061A:1
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=2 trigger_puxch_update\=0
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=3 trigger_puxch_update\=0
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 step\=4 trigger_puxch_update\=0
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# 
# ${UL_CELL_NOISE_TESTMODE_PROFILE1}    ul_cell_noise_testmode_nr profile_id\=1 noise_pusch\=-760
# ${UL_CELL_NOISE_TESTMODE_SET}    cell_testmode_set_nr cell_id\=1 gnb\=1 testmode\=ul_cell_noise profile_id\=1 action\=activate
# 
# *** Test Cases ***
# CB010659_B_case35_TDD_IWK_CB008360_reTx_UEs_paired_with_initTx_UEs
#     [Documentation]
#     ...    interwork CB008360
#     #Prepare test
#     Get and Update BSR File    par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Prepare gnb onair
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
# 
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    ${ue_id_1}    PDU_ID=${ue_id_1}    GW_ID=${ue_id_1}
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     SA UE'1' send '90M' with trf num'4' dl data and '90M' with trf num'1' ul data
#     Airphone Execute Egate Command    ${UL_CELL_NOISE_TESTMODE_PROFILE1}
#     Airphone Execute Egate Command    ${UL_CELL_NOISE_TESTMODE_SET}
#     Wait '3s' for stabible
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=1 sinr_target_pusch\=-330
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_sinr profile_id\=1 action\=activate
#     Wait '3s' for stabible
#     run keyword and continue on failure    Start collect ttitrace
#     run keyword and continue on failure    Wait for '4s' to stop ttitrace with name'tti0_targetPct100_1ue'
# 
#     Online change targetPctResourceReservedMcsUl 75
#     run keyword and continue on failure    Start collect ttitrace
#     run keyword and continue on failure    Wait for '4s' to stop ttitrace with name'tti1_targetPct75_1ue'
# 
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    ${ue_id_2}    PDU_ID=${ue_id_2}    GW_ID=${ue_id_2}
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}
#     SA UE'2' send '90M' with trf num'4' dl data and '90M' with trf num'1' ul data
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_sinr profile_id\=1 action\=activate
#     Wait '3s' for stabible
#     run keyword and continue on failure    Start collect ttitrace
#     run keyword and continue on failure    Wait for '4s' to stop ttitrace with name'tti2_targetPct75_2ue'
# 
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    ${ue_id_3}    PDU_ID=${ue_id_3}    GW_ID=${ue_id_3}
#     Airphone Execute Egate Command    ${PROFILE3}
#     Airphone Execute Egate Command    ${SET_PROFILE3}
#     SA UE'3' send '90M' with trf num'4' dl data and '90M' with trf num'1' ul data
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=3 testmode\=ul_sinr profile_id\=1 action\=activate
# 
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    ${ue_id_4}    PDU_ID=${ue_id_4}    GW_ID=${ue_id_4}
#     Airphone Execute Egate Command    ${PROFILE4}
#     Airphone Execute Egate Command    ${SET_PROFILE4}
#     SA UE'4' send '90M' with trf num'4' dl data and '90M' with trf num'1' ul data
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=4 testmode\=ul_sinr profile_id\=1 action\=activate
# 
#     Wait '10s' for stabible
#     run keyword and continue on failure    check SA UE'1' dl tput range is '300' to '335' and ul tput range is '10' to '29'
#     run keyword and continue on failure    check SA UE'2' dl tput range is '300' to '335' and ul tput range is '10' to '29'
#     run keyword and continue on failure    check SA UE'3' dl tput range is '300' to '335' and ul tput range is '10' to '29'
#     run keyword and continue on failure    check SA UE'4' dl tput range is '300' to '335' and ul tput range is '10' to '29'
#     run keyword and continue on failure    Start collect ttitrace
#     run keyword and continue on failure    Wait for '3s' to stop ttitrace with name'tti3_targetPct75_4ue'
#     Check reserved mcs in ttitrace is correct    tti3_targetPct75_4ue
#     #Online change targetPctResourceReservedMcsUl 60
#     #run keyword and continue on failure    Start collect ttitrace
#     #run keyword and continue on failure    Wait for '3s' to stop ttitrace with name'tti4_targetPct60_4ue'
#     #Online change targetPctResourceReservedMcsUl 50
#     #run keyword and continue on failure    Start collect ttitrace
#     #run keyword and continue on failure    Wait for '3s' to stop ttitrace with name'tti5_targetPct50_4ue'
# 
#     
# *** Keywords ***
# Prepare test
#     Active GNB L2 feature debug traces
#     Add GNB swconfig    @{Rdparameter}
# 
# Online change targetPctResourceReservedMcsUl ${targetValue}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1    targetPctResourceReservedMcsUl    ${targetValue}    online
#     TAF_ADMIN.teardown admin    connection=online
# 
# Online change minPctResourceReservedMcsUl ${targetValue}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1    minPctResourceReservedMcsUl    ${targetValue}    online
#     TAF_ADMIN.teardown admin    connection=online
# 
# Detach SA UE'${UE_ID}'
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 
# Attach one NSA UE'${ue_id}'
#     #airphone_cleanup_egate_console_log
#     Log To Console   ${\n}-----Attach NSA UE ${ue_id} ------
#     Airphone Nsa Attach    ${ue_id}     profile_id=None
# 
# SA UE'${ue_id}' send '${dl_data_size}' with trf num'${dl_trf_num}' dl data and '${ul_data_size}' with trf num'${ul_trf_num}' ul data
#     SA send mutiple trf dl data    ${ue_id}    number=${dl_trf_num}   dl_data=${dl_data_size}    pdu_id=${ue_id}
#     SA send mutiple trf ul data    ${ue_id}    number=${ul_trf_num}   ul_data=${ul_data_size}    pdu_id=${ue_id}
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
