# *** Settings ***
# Suite Setup     Get SBTS Release Version
# Force Tags    PY36
# Documentation
# ...   author: shengrong.rao@nokia-sbell.com
# ...   contact: shengrong.rao@nokia-sbell.com
# ...   PM Operability
# 
# Resource    resources/comm_keyword_TL738.robot
# Resource    resources/comm_case_keyword.robot
# Resource    ../5GC001937_OTA/resources/5GC001937_mmw4_common_keyword.robot
# Variables   ../5GC001937_OTA/resources/5GC001937_mmw4_modify_para.py
# 
# *** Variables ***
# ${duration}             ${1800}
# ${ul_tput_udp}          300M
# ${dl_tput_udp}          2200M
# ${ul_tput_tcp}          30M
# ${dl_tput_tcp}          100M
# ${log_time}             1m
# ${exp_ul}               ${204}
# ${exp_dl}               ${2020}
# ${exp_ul_dmrs}          ${195}
# ${exp_dl_dmrs}          ${1950}
# ${total_count}          ${600}
# @{dlcell_list}          12091413    12091414    12091415    12091416
# @{ulcell_list}          12091413    12091414
# 
# ${LTE_index}            ${1}
# @{SMOD_list}            ${1}
# @{BBMOD_list}           ${1}    ${2}
# @{RMOD_list}            ${2}    ${3}
# @{cell_info_List}       ${21}    ${22}    ${23}    ${24}
# 
# *** Test Cases ***
# [1]TC01_General_SiSo_Cell_block_and_unblock_L3Call_and_pcmd_check
#     [Documentation]    shanshan.zhang@nokia-sbell.com
#     [Setup]    Check BTS Should Be Normal
#     FOR    ${i}    IN RANGE    ${5}
#         Log To Console    round ${i} Separately_CELL_block_unblock_then_L3call
#         ${result}    Run Keyword And Return Status    Separately_CELL_block_unblock_then_L3call
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]TC02_General_SiSo_RU_lock_unlock_L3Call
#     [Tags]       CDRT_TRUNK
#     [Setup]    Check BTS Should Be Normal
#     FOR    ${i}    IN RANGE    ${5}
#         ${result}    Run Keyword And Return Status    Each RF module lock and unlock    ue_index=${0}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]TC03_General_SiSo_BBMOD_lock_unlock_L3Call
#     [Tags]       CDRT_TRUNK
#     [Setup]    Check BTS Should Be Normal
#     ${selectue_index}    Select which UE to test
#     FOR    ${i}    IN RANGE    ${5}
#         ${result}    Run Keyword And Return Status    Each single Baseband module lock and unlock    list=${BBMOD_list}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]TC04_General_SiSo_BTS_block_unblock_L3Call
#     [Documentation]    shanshan.zhang@nokia-sbell.com
#     [Setup]    Check BTS Should Be Normal
#     FOR    ${i}    IN RANGE    ${5}
#         Log To Console    round ${i} Separately_site_block_unblock_then_L3call
#         ${result}    Run Keyword And Return Status    Separately_site_block_unblock_then_L3call
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]TC07_General_SiSo_RF_module_power_reset_L3Call
#     [Tags]    CDRT_TRUNK
#     [Setup]    Check BTS Should Be Normal
#     ${selectue_index}    Select which UE to test
#     FOR    ${i}    IN RANGE    ${5}
#         ${result}    Run Keyword And Return Status     RF module poweroff on    ue_index=${0}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]TC08_General_SiSo_RF_module_WebGUI_reset_L3Call
#     [Tags]      CDRT_TRUNK
#     [Setup]    Check BTS Should Be Normal
#     ${selectue_index}    Select which UE to test
#     FOR    ${i}    IN RANGE    ${5}
#         ${result}    Run Keyword And Return Status    RF module reset    ue_index=${0}    RU_index_list=${RMOD_list}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]TC09_General_SiSo_BBMOD_reset_L3Call
#     [Tags]        CDRT_TRUNK
#     [Setup]    Check BTS Should Be Normal
#     FOR    ${i}    IN RANGE    ${5}
#         ${result}    Run Keyword And Return Status     Each single Baseband module reset    list=${BBMOD_list}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]TC17_RRM_Single_UE_DL_UL_DL+UL_TCP_Tput_Peak_mmW
#     [Documentation]
#     ...    -23.03.2021,shengrong.rao@nokia-sbell.com,case draft
#     [Tags]      CDRT_TRUNK
#     [Setup]    Check BTS Should Be Normal
#     run keyword and continue on failure    L3 call    protocol=udp    log_time=15m    ue_index=${0}
#     ...    ul_enable=${True}    dl_enable=${False}    total_count=${4200}
#     run keyword and continue on failure    L3 call    protocol=udp    log_time=15m    ue_index=${0}
#     ...    ul_enable=${False}    dl_enable=${True}    total_count=${4200}
#     run keyword and continue on failure    L3 call    protocol=udp    log_time=15m    ue_index=${0}
#     ...    ul_enable=${True}    dl_enable=${True}    total_count=${4200}
#     run keyword and continue on failure    L3 call    protocol=tcp    log_time=15m    ue_index=${0}
#     ...    ul_enable=${True}    dl_enable=${False}    total_count=${4200}
#     run keyword and continue on failure    L3 call    protocol=tcp    log_time=15m    ue_index=${0}
#     ...    ul_enable=${False}    dl_enable=${True}    total_count=${4200}
#     run keyword and continue on failure    L3 call    protocol=tcp    log_time=15m    ue_index=${0}
#     ...    ul_enable=${True}    dl_enable=${True}    total_count=${4200}
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]TC16_RRM_UE_Attach_Success_Rate
#     [Tags]       CDRT_TRUNK
#     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
# 
# *** Keywords ***
