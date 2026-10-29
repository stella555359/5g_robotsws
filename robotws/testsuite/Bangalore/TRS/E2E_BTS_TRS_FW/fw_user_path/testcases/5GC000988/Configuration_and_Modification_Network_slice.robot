*** Settings ***
Documentation
	...		[Procedure]				"The test case is planned to verify network slice configurations and calls with scling"
	...		[Date]					"07-10-2020"
	...		[Author]				"Madhu Chinthakindi"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		"NETWORK SLICE"
	...   	[Feature_ID]         	"5GC00988"
	...  	[Validation_status]  	"Partially Validated"
	...   	[Validated  TestLine]   "5G_9047"
	...   	[Config] 				"scf should not have any scling configurations"



Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Common_keyword_Network_slice.robot



Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND		Teardown Oamops




*** Test Cases ***
Configuration and Modification of network slice
	[Documentation]		The test case is planned to verify network slice maximum Slice configurations and calls with scling
	Perform Commissioning		timeout=900		verify_bts_status=False  	timeout=900
	sleep 	900
	Perform Call setup
	#Trigger Call and verify no network scling
	Configure maximum SNSSAI Ids and verify operationalState
	Trigger Call and verify network slicing with maximum SNSSAI configuration
	Verify SNSSAI ip rules
	Modify sclice administrativeState and verify operationalState
	Delete maximum SNSSAI Ids and verify no network scling
	[Teardown]		TeardownKeywords

*** Keywords ***
Configure maximum SNSSAI Ids and verify operationalState
	[Documentation]		The keyword create maximum slice configurations and verify operation status
	Perform Recommissioning    type=delta    delta_file=${CreateMaxSNSSAI}        timeout=600
	GetSliceIds
	FOR    ${value}    IN    @{sliceindex_list}
        GetSNSSAIDetails      ${value}
        Should be Equal		${administrativeState}	${unLocked}
	    Should be Equal		${operationalState}		${enable}
	END

Trigger Call and verify network slicing with maximum SNSSAI configuration
	[Documentation]		The keyword calls with maximum network slicing configuration
	FOR    ${value}    IN    @{sliceindex_list}
        Trigger Call and with sclice id	 ${value}
    END

Modify sclice administrativeState and verify operationalState
	[Documentation]		The keyword is to verify slice configuration with delta modification
	${NewSliceIndex}=	    random.choice      	${sliceindex_list}
	Perform Recommissioning		type=param	    		param_path=SNSSAI-${NewSliceIndex}:administrativeState	  operation=update	  value=${Locked}
	sleep  10
	GetSNSSAIDetails      ${NewSliceIndex}
	Should be Equal		${administrativeState}	${Locked}
	Should be Equal		${operationalState}		${disable}

Delete maximum SNSSAI Ids and verify no network scling
	[Documentation]		The keyword delete maximum slice configurations and verify operation status
	Perform Recommissioning    type=delta    delta_file=${DelteMaxSNSSAI}        timeout=600
	#Trigger Call and verify no network scling

Verify SNSSAI ip rules
	[Documentation]		The keyword is to verify iprules for slicing configuration
	Setup Remote Access	    remote_device=bts		alias=iprule
	FOR    ${value}    IN    @{sliceindex_list}
	    GetSNSSAIDetails      ${value}
		${iprule}=			Remote Command Execute		command=${ip_rule_cmd} | grep -i "${nGuIp}" | grep -i "2152"
		should not be empty 	${iprule}
    END
	[Teardown]    Teardown Remote Access        alias=iprule

TeardownKeywords
    Run Keyword And Ignore Error        Perform Recommissioning    type=delta    delta_file=${DelteMaxSNSSAI}        timeout=300
