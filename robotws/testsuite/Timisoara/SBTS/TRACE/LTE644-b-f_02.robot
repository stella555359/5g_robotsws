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
${trace_reference}			630637
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


*** Keywords ***
LTE644-b-f_02_ST_BTS Testability_PMO Trace - 6261_EFaultId_TraceConnectionFaulty
    [Documentation]    Short description.
	Step 1: Create MTRACE From NetAct
	Step 2: Trace session is Active
	Step 3: Check Fault 6261 from Monitor
	Step 4: Deactivate Trace And Check Fault 6261

LTE644-b-f_02 Setup
    [Documentation]    Short description.
    Common TC Setup For Trace
	Set Up UE	${UE1}

LTE644-b-f_02 Teardown
    [Documentation]    Short description.
    Common TC Teardown For Trace

Step 1: Import Local Plan To NETACT Then Provison
    [Documentation]    Short description.
	Update DistName In Local Plan File And Upload Plan
	...     /home/ute/trace/traceConfig/SBTS_${mrbts_id}_R4/delta_commissioning/	cellTrace_LTE644-b-f_02.xml
	Provision the plan SyVe

Step 1: Create MTRACE From NetAct
    [Documentation]    Short description.
    Create MTRACE

Step 2: Trace session is Active
    [Documentation]    Short description.
	wait until keyword succeeds		60s	5s    Trace Is Active

Step 3: Check Fault 6261 from Monitor
    [Documentation]    Short description.
	Log		Check fault 6261 is raised
	wait until keyword succeeds		180s	10s    Fault 6261 Is Active

Step 4: Deactivate Trace And Check Fault 6261
    [Documentation]    Short description.
	Log		Check if fault 6261 is cleared after trace was deactivated
	Deactivate Cell Trace	${trace_reference}
	wait until keyword succeeds		180s	10s    Fault 6261 Is Inactive

Fault 6261 Is Active
    [Documentation]    Short description.
	${alarms}=	taf.nms.netact.get_alarms		dist_name=PLMN-PLMN/MRBTS-${mrbts_id}   alias=netact_allias
	${result}=	Set Variable	${FALSE}
	FOR	${alarm}	IN	@{alarms}
		Log Dictionary	${alarm}
		${result}=	Run Keyword And Return Status	Should Contain	${alarm['additionalText3']}		6261
		Exit For Loop If		${result}==${TRUE}
	END
	Should Be True		${result}==${TRUE}

Fault 6261 Is Inactive
    [Documentation]    Short description.
	${alarms}=	taf.nms.netact.get_alarms		dist_name=PLMN-PLMN/MRBTS-${mrbts_id}   alias=netact_allias
	${result}=	Set Variable	${FALSE}
	FOR	${alarm}	IN	@{alarms}
		Log Dictionary	${alarm}
		${result}=	Run Keyword And Return Status	Should Contain	${alarm['additionalText3']}		6261
		Should Be True		${result}==${FALSE}
	END

Fault 6261 Is Visible In History
    [Documentation]    Short description.
	Log To Console	Checking Fault 6261
	${count}=	Count Fault 6261 In Alarm History
	Should Be True	${count}>0

Count Fault 6261 In Alarm History
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${count}: <description>
	Log		Count fault 6261 in alarm history
	${current_time}=	  Get NA Current Date
	${count}=	Set Variable	0

	${time_from}=	Convert Date	${start_time_str}		result_format=datetime

	${alarms}=	taf.nms.netact.get_cleared_alarms
	...     dist_name=PLMN-PLMN/MRBTS-${mrbts_id}		time_from=${time_from}		time_to=${current_time}
	...     date_format=datetime    alias=netact_allias
	FOR	${alarm}	IN	@{alarms}
		Log Dictionary	${alarm}
		${result}=	Run Keyword And Return Status	Should Contain	${alarm['additionalText3']}		6261
		${count}=	Run Keyword If	${result}==${TRUE}		evaluate	${count}+1
					...	ELSE	Set Variable	${count}
	END
	[RETURN]	${count}
