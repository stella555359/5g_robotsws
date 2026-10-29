*** Settings ***
Documentation
...		[Author]     		        "Abeer"
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
#Resource    	${CURDIR}/../resources/common_keywords.robot
#Resource    	${CURDIR}/../resources/Admin_Common_Library.robot
*** Keywords ***
Tigger IR_KUR
	[Arguments]			${CertType}		${Operation}
    Traffic Capture Start       capture_device=bts               alias=${cmp_alias}
    Certificate Configure       operation=${Operation}   	key_pool_type=${CertType}		timeout=100
	${cmp_pcap_log}=	Traffic Capture Stop        alias=${cmp_alias}
	Set Suite Variable    ${cmp_pcap_log}    ${cmp_pcap_log}

Verify IR Operation
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_ir         filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_ip         filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_certConf   filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_pkiconf    filter_file_name=${traffic_filter_file_name}

Verify KUR Operation
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_kur          filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_kup          filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_certConf     filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_pkiconf      filter_file_name=${traffic_filter_file_name}


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
    Should be equal    ${cmp_state_var['state']}    ${CMP_status_check}
Restore all Certificate
	certificate configure    operation=restore_vendor_certificate
	Sleep 		10
	certificate configure    operation=delete_cert    all_certs=${True}
	Sleep     10

Configure PSK and Refnum
	[Arguments]		 ${CertType}
	Certificate Configure		operation=set_certificate_automatic_managment		key_pool_type=${CertType}
...     reference_number=${ref_num_ecdsa}		preshared_key=${psk_ecdsa_key}

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
	${certificate_Details}=		certificate configure 		cert_type=${Cert_type}		operation=get_certificate_details
...     source=Operator	    Subject=CMPECDSA_TA	    type=TrustAnchor
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
    [Arguments]         ${CertType}     ${Operation}
    Certificate Configure       operation=${Operation}      key_pool_type=${CertType}       timeout=100

























