*** Settings ***
Documentation
...		[Author]				"Nandini R"
...		[Procedure]				Verify IKE and SA Rekeying
...		[Requirement ID]		WBTS_SEC_50722;WBTS_SEC_50722
...		[Feature ID]			LTE739, CB007425-5G-AB-B23
...		[Validated_TestLine]	10_2_T0401-ASIM04
...		[Config_Comments]		DualStack Configuration
...		[Funtion_Hash_Tags]		IPSEC, IKE_REKEYING, SA_REKEYING

Force Tags      CLOUD_F    CA_VRF_BLR2        SBTS00        QCD_MN_RAN       QCP_RAN_VRF        CRT

Resource        ${CURDIR}/resources/LTE739_Common_keywords.robot

Suite Setup     	LTE739 Suite Setup precondition
Suite Teardown  	LTE739 Suite Teardown Postcondition

Test Setup		Testcase precondition
Test Teardown	Testcase postcondition

*** Test Cases ***
[1][1.0] LTE739 - B Verify failedSAEstablishments counter
	Call Setup		5g=airphone_DualStack_sansa:data	parallel=${False}	verify_attach=${False}	attach=${False}		ipv4_or_6=ipv6	timeout=180
	Verify Bts Status	    should_be_onair=${True}
	Create SA Failure and Verify failedSAEstablishments Counter
	Call Teardown  5g=airphone_DualStack_sansa:data
	Remove SA Failure

#[1][1.0] AntiReplayErrors
	Duplicate and reorder downlink traffic and Verify AntiReplayErrors Counter

#[1]LTE739 - B Verify sentPacketMatchDefPol counter
	Start Ping test from Enb for Unconfigured IP and Verify sentPacketMatchDefPol counter

#[1][1.0] espCryptographicErrors
	Corrupt ESP packets sent to eNB and Verify espCryptographicErrors Counter

#[1]LTE739 - B Verify ipsecSaNotFound and recvUnprotPacketMatchProtPol counter
	Verify ipsecSaNotFound and recvUnprotPacketMatchProtPol counter

#[1][1.0] Sent and received ESP
	Send Traffic and Verify SentESP and ReceivedESP Counter

#[1][1.0] setPacketMatchDiscPol and receivedPacketMatchDiscPol
	Create Discard Policy and Verify setPacketMatchDiscPol and receivedPacketMatchDiscPol Counter

#[1][1.0] setPacketMatchBypassPol and receivedPacketMatchBypassPol
	Create Discard Policy and Verify setPacketMatchBypassPol and receivedPacketMatchBypassPol Counter