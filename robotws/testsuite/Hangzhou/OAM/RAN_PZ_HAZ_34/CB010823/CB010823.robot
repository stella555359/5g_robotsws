# @Time    : 2023/9/14 10:32
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB010823.robot.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CB010823 9 cases on 2006

Suite Setup         Run Keywords    SISO Coam Suite Setup
...    AND     Set Suite Variables Via SW Version
Suite Teardown      SISO Coam Suite Teardown
Test Setup          MMW5 Common Case Setup    allowed_faults_ids=4681
Test Teardown       MMW5 Common Case Teardown
Force Tags          SBTS00    RAN_5G    PY39    RAN_5G_TDD
...                 CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASILR_ABIOB4_2xAEHC_ENB

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/feature/CB010823_common_keywords.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/feature/concurrent_diagnostic_check.py

*** Variables ***
${if_commissioning}    True
@{POINT_41_WEBEM}    41 - RU Memory usage
@{POINT_42_WEBEM}    42 - RU Temperature sensor
@{POINT_41_42_WEBEM}    41 - RU Memory usage    42 - RU Temperature sensor
&{CUSTOM_CHECK_RU1_RU2_41_42_WEBEM}    RMOD-1 / RMOD_R-1 (AEHC)=@{POINT_41_42_WEBEM}
...    RMOD-2 / RMOD_R-2 (AEHC)=@{POINT_41_42_WEBEM}
&{CUSTOM_CHECK_RU1_41_42_WEBEM}    RMOD-1 / RMOD_R-1 (AEHC)=@{POINT_41_42_WEBEM}
&{CUSTOM_CHECK_RU1_41_WEBEM}    RMOD-1 / RMOD_R-1 (AEHC)=@{POINT_41_WEBEM}
&{CUSTOM_CHECK_RU1_42_WEBEM}    RMOD-1 / RMOD_R-1 (AEHC)=@{POINT_42_WEBEM}
&{CUSTOM_CHECK_RU2_41_WEBEM}    RMOD-2 / RMOD_R-2 (AEHC)=@{POINT_41_WEBEM}
&{CUSTOM_CHECK_RU2_42_WEBEM}    RMOD-2 / RMOD_R-2 (AEHC)=@{POINT_42_WEBEM}
@{RADIO_MODUDLES_RU1}    RMOD_R-1
@{RADIO_MODUDLES_RU2}    RMOD_R-2
@{RADIO_MODUDLES_RU1_RU2}    RMOD_R-1    RMOD_R-2

${OPERATION_HISTORY_FILE_PATH}    /home/ute/MMW_SG5/operation_history.log
@{CASE024_CONCURRENT_OPERATION_HISTORY_CHECK}    Start customized diagnostic check    Failed
...    Monitor diagnostic check completion    Succeeded
...    Start full diagnostic check    Succeeded
...    Fetch diagnostic check points    Succeeded
@{CASE028_CONCURRENT_OPERATION_HISTORY_CHECK}    Activate plan    Succeeded
...    Start customized diagnostic check    Failed
...    Validate plan    Succeeded
...    Fetch diagnostic check points    Succeeded
@{CASE028_CONCURRENT_OPERATION_HISTORY_CHECK2}    Start customized diagnostic check    Failed
...    Activate plan    Succeeded
...    Validate plan    Succeeded
...    Fetch diagnostic check points    Succeeded
@{CASE029_CONCURRENT_OPERATION_HISTORY_CHECK}    Start customized diagnostic check    Failed
...    Activate plan    Succeeded
...    Validate plan    Succeeded
...    Fetch diagnostic check points    Succeeded

@{EXCLUDED_POINTS_35}    ${35}
@{EXCLUDED_POINTS_CB010239_NO1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}
...    ${16}    ${17}    ${18}    ${19}    ${21}    ${22}    ${24}    ${26}    ${29}    ${31}    ${35}
@{EXCLUDED_POINTS_CB010239_NO1_31}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}
...    ${16}    ${17}    ${18}    ${19}    ${21}    ${22}    ${24}    ${26}    ${29}    ${35}
@{EXCLUDED_POINTS_CB010239_NO31}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}
...    ${16}    ${17}    ${18}    ${19}    ${21}    ${22}    ${24}    ${26}    ${29}    ${35}
@{EXCLUDED_POINTS_CB010823_NO31_41}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}
...    ${16}    ${17}    ${18}    ${19}    ${21}    ${22}    ${24}    ${26}    ${29}    ${35}    ${42}
${RADIO_CHECK_POINTS_RU1_41_42}

@{CHECK_POINTS_1_41_42}    ${1}    ${41}    ${42}
@{CHECK_POINTS_1_31_41_42}    ${1}    ${31}    ${41}    ${42}
@{CHECK_POINTS_41_42}    ${41}    ${42}
@{CHECK_POINTS_31_41}    ${31}    ${41}

${CHECK_POINTS_DIST}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
${CHECK_POINTS_ABBREVIATION}    excludedDiagnosticCheckPoints

${DIAGNOSTIC_CHECK_DIST}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
${DIAGNOSTIC_CHECK_ABBREVIATION}    actDiagnosticCheck

@{system_module_checkpoints_ids}    1
&{radio_module}    targetDN=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
...    checkpointIds=${CHECK_POINTS_41_42}
@{radio_modules}    ${radio_module}

# diagnostic report file name in snapshot
#${BLACKBOX_DIAGNOSTIC_REPORT}    BTS${MRBTS_ID}_1011_blackbox_DiagnosticReport.csv
#${BLACKBOX_DIAGNOSTIC_REPORT}    BTS${MRBTS_ID}_1011_blackbox_DiagnosticHistoryHistogram.csv
#${BLACKBOX_DIAGNOSTIC_REPORT}    BTS${MRBTS_ID}_1011_blackbox_DiagnosticReport.csv

# tmp for siso
${Active_SW_version}    SBTS24R1_ENB_9999_230925_000013

${REMOVE_RU1_DELTA}    ${CURDIR}/2006_DELETE_RU1_DELTA.json
${COMMON_SCF}          ${CURDIR}/COMMON_10823_2006.xml
${COMMON_SCF2}         ${CURDIR}/10823_CB007042_2006.xml

*** Test Cases ***
CB010823-A_014_Admin CLI checkpoint 41 NOK alarm_call
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/10/11 13:49
    [Tags]    014
    # precondition
    Modify RU Memory Threshold Trigger 41 NOK&OK    memory_test_threshold=${100.0}
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    COAM Commission with scf file    ${COMMON_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    AlarmWatchdog.remove_allow_alarms    fault_id=6327

    # step1: Modify RU Memory Threshold trigger 41 NOK
    AlarmWatchdog.add_allow_alarms    fault_id=4681
    AlarmWatchdog.add_allow_alarms    fault_id=7107
    Modify RU Memory Threshold Trigger 41 NOK&OK    memory_test_threshold=${10.0}

    # step2: run diagnostic check via admin cli, check ru 41 nok, 4681 show and clear
    #Run Keyword If    '${IS_25R1}'!='True'
    Verify Diagnostic Check Result Via Admin CLI    check_point_id=41
    ...    dist_name=MRBTS-2006/EQM_R-4/APEQM_R-1/RMOD_R-1    result=Check point failure
    #Run Keyword If    '${IS_25R1}'!='True'
    Verify Diagnostic Check Result Via Admin CLI    check_point_id=41
    ...    dist_name=MRBTS-2006/EQM_R-4/APEQM_R-1/RMOD_R-2    result=Check point failure
    #Run Keyword If    '${IS_25R1}'=='True'
    #...    Verify Diagnostic Check Result Via Admin CLI For 25R1    check_point_id=41
    #...    dist_name=MRBTS-2006/EQM_R-4/APEQM_R-1/RMOD_R-1    result=NOK
    #Run Keyword If    '${IS_25R1}'=='True'
    #...    Verify Diagnostic Check Result Via Admin CLI For 25R1    check_point_id=41
    #...    dist_name=MRBTS-2006/EQM_R-4/APEQM_R-1/RMOD_R-2    result=NOK

    Run Keyword If    '${IS_TMO}'!='True'
    ...    Wait Until Keyword Succeeds    5min    30s    Verify BTS Alarm Exist
    ...    fault_id=4681    fault_name=Diagnostic Check Error
    ...    fault_info=Failed diagnostic check points with NOK results: 41. Please check the details in diagnostic report
    Sleep    30s
    Run Keyword If    '${IS_TMO}'!='True'
    ...    Wait Until Keyword Succeeds    5min    30s    Verify BTS Alarm Not Exist
    ...    fault_id=4681    fault_name=Diagnostic Check Error

    # step3: Modify RU Memory Threshold trigger 41 OK
    Modify RU Memory Threshold Trigger 41 NOK&OK    memory_test_threshold=${100.0}

    # step4: run diagnostic check via admin cli, check ru 41 ok, 4681 not exist
    #Run Keyword If    '${IS_25R1}'!='True'
    Verify Diagnostic Check Result Via Admin CLI    check_point_id=41
    ...    dist_name=MRBTS-2006/EQM_R-4/APEQM_R-1/RMOD_R-1    result=Check point successful
    #Run Keyword If    '${IS_25R1}'!='True'
    Verify Diagnostic Check Result Via Admin CLI    check_point_id=41
    ...    dist_name=MRBTS-2006/EQM_R-4/APEQM_R-1/RMOD_R-2    result=Check point successful
    #Run Keyword If    '${IS_25R1}'=='True'
    #...    Verify Diagnostic Check Result Via Admin CLI For 25R1    check_point_id=41
    #...    dist_name=MRBTS-2006/EQM_R-4/APEQM_R-1/RMOD_R-1    result=OK
    #Run Keyword If    '${IS_25R1}'=='True'
    #...    Verify Diagnostic Check Result Via Admin CLI For 25R1    check_point_id=41
    #...    dist_name=MRBTS-2006/EQM_R-4/APEQM_R-1/RMOD_R-2    result=OK


    Run Keyword If    '${IS_TMO}'!='True'
    ...    Verify BTS Alarm Not Exist    fault_id=4681    fault_name=Diagnostic Check Error
    AlarmWatchdog.remove_allow_alarms    fault_id=4681
    AlarmWatchdog.remove_allow_alarms    fault_id=7107
    # step5: make call on ru1&ru2
    #UE Attach And Check Throughput With Detach    global_cell_id=303    ul_tp=10M    ul_tp_threshold=1
    #...    dl_tp=10M    dl_tp_threshold=1    attach_mode=NSA    ignore_lte_cells=True    min_percent=0

CB010823-A_024_WebEM_concurrent scenarios with Other Diagnostic check
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/10/09 09:54
    [Tags]    024
    # precondition, exclueded point 35 to avoid site reset
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    COAM Commission with scf file    ${COMMON_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    Modify Parameter On BTS With Activate    dist_name=${CHECK_POINTS_DIST}    parameter=${CHECK_POINTS_ABBREVIATION}
    ...    value=${EXCLUDED_POINTS_35}
    AlarmWatchdog.remove_allow_alarms    fault_id=6327

    Concurrent 24 need retry

CB010823-A_028_WebEM_concurrent scenarios with Recommissionig
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/10/09 17:14
    [Tags]    028
    # precondition
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    COAM Commission with scf file    ${COMMON_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    AlarmWatchdog.remove_allow_alarms    fault_id=6327
    Concurrent 28 need retry

*** Keywords ***
Concurrent 24 need retry
    [Documentation]    Author:jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/11/02 16:06
    @{sleep_times}    Create List    ${12}    ${10}    ${8}
    ...    ${11}    ${9}    ${7}
    @{status_list}    Create List
    FOR    ${sleep_time}    IN    @{sleep_times}
        # step1: concurrent between full and custom webem
        Selenium Login With Version And Alia    alia=sbts1
        Selenium Login With Version And Alia    alia=sbts2
        ${result1}    ${result2}    concurrent_between_full_and_custom_webem
        ...    radio_checkpoints=${CUSTOM_CHECK_RU1_RU2_41_42_WEBEM}    alia1=sbts1    alia2=sbts2    sleep=${sleep_time}
        Run Keyword And Ignore Error    Selenium Logout And Close Browser With Alia    alia=sbts1
        Run Keyword And Ignore Error    Selenium Logout And Close Browser With Alia    alia=sbts2

        # step2: verify operation_history_normal
        ${status}    Run Keyword And Return Status    verify_results_from_operation_history_normal
        ...    file_name=${OPERATION_HISTORY_FILE_PATH}
        ...    except_results=${CASE024_CONCURRENT_OPERATION_HISTORY_CHECK}
        Append To List    ${status_list}    ${status}
        EXIT FOR LOOP IF  '${status}'=='True'
    END
    List Should Contain Value    ${status_list}    ${True}

Concurrent 28 need retry
    [Documentation]    Author:jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/11/01 21:00
    # step1: concurrent between recommission and custom webem
    @{sleep_times}    Create List    ${6}    ${10}    ${8}    ${12}    ${14}
    ...    ${5}    ${9}    ${7}    ${11}    ${13}
    @{status_list}    Create List
    FOR    ${sleep_time}    IN    @{sleep_times}
        Selenium Login With Version And Alia    alia=sbts1
        ${result1}    ${result2}    concurrent_between_recommission_and_custom_webem
        ...    dist_name=MRBTS-${MRBTS_ID}    parameter=btsName    value=MRBTS-${MRBTS_ID}-tmp${sleep_time}
        ...    radio_checkpoints=${CUSTOM_CHECK_RU1_RU2_41_42_WEBEM}    alia1=sbts1    sleep=${sleep_time}
        Run Keyword And Ignore Error    Selenium Logout And Close Browser With Alia    alia=sbts1

        # step2: verify operation_history_normal
        ${status}    Run Keyword And Return Status    verify_results_from_operation_history_normal
        ...    file_name=${OPERATION_HISTORY_FILE_PATH}    except_results=${CASE028_CONCURRENT_OPERATION_HISTORY_CHECK}
        Append To List    ${status_list}    ${status}
        EXIT FOR LOOP IF  '${status}'=='True'
        ${status}    Run Keyword And Return Status    verify_results_from_operation_history_normal
        ...    file_name=${OPERATION_HISTORY_FILE_PATH}    except_results=${CASE028_CONCURRENT_OPERATION_HISTORY_CHECK2}
        Append To List    ${status_list}    ${status}
        EXIT FOR LOOP IF  '${status}'=='True'
    END
    List Should Contain Value    ${status_list}    ${True}

    [Teardown]    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}    parameter=btsName
    ...    value=MRBTS-${MRBTS_ID}
