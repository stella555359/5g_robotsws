*** Settings ***
Documentation
...     [Author]            "Meghana J"
...     [Maintenance]       "TRS I & V Tools Bangalore Team"
...     [Procedure]         "The test case covers sbr configuration"
...     [Date]              "21-10-2024"
...     [QC_Path]           "QC_Path in Test Plan"
...     [QC_ID]             "TRS_CB010453_source_based_ routing_ configuration_ for_VCU_IPV4_CPIF_and_UPUE_POD"
...     [Funtion_Hash_Tags]     "TRS - Security"
...     [Feature_ID]            "CB010453"
...     [Config]            "This testcase needs sbr configuration"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB010453_Keywords.robot

Force Tags      CLOUD_F    CA_VRF_BLR2        SBTS00        SBTS24R2    SBTS24R3      QCD_MN_RAN       QCP_RAN_VRF  CRT

*** Variables ***
&{EXPECTED_GATEWAYS_CPIF}
...    52=10.0.11.1
...    53=10.0.1.1
...    54=10.0.12.1
...    55=10.0.1.5

&{EXPECTED_GATEWAYS_UPUE}
...    52=10.0.11.2
...    53=10.0.12.2

&{EXPECTED_GATEWAYS_CPRT}
...    52=172.16.1.10

&{EXPECTED_GATEWAYS_L2NRT}
...    52=172.16.2.10

***Test case***
[1]TRS_CB010453_source_based_routing_configuration_for_VCU_IPV4_CPIF_and_UPUE_POD
	Perform Commissioning on vcu and vdu
	Verifying alarm during Creation of deletion of conflicting IPRT and routing table for VCU
	Verifying alarm during Creation of deletion of conflicting IPRT and routing table for VDU
	Perform SBR configuration
	Check SBR Routing And Gateway CPIF
	Check SBR Routing And Gateway UPUE
    Start traffic Capture for VCU and analyze
	Check SBR Routing And Gateway CPRT
	Check SBR Routing And Gateway L2NRT
	Start traffic Capture for VDU and analyze
    Modify and Verify ipmtu on VCU
    Modify and Verify ipmtu on VDU
	Test Routing After SBR Removal
	Deletion of default route should not be allowed
	Order Number Outside Valid Range
	Verify Maximum configuration for CPIF
    Verify Maximum configuration for UPUE
	Verify Maximum configuration for CPRT
    Verify Maximum configuration for L2NRT