*** Settings ***
Documentation
	...		[Procedure]				"The test case is planned to Verification of flow control"
	...		[Date]					"7-9-2020"
	...		[Author]				"Manohar KR"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		"IPSEC","RANSHARING"
	...   	[Feature_ID]         	"5GC001464"
	...  	[Validation_status]  	"Validated and Passed"
	...   	[Validated_TestLine] 	"5G_9049"
	...   	[Config] 				"NRBTS-1 need to configured with 6 x2clist"

Variables         ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/CB006540_SR002749_Common_keywords.robot


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND		Teardown Oamops



*** Test Cases ***
TRS_CB006540_Verification_of_ipsec_tunnels_for_6operators_shared_gNB_with_maxconfiguration.
	[Documentation]		"The test case to verify Maximum flowctrl support and flowctrl counter verification"
	Perform Commissioning        verify_bts_status=${False}     timeout=400     alias=default
	Verify RMOD is up
	Load BTS with Scenario Specific Configuration 		${deltaOnbaseConfig_ipsecDedPKI}
	Configure IPsec and verify status
	Configure MaxVLAN and verify
	Configure Max IPIF_IPAddress and verify
	Wait Until Keyword Succeeds    2 min    30		Get Ipsec Tunnels Status
   	verify snapshot collection
	Revert Max Config
	verify snapshot collection

***Keywords***

Configure MaxVLAN and verify
	Perform Recommissioning        type=delta        delta_file=${MaxVlanConfig}        timeout=600

Configure Max IPIF_IPAddress and verify
	Perform Recommissioning        type=delta        delta_file=${MaxIPAddrConfig}        timeout=600

verify snapshot collection
    ${snap}=	Collect Snapshot        timeout=1200

Configure IPsec and verify status
	Delete All Certificates
	Install RAN sharing ipsec certs
	Wait Until Keyword Succeeds    5 min    30 	Get Ipsec Tunnels Status

Get Ipsec Tunnels Status
	[Documentation]		This test case keyword is to verify IPSec tunnels status for 6 operators x2c list
	@{parent_tunnel_moc_list} = 	Query Admin Infomodel		query=get list ${ike_sa_l_moc_path}
	FOR 	${ike_tunnel}	IN 	@{parent_tunnel_moc_list}
		${parent_tunnel_stateInfo}=	Get From Dictionary		dictionary=${ike_tunnel}		key=stateInfo
		${parent_tunnel_proceduralState}=	Get From Dictionary		dictionary=${parent_tunnel_stateInfo}		key=proceduralState
		Should Be True	'${parent_tunnel_proceduralState}'=='Established'
	END

	@{child_tunnel_moc_list} = 	Query Admin Infomodel		query=get list ${ipsec_sa_l_moc_path}
	FOR 	${child_tunnel}	IN 	@{child_tunnel_moc_list}
		${child_tunnel_stateInfo}=	Get From Dictionary		dictionary=${child_tunnel}		key=stateInfo
		${child_tunnel_proceduralState}=	Get From Dictionary		dictionary=${child_tunnel_stateInfo}		key=proceduralState
		Should Be True	'${child_tunnel_proceduralState}'=='Installed'
	END

Revert Max Config
    Perform Recommissioning        type=delta        delta_file=${MaxIPAddrConfigDel}        timeout=600
	sleep     10
	Perform Recommissioning        type=delta        delta_file=${MaxVlanConfigDel}        timeout=600


Delete All Certificates
	certificate configure    operation=restore_vendor_certificate
	Sleep 		10
	certificate configure    operation=delete_cert  all_certs=${True}

Install RAN sharing ipsec certs
    [Documentation]    This test case keyword is to install ipsec operator certificate
    Certificate Configure    operation=install_certificate
    ...    cert_file=${Ransharing_Dedicated_Cert}    cert_type=BtsTrustChain
    ...    cert_format=P12    password=${Ransharing_Dedicated_Cert_password}
    certificate configure    operation=install_certificate
    ...    cert_file=${Ransharing_Dedicated_Cert_additionPem}
    ...    cert_type=AdditionalCa    cert_format=PEM    timeout=200
    certificate configure    operation=install_certificate
    ...    cert_file=${Ransharing_Crossigned_additionPem}
    ...    cert_type=AdditionalCa    cert_format=PEM    timeout=200
    IPSec restart


IPSec restart
	Perform Recommissioning			type=param		param_path=${ipSecEnabled}		value=false	  	operation=update	 timeout=600
	sleep 	10
	Perform Recommissioning			type=param		param_path=${ipSecEnabled}		value=true		operation=update		timeout=600
	sleep 	10
