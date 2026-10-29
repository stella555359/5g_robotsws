*** Settings ***
Documentation
...     [Documentation]
...     [Author]        "Bibhukinkar Behera"
...     [Maintenance]   "TRS ET Bangalore Team"
...     [Procedure]     "The test case is planned to validate Automatic trigger_CMPIR and trigger CRL using Source IP address"
...     [Date]          "13-09-2022"
...     [Feature_ID]    "RP000845"
...     [Requirement ID]    "WBTS_TRS_20224"
...     [Config_Comments]    "This script requires basic SCF loading with CMP and CRL server configuration."
...     [Funtion_Hash_Tags]     "CMP"
...     [RunTime Parameters]    "bts_id used is 2010"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot

Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


*** Test Cases ***

[1][2.0] RP000845_CertMan CRL Download Failure
     Perform Commissioning     scf_file=${RP000845_config}     verify_bts_status=True     timeout=400     alias=default
     Sleep    200
    Install RSA and ECDSA certificates through NMS
    Certificate Configure     operation=restore_vendor_certificate
    Certificate Configure    operation=install_cmp_certificate     timeout=120
    Perform recommissioning    type=delta    delta_file=${Invalid_crl_file}
    Sleep    250
    Verify Alarm    faultid=${crl_update_failure}    occurrences=${1}    should_exist=${True}
    Perform recommissioning    type=delta    delta_file=${Valid_crl_file}
    Sleep    250
    Verify Alarm    faultid=${crl_update_failure}    occurrences=${0}    should_exist=${False}
    Perform recommissioning    type=delta    delta_file=${Invalid_DNS_crl_file}
    Sleep       200
    Sleep    300
    Verify Alarm    faultid=${crl_update_failure}    occurrences=${1}    should_exist=${True}
    Verify Status for CRL Failure    DnsResolutionFailed
    Perform recommissioning    type=delta    delta_file=${Valid_crl_file}
    Sleep    300
    Verify Alarm    faultid=${crl_update_failure}    occurrences=${0}    should_exist=${False}
    CRL Verification with NMS

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

CRL Verification with NMS
    Setup Ems    config_device=netact1042    alias=lab42
    Cm Upload    config_device=netact1042    alias=lab42
    Configuration Manage    config_device=netact1042    config=enable_ldap_params.json    plan_name=enable_ldap   delete_plan="True"
...     timeout=300   alias=lab42
    Sleep    300
    Verify Alarm    faultid=${crl_update_failure}    occurrences=0    should_exist=${False}
    Configuration Manage    config_device=netact1042    config=invalid_ldap_params.json    plan_name=enable_ldap   delete_plan="True"
...     timeout=300   alias=lab42
    Sleep    300
    Verify Alarm    faultid=${crl_update_failure}    occurrences=1    should_exist=${True}

    Teardown Ems    config_device=netact1042    alias=lab42


Restore default certificates and delete certificate parameter
    certificate configure    operation=restore_vendor_certificate   timeout=60   alias=default
    Perform Recommissioning    type=param   rat=common    param_path=CMP-1:caSubjectName    operation=delete   value=CN=add_lte3065_ta13
...     timeout=300
    Perform Recommissioning    type=param   rat=common    param_path=CMPECDSA-1:caSubjectName    operation=delete   value=CN=VALIDECDSA7351TA
...     timeout=300


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

Start var log on DUT
    Setup Enb Fsm Access
    ${a}=    Execute Command On Enb    tail -f /var/log/trs | grep -i cert > /tmp/cmp.txt &

Stop var log on DUT
    Execute Command On Enb    killall tail
    Sleep    5
    Get Enb File    /tmp/cmp.txt    ${EXECDIR}/cmp.txt
    Teardown Enb Fsm Access
