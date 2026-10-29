*** Settings ***
Documentation
	...		[Procedure]				"The test case is planned to validate TRS_Security-Certificate_Based_Authentication"
    ...     [Date]                  "08-09-21"
    ...     [Author]                "Bibhukinkar"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		"IPSEC, CERT"
	...  	[Validation_status]  	"Validated and Passed"
	...   	[Validated_TestLine] 	"TL-3908"
    ...     [Feature_ID]            "RP000356"
    ...     [Requirement ID]    "WBTS_TRS_20224"
    ...     [Config]    "This script requires IPV4 address and with IPSec configuration"
    ...     [RunTime Parameters]    "[bts_id used is 65]"


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown    Teardown Oamops


*** Variables ***
${tc_variables}     testcase_variables.json

*** Test Cases ***
[2][2.0] TRS_Security-Certificate_Based_Authentication-RP000356

     Perform Commissioning       scf_file=${IPSec_IP_certificate_commisioning}    verify_bts_status=False      timeout=400      alias=default
     BuiltIn.Sleep    900
	 Verify IP Certificates
     Get Ipsec Tunnels Status
     Read IKE Authentication Method
     Read IPSEC Authentication Method


*** Keywords ***

Verify IP Certificates
	Certificate Configure    operation=install_certificate    cert_file=${IP_BTSCertp12} 	cert_type=BtsTrustChain 	cert_format=P12
...     password=${IP_BTSCertpass}
    BUiltIn.Sleep    20

Get Ipsec Tunnels Status
	[Arguments]    ${dut}=default
    @{parent_tunnel_moc_list} =    Query Admin Infomodel	query=get list ${ike_sa_l_moc_path}	alias=${dut}
    FOR    ${ike_tunnel}	IN      @{parent_tunnel_moc_list}
     	${parent_tunnel_stateInfo}=     Get From Dictionary	dictionary=${ike_tunnel}	key=stateInfo
     	${parent_tunnel_proceduralState}=    Get From Dictionary	dictionary=${parent_tunnel_stateInfo}	key=proceduralState
     	Should Be True	'${parent_tunnel_proceduralState}'=='Established'
    END
    @{child_tunnel_moc_list} =      Query Admin Infomodel	query=get list ${ipsec_sa_l_moc_path}	alias=${dut}
    FOR    ${child_tunnel}    IN       @{child_tunnel_moc_list}
     	${child_tunnel_stateInfo}=      Get From Dictionary	dictionary=${child_tunnel}	key=stateInfo
     	${child_tunnel_proceduralState}=        Get From Dictionary	dictionary=${child_tunnel_stateInfo}	key=proceduralState
     	Should Be True	'${child_tunnel_proceduralState}'=='Installed'
    END

Read IKE Authentication Method
    ${ike_auth}=    Get Parameter   param_path=${ike_auth_moc_path}
    Set Suite Variable        ${ike_auth}     ${ike_auth}

Read IPSEC Authentication Method
    ${ipsec_auth}=    Get Parameter   param_path=${ipsec_auth_moc_path}
    Set Suite Variable        ${ipsec_auth}     ${ipsec_auth}

