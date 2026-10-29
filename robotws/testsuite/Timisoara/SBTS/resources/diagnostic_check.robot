*** Settings ***
Library     DateTime
Library     OperatingSystem
Library     taf.sbts.oam.coam.admin  WITH NAME  coam


*** Variables ***


*** Keywords ***
Get Single Checkpoint Results By CP Name
    [Documentation]
    ...  This keyword returns first found Checkpoint element(dict) from Diagnostic Check Report (parameter dc_resullt in keyword arguments).
    ...  Searched checkpoint is defined in argument cp_name.
    ...  *AUTHOR*
    ...  iuliia.taupeka@nokia.com

    [Arguments]    ${dc_result}    ${cp_name}
    ${found_checkpoints}    Set Variable    None
    FOR    ${CP}    IN    @{dc_result}
        ${checkpoint_name}    Get From Dictionary    ${CP}    checkpointName
        Log To Console    Checkpoint under check: ${checkpoint_name}
        Run Keyword If    '${checkpoint_name}' == '${cp_name}'
        ...    Return From Keyword    ${CP}
    END


Verify Checkpoints Timestamp
    [Documentation]
    ...  This keyword takes in arguments Checkpoint under check and timestamp gathered before Diagnostic Check run.
    ...  It is verified that checkpoint execution timestamp is greater than timestamp before DC run.
    ...  *AUTHOR*
    ...  iuliia.taupeka@nokia.com

    [Arguments]    ${checkpoint_under_check}    ${DC_run_time}
    ${cp_timestamp}    Get From Dictionary     ${checkpoint_under_check}    timestamp
    ${cp_timestamp}    Fetch From Left    ${cp_timestamp}    +
    Log    Timestamp ${cp_timestamp}    console=${True}
    ${time_compare_result}=	Set Variable If	 '${cp_timestamp}' >= '${DC_run_time}'	${True}	 ${False}
    Run Keyword Unless  ${time_compare_result}  Fail  CP timestamp: ${cp_timestamp} incorrect (less than DC start time: ${DC_run_time}).


Verify CP Status
    [Documentation]
    ...  This KW checks that result of checkpoint execution is as expected (OK or NOK - defined in argument: expected_status - set to OK by default).

    [Arguments]    ${checkpoint_under_check}    ${expected_status}=OK
    ${cp_result}    Get From Dictionary     ${checkpoint_under_check}    lastResult
    ${result_status}    Run Keyword And Ignore Error  Should Match  ${cp_result}  ${expected_status}
    Run Keyword If  '${result_status[0]}'=='PASS'
    ...  Log   Last checkpoint execution result is correct: ${cp_result}.  console=${TRUE}
    ...  ELSE  verdicts.Set Test Failed  Incorrect result of last CP execution: ${cp_result}.


Schedule Diagnostic Check
    [Documentation]
    ...  This keyword prepares and recommissions delta that schedules diagnostic check to start after declared time delay.
    ...  *AUTHOR*
    ...  damian.kotula@nokia.com
    ...  Example of simple usage:  Schedule Diagnostic Check   10 minutes

    [Arguments]   ${time_delay}=3 minutes
    ${TRBL_MNLENT_DISTNAME}  Set Variable   MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ${Current_Date}   Get Current Date
    ${DC_run_date}   Add Time To Date   ${Current_Date}   ${time_delay}   exclude_millis=True   result_format=%Y-%m-%d %H:%M:%S
    ${check_time}   Convert Date   ${DC_run_date}   result_format=%H:%M:%S
    ${DC_run_date}   Replace String   ${DC_run_date}   ${SPACE}   T
    Set Test Variable   ${DC_run_date}

    ${delta_id}   Set Variable   schedule_diagnostic_check
    coam.Create Delta   ${delta_id}
    coam.Append Complex Item To Delta
    ...   ${TRBL_MNLENT_DISTNAME}   list_name=diagnosticCheckSchedule   checkDays=127   checkTime=${check_time}   delta_id=${delta_id}
    coam.Get Delta   ${delta_id}
    coam.Save Delta   ${BTS Files}/schedule_diagnostic_delta.json   ${delta_id}
    coam.Perform Delta Recommissioning   ${BTS Files}/schedule_diagnostic_delta.json   skip_parameter_relation_errors=${True}
    Log   \nDiagnostic Check scheduled to start at ${check_time}   console=${True}


Get Checkpoint Result For SMOD
    [Documentation]
    ...  This keyword returns Checkpoint result from Diagnostic Check Report for specified checkpointId and SMOD.
    ...  |  Parameters               | Man. |  Description                                     |
    ...  |  smod_activeRole          | Yes  |  smod for fetched CP: Primary / Secondary        |
    ...  |  dc_result                | Yes  |  DC report from KW coam.Get Diagnostic Report    |
    ...  |  cp_id                    | Yes  |  id of checkpoint to get                         |
    ...  *RETURN*
    ...  |  Parameters           |  Description  |
    ...  |  CP                   |  dict with requested CP result from DC report  |
    ...  *AUTHOR*
    ...  damian.kotula@nokia.com
    ...  Example of simple usage:  Get Checkpoint Result For SMOD   Secondary   ${dc_result}   17

    [Arguments]   ${smod_activeRole}   ${dc_result}   ${cp_id}
    ${is_it_singlecore}   Run Keyword And Return Status   Variable Should Not Exist   ${SMOD2}
    Run Keyword If   ${is_it_singlecore}   Set Test Variable   ${smod_activeRole}   empty
    ...   ELSE   Set Test Variable   ${smod_activeRole}   "${smod_activeRole}"
    ${smod_obj}   Query Infomodel   get object //SMOD_R-* is [activeRole=${smod_activeRole}]
    ${smod_distname}   Fetch From Right   ${smod_obj.dist_name}   /

    ${found_checkpoints}   Set Variable   None
    FOR   ${CP}   IN   @{dc_result}
        ${checkpoint_id}   Get From Dictionary   ${CP}   checkpointId
        ${cp_distname}   Get From Dictionary   ${CP}   distName
        ${cp_distname}   Fetch From Right   ${cp_distname}   /
        Run Keyword If   '${checkpoint_id}' == '${cp_id}' and '${cp_distname}' == '${smod_distname}'
        ...   Return From Keyword   ${CP}
    END


Disable Diagnostic Checkpoints Except
    [Documentation]
    ...  This keyword prepares and recommissions delta that disables all diagnostic checkpoints except those passed as keyword arguments.
    ...  Multiple checkpoints can be passed as arguments.
    ...  *AUTHOR*
    ...  damian.kotula@nokia.com
    ...  Example of simple usage:  Disable Diagnostic Checkpoints Except  7  24  20

    [Arguments]   ${not_excluded_checkpoint}   @{more_not_excluded_checkpoints}
    ${list_of_not_excluded_CPs}   Create List   ${not_excluded_checkpoint}   @{more_not_excluded_checkpoints}
    Log   \nDisabling diagnostic checkpoints except CP ${list_of_not_excluded_CPs}.   console=${True}
    ${excluded_checkpoint_list}   Create List
    FOR   ${checkpoint}   IN RANGE   1   44
       ${match}   Evaluate   '${checkpoint}' in ${list_of_not_excluded_CPs}
       Run Keyword If   ${match}   Continue For Loop
       Append To List   ${excluded_checkpoint_list}   ${checkpoint}
    END
    Log   Excluded CheckPoint list: ${excluded_checkpoint_list}   console=${True}

    ${delta_id}   Set Variable   disable_CPs
    coam.Create Delta   ${delta_id}
    coam.Append List Items To Delta   ${TRBL_MNLENT_DISTNAME}   excludedDiagnosticCheckPoints   @{excluded_checkpoint_list}   delta_id=${delta_id}
    coam.Get Delta   ${delta_id}
    coam.Save Delta   ${BTS Files}/disable_CPs_delta.json   ${delta_id}
    coam.Perform Delta Recommissioning   ${BTS Files}/disable_CPs_delta.json   skip_parameter_relation_errors=${True}


Get DC Report And Check CP Result
    [Documentation]
    ...   This keyword verifies if checkpoint has expected status in latest diagnostic check report.
    ...  |  Parameters           | Man. |  Description                                                        |
    ...  |  checkpoint           | Yes  |  id of checkpoint to check                                          |
    ...  |  expected_status      | Yes  |  expected checkpoint status: OK / NOK                               |
    ...  |  smod_activeRole      | No   |  smod for fetched CP: Primary / Secondary. Primary by default       |
    ...  *AUTHOR*
    ...  damian.kotula@nokia.com
    ...  Example of simple usage:  Get DC Report And Check CP Result   13   NOK   Secondary

    [Arguments]   ${checkpoint}   ${expected_status}   ${smod_activeRole}=Primary
    Log   \nVerifying if CP '${checkpoint}' has expected status '${expected_status}' in DC Report.   console=${True}
    ${dc_report_connection}   coam.Connect To   name=dc_report_connection
    ${diagnostic_report}   coam.Get Diagnostic Report   connection=${dc_report_connection}
    ${found_checkpoint}   diagnostic_check.Get Checkpoint Result For SMOD   ${smod_activeRole}   ${diagnostic_report}   ${checkpoint}
    diagnostic_check.Verify Checkpoints Timestamp   ${found_checkpoint}   ${DC_run_date}
    diagnostic_check.Verify CP Status   ${found_checkpoint}   ${expected_status}
    coam.Teardown   connection=${dc_report_connection}


Perform Diagnostic Check
    [Documentation]
    ...   This keyword gets timestamp before running diagnostic check and performs diagnostic check

    ${DC_run_date}   DateTime.Get Current Date   exclude_millis=True   result_format=%Y-%m-%d %H:%M:%S
    Log   Timestamp before DC Start: ${DC_run_date}. Sleep for 10s and run Diagnostic Check.   console=${True}
    ${DC_run_date}   Replace String   ${DC_run_date}   ${SPACE}   T
    Set Test Variable   ${DC_run_date}
    Sleep   10s
    coam.Run Diagnostic Check   timeout=930
    Log   Diagnostic Check finished. [OK]   console=${True}


Check Alarm 4681
    [Documentation]
    ...   This keyword verifies status of fault 4681 with particular severity on BTS.
    ...  |  Parameters           | Man. |  Description                                    |
    ...  |  status               | Yes  |  status of expected alarm: Active / Inactive    |
    ...  |  severity             | Yes  |  seveirty of expected alarm: Minor / Warning    |
    ...  Example of simple usage:  Check Alarm 4681   Active   Warning

    [Arguments]   ${status}   ${severity}
    Log   \nCheck If Alarm 4681 is ${status} (severity: ${severity}).   console=${True}
    ${fault_status}   Run Keyword And Return Status   Wait Until Keyword Succeeds   120   10
    ...   coam.Assert Alarm ${status}   parameters=alarmId=7115, faultId=4681, faultName="Diagnostic Check Error", severity=${severity}   timeout=120
    Run Keyword If   ${fault_status}
    ...   Log   WebEM: Fault 4681 "Diagnostic Check Error" is ${status}. [OK]   console=${True}
    ...   ELSE   Set Test Failed   WebEM: Fault 4681 "Diagnostic Check Error" not ${status} on BTS. [NOK]


Schedule Service Impacted Diagnostic Check
    [Arguments]   ${time_delay}=4 minutes
    ${TRBL_MNLENT_DISTNAME}  Set Variable   MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ${Current_Date}   Get Current Date
    ${DC_run_date}    Add Time To Date   ${Current_Date}   ${time_delay}   exclude_millis=True   result_format=%Y-%m-%d %H:%M:%S
    ${CurrentDay}     Convert Date   ${DC_run_date}    result_format=%A
    ${check_time}     Convert Date   ${DC_run_date}   result_format=%H:%M:%S
    ${start_date}     Convert Date   ${DC_run_date}   result_format=%Y-%m-%d
    ${DC_run_date}    Replace String   ${DC_run_date}   ${SPACE}   T
    Set Test Variable   ${DC_run_date}
    Log    Perform recommissioning to schedule service impacted DC.    console=${True}
    ${delta_id}   Set Variable   schedule_servImp_diagnostic_check
    coam.Create Delta   ${delta_id}
    coam.Append Complex Item To Delta
    ...   ${TRBL_MNLENT_DISTNAME}   list_name=servImpDiagnosticCheckSchedule   checkDay=${CurrentDay}   checkTime=${check_time}
    ...   repeatEveryNWeeks=4   startDate=${start_date}    delta_id=${delta_id}
    coam.Get Delta   ${delta_id}
    coam.Save Delta   ${BTS Files}/schedule_servImp_diagnostic_delta.json   ${delta_id}
    coam.Perform Delta Recommissioning   ${BTS Files}/schedule_servImp_diagnostic_delta.json   skip_parameter_relation_errors=${True}
    Log   \nDiagnostic Check scheduled to start at ${check_time}   console=${True}
