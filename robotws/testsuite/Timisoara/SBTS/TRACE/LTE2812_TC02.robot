*** Settings ***
Documentation     [PURPOSE]
Library		 ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/emil_decoder.py
... 	host_name=10.56.111.77	username=hoam-tester	password=Nokia123!
...     emil_path=C:\\\"Program Files\"\\Emil\\Emil.exe	host_name_l3dc=10.97.92.238	username_l3dc=dcapuser
...     password_l3dc=T@dmin@123	log_dir_l3dc=/sharedvolume/ntracer/_data/
Library		 ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/iphyClient.py
... 	host_ip=10.97.92.53	username=ute	password=N0kia@dmin56

Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/SQL.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/GUIKeywords.robot
#Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/ActivationCellTraceKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/ConnectionKeywords.robot
#Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/CellTraceAnalysisWindowKeywords.robot
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


*** Keywords ***
LTE2812_TC02_RCEF_reporting_with_TraceOnly_via_TraceViewer_and_TCE_as_L3DC_and_traceRrcSetting_as_all
    [Documentation]    Short description.
	Step 1: New Cell Trace via Trace Viewer with TCE as L3DC
	Step 2: Make a Call With Iphy For LTE2812 TC02
	Step 3: Check Traced Log In L3DC with actRCEFReporting ${true}
	Update actRCEFReporting to false via CM Editor
	Step 5: Make a Call With Iphy For LTE2812 TC02
	step 6: Check Traced Log In L3DC with actRCEFReporting ${false}

LTE2812 Setup
    [Documentation]    Short description.
    Log to Console      ${EMPTY}
	log to console      Setup for LTE2812
	Set To Dictionary	${TraceConfiguration}   TraceTarget     MRBTS-22264/LNBTS-22264/LNCEL-1
	Log Dictionary      ${TraceConfiguration}
	Set Test Variable   ${original_target}     ${TraceConfiguration}[TraceTarget]
	Set Test Variable   ${bts_ip_temp}     ${bts_ip}
	Trace Target Check
	Set Test Variable   ${bts_ip}   10.97.92.213
	Common TC Setup For Trace
	admin.reset_site
    Run Keyword And Ignore Error    Delete CTRLTS Object
    Run Keyword And Ignore Error    Create CTRLTS Object
    start ip capture file with admin
    Log Variables
	init_iphy	reset=${FALSE}
	Update actRCEFReporting to true via CM Editor
	${trace_before}=    Run Sql Statement
	...     SELECT count(*) FROM TRC.COR_TRACE_HEADER WHERE TRACE_TARGET LIKE '%${lnbts_id}%'
	set test variable	${trace_before}
    log to console    Test set up finished.

Step 1: New Cell Trace via Trace Viewer with TCE as L3DC
    [Documentation]    Short description.
	Log Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		IP_of_TCE			10.97.92.238
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}		Port_of_TCE			49151
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceBasic']}		Activation_profile	System profile
	Set To Dictionary	${TraceConfiguration['CellTrace']['CellTraceBasic']}		Job_type			Trace only
	Log Dictionary	${TraceConfiguration['CellTrace']['CellTraceAdvanced']}
	Log Dictionary	${TraceConfiguration['CellTrace']['CellTraceBasic']}
	New Cell Trace Activation Window Is Opened
	Configure Cell Trace	${TraceConfiguration['CellTrace']}
	Check If Lncel Is Clicked And Should Be Selected	${lnbts_fqdn}	${lncel_name}
	New Cell Trace Activation Is Started
	Trace Is Activated successfully
	Append to List		${trace_reference_list}		${trace_reference}
	Log List	${trace_reference_list}

Step ${index}: Make a Call With Iphy For LTE2812 TC02
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
	Log		Make a call with iphy
    ${start_time}=	Get Current DateTime From BTS	${bts_ip}
	Set Test Variable	${start_time}
	${cmd}=     Catenate    SEPARATOR=${SPACE}
	...     ue_conn_est_fail_report_info id=2 failed_cell_ecgi=262:03|1234567 reporting=1 failed_cell_rsrp=1
	...     failed_cell_rsrq=2 num_of_preambles_sent=50 time_since_failure=500
	...     basic_fields=contention_detected,max_tx_power_reached neigh_meas_list=eutran

	iphyClient.execute_iphy_command		detach_ue id=2
    iphyClient.execute_iphy_command	    ${cmd}
	iphyClient.execute_iphy_command		ue_attach id=2
	iphyClient.execute_iphy_command		detach_ue id=2

Step ${index}: Check Traced Log In L3DC with actRCEFReporting ${actRCEFReporting}
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    ...        ${actRCEFReporting}: <description>
    Sleep    120s
	${recent_log}=	Fetch Recent Traced Log From L3DC	2
	${result}	${MessageBody}=	Is Message In Recent Traced Log		${recent_log}	rrcConnectionSetupComplete-r8
	Should Be True		${result}==${TRUE}
	Should Contain		${MessageBody}		connEstFailInfoAvailable-r11 true
	${result}	${MessageBody_UeInformationRequest}=	Is Message In Recent Traced Log
	...     ${recent_log}	ueInformationRequest-r9
	Should Be True	${result}==${actRCEFReporting}
	${result}	${MessageBody_UeInformationResponse}=	Is Message In Recent Traced Log
	...     ${recent_log}	ueInformationResponse-r9
	Should Be True	${result}==${actRCEFReporting}
	Run Keyword If	${actRCEFReporting}==${TRUE}
	...	Run Keywords
		...	Should Contain	${MessageBody_UeInformationRequest}		connEstFailReportReq-r11 true
		...	AND	Should Contain	${MessageBody_UeInformationResponse}	connEstFailReport-r11

Update actRCEFReporting to ${actRCEFReporting} via CM Editor
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${actRCEFReporting}: <description>
	Update Parameter From NetAct	actRCEFReporting
	...     ${actRCEFReporting}		MRBTS-${mrbts_id}/LNBTS-${lnbts_id}

LTE2812 Teardown
    [Documentation]    Short description.
	Log List	${trace_reference_list}
	Deactivate Cell Traces	${trace_reference_list}
    Common TC Teardown For Trace
    Set To Dictionary	${TraceConfiguration}   TraceTarget     ${original_target}
    Log Dictionary      ${TraceConfiguration}
    Set Test Variable   ${bts_ip}   ${bts_ip_temp}
    Trace Target Check
