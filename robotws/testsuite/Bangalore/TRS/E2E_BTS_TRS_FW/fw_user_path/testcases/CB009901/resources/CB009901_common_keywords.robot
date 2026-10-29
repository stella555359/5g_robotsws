*** Settings ***
Documentation
     ...    [Author] "Meghana J"

Resource		${CURDIR}/../../resources/common_keywords.robot
Resource		${CURDIR}/../../resources/Admin_Common_Library.robot

*** Keywords ***
Preconditions
    Setup Ems    config_device=netact1    alias=lab2006_omc_user

Postconditions
    Teardown Ems    config_device=netact1    alias=lab2006_omc_user

Perform AMF FQDN Commissioning
	Perform Commissioning       scf_file=${AMF_FQDN_SCF}   verify_bts_status=False     timeout=400
    Sleep    300
	Verify Bts Status       req_rat=nr      should_be_onair=${True}        timeout=90        alias=default

Verify AMF FQDN IP Address Resolved
	Configuration Manage    config_device=netact1    operation=Edit    plan_name=fw_plan    alias=lab2006_omc_user    config=${FQDN_Caps}
	...    delete_plan=False    should_provision=True    timeout=300    provisioning_operation=activate    ignore_errors=False
	...    skip_autocorrection=False
	${dict}=	Configuration Get    config_device=netact1    dist_name=PLMN-PLMN/MRBTS-3290/NRBTS-3290/SERVEDAMF-1		alias=lab2006_omc_user
	${amfip}=    BuiltIn.Evaluate    ${dict}.get("amfIPAddressResolved")

Online Modification with Different AMF FQDN
	Configuration Manage    config_device=netact1    operation=Edit    plan_name=fw_plan    alias=lab2006_omc_user    config=${Different_AMF}
	...    delete_plan=False    should_provision=True    timeout=300    provisioning_operation=activate    ignore_errors=False
	...    skip_autocorrection=False
	${dict}=	Configuration Get    config_device=netact1    dist_name=PLMN-PLMN/MRBTS-3290/NRBTS-3290/SERVEDAMF-1		alias=lab2006_omc_user
	${nglink}=    BuiltIn.Evaluate    int(${dict}.get('ngLinkStatus', '0'))
	Should Be Equal    ${nglink}    ${0}
	Wait Until Keyword Succeeds   960 sec	30 sec	Verify Ems Alarm   config_device=netact1        faultid=7305       occurrences=1
	...    should_exist=${True}       alias=lab2006_omc_user
	Configuration Manage    config_device=netact1    operation=Edit    plan_name=fw_plan    alias=lab2006_omc_user    config=${AMF_FQDN}
    ...    delete_plan=False    should_provision=True    timeout=300    provisioning_operation=activate    ignore_errors=False
	...    skip_autocorrection=False
	Verify Ems Alarm   config_device=netact1        faultid=7305	should_exist=${False}       alias=lab2006_omc_user

Modification with Wrong AMF FQDN
	Configuration Manage    config_device=netact1    operation=Edit    plan_name=iv_fw_plan    alias=lab2006_omc_user    config=${Wrong_AMF}
	...    delete_plan=False    should_provision=True    timeout=300    provisioning_operation=activate    ignore_errors=False
	...    skip_autocorrection=False
	Verify Ems Alarm   config_device=netact1        faultid=7334       occurrences=1       should_exist=${True}       alias=lab2006_omc_user
	Configuration Manage    config_device=netact1    operation=Edit    plan_name=fw_plan    alias=lab2006_omc_user    config=${AMF_FQDN}
	...    delete_plan=False    should_provision=True    timeout=300    provisioning_operation=activate    ignore_errors=False
	...    skip_autocorrection=False
	Wait Until Keyword Succeeds		30 sec	10 sec	Verify Ems Alarm   config_device=netact1        faultid=7334	should_exist=${False}
	...    alias=lab2006_omc_user
	${dict}=	Configuration Get    config_device=netact1    dist_name=PLMN-PLMN/MRBTS-3290/NRBTS-3290/SERVEDAMF-1		alias=lab2006_omc_user
	${amfip}=    BuiltIn.Evaluate    ${dict}.get("amfIPAddressResolved")
	${dict}=	Configuration Get    config_device=netact1    dist_name=PLMN-PLMN/MRBTS-3290/NRBTS-3290/SERVEDAMF-1		alias=lab2006_omc_user
	${nglink}=    BuiltIn.Evaluate    int(${dict}.get('ngLinkStatus', '1'))
	Should Be Equal    ${nglink}    ${1}

Lock and unlock SERVEDAMF administrative state
	Configuration Manage    config_device=netact1    operation=Edit    plan_name=fw_plan    alias=lab2006_omc_user    config=${AMF_Lock}
	...    delete_plan=False    should_provision=True    timeout=300    provisioning_operation=activate    ignore_errors=False
	...    skip_autocorrection=False
	${dict}=	Configuration Get    config_device=netact1    dist_name=PLMN-PLMN/MRBTS-3290/NRBTS-3290/SERVEDAMF-1		alias=lab2006_omc_user
	${nglink}=    BuiltIn.Evaluate    int(${dict}.get('ngLinkStatus', '0'))
	Should Be Equal    ${nglink}    ${0}
	Configuration Manage    config_device=netact1    operation=Edit    plan_name=fw_plan    alias=lab2006_omc_user    config=${AMF_Unlock}
	...    delete_plan=False    should_provision=True    timeout=300    provisioning_operation=activate    ignore_errors=False
	...    skip_autocorrection=False
	${dict}=	Configuration Get    config_device=netact1    dist_name=PLMN-PLMN/MRBTS-3290/NRBTS-3290/SERVEDAMF-1		alias=lab2006_omc_user
	${nglink}=    BuiltIn.Evaluate    int(${dict}.get('ngLinkStatus', '1'))
	Should Be Equal    ${nglink}    ${1}

Perform Basic Commissioning
	Perform Commissioning		scf_file=${Basic_SCF_ASOH}	verify_bts_status=False     timeout=1200
	Sleep	250
	Call Setup		nr=airphone_sa:data      parallel=${False}    verify_attach=${False}   attach=${False}    ipv4_or_6=ipv4       timeout=300
	Verify Bts Status       req_rat=nr      should_be_onair=${True}        timeout=90        alias=default

Perform AMF FQDN Recommissioning
	Perform Recommissioning        type=delta      delta_file=${CB009901_AMF_FQDN_ASOH}       skip_parameter_relation_errors=${True}      timeout=300
	Verify AMF FQDN Resolved IP Address

Verify AMF FQDN Resolved IP Address
	${amfIPAddressResolved}=     Get Parameter     param_path=SERVEDAMF-1:amfIPAddressResolved
	Should Be Equal     ${amfIPAddressResolved}       ${amfIPAddress_ipv4_ASOH}
	${amfIPAddressResolved}=     Get Parameter     param_path=SERVEDAMF-2:amfIPAddressResolved
	Should Be Equal     ${amfIPAddressResolved}       ${amfIPAddress_ipv6_ASOH}

Verify nglink status
    [Arguments]    ${status}    ${AMFID}
    ${nglink}=    Query Admin Infomodel    query=get object //SERVEDAMF_R-${AMFID}
    Should Be Equal    ${nglink["ngLinkStatus"]}    ${status}

Online Modification AMF FQDN to AMF IP
	Perform Recommissioning        type=delta      delta_file=${Wrong_Adding_IPv4_IPv6_AMF_IP_ASOH}       skip_parameter_relation_errors=${True}
	...    timeout=300
	Verify nglink status	Inactive	1
	Verify nglink status	Inactive	2
	Perform Recommissioning        type=delta      delta_file=${Adding_IPv4_IPv6_AMF_IP_ASOH}       skip_parameter_relation_errors=${True}
	...    timeout=300
	Verify nglink status	Active	1
	Verify nglink status	Active	2

Create Wrong FQDN Check Status
	Perform Recommissioning        type=delta      delta_file=${Wrong_AMF_FQDN_ASOH}       skip_parameter_relation_errors=${True}      timeout=300
	Sleep	30
	Run Keyword And Ignore Error	Verify Alarm	faultid=7334    occurrences=2
	Verify nglink status	Active	1
	Verify nglink status	Active	2
	Perform Recommissioning        type=delta      delta_file=${Delete_SERVEDAMF_1_ASOH}       skip_parameter_relation_errors=${True}
	...    timeout=300
	Run Keyword And Ignore Error	Verify Alarm	faultid=7334    occurrences=1
	Perform Recommissioning        type=delta      delta_file=${Add_SERVEDAMF_With_Valid_FQDN_ASOH}       skip_parameter_relation_errors=${True}
	...    timeout=300
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
	Reset Bts   verify_bts=${False}
	Sleep	200
	Verify Bts Status       req_rat=nr      should_be_onair=${True}        timeout=90        alias=default
	Verify AMF FQDN Resolved IP Address
	Verify nglink status	Active	1
	Verify nglink status	Active	2