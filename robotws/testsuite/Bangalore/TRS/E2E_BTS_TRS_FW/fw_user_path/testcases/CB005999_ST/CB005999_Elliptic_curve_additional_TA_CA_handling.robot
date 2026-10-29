*** Settings ***
Documentation
...     [Author]                    "Aishwarya Gade"
...     [Maintenance]               "TRS I&V Tools Bangalore Team"
...     [Date]                      "09:05:2022"
...     [QC_Path]                   "QC_Path in Test Plan"
...     [QC_ID]                     "QC_ID in Test Lab for reporting"
...     [Feature_ID]                "CB005999"
...     [Validated_TestLine]        "KVM58-TRSIV-TL3297"
...     [Procedure]                 "CB005999_Verification of Additional intermediate CA and TA Certificates"
...     [Precondition]              "ASIB + ASIB hardware is required"
...     [Config]                    "CRLH-1 param should be configured in SCF"
...     [Function_Hash_Tags]        "ECDSA, RSA, Certificates, CMP Configuration"


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot

#Suite Setup     Setup Oamops
#Suite Teardown     Teardown Oamops


Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


*** Test Cases ***
[1.0] CB005999_Elliptic_curve_additional_TA_CA_handling
   Perform Commissioning   scf_file=${base_scf1}    verify_bts_status=True   wait_for_onair_status=900   alias=default
   Install Root Certificates
   Sleep       200
   Install Additonal TA Certificates
   Sleep      200
   Install Concatenated CA Cetificate
   Sleep   300
   CRL verification with WEBEM
   CRL Verification with NMS
   Negative CMP scenarios

*** Keywords ***
Install Root Certificates
    certificate configure    operation=install_certificate    cert_file=${caCert_valid}    cert_type=BtsTrustChain
...     cert_format=P12    password=${password}
    Log    Certificate Installed successfully

Install Additonal TA Certificates
    certificate configure    operation=install_certificate    cert_file=${ta_certificate}    cert_type=AdditionalCa    cert_format=PEM
    Log    TA Certificate Installed successfully

Delete Additional TA Certificates
    Certificate Configure    operation=delete_cert   type=${ta_cert}    subject=${ta_sub}   source=${source}
    Log    Certificate Deleted Successfully

Install Concatenated CA Cetificate
    certificate configure    operation=install_certificate    cert_file=${Conca_ca_cert}    cert_type=AdditionalCa    cert_format=PEM
    Log    TA Certificate Installed successfully



CRL verification with WEBEM
    Perform recommissioning    type=delta    delta_file=${Valid_crl_file}
    Sleep    300
    Verify Alarm    faultid=${crl_update_failure}    occurrences=0    should_exist=${False}
    Perform recommissioning    type=delta    delta_file=${Invalid_crl_file}
    Sleep    300
    Verify Alarm    faultid=${crl_update_failure}    occurrences=1    should_exist=${True}
    Verify Status for CRL Failure    DnsResolutionFailed

CRL Verification with NMS
    Setup Ems    config_device=netact1042    alias=lab42
    Cm Upload    config_device=netact1042    alias=lab42
    Configuration Manage    config_device=netact1042    config=enable_ldap_params.json    plan_name=enable_ldap   delete_plan="True"
...     timeout=300   alias=lab42
    Sleep    300
    Verify Alarm    faultid=${crl_update_failure}    occurrences=0    should_exist=${False}
    Teardown Ems    config_device=netact1042    alias=lab42

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

Negative CMP scenarios
    certificate configure    operation=restore_vendor_certificate   timeout=60    alias=default
    Incorrect cmp parameters and trigger IR KUR
Incorrect cmp parameters and trigger IR KUR
    Setup Ems   config_device=netact1042   alias=lab42
    Cm Upload   config_device=netact1042   alias=lab42
    Configuration Manage    config_device=netact1042   config=enable_ecdsa_incorrect_params.json    plan_name=enable_incorrect_ecdsa00
...     delete_plan="True"  timeout=300   alias=lab42
    Sleep   60
    ${output}=     Get Parameter     param_path=${ecdsa_state_moc_path}     dut=bts     timeout=300      alias=default     str_format=True
    Should Contain     ${output}     ${cmp_state_failed}
    Configuration Manage    config_device=netact1042   config=enable_rsa_incorrect_params.json    plan_name=enable_incorrect_rsa00
...     delete_plan="True"   timeout=300     alias=lab42
    Sleep   60
    ${output}=     Get Parameter     param_path=${rsa_state_moc_path}     dut=bts     timeout=300      alias=default     str_format=True
    Should Contain     ${output}     ${cmp_state_failed}
    Run Keyword and Expect Error    ${no_certificate}     certificate configure      operation=cmp_update_key    key_pool_type=RSA
...     timeout=300     alias=default
    Run Keyword and Expect Error    ${no_certificate}     certificate configure      operation=cmp_update_key    key_pool_type=ECDSA
...     timeout=300     alias=default
    Teardown Ems   config_device=netact1042   alias=lab42

Configure secondary cmp deatils and verify certificate is installed via secondary
    Setup Ems   config_device=netact1042   alias=lab42
    Cm Upload   config_device=netact1042   alias=lab42
    Configuration Manage    config_device=netact1042   config=enable_ecdsa_secondary_params.json
...     plan_name=secondary_ecdsa   delete_plan="True"   timeout=300   alias=lab42
    Configuration Manage    config_device=netact1042   config=enable_rsa_secondary_params.json
...     plan_name=secondary_rsa   delete_plan="True"   timeout=300   alias=lab42
    Sleep   60
    ${output}=     Get Parameter     param_path=${ecdsa_state_moc_path}     dut=bts     timeout=300      alias=default     str_format=True
    Should Contain     ${output}     ${cmp_state}
    ${output}=     Get Parameter     param_path=${rsa_state_moc_path}     dut=bts     timeout=300      alias=default     str_format=True
    Should Contain     ${output}     ${cmp_state}
    certificate configure    operation=restore_vendor_certificate   timeout=60    alias=default
    Teardown Ems    config_device=netact1042   alias=lab42
