*** Settings ***
Documentation     [PURPOSE]
Library      SSHLibrary
Library      DateTime
Library      String
Library		 Screenshot
Library		 OperatingSystem
Library		 XML
Library		 ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/emil_decoder.py
... 	host_name=10.56.111.77	username=hoam-tester	password=Nokia123!
...     emil_path=C:\\\"Program Files\"\\Emil\\Emil.exe	host_name_l3dc=10.97.92.238	username_l3dc=dcapuser
...     password_l3dc=T@dmin@123	log_dir_l3dc=/sharedvolume/ntracer/_data/

Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/SQL.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/GUIKeywords.robot
#Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/ActivationCellTraceKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/ConnectionKeywords.robot
#Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/CellTraceAnalysisWindowKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/UeHandler.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/IPTraffic.robot
Resource	 ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/SyveCmKeywords.robot


*** Variables ***
${TOPOLOGY_GENERATOR_NUMBER_OF_LNBTS}	1
${TOPOLOGY_GENERATOR_CELLS_PER_LNBTS}	1
${TOPOLOGY_GENERATOR_STARTING_LNBTS}	1
${VERSION}      FL18
${DESCRIPTION}    PET Test Activate Many Traces
${GET_PLAN_IDS_QUERY}    SELECT CONF_ID FROM CMDPLA.C_CONFIGURATIONS_TBL WHERE CONF_TYPE_ID=3
${GET_NUMBER_OF_LNBTSES_QUERY}    SELECT count(*) FROM TRC.CACHE_LN_BTS WHERE name = 'WS_TEST'
${WS_NAME}    PETActivationTestWorkingSet
${TESTCASE_RESULT_FILE}    PETreports/WorkingSetActivationOfCellTracesInGUIResults.csv
@{TOPOLOGY_GENERATOR_LNCEL_PARAMS}		mcc=262		mnc=03
@{TOPOLOGY_GENERATOR_LNBTS_PARAMS}		name=WS_TEST
${active_trace_before}		8
${type}						CellTrace
${trace_reference}			-1
@{trace_reference_list}
${close_all_dialog_in_teardown}     ${FALSE}
${mrbts_distname}
${lnbts_fqdn}
${lncel_name}
${mrbts_id}
${lnbts_id}		5058
${lncel_id}
${tcpdump_pid}
${start_time}
${bts_ip}
${UE1}			SONY_XZ2
#${UE1}			Nokia_8
${UE2}			Nokia_8.3_5G
${stop_ip_traffic_required}		${FALSE}
${tce_ip}       2a00:8a00:8000:134:105:97:92:ee


*** Keywords ***
LBT2864-B_01_ST_Include eNB type in cell trace report_full cell trace process
    [Documentation]    Short description.
    Step 1: Start New Cell Trace From Trace Viewer
	Step 2: Make a Call
	Step 3: Stop Trace Session Via Trace Viewer
	Step 4: Post Check
	Step 5: LBT2864 Post Steps

LBT2864 Setup
    [Documentation]    Short description.
    Log to Console      ${EMPTY}
	log to console      Setup for LBT2864
	Common TC Setup For Trace
	Set Up UE	${UE1}
	Enable actCellTrace And extCellTraceRep
	${trace_before}=    Run Sql Statement
	...     SELECT count(*) FROM TRC.COR_TRACE_HEADER WHERE TRACE_TARGET LIKE '%${lnbts_id}%'
	set test variable	${trace_before}
	log to console    Setup finished.

Enable actCellTrace And extCellTraceRep
    [Documentation]    Short description.
	Update Parameter From NetAct	actCellTrace	${TRUE}		MRBTS-${mrbts_id}/LNBTS-${lnbts_id}
	Update Parameter From NetAct	extUeTraceRep	${TRUE}		MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/CTRLTS-1

Step 1: Start New Cell Trace From Trace Viewer
    [Documentation]    Short description.
	Update Trace Configuration
	Start IP Traffic Capturing at BTS		${bts_ip}   ${tce_ip}
	${stop_ip_traffic_required}=	Set Variable		${TRUE}
	LBT2864 New Trace with TCE as L3DC

Step 2: Make a Call
    [Documentation]    Short description.
	LBT2864 Make Call With Android UE

Step 3: Stop Trace Session Via Trace Viewer
    [Documentation]    Short description.
	Deactivate Cell Trace	${trace_reference}
	${trace_reference_tmp}=     Set Variable    ${trace_reference}
	${trace_reference}      Set Variable    ${-1}
	Set Test Variable   ${trace_reference_tmp}
	Set Test Variable   ${trace_reference}

Step 4: Post Check
    [Documentation]    Short description.
	Wait Until Keyword Succeeds    5min    30s    Trace Reports Are Available At L3DC
	Stop IP Traffic Capturing at BTS
	${stop_ip_traffic_required}=	Set Variable		${FALSE}
	NSNTI Trace Message Verification	startTrace
	NSNTI Trace Message Verification	stopTrace

Trace Reports Are Available At L3DC
	[Documentation]	${msg_name} is used in case of NAS msg not proper decoded
	${recent_log}=	Fetch Recent Traced Log From L3DC	2
	FOR		${message}	IN	@{recent_log}
		${message_time}=	Convert Date	${message['Time']}
		${time}=	Subtract Date From Date		${message_time}		${start_time}
		${msg_name}=	Convert To String	${message['Message name']}
		${status}=	Run Keyword If	"${msg_name}"=="Stop trace"
		...	Run Keyword And Return Status	Should Be True	${time}>0
		Set Variable	${status}
		Exit For Loop If	${status}==${TRUE}
	END
	Should Be True	${status}==${TRUE}

NSNTI Trace Message Verification
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${message_type}: <description>
	[Arguments]		${message_type}
	${message_type}=	Convert To Lower Case	${message_type}
	${msgtype}=	Run keyword If	'${message_type}'=='starttrace'		Set Variable	0x00001200
				...	ELSE IF		'${message_type}'=='stoptrace'		Set Variable	0x00001300
	${xml}=		Run
	...    tshark -r \"${Test Results Dir}\"/${traffic_file_name} -Y "nsnti.msgreport.msginfo.msgtype == ${msgtype}" -T pdml
	Log		${xml}
	${root} =	Parse XML	${xml}
	Should Be Equal	${root.tag}	pdml
	${packets}=		Get Elements		${root}		packet
	Length Should Be	${packets}	2
	@{TraceRecSessionID_list}=	Create List
	FOR		${packet}	IN	@{packets}
		${proto_nsnti}=	Proto Nsnti message Check		${packet}	${msgtype}
		${field_tracereportmode}=	Get Element		${proto_nsnti}		field/field[@name="nsnti.tracereportmode"]
		${TraceReportMode}=		XML.Get Element Attribute	${field_tracereportmode}	showname
		${field_TraceRecSessionID}=		Get Element		${proto_nsnti}
		...     field/field/field[@name="nsnti.tracerecsessionis"]
		${TraceRecSessionID}=	XML.Get Element Attribute	${field_TraceRecSessionID}	value
		Append To List		${TraceRecSessionID_list}	${TraceRecSessionID}
		Run Keyword If	'${TraceReportMode}'=='TraceReportMode: New trace session-Online report (0)'
			...	Should Be Equal		'${TraceRecSessionID}'	'ffff'
			...	ELSE IF			'${TraceReportMode}'=='TraceReportMode: New trace recording session-Online report (16)'
				...	Should Not Be Equal	'${TraceRecSessionID}'	'ffff'
	END
	Log List	${TraceRecSessionID_list}
	Should Not Be Equal		'${TraceRecSessionID_list}[0]'	'${TraceRecSessionID_list}[1]'

Proto Nsnti message Check
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${packet}: <description>
    ...        ${target_msgtype}: <description>
    ...
    ...    Returns:
    ...        ${proto_nsnti}: <description>
	[Arguments]		${packet}	${target_msgtype}
	${proto_nsntis}=	Get Elements		${packet}				proto[@name="nsnti"]
	FOR		${proto_nsnti}	IN	@{proto_nsntis}
		${field_msgtype}=	Get Element
		...     ${proto_nsnti}				field/field/field[@name="nsnti.msgreport.msginfo.msgtype"]
		${msgtype}=		XML.Get Element Attribute	${field_msgtype}	showname
		${status}=	Run keyword And Return Status	Should Contain	${msgtype}		${target_msgtype}
		Continue For Loop IF	${status}==${FALSE}
		Set Variable	${proto_nsnti}
		${field_traceid}=	Get Element		${proto_nsnti}				field/field/field[@name="nsnti.traceid"]
		${traceid_hex}=		XML.Get Element Attribute	${field_traceid}	value
		${traceid}=		Convert To Integer	0x${traceid_hex}
		Exit For Loop If	'${traceid}'=='${trace_reference_tmp}'
	END
	Should Be Equal		'${traceid}'	'${trace_reference_tmp}'
	[RETURN]	${proto_nsnti}

LBT2864 New Trace with TCE as L3DC
    [Documentation]    Short description.
	New Cell Trace Activation Window Is Opened
	Configure Cell Trace	${TraceConfiguration['CellTrace']}
	Check If Lncel Is Clicked And Should Be Selected	${lnbts_fqdn}	${lncel_name}
	New Cell Trace Activation Is Started
	Trace Is Activated successfully

Update Trace Configuration
    [Documentation]    Short description.
	Log Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		IP_of_TCE			${tce_ip}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		Port_of_TCE			49151
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		Interface_selection	NSNTI
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceBasic']}		Activation_profile	System profile
	Log Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}
	Log Dictionary	${TraceConfiguration['CellTrace']['CellTraceBasic']}

Fetch Recent Traced Log From L3DC
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${count}: <description>
    ...
    ...    Returns:
    ...        ${recent_log}: <description>
	[Arguments]		${count}
	${recent_log}=		emil_decoder.decode_recent_logs		count=${count}	ne=${lnbts_id}
	[RETURN]	${recent_log}

Recent Traced Log Check
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${recent_log}: <description>
    ...        ${expected_messages}: <description>
	[Arguments]		${recent_log}	${expected_messages}
	FOR		${expected_message}	IN	@{expected_messages}
		${result}   ${message_body}=	Is Message In Recent Traced Log		${recent_log}	${expected_message}
		Should Be True	${result}==${TRUE}
	END

Is Message In Recent Traced Log
	[Arguments]			${recent_log}	${expected_message}
	[Documentation]		'Message name' should be used to check if message is proper decoded.
	...					While the customer sack was not published in time which will lead to
	...					'Message name' not proper displayed. Here we use 'Message body' instead.
	${expected_message_dic}=	Create Dictionary	Message name	${expected_message}
	FOR		${message}	IN	@{recent_log}
		Log		${message['Message name']} ${expected_message}
		Log		${message['Message body']} ${expected_message}
		${status}=	Timestamp Check Temp		${start_time}	${message['Time']}
		Continue For Loop If	${status}==${FALSE}
		${MessageBody}=		Convert To String	${message['Message body']}
		${result}=	Run Keyword And Return Status	Should Contain
		...     ${message['Message body']}		${expected_message}		ignore_case=${TRUE}
		Exit For Loop If	${result}==${TRUE}
	END
	[RETURN]	${result}   ${MessageBody}

Timestamp Check Temp
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${timestamp1}: <description>
    ...        ${timestamp2}: <description>
    ...
    ...    Returns:
    ...        ${status}: <description>
	[Arguments]		${timestamp1}	${timestamp2}
	Log		${timestamp1} ${timestamp2}
	${d1}=	Convert Date		${timestamp1}		epoch
	${d2}=	Convert Date		${timestamp2}		epoch
	${status}=	Run Keyword And Return Status	Should Be True	${d2}>${d1}
	[RETURN]	${status}

LBT2864 Make Call With Android UE
    [Documentation]    Short description.
	Log		Make a call with Android UE
	UE_RRC_ACTIVE	1	UE_alias=UE1	required_ue=${UE1}

Step 5: LBT2864 Post Steps
    [Documentation]    Short description.
	Run keyword If		${stop_ip_traffic_required}==${TRUE}
		...	Stop IP Traffic Capturing at BTS

LBT2864 Teardown
    [Documentation]    Short description.
    Run Keyword If Test Passed      Set Suite Variable    ${LTE955_PASSED}        ${TRUE}
    Run Keyword If Test Failed      Set Suite Variable    ${LTE955_PASSED}        ${FALSE}
    Deactivate Cell Trace	${trace_reference}
	Common TC Teardown For Trace
