*** Settings ***
Documentation
...     [Author]        "Megha H D"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case checks the support Of E2 interface in vCU"
...     [Date]      "30-06-2023"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify SCTP association re-establishment on E2 interface"
...     [Funtion_Hash_Tags] "TRS - Security"
...     [Feature_ID]            "CB009167"
...     [Requirement ID]    "TT_TTSEC.2358"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "5376"
...     [Config]    "This testcase configuration with E2 MOC"
...     [scf_file]  "vcu.xml"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB009167_keyword.robot

Force Tags      CA_E2ET_BTSTRSPZ        vCUCNF00      vCUCNF23R3     4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT

Suite Teardown      Collect logs in cloud

***Test Cases***
TRS_CB009167_CB007116_SCTP association re-establishment on E2 interface.
	Perform IP Configuration on VM
	Configure RICSim
	Perform E2 configuration with IPV6
	Verify ipv6 E2 link status
	Modify cplane DSCP value
	Remove ipv6 RICSim Configuration and verify E2 alarm
	Reset vcu and Verify alarm persistance
	Revertback RICSim Configuration and verify alarm is cleared
	Teardown core configuration and verify E2 alarm
	[Teardown]	Keywords To Run At End
