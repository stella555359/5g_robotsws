*** Settings ***
Documentation
...		[Author]				"Meghana J"
...		[Procedure]				Verify IKE and SA Rekeying
...		[Requirement ID]		WBTS_SEC_50722;TT_TTSEC.1462;TT_TTSEC.1821;WBTS_SEC_60656;WBTS_TRS_20224
...		[Feature ID]			LTE739, CB007425-5G-AB-B23
...		[Validated_TestLine]	10_2_T0401-ASOE03
...		[Config_Comments]		DualStack Configuration
...		[Funtion_Hash_Tags]		IPSEC, IKE_REKEYING, SA_REKEYING

Force Tags      CLOUD_F    CA_VRF_BLR2        SBTS00        SBTS24R2    SBTS24R3      QCD_MN_RAN       QCP_RAN_VRF        CRT

Resource        ${CURDIR}/resources/LTE739_Common_keywords.robot

Suite Setup                 Pre-conditions for testsuite
Suite Teardown              Post-conditions for testteardown

***Test case***
[1][1.0] LTE739 - A Verify ESP and IKE encryption and authentication method combinations for AES_GCM_128-256 and AES_GMAC_128-192-256 algorithms
    Perform Recommissioning     type=delta		delta_file=${ASOE_SA_NSA_DualStack_Ipsec_delta}     timeout=300
    Run	sudo cp ${SECGW_CONF} ${SECGW_BACKUP_COPY}
	Run	sudo cp ${LTE739_ipsec_conf} ${SECGW_CONF}
	Enable Ipsec on SecureGW
	Enable Ipsec on Admin
	Verify IPSEC Security Association	${Combination_2_Policy_List}
	Call Setup		5g=airphone_DualStack_sansa:data	parallel=${False}	verify_attach=${False}	attach=${False}		ipv4_or_6=ipv4
	...    timeout=300
	Sleep	200
    ${alarms}        Verify Alarm
	Choose GCM/GMAC for IKE and establish tunnel
    Get IKE SPI Value Before Rekeying		${Combination_2_Policy_List}
	Pump ingress & egress High traffic
	Verify if call is successful for ASOE       ${Point_B_Capture}
    Pump ingress & egress High traffic with high MTU
	Verify if call is successful for ASOE       ${Point_B_Capture}
    Sleep   ${max_val}
    Verify IKE Algorithm		${Combination_2_Policy_List}
    Verify ESP Algorithm		${Combination_2_Policy_List}
    Verify Alarm      prev_alarms=${alarms}     check_unexpected_alarms=${True}
	Verify IKE SPI After Rekeying		${Combination_2_Policy_List}
    Call Teardown      5g=airphone_DualStack_sansa_asoe:data
	Reboot And verify IPSEC connections