*** Settings ***
Documentation
...		[Author]				"Nandini R"
...		[Procedure]				Verify IKE and SA Rekeying
...		[Requirement ID]		WBTS_SEC_50722;TT_TTSEC.1462;TT_TTSEC.1821;WBTS_SEC_60656;WBTS_TRS_20224
...		[Feature ID]			LTE739, CB007425-5G-AB-B23
...		[Validated_TestLine]	10_2_T0401-ASIM04
...		[Config_Comments]		DualStack Configuration
...		[Funtion_Hash_Tags]		IPSEC, IKE_REKEYING, SA_REKEYING

Force Tags      CLOUD_F    CA_VRF_BLR2        SBTS00        SBTS24R2    SBTS24R3      QCD_MN_RAN       QCP_RAN_VRF        CRT

Resource        ${CURDIR}/resources/LTE739_Common_keywords.robot

Suite Setup     	LTE739 Suite Setup precondition
Suite Teardown  	LTE739 Suite Teardown Postcondition

***Test case***
[1]LTE739 - A Verify ESP and IKE encryption and authentication method combinations - 1

#Step 1-2
	Call Setup		5g=airphone_DualStack_sansa:data	parallel=${False}	verify_attach=${False}	attach=${False}		ipv4_or_6=ipv4	timeout=300
    Sleep   120

#Step 3-5
    ${alarms}        Verify Alarm
	Choose algorithm and establish tunnel       ${Algorithm_PFS_File}       false
	Get IKE SPI Value Before Rekeying
	Start Ingress&Egress High traffic
    Verify Alarm      prev_alarms=${alarms}     check_unexpected_alarms=${True}
	Sleep	${max_val}
    Verify IKE Algorithm
    Verify ESP Algorithm

#Step 6 : wait for rekeying
	Verify IKE SPI After Rekeying

#Step 7
    Call Teardown      5g=airphone_DualStack_sansa:data
    Run     sudo killall egate edaemon
	Reboot enB And verify IPSEC connections

#Step 8
 	Disable Ipsec on Admin
	Change Ipsec conf file in VM to enable PFS
	Choose algorithm and establish tunnel       ${Algorithm_PFS_File}       true
	Get IKE SPI Value Before Rekeying
	Sleep       ${max_val}
    Verify IKE Algorithm
    Verify ESP Algorithm
	Verify IKE SPI After Rekeying
	Verify PFS DH Algorithm to be same as opted in BTS
	Reboot enB And verify IPSEC connections