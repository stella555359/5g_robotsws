*** Settings ***
Documentation
...		[Author]     		        "Pranitha"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "30:05:2022"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB005999"
...     [Validated_TestLine]        "KVM58-TRSIV-TL3297"
...		[Procedure]   		        "CB005999_Verification of Additional intermediate CA and TA Certificates"
...     [Precondition]              "ASIB + ASIB hardware is required"
...     [Config]    	            "CRLH-1 param should be configured in SCF"
...     [Function_Hash_Tags]        "ECDSA, RSA, Certificates, CMP Configuration"


variables       ta_e2e_bts_trs_fw
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource    	${CURDIR}/../resources/Admin_Common_Library.robot

*** Keywords ***

Install Additional certificate
	[Arguments]				${Certificate}
	Certificate Configure		operation=install_certificate		cert_file=${Certificate}      cert_type=AdditionalCa      cert_format=PEM
	fetch cert details		ECDSA

Tigger IR_KUR
	[Arguments]			${CertType}		${Operation}
    Traffic Capture Start       capture_device=bts               alias=${cmp_alias}
    Certificate Configure       operation=${Operation}   	key_pool_type=${CertType}		timeout=300
	sleep   100
	${cmp_pcap_log}=	Traffic Capture Stop        alias=${cmp_alias}
	Set Suite Variable    ${cmp_pcap_log}    ${cmp_pcap_log}

Verify IR Operation
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_ir         filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_ip         filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_certConf   filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_pkiconf    filter_file_name=${traffic_filter_file_name}

Verify V6IR Operation
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_v6ir         filter_file_name=${traffic_filter_file_name}


Verify KUR Operation
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_kur          filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_kup          filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_certConf     filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_pkiconf      filter_file_name=${traffic_filter_file_name}

Verify V6KUR Operation
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_v6kur          filter_file_name=${traffic_filter_file_name}


Install certificate automatically for common pool
	Traffic Capture Start       capture_device=bts      alias=${cmp_alias}
	Perform Recommissioning		type=delta		delta_file=${cmprsa_delta}		skip_parameter_relation_errors=${True}		timeout=300
	Certificate Configure       operation=install_cmp_certificate    key_pool_type=${cmp_ECDSA}		timeout=60
	Certificate Configure       operation=cmp_update_key             key_pool_type=${cmp_ECDSA}		timeout=60
	${cmp_pcap_common}=Traffic Capture Stop        alias=${cmp_alias}
	Analyse pcap    pcap_filename=${cmp_pcap_common}      analysis=cmp_ir         filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap_common}      analysis=cmp_kur        filter_file_name=${traffic_filter_file_name}

Fetch CMPECDSA Certificate Name
	${cmpecdsa_casubjectname} =    Query Admin Infomodel    query=get object   ${CMPECDSA_path_casubjectname}
	Should Be Equal		'${cmpecdsa_casubjectname}'		'${casubjectname_cmpecdsa}'

verify cmp status
    [Arguments]   ${certType}	 ${CMP_status_check}
	Run keyword if  '${certType}' == 'ECDSA'    		Set Suite Variable 	${cmp_state_path}  ${cmpecdsa_r_moc_path}
	Run keyword if  '${certType}' == 'RSA'    		Set Suite Variable  	${cmp_state_path}  ${cmp_r_moc_path}
    ${cmp_state_var} =    Query Admin Infomodel    query=get object ${cmp_state_path}
	Sleep    100
    Should be equal    ${cmp_state_var['state']}    ${CMP_status_check}	   timeout=700

Restore all Certificate
	certificate configure    operation=restore_vendor_certificate
	Sleep 		10
	certificate configure    operation=delete_cert    all_certs=${True}
	Sleep     10

Configure PSK and Refnum
	[Arguments]		 ${CertType}
	Certificate Configure		operation=set_certificate_automatic_managment		key_pool_type=${CertType}
	...		reference_number=${ref_num_ecdsa}		preshared_key=${psk_ecdsa_key}

Get Mplane details
	[Arguments]		 ${Mplane_Ip_path}
    ${mplaneIp} =    Get Parameter    param_path=${Mplane_Ip_path}
	Set Suite Variable    ${srccmp_Ip}     ${mplaneIp}

Read CMP Parameters
	[Arguments]		 ${CertType}
	Get Mplane details	 ${Mplane_Ip_path}
    Get ECDSA details
	Get SrcCMPCrlConfigured details         ${SrcCMPCrlConfigured_IP_path}
    Run keyword If 		'${CertType}' == 'RSA'				Get RSA details
	Run keyword If 		'${CertType}' == 'ECDSA'				Get ECDSA details

Get SrcCMPCrlConfigured details
	[Arguments]		 ${SrcCMPCrlConfigured_IP_path}
    ${srcCmpCrlIp} =    Get Parameter    param_path=${SrcCMPCrlConfigured_IP_path}
    Set Suite Variable    ${srcCmpCrlIp}     ${srcCmpCrlIp}


Get ECDSA details
	${cmp_ip_dict} =    Query Admin Infomodel    query=get object ${cmp_ip_path}	 	timeout=60
    ${primary_cmpecdsa_ip}=      Get From Dictionary    dictionary=${cmp_ip_dict}    key=serverHost
    ${secondary_cmpecdsa_ip}=    Get From Dictionary    dictionary=${cmp_ip_dict}    key=secondaryServerHost
	Set Suite Variable    ${cmpecdsa_server_ip}    ${primary_cmpecdsa_ip}
	Set Suite Variable    ${secondary_cmp_ip}    ${secondary_cmpecdsa_ip}

Get RSA details
	${cmpecdsa_ip_dict} =    Query Admin Infomodel    query=get object ${cmpecdsa_ip_path}    timeout=60
    ${primary_cmpecdsa_ip}=      Get From Dictionary    dictionary=${cmpecdsa_ip_dict}    key=serverHost
    ${secondary_cmpecdsa_ip}=    Get From Dictionary    dictionary=${cmpecdsa_ip_dict}    key=secondaryServerHost
	Set Suite Variable    ${primary_cmp_ip}    ${primary_cmpecdsa_ip}
	Set Suite Variable    ${secondary_cmp_ip}    ${secondary_cmpecdsa_ip}

fetch cert details
	[Arguments]		 ${CertType}
	${certificate_Details}=		certificate configure 		cert_type=${Cert_type}		operation=get_certificate_details		source=Operator
	...	    Subject=CMPECDSA_TA	    type=TrustAnchor
    log     ${certificate_Details}
	${Certificate_list}=      Certificate Configure     cert_type=${Cert_type}		operation=get_certificate_list   type=TA     timeout=120
	Log     ${Certificate_list}
    @{operator_certs}=     Create List
	:FOR   ${Certificate}  IN   @{Certificate_list}
	\      Log        ${Certificate}
    \      ${vendor}=     Get From Dictionary     ${Certificate}        source
    \      ${cert_name}=    Get From Dictionary      ${Certificate}     issuedTo
    \      ${Result}=    Remove String    ${cert_name}    ${SPACE}
    \      Run Keyword If   '${vendor}' == 'Operator'    Append To List    ${operator_certs}    ${Result}
    Set Suite Variable      ${operator_certs}         ${operator_certs}

Tigger IR_KUR1
	[Arguments]			${CertType}		${Operation}
    Certificate Configure       operation=${Operation}      key_pool_type=${CertType}       timeout=300


Perfom CLRDP delta operation and verify CRL update
    [Documentation] To configure and verify CRL Download with HTTP protocol on primary CLDP
    Perform recommissioning			type=delta		delta_file=${CRLH_HTTP_Config}
   Trigger and verify CRL update
   Verify Status for CRL Failure

Trigger and verify CRL update
	certificate configure 		operation=update_certificate_revocation_list			timeout=500


Verify Status for CRL Failure
	[Arguments]		${failure_reason}=None
	Set Suite Variable			${failure_reason}		${failure_reason}
	${certificate_Details}=		certificate configure 		operation=get_certificate_revocation_list
	${request_message}=		Get From Dictionary	${certificate_Details}	requestMessage
	${len}=	Get Length	${request_message}
	${dict_val}=	Get From List	${request_message}	0
	Log	${dict_val}


Perform CMP initialization and verify CRL update
	Perform Recommissioning 		type=param		param_path=CRLDPCONFIG-1:primaryCRLDP		value=${http}
	...  	operation=update        timeout=500
	certificate configure 		operation=update_certificate_revocation_list			timeout=500
	Tigger IR_KUR 			ECDSA 	install_cmp_certificate
	CRL Download success
	Perform Recommissioning 		type=param		param_path=CRLDPCONFIG-1:primaryCRLDP		value=${ldap}
	... 	operation=update        timeout=120
	certificate configure 		operation=update_certificate_revocation_list			timeout=500
	Tigger IR_KUR 			ECDSA 	install_cmp_certificate
	CRL Download success


Perform CMP Keyupdate and verify CRL update
	Perform Recommissioning 		type=param		param_path=CRLDPCONFIG-1:primaryCRLDP		value=${http}
	...		operation=update        timeout=500
	certificate configure 		operation=update_certificate_revocation_list			timeout=500
	Tigger IR_KUR 			ECDSA 	cmp_update_key
	CRL Download success
	Perform Recommissioning 		type=param		param_path=CRLDPCONFIG-1:primaryCRLDP		value=${ldap}
	...		operation=update        timeout=120
	certificate configure 		operation=update_certificate_revocation_list			timeout=500
	Tigger IR_KUR 			ECDSA 	cmp_update_key
	CRL Download success

Perform additional CA certificate operation and verify CRL update
	Perform Recommissioning 		type=param		param_path=CRLDPCONFIG-1:primaryCRLDP		value=${http}
	...		operation=update        timeout=500
	Certificate Configure		operation=install_certificate		cert_file=${AdditionalCACertCRLfile}
	...		cert_type=AdditionalCa		cert_format=PEM
	Trigger and verify CRL update
	CRL Download success

Configure CRLDP
	[Arguments]			${value}
	Perform Recommissioning 		type=param		param_path=${CRLDP_Path}		value=${value}		 operation=update        timeout=120

Verify CRL auto download
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
	${reasoning_val}=		Convert To String		${reasoning}
	@{reasoning_newlist}=		Split String	string=${reasoning_val}		separator='
	${reasoning_new}=			Set Variable	@{reasoning_newlist}[1]
	Should Be Equal		${reasoning_new}		${failure_reason}
	Wait Until Keyword Succeeds    5 min    30 		Verify Alarm		faultid=61074	 occurrences=${1}		should_exist=${True}


CRL Download success
	Wait Until Keyword Succeeds    5 min    30 		Verify Alarm		faultid=61074	 		should_exist=${False}