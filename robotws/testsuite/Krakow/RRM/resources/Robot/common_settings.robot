*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     Collections
Library     DateTime
Library     OperatingSystem
Library     String
Library     Process
Library     ute_admin
Library     ute_fsmaccess
Library     ute_wtssim
Library     ta_emss
Library     ta_pcmd
Library     ta_messaging
Library     ta_measurements
Library     ta_egate_cmd_parser
Library     ta5g_commissioning
Library     ta5g_egate
Library     ta5g_pm_counters
Library     ta5g_ue_mobility
Library     ta5g_testline_management
Library     ta5g_iphy
Library     ta5g_enb
Library     ta5g_cell_operations
Library     ta5g_ue_measurements

Library     ta_messaging/robot_flow_framework/expect_keyword_listener.py
Resource    ta_messaging/flow.robot

Resource    common_keywords/attach_detach.robot
Resource    common_keywords/bwp.robot
Resource    common_keywords/counters.robot
Resource    common_keywords/gnb_commissioning.robot
Resource    common_keywords/gnb_ssh.robot
Resource    common_keywords/handover.robot
Resource    common_keywords/pcmd.robot
Resource    common_keywords/pdu_session.robot
Resource    common_keywords/traffic.robot
Resource    common_keywords/vran.robot

Library     ../Python/suite_setup_managment.py
Library     ../Python/common_reach_onair.py
Library     ../Python/utilities.py
Library     ../Python/short_syslog.py
Library     ../Python/emss_param_disp.py
Library     ../Python/emss_vran.py
Library     ../Python/vran.py
Library     ../Python/admin_cli.py
Library     ../Python/rtpm_validator.py

*** Keywords ***

Run Keyword When Not In UTE
    [Documentation]     Accepts only keyword without kwargs
    [Arguments]     @{keyword_name_with_args}
    ${cloud_exec_id}=   Get Environment Variable        CM_EXECUTION_ID     ${FALSE}
    Run Keyword if  '${cloud_exec_id}' == '${FALSE}'
    ...         @{keyword_name_with_args}

Omit when SKIP_COUNTERS present
    [Documentation]     Accepts only keyword without kwargs
    [Arguments]     @{keyword_name_with_args}
    ${if_skip_counters}=   get variable value        ${SKIP_COUNTERS}     ${FALSE}
    ${if_skip_counters}=        val to bool          ${if_skip_counters}
    Run Keyword if  ${if_skip_counters} == ${FALSE}
    ...         @{keyword_name_with_args}

Omit keyword when variable present
    [Documentation]     Accepts keyword with args and kwargs. Single line keywords must not have = sign or it should be
    ...                 escaped like \=
    [Arguments]     ${variable_name}    @{keyword_name_with_args}    &{keyword_name_with_kwargs}
    ${if_skip}=   get variable value        ${${variable_name}}     ${None}
    Run Keyword if  '${if_skip}' == '${None}'
    ...         @{keyword_name_with_args}    &{keyword_name_with_kwargs}


On failure
    [Documentation]     Accepts only keyword without kwargs
    [Arguments]     @{keyword_name_with_args}
    ${if_on_failure}=   get variable value        ${ON_FAILURE}         CONTINUE
    ${if_on_failure}    val remove quotes       ${if_on_failure}

    Run Keyword if  '${if_on_failure}' == 'CONTINUE'
    ...         Run Keyword And Continue On Failure
    ...         @{keyword_name_with_args}

    Run Keyword if  '${if_on_failure}' == 'IGNORE'
    ...         Run Keyword and ignore error
    ...         @{keyword_name_with_args}

Run And Continue On Failure And Teardown On Failed
    [Documentation]         This keyword can be used to execute some keyword teardown after it fails
    ...                     Teardown keyword cannot have arguments
    ...                     Note: Teardown keyowrd is allowed to fail
    ...                     Accepts keyword with args and kwargs. Single line keywords must not have = sign or it should be
    ...                     escaped like \=

    [Arguments]     ${teardown_keyword_without_args}     @{keyword_name_with_args}    &{keyword_name_with_kwargs}
    @{status_message}=      Run Keyword And Ignore Error      @{keyword_name_with_args}   &{keyword_name_with_kwargs}
    ${status}             Set variable         ${status_message[0]}
    ${error_received}     Set variable       ${status_message[1]}
    Run keyword if    '${status}'=='FAIL'
    ...        Run Keyword and ignore error
    ...        ${teardown_keyword_without_args}
    Run keyword if    '${status}'=='FAIL'
    ...        Run keyword and continue on failure
    ...        Fail
    ...        Keyword failed with error: ${error_received}

Run And Continue On Failure And Always Teardown
    [Documentation]         This keyword can be used to execute some keyword teardown unconditionally
    ...                     Teardown keyword cannot have arguments
    ...                     Note: Teardown keyowrd is allowed to fail
    ...                     Accepts keyword with args and kwargs. Single line keywords must not have = sign or it should be
    ...                     escaped like \=
    [Arguments]     ${teardown_keyword_without_args}        @{keyword_name_with_args}    &{keyword_name_with_kwargs}
    @{status_message}=      Run Keyword And Ignore Error      @{keyword_name_with_args}   &{keyword_name_with_kwargs}
    ${status}             Set variable         ${status_message[0]}
    ${error_received}     Set variable       ${status_message[1]}
    Run Keyword and ignore error
    ...        ${teardown_keyword_without_args}
    Run keyword if    '${status}'=='FAIL'
    ...        Run keyword and continue on failure
    ...        Fail
    ...        Keyword failed with error: ${error_received}

Run And Teardown On Failed
    [Documentation]         This keyword can be used to execute some keyword teardown after it fails
    ...                     Teardown keyword cannot have arguments
    ...                     Note: Teardown keyowrd is allowed to fail
    ...                     Accepts keyword with args and kwargs. Single line keywords must not have = sign or it should be
    ...                     escaped like \=

    [Arguments]     ${teardown_keyword_without_args}        @{keyword_name_with_args}   &{keyword_name_with_kwargs}
    @{status_message}=      Run Keyword And Ignore Error      @{keyword_name_with_args}    &{keyword_name_with_kwargs}
    ${status}             Set variable         ${status_message[0]}
    ${error_received}     Set variable       ${status_message[1]}
    Run keyword if    '${status}'=='FAIL'
    ...        Run Keyword and ignore error
    ...        ${teardown_keyword_without_args}
    Run keyword if    '${status}'=='FAIL'
    ...        Fail
    ...        Keyword failed with error: ${error_received}

Expect Keyword To Pass With Ratio
    [Documentation]        This keyword can be used for non-deterministic tests.
    ...                     Accepts keyword with args and kwargs. Single line keywords must not have = sign or it should be
    ...                     escaped like \=
    [Arguments]         ${pass}         ${attempts}       @{keyword_name_with_args}    &{keyword_name_with_kwargs}
    Set test variable    ${multiple_exec_result}      0
    ${multiple_exec_errors}=      Create List
    Log to console      [MULTI RUN ${attempts}] Running keyword: @{keyword_name_with_args} &{keyword_name_with_kwargs}
    FOR    ${i}    IN RANGE    ${attempts}
        ${att}=     Evaluate   ${i} + 1
        Log to console      Run ${att}/${attempts}
        @{status_message}=      Run Keyword And Ignore Error    @{keyword_name_with_args}    &{keyword_name_with_kwargs}
        ${status}             Set variable         ${status_message[0]}
        ${error_received}     Set variable       ${status_message[1]}
        ${multiple_exec_result}=    Run keyword if    '${status}'=='PASS'
        ...      Evaluate    ${multiple_exec_result} + 1
        ...      ELSE
        ...      Evaluate    ${multiple_exec_result} + 0
        Run keyword if    '${status}'=='FAIL'
        ...      Append to list     ${multiple_exec_errors}     ${error_received}
        Run keyword if    '${status}'=='FAIL'
        ...      Log to console     Failed with error: ${error_received}

    END
    Log to console       Keyword passed ${multiple_exec_result} out of ${attempts} attemps
    Run Keyword if     ${multiple_exec_result}<${pass}
    ...          Fail
    ...          Keyword @{keyword_name_with_args} passed ${multiple_exec_result} out of ${attempts} attempts. ${multiple_exec_errors}
    ...          ELSE
    ...          Log    Keyword passed ${multiple_exec_result} out of ${attempts} attemps       INFO

Run Keywords And Expect Single Pass
    [Documentation]    Wrapper for Run Keywords And Expect Number Of Passes with hardcoded number of passes to 1.
    ...                This gives shorter version as in exapmle:
    ...                Run Keywords And Expect single pass
    ...                Keyword to pass	2   b=3    AND
    ...                Keyword to fail	7   8    AND
    ...                Keyword to fail     c=4   d=5

    [Arguments]     @{keywords}
    Run Keywords And Expect Number Of Passes
    ...     1
    ...     @{keywords}

Run Keywords And Expect Number Of Passes
    [Documentation]     This keyword can be used when there is undertemined sequence of message and we know that
    ...                 only one of them should pass the criteria. Keyword with arguments should be joined with AND clause.
    ...                 Example:
    ...                 Run Keywords And Expect Number Of Passes
    ...                 2
    ...                 Keyword to pass	2   b=3    AND
    ...                 Keyword to pass	7   8    AND
    ...                 Keyword to fail     c=4   d=5
    ...                 Note! expected_passes argument must be given as arg, so writing expected_passes=4 is not allowed.

    [Arguments]     ${expected_passes}=1    @{keywords}
    @{split_keywords}		split_run_keywords		@{keywords}
    Set test variable    ${multiple_exec_result}      0
    ${multiple_exec_errors}=      Create List
    ${passed_kws}=  	Create List
    FOR    ${keyword}    IN    @{split_keywords}
        @{status_message}=      Run Keyword And Ignore Error   run_keywords_with_args    ${keyword}
        ${status}             Set variable         ${status_message[0]}
        ${error_received}     Set variable       ${status_message[1]}
        ${multiple_exec_result}=    Run keyword if    '${status}'=='PASS'
        ...      Evaluate    ${multiple_exec_result} + 1
        ...      ELSE
        ...      Evaluate    ${multiple_exec_result} + 0
        Run keyword if    '${status}'=='FAIL'
        ...      Append to list     ${multiple_exec_errors}     ${error_received}
        Run keyword if    '${status}'=='PASS'
        ...      Append to list     ${passed_kws}     ${keyword}
        Run keyword if    '${status}'=='FAIL'
        ...      Log to console     KW: ${keyword} Failed with error: ${error_received}
    END
    Run Keyword if     ${multiple_exec_result}!=${expected_passes}
    ...          Fail
    ...          ${multiple_exec_result} keywords passed.Expected pass runs: ${expected_passes}
    ...          ELSE
    ...          Log    Expected: ${expected_passes} keywords passed: ${passed_kws}

Open egate terminal

    ${cmd}=     catenate
    ...         xterm -T 'EPCSIM LOG ${TEST_START_TIME}' -geometry 200x30  -hold -e
    ...         'tail -f /opt/iphy/latest/egate_console.log | sed --unbuffered s"/\\[session.*/\\n\x1b[31m&\x1b[0m\\n\\n/g"'
    ${proc}=      Start process
    ...   ${cmd}
    ...   shell=True
    set suite variable     ${EGATE_CMD_PROCESS}         ${proc}

Close egate terminal
    run keyword and ignore error     Terminate process    ${EGATE_CMD_PROCESS}

Start flushing logs in backgorund
    no operation

Open xterm with log from last run
    ${cmd}=      catenate
    ...         xterm -geometry 200x30 -T 'EPCSIM LOG ${TEST_START_TIME}' -hold -e
    ...         'cat ${OUTPUT DIR}/egate_console_suite_color_${TEST_START_TIME}.log' &

    ${proc}=       Start process    ${cmd}
    ...            shell=True
    ${pid}         Get Process Id    ${proc}
    ${background_pid}       evaluate    ${pid}+1
    Run process    echo ${background_pid} > /tmp/.egate_proc   shell=True

Start egate collection
    run keyword and ignore error      Run process       cat /tmp/.egate_proc | xargs kill -9    shell=True
    Run keyword and ignore error      setup egate    20000      alias=log_collector     save_egate=${True}
    ${date} =	get_current_date
    set suite variable          ${TEST_START_TIME}          ${date}
    Execute egate command   cmd=set_log flush    alias=log_collector
    Execute egate command   cmd=echo TEST START ${date}    alias=log_collector
    Run Keyword When Not In UTE      Open egate terminal
    Run Keyword When Not In UTE      Start flushing logs in backgorund


Stop egate collection
    Execute egate command   cmd=set_log flush    alias=log_collector
    sleep     1
#    Teardown egate   alias=log_collector
    Run process     cp /opt/iphy/latest/egate_console.log ${OUTPUT DIR}/egate_console_full.log    shell=True
    Run Keyword When Not In UTE         Close egate terminal
    ${sed1}=    catenate
    ...    sed -n '/^TEST START ${TEST_START_TIME}$/,$p' ${OUTPUT DIR}/egate_console_full.log
    ...    > ${OUTPUT DIR}/egate_console_suite_${TEST_START_TIME}.log
    Run process    ${sed1}
    ...            shell=True
    ${sed2}=     catenate
    ...     sed s"/\\[session.*/\\n\x1b[31m&\x1b[0m\\n\\n/g" ${OUTPUT DIR}/egate_console_suite_${TEST_START_TIME}.log
    ...     > ${OUTPUT DIR}/egate_console_suite_color_${TEST_START_TIME}.log
    Run process    ${sed2}
    ...            shell=True
    Run Keyword When Not In UTE      Open xterm with log from last run

