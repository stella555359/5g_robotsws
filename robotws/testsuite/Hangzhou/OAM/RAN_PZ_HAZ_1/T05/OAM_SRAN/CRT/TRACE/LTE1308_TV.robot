*** Settings ***
Documentation     [PURPOSE]
Library      SSHLibrary
Library      DateTime
Library      String
Library      Collections
Library      OperatingSystem

Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/SQL.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/GUIKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/ActivationCellTraceKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/ConnectionKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/CellTraceAnalysisWindowKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/UeHandler.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/IPTraffic.robot
Resource	 ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/SyveCmKeywords.robot

#Variables	 ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/traceConfiguration.yaml
#Variables	 ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/android_ue_config.yaml


*** Variables ***
${close_all_dialog_in_teardown}     ${FALSE}
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
${mrbts_distname}
${lnbts_fqdn}
${lncel_name}
${mrbts_id}
${lnbts_id}
${lncel_id}
${eutraCelId}=	1294848
${plan_name}=	PLAN_7
${UE1}=		SONY_XZ2			# Management_Based_MDT_Allowed
${UE2}=		Nokia_8.3_5G
${traffic_file_name}


*** Keywords ***
LTE1308 Immediate MDT Basic operation
    [Documentation]    Short description.
	Step 1: New Trace with TCE as TraceViewer
	Step 2: Make Call With Android UE
	Step 3: Trace Data Verificaiton in Trace Viewer
	Step 4: LTE1308 Post Steps

LTE1308 Setup
    [Documentation]    Short description.
    log to console    ${empty}
    log to console    setup for LTE1308.
    Common TC Setup For Trace
	Set Up UE	${UE1}
	Set Up UE	${UE2}
	Update actMDTCellTrace and actCellTrace and actCellTraceWithIMSI From NetAc
	#Update connected MME	10.108.225.167
	${trace_before}=    Run Sql Statement
	...     SELECT count(*) FROM TRC.COR_TRACE_HEADER WHERE TRACE_TARGET LIKE '%${lnbts_id}%'
	set test variable	${trace_before}
    log to console    Test set up finished.

Update actMDTCellTrace and actCellTrace and actCellTraceWithIMSI From NetAc
	[Arguments]		${actMDTCellTrace}=true		${actCellTrace}=true 	${actCellTraceWithIMSI}=true
	Log    ${actCellTraceWithIMSI}
	[Documentation]	update actMDTCellTrace and actCellTrace from NetAct
	Update Parameter From NetAct	actCellTrace		${actCellTrace}	MRBTS-${mrbts_id}/LNBTS-${lnbts_id}
	Update Parameter From NetAct	actMDTCellTrace		${actMDTCellTrace}	MRBTS-${mrbts_id}/LNBTS-${lnbts_id}

Update connected MME
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${mme_ip}: <description>
	[Arguments]	${mme_ip}
	Update Parameter From NetAct	ipAddrPrim		${mme_ip}	MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/LNMME-0

Step 1: New Trace with TCE as TraceViewer
    [Documentation]    Short description.
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceBasic']}    Job_type    Immediate MDT and trace
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceBasic']}		Activation_profile	System profile
	Log Dictionary		${TraceConfiguration['CellTrace']['CellTraceBasic']}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		IP_of_TCE			${EMPTY}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		Port_of_TCE			${EMPTY}
	Log Dictionary		${TraceConfiguration['CellTrace']['CellTraceAdvanced']}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceMDT']}			Report_interval		5120 ms
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceMDT']}			Report_amount		4
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceMDT']}			Data_anoymization	IMEI-TAC
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceMDT']}			Fore_UE_consent		${false}
	Log Dictionary		${TraceConfiguration['CellTrace']['CellTraceMDT']}
	New Cell Trace Activation Window Is Opened
	Configure Cell Trace	${TraceConfiguration['CellTrace']}
	Check If Lncel Is Clicked And Should Be Selected	${lnbts_fqdn}	${lncel_name}
	New Cell Trace Activation Is Started
	Trace Is Activated successfully
#	Append to List		${trace_reference_list}		${trace_reference}
#	Log List	${trace_reference_list}

Step 2: Make Call With Android UE
    [Documentation]    Short description.
	Log		Make a call with Android UE
	${tcpdump_pid}		${traffic_file_name}=		Start IP Traffic Capturing at BTS	${bts_ip}
	${Report_interval}=		Set Variable	${TraceConfiguration['CellTrace']['CellTraceMDT']['Report_interval']}
	${Report_interval}=		Fetch From Left		${Report_interval}	${SPACE}
	${interval}=    evaluate
	...     ${Report_interval}*${TraceConfiguration['CellTrace']['CellTraceMDT']['Report_amount']}/1000.0
	UE_RRC_ACTIVE	interval=${interval}	UE_alias=UE1	required_ue=${UE1}      extra=5
	UE_RRC_ACTIVE	interval=${interval}	UE_alias=UE2	required_ue=${UE2}      extra=5
	Stop IP Traffic Capturing at BTS
	Get Calls Count From Wireshark Log
	Sleep	180s

Step 3: Trace Data Verificaiton in Trace Viewer
    [Documentation]    Short description.
	wait until keyword succeeds		10min		30s    Analysis Each Call

Get Calls Count From Wireshark Log
    [Documentation]    Short description.
    ${cmd}=     Catenate    SEPARATOR=${SPACE}
    ...     tshark -r \"${Test Results Dir}\"/${traffic_file_name}
    ...     -Y "xml.tag == \\\"<traceRecordingSessionReference>\\\"" -T pdml|
    ...     grep -i traceRecordingSessionReference -A 1 | grep -i showname
	${output}=	Run     ${cmd}
	Log		${output}
	${matchs}=	Get Regexp Matches	${output}	showname=\"0x([\\d\\w]+)"		1
	${trsrs}=	Remove Duplicates	${matchs}
	Log		Trace recording session reference List: ${trsrs}
	${calls_count}=		Get Length	${trsrs}
	Set Test Variable	${calls_count}

Analysis Each Call
    [Documentation]    Short description.
	Run Keyword And Ignore Error	Close Trace Analysis
	${call_list}=	Read All Calls of Trace		${trace_reference}
	...     close_trace_analysis=${FALSE}	calls_count=${calls_count}
	${len}=		Get Length		${call_list}
	${Report_interval}=	Fetch From Left
	...     ${TraceConfiguration['CellTrace']['CellTraceMDT']['Report_interval']}	${SPACE}
	Should Be True	${len}>1
	${UE_MDT}=	Create Dictionary	ManagementBasedMDTAllowed_UE=${FALSE}	ManagementBasedMDTNotAllowed_UE=${FALSE}
	FOR		${call}		IN	@{call_list}
		${index}=	Get Index From List		${call_list}	${call}
		${rrcConnectionReconfiguration_msg}=	Fetch Messages From Call	${call}		RRCConnectionReconfiguration
		${CellTrafficTrace_msg}=	Fetch Messages From Call	${call}		CellTrafficTrace
		Length Should Be	${CellTrafficTrace_msg}	1
		${InitialContextSetupRequest_msg}=	Fetch Messages From Call	${call}		InitialContextSetupRequest
		${len}=		Get Length		${InitialContextSetupRequest_msg}
		Continue For Loop If	${len}==0
		${is_mdt_allow}=	Run Keyword And Return Status	Should Contain
		...     ${InitialContextSetupRequest_msg[0]['L3 Messages Details']}		ManagementBasedMDTAllowed
		...     ignore_case=${TRUE}
		${MR_message_list}=		Fetch Messages From Call	${call}		MeasurementReport
		Log List	${MR_message_list}
		${len}=		Get Length		${MR_message_list}
		Run Keyword If	${is_mdt_allow}==${TRUE}
			...	Run Keywords
			...	Set To Dictionary	${UE_MDT}	ManagementBasedMDTAllowed_UE=${TRUE}
#			...	AND	Should Be True	${len}==${TraceConfiguration['CellTrace']['CellTraceMDT']['Report_amount']}
			...	AND	Measurement Check	${MR_message_list}	${index}
			...	AND	Check Report Interval And Report Amount From RRCConnectionReconfiguration Message
			...     ${rrcConnectionReconfiguration_msg[0]['L3 Messages Details']}
			...     ${Report_interval}	${TraceConfiguration['CellTrace']['CellTraceMDT']['Report_amount']}
		...	ELSE IF	${is_mdt_allow}==${FALSE}
		...	Run Keywords
			...	Set To Dictionary	${UE_MDT}	ManagementBasedMDTNotAllowed_UE=${TRUE}
			...	AND	Should Be True	${len}==0
	END
	Close Trace Analysis
	Should Be True	${UE_MDT['ManagementBasedMDTAllowed_UE']}==${TRUE}
	Should Be True	${UE_MDT['ManagementBasedMDTNotAllowed_UE']}==${TRUE}

Step 4: LTE1308 Post Steps
    [Documentation]    Short description.
    Log     TBD

LTE1308 Teardown
    [Documentation]    Short description.
	Deactivate Cell Trace	${trace_reference}
	Common TC Teardown For Trace
