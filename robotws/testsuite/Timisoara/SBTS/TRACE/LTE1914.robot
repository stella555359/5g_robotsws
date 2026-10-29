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
LTE1914_01_02_Measurement Report (MR) addition to cell trace with RIP correlation base on per subframe
    [Documentation]    Short description.
#    LTE1914 New Trace With TCE as TraceViewer	RB subframe and slot	5 sec
    LTE1914 New Trace With TCE as TraceViewer	Subframe and slot	10 sec
	LTE1914 Make Call With Android UE
	${call_list_dictionary}=	Read All Calls of Trace	${trace_reference}	${FALSE}
	Analyze Measurement And SINR		${call_list_dictionary}
	Read RIP Table
	RIP Statistics Check
	Start Trace and Trace Reaport and Stop Trace Messafe Check
	LTE1914 Post Steps

LTE1914 Setup
    [Documentation]    Short description.
    Log to Console      ${EMPTY}
	log to console      Setup for LTE1914
	Common TC Setup For Trace
	Set Up UE	${UE1}
	Activate actVendSpecCellTraceEnh
	${trace_before}=    Run Sql Statement
	...     SELECT count(*) FROM TRC.COR_TRACE_HEADER WHERE TRACE_TARGET LIKE '%${lnbts_id}%'
	set test variable	${trace_before}
	Configuration Check Via SCF
	Start IP Traffic Capturing at BTS		${bts_ip}
    log to console    Setup finished.

Activate actVendSpecCellTraceEnh
    [Documentation]    Short description.
	Update Parameter From NetAct	actVendSpecCellTraceEnh			true			MRBTS-${mrbts_id}/LNBTS-${lnbts_id}

LTE1914 Make Call With Android UE
    [Documentation]    Short description.
	Log		Make a call with Android UE
	UE_RRC_ACTIVE	interval=10	UE_alias=UE1	required_ue=${UE1}

Configuration Check Via SCF
	[Documentation]		Get cellTechnology, chbw and tddFrameConf from SCF.
	${root} =	Parse XML	${BTS_scf_initial}
	Should Be Equal	${root.tag}	raml
	${obj}=	Get Element		${root}		cmData/managedObject[@class="com.nokia.srbts:MRBTS"]
	${distName}=		XML.Get Element Attribute	${obj}	distName
	${mrbts_id_scf}=	Fetch From Right	${distName}		-
	Should Be True		'${mrbts_id_scf}'=='${mrbts_id}'
	${lncell_obj}=		Get Element			${root}
	...     cmData/managedObject[@distName="MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/LNCEL-${lncel_id}"]
	${cellTechnology}=	Get Element Text	${lncell_obj}	p[@name="cellTechnology"]
	${dn}=  Set Variable    MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/LNCEL-${lncel_id}/LNCEL_${cellTechnology}-0
	${obj}=	Get Element		${root}     cmData/managedObject[@distName="${dn}"]
	${chbw}=	Get Element Text	${obj}		p[@name="dlChBw"]
	${tddFrameConf}=	Run Keyword If	'${cellTechnology}'=='TDD'
						...	Get Element Text	${obj}	p[@name="tddFrameConf"]
	Set Test Variable	 ${cellTechnology}
	Set Test Variable	 ${chbw}
	Set Test Variable	 ${tddFrameConf}

LTE1914 New Trace With TCE as TraceViewer
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RIP_type}: <description>
    ...        ${RIP_report_interval}: <description>
	[Arguments]		${RIP_type}=RB subframe and slot	${RIP_report_interval}=5 sec
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceBasic']}		Activation_profile	System profile
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceBasic']}		Job_type    Immediate MDT and trace
	Log Dictionary		${TraceConfiguration['CellTrace']['CellTraceBasic']}

	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		IP_of_TCE			${EMPTY}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		Port_of_TCE			${EMPTY}
	Log Dictionary		${TraceConfiguration['CellTrace']['CellTraceAdvanced']}

	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceMDT']}		Report_interval			5120 ms
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceMDT']}		Report_amount			4
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceMDT']}		Fore_UE_consent			${TRUE}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceMDT']}		UL_SINR					${TRUE}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceMDT']}		RIP						${TRUE}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceMDT']}		RIP_type				${RIP_type}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceMDT']}  RIP_report_interval  ${RIP_report_interval}
	Log Dictionary		${TraceConfiguration['CellTrace']['CellTraceMDT']}

	New Cell Trace Activation Window Is Opened
	Configure Cell Trace	${TraceConfiguration['CellTrace']}
	Check If Lncel Is Clicked And Should Be Selected	${lnbts_fqdn}	${lncel_name}
	New Cell Trace Activation Is Started
	Trace Is Activated successfully
#	Append to List		${trace_reference_list}		${trace_reference}
#	Log List	${trace_reference_list}

Report Type Check
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${file}: <description>
    ...        ${report_type}: <description>
    [Arguments]		${file} 	${report_type}
    ${output}=    Run		tshark -r ${file} -Y "xml.cdata == ${report_type}" -T pdml
    Log     ${output}
    ${result}=    Run		tshark -r ${file} -Y "xml.cdata == ${report_type}" -T pdml | grep ${report_type} | wc -l
    ${count}=   Convert To Integer      ${result}
    Should Be True      ${count}>0

Start Trace and Trace Reaport and Stop Trace Messafe Check
    [Documentation]    Short description.
    # checkpoint was added due to BOAM ET transfer
    Stop IP Traffic Capturing at BTS
    Report Type Check   \"${Test Results Dir}\"/${traffic_file_name}   startTrace
    Report Type Check   \"${Test Results Dir}\"/${traffic_file_name}   stopTrace
    Report Type Check   \"${Test Results Dir}\"/${traffic_file_name}   traceReport

LTE1914 Post Steps
    [Documentation]    Short description.
	Log List	${trace_reference_list}

LTE1914 Teardown
    [Documentation]    Short description.
	Deactivate Cell Trace	${trace_reference}
	Common TC Teardown For Trace
