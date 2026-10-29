# *** Settings ***
# Suite Setup     Suite Setup
# Suite Teardown    Suite Teardown
# 
# Documentation
# ...   author: pengliang.wu@nokia-sbell.com
# ...   contact: pengliang.wu@nokia-sbell.com
# ...   CB007835-5G-B-SyVe_Key_customer_scenario_testing_for-KDDI-E2E_eNB_Cases
# 
# Resource     ./resources/common_keywords.robot
# Resource     ../5GC001937_OTA/resources/5GC001937_mmw4_common_keyword.robot
# Variables    ../5GC001937_OTA/resources/5GC001937_mmw4_modify_para.py
# Variables    ./resources/modify_para.py
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# *** Variables ***
# ${testline_name}
# ${test_iteration}       ${1}   #testing numbers
# ${duration}             ${1800}
# ${ul_tput_udp}          20M
# ${dl_tput_udp}          20M
# ${log_time}             1m
# ${exp_ul}               ${5}
# ${exp_dl}               ${5}
# ${total_count}          ${100}
# @{SMOD_list}            ${1}
# @{BBMOD_list}           ${1}
# @{RMOD_list}            ${1}
# @{row_list}              NR PDCP Thr. DL [Mbps]    NR PDCP Thr. UL [Mbps]    NR PDSCH iBLER[%]    NR PUSCH iBLER[%]
# 
# 
# *** Test Cases ***
# [1]General_SiSo_eNB_State_Management-eNB_reset_with_L3_call
#     [Tags]    Trunk
#     [Setup]   Enb common case setup
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} 4G site reset
#         ${result}    Run Keyword And Return Status    4G site reset
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword and continue on failure    ENB L3 call    protocol=udp    log_time=2m    ul_enable=${True}    dl_enable=${True}
#         ...    total_count=${total_count}    exp_ul_tp=${exp_ul}    exp_dl_tp=${exp_dl}    ue_index=${enb_ue_index}
#         ...    ul_list=@{enb_ulcell_list}    dl_list=@{enb_dlcell_list}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]General_SiSo_eNB_State_Management-Cell_lock_and_unlock_with_L3_call
#     [Tags]    Trunk
#     [Documentation]
#     ...    -02.06.2023,pengliang.wu@nokia-sbell.com,case draft
#     [Setup]   Enb common case setup
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} 4G CELL Lock Unlock then L3call
#         ${result}    Run Keyword And Return Status    4G CELL Lock Unlock then L3call
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword and continue on failure    run keyword if   ${result}     ENB L3 call
#         ...    protocol=udp    log_time=2m    ul_enable=${True}    dl_enable=${True}
#         ...    total_count=${total_count}    exp_ul_tp=${exp_ul}    exp_dl_tp=${exp_dl}    ue_index=${enb_ue_index}
#         ...    ul_list=@{enb_ulcell_list}    dl_list=@{enb_dlcell_list}
#         run keyword if    '${result}'!='${True}'
#         ...    run keyword and continue on failure    Save Snapshot Log    ip_address=${eNB_DU_OAM_IP}
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]General_SiSo_eNB_State_Management-RU_lock_and_unlock_with_L3_call
#     [Tags]    Trunk
#     [Setup]   Enb common case setup
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} 4G RU Lock Unlock then L3call
#         ${result}    Run Keyword And Return Status    4G RU Lock Unlock then L3call
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword and continue on failure    run keyword if   ${result}     ENB L3 call
#         ...    protocol=udp    log_time=2m    ul_enable=${True}    dl_enable=${True}
#         ...    total_count=${total_count}    exp_ul_tp=${exp_ul}    exp_dl_tp=${exp_dl}    ue_index=${enb_ue_index}
#         ...    ul_list=@{enb_ulcell_list}    dl_list=@{enb_dlcell_list}
#         run keyword if    '${result}'!='${True}'
#         ...    run keyword and continue on failure    Save Snapshot Log    ip_address=${eNB_DU_OAM_IP}
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]General_SiSo_eNB_State_Management-RU_reset_with_L3_call
#     [Tags]    Trunk
#     [Setup]   Enb common case setup
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} ENB Reset RU And Wait Until On Air
#         ${result}    Run Keyword And Return Status    ENB Reset RU And Wait Until On Air
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if   ${result}    run keyword and continue on failure      ENB L3 call
#         ...    protocol=udp    log_time=2m    ul_enable=${True}    dl_enable=${True}
#         ...    total_count=${total_count}    exp_ul_tp=${exp_ul}    exp_dl_tp=${exp_dl}    ue_index=${enb_ue_index}
#         ...    ul_list=@{enb_ulcell_list}    dl_list=@{enb_dlcell_list}
#         run keyword if    '${result}'!='${True}'
#         ...     run keyword and continue on failure    Save Snapshot Log     ip_address=${eNB_DU_OAM_IP}
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]General_SiSo_eNB_State_Management-BBMOD_lock_and_unlock_with_L3_call
#     [Tags]    Trunk
#     [Setup]   Enb common case setup
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} ENB Lock and unlock BBMOD
#         ${result}    Run Keyword And Return Status    ENB Lock and unlock BBMOD
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if   ${result}    run keyword and continue on failure      ENB L3 call
#         ...    protocol=udp    log_time=2m    ul_enable=${True}    dl_enable=${True}
#         ...    total_count=${total_count}    exp_ul_tp=${exp_ul}    exp_dl_tp=${exp_dl}    ue_index=${enb_ue_index}
#         ...    ul_list=@{enb_ulcell_list}    dl_list=@{enb_dlcell_list}
#         run keyword if    '${result}'!='${True}'
#         ...     run keyword and continue on failure    Save Snapshot Log      ip_address=${eNB_DU_OAM_IP}
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# *** Keywords ***
# Enb common case setup
#     CI_Common_Case_Setup
#     Check BTS Should Be Normal
#     Check BTS Should Be Normal    bts_host=${eNB_DU_OAM_IP}     cell_type=lte    connection=enb
# 
# Suite Setup
#     [Arguments]  ${connection}=GNB_OAM
#     Adapt to ute cloud commission scf
#     Set Suit Variables for different testline
#     Get BTS Software Version
#     Connect to gnb coam via ssl     bts_host=${DU_OAM_IP}      connection=${connection}
#     log to console    Modify_NR_BTS_DRB_4_split_mode_To_X2U
#     Modify Common parameter via Coam      input_list=${MODIFY_Parameter_FOR_SPLIT_MODE_X2U}    connection=${connection}
#     CI_Common_Suit_Setup
#     [Teardown]  COAM Teardown gnb connections    connection=${connection}
# 
# Suite Teardown
#     [Arguments]  ${connection}=GNB_OAM
#     Connect to gnb coam via ssl     bts_host=${DU_OAM_IP}      connection=${connection}
#     log to console    Recovery_NR_BTS_DRB_4_split_mode_To_F1U
#     Modify Common parameter via Coam      input_list=${MODIFY_Parameter_FOR_SPLIT_MODE_F1U}     connection=${connection}
#     CI_Common_Suit_Teardown
#     [Teardown]  COAM Teardown gnb connections    connection=${connection}
# 
# Set Suit Variables for different testline
#     ${enb_dlcell_list}    Set Variable    ${TestLineList['${TLNAME}']['enb_used_nr_dlcell_list']}
#     ${enb_ulcell_list}    Set Variable    ${TestLineList['${TLNAME}']['enb_used_nr_ulcell_list']}
#     ${enb_ue_index}    Set Variable    ${TestLineList['${TLNAME}']['enb_used_ue_index']}
#     ${ENB_CELL_ID}    Set Variable    ${TestLineList['${TLNAME}']['enb_lcrid_list']}
#     Set Suite Variable     ${enb_dlcell_list}
#     Set Suite Variable     ${enb_ulcell_list}
#     Set Suite Variable     ${enb_ue_index}
#     Set Suite Variable     ${ENB_CELL_ID}
