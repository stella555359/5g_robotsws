*** Settings ***
Documentation
...     [Author]        	"Megha H D"
...     [Maintenance]   	"TRS I & V Tools Bangalore Team"
...     [Procedure] 		"The test case covers basic check for certificate configuration with ipsec on
...					vCU with revoked EE certificate"
...     [Date]      		"21-10-2024"
...     [QC_Path]   		"QC_Path in Test Plan"
...     [QC_ID]     		"Verify_IKE&ESP_encryption_keeping_M-Plane_Ipsec_tunnel_established_with_revoked_SeGW_certificate"
...     [Funtion_Hash_Tags] 	"TRS - Security"
...     [Feature_ID]            "CB009741"
...     [Requirement ID]    	""
...     [Validation_Status]	"Validated"
...     [Validated_TestLine]    "TL006"
...     [Config]    		"This testcase needs basic scf with ipsec configuration"
...     [scf_file]  		"basic_scfc_vcu_ipsec.xml"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB009741.robot
Resource        ${CURDIR}/../resources/common_Cloud_keywords.robot


Suite Teardown      Collect logs in cloud

Force Tags      CA_E2ET_BTSTRSPZ        vCUCNF00      vCUCNF25R1     4G_FDD       QCD_MN_RAN        QCP_RAN_VRF      CRT


*** Test Cases ***
[1]TRS_CB009741_M-Plane_IPv4_Ipsec_tunnel_established_and_skip_parameter_is_disabled_with_revoked_SeGW_certificate
    Load basic ipsec SCFC	vcu
    Configure cmpserver with Revoked EE certificate	vcu
    Triger IR to install certificate   RSA     vcu
    Verify cmp certificate state	vcu
    Copy Revoked EE certificate to strongswan
    Configure Mplane with ignorePeerCertValidity enabled	vcu
    Verify alarm with Peer certificate is revoked	vcu
    Reset vcu and check alarm persistance
    Disable Mplane ignorePeerCertValidity and verify alarm is cleared	vcu

