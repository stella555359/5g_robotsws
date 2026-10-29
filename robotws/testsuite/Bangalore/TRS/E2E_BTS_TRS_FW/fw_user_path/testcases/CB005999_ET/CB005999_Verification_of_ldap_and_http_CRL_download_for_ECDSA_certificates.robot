*** Settings ***
Documentation
    ...     [Procedure]             "The test case is planned to verify CRL with manually and auto download"
    ...     [Date]                  "14-08-20"
    ...     [Author]                "Madhu Chinthakindi"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "CMP,CRL"
    ...     [Feature_ID]            "RP0001344"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "3248"
    ...     [Config]    	        "CRLDPCONFIG-1 param should be configured in SCF"
    ...     [Dependent files]       "CRLH_HTTP_Config.xml,CreateCRLDPConfig.xml,HTTP_URI_primary.xml,HTTP_URI_SecondaryCLDP.xml"



variables         ta_e2e_bts_trs_fw
Resource         taf/rfrl/trs_e2e_fw/setup/framework.robot
Library           Collections
Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/../resources/Admin_Common_Library.robot
Library           SSHLibrary
Resource    	${CURDIR}/../resources/common_keywords_5999.robot


Suite Setup       Run Keywords    Suite Setup Preconditions
        ...     AND         Setup Oamops
Suite Teardown    Run Keywords    Suite Teardown Postconditions
        ...     AND         Teardown Oamops


*** Test Cases ***
[1]CB005999_Verification of ldap and http CRL download for ECDSA certificates
	Perform Recommissioning		type=delta		delta_file=${certificate_config_crl}		skip_parameter_relation_errors=${True}		timeout=300
   	Restore all Certificate
    Get mplaneIP
    Read CMP Parameters     ECDSA
    Tigger IR_KUR           ECDSA   install_cmp_certificate
    verify cmp status       ECDSA   CMP_InitializationOK

	Traffic Capture Start       capture_device=bts               alias=${cmp_alias}

	Perform additional CA certificate operation and verify CRL update
    Perform CMP initialization and verify CRL update
    Perform CMP Keyupdate and verify CRL update

	${cmp_pcap_log}=	Traffic Capture Stop        alias=${cmp_alias}
	Set Suite Variable    ${cmp_pcap_log}    ${cmp_pcap_log}
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=ldap_crl_req         filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=ldap_crl_resp         filter_file_name=${traffic_filter_file_name}


*** Keywords ***

Get mplaneIP
	[Documentation]		This keyword is to get mplane ip from existing configuration
    ${mplaneObjects_dict} =    Query Admin Infomodel    query=get list ${mplane_moc}
	 FOR    ${eachMplane}    IN    @{mplaneObjects_dict}
    	${mplane_ipv4_ip_admin}=    Get From Dictionary    dictionary=${eachMplane}    key=mPlaneIpv4AddressDN
		${mplane}=		Query Admin Infomodel    query=get param ${mplane_ipv4_ip_admin}:localIpAddr
		Set Suite Variable		${mplane}		${mplane}
     END

Perfom CLRDP delta operation and verify CRL update
    [Documentation] To configure and verify CRL Download with HTTP protocol on primary CLDP
    Perform recommissioning			type=delta		delta_file=${CRLH_HTTP_Config}
   Trigger and verify CRL update
   Verify Status for CRL Failure

Trigger and verify CRL update
	[Documentation]		This keyword is trigger CRL Download and to capture wireshark logs

	certificate configure 		operation=update_certificate_revocation_list			timeout=500


Verify Status for CRL Failure
	[Documentation]		This keyword is to verify CRL Download failure reason from admin and to check the Alarms if any failures
	[Arguments]		${failure_reason}=None
	Set Suite Variable			${failure_reason}		${failure_reason}
	${certificate_Details}=		certificate configure 		operation=get_certificate_revocation_list
	${request_message}=		Get From Dictionary	${certificate_Details}	requestMessage
	${len}=	Get Length	${request_message}
	${dict_val}=	Get From List	${request_message}	0
	Log	${dict_val}


Perform CMP initialization and verify CRL update
	[Documentation]		This keyword is to Perform CMP initialization and verify CRL update
	Perform Recommissioning 		type=param		param_path=CRLDPCONFIG-1:primaryCRLDP		value=${http}  operation=update        timeout=500
	certificate configure 		operation=update_certificate_revocation_list			timeout=500
	Certificate Configure       operation=install_cmp_certificate   	key_pool_type=ECDSA		timeout=300
	CRL Download success
	Perform Recommissioning 		type=param		param_path=CRLDPCONFIG-1:primaryCRLDP		value=${ldap}  operation=update        timeout=120
	certificate configure 		operation=update_certificate_revocation_list			timeout=500
	Certificate Configure       operation=install_cmp_certificate   	key_pool_type=ECDSA		timeout=300
	CRL Download success

Perform CMP Keyupdate and verify CRL update
	[Documentation]		This keyword is to Perform CMP Keyupdate and verify CRL update
    Certificate Configure       operation=cmp_update_key       key_pool_type=ECDSA     timeout=300
	Perform Recommissioning 		type=param		param_path=CRLDPCONFIG-1:primaryCRLDP		value=${http}  operation=update        timeout=500
	certificate configure 		operation=update_certificate_revocation_list			timeout=500
	CRL Download success
	Perform Recommissioning 		type=param		param_path=CRLDPCONFIG-1:primaryCRLDP		value=${ldap}  operation=update        timeout=120
	certificate configure 		operation=update_certificate_revocation_list			timeout=500
	Certificate Configure       operation=cmp_update_key       key_pool_type=ECDSA     timeout=300
	CRL Download success

Perform additional CA certificate operation and verify CRL update
	[Documentation]		This keyword is to verify HTTP CRL for addition CA certificates and also to verify automatic trigger for restoration of
	Perform Recommissioning 		type=param		param_path=CRLDPCONFIG-1:primaryCRLDP		value=${http}  operation=update        timeout=500
	Certificate Configure		operation=install_certificate		cert_file=${AdditionalCACertCRLfile}  ert_type=AdditionalCa		cert_format=PEM
	Trigger and verify CRL update
	CRL Download success

Configure CRLDP
	[Documentation]		This keyword is to configure URI for the given inputs
	[Arguments]			${value}
	Perform Recommissioning 		type=param		param_path=${CRLDP_Path}		value=${value}		 operation=update        timeout=120

Verify CRL auto download
	[Documentation]		This keyword is to verify Automatioc CRL Download with HTTP protocol
    Perform Recommissioning 	type=param		param_path=CRLH-1:updatePeriod	  value=0	 operation=update        timeout=120
    Sleep      10
    Perform Recommissioning 	type=param	 	param_path=CRLH-1:updatePeriod	  value=1	 operation=update        timeout=120
    sleep       3540
    Traffic Capture Start		capture_device=bts_multicast		capture_filter=vlan and (host ${mplane} )			alias=autocrldownload
    sleep   360
	Verify Status for CRL Failure
	${CRL_log}=	Traffic Capture Stop		alias=autocrldownload
	Set Suite Variable    ${CRL_log}  	${CRL_log}

Check CRL failure
	[Documentation]		This keyword is to verify CRL Download failure reason from admin and to check the Alarms if any failures
	${reasoning_val}=		Convert To String		${reasoning}
	@{reasoning_newlist}=		Split String	string=${reasoning_val}		separator='
	${reasoning_new}=			Set Variable	@{reasoning_newlist}[1]
	Should Be Equal		${reasoning_new}		${failure_reason}
	Wait Until Keyword Succeeds    5 min    30 		Verify Alarm		faultid=61074	 occurrences=${1}		should_exist=${True}

CRL Download success
	Wait Until Keyword Succeeds    5 min    30 		Verify Alarm		faultid=61074	 		should_exist=${False}