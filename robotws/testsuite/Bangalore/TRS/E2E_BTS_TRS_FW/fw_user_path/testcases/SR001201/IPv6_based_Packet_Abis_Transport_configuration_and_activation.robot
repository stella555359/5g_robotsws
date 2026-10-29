*** Settings ***
Documentation
...		[Author]     		        "Abhishake"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "05:01:2023"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "SR001201"
...     [Validated_TestLine]        "KVM87-TRSIV-TL0005"
...		[Funtion_Hash_Tags]			"OAM_Security"
...		[Procedure]   		        "IPv6 based Packet Abis Transport configuration and activation"
...     [Precondition]              "ASIM hardware is required"


Variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource    	${CURDIR}/../resources/Admin_Common_Library.robot


Suite Setup  Run Keywords  Suite Setup Preconditions
...  AND  Setup Oamops
Suite Teardown   Run Keywords  Suite Teardown Postconditions
...  AND  Teardown Oamops


*** Test Cases ***
[1][2.0] RP000397 IPv4 based Packet Abis transport activation , deactivation and static parameter configuration with two IP address - Ethernet based
    Perform Commissioning		scf_file=${basic_config}		verify_bts_status=True
	Deactivate PacketAbis and check gsm cplane IP ping status
    Verify Bts Status  should_be_onair=${True}
	Activate PacketAbis and check gsm cplane IP ping status
    Verify Bts Status  should_be_onair=${True}

*** Keywords ***
Deactivate PacketAbis and check gsm cplane IP ping status
    Perform Recommissioning       type=param       param_path=MRBTS-3792/MNL-1/MNLENT-1/FEATCADM-1/FEATGADM-1:actIpV6BasedPktAbTrs
	...       operation=update       value=false    timeout=600
    Sleep    120
    Perform Recommissioning       type=param       param_path=MRBTS-3792/GNBTS-1/GNBCF-1:bcfId       operation=update     value=3792    timeout=600
    Sleep         120
    Verify Bts Status       req_rat=gsm     should_be_onair=${True}     timeout=400
	${gsm_cplane1} =     Get Parameter        rat=gsm        param_path=${gsm_cplane1_ip_moc_path}
	${bsc_ip}=        Get Parameter        rat=gsm        param_path=${gsm_bsc_ip_moc_path}
	Set Suite Variable        ${bsc_ip}            ${bsc_ip}
	Set Suite Variable        ${gsm_cplane1}        ${gsm_cplane1}
	Execute command on ENodeB       ping 2a00:8a00:a000:11b0::4057 -c 5
	Should contain      ${stdout}       5 packets transmitted, 5 received


Activate PacketAbis and check gsm cplane IP ping status
    Perform Recommissioning       type=param       param_path=MRBTS-3792/MNL-1/MNLENT-1/FEATCADM-1/FEATGADM-1:actIpV6BasedPktAbTrs
	...       operation=update       value=${True}   timeout=600
    Sleep    120
    Perform Recommissioning       type=param       param_path=MRBTS-3792/GNBTS-1/GNBCF-1:bcfId       operation=update       value=379    timeout=600
    Verify Bts Status       req_rat=gsm     should_be_onair=${True}     timeout=400
	${gsm_cplane1} =     Get Parameter        rat=gsm        param_path=${gsm_cplane1_ip_moc_path}
	${bsc_ip}=        Get Parameter        rat=gsm        param_path=${gsm_bsc_ip_moc_path}
	Set Suite Variable        ${bsc_ip}            ${bsc_ip}
	Set Suite Variable        ${gsm_cplane1}        ${gsm_cplane1}
	Execute command on ENodeB       ping 2a00:8a00:a000:11b0::4057 -c 5
	Should contain      ${stdout}       5 packets transmitted, 5 received