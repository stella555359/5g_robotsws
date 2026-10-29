*** Settings ***
Documentation     [PURPOSE]
Library      SSHLibrary
Library      DateTime
Library		OperatingSystem
Library		XML

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
${lnbts_fqdn}				LNBTS-5051
${lncel_name}				LNCEL-1
${GET_TRACE_STATE}			SELECT count(*) FROM TRC.COR_TRACE_HEADER WHERE STATE='ACTIVE' AND TARGET=${lnbts_fqdn}
${active_trace_before}		8
${trace_reference}			-1
${bts_ip}
${plan_name}	PLAN_5
${UE1}			SONY_XZ2
#${UE2}          Nokia_8
${UE2}			Nokia_8.3_5G


*** Keywords ***
LTE1049-B_02_ST_eNB sends cellTrafficTrace with LoggedMDT indicator to MME for multiple UEs
    [Documentation]    Short description.
	Step 1: Create New Logged MDT With Trace Viewer GUI
	Step 2: Multiple UE Attach To eNB And Trigger UE To RRC IDLE State
	Step 3: Check CellTrafficTrace Message With Wireshark Log And Logged MDT Data With Trace Viewer GUI
	Step 4: LTE1049 Post Steps

LTE1049 Setup
    [Documentation]    Short description.
    Common TC Setup For Trace
    Set Up UE	${UE1}
#	Set Up UE	${UE2}
	Update Parameter From NetAct    actCellTraceWithIMSI    ${TRUE}     MRBTS-${mrbts_id}/LNBTS-${lnbts_id}
	Update Parameter From NetAct    actMDTloggedCellTrace   ${TRUE}     MRBTS-${mrbts_id}/LNBTS-${lnbts_id}
	Update Parameter From NetAct    inactivityTimer		    1	        ${TraceConfiguration['TraceTarget']}
	${trace_before}=    Run Sql Statement
	...     SELECT count(*) FROM TRC.COR_TRACE_HEADER WHERE TRACE_TARGET LIKE '%${lnbts_id}%'
	set test variable	${trace_before}
	Start IP Traffic Capturing at BTS		${bts_ip}
	${mystr}=	Generate String With Prefix And Timestamp	cellTrafficTrace
	Set Test Variable	${mystr}

Step 1: Create New Logged MDT With Trace Viewer GUI
    [Documentation]    Short description.
	New Logged MDT Activation Window Is Opened
	New Logged MDT Activation Is Started
	Trace Is Activated successfully

Step 2: Multiple UE Attach To eNB And Trigger UE To RRC IDLE State
    [Documentation]    Short description.
	Log		Trigger UE from RRC ACTIVE to RRC IDLE, then to RRC ACTIVE
	UE_RRC_IDLE		interval=30		UE_alias=UE2    required_ue=${UE1}
	UE_RRC_IDLE		interval=30		UE_alias=UE2	required_ue=${UE1}
	UE_RRC_IDLE		interval=30		UE_alias=UE2	required_ue=${UE1}
	UE_RRC_IDLE		interval=30		UE_alias=UE2	required_ue=${UE1}

Step 3: Check CellTrafficTrace Message With Wireshark Log And Logged MDT Data With Trace Viewer GUI
    [Documentation]    Short description.
	Stop IP Traffic Capturing at BTS
	${msg_count}=	CellTrafficTrace Message Check		\"${Test Results Dir}\"/${traffic_file_name}
	Log		TBD: MDT data read from Trace Analysis shall be compared with emqil logs.
	${msg_list}=	Read L3 Messages of Logged MDT from Trace Analysis
	...     ${trace_reference}	expected_calls_count=${msg_count}
	Log List		${msg_list}

CellTrafficTrace Message Check
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${file}: <description>
    ...        ${msg_count}: <description>
    ...
    ...    Returns:
    ...        ${len}: <description>
	[Arguments]		${file}=/home/ute/22260_20201124T132811.pcap	${msg_count}=2
	${xml}=		Run		tshark -r ${file} -Y "s1ap.procedureCode == 42" -T pdml
	Log		${xml}
	${root} =	Parse XML	${xml}
	Should Be Equal	${root.tag}	pdml
	${packets}=		XML.Get Elements		${root}		packet
	${len}=		Get Length	${packets}
	Should Be True	${len}>=${msg_count}
	FOR		${packet}	IN	@{packets}
		${proto_s1ap}=	XML.Get Element		${packet}	proto[@name="s1ap"]
		Log		${proto_s1ap}
		${field_s1ap_protocolIEs}=	XML.Get Element
		...     ${proto_s1ap}	field/field/field/field/field[@name="s1ap.protocolIEs"]
		Log		${field_s1ap_protocolIEs}
		${field_s1ap_MME_UE_S1AP_ID}=	XML.Get Element
		...     ${field_s1ap_protocolIEs}	field/field/field/field[@name="s1ap.MME_UE_S1AP_ID"]
		${MME_UE_S1AP_ID}=	XML.Get Element Attribute	${field_s1ap_MME_UE_S1AP_ID}	show

		${field_s1ap_ENB_UE_S1AP_ID}=	XML.Get Element
		...     ${field_s1ap_protocolIEs}	field/field/field/field[@name="s1ap.ENB_UE_S1AP_ID"]
		${ENB_UE_S1AP_ID}=	XML.Get Element Attribute	${field_s1ap_ENB_UE_S1AP_ID}	show

		${field_s1ap_E_UTRAN_Trace_ID}=	XML.Get Element
		...     ${field_s1ap_protocolIEs}	field/field/field/field[@name="s1ap.E_UTRAN_Trace_ID"]
		${E_UTRAN_Trace_ID}=	XML.Get Element Attribute	${field_s1ap_E_UTRAN_Trace_ID}	value
		${field_traceID}=	XML.Get Element
	    ...     ${field_s1ap_E_UTRAN_Trace_ID}	field[@name="s1ap.E_UTRAN_Trace_ID.TraceID"]
		${traceID}=		XML.Get Element Attribute	${field_traceID}	show
		${traceID_decimal}=		Convert To Integer	${traceID}
		Should Be True	'${traceID_decimal}'=='${trace_reference}'
		${field_TraceRecordingSessionReference}=	XML.Get Element
		...     ${field_s1ap_E_UTRAN_Trace_ID}	field[@name="s1ap.E_UTRAN_Trace_ID.TraceRecordingSessionReference"]
		${TraceRecordingSessionReference}=	XML.Get Element Attribute	${field_TraceRecordingSessionReference}	show

		${ecgi}=	XML.Get Element
		...     ${field_s1ap_protocolIEs}	field/field/field/field[@name="s1ap.EUTRAN_CGI_element"]
		${ecgi_contain}=    Run Keyword And Return Status
		...     Should Contain      ${xml}      s1ap.EUTRAN_CGI_element
		${field_mcc}=   Run Keyword If
		...     ${ecgi_contain}==${TRUE}  XML.Get Element  ${ecgi}	field[@name="e212.ecgi.mcc"]
		...     ELSE    XML.Get Element		${ecgi}	field[@name="e212.mcc"]
#		 ${field_mcc}=	XML.Get Element		${ecgi}	field[@name="e212.ecgi.mcc"]
#        ${field_mcc}=	XML.Get Element		${ecgi}	field[@name="e212.mcc"]
		${mcc}=		XML.Get Element Attribute	${field_mcc}	show

		${field_mnc}=	Run Keyword If
		...     ${ecgi_contain}==${TRUE}    XML.Get Element		${ecgi}	field[@name="e212.ecgi.mnc"]
		...     ELSE    XML.Get Element		${ecgi}	field[@name="e212.mnc"]
#		 ${field_mnc}=	XML.Get Element		${ecgi}	field[@name="e212.ecgi.mnc"]
#        ${field_mnc}=	XML.Get Element		${ecgi}	field[@name="e212.mnc"]
		${mnc}=		XML.Get Element Attribute	${field_mnc}	show
		${field_CellIdentity}=	XML.Get Element
		...     ${ecgi}	field[@name="s1ap.CellIdentity"]
		${CellIdentity}=	XML.Get Element Attribute	${field_CellIdentity}	show

		${field_s1ap_transportLayerAddressIPv4}=	XML.Get Element
		...     ${field_s1ap_protocolIEs}	field/field/field/field/field[@name="s1ap.transportLayerAddressIPv4"]
		${transportLayerAddressIPv4}=	XML.Get Element Attribute	${field_s1ap_transportLayerAddressIPv4}	show

		${field_s1ap_PrivacyIndicator}=	XML.Get Element
		...     ${field_s1ap_protocolIEs}	field/field/field/field[@name="s1ap.PrivacyIndicator"]
		${PrivacyIndicator}=	XML.Get Element Attribute	${field_s1ap_PrivacyIndicator}	showname
		Should Contain	${PrivacyIndicator}		logged-MDT
	END
	[RETURN]	${len}

New Logged MDT Activation Window Is Opened
    [Documentation]    Short description.
    wait until keyword succeeds    2m    30s    Open Logged MDT Window

New Logged MDT Activation Is Started
    [Documentation]    Short description.
	Configure Logged MDT	${TraceConfiguration['LoggedMDT']}
	Check If Lncel Is Clicked And Should Be Selected	${lnbts_fqdn}	${lncel_name}
    wait until keyword succeeds    60s    15s    Activate Logged MDT

Step 4: LTE1049 Post Steps
    [Documentation]    Short description.
    Update Parameter From NetAct    inactivityTimer		    60	        ${TraceConfiguration['TraceTarget']}

LTE1049 Teardown
    [Documentation]    Short description.
    Deactivate Cell Trace	${trace_reference}
    Common TC Teardown For Trace
