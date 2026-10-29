# *** Settings ***
# Suite Setup     Suit setup for Sleeing cell
# Suite Teardown    Run Keywords    Select and setup Commission SCF
# ...               AND    CI_Common_Suit_Teardown
# 
# Documentation
# ...   author: pengliang.wu@nokia-sbell.com
# ...   contact: pengliang.wu@nokia-sbell.com
# ...   CB007835-5G-B-SyVe_Key_customer_scenario_testing_for-KDDI-E2E_Sleeping_Cell_Cases
# 
# Resource     ./resources/common_keywords.robot
# Resource    ../5GC001937_OTA/resources/5GC001937_mmw4_common_keyword.robot
# Variables   ../5GC001937_OTA/resources/5GC001937_mmw4_modify_para.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# 
# Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot
# Resource    taf/rfrl/uuf4all/resources/robot/uuf_rfrl_common_keywords.robot
# 
# *** Variables ***
# ${testline_name}
# ${target_version}
# ${ENB_BUILD}
# ${test_iteration}       ${1}   #testing numbers
# ${log_time}             1m
# ${total_count}          ${100}
# ${duration}             ${1800}
# @{row_list}             NR PDCP Thr. DL [Mbps]    NR PDCP Thr. UL [Mbps]    NR PDSCH iBLER[%]    NR PUSCH iBLER[%]
# ${non_peak_target_avg_percent}    ${0.5}
# ${stay_target_build}    ${True}
# 
# ${STOP_FIX}               ${False}
# ${should_be_reported}     ${False}
# 
# *** Test Cases ***
# [1]E2E_TL_SW_Upgrade_Rollback_With_Oam_Kpi
#     [Tags]    UTE_Cloud
#     [Documentation]
#     ...    -02.03.2023,pengliang.wu@nokia-sbell.com,case draft
#     [Setup]    OAM KPI common case setup
#     Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Clear Kpi Results
#     @{loop_results}=    Create List
#     Set Test Variable  ${LOOP_RESULTS}
#     ${should_be_reported}    Set Variable    ${True}
# 
#     ${Is_need_rollback}    BTS_whether_need_rollback_before_upgrade
#     run keyword if    ${Is_need_rollback}==${True}    Classical gNB Software Rollback successfully via WebUI
# 
#     Log to console    ------Before upgrade------
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         admin.Teardown All Aliases For Admin
#         uuf_rfrl_common_keywords.Get Iteration Start Time
#         uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
# 
#         Log To Console    round ${i} Upgrade and Rollback start..
#         ${result}    Run Keyword And Return Status    Gnb upgraded via WEBUI    ue_index=${mmw_ue_index}
#         run keyword and continue on failure    Should Be True    ${result}
# 
#         ${result}    run keyword if    '${result}'=='${True}'    Set Variable    PASS
#         ...    ELSE    Set Variable    FAIL
#         ${test_run_status}=  uuf_rfrl_common.Evaluate Test Run Results  ${result}
#         Append To List    ${loop_results}    ${test_run_status}
#         uuf_rfrl_common_keywords.Get Iteration End Time
#         uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=Loop_${i}
#     END
#     Log to console    ------After upgrade------
#     Get BTS Software Version
#     Get SBTS Release Version
#     run keyword if    ${stay_target_build}==${True}    SWM supports provision SW build package via WebUI
#     Run Keyword And Ignore Error    OperatingSystem.Empty Directory    ${SW_build_path}
# 
#     List Should Not Contain Value    ${loop_results}    failed
#     uuf_rfrl_common_keywords.Pass Ratio    ${loop_results}
#     Run Keywords
#     ...  Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Report Success Ratio
#     ...  AND      Run Keyword If  "${should_be_reported}" == "True"  Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Report Kpi Results
#     ...  ELSE     Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Log Kpi Results
#     ...  AND      Run Keyword If  "${should_be_reported}" == "True"  Run Keyword And Ignore Error  uuf_rfrl_common.Log Reports
#     ...  AND      Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]E2E_TL_SW_upgrade_rollback_with_sleeping_cell_check
#     [Tags]    UTE_Cloud
#     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
# 
# [1]E2E_TL_Delta_Commissioning_With_Site_Reset_Required_sleeping_cell_check
#     [Tags]    UTE_Cloud
#     [Documentation]
#     ...    -02.06.2023,pengliang.wu@nokia-sbell.com,case draft
#     [Setup]    OAM KPI common case setup
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} change parameter which need bts restart.
#         ${result}    Run Keyword And Return Status    Change parameter which need bts restart
#         ...    ue_index=${mmw_ue_index}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]E2E_TL_Cell_Lock_Unlock_NR_With_Oam_Kpi
#     [Tags]    UTE_Cloud
#     [Documentation]
#     ...    -02.06.2023,pengliang.wu@nokia-sbell.com,case draft
#     [Setup]    OAM KPI common case setup
#     Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Clear Kpi Results
#     @{loop_results}=    Create List
#     Set Test Variable  ${LOOP_RESULTS}
# 
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} cell lock/unlock start..
#         uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
# 
#         ${result}    Run Keyword And Return Status    All configured NRCells lock and unlock stability testing
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#         run keyword and continue on failure    Should Be True    ${result}
# 
#         ${result}    run keyword if    '${result}'=='${True}'    Set Variable    PASS
#         ...    ELSE    Set Variable    FAIL
#         ${test_run_status}=  uuf_rfrl_common.Evaluate Test Run Results  ${result}
#         Append To List    ${loop_results}    ${test_run_status}
#         uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=Loop_${i}
# 
#         run keyword and continue on failure    L3 call    ue_index=${mmw_ue_index}
#         ...    target_avg_percent=${non_peak_target_avg_percent}
# 
#     END
#     List Should Not Contain Value    ${loop_results}    failed
#     uuf_rfrl_common_keywords.Pass Ratio    ${loop_results}
#     Run Keywords
#     ...  Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Report Success Ratio
#     ...  AND      Run Keyword If  "${should_be_reported}" == "True"  Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Report Kpi Results
#     ...  ELSE     Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Log Kpi Results
#     ...  AND      Run Keyword If  "${should_be_reported}" == "True"  Run Keyword And Ignore Error  uuf_rfrl_common.Log Reports
#     ...  AND      Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure
# 
#     [Teardown]   Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]E2E_TL_Cell_Lock_Unlock_NR_with_sleeping_cell_check
#     [Tags]    UTE_Cloud
#     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
# 
# [1]E2E_TL_Site_Reset_Without_HWF_With_Oam_Kpi
#     [Tags]    UTE_Cloud
#     [Documentation]
#     ...    -02.06.2023,pengliang.wu@nokia-sbell.com,case draft
#     [Setup]    OAM KPI common case setup
#     Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Clear Kpi Results
#     @{loop_results}=    Create List
#     Set Test Variable  ${LOOP_RESULTS}
#     ${should_be_reported}    Set Variable    ${True}
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} Reset start..
#         uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
# 
#         ${result}    Run Keyword And Return Status    Stability Reset with HWF deletion
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#         run keyword and continue on failure    Should Be True    ${result}
# 
#         ${result}    run keyword if    '${result}'=='${True}'    Set Variable    PASS
#         ...    ELSE    Set Variable    FAIL
#         ${test_run_status}=  uuf_rfrl_common.Evaluate Test Run Results  ${result}
#         Append To List    ${loop_results}    ${test_run_status}
#         uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=Loop_${i}
# 
#         run keyword and continue on failure    L3 call    ue_index=${mmw_ue_index}
#         ...    target_avg_percent=${non_peak_target_avg_percent}
# 
#     END
#     List Should Not Contain Value    ${loop_results}    failed
#     uuf_rfrl_common_keywords.Pass Ratio    ${loop_results}
#     Run Keywords
#     ...  Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Report Success Ratio
#     ...  AND      Run Keyword If  "${should_be_reported}" == "True"  Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Report Kpi Results
#     ...  ELSE     Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Log Kpi Results
#     ...  AND      Run Keyword If  "${should_be_reported}" == "True"  Run Keyword And Ignore Error  uuf_rfrl_common.Log Reports
#     ...  AND      Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure
# 
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]E2E_TL_Reset_with_HWF_deletion_sleeping_cell_check
#     [Tags]    UTE_Cloud
#     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
# 
# [1]E2E_TL_Cell_Block_Unblock_NR_With_Oam_Kpi
#     [Tags]    UTE_Cloud
#     [Documentation]
#     ...    -shanshan.zhang@nokia-sbell.com
#     ...    [1]TC01_General_SiSo_Cell_block_and_unblock_L3Call_and_pcmd_check
#     [Setup]    OAM KPI common case setup
#     Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Clear Kpi Results
#     @{loop_results}=    Create List
#     Set Test Variable  ${LOOP_RESULTS}
# 
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} NR cell block and unblock start..
#         uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
# 
#         ${result}    Run Keyword And Return Status    Separately CELL block unblock
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
# 
#         ${result}    run keyword if    '${result}'=='${True}'    Set Variable    PASS
#         ...    ELSE    Set Variable    FAIL
#         ${test_run_status}=  uuf_rfrl_common.Evaluate Test Run Results  ${result}
#         Append To List    ${loop_results}    ${test_run_status}
#         uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=Loop_${i}
# 
#         run keyword and continue on failure    L3 call    pcmd=${False}    ue_index=${mmw_ue_index}
#         ...    target_avg_percent=${non_peak_target_avg_percent}
# 
#     END
#     List Should Not Contain Value    ${loop_results}    failed
#     uuf_rfrl_common_keywords.Pass Ratio    ${loop_results}
#     Run Keywords
#     ...  Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Report Success Ratio
#     ...  AND      Run Keyword If  "${should_be_reported}" == "True"  Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Report Kpi Results
#     ...  ELSE     Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Log Kpi Results
#     ...  AND      Run Keyword If  "${should_be_reported}" == "True"  Run Keyword And Ignore Error  uuf_rfrl_common.Log Reports
#     ...  AND      Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure
# 
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]E2E_TL_Cell_Block_Unblock_NR_with_sleeping_cell_check
#     [Tags]    UTE_Cloud
#     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
# 
# [1]E2E_TL_RU_Reset_With_Oam_Kpi
#     [Tags]    UTE_Cloud
#     [Documentation]
#     ...    -23.03.2021,shengrong.rao@nokia-sbell.com,case draft
#     ...    [1]TC08_General_SiSo_RF_module_WebGUI_reset_L3Call
#     [Setup]    OAM KPI common case setup
#     Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Clear Kpi Results
#     @{loop_results}=    Create List
#     Set Test Variable  ${LOOP_RESULTS}
# 
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
# 
#         ${result}    Run Keyword And Return Status    RF module reset
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
# 
#         ${result}    run keyword if    '${result}'=='${True}'    Set Variable    PASS
#         ...    ELSE    Set Variable    FAIL
#         ${test_run_status}=  uuf_rfrl_common.Evaluate Test Run Results  ${result}
#         Append To List    ${loop_results}    ${test_run_status}
#         uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=Loop_${i}
# 
#         run keyword and continue on failure    L3 call    ue_index=${mmw_ue_index}
#         ...    target_avg_percent=${non_peak_target_avg_percent}
# 
#     END
#     List Should Not Contain Value    ${loop_results}    failed
#     uuf_rfrl_common_keywords.Pass Ratio    ${loop_results}
#     Run Keywords
#     ...  Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Report Success Ratio
#     ...  AND      Run Keyword If  "${should_be_reported}" == "True"  Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Report Kpi Results
#     ...  ELSE     Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Log Kpi Results
#     ...  AND      Run Keyword If  "${should_be_reported}" == "True"  Run Keyword And Ignore Error  uuf_rfrl_common.Log Reports
#     ...  AND      Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]E2E_TL_RU_Reset_with_sleeping_cell_check
#     [Tags]    UTE_Cloud
#     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
# 
# [1]E2E_TL_Capacity_Module_Reset_With_Oam_Kpi
#     [Tags]    UTE_Cloud
#     [Documentation]
#     ...    -23.03.2021,shengrong.rao@nokia-sbell.com,case draft
#     ...    [1]TC09_General_SiSo_BBMOD_reset_L3Call
#     [Setup]    OAM KPI common case setup
#     Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Clear Kpi Results
#     @{loop_results}=    Create List
#     Set Test Variable  ${LOOP_RESULTS}
# 
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
# 
#         ${result}    Run Keyword And Return Status     Each single Baseband module reset
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
# 
#         ${result}    run keyword if    '${result}'=='${True}'    Set Variable    PASS
#         ...    ELSE    Set Variable    FAIL
#         ${test_run_status}=  uuf_rfrl_common.Evaluate Test Run Results  ${result}
#         Append To List    ${loop_results}    ${test_run_status}
#         uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=Loop_${i}
# 
#         run keyword and continue on failure    L3 call    ue_index=${mmw_ue_index}
#         ...    target_avg_percent=${non_peak_target_avg_percent}
# 
#     END
#     List Should Not Contain Value    ${loop_results}    failed
#     uuf_rfrl_common_keywords.Pass Ratio    ${loop_results}
#     Run Keywords
#     ...  Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Report Success Ratio
#     ...  AND      Run Keyword If  "${should_be_reported}" == "True"  Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Report Kpi Results
#     ...  ELSE     Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Log Kpi Results
#     ...  AND      Run Keyword If  "${should_be_reported}" == "True"  Run Keyword And Ignore Error  uuf_rfrl_common.Log Reports
#     ...  AND      Run Keyword If  "${STOP_FIX}" != "False"  uuf_rfrl_common.Stop And Fix Procedure
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]E2E_TL_Capacity_Module_Reset_with_sleeping_cell_check
#     [Tags]    UTE_Cloud
#     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
# 
# [1]E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification_sleeping_cell_check
#     [Tags]    UTE_Cloud
#     [Documentation]
#     ...    -25.10.2023,pengliang.wu@nokia-sbell.com,case draft
#     [Setup]    OAM KPI common case setup
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} change ${MR_NR_BTS_NAME}/NRCELL-${TestLineList['${TLNAME}']['mmw_lcrid_list']}[${0}] physcellId.
#         ${result}    Run Keyword And Return Status    Online change parameter for delta dommissioning and L3 call
#         ...    ue_index=${mmw_ue_index}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]E2E_TL_Delta_Commissioning_With_NR_Rat_sleeping_cell_check
#     [Tags]    UTE_Cloud
#     [Documentation]
#     ...    -25.10.2023,pengliang.wu@nokia-sbell.com,case draft
#     [Setup]    OAM KPI common case setup
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} NR RAT reset then L3call
#         ${result}    Run Keyword And Return Status    RAT Reset and L3 call    rat_type=nr    ue_index=${mmw_ue_index}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
#     [Teardown]    Run Keyword And Ignore Error    CI_Common_Case_Teardown
# 
# [1]E2E_TL_Delta_Commissioning_With_LTE_Rat_sleeping_cell_check
#     [Tags]    LTE
#     [Documentation]
#     ...    -25.10.2023,pengliang.wu@nokia-sbell.com,case draft
#     [Setup]    OAM KPI common case setup
#     Get BTS Software Version
#     ENB Case X2U
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} LTE RAT reset then L3call
#         ${result}    Run Keyword And Return Status    RAT Reset and L3 call    rat_type=lte    ue_index=${enb_ue_index}
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if    '${result}'!='${True}'
#         ...    run keyword and continue on failure    Save Snapshot Log    ip_address=${eNB_DU_OAM_IP}
#     END
#     [Teardown]    Run keywords    ENB Case F1U    CI_Common_Case_Teardown
# 
# [1]E2E_TL_Cell_Lock_Unlock_LTE_With_Sleeping_Cell_Check
#     [Tags]    LTE
#     [Documentation]
#     ...    -02.06.2023,pengliang.wu@nokia-sbell.com,case draft
#     [Setup]   OAM KPI common case setup
#     Get BTS Software Version
#     ENB Case X2U
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} 4G CELL Lock Unlock then L3call
#         ${result}    Run Keyword And Return Status    4G CELL Lock Unlock then L3call
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword and continue on failure    run keyword if   ${result}     ENB L3 call
#         ...    protocol=udp    log_time=2m    ul_enable=${True}    dl_enable=${True}
#         ...    total_count=${100}    exp_ul_tp=${5}    exp_dl_tp=${5}    ue_index=${enb_ue_index}
#         ...    ul_list=@{enb_ulcell_list}    dl_list=@{enb_dlcell_list}
#         ...    dl_tput_udp_value=20M    ul_tput_udp_value=20M
#         run keyword if    '${result}'!='${True}'
#         ...    run keyword and continue on failure    Save Snapshot Log    ip_address=${eNB_DU_OAM_IP}
#     END
#     [Teardown]    Run keywords    ENB Case F1U    CI_Common_Case_Teardown
# 
# [1]E2E_TL_Cell_Bock_Unblock_LTE_With_Sleeping_Cell_Check
#     [Documentation]
#     ...    [1]General_SiSo_eNB_State_Management-Cell_lock_and_unlock_with_L3_call
#     [Tags]    LTE
#     [Setup]   OAM KPI common case setup
#     Get BTS Software Version
#     ENB Case X2U
#     FOR    ${i}    IN RANGE    ${test_iteration}
#         Log To Console    round ${i} 4G CELL block unblock then L3call
#         ${result}    Run Keyword And Return Status    4G CELL block unblock then L3call
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword and continue on failure    run keyword if   ${result}     ENB L3 call
#         ...    protocol=udp    log_time=2m    ul_enable=${True}    dl_enable=${True}
#         ...    total_count=${100}    exp_ul_tp=${5}    exp_dl_tp=${5}    ue_index=${enb_ue_index}
#         ...    ul_list=@{enb_ulcell_list}    dl_list=@{enb_dlcell_list}
#         ...    dl_tput_udp_value=20M    ul_tput_udp_value=20M
#         run keyword if    '${result}'!='${True}'
#         ...    run keyword and continue on failure    Save Snapshot Log     ip_address=${eNB_DU_OAM_IP}
#     END
#     [Teardown]    Run keywords    ENB Case F1U    CI_Common_Case_Teardown
# 
# *** Keywords ***
# Suit setup for Sleeing cell
#     CI_Common_Suit_Setup
#     Adapt to ute cloud commission scf
#     Set Suit Variables for different testline
#     Get SBTS Release Version
#     Get eNB Release Version
#     Iptables UDP destination port ACCEPT    port1=51000    port2=51001
# 
# OAM KPI common case setup
#     CI_Common_Case_Setup
#     Check BTS Should Be Normal
#     Check BTS Should Be Normal    bts_host=${eNB_DU_OAM_IP}     cell_type=lte    connection=enb
# 
# Set Suit Variables for different testline
#     ${dlcell_list}    Set Variable    ${TestLineList['${TLNAME}']['mmw_dlcell_list']}
#     ${ulcell_list}    Set Variable    ${TestLineList['${TLNAME}']['mmw_ulcell_list']}
#     ${cell_info_List}    Set Variable    ${TestLineList['${TLNAME}']['mmw_lcrid_list']}
#     ${tcpdump_interface}    Set Variable    ${TestLineList['${TLNAME}']['tcpdump_interface']}
#     ${enb_dlcell_list}    Set Variable    ${TestLineList['${TLNAME}']['enb_used_nr_dlcell_list']}
#     ${enb_ulcell_list}    Set Variable    ${TestLineList['${TLNAME}']['enb_used_nr_ulcell_list']}
#     ${enb_ue_index}    Set Variable    ${TestLineList['${TLNAME}']['enb_used_ue_index']}
#     ${ENB_CELL_ID}    Set Variable    ${TestLineList['${TLNAME}']['enb_lcrid_list']}
#     ${BBMOD_List}    Set Variable    ${TestLineList['${TLNAME}']['BBMOD_list']}
#     ${exp_ul}    Set Variable    ${TestLineList['${TLNAME}']['mmw_tput_ul_non_peak_exp']}
#     ${exp_dl}    Set Variable    ${TestLineList['${TLNAME}']['mmw_tput_dl_non_peak_exp']}
#     ${ul_tput_udp}    Set Variable    ${TestLineList['${TLNAME}']['mmw_tput_ul_non_peak_sent']}
#     ${dl_tput_udp}    Set Variable    ${TestLineList['${TLNAME}']['mmw_tput_dl_non_peak_sent']}
#     ${mmw_ue_index}    Set Variable    ${TestLineList['${TLNAME}']['mmw_used_ue_index']}
# 
#     Set Suite Variable     ${dlcell_list}
#     Set Suite Variable     ${ulcell_list}
#     Set Suite Variable     ${cell_info_List}
#     Set Suite Variable     ${tcpdump_interface}
#     Set Suite Variable     ${enb_dlcell_list}
#     Set Suite Variable     ${enb_ulcell_list}
#     Set Suite Variable     ${enb_ue_index}
#     Set Suite Variable     ${ENB_CELL_ID}
#     Set Suite Variable     ${BBMOD_List}
#     Set Suite Variable     ${exp_ul}
#     Set Suite Variable     ${exp_dl}
#     Set Suite Variable     ${ul_tput_udp}
#     Set Suite Variable     ${dl_tput_udp}
#     Set Suite Variable     ${mmw_ue_index}
