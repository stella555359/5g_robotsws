*** Settings ***
Documentation
...		[Procedure]	"CDRT_04572591_With_Dynamic_Inner_IP"
...		[Date]		"16-04-2025"
...		[Author]	"Meghana J"
...		[Feature_ID]	"SR001941_CDRT"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"

Force Tags    CLOUD_R4P_IPSEC	CA_E2ET_BTSTRSPZ	SBTS00	RAN_4G    RAN_4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT

Resource        ${CURDIR}/resources/Common_CDRT_keywords.robot

Suite Setup                 Pre-conditions for testsuite
Suite Teardown              Post-conditions for testteardown

*** Test Cases ***
[1]CDRT_04572591_With_Dynamic_Inner_IP
	Perform Basic Commisioning
	Perform Recommissioning with Dynamic Inner IP configuration
	${alarms}        Verify Alarm
	Verify IPSec Status ESTABLISHED
	Get IKE ID Value Before Rekeying
	Verify IPSec Status after CMP Initialization
	Verify ESP SPI Before and After Rekeying
	Verify IKE and ESP SPI Before and After Rekeying
	Verify IKE ID After Rekeying
	Verify Alarm      prev_alarms=${alarms}     check_unexpected_alarms=${True}