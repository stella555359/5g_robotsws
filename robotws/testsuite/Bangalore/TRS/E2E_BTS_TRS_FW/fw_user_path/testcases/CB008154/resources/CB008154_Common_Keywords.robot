*** Settings ***
Documentation
...		[Author]     		        "Nupur"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "19:05:2021"
...		[Feature_ID] 		        "CB006557"


variables           ta_e2e_bts_trs_fw

*** Variables ***
${tc_variables}		testcase_variables.json

*** Keywords ***
Verify Alarm for Manually Installed NE Certificate
	${Invalid_Day}=    Evaluate    ${Day_Diff}+1
    Perform Recommissioning        type=param           param_path=CMP-1:neCertificateUpdateTime     operation=update
    ...     value=${Invalid_Day}    timeout=60
	Sleep   30
	Verify Alarm	faultid=61618	should_exist=${True}	occurrences=1

Verify failed KUR Operation
	Traffic Capture Start   		capture_device=vm_eth3_interface     alias=cmp_kur
	${Invalid_Day}=    Evaluate    ${Day_Diff}+1
    Perform Recommissioning        type=param           param_path=CMP-1:neCertificateUpdateTime     operation=update
    ...     value=${Invalid_Day}    timeout=60
	Sleep   30
	${cmp_pcap}=    Traffic Capture Stop    	alias=cmp_kur
	${mplaneIp} =    Get Parameter    param_path=${Mplane_Ip_path}
    ${cmp_dict} =    Query Admin Infomodel    query=get object ${cmp_ip_path}
	${server_host}=       Get From Dictionary    dictionary=${cmp_dict}    key=serverHost
	Run Keyword And Expect Error        *Packet Count doesnt Match for query*
	...     Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_kur           filter_file_name=${traffic_filter_file_name}
	Run Keyword And Expect Error        *Packet Count doesnt Match for query*
	...     Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_kup           filter_file_name=${traffic_filter_file_name}
	Run Keyword And Expect Error        *Packet Count doesnt Match for query*
	...     Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_certConf     filter_file_name=${traffic_filter_file_name}
	Run Keyword And Expect Error        *Packet Count doesnt Match for query*
	...     Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_pkiconf      filter_file_name=${traffic_filter_file_name}
	Verify cmp status         CMP_KeyUpdateFailed
    Verify Alarm    faultid=61510   should_exist=${True}    occurrences=1
	[TEARDOWN]   Run Keyword and Ignore Error        Traffic Capture Stop    	alias=cmp_kur


Manually Install Certificates in BTS
	Certificate Configure   operation=install_certificate     cert_file=${Cert1p12}    cert_type=BtsTrustChain
	...     cert_format=P12    password=${Cert1password}
	Sleep   15
	Certificate Configure   operation=install_certificate     cert_file=${Additional_Cert}    cert_type=AdditionalCa 	 cert_format=PEM
	Sleep   15

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

Change CMP Configuration for Manual Installation
	Perform Recommissioning        type=param           param_path=CMP-1:caSubjectName     operation=delete   value=  timeout=60
	Sleep   15
	Perform Recommissioning	     type=delta		 delta_file=${Remove_Cert_Config}		 timeout=120
	Sleep   15

Create Certificate List
	@{cert_time_list}=     Create List
	Set Suite Variable      ${cert_time_list}     ${cert_time_list}

Schedule CA Certificate Update Time and Verify Expiry Alarm
	Set Suite Variable     ${count}    1
    Sort List  ${days_list}
    #Reverse List    ${days_list}
	FOR  ${days}  IN   @{days_list}
	    ${count}=     Evaluate      ${count}+1
		Perform Recommissioning        type=param           param_path=CMP-1:caCertificateUpdateTime     operation=update
	    ...     value=${days}    timeout=60
	    Sleep   30
	    Verify Alarm	faultid=61618	should_exist=${True}	occurrences=${count}
	END

Verify Alarm and Valid KUR for NE Cert Expiry
    Traffic Capture Start   		capture_device=vm_eth3_interface     alias=cmp_kur
	${Invalid_Day}=    Evaluate    ${Day_Diff}+1
    Perform Recommissioning        type=param           param_path=CMP-1:neCertificateUpdateTime     operation=update
    ...     value=${Invalid_Day}    timeout=60
	Sleep   30
	${cmp_pcap}=    Traffic Capture Stop    	alias=cmp_kur
	${mplaneIp} =    Get Parameter    param_path=${Mplane_Ip_path}
    ${cmp_dict} =    Query Admin Infomodel    query=get object ${cmp_ip_path}
	${server_host}=       Get From Dictionary    dictionary=${cmp_dict}    key=serverHost
	Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_kur           filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_kup           filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_certConf     filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_pkiconf      filter_file_name=${traffic_filter_file_name}
	Verify Alarm	faultid=61618	should_exist=${True}	occurrences=1
	Verify cmp status      CMP_KeyUpdateOK
	[TEARDOWN]   Run Keyword and Ignore Error        Traffic Capture Stop    	alias=cmp_kur

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

Schedule NE Certificate Update Time for Expiry and Verify Mismatch Alarm
    ${End_Entity_dict}=    Certificate Configure    operation=get_certificate_details   type=EndEntity     source=Operator      timeout=120
    ${Valid_to}=      Get from Dictionary      ${End_Entity_dict}[0]       validTo
    Execute command on ENodeB       date -u
    Convert Certificate Time to Standard Format     ${Valid_to}
    Convert ENodeB Time to Standard Format      ${stdout}
    ${Date_Diff}=     Subtract Date From Date     ${Cert_DateTime}     ${Enb_DateTime}    verbose
    @{Date_list}=     Split String     ${Date_Diff}       ${SPACE}
    ${Day_Diff}=  Convert to Integer    ${Date_list}[0]
    Set Suite Variable   ${Day_Diff}         ${Day_Diff}
    Perform Recommissioning        type=param           param_path=CMP-1:neCertificateUpdateTime     operation=update
    ...     value=${Day_Diff}    timeout=60
	Sleep    30
	Verify Alarm	faultid=61011	should_exist=${True}	occurrences=1

Convert Certificate Time to Standard Format
    [Arguments]         ${cert_time}
    ${Cert_DateTime}=      Convert Date       ${cert_time}      result_format=%Y-%m-%d %H:%M:%S.%f     date_format=%b %d %H:%M:%S %Y %Z
    Set Suite Variable   ${Cert_DateTime}     ${Cert_DateTime}

Convert ENodeB Time to Standard Format
    [Arguments]         ${enodeb_time}
    @{DateTime}=     Split String     ${enodeb_time}       ${SPACE}
    Run Keyword and Ignore Error       Remove Values From List      ${DateTime}     ${EMPTY}
    Log    ${DateTime}
    ${Enb_Date} =   Catenate   SEPARATOR=-    ${DateTime}[5]   ${DateTime}[1]   ${DateTime}[2]
    ${Enb_DateTime}=     Catenate    SEPARATOR=${SPACE}    ${Enb_Date}    ${DateTime}[3]
    ${Enb_DateTime}=      Convert Date      ${Enb_DateTime}      result_format=%Y-%m-%d %H:%M:%S.%f     date_format=%Y-%b-%d %H:%M:%S
    Set Suite Variable   ${Enb_DateTime}      ${Enb_DateTime}

Restore all Certificate
	certificate configure    operation=restore_vendor_certificate
	Sleep 		10
	certificate configure    operation=delete_cert  all_certs=${True}
	Sleep     10

Verify cmp status
    [Arguments]    ${CMP_status_check}
    ${cmp_state_var} =    Query Admin Infomodel    query=get object ${cmp_r_moc_path}
    Should be equal    ${cmp_state_var['state']}    ${CMP_status_check}

Verify Installation of Certificate
    Get CMP Certificate Name from Admin
    Get Operator Certificates    All
    List Should Contain Value     ${operator_certs}    ${caSubjectName}

Install New Root CA Certificate
    [Arguments]    ${certificate}
    Perform Recommissioning     type=param          param_path=CMP-1:caSubjectName     value=${certificate}    timeout=60     operation=update
    Certificate Configure       operation=install_cmp_certificate   timeout=120
    sleep   30

Get CMP Certificate Name from Admin
    ${cmp_dict} =    Query Admin Infomodel    query=get object ${cmp_ip_path}
    ${caSubjectName}=       Get From Dictionary    dictionary=${cmp_dict}    key=caSubjectName
    Set Suite Variable    	  ${caSubjectName}       ${caSubjectName}

Get Operator Certificates
    [Arguments]    ${type}
    ${Certificate_list}=      Certificate Configure     operation=get_certificate_list   type=${type}     timeout=120
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

check for Additional TA Certificates
    Get Operator Certificates      TA
    ${len}=      Get Length        ${operator_certs}
    Should Be True      ${len}>=1

Install Additonal TA Certificates
    Certificate Configure   operation=install_certificate   cert_file=${FQDN_BTSCertp12}    cert_type=BtsTrustChain
    ...    cert_format=P12      password=${FQDN_BTSCertpass}
    Log    TA Certificate Installed successfully

Create BTS Security Account from BTS Administrator Account
	User Account Manage        operation=manage_local_user_account         new_username=${new_username}
	...       new_password=${new_password}   old_username=${old_username}    old_password=${old_password}    account_type=${account_type}

Configure CMP object using BTS Security Account
	Setup Oamops     dut=bts        username=${new_username}      password=${new_password}         alias=bts_security
	Perform Recommissioning        type=param           param_path=CMP-1:caSubjectName     operation=update     value=CN=8154_ta111
	...    timeout=60      alias=bts_security

Trigger IR from BTS Security Account and Verify
	Traffic Capture Start   		capture_device=vm_eth3_interface	    timeout=120      alias=ir_1
	Certificate Configure     operation=install_cmp_certificate       timeout=120      alias=bts_security
	Sleep   30
	${cmp_pcap}=    Traffic Capture Stop        mode=file       timeout=350  	alias=ir_1
	Verify cmp status         CMP_InitializationOK
	Read Mplane IP
	Read CMP Server IP    primary
	Verify IR Operation     ${cmp_pcap}
	Verify Alarm    faultid=61510   should_exist=${False}
	Get CMP Certificate Name from Admin
	Get Operator Certificates    All
	List Should Contain Value     ${operator_certs}    ${caSubjectName}

Verify IR Operation
	[Arguments]    ${cmp_pcap}
	Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_ir         filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_ip         filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_certConf         filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_pkiconf         filter_file_name=${traffic_filter_file_name}

Verify KUR Operation
	[Arguments]    ${cmp_pcap}
	Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_kur           filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_kup           filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_certConf     filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_pkiconf      filter_file_name=${traffic_filter_file_name}

Trigger KUR from BTS Security Account and Verify
	Traffic Capture Start   		capture_device=vm_eth3_interface     alias=kur_1
	Certificate Configure     operation=cmp_update_key       timeout=120      alias=bts_security
	Sleep   30
	${cmp_pcap}=    Traffic Capture Stop    	alias=kur_1
	Verify cmp status      CMP_KeyUpdateOK
	Read Mplane IP
	Read CMP Server IP    primary
	Verify KUR Operation     ${cmp_pcap}
	Verify Alarm    faultid=61510   should_exist=${False}

Read Mplane IP
	${mplaneIp} =    Get Parameter    param_path=${Mplane_Ip_path}
    Set Suite Variable    ${mplaneIp}    ${mplaneIp}

Read CMP Server IP
    [Arguments]    ${type}
	Run Keyword If    '${type}' == 'secondary'     Set Suite Variable       ${key}    secondaryServerHost
    ...       ELSE    Set Suite Variable       ${key}    serverHost
	${server_host}=     Get Parameter    param_path=${cmp_moc_path}:${key}
	Set Suite Variable    ${server_host}    ${server_host}

Install expiry certificate with p12 file
        [Documentation]     This keyword is to intall Additional CA certificates and to check CRL Download
        Run Keyword and Expect Error     *Failed: Certificate validation - Certificate expired*    Certificate Configure
        ...      operation=install_certificate       cert_file=${ExpirecaCert}       cert_type=BtsTrustChain
        ...      cert_format=P12      password=${invalid_ca_pass}
		sleep   60

Install expiry certificate with PEM format
        Run Keyword and Expect Error     *Failed: Certificate validation - Certificate expired*     Certificate Configure
        ...       operation=install_certificate       cert_file=${ExpiredPem}      cert_type=AdditionalCa      cert_format=PEM
        Sleep   10

Install additional CA certificate
        Certificate Configure       operation=install_certificate       cert_file=${AdditionalCA}      cert_type=AdditionalCa      cert_format=PEM
        Run Keyword and Expect Error     *Failed: Duplicate certificate found/error*   Certificate Configure       operation=install_certificate
        ...       cert_file=${AdditionalCA}      cert_type=AdditionalCa      cert_format=PEM
        Sleep   10

Install Root CA Certificate with invalid p12 file
        [Documentation]     This keyword is to intall invalid P12 file
        Run Keyword and Expect Error
        ...    *Failed: Invalid trust chain - intermediate CA or root CA of EE/RA is missing or have additional \ CA/TA's of EE/RA*
        ...    Certificate Configure     operation=install_certificate   cert_file=${Invalid_ca}    cert_type=BtsTrustChain
        ...     cert_format=P12       password=${invalid_ca_pass}
        Sleep   10

Install Intermediate CA Certificate with invalid pem file
        [Documentation]     This keyword is to intall invalid PEM file
        Run Keyword and Expect Error    *Failed: Profile validation failure - EE/RA/CA/TA CERT profile validation like basic constraints, key usage*
        ...    Certificate Configure       operation=install_certificate       cert_file=${InvalidPemCert}       cert_type=AdditionalCa
        ...      cert_format=PEM
        Sleep   10

Install Certificate Chain where Intermediate CA is missing
		[Documentation]     This keyword is to install intermediate missing CA
        Run Keyword And Expect Error    *Failed: Wrong Certificate data/format/invalid PKCS12/PEM chain file content*   Certificate Configure
        ...       operation=install_certificate       cert_file=${InvalidIntermCA}       cert_type=AdditionalCa      cert_format=PEM
        Sleep   10

Install Certificate where algorithm is invalid
		[Documentation]     This keyword is to install intermediate missing CA
        Run Keyword And Expect Error    *Failed: Wrong Certificate data/format/invalid PKCS12/PEM chain file content*    Certificate Configure
        ...       operation=install_certificate       cert_file=${InvalidAlgo}       cert_type=BtsTrustChain      cert_format=P12
        ...      password=${invalid_ca_pass}
        Sleep   10


Install Certificate where intermediate CA certificate is exceeded above 8K
		[Documentation]     This keyword is to install intermediate missing CA
        Run Keyword And Expect Error    *Failed: Certificate exceeding maximum size*        Certificate Configure     operation=install_certificate
        ...       cert_file=${ExceededPemCert}       cert_type=AdditionalCa      cert_format=PEM

Configure Invalid CMP ServerHost Port And path
    Perform Recommissioning     type=delta      delta_file=${Cmp_invalid_server_port_path}     timeout=120
	sleep   30
    Run Keyword And Expect Error    *Failed: CMP server not reachable/timeout*      Certificate Configure       key_pool_type=RSA
    ...       operation=install_cmp_certificate   timeout=120
	sleep   30
