*** Settings ***
Documentation     [PURPOSE] cell trace analysis window keywords
Resource        MainWindowKeywords.robot
Library         DateTime


*** Keywords ***
Open Cell Trace Analysis Window
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${tableName}: <description>
    [Arguments]  ${tableName}
    ${rowCount}=	Get Table Row Count	    ${tableName}
    ${lastRowNumber}=	Evaluate	${rowCount} - 1
    Click On Table Cell	    ${tableName}	${lastRowNumber}	    0	    2
    RemoteSwingLibrary.Select Window	    regexp=^Trace Analysis.*

Open Subscriber Trace Analysis Window With Trace Reference
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${trace_ref}: <description>
	[Arguments]  ${trace_ref}
	Log    ${trace_ref}
	RemoteSwingLibrary.Select Window	    regexp=^TraceViewer.*
	List Components In Context
	Select Tab	0
	Select Tab	0
	${table}=	Get Table Values	MAIN_VIEW_MAIN_TABLE
	Log List	${table}
	#Wait Until Keyword Succeeds    30s    2s
#	... Select Last Trace In Main Table With Given Traced Number    0    ${trace_ref}
	#Wait Until Keyword Succeeds    30s    2s    Open Cell Trace Analysis Window    MAIN_VIEW_MAIN_TABLE
	Wait Until Keyword Succeeds    60s    1s
	...     Select Last Trace In Table    MAIN_VIEW_MAIN_TABLE    0     traceReference_filter    ${traceReference}

Open Trace Analysis Window For Trace With Trace Reference
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${trace_ref}: <description>
    ...        ${trace_type}: <description>
	[Arguments]  ${trace_ref}	${trace_type}=cell trace
	Run Keyword If	'${trace_type}'=='cell trace'
	...	Run Keywords
		...	Wait Until Keyword Succeeds    30s    2s
		...     Select Last Trace In Cell Table With Given Trace Reference    1    ${trace_ref}
		...	AND	Wait Until Keyword Succeeds    30s    2s    Open Cell Trace Analysis Window    MAIN_VIEW_CELL_TABLE
	...	ELSE IF	'${trace_type}'=='subscriber trace'
	...	Run Keywords
		...	Wait Until Keyword Succeeds    30s    2s
		...     Select Last Trace In Table    MAIN_VIEW_MAIN_TABLE    0     traceReference_filter    ${trace_ref}
		...	AND	Wait Until Keyword Succeeds    30s    2s    Open Cell Trace Analysis Window    MAIN_VIEW_MAIN_TABLE

Close Trace Analysis
    [Documentation]    Short description.
	RemoteSwingLibrary.Select Window	    regexp=^Trace Analysis.*
	RemoteSwingLibrary.Close Window	regexp=^Trace Analysis.*

Open Cell Trace Analysis Window For Trace With Trace Reference
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${trace_ref}: <description>
    [Arguments]  ${trace_ref}
    Wait Until Keyword Succeeds    30s    2s
    ...     Select Last Trace In Cell Table With Given Trace Reference    1    ${trace_ref}
    Wait Until Keyword Succeeds    30s    2s    Open Cell Trace Analysis Window    MAIN_VIEW_CELL_TABLE

Select Filters Tab In Cell Trace Analysis Window
    [Documentation]    Short description.
    Wait Until Keyword Succeeds	    30s	    1s	    RemoteSwingLibrary.Select Window	    regexp=^Trace Analysis.*
	wait until keyword succeeds    10s    1s    Push Radio Button    OVERVIEW_RADIO_BUTTON
    Wait Until Keyword Succeeds	    30s	    1s    Select Tab Pane    CELL_TRACE_ACTIONS_TAB_PANE
    Select Tab    Filters

Read Interface L3 Messages
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${trace_ref}: <description>
    ...        ${calls_count}: <description>
    ...        ${close_trace_analysis}: <description>
    ...
    ...    Returns:
    ...        ${msg_list}: <description>
	[Arguments]  ${trace_ref}		${calls_count}=1	${close_trace_analysis}=${TRUE}
	Run Keyword And Ignore Error
	...	Run Keywords
		...	RemoteSwingLibrary.Select Window	    regexp=^Trace Analysis.*
		...	AND	RemoteSwingLibrary.Close Window		regexp=^Trace Analysis.*
    Open Cell Trace Analysis Window For Trace With Trace Reference    ${trace_ref}
	Wait Until Keyword Succeeds	    300s	    20s		Calls Available For Trace Analysis	${calls_count}
	View Lte Interface L3 Messages
	List Components In Context
	Wait Until Keyword Succeeds	    20s	    1s    Interface L3 Messages Table is loaded
	${msg_list}=	Get Table Column Values		Messages	11
	Log List	${msg_list}
	Run Keyword If		${close_trace_analysis}==${TRUE}
	...	Run Keywords
		...	RemoteSwingLibrary.Select Window	    regexp=^Trace Analysis.*
		...	AND	RemoteSwingLibrary.Close Window	    regexp=^Trace Analysis.*
	[Return]	${msg_list}

Interface L3 Messages Table is loaded
    [Documentation]    Short description.
	${count}=	Get Table Row Count		Messages
	Should Be True	${count}>0
	${count_last}=	evaluate	${count}-1
	Click On Table Cell		Messages	${count_last}	0
	Focus To Component    MESSAGES_DECODED_PANE
    ${decoded_msg}    Get Text Field Value    MESSAGES_DECODED_PANE
	Should Not Be Empty		 ${decoded_msg}

Read L3 Messages of Logged MDT from Trace Analysis
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${trace_reference}: <description>
    ...        ${expected_calls_count}: <description>
    ...        ${close_trace_analysis}: <description>
    ...
    ...    Returns:
    ...        ${msg_list}: <description>
	[Arguments]  ${trace_reference}		${expected_calls_count}=1	${close_trace_analysis}=${TRUE}
	Run Keyword And Ignore Error
	...	Run Keywords
		...	RemoteSwingLibrary.Select Window	    regexp=^Trace Analysis.*
		...	AND	RemoteSwingLibrary.Close Window		regexp=^Trace Analysis.*
    Open Cell Trace Analysis Window For Trace With Trace Reference    ${trace_reference}
	Wait Until Keyword Succeeds	    360s	    10s
	...     Logged MDT Is Available In Trace Analysis	${expected_calls_count}
	${msg_list}=	Read all L3 Messages of Logged MDT
	Run Keyword If		${close_trace_analysis}==${TRUE}
	...	Run Keywords
		...	RemoteSwingLibrary.Select Window	    regexp=^Trace Analysis.*
		...	AND	RemoteSwingLibrary.Close Window	regexp=^Trace Analysis.*
	[Return]	${msg_list}

Logged MDT Is Available In Trace Analysis
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${expected_calls_count}: <description>
	[Arguments] 	${expected_calls_count}=1
	RemoteSwingLibrary.Select Window	    regexp=^Trace Analysis.*
	Select Tab		Analysis
	Push Button		Refresh
	Select Filters Tab In Cell Trace Analysis Window
	${current_date}=	Get Current Date
    ${end_day}=     Add Time To Date    ${current_date}     02:00:00.000    result_format=%Y-%m-%d
    ${end_time}=     Add Time To Date    ${current_date}     02:00:00.000    result_format=%H:%M
    Show Calls In Cell Trace Analysis Window    2023-01-1    01:01    ${end_day}    ${end_time}
	View Lte Logged Mdt L3 Messages Table In Cell Trace Analysis Window
	Sleep	5s
	${rows_count}=		Get Table Row Count		Messages
	Should Be True	${rows_count}>=${expected_calls_count}

Read all L3 Messages of Logged MDT
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${msg_list}: <description>
	${msg_list}		create list
	${rows_count}=		Get Table Row Count		Messages
	Should Be True	${rows_count}>0
	FOR    ${index}    IN RANGE    0	${rows_count}
		${msg}=	Set Variable	${EMPTY}
		Log		${index}
		${msg}		Check L3 Message	${index}
		Should Not Be Empty		${msg}
		Append to List		${msg_list}		${msg}
		Log		${msg}
	END
	Log		${msg_list}
	[Return]	${msg_list}

Check L3 Message
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${row}: <description>
    ...
    ...    Returns:
    ...        ${decoded_msg}: <description>
    [Arguments]  ${row}
    Click On Table Cell    Messages    ${row}    0    1
	Sleep	2s
    Focus To Component    MESSAGES_DECODED_PANE
    ${decoded_msg}    Get Text Field Value    MESSAGES_DECODED_PANE
	Log		${decoded_msg}
	[Return]	${decoded_msg}

Select Analysis Tab In Cell Trace Analysis Window
    [Documentation]    Short description.
    Wait Until Keyword Succeeds	    10s	    1s	    RemoteSwingLibrary.Select Window	    regexp=^Trace Analysis.*
    Wait Until Keyword Succeeds	    10s	    1s    Select Tab Pane    CELL_TRACE_ACTIONS_TAB_PANE
    Select Tab    Analysis

Timestamp Check
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ts1}: <description>
    ...        ${ts2}: <description>
    ...        ${interval}: <description>
    ...        ${allowance}: <description>
	[Arguments]	${ts1}	${ts2}	${interval}	${allowance}=200
	${time}=	Subtract Date From Date		${ts1}	${ts2}	exclude_millis=${FALSE}
	${value}=	evaluate	abs(${interval}-1000*${time})
	Should Be True	${value}<=${allowance}

Report Interval Check From Message List
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${mesage_list}: <description>
    ...        ${interval}: <description>
    ...        ${allowance}: <description>
	[Arguments]		${mesage_list}	${interval}=4096	${allowance}=0
	${len}=	Get Length	${mesage_list}
	${len}=	evaluate	${len}-1
	FOR	${index}	IN RANGE	1	${len}
		${previous}=	evaluate	${index}-1
		Timestamp Check		${mesage_list[${index}]['Time']}
		...     ${mesage_list[${previous}]['Time']}		${interval}		${allowance}
	END

Check Non-GBR Bearers
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${call}: <description>
    ...        ${UE_Throughput}: <description>
	[Arguments]		${call}		${UE_Throughput}=${TRUE}
	RemoteSwingLibrary.Select Window	regexp=^Trace Analysis.*
	Select Tab    Reports
	Wait Until Keyword Succeeds    10s    3s    Click On Tree Node    TREE_FOR_REPORTS
	...     LTE Tree|Recording Session|Throughput Measurements|Number of bytes received for non-GBR bearers
	Wait Until Keyword Succeeds		60s		5s		Table Is Loaded		COUNTER_TABLE
	${dl_msgs}=	Fetch Messages From Call	${call}		MAC DL UE Throughput Measurements
	Log List	${dl_msgs}
	#Report Interval Check From Message List		${dl_msgs}	4096	0
	${ul_msgs}=	Fetch Messages From Call	${call}		MAC UL UE Throughput Measurements
	Log List	${ul_msgs}
	${dl_len}=		Get Length	${dl_msgs}
	${ul_len}=		Get Length	${ul_msgs}
#	Should Be True	${dl_len}==${ul_len}
	${len}=		Set Variable	${dl_len}
	Run Keyword If	${UE_Throughput}==${FALSE}
		...	Should Be True	${dl_len}==0 and ${ul_len}==0
	${timestamp}=	Get Table Cell Value	COUNTER_TABLE	0	1
	FOR		${index}	IN RANGE	0	${len}
	    Exit For Loop If    ${ul_len}-${index}==1 or ${dl_len}-${index}==1

		${is_last}=	Run Keyword And Return Status	Should Be True	${len}-${index}==1
		${matchs}=	Get Regexp Matches	${ul_msgs[${index}]['L3 Messages Details']}
		...     utUlsReceivedNonGbrBytes:[\ ]([\\d]+),	1
		${ul_bytes}=	Set Variable	${matchs[0]}
		${matchs}=	Get Regexp Matches	${dl_msgs[${index}]['L3 Messages Details']}
		...     utDlsSentNonGbrBytes:[\ RIP Statistics Check]([\\d]+),	1
		${dl_bytes}=	Set Variable	${matchs[0]}
#		Continue For Loop If    ${dl_len}!=${ul_len}
#		${timestamp}=	Non-GBR Counter Table Check		${timestamp}	${ul_bytes}		${dl_bytes}
#		${timestamp}=	Non-GBR Counter Table Check		${timestamp}	${ul_bytes}		${dl_bytes}		${is_last}
	END

Non-GBR Counter Table Check
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${timestamp}: <description>
    ...        ${ul_bytes}: <description>
    ...        ${dl_bytes}: <description>
    ...        ${is_last}: <description>
    ...
    ...    Returns:
    ...        ${new_timestamp}: <description>
	[Arguments]		${timestamp}	${ul_bytes}		${dl_bytes}		${is_last}=${FALSE}
	${table}=	Get Table Values	COUNTER_TABLE
	${is_ul}=	Run Keyword And Return Status	Should Contain	${table[1][0]}	received
	${is_dl}=	Run Keyword And Return Status	Should Contain	${table[1][0]}	sent
	Run keyword If	${is_dl}==${TRUE}
	...	Should Be True	'${dl_bytes}'=='${table[1][1]}'
	...	ELSE IF	${is_ul}==${TRUE}
	...	Should Be True	'${ul_bytes}'=='${table[1][1]}'
	Push Button		VIEW_TRACE_NAVIGATION_NEXT
	Return From Keyword If	${is_last}==${TRUE}
	${new_timestamp}=	Wait Until Keyword Succeeds		10s	0.5s	Next Counter Is Available	${timestamp}
	[RETURN]	${new_timestamp}

Next Counter Is Available
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${timestamp}: <description>
    ...
    ...    Returns:
    ...        ${new_timestamp}: <description>
	[Arguments]		${timestamp}
	${new_timestamp}=	Get Table Cell Value	COUNTER_TABLE	0	1
	Should Not Be True	'${timestamp}'=='${new_timestamp}'
	[RETURN]	${new_timestamp}

Check Report Interval And Report Amount From RRCConnectionReconfiguration Message
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${message}: <description>
    ...        ${expected_ReportInterval}: <description>
    ...        ${expected_reportAmount}: <description>
    ...        ${expected_GNSS_positioning}: <description>
	[Arguments]		${message}	${expected_ReportInterval}
	...     ${expected_reportAmount}	${expected_GNSS_positioning}=${FALSE}
	Log		${message}
	${message}=		Replace String		${message}	\n\n	${EMPTY}
	Log		${message}
	${message}=		Replace String Using Regexp		${message}
	...     (dedicatedInfoNASList: {\n[\ ]+element\: \\[[\ ]\n)(((.+)\n)+)[\\]]  dedicatedInfoNASList: {\nelement\:
	Log		${message}
	${message}=		Replace String Using Regexp		${message}	([^:^\\s^{^}^,^\\[^\\]][<=\.\ \\w\-]*)	\"\\1\"
	Log		${message}
	${message}=		Replace String Using Regexp		${message}	([:])([ ]*)([\n][ ]+[}])	\\1\\2\"\"\\3
	Log		${message}
	${obj}=     Evaluate     json.loads("""${message}""")    json
#	${value}=       Set Variable    ${obj}[DL-DCCH-Message][message][c1][rrcConnectionReconfiguration]
#	[criticalExtensions][c1][rrcConnectionReconfiguration-r8][measConfig][reportConfigToAddModList][element]
	${ce}=      Set Variable    ${obj}[DL-DCCH-Message][message][c1][rrcConnectionReconfiguration][criticalExtensions]
	${config}=       Set Variable    ${ce}[c1][rrcConnectionReconfiguration-r8][measConfig]
	${value}=       Set Variable    ${config}[reportConfigToAddModList][element]

	Log		${value}
#	FOR		${rc}		IN	@{value[0]}
    FOR		${rc}		IN	@{value}
		Log		${rc}
		Log		${rc['reportConfig']['reportConfigEUTRA']}
		${status}=	Run Keyword And Return Status 	Dictionary Should Contain Key
		...     ${rc['reportConfig']['reportConfigEUTRA']['triggerType']['periodical']['purpose']}
		...     reportStrongestCells
		Continue For Loop If	${status}==${FALSE}
		${keys}=	Get Dictionary Keys		${rc['reportConfig']['reportConfigEUTRA']['reportInterval']}
		Remove Values From List	${keys}		number
		${reportInterval}=	Replace String	${keys[0]}	ms	${EMPTY}
		Set Variable	${reportInterval}
		${keys}=	Get Dictionary Keys		${rc['reportConfig']['reportConfigEUTRA']['reportAmount']}
		Remove Values From List	${keys}		number
		${reportAmount}=	Replace String	${keys[0]}	r	${EMPTY}
		Set Variable	${reportAmount}
		${GNSS_positioning}=	Run Keyword If	${expected_GNSS_positioning}==${TRUE}
								...	    Read GNSS Positioning From Dictionary
								...     ${rc['reportConfig']['reportConfigEUTRA']['G3']['includeLocationInfo-r10']}
	END
	Should Be True	'${expected_ReportInterval}'=='${reportInterval}'
	Should Be True	'${expected_reportAmount}'=='${reportAmount}'
	Run Keyword If	${expected_GNSS_positioning}==${TRUE}
	...	Should Be True	'${GNSS_positioning}'=='true'

Read GNSS Positioning From Dictionary
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${dic}: <description>
    ...
    ...    Returns:
    ...        ${keys[0]}: <description>
	[Arguments]  ${dic}
	${keys}=	Get Dictionary Keys	${dic}
	Remove Values From List	${keys}		number
	[RETURN]	${keys[0]}

Read RIP Table
    [Documentation]    Short description.
	Wait Until Keyword Succeeds		10s		1s		RemoteSwingLibrary.Select Window	regexp=^Trace Analysis.*
	Select Tab		Reports
	Wait Until Keyword Succeeds    10s    3s    Click On Tree Node    TREE_FOR_REPORTS    LTE Tree|Interface|RIP
	List Components In Context
	Wait Until Keyword Succeeds		20s		1s	Get RIP Table Rows Count
	Click On Table Cell		0	0	0
	Sleep	2s
	List Components In Context
	${headers}=		Get Table Headers	0
	Log List	${headers}
	${rip_table}=	Get Table Values	0
	Log List	${rip_table}
	${interval}=	Convert Time	${TraceConfiguration['CellTrace']['CellTraceMDT']['RIP_report_interval']}
	RIP Report Interval Check	${rip_table}	${interval}

RIP Report Interval Check
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${rip_table}: <description>
    ...        ${interval}: <description>
	[Arguments]  ${rip_table}	${interval}
	${rows}=	Get Table Row Count		0
	FOR		${index}	IN RANGE	1	${rows}
		${index_pre}=	evaluate	${index}-1
		${time}=	Subtract Date From Date	${rip_table}[${index}][1]
		...     ${rip_table}[${index_pre}][1]	exclude_millis=${TRUE}
		Should Be True	${time}==${interval}
		Exit For Loop If	${index}>20
	END

Get RIP Table Rows Count
    [Documentation]    Short description.
	${rows}=		Get Table Row Count	0
	Should Be True	${rows}>0

Calls Available For Trace Analysis
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${calls_count}: <description>
	[Arguments]  ${calls_count}=1
	Wait Until Keyword Succeeds		10s		1s		RemoteSwingLibrary.Select Window	regexp=^Trace Analysis.*
	Run Keyword And Ignore Error	Reset Analysis
	Select Tab		Analysis
	Push Button		Refresh
	Push Button		ANALYZE_BUTTON
	wait until keyword succeeds		60s		2s		Component Should Be Visible		RESET_BUTTON
    Select Filters Tab In Cell Trace Analysis Window
    ${current_date}=	Get Current Date
    ${end_day}=     Add Time To Date    ${current_date}     02:00:00.000    result_format=%Y-%m-%d
    ${end_time}=     Add Time To Date    ${current_date}     02:00:00.000    result_format=%H:%M
    Show Calls In Cell Trace Analysis Window    2023-01-1    01:01    ${end_day}    ${end_time}
	Wait Until Keyword Succeeds	    10s	    1s	    RemoteSwingLibrary.Select Window	    regexp=^Trace Analysis.*
	View Lte Calls Table In Cell Trace Analysis Window
	List Components In Context
	${rows}=	Get Table Row Count		LTE_CALL_TABLE
	${status}=	Run Keyword And Return Status	Should Be True	${rows}>=${calls_count}
	Return From Keyword If	${status}==${TRUE}
	Reset Analysis
	Should Be True	${rows}>=${calls_count}

Reset Analysis
    [Documentation]    Short description.
	Wait Until Keyword Succeeds		10s		1s		RemoteSwingLibrary.Select Window	regexp=^Trace Analysis.*
	wait until keyword succeeds    10s    1s    Push Radio Button    OVERVIEW_RADIO_BUTTON
	Select Tab		Analysis
	Push Button		RESET_BUTTON
	wait until keyword succeeds		10s		1s		Select Dialog	regexp=^Confirm Res.*
	Push Button		Yes
	Wait Until Keyword Succeeds	    10s	    1s	    RemoteSwingLibrary.Select Window	regexp=^Trace Analysis.*
	Sleep	5s

Fetch Messages From Call
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${call}: <description>
    ...        ${message_name}: <description>
    ...
    ...    Returns:
    ...        ${message_list}: <description>
	[Arguments]     ${call}		${message_name}
	#${message_name_1}=  Set Variable    ${message_name} (UL-DCCH)
	#${message_name_2}=  Set Variable    ${message_name} (UL-CCCH-Message)
	@{message_list}=	Create List
	FOR		${message}		IN	@{call}
		Log Dictionary	${message}
		${match}=   Run Keyword And Return Status   Should Match Regexp
		...     ${message['L3 message']}      ${message_name}( ([\\w-]+))*
		Run Keyword If	${match}==${TRUE}
		...	Append To List		${message_list}		${message}
	END
	[RETURN]	${message_list}

Read All Calls of Trace
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${trace_reference}: <description>
    ...        ${close_trace_analysis}: <description>
    ...        ${calls_count}: <description>
    ...        ${trace_type}: <description>
    ...
    ...    Returns:
    ...        ${call_list_dictionary}: <description>
	[Arguments]     ${trace_reference}		${close_trace_analysis}=${TRUE}
	...     ${calls_count}=1	${trace_type}=cell trace
	Log		${trace_reference}
	@{call_list}=	Create List
	@{call_list_dictionary}=	Create List
	Set Test Variable	${call_list}
	Set Test Variable	${call_list_dictionary}
	#Open Cell Trace Analysis Window For Trace With Trace Reference    ${trace_reference}	${trace_type}
	Open Trace Analysis Window For Trace With Trace Reference	${trace_reference}	${trace_type}
	Wait Until Keyword Succeeds	    300s	    20s		Calls Available For Trace Analysis	${calls_count}
	RemoteSwingLibrary.Select Window	    regexp=^Trace Analysis.*
	${rows}=	Get Table Row Count		LTE_CALL_TABLE
	FOR		${row}	IN RANGE	0	${rows}
		Click On Table Cell		LTE_CALL_TABLE	${row}	0
		${call}	${call_dictionary}=	Read All Messages of Call
		Append to List	${call_list}			${call}
		Append to List	${call_list_dictionary}	${call_dictionary}
	END
	Run Keyword If		${close_trace_analysis}==${TRUE}
	...	Run Keywords
		...	RemoteSwingLibrary.Select Window	    regexp=^Trace Analysis.*
		...	AND	RemoteSwingLibrary.Close Window	regexp=^Trace Analysis.*
	[RETURN]	${call_list_dictionary}

Message Check Of Cell Trace
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${call_list}: <description>
    ...        ${expected_messages}: <description>
	[Arguments]     ${call_list}	${expected_messages}
	Log List		${expected_messages}
	Log List		${call_list}
	FOR	${expected_message}		IN	@{expected_messages}
		${result}=	Is Message In The Call List		${call_list}	${expected_message}
		Should Be True	${result}
	END

Is Message In The Call List
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${call_list}: <description>
    ...        ${expected_message}: <description>
    ...
    ...    Returns:
    ...        ${result}: <description>
	[Arguments]     ${call_list}		${expected_message}
	${result}=	Set Variable	${FALSE}
	FOR		${call}		IN	@{call_list}
		${len}=		Get Length		${call}
		Continue For Loop If	${len}<=0
		${result}=		Is Message Match	${call}		${expected_message}
		Exit For Loop If	${result}==${TRUE}
	END
	[RETURN]	${result}

Is Message Match
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${call}: <description>
    ...        ${expected_message}: <description>
    ...
    ...    Returns:
    ...        ${result}: <description>
	[Arguments]     ${call}		${expected_message}
	Log List	${call}
	FOR		${message}	IN	@{call}
		#${result}=	Run Keyword And Return Status	Should Contain	${message['L3_message']}		${expected_message}
		${result}=	Run Keyword And Return Status	Should Contain	${message['L3 message']}		${expected_message}
		Exit For Loop If	${result}==${TRUE}
	END
	[RETURN]	${result}

Analyze Measurement And SINR
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${call_list_dictionary}: <description>
	[Arguments]		${call_list_dictionary}
	${row_index}=	Set Variable	0
	FOR		${call}		IN	@{call_list_dictionary}
		Wait Until Keyword Succeeds		10s		1s		RemoteSwingLibrary.Select Window	regexp=^Trace Analysis.*
		Click On Table Cell		LTE_CALL_TABLE	${row_index}	0
		${row_index}=	evaluate	${row_index}+1
		List Components In Context
		${MR_message_list}=		Fetch Messages From Call	${call}		MeasurementReport (UL-DCCH-Message)
		${len}=		Get Length		${MR_message_list}
		Continue For Loop If	${len}==0
		Log List	${MR_message_list}
		Measurement Check	${MR_message_list}
		${SINR_message_list}=	Fetch Messages From Call	${call}		MAC Signal to Interference-plus-Noise Ratio
		Log List	${SINR_message_list}
		${len}=		Get Length		${SINR_message_list}
		Should Be True	${len}>0
		SINR Check	${SINR_message_list}
	END

Measurement Check
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${MR_message_list}: <description>
    ...        ${index}: <description>
	[Arguments]		${MR_message_list}	${index}=0
	Wait Until Keyword Succeeds		10s		1s		RemoteSwingLibrary.Select Window	regexp=^Trace Analysis.*
	Wait Until Keyword Succeeds    10s    3s
	...     Click On Tree Node    TREE_FOR_REPORTS    LTE Tree|Recording Session|Measurement
	Select Tab		Reports
	Wait Until Keyword Succeeds		10s		1s		RemoteSwingLibrary.Select Window	regexp=^Trace Analysis.*
	Click On Table Cell		LTE_CALL_TABLE	${index}	0
	Wait Until Keyword Succeeds		15s		5s		Table Is Loaded		2
	FOR		${MR_message}	IN	@{MR_message_list}
		${counter_table_1}=	Get Table Values	1
		Should Contain		${counter_table_1}[0][1]	${MR_message['Time']}
		${headers}=		Get Table Headers	2
		${counter_table_2}=	Get Table Values	2
		Log List	${headers}
		Log List	${counter_table_2}
		Should Be True		${counter_table_2}[0][0]==${lnbts_id}
		${rsrp}=	Replace String	${MR_message['L3 Messages Details']}		Result	${EMPTY}
		${rsrp}=	Replace String	${rsrp}		.0		${EMPTY}
		${rsrp}=	Replace String	${rsrp}		dBm${SPACE}		${EMPTY}
		Should Contain		${rsrp}		${counter_table_2}[0][5]		ignore_case=${TRUE}
		${rsrq}=	Replace String		${MR_message['L3 Messages Details']}		Result	${EMPTY}
		${rsrq}=	Replace String		${rsrq}		dB${SPACE}	${EMPTY}
		${rsrq}=	Replace String		${rsrq}		.0		${EMPTY}
		Should Contain		${rsrq}		${counter_table_2}[0][6]		ignore_case=${TRUE}
		Wait Until Keyword Succeeds		10s		1s		RemoteSwingLibrary.Select Window	regexp=^Trace Analysis.*
		Push Button		VIEW_TRACE_NAVIGATION_NEXT
		Sleep	2s
	END
	${interval}=	Fetch From Left    ${TraceConfiguration['CellTrace']['CellTraceMDT']['Report_interval']}	${SPACE}
	Measurement Report Interval Check	${MR_message_list}	${interval}

Measurement Report Interval Check
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${MR_message_list}: <description>
    ...        ${interval}: <description>
	[Arguments]  ${MR_message_list}		${interval}
	${len}=	Get Length		${MR_message_list}
	FOR		${index}	IN RANGE	1	${len}
		${index_pre}=	evaluate	${index}-1
		${time}=	Subtract Date From Date	${MR_message_list}[${index}][Time]
		...     ${MR_message_list}[${index_pre}][Time]	exclude_millis=${FALSE}
		#Should Be True	${time}==${interval}
		${abs}=		Evaluate	abs(1000*${time}-${interval})
		Should Be True		${abs}<=500
		Exit For Loop If	${index}>100
	END

Table Is Loaded
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${table_id}: <description>
	[Arguments]		${table_id}
	Set Jemmy Timeouts	15
	Push Button		VIEW_TRACE_NAVIGATION_FIRST
	Sleep	2s
	RemoteSwingLibrary.Select Window	regexp=^Trace Analysis.*
	${rows}=	Get Table Row Count		${table_id}
	Should Be True	${rows}>0
	Set Jemmy Timeouts	5

RIP Statistics Check
    [Documentation]    Short description.
	Wait Until Keyword Succeeds		10s		1s		RemoteSwingLibrary.Select Window	regexp=^Trace Analysis.*
	Wait Until Keyword Succeeds    10s    3s    Click On Tree Node    TREE_FOR_REPORTS    LTE Tree|Statistics|RIP
	sleep	5s
	List Components In Context
	${bw}=	Fetch From Left		${chbw}		${SPACE}
	${prb_count}=	evaluate	100*${bw}/20
	${rows}=	Get Table Row Count		0
	Run Keyword If	'${TraceConfiguration['CellTrace']['CellTraceMDT']['RIP_type']}'=='Subframe and slot'
		...	Should Be True	${rows}==1
	...	ELSE IF	'${TraceConfiguration['CellTrace']['CellTraceMDT']['RIP_type']}'=='RB subframe and slot'
	...	Should Be True	${rows}==${prb_count}
	${counter_table}=	Get Table Values	0
	Log		${counter_table}
	Close Trace Analysis

SINR Check
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${SINR_message_list}: <description>
	[Arguments]		${SINR_message_list}
	Wait Until Keyword Succeeds		10s		1s		RemoteSwingLibrary.Select Window	regexp=^Trace Analysis.*
	Wait Until Keyword Succeeds    10s    3s
	...     Click On Tree Node    TREE_FOR_REPORTS    LTE Tree|Recording Session|SINR
	Wait Until Keyword Succeeds		10s		1s		RemoteSwingLibrary.Select Window	regexp=^Trace Analysis.*
	#Push Button		VIEW_TRACE_NAVIGATION_FIRST
	Wait Until Keyword Succeeds		10s		1s		Table Is Loaded	1
	FOR		${SINR_message}	IN	@{SINR_message_list}
		${headers}=		Get Table Headers	1
		${counter_table}=	Get Table Values	1
		Log List	${headers}
		Log List	${counter_table}
		Should Contain	${counter_table}[0][1]	${SINR_message['Time']}
		Should Contain	${SINR_message['L3 Messages Details']}	${counter_table}[1][1]
		Push Button		VIEW_TRACE_NAVIGATION_NEXT
		Sleep	2s
	END

Read Matched Message In A Call
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${call}: <description>
    ...        ${expected_message}: <description>
    ...
    ...    Returns:
    ...        ${message_list}: <description>
	[Arguments]     ${call}		${expected_message}
	Log List	${call}
	Log 	${expected_message}
	Create List		${message_list}
	FOR		${message}	IN	@{call}
		${result}=	Run Keyword And Return Status	Should Contain	${message['L3 message']}		${expected_message}
		Append To List		${message_list}		${message}
	END
	[RETURN]	${message_list}

Read All Messages of Call
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${message_list_of_celltrace}: <description>
    ...        ${message_list_of_celltrace_dictionary}: <description>
	#[Arguments]     ${row}
	@{message_list_of_celltrace}=	Create List
	@{message_list_of_celltrace_dictionary}=		Create Dictionary
	Set Test Variable	${message_list_of_celltrace}
	Set Test Variable	${message_list_of_celltrace_dictionary}
	Focus To Component		Messages
	${headers}=	Get Table Headers	Messages
	${header_counts}=	Get length	${headers}
	FOR		${index}	IN RANGE	0	${header_counts}
		#${headers_new}=	Replace String	${headers}[${index}]	${SPACE}	_
		#Set List Value		${headers}	${index}	${headers_new}
		Set List Value		${headers}	${index}	${headers}[${index}]
	END
	Log		${headers}
	Sleep	5s
	#Wait Until Keyword Succeeds		10s		1s	Show Call Messages
	${rows}=	Get Table Row Count		Messages
	FOR		${row}	IN RANGE	0	${rows}
		Click On Table Cell		Messages	${row}	0
		${msg}	${msg_dictionary}=		Read Message	${row}	${headers}
		Append to List	${message_list_of_celltrace}		${msg}
		Append to List	${message_list_of_celltrace_dictionary}		${msg_dictionary}
	END
	Log List		${message_list_of_celltrace}
	#Log	Dictionary	${message_list_of_celltrace_dictionary}
	[RETURN]	${message_list_of_celltrace}	${message_list_of_celltrace_dictionary}

Show Call Messages
    [Documentation]    Short description.
	RemoteSwingLibrary.Select Window	    regexp=^Trace Analysis.*
	${rows}=	Get Table Row Count		Messages
	Should Be True	${rows}>0

Read Message
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${row}: <description>
    ...        ${headers}: <description>
    ...
    ...    Returns:
    ...        ${msg}: <description>
    ...        ${msg_dictionary}: <description>
	[Arguments]     ${row}	${headers}
	${msg}=		Create List
	${msg_dictionary}=	Create Dictionary
	${columns}=	Get Table Column Count	Messages

	${msg}=	Get Table Row Values	Messages	${row}
	FOR		${column}	IN RANGE	0	${columns}
		${key}=		Get From List	${headers}	${column}
		${value}=	Get Table Cell Value	Messages	${row}	${column}
		Set to Dictionary	${msg_dictionary}	${key}	${value}
	END
	${detail}=	Get Text Field Value	MESSAGES_DECODED_PANE
	Set to Dictionary	${msg_dictionary}	L3 Messages Details		${detail}
	Append to List		${msg}		${detail}
	#Log	List		${msg}
	#Log	Dictionary	${msg_dictionary}
	[RETURN]	${msg}	${msg_dictionary}

Show Calls In Cell Trace Analysis Window
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${start_date}: <description>
    ...        ${start_time}: <description>
    ...        ${stop_date}: <description>
    ...        ${stop_time}: <description>
    [Arguments]     ${start_date}    ${start_time}    ${stop_date}    ${stop_time}
    Wait Until Keyword Succeeds	    10s	    1s	    RemoteSwingLibrary.Select Window	    regexp=^Trace Analysis.*
    Wait Until Keyword Succeeds	    10s	    1s	    Focus To Component    START_DATE
    Wait Until Keyword Succeeds	    10s	    1s	    Type Into Combobox	START_DATE	${start_date}
    Wait Until Keyword Succeeds	    10s	    1s	    Focus To Component    START_TIME
    Wait Until Keyword Succeeds	    10s	    1s	    Type Into Combobox	START_TIME	${start_time}
    Wait Until Keyword Succeeds	    10s	    1s	    Focus To Component    STOP_DATE
    Wait Until Keyword Succeeds	    10s	    1s	    Type Into Combobox	STOP_DATE	${stop_date}
    Wait Until Keyword Succeeds	    10s	    1s	    Focus To Component    STOP_TIME
    Wait Until Keyword Succeeds	    10s	    1s	    Type Into Combobox	STOP_TIME	${stop_time}
	Select Tab    Filters
    Wait Until Keyword Succeeds	    10s	    1s	    Click On Component	LOAD_BUTTON

View Lte Calls Table In Cell Trace Analysis Window
    [Documentation]    Short description.
    List Components In Context
    Run Keyword And Ignore Error    Select Tab    Reports
    Wait Until Keyword Succeeds    10s    3s
    ...     Click On Tree Node    TREE_FOR_REPORTS    LTE Tree|Recording Session|L3 Messages

View Lte Logged Mdt L3 Messages Table In Cell Trace Analysis Window
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    10s    3s
    ...     Click On Tree Node    TREE_FOR_REPORTS    LTE Tree|Logged MDT|L3 Messages

View Lte Interface L3 Messages
    [Documentation]    Short description.
	Wait Until Keyword Succeeds    10s    3s
	...    Click On Tree Node    TREE_FOR_REPORTS    LTE Tree|Interface|L3 Messages

Get All Rows From Table
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${table_id}: <description>
    ...
    ...    Returns:
    ...        ${table_values}: <description>
    [Arguments]  ${table_id}
    ${table_values}=    Get Table Values    ${table_id}
    should not be empty    ${table_values}
    [Return]  ${table_values}

Check Lte Messages Colour In Cell Trace Analysis Window
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${failing_message}: <description>
    ...        ${pass_message}: <description>
    [Arguments]    ${failing_message}    ${pass_message}
    ${columnCount}=	  Get Table Column Count    Messages
    Check If Color Is Red For Failed Call Or Message    Messages    ${failing_message}    ${columnCount}
    Check If Color Is Neutral For Call Or Message That Do Not Fail    Messages    ${pass_message}    ${columnCount}

Check Calls Color From Cell Trace Analysis Window
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${calls}: <description>
    [Arguments]  ${calls}
    ${failed_calls_row_number}    ${success_calls_row_number}=
    ...     get_calls_row_numbers_for_failed_and_nonfailed_rows    ${calls}
    ${columnCount}=	  Get Table Column Count	LTE_CALL_TABLE
    FOR    ${failed_call_row_no}    IN    @{failed_calls_row_number}
        ${failed_call_row_no}=    Convert To Integer    ${failed_call_row_no}
        ${failed_call_row_no}=    Evaluate    ${failed_call_row_no}-1
        Check If Color Is Red For Failed Call Or Message    LTE_CALL_TABLE    ${failed_call_row_no}    ${columnCount}
    END
    FOR    ${success_call_row_number}    IN    @{success_calls_row_number}
        ${success_call_row_number}=    Convert To Integer    ${success_call_row_number}
        ${success_call_row_number}=    Evaluate    ${success_call_row_number}-1
        Check If Color Is Neutral For Call Or Message That Do Not Fail
        ...     LTE_CALL_TABLE    ${success_call_row_number}    ${columnCount}
    END

Check If Color Is Red For Failed Call Or Message
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${table_name}: <description>
    ...        ${call_row_number}: <description>
    ...        ${columnCount}: <description>
    [Arguments]  ${table_name}    ${call_row_number}    ${columnCount}
    FOR    ${column}    IN RANGE    1    ${columnCount}
        ${foreground}=    Get Table Cell Property  ${table_name}    ${call_row_number}     ${column}   foreground
        Log    ${foreground}
        Should Contain    ${foreground}    [r=190,g=0,b=6]
    END

Check If Color Is Neutral For Call Or Message That Do Not Fail
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${table_name}: <description>
    ...        ${call_row_number}: <description>
    ...        ${columnCount}: <description>
    [Arguments]  ${table_name}    ${call_row_number}    ${columnCount}
    FOR    ${column}    IN RANGE    1    ${columnCount}
        ${foreground}=    Get Table Cell Property  ${table_name}    ${call_row_number}     ${column}    foreground
        Log    ${foreground}
        Should Not Contain    ${foreground}    [r=190,g=0,b=6]
    END
