*** Settings ***
Documentation
    ...     [Procedure]             "The test case is planned to verify CRL with manually and auto download"
    ...     [Date]                  "14-08-20"
    ...     [Author]                "Madhu Chinthakindi"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "CMP,CRL"
    ...     [Feature_ID]            "RP0001344"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "3248"
    ...     [Config]    	        "CRLDPCONFIG-1 param should be configured in SCF"
    ...     [Dependent files]       "CRLH_HTTP_Config.xml,CreateCRLDPConfig.xml"



variables         ta_e2e_bts_trs_fw
Resource         taf/rfrl/trs_e2e_fw/setup/framework.robot
Library           Collections
Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/../resources/Admin_Common_Library.robot
Library           SSHLibrary
Resource    	${CURDIR}/resources/common_keywords_6285.robot


Suite Setup       Run Keywords    Suite Setup Preconditions
        ...     AND         Setup Oamops
Suite Teardown    Run Keywords    Suite Teardown Postconditions
        ...     AND         Teardown Oamops

*** Test Cases ***
[1][1.0] CB006285 Verification of CRL update failure alarm for all CRL failures.
	Perform Recommissioning		type=delta		delta_file=${certificate_config_crl}		skip_parameter_relation_errors=${True}		timeout=300
   	Restore all Certificate
    Get mplaneIP
    Read CMP Parameters     RSA
    Tigger IR_KUR           RSA   install_cmp_certificate
    verify cmp status       RSA   CMP_InitializationOK

	Perform additional CA certificate operation and verify CRL update
    Perform CMP initialization and verify CRL update
    Perform CMP Keyupdate and verify CRL update
    Perform CRLDP Update and check for dirrerent CRL check failures