*** Settings ***
Documentation     [PURPOSE]
Library      SSHLibrary
Library      DateTime
Library      String
#Library		 JSONLibrary
Library      OperatingSystem
Library		 ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/PaClient.py	host=10.97.92.221	port=1000

Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/SQL.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/GUIKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/ActivationCellTraceKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/ActivationSubscriberTraceKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/CellTraceAnalysisWindowKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/UeHandler.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/IPTraffic.robot
Resource	 ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/SyveCmKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/ConnectionKeywords.robot

#Variables	 ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/traceConfiguration.yaml
#Variables	 ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/android_ue_config.yaml


*** Variables ***
${active_trace_before}		8
${type}						CellTrace
${trace_reference}			0
@{trace_reference_list}
@{trace_list}
${mrbts_distname}
${lnbts_fqdn}
${lncel_name}
${mrbts_id}
${lnbts_id}
${lncel_id}
${plan_name}=	PLAN_5
#${UE2}			SONY_XZ2
#${UE2}			Nokia_8.3_5G
#${UE2}			Nokia_8
${port_source_cell}     10
${port_neighbour_cell}     9


*** Keywords ***
LTE644-k_01_ST_Active Interface trace with IMSI by Netact Tracviewer
    [Documentation]    Short description.
    X2 precondition
	Step 1: New Interface Trace with TCE as TraceViewer
	Step 2: Trigger Radio link Failure      ${port_source_cell}
	Step 3: Analysis Trace

LTE644-k_01 Setup
    [Documentation]    Short description.
    Log to Console      ${EMPTY}
	log to console      Setup for LTE644
	Common TC Setup For Trace
	Set Up UE	${UE2}
	${trace_before}=    Run Sql Statement
	...     SELECT count(*) FROM TRC.COR_TRACE_HEADER WHERE TRACE_TARGET LIKE '%${lnbts_id}%'
	set test variable	${trace_before}
	Update actRLFReportEval
    CommonKeywords.Log to console with time    Test set up finished.

Step 1: New Interface Trace with TCE as TraceViewer
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Job_type}: <description>
	[Arguments]	${Job_type}=Trace only
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceBasic']}		Job_type			Trace only
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceBasic']}		Trace_type			Interface Trace
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceBasic']}		Activation_profile	System profile
	Log Dictionary		${TraceConfiguration['CellTrace']['CellTraceBasic']}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		IP_of_TCE			${EMPTY}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		Port_of_TCE			${EMPTY}
	Log Dictionary		${TraceConfiguration['CellTrace']['CellTraceAdvanced']}
	New Cell Trace Activation Window Is Opened
	Configure Cell Trace	${TraceConfiguration['CellTrace']}
	Lnbts Is Clicked And Should Be Selected	${lnbts_fqdn}
	New Cell Trace Activation Is Started
	Trace Is Activated successfully
#	Append to List		${trace_reference_list}		${trace_reference}
	Set To Dictionary	${TraceConfiguration}		TraceReference		${trace_reference}
#	Log List	${trace_reference_list}

Check RLFIndication From Interface L3 Messages
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${traceRef}: <description>
	[Arguments]	${traceRef}
	Log		${traceRef}
	${msg_list}=	Read Interface L3 Messages		${traceRef}		1
	Should Contain		${msg_list}		RLFIndication

Step 2: Trigger Radio link Failure
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${port_source_cell}: <description>
    [Arguments]	${port_source_cell}
	Log		Make a call and trigger RLF
	${tcpdump_pid}		${traffic_file_name}=		Start IP Traffic Capturing at BTS	${bts_ip}
	PaClient.set_port_value		port=${port_source_cell}	value=0
	PaClient.set_port_value		port=${port_neighbour_cell}	value=120
	Attach UE And Start Traffic		UE_alias=UE1	required_ue=${UE2}
	PaClient.set_port_value		port=${port_neighbour_cell}	    value=0
	PaClient.set_port_value		port=${port_source_cell}	value=120
	Sleep	5s
	wait until keyword succeeds		10s		1s      Log UE info    UE1
	PaClient.set_port_value		port=${port_source_cell}	value=0
	PaClient.set_port_value		port=${port_neighbour_cell}	value=120
	Sleep	5s
	wait until keyword succeeds		10s		1s      Log UE info    UE1
	Detach UE And Stop Traffic	UE_alias=UE1
	Stop IP Traffic Capturing at BTS

Step 3: Analysis Trace
    [Documentation]    Short description.
	Check RLFIndication From Interface L3 Messages		${trace_reference}
	Analysis Each Call With Given Trace Reference	${trace_reference}	1	UEInformationResponse (UL-DCCH)

UE attached to Neighbour Cell
    [Documentation]    Short description.
    ${cid}=     Log UE info     ${UE2}      CELL_ID
    Should Contain      ${neighbour_cell_list}  ${cid}

X2 Precondition
    [Documentation]    Short description.
    ${objs}=    admin.get_managed_objects     LNREL_A
    ${neighbour_cell_list}=     Create List
    ${neighbour_cell_status}=   Set Variable    unavailable
#    Set Test Variable   ${neighbour_cell_list}
    FOR     ${obj}      IN  @{objs}
        Log     ${obj}
        Continue For Loop If   '${obj}[parameters][ecgiAdjEnbId]'=='${lnbts_id}'
        Append To List  ${neighbour_cell_list}  ${${obj}[parameters][ecgiAdjEnbId]*256+${obj}[parameters][ecgiLcrId]}
        Log     ${neighbour_cell_list}
        ${neighbour_cell_status}=   Set Variable If  '${obj}[parameters][nrStatus]==available'
        ...     ${obj}[parameters][nrStatus]
        Log    ${neighbour_cell_status}
    END
    Should Not Be Empty     ${neighbour_cell_list}
    # ${neighbour_cell_status}==available means at least one neighbour cell is available
    Should Be True      '${neighbour_cell_status}==available'

Analysis Each Call With Given Trace Reference
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${traceRef}: <description>
    ...        ${calls_count}: <description>
    ...        ${expected_msg}: <description>
	[Arguments]		${traceRef}		${calls_count}=1	${expected_msg}=UEInformationResponse (UL-DCCH)
	${call_list}=	Read All Calls of Trace    ${traceRef}    close_trace_analysis=${TRUE}    calls_count=${calls_count}
	${len}=		Get Length		${call_list}
	Should Be True	${len}>=${calls_count}
	FOR		${call}		IN	@{call_list}
		${msgs}=	Fetch Messages From Call	${call}		${expected_msg}
		${len}=		Get Length		${msgs}
		Exit For Loop If	${len}>0
	END
	Log List		${msgs}
	Should Not Be Empty		${msgs}

Update actRLFReportEval
	[Documentation]	The kw is aimed to set actRLFReportEval to true
	Log	${plan_info}
	Update Parameter From NetAct	actRLFReportEval
	...     ${TRUE}		MRBTS-${mrbts_id}/LNBTS-${lnbts_id}

LTE644-k_01 Teardown
    [Documentation]    Short description.
    Deactivate Cell Trace	${trace_reference}
	Common TC Teardown For Trace
