*** Settings ***
Documentation
     ...    [Procedure] "TRS_CB009901_NG-C_Setup_With_AMF_Address_Configured_As_FQDN_And_IP"
     ...    [Date] "02-01-2025"
     ...    [Author] "Meghana J"
     ...    [QC_Path] "QC_Path in Test Plan"
     ...    [QC_ID] "QC_ID in Test Lab for reporting"
     ...    [Funtion_Hash_Tags] "AMF FQDN"
     ...    [Feature_ID] "CB009901"
     ...    [Validation_status] "Validated"
     ...    [Validated_TestLine] "ASIM"
     ...    [Commissioning_comment] "This script requires 5G and AMF FQDN Configuration"

Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup                     Pre-conditions for testsuite
Suite Teardown                   Post-conditions for testteardown

*** Test Cases ***
[1]TRS_CB009901_NG-C_Setup_With_AMF_Address_Configured_As_FQDN_And_IP

	Perform Basic Commissioning
	Perform AMF FQDN Recommissioning
    Online Modification AMF FQDN to AMF IP
	Create Wrong FQDN Check Status
	Lock and Unlock operation for AMF Administrative state
	Reboot enB And verify nglink status

*** Keywords ***
Perform Basic Commissioning
	Perform Commissioning		scf_file=${Basic_SCF}	verify_bts_status=False     timeout=1200
	Sleep	250
	Call Setup		nr=airphone_sa:data      parallel=${False}    verify_attach=${False}   attach=${False}    ipv4_or_6=ipv4       timeout=300
	Verify Bts Status       req_rat=nr      should_be_onair=${True}        timeout=90        alias=default

Perform AMF FQDN Recommissioning
	Perform Recommissioning        type=delta      delta_file=${CB009901_AMF_FQDN}       skip_parameter_relation_errors=${True}      timeout=300
	Verify AMF FQDN Resolved IP Address

Verify AMF FQDN Resolved IP Address
	${amfIPAddressResolved}=     Get Parameter     param_path=SERVEDAMF-1:amfIPAddressResolved
	Should Be Equal     ${amfIPAddressResolved}       ${amfIPAddress_ipv4}
	${amfIPAddressResolved}=     Get Parameter     param_path=SERVEDAMF-2:amfIPAddressResolved
	Should Be Equal     ${amfIPAddressResolved}       ${amfIPAddress_ipv6}


Verify nglink status
    [Arguments]    ${status}    ${AMFID}
    ${nglink}=    Query Admin Infomodel    query=get object //SERVEDAMF_R-${AMFID}
    Should Be Equal    ${nglink["ngLinkStatus"]}    ${status}


Online Modification AMF FQDN to AMF IP
	Perform Recommissioning        type=delta      delta_file=${Wrong_Adding_IPv4_IPv6_AMF_IP}       skip_parameter_relation_errors=${True}
	...		timeout=300
	Verify nglink status	Inactive	1
	Verify nglink status	Inactive	2
	Perform Recommissioning        type=delta      delta_file=${Adding_IPv4_IPv6_AMF_IP}       skip_parameter_relation_errors=${True}
	...		timeout=300
	Verify nglink status	Active	1
	Verify nglink status	Active	2

Create Wrong FQDN Check Status
	Perform Recommissioning        type=delta      delta_file=${Wrong_AMF_FQDN}       skip_parameter_relation_errors=${True}      timeout=300
	Sleep	30
	Verify Alarm	faultid=7334    occurrences=2
	Verify nglink status	Active	1
	Verify nglink status	Active	2
	Perform Recommissioning        type=delta      delta_file=${Delete_SERVEDAMF_1}       skip_parameter_relation_errors=${True}      timeout=300
	Verify Alarm	faultid=7334    occurrences=1
	Perform Recommissioning        type=delta      delta_file=${Add_SERVEDAMF_With_Valid_FQDN}       skip_parameter_relation_errors=${True}
	...		timeout=300
	Verify Alarm	faultid=7334	should_exist=${False}
	Verify nglink status	Active	1
	Verify nglink status	Active	2

Lock and Unlock operation for AMF Administrative state
	Perform Recommissioning		type=param	param_path=SERVEDAMF-1:administrativeState	operation=update	value=Locked
	...        timeout=300
	Verify nglink status	Inactive	1
	Verify nglink status	Active	2
	Perform Recommissioning		type=param	param_path=SERVEDAMF-1:administrativeState	operation=update	value=Unlocked
	...        timeout=300
	Perform Recommissioning		type=param      param_path=SERVEDAMF-2:administrativeState	operation=update	value=Locked
	...        timeout=300
	Verify nglink status	Active	1
	Verify nglink status	Inactive	2
	Perform Recommissioning		type=param	param_path=SERVEDAMF-2:administrativeState	operation=update	value=Unlocked
	...        timeout=300
	Verify nglink status	Active	1
	Verify nglink status	Active	2

Reboot enB And verify nglink status
	Reset Bts   verify_bts=${True}
	Sleep	200
	Call Setup		nr=airphone_sa:data      parallel=${False}    verify_attach=${False}   attach=${False}    ipv4_or_6=ipv4       timeout=300
	Verify Bts Status       req_rat=nr      should_be_onair=${True}        timeout=90        alias=default
	Verify AMF FQDN Resolved IP Address
	Verify nglink status	Active	1
	Verify nglink status	Active	2