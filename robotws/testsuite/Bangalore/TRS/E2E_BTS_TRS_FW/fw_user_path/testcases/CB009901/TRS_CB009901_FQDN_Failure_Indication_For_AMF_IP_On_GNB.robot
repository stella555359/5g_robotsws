*** Settings ***
Documentation
     ...    [Procedure] "TRS_CB009901_NG-C_Setup_With_AMF_Address_Configured_As_FQDN_And_IP"
     ...    [Date] "02-01-2025"
     ...    [Author] "Meghana J"
     ...    [QC_Path] "QC_Path in Test Plan"
     ...    [QC_ID] "QC_ID in Test Lab for reporting"
     ...    [Funtion_Hash_Tags] "AMF FQDN"
     ...    [Feature_ID] "CB009901"
     ...    [Validation_status] "Validated"
     ...    [Validated_TestLine] "ASOH"
     ...    [Commissioning_comment] "This script requires 5G and AMF FQDN Configuration"

Force Tags	CLOUD_R4P_IPSEC	CA_E2ET_BTSTRSPZ	SBTS00	[SBTS22R2]	PY36	RAN_4G	RAN_4G_FDD	QCD_MN_RAN	QCP_RAN_VRF	CRT

Resource		${CURDIR}/../resources/Admin_Common_Library.robot
Resource		${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB009901_common_keywords.robot

Suite Setup                     Pre-conditions for testsuite
Suite Teardown                   Post-conditions for testteardown

*** Test Cases ***
[1]TRS_CB009901_FQDN_Failure_Indication_For_AMF_IP_On_GNB
	Perform Basic Commissioning
	Perform AMF FQDN Recommissioning
	Online Modification AMF FQDN to AMF IP
	Create Wrong FQDN Check Status
	Lock and Unlock operation for AMF Administrative state
	Reboot enB And verify nglink status