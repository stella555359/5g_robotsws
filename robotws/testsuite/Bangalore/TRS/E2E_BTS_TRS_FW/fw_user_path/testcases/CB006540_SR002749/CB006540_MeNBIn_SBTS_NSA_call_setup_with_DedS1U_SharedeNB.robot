*** Settings ***
Documentation
	...		[Procedure]				"The test case is planned to Verification of flow control"
	...		[Date]					"08-15-2021"
	...		[Author]				"Madhu Chinthakindi"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		"RANSHARING"
	...   	[Feature_ID]         	"5GC001464","CB006540","SR002749"
	...  	[Validation_status]  	"Validated and Passed"
	...   	[Validated_TestLine] 	"5gSBTS_9047"
	...   	[Config] 				"cfg file varible should with given as regEx metion, refer testcases_variable.json for the same"

Variables         ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/CB006540_SR002749_Common_keywords.robot



Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND		Teardown Oamops



*** Test Cases ***
[1]TRS_CB006540_MeNB_within_SBTS_NSA_call_setup_with_dedicated_S1U_for_all_operators_in_sharedgNB_with_sharedeNB.
	[Documentation]		This test case to verify 6 operator calls with MeNB in side SBTS
	Perform Commissioning        verify_bts_status=${False}     timeout=900     alias=default
    Verify RMOD is up
	Read Ip and plmn deatils		${MeNBIn_DedS1U_SharedeNB}
	###Modified to save space and execution time and added new steps for EDA implementation [03102022]
	Trigger and verify 6 operators parallel calls with low traffic		${MeNBIn_DedS1U_SharedeNB}
	Verify X2 link status
	Verify And Retry On Attach Failure
	Verify s1U traffic
	Trigger and verify 6 operators parallel calls with high traffic

***Keywords***
Verify And Retry On Attach Failure
	${status}=  Run Keyword And Return Status  Verify attach for 6 operator
	Run Keyword If  ${status}==False  Retry Attach

Retry Attach
	Execute Cus Command		config update
	Execute Cus Command		config remote update
	Wait Until Keyword Succeeds	15 min	30 min	RMOD is Enabled
	Traffic Capture Start   capture_device=vm_any_interface     capture_filter=(${l2_capture_filter_ips})    alias=${MeNBIn_DedS1U_SharedeNB}
	Perform Call setup       ${MeNBIn_DedS1U_SharedeNB}
	Wait Until Keyword Succeeds    15 minutes    30 seconds    Verify Bts Status    req_rat=lte    should_be_onair=${True}
	Wait Until Keyword Succeeds    15 minutes    30 seconds    Verify Bts Status    req_rat=5g    should_be_onair=${True}
	Execute Call Script 	${MeNBIn_DedS1U_SharedeNB}
	${pcap_file}=       Traffic capture stop	alias=${MeNBIn_DedS1U_SharedeNB}
	Verify attach for 6 operator
	[Teardown]    Run Keyword And Ignore Error   	Traffic capture stop	alias=${MeNBIn_DedS1U_SharedeNB}

Trigger and verify 6 operators parallel calls with low traffic
    [Documentation]		This keyword to trigger 6 oprator parellal calls
	[Arguments]			${testSenario}=default
   	Set Suite Variable      ${testSenario}        ${testSenario}
	Traffic Capture Start   capture_device=vm_any_interface     capture_filter=(${l2_capture_filter_ips})    alias=${testSenario}
   	Perform Call setup       ${testSenario}
	Wait Until Keyword Succeeds    15 minutes    30 seconds    Verify Bts Status    req_rat=lte    should_be_onair=${True}
	Wait Until Keyword Succeeds    15 minutes    30 seconds    Verify Bts Status    req_rat=5g    should_be_onair=${True}
	Execute Call Script 	${testSenario}
	${pcap_file}=       Traffic capture stop	alias=${testSenario}
   	Set Suite Variable      ${pcap_file}        ${pcap_file}
	[Teardown]    Run Keyword And Ignore Error   	Traffic capture stop	alias=${testSenario}


Trigger and verify 6 operators parallel calls with high traffic
	Perform Call setup       ${MeNBIn_DedS1U_SharedeNB}
	Execute Call Script 	${multi_call_SimulateHigTraficProfile}
	Verify Alarm    	expected_alarms=${expected_alarms}

