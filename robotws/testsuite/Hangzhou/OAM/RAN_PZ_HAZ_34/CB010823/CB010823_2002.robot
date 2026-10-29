# @Time    : 2024/01/05 10:15
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB010823_2002.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CB010823 F/B

Suite Setup         Run Keywords    SISO Coam Suite Setup
...    AND     Set Suite Variables Via SW Version
Suite Teardown      SISO Coam Suite Teardown
Test Setup          MMW5 Common Case Setup    allowed_faults_ids=4681,1806,4559
Test Teardown       MMW5 Common Case Teardown
Force Tags          CRT_TRUNK    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/feature/CB010823_common_keywords.robot

*** Variables ***
${if_commissioning}    False

@{EXCLUDED_POINTS_CB010823_F}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}
...    ${11}    ${12}    ${13}    ${14}    ${15}    ${16}    ${17}    ${18}    ${19}    ${20}    ${21}    ${22}    ${23}
...    ${24}    ${25}    ${26}    ${27}    ${28}    ${29}    ${30}    ${31}    ${32}    ${33}    ${34}    ${35}    ${36}
...    ${37}    ${38}    ${39}    ${43}
@{EXCLUDED_POINTS_CB010823_F_41}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}
...    ${11}    ${12}    ${13}    ${14}    ${15}    ${16}    ${17}    ${18}    ${19}    ${20}    ${21}    ${22}    ${23}
...    ${24}    ${25}    ${26}    ${27}    ${28}    ${29}    ${30}    ${31}    ${32}    ${33}    ${34}    ${35}    ${36}
...    ${37}    ${38}    ${39}    ${41}    ${43}
@{EXCLUDED_POINTS_CB010823_F_NO43}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}
...    ${11}    ${12}    ${13}    ${14}    ${15}    ${16}    ${17}    ${18}    ${19}    ${20}    ${21}    ${22}    ${23}
...    ${24}    ${25}    ${26}    ${27}    ${28}    ${29}    ${30}    ${31}    ${32}    ${33}    ${34}    ${35}    ${36}
...    ${37}    ${38}    ${39}
@{EXCLUDED_POINTS_CB010823_B}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}
...    ${11}    ${12}    ${13}    ${14}    ${15}    ${16}    ${17}    ${18}    ${19}    ${20}    ${21}    ${22}    ${23}
...    ${24}    ${25}    ${26}    ${27}    ${28}    ${29}    ${30}    ${31}    ${32}    ${33}    ${34}    ${35}    ${36}
...    ${37}    ${38}    ${39}
@{EXCLUDED_POINTS_CB010823_B_40_41_42}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}
...    ${11}    ${12}    ${13}    ${14}    ${15}    ${16}    ${17}    ${18}    ${19}    ${20}    ${21}    ${22}    ${23}
...    ${24}    ${25}    ${26}    ${27}    ${28}    ${29}    ${30}    ${31}    ${32}    ${33}    ${34}    ${35}    ${36}
...    ${37}    ${38}    ${39}    ${40}    ${41}    ${42}
@{EXCLUDED_POINTS_CB010823_B_NO19}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}
...    ${11}    ${12}    ${13}    ${14}    ${15}    ${16}    ${17}    ${18}    ${20}    ${21}    ${22}    ${23}
...    ${24}    ${25}    ${26}    ${27}    ${28}    ${29}    ${30}    ${31}    ${32}    ${33}    ${34}    ${35}    ${36}
...    ${37}    ${38}    ${39}
@{EXCLUDED_POINTS_CB010823_B_NO19_NO35}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}
...    ${11}    ${12}    ${13}    ${14}    ${15}    ${16}    ${17}    ${18}    ${20}    ${21}    ${22}    ${23}
...    ${24}    ${25}    ${26}    ${27}    ${28}    ${29}    ${30}    ${31}    ${32}    ${33}    ${34}    ${36}
...    ${37}    ${38}    ${39}

# For WebEM
@{POINT_40_WEBEM}    40 - RU SW package and NVM integrity
@{POINT_41_WEBEM}    41 - RU Memory usage
@{POINT_42_WEBEM}    42 - RU Temperature sensor
@{POINT_43_WEBEM}    43 - Extended RU DDR tests (RST)
@{POINT_40_43_WEBEM}    40 - RU SW package and NVM integrity    43 - Extended RU DDR tests (RST)
@{POINT_40_41_42_43_WEBEM}    40 - RU SW package and NVM integrity    41 - RU Memory usage
...    42 - RU Temperature sensor    43 - Extended RU DDR tests (RST)
&{CUSTOM_CHECK_RU1_40_43_WEBEM}    RMOD-1 / RMOD_R-1 (AZQJ)=@{POINT_40_43_WEBEM}
&{CUSTOM_CHECK_RU1_RU2_43_WEBEM}    RMOD-1 / RMOD_R-1 (AZQJ)=@{POINT_43_WEBEM}
...    RMOD-2 / RMOD_R-2 (AZQJ)=@{POINT_43_WEBEM}
&{CUSTOM_CHECK_RU2_43_WEBEM}    RMOD-1 / RMOD_R-1 (AZQJ)=@{POINT_41_WEBEM}
...    RMOD-2 / RMOD_R-2 (AZQJ)=@{POINT_43_WEBEM}
&{CUSTOM_CHECK_RU1_RU2_40_41_42_43_WEBEM}    RMOD-1 / RMOD_R-1 (AZQJ)=@{POINT_40_41_42_43_WEBEM}
...    RMOD-2 / RMOD_R-2 (AZQJ)=@{POINT_40_41_42_43_WEBEM}
@{CHECK_POINTS_43}    43
@{CHECK_POINTS_40_43}    40    43
@{CHECK_POINTS_40_41_42_43}    40    41    42    43

# CB010823 feature params
${CHECK_POINTS_DIST}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
${CHECK_POINTS_ABBREVIATION}    excludedDiagnosticCheckPoints
${DIAGNOSTIC_CHECK_DIST}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
${DIAGNOSTIC_CHECK_ABBREVIATION}    actDiagnosticCheck

@{RADIO_MODUDLES_RU1}    RMOD_R-1
@{RADIO_MODUDLES_RU2}    RMOD_R-2
@{RADIO_MODUDLES_RU1_RU2}    RMOD_R-1    RMOD_R-2
@{RU1_INDEX}    1
@{RU2_INDEX}    2
@{RU1_RU2_INDEX}    1    2

@{19_OK}    19=OK
@{19_35_OK}    19=OK    35=OK
@{40_42_OK}    40=OK    42=OK
@{40_41_42_OK}    40=OK    41=OK    42=OK
@{40_41_42_43_OK}    40=OK    41=OK    42=OK    43=OK
@{40_41_42_OK_43_NOK}    40=OK    41=OK    42=OK    43=NOK
@{43_NOK}    43=NOK
@{43_OK}    43=OK

&{RU1_43NOK_RU2_43OK}    RMOD_R-1=@{43_NOK}    RMOD_R-2=@{43_OK}
&{RU1_43OK_RU2_43NOK}    RMOD_R-1=@{43_OK}    RMOD_R-2=@{43_NOK}
&{RU1_43NOK_RU2_43OK_40_41_42_OK}    RMOD_R-1=@{40_41_42_OK_43_NOK}    RMOD_R-2=@{40_41_42_43_OK}
&{RU1_43OK_RU2_43NOK_40_41_42_OK}    RMOD_R-1=@{40_41_42_43_OK}    RMOD_R-2=@{40_41_42_OK_43_NOK}
&{RU1_RU2_43OK}    RMOD_R-1=@{43_OK}    RMOD_R-2=@{43_OK}
&{RU1_RU2_40_42_OK}    RMOD_R-1=@{40_42_OK}    RMOD_R-2=@{40_42_OK}
&{RU1_RU2_40_41_42_OK}    RMOD_R-1=@{40_41_42_OK}    RMOD_R-2=@{40_41_42_OK}
&{RU1_RU2_40_41_42_43_OK}    RMOD_R-1=@{40_41_42_43_OK}    RMOD_R-2=@{40_41_42_43_OK}
&{RU1_RU2_40_41_42_43_OK_SMOD_19_OK}    RMOD_R-1=@{40_41_42_43_OK}    RMOD_R-2=@{40_41_42_43_OK}    SMOD_R-1=@{19_OK}
&{RU1_RU2_40_41_42_43_OK_SMOD_19_35_OK}    RMOD_R-1=@{40_41_42_43_OK}    RMOD_R-2=@{40_41_42_43_OK}
...    SMOD_R-1=@{19_35_OK}

# tmp for siso
${Active_SW_version}    SBTS24R1_ENB_9999_230925_000013

*** Test Cases ***
CB010823-F_001_WebEM full diagnostic check with or without service impact
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/02 16:57
    [Tags]    F001
    Modify Parameter On BTS With Activate    dist_name=${CHECK_POINTS_DIST}    parameter=${CHECK_POINTS_ABBREVIATION}
    ...    value=${EXCLUDED_POINTS_CB010823_F}
    Modify Parameter On BTS With Activate    dist_name=${DIAGNOSTIC_CHECK_DIST}    parameter=${DIAGNOSTIC_CHECK_ABBREVIATION}
    ...    value=false

    Verify Full Diagnostic Check Results Via WebEM    expect_result=${RU1_RU2_40_41_42_OK}
    ...    allow_service_impact=${False}

    Modify Parameter On BTS With Activate    dist_name=${CHECK_POINTS_DIST}    parameter=${CHECK_POINTS_ABBREVIATION}
    ...    value=${EXCLUDED_POINTS_CB010823_F_41}
    Verify Full Diagnostic Check Results Via WebEM    expect_result=${RU1_RU2_40_42_OK}
    ...    allow_service_impact=${False}

    Modify Parameter On BTS With Activate    dist_name=${CHECK_POINTS_DIST}    parameter=${CHECK_POINTS_ABBREVIATION}
    ...    value=${EXCLUDED_POINTS_CB010823_F_NO43}
    Verify Full Diagnostic Check Results Via WebEM    expect_result=${RU1_RU2_40_41_42_43_OK}
    ...    allow_service_impact=${True}

    ${uptime}    Get RU Reset Via Uptime On WebEM    ru_index=2
    Should Be True    ${uptime}<10

    Modify Parameter On BTS With Activate    dist_name=${CHECK_POINTS_DIST}    parameter=${CHECK_POINTS_ABBREVIATION}
    ...    value=${EXCLUDED_POINTS_CB010823_F}
    Verify Full Diagnostic Check Results Via WebEM    expect_result=${RU1_RU2_40_41_42_OK}
    ...    allow_service_impact=${True}

    ${uptime2}    Get RU Reset Via Uptime On WebEM    ru_index=2
    Should Be True    ${uptime2}>${uptime}

CB010823-B_004_WebEM customized diagnostic check with service impact
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/02 16:57
    [Tags]    B004
    Modify Parameter On BTS With Activate    dist_name=${CHECK_POINTS_DIST}    parameter=${CHECK_POINTS_ABBREVIATION}
    ...    value=${EXCLUDED_POINTS_CB010823_B}
    Modify Parameter On BTS With Activate    dist_name=${DIAGNOSTIC_CHECK_DIST}    parameter=${DIAGNOSTIC_CHECK_ABBREVIATION}
    ...    value=true

    ${number_of_executions1}    Get Diagnostic Execution Number From Snapshot    radio_points=${CHECK_POINTS_40_41_42_43}
    ${snapshot_file}    MMW5 Collect Snapshot
    ${ru1_40_execution_number1}    Get Single Diagnostic Execution Number From Snapshot    snapshot_file=${snapshot_file}
    ...    check_point=40    dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-1
    ${ru1_43_execution_number1}    Get Single Diagnostic Execution Number From Snapshot    snapshot_file=${snapshot_file}
    ...    check_point=43    dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-1
    ${ru2_43_execution_number1}    Get Single Diagnostic Execution Number From Snapshot    snapshot_file=${snapshot_file}
    ...    check_point=43    dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-2

    # Step 3: select checkpoint 43 + RMOD2 and start diagnostic check
    Verify Customized Diagnostic Check Normal    radio_params=${CUSTOM_CHECK_RU2_43_WEBEM}
    ...    radio_modules=${RADIO_MODUDLES_RU2}    radio_points=${CHECK_POINTS_43}
    Verify RU Reset Via Uptime On WebEM    rus_index=${RU2_INDEX}

    # Step 4: select checkpoint 43&40&41&42 + RMOD1&RMOD2 and start diagnostic check, ru is reset
    Verify Customized Diagnostic Check Normal    radio_params=${CUSTOM_CHECK_RU1_RU2_40_41_42_43_WEBEM}
    ...    radio_modules=${RADIO_MODUDLES_RU1_RU2}    radio_points=${CHECK_POINTS_40_41_42_43}
    Verify RU Reset Via Uptime On WebEM    rus_index=${RU1_RU2_INDEX}

    # Step 5: select checkpoint 43&40 + RMOD1 and start diagnostic check, ru is reset
    Verify Customized Diagnostic Check Normal    radio_params=${CUSTOM_CHECK_RU1_40_43_WEBEM}
    ...    radio_modules=${RADIO_MODUDLES_RU1}    radio_points=${CHECK_POINTS_40_43}
    Verify RU Reset Via Uptime On WebEM    rus_index=${RU1_INDEX}

    # Step 6: select checkpoint 43 + RMOD1&RMOD2 and start diagnostic check
    Verify Customized Diagnostic Check Normal    radio_params=${CUSTOM_CHECK_RU1_RU2_43_WEBEM}
    ...    radio_modules=${RADIO_MODUDLES_RU1_RU2}    radio_points=${CHECK_POINTS_43}
    Verify RU Reset Via Uptime On WebEM    rus_index=${RU1_RU2_INDEX}

    ${number_of_executions2}    Get Diagnostic Execution Number From Snapshot    radio_points=${CHECK_POINTS_40_41_42_43}
    ${snapshot_file}    MMW5 Collect Snapshot
    ${ru1_40_execution_number2}    Get Single Diagnostic Execution Number From Snapshot    snapshot_file=${snapshot_file}
    ...    check_point=40    dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-1
    ${ru1_43_execution_number2}    Get Single Diagnostic Execution Number From Snapshot    snapshot_file=${snapshot_file}
    ...    check_point=43    dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-1
    ${ru2_43_execution_number2}    Get Single Diagnostic Execution Number From Snapshot    snapshot_file=${snapshot_file}
    ...    check_point=43    dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-2

    ${executions_add_number}    Evaluate    ${number_of_executions2}-${number_of_executions1}
    Should Be True    ${executions_add_number}==14
    ${executions_ru1_40_add_number}    Evaluate    ${ru1_40_execution_number2}-${ru1_40_execution_number1}
    Should Be True    ${executions_ru1_40_add_number}==2
    ${executions_ru1_43_add_number}    Evaluate    ${ru1_43_execution_number2}-${ru1_43_execution_number1}
    Should Be True    ${executions_ru1_43_add_number}==3
    ${executions_ru2_43_add_number}    Evaluate    ${ru2_43_execution_number2}-${ru2_43_execution_number1}
    Should Be True    ${executions_ru2_43_add_number}==3

CB010823-B_006_Admin CLI full diagnostic check with service impact
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/08 11:30
    [Tags]    B006
    Modify Parameter On BTS With Activate    dist_name=${CHECK_POINTS_DIST}    parameter=${CHECK_POINTS_ABBREVIATION}
    ...    value=${EXCLUDED_POINTS_CB010823_B}
    Modify Parameter On BTS With Activate    dist_name=${DIAGNOSTIC_CHECK_DIST}    parameter=${DIAGNOSTIC_CHECK_ABBREVIATION}
    ...    value=false

    Verify Sanity Check Results Via Admin Cli    expect_result=${RU1_RU2_40_41_42_43_OK}
    ...    allow_service_impact=${True}
    Verify RU Reset Via Uptime On WebEM    rus_index=${RU1_RU2_INDEX}

    Verify Full Diagnostic Check Results Via Admin Cli    expect_result=${RU1_RU2_40_41_42_43_OK}
    ...    allow_service_impact=${True}
    Verify RU Reset Via Uptime On WebEM    rus_index=${RU1_RU2_INDEX}

    Modify Parameter On BTS With Activate    dist_name=${CHECK_POINTS_DIST}    parameter=${CHECK_POINTS_ABBREVIATION}
    ...    value=${EXCLUDED_POINTS_CB010823_B_NO19}
    Verify Full Diagnostic Check Results Via Admin Cli    expect_result=${RU1_RU2_40_41_42_43_OK_SMOD_19_OK}
    ...    allow_service_impact=${True}
    Verify RU Reset Via Uptime On WebEM    rus_index=${RU1_RU2_INDEX}

    Modify Parameter On BTS With Activate    dist_name=${CHECK_POINTS_DIST}    parameter=${CHECK_POINTS_ABBREVIATION}
    ...    value=${EXCLUDED_POINTS_CB010823_B_NO19_NO35}
    ${time_before_start_diagnostic_check}    robot.libraries.DateTime.Get Current Date
    ...    result_format=%Y-%m-%dT%H:%M:%S+08:00
    Sleep    30s
    Run Keyword And Ignore Error    coam.run_diagnostic_check    allow_service_impact=${True}
    ...    connection=GNB_OAM
    Sleep    300s
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online

    ${results}    coam.get_diagnostic_report    detailed_output=True    connection=GNB_OAM

    ${analysis_result}    Analysis Diagnostic Check Result Via Admin Cli    ${results["requestMessage"]}
    ...    ${time_before_start_diagnostic_check}
    Should Be Equal    ${analysis_result}    ${RU1_RU2_40_41_42_43_OK_SMOD_19_35_OK}

    Verify RU Reset Via Uptime On WebEM    rus_index=${RU1_RU2_INDEX}    except_uptime=15

CB010823-B_016_WebEM checkpoint 43 NOK alarm one RU OK one NOK_Call
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/09 10:17
    [Tags]    B016
    Modify Parameter On BTS With Activate    dist_name=${CHECK_POINTS_DIST}    parameter=${CHECK_POINTS_ABBREVIATION}
    ...    value=${EXCLUDED_POINTS_CB010823_B_40_41_42}
    Modify Parameter On BTS With Activate    dist_name=${DIAGNOSTIC_CHECK_DIST}    parameter=${DIAGNOSTIC_CHECK_ABBREVIATION}
    ...    value=true

    Modify RU DDR Post Result Trigger 43 NOK&OK    restore_ddr=False
    AlarmWatchdog.add_allow_alarms    fault_id=4681
    Verify Customized Diagnostic Check Results Via WebEM    radio_params=${CUSTOM_CHECK_RU1_RU2_40_41_42_43_WEBEM}
    ...    expect_result=${RU1_43NOK_RU2_43OK}
    Verify RU Reset Via Uptime On WebEM    rus_index=${RU1_RU2_INDEX}
    Run Keyword If    '${IS_TMO}'!='True'
    ...    Verify BTS Alarm Not Exist    fault_id=4681    fault_name=Diagnostic Check Error

    Modify Parameter On BTS With Activate    dist_name=${CHECK_POINTS_DIST}    parameter=${CHECK_POINTS_ABBREVIATION}
    ...    value=${EXCLUDED_POINTS_CB010823_B}
    Verify Full Diagnostic Check Results Via WebEM    expect_result=${RU1_43NOK_RU2_43OK_40_41_42_OK}
    ...    allow_service_impact=${True}
    Verify RU Reset Via Uptime On WebEM    rus_index=${RU1_RU2_INDEX}
    Run Keyword If    '${IS_TMO}'!='True'
    ...    Wait Until Keyword Succeeds    5min    30s    Verify BTS Alarm Exist
    ...    fault_id=4681    fault_name=Diagnostic Check Error
    ...    fault_info=Failed diagnostic check points with NOK results: 43. Please check the details in diagnostic report

    Modify RU DDR Post Result Trigger 43 NOK&OK    restore_ddr=True
    Verify Full Diagnostic Check Results Via WebEM    expect_result=${RU1_RU2_40_41_42_43_OK}
    ...    allow_service_impact=${True}
    Verify RU Reset Via Uptime On WebEM    rus_index=${RU1_RU2_INDEX}
    Run Keyword If    '${IS_TMO}'!='True'
    ...    Verify BTS Alarm Not Exist    fault_id=4681    fault_name=Diagnostic Check Error

    # Run On RU2
    Modify Parameter On BTS With Activate    dist_name=${CHECK_POINTS_DIST}    parameter=${CHECK_POINTS_ABBREVIATION}
    ...    value=${EXCLUDED_POINTS_CB010823_B_40_41_42}
    Modify Parameter On BTS With Activate    dist_name=${DIAGNOSTIC_CHECK_DIST}    parameter=${DIAGNOSTIC_CHECK_ABBREVIATION}
    ...    value=true

    Modify RU DDR Post Result Trigger 43 NOK&OK    ru_index=2    restore_ddr=False
    Verify Customized Diagnostic Check Results Via WebEM    radio_params=${CUSTOM_CHECK_RU1_RU2_40_41_42_43_WEBEM}
    ...    expect_result=${RU1_43OK_RU2_43NOK}
    Verify RU Reset Via Uptime On WebEM    rus_index=${RU1_RU2_INDEX}
    Run Keyword If    '${IS_TMO}'!='True'
    ...    Verify BTS Alarm Not Exist    fault_id=4681    fault_name=Diagnostic Check Error

    Modify Parameter On BTS With Activate    dist_name=${CHECK_POINTS_DIST}    parameter=${CHECK_POINTS_ABBREVIATION}
    ...    value=${EXCLUDED_POINTS_CB010823_B}
    Verify Full Diagnostic Check Results Via WebEM    expect_result=${RU1_43OK_RU2_43NOK_40_41_42_OK}
    ...    allow_service_impact=${True}
    Verify RU Reset Via Uptime On WebEM    rus_index=${RU1_RU2_INDEX}
    Run Keyword If    '${IS_TMO}'!='True'
    ...    Wait Until Keyword Succeeds    5min    30s    Verify BTS Alarm Exist
    ...    fault_id=4681    fault_name=Diagnostic Check Error
    ...    fault_info=Failed diagnostic check points with NOK results: 43. Please check the details in diagnostic report

    Modify RU DDR Post Result Trigger 43 NOK&OK    ru_index=2    restore_ddr=True
    Verify Full Diagnostic Check Results Via WebEM    expect_result=${RU1_RU2_40_41_42_43_OK}
    ...    allow_service_impact=${True}
    Verify RU Reset Via Uptime On WebEM    rus_index=${RU1_RU2_INDEX}
    Run Keyword If    '${IS_TMO}'!='True'
    ...    Verify BTS Alarm Not Exist    fault_id=4681    fault_name=Diagnostic Check Error
    AlarmWatchdog.remove_allow_alarms    fault_id=4681
