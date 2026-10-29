*** Settings ***
Documentation
...			[Procedure]		 			"CertMan CRL Download Failure"
...			[Date]			 			"Date of creation 25-11-2017"
...			[Author]         			"Nupur"
...         [QC_Path]                   "QC_Path in Test Plan"
...		    [QC_ID]			            "QC_ID in Test Lab for reporting"
...			[Funtion_Hash_Tags]			"CMP CRL "

Library			  Collections

variables      ta_e2e_bts_trs_fw
Resource      ${CURDIR}/../resources/common_keywords.robot


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND		Teardown Oamops

*** Test Cases ***
[1][1.0] SR001344_Verification of Manual and Auto CRL Download
	Perform Commissioning		 scf_file=${Manual_Auto_CRL_Download}     verify_bts_status=False  	  	timeout=600
	sleep 		240
	Certificate Configure       operation=install_cmp_certificate
	Sleep    60
	Get mplaneIP
	Configure and verify CRL download
    Reset    operation=reset_bts       should_be_onair=False
    Sleep   240
    Verify Status for CRL Failure
    Verify Auto CRL update
	Verify No Periodic update
    Verify CRL CA Signature Failed
    Certificate Configure       operation=install_cmp_certificate
    Sleep    60
	Configure CRLDP 						${Unsupported_HTTP_URL}
	Trigger and verify CRL update for Invalid CRL			Unsupported_HTTP_URL
	Verify Status for CRL Failure			${Unsupported_HTTP_Failure}
	Configure and verify CRL download
	Configure CRLDP 						${Unreachable_HTTP_URL}
	Trigger and verify CRL update for Invalid CRL			Unreachable_HTTP_URL
	Verify Status for CRL Failure			${Unreachable_HTTP_Failure}
	Configure and verify CRL download
	Configure CRLDP 						${URI_format_error}
	Trigger and verify CRL update for Invalid CRL			URI_format_error
	Verify Status for CRL Failure			${URI_format_error_Failure}
	Configure and verify CRL download
	Configure CRLDP 						${InvalidDNS_HTTP_URL}
	Trigger and verify CRL update for Invalid CRL			InvalidDNS_HTTP_URL
 	Verify Status for CRL Failure			${InvalidDNS_HTTP_Failure}
	Configure CRLDP 						${Empty_HTTP_URL}
 	Trigger and verify CRL update for Invalid CRL			Empty_HTTP_URL
    Verify Status for CRL Failure			${Empty_HTTP_Failure}
	Configure and verify CRL download
 	Configure CRLDP 						${Invalid_LDAP_URL}
 	Trigger and verify CRL update for Invalid CRL			Invalid_LDAP_URL
	Verify Status for CRL Failure			${Invalid_LDAP_Failure}
	Configure CRLDP 						${LDAP_URL}
	Trigger and verify CRL update			LDAP_URL
	Verify Status for CRL Failure
	Verify CRL download with ldap
    Change CRL Protocol and Check CRL Failure

*** Keywords ***
Get mplaneIP
    ${mplaneObjects_dict} =    Query Admin Infomodel    query=get list ${mplane_moc}
	FOR    ${eachMplane}    IN    @{mplaneObjects_dict}
    	${mplane_ipv4_ip_admin}=    Get From Dictionary    dictionary=${eachMplane}    key=mPlaneIpv4AddressDN
		${mplane}=		Query Admin Infomodel    query=get param ${mplane_ipv4_ip_admin}:localIpAddr
		Set Suite Variable		${mplane}		${mplane}
    END

Configure and verify CRL download
	Configure CRLDP 					${HTTP_URL}
	Trigger and verify CRL update
	Verify Status for CRL Failure		None
	Verify CRL download with http

Change CRL Protocol and Check CRL Failure
    Configure CRLDP                     ${HTTP_URL}
    Perform Recommissioning         type=param      param_path=${CRL_Protocol}       value=LDAP       operation=update
    Sleep   60
    Trigger and verify CRL update for Invalid CRL           Unsupported_HTTP_URL
    Verify Status for CRL Failure           ${Unsupported_HTTP_Failure}
    Perform Recommissioning         type=param      param_path=${CRL_Protocol}       value=LDAP_OR_HTTP       operation=update
    Configure and verify CRL download

Verify CRL CA Signature Failed
    certificate configure    operation=delete_cert   all_certs=${True}
    Trigger and verify CRL update for Invalid CRL
    Verify Status for CRL Failure           ${CA_Signature_Failed}

Verify Auto CRL update
    [Arguments]			${value}=1
    Perform Recommissioning 		type=param		param_path=${CRL_update_time}		value=${value}		 operation=update
	Trigger and verify CRL update
	Verify Status for CRL Failure		None
	Verify CRL download with http
	Traffic Capture Start		capture_device=vm_eth3_interface     alias=auto_crl
	Sleep   ${value} hour
	${CRL_log}=	Traffic Capture Stop		alias=auto_crl
	Set Suite Variable    ${CRL_log}  	${CRL_log}
	Verify CRL download with http

Verify no Periodic update
    [Arguments]			${orig_value}=1    ${value}=0
    Perform Recommissioning 		type=param		param_path=${CRL_update_time}		value=${value}		 operation=update
	Traffic Capture Start		capture_device=vm_eth3_interface     alias=no_auto_crl
	Sleep    ${orig_value} hour
	${CRL_log}=	Traffic Capture Stop		alias=no_auto_crl
	Set Suite Variable    ${CRL_log}  	${CRL_log}
	Verify No CRL download with http

Configure CRLDP
	[Arguments]			${value}
	Perform Recommissioning 		type=param		param_path=${CRLDP_Path}		value=${value}		 operation=update        timeout=120

Trigger and verify CRL update
	[Arguments]		${alias}=CRL_Download
	Traffic Capture Start		capture_device=vm_eth3_interface     alias=${alias}
    certificate configure 		operation=update_certificate_revocation_list      timeout=300
	Sleep	60
	${CRL_log}=	Traffic Capture Stop		alias=${alias}
	Set Suite Variable    ${CRL_log}  	${CRL_log}
	[Teardown]    Run Keyword And Ignore Error		Traffic Capture Stop		alias=${alias}

Trigger and verify CRL update for Invalid CRL
	[Arguments]		${alias}=CRL_Download
	Traffic Capture Start		capture_device=vm_eth3_interface     alias=${alias}
	Run Keyword and Expect Error      *Update certificate revocation list failed after maximum retries*  	certificate configure
	...       operation=update_certificate_revocation_list   timeout=300
	Sleep	60
	${CRL_log}=	Traffic Capture Stop		alias=${alias}
	Set Suite Variable    ${CRL_log}  	${CRL_log}
	[Teardown]    Run Keyword And Ignore Error		Traffic Capture Stop		alias=${alias}

Verify CRL download with ldap
    Analyse Pcap    pcap_filename=${CRL_log}    analysis=verify_ldap_bind_request    filter_file_name=${filter_file_name}
    Analyse Pcap    pcap_filename=${CRL_log}    analysis=verify_ldap_bind_response    filter_file_name=${filter_file_name}
    Analyse Pcap    pcap_filename=${CRL_log}    analysis=verify_ldap_search_request    filter_file_name=${filter_file_name}
    Analyse Pcap    pcap_filename=${CRL_log}    analysis=verify_ldap_search_resentry    filter_file_name=${filter_file_name}
    Analyse Pcap    pcap_filename=${CRL_log}    analysis=verify_ldap_search_resdone    filter_file_name=${filter_file_name}
    Analyse Pcap    pcap_filename=${CRL_log}    analysis=verify_ldap_unbind_request    filter_file_name=${filter_file_name}

Verify No CRL download with http
    Analyse Pcap    pcap_filename=${CRL_log}    analysis=verify_no_http_crl_req    filter_file_name=${filter_file_name}
    Analyse Pcap    pcap_filename=${CRL_log}    analysis=verify_no_http_crl_reply    filter_file_name=${filter_file_name}

Verify CRL download with http
    Analyse Pcap    pcap_filename=${CRL_log}    analysis=verify_http_crl_req    filter_file_name=${filter_file_name}
    Analyse Pcap    pcap_filename=${CRL_log}    analysis=verify_http_crl_reply    filter_file_name=${filter_file_name}

Verify Status for CRL Failure
	[Arguments]		${failure_reason}=None
	Set Suite Variable			${failure_reason}		${failure_reason}
	${request_message}=		certificate configure 		operation=get_certificate_revocation_list    timeout=300
	${len}=	Get Length	${request_message}
	${dict_val}=	Get From List	${request_message}	0
	Log	${dict_val}
	${stateInfo}=			Get From Dictionary		${dict_val}		stateInfo
	${reasoning}=			Get From Dictionary			${stateInfo}	reasoningStatus
	Set Suite Variable		${reasoning}		${reasoning}
	Run Keyword If  	${reasoning} == []		CRL Download success
	...		ELSE		Check CRL failure

CRL Download success
	Wait Until Keyword Succeeds    5 min    30 		Verify Alarm		faultid=${crl_update_failure}	 occurrences=${0}	should_exist=${False}

Check CRL failure
	${reasoning_val}=		Convert To String		${reasoning}
	@{reasoning_newlist}=		Split String	string=${reasoning_val}		separator='
	${reasoning_new}=			Set Variable	${reasoning_newlist}[1]
	Should Be Equal		${reasoning_new}		${failure_reason}
	Wait Until Keyword Succeeds    5 min    30 		Verify Alarm		faultid=${crl_update_failure}	 occurrences=${1}	should_exist=${True}

Install expiry certificate
	Run Keyword And Ignore Error	certificate configure    operation=delete_cert	source=Operator		subject=${expirycaCertSub}
	...    type=TrustAnchor
	Sleep	10
	Certificate Configure		operation=install_certificate		cert_file=${ExpirecaCert}		cert_type=AdditionalCa
	...    cert_format=PEM