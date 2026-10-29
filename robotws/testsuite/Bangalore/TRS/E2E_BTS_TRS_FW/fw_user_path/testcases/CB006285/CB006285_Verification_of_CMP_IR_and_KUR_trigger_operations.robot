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
Resource    	${CURDIR}/../CB006285/resources/common_keywords_6285.robot
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource    	${CURDIR}/../resources/Admin_Common_Library.robot
#Resource        /home/ute/fw_user_path/testcases/CB006285/resources/common_keywords_6285.robot
Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


*** Test Cases ***
[1][1.0] CB006285 Verification of CMP IR and KUR trigger operation
	Perform Commissioning       scf_file=${scf}   verify_bts_status=True     timeout=400     alias=default
    Sleep  300
	Restore all Certificate
    Install RSA and ECDSA certificates through NMS
	Read CMP Parameters     	RSA
	Tigger IR_KUR 			RSA 	install_cmp_certificate
    Sleep  50
	verify cmp status		RSA		CMP_InitializationOK
    Verify IR Operation
	Tigger IR_KUR 			RSA 	cmp_update_key
    Sleep   50
	verify cmp status		RSA		CMP_KeyUpdateOK
    Verify KUR Operation
	Read CMP Parameters 	ECDSA
    Tigger IR_KUR           ECDSA   install_cmp_certificate
    verify cmp status       ECDSA   CMP_InitializationOK
    Verify IR Operation
	Tigger IR_KUR 			ECDSA 	cmp_update_key
	verify cmp status		ECDSA	CMP_KeyUpdateOK
    Verify KUR Operation








*** Keywords ***
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


Restore all Certificate
    certificate configure    operation=restore_vendor_certificate
    Sleep       10
    certificate configure    operation=delete_cert    all_certs=${True}
    Sleep     10


Read CMP Parameters
    [Arguments]      ${CertType}
    Get Mplane details   ${Mplane_Ip_path}
    Get ECDSA details
    Get SrcCMPCrlConfigured details         ${SrcCMPCrlConfigured_IP_path}
    Run keyword If      '${CertType}' == 'RSA'              Get RSA details
    Run keyword If      '${CertType}' == 'ECDSA'                Get ECDSA details



Tigger IR_KUR
    [Arguments]         ${CertType}     ${Operation}
    Traffic Capture Start       capture_device=bts               alias=${cmp_alias}
    Certificate Configure       operation=${Operation}      key_pool_type=${CertType}       timeout=100
    ${cmp_pcap_log}=    Traffic Capture Stop        alias=${cmp_alias}
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

verify cmp status
    [Arguments]   ${certType}    ${CMP_status_check}
    Run keyword if  '${certType}' == 'ECDSA'            Set Suite Variable  ${cmp_state_path}  ${cmpecdsa_r_moc_path}
    Run keyword if  '${certType}' == 'RSA'          Set Suite Variable      ${cmp_state_path}  ${cmp_r_moc_path}
    ${cmp_state_var} =    Query Admin Infomodel    query=get object ${cmp_state_path}
    Should be equal    ${cmp_state_var['state']}    ${CMP_status_check}



Install Additional certificate
    [Arguments]             ${Certificate}          ${alias}=default
    Certificate Configure       operation=install_certificate       cert_file=${Certificate}      cert_type=AdditionalCa      cert_format=PEM
...     ${alias}=default
    fetch cert details      ECDSA



Get mplaneIP
    ${mplaneObjects_dict} =    Query Admin Infomodel    query=get list ${mplane_moc}
    FOR    ${eachMplane}    IN    @{mplaneObjects_dict}
        ${mplane_ipv4_ip_admin}=    Get From Dictionary    dictionary=${eachMplane}    key=mPlaneIpv4AddressDN
        ${mplane}=      Query Admin Infomodel    query=get param ${mplane_ipv4_ip_admin}:localIpAddr
        Set Suite Variable      ${mplane}       ${mplane}
    END

Get Mplane details
    [Arguments]      ${Mplane_Ip_path}
    ${mplaneIp} =    Get Parameter    param_path=${Mplane_Ip_path}
    Set Suite Variable    ${srccmp_Ip}     ${mplaneIp}


Get SrcCMPCrlConfigured details
    [Arguments]      ${SrcCMPCrlConfigured_IP_path}
    ${srcCmpCrlIp} =    Get Parameter    param_path=${SrcCMPCrlConfigured_IP_path}
    Set Suite Variable    ${srcCmpCrlIp}     ${srcCmpCrlIp}


Get ECDSA details
    ${cmp_ip_dict} =    Query Admin Infomodel    query=get object ${cmp_ip_path}        timeout=60
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

