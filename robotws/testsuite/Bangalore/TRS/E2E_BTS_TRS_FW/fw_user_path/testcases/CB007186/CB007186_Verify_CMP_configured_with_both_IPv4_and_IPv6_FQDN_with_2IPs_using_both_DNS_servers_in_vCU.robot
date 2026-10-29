*** Settings ***
Documentation
...     [Author]        "Megha H D"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case covers basic check for certificate configuration on vCU and vDU"
...     [Date]      "20-10-2023"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify support for certificate configuration on vCU"
...     [Funtion_Hash_Tags] "TRS - Security"
...     [Feature_ID]            "CB007186"
...     [Requirement ID]    ""
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "TL006"
...     [Config]    "This testcase needs basic scf with certificate details and CMP MOC with fqdn"
...     [scf_file]  "Actual_configuration_scf_MRBTS-5562_5GvDU-TL1107_20230621-1924_Base_SCF.xml"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB007186.robot
Resource        ${CURDIR}/../resources/common_Cloud_keywords.robot

Suite Teardown      Collect logs in cloud

Force Tags      CA_E2ET_BTSTRSPZ        vCUCNF00      vCUCNF23R3     4G_FDD       QCD_MN_RAN        QCP_RAN_VRF      CRT

*** Test Cases ***
[1]CB007186_Verify_CMP_configured_with_both_IPv4_and IPv6_FQDN_with_2IPs_using_both_DNS_servers_in_vCU
    Configure cmpserver with fqdn	vcu_7186
    Comment     Manual Trigger with Keypool as RSA
    Triger CMP IR to install certificates   RSA     vcu_7186
    Verify CMP packets     ${vcu_7186_RSA}	vcu_7186
    Verify cmp status	${cmp_r_moc_path}	CMP_R-1		vcu_7186
    Comment     Manual Trigger with Keypool as ECDSA.
    Triger CMP IR to install certificates   ECDSA   vcu_7186
    Verify CMP packets     ${vcu_7186_ECDSA}	vcu_7186
    Verify cmp status	${cmpecdsa_r_moc_path}	CMPECDSA_R-1	vcu_7186
    Trigger oampod reset	vcu_7186
    Configure cmpserver with ipv6 fqdn	vcu_7186
    Perform initialize cert without fqdn	vcu_7186
    [Teardown]      Teardown Oamops     dut=vcu_7186     alias=vcu_7186
