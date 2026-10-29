*** Settings ***
Documentation
     ...    [Procedure] "The test case is planned to validate M-PlaneIPv4 Ipsec tunnel established with expired SeGW certificate"
     ...    [Date] "30-09-2024"
     ...    [Author] "Meghana J"
     ...    [QC_Path] "QC_Path in Test Plan"
     ...    [QC_ID] "QC_ID in Test Lab for reporting"
     ...    [Funtion_Hash_Tags] "IPSEC with backup ipsec enable"
     ...    [Feature_ID] "CB009741"
     ...    [Validation_status] "Validated"
     ...    [Validated_TestLine] "ASIB"
     ...    [Commissioning_comment] "This script requires 5G configuration with IPSEC Enabled."

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB009901_common_keywords.robot

Suite Setup                 Pre-conditions for testsuite
Suite Teardown              Post-conditions for testteardown

*** Test cases ***
[1]TRS_CB009901_NG-C_Setup_With_AMF_Address_Configured_As_FQDN_IPv4_v6
	Preconditions
    Perform AMF FQDN Commissioning
	Verify AMF FQDN IP Address Resolved
	Online Modification with Different AMF FQDN
	Modification with Wrong AMF FQDN
	Lock and unlock SERVEDAMF administrative state
	Postconditions
    [Teardown]  Teardown Ems        config_device=netact1       alias=lab2006_omc_user