*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB006627: Flexible synchronization behavior management library


*** Keywords ***
Check FaultId 4731
    [Documentation]    Check that FaultId 4731 is raised at the right time
    [Arguments]    ${bts_addr}    ${maxAbsoluteTimeError}

    ${estimated_duration}=    COAM Get Estimated Time To disable App    ${bts_addr}
    ${estimated_sec}=    Convert Web Time    ${estimated_duration}
    ${estimated_sec}=    Convert To Integer    ${estimated_sec}
    ${estimated_sec_min}=    Evaluate    ${estimated_sec} * 0.9
    ${estimated_sec_max}=    Evaluate    ${estimated_sec} * 1.1
    ${time_to_sleep}=    Evaluate    ${estimated_sec} / 20.0

    # Current Time
    ${start_currentTime}=    Get Time
    ${start_epochDate}=    Convert Date    ${start_currentTime}    epoch

    # Time to end checks
    ${endTimeMax}=    Add Time To Date    ${start_currentTime}    ${estimated_sec_max}
    ${maxTime}=    Convert Date    ${endTimeMax}    epoch

    # Earliest Time to have alarm
    ${endTimeMin}=    Add Time To Date    ${start_currentTime}    ${estimated_sec_min}
    ${minTime}=    Convert Date    ${endTimeMin}    epoch

    # Previous phase error
    ${phase_error}=    Set Variable    0

    # While...
    FOR    ${index}    IN RANGE    9999
        ${previous_phase_error}=    Set Variable    ${phase_error}
        ${phase_error}=    COAM Get Phase Error    ${bts_addr}
        IF    ${phase_error} >= ${maxAbsoluteTimeError}    BREAK

        ${deviation}=    Evaluate    ${phase_error} - ${previous_phase_error}
        ${remaining}=    Evaluate    ${maxAbsoluteTimeError} - ${phase_error}

        # 4731 is not raised (we don't check if phase error was is to close to the target.. it could be reached now)
        # Run Keyword If    ${remaining} > ${deviation}    COAM Check Fault not Displayed in webEM    ${bts_addr}    4731
        ${status}    ${result}=    Run Keyword And Ignore Error
        ...    COAM Check Fault not Displayed in webEM
        ...    ${bts_addr}
        ...    4731

        IF    "${status}" == "FAIL"
            Check Phase Error greater than    ${bts_addr}    ${maxAbsoluteTimeError}
        END

        Sleep    ${time_to_sleep}

        # Stop if it's time to
        ${currentTime}=    Get Time
        ${epochDate}=    Convert Date    ${currentTime}    epoch
        IF    ${epochDate} > ${maxTime}    BREAK
    END

    # 4731 is raised
    COAM Check Fault Displayed in webEM    ${bts_addr}    4731

    # Check if it's not to early
    ${currentTime}=    Get Time
    ${epochDate}=    Convert Date    ${currentTime}    epoch
    Should Be True    ${epochDate} > ${minTime}

    ${elapsed_time}=    Subtract Time From Time    ${epochDate}    ${start_epochDate}
    [Return]    ${elapsed_time}
    RETURN    ${elapsed_time}

Check Phase Error Greater Than
    [Documentation]    Check that phase error is larger than a value
    [Arguments]    ${bts_addr}    ${timeError}

    ${phase_error}=    COAM Get Phase Error    ${bts_addr}

    Should Be True    ${phase_error} >= ${timeError}

Wait Phase Error Larger
    [Documentation]    Wait for phase Error to reach a value during a specified max time
    [Arguments]    ${bts_addr}    ${maxTimeError}    ${maxTime}

    # Current Time
    ${currentTime}=    Get Time

    # Time to end checks
    ${endLastTime}=    Add Time To Date    ${currentTime}    ${maxTime}
    ${LastTime}=    Convert Date    ${endLastTime}    epoch

    # While...
    FOR    ${index}    IN RANGE    9999
        ${phase_error}=    COAM Get Phase Error    ${bts_addr}
        IF    ${phase_error} >= ${maxTimeError}    BREAK

        Sleep    1 min

        # Stop if it's time to
        ${currentTime}=    Get Time
        ${epochDate}=    Convert Date    ${currentTime}    epoch
        IF    ${epochDate} > ${LastTime}
            Fail    Phase Error does'nt reach ${maxTimeError}
        END
        IF    ${epochDate} > ${LastTime}    BREAK
    END

Check All Cells Enabled
    [Documentation]    Get 4G&5G cells status
    [Arguments]    ${enb_addr}    ${gnb_addr}

    COAM Get 4g status enabled    ${enb_addr}
    COAM Get 5g status enabled    ${gnb_addr}
