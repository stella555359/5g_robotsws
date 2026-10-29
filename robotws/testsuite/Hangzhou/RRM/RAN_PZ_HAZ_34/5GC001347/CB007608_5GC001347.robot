# *** Settings ***
# Suite Setup          SISO Coam Suite Setup for CLOUD UTE    enb_flag=${False}
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        Case_Teardown for 1347
# Force Tags                5G_RAN    5G_RAN_TDD    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASOE_2xAEWD_ENB    master_pDU
# ...   PY39
# 
# Library   taf.selenium.gnb.oam.coam.classical   WITH NAME   selenium_coam
# Resource    ./resources/5GC001347_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# 
# Documentation
# ...    author: yu.2.zhang
# ...    squad group: SG_07
# ...    feature : 5GC007608
# 
# 
# *** Variables ***
# ${ultp}    120M
# ${dltp}    600M
# ${pcap_path}    ${logPath}
# ${interface}    ethbp1
# ${exp_ul}    30
# ${exp_dl}    100
# 
# *** Test Cases ***
# 
# [1][1.0] 5GC001347_A_004_Ptrs_On_1UlAdditionalDmrs_On_tddFR2
#     [Tags]    CRT
#     [Documentation]
#     ...   author: yu.2.zhang@nokia-sbell.com
#     ...   squad group: SG_07
#     ...   Feature 5GC007608
#     [Setup]    SISO Coam Test Setup
#     ${list_of_cell_ids1}    Create List    2605057
#     Modify Basic Beam Set2
#     step1: Prepare UE    ue_index=${ue_index}
#     Step2: UE Attach    ue_index=${ue_index}
#     Step3: Start traffic    ul_throughput=${ultp}    dl_throughput=${dltp}    ue_index=${ue_index}
#     ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=3m
#     ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids${ue_index}}
#     ...    ultarget_throughput=${exp_ul}    dltarget_throughput=${exp_dl}
#     ...    target_avg_percent=1
#     [Teardown]    Case_Teardown for 1347
# 
# 
# 	
# *** Keywords ***
# Modify Basic Beam Set2
#    Du login page via webUI
#    Run keyword and continue on failure    Wait Until Keyword Succeeds    15min    20s    step1: Check all cells status
#    selenium_coam.set_parameter_value    dist_name=MRBTS-159/NRBTS-159/NRCELL-11
#    ...    filter_param=Uplink DMRS additional position    new_value=One additional DMRS
#    selenium_coam.set_parameter_value    dist_name=MRBTS-159/NRBTS-159/NRCELL-11
#    ...    filter_param=Initial MCS for UL Transmission   new_value=27
#    Validate Plan
#    Activate Plan
#    wait until keyword succeeds    15 min    30 sec
#    ...    Du Check cell on air via WebUI
#    
# Modify Basic Beam Set3
#    selenium_coam.set_parameter_value    dist_name=MRBTS-159/NRBTS-159/NRCELL-11
#    ...    filter_param=Downlink DMRS additional position    new_value=One additional DMRS
#    selenium_coam.set_parameter_value    dist_name=MRBTS-159/NRBTS-159/NRCELL-11
#    ...    filter_param=Initial MCS for DL transmission   new_value=28
#    Validate Plan
#    Activate Plan
#    wait until keyword succeeds    15 min    30 sec
#    ...    Du Check cell on air via WebUI
# 
# Case_Teardown for 1347
#     [Arguments]    ${connection}=GNB_OAM
#     Log To Console    \n *** Case teardown
#     Run Keyword And Ignore Error    Step6: Stop traffic    ue_index=${ue_index}
#     Run Keyword And Ignore Error    Step7: UE Detach    ue_index=${ue_index}
#     Run Keyword And Ignore Error    Stop BIP Capture On ASOD
#     SISO Coam Test Teardown
