# *** Settings ***
# Suite Setup     Get SBTS Release Version
# Force Tags    PY36
# Documentation
# ...   author: shengrong.rao@nokia-sbell.com
# ...   contact: shengrong.rao@nokia-sbell.com
# ...   PM Operability
# 
# Resource    resources/comm_keyword.robot
# Resource    resources/comm_case_keyword.robot
# Resource    ../5GC001937_OTA/resources/5GC001937_mmw4_common_keyword.robot
# Variables   ../5GC001937_OTA/resources/5GC001937_mmw4_modify_para.py
# 
# *** Variables ***
# ${duration}         ${1800}
# ${ul_tput_udp}          300M
# ${dl_tput_udp}          2200M
# ${ul_tput_tcp}          30M
# ${dl_tput_tcp}          100M
# ${log_time}             1m
# ${exp_ul}               ${204}
# ${exp_dl}               ${2020}
# ${exp_ul_dmrs}          ${195}
# ${exp_dl_dmrs}          ${1950}
# ${cmw_exp_ul}           ${70}
# ${cmw_exp_dl}           ${1400}
# ${deviation}            3%
# ${total_count}          ${600}
# ${enb_mrbts}            5531
# ${enb_lnbts}            5531
# @{dlcell_list}        186089473    186089474    186089475    186089476
# @{ulcell_list}        186089473    186089474
# @{cmw_ulcell_list}    186089703
# @{cmw_dlcell_list}    186089703
# ${LTE_index}            ${0}
# ${mmw_cell_group}        NRCELLGRP-2
# ${cmw_cell_group}        NRCELLGRP-4
# 
# *** Test Cases ***
# [1]E2E_TL_SW_upgrade_rollback_with_sleeping_cell_check
#     [Documentation]
#     ...    -02.03.2023,pengliang.wu@nokia-sbell.com,case draft
#     Get BTS Software Version
#     ${selectue_index}    Select which UE to test
#     Set Test Variable    ${test_round}    3
#     FOR    ${count}    IN RANGE    ${test_round}
#         ${result}    Run Keyword And Return Status    Gnb upgraded via WEBUI    ue_index=${selectue_index}    protocol=udp
#         ...    index=${count}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#         run keyword and continue on failure    Should Be True    ${result}
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]CB007835-5G-B-SyVe_Key_customer_scenario_testing_for_P8-5G21B-KDDI-TDD_mmW
#     [Documentation]
#     ...    -23.03.2021,shengrong.rao@nokia-sbell.com,case draft
#     [Tags]    CIT_22R1
#     [Setup]    Check All Cells in Cell Group Should Be on air    cell_grp_name=${mmw_cell_group}
#     Get BTS Software Version
#     ${selectue_index}    Select which UE to test
#     run keyword and continue on failure    L3 call    protocol=udp    log_time=15m    ue_index=${selectue_index}
#     ...    ul_enable=${True}    dl_enable=${False}    total_count=${4200}
#     run keyword and continue on failure    L3 call    protocol=udp    log_time=15m    ue_index=${selectue_index}
#     ...    ul_enable=${False}    dl_enable=${True}    total_count=${4200}
#     run keyword and continue on failure    L3 call    protocol=udp    log_time=15m    ue_index=${selectue_index}
#     ...    ul_enable=${True}    dl_enable=${True}    total_count=${4200}
#     run keyword and continue on failure    L3 call    protocol=tcp    log_time=15m    ue_index=${selectue_index}
#     ...    ul_enable=${True}    dl_enable=${False}    total_count=${4200}
#     run keyword and continue on failure    L3 call    protocol=tcp    log_time=15m    ue_index=${selectue_index}
#     ...    ul_enable=${False}    dl_enable=${True}    total_count=${4200}    process_num=${16}
#     run keyword and continue on failure    L3 call    protocol=tcp    log_time=15m    ue_index=${selectue_index}
#     ...    ul_enable=${True}    dl_enable=${True}     total_count=${4200}    process_num=${16}
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]CB007835-5G-B-SyVe_Key_customer_scenario_testing_for_OAM-KDDI-TDD_mmW_01
#     [Documentation]
#     ...    -23.03.2021,shengrong.rao@nokia-sbell.com,case draft
#     [Tags]    CIT_22R1
#     [Setup]    Check BTS Should Be Normal
#     ${selectue_index}    Select which UE to test
#     run keyword and continue on failure    Site reset stability    ue_index=${selectue_index}
#     run keyword and continue on failure    LED status check after site reset
#     run keyword and continue on failure    RF module reset    ue_index=${selectue_index}
#     run keyword and continue on failure    All configured NRCells lock and unlock stability testing    ue_index=${selectue_index}
#     run keyword and continue on failure    NRCell group lock and unlock stability testing    ue_index=${selectue_index}
#     run keyword and continue on failure    Each RF module lock and unlock    ue_index=${selectue_index}
#     run keyword and continue on failure    RF module poweroff on    ue_index=${selectue_index}
#     run keyword and continue on failure    Save Snapshot Log
#     run keyword and continue on failure    X2 link lock and unlock    ue_index=${selectue_index}
#     run keyword and continue on failure    Each single Baseband module reset
#     run keyword and continue on failure    Each single Baseband module lock and unlock
#     run keyword and continue on failure    4G site reset
#     run keyword and continue on failure    Configuration backup
#     run keyword and continue on failure    parameter pdl check
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]CB007835-5G-B-SyVe_Key_customer_scenario_testing_for_OAM-KDDI-TDD_mmW_02
#     [Documentation]
#     ...    -23.10.2021,shengrong.rao@nokia-sbell.com,case draft
#     [Tags]    CIT_22R1
#     [Setup]    Check BTS Should Be Normal
#     ${selectue_index}    Select which UE to test
#     run keyword and continue on failure    Site reset stability    ue_index=${selectue_index}
#     run keyword and continue on failure    LED status check after site reset
#     run keyword and continue on failure    RF module reset    ue_index=${selectue_index}
#     run keyword and continue on failure    All configured NRCells lock and unlock stability testing    ue_index=${selectue_index}
#     run keyword and continue on failure    NRCell group lock and unlock stability testing    ue_index=${selectue_index}
#     run keyword and continue on failure    Each RF module lock and unlock    ue_index=${selectue_index}
#     run keyword and continue on failure    RF module poweroff on    ue_index=${selectue_index}
#     run keyword and continue on failure    Save Snapshot Log
#     run keyword and continue on failure    X2 link lock and unlock    ue_index=${selectue_index}
#     run keyword and continue on failure    Each single Baseband module reset
#     run keyword and continue on failure    Each single Baseband module lock and unlock
#     run keyword and continue on failure    4G site reset
#     run keyword and continue on failure    Configuration backup
#     run keyword and continue on failure    parameter pdl check
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]CB007835-5G-B-SyVe_Key_customer_scenario_testing_for_OAM-KDDI-TDD_mmW_03
#     [Documentation]
#     ...    -23.10.2021,shengrong.rao@nokia-sbell.com,case draft
#     [Tags]    CIT_22R1
#     [Setup]    Check BTS Should Be Normal
#     ${selectue_index}    Select which UE to test
#     run keyword and continue on failure    Site reset stability    ue_index=${selectue_index}
#     run keyword and continue on failure    LED status check after site reset
#     run keyword and continue on failure    RF module reset    ue_index=${selectue_index}
#     run keyword and continue on failure    All configured NRCells lock and unlock stability testing    ue_index=${selectue_index}
#     run keyword and continue on failure    NRCell group lock and unlock stability testing    ue_index=${selectue_index}
#     run keyword and continue on failure    Each RF module lock and unlock    ue_index=${selectue_index}
#     run keyword and continue on failure    RF module poweroff on    ue_index=${selectue_index}
#     run keyword and continue on failure    Save Snapshot Log
#     run keyword and continue on failure    X2 link lock and unlock    ue_index=${selectue_index}
#     run keyword and continue on failure    Each single Baseband module reset
#     run keyword and continue on failure    Each single Baseband module lock and unlock
#     run keyword and continue on failure    4G site reset
#     run keyword and continue on failure    Configuration backup
#     run keyword and continue on failure    parameter pdl check
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]CB007835-5G-B-SyVe_Key_customer_scenario_testing_for_OAM-KDDI-TDD_mmW_04
#     [Documentation]
#     ...    -23.03.2021,shengrong.rao@nokia-sbell.com,case draft
#     [Tags]    CIT_22R1
#     [Setup]    Check BTS Should Be Normal
#     ${selectue_index}    Select which UE to test
#     run keyword and continue on failure    Site reset stability    ue_index=${selectue_index}
#     run keyword and continue on failure    LED status check after site reset
#     run keyword and continue on failure    RF module reset    ue_index=${selectue_index}
#     run keyword and continue on failure    All configured NRCells lock and unlock stability testing    ue_index=${selectue_index}
#     run keyword and continue on failure    NRCell group lock and unlock stability testing    ue_index=${selectue_index}
#     run keyword and continue on failure    Each RF module lock and unlock    ue_index=${selectue_index}
#     run keyword and continue on failure    RF module poweroff on    ue_index=${selectue_index}
#     run keyword and continue on failure    Save Snapshot Log
#     run keyword and continue on failure    X2 link lock and unlock    ue_index=${selectue_index}
#     run keyword and continue on failure    Each single Baseband module reset
#     run keyword and continue on failure    Each single Baseband module lock and unlock
#     run keyword and continue on failure    4G site reset
#     run keyword and continue on failure    Configuration backup
#     run keyword and continue on failure    parameter pdl check
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]CB007835-5G-B-SyVe_Key_customer_scenario_testing_for_OAM-KDDI-TDD_mmW_05
#     [Documentation]
#     ...    -23.03.2021,shengrong.rao@nokia-sbell.com,case draft
#     [Tags]    CIT_22R1
#     [Setup]    Check BTS Should Be Normal
#     ${selectue_index}    Select which UE to test
#     run keyword and continue on failure    Site reset stability    ue_index=${selectue_index}    pcmd=${True}
#     run keyword and continue on failure    LED status check after site reset
#     run keyword and continue on failure    RF module reset    ue_index=${selectue_index}    pcmd=${True}
#     run keyword and continue on failure    All configured NRCells lock and unlock stability testing    ue_index=${selectue_index}    pcmd=${True}
#     run keyword and continue on failure    NRCell group lock and unlock stability testing    ue_index=${selectue_index}
#     run keyword and continue on failure    Each RF module lock and unlock    ue_index=${selectue_index}
#     run keyword and continue on failure    Save Snapshot Log
#     run keyword and continue on failure    X2 link lock and unlock    ue_index=${selectue_index}
#     run keyword and continue on failure    4G site reset    ue_index=${selectue_index}    pcmd=${True}
#     run keyword and continue on failure    Each single Baseband module reset
#     run keyword and continue on failure    Each single Baseband module lock and unlock
#     run keyword and continue on failure    Configuration backup
#     run keyword and continue on failure    parameter pdl check
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]CB007834-5G-B-SyVe_Key_customer_scenario_testing_for_P8-5G21B-KDDI-TDD_mmW_with_DMRS
#     [Documentation]
#     ...    -23.03.2021,shengrong.rao@nokia-sbell.com,case draft
#     [Tags]    CRT_22R1
#     [Setup]    Check BTS Should Be Normal
#     ${selectue_index}    Select which UE to test
#     DMRS parameters modfiy
#     Check BTS Should Be Normal
#     run keyword and continue on failure    L3 call    protocol=udp    log_time=5m    ul_enable=${True}    dl_enable=${False}
#     ...    total_count=${1300}    exp_ul_tp=${exp_ul_dmrs}    exp_dl_tp=${exp_dl_dmrs}    ue_index=${selectue_index}
#     run keyword and continue on failure    L3 call    protocol=udp    log_time=5m    ul_enable=${False}    dl_enable=${True}
#     ...    total_count=${1300}    exp_ul_tp=${exp_ul_dmrs}    exp_dl_tp=${exp_dl_dmrs}    ue_index=${selectue_index}
#     run keyword and continue on failure    L3 call    protocol=udp    log_time=5m    ul_enable=${True}    dl_enable=${True}
#     ...    total_count=${1300}    exp_ul_tp=${exp_ul_dmrs}    exp_dl_tp=${exp_dl_dmrs}    ue_index=${selectue_index}
#     run keyword and continue on failure    L3 call    protocol=tcp    log_time=5m    ul_enable=${True}    dl_enable=${False}
#     ...    total_count=${1300}    exp_ul_tp=${exp_ul_dmrs}    exp_dl_tp=${exp_dl_dmrs}    ue_index=${selectue_index}
#     run keyword and continue on failure    L3 call    protocol=tcp    log_time=5m    ul_enable=${False}    dl_enable=${True}
#     ...    total_count=${1300}    exp_ul_tp=${exp_ul_dmrs}    exp_dl_tp=${exp_dl_dmrs}    ue_index=${selectue_index}    process_num=${16}
#     run keyword and continue on failure    L3 call    protocol=tcp    log_time=5m    ul_enable=${True}    dl_enable=${True}
#     ...    total_count=${1300}    exp_ul_tp=${exp_ul_dmrs}    exp_dl_tp=${exp_dl_dmrs}    ue_index=${selectue_index}    process_num=${16}
#     [Teardown]    DMRS parameters recover
# 
# [1]CB007835-5G-B-SyVe_Key_customer_scenario_testing_for_cmW_peak
#     [Documentation]
#     ...    -23.03.2021,shengrong.rao@nokia-sbell.com,case draft
#     [Tags]    CRT_22R1
#     [Setup]    Cmw env setup    cell_grp_name=${cmw_cell_group}
#     Get BTS Software Version
#     run keyword and continue on failure    L3 call    protocol=udp    log_time=15m    ul_enable=${True}    dl_enable=${False}
#     ...    total_count=${4200}    exp_ul_tp=${cmw_exp_ul}    exp_dl_tp=${cmw_exp_dl}    ue_index=${1}
#     ...    ul_list=@{cmw_ulcell_list}    dl_list=@{cmw_ulcell_list}
#     run keyword and continue on failure    L3 call    protocol=udp    log_time=15m    ul_enable=${False}    dl_enable=${True}
#     ...    total_count=${4200}    exp_ul_tp=${cmw_exp_ul}    exp_dl_tp=${cmw_exp_dl}    ue_index=${1}
#     ...    ul_list=@{cmw_ulcell_list}    dl_list=@{cmw_ulcell_list}
#     run keyword and continue on failure    L3 call    protocol=udp    log_time=15m    ul_enable=${True}    dl_enable=${True}
#     ...    total_count=${4200}    exp_ul_tp=${cmw_exp_ul}    exp_dl_tp=${cmw_exp_dl}    ue_index=${1}
#     ...    ul_list=@{cmw_ulcell_list}    dl_list=@{cmw_ulcell_list}
#     run keyword and continue on failure    L3 call    protocol=tcp    log_time=15m    ul_enable=${True}    dl_enable=${False}
#     ...    total_count=${4200}    exp_ul_tp=${cmw_exp_ul}    exp_dl_tp=${cmw_exp_dl}    ue_index=${1}
#     ...    ul_list=@{cmw_ulcell_list}    dl_list=@{cmw_ulcell_list}
#     run keyword and continue on failure    L3 call    protocol=tcp    log_time=15m    ul_enable=${False}    dl_enable=${True}
#     ...    total_count=${4200}    exp_ul_tp=${cmw_exp_ul}    exp_dl_tp=${cmw_exp_dl}    ue_index=${1}
#     ...    ul_list=@{cmw_ulcell_list}    dl_list=@{cmw_ulcell_list}    process_num=${16}
#     run keyword and continue on failure    L3 call    protocol=tcp    log_time=15m    ul_enable=${True}    dl_enable=${True}
#     ...    total_count=${4200}    exp_ul_tp=${cmw_exp_ul}    exp_dl_tp=${cmw_exp_dl}    ue_index=${1}
#     ...    ul_list=@{cmw_ulcell_list}    dl_list=@{cmw_ulcell_list}    process_num=${16}
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]CB007835-5G-B-SyVe_Key_customer_scenario_testing_for_pcmd
#     [Documentation]
#     ...    -23.03.2021,shengrong.rao@nokia-sbell.com,case draft
#     [Tags]    CRT_22R1
#     [Setup]    Check BTS Should Be Normal
#     ${selectue_index}    Select which UE to test
#     run keyword and continue on failure    Site reset stability    ue_index=${selectue_index}    pcmd=${True}
#     run keyword and continue on failure    RF module reset    ue_index=${selectue_index}    pcmd=${True}
#     run keyword and continue on failure    All configured NRCells lock and unlock stability testing    ue_index=${selectue_index}    pcmd=${True}
#     run keyword and continue on failure    Each RF module lock and unlock    ue_index=${selectue_index}    pcmd=${True}
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]E2E_Reset_with_HWF_deletion
#     [Documentation]
#     ...    -23.03.2021,shengrong.rao@nokia-sbell.com,case draft
#     [Tags]    CIT_22R1
#     [Setup]    Check BTS Should Be Normal
#     FOR    ${i}    IN RANGE    ${1}
#         Log To Console    round ${i} Stability Reset with HWF deletion start..
#         ${result}    Run Keyword And Return Status    Stability Reset with HWF deletion TL729
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]TC04_General_SiSo_BTS_block_unblock_L3Call
#     [Documentation]    shanshan.zhang@nokia-sbell.com
#     [Setup]    Check BTS Should Be Normal
#     ${selectue_index}    Select which UE to test
#     Set Test Variable    ${selectue_index}
#     FOR    ${i}    IN RANGE    ${5}
#         Log To Console    round ${i} Stability Reset with HWF deletion start..
#         ${result}    Run Keyword And Return Status    Separately_site_block_unblock_then_L3call
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]TC11_General_SiSo_Filber_break_L3Call
#     [Documentation]    shanshan.zhang@nokia-sbell.com
#     [Setup]    Check BTS Should Be Normal
#     ${selectue_index}    Select which UE to test
#     Set Test Variable    ${selectue_index}
#     FOR    ${i}    IN RANGE    ${5}
#         Log To Console    round ${i} Separately Filber break then L3call
#         ${result}    Run Keyword And Return Status    Separately Filber break then L3call
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]TC12_General_OAM_mmWave_cell_delete_and_mmWave_cell_add_L3Call
#     [Documentation]    shanshan.zhang@nokia-sbell.com
#     [Setup]    Check BTS Should Be Normal
#     ${selectue_index}    Select which UE to test
#     Set Test Variable    ${selectue_index}
#     FOR    ${i}    IN RANGE    ${5}
#         Log To Console    round ${i} OAM_mmWave_cell_delete_and_mmWave_cell_add_L3Call
#         ${result}    Run Keyword And Return Status    Run keywords    comm_case_keyword.Online Cell addition deletion
#         ...    addition_deletion_cellgrp=2       AND
#         ...    run keyword and continue on failure    L3 call    protocol=udp    log_time=3m    ue_index=${selectue_index}
#         ...    ul_enable=${True}    dl_enable=${True}    total_count=${4200}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]E2E_Reset_with_HWF_deletion_with_sleeping_cell_check
#     [Documentation]
#     ...    -02.06.2023,pengliang.wu@nokia-sbell.com,case draft
#     [Setup]    Check BTS Should Be Normal
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${3}
#         Log To Console    round ${i} Reset start..
#         ${selectue_index}    Select which UE to test
#         ${result}    Run Keyword And Return Status    Stability Reset with HWF deletion TL729
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword and continue on failure    L3 call    ue_index=${selectue_index}
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]E2E_TL_Cell_Lock_Unlock_NR_with_sleeping_cell_check
#     [Documentation]
#     ...    -02.06.2023,pengliang.wu@nokia-sbell.com,case draft
#     [Setup]    Check BTS Should Be Normal
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${3}
#         Log To Console    round ${i} cell lock/unlock start..
#         ${selectue_index}    Select which UE to test
#         ${result}    Run Keyword And Return Status    All configured NRCells lock and unlock stability testing
#         ...    ue_index=${selectue_index}    pcmd=${True}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#         run keyword and continue on failure    Should Be True    ${result}
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]E2E_TL_Cell_Bock_Unblock_NR_with_sleeping_cell_check
#     [Documentation]
#     ...    -shanshan.zhang@nokia-sbell.com
#     ...    [1]TC01_General_SiSo_Cell_block_and_unblock_L3Call_and_pcmd_check
#     [Setup]    Check BTS Should Be Normal
#     Get BTS Software Version
#     ${selectue_index}    Select which UE to test
#     Set Test Variable    ${selectue_index}
#     FOR    ${i}    IN RANGE    ${3}
#         Log To Console    round ${i} NR cell block and unblock start..
#         ${result}    Run Keyword And Return Status    Separately_CELL_block_unblock_then_L3call    pcmd=${True}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]E2E_TL_Delta_Commissioning_With_Site_Reset_Required_sleeping_cell_check
#     [Documentation]
#     ...    -02.06.2023,pengliang.wu@nokia-sbell.com,case draft
#     [Setup]    Check BTS Should Be Normal
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${3}
#         Log To Console    round ${i} change parameter which need bts restart.
#         ${selectue_index}    Select which UE to test
#         ${result}    Run Keyword And Return Status    Change parameter which need bts restart
#         ...    ue_index=${selectue_index}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# *** Keywords ***
