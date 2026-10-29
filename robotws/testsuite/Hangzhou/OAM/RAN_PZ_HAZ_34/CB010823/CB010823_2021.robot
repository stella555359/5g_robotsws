# @Time    : 2023/10/3 9:05
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB010823_2021.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CB010823 2 cases on 2021

Suite Setup         Run Keywords    SISO Coam Suite Setup
...    AND     Set Suite Variables Via SW Version
Suite Teardown      SISO Coam Suite Teardown
Test Setup          MMW5 Common Case Setup    allowed_faults_ids=4681,4589
Test Teardown       MMW5 Common Case Teardown
Force Tags          CRT_TRUNK    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/feature/CB010823_common_keywords.robot

*** Variables ***
${if_commissioning}    True
@{POINT_40_WEBEM}    40 - RU SW package and NVM integrity
@{POINT_41_WEBEM}    41 - RU Memory usage
@{POINT_42_WEBEM}    42 - RU Temperature sensor
@{POINT_41_42_WEBEM}    41 - RU Memory usage    42 - RU Temperature sensor
@{POINT_40_41_42_WEBEM}    40 - RU SW package and NVM integrity    41 - RU Memory usage    42 - RU Temperature sensor

&{CUSTOM_CHECK_RU1_RU2_40_41_42_WEBEM}    RMOD-1 / RMOD_R-1 (AEHC)=@{POINT_40_41_42_WEBEM}
...    RMOD-2 / RMOD_R-2 (AEHC)=@{POINT_40_41_42_WEBEM}
&{CUSTOM_CHECK_RU1_RU2_41_42_WEBEM}    RMOD-1 / RMOD_R-1 (AEHC)=@{POINT_41_42_WEBEM}
...    RMOD-2 / RMOD_R-2 (AEHC)=@{POINT_41_42_WEBEM}
&{CUSTOM_CHECK_RU1_RU2_41_WEBEM}    RMOD-1 / RMOD_R-1 (AEHC)=@{POINT_41_WEBEM}
...    RMOD-2 / RMOD_R-2 (AEHC)=@{POINT_41_WEBEM}
&{CUSTOM_CHECK_RU1_RU2_40_WEBEM}    RMOD-1 / RMOD_R-1 (AEHC)=@{POINT_40_WEBEM}
...    RMOD-2 / RMOD_R-2 (AEHC)=@{POINT_40_WEBEM}
&{CUSTOM_CHECK_RU1_41_42_WEBEM}    RMOD-1 / RMOD_R-1 (AEHC)=@{POINT_41_42_WEBEM}
&{CUSTOM_CHECK_RU1_40_WEBEM}    RMOD-1 / RMOD_R-1 (AEHC)=@{POINT_40_WEBEM}
&{CUSTOM_CHECK_RU1_41_WEBEM}    RMOD-1 / RMOD_R-1 (AEHC)=@{POINT_41_WEBEM}
&{CUSTOM_CHECK_RU1_42_WEBEM}    RMOD-1 / RMOD_R-1 (AEHC)=@{POINT_42_WEBEM}
&{CUSTOM_CHECK_RU2_41_WEBEM}    RMOD-2 / RMOD_R-2 (AEHC)=@{POINT_41_WEBEM}
&{CUSTOM_CHECK_RU2_42_WEBEM}    RMOD-2 / RMOD_R-2 (AEHC)=@{POINT_42_WEBEM}
@{RADIO_MODUDLES_RU1}    RMOD_R-1
@{RADIO_MODUDLES_RU2}    RMOD_R-2
@{RADIO_MODUDLES_RU1_RU2}    RMOD_R-1    RMOD_R-2

@{EXCLUDED_POINTS_CB010239}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}
...    ${11}    ${12}    ${13}    ${14}    ${15}    ${16}    ${17}    ${18}    ${19}    ${20}    ${21}    ${22}    ${23}
...    ${24}    ${25}    ${26}    ${27}    ${28}    ${29}    ${30}    ${31}    ${32}    ${33}    ${34}    ${35}    ${36}
...    ${37}    ${38}    ${39}    ${40}    ${43}
@{EXCLUDED_POINTS_CB010239_41}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}
...    ${11}    ${12}    ${13}    ${14}    ${15}    ${16}    ${17}    ${18}    ${19}    ${20}    ${21}    ${22}    ${23}
...    ${24}    ${25}    ${26}    ${27}    ${28}    ${29}    ${30}    ${31}    ${32}    ${33}    ${34}    ${35}    ${36}
...    ${37}    ${38}    ${39}    ${40}    ${41}    ${43}
@{EXCLUDED_POINTS_CB010239_42}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}
...    ${11}    ${12}    ${13}    ${14}    ${15}    ${16}    ${17}    ${18}    ${19}    ${20}    ${21}    ${22}    ${23}
...    ${24}    ${25}    ${26}    ${27}    ${28}    ${29}    ${30}    ${31}    ${32}    ${33}    ${34}    ${35}    ${36}
...    ${37}    ${38}    ${39}    ${40}    ${42}    ${43}
@{EXCLUDED_POINTS_CB010823_F}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}
...    ${11}    ${12}    ${13}    ${14}    ${15}    ${16}    ${17}    ${18}    ${19}    ${20}    ${21}    ${22}    ${23}
...    ${24}    ${25}    ${26}    ${27}    ${28}    ${29}    ${30}    ${31}    ${32}    ${33}    ${34}    ${35}    ${36}
...    ${37}    ${38}    ${39}    ${43}

@{CHECK_POINTS_40}    40
@{CHECK_POINTS_41}    41
@{CHECK_POINTS_42}    42
@{CHECK_POINTS_41_42}    41    42
@{CHECK_POINTS_40_42}    40    42
@{CHECK_POINTS_40_41_42}    40    41    42
@{CHECK_POINTS_41_42_INT}    ${41}    ${42}

# CB010823 feature params
${CHECK_POINTS_DIST}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
${CHECK_POINTS_ABBREVIATION}    excludedDiagnosticCheckPoints
${DIAGNOSTIC_CHECK_DIST}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
${DIAGNOSTIC_CHECK_ABBREVIATION}    actDiagnosticCheck

# schedule diagnostic check time
&{CHECK_DAY}    Monday=1    Tuesday=2    Wednesday=4    Thursday=8    Friday=16    Saturday=32    Sunday=64


*** Test Cases ***
CB010823-A_003_WebEM customized diagnostic check_without service impact_disable some checkpoints_start button
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/09/22 13:40
    [Tags]    003
    # case precondition: actDiagnosticCheck=false
    # excludedDiagnosticCheckPoints:all CB010239 checkpoints are disabled/in the list
    # all CB010823 checkpoints41 42 are enabled/not in the list.
    Modify Parameter On BTS With Activate    dist_name=${CHECK_POINTS_DIST}    parameter=${CHECK_POINTS_ABBREVIATION}
    ...    value=${EXCLUDED_POINTS_CB010239}
    Modify Parameter On BTS With Activate    dist_name=${DIAGNOSTIC_CHECK_DIST}    parameter=${DIAGNOSTIC_CHECK_ABBREVIATION}
    ...    value=false

    # check 41&42 ok
    Verify Customized Diagnostic Check Normal    radio_params=${CUSTOM_CHECK_RU1_RU2_41_42_WEBEM}
    ...    radio_modules=${RADIO_MODUDLES_RU1_RU2}    radio_points=${CHECK_POINTS_41_42}

    # remove 41, can not check 41, check 42 ok
    Modify Parameter On BTS With Activate    dist_name=${CHECK_POINTS_DIST}    parameter=${CHECK_POINTS_ABBREVIATION}
    ...    value=${EXCLUDED_POINTS_CB010239_41}
    Selenium Login And Disable Screen Lock
    ${check_41_result}    Run Keyword And Return Status    selenium_sbts.start_diagnostic_check
    ...    scope=Customized diagnostic check    radio_checkpoints=${CUSTOM_CHECK_RU1_41_WEBEM}
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Should Be True    '${check_41_result}'=='False'

    Verify Customized Diagnostic Check Normal    radio_params=${CUSTOM_CHECK_RU1_42_WEBEM}
    ...    radio_modules=${RADIO_MODUDLES_RU1}    radio_points=${CHECK_POINTS_42}

    # remove 42, can not check 42, check 41 ok
    Modify Parameter On BTS With Activate    dist_name=${CHECK_POINTS_DIST}    parameter=${CHECK_POINTS_ABBREVIATION}
    ...    value=${EXCLUDED_POINTS_CB010239_42}
    Selenium Login And Disable Screen Lock
    ${check_42_result}    Run Keyword And Return Status    selenium_sbts.start_diagnostic_check
    ...    scope=Customized diagnostic check    radio_checkpoints=${CUSTOM_CHECK_RU2_42_WEBEM}
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Should Be True    '${check_42_result}'=='False'

    Verify Customized Diagnostic Check Normal    radio_params=${CUSTOM_CHECK_RU2_41_WEBEM}
    ...    radio_modules=${RADIO_MODUDLES_RU2}    radio_points=${CHECK_POINTS_41}

CB010823-F_013_WebEM checkpoint 40 NOK alarm one RU OK one NOK_Call
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/12/29 16:24
    [Tags]    F013
    Modify Parameter On BTS With Activate    dist_name=${CHECK_POINTS_DIST}    parameter=${CHECK_POINTS_ABBREVIATION}
    ...    value=${EXCLUDED_POINTS_CB010823_F}
    Modify Parameter On BTS With Activate    dist_name=${DIAGNOSTIC_CHECK_DIST}    parameter=${DIAGNOSTIC_CHECK_ABBREVIATION}
    ...    value=true

    Modify RU Swman Digest    position=left
    Verify Customized Diagnostic Check Normal    radio_params=${CUSTOM_CHECK_RU1_RU2_40_WEBEM}
    ...    radio_modules=${RADIO_MODUDLES_RU2}    radio_points=${CHECK_POINTS_40}
    ...    last_definitive_result=Check point failure    last_execution_result=Check point failure
    Verify Customized Diagnostic Check Normal    radio_params=${CUSTOM_CHECK_RU1_RU2_40_WEBEM}
    ...    radio_modules=${RADIO_MODUDLES_RU1}    radio_points=${CHECK_POINTS_40}
    ...    last_definitive_result=Check point successful    last_execution_result=Check point successful
    Verify BTS Alarm Not Exist    fault_id=4681    fault_name=Diagnostic Check Error

    Verify Diagnostic Check Result Via Admin CLI    check_point_id=40
    ...    dist_name=MRBTS-${MRBTS_ID}/EQM_R-4/APEQM_R-1/RMOD_R-1    result=Check point successful
    Verify Diagnostic Check Result Via Admin CLI    check_point_id=40
    ...    dist_name=MRBTS-${MRBTS_ID}/EQM_R-4/APEQM_R-1/RMOD_R-2    result=Check point failure
    Run Keyword If    '${IS_TMO}'!='True'
    ...    Wait Until Keyword Succeeds    5min    30s    Verify BTS Alarm Exist
    ...    fault_id=4681    fault_name=Diagnostic Check Error
    ...    fault_info=Failed diagnostic check points with NOK results: 40. Please check the details in diagnostic report

    Modify RU Swman Digest    position=left    restore_digest=True
    Connect to gnb coam via ssl    connection=GNB_OAM
    coam.reset_site    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
    Verify BTS Alarm Not Exist    fault_id=4681    fault_name=Diagnostic Check Error
    Verify Customized Diagnostic Check Normal    radio_params=${CUSTOM_CHECK_RU1_RU2_40_WEBEM}
    ...    radio_modules=${RADIO_MODUDLES_RU1_RU2}    radio_points=${CHECK_POINTS_40}

    [Teardown]    Run Keywords    Modify RU Swman Digest    position=left    restore_digest=True
    ...    AND    MMW5 Common Case Teardown

CB010823-F_017_Schedule trigger online checkpoints
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/12/28 16:28
    [Tags]    F017
    Modify Parameter On BTS With Activate    dist_name=${CHECK_POINTS_DIST}    parameter=${CHECK_POINTS_ABBREVIATION}
    ...    value=${EXCLUDED_POINTS_CB010823_F}
    Modify Parameter On BTS With Activate    dist_name=${DIAGNOSTIC_CHECK_DIST}    parameter=${DIAGNOSTIC_CHECK_ABBREVIATION}
    ...    value=true
    ${diagnostic_check_schedule_start_time_verify}    robot.libraries.DateTime.Get Current Date
    ...    time_zone=UTC    result_format=%Y-%m-%dT%H:%M:%S+08:00    increment=+8hours2mins
    ${diagnostic_check_schedule_start_time}    robot.libraries.DateTime.Get Current Date
    ...    time_zone=UTC    result_format=%H:%M:%S    increment=+8hours2mins
    ${weekday}    robot.libraries.DateTime.Get Current Date    result_format=%A
    &{DIAGNOSTIC_CHECK_SCHEDULE}    Create Dictionary    checkDays=${CHECK_DAY["${weekday}"]}
    ...    checkTime=${diagnostic_check_schedule_start_time}
    @{DIAGNOSTIC_CHECK_SCHEDULE_LIST}    Create List    ${DIAGNOSTIC_CHECK_SCHEDULE}
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    parameter=diagnosticCheckSchedule    value=${DIAGNOSTIC_CHECK_SCHEDULE_LIST}
    Sleep    120s
    Verify Diagnostic Check Time Later Than Schedule Time    check_time=${diagnostic_check_schedule_start_time_verify}

    Connect to gnb coam via ssl    connection=GNB_OAM
    ${report1}    coam.get_diagnostic_report    connection=GNB_OAM

    ${diagnostic_check_schedule_start_time}    robot.libraries.DateTime.Get Current Date
    ...    time_zone=UTC    result_format=%H:%M:%S    increment=+8hours2mins
    ${diagnostic_check_schedule_start_time_verify}    robot.libraries.DateTime.Get Current Date
    ...    time_zone=UTC    result_format=${TIME_FORMAT_DIFF_BRANCH}    increment=+8hours2mins
    ${weekday}    robot.libraries.DateTime.Get Current Date    result_format=%A    increment=+24hours
    &{DIAGNOSTIC_CHECK_SCHEDULE}    Create Dictionary    checkDays=${CHECK_DAY["${weekday}"]}
    ...    checkTime=${diagnostic_check_schedule_start_time}
    @{DIAGNOSTIC_CHECK_SCHEDULE_LIST}    Create List    ${DIAGNOSTIC_CHECK_SCHEDULE}
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    parameter=diagnosticCheckSchedule    value=${DIAGNOSTIC_CHECK_SCHEDULE_LIST}
    Sleep    120s

    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
    Connect to gnb coam via ssl    connection=GNB_OAM
    ${report2}    coam.get_diagnostic_report    connection=GNB_OAM
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM

    Should Be Equal    ${report1}    ${report2}

CB010823-F_020_Automatic execution of Diagnostic check when BTS starts up successfully
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/12/29 13:32
    [Tags]    F020
    Modify Parameter On BTS With Activate    dist_name=${CHECK_POINTS_DIST}    parameter=${CHECK_POINTS_ABBREVIATION}
    ...    value=${EXCLUDED_POINTS_CB010823_F}
    Modify Parameter On BTS With Activate    dist_name=${DIAGNOSTIC_CHECK_DIST}    parameter=${DIAGNOSTIC_CHECK_ABBREVIATION}
    ...    value=true

    ${number_of_executions1}    Get Diagnostic Execution Number From Snapshot    radio_points=${CHECK_POINTS_40_41_42}

    Connect to gnb coam via ssl    connection=GNB_OAM
    coam.reset_site    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    15s    Verify BTS All Cells Status Is Normal State
    ${number_of_executions2}    Get Diagnostic Execution Number From Snapshot    radio_points=${CHECK_POINTS_40_41_42}
    ${add_number}    Evaluate    ${number_of_executions2}-${number_of_executions1}
    Should Be True    ${add_number}==6

    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
    Connect to gnb coam via ssl    connection=GNB_OAM
    CI_interface.Common Suite Setup    gnb_index=0
    Wait Until Keyword Succeeds    15min    15s    Verify BTS All Cells Status Is Normal State
    ${number_of_executions3}    Get Diagnostic Execution Number From Snapshot    radio_points=${CHECK_POINTS_40_41_42}
    ${add_number}    Evaluate    ${number_of_executions3}-${number_of_executions2}
    Should Be True    ${add_number}==6

    Perform Site Power Off
    Perform RU Power Off    ru_index=1
    Perform RU Power Off    ru_index=2
    Sleep    60s
    Perform Site Power On
    Perform RU Power On    ru_index=1
    Perform RU Power On    ru_index=2
    Sleep    300s
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
    Connect to gnb coam via ssl    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    15s    Verify BTS All Cells Status Is Normal State
    ${number_of_executions4}    Get Diagnostic Execution Number From Snapshot    radio_points=${CHECK_POINTS_40_41_42}
    ${add_number}    Evaluate    ${number_of_executions4}-${number_of_executions3}
    Should Be True    ${add_number}==6
