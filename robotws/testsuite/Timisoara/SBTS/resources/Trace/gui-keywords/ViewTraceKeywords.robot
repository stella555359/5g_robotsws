*** Settings ***
Documentation     [PURPOSE] counter keywords
#Library           RemoteSwingLibrary


*** Keywords ***
Show Messages In Trace Analysis Window
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${start_date}: <description>
    ...        ${start_time}: <description>
    ...        ${stop_date}: <description>
    ...        ${stop_time}: <description>
    [Arguments]     ${start_date}    ${start_time}    ${stop_date}    ${stop_time}
    Wait Until Keyword Succeeds	    30s	    1s	    RemoteSwingLibrary.Select Window	    regexp=^Trace Analysis.*
    Focus To Component    START_DATE
    Type Into Combobox	START_DATE	${start_date}
    Focus To Component    START_TIME
    Type Into Combobox	START_TIME	${start_time}
    Focus To Component    STOP_DATE
    Type Into Combobox	STOP_DATE	${stop_date}
    Focus To Component    STOP_TIME
    Type Into Combobox	STOP_TIME	${stop_time}
    Click On Component	LOAD_BUTTON

Get Counter Value For Event By Name
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${eventRowId}: <description>
    ...        ${counterName}: <description>
    ...
    ...    Returns:
    ...        ${counterValue}: <description>
    [Arguments]    ${eventRowId}    ${counterName}
    ${eventRow}=    Evaluate    ${eventRowId} - 1
    Wait Until Keyword Succeeds    10s    3s    Click On Table Cell    EVENT_TABLE     ${eventRow}   0
    ${counterRow}=    Wait Until Keyword Succeeds    30s    2s    Get Row Number For Counter    ${counterName}
    ${counterValue}=    Wait Until Keyword Succeeds    10s    3s
    ...     Get Table Cell Value    COUNTER_TABLE    ${counterRow}    1
    [Return]    ${counterValue}

Get Row Number For Counter
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${counterName}: <description>
    ...
    ...    Returns:
    ...        ${counterRow}: <description>
     [Arguments]    ${counterName}
     ${counterRow}=    Find Table Row   COUNTER_TABLE    ${counterName}
     Should Not Be Equal As Integers     ${counterRow}    -1
     [Return]     ${counterRow}
