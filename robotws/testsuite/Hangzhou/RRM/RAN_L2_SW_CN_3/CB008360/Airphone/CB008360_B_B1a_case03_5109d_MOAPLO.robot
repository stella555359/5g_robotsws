# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_pennwang    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    
# ...   CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_b_case03_MOAPLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL_b_LOAPLO.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport
# ${WTS_NAME}    BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD_LOAPLO.cfg
# ${UE_ID}          1
# ${UE_ID2}          2
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=4 trigger_puxch_update\=0
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=3 trigger_puxch_update\=0
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=2 trigger_puxch_update\=0
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# 
# ${ul_sinr_pathloss}    ul_sinr_testmode_nr profile_id\=1 pathloss\=105
# ${ul_sinr_pathloss_active}    ue_testmode_set_nr id\=1 testmode\=ul_sinr profile_id\=1 scell\=0 action\=activate
# *** Test Cases ***
# CNI92510_case03_EDA_4UE_UL_pairing_10bler_KPI_NR_5109d_checking_with_CB008360_64_256QAM
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Prepare gnb onair
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair1' file
#     Attach ue and send data    t2r4_n2   
#     Send bler for 1_1 time
#     ${KPI_mimo_true1}    Wait '60s' get NR_5109d counter true
#     ${KPI_mimo_true2}    Wait '120s' get NR_5109d counter true2
#     ${KPI_mimo_true3}    Wait '120s' get NR_5109d counter true3
#     Detach UEs
#     Online change 'actUlMuMimo' 'false' with cell setup
#     Attach ue and send data    t2r4_n2
#     Send bler for 1_2 time
#     Stop egate log and unzip with name'kpi1'
#     ${KPI_mimo_false1}    Wait '60s' get NR_5109d counter false
#     ${KPI_mimo_false2}    Wait '120s' get NR_5109d counter false2
#     ${KPI_mimo_false3}    Wait '120s' get NR_5109d counter false3
#     should be true    ${KPI_mimo_true1}>=${KPI_mimo_false1} 
#     should be true    ${KPI_mimo_true2}>=${KPI_mimo_false2} 
#     should be true    ${KPI_mimo_true3}>=${KPI_mimo_false3} 
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair1' file
#     Detach UEs
# 
#     Online change 'actUl256Qam' to 'true'
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair2' file
#     Attach ue and send data    t2r4_n2  
#     Send bler for 2_1 time 
#     ${KPI_mimo_true2}    Wait '600s' get NR_5109d counter true
#     Detach UEs
#     Online change 'actUlMuMimo' 'false' with cell setup
#     Attach ue and send data    t2r4_n2
#     Send bler for 2_2 time
#     Stop egate log and unzip with name'kpi2'
#     ${KPI_mimo_false2}    Wait '600s' get NR_5109d counter false
#     should be true    ${KPI_mimo_true2}>=${KPI_mimo_false2}  
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair2' file
#     Detach UEs
# 
# CNI92510_case04_EDA_4UE_UL_pairing_10bler_KPI_NR_5109d_checking_with_CB008360_DFT_S_OFDM
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Add GNB swconfig    0x580376:0x5    0x580377:0x2
#     Prepare gnb onair
#     Online change 'actUlDftSOfdm' to 'true'
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair3' file
#     Attach ue and send data    DFT-s-OFDM_enabled  
#     Send passloss 
#     ${KPI_mimo_true3}    Wait '600s' get NR_5109d counter true
#     Detach UEs
#     Online change 'actUlMuMimo' 'false' with cell setup
#     Attach ue and send data    DFT-s-OFDM_enabled
#     Send passloss
#     Stop egate log and unzip with name'kpi3'
#     ${KPI_mimo_false3}    Wait '600s' get NR_5109d counter false
#     should be true    ${KPI_mimo_true3}>=${KPI_mimo_false3} 
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair3' file
#     Detach UEs
# 
# 
# 
# *** Keywords ***
# Send bler for ${number} time
#     : FOR    ${uid}    IN RANGE    1    5
#     \    Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=${uid} sinr_target_pusch\=-370
#     \    Wait '1s' for stable
#     \    Airphone Execute Egate Command    ue_testmode_set_nr id\=${uid} testmode\=ul_sinr profile_id\=${uid} action\=activate
#     \    Wait '2s' for stable
#     Wait '5s' for stable
# 
# 
# Detach UEs
#     : FOR    ${ueid}    IN RANGE    1    5
#     \    airphone_sa_detach    ue_id=${ueid}
#     \    Airphone Execute Egate Command    ul_mimo_srs_beam_pos_nr profile_id\=${ueid} delete\=true
#     \    Wait '2s' for stable
# 
# Send passloss
#     : FOR    ${uid}    IN RANGE    1    5
#     \    Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=${uid} pathloss\=140
#     \    Wait '1s' for stable
#     \    Airphone Execute Egate Command    ue_testmode_set_nr id\=${uid} testmode\=ul_sinr profile_id\=${uid} scell\=0 action\=activate
#     \    Wait '1s' for stable
#     Wait '5s' for stable
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'ttidft'
#     ${ret}    Read Csv Columns    ${test_log_directory()}/All/ttidft_ul.csv    ulFdSchedData.puschTPstate
#     Run Keyword If    2 in ${ret}    log to console    pass    ELSE    Fail
#     #0是CP OFDM,2是DFT ofdm,1是CP转DFT的过渡,3是DFT转CP的过渡
# 
# 
# Attach ue and send data
#     [Arguments]    ${cap}
#     Attach SA ue to 5g cell    ${cap}    1
#     Attach SA ue to 5g cell    ${cap}    2    PDU_ID=2    GW_ID=2
#     Attach SA ue to 5g cell    ${cap}    3    PDU_ID=3    GW_ID=3
#     Attach SA ue to 5g cell    ${cap}    4    PDU_ID=4    GW_ID=4
#     Set ue position
#     SA send dl and ul data    1    number=2    dl_data=10M    ul_data=100M
#     SA send dl and ul data    2    number=2    dl_data=10M    ul_data=100M    pdu_id=2
#     SA send dl and ul data    3    number=2    dl_data=10M    ul_data=100M    pdu_id=3
#     SA send dl and ul data    4    number=2    dl_data=10M    ul_data=100M    pdu_id=4
#     
# 
# Online change '${par}' to '${value}'
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1    ${par}    ${value}    online
#     Wait '30s' for stabible
#     TAF_ADMIN.teardown admin    connection=online
# 
# Online change '${par}' '${value}' with cell setup
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1    ${par}    ${value}    online
#     # ######
#     OperatingSystem.Run And Return Rc And Output
#     ...    sshpass -p ${GNB_ASIK.password} ssh ${GNB_ASIK.username}@${GNB_ASIK.ip} 'reboot'
#     Wait '10s' for stable
#     Wait Until Keyword Succeeds    240s    5s    check ping is enabled    ${GNB_ASIK.ip}
#     # ######
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '60s' for stable
#     
# Check ue tput is correct
#     Wait '30s' for stable
#     ${tput_list_ul}   create list
#     ${tput_list_dl}   create list
#     ${dl_tput1}    ${ul_tput1}    Obtain one sa ue dl and ul throught    1
#     ${dl_tput2}    ${ul_tput2}    Obtain one sa ue dl and ul throught    2    pdu_id=2
#     ${dl_tput3}    ${ul_tput3}    Obtain one sa ue dl and ul throught    3    pdu_id=3
#     ${dl_tput4}    ${ul_tput4}    Obtain one sa ue dl and ul throught    4    pdu_id=4
#     append to list     ${tput_list_ul}    ${ul_tput1}
#     append to list     ${tput_list_ul}    ${ul_tput2}
#     append to list     ${tput_list_ul}    ${ul_tput3}
#     append to list     ${tput_list_ul}    ${ul_tput4}
#     append to list     ${tput_list_dl}    ${dl_tput1}
#     append to list     ${tput_list_dl}    ${dl_tput2}
#     append to list     ${tput_list_dl}    ${dl_tput3}
#     append to list     ${tput_list_dl}    ${dl_tput4}
#     log to console    ul tput is:${tput_list_ul}
#     log to console    dl tput is:${tput_list_dl}
#     should be true    ${ul_tput1}>20000
#     should be true    ${ul_tput2}>20000
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
# 
# Wait '${ct}' get NR_5109d counter ${vv}
#     Wait '${ct}' for stable
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${L_M55304C0400X}   create list
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
#     run keyword and continue on failure    Check ue tput is correct
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti${vv}'
#     ${M55304C0400X}    set variable    0
#     : FOR    ${num}    IN RANGE    0    10
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0400${num}    cell_id=1   
#     \    ${M55304C0400X}    Evaluate    ${M55304C0400X}+${result}
#     \    append to list    ${L_M55304C0400X}    ${result}   
# 
#     : FOR    ${num}    IN RANGE    10    32
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C040${num}    cell_id=1   
#     \    ${M55304C0400X}    Evaluate    ${M55304C0400X}+${result}
#     \    append to list    ${L_M55304C0400X}    ${result}
# 
#     ${L_M55304C0800X}   create list
#     ${M55304C0800X}    set variable    0
#     : FOR    ${num}    IN RANGE    0    10
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0800${num}    cell_id=1   
#     \    ${M55304C0800X}    Evaluate    ${M55304C0800X}+${result}
#     \    append to list    ${L_M55304C0800X}    ${result}
# 
#     : FOR    ${num}    IN RANGE    10    32
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C080${num}    cell_id=1   
#     \    ${M55304C0800X}    Evaluate    ${M55304C0800X}+${result}
#     \    append to list    ${L_M55304C0800X}    ${result}
# 
#     ${L_M55304C1000X}   create list
#     ${M55304C1000X}    set variable    0
#     : FOR    ${num}    IN RANGE    0    10
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C1000${num}    cell_id=1   
#     \    ${M55304C1000X}    Evaluate    ${M55304C1000X}+${result}
#     \    append to list    ${L_M55304C1000X}    ${result}
# 
#     : FOR    ${num}    IN RANGE    10    32
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C100${num}    cell_id=1   
#     \    ${M55304C1000X}    Evaluate    ${M55304C1000X}+${result}
#     \    append to list    ${L_M55304C1000X}    ${result}
# 
#     ${top_counter}    Evaluate    (${M55304C0400X}+${M55304C0800X}+${M55304C1000X})*8
#     ${L_M55308}   create list
#     ${M55308C03006}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C03006    cell_id=1
#     ${M55308C10002}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C10002    cell_id=1
#     ${M55308C00009}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00009    cell_id=1
#     ${M55308C00011}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00011    cell_id=1
#     append to list    ${L_M55308}    ${M55308C03006}
#     append to list    ${L_M55308}    ${M55308C10002}
#     append to list    ${L_M55308}    ${M55308C00009}
#     append to list    ${L_M55308}    ${M55308C00011}
#     ${bottom_counter}    Evaluate    ${M55308C03006}*180*(float(${M55308C10002})/(${M55308C00009}+${M55308C00011}))
#     ${SE_KPI_Value}    Evaluate    float(${top_counter}/${bottom_counter})
#     log to console    64qam:${L_M55304C0400X}
#     log to console    dft_s_ofdm:${L_M55304C0800X}
#     log to console    256qam:${L_M55304C1000X}
#     log to console    other counter:${L_M55308}
#     log to console    SE_KPI_Value=${SE_KPI_Value}
#     [Return]    ${SE_KPI_Value}    