*** Settings ***
Documentation
	...		[Procedure]				"The test case is planned to Verification of ipsec tunnels for 6 operators shared gNB with dedicated eNB & common PKI"
	...		[Date]					"17-19-2020"
	...		[Author]				"Madhu Chinthakindi"
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
TRS_CB006540_Verification_of_ipsec_tunnels_for_6operators_shared_gNB_with_dedicated_eNB_dedicated_PKI_using_additonalintermediateCas.
	[Documentation]		This test case verify 6 operator x2c tunnels IPSec status and with reconfiguring supported and non suported certificates
	Perform Commissioning        verify_bts_status=${False}     timeout=400     alias=default
	Verify RMOD is up
	Preconditions for IPSEC
	Load BTS with Scenario Specific Configuration 		${deltaOnbaseConfig_ipsecDedPKI}
	Verify RMOD is up
	Get Ipsec Tunnels Status
	Read Ip and plmn deatils		${MeNBIn_DedS1U_SharedeNB}
	Trigger and verify 6 operators parallel calls	 ${MeNBIn_DedS1U_SharedeNB}
	Verify And Retry On Attach Failure	${MeNBIn_DedS1U_SharedeNB}
	Verify s1U traffic

*** Keywords ***
Preconditions for IPSEC
    [Documentation]    This test case keyword is to install ipsec operator certificate
    Run Keyword And Ignore Error    Delete All Certificates
    Sleep    10
    Certificate Configure    operation=install_certificate
    ...    cert_file=${Ransharing_Dedicated_Cert}    cert_type=BtsTrustChain 	cert_format=P12    password=${Ransharing_Dedicated_Cert_password}
    certificate configure    operation=install_certificate
    ...    cert_file=${Ransharing_Dedicated_Cert_additionPem}
    ...    cert_type=AdditionalCa    cert_format=PEM    timeout=200
    Add ipsec configuration for crosssigned operator


IPSec restart
	Perform Recommissioning			type=param		param_path=${ipSecEnabled}		value=false	  	operation=update	 timeout=600
	sleep 	15
	Perform Recommissioning			type=param		param_path=${ipSecEnabled}		value=true		operation=update 	timeout=600
	sleep 	15

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

Add ipsec configuration for crosssigned operator
    certificate configure    operation=install_certificate  cert_file=${Ransharing_Crossigned_additionPem}
    ...    cert_type=AdditionalCa    cert_format=PEM    timeout=200
    Run Keyword And Ignore Error    IPSec restart

Delete All Certificates
	certificate configure    operation=restore_vendor_certificate
	Sleep 		10
	Run Keyword And Ignore Error	certificate configure    operation=delete_cert  all_certs=${True}
	Log    Certificate Deleted Successfully
