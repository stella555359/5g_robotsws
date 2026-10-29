*** Settings ***
Documentation
...     [Author]        "Megha H D"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case checks the support Of E2 interface in vCU"
...     [Date]      "24-08-2023"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify SCTP association re-establishment on E2 interface"
...     [Funtion_Hash_Tags] "TRS - Security"
...     [Feature_ID]            "CB009167"
...     [Requirement ID]    "TT_TTSEC.2358"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "5376"
...     [Config]    "This testcase configuration with E2 MOC"
...     [scf_file]  "CB009167_VRAN_E2_IPSec_config"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB009167_keyword.robot

Force Tags      CA_E2ET_BTSTRSPZ        vCUCNF00      vCUCNF23R3     4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT

Suite Teardown      Collect logs in cloud


***Test Cases***
TRS_CB009167_CB007116_Configuration_SCTP_E2_Interface_Ipsec
	Perform IPsec Configuration on VM
	Configure RICSim
	Perform E2 configuration with IPSec
	Verify IPsec status and E2 link status
	Remove RICSim Configuration and verify E2 alarm
	Revertback RICSim Configuration and verify alarm is cleared
	Change RICSCTPPort and check E2 alarm with IPsec status
	Disable Ipsec and verify E2 link status
	Lock and Unlock E2 link and verify E2
	Teardown core configuration and verify E2 alarm
	[Teardown]	Keywords To Run At End
