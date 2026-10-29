*** Settings ***
Documentation     [PURPOSE]
Library		 ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/emil_decoder.py
...    	host_name=10.56.111.77	username=hoam-tester	password=Nokia123!
...     emil_path=C:\\\"Program Files\"\\Emil\\Emil.exe	host_name_l3dc=10.97.92.238	username_l3dc=dcapuser
...     password_l3dc=T@dmin@123	log_dir_l3dc=/sharedvolume/ntracer/_data/
Library		 ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/iphyClient.py
... 	host_ip=10.97.92.53	username=ute	password=N0kia@dmin56
#Library     taf.sbts.oam.coam.admin	WITH NAME	admin

Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/SQL.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/GUIKeywords.robot
#Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/ActivationCellTraceKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/ConnectionKeywords.robot
#Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/CellTraceAnalysisWindowKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/IPTraffic.robot
Resource	 ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/SyveCmKeywords.robot


*** Variables ***
${active_trace_before}		8
${type}						CellTrace
${trace_reference}			${-1}
@{trace_reference_list}
${mrbts_distname}
${lnbts_fqdn}
${lncel_name}
${mrbts_id}
${lnbts_id}
${lncel_id}


*** Keywords ***
RRCEarlyDataRequest Cell Trace
    [Documentation]    Short description.
	Step 1: New Trace with TCE as L3DC
	Step 2: New Trace With TCE as TraceViewer
	Step 3: Make a Call With Iphy
	Step 4: Check Traced Logs

Step 2: New Trace With TCE as TraceViewer
    [Documentation]    Short description.
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		IP_of_TCE			${EMPTY}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		Port_of_TCE			${EMPTY}
	Log Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}
	Create New LTE Activation Profile
	...     ${TraceConfiguration['CellTrace']['CellTraceBasic']['Activation_profile']}
	New Cell Trace Activation Window Is Opened
	Configure Cell Trace	${TraceConfiguration['CellTrace']}
	Check If Lncel Is Clicked And Should Be Selected	${lnbts_fqdn}	${lncel_name}
	New Cell Trace Activation Is Started
	Trace Is Activated successfully
	Append to List		${trace_reference_list}		${trace_reference}
	Log List	${trace_reference_list}

Step 1: New Trace with TCE as L3DC
    [Documentation]    Short description.
	Log Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		IP_of_TCE			10.97.92.238
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		Port_of_TCE			49151
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceBasic']}		Activation_profile	System profile
	Log Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}
	Log Dictionary	${TraceConfiguration['CellTrace']['CellTraceBasic']}
	New Cell Trace Activation Window Is Opened
	Configure Cell Trace	${TraceConfiguration['CellTrace']}
	Check If Lncel Is Clicked And Should Be Selected	${lnbts_fqdn}	${lncel_name}
	New Cell Trace Activation Is Started
	Trace Is Activated successfully
	Append to List		${trace_reference_list}		${trace_reference}
	Log List	${trace_reference_list}

Step 4: Check Traced Logs
    [Documentation]    Short description.
	Read All Calls of Trace	${trace_reference}
	Message Check Of Cell Trace		${call_list_dictionary}		${TraceConfiguration['LTE_Activation_Profile']}
	${recent_log}=	Fetch Recent Traced Log From L3DC	6
	Recent Traced Log Check		${recent_log}	${TraceConfiguration['LTE_Activation_Profile']}

Step 3: Make a Call With Iphy
    [Documentation]    Short description.
#    Reset LTE
    iphyClient.init_iphy        reset=${TRUE}
	${start_time}=	Get Current DateTime From BTS	${bts_ip}
	Set Test Variable	${start_time}
	Start IP Traffic Capturing at BTS	${bts_ip}
	${cmd}=     Catenate    SEPARATOR=
	...     ue_attach id=1 ue_eutra_capabilities=D628030300082100C1F83F07E0FFFC3062FF282008800886400C08216A
	...     7008047480003184000AEC04390A6A03AA14908000000100
	iphyClient.execute_iphy_command		detach_ue id=1
	Sleep	2s
	iphyClient.execute_iphy_command		trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
	Sleep	2s
	iphyClient.execute_iphy_command		ue_param id=1 rrc_attach_attempts=1
	Sleep	3s
	iphyClient.execute_iphy_command		ue_rrc_conn_req_param id=1 choice=default
	Sleep	3s
	iphyClient.execute_iphy_command		${cmd}
	Sleep	3s
	FOR		${index}	IN RANGE	1	30
		${cmd_output}=	iphyClient.execute_iphy_command		ue_disp id=1
		${is_idle}=		Run Keyword And Return Status	Should Match Regexp		${cmd_output}	state([\\s]+)IDLE
		Sleep	10
		Exit For Loop If	${is_idle}==${TRUE}
	END
	Should Be True	${is_idle}==${TRUE}
	iphyClient.execute_iphy_command		ue_early_data_request id=1
	Sleep	3s
	iphyClient.execute_iphy_command		detach_ue id=1
    Sleep   10
    Stop IP Traffic Capturing at BTS

Reset LTE
    [Documentation]    Short description.
#    admin.connect to	bts_host=${bts_ip}
    ${result}=      admin.get_managed_objects   SWRESETREQ_A
    ${status}=      Run Keyword And Return Status   Should Be Empty     ${result}
    Run Keyword If      ${status}==${FALSE}     Delete CMD Object
    ${result}=      admin.get_managed_objects   CMD_A
    ${status}=      Run Keyword And Return Status   Should Not Be Empty     ${result}
    Run Keyword If      ${status}==${FALSE}     Create CMD Object
    Create SWRESETREQ Object
    LTE reset Is Successful
#    admin.teardown

LTE reset Is Successful
    [Documentation]    Short description.
    wait until keyword succeeds		300s		10s         BTS is Not Onair
    wait until keyword succeeds		300s		10s         BTS is Onair

BTS is Not Onair
    [Documentation]    Short description.
    ${bts_info}=    admin.get_bts_info
    ${state}=   Set Variable    ${bts_info}[status][proceduralState]
    Should Not Be True      '${state}'=='OnAir'

BTS is Onair
    [Documentation]    Short description.
    ${bts_info}=    admin.get_bts_info
    ${state}=   Set Variable    ${bts_info}[status][proceduralState]
    Should Be True      '${state}'=='OnAir'

Delete CMD Object
    [Documentation]    Short description.
    ${parameter}=      Create List
    admin.perform_object_recommissioning
    ...     dist_name=MRBTS-${mrbts_id}/MNL-1/CMD-1
    ...     parameter=${parameter}
    ...     operation=delete

Create CMD Object
    [Documentation]    Short description.
    ${cmd_id}=      Create Dictionary    parameterName=cmdId     operation=update      value=1
    ${parameter}=      Create List     ${cmd_id}
    admin.perform_object_recommissioning
    ...     dist_name=MRBTS-${mrbts_id}/MNL-1/CMD-1
    ...     parameter=${parameter}
    ...     operation=create

Create SWRESETREQ Object
    [Documentation]    Short description.
    ${sw_reset_level}=  Create Dictionary    parameterName=swResetLevel     operation=update      value=lteReset
    ${sw_reset_req_id}=     Create Dictionary    parameterName=swResetReqId     operation=update      value=1
    ${parameter}=      Create List     ${sw_reset_level}   ${sw_reset_req_id}
    admin.perform_object_recommissioning
    ...     dist_name=MRBTS-${mrbts_id}/MNL-1/CMD-1/SWRESETREQ-1
    ...     parameter=${parameter}
    ...     operation=create
