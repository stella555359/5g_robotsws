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
${UE1}			SONY_XZ2
${UE2}			Nokia_8.3_5G
#${UE2}			Nokia_8
# port 16: 22261
# port 9: 10673
# port 10: 22262
${source_cell_port}=	16	# PA port which source CELL connected to
${target_cell_port}=	9	# PA port which target CELL connected to


*** Keywords ***
LTE644_01_ST_Subscriber and Equipment Trace Session Start and stop_Handover
    [Documentation]    Short description.
	Step 1: pre-condition
	Step 2: Trigger Handover
	Step 3: Analysis Each Call		${TraceConfiguration}		1
	Step 4: Post Steps

LTE644_01 Setup
    [Documentation]    Short description.
    Log to Console      ${EMPTY}
	log to console      Setup for LTE644
	Common TC Setup For Trace
	Set Up UE	${UE2}
    CommonKeywords.Log to console with time    Test set up finished.

Step 1: pre-condition
    [Documentation]    Short description.
	CommonKeywords.Log to console with time	Disable Discard Unkown Subscriber Trace
	Clear Exist Trace From Trace Viewer
	wait until keyword succeeds    180s    2s 		Disable Discard Unkown Subscriber Trace
	CommonKeywords.Log to console with time	Enable feature flags.
	Update Parameter From NetAct    actSubscriberTrace	    ${TRUE}     MRBTS-${mrbts_id}/LNBTS-${lnbts_id}
	Update Parameter From NetAct    extUeTraceRep           ${FALSE}	MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/CTRLTS-1
	Update Parameter From NetAct    actCellTraceWithIMSI    ${TRUE}		MRBTS-${mrbts_id}/LNBTS-${lnbts_id}
	Update Parameter From NetAct    inactivityTimer		    60	        ${TraceConfiguration['TraceTarget']}
	CommonKeywords.Log to console with time	Enable feature flags complete.

Step 1: Activate Subscriber Trace
    [Documentation]    Short description.
	Activate Subscriber Trace On Given Ne With Imsi		${TraceConfiguration}
	Trace Is Activated successfully
	Set To Dictionary	${TraceConfiguration}			TraceReference		${trace_reference}
	Append to List		${trace_list}		${TraceConfiguration}
	Log		${trace_list}
	Append to List		${trace_reference_list}		${trace_reference}
	Log List	${trace_reference_list}

Step 3: Analysis Each Call
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${TraceConfiguration}: <description>
    ...        ${calls_count}: <description>
	[Arguments]		${TraceConfiguration}		${calls_count}=2
	${call_list}=	Read All Calls of Trace		${TraceConfiguration['TraceReference']}
	...     close_trace_analysis=${TRUE}	calls_count=${calls_count}	trace_type=subscriber trace
	${len}=		Get Length		${call_list}
	Should Be True	${len}>=${calls_count}
	FOR		${call}		IN	@{call_list}
		${HandoverRequest_msg}=	Fetch Messages From Call	${call}		HandoverRequest
		${len}=		Get Length		${HandoverRequest_msg}
		Exit For Loop If	${len}>0
	END
	Log List		${HandoverRequest_msg}
	Should Not Be Empty		${HandoverRequest_msg}

	FOR		${call}		IN	@{call_list}
		${PathSwitchRequestAcknowledge_msg}=	Fetch Messages From Call	${call}		PathSwitchRequestAcknowledge
		${len}=		Get Length		${PathSwitchRequestAcknowledge_msg}
		Exit For Loop If	${len}>0
	END
	Log List	${PathSwitchRequestAcknowledge_msg}
	#Should Not Be Empty		${PathSwitchRequestAcknowledge_msg}

Step 4: Post Steps
    [Documentation]    Short description.
	Log		Delete the trace in case of next round running of the case.
	Delete Subsriber Trace		${TraceConfiguration['TraceReference']}
	Update Parameter From NetAct    actMDTSubscriberTrace	${FALSE}    MRBTS-${mrbts_id}/LNBTS-${lnbts_id}
	Update Parameter From NetAct    actSubscriberTrace		${FALSE}    MRBTS-${mrbts_id}/LNBTS-${lnbts_id}
	Run Keyword If	${trace_reference}>0
		...	Deactivate Subscriber Trace		${trace_reference}

List Connections
    [Documentation]    Short description.
	${connections}=	Get Connections
	FOR ${connection}	IN	@{connections}
		Log		${connection.host}
	END

Activate Trace
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${TraceConfiguration}: <description>
	[Arguments]		${TraceConfiguration}
	New Cell Trace Activation Window Is Opened
	Configure Cell Trace	${TraceConfiguration['CellTrace']}
	Check If Lncel Is Clicked And Should Be Selected	${lnbts_fqdn}	${lncel_name}
	New Cell Trace Activation Is Started
	#All Trace Activation Operations Should Start
	Trace Is Activated successfully
	Set To Dictionary	${TraceConfiguration}			TraceReference		${trace_reference}
	Append to List		${trace_list}		${TraceConfiguration}
	Log		${trace_list}
	Append to List		${trace_reference_list}		${trace_reference}
	Log List	${trace_reference_list}

Clear Exist Trace From Trace Viewer
    [Documentation]    Short description.
	CommonKeywords.Log to console with time	Clear Exist Trace From Trace Viewer
	${tcpdump_pid}		${traffic_file_name}=		Start IP Traffic Capturing at BTS	${bts_ip}
	Attach UE And Start Traffic		UE_alias=UE1	required_ue=${UE2}
	Detach UE And Stop Traffic	UE_alias=UE1
	Stop IP Traffic Capturing at BTS
	Get Trace Reference From S1 Messages
	Delete Subsriber Trace		${TraceConfiguration['TraceReference']}

Make Call With Android UE And Trigger Handover
    [Documentation]    Short description.
	Log		Make a call and trigger handover
	CommonKeywords.Log to console with time	Make a call and trigger handover
	Run Keyword And Ignore Error		Stop IP Traffic Capturing at BTS
	${tcpdump_pid}		${traffic_file_name}=		Start IP Traffic Capturing at BTS	${bts_ip}
	PaClient.set_port_value		port=${target_cell_port}	value=120
	PaClient.set_port_value		port=${source_cell_port}	value=0
	Attach UE And Start Traffic		UE_alias=UE1	required_ue=${UE2}
	PaClient.set_port_value		port=${target_cell_port}	value=0
	PaClient.auto_set_port_value	port=${source_cell_port}	startValue=0	endValue=90	step=1	interval=0.4
	PaClient.set_port_value		port=${source_cell_port}	value=120
	#Attach UE And Start Traffic		UE_alias=UE1	required_ue=${UE1}
	PaClient.set_port_value		port=${source_cell_port}	value=0
	PaClient.auto_set_port_value	port=${target_cell_port}	startValue=0	endValue=90	step=1	interval=0.4
	Detach UE And Stop Traffic	UE_alias=UE1
	Stop IP Traffic Capturing at BTS
	Handover is Successful
	CommonKeywords.Log to console with time	Trigger handover complete

Handover is Successful
    [Documentation]    Short description.
    ${cmd}=     Catenate    SEPARATOR=${SPACE}
	...     tshark -r \"${Test Results Dir}\"/${traffic_file_name} -Y
	...     "x2ap.procedureCode == 0" -T pdml| grep -i handoverrequestacknowledge | wc -l
	${count}=	Run	    ${cmd}
	Should Be True	${count}>0

Trace is Activated at MME
    [Documentation]    Short description.
#	Log		id-TraceActivation shoud be found in InitialContextSetupRequest messagse.
#	...     Ids in same hierarchy: id-MME-UE-S1AP-ID/id-eNB-UE-S1AP-ID/
#	...     id-uEaggregateMaximumBitrate/id-E-RABToBeSetupListCtxtSUReq/
#	...     id-UESecurityCapabilities/id-SecurityKey/id-TraceActivation/
#	...     id-HandoverRestrictionList/id-SubscriberProfileIDforRFP/
#	...     id-SRVCCOperationPossible/id-RegisteredLAI/id-Masked-IMEISV
	CommonKeywords.Log to console with time	Verifing if trace is activated at MME

    ${file}=    Set Variable   \"${Test Results Dir}\"/${traffic_file_name}
	${count}=	Run
	...     tshark -r ${file} -Y "s1ap.procedureCode == 9" -T pdml| grep -i id-TraceActivation|wc -l
	Run Keyword If		${count}<=0
		...	Log		id-TraceActivation Not found in InitialContextSetupRequest messagse. Pls check config in MME or HSS
	Should Be True	${count}>0
	CommonKeywords.Log to console with time	Trace is Activated at MME

Get Trace Reference From S1 Messages
    [Documentation]    Short description.
	Log		Get Trace Reference From S1 Messages
	#${msg}=		Run		tshark -r \"${Test Results Dir}\"/s1ap.pcap -Y "s1ap.procedureCode == 9" -T pdml |
	#...    grep -i "s1ap.E_UTRAN_Trace_ID.TraceID"
	${file}=  Set Variable    \"${Test Results Dir}\"/${traffic_file_name}
	${msg}=		Run
	...     tshark -r ${file} -Y "s1ap.procedureCode==9" -T pdml|grep -i "s1ap.E_UTRAN_Trace_ID.TraceID"
	${traceIDs}=		Get Regexp Matches	${msg}	value="([\\d]+)"	1
	${traceIDs_len}=	Get Length		${traceIDs}
	${count}=	Get Match Count		${traceIDs}		${traceIDs}[0]
	Log		All the trace ids should same in case of there is other UEs are attached to cell.
	Should Be True	${traceIDs_len}==${count}
	${traceID}=		Convert To Integer	${traceIDs}[0]
	${trace_reference}=		Convert To String	${traceID}
	Set To Dictionary	${TraceConfiguration}			TraceReference		${trace_reference}
	Log		${TraceConfiguration}
	CommonKeywords.Log to console with time	Trace reference read from S1 message: ${trace_reference}

Step 2: Trigger Handover
    [Documentation]    Short description.
	#Make Call With Android UE And Trigger Handover
	Wait Until Keyword Succeeds		300s	10s		Make Call With Android UE And Trigger Handover
	Trace is Activated at MME
	Get Trace Reference From S1 Messages

LTE644_01 Teardown
    [Documentation]    Short description.
	Common TC Teardown For Trace
