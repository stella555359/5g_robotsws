*** Settings ***
Documentation
...     [Procedure]		"The test case is planned to validate TRS_Security-Certificate_Based_Authentication"
...     [Date]                  "08-09-21"
...     [Author]                "Bibhukinkar"
...     [QC_Path]		"QC_Path in Test Plan"
...     [QC_ID]			"QC_ID in Test Lab for reporting"
...	[Funtion_Hash_Tags]	"IPSEC, CERT"
...  	[Validation_status]  	"Validated and Passed"
...   	[Validated_TestLine] 	"TL-3908"
...     [Feature_ID]            "RP000356"
...     [Requirement ID]        "WBTS_TRS_20224"
...     [Config]                "This script requires IPV4 address and with IPSec configuration"
...     [RunTime Parameters]    "[bts_id used is 65]"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot

Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown    Teardown Oamops

*** Variables ***
${tc_variables}     testcase_variables.json

*** Test Cases ***
[2][1.0]RP000727_1197 Verification of IPv4 IPv6 concurrent tunnel with different ESP and IKE encryption and authentication method.
	[Documentation]		Verification of IPv4 IPv6 concurrent tunnel with different ESP and IKE encryption and authentication

     Certificate Configure    operation=install_certificate    cert_file=${IP_BTSCertp12_vsr}    cert_type=BtsTrustChain     cert_format=P12
...     password=${IP_BTSCertpass}
     Perform Commissioning       scf_file=${IPSec_IP_certificate_commisioning}    verify_bts_status=False      timeout=400      alias=default
     BuiltIn.Sleep    300
     Enable Ipsec on Admin
     Verify Ipsec Tunnels Status
     Read IPv4 parameters
     Disable Ipsec on Admin
     BuiltIn.Sleep   60
     Enable Ipsec on Admin
     Verify Ipsec Tunnels Status
     Check the ipsec tunnels after ike rekey
     Reboot BTS
     BuiltIn.Sleep   300
     Verify Ipsec Tunnels Status

*** Keywords ***

Check the ipsec tunnels after ike rekey
    Traffic Capture Start       capture_device=bts2      alias=ike_br0
    BuiltIn.Sleep    3700
    ${ike_rekey_pcap}=       Traffic Capture Stop        alias=ike_br0
    Analyse pcap            pcap_filename=${ike_rekey_pcap}      analysis=ike_rekey_ipv4      filter_file_name=${filter_file_name}
    Verify Ipsec Tunnels Status

Command to execute on board
        [Arguments]      ${command}
        Remote Command Execute      command=${command}

Reboot BTS
        Setup Remote Access    remote_device=bts
        Run Keyword And Ignore Error    Command to execute on board   reboot
        Teardown remote Access


Read IPv4 parameters
    ${AMF_ipv4_IP}=    Get Parameter   param_path=${AMF_ipv4_moc_path}
    Set Suite Variable        ${AMF_ipv4_IP}     ${AMF_ipv4_IP}
    ${cplane_ipv4}=    Get Parameter   param_path=${cplane_ipv4_moc_path}
    Set Suite Variable        ${cplane_ipv4}     ${cplane_ipv4}
    ${tunnel_ipv4_IP}=    Get Parameter   param_path=${tunnel_ipv4_IP_moc_path}
    Set Suite Variable        ${tunnel_ipv4_IP}     ${tunnel_ipv4_IP}

Read IPv6 parameters
    ${MME_ipv6_IP}=    Get Parameter   param_path=${MME_ipv6_moc_path}
    Set Suite Variable        ${MME_ipv6_IP}     ${MME_ipv6_IP}
    ${cplane_ipv6}=    Get Parameter   param_path=${cplane_ipv6_moc_path}
    Set Suite Variable        ${cplane_ipv6}     ${cplane_ipv6}
