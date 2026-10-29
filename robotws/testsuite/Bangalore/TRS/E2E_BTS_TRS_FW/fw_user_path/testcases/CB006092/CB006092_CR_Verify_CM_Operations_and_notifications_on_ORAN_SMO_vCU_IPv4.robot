*** Settings ***
Documentation
...		[Author]				"Nandini R"
...		[Procedure]				Verify ORAN-O1 CM opeartions with netconf and pano server
...		[Requirement ID]		FCA_E2ETRSIV-2321, FCA_E2ETRSIV-2317, FCA_E2ETRSIV-2318, FCA_E2ETRSIV-2319
...		[Feature ID]			CB006092
...		[Validated_TestLine]	CLOUD testline : 7-2-UTE5GCLOUDIAVTL03
...		[Config_Comments]		Ipv4 configuration with RSA and ECDSA certificates
...		[Funtion_Hash_Tags]		ORAN-O1, RSA, ECDSA, CB006092

Force Tags      SBTS00        QCD_MN_RAN       QCP_RAN_VRF        CRT

Resource        ${CURDIR}/resources/CB006092_Common_keywords.robot


Suite Setup			Setup Oamops        dut=vcu_cran12
Suite Teardown		Run Keywords	Collect Snapshot	dut=vcu_cran12		operation_timeout=300	AND		Teardown Oamops     dut=vcu_cran12

*** Test Cases ***
[1]CB006092_CR_Verify_CM_Operations_and_notifications_on_ORAN_SMO_vCU_IPv4
#Step1:
	Restore Vendor Certificates
	Perform Recommissioning	    dut=vcu_cran12	type=delta      delta_file=${CMP_delta_file}     timeout=400
	Initialize CMP Certificate      RSA
	Fetch Certs from vCU and Configure Netconf		RSA
	Get fingerprint and Configure MPLANEONAP and VES with 'RSA' certificate
	Start Netconf server and verify session couldnt be connected	${vCU_RSA_hostname}

#Step2:
	Start Pano and Activate Oran O1 and CM Events Flag
	Verify heartbeat notifications and time interval
	Start Netconf server and verify status		${vCU_RSA_hostname}

#Step3:
	Verify get getconfig and validate operations from netconf		${vCU_RSA_hostname}
	Verify CM Feedback notification messages and time interval		validation
	Start Pano and Perform delta Operations via BTS
	Verify MOI notification change messages
	Start Pano and Perform delta Operations via netconf		${vCU_RSA_hostname}		test-only
	Verify CM Feedback notification messages and time interval		validation
	Start Pano and Perform delta Operations via netconf		${vCU_RSA_hostname}		test-then-set
	Verify MOI notification change messages
	Verify VES source name		${new_VES_name}
	Verify CM Feedback notification messages and time interval		provision
	Perform Recommissioning		dut=vcu_cran12	type=delta		delta_file=${delete_onap}	timeout=400

#Step4:
	Restore Vendor Certificates
	Initialize CMP Certificate      ECDSA
	Fetch Certs from vCU and Configure Netconf		ECDSA
	Get fingerprint and Configure MPLANEONAP and VES with 'ECDSA' certificate
	Start Netconf server and verify session couldnt be connected	${vCU_ECDSA_hostname}

#Step5:
	Start Pano and Activate Oran O1 and CM Events Flag
	Verify heartbeat notifications and time interval
	Start Netconf server and verify status		${vCU_ECDSA_hostname}

#Step6:
	Verify get getconfig and validate operations from netconf		${vCU_ECDSA_hostname}
	Verify CM Feedback notification messages and time interval		validation
	Start Pano and Perform delta Operations via BTS
	Verify MOI notification change messages
	Start Pano and Perform delta Operations via netconf		${vCU_ECDSA_hostname}		test-only
	Verify CM Feedback notification messages and time interval		validation
	Start Pano and Perform delta Operations via netconf		${vCU_ECDSA_hostname}		test-then-set
	Verify MOI notification change messages
	Verify VES source name		${new_VES_name}
	Verify CM Feedback notification messages and time interval		provision
	Perform Recommissioning		dut=vcu_cran12	type=delta		delta_file=${delete_onap}	timeout=400