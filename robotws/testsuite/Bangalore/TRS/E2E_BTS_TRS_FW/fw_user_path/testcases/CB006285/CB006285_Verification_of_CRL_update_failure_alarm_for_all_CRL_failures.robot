*** Settings ***
Documentation
...		[Author]     		        "Eswarlal Abhishake T"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "29:06:2022"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB005999"
...     [Validated_TestLine]        "IAV_BLR_TL074"
...		[Procedure]   		        "CB005999_Verification of invalid crl and maximum crl support for ECDSA certificates"
...     [Precondition]              "ASIL + ABIA hardware is required"
...     [Config]    	            "CRLH-1 param should be configured in SCF"
...     [Function_Hash_Tags]        "ECDSA, RSA, Certificates, CMP Configuration"



variables       ta_e2e_bts_trs_fw
Resource         taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource    	${CURDIR}/../resources/common_keywords.robot
#Resource    	${CURDIR}/../resources/Admin_Common_Library.robot
#Resource    	${CURDIR}/../resources/common_keywords_6285.robot
#Resource        /home/ute/fw_user_path/testcases/CB006285/resources/common_keywords_6285.robot
Resource        ${CURDIR}/../CB006285/resources/common_keywords_6285.robot


Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


*** Test Cases ***
[1][1.0] CB006285 Verification of CRL update failure alarm for all CRL failure
   Perform Commissioning        scf_file=${scf}     verify_bts_status=True         timeout=900
   sleep       300
   Install RSA and ECDSA certificates through NMS
   Read CMP Parameters     RSA
   Read CMP Parameters     ECDSA
   Get mplaneIP
   Configure CRLDP                         ${Unsupported_HTTP_URL}
   Sleep       300
   Verify Alarm    faultid=${crl_update_failure}    occurrences=${1}    should_exist=${True}
   Verify Status for CRL Failure    UnsupportedProtocol
   Configure CRLDP                         ${Unreachable_HTTP_URL}
   Sleep       300
   Verify Alarm    faultid=${crl_update_failure}    occurrences=${1}    should_exist=${True}
   Verify Status for CRL Failure    UnsupportedProtocol
   Configure CRLDP                         ${URI_format_error}
   Sleep           300
   Verify Alarm    faultid=${crl_update_failure}    occurrences=${1}    should_exist=${True}
   Verify Status for CRL Failure    UriFormatError




*** Keywords ***
Verify Status for CRL Failure
    [Arguments]    ${failure_msg}
    ${certificate_Details}=    certificate configure    operation=get_certificate_revocation_list
    ${len}=    Get Length    ${certificate_Details}
    ${dict_val}=    Get From List    ${certificate_Details}    0
    Log    ${dict_val}
    ${stateInfo}=    Get From Dictionary    ${dict_val}    stateInfo
    ${reasoning}=    Get From Dictionary    ${stateInfo}    reasoningStatus
    ${reasoning}=    Get From List    ${reasoning}    0
    Should Be Equal    ${reasoning}    ${failure_msg}




Install RSA and ECDSA certificates through NMS
#Enable RSA,ECDSA related parameters like caSubjectName,serverHost,serverPort IR will be triggered automatically.
#From netact ,triggering IR wont be possible
    Setup Ems    config_device=netact1042    alias=lab42
    Cm Upload   config_device=netact1042   alias=lab42
    Configuration Manage    config_device=netact1042   config=enable_ecdsa_params.json    plan_name=enable_ecdsa_cert12
...     delete_plan="True"  timeout=300   alias=lab42
    Sleep   60
    ${output}=     Get Parameter     param_path=${ecdsa_state_moc_path}     dut=bts     timeout=300      alias=default     str_format=True
    Should Contain     ${output}     ${cmp_state}
    Configuration Manage    config_device=netact1042   config=enable_rsa_params.json    plan_name=enable_rsa_certi12
...     delete_plan="True"   timeout=300     alias=lab42
    Sleep   60
    ${output}=     Get Parameter     param_path=${rsa_state_moc_path}     dut=bts     timeout=300      alias=default     str_format=True
    Should Contain     ${output}     ${cmp_state}
    Teardown Ems    config_device=netact1042    alias=lab42



Get mplaneIP
    ${mplaneObjects_dict} =    Query Admin Infomodel    query=get list ${mplane_moc}
	FOR    ${eachMplane}    IN    @{mplaneObjects_dict}
    	${mplane_ipv4_ip_admin}=    Get From Dictionary    dictionary=${eachMplane}    key=mPlaneIpv4AddressDN
		${mplane}=		Query Admin Infomodel    query=get param ${mplane_ipv4_ip_admin}:localIpAddr
		Set Suite Variable		${mplane}		${mplane}
    END

Configure and verify CRL download
	Configure CRLDP 					${HTTP_URL}

Configure CRLDP
	[Arguments]			${value}
	Perform Recommissioning 		type=param		param_path=${CRLDP_Path}		value=${value}		 operation=update        timeout=120

Get Mplane details
    [Arguments]      ${Mplane_Ip_path}
    ${mplaneIp} =    Get Parameter    param_path=${Mplane_Ip_path}
    Set Suite Variable    ${srccmp_Ip}     ${mplaneIp}



Read CMP Parameters
    [Arguments]      ${CertType}
    Get Mplane details   ${Mplane_Ip_path}
    Get ECDSA details
    Get SrcCMPCrlConfigured details         ${SrcCMPCrlConfigured_IP_path}
    Run keyword If      '${CertType}' == 'RSA'              Get RSA details
    Run keyword If      '${CertType}' == 'ECDSA'                Get ECDSA details

Get SrcCMPCrlConfigured details
    [Arguments]      ${SrcCMPCrlConfigured_IP_path}
    ${srcCmpCrlIp} =    Get Parameter    param_path=${SrcCMPCrlConfigured_IP_path}
    Set Suite Variable    ${srcCmpCrlIp}     ${srcCmpCrlIp}
