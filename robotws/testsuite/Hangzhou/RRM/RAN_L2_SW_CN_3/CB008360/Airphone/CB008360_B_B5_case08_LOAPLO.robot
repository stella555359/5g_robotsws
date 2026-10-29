# *** Settings ***
# Test Timeout    150 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    test teardown for collect titrace
# Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R2
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_B_b5_case08_LOAPLO.xml
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
# ${UE_NUM}    8
# 
# @{Rdparameter}
#     ...    0x340000:15
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=2 trigger_puxch_update\=0
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=3 trigger_puxch_update\=0
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 step\=4 trigger_puxch_update\=0
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 step\=2 trigger_puxch_update\=0
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=1 step\=3 trigger_puxch_update\=0
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 step\=4 trigger_puxch_update\=0
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# ${SET_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
# ${SET_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
# ${deactive_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=1
# ${deactive_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2
# ${deactive_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=3
# ${deactive_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=4
# ${deactive_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=5
# ${deactive_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=6
# ${deactive_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=7
# ${deactive_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=8
# 
# *** Test Cases ***
# CB008360_B_B5_case08_8_rank2_Ues_with_tapering_H_15db_V_0db
#     [Documentation]
#     ...    this Robustness test case
#     Prepare gNB and wait on Air
#     Repeat test 2 times
# 
# *** Keywords ***
# Prepare gNB and wait on Air
#     Prepare test
#     Get and Update BSR File    par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Prepare gnb onair
#     Prepare X2 link
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
# 
# 
# Repeat test ${NUM} times
#     : FOR    ${num}    IN RANGE    1    ${NUM}+1
#     \    Block and unBlock cell
#     \    Log To Console   ${\n}+++++++++++++++ test NO-${num} time +++++++++++++++
#     \    Log To Console   -----NO-${num}-step1:start attach UE1 to UE4 and inject ul data ------
#     \    Attach UE1 to UE4 and check log with No_'${num}'
#     \    Log To Console   -----NO-${num}-step2:start attach UE5 to UE8 and inject ul data ------
#     \    Attach UE5 to UE8 and check 8UEs log with No_'${num}'
#     \    Log To Console   ${\n}-----NO-${num}-step3:detach UE1 to UE8 ------
#     \    Detach 8 UEs and deactive SRS beam profile
# 
# Attach UE1 to UE4 and check log with No_'${num}'
#     Attach UE1 to UE4 and inject UL data
#     Check 4UEs UE1 to UE4's tput
#     run keyword and continue on failure    Check 4UEs ttitrace'${num}' with tapering false
# 
# Attach UE5 to UE8 and check 8UEs log with No_'${num}'
#     Attach UE5 to UE8 and inject UL data
#     Stop UE'1' to UE'8' DL and UL data transfer
#     UE'1' to UE'8' send '2' mutiple trf '90M' DL data and '90M' UL data
#     Log To Console   ${\n}-----NO-${num}:check no tapering UE1 to UE8's tput ------
#     Check 8 UEs's tput
#     run keyword and continue on failure    Check 8UEs ttitrace'${num}' with tapering false
# 
# Detach 8 UEs and deactive SRS beam profile
#     Stop UE'1' to UE'8' DL and UL data transfer
#     Deactive all UE UL MIMO SRS Beam Profile
#     DeRegister UE'1' to UE'8'
#     Wait '10s' for stabible
# 
# Get PM counter ${COUNTER_NAME} ${counter_id} value in cell ${cell_id}
#     Wait '60s' for stabible
#     ${cpath}    set variable    ${test_log_directory()}/All/counter_${counter_id}/
#     ${counter_value}    Get pm counter value    ${counter_id}    ${cell_id}    ${cpath}
#     [return]    ${counter_value}
# 
# Check pm counter ${counter} in cell ${cell_id} is expected ${symbol} ${expected_value}
#     ${cpath}    set variable    ${test_log_directory()}/All/counter_${counter}/
#     ${counter_value}    Get pm counter value    ${counter}    ${cell_id}    ${cpath}
#     should be true    ${counter_value} ${symbol} ${expected_value}
# 
# Prepare test
#     #Active GNB L2 feature debug traces
#     Add GNB swconfig    @{Rdparameter}
# 
# Prepare X2 link
#     airphone_execute_egate_command    ${X2_CMD}
# 
# Detach SA UE'${UE_ID}'
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 
# SA UE'${ue_id}' send '${dl_data_size}' with trf num'${dl_trf_num}' dl data and '${ul_data_size}' with trf num'${ul_trf_num'} ul data
#     SA send mutiple trf dl data    ${ue_id}    number='${ul_data_size}'   ul_data=${dl_data_size}    pdu_id=${ue_id}
#     SA send mutiple trf ul data    ${ue_id}    number='${ul_data_size}'   ul_data=${ul_data_size}    pdu_id=${ue_id}
# 
# SA send ue '${ue_id}' mutiple trf '${number}' for each '${ul_data}' UL data
#     SA send mutiple trf ul data    ${ue_id}    number=${number}   ul_data=${ul_data}    pdu_id=${ue_id}
#     Wait Throughput Timer    3s
# 
# SA send ue '${ue_id}' mutiple trf '${number}' for each '${dl_data}' DL data
#     SA send mutiple trf dl data    ${ue_id}    number=${number}   dl_data=${dl_data}    pdu_id=${ue_id}
#     Wait Throughput Timer    3s
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
# Online change ulMuMimoCorrThd2 ${ulMuMimoCorrThd2_value}
#     Log To Console   ${\n}Online change ulMuMimoCorrThd2 to ${ulMuMimoCorrThd2_value} ------
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0    ulMuMimoCorrThd2    ${ulMuMimoCorrThd2_value}    online
#     TAF_ADMIN.teardown admin    connection=online
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
# Stop ul data transfer
#     [Arguments]    ${UE_ID}
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}   pdu_id=${UE_ID}   direction=ul
# 
# Detach UE
#     [Arguments]    ${UE_ID}
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 
# Block Cell
#     [Arguments]    ${phy_cell_id}    ${alias}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.administrativeState}'=='Unlocked'
#          ...    Run Keywords    TAF_ADMIN.lock    ${nrcel.id}    timeout=60    connection=${alias}  AND    Wait '60s' for stable
#     TAF_ADMIN.teardown    connection=${alias}
# 
# Unblock Cell
#     [Arguments]    ${phy_cell_id}    ${alias}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.administrativeState}'=='Locked'
#          ...    Run Keywords    TAF_ADMIN.unlock    ${nrcel.id}    timeout=60    connection=${alias}  AND    Wait '60s' for stable
#     TAF_ADMIN.teardown    connection=${alias}
# 
# Check bler and pair ratio without tapering ${tti_tag}
#     Log To Console   ---check tti ---${\n}
#     Set test Variable    ${tti_title_tag}    ${tti_tag}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_b5_case08_without_tapering_ul.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# 
# Check 4 UEs bler and pair ratio without tapering ${tti_tag}
#     Log To Console   ---check tti ---${\n}
#     Set test Variable    ${tti_title_tag}    ${tti_tag}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_b5_case08_without_tapering_ul.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check 8 UEs bler and pair ratio without tapering ${tti_tag}
#     Log To Console   ---check tti ---${\n}
#     Set test Variable    ${tti_title_tag}    ${tti_tag}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_b5_case08_8ue_without_tapering_ul.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check bler and per slot ue num with ${tti_tag}
#     Log To Console   ---check tti ---${\n}
#     Set test Variable    ${tti_title_tag}    ${tti_tag}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_b5_case08_fulldata_ul.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# DeRegister ${NUM} SA UEs
#     : FOR    ${num}    IN RANGE    1    ${NUM}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=30
#     \   Log To Console   ${\n}-----de-attach ue_id${num}
#     \   Wait '2s' for stabible
# 
# Stop ${NUM} SA UEs UL data transfer
#     : FOR    ${UE_ID}    IN RANGE    1    ${NUM}+1
#     \   airphone_sa_stop_data_traffic    ue_id=${UE_ID}   pdu_id=${UE_ID}   direction=ul
# 
# test teardown for collect titrace
#     #run keyword and ignore error    Start collect ttitrace
#     #run keyword and ignore error    Wait for '3s' to stop ttitrace with name'teardown_tti'
#     #run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     Common Test Teardown
# 
# Deactive all UE UL MIMO SRS Beam Profile
#     Airphone Execute Egate Command    ${deactive_PROFILE1}
#     Airphone Execute Egate Command    ${deactive_PROFILE2}
#     Airphone Execute Egate Command    ${deactive_PROFILE3}
#     Airphone Execute Egate Command    ${deactive_PROFILE4}
#     Airphone Execute Egate Command    ${deactive_PROFILE5}
#     Airphone Execute Egate Command    ${deactive_PROFILE6}
#     Airphone Execute Egate Command    ${deactive_PROFILE7}
#     Airphone Execute Egate Command    ${deactive_PROFILE8}
# 
# Attach UE1 to UE4 and inject UL data
#     Attach SA ue to 5g cell    t2r4_n2    ${ue_id_1}    PDU_ID=${ue_id_1}    GW_ID=${ue_id_1}
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     SA send ue '1' mutiple trf '1' for each '90M' UL data
#     SA send ue '1' mutiple trf '4' for each '90M' DL data
# 
#     Attach SA ue to 5g cell    t2r4_n2    ${ue_id_2}    PDU_ID=${ue_id_2}    GW_ID=${ue_id_2}
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}
#     SA send ue '2' mutiple trf '1' for each '90M' UL data
#     SA send ue '2' mutiple trf '4' for each '90M' DL data
# 
#     Attach SA ue to 5g cell    t2r4_n2    ${ue_id_3}    PDU_ID=${ue_id_3}    GW_ID=${ue_id_3}
#     Airphone Execute Egate Command    ${PROFILE3}
#     Airphone Execute Egate Command    ${SET_PROFILE3}
#     SA send ue '3' mutiple trf '1' for each '90M' UL data
#     SA send ue '3' mutiple trf '4' for each '90M' DL data
# 
#     Attach SA ue to 5g cell    t2r4_n2    ${ue_id_4}    PDU_ID=${ue_id_4}    GW_ID=${ue_id_4}
#     Airphone Execute Egate Command    ${PROFILE4}
#     Airphone Execute Egate Command    ${SET_PROFILE4}
#     SA send ue '4' mutiple trf '1' for each '90M' UL data
#     SA send ue '4' mutiple trf '4' for each '90M' DL data
#     Wait '10s' for stable
# 
# Attach UE5 to UE8 and inject UL data
#     Attach SA ue to 5g cell    t2r4_n2    ${ue_id_5}    PDU_ID=${ue_id_5}    GW_ID=${ue_id_5}
#     Airphone Execute Egate Command    ${PROFILE5}
#     Airphone Execute Egate Command    ${SET_PROFILE5}
#     SA send ue '5' mutiple trf '1' for each '90M' UL data
#     SA send ue '5' mutiple trf '3' for each '90M' DL data
# 
#     Attach SA ue to 5g cell    t2r4_n2    ${ue_id_6}    PDU_ID=${ue_id_6}    GW_ID=${ue_id_6}
#     Airphone Execute Egate Command    ${PROFILE6}
#     Airphone Execute Egate Command    ${SET_PROFILE6}
#     SA send ue '6' mutiple trf '1' for each '90M' UL data
#     SA send ue '6' mutiple trf '3' for each '90M' DL data
# 
#     Attach SA ue to 5g cell    t2r4_n2    ${ue_id_7}    PDU_ID=${ue_id_7}    GW_ID=${ue_id_7}
#     Airphone Execute Egate Command    ${PROFILE7}
#     Airphone Execute Egate Command    ${SET_PROFILE7}
#     SA send ue '7' mutiple trf '1' for each '90M' UL data
#     SA send ue '7' mutiple trf '3' for each '90M' DL data
# 
#     Attach SA ue to 5g cell    t2r4_n2    ${ue_id_8}    PDU_ID=${ue_id_8}    GW_ID=${ue_id_8}
#     Airphone Execute Egate Command    ${PROFILE8}
#     Airphone Execute Egate Command    ${SET_PROFILE8}
#     SA send ue '8' mutiple trf '1' for each '90M' UL data
#     SA send ue '8' mutiple trf '3' for each '90M' DL data
#     Wait '10s' for stable
# 
# Check 4UEs UE1 to UE4's tput
#     Log To Console   --Start check UE1 to UE4's TPut --
#     run keyword and continue on failure    check SA UE'1' dl tput range is '322' to '335' and ul tput range is '70' to '81'
#     run keyword and continue on failure    check SA UE'2' dl tput range is '322' to '335' and ul tput range is '70' to '81'
#     run keyword and continue on failure    check SA UE'3' dl tput range is '322' to '335' and ul tput range is '70' to '81'
#     run keyword and continue on failure    check SA UE'4' dl tput range is '322' to '335' and ul tput range is '70' to '81'
# 
# Check 8 UEs's tput
#     run keyword and continue on failure    check SA UE'1' dl tput range is '100' to '180' and ul tput range is '23' to '42'
#     run keyword and continue on failure    check SA UE'2' dl tput range is '100' to '180' and ul tput range is '23' to '42'
#     run keyword and continue on failure    check SA UE'3' dl tput range is '100' to '180' and ul tput range is '23' to '42'
#     run keyword and continue on failure    check SA UE'4' dl tput range is '100' to '180' and ul tput range is '23' to '42'
#     run keyword and continue on failure    check SA UE'5' dl tput range is '100' to '180' and ul tput range is '23' to '42'
#     run keyword and continue on failure    check SA UE'6' dl tput range is '100' to '180' and ul tput range is '23' to '42'
#     run keyword and continue on failure    check SA UE'7' dl tput range is '100' to '180' and ul tput range is '23' to '42'
#     run keyword and continue on failure    check SA UE'8' dl tput range is '100' to '180' and ul tput range is '23' to '42'
# 
# All UEs start inject UL data transfer
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   Wait '2s' for stabible
#     \   SA send mutiple trf ul data    ue_id=${num}    number=1   ul_data=90M    pdu_id=${num}
#     \   Wait '3s' for stabible
# 
# Block and unBlock cell
#     Log To Console   ${\n}--block cell --
#     Block Cell    50    gNB
#     Wait '10s' for stable
#     Log To Console   ${\n}--unblock cell --
#     Unblock Cell  50    gNB
#     Wait '60s' for stable
# 
# Check 4UEs ttitrace'${num}' with tapering false
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'${num}_tti1_tap_false_4ue'
#     Check 4 UEs bler and pair ratio without tapering ${num}_tti1_tap_false_4ue_ul.csv
# 
# Check 8UEs ttitrace'${num}' with tapering false
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'${num}_tti2_tap_false_8ue'
#     Check 8 UEs bler and pair ratio without tapering ${num}_tti2_tap_false_8ue_ul.csv
# 
# DeRegister UE'${start_ueid}' to UE'${end_ueid}'
#     : FOR    ${id}    IN RANGE    ${start_ueid}    ${end_ueid}+1
#     \   airphone_sa_detach    ue_id=${id}    timeout=30
#     \   Wait '3s' for stabible
# 
# Stop UE'${start_ueid}' to UE'${end_ueid}' DL and UL data transfer
#     Stop UE'${start_ueid}' to UE'${end_ueid}' 'UL' data transfer
#     Stop UE'${start_ueid}' to UE'${end_ueid}' 'DL' data transfer
# 
# Stop UE'${start_ueid}' to UE'${end_ueid}' '${direction}' data transfer
#     : FOR    ${id}    IN RANGE    ${start_ueid}    ${end_ueid}+1
#     \   airphone_sa_stop_data_traffic    ue_id=${id}   pdu_id=${id}   direction=${direction}
# 
# UE'${start_ueid}' to UE'${end_ueid}' send '${dl_num}' mutiple trf '${dl_size}' DL data and '${ul_size}' UL data
#     : FOR    ${id}    IN RANGE    ${start_ueid}    ${end_ueid}+1
#     \   SA send ue '${id}' mutiple trf '1' for each '${ul_size}' UL data
#     \   SA send ue '${id}' mutiple trf '${dl_num}' for each '${dl_size}' DL data
# 
# 
