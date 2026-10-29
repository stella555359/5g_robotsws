*** Settings ***
Documentation
...		[Author]     		        "Pranitha"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "11:01:2023"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB008639"
...     [Validated_TestLine]        "KVM08-TRSIV-TL9047"
...		[Procedure]   		        "Auto_Verification of manual and auto cert installation along with sw upgrade and rollback"
...     [Precondition]              "ASIL & ASOE hardware is required"
...     [Config]    	            "CRLH-1 param should be configured in SCF"
...     [Function_Hash_Tags]        "RSA, Certificates, CMP Configuration"


Variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Library         Collections
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource    	${CURDIR}/../resources/Admin_Common_Library.robot


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND	    Teardown Oamops




*** Test Cases ***
[1]CB008639_Auto_Verification of manual and auto cert installation along with sw upgrade and rollback
	Perform Commissioning       scf_file=${basic_cmp_scf}   verify_bts_status=False     timeout=400     alias=default
    Sleep  600
	Restore all Certificate
	Read CMP Parameters     	RSA
	Instal Additional certificates		RSA
	Tigger IR_KUR 			RSA 	install_cmp_certificate
	verify cmp status		RSA		CMP_InitializationOK
	Tigger IR_KUR 			RSA 	cmp_update_key
	verify cmp status		RSA		CMP_KeyUpdateOK
	Verify crl update and check for certificate details	 	RSA
	Block sha1 certificate and verify certificate installation
	Block RSA 2k certificate and verify certificate installation
	Perform software upgrade and rollback and check certificate details
	UnBlock sha1 certificate and verify certificate installation
	UnBlock RSA 2k certificate and verify certificate installation


*** Keywords ***

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

Instal Additional certificates
	[Arguments]			${CertType}		${Operation}=install_certificate
	Certificate Configure	  key_pool_type=${CertType} 		operation=${Operation}		cert_file=${block_sha1}
	...	cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Certificate Configure	  key_pool_type=${CertType} 		operation=${Operation}		cert_file=${block_sha2k}
	...	cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Certificate Configure	  key_pool_type=${CertType} 		operation=${Operation}		cert_file=${block_sha1k}
	...	cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Certificate Configure	  key_pool_type=${CertType} 		operation=${Operation}		cert_file=${block_sha4k}
	...	cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Certificate Configure     operation=${Operation}     cert_file=${4k_Cert}    cert_type=BtsTrustChain     	cert_format=P12
	... 	password=${4k_Cert_Password}


Tigger IR_KUR
	[Arguments]			${CertType}		${Operation}
    Traffic Capture Start       capture_device=bts      alias=${cmp_alias}
    Certificate Configure       operation=${Operation}   	key_pool_type=${CertType}		timeout=100
	${cmp_pcap_log}=	Traffic Capture Stop        alias=${cmp_alias}
	Set Suite Variable    ${cmp_pcap_log}    ${cmp_pcap_log}
	[Teardown]    Run Keyword And Ignore Error		Traffic Capture Stop		alias=${cmp_alias}

verify cmp status
    [Arguments]   ${certType}	 ${CMP_status_check}
    Sleep   60
	Run keyword if  '${certType}' == 'RSA'    		Set Suite Variable  	${cmp_state_path}  ${cmp_r_moc_path}
    ${cmp_state_var} =    Query Admin Infomodel    query=get object ${cmp_state_path}
    Should be equal    ${cmp_state_var['state']}    ${CMP_status_check}

Verify crl update and check for certificate details
	[Arguments]			${CertType}
	Perform Recommissioning        type=delta           delta_file=${crl_delta}		skip_parameter_relation_errors=${True}		timeout=300
	Certificate Configure       operation=install_cmp_certificate    key_pool_type=${CertType}		timeout=60
	Certificate Configure       operation=cmp_update_key             key_pool_type=${CertType}		timeout=60
	${cert_details}=    Certificate Configure       operation=get_certificate_list   	key_pool_type=${CertType}		type=TA      timeout=100

Block sha1 certificate and verify certificate installation
	Perform Recommissioning        type=param           param_path=${block_sha1_path}:blockSha1CertChain     operation=update
    ...    value=${true}    timeout=60
	Restore all Certificate
	Read CMP Parameters     	RSA
	Instal Additional certificates1	     RSA
	Tigger IR_KUR 			RSA 	install_cmp_certificate
	verify cmp status		RSA		CMP_InitializationOK
	Tigger IR_KUR 			RSA 	cmp_update_key
	verify cmp status		RSA		CMP_KeyUpdateOK

Block RSA 2k certificate and verify certificate installation
	Perform Recommissioning        type=param           param_path=${block_sha1_path}:blockRsaKeyLengthBelow2048     operation=update
    ...    value=${true}    timeout=60
	Restore all Certificate
	Read CMP Parameters     	RSA
	Instal Additional certificates2	    RSA
	Tigger IR_KUR 			RSA 	install_cmp_certificate
	verify cmp status		RSA		CMP_InitializationOK
	Tigger IR_KUR 			RSA 	cmp_update_key
	verify cmp status		RSA		CMP_KeyUpdateOK

Perform software upgrade and rollback and check certificate details
    fetch cert details  RSA
	Run Keyword And Ignore Error             Perform Software Download And Update	           package=${package}        timeout=1200
	Sleep	300
	Run Keyword And Ignore Error		Rollback Software               timeout=1200       alias=default
	Sleep	300
    ${cert_details}=    Certificate Configure       operation=get_certificate_list      key_pool_type=${CertType}
	...	type=TA      timeout=100
	fetch cert details after  RSA
	Should Be Equal     ${operator_certs}    ${operator_certs_after}

UnBlock sha1 certificate and verify certificate installation
	Perform Recommissioning        type=param           param_path=${block_sha1_path}:blockSha1CertChain     operation=update
    ...    value=${false}    timeout=60
	Restore all Certificate
	Read CMP Parameters     	RSA
	Instal Additional certificates3	    RSA
	Tigger IR_KUR 			RSA 	install_cmp_certificate
	verify cmp status		RSA		CMP_InitializationOK
	Tigger IR_KUR 			RSA 	cmp_update_key
	verify cmp status		RSA		CMP_KeyUpdateOK

UnBlock RSA 2k certificate and verify certificate installation
	Perform Recommissioning        type=param           param_path=${block_sha1_path}:blockSha1CertChain     operation=update
    ...    value=${true}    timeout=60
	Perform Recommissioning        type=param           param_path=${block_sha1_path}:blockRsaKeyLengthBelow2048     operation=update
    ...    value=${false}    timeout=60
	Restore all Certificate
	Read CMP Parameters     	RSA
	Instal Additional certificates4	       RSA
	Tigger IR_KUR 			RSA 	install_cmp_certificate
	verify cmp status		RSA		CMP_InitializationOK
	Tigger IR_KUR 			RSA 	cmp_update_key
	verify cmp status		RSA		CMP_KeyUpdateOK


Restore all Certificate
	certificate configure          operation=restore_vendor_certificate
	Sleep   10
	certificate configure          operation=delete_cert        all_certs=${True}
	Sleep   10

Get RSA details
	${cmp_ip_dict} =    Query Admin Infomodel    query=get object ${cmp_ip_path}    timeout=60
    ${primary_cmp_ip}=      Get From Dictionary    dictionary=${cmp_ip_dict}    key=serverHost
    ${secondary_cmp_ip}=    Get From Dictionary    dictionary=${cmp_ip_dict}    key=secondaryServerHost
	Set Suite Variable    ${primary_cmp_ip}    ${primary_cmp_ip}
	Set Suite Variable    ${secondary_cmp_ip}    ${secondary_cmp_ip}

Instal Additional certificates1
	[Arguments]			${CertType}		${Operation}=install_certificate
	Run keyword And Expect Error	${weak_signature}    	Certificate Configure	  key_pool_type=${CertType} 		operation=${Operation}
	...	cert_file=${block_sha1}		    cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Certificate Configure	  key_pool_type=${CertType} 		operation=${Operation}		cert_file=${block_sha2k}
	...	cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Run keyword And Expect Error	${weak_signature}		Certificate Configure	  key_pool_type=${CertType} 		operation=${Operation}
	...	cert_file=${block_sha1k}		cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Certificate Configure	  key_pool_type=${CertType} 		operation=${Operation}		cert_file=${block_sha4k}
	...	cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Certificate Configure     operation=${Operation}     cert_file=${4k_Cert}    cert_type=BtsTrustChain     	cert_format=P12
	... 	password=${4k_Cert_Password}

Instal Additional certificates2
	[Arguments]			${CertType}		${Operation}=install_certificate
	Run keyword And Expect Error	${length_not_supported}    	Certificate Configure	  key_pool_type=${CertType}
	...	operation=${Operation}		cert_file=${block_sha1}		    cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Run keyword And Expect Error	${length_not_supported}    	Certificate Configure	  key_pool_type=${CertType}
	...	operation=${Operation}		cert_file=${block_sha2k}		cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Run keyword And Expect Error	${weak_signature}    	Certificate Configure	  key_pool_type=${CertType}
	...	operation=${Operation}		cert_file=${block_sha1k}		cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Certificate Configure	  key_pool_type=${CertType} 		operation=${Operation}		cert_file=${block_sha4k}
	...	cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Certificate Configure     operation=${Operation}     cert_file=${4k_Cert}    cert_type=BtsTrustChain     	cert_format=P12
	... 	password=${4k_Cert_Password}

Instal Additional certificates3
	[Arguments]			${CertType}		${Operation}=install_certificate
	Run keyword And Expect Error	${length_not_supported}    	Certificate Configure	  key_pool_type=${CertType}
	...	operation=${Operation}		cert_file=${block_sha1}		    cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Run keyword And Expect Error	${length_not_supported}    	Certificate Configure	  key_pool_type=${CertType}
	...	operation=${Operation}		cert_file=${block_sha2k}		cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Certificate Configure	  key_pool_type=${CertType} 		operation=${Operation}		cert_file=${block_sha1k}
	...	cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Certificate Configure	  key_pool_type=${CertType} 		operation=${Operation}		cert_file=${block_sha4k}
	...	cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Certificate Configure     operation=${Operation}     cert_file=${4k_Cert}    cert_type=BtsTrustChain     	cert_format=P12
	... 	password=${4k_Cert_Password}

Instal Additional certificates4
	[Arguments]			${CertType}		${Operation}=install_certificate
	Run keyword And Expect Error	${weak_signature}    	Certificate Configure	  key_pool_type=${CertType}
	...	operation=${Operation}		cert_file=${block_sha1}		    cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Certificate Configure	  key_pool_type=${CertType} 		operation=${Operation}		cert_file=${block_sha2k}
	...	cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Run keyword And Expect Error	${weak_signature}    	Certificate Configure	  key_pool_type=${CertType}
	...	operation=${Operation}		cert_file=${block_sha1k}		cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Certificate Configure	  key_pool_type=${CertType} 		operation=${Operation}		cert_file=${block_sha4k}
	...	cert_type=AdditionalCa		cert_format=${Cert_format}
    Sleep   60
	Certificate Configure     operation=${Operation}     cert_file=${4k_Cert}    cert_type=BtsTrustChain     	cert_format=P12
	... 	password=${4k_Cert_Password}

fetch cert details
	[Arguments]		 ${CertType}
	${certificate_Details}=		certificate configure 		cert_type=${Cert_type}		operation=get_certificate_details
	...		source=Operator	    Subject=CMPECDSA_TA	    type=TrustAnchor
    log     ${certificate_Details}
	${Certificate_list}=      Certificate Configure     cert_type=${Cert_type}		operation=get_certificate_list   type=TA     timeout=120
	Log     ${Certificate_list}
    @{operator_certs}=     Create List
	FOR   ${Certificate}  IN   @{Certificate_list}
	      Log        ${Certificate}
          ${vendor}=     Get From Dictionary     ${Certificate}        source
          ${cert_name}=    Get From Dictionary      ${Certificate}     issuedTo
          ${Result}=    Remove String    ${cert_name}    ${SPACE}
          Run Keyword If   '${vendor}' == 'Operator'    Append To List    ${operator_certs}    ${Result}
    END
    Set Suite Variable      ${operator_certs}         ${operator_certs}

fetch cert details after
	[Arguments]		 ${CertType}
	${certificate_Details}=		certificate configure 		cert_type=${Cert_type}		operation=get_certificate_details
	...     source=Operator	    Subject=CMPECDSA_TA	    type=TrustAnchor
    log     ${certificate_Details}
	${Certificate_list}=      Certificate Configure     cert_type=${Cert_type}		operation=get_certificate_list   type=TA     timeout=120
	Log     ${Certificate_list}
    @{operator_certs}=     Create List
	FOR   ${Certificate}  IN   @{Certificate_list}
	      Log        ${Certificate}
          ${vendor}=     Get From Dictionary     ${Certificate}        source
          ${cert_name}=    Get From Dictionary      ${Certificate}     issuedTo
          ${Result}=    Remove String    ${cert_name}    ${SPACE}
          Run Keyword If   '${vendor}' == 'Operator'    Append To List    ${operator_certs}    ${Result}
    END
    Set Suite Variable      ${operator_certs_after}         ${operator_certs}
