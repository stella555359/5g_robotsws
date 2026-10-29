*** Settings ***
Documentation
...		[Author]     		        "Pranitha"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "30:05:2022"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB005999"
...     [Validated_TestLine]        "KVM58-TRSIV-TL3297"
...		[Procedure]   		        "CB005999_Verification of both IR and KUR for for ECDSA certficates"
...     [Precondition]              "ASIB + ASIB hardware is required"
...     [Config]    	            "CRLH-1 param should be configured in SCF"
...     [Function_Hash_Tags]        "ECDSA, RSA, Certificates, CMP Configuration"


variables       ta_e2e_bts_trs_fw
Resource    	${CURDIR}/resources/common_keywords_6285.robot
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource    	${CURDIR}/../resources/Admin_Common_Library.robot

Suite Setup       Run Keywords    Suite Setup Preconditions
        ...     AND         Setup Oamops
Suite Teardown    Run Keywords    Suite Teardown Postconditions
        ...     AND         Teardown Oamops
*** Test Cases ***
[1][1.0] CB006285 Verification of CMP IR and KUR trigger operations.
	Perform Recommissioning		type=delta		delta_file=${certificate_config}		skip_parameter_relation_errors=${True}		timeout=300
	Restore all Certificate
	Read CMP Parameters     	RSA
	Tigger IR_KUR 			RSA 	install_cmp_certificate
	verify cmp status		RSA		CMP_InitializationOK
	Verify IR Operation
	Tigger IR_KUR 			RSA 	cmp_update_key
	verify cmp status		RSA		CMP_KeyUpdateOK
	Verify KUR Operation