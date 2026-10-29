*** Settings ***
Documentation
...  Testline Multireset Test
...
...  Author Karol Sadowski
...  karol.sadowski@nokia.com
...
...  Basic reset test in loops
...  Randomly pick and perform one reset scenario
...  Check cell status, fault list after every iteration.
...  Gathers syslog, snapshot and IM log after fail
...  Recovers testline after test fails.
...  Prepare custom logs from failed iterations
...  Reset type counter

Resource    ./../../Resources/cbrs_common_keywords.robot
Library     taf.ul.alarms_watchdog
Library     ./Data/alarms.py        WITH NAME  alarms

*** Keywords ***

Multireset In Loop

    ${time_start}   Get Time
    Set Test Variable    ${TEST_BEGIN_TIME}     ${time_start}

    Kill All SAS Processes
    Start SAS Process

    ${RESET_COUNTER}   Create Dictionary
    ...    Perform Site Reset=${0}
    ...    Perform Lock/Unlock Of Randomly Picked RMOD=${0}
    ...    Perform Block Unblock Of Randomly Picked Cells=${0}
    ...    Perform Power Reset Of Randomly Picked RMOD=${0}
    ...    Perform Reset Of Randomly Picked BBMOD=${0}

    Create File    ${TEST_LOGS_DIR_PATH}/CustomLogs.log

    Wait For All Cells To Be OnAir

    FOR    ${loop_nr}    IN RANGE    1    ${NUMBER_OF_LOOPS}+1

        ${random_test}   Evaluate    random.sample(${TESTS_SCENARIOS}, 1)    modules=random
        Log to console with time  \n------------------- ${random_test[0]} - LOOP: ${loop_nr}/${NUMBER_OF_LOOPS} -------------------

        ${key}   Set Variable    ${random_test[0]}
        ${count}   Evaluate     ${RESET_COUNTER}[${key}] + 1
        Set To Dictionary    ${RESET_COUNTER}    ${random_test[0]}    ${count}

        IF  ${CONTINUE_ON_FAIL}
            Run Keyword And Continue On Failure    Reset Action    ${random_test}    loop=${loop_nr}
        ELSE
            Reset Action    ${random_test}    loop=${loop_nr}
        END

        Set Test Variable    ${LOOPS_DONE}    ${loop_nr}

        ${time_stop}   Get Time
        Set Test Variable    ${TEST_END_TIME}     ${time_stop}

    END

    [Teardown]    Run Keywords
    ...    Write Reset Counters Into Custom Logs File    counters=${RESET_COUNTER}    AND
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Collect SysLog DCAP    trace_id=${SYSLOG_TRACE}    filename=${TEST_LOGS_DIR_PATH}/Syslog.zip


*** Keywords ***

Reset Action
        [Arguments]    ${random_test}    ${loop}

        Wait Until BTS Is Not Busy
        Start alarms watchdog


        IF  '${random_test[0]}'=='Perform Site Reset'
            ${status_0}   Run Keyword And Ignore Error
            ...    taf.sbts.oam.coam.admin.Reset Site
            ...    connection=${ALIAS}
            ...    wait_for_reconnection=True
            ...    timeout=10min
        ELSE
            ${status_0}   Run Keyword And Ignore Error  Run Keywords    ${random_test[0]}
        END
        ${status_1}   Run Keyword And Ignore Error    Wait Until Keyword Succeeds    150x    5sec
        ...    Check Cells    admin_alias=${ALIAS}

        ${status_2}   Run Keyword And Ignore Error    Wait Until Keyword Succeeds    10x    5s
        ...    Admin Alarms Get And Check    allowed=${enb_allowed_alarms}    alias=${alias}

        ${status_3}   Run Keyword And Ignore Error     Check alarms and stop watchdog on eNB

        Write Loop Into Custom Logs File    ${status_0}    ${status_1}    ${status_2}    ${status_3}    ${loop}    ${random_test}
        ${status}  Set Variable If  '${status_1[0]}'=='FAIL' or '${status_2[0]}'=='FAIL' or '${status_3[0]}'=='FAIL'  Fail  Pass
        IF  '${status}'=='Fail'  Fail  'Loop Failed, check logs!'

        [Teardown]  Teardown action recovey

Teardown action recovey
    IF  '${status}'=='Fail'
        taf.sbts.oam.coam.admin.Collect Snapshot  target_file_name=${TEST_LOGS_DIR_PATH}/snapshot_loop_${loop}.zip  timeout=1800  connection=RAT_1ST
        Recovery Action
    END

Recovery Action

    Wait Until Keyword Succeeds    3x    1s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    taf.sbts.oam.coam.admin.Perform Commissioning
           ...    bts_id=${testlines.${testline_id}.enb_id}
           ...    scf_file=${SUITE_LOGS_DIR_PATH}RAT_1ST_SCFC_Before_Suite.xml
           ...    connection=${ALIAS}

    Wait Until BTS Is Not Busy
    ${status_1}   Run Keyword And Return Status    Wait Until Keyword Succeeds    20x     1s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Check Cells    admin_alias=${ALIAS}
    ${status_2}   Run Keyword And Return Status    Wait Until Keyword Succeeds    5x    1s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Admin Alarms Get And Check    allowed=${enb_allowed_alarms}    alias=${alias}

    Return From Keyword If    ${status_1} and ${status_2}     "Testline repaired!"

    Wait Until Keyword Succeeds    3x     2s    Run Keywords
    ...    Switch Power Outlet Of BTS Radio Units    action=power_off    AND
    ...    Sleep    10s    AND
    ...    Switch Power Outlet Of BTS Radio Units    action=power_on

    ${status_1}   Run Keyword And Return Status    Wait Until Keyword Succeeds    20x     1s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Check Cells    admin_alias=${ALIAS}
    ${status_2}   Run Keyword And Return Status    Wait Until Keyword Succeeds    5x    1s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Admin Alarms Get And Check    allowed=${enb_allowed_alarms}    alias=${alias}

    [Teardown]    IF  ${status_1}==${False} or ${status_2}==${False}  Fatal Error  'Testline broken - further executions not possible!'

Write Reset Counters Into Custom Logs File
    [Arguments]    ${counters}
    Append To File    ${TEST_LOGS_DIR_PATH}/CustomLogs.log    \nstarted: ${TEST_BEGIN_TIME}
    Append To File    ${TEST_LOGS_DIR_PATH}/CustomLogs.log    \nended:${SPACE*3} ${TEST_END_TIME}\n\n
    Append To File    ${TEST_LOGS_DIR_PATH}/CustomLogs.log    \n\nDuring test done ${LOOPS_DONE} reset loops:\n
    Append To File    ${TEST_LOGS_DIR_PATH}/CustomLogs.log    =====================================================\n
    FOR    ${key}    IN    @{counters}
        Append To File    ${TEST_LOGS_DIR_PATH}/CustomLogs.log    ${key}: ${counters}[${key}]\n
    END

Write Loop Into Custom Logs File
    [Arguments]    ${status_0}    ${status_1}    ${status_2}    ${status_3}    ${loop}    ${random_test}

    Append To File    ${TEST_LOGS_DIR_PATH}/CustomLogs.log
    ...     ______________________________________________________________________________________________________\n\n-LOOP ${loop}. ${random_test[0]}
    ${status}  Set Variable If  '${status_0[0]}'=='FAIL'  Fail
    IF  '${status}'=='Fail'
        Append To File    ${TEST_LOGS_DIR_PATH}/CustomLogs.log    \n ${SPACE*5}== Reset Action Failed - results N/A ==\n    AND
        RETURN
    END
    ${status}  Set Variable If  '${status_1[0]}'=='FAIL' or '${status_2[0]}'=='FAIL'  Fail
    IF  '${status}'=='Fail'
        Append To File  ${TEST_LOGS_DIR_PATH}/CustomLogs.log  \n${SPACE*5}Check Cells Status: ${status_1[0]}\n${SPACE*7}== "${status_1[1]}" ==
        Append To File  ${TEST_LOGS_DIR_PATH}/CustomLogs.log
        ...  \n${SPACE*5}Check Alarms Status: ${status_2[0]}\n${SPACE*7}== "${status_2[1]}" ==\n${SPACE*7}== "${status_3[1]}" ==\n
        RETURN
    ELSE
       Append To File    ${TEST_LOGS_DIR_PATH}/CustomLogs.log     \n ${SPACE*5}== Reset Action Passed - results OK ==\n
    END

Collect Loop Logs
    [Arguments]    ${loop}

    Wait Until Keyword Succeeds    5x    10s    dcap.Stop Trace
    ...    trace_id=${LOGS_TRACE}
    ...    connection=RAT_1ST_dcap
    ...    timeout=60

    ute_admin_infomodel.Save Infomodel Log    filename=${logs_dir_path}/infomodel_loop_${loop}.ims2    timeout=300    alias=RAT_1ST

    Wait Until Keyword Succeeds    12min    30s     dcap.Get Results
    ...    result_id=${LOGS_TRACE}
    ...    target_dir=${TEST_LOGS_DIR_PATH}/Syslog_loop_${loop}.zip
    ...    connection=RAT_1ST_dcap
    ...    timeout=180

    Wait Until Keyword Succeeds    12min    15s     Start Collecting Logs    ${loop}


Start Collecting Logs
    [Arguments]    ${loop}

    ${parameters_bts}   Create List    immediateSnapshot
    ${parameters_enb}   Create List    condor4gSyslog
    ${bts_dict}   Create BTS Dictionary     host=192.168.255.129     port=443

    ${trace_id}   Wait Until Keyword Succeeds     6min    10s     dcap.Start Trace
    ...    bts=${bts_dict}
    ...    tag=Loop_${loop}
    ...    bts_custom_profile=${parameters_bts}
    ...    enb_custom_profile=${parameters_enb}
    ...    wait_for_activation=${True}
    ...    connection=RAT_1ST_dcap
    ...    force=${True}

    Set Test Variable     ${LOGS_TRACE}     ${trace_id['id']}

Start alarms watchdog
    [Documentation]  Starts watching alarms on BTS with default allowed alarms.
    [Arguments]    ${interval}=2 sec     ${log_dir}=${TEST_LOGS_DIR_PATH}

    @{allowed_alarms}   alarms.get_default_allowed_alarms_for_enb
    Log    Starting alarms watchdog on BTS    console=true
    Wait Until Keyword Succeeds    3x    10s    taf.ul.alarms_watchdog.watch_alarms
    ...                                         allowed_alarms=${allowed_alarms}
    ...                                         interval=${interval}
    ...                                         log_dir=${log_dir}

Check alarms and stop watchdog on eNB
    [Documentation]  Checks whether alarms watchdog detected any disallowed alarms on gNB BTS and stops watching alarms
    ...              afterwards.
    Log    Checking alarms and stopping watchdog on BTS
    taf.ul.alarms_watchdog.check_detected_alarms
    [Teardown]  taf.ul.alarms_watchdog.stop_watching_alarms
