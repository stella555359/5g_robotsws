*** Settings ***
Documentation     [PURPOSE] activation cell trace gui keywords
Library           OperatingSystem
Library           BuiltIn
#Library           RemoteSwingLibrary
Library           String
Resource          ActivationWindowKeywords.robot
Resource          ../CommonKeywords.robot


*** Keywords ***
Open New Cell Trace Window
    [Documentation]    Short description.
	Re-authenticate
    wait until keyword succeeds    60s    2s    RemoteSwingLibrary.Select Window    regexp=^TraceViewer.*
    wait until keyword succeeds    60s    2s    Select From Main Menu    Trace|New|Cell Trace
    wait until keyword succeeds    60s    2s    Select Dialog    regexp=^Cell Trace Type.*
    wait until keyword succeeds    60s    2s    Push Button    	CELL_TRACING_BUTTON
    wait until keyword succeeds    60s    2s    Select Dialog    regexp=^New.*

Open Logged MDT Window
    [Documentation]    Short description.
	Re-authenticate
    wait until keyword succeeds    60s    2s    RemoteSwingLibrary.Select Window    regexp=^TraceViewer.*
    wait until keyword succeeds    60s    2s    Select From Main Menu    Trace|New|Cell Trace
    wait until keyword succeeds    60s    2s    Select Dialog    regexp=^Cell Trace Type.*
    wait until keyword succeeds    60s    2s    Push Button		 LTE BTS Logged MDT
    wait until keyword succeeds    60s    2s    Select Dialog    regexp=^New.*
	List Components In Context

Re-authenticate
    [Documentation]    Short description.
#    Return From Keyword
	Log		In case of re-authenticate is required
	${status}=	Run Keyword And Return Status	Re-authenticate Dialog is Disappered
	Return From Keyword If	${status}==${TRUE}
	Log To Console	Re-authenticate is required
	wait until keyword succeeds    5s    1s    Select Dialog    regexp=^NetAct.*
	${status}=	Run Keyword And Return Status	Push Button	Re-authenticate...
	wait until keyword succeeds    5s    1s    Select Dialog    regexp=^NetAct.*
	List Components In Context
	#Type Into Text Field	PASS_FIELD	${NETACT['password']}
	Type Into Text Field	PASS_FIELD	${netact}[SDV_DESKTOP_ADMIN_PASSWORD]
	wait until keyword succeeds    20s    2s	Push Button		OK
	wait until keyword succeeds    30s    2s	Re-authenticate Dialog is Disappered

Re-authenticate Dialog is Disappered
    [Documentation]    Short description.
	${status}=	Run Keyword And Return Status	Select Dialog    regexp=^NetAct.*
	Should be True		${status}== ${FALSE}

Disable Discard External Trace
    [Documentation]    Short description.
	wait until keyword succeeds    15s    2s    Select From Main Menu    Options|Settings
	wait until keyword succeeds    15s    2s    Select Dialog    regexp=^Settings*
	Select Tab	General
	Wait Until Keyword Succeeds    10s    0.5s   Switch To Discard
	${status}=	Run Keyword And Return Status	Toggle Button Should Not Be Selected	3
	Run Keyword If	${status}==${FALSE}
	...	Run Keywords
		...	Push Toggle Button		3
		...	AND	Toggle Button Should Not Be Selected	3
	Push Button		OK
	wait until keyword succeeds    60s    2s    RemoteSwingLibrary.Select Window    regexp=^TraceViewer.*

Switch To Discard
    [Documentation]    Short description.
	Send Keyboard Event		VK_DOWN	CTRL_MASK
	Sleep	0.5s
	${components}=	List Components In Context
	Should Contain	${components}	ToggleOption

Disable Discard Unkown Subscriber Trace
    [Documentation]    Short description.
	wait until keyword succeeds    60s    2s    Select From Main Menu    Options|Settings
	wait until keyword succeeds    60s    2s    Select Dialog    regexp=^Settings*
	Select Tab	General
	Wait Until Keyword Succeeds    10s    0.5s   Switch To Discard
	${status}=	Run Keyword And Return Status	Toggle Button Should Not Be Selected	4
	Run Keyword If	${status}==${FALSE}
	...	Run Keywords
		...	Push Toggle Button		4
		...	AND	Toggle Button Should Not Be Selected	4
	Push Button		OK
	wait until keyword succeeds    60s    2s    RemoteSwingLibrary.Select Window    regexp=^TraceViewer.*

Deactivate Cell Traces
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${trace_ref_list}: <description>
	[Arguments]  ${trace_ref_list}
	FOR		${trace_ref}	IN	@{trace_ref_list}
		Deactivate Cell Trace	${trace_ref}
		Sleep	30s
	END

Deactivate Cell Trace
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${trace_ref}: <description>
	[Arguments]  ${trace_ref}
	Run keyword If	'${trace_ref}'=='' or '${trace_ref}'=='-1'
	...	Run Keywords
		...	Log to Console	trace reference not set, exit deactivation
		...	AND	Return From Keyword
	Wait Until Keyword Succeeds    30s    2s    Select Last Trace In Cell Table With Given Trace Reference    1    ${trace_ref}
	Push Button		Stop Trace
	wait until keyword succeeds		10s		1s		Select Dialog	regexp=^Confirm St.*
	Push Button		Yes
	Wait Until Keyword Succeeds		10s		1s		RemoteSwingLibrary.Select Window	regexp=^TraceView.*
	Wait Until Keyword Succeeds		300s	5s		Trace Is Stopped		${trace_ref}

Trace Is Stopped
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${trace_ref}: <description>
	[Arguments]  ${trace_ref}
	Wait Until Keyword Succeeds		10s		1s		RemoteSwingLibrary.Select Window	regexp=^TraceView.*
	Wait Until Keyword Succeeds    30s    2s    Select Last Trace In Cell Table With Given Trace Reference    1    ${trace_ref}
	${state}=	Get Table Cell Value	MAIN_VIEW_CELL_TABLE	0	6
	Should Be True	'${state}'=='Inactive'

Input Into Search Box
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${nameToFind}: <description>
    [Arguments]  ${nameToFind}
    Wait Until Keyword Succeeds    30s    1s    Select Dialog    regexp=^New.*
    Insert Into Text Field    NES_SEARCH_TEXT_FIELD    ${nameToFind}
    Focus To Component    NES_SEARCH_TEXT_FIELD
    Send Keyboard Event    VK_ENTER

Select Working Set On WS Tree
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ws_name}: <description>
    [Arguments]    ${ws_name}
    Input Into Working Sets Search Box     ${ws_name}
    Working Set Is Clicked And Should Be Selected    ${ws_name}

Input Into Working Sets Search Box
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${nameToFind}: <description>
    [Arguments]  ${nameToFind}
    Insert Into Text Field    NES_FILTER_TEXT_FIELD    ${nameToFind}
    Focus To Component    NES_FILTER_TEXT_FIELD
    Send Keyboard Event    VK_ENTER

Working Set Is Clicked And Should Be Selected
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ws_name}: <description>
    [Arguments]  ${ws_name}
    ${nodeLabel}=    Get Tree Node Label    WORKING_SET_TREE    0
    Should Contain    ${nodeLabel}    ${ws_name}
    Click On Tree Node    WORKING_SET_TREE    ${nodeLabel}
    Tree Node Should Be Selected    WORKING_SET_TREE    ${nodeLabel}

Get First Element From First Group of Ne Tree
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${nodeLabel}|@{technologies}[0]|${Cell}: <description>
    Tree Node Should Exist    NE_TREE    0
    ${nodeLabel}=       Get Tree Node Label    NE_TREE    0
    @{technologies}=    Get Tree Node Child Names    NE_TREE    ${nodeLabel}
    @{Cells}=           Get Tree Node Child Names    NE_TREE    ${nodeLabel}|@{technologies}[0]
	FOR		${Cell}	IN		@{Cells}
		Log		${Cell}
		${status}=		Run Keyword And Return status	Should Contain		${Cell}		${lncel_name}
		Run Keyword If		${status} == ${TRUE}		Exit For Loop
	END
	Should Be Equal		${status}	${TRUE}
    [Return]    ${nodeLabel}|@{technologies}[0]|${Cell}

Get All CELLS Under LNBTS
    [Documentation]  Return all cells under first found LNBTS
    [Arguments]    ${lnbts}
    ${nodeLabel}=    Get Tree Node Label    NE_TREE    0
    Should Contain    ${nodeLabel}    ${lnbts}
    @{technology}=   Get Tree Node Child Names      NE_TREE     ${nodeLabel}
    @{Cells}=  Get Tree Node Child Names    NE_TREE    ${nodeLabel}|@{technology}[0]
    [Return]  @{Cells}

Check If Lncel Is Clicked And Should Be Selected
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${lnbts_fqdn}: <description>
    ...        ${lncel_name}: <description>
    [Arguments]  ${lnbts_fqdn}      ${lncel_name}
    wait until keyword succeeds    30s    1s    Lncel Is Clicked And Should Be Selected    ${lnbts_fqdn}    ${lncel_name}

Lncel Is Clicked And Should Be Selected
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${lnbts_fqdn}: <description>
    ...        ${lncel_name}: <description>
    [Arguments]  ${lnbts_fqdn}      ${lncel_name}
    Input Into Search Box    ${lnbts_fqdn}
    ${nodePath}     Get First Element From First Group of Ne Tree
    should contain      ${nodePath}     ${lnbts_fqdn}
    should contain      ${nodePath}     ${lncel_name}
    Click On Tree Node    NE_TREE    ${nodePath}
    Tree Node Should Be Selected    NE_TREE    ${nodePath}
    #Input Into Search Box    ${EMPTY}

Lncels Should Be Selected
    [Documentation]    Short description.
    ${nodePath}     Get First Element From First Group of Ne Tree
    Tree Node Should Be Selected    NE_TREE    ${nodePath}

Lnbts Is Clicked And Should Be Selected
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${lnbts_fqdn}: <description>
	[Arguments]  ${lnbts_fqdn}
    Input Into Search Box    ${lnbts_fqdn}
    ${nodeLabel}=    Get Tree Node Label    NE_TREE     0
    should contain      ${nodeLabel}     ${lnbts_fqdn}
    Click On Tree Node    NE_TREE    ${nodeLabel}
    Tree Node Should Be Selected    NE_TREE    ${nodeLabel}

Select All Lncels For Given Lnbts
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${lnbts}: <description>
    [Arguments]    ${lnbts}
    Input Into Search Box    ${lnbts}
    ${count}=    Get Tree Node Count    NE_TREE
    Log to console    COUNT: ${count}
    ${nodeLabel}=    Get Tree Node Label    NE_TREE    0
    should contain      ${nodeLabel}    ${lnbts}
    @{technologies}=     Get Tree Node Child Names    NE_TREE     ${nodeLabel}
    @{Cells}=    Get Tree Node Child Names    NE_TREE     ${nodeLabel}|@{technologies}[0]
    FOR    ${cell}    IN    @{Cells}
        Click On Tree Node    NE_TREE                ${nodeLabel}|@{technologies}[0]|${cell}
    END
    Input Into Search Box    ${EMPTY}

Click on NE tree node ${node_index} if label contains ${substring}
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${node_index}: <description>
    ...        ${substring}: <description>
    ...
    ...    Returns:
    ...        ${contains}: <description>
    ${node_label}=    Get Tree Node Label    NE_TREE    ${node_index}
    ${contains}=    evaluate    """${substring}""" in """${node_label}"""
    Log to console    ${substring} | ${node_index} | ${node_label} | ${contains}
    Run keyword if    ${contains}==True    Click On Tree Node    NE_TREE    ${node_index}
    [Return]    ${contains}

Select First ${amount_to_select} Lncels For Bts Name ${bts_name}
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${amount_to_select}: <description>
    ...        ${bts_name}: <description>
    Input Into Search Box    ${bts_name}
    ${click_count}    Set Variable    0
    ${current_node}    Set Variable    0
    FOR    ${iteration}    IN RANGE    0    999999    #robotframework doesn't have while loop
        ${tree_size}=    Get Tree Node Count    NE_TREE
        ${is_clicked}=    Click on NE tree node ${current_node} if label contains LNCEL
        ${click_count}=    Evaluate    ${click_count}+int(${is_clicked})
        Log to console    CLICK COUNT: ${click_count}
        ${current_node}=    Evaluate    (${current_node}+1)
        Exit For Loop If 	${click_count} >= ${amount_to_select}
        Run keyword If    ${current_node} >= ${tree_size}    Button should be enabled    NEXT_PAGE_BUTTON
        Run keyword If    ${current_node} >= ${tree_size}    Click next page
        ${current_node}=    Evaluate    ${current_node}%${tree_size}
    END

    Input Into Search Box    ${EMPTY}

Lncels For Given Lnbts Should Be Selected
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${lnbts}: <description>
    [Arguments]    ${lnbts}
    Input Into Search Box    ${lnbts}
    ${nodeLabel}=    Get Tree Node Label    NE_TREE    0
    should contain      ${nodeLabel}    ${lnbts}
    @{technologies}=     Get Tree Node Child Names    NE_TREE     ${nodeLabel}
    @{Cells}=    Get Tree Node Child Names    NE_TREE     ${nodeLabel}|@{technologies}[0]
    Tree Node Should Be Selected    NE_TREE    ${nodeLabel}|@{technologies}[0]|@{Cells}[0]
    Tree Node Should Be Selected    NE_TREE    ${nodeLabel}|@{technologies}[0]|@{Cells}[1]
    Tree Node Should Be Selected    NE_TREE    ${nodeLabel}|@{technologies}[0]|@{Cells}[2]
    Tree Node Should Be Selected    NE_TREE    ${nodeLabel}|@{technologies}[0]|@{Cells}[3]
    Input Into Search Box    ${EMPTY}

Lncels For Given Lnbts Should Not Be Selected
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${lnbts}: <description>
    [Arguments]    ${lnbts}
    Input Into Search Box    ${lnbts}
    ${nodeLabel}=    Get Tree Node Label    NE_TREE    0
    should contain      ${nodeLabel}    ${lnbts}
    @{technologies}=     Get Tree Node Child Names    NE_TREE     ${nodeLabel}
    @{Cells}=    Get Tree Node Child Names    NE_TREE     ${nodeLabel}|@{technologies}[0]
    Tree Node Should Not Be Selected    NE_TREE    ${nodeLabel}|@{technologies}[0]|@{Cells}[0]
    Tree Node Should Not Be Selected    NE_TREE    ${nodeLabel}|@{technologies}[0]|@{Cells}[1]
    Tree Node Should Not Be Selected    NE_TREE    ${nodeLabel}|@{technologies}[0]|@{Cells}[2]
    Tree Node Should Not Be Selected    NE_TREE    ${nodeLabel}|@{technologies}[0]|@{Cells}[3]
    Input Into Search Box    ${EMPTY}

Lncels Should Not Be Selected
    [Documentation]    Short description.
    ${nodePath}     Get First Element From First Group of Ne Tree
    Tree Node Should Not Be Selected    NE_TREE    ${nodePath}

Lncel Is Clicked And Should Not Be Selected
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${lnbts_fqdn}: <description>
    ...        ${lncel_name}: <description>
    [Arguments]  ${lnbts_fqdn}      ${lncel_name}
    Input Into Search Box    ${lnbts_fqdn}
    ${nodePath}     Get First Element From First Group of Ne Tree
    should contain      ${nodePath}     ${lnbts_fqdn}
    should contain      ${nodePath}     ${lncel_name}
    Click On Tree Node    NE_TREE    ${nodePath}
    Tree Node Should Not Be Selected    NE_TREE    ${nodePath}
    Input Into Search Box    ${EMPTY}

Lncel Should Be Selected
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${lnbts_fqdn}: <description>
    ...        ${lncel_name}: <description>
    [Arguments]  ${lnbts_fqdn}      ${lncel_name}
    Input Into Search Box    ${lnbts_fqdn}
    ${nodePath}     Get First Element From First Group of Ne Tree
    should contain      ${nodePath}     ${lnbts_fqdn}
    should contain      ${nodePath}     ${lncel_name}
    Tree Node Should Be Selected    NE_TREE    ${nodePath}
    Input Into Search Box    ${EMPTY}

Tick UE Throughput Parameter Checkbox
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    30s    1s    Select Dialog    regexp=^New.*
    Select Tab    1
    Check Check Box    UE_THROUGHPUT_CHECK_BOX
    Check Box Should Be Checked    UE_THROUGHPUT_CHECK_BOX

Tick PCMD Parameter Checkbox
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    30s    1s    Select Dialog    regexp=^New.*
    Select Tab    1
    Check Check Box    PCMD_CHECK_BOX
    Check Box Should Be Checked    PCMD_CHECK_BOX

Tick FORCE UE CONSTENT Checkbox
    [Documentation]    Short description.
	Wait Until Keyword Succeeds    30s    1s    Select Dialog    regexp=^New.*
    Check Check Box    FORCE_UE_CONSTENT_CHECK_BOX
    Check Box Should Be Checked    FORCE_UE_CONSTENT_CHECK_BOX

Select Activation Profile From Combobox
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${profile_to_select}: <description>
    [Arguments]    ${profile_to_select}
    Wait Until Keyword Succeeds    30s    1s    Select Dialog    regexp=^New.*
    Select Tab    0
    Select Value From Combobox And Check If It Is Selected    ACTIVATION_PROFILE_COMBO_BOX    ${profile_to_select}

Select Value From Combobox And Check If It Is Selected
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${checkbox_id}: <description>
    ...        ${value_to_select}: <description>
    [Arguments]    ${checkbox_id}    ${value_to_select}
	Log		${value_to_select}
	${selected_profile}=    Get Selected Item From Combo Box    ${checkbox_id}
	Return from keyword if	'${selected_profile}'=='${value_to_select}'
    Select From Combo Box    ${checkbox_id}    ${value_to_select}
    ${selected_profile}=    Get Selected Item From Combo Box    ${checkbox_id}
    Should Be Equal    ${selected_profile}    ${value_to_select}

Paging Navigation Buttons Are Disabled
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    30s    1s    Select Dialog    regexp=^New.*
    Focus To Component    FIRST_PAGE_BUTTON
    Wait Until Keyword Succeeds    10s    1s    Button Should Be Disabled    FIRST_PAGE_BUTTON
    Focus To Component    NEXT_PAGE_BUTTON
    Wait Until Keyword Succeeds    10s    1s    Button Should Be Disabled    NEXT_PAGE_BUTTON
    Focus To Component    PREVIOUS_PAGE_BUTTON
    Wait Until Keyword Succeeds    10s    1s    Button Should Be Disabled    PREVIOUS_PAGE_BUTTON
    Focus To Component    LAST_PAGE_BUTTON
    Wait Until Keyword Succeeds    10s    1s    Button Should Be Disabled    LAST_PAGE_BUTTON

Click Select All Button
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    30s    1s    Select Dialog    regexp=^New.*
    Push Button    SELECT_ALL_CHECKBOX

Click Clear All Selection Button
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    30s    1s    Select Dialog    regexp=^New.*
    Push Button    CLEAR_ALL_BUTTON

Click Next Page
    [Documentation]    Short description.
    Push Button    NEXT_PAGE_BUTTON

Click Previous Page
    [Documentation]    Short description.
    Push Button    PREVIOUS_PAGE_BUTTON

Activate Cell Trace
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    30s    1s    Select Dialog    regexp=^New.*
	#Type Into Text Field	DESCRIPTION_AREA	SystemTest
    Push Button    ACTIVATE_BUTTON

Activate Logged MDT
    [Documentation]    Short description.
	#Input Into Search Box
    Wait Until Keyword Succeeds    30s    1s    Select Dialog    regexp=^New.*
	#Select Tab	0
	Type Into Text Field	DESCRIPTION_TEXT_AREA	SystemTest
    Push Button    ACTIVATE_BUTTON

Configure Cell Trace
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${CellTraceConfiguration}: <description>
	[Arguments]		${CellTraceConfiguration}
	Log		${CellTraceConfiguration}
	Wait Until Keyword Succeeds    30s    1s    Select Dialog    regexp=^New.*
	List Components In Context
	Cell Trace Basic configuration		${CellTraceConfiguration['CellTraceBasic']}
	Cell Trace Advanced Configuration	${CellTraceConfiguration['CellTraceAdvanced']}
	Cell Trace MDT Configuration		${CellTraceConfiguration['CellTraceMDT']}
	Wait Until Keyword Succeeds    30s    1s    Select Dialog    regexp=^New.*
	#Push Button		ACTIVATE_BUTTON

Cell Trace Basic Configuration
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${CellTraceBasic}: <description>
	[Arguments]		${CellTraceBasic}
	Select Tab    Basic
	List Components In Context
	Log		${CellTraceBasic}
	Wait Until Keyword Succeeds    30s    1s    Select Dialog    regexp=^New.*
	Select Value From Combobox And Check If It Is Selected	JOB_TYPE_COMBO_BOX				${CellTraceBasic}[Job_type]
	Select Value From Combobox And Check If It Is Selected	TRACE_TYPE_COMBO_BOX			${CellTraceBasic}[Trace_type]
	Run Keyword If	'${CellTraceBasic}[Job_type]'=='Trace only' or '${CellTraceBasic}[Job_type]'=='Immediate MDT and trace'
	...	Select Value From Combobox And Check If It Is Selected	ACTIVATION_PROFILE_COMBO_BOX	${CellTraceBasic}[Activation_profile]
	Wait Until Keyword Succeeds	    10s	    1s	    Focus To Component		STOP_DATE
    Wait Until Keyword Succeeds	    10s	    1s	    Type Into Combobox		STOP_DATE	${CellTraceBasic}[STOP_DATE]
    Wait Until Keyword Succeeds	    10s	    1s	    Focus To Component		STOP_TIME
    Wait Until Keyword Succeeds	    10s	    1s	    Type Into Combobox		STOP_TIME	${CellTraceBasic}[STOP_TIME]
	Type Into Text Field    DESCRIPTION_AREA    ${CellTraceBasic}[Description]

Cell Trace Advanced Configuration
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${CellTraceAdvanced}: <description>
	[Arguments]		${CellTraceAdvanced}
	Log		${CellTraceAdvanced}
	Select Dialog    regexp=^New.*
	Select Tab    Advanced
	List Components In Context
	Run Keyword If		${CellTraceAdvanced}[TA] == ${TRUE}
		...	Check check box	TA_CHECK_BOX
	Run Keyword If		${CellTraceAdvanced}[UE_Throughput] == ${TRUE}
		...	Check check box	UE_THROUGHPUT_CHECK_BOX
	Run Keyword If		${CellTraceAdvanced}[PCMD] == ${TRUE}
		...	Check check box	PCMD_CHECK_BOX
	${status}=		Run Keyword And Return status	Should Not Be Empty		${CellTraceAdvanced}[IP_of_TCE]
	Run Keyword If		${status}==${TRUE}
	...	Run Keywords
		...	uncheck check box	USE_DEFAULT_IP
		...	AND	Clear Text Field		IP_FIELD
		...	AND	Type Into Text Field	IP_FIELD	${CellTraceAdvanced}[IP_of_TCE]
	Run Keyword If		${CellTraceAdvanced}[PCMD] == ${FALSE} and ${status}==${TRUE}
	...	Select Value From Combobox And Check If It Is Selected		FORCE_UI_IDS_REPETITION_COMBOBOX	${CellTraceAdvanced}[Force_UE_IDs_repetition]
	Run Keyword If		${CellTraceAdvanced}[PCMD] == ${FALSE} and ${status}==${TRUE} and '${CellTraceAdvanced}[Force_UE_IDs_repetition]'=='No'
	...	Select Value From Combobox And Check If It Is Selected	INTERFACE_SELECTION_COMBOBOX		${CellTraceAdvanced}[Interface_selection]
	${status}=		Run Keyword And Return status	Should Not Be Empty		${CellTraceAdvanced}[Port_of_TCE]
	Run Keyword If		${status}==${TRUE}
	...	Run Keywords
		...	uncheck check box	USE_DEFAULT_PORT
		...	AND	Clear Text Field		PORT_FIELD
		...	AND	Type Into Text Field	PORT_FIELD	${CellTraceAdvanced}[Port_of_TCE]
	Clear Text Field	CELL_LIMIT_FIELD
	Type Into Text Field	CELL_LIMIT_FIELD		${CellTraceAdvanced}[Limit_of_active_UEs]
	#Input Maximum Buffering Time	${CellTraceAdvanced}[Maximum_buffering_time]
	Select Dialog    regexp=^New.*

Input Maximum Buffering Time
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Maximum_buffering_time}: <description>
	[Arguments]		${Maximum_buffering_time}
	Focus To Component		CELL_LIMIT_FIELD
	Send Keyboard Event		VK_TAB
	@{Maximum_buffering_time_chars}=	Split String To Characters		${Maximum_buffering_time}
	FOR		${char}		IN	@{Maximum_buffering_time_chars}
		Send Keyboard Event		VK_${char}
		Send Keyboard Event		VK_RIGHT
	END

Cell Trace MDT Configuration
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${CellTraceMDT}: <description>
	[Arguments]		${CellTraceMDT}
	${is_MDT}=	Run Keyword And Return Status	Should Contain	${TraceConfiguration['CellTrace']['CellTraceBasic']['Job_type']}	MDT
	Return from keyword if	${is_MDT}==${FALSE}
	Log		${CellTraceMDT}
	Select Tab    MDT
	List Components In Context
	Select Value From Combobox And Check If It Is Selected	REPORT_INTERVAL_COMBOBOX	${CellTraceMDT}[Report_interval]
	Select Report Amount	${CellTraceMDT}[Report_interval]	${CellTraceMDT}[Report_amount]
	Select Data Anoymization	${CellTraceMDT}[Data_anoymization]
	Configure Immediate MDT Control		${CellTraceMDT}
	Configure Vendor Specific	${CellTraceMDT}
	Clear Text Field	CELL_LIMIT_MDT_FIELD
	Type Into Text Field	CELL_LIMIT_MDT_FIELD	${CellTraceMDT}[Limit_of_active_MDT_UEs]
	Configure RIP	${CellTraceMDT}

Configure RIP
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${CellTraceMDT}: <description>
	[Arguments]		${CellTraceMDT}
	Log		${CellTraceMDT}
	Return from keyword if		${CellTraceMDT}[RIP]==${FALSE}
	Select Value From Combobox And Check If It Is Selected	RIP_TYPE_COMBOBOX	${CellTraceMDT}[RIP_type]
	Select Value From Combobox And Check If It Is Selected	RIP_REPORT_INTERVAL_COMBO_BOX	${CellTraceMDT}[RIP_report_interval]
	${RIP_type}=	Get Selected Item From Combo Box	RIP_TYPE_COMBOBOX
	Should Be True	'${RIP_type}'=='${CellTraceMDT}[RIP_type]'
	${RIP_report_interval}=		Get Selected Item From Combo Box	RIP_REPORT_INTERVAL_COMBO_BOX
	Should Be True	'${RIP_report_interval}'=='${CellTraceMDT}[RIP_report_interval]'

Select Report Amount
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Report_interval}: <description>
    ...        ${Report_amount}: <description>
	[Arguments]		${Report_interval}	${Report_amount}
	Log		Keyword "Select From Combo Box" not work to the REPORT_AMOUNT_COMBOBOX
	Log		${Report_interval}
	Log		${Report_amount}
	${selected_value}=    Get Selected Item From Combo Box    REPORT_AMOUNT_COMBOBOX
	Return from keyword if	'${selected_value}'=='${Report_amount}'
	Click On Component		REPORT_AMOUNT_COMBOBOX
	@{amounts}=	Get Combobox Values		REPORT_AMOUNT_COMBOBOX
	Should Contain		${amounts}	${Report_amount}
	${interval}=	Replace String	${Report_interval}	${SPACE}ms	${EMPTY}
	${key}=		Run Keyword If	${interval}>=5120	Set Variable	VK_UP
		...		ELSE	set variable	VK_DOWN
	FOR		${i}		IN RANGE	1	20
		Log	${i}
		${selected_value}=	Get Selected Item From Combo Box	REPORT_AMOUNT_COMBOBOX
		Run Keyword If	'${selected_value}'=='${Report_amount}'
		...		Run Keywords
		...		Send Keyboard Event		VK_SPACE
		...		AND	Exit For Loop
		Send Keyboard Event		${key}
		sleep	0.5s
	END
	${selected_value}=	Get Selected Item From Combo Box	REPORT_AMOUNT_COMBOBOX
	Should Be True		'${selected_value}'=='${Report_amount}'

Select Data Anoymization
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Data_anoymization}: <description>
	[Arguments]		${Data_anoymization}
	Run Keyword If	'${Data_anoymization}'=='IMEI-TAC'
	...		Run Keywords
	...		Focus To Component		REPORT_AMOUNT_COMBOBOX
	...		AND	Send Keyboard Event		VK_TAB
	...		AND	Send Keyboard Event		VK_SPACE
	...		AND		sleep	0.5s
	...		AND	Send Keyboard Event		VK_UP
	...		AND		sleep	0.5s
	...		AND	Send Keyboard Event		VK_ENTER

Configure Immediate MDT Control
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${CellTraceMDT}: <description>
	[Arguments]		${CellTraceMDT}
	Select Tab    2
	Focus To Component		REPORT_AMOUNT_COMBOBOX
	Send Keyboard Event		VK_TAB
	Send Keyboard Event		VK_TAB
	Run Keyword If		${CellTraceMDT}[GNSS_positioning] == ${TRUE}
	...	Send Keyboard Event		VK_SPACE

	Run Keyword If		${CellTraceMDT}[Obtain_location] == ${TRUE}
	...	Run Keywords
	...	Send Keyboard Event		VK_TAB
	...	AND	Send Keyboard Event		VK_SPACE

	Send Keyboard Event		VK_TAB
	Run Keyword If		${CellTraceMDT}[Fore_UE_consent]==${TRUE}
		...	Send Keyboard Event		VK_SPACE

	Send Keyboard Event		VK_TAB
	Run Keyword If		${CellTraceMDT}[Select_only_GNSS_UEs]==${TRUE}
		...	Send Keyboard Event		VK_SPACE

Configure Vendor Specific
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${CellTraceMDT}: <description>
	[Arguments]		${CellTraceMDT}
	Select Tab    2
	Run Keyword If		${CellTraceMDT}[TA_synch] == ${TRUE}
	...	check check box		TA_SYNC_CHECK_BOX
	Run Keyword If		${CellTraceMDT}[PHR]==${TRUE}
	...	check check box		PHR_CHECK_BOX
	Run Keyword If		${CellTraceMDT}[UE_RANK]==${TRUE}
	...	check check box		UE_RANK_CHECK_BOX
	Run Keyword If		${CellTraceMDT}[UL_SINR]==${TRUE}
	...	check check box		SINR_CHECK_BOX
	Run Keyword If		${CellTraceMDT}[RIP]==${TRUE}
	...	check check box		RIP_CHECK_BOX
	Run Keyword If		${CellTraceMDT}[PDSCH_PRB]==${TRUE}
	...	check check box		PDSCH_PRB_CHECK_BOX
	Run Keyword If		${CellTraceMDT}[UE_BSR]==${TRUE}
	...	check check box		UE_BSR_CHECK_BOX
	Run Keyword If		${CellTraceMDT}[AoA]==${TRUE}
	...	check check box		AOA_CHECK_BOX
	Run Keyword If		${CellTraceMDT}[PUSCH_PRB]==${TRUE}
	...	check check box		PUSCH_PRB_CHECK_BOX

Configure Logged MDT
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${LoggedMDT_configuration}: <description>
	[Arguments]		${LoggedMDT_configuration}
    Wait Until Keyword Succeeds    30s    1s    Select Dialog    regexp=^New.*
	Select Value From Combobox And Check If It Is Selected    CELL_WORKING_MODE_COMBO_BOX		${LoggedMDT_configuration['CELL_WORKING_MODE']}
	Select Value From Combobox And Check If It Is Selected    ANONYMIZATION_MDT_DATA_COMBO_BOX	${LoggedMDT_configuration['ANONYMIZATION_MDT_DATA']}
	Clear Text Field		TCE_ID_TEXT_FIELD
	Type Into Text Field	TCE_ID_TEXT_FIELD	${LoggedMDT_configuration['TCE_ID']}
	Select Value From Combobox And Check If It Is Selected    LOGGING_DURATION_COMBO_BOX		${LoggedMDT_configuration['LOGGING_DURATION']}
	Select Value From Combobox And Check If It Is Selected    LOGGING_INTERVAL_COMBO_BOX		${LoggedMDT_configuration['LOGGING_INTERVAL']}
	Select Value From Combobox And Check If It Is Selected    COLLECTION_AREA_COMBO_BOX			${LoggedMDT_configuration['COLLECTION_AREA']}

	Run Keyword If		${LoggedMDT_configuration['SELECT_ONLY_STANDALONE_GNSS_UES']} == ${FALSE}
		...	Uncheck check box	SELECT_ONLY_STANDALONE_GNSS_UES_CHECK_BOX

	Run Keyword If		${LoggedMDT_configuration['FORCE_UE_CONSTENT']} == ${TRUE}
		...	Check Check Box		FORCE_UE_CONSTENT_CHECK_BOX

	Run Keyword If		${LoggedMDT_configuration['ENABLE_LOGGED_MDT_TRS_START']} == ${TRUE}
		...	Check Check Box		ENABLE_LOGGED_MDT_TRS_START_CHECK_BOX

	Wait Until Keyword Succeeds	    10s	    1s	    Focus To Component    STOP_DATE
    Wait Until Keyword Succeeds	    10s	    1s	    Type Into Combobox	STOP_DATE	${LoggedMDT_configuration['STOP_DATE']}
    Wait Until Keyword Succeeds	    10s	    1s	    Focus To Component    STOP_TIME
    Wait Until Keyword Succeeds	    10s	    1s	    Type Into Combobox	STOP_TIME	${LoggedMDT_configuration['STOP_TIME']}

Error Popup Window Appears With Exceeded Number Of Traces To Activate
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    30s    2s    Dialog Should Be Open    regexp=^Error.*

All Cells Are Diplayed
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${lnbts_fqdn}: <description>
    ...        ${expected_number_of_cells}: <description>
    [Arguments]    ${lnbts_fqdn}    ${expected_number_of_cells}
    @{cells}=    Get All CELLS Under LNBTS    ${lnbts_fqdn}
    ${number_of_cells}=    Get Length    ${cells}
    Should Be Equal As Integers   ${expected_number_of_cells}    ${number_of_cells}

No Cells Are Displayed
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    30s    1s    Select Dialog    regexp=^New.*
    ${node_count}=    Get Tree Node Count    NE_TREE
    Should Be Equal As Integers   0    ${node_count}

Click Activate Button
    [Documentation]    Short description.
    Push Button    ACTIVATE_BUTTON

Activate Button Should Be Disabled
    [Documentation]    Short description.
    wait until keyword succeeds    30s    1s    Button Should Be Disabled    ACTIVATE_BUTTON

Activate Button Should Be Enabled
    [Documentation]    Short description.
    wait until keyword succeeds    30s    1s    Button Should Be Enabled    ACTIVATE_BUTTON

Select Fast Pass Parameter Tab
    [Documentation]    Short description.
    Select Tab    Fast Pass

Fill Required Description Text Box
    [Documentation]    Short description.
    Wait Until Keyword Succeeds    30s    1s    Select Dialog    regexp=^New.*
    Type Into Text Field    DESCRIPTION_AREA    SystemTest

Select Working Set Radio Button
    [Documentation]    Short description.
    wait until keyword succeeds    10s    1s    Push Radio Button    WORKING_SET_RADIO_BUTTON

Create New LTE Activation Profile
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${profile_name}: <description>
	[Arguments]    ${profile_name}
	${profile_name}=	Generate String With Prefix And Timestamp	profile
	set test variable	${profile_name}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceBasic']}	Activation_profile	${profile_name}
	&{selected_messages}=	Create Dictionary
	Set Test Variable	${selected_messages}
	Open LTE Activation Profile Dialog
	Profile Name Not Exist	${profile_name}
    wait until keyword succeeds    60s    2s    Select From Menu    Profile|New
    wait until keyword succeeds    60s    2s    Select Dialog    regexp=^Create New.*

	Read List of Messages	0	0
	Log		${selected_messages}
	Selected Message Check	${selected_messages}	${TraceConfiguration['LTE_Activation_Profile']}
	#${label}=		Get Tree Node Label		0	0
	#Expand Tree Node	0	Protocols|E-RRC
	#Tree Node Should Be Expanded	0	Protocols|E-RRC
	#Expand Tree Node	0	Protocols|E-RRC|No Procedure
	#Tree Node Should Be Expanded	0	Protocols|E-RRC|No Procedure
	#@{list}=	Get Tree Node Child Names	0	0
	#Log		${list}
	#Click On Tree Node		0	Protocols|E-RRC|No Procedure|RRCEarlyDataRequest (UL-CCCH-Message)
	#Click On Tree Node		0	Protocols|E-RRC|No Procedure|RRCConnectionReject (DL-CCCH-Message)
	Type Into Text Field	0	${profile_name}
	Push Button		Save as
	${reslut}=		Run Keyword And Return status	Profile Name Not Exist	${profile_name}
	Should Not Be True		${reslut}==${TRUE}
	Close LTE Activation Profile Dialog

Create New LTE Activation Profile With Exist Profile
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${exist_profile_name}: <description>
    ...        ${message}: <description>
    ...
    ...    Returns:
    ...        ${profile_name}: <description>
	[Arguments]   ${exist_profile_name}		${message}
	${profile_name}=	Generate String With Prefix And Timestamp	profile
	set test variable	${profile_name}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceBasic']}	Activation_profile	${profile_name}
	&{selected_messages}=	Create Dictionary
	Set Test Variable	${selected_messages}
	Open LTE Activation Profile Dialog
	Profile Name Not Exist	${profile_name}
	Run Keyword And Ignore Error	Profile Name Not Exist	${exist_profile_name}
	Click On Table Cell		PROFILE_TABLE	0	0
	wait until keyword succeeds    60s    2s    Select From Menu    Profile|Open
	wait until keyword succeeds    60s    2s    Select Dialog    	regexp=^Edit Pro.*
	Expand Tree Node	0	Protocols|E-RRC
	Sleep	1s
	Expand Tree Node	0	Protocols|E-RRC|No Procedure
	Sleep	1s
	Click On Tree Node		0	Protocols|E-RRC|No Procedure|${message}
	Sleep	1s
	${status}=	Run Keyword And Return Status	Push Button		Update
	Should Be True		${status}==${FALSE}
	${status}=	Run Keyword And Return Status	Push Button		Save as
	Should Be True		${status}==${FALSE}
	Clear Text Field		0
	Type Into Text Field	0	${profile_name}
	Push Button		Save as
	${reslut}=		Run Keyword And Return status	Profile Name Not Exist	${profile_name}
	Should Be True		${reslut}==${FALSE}
	Update Message In LTE Activation Profile	${message}						is_clear=${TRUE}
	Update Message In LTE Activation Profile	MeasurementReport (UL-DCCH-Message)		is_clear=${FALSE}
	Close LTE Activation Profile Dialog
	[RETURN]	${profile_name}

Update Message In LTE Activation Profile
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${message}: <description>
    ...        ${is_clear}: <description>
	[Arguments]		${message}=RRCConnectionSetup (DL-CCCH-Message)		${is_clear}=${FALSE}
	Run Keyword If	${is_clear}==${TRUE}		Log		Clear list
	FOR		${index}	IN RANGE	1	999
		Exit For Loop If	${is_clear}==${FALSE}
		${status}=		Run Keyword And Return Status	Remove From List	${TraceConfiguration['LTE_Activation_Profile']}		0
		Exit For Loop If	${status}==${FALSE}
	END
	Append To List		${TraceConfiguration['LTE_Activation_Profile']}		${message}
	Log List	${TraceConfiguration['LTE_Activation_Profile']}

Selected Message Check
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${selected_messages}: <description>
    ...        ${expected_messages}: <description>
	[Arguments]		${selected_messages}	${expected_messages}
	Log Dictionary	${selected_messages}
	Log List	${expected_messages}
	${len_selected}=	Get Length	${selected_messages}
	${len_expected}=	Get Length	${expected_messages}
	Should Be Equal		${len_selected}		${len_expected}
	${selected_messages_list}=		Get Dictionary Keys		${selected_messages}
	FOR		${message}	IN	@{expected_messages}
		${result}=	Messages Check		${selected_messages_list}	${message}
		Should Be True	${result}
	END

Read List of Messages
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${nodeIdentifier}: <description>
    ...        ${nodePath}: <description>
    ...
    ...    Returns:
    ...        @{list}: <description>
	[Arguments]    ${nodeIdentifier}	${nodePath}
	Log		${nodeIdentifier}
	Log		${nodePath}
	Select Dialog    regexp=^Create New.*
	${label}=		Get Tree Node Label		0	${nodeIdentifier}
	${nodePath}=	Run Keyword If	'${nodePath}'=='0'		set variable	${label}
	...				ELSE	set variable	${nodePath}|${label}
	Expand Tree Node	0	${nodePath}
	${is_contain}=	Run Keyword And Return Status	Should Contain	${TraceConfiguration['LTE_Activation_Profile']}		${label}	case_sensitive=${FALSE}
	${label_striped}=	String.Strip String	${label}	characters=*
	${label_striped}=	String.Strip String	${label_striped}	characters=${SPACE}(UL-CCCH-Message)
	${label_striped}=	String.Strip String	${label_striped}	characters=${SPACE}(DL-DCCH-Message)
	${is_contain}=	Run Keyword If		${is_contain}==${FALSE}
					...	Run Keyword And Return Status	Should Contain	${TraceConfiguration['LTE_Activation_Profile']}			${label_striped}	case_sensitive=${FALSE}
	...				ELSE	Set Variable	${is_contain}
	Run Keyword If		${is_contain}==${TRUE}
	...	Run Keywords
		...	Click On Tree Node		0	${nodePath}
		...	AND	Set To Dictionary	${selected_messages}	${label}	${nodePath}
	${index}=	Get Tree Node Index			0	${nodePath}
	@{list}=	Get Tree Node Child Names	0	${index}
	Log		${list}
	FOR		${item}		IN	@{list}
		${id}=	Get Tree Node Index			0		${nodePath}|${item}
		Read List of Messages				${id}	${nodePath}
	END
	[RETURN]	@{list}

Messages Check
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${msg_list}: <description>
    ...        ${msg}: <description>
    ...
    ...    Returns:
    ...        ${is_contain}: <description>
	[Arguments]    ${msg_list}		${msg}
	FOR		${item}		IN		@{msg_list}
		${is_contain}=		Run Keyword And Return status	Should Contain		${item}		${msg}
		Exit For Loop If	${is_contain}==${TRUE}
	END
	[RETURN]	${is_contain}

Open LTE Activation Profile Dialog
    [Documentation]    Short description.
    wait until keyword succeeds    60s    2s    RemoteSwingLibrary.Select Window    regexp=^TraceViewer.*
    wait until keyword succeeds    180s    2s    Select From Main Menu    Tools|LTE Activation Profiles
    wait until keyword succeeds    60s    2s    Select Dialog    regexp=^LTE Activation.*

Close LTE Activation Profile Dialog
    [Documentation]    Short description.
	wait until keyword succeeds    60s    2s    Select Dialog    regexp=^LTE Activation.*
	List Components In Context
	Push Button		Close
	wait until keyword succeeds    60s    2s    RemoteSwingLibrary.Select Window    regexp=^TraceViewer.*

Profile Name Not Exist
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${profile_name}: <description>
	[Arguments]    ${profile_name}
	wait until keyword succeeds    60s    2s    Select Dialog    regexp=^LTE Activation.*
	Clear Text Field		0
	Type Into Text Field	0	${profile_name}
	Send Keyboard Event    VK_ENTER
	Sleep	5s
	${row_count}=		Get Table Row Count		PROFILE_TABLE
	Should Be True		${row_count}==0
	Clear Text Field		0
