*** Settings ***
Documentation
	...		[Procedure]				"The test case is planned to Verification network slicing with SBR and plane ip configuration"
	...		[Date]					"07-10-2020"
	...		[Author]				"Madhu Chinthakindi"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		"SBR","Slice"
	...   	[Feature_ID]         	"5GC00988"
	...  	[Validation_status]  	"Not validated"
	...   	[Planned TestLine] 		"5G_9047"


Variables     ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Common_keyword_Network_slice.robot


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND		Teardown Oamops


*** Test Cases ***
IPsec tunnel for Network slice mutual isolation
	[Documentation]		"The test case is planned to Verification network slicing with SBR and plane ip configuration"
	Perform Commissioning 	 scf_file=${scf_plain_configuration} 	timeout=900
	Trigger Random network slice call
	Perform Commissioning 	 scf_file=${scf_SBR_configuration} 		timeout=900
	Trigger Random network slice call
	Trigger Random network slice call		ipv6
*** Keywords ***
Trigger Random network slice call
	[Documentation]		"This keyword is to genarate a random value and verify calls with sclicing"
	[Arguments]         ${ipv4_ipv6}=ipv4
	GetSliceIds
	${NewSliceIndex}=	    random.choice      	${sliceindex_list}
	GetSNSSAIDetails		${NewSliceIndex}
	Trigger Call and with sclice id		${NewSliceIndex}	${ipv4_ipv6}
