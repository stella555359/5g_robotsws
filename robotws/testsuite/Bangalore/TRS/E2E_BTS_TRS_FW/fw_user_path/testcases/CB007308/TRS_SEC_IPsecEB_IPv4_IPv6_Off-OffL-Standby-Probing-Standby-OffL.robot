*** Settings ***
Documentation
...		[Author]				"Nandini R"
...		[Procedure]				Verify IPsec Emergency Bypass
...		[Requirement ID]		WBTS_SEC_51673
...		[Feature ID]			CB007421-SR-I-B1
...		[Validated_TestLine]	10_2_T0401-ASOE03
...		[Config_Comments]		DualStack Configuration
...		[Funtion_Hash_Tags]		IPSEC, IPSEC_EMERGENCY_BYPASS

Force Tags      CLOUD_F    CA_VRF_BLR2        SBTS00      QCD_MN_RAN       QCP_RAN_VRF        CRT

Resource		${CURDIR}/../resources/Admin_Common_Library.robot
Resource		${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource		${CURDIR}/../resources/Common_Ipsec_Emergency_Bypass.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Pre-conditions for testsuite
Suite Teardown      Post-conditions for testteardown

*** Test Cases ***
[1.0] TRS_SEC_IPsecEB_IPv4_IPv6_Off-OffL-Standby-Probing-Standby-OffL
#Step1-2:
	Perform Recommissioning     type=delta		delta_file=${ASOE_SA_NSA_DualStack_Ipsec_delta}     timeout=300
	Check if IPv6 Control server doesnot reply on ping
	Run	sudo cp ${SECGW_CONF} ${SECGW_BACKUP_COPY}
	Run	sudo cp ${OFFL_ipsec_conf} ${SECGW_CONF}
	Enable Ipsec on SecureGW
	Enable Ipsec on Admin
	Verify IPSEC Security Association	${OFFL_Policy_list}

#Step3-4:
	Turn On Emergency Bypass Feature with IPv6
	Sleep	30
	Verify Ipsec Emergency Bypass Standby state
	Disable Ipsec on SecureGW
	Sleep	60
	Verify Alarm    faultid=${dpdFaultId}	occurrences=8
	Verify Ipsec Emergency Bypass Probing state
	Reset Bts	verify_bts=${False}	req_rat=5g
	Sleep	60
	Verify Ipsec Emergency Bypass Probing state

#Step5-6:
	Turn Off Emergency Bypass Feature with IPv6
	Sleep	30
	Check if IPv6 Control server doesnot reply on ping
	Verify Ipsec Emergency Bypass Off state
	[Teardown]	Disable Ipsec on Admin