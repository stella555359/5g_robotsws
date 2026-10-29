*** Settings ***
Documentation
	...		[Procedure]				"The test case is planned to Verification of IPsec tunnel for Network slice mutual isolation"
	...		[Date]					"07-10-2020"
	...		[Author]				"Madhu Chinthakindi"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		"IPSEC"
	...   	[Feature_ID]         	"5GC00988"
	...  	[Validation_status]  	"Partially validated"
	...   	[Validated TestLine] 	"5G_9047"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Common_keyword_Network_slice.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND		Teardown Oamops


*** Test Cases ***
IPsec tunnel for Network slice mutual isolation
	[Documentation]		The test case is planned to Verification of IPsec tunnel for Network slice mutual isolation
	Preconditions
	Perform Commissioning		timeout=900
	Trigger Call and verify slicing with ipsec

*** Keywords ***

Preconditions
	[Documentation]		This test case keyword is to install ipsec  certificate
	Certificate Configure    operation=install_certificate    cert_file=${valid_ipsec_cert} 	cert_type=BtsTrustChain 	cert_format=P12
	...         password=${valid_ipsec_cert_password}

Trigger Call and verify slicing with ipsec
	GetSliceIds
	${NewSliceIndex}=	    random.choice      	${sliceindex_list}
	GetSNSSAIDetails		${NewSliceIndex}
	Generate Esp Sa Key File		wireshark_host=wireshark_host
	Trigger Call and with sclice id		${NewSliceIndex}
