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

Variables        ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/CB006540_SR002749_Common_keywords.robot


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND		Teardown Oamops


*** Test Cases ***
[1]TRS_CB006540_MeNB_outside_SBTS_NSA_call_setup_with_shared_S1U_for_all_operators_in_sharedgNB_with_sharedeNB.
	[Documentation]		This test case to verify 6 operator calls with common enb configured  out side for shared S1U ips configured for 5g
	Perform Commissioning        verify_bts_status=${False}     timeout=400     alias=default
	Verify RMOD is up
	Read Ip and plmn deatils		${MeNBOut_SharedS1U_SharedeNB}
	Trigger and verify 6 operators parallel calls	 ${MeNBOut_SharedS1U_SharedeNB}
	Verify And Retry On Attach Failure	${MeNBOut_SharedS1U_SharedeNB}
	Verify s1U traffic

