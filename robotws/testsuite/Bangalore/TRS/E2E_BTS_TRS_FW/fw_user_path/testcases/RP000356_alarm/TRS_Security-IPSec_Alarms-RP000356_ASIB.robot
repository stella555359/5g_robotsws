*** Settings ***
Documentation
	...		[Procedure]				"This test case verifies various IPsec Alarms behaviour"
	...		[Date]					"10-01-23"
	...		[Author]				"Vivin"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		"IPSEC, IPsec Alarms"
	...   	[Feature_ID]         	"SR002672_RP000356"
	...  	[Validation_status]  	"Validated and Passed"
	...   	[Validated_TestLine] 	"ASIB"

Force Tags       SBTS00       SBTS25R3       QCD_MN_RAN        QCP_RAN_VRF



Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CommonKeywords_RP000356.robot
Library         ute_fsmaccess
Library         Collections
Library         String
Library         XML     lxml=True



Suite Setup     Run Keywords    Suite Setup Preconditions
...             AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...             AND     Teardown Oamops



*** Test Cases ***
[1][1.0] TRS_SR002672_RP000356_Security-IPSec_Alarms
    @{policy_50_60}=        Create List     ${Policy_50}    ${Policy_60}
    Set Global Variable     ${policy_50_60}     ${policy_50_60}
# Enable IPSEC on secgw and verify whether the configured policy IPSEC tunnels are up
    Enable IPSEC and verify whether the configured policy IPSEC tunnels are up

    Dead Peer Alarm Validation

    IKE Auth Alarm Validation

    IPSec SA Mismatch Alarm Validation

    IKE SA Mismatch Alarm Validation


*** Keywords ***
Enable IPSEC and verify whether the configured policy IPSEC tunnels are up
    Perform Commissioning    scf_file=${base_customer_config_asib}    verify_bts_status=true        timeout=600
    Sleep   300
    Perform Recommissioning     type=delta      delta_file=${RP000356_IPSEC_IPv4v6_asib}     skip_parameter_relation_errors=${True}      timeout=300
	Certificate Configure		operation=restore_vendor_certificate
	Sleep	30
	Certificate Configure		operation=install_certificate		cert_file=${Ipsec_Cert_file}		cert_type=BtsTrustChain		cert_format=P12
    ... 		password=${Ipsec_Cert_password}		timeout=300

	Run     sh ${ip_addr_rout_addition_asib}
    Comment     copy cert file to etc path required for ipsec conn
    Run     sudo chmod 777 /etc/ipsec.d/private/
    Run     sudo cp ${CURDIR}/resources/certificates/cacerts/* /etc/ipsec.d/cacerts/
    Run     sudo cp ${CURDIR}/resources/certificates/certs/* /etc/ipsec.d/certs/
    Run     sudo cp ${CURDIR}/resources/certificates/private/* /etc/ipsec.d/private/
    Run     sudo unlink /etc/ipsec.d/certs/BTSCert.pem
    Run     sudo unlink /etc/ipsec.d/private/privkey.pem
    Run     sudo ln -s /etc/ipsec.d/certs/BTSCert_sha1.pem /etc/ipsec.d/certs/BTSCert.pem
    Run     sudo ln -s /etc/ipsec.d/private/privkey_sha1.pem /etc/ipsec.d/private/privkey.pem
    Run     sudo cp /etc/ipsec.secrets /etc/ipsec_bkp.secrets
    Run     sudo cp ${CURDIR}/resources/certificates/ipsec.secrets /etc/ipsec.secrets
    Comment     Copy the ipsec.conf file into the VM strongswan where fragmentation is enabled for Policy 50 and Policy 60
    Run     sudo cp /etc/ipsec.conf /etc/ipsec_bkp.conf
    Run     sudo cp ${CURDIR}/resources/${RP000356_IPv4v6_IPSEC} /etc/ipsec.conf
    Run     sudo ipsec restart
    Comment     Enable IPsec on BTS
	Perform Recommissioning		type=param		param_path=IPSECC-1:ipSecEnabled	operation=update	value=true		timeout=300		alias=default
	Sleep	30
    Comment     Verify if all tunnels are established
    Verify Ipsec Tunnel Status
