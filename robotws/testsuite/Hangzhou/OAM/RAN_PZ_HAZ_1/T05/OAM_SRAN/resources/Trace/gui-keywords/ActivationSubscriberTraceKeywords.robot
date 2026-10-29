*** Settings ***
Documentation     [PURPOSE] activation subscriber trace gui keywords
Library           OperatingSystem
Library           BuiltIn
#Library           RemoteSwingLibrary
#Library           ../../lib/stringUtils.py
Resource          ActivationWindowKeywords.robot


*** Keywords ***
Activate Subscriber Trace On Given Ne With Imsi
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${TraceConfiguration}: <description>
    [Arguments]    ${TraceConfiguration}
	Log		${TraceConfiguration}
	Re-authenticate
    wait until keyword succeeds    180s    1s    Open Subscriber Activation Window
	List Components In Context
    Filter And Select Network Element On Tree    FlexiNS    ${TraceConfiguration['SubscriberTrace']['NE']}
    Set Imsi Traced Number    ${TraceConfiguration['SubscriberTrace']['Traced number']}
	Clear Text Field	MCC_FIELD
	Clear Text Field	MNC_FIELD
	Type Into Text Field	MCC_FIELD	${TraceConfiguration['SubscriberTrace']['MCC']}
	Type Into Text Field	MNC_FIELD	${TraceConfiguration['SubscriberTrace']['MNC']}
	Wait Until Keyword Succeeds	    10s	    1s	    Focus To Component		STOP_DATE
    Wait Until Keyword Succeeds	    10s	    1s
    ...     Type Into Combobox		STOP_DATE	${TraceConfiguration['SubscriberTrace']['STOP_DATE']}
    Put Text Into Description Area    ${TraceConfiguration['SubscriberTrace']['Description']}
    Push Button    ACTIVATE_BUTTON

Deactivate Subscriber Trace
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${trace_ref}: <description>
	[Arguments]  ${trace_ref}
	Run keyword If	'${trace_ref}'==''
	...	Run Keywords
		...	Log to Console	trace reference not set, exit deactivation
		...	AND	Return From Keyword
	Wait Until Keyword Succeeds    30s    2s
	...     Select Last Trace In Main Table With Given Trace Reference    0    ${trace_ref}
	Push Button		Stop Trace
	wait until keyword succeeds		10s		1s		Select Dialog	regexp=^Confirm St.*
	Push Button		Yes
	Wait Until Keyword Succeeds		10s		1s		RemoteSwingLibrary.Select Window	regexp=^TraceView.*
	Wait Until Keyword Succeeds		60s		5s		Subscriber Trace Is Stopped		${trace_ref}

Delete Subsriber Trace
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${trace_ref}: <description>
	[Arguments]  ${trace_ref}
	Log		${trace_ref}
	${status}=		Run Keyword And Return Status
	...      Select Last Trace In Table    MAIN_VIEW_MAIN_TABLE    0     traceReference_filter    ${trace_ref}
	Return From Keyword If		${status}==${FALSE}

	Wait Until Keyword Succeeds    30s    2s
	...     Select Last Trace In Main Table With Given Trace Reference    0    ${trace_ref}

	wait until keyword succeeds		60s		1s
	...	Run Keywords
		...	RemoteSwingLibrary.Select Window	regexp=^TraceView.*
		...	AND		Push Button		Delete Trace
		...	AND		Log To Console	Delete exist trace
		...	AND		Select Dialog	regexp=^Confirm Del.*
	Push Button		Yes
	Wait Until Keyword Succeeds		10s		1s		RemoteSwingLibrary.Select Window	regexp=^TraceView.*
	Wait Until Keyword Succeeds		30s		1s		Subscriber Trace Is Deleted		${trace_ref}

Subscriber Trace Is Deleted
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${trace_ref}: <description>
	[Arguments]  ${trace_ref}
	${status}=		Run Keyword And Return Status
	...     Select Last Trace In Table    MAIN_VIEW_MAIN_TABLE    0     traceReference_filter    ${trace_ref}
	Should Be True	${status}==${FALSE}

Subscriber Trace Is Stopped
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${trace_ref}: <description>
	[Arguments]  ${trace_ref}
	Wait Until Keyword Succeeds		10s		1s		RemoteSwingLibrary.Select Window	regexp=^TraceView.*
	Wait Until Keyword Succeeds    30s    2s
	...     Select Last Trace In Main Table With Given Trace Reference    0    ${trace_ref}
	${state}=	Get Table Cell Value	MAIN_VIEW_MAIN_TABLE	0	6
	Should Be True	'${state}'=='Inactive'

Open Subscriber Activation Window
    [Documentation]    Short description.
    Open Subscriber Activation Dialog
    #wait until keyword succeeds    60s    2s    Push Button    SUBSCRIBER_BUTTON

Open IMS Subscriber Activation Window
    [Documentation]    Short description.
    Open Subscriber Activation Dialog
    wait until keyword succeeds    60s    2s    Push Button    SUBSCRIBER_IMS_BUTTON
    Focus On Window

Open Subscriber Activation Dialog
    [Documentation]    Short description.
    wait until keyword succeeds    60s    2s    RemoteSwingLibrary.Select Window    regexp=^TraceViewer.*
    wait until keyword succeeds    60s    2s    Select From Main Menu    Trace|New|Subscriber Trace
    wait until keyword succeeds    60s    2s    Select Dialog    regexp=^New.*

Input Into Ims Search Box
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${nameToFind}: <description>
    [Arguments]  ${nameToFind}
    Insert Into Text Field    NES_FILTER_TEXT_FIELD    ${nameToFind}
    Focus To Component    NES_FILTER_TEXT_FIELD
    Send Keyboard Event    VK_ENTER

Filter And Select Network Element On Tree
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${neType}: <description>
    ...        ${neName}: <description>
    [Arguments]    ${neType}    ${neName}
    Select Dialog    regexp=^New.*
    Insert Into Text Field    NES_FILTER_TEXT_FIELD    ${neName}
    Push Button    FILTER_BUTTON
    @{mscElements}=    Get Tree Node Child Names    NES_TREE    ${neType}
    Click On Tree Node    NES_TREE    ${neType}|@{mscElements}[0]

Set Imsi Traced Number
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${imsi}: <description>
    [Arguments]    ${imsi}
    Input Into Traced Number Text Box    ${imsi}

Set Msisdn Traced Number
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${msisdn}: <description>
    [Arguments]    ${msisdn}
    Input Into Traced Number Text Box    ${msisdn}

Set Impi Traced Number
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${impi}: <description>
    [Arguments]    ${impi}
    Input Into Traced Number Text Box    ${impi}

Put Text Into Description Area
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${textToSet}: <description>
    [Arguments]    ${textToSet}
    Type Into Text Field    TRACE_DESCRIPTION_TEXT_AREA    ${textToSet}

Check If Network Element Is Clicked And Selected
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${neElement_fqdn}: <description>
    [Arguments]  ${neElement_fqdn}
    wait until keyword succeeds    30s    1s    Network Element Is Clicked And Should Be Selected    ${neElement_fqdn}

Network Element Is Clicked And Should Be Selected
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${neElement_fqdn}: <description>
    [Arguments]  ${neElement_fqdn}
    Element On Tree Is Clicked And Should Be Selected      ${neElement_fqdn}    NES_TREE

Network Element Is Clicked And Should Be Deselected
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${neElement_fqdn}: <description>
    [Arguments]  ${neElement_fqdn}
    Element On Tree Is Clicked And Should Be Deselected    ${neElement_fqdn}    NES_TREE

Select NE on NE tree
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ne_gui_name}: <description>
    [Arguments]    ${ne_gui_name}
    Input Into Ims Search Box    ${ne_gui_name}
    Check If Network Element Is Clicked And Selected    ${ne_gui_name}

Input Into Traced Number Text Box
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${numberToInput}: <description>
    [Arguments]  ${numberToInput}
    Select Dialog    regexp=^New.*
    Type Into Text Field    TRACED_NUMBER_TEXT_FIELD    ${numberToInput}
    Push Button    ADD_BUTTON

Input Into Traced Number Text Box Without Adding
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${numberToInput}: <description>
    [Arguments]  ${numberToInput}
    Select Dialog    regexp=^New.*
    Type Into Text Field    TRACED_NUMBER_TEXT_FIELD    ${numberToInput}

Select Trace Target
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${trace_target}: <description>
    [Arguments]    ${trace_target}
    wait until keyword succeeds    10s    1s    Select From Combo Box    TRACED_TARGET_COMBOBOX    ${trace_target}

Warning Text Should Be
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${warning_text}: <description>
    ...        ${warning_panel_name}: <description>
    [Arguments]  ${warning_text}  ${warning_panel_name}=WARNING_PANEL_LABEL
    ${warning_text_with_spans}=    add span every 10 characters    ${warning_text}
    ${warning_text_with_spans_and_html}=    Catenate    SEPARATOR=    <html>    ${warning_text_with_spans}    </html>
    Wait Until Keyword Succeeds    5s    100ms
    ...     Label Text Should Be    ${warning_panel_name}    ${warning_text_with_spans_and_html}

Warning Text Should Not Be Visible
    [Documentation]    Short description.
    Label Should Not Exist    WARNING_PANEL_LABEL
