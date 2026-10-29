*** Settings ***
Documentation     [PURPOSE]
Library		 ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/iphyClient.py	host_ip=10.97.92.53	username=ute	password=N0kia@dmin56
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/SQL.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/GUIKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/ActivationCellTraceKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/ConnectionKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/CellTraceAnalysisWindowKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/IPTraffic.robot
Resource	 ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/SyveCmKeywords.robot


*** Variables ***
${type}						CellTrace
${trace_reference}			${-1}
@{trace_reference_list}
${mrbts_distname}
${lnbts_fqdn}
${lncel_name}
${mrbts_id}
${lnbts_id}
${lncel_id}
${plan_name}=	PLAN_9


*** Keywords ***
LTE2812_TC04_RCEF_reporting_at_different_Cell_with_RLFReportsOnly_and_TCE_as_TraceViewer
    [Documentation]    Short description.
	Step 1: New Trace With Job type as RLF reports only
	Step 2: Make a Call With rlf ${true}
	Step 3: Check Traced Log In Trace Viewer with rlf ${true}
	Step 4: Make a Call With rlf ${false}
	step 5: Check Traced Log In Trace Viewer with rlf ${false}

Step 1: New Trace With Job type as RLF reports only
    [Documentation]    Short description.
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceBasic']}    Job_type    RLF reports only
	Log Dictionary	${TraceConfiguration['CellTrace']['CellTraceBasic']}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		IP_of_TCE			${EMPTY}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		Port_of_TCE			${EMPTY}
	Log Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}
	New Cell Trace Activation Window Is Opened
	Configure Cell Trace	${TraceConfiguration['CellTrace']}
	Check If Lncel Is Clicked And Should Be Selected	${lnbts_fqdn}	${lncel_name}
	New Cell Trace Activation Is Started
	Trace Is Activated successfully
	Append to List		${trace_reference_list}		${trace_reference}
	Log List	${trace_reference_list}

Step ${index}: Make a Call With rlf ${rlf}
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    ...        ${rlf}: <description>
	Log		Make a call with iphy
	Start IP Traffic Capturing at BTS	${bts_ip}
	${start_time}=	Get Current DateTime From BTS	${bts_ip}
	Set Test Variable	${start_time}
	iphyClient.execute_iphy_command		trace uec=1 protocol=rrc on
	iphyClient.execute_iphy_command		detach_ue id=3
	${cmd1}=     Catenate    SEPARATOR=${SPACE}
	...     ue_report_info id=3 rlf_report serv_cell_rsrp=75
	...     serv_cell_rsrq=24 neigh_meas_list=utran previous_cell=262:03|1234567

	${cmd2}=     Catenate    SEPARATOR=${SPACE}
	...     ue_conn_est_fail_report_info id=3 failed_cell_ecgi=262:03|1234567 reporting=1 failed_cell_rsrp=1
	...     failed_cell_rsrq=2 num_of_preambles_sent=50 time_since_failure=500
	...     basic_fields=contention_detected,max_tx_power_reached neigh_meas_list=eutran

	Run Keyword If	${rlf}==${true}     iphyClient.execute_iphy_command		${cmd1}
	iphyClient.execute_iphy_command		${cmd2}
	iphyClient.execute_iphy_command		ue_attach id=3
	iphyClient.execute_iphy_command		detach_ue id=3
	iphyClient.execute_iphy_command		trace uec=1 protocol=rrc off
	Sleep	5s
	Stop IP Traffic Capturing at BTS

Step ${index}: Check Traced Log In Trace Viewer with rlf ${rlf}
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    ...        ${rlf}: <description>
	${expected_message_count}=	Run Keyword If	${rlf}==${true}
								...	Set Variable	1
								...	ELSE IF	${rlf}==${false}	Set Variable	0
	Wireshak Log Check	${expected_message_count}
	Return From Keyword If	'${rlf}'=='false'
	${call_list}=	Read All Calls of Trace		${trace_reference}    close_trace_analysis=${TRUE}    calls_count=1
	Log List		${call_list}
	Length Should Be	${call_list}	1
	Length Should Be	${call_list[0]}	1
	Should Contain	${call_list[0][0]['L3 Messages Details']}	rlf-Report-r9
	Should Contain	${call_list[0][0]['L3 Messages Details']}	connEstFailReport-r11

Wireshak Log Check
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${expected_message_count}: <description>
	[Arguments]	${expected_message_count}
	${xml}=		Run		tshark -r \"${Test Results Dir}\"/${traffic_file_name} -Y "xml.cdata == "traceReport"" -T pdml
	Log		${xml}
	${root} =	Parse XML	${xml}
	Should Be Equal	${root.tag}	pdml
	${packets}=		Get Elements		${root}		packet
	Length Should Be	${packets}	${expected_message_count}

LTE2812 TC04 Teardown
    [Documentation]    Short description.
	Log List	${trace_reference_list}
	Deactivate Cell Traces	${trace_reference_list}
    Common TC Teardown For Trace
    Set To Dictionary	${TraceConfiguration}   TraceTarget     ${original_target}
    Log Dictionary      ${TraceConfiguration}
