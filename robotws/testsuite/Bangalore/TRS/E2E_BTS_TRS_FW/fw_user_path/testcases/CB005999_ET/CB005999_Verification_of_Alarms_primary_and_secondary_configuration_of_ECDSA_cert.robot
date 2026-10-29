*** Settings ***
Documentation
...		[Author]     		        "Pranitha"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "30:05:2022"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB005999"
...     [Validated_TestLine]        "KVM58-TRSIV-TL3297"
...		[Procedure]   		        "CB005999_Verification of both IR and KUR for for ECDSA certficates"
...     [Precondition]              "ASIB + ASIB hardware is required"
...     [Config]    	            "CRLH-1 param should be configured in SCF"
...     [Function_Hash_Tags]        "ECDSA, RSA, Certificates, CMP Configuration"

variables       ta_e2e_bts_trs_fw
Resource         taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource    	${CURDIR}/../resources/common_keywords_5999.robot
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource    	${CURDIR}/../resources/Admin_Common_Library.robot


Suite Setup       Run Keywords    Suite Setup Preconditions
        ...     AND         Setup Oamops
Suite Teardown    Run Keywords    Suite Teardown Postconditions
        ...     AND         Teardown Oamops



*** Test Cases ***
[1]CB005999_Verification of Alarms primary and secondary configuration of ECDSA certificates
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=False     timeout=400     alias=default
    Sleep   240
	Perform Recommissioning     type=delta      delta_file=${certificate_config}      skip_parameter_relation_errors=${True}      timeout=300
	Restore all Certificate
	Read CMP Parameters 	ECDSA
	Get Day Difference from Installed CA and Root CA Certificates
 	Trigger IR from BTS Security Account and Verify		ECDSA	2
	Schedule NE Certificate Update Time for Expiry and Verify Mismatch Alarm	ECDSA	 1
    Schedule CA Certificate Update Time and Verify Expiry Alarm     ECDSA

*** Keywords ***


Restore all Certificate
	certificate configure    operation=restore_vendor_certificate
	Sleep 		10
	certificate configure    operation=delete_cert    all_certs=${True}
	Sleep     10

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
    Run Keyword and Expect Error   *UnboundLocalError*   Certificate Configure
	...      operation=install_cmp_certificate   key_pool_type=${CertType}  timeout=600
    Sleep    100
    Run Keyword and Expect Error   *Failed*     Certificate Configure       operation=cmp_update_key             key_pool_type=${CertType}
	...		timeout=200

	Verify Alarm    faultid=61510   should_exist=${True}    occurrences=${alarm_count}
	Perform Recommissioning     type=delta      delta_file=${cmp_rsa_ecdsa_delta}      skip_parameter_relation_errors=${True}      timeout=300
	Certificate Configure       operation=install_cmp_certificate    key_pool_type=${CertType}		timeout=600
	Certificate Configure       operation=cmp_update_key             key_pool_type=${CertType}		timeout=600
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
verify cmp status
    [Arguments]   ${certType}	 ${CMP_status_check}
	Run keyword if  '${certType}' == 'ECDSA'    		Set Suite Variable 	${cmp_state_path}  ${cmpecdsa_r_moc_path}
	Run keyword if  '${certType}' == 'RSA'    		Set Suite Variable  	${cmp_state_path}  ${cmp_r_moc_path}
    ${cmp_state_var} =    Query Admin Infomodel    query=get object ${cmp_state_path}
    Should be equal    ${cmp_state_var['state']}    ${CMP_status_check}

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

Verify IR Operation
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_ir         filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_ip         filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_certConf   filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_pkiconf    filter_file_name=${traffic_filter_file_name}

Verify KUR Operation
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_kur          filter_file_name=${traffic_filter_file_name
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_kup          filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_certConf     filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap_log}      analysis=cmp_pkiconf      filter_file_name=${traffic_filter_file_name}

Tigger IR_KUR
	[Arguments]			${CertType}		${Operation}
        Traffic Capture Start       capture_device=bts      alias=${cmp_alias}
        Certificate Configure       operation=${Operation}   	key_pool_type=${CertType}		timeout=100
	${cmp_pcap_log}=	Traffic Capture Stop        alias=${cmp_alias}
	Set Suite Variable    ${cmp_pcap_log}    ${cmp_pcap_log}