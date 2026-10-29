*** Settings ***
Documentation
	...		[Procedure]				"TRS_5GC001464_C_Verification of MAX CRL and MAX CA configurationl"
	...		[Date]					"7-9-2020"
	...		[Author]				"Manohar KR"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		"IPSEC","RANSHARING"
	...   	[Feature_ID]         	"5GC001464"
	...  	[Validation_status]  	"Validated and Passed"
	...   	[Validated_TestLine] 	"5G_9049"
	...   	[Config] 				"NRBTS-1 need to configured with 6 x2clist"

Variables         ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/CB006540_SR002749_Common_keywords.robot


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND		Teardown Oamops


*** Test Cases ***
TRS_CB006540_Verification_of_MAXCA_configuration.
	[Documentation]		"The test case to verify Maximum CA and CRL verification"
	Perform Commissioning        verify_bts_status=${False}     timeout=400     alias=default
	Delete All Certificates
	Install max certificate and verify

TRS_CB006540_Verification_of_MAXCRL_configuration.
	Perfom MaxCLRDP delta operation and verify CRL entries

***Keywords***
Perfom MaxCLRDP delta operation and verify CRL entries
   Perform recommissioning			type=delta		delta_file=${Max_CRLH_HTTP_Config}		timeout=300
   Trigger and verify CRL update
   Run Keyword And Expect Error		${Max_CRLH_CRL_ERR}		Perform recommissioning		type=delta		delta_file=${Additiona_CRLDP_Config}

Install max certificate and verify
	Install max Additonal TA Certificates
	Install Additonal CA Certificates

Trigger and verify CRL update
	certificate configure 		operation=update_certificate_revocation_list		timeout=500
	Sleep	60
	Verify Status CRL entries

Verify Status CRL entries
	${certificate_Details}=		certificate configure 		operation=get_certificate_revocation_list
	${maxCrlentriesLen}=    Get Length    ${certificate_Details}
	Should Be Equal As Numbers    ${maxCrlLen}    ${maxCrlentriesLen}

Install Additonal CA Certificates
    FOR    ${i}    IN RANGE    0    48
        certificate configure    operation=install_certificate    cert_file=${CACertpath}@{ca_cert}[${i}]
        ...    cert_type=AdditionalCa    cert_format=PEM    timeout=200
        Sleep   10
        Log    Max additional CA Certificate Installed successfully
    END


Install max Additonal TA Certificates
    FOR    ${i}    IN RANGE    0    12
        certificate configure    operation=install_certificate    cert_file=${TACertpath}@{ta_cert}[${i}]
        ...    cert_type=AdditionalCa    cert_format=PEM    timeout=200
        Sleep   10
    END
    Log    Max additional TA Certificate Installed successfully
    Run Keyword And Expect Error    ${ma_additional_certs_err}
    ...    certificate configure    operation=install_certificate cert_file=${TACertpath}@{ta_cert}[12]    cert_type=AdditionalCa
    ...    cert_format=PEM    timeout=200

Delete All Certificates
	certificate configure    operation=restore_vendor_certificate
	Sleep 		10
	Run Keyword And Ignore Error		certificate configure    operation=delete_cert  all_certs=${True}
