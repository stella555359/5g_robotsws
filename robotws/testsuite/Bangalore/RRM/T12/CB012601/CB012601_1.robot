*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Tom
...             :contact  : tom.toby@nokia.com

Resource        resources/Keywords/CB012601_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${BLER_TESTMODE}      	    bler
${RI_VALUES}		    SEPARATOR=
...		-88,-93,-94,-97,-98,-103,-105,-106,-107,-110,-110,-110,-115,-115,-115,-115,-115,-115,-115,-115,-115,
...		-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115
${LUA_FILE}        ${CURDIR}/resources/Keywords/scripts.lua


*** Test Cases ***
[1][1.0] CB012601_27_Verify_redirection_in_a_multi-UE_environment
    [Documentation]    CB012601_1_Verify UE redirection is successful to a diff cell due to bad uplink radio condition
    ...    1. The test covers different functionality tests associated with feature CB012601 related with
	...	      UE redirection to a different cell due to bad uplink radio conditions. The NIDD parameter
	...       'NRBTS/NRCEL/actBadUplinkRadioRedirect' is extended to support 2 new values. CB012601 feature is
    ...       enabled with redirection target cell priorities set through 'redirPrioBadUlRadio'.
    ...    2. Test Case Steps:
    ...       Step 1:Trigger Remote Interference in cell 1
    ...         Expected Results:
    ...            Remote Interference Alarm 7525 is observed in cell 1
    ...       Step 2:Register Datacall & VoNR SA UEs
    ...         Expected Results:
    ...            Multi UE registartion is successful for datacall & VoNR UEs.
    ...       Step 3:Bad Uplink radio redirect when actBadUplinkRadioRedirect='highUlBlerBased' with CB012601 enabled
    ...         Expected Results:
    ...            UE will release the UE context (with redirection) when high uplink Bler is observed.
    ...       Step 4:Bad Uplink radio redirect when actBadUplinkRadioRedirect='highUlBlerOrUlNackFloodBased'CB012601
    ...         Expected Results:
    ...       UE will release the UE context (with redirection) when high uplink Bler or UL NACK flooding is observed.
	...       Step 5:Bad Uplink radio redirect when actBadUplinkRadioRedirect='rIEventAndHighUlBlerOrUlNackFloodBased'
    ...               with CB012601 enabled
    ...         Expected Results:
    ...       UE will release the UE context (with redirection) when RI event and high uplink Bler or UL NACK flooding
    ...       is observed.
	...       Step 6: Bad Uplink radio redirect when actBadUplinkRadioRedirect='dataRimAndHubOrUnf_voNrHubOrUnf'
    ...       with CB012601. Expected Results:
    ...       Data call UE will release the UE context (with redirection) only when RI event and high uplink Bler
    ...       or UL NACK flooding is observed.
	...       VoNR UE will release UE context(with redirection) when high uplink Bler or UL NACK flooding is observed
	...       Step 7: Bad Uplink radio redirect when actBadUplinkRadioRedirect='voNrRimAndHubOrUnf_dataHubOrUnf'
    ...        with CB012601
    ...       Expected Results:
    ...        VoNR UE will release the UE context (with redirection) only when RI event and high uplink Bler
    ...        or UL NACK flooding is observed.
	...        Data call UE will release the UE context (with redirection)when high uplink Bler or UL NACK flooding
    ...            is observed.
	...       Step 8: Multi UE (Data call + VoNR UEs) redirect when cell noise introduced UL NACK flooding for all UEs
    ...         Expected Results:
    ...            All UEs in the cell will release the UE context (with redirection) as per step 7 results
	...            Verify PM counter to validate the results
    [Tags]     QC_28344   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare For Test Case CB012601
    Basic Bring Up
    Sleep   30s
    # Step 1: Remote Interference Activation in Cell 1
	Log To Console      \nStep 1: Remote Interference Activation for cell 1\n
	Pass Lua File       ${LUA_FILE}
    Setup Remote Interfernce		1		0		32		${RI_VALUES}
	Activate Cell TestMode		2		1		remote_interference     activate        1
	Wait For 2 RI Monitoring Periods
    Sleep   300s
    Pass Lua File       ${LUA_FILE}
    Check If RI Alarm Is Present
    Log To Console      \nRemote Interference Alarm 7525 is observed
	# Comment: To maintain Remote Interference alarm active for longer time 'nrRiMonitorWindow'updated maximum value
    GNB Delta Commission          ${CURDIR}/config/gnb_scf/RIM_window_modify.json
    Sleep   25s
    # Step 2: Register Datacall and VoNR SA UEs
    Log To Console      Step 2:Register Datacall and VoNR SA UEs \n
	Register Multiple SA UEs       1      6
    Pass Lua File       ${LUA_FILE}
	Register Multiple VoNR SA UEs	7		10
    Pass Lua File       ${LUA_FILE}
    wtsrunner.Ue Disp
    Pass Lua File       ${LUA_FILE}
    # Step 3: Bad Uplink radio redirect when actBadUplinkRadioRedirect='highUlBlerBased' enabled
    Log To Console      Step 3: Verifying Redirect when actBadUplinkRadioRedirect='highUlBlerBased'
	Change BaduplinkAlgo Online		1			highUlBlerBased
	Sleep   20s
    Setup UL BLER Testmode		1		405,405,405,405,405,405,405,405
	Log To Console      UL BLER activation for UE 1
    Pass Lua File       ${LUA_FILE}
    Start Pcap Collection In GNB CU     gnbTcpdump_UE_1
    Sleep   10s
	Activate UE TestMode       1      ${Bler_Testmode}    activate    1
    Sleep   10s
    wtsrunner.Ue Disp
    Pass Lua File       ${LUA_FILE}
    Stop Pcap Collection In GNB     gnbTcpdump_UE_1      ${Log_Path}
	${ngap_Context_release_cause}          Get UEcontext Release Cause
	...		/home/ute/logs/CB012601_1/gnbTcpdump_UE_1/gnbTcpdump_UE_1.pcap
	Run Keyword If    '${ngap_Context_release_cause}' == '41'
	...		Log To Console      \nUE 1 (Data call) context release caused due to redirection\n
    Sleep       5s
    # Step 4: Bad Uplink radio redirect when actBadUplinkRadioRedirect='highUlBlerOrUlNackFloodBased' enabled
    Log To Console      Step 4: Verifying Redirect when actBadUplinkRadioRedirect='highUlBlerOrUlNackFloodBased'\n
    Change BaduplinkAlgo Online		1			highUlBlerOrUlNackFloodBased
    Sleep       20s
	Setup UL BLER Testmode		2		900,900,900,900,900,900,900,900
	Log To Console      UL NACK flooding activation for UE 2
    Pass Lua File       ${LUA_FILE}
    Start Pcap Collection In GNB CU     gnbTcpdump_UE_2
    Sleep   10s
	Activate UE TestMode       2      ${Bler_Testmode}    activate    2
    Sleep   10s
    Pass Lua File       ${LUA_FILE}
    Stop Pcap Collection In GNB     gnbTcpdump_UE_2      ${Log_Path}
	${ngap_Context_release_cause}          Get UEcontext Release Cause
	...		/home/ute/logs/CB012601_1/gnbTcpdump_UE_2/gnbTcpdump_UE_2.pcap
	Run Keyword If    '${ngap_Context_release_cause}' == '41'
	...		Log To Console      \nUE 2 (Data call) context release caused due to redirection\n
    Sleep   5s
    wtsrunner.Ue Disp
    # Step 5: Bad Uplink radio redirect when
    #  actBadUplinkRadioRedirect='rIEventAndHighUlBlerOrUlNackFloodBased' with CB012601
    Log To Console      Step 5: Verify Redirect when actBadUplinkRadioRedirect='rIEventAndHighUlBlerOrUlNackFloodBased' with CB012601\n
	Activate Cell TestMode		2		1		remote_interference     activate        1
    Check If RI Alarm Is Present
    Change BaduplinkAlgo Online		1			rIEventAndHighUlBlerOrUlNackFloodBased
    Sleep       20s
	Setup UL BLER Testmode		3		900,900,900,900,900,900,900,900
	Log To Console      RI and UL NACK flooding activation for UE 3
    Pass Lua File       ${LUA_FILE}
    Start Pcap Collection In GNB CU     gnbTcpdump_UE_3
    Sleep   10s
	Activate UE TestMode       3      ${Bler_Testmode}    activate    3
    Sleep   10s
    Pass Lua File       ${LUA_FILE}
    Stop Pcap Collection In GNB     gnbTcpdump_UE_3      ${Log_Path}
	${ngap_Context_release_cause}          Get UEcontext Release Cause
	...		/home/ute/logs/CB012601_1/gnbTcpdump_UE_3/gnbTcpdump_UE_3.pcap
	Run Keyword If    '${ngap_Context_release_cause}' == '41'
	...		Log To Console      \nUE 3 (Data call) context release caused due to redirection\n
    Sleep   5s
    wtsrunner.Ue Disp
    # Step6:Bad Uplink radio redirect when actBadUplinkRadioRedirect='dataRimAndHubOrUnf_voNrHubOrUnf'CB012601 enabled
    Log To Console      Step 6: Verifying Redirect when actBadUplinkRadioRedirect='dataRimAndHubOrUnf_voNrHubOrUnf'\n
    Activate Cell TestMode		2		1		remote_interference     activate        1
    Change BaduplinkAlgo Online		1			dataRimAndHubOrUnf_voNrHubOrUnf
    Sleep       20s
	Setup UL BLER Testmode		4		405,405,405,405,405,405,405,405
	Log To Console     RI and UL BLER activation for Data call UE 4
    Pass Lua File       ${LUA_FILE}
    Check If RI Alarm Is Present
    Start Pcap Collection In GNB CU     gnbTcpdump_UE_4
    Sleep   10s
	Activate UE TestMode       4      ${Bler_Testmode}    activate      4
    Sleep   10s
    Pass Lua File       ${LUA_FILE}
    Stop Pcap Collection In GNB     gnbTcpdump_UE_4      ${Log_Path}
	${ngap_Context_release_cause}          Get UEcontext Release Cause
	...		/home/ute/logs/CB012601_1/gnbTcpdump_UE_4/gnbTcpdump_UE_4.pcap
	Run Keyword If    '${ngap_Context_release_cause}' == '41'
	...		Log To Console      \nUE 4 (Data call) context release caused due to redirection\n
	Log To Console     UL BLER activation for VoNR UE 7
    Pass Lua File       ${LUA_FILE}
    Start Pcap Collection In GNB CU     gnbTcpdump_UE_7
    Sleep   10s
	Activate UE TestMode       7      ${Bler_Testmode}    activate      4
    Sleep   10s
    Pass Lua File       ${LUA_FILE}
    Stop Pcap Collection In GNB     gnbTcpdump_UE_7      ${Log_Path}
	${ngap_Context_release_cause}          Get UEcontext Release Cause
	...		/home/ute/logs/CB012601_1/gnbTcpdump_UE_7/gnbTcpdump_UE_7.pcap
	Run Keyword If    '${ngap_Context_release_cause}' == '41'
	...		Log To Console      \nUE 7 (VoNR) context release caused due to redirection\n
    Sleep   5s
    wtsrunner.Ue Disp
    # Step 7: Bad Uplink radio redirect when actBadUplinkRadioRedirect='voNrRimAndHubOrUnf_dataHubOrUnf' with CB012601 enabled
    Log To Console      Step 7: Verifying Redirect when actBadUplinkRadioRedirect='voNrRimAndHubOrUnf_dataHubOrUnf'\n
    Activate Cell TestMode		2		1		remote_interference     activate        1
    Change BaduplinkAlgo Online		1			voNrRimAndHubOrUnf_dataHubOrUnf
    Sleep       15s
	Setup UL BLER Testmode		5		900,900,900,900,900,900,900,900
	Log To Console     RI and UL NACK flooding activation for VoNR UE 8
    Pass Lua File       ${LUA_FILE}
    Check If RI Alarm Is Present
    Start Pcap Collection In GNB CU     gnbTcpdump_UE_8
    Sleep   10s
	Activate UE TestMode       8      ${Bler_Testmode}    activate      5
    Sleep   10s
    Pass Lua File       ${LUA_FILE}
    Stop Pcap Collection In GNB     gnbTcpdump_UE_8      ${Log_Path}
	${ngap_Context_release_cause}          Get UEcontext Release Cause
	...		/home/ute/logs/CB012601_1/gnbTcpdump_UE_8/gnbTcpdump_UE_8.pcap
	Run Keyword If    '${ngap_Context_release_cause}' == '41'
	...		Log To Console      \nUE 8 (VoNR) context release caused due to redirection\n
	Log To Console     UL NACK flooding activation for Data Call UE 5
    Pass Lua File       ${LUA_FILE}
    Start Pcap Collection In GNB CU     gnbTcpdump_UE_5
    Sleep   10s
	Activate UE TestMode       5      ${Bler_Testmode}    activate      5
    Sleep   15s
    Pass Lua File       ${LUA_FILE}
    Stop Pcap Collection In GNB     gnbTcpdump_UE_5      ${Log_Path}
	${ngap_Context_release_cause}          Get UEcontext Release Cause
	...		/home/ute/logs/CB012601_1/gnbTcpdump_UE_5/gnbTcpdump_UE_5.pcap
	Run Keyword If    '${ngap_Context_release_cause}' == '41'
	...		Log To Console      \nUE 5 (Data call) context release caused due to redirection\n
    Sleep   30s
    Log To Console      \nStarting Tear Down for Test Case
