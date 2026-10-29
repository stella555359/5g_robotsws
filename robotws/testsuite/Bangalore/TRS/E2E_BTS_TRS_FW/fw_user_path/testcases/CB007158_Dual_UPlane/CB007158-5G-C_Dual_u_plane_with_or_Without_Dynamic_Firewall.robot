*** Settings ***
Documentation
...		[Author]     		        "Pranitha"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "19:06:2023"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB007158"
...     [Validated_TestLine]        "KVM53-TRSIV-TL003"
...		[Procedure]         "CB007158-5G- C Dual u plane with or Without Dynamic Firewall"
...     [Precondition]              "ASIL + ABIO hardware is required"
...     [Config_Comments]           "Shared VLAN NG-U NG-C Xn-U and Xn-C IPs for 6 Operators_IPv4"
...     [Function_Hash_Tags]        "SA 6 Operator RAN Sharing, Dual Stack, verify 6 operator call with Airphone"


Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup	    Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops


*** Test Cases ***
[1]CB007158-5G- C Dual u plane with SA + NSA ran sharing with fast ip rerouting with or Without Dynamic Firewall
	Perform Commissioning	scf_file=${7158_SA_NSA_6OP_Ransharing_SCF}		verify_bts_status=${False}	timeout=400
	...		alias=default
	Sleep    120
	Call Setup		5g=7158_dualstack_6OP_slice:data		parallel=${False}    verify_attach=${False}   attach=${False}
	...		ipv4_or_6=ipv4     timeout=600
    	Sleep   60
#    	Bring UP X2 Link
    	Generate Scf    target_file=${Current_Backup_SCF}   export_type=configurationAndRuntimeObjects
#	Verify the NG link status
	Verify Bts Status
	Perform Recommissioning 	type=param 	param_path=NRBTS-1:actDynamicFirewall 	operation=update
	...		value=true 		timeout=120
    	Block Cell      rat=nr
    	Sleep   120
    	Unblock Cell    rat=nr
    	Sleep   120
#    	Perform SA NSA Dual Uplane Calls
#	[Teardown]      Keywords To Run At End

*** Keywords ***
Precondition
	FOR   ${IP}  IN   @{eth3_IPv4}
	    Run      sudo ip addr add ${IP} dev eth3
	END

	FOR   ${IP}  IN   @{eth3_IPv6}
	    Run      sudo ip -6 addr add ${IP} dev eth3
	END

	FOR   ${vlan}  IN   @{eth3_vlan_Ipv4}
#	    ${ip}=    Get From Dictionary       ${eth3_vlan_Ipv4}     ${vlan}
	    Run   sudo ip link add link eth3 name eth3.${vlan} type vlan id ${vlan}
   	    Run   sudo ip addr add ${ip} dev eth3.${vlan}
  	    Run   sudo ip link set dev eth3.${vlan} up
  	END

	FOR   ${vlan}  IN   @{eth3_vlan_Ipv6}
	    ${ip}=    Get From Dictionary       ${eth3_vlan_Ipv6}     ${vlan}
	    Run   sudo ip -6 addr add ${ip} dev eth3.${vlan}
	END
