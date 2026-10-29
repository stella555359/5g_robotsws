*** Settings ***
Documentation
...	[Procedure]				"The test case performs commissioning and verifies any to any policy of IPSec."
...	[Date]					"01-04-2022"
...	[Author]				"Ruchika"
...	[Feature_ID] 			"SR000727"
...	[Maintenance]			"TRS I & V Tools Bangalore Team"
...	[Funtion_Hash_Tags] 	"E2LINK_RIC"
...	[Validated_TestLine] 	"CLOUD_5G - ASIB, ASIL, ASIK, ASOE topologies"
...	[Config_Comments] 		"5G classical mode SA configuration with IPv4"
...	[Precondition] 			"BTS should be operational and on Air with NR RAT"
...	[QC_Path]               "QC_Path in Test Plan"
...	[QC_ID]					"QC_ID in Test Lab for reporting"

Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup                 Pre-conditions for testsuite
Suite Teardown              Post-conditions for testteardown

***Test Cases***
[1][1.0] IPsec_Ipv4_outer_tunnelwith_any_any_traffic
    Run     sudo cp /etc/strongswan.d/charon.conf /etc/strongswan.d/charon_bkp.conf
    Run     sudo cp ${charon_path} /etc/strongswan.d/charon.conf
	Run     sudo cp /etc/ipsec.conf /etc/ipsec_bkp.conf
    Run     sudo cp ${Ipsec.conf} /etc/ipsec.conf
    Perform Recommissioning     type=delta  delta_file=${IPSec_AtoA}    skip_parameter_relation_errors=${True}  timeout=300
    Certificate Configure    operation=install_certificate    cert_file=${BTSCertp12}   cert_type=BtsTrustChain
    ...     cert_format=P12     password=${BTSCertpass}
    BuiltIn.Sleep   50
    Run     sudo ip a a 10.0.1.7/32 dev eth3.650
    Run     sudo ip tunnel add con1 local 10.0.1.7 remote 10.0.1.2 mode vti key 100
    Run     sudo ip link set con1 up
    Run     sudo ip r a 10.0.1.4/32 dev con1
    Run     sudo ipsec restart
    BuiltIn.Sleep   40
    Verify Ipsec Tunnels Status from Webem
    Perform Recommissioning     type=delta  delta_file=${IPSec_AtoV}    skip_parameter_relation_errors=${True}  timeout=300
    Run     sudo cp ${Ipsec_1.conf} /etc/ipsec.conf
    Run     sudo ipsec restart
    BuiltIn.Sleep   40
    Verify Ipsec Tunnels Status from Webem
    Perform Recommissioning     type=delta  delta_file=${IPSec_VtoA}    skip_parameter_relation_errors=${True}  timeout=300
    Run     sudo cp ${Ipsec.conf} /etc/ipsec.conf
    Run     sudo ipsec restart
    BuiltIn.Sleep   40
    Verify Ipsec Tunnels Status from Webem

*** Keywords ***
Verify Ipsec Tunnels Status from Webem
    @{ike_peer_moc_list} =      Query Admin Infomodel    query=get list ${ike_peer_moc_path}
    FOR    ${ike_peer}    IN       @{ike_peer_moc_list}
         ${ike_peer_state}=      Get From Dictionary    dictionary=${ike_peer}    key=ikePeerState
         Should Be True    '${ike_peer_state}'=='ESTABLISHED' 
    END

