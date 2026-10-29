# *** Settings ***
# Suite Setup     Suit setup for e2e gNB
# Suite Teardown    Run Keywords    Select and setup Commission SCF
# ...               AND    CI_Common_Suit_Teardown
# 
# Documentation
# ...   author: pengliang.wu@nokia-sbell.com
# ...   contact: pengliang.wu@nokia-sbell.com
# ...   CB007835-5G-B-SyVe_Key_customer_scenario_testing_for-KDDI-E2E_gNB_Cases
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource     ./resources/common_keywords.robot
# Resource    ../5GC001937_OTA/resources/5GC001937_mmw4_common_keyword.robot
# Variables   ../5GC001937_OTA/resources/5GC001937_mmw4_modify_para.py
# 
# *** Variables ***
# #${testline_name}
# ${test_iteration}       ${1}   #testing numbers
# ${log_time}             1m
# ${peak_log_time}        5m
# ${total_count}          ${100}
# ${duration}             ${1800}
# @{row_list}             NR PDCP Thr. DL [Mbps]    NR PDCP Thr. UL [Mbps]    NR PDSCH iBLER[%]    NR PUSCH iBLER[%]
# ${cmw_exp_ul}           ${70}
# ${cmw_exp_dl}           ${1400}
# ${non_peak_target_avg_percent}    ${0.5}
# ${stay_target_build}    ${True}
# 
# *** Test Cases ***
# [1]TC13_OAM_gNB_SW_Upgrade_success_L3Call
#     [Tags]    23R1
#     [Documentation]
#     ...    -02.03.2023,pengliang.wu@nokia-sbell.com,case draft
#     [Setup]    Gnb common case setup
#     Log to console    ------Before upgrade------
#     Get BTS Software Version
#     ${Is_need_rollback}    BTS_whether_need_rollback_before_upgrade
#     run keyword if    ${Is_need_rollback}==${True}    Classical gNB Software Rollback successfully via WebUI
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} Upgrade and Rollback start..
#         ${result}    Run Keyword And Return Status    Gnb upgraded via WEBUI    ue_index=${mmw_ue_index}
#         run keyword and continue on failure    Should Be True    ${result}
#         ${last_index}    Evaluate    ${test_iteration}-${1}
#         run keyword if    ${i}==${last_index} and ${stay_target_build}==${True}
#         ...    SWM supports provision SW build package via WebUI
#     END
#     Log to console    ------After upgrade------
#     Get BTS Software Version
#     Get SBTS Release Version
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]TC01_General_SiSo_Cell_block_and_unblock_L3Call_and_pcmd_check
#     [Tags]    23R1
#     [Documentation]
#     ...    -shanshan.zhang@nokia-sbell.com
#     [Setup]    Gnb common case setup
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} NR cell block and unblock start..
#         ${result}    Run Keyword And Return Status    Separately CELL block unblock
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#         run keyword and continue on failure    L3 call    pcmd=${True}    ue_index=${mmw_ue_index}
#         ...    target_avg_percent=${non_peak_target_avg_percent}
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]TC02_General_SiSo_RU_lock_unlock_L3Call
#     [Tags]    23R1
#     [Documentation]
#     ...    -pengliang.wu@nokia-sbell.com
#     [Setup]    Gnb common case setup
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} NR RF lock and unlock start..
#         ${result}    Run Keyword And Return Status    Each RF module lock and unlock    ue_index=${mmw_ue_index}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]TC03_General_SiSo_BBMOD_lock_unlock_L3Call
#     [Tags]    23R1
#     [Documentation]
#     ...    -pengliang.wu@nokia-sbell.com
#     [Setup]    Gnb common case setup
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} NR BBMOD lock and unlock start..
#         ${result}    Run Keyword And Return Status    Each single Baseband module lock and unlock
#         ...    ue_index=${mmw_ue_index}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]TC04_General_SiSo_BTS_block_unblock_L3Call
#     [Documentation]    shanshan.zhang@nokia-sbell.com
#     [Setup]    Gnb common case setup
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} NR BTS block and unblock start..
#         ${result}    Run Keyword And Return Status    Separately site block unblock then L3call
#         ...    ue_index=${mmw_ue_index}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]TC05_General_SiSo_NRCell_group_lock_unlock_L3Call_and_pcmd_check
#     [Documentation]    shanshan.zhang@nokia-sbell.com
#     [Setup]    Gnb common case setup
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} NR Cell Group lock and unlock start..
#         ${result}    Run Keyword And Return Status    NRCell group lock and unlock stability testing
#         ...    ue_index=${mmw_ue_index}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]TC06_General_SiSo_X2_link_lock_unlock_L3Call
#     [Documentation]    shanshan.zhang@nokia-sbell.com
#     [Setup]    Gnb common case setup
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} NR X2 lock and unlock start..
#         ${result}    Run Keyword And Return Status    X2 link lock and unlock    ue_index=${mmw_ue_index}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]TC07_General_SiSo_RF_module_power_reset_L3Call
#     [Tags]    CDRT_TRUNK
#     [Setup]    Gnb common case setup
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         ${result}    Run Keyword And Return Status     RF module poweroff on    ue_index=${mmw_ue_index}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]TC08_General_SiSo_RF_module_WebGUI_reset_L3Call
#     [Tags]    23R1
#     [Documentation]
#     ...    -23.03.2021,shengrong.rao@nokia-sbell.com,case draft
#     ...    [1]TC08_General_SiSo_RF_module_WebGUI_reset_L3Call
#     [Setup]    Gnb common case setup
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         ${result}    Run Keyword And Return Status    RF module reset
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#         run keyword and continue on failure    L3 call    pcmd=${True}    ue_index=${mmw_ue_index}
#         ...    target_avg_percent=${non_peak_target_avg_percent}
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]TC09_General_SiSo_BBMOD_reset_L3Call
#     [Tags]    23R1
#     [Documentation]
#     ...    -23.03.2021,shengrong.rao@nokia-sbell.com,case draft
#     ...    [1]TC09_General_SiSo_BBMOD_reset_L3Call
#     [Setup]    Gnb common case setup
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         ${result}    Run Keyword And Return Status     Each single Baseband module reset
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#         run keyword and continue on failure    L3 call    pcmd=${True}    ue_index=${mmw_ue_index}
#         ...    target_avg_percent=${non_peak_target_avg_percent}
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]TC10_General_SiSo_LED_status_and_pcmd_check_after_site_reset
#     [Tags]    23R1
#     [Documentation]
#     ...    -23.03.2021,shengrong.rao@nokia-sbell.com,case draft
#     ...    [1]TC09_General_SiSo_BBMOD_reset_L3Call
#     [Setup]    Gnb common case setup
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         ${result}    Run Keyword And Return Status     LED status check after site reset
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#         run keyword and continue on failure    L3 call    protocol=udp    syslog_check=${False}
#         ...    target_avg_percent=${non_peak_target_avg_percent}    ue_index=${mmw_ue_index}
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]TC11_General_SiSo_Filber_break_L3Call
#     [Documentation]    shanshan.zhang@nokia-sbell.com
#     [Setup]    Gnb common case setup
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} Separately Filber break then L3call
#         ${result}    Run Keyword And Return Status    Separately Filber break then L3call    ue_index=${mmw_ue_index}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]TC17_RRM_Single_UE_DL_UL_DL+UL_TCP_Tput_Peak_mmW
#     [Tags]    UTE_Cloud
#     [Documentation]    shanshan.zhang@nokia-sbell.com
#     [Setup]    Gnb common case setup
#     Get BTS Software Version
#     run keyword and continue on failure    L3 call    protocol=tcp    log_time=${peak_log_time}
#     ...    ul_enable=${True}    dl_enable=${False}    total_count=${300}    exp_ul_tp=${exp_ul_peak}
#     ...    ue_index=${mmw_ue_index}
#     run keyword and continue on failure    L3 call    protocol=tcp    log_time=${peak_log_time}
#     ...    ul_enable=${False}    dl_enable=${True}    total_count=${300}    process_num=${16}
#     ...    exp_dl_tp=${exp_dl_peak}    ue_index=${mmw_ue_index}
#     run keyword and continue on failure    L3 call    protocol=tcp    log_time=${peak_log_time}
#     ...    ul_enable=${True}    dl_enable=${True}     total_count=${300}    process_num=${16}
#     ...    exp_ul_tp=${exp_ul_peak}    exp_dl_tp=${exp_dl_peak}    ue_index=${mmw_ue_index}
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]TC16_RRM_UE_Attach_Success_Rate
#     [Tags]       CDRT_TRUNK
# #    Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
#     [Documentation]    pengliang.wu@nokia-sbell.com
#     [Setup]    Gnb common case setup
#     FOR    ${i}    IN RANGE    ${10}
#         Log To Console    round ${i} UE attach..
#         ${result}    Run Keyword And Return Status    UE attach by Spark by Index    ue_index=${mmw_ue_index}
#         ...    try_time=${1}
#         run keyword and continue on failure    Should Be True    ${result}
#         Run Keyword And Ignore error    samsung_spark.detach_ue    ue_alias=UE_${mmw_ue_index}
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]TC19_RRM_Single_UE_DL_UL_DL+UL_TCP_Tput_Peak_cmW
#     [Documentation]    shanshan.zhang@nokia-sbell.com
#     [Setup]    Gnb common case setup
#     run keyword and continue on failure    L3 call    protocol=tcp    log_time=${peak_log_time}    ul_enable=${True}
#     ...    dl_enable=${False}    total_count=${300}    exp_ul_tp=${cmw_exp_ul}    exp_dl_tp=${cmw_exp_dl}
#     ...    ue_index=${cmw_ue_index}    ul_list=@{cmw_ulcell_list}    dl_list=@{cmw_dlcell_list}
#     run keyword and continue on failure    L3 call    protocol=tcp    log_time=${peak_log_time}    ul_enable=${False}
#     ...    dl_enable=${True}    total_count=${300}    exp_ul_tp=${cmw_exp_ul}    exp_dl_tp=${cmw_exp_dl}
#     ...    ue_index=${cmw_ue_index}    ul_list=@{cmw_ulcell_list}    dl_list=@{cmw_dlcell_list}
#     ...    process_num=${16}
#     run keyword and continue on failure    L3 call    protocol=tcp    log_time=${peak_log_time}    ul_enable=${True}
#     ...    dl_enable=${True}    total_count=${300}    exp_ul_tp=${cmw_exp_ul}    exp_dl_tp=${cmw_exp_dl}
#     ...    ue_index=${cmw_ue_index}    ul_list=@{cmw_ulcell_list}    dl_list=@{cmw_dlcell_list}
#     ...    process_num=${16}
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# *** Keywords ***
# Suit setup for e2e gNB
#     CI_Common_Suit_Setup
#     Adapt to ute cloud commission scf
#     Set Suit Variables for different testline
#     Get SBTS Release Version
# 
# Gnb common case setup
#     CI_Common_Case_Setup
#     Check BTS Should Be Normal
# 
# Set Suit Variables for different testline
#     ${dlcell_list}    Set Variable    ${TestLineList['${TLNAME}']['mmw_dlcell_list']}
#     ${ulcell_list}    Set Variable    ${TestLineList['${TLNAME}']['mmw_ulcell_list']}
#     ${cell_info_List}    Set Variable    ${TestLineList['${TLNAME}']['mmw_lcrid_list']}
#     ${tcpdump_interface}    Set Variable    ${TestLineList['${TLNAME}']['tcpdump_interface']}
#     ${RMOD_List}    Set Variable    ${TestLineList['${TLNAME}']['RMOD_list']}
#     ${BBMOD_List}    Set Variable    ${TestLineList['${TLNAME}']['BBMOD_list']}
#     ${break_SRF}    Set Variable    ${TestLineList['${TLNAME}']['break_SRF']}
#     ${exp_ul}    Set Variable    ${TestLineList['${TLNAME}']['mmw_tput_ul_non_peak_exp']}
#     ${exp_dl}    Set Variable    ${TestLineList['${TLNAME}']['mmw_tput_dl_non_peak_exp']}
#     ${ul_tput_udp}    Set Variable    ${TestLineList['${TLNAME}']['mmw_tput_ul_non_peak_sent']}
#     ${dl_tput_udp}    Set Variable    ${TestLineList['${TLNAME}']['mmw_tput_dl_non_peak_sent']}
#     ${exp_ul_peak}    Set Variable    ${TestLineList['${TLNAME}']['mmw_tput_ul_peak_exp']}
#     ${exp_dl_peak}    Set Variable    ${TestLineList['${TLNAME}']['mmw_tput_dl_peak_exp']}
#     ${ul_tput_udp_peak}    Set Variable    ${TestLineList['${TLNAME}']['mmw_tput_ul_peak_sent']}
#     ${dl_tput_udp_peak}    Set Variable    ${TestLineList['${TLNAME}']['mmw_tput_dl_peak_sent']}
#     ${mmw_ue_index}    Set Variable    ${TestLineList['${TLNAME}']['mmw_used_ue_index']}
#     ${cmw_ue_index}    Set Variable    ${TestLineList['${TLNAME}']['cmw_used_ue_index']}
#     ${cmw_ulcell_list}    Set Variable    ${TestLineList['${TLNAME}']['cmw_ulcell_list']}
#     ${cmw_dlcell_list}    Set Variable    ${TestLineList['${TLNAME}']['cmw_dlcell_list']}
# 
#     Set Suite Variable     ${break_SRF}
#     Set Suite Variable     ${BBMOD_List}
#     Set Suite Variable     ${RMOD_List}
#     Set Suite Variable     ${cell_info_List}
#     Set Suite Variable     ${dlcell_list}
#     Set Suite Variable     ${ulcell_list}
#     Set Suite Variable     ${tcpdump_interface}
#     Set Suite Variable     ${exp_ul}
#     Set Suite Variable     ${exp_dl}
#     Set Suite Variable     ${ul_tput_udp}
#     Set Suite Variable     ${dl_tput_udp}
#     Set Suite Variable     ${exp_ul_peak}
#     Set Suite Variable     ${exp_dl_peak}
#     Set Suite Variable     ${ul_tput_udp_peak}
#     Set Suite Variable     ${dl_tput_udp_peak}
#     Set Suite Variable     ${mmw_ue_index}
#     Set Suite Variable     ${cmw_ue_index}
#     Set Suite Variable     ${cmw_ulcell_list}
#     Set Suite Variable     ${cmw_dlcell_list}
