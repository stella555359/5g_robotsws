*** Settings ***
Documentation
...		[Author]     		        "Aishwarya Gade"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "09:05:2022"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB005999"
...     [Validated_TestLine]        "KVM_ST_LMP_TL1004"
...		[Procedure]   		        "CB005999_Verification of Additional intermediate CA and TA Certificates"
...     [Precondition]              "ASOE hardware is required"
...     [Config]    	            "CRLH-1 param should be configured in SCF"
...     [Function_Hash_Tags]        "ECDSA, RSA, Certificates, CMP Configuration"


variables       ta_e2e_bts_trs_fw
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource    	${CURDIR}/../resources/Admin_Common_Library.robot


Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


*** Test Cases ***
[1.0] CB005999_Verification_of_CMP_parameters_when_ECDSA_and_RSA_certificates_are_installed_from_WEBEM_and_NMS
    Perform Commissioning   scf_file=${base_scf_custconfig}    verify_bts_status=True   wait_for_onair_status=900   alias=default
    Sleep   300
    certificate configure    operation=restore_vendor_certificate   timeout=60   alias=default
    Install RSA and ECDSA certificates through WEBEM
    Restore default certificates and delete certificate parameter
    Install RSA and ECDSA certificates through NMS
    CMP key update for RSA and ECDSA
    Install RSA and ECDSA certificates and verify packets while certificate installation
    CMP key update for RSA and ecdsa certificates and verify packets while KUR

*** Keywords ***
Restore default certificates and delete certificate parameter
    certificate configure    operation=restore_vendor_certificate   timeout=60   alias=default
    Perform Recommissioning	   type=param   rat=common    param_path=CMP-1:caSubjectName    operation=delete
...     value=CN=add_lte3065_ta13    timeout=300
    Perform Recommissioning    type=param   rat=common    param_path=CMPECDSA-1:caSubjectName    operation=delete
...     value=CN=VALIDECDSA7351TA    timeout=300

Install RSA and ECDSA certificates through NMS
#Enable RSA,ECDSA related parameters like caSubjectName,serverHost,serverPort IR will be triggered automatically.From netact
#triggering IR wont be possible
    Setup Ems    config_device=netact1042    alias=lab42
    Cm Upload   config_device=netact1042   alias=lab42
    Configuration Manage    config_device=netact1042   config=enable_ecdsa_params.json
...     plan_name=enable_ecdsa_cert12     delete_plan="True"  timeout=300   alias=lab42
    Sleep   60
    ${output}=     Get Parameter     param_path=${ecdsa_state_moc_path}     dut=bts     timeout=300      alias=default     str_format=True
    Should Contain     ${output}     ${cmp_state}
    Configuration Manage    config_device=netact1042   config=enable_rsa_params.json    plan_name=enable_rsa_certi12   delete_plan="True"
...     timeout=300     alias=lab42
    Sleep   60
    ${output}=     Get Parameter     param_path=${rsa_state_moc_path}     dut=bts     timeout=300      alias=default     str_format=True
    Should Contain     ${output}     ${cmp_state}
    Teardown Ems    config_device=netact1042    alias=lab42

Install RSA and ECDSA certificates through WEBEM
    Perform Recommissioning    type=delta      delta_file=${rsa_ecdsa_params}    timeout=300    alias=default
    Sleep   60
    ${output_ecdsa}=     Get Parameter     param_path=${ecdsa_state_moc_path}     dut=bts     timeout=300      alias=default     str_format=True
    Should Contain     ${output_ecdsa}     ${cmp_state}
    ${output_rsa}=     Get Parameter     param_path=${rsa_state_moc_path}     dut=bts     timeout=300      alias=default     str_format=True
    Should Contain     ${output_rsa}     ${cmp_state}

CMP key update for RSA and ECDSA
    certificate configure      operation=cmp_update_key    key_pool_type=RSA    timeout=300     alias=default
    Sleep   60
    ${output_rsa}=     Get Parameter     param_path=${rsa_state_moc_path}     dut=bts     timeout=300      alias=default     str_format=True
    Should Contain     ${output_rsa}     ${cmp_state_key_update}
    certificate configure      operation=cmp_update_key    key_pool_type=ECDSA    timeout=300     alias=default
   Sleep   60
    ${output_ecdsa}=     Get Parameter     param_path=${ecdsa_state_moc_path}     dut=bts     timeout=300      alias=default     str_format=True
    Should Contain     ${output_ecdsa}     ${cmp_state_key_update}

Install RSA and ECDSA certificates and verify packets while certificate installation
    Certificate Configure    operation=restore_vendor_certificate   timeout=60   alias=default
    Traffic Capture Start    capture_device=bts_mplane
    Certificate Configure    operation=install_cmp_certificate    key_pool_type=RSA   timeout=60   alias=default
    Sleep   30
    ${output}=     Get Parameter     param_path=${rsa_state_moc_path}    dut=bts     timeout=300      alias=default     str_format=True
    Should Contain     ${output}     ${cmp_state}
    ${filename}=    Traffic Capture Stop
    Set Suite Variable     ${filename}
    Verify RSA pcap
    Traffic Capture Start    capture_device=bts_mplane
    Certificate Configure    operation=install_cmp_certificate    key_pool_type=ECDSA   timeout=60   alias=default
    Sleep   30
    ${output}=     Get Parameter     param_path=${ecdsa_state_moc_path}     dut=bts     timeout=300      alias=default     str_format=True
    Should Contain     ${output}     ${cmp_state}
    ${filename}=    Traffic Capture Stop
    Set Suite Variable     ${filename}
    Verify ECDSA pcap

CMP key update for RSA and ecdsa certificates and verify packets while KUR
    Traffic Capture Start    capture_device=bts_mplane
    certificate configure      operation=cmp_update_key    key_pool_type=RSA    timeout=300     alias=default
    Sleep   30
    ${output_rsa}=     Get Parameter     param_path=${rsa_state_moc_path}     dut=bts     timeout=300      alias=default     str_format=True
    Should Contain     ${output_rsa}     ${cmp_state_key_update}
    ${filename}=    Traffic Capture Stop
    Set Suite Variable     ${filename}
    Verify RSA KUR pcap
    Traffic Capture Start    capture_device=bts_mplane
    certificate configure      operation=cmp_update_key    key_pool_type=ECDSA    timeout=300     alias=default
    Sleep   60
    ${output_ecdsa}=     Get Parameter     param_path=${ecdsa_state_moc_path}     dut=bts     timeout=300      alias=default     str_format=True
    Should Contain     ${output_ecdsa}     ${cmp_state_key_update}
    ${filename}=    Traffic Capture Stop
    Set Suite Variable     ${filename}
    Verify ECDSA KUR pcap

Verify RSA pcap
    Analyse Pcap   pcap_filename=${filename}    analysis=cmp_ir       filter_file_name=${traffic_filter_file_name}
    Analyse Pcap   pcap_filename=${filename}    analysis=cmp_ip_rsa     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap   pcap_filename=${filename}    analysis=cmp_certConf   filter_file_name=${traffic_filter_file_name}
    Analyse Pcap   pcap_filename=${filename}    analysis=cmp_pkiconf    filter_file_name=${traffic_filter_file_name}

Verify ECDSA pcap
    Analyse Pcap   pcap_filename=${filename}    analysis=cmp_ir       filter_file_name=${traffic_filter_file_name}
    Analyse Pcap   pcap_filename=${filename}    analysis=cmp_ip_ecdsa     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap   pcap_filename=${filename}    analysis=cmp_certConf   filter_file_name=${traffic_filter_file_name}
    Analyse Pcap   pcap_filename=${filename}    analysis=cmp_pkiconf    filter_file_name=${traffic_filter_file_name}

verify RSA KUR pcap
    Analyse Pcap   pcap_filename=${filename}    analysis=cmp_kur_rsa     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap   pcap_filename=${filename}    analysis=cmp_kup_rsa     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap   pcap_filename=${filename}    analysis=cmp_certConf   filter_file_name=${traffic_filter_file_name}
    Analyse Pcap   pcap_filename=${filename}    analysis=cmp_pkiconf    filter_file_name=${traffic_filter_file_name}

verify ECDSA KUR pcap
    Analyse Pcap   pcap_filename=${filename}    analysis=cmp_kur_ecdsa     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap   pcap_filename=${filename}    analysis=cmp_kup_ecdsa     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap   pcap_filename=${filename}    analysis=cmp_certConf   filter_file_name=${traffic_filter_file_name}
    Analyse Pcap   pcap_filename=${filename}    analysis=cmp_pkiconf    filter_file_name=${traffic_filter_file_name}

Retriveing certificate information from NMS
    Setup Ems    config_device=netact1042    alias=lab42
    Cm Upload    config_device=netact1042    alias=lab42
    Configuration Get    config_device=netact1042    dist_name=PLMN-PLMN/MRBTS-3901/MNL-1/CERTH-1/CMPECDSA-1    alias=lab42
    Configuration Get    config_device=netact1042    dist_name=PLMN-PLMN/MRBTS-3901/MNL-1/CERTH-1/CMP-1    alias=lab42
    Teardown Ems    config_device=netact1042    alias=lab42
