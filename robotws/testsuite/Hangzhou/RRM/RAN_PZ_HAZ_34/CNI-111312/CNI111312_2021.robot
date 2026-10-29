# -*- coding: utf-8 -*-
# @Time    : 2024/1/23 13:10
# @Author  : Jiao hu & Jian Chen
# @Email   : jiao.hu@nokia-sbell.com & jian.1.chen@nokia-sbell.com
# @File    : CNI111312.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Hu Jiao & Chen Jian
...    contact: jiao.hu@nokia-sbell.com & jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05

Suite Setup         SISO Coam Suite Setup
Suite Teardown      SISO Coam Suite Teardown
Test Setup          MMW5 Common Case Setup
Test Teardown       MMW5 Common Case Teardown
Force Tags          CRT_TRUNK    PY39

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/feature/CNI_111312_common_keywords.robot

*** Variables ***
${SCF_A101}                     ${CURDIR}/CNI111312_Resources/SCF_A101.xml
${SCF_A102}                     ${CURDIR}/CNI111312_Resources/SCF_A102.xml
${SCF_A102_3CELLS}              ${CURDIR}/CNI111312_Resources/3-Cells.xml
${SCF_A102_2CELLS}              ${CURDIR}/CNI111312_Resources/2-Cells.xml
${A102_DELETE_CELL305}          ${CURDIR}/CNI111312_Resources/A102_DELETE_CELL305.json
${A102_ADD_CELL305}             ${CURDIR}/CNI111312_Resources/A102_ADD_CELL305.json
${A102_TRIGGER_UE_ATTACH_305}   ${CURDIR}/CNI111312_Resources/trigger_ue_attach_305.json

${RU1_DIST}             MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-1
${NRCELL304_DIST}       MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-304
${NRCELL305_DIST}       MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-305
${DISABLE_RF_COOLING}   disableSchedAssistRfCooling
${UE_TYPE}              qct_dx50
${NRCELL304_CELLID}     186335536
${NRCELL305_CELLID}     186335537
${DL_PEAK}              1450
${DL_17_PEAK_LOW}       1100
${DL_17_PEAK_HIGH}      1200
${DL_35_PEAK_LOW}       800
${DL_35_PEAK_HIGH}      900
${DL_50_PEAK_LOW}       600
${DL_50_PEAK_HIGH}      700
${DL_50_PEAK_LOW_305}   100
${DL_50_PEAK_HIGH_305}  500
${DL_PEAK_LOW_305}      600
${DL_PEAK_HIGH_305}     800

*** Test Cases ***
CB010796-SR-A_Single_UE_Slot_blanking_triggering_by_RFU_for_the_high_temperature_detected
    [Documentation]    Author: jiao.hu@nokia-sbell.com & jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/1/23 13:00
    [Tags]    c01
    COAM Commission with scf file    ${SCF_A101}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    15s    CI_commssion.Verify all cells should be Online

    ${temperature}    Get RU-${1} Current Temperature
    ${off_value}    Evaluate    ${temperature}+2
    ${on_value}    Evaluate    ${temperature}+3
    Setup Temperature Tresholds On RU With Reset    off_value=${off_value}    on_value=${on_value}    timer_value=120

    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=150M    dl_tp=900M    parallel=2    duration=1800
    power_ue.Check throughput   ue_index=0    direction=dl    ue_type=${UE_TYPE}
    ...    throughput=${DL_PEAK}    cellid=${NRCELL304_CELLID}

    ${syslog}    Capturing Aasyslog with duration    duration=1200s
    ${tp17}    ${tp35}    ${tp50}    analysis_syslog_for_cni_111312    syslog=${syslog}    cur_nr_cell_id=${NRCELL304_CELLID}
    Should Be True    ${DL_17_PEAK_LOW}<${tp17}${DL_17_PEAK_HIGH}
    Should Be True    ${DL_35_PEAK_LOW}<${tp35}${DL_35_PEAK_HIGH}
    Should Be True    ${DL_50_PEAK_LOW}<${tp50}${DL_50_PEAK_HIGH}

    UE Stop Traffic And Release UE
    Setup Temperature Tresholds On RU With Reset    off_value=102.0    on_value=105.0    timer_value=300

CB010796-SR-A_Cell_adding_deleting_for_RFU_which_is_already_hot
     [Documentation]    Author: jiao.hu@nokia-sbell.com & jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/1/23 13:00
    [Tags]    c02
    COAM Commission with scf file    ${SCF_A102}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    15s    CI_commssion.Verify all cells should be Online
    ${cur_scf}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}
    generate_delta_jsons_from_3_scf    ${cur_scf}    ${SCF_A102_3CELLS}    ${SCF_A102_2CELLS}
    ...    ${A102_DELETE_CELL305}    ${A102_ADD_CELL305}

    coam.perform_delta_recommissioning    delta_file=${A102_DELETE_CELL305}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Setup Temperature Tresholds On RU With Reset    off_value=40    on_value=41    timer_value=30
    Verify NRCELL304 Overheating And TP Normal

    coam.perform_delta_recommissioning    delta_file=${A102_ADD_CELL305}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    25min    15s    Verify BTS 5G Cells Status Is Normal State
    coam.perform_delta_recommissioning    delta_file=${A102_TRIGGER_UE_ATTACH_305}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=150M    dl_tp=900M    parallel=2    duration=1800
    ${dl_tp}    power_ue.Check throughput   ue_index=0    direction=dl    ue_type=${UE_TYPE}
    ...    throughput=${DL_50_PEAK_LOW_305}    cellid=${NRCELL305_CELLID}
    Should Be True    ${dl_tp}<${DL_50_PEAK_HIGH_305}
    UE Stop Traffic And Release UE

    #coam.perform_delta_recommissioning    delta_file=${A102_DELETE_CELL305}
    #...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    #coam.perform_delta_recommissioning    delta_file=${A102_ADD_CELL305}
    #...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    #Wait Until Keyword Succeeds    25min    15s    Verify BTS 5G Cells Status Is Normal State

    #coam.perform_delta_recommissioning    delta_file=${A102_TRIGGER_UE_ATTACH_305}
    #...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    #UE Attach With Verify Attach
    #UE Start UL&DL UDP Traffic    ul_tp=150M    dl_tp=900M    parallel=2    duration=1800
    #${dl_tp}    power_ue.Check throughput   ue_index=0    direction=dl    ue_type=${UE_TYPE}
    #...    throughput=${DL_PEAK_LOW_305}    cellid=${NRCELL305_CELLID}
    #Should Be True    ${dl_tp}<${DL_PEAK_HIGH_305}

    #UE Stop Traffic And Release UE
    Setup Temperature Tresholds On RU With Reset    off_value=102.0    on_value=105.0    timer_value=300

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
    selenium_coam.reset_ru    ru_index=1
    Wait Until Keyword Succeeds    5min    20s    RU Should Be Offline    ru_index=1
    Selenium Logout And Close Browser
    Wait Until Keyword Succeeds    25min    15s    Verify BTS 5G Cells Status Is Normal State
    Verify NRCELL304 Overheating And TP Normal

    Selenium Login And Disable Screen Lock
    selenium_coam.reset_baseband    baseband_index=1
    selenium_coam.reset_baseband    baseband_index=3
    Selenium Logout And Close Browser
    Wait Until Keyword Succeeds    25min    15s    Verify BTS 5G Cells Status Is Normal State
    Verify NRCELL304 Overheating And TP Normal

    Modify Parameter On BTS With Activate    dist_name=${NRCELL304_DIST}    parameter=administrativeState    value=Locked
    Modify Parameter On BTS With Activate    dist_name=${NRCELL304_DIST}    parameter=administrativeState    value=Unlocked
    Wait Until Keyword Succeeds    25min    15s    Verify BTS 5G Cells Status Is Normal State
    Verify NRCELL304 Overheating And TP Normal

    AlarmWatchdog.add_allow_alarms    fault_id=6327
    Setup Temperature Tresholds On RU With Reset    off_value=102.0    on_value=105.0    timer_value=300
    AlarmWatchdog.remove_allow_alarms    fault_id=6327
