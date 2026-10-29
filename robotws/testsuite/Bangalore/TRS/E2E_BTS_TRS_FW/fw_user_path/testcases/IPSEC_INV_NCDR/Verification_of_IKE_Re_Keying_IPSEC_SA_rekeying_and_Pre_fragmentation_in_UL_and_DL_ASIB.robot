*** Settings ***
Documentation
...		[Author]     			"Santoshkumar"
...		[Maintenance]			"TRS I & V Tools Bangalore Team"
...		[Date] 					"05:10:2023"
...		[QC_Path]               "QC_Path in Test Plan"
...		[QC_ID]					"QC_ID in Test Lab for reporting"
...		[Feature_ID] 			"NCDR"
...		[Procedure]   			"IPSEC_NCDR_INV"
...     [Validated_TestLine]    "IV_BLR_TL001"
...     [Precondition]          "ASIB+ABIL+ABIA"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/IPSEC_NCDR_common_keywords.robot
#Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot

Suite Setup                 Pre-conditions for testsuite
Suite Teardown              Post-conditions for testteardown

***Test Cases***
[1]Verification_of_IKE_Re_Keying_and_IPSEC_SA_rekeying_and_Pre_fragmentation_in_UL_and_DL_ASIB
	Perform BASIC Commisioning
	Perform IPSEC Recommisioning
	Verify Ipsec Tunnels Status
	Verify BTS on Air status
	Upgrade to target build and verify the status
	Verify Ipsec Tunnels Status
	${alarms}=    Verify Alarm
	Pm Counters Start		analysis=Send_and_Rcv_ESP_Counters		counter_analysis_file=${counter_analysis_file}		pm_interval=5
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=True    timeout=120
	Attach UE and send traffic
	Sleep	300
	Stop Traffic
	${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120
    ${ESP_UL}=		Analyse Pcap    pcap_filename=${Point_B_Capture}        analysis=ESP_UL
    ${ESP_DL}=		Analyse Pcap    pcap_filename=${Point_B_Capture}        analysis=ESP_DL
	Verify Pm Counters		analysis=Send_and_Rcv_ESP_Counters		counter_analysis_file=${counter_analysis_file}		pm_interval=5
	Verify Alarm    faultid=4590    should_exist=${False}
    Verify Alarm    faultid=7504    should_exist=${False}
	Verify Alarm      prev_alarms=${alarms}     check_unexpected_alarms=${True}
	Wait Until Keyword Succeeds   300 sec   20 sec    Verify Established Tunnels   647
	Mplane ping test
	IPsec Disable and Enable
	Modify IPSEC configuration and check for tunnel status
	Send Traffic and Verify SentESP and ReceivedESP Counter
	Duplicate and reorder downlink traffic and Verify AntiReplayErrors Counter
	Corrupt ESP packets sent to eNB and Verify espCryptographicErrors Counter
	Verify ipsecSaNotFound and recvUnprotPacketMatchProtPol counter
	Create Bypass Policy and Verify setPacketMatchBypassPol and receivedPacketMatchBypassPol Counter
	Start Ping test from Enb for Unconfigured IP and Verify sentPacketMatchDefPol counter
	Create Discard Policy and Verify setPacketMatchDiscPol and receivedPacketMatchDiscPol Counter
	Create SA Failure and Verify failedSAEstablishment
	ETHIF Counter Verification
	ETHLK Counter Verification
	Send Pre fragmented traffic and Verify traffic
    Send Post fragmented traffic and Verify traffic
	Jumbo frame verification