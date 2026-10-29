*** Settings ***
Documentation
	...		[Procedure]				"TRS_5GC001464_C_Verification of MAX CRL and MAX CA configurationl"
	...		[Date]					"7-9-2020"
	...		[Author]				"Mamatha"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		"IPSEC","RANSHARING"
	...   	[Feature_ID]         	"5GC002018"
	...  	[Validation_status]  	"Validated and Passed"
	...   	[Validated_TestLine] 	"5G_9049"
	...   	[Config] 				"NRBTS-1 need to configured with 6 x2clist"

Variables         ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
#Resource        ${CURDIR}/../resources/Common_Certificate_Keywords.robot


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND		Teardown Oamops


*** Test Cases ***
[1]TRS_Transport Separation for 6 operators with Max CA Configuration_5GC002018
	[Documentation]		"The test case to verify Maximum CA and CRL verification"


#Default configaration bringup
    sleep   5
#	Perform Commissioning       scf_file=${default_Comm_file}       verify_bts_status=False		timeout=900
	Sleep	1000

#Maximum CA configaration
    Install Additonal CA Certificates
	Sleep   5
    Delete Additional CA Certificates
	Check for extra CA addition
	[Teardown]		Keywords To Run At End

*** Keywords ***

Keywords To Run At End
#	Restore Vendor Certificates
	Delete All AdditionalCa
#	Perform Commissioning       scf_file=${default_Comm_file}       verify_bts_status=False		timeout=900

Install Root Certificates
    certificate configure    operation=install_certificate    cert_file=${ta_1}	cert_type=BtsTrustChain	cert_format=P12
    ...      password=${password}	timeout=200
    Sleep 20
    Log    Certificate Installed successfully

Install Additonal CA Certificates
	FOR	${i}	IN RANGE	1	61
		certificate configure    operation=install_certificate    cert_file=${ca_cert${i}}	cert_type=AdditionalCa	cert_format=PEM
	    ...     timeout=200
		Sleep   1
 		Log    TA Certificate Installed successfully
 	END

Check for extra CA addition
	Run Keyword And Expect Error				*AdminApiProcedureFailureException	certificate configure
	...         operation=install_certificate    cert_file=${ca_cert61}	cert_type=AdditionalCa	cert_format=PEM	      timeout=200
	Sleep   1
	Run Keyword And Expect Error   	   AdminApiProcedureFailureException* 		Add Additional cert in Admin		${ca_cert61}
	...         AdditionalCa	PEM
#	Run Keyword And Expect Error    AdminApiProcedureFailureException*

Add Additional cert in Admin
	[Arguments]		${cert_file}		${type}		${format}		${password}=None
	certificate configure    operation=install_certificate    cert_file=${cert_file}	cert_type=${type}	cert_format=${format}
    ...      password=${password}	timeout=200

Delete Additional CA Certificates
#    Log    Certificate Deleted Successfully
	Run Keyword And Ignore Error    certificate configure    operation=delete_cert  all_certs=${True}

Delete All AdditionalCa
	Run Keyword And Ignore Error    certificate configure    operation=delete_cert  all_certs=${True}
	Log    Certificate Deleted Successfully
