*** Settings ***
Documentation
...            [Author]         "Nandini R"

*** Keywords ***
Bring IPv4 Control Server Up
	Run		sudo ip addr add 10.0.1.10/24 brd 10.0.1.255 dev eth3

Bring IPv6 Control Server Up
	Run		sudo ifconfig eth3 inet6 add fc00::10/124

Turn On Emergency Bypass Feature with IPv4
	[Arguments]	${control_server_IP}=10.0.1.10
	Perform Recommissioning		type=param		param_path=IPSECC-1:ipSecEmBypassCtrlIpAddr		operation=update	value=${control_server_IP}
	...		timeout=300

Turn On Emergency Bypass Feature with IPv6
	[Arguments]	${control_server_IP}=fc00::10
	Perform Recommissioning		type=param	param_path=IPSECC-1:ipSecEmBypassCtrlIpAddr		operation=update	value=${control_server_IP}
	...		timeout=300

Turn Off Emergency Bypass Feature with IPv6
	[Arguments]	${control_server_IP}=fc00::10
	Perform Recommissioning		type=param	param_path=IPSECC-1:ipSecEmBypassCtrlIpAddr		operation=delete	value=${control_server_IP}
	...		timeout=300

Verify Ipsec Emergency Bypass Probing state
	${probingState_check_dict}=		Query Admin Infomodel	query=get object ${ipsec_path}
	${probingState_check}=		Get From Dictionary		dictionary=${probingState_check_dict}	key=ipSecEmBypassState
	Should Be Equal		${probingState_check}	${probingState}

Verify Ipsec Emergency Bypass Off state
	${offState_check_dict}=		Query Admin Infomodel	query=get object ${ipsec_path}
	${offState_check}=		Get From Dictionary		dictionary=${offState_check_dict}	key=ipSecEmBypassState
	Should Be Equal		${offState_check}	${offState}

Verify Ipsec Emergency Bypass Standby state
	${standbyState_check_dict}=		Query Admin Infomodel	query=get object ${ipsec_path}
	${standbyState_check}=		Get From Dictionary		dictionary=${standbyState_check_dict}	key=ipSecEmBypassState
	Should Be Equal		${standbyState_check}	${standbyState}

Check if IPv6 Control server doesnot reply on ping
	Execute command on gNB		ping -c 5 fc00::10
	Should Match Regexp      '${stdout}'      0\\s*received

Check if IPv6 Control server replies on ping
	Execute command on gNB		ping -c 5 fc00::10
	Should Match Regexp      '${stdout}'      5\\s*received

Verify Ipsec Emergency Bypass Active state
	${ActiveState_check_dict}=	Query Admin Infomodel	query=get object ${ipsec_path}
	${ActiveState_check}=		Get From Dictionary	dictionary=${ActiveState_check_dict}	key=ipSecEmBypassState
	Should Be Equal		${ActiveState_check}	${activeState}
	Verify Alarm    faultid=${ipsecEmergencyBypassActive}