*** Settings ***
Documentation     [PURPOSE]
Library      SSHLibrary
Library      DateTime
Library      String
Library		 OperatingSystem

Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/SQL.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/GUIKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/ActivationCellTraceKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/CellTraceAnalysisWindowKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/UeHandler.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/IPTraffic.robot
Resource	 ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/SyveCmKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/ConnectionKeywords.robot


*** Variables ***
${close_all_dialog_in_teardown}     ${FALSE}
${active_trace_before}		8
${type}						CellTrace
${trace_reference}			81
@{trace_reference_list}
${mrbts_distname}
${lnbts_fqdn}
${lncel_name}
${mrbts_id}
${lnbts_id}
${lncel_id}
${plan_name}=	PLAN_8
${UE1}			SONY_XZ2
#${UE1}          Nokia_8
${UE2}			Nokia_8.3_5G


*** Keywords ***
LTE2202-A-a_01_01_additional MAC measurement with non-MDT cell trace with TraceViewer
    [Documentation]    Short description.
    Step 1: Start a cell trace with TraceViewer as TCE and actUeThroughputMeas as false
	Step 2: Start a cell trace with TraceViewer as TCE and actUeThroughputMeas as true

LTE2202 Setup
    [Documentation]    Short description.
    Log to Console      ${EMPTY}
	log to console      Setup for LTE2202
	Common TC Setup For Trace
	Set Up UE	${UE1}
	Activate actVendSpecCellTraceEnh
	${trace_before}=    Run Sql Statement
	...     SELECT count(*) FROM TRC.COR_TRACE_HEADER WHERE TRACE_TARGET LIKE '%${lnbts_id}%'
	set test variable	${trace_before}
	Start IP Traffic Capturing at BTS		${bts_ip}
    log to console    Setup finished.

Step 1: Start a cell trace with TraceViewer as TCE and actUeThroughputMeas as false
    [Documentation]    Short description.
	Update Parameter From NetAct	actUeThroughputMeas
	...     ${FALSE}		MRBTS-${mrbts_id}/LNBTS-${lnbts_id}
	New Trace With UE Throughput	actUEThroughputMR=${FALSE}
	LTE2202 Make Call With Android UE	1

LTE2202 Make Call With Android UE
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
	[Arguments]		${index}
	Log		Make a call with Android UEs
	UE_RRC_ACTIVE	interval=30	UE_alias=UE_${index}	required_ue=${UE1}

Step 2: Start a cell trace with TraceViewer as TCE and actUeThroughputMeas as true
    [Documentation]    Short description.
	${trace_before}=    Run Sql Statement
	...     SELECT count(*) FROM TRC.COR_TRACE_HEADER WHERE TRACE_TARGET LIKE '%${lnbts_id}%'
	set test variable	${trace_before}
	Update Parameter From NetAct	actUeThroughputMeas
	...     ${TRUE}		MRBTS-${mrbts_id}/LNBTS-${lnbts_id}
	New Trace With UE Throughput	actUEThroughputMR=${TRUE}
	LTE2202 Make Call With Android UE	1
	#LTE2202 Make 20 Calls With Android UE
	Check UE Throughput At Trace Viewer		${trace_list[1]}
	Check UE Throughput At Trace Viewer		${trace_list[0]}

New Trace With UE Throughput
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${actUEThroughputMR}: <description>
	[Arguments]		${actUEThroughputMR}=${TRUE}
	Update Trace Configuration with UE Throughput	actUEThroughputMR=${actUEThroughputMR}
	Activate Trace	${TraceConfiguration}

#Activate Trace
#        [Arguments]             ${TraceConfiguration}
#        New Cell Trace Activation Window Is Opened
#        Configure Cell Trace    ${TraceConfiguration['CellTrace']}
#        Lncel Is Clicked And Should Be Selected ${lnbts_fqdn}   ${lncel_name}
#        New Cell Trace Activation Is Started
#        Trace Is Activated successfully
#        Set To Dictionary       ${TraceConfiguration}                   TraceReference          ${trace_reference}
#        Append to List          ${trace_list}           ${TraceConfiguration}
#        Log             ${trace_list}
#        Append to List          ${trace_reference_list}         ${trace_reference}
#        Log List        ${trace_reference_list}

Update Trace Configuration with UE Throughput
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${actUEThroughputMR}: <description>
	[Arguments]		${actUEThroughputMR}=${TRUE}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceBasic']}		Job_type			Trace only
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceBasic']}		Activation_profile	System profile
	Log Dictionary		${TraceConfiguration['CellTrace']['CellTraceBasic']}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		UE_Throughput		${actUEThroughputMR}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		IP_of_TCE			${EMPTY}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		Port_of_TCE			${EMPTY}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		Limit_of_active_UEs	300
	Log Dictionary		${TraceConfiguration['CellTrace']['CellTraceAdvanced']}

Check UE Throughput At Trace Viewer
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${TraceConfiguration}: <description>
    ...        ${calls_count}: <description>
	[Arguments]		${TraceConfiguration}		${calls_count}=1
	Log		${TraceConfiguration}
	${call_list}=	Read All Calls of Trace		${TraceConfiguration['TraceReference']}		close_trace_analysis=${false}	calls_count=${calls_count}
	${len}=		Get Length		${call_list}
	Should Be True	${len}>=${calls_count}
	FOR		${call}		IN	@{call_list}
		${index}=	Get Index From List		${call_list}	${call}
		Check Non-GBR Bearers	${call}	${TraceConfiguration['CellTrace']['CellTraceAdvanced']['UE_Throughput']}
	END

LTE2202 Teardown
    [Documentation]    Short description.
	Deactivate Cell Trace	${trace_reference}
	Common TC Teardown For Trace
