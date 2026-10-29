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
[1][1.0] CB005999_Verification of invalid crl and maximum crl support for ECDSA certificates
	Perform Recommissioning		type=delta		delta_file=${certificate_config}		skip_parameter_relation_errors=${True}		timeout=300
	Restore all Certificate
    Get mplaneIP
	Install All TA Certificates
    Install All CA Certificates
    Configure and verify max crl
    Count CRL Entries
    Restore all Certificate
    Perform Recommissioning     type=delta      delta_file=${delete_crldp}      skip_parameter_relation_errors=${True}      timeout=300

    Perform CRLDP Update and check for dirrerent CRL check failures

*** Keywords ***

Configure and verify max crl
    Perform Recommissioning     type=delta      delta_file=${max_crl}       skip_parameter_relation_errors=${True}      timeout=300
    Sleep   300
    Certificate Configure       operation=get_certificate_revocation_list



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
    ...     certificate configure    operation=update_certificate_revocation_list     timeout=500
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


Configure CRLDP
    [Documentation]     This keyword is to configure URI for the given inputs
    [Arguments]         ${value}
    Perform Recommissioning         type=param      param_path=${CRLDP_Path}        value=${value}       operation=update        timeout=120



Install All TA Certificates
    FOR    ${INDEX}    IN RANGE    1    10
        Certificate Configure
        ...    key_pool_type=ECDSA
        ...    operation=install_certificate
        ...    cert_file=${5999_ECDSA_CRL${INDEX}}
        ...    cert_type=AdditionalCa
        ...    cert_format=PEM
		...    timeout=60
        Sleep    5
    END


Count CRL Entries
    ${crl_list}=    Certificate Configure    operation=get_certificate_revocation_list
    ${length}=      Get Length    ${crl_list}
    Log    Number of CRL entries: ${length}
    Should Be Equal As Integers    ${length}    68

Install All CA Certificates
    FOR    ${i}    IN RANGE    1    22
        Certificate Configure
        ...    key_pool_type=ECDSA
        ...    operation=install_certificate
        ...    cert_file=${5999_ECDSA_CRL${i}_CA1}
        ...    cert_type=AdditionalCa
        ...    cert_format=PEM
		...    timeout=60
        Sleep    5
        Certificate Configure
        ...    key_pool_type=ECDSA
        ...    operation=install_certificate
        ...    cert_file=${5999_ECDSA_CRL${i}_CA2}
        ...    cert_type=AdditionalCa
        ...    cert_format=PEM
		...    timeout=60
        Sleep    5
        Certificate Configure
        ...    key_pool_type=ECDSA
        ...    operation=install_certificate
        ...    cert_file=${5999_ECDSA_CRL${i}_CA3}
        ...    cert_type=AdditionalCa
        ...    cert_format=PEM
		...    timeout=60
        Sleep    5
    END


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
	Perform Recommissioning 		type=param		param_path=CRLDPCONFIG-1:primaryCRLDP		value=${http}		 operation=update        timeout=500
	certificate configure 		operation=update_certificate_revocation_list			timeout=500
	Tigger IR_KUR 			ECDSA 	install_cmp_certificate
	CRL Download success
	Perform Recommissioning 		type=param		param_path=CRLDPCONFIG-1:primaryCRLDP		value=${ldap}		 operation=update        timeout=120
	certificate configure 		operation=update_certificate_revocation_list			timeout=500
	Tigger IR_KUR 			ECDSA 	install_cmp_certificate
	CRL Download success

Perform CMP Keyupdate and verify CRL update
	[Documentation]		This keyword is to Perform CMP Keyupdate and verify CRL update
	Perform Recommissioning 		type=param		param_path=CRLDPCONFIG-1:primaryCRLDP		value=${http}		 operation=update        timeout=500
	certificate configure 		operation=update_certificate_revocation_list			timeout=500
	Tigger IR_KUR 			ECDSA 	cmp_update_key
	CRL Download success
	Perform Recommissioning 		type=param		param_path=CRLDPCONFIG-1:primaryCRLDP		value=${ldap}		 operation=update        timeout=120
	certificate configure 		operation=update_certificate_revocation_list			timeout=500
	Tigger IR_KUR 			ECDSA 	cmp_update_key
	CRL Download success

Perform additional CA certificate operation and verify CRL update
	[Documentation]		This keyword is to verify HTTP CRL for addition CA certificates and also to verify automatic trigger for restoration of
	Perform Recommissioning 		type=param		param_path=CRLDPCONFIG-1:primaryCRLDP		value=${http}		 operation=update        timeout=500
	Certificate Configure		operation=install_certificate		cert_file=${AdditionalCACertCRLfile}		cert_type=AdditionalCa		cert_format=PEM
	Trigger and verify CRL update
	CRL Download success


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