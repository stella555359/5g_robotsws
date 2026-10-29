*** Settings ***
Documentation
     ...    [Procedure] "The test case is planned to validate emergency bypass with IPSec"
     ...    [Date] "30-09-2024"
     ...    [Author] "Ruchika"
     ...    [QC_Path] "QC_Path in Test Plan"
     ...    [QC_ID] "QC_ID in Test Lab for reporting"
     ...    [Funtion_Hash_Tags] "IPSEC with emergency_bypass"
     ...    [Feature_ID] "RP000439"
     ...    [Validation_status] "Validated"
     ...    [Validated_TestLine] "ASIM"
     ...    [Commissioning_comment] "This script requires 5G configuration with IPSEC Enabled."


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Emergencybypass_commonkeywords.robot

Suite Setup                 Pre-conditions for testsuite
Suite Teardown              Post-conditions for testteardown

***Test Cases***

[1][1.0] IPSec Emergency Bypass_RP000439

    Run     sudo cp /etc/ipsec.conf /etc/ipsec_bkp.conf
    Run     sudo cp ${Ipsec.conf} /etc/ipsec.conf
    Perform Recommissioning     type=delta  delta_file=${IPSec_upforembypass}    skip_parameter_relation_errors=${True}  timeout=300
    Certificate Configure    operation=install_certificate    cert_file=${BTSCertp12}   cert_type=BtsTrustChain     cert_format=P12
   ...       password=${BTSCertpass}
    BuiltIn.Sleep   50
    Run     sudo ip a a 10.0.1.7/32 dev eth3.650
    Run     sudo ipsec restart
    BuiltIn.Sleep   40
    Verify Ipsec Tunnels Status from Webem
	Log To Console	checking timer config
    Sleep   30
	Perform Recommissioning		type=param	param_path=IPSECC-1:ipSecEmBypassCtrlIpAddr	value=${dummyIp}		operation=update
    ...     timeout=600
    Disable Ipsec on Strongswan
	BuiltIn.Sleep	50

	${mplane_ip}=	Get parameter     param_path=MPLANENW-1:mPlaneIpv4AddressDN:localIpAddr
	Perform Recommissioning		type=param	param_path=IPSECC-1:ipSecEmBypassCtrlIpAddr	value=${dummyIp}	operation=update	timeout=600
	Perform Recommissioning		type=param	param_path=IPSECC-1:ipSecEmBypassPingTimer	value=${timer_1}	operation=update
	BuiltIn.Sleep	50
	ICMP Capture pingtimer		${dummyIp}
	Check Ping Retrytimer	timer=${timer_1}
	Perform Recommissioning		type=param	param_path=IPSECC-1:ipSecEmBypassPingTimer	value=${timer_2}	operation=update
	BuiltIn.Sleep	30
	ICMP Capture pingtimer		${dummyIp}
	Check Ping Retrytimer	timer=${timer_2}
	Perform Recommissioning		type=param	param_path=IPSECC-1:ipSecEmBypassPingTimer	value=${timer_3}	operation=update
	BuiltIn.Sleep	30
	ICMP Capture pingtimer		${dummyIp}
	Check Ping Retrytimer	timer=${timer_3}
	Perform Recommissioning		type=param	param_path=IPSECC-1:ipSecEmBypassPingTimer	value=${timer_4}	operation=update
	BuiltIn.Sleep	30
	ICMP Capture pingtimer		${dummyIp}
	Check Ping Retrytimer	timer=${timer_4}


	Perform Recommissioning		type=param	param_path=IPSECC-1:ipSecEmBypassCtrlIpAddr	value=${icmpServer}		operation=update
    ...     timeout=600
	BuiltIn.Sleep	120
	Verify Alarm	faultid=${ipsecEmergencyBypassActive}
	Verify Alarm	faultid=${dpdFaultId}		should_exist=${False}
    Enable Ipsec on Strongswan
	Perform Recommissioning		type=delta	delta_file=${add_embypassmoc}	timeout=600
	BuiltIn.Sleep	120
	${standbyState_check_dict} = 	Query Admin Infomodel	query=get object ${ipsec_path}
	${standbyState_check}=		Get From Dictionary	dictionary=${standbyState_check_dict}		key=ipSecEmBypassState
	Should Be Equal		${standbyState_check}		${standbyState}


