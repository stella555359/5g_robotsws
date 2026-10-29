*** Settings ***
Documentation     [PURPOSE] main window keywords
#Library           RemoteSwingLibrary


*** Keywords ***
Select Last Trace In Main Table With Given Traced Number
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${tabNumber}: <description>
    ...        ${tracedNumber}: <description>
    [Arguments]    ${tabNumber}    ${tracedNumber}
	Clear Search	${tabNumber}
    Select Last Trace In Table    MAIN_VIEW_MAIN_TABLE    ${tabNumber}     tracedNumber_filter    ${tracedNumber}

Select Last Trace In Main Table With Given Trace Reference
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${tabNumber}: <description>
    ...        ${traceReference}: <description>
    [Arguments]    ${tabNumber}    ${traceReference}
    Select Last Trace In Table    MAIN_VIEW_MAIN_TABLE    ${tabNumber}     traceReference_filter    ${traceReference}

Select Last Trace In Ne Table With Given Trace Reference
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${tabNumber}: <description>
    ...        ${traceReference}: <description>
    [Arguments]    ${tabNumber}    ${traceReference}
    Select Last Trace In Table    MAIN_FULL_LOAD_TABLE    ${tabNumber}     traceReference_filter    ${traceReference}

Select Last Trace In Cell Table With Given Trace Reference
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${tabNumber}: <description>
    ...        ${traceReference}: <description>
    [Arguments]    ${tabNumber}    ${traceReference}
    RemoteSwingLibrary.Select Window    regexp=^TraceViewer.*
    Click On Component   MAIN_VIEW_REFRESH_TRACE_ICON
    Wait Until Keyword Succeeds    60s    1s    Select Last Trace In Table
    ...     MAIN_VIEW_CELL_TABLE    ${tabNumber}     traceReference_filter    ${traceReference}

Open Trace Analysis Window For Trace
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${tableName}: <description>
    ...        ${traceReference}: <description>
    [Arguments]  ${tableName}    ${traceReference}
    ${row}= 	Find Table Row    ${tableName}    ${traceReference}
    Wait Until Keyword Succeeds    30s    2s    Click On Cell In Table    ${tableName}    ${row}    0
    Push Button    MAIN_VIEW_VIEW_TRACE_ICON

Clear Trace Reference Filter
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${tabNumber}: <description>
    [Arguments]    ${tabNumber}
    Filter Traces    traceReference_filter  ${tabNumber}  ${EMPTY}

Clear Trace Number Filter
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${tabNumber}: <description>
    [Arguments]    ${tabNumber}
    Filter Traces    tracedNumber_filter  ${tabNumber}  ${EMPTY}

Clear All Filters
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${tabNumber}: <description>
    [Arguments]    ${tabNumber}
    Run Keyword And Ignore Error    Clear Trace Reference Filter    ${tabNumber}
    Run Keyword And Ignore Error    Clear Trace Number Filter    ${tabNumber}
    Run Keyword And Ignore Error    Clear Search    ${tabNumber}

Clear Filter On All Tabs
    [Documentation]    Short description.
    Clear All Filters    0
    Clear All Filters    1
    Clear All Filters    2

Select Last Trace In Table
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${tableName}: <description>
    ...        ${tabNumber}: <description>
    ...        ${filterName}: <description>
    ...        ${traceReference}: <description>
    [Arguments]    ${tableName}    ${tabNumber}    ${filterName}    ${traceReference}
    Search  ${traceReference}  ${tabNumber}
    Filter Traces    ${filterName}    ${tabNumber}    ${traceReference}
    Wait Until Keyword Succeeds    30s    1s
    ...     Trace Should Be Filtered    ${tabNumber}	${tableName}    ${traceReference}
    ${rowCount}=    Get Table Row Count    ${tableName}
    ${rowCount}=    Evaluate    ${rowCount} - 1
    Wait Until Keyword Succeeds    30s    2s    Click On Cell In Table    ${tableName}    ${rowCount}    0

Click On Cell In Table
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${tableId}: <description>
    ...        ${row}: <description>
    ...        ${column}: <description>
    [Arguments]  ${tableId}    ${row}    ${column}
    Click On Table Cell    ${tableId}    ${row}    ${column}
    Table Cell Should Be Selected    ${tableId}    ${row}    ${column}

Trace Should Be Filtered
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${tabNumber}: <description>
    ...        ${tableName}: <description>
    ...        ${traceReference}: <description>
    [Arguments]    ${tabNumber}	 ${tableName}    ${traceReference}
	RemoteSwingLibrary.Select Window    regexp=^TraceViewer.*
	Select Tab		${tabNumber}
    ${rowCount}=    Get Table Row Count    ${tableName}
    Should Be Equal As Integers    1      ${rowCount}
    ${rowValues}=    Get Table Row Values    ${tableName}    0
    #Should Contain    ${rowValues}    ${traceReference}
	Should Be True	'${rowValues}[0]'=='${traceReference}'

Search
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${searchCriteria}: <description>
    ...        ${tabNumber}: <description>
    [Arguments]  ${searchCriteria}  ${tabNumber}
    Log  ${tabNumber}
    Log  ${searchCriteria}
    ${context}=  List Components In Context
    RemoteSwingLibrary.Select Window    regexp=^TraceViewer.*
    Select Tab    ${tabNumber}
    Focus To Component    ${tabNumber}_CRITERIA_TEXT_FIELD
    Click On Component    ${tabNumber}_CRITERIA_TEXT_FIELD
    wait until keyword succeeds  30s  3s  Insert Into Text Field    ${tabNumber}_CRITERIA_TEXT_FIELD  ${searchCriteria}
    ${readValue}=  Get Text Field Value  ${tabNumber}_CRITERIA_TEXT_FIELD
    should be equal  ${readValue}  ${searchCriteria}
    Click On Component     ${tabNumber}_FILTER_BUTTON

Clear Search
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${tabNumber}: <description>
    [Arguments]         ${tabNumber}
    RemoteSwingLibrary.Select Window       regexp=^TraceViewer.*
    Select Tab          ${tabNumber}
    wait until keyword succeeds    60s    3s    Push Button         ${tabNumber}_CLEAR_BUTTON

Filter Traces
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${filterName}: <description>
    ...        ${tabNumber}: <description>
    ...        ${text}: <description>
    [Arguments]    ${filterName}    ${tabNumber}    ${text}
	Log		${filterName}, ${tabNumber}, ${text}
    RemoteSwingLibrary.Select Window    regexp=^TraceViewer.*
    Select Tab    ${tabNumber}
    Focus To Component    ${filterName}_${tabNumber}
    Click On Component    ${filterName}_${tabNumber}
    Run Keyword And Ignore Error    Clear Text Field    ${filterName}_${tabNumber}
    Insert Into Text Field    ${filterName}_${tabNumber}    ${text}
	${readValue}=	Get Text Field Value	${filterName}_${tabNumber}
	Should Be True	'${readValue}'=='"${text}"'

Invoke Force Deletion
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    60s    1s    Select From Main Menu    Trace|Force Deletion
    Wait Until Keyword Succeeds    60s    1s    Select Dialog    regexp=^.*Confirm.*
    Wait Until Keyword Succeeds    60s    1s    Click On Component    Yes

Trace With Given Traced Number Is Not Visible In GUI
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${tracedNumber}: <description>
    [Arguments]    ${tracedNumber}
    Filter Traces    tracedNumber_filter    0    ${tracedNumber}
    Sleep    2s
    ${rowCount}=    Get Table Row Count    MAIN_VIEW_MAIN_TABLE
    Should Be Equal As Integers    0    ${rowCount}

Invoke Restart Trace
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    60s    1s    Select From Main Menu    Trace|Restart
    Wait Until Keyword Succeeds    60s    1s    Select Dialog    regexp=^Restart.*

Invoke Modify Trace
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    60s    1s    Select From Main Menu    Trace|Modify
    Wait Until Keyword Succeeds    90s    1s    Select Dialog    regexp=^Modify.*

Invoke Copy Trace
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    60s    1s    Select From Main Menu    Trace|Copy
    Wait Until Keyword Succeeds    60s    1s    Select Dialog    regexp=^Copy.*

Invoke Refresh Traces
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    30s    1s    RemoteSwingLibrary.Select Window    regexp=^TraceViewer.*
    Wait Until Keyword Succeeds    30s    1s    Click On Component   MAIN_VIEW_REFRESH_TRACE_ICON
