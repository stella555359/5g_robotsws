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
Resource         taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource    	${CURDIR}/../resources/common_keywords_5999.robot
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource    	${CURDIR}/../resources/Admin_Common_Library.robot


Suite Setup       Run Keywords    Suite Setup Preconditions
        ...     AND         Setup Oamops
Suite Teardown    Run Keywords    Suite Teardown Postconditions
        ...     AND         Teardown Oamops

*** Variables ***

${base_scf}     /home/ute/Downloads/ECDSA_5999.xml

*** Test Cases ***
[1]CB005999_Verification of both IR and KUR for for ECDSA certficates
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=False     timeout=400     alias=default
    Sleep   240
	Perform Recommissioning		type=delta		delta_file=${certificate_config}		skip_parameter_relation_errors=${True}		timeout=300
	Restore all Certificate
	Read CMP Parameters     	RSA
	Tigger IR_KUR 			RSA 	install_cmp_certificate
	verify cmp status		RSA		CMP_InitializationOK
	Verify IR Operation
	Tigger IR_KUR 			RSA 	cmp_update_key
	verify cmp status		RSA		CMP_KeyUpdateOK
	Verify KUR Operation
	Read CMP Parameters 	ECDSA
    Tigger IR_KUR           ECDSA   install_cmp_certificate
    verify cmp status       ECDSA   CMP_InitializationOK
    Verify IR Operation
	Tigger IR_KUR 			ECDSA 	cmp_update_key
    verify cmp status		ECDSA	CMP_KeyUpdateOK
	Verify KUR Operation
#######IPV6 Part#######################
	Perform Recommissioning		type=delta		delta_file=${ipv6_certificate_config}  	skip_parameter_relation_errors=${True}		timeout=300
	Restore all Certificate
	Read CMP Parameters 	ECDSA
    Tigger IR_KUR           ECDSA   install_cmp_certificate
    verify cmp status       ECDSA   CMP_InitializationOK
    Verify V6IR Operation
	sleep    100
	Tigger IR_KUR 			ECDSA 	cmp_update_key
    verify cmp status		ECDSA	CMP_KeyUpdateOK
    Verify V6KUR Operation
######EDA########3
	Perform Recommissioning		type=delta		delta_file=${cmprsa_delta}		skip_parameter_relation_errors=${True}		timeout=300
    Run keyword And Expect Error	*UnboundLocalError*		Tigger IR_KUR1 		RSA     install_cmp_certificate
	Sleep   60
    verify cmp status		RSA 	CMP_InitializationFailed

    Run keyword And Expect Error  *Invalid or wrong response*  Tigger IR_KUR1      RSA     cmp_update_key
    Sleep   60
    verify cmp status       RSA     CMP_KeyUpdateFailed

	Run keyword And Expect Error	*UnboundLocalError*	   Tigger IR_KUR1 		ECDSA   install_cmp_certificate
    Sleep   60
	verify cmp status		ECDSA	CMP_InitializationFailed

    Run keyword And Expect Error  *Invalid or wrong response*  Tigger IR_KUR1      ECDSA   cmp_update_key
    Sleep   60
    verify cmp status       ECDSA   CMP_KeyUpdateFailed