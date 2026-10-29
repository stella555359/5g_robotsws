# -*- coding: utf-8 -*-
# @Time    : 2024/1/23 13:10
# @Author  : Jiao hu & Jian Chen
# @Email   : jiao.hu@nokia-sbell.com & jian.1.chen@nokia-sbell.com
# @File    : CNI111312.robot
# @Software: PyCharm
# @Doc     : Some Description
# Reference : From 5G_RAN_ARC_9617, DL peak throughput reduction is 23%,43%,60% for SB Level 1,2,3(17%,35%,50%), refer slot blanking simulation.
*** Settings ***
Documentation
...    author: Hu Jiao & Chen Jian
...    contact: jiao.hu@nokia-sbell.com & jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05

Suite Setup         Run Keywords    SISO Coam Suite Setup    AND    Set PA For CNI111312
Suite Teardown      Run Keywords    SISO Coam Suite Teardown    AND    Restore PA For 6CC CA
Test Setup          MMW5 Common Case Setup
Test Teardown       Run Keywords    MMW5 Common Case Teardown
...    AND    Restore Temperature Thresholds On RU
Force Tags          CRT_TRUNK

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/feature/CNI_111312_common_keywords.robot

*** Variables ***
${SCF_A101}                     ${CURDIR}/CNI111312_Resources/SCF_A101.xml
${SCF_A102}                     ${CURDIR}/CNI111312_Resources/SCF_A102.xml
${SCF_A102_3CELLS}              ${SCF_A102}
${SCF_A102_2CELLS}              ${CURDIR}/CNI111312_Resources/2-Cells.xml
${A102_DELETE_CELL7}          ${CURDIR}/CNI111312_Resources/A102_DELETE_CELL7.json
${A102_ADD_CELL7}             ${CURDIR}/CNI111312_Resources/A102_ADD_CELL7.json
${A102_TRIGGER_UE_ATTACH_7}   ${CURDIR}/CNI111312_Resources/trigger_ue_attach_7.json

${RU3_DIST}             MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-3
${NRCELL4_DIST}       MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-4
${NRCELL7_DIST}       MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-7
${DISABLE_RF_COOLING}   disableSchedAssistRfCooling
${UE_TYPE}              qualcomm
${NRCELL4_CELLID}     608632836
${NRCELL7_CELLID}     608632839
${DL_PEAK}              1638
${DL_17_PEAK_LOW}       1244    # 23% reduction=1261, Low bound is 24% reduction
${DL_17_PEAK_HIGH}      1294    # 23% reduction=1261, High bound is 21% reduction
${DL_35_PEAK_LOW}       917    # 43% reduction=933.66, Low bound is 44% reduction
${DL_35_PEAK_HIGH}      967    # 43% reduction=933.66, High bound is 41% reduction
${DL_50_PEAK_LOW}       638    # 60% reduction=655.2, Low bound is 61% reduction
${DL_50_PEAK_HIGH}      688    # 60% reduction=655.2, High bound is 58% reduction
${DL_PEAK_102_4}        1595   # DL peak throughput for cell4 SCF_A102
${DL_50_PEAK_LOW_A102}     ${1595 * 0.39}    # 60% reduction=655.2, Low bound is 61% reduction
${DL_50_PEAK_HIGH_A102}    ${1595 * 0.43}    # 60% reduction=655.2, High bound is 57% reduction
${DL_50_PEAK_LOW_7}     301    # 60% reduction=773.2*0.4=309, Low bound is 61% reduction
${DL_50_PEAK_HIGH_7}    325    # 60% reduction=773.2*0.4=309, High bound is 58% reduction
#${DL_PEAK_LOW_305}      600
#${DL_PEAK_HIGH_305}     800
${TS_CASE_LOG_PATH}    ${OUTPUT_DIR}
${if_commissioning}    False

*** Test Cases ***
CB010796-SR-A_Single_UE_Slot_blanking_triggering_by_RFU_for_the_high_temperature_detected
    [Documentation]    Author: jiao.hu@nokia-sbell.com & jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/1/23 13:00
    [Tags]    c01
    COAM Commission with scf file    ${SCF_A101}    is_pdl_checking_needed=${True}    timeout=900
    Wait Until Keyword Succeeds    25min    15s    CI_commssion.Verify all cells should be Online

    ${temperature}    Get RU-${3} Current Temperature
#    ${off_value}    Evaluate    ${temperature}+1
    ${on_value}    Evaluate    ${temperature}+1
    Setup Temperature Tresholds On RU With Reset    off_value=${temperature}    on_value=${on_value}    timer_value=120

    Wait Until Keyword Succeeds    3x    30s    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=110M    dl_tp=820M    parallel=2    duration=1800
#    ${tput_log}    power_ue.Collect Tput    ue_type=${UE_TYPE}    duration=20s    ignore_time=1s    check_source=aasyslog
#    ${tput_cells}    Create List    ${NRCELL4_CELLID}
#    ${output}    power_ue.Check Tput    ue_type=${UE_TYPE}    direction=DL    target_throughput=${DL_PEAK}
#    ...    log=${tput_log}    cells=${tput_cells}    check_source=aasyslog

    ${syslog}    Capturing Aasyslog with duration    duration=1200s
    ${tp_peak}    ${tp17}    ${tp35}    ${tp50}    analysis_syslog_for_cni_111312    syslog=${syslog}    cur_nr_cell_id=${NRCELL4_CELLID}

    ${tp_peak_threshold}    Evaluate    ${DL_PEAK} * 0.98
    Should Be True    ${tp_peak} >= ${tp_peak_threshold}
    Should Be True    ${DL_17_PEAK_LOW}<${tp17}${DL_17_PEAK_HIGH}
    Should Be True    ${DL_35_PEAK_LOW}<${tp35}${DL_35_PEAK_HIGH}
    Should Be True    ${DL_50_PEAK_LOW}<${tp50}${DL_50_PEAK_HIGH}

    UE Stop Traffic And Release UE
#    Setup Temperature Tresholds On RU With Reset    off_value=102.0    on_value=105.0    timer_value=300

CB010796-SR-A_Cell_adding_deleting_for_RFU_which_is_already_hot
     [Documentation]    Author: jiao.hu@nokia-sbell.com & jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/1/23 13:00
    [Tags]    c02
    COAM Commission with scf file    ${SCF_A102}    is_pdl_checking_needed=${True}    timeout=900
    Wait Until Keyword Succeeds    25min    15s    CI_commssion.Verify all cells should be Online
    ${cur_scf}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}
    generate_delta_jsons_from_3_scf    ${cur_scf}    ${SCF_A102_3CELLS}    ${SCF_A102_2CELLS}
    ...    ${A102_DELETE_CELL7}    ${A102_ADD_CELL7}

    coam.perform_delta_recommissioning    delta_file=${A102_DELETE_CELL7}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Setup Temperature Tresholds On RU With Reset    off_value=40    on_value=41    timer_value=30
    Verify NRCELL304 Overheating And TP Normal

    coam.perform_delta_recommissioning    delta_file=${A102_ADD_CELL7}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    25min    15s    Verify BTS 5G Cells Status Is Normal State
    coam.perform_delta_recommissioning    delta_file=${A102_TRIGGER_UE_ATTACH_7}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Run Keyword And Ignore Error    UE Attach With Verify Attach
    Sleep    15s
    UE Start UL&DL UDP Traffic    ul_tp=60M    dl_tp=200M    parallel=2    duration=1800
    ${tput_log}    power_ue.Collect Tput    ue_type=${UE_TYPE}    duration=60s    ignore_time=60s    check_source=aasyslog
    ${tput_cells}    Create List    ${NRCELL7_CELLID}
    ${dl_tp}    power_ue.Check Tput    ue_type=${UE_TYPE}    direction=DL    target_throughput=${DL_50_PEAK_LOW_7}
    ...    log=${tput_log}    cells=${tput_cells}    check_source=aasyslog
    Should Be True    ${dl_tp[0]["average"]}<${DL_50_PEAK_HIGH_7}
    UE Stop Traffic And Release UE

    #coam.perform_delta_recommissioning    delta_file=${A102_DELETE_CELL7}
    #...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    #coam.perform_delta_recommissioning    delta_file=${A102_ADD_CELL7}
    #...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    #Wait Until Keyword Succeeds    25min    15s    Verify BTS 5G Cells Status Is Normal State

    #coam.perform_delta_recommissioning    delta_file=${A102_TRIGGER_UE_ATTACH_7}
    #...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    #UE Attach With Verify Attach
    #UE Start UL&DL UDP Traffic    ul_tp=150M    dl_tp=900M    parallel=2    duration=1800
    #${dl_tp}    power_ue.Check throughput   ue_index=0    direction=dl    ue_type=${UE_TYPE}
    #...    throughput=${DL_PEAK_LOW_305}    cellid=${NRCELL7_CELLID}
    #Should Be True    ${dl_tp}<${DL_PEAK_HIGH_305}

    #UE Stop Traffic And Release UE
#    Setup Temperature Tresholds On RU With Reset    off_value=102.0    on_value=105.0    timer_value=300

CB010796-SR-A_Exploratory
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/02/07 09:48
    [Tags]    c03
    COAM Commission with scf file    ${SCF_A102}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    15s    CI_commssion.Verify all cells should be Online

    AlarmWatchdog.add_allow_alarms    fault_id=6327
    Setup Temperature Tresholds On RU With Reset    off_value=40    on_value=41    timer_value=30
    AlarmWatchdog.remove_allow_alarms    fault_id=6327
    Verify NRCELL304 Overheating And TP Normal

    Selenium Login And Disable Screen Lock
    selenium_coam.reset_ru    ru_index=3
    Wait Until Keyword Succeeds    5min    20s    RU Should Be Offline    ru_index=3
    Selenium Logout And Close Browser
    Wait Until Keyword Succeeds    25min    15s    Verify BTS 5G Cells Status Is Normal State
    Verify NRCELL304 Overheating And TP Normal

    Selenium Login And Disable Screen Lock
    selenium_coam.reset_baseband    baseband_index=1
    selenium_coam.reset_baseband    baseband_index=4
    Selenium Logout And Close Browser
    Wait Until Keyword Succeeds    25min    15s    Verify BTS 5G Cells Status Is Normal State
    Verify NRCELL304 Overheating And TP Normal

    Modify Parameter On BTS With Activate    dist_name=${NRCELL4_DIST}    parameter=administrativeState    value=Locked
    Modify Parameter On BTS With Activate    dist_name=${NRCELL4_DIST}    parameter=administrativeState    value=Unlocked
    Wait Until Keyword Succeeds    25min    15s    Verify BTS 5G Cells Status Is Normal State
    Verify NRCELL304 Overheating And TP Normal

#    AlarmWatchdog.add_allow_alarms    fault_id=6327
#    Setup Temperature Tresholds On RU With Reset    off_value=102.0    on_value=105.0    timer_value=300
#    AlarmWatchdog.remove_allow_alarms    fault_id=6327

*** Keywords ***
Restore Temperature Thresholds On RU
    [Documentation]    Author: Li Chun
    ...    Init Define: 2025/01/20
    [Arguments]
    Connect to gnb coam via ssl
    Setup Temperature Tresholds On RU With Reset    off_value=97    on_value=100    timer_value=300
    Run Keyword And Ignore Error    COAM Teardown gnb connections