*** Settings ***
Documentation
...		[Author]     		        "Pranitha"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "11:01:2023"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB008639"
...     [Validated_TestLine]        "KVM08-TRSIV-TL9047"
...		[Procedure]   		        "CB008639_Verification of TLS connection between BTS and WebEM using RSA key length 4K and 2k certs."
...     [Precondition]              "ASIL & ASOE hardware is required"
...     [Config]    	            "CRLH-1 param should be configured in SCF"
...     [Function_Hash_Tags]        "RSA, Certificates, CMP Configuration"


Variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Library 		Selenium2Library
Library     	Collections
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource    	${CURDIR}/../resources/Admin_Common_Library.robot

Suite Setup       Setup Oamops
Suite Teardown    Teardown Oamops



*** Test Cases ***
[1]CB008639_Auto_Verification of TLS connection between BTS and WebEM using RSA key length 4K and 2k certs.
	Perform Commissioning       scf_file=${cmp_scf}   verify_bts_status=False     timeout=400     alias=default
   Sleep  600
	Restore all Certificate
	Read CMP Parameters     	RSA
	Tigger IR_KUR 			RSA 	install_cmp_certificate
	verify cmp status		RSA		CMP_InitializationOK
	Tigger IR_KUR 			RSA 	cmp_update_key
	verify cmp status		RSA		CMP_KeyUpdateOK
	Instal Additional certificates		RSA
	Initiate TLS Connection
	Verify Wireshark for TLS Communication



*** Keywords ***

Restore all Certificate
	certificate configure          operation=restore_vendor_certificate
	Sleep   10
	certificate configure          operation=delete_cert        all_certs=${True}
	Sleep   10

Read CMP Parameters
	[Arguments]		 ${CertType}
	Get Mplane details	 ${Mplane_Ip_path}
   	Get SrcCMPCrlConfigured details         ${SrcCMPCrlConfigured_IP_path}
    Run keyword If 		'${CertType}' == 'RSA'				Get RSA details

Get SrcCMPCrlConfigured details
	[Arguments]		 ${SrcCMPCrlConfigured_IP_path}
    ${srcCmpCrlIp} =    Get Parameter    param_path=${SrcCMPCrlConfigured_IP_path}
    Set Suite Variable    ${srcCmpCrlIp}     ${srcCmpCrlIp}

Get Mplane details
	[Arguments]		 ${Mplane_Ip_path}
    ${mplaneIp} =    Get Parameter    param_path=${Mplane_Ip_path}
	Set Suite Variable    ${srccmp_Ip}     ${mplaneIp}

Tigger IR_KUR
	[Arguments]			${CertType}		${Operation}
    Traffic Capture Start       capture_device=bts_multicast      alias=${cmp_alias}
    Certificate Configure       operation=${Operation}   	key_pool_type=${CertType}		timeout=100
	${cmp_pcap_log}=	Traffic Capture Stop        alias=${cmp_alias}
	Set Suite Variable    ${cmp_pcap_log}    ${cmp_pcap_log}
	[Teardown]    Run Keyword And Ignore Error		Traffic Capture Stop		alias=${cmp_alias}

verify cmp status
    [Arguments]   ${certType}	 ${CMP_status_check}
	Run keyword if  '${certType}' == 'RSA'    		Set Suite Variable  	${cmp_state_path}  ${cmp_r_moc_path}
    ${cmp_state_var} =    Query Admin Infomodel    query=get object ${cmp_state_path}
    Should be equal    ${cmp_state_var['state']}    ${CMP_status_check}

Initiate TLS Connection
	Get Interface for TLS capture from DUT
	Traffic Capture Start        capture_device=tls_interface
	Open Browser		browser=firefox		url=https://192.168.255.129
	Input Text    login-username    Nemuadmin
	Input Text    login-password    nemuuser
	Click Button    Login
	Sleep		30
	Close Browser
	${pcap_file}=		Traffic Capture Stop
	Set Suite Variable		${pcap_file}		${pcap_file}

Get Interface for TLS capture from DUT
	Setup Remote Access    remote_device=bts
    ${interface}=		Execute Command On gnb		${interface_cmd}
	Set Suite Variable			${interface}		${interface}

Verify Wireshark for TLS Communication
	Analyse Pcap	pcap_filename=${pcap_file}	 analysis=tls_HelloClient	    filter_file_name=${filter_file_name}
	Analyse Pcap	pcap_filename=${pcap_file}	 analysis=tls_HelloServer	    filter_file_name=${filter_file_name}
	Analyse Pcap	pcap_filename=${pcap_file}	 analysis=tls_ApplicationData	    filter_file_name=${filter_file_name}
	Analyse Pcap	pcap_filename=${pcap_file}	 analysis=tls_KeyExchange_Server	    filter_file_name=${filter_file_name}
	Analyse Pcap	pcap_filename=${pcap_file}	 analysis=tls_KeyExchange_Client	    filter_file_name=${filter_file_name}

Get RSA details
	${cmp_ip_dict} =    Query Admin Infomodel    query=get object ${cmp_ip_path}    timeout=60
    ${primary_cmp_ip}=      Get From Dictionary    dictionary=${cmp_ip_dict}    key=serverHost
    ${secondary_cmp_ip}=    Get From Dictionary    dictionary=${cmp_ip_dict}    key=secondaryServerHost
	Set Suite Variable    ${primary_cmp_ip}    ${primary_cmp_ip}
	Set Suite Variable    ${secondary_cmp_ip}    ${secondary_cmp_ip}

Instal Additional certificates
	[Arguments]			${CertType}		${Operation}=install_certificate
	Certificate Configure	  key_pool_type=${CertType} 		operation=${Operation}		cert_file=${block_sha1}
	...     cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Certificate Configure	  key_pool_type=${CertType} 		operation=${Operation}		cert_file=${block_sha2k}
	...     cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Certificate Configure	  key_pool_type=${CertType} 		operation=${Operation}		cert_file=${block_sha1k}
	...     cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Certificate Configure	  key_pool_type=${CertType} 		operation=${Operation}		cert_file=${block_sha4k}
	...     cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Certificate Configure     operation=${Operation}     cert_file=${4k_Cert}    cert_type=BtsTrustChain     	cert_format=P12
	... 	password=${4k_Cert_Password}
