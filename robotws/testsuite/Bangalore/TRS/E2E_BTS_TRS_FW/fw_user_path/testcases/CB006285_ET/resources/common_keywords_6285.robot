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

*** Keywords ***

Perform CRLDP Update and check for dirrerent CRL check failures
    Perform CRLDP Update and check CRL update failure   ${Wrong_format}   ${UriFormatError}
    Perform CRLDP Update and check CRL update failure   ${wront_crl_server}  ${CrlDpUnreachable}
    Perform CRLDP Update and check CRL update failure   ${Wrong_crl_cert}    ${NoCRLfound}
	Perform CRLDP Update and check CRL update failure   ${Wrong_Protocol}    ${Wrong_Protocol_support}
	Perform CRLDP Update and check CRL update failure   ${Wrong_DNS_HTTP}    ${Wrong_DNS}
	Perform CRLDP Update and check CRL update failure   ${Wrong_LDAP_crl}    ${Wrong_LDAP}
	Perform CRLDP Update and check CRL update failure   ${Empty_CRL}    ${Empty_CRL_Failure}
Perform CRLDP Update and check CRL update failure
    [Arguments]         ${crl_update}   ${CRL_error}

    Configure CRLDP     ${crl_update}
    Run Keyword and Expect Error    *Update certificate revocation list failed after maximum retries*
	...  	certificate configure       operation=update_certificate_revocation_list            timeout=500
# Step 1: Call the keyword and capture the response
    ${response}=    Certificate Configure    operation=get_certificate_revocation_list    timeout=500

# Step 2: Get the first dictionary from the list
    ${first_item}=    Get From List    ${response}    0

# Step 3: Extract 'stateInfo' from the dictionary
    ${state_info}=    Get From Dictionary    ${first_item}    stateInfo

# Step 4: Extract 'reasoningStatus' from 'stateInfo'
    ${reasoning_status}=    Get From Dictionary    ${state_info}    reasoningStatus

# Step 5: Validate that 'UriFormatError' is present in 'reasoningStatus'
    Should Contain    ${reasoning_status}    ${CRL_error}
#    Wait Until Keyword Succeeds    5 min    30      Verify Alarm        faultid=61074           should_exist=${True}


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
	... 	reference_number=${ref_num_ecdsa}		preshared_key=${psk_ecdsa_key}

Get Mplane details
	[Arguments]		 ${Mplane_Ip_path}
    ${mplaneIp} =    Get Parameter    param_path=${Mplane_Ip_path}
	Set Suite Variable    ${srccmp_Ip}     ${mplaneIp}

Get mplaneIP
	[Documentation]		This keyword is to get mplane ip from existing configuration
    ${mplaneObjects_dict} =    Query Admin Infomodel    query=get list ${mplane_moc}
	 FOR    ${eachMplane}    IN    @{mplaneObjects_dict}
    	${mplane_ipv4_ip_admin}=    Get From Dictionary    dictionary=${eachMplane}    key=mPlaneIpv4AddressDN
		${mplane}=		Query Admin Infomodel    query=get param ${mplane_ipv4_ip_admin}:localIpAddr
		Set Suite Variable		${mplane}		${mplane}
     END

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
	${certificate_Details}=  certificate configure   cert_type=${Cert_type}  operation=get_certificate_details
	...	source=Operator  Subject=CMPECDSA_TA  type=TrustAnchor
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
	Perform Recommissioning 		type=param		param_path=CRLDPCONFIG-1:primaryCRLDP		value=${http}	 operation=update   timeout=500
	certificate configure 		operation=update_certificate_revocation_list			timeout=500
	Tigger IR_KUR 			ECDSA 	install_cmp_certificate
	CRL Download success
	Perform Recommissioning 		type=param		param_path=CRLDPCONFIG-1:primaryCRLDP		value=${ldap}  operation=update   timeout=120
	certificate configure 		operation=update_certificate_revocation_list			timeout=500
	Tigger IR_KUR 			ECDSA 	install_cmp_certificate
	CRL Download success

Perform CMP Keyupdate and verify CRL update
	[Documentation]		This keyword is to Perform CMP Keyupdate and verify CRL update
    Tigger IR_KUR           ECDSA   cmp_update_key
	Perform Recommissioning 		type=param		param_path=CRLDPCONFIG-1:primaryCRLDP		value=${http}  operation=update    timeout=500
	certificate configure 		operation=update_certificate_revocation_list			timeout=500
	CRL Download success
	Perform Recommissioning 		type=param		param_path=CRLDPCONFIG-1:primaryCRLDP		value=${ldap}  operation=update    timeout=120
	certificate configure 		operation=update_certificate_revocation_list			timeout=500
	Tigger IR_KUR 			ECDSA 	cmp_update_key
	CRL Download success

Perform additional CA certificate operation and verify CRL update
	[Documentation]		This keyword is to verify HTTP CRL for addition CA certificates and also to verify automatic trigger for restoration of
	Perform Recommissioning 		type=param		param_path=CRLDPCONFIG-1:primaryCRLDP		value=${http}		 operation=update    timeout=500
	Certificate Configure  operation=install_certificate  cert_file=${AdditionalCACertCRLfile}  cert_type=AdditionalCa		cert_format=PEM
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
    Traffic Capture Start		capture_device=bts_multicast		capture_filter=vlan and (host ${mplane} )	  alias=autocrldownload
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

Get Day Difference from Installed CA and Root CA Certificates
	Create Certificate List
    Get Certificates Time Details    CA
	Get Certificates Time Details    TA
	@{days_list}=     Create List
	FOR  ${Cert_Time}  IN   @{cert_time_list}
	   Execute command on ENodeB       date -u
	   Convert ENodeB Time to Standard Format      ${stdout}
	   Convert Certificate Time to Standard Format     ${Cert_Time}
       ${Date_Diff}=     Subtract Date From Date     ${Cert_DateTime}     ${Enb_DateTime}    verbose
	   @{Date_list}=     Split String     ${Date_Diff}       ${SPACE}
	   ${Day_Diff}=  Convert to Integer    ${Date_list}[0]
	   ${Day_Diff}=     Evaluate      ${Day_Diff}+1
	   Append To List    ${days_list}    ${Day_Diff}
    END
	Set Suite Variable      ${days_list}       ${days_list}

Create Certificate List
	@{cert_time_list}=     Create List
	Set Suite Variable      ${cert_time_list}     ${cert_time_list}

Get Certificates Time Details
	[Arguments]    ${type}
	${Certificate_list}=      Certificate Configure     operation=get_certificate_list   type=${type}     timeout=120
	Log     ${Certificate_list}
	FOR   ${Certificate}  IN   @{Certificate_list}
	      Log        ${Certificate}
          ${vendor}=     Get From Dictionary     ${Certificate}        source
          ${cert_time}=    Get From Dictionary      ${Certificate}     validTo
          Run Keyword If   '${vendor}' == 'Operator'    Append To List    ${cert_time_list}    ${cert_time}
    END
    Set Suite Variable      ${cert_time_list}       ${cert_time_list}

Convert ENodeB Time to Standard Format
    [Arguments]         ${enodeb_time}
    @{DateTime}=     Split String     ${enodeb_time}       ${SPACE}
    Run Keyword and Ignore Error       Remove Values From List      ${DateTime}     ${EMPTY}
    Log    ${DateTime}
    ${Enb_Date} =   Catenate   SEPARATOR=-    ${DateTime}[5]   ${DateTime}[1]   ${DateTime}[2]
    ${Enb_DateTime}=     Catenate    SEPARATOR=${SPACE}    ${Enb_Date}    ${DateTime}[3]
    ${Enb_DateTime}=      Convert Date      ${Enb_DateTime}      result_format=%Y-%m-%d %H:%M:%S.%f 	date_format=%Y-%b-%d %H:%M:%S
    Set Suite Variable   ${Enb_DateTime}      ${Enb_DateTime}
Convert Certificate Time to Standard Format
    [Arguments]         ${cert_time}
    ${Cert_DateTime}=      Convert Date       ${cert_time}      result_format=%Y-%m-%d %H:%M:%S.%f     date_format=%b %d %H:%M:%S %Y %Z
    Set Suite Variable   ${Cert_DateTime}     ${Cert_DateTime}

Schedule CA Certificate Update Time and Verify Expiry Alarm
	[Arguments]		 ${CertType}
	Run keyword if  '${CertType}' == 'ECDSA'    		 Set Suite Variable 	${caCert_path}  	 ${cmpecdsa_ip_path}
	Run keyword if  '${CertType}' == 'RSA'    		  	Set Suite Variable  	${caCert_path}  	 ${cmp_ip_path1}
	Set Suite Variable     ${count}    1
    Sort List  ${days_list}
    FOR  ${days}  IN   @{days_list}
	     ${count}=     Evaluate      ${count}+1
		 Perform Recommissioning  type=param  param_path=${caCert_path}:caCertificateUpdateTime   operation=update 	value=${days}    timeout=60
	     Sleep   30
	     Verify Alarm	faultid=61618	should_exist=${True}
	END

Trigger IR from BTS Security Account and Verify
	[Arguments]		 ${CertType}    ${alarm_count}
	Run keyword if  '${CertType}' == 'ECDSA'      Set Suite Variable     ${caCert_path}       ${cmpecdsa_ip_path}
	Run keyword if  '${CertType}' == 'RSA'        Set Suite Variable      ${caCert_path}       ${cmp_ip_path}
	Perform Recommissioning     type=delta      delta_file=${cmp_rsa_ecdsa_delta}      skip_parameter_relation_errors=${True}      timeout=300
	Certificate Configure       operation=install_cmp_certificate    key_pool_type=${CertType}		timeout=600
    Sleep   260
	Certificate Configure       operation=cmp_update_key             key_pool_type=${CertType}		timeout=600
	Perform Recommissioning     type=delta      delta_file=${cmp_wrong_delta}      skip_parameter_relation_errors=${True}      timeout=300
    Run Keyword and Expect Error   *UnboundLocalError*  	Certificate Configure       operation=install_cmp_certificate
	...  	key_pool_type=${CertType}		timeout=600
    Sleep    100
    Run Keyword and Expect Error   *Failed*     Certificate Configure       operation=cmp_update_key     key_pool_type=${CertType}		timeout=200
	Verify Alarm    faultid=61510   should_exist=${True}    occurrences=${alarm_count}
	Perform Recommissioning     type=delta      delta_file=${cmp_rsa_ecdsa_delta}      skip_parameter_relation_errors=${True}      timeout=300
	Certificate Configure       operation=install_cmp_certificate    key_pool_type=${CertType}		timeout=600
	Certificate Configure       operation=cmp_update_key             key_pool_type=${CertType}		timeout=600
    Sleep  100
	Verify Alarm    faultid=61510   should_exist=${False}
Schedule NE Certificate Update Time for Expiry and Verify Mismatch Alarm
    [Arguments]		 ${CertType}   ${alarm_count}
    Run keyword if  '${CertType}' == 'ECDSA'             Set Suite Variable     ${caCert_path}       ${cmpecdsa_ip_path1}
    Run keyword if  '${CertType}' == 'RSA'              Set Suite Variable      ${caCert_path}       ${cmp_ip_path1}
    ${End_Entity_dict}=    Certificate Configure    operation=get_certificate_details   type=EndEntity    source=Vendor
    ...     timeout=120
    Perform Recommissioning        type=param           param_path=${caCert_path}:neCertificateUpdateTime     operation=update
    ...    value=4000    timeout=60
    Sleep   30
    Verify Alarm	faultid=61618	should_exist=${True}   occurrences=${alarm_count}    severity=major
    Verify Alarm	faultid=61011	should_exist=${True}	occurrences=${alarm_count}    severity=major