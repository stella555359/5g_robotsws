*** Settings ***
Documentation
...                 [Procedure]    "The test case is planned to validate Max Ipsec Tunnels"
...                 [Date]    "15-09-25"
...                 [Author]    "Pranitha"
...                 [QC_Path]    "QC_Path in Test Plan"
...                 [QC_ID]    "QC_ID in Test Lab for reporting"
...                 [Validation_status]    "Validated and Passed"
...                 [Validated_TestLine]    "TL-1"
...                 [Config]    "This script verifies Ipsec tunnels for long duration"
...                 [RunTime Parameters]    "[bts_id used is 1]"

Resource            ${CURDIR}/../resources/common_keywords.robot
Resource            ${CURDIR}/../resources/Admin_Common_Library.robot
Resource            ${CURDIR}/resources/common_keywords_PET.robot

Suite Setup         Run Keywords    Suite Setup Preconditions
...                     AND    Setup Oamops
Suite Teardown      Run Keywords    Suite Teardown Postconditions
...                     AND    Teardown Oamops


*** Variables ***
${TOTAL_DURATION}       1728    # 48 hours in seconds
${INTERVAL}             720    # 2 hours in seconds


*** Test Cases ***
[1] 48h Stability test with IPSEC with max IPSEC tunnels
    Perform Commissioning
    ...    scf_file=${base_scf_PET_maxvlan_ipif}
    ...    verify_bts_status=False
    ...    timeout=400
    ...    alias=default
    Sleep    250
    Run    sudo ipsec restart
    Enable 8639 feature
    Perform Recommissioning    type=delta    delta_file=${Max_ipsec}    timeout=300
    Sleep    120
    Periodic IPSec Verification Over 48 Hours


*** Keywords ***
Periodic IPSec Verification Over 48 Hours
    [Documentation]    Run full IPSec verification every 2 hours for 48h. Stop on failure.
    ${iterations}=    Evaluate    ${TOTAL_DURATION} // ${INTERVAL}
    Log    Running IPSec verification ${iterations} times every 2 hours
    FOR    ${i}    IN RANGE    ${iterations}
        Log    Iteration ${i+1}
        Perform Full IPSec Verification
        Sleep    ${INTERVAL}s
    END
    Log    Completed 48 hours periodic IPSec verification

Perform Full IPSec Verification
    Perform Recommissioning
    ...    type=param
    ...    param_path=IPSECC-1:ipSecEnabled
    ...    operation=update
    ...    value=false
    ...    timeout=120
    Run    sudo ipsec restart
    Sleep    60
    Verify IPSec Status    NO_STATE
    # Install cert on bts
    # Install Ipsec Cerificate on Strongswan
    # Sleep    60
    Perform Recommissioning
    ...    type=param
    ...    param_path=IPSECC-1:ipSecEnabled
    ...    operation=update
    ...    value=true
    ...    timeout=180
    Sleep    30
    Run    sudo ipsec restart
    Sleep    120
    Wait Until Keyword Succeeds    9 min    1 min    Verify IPSec Status    ESTABLISHED

Enable 8639 feature
    Restore all Certificate
    Read CMP Parameters    RSA
    Instal Additional certificates    RSA
    Tigger IR_KUR    RSA    install_cmp_certificate
    verify cmp status    RSA    CMP_InitializationOK
    Tigger IR_KUR    RSA    cmp_update_key
    verify cmp status    RSA    CMP_KeyUpdateOK
    Block sha1 certificate and verify certificate installation
    Block RSA 2k certificate and verify certificate installation
    UnBlock sha1 certificate and verify certificate installation
    UnBlock RSA 2k certificate and verify certificate installation

Restore all Certificate
    certificate configure    operation=restore_vendor_certificate
    Sleep    10
    certificate configure    operation=delete_cert    all_certs=${True}
    Sleep    10

Read CMP Parameters
    [Arguments]    ${CertType}
    Get Mplane details    ${Mplane_Ip_path}
    Get SrcCMPCrlConfigured details    ${SrcCMPCrlConfigured_IP_path}
    IF    '${CertType}' == 'RSA'    Get RSA details

Get RSA details
    ${cmp_ip_dict}=    Query Admin Infomodel    query=get object ${cmp_ip_path}    timeout=160
    ${primary_cmp_ip}=    Get From Dictionary    dictionary=${cmp_ip_dict}    key=serverHost
    ${secondary_cmp_ip}=    Get From Dictionary    dictionary=${cmp_ip_dict}    key=secondaryServerHost
    Set Suite Variable    ${primary_cmp_ip}    ${primary_cmp_ip}
    Set Suite Variable    ${secondary_cmp_ip}    ${secondary_cmp_ip}

Get SrcCMPCrlConfigured details
    [Arguments]    ${SrcCMPCrlConfigured_IP_path}
    ${srcCmpCrlIp}=    Get Parameter    param_path=${SrcCMPCrlConfigured_IP_path}
    Set Suite Variable    ${srcCmpCrlIp}    ${srcCmpCrlIp}

Get Mplane details
    [Arguments]    ${Mplane_Ip_path}
    ${mplaneIp}=    Get Parameter    param_path=${Mplane_Ip_path}
    Set Suite Variable    ${srccmp_Ip}    ${mplaneIp}

Instal Additional certificates
    [Arguments]    ${CertType}    ${Operation}=install_certificate
    Certificate Configure
    ...    key_pool_type=${CertType}
    ...    operation=${Operation}
    ...    cert_file=${block_sha1}
    ...    cert_type=AdditionalCa
    ...    cert_format=${Cert_format}
    Sleep    60
    Certificate Configure
    ...    key_pool_type=${CertType}
    ...    operation=${Operation}
    ...    cert_file=${block_sha2k}
    ...    cert_type=AdditionalCa
    ...    cert_format=${Cert_format}
    Sleep    60
    Certificate Configure
    ...    key_pool_type=${CertType}
    ...    operation=${Operation}
    ...    cert_file=${block_sha1k}
    ...    cert_type=AdditionalCa
    ...    cert_format=${Cert_format}
    Sleep    60
    Certificate Configure
    ...    key_pool_type=${CertType}
    ...    operation=${Operation}
    ...    cert_file=${block_sha4k}
    ...    cert_type=AdditionalCa
    ...    cert_format=${Cert_format}
    Sleep    60

Tigger IR_KUR
    [Arguments]    ${CertType}    ${Operation}
    Traffic Capture Start    capture_device=bts    alias=${cmp_alias}
    Certificate Configure    operation=${Operation}    key_pool_type=${CertType}    timeout=100
    ${cmp_pcap_log}=    Traffic Capture Stop    alias=${cmp_alias}
    Set Suite Variable    ${cmp_pcap_log}    ${cmp_pcap_log}
    [Teardown]    Run Keyword And Ignore Error    Traffic Capture Stop    alias=${cmp_alias}

verify cmp status
    [Arguments]    ${certType}    ${CMP_status_check}
    Sleep    60
    IF    '${certType}' == 'RSA'
        Set Suite Variable    ${cmp_state_path}    ${cmp_r_moc_path}
    END
    ${cmp_state_var}=    Query Admin Infomodel    query=get object ${cmp_state_path}
    Should be equal    ${cmp_state_var['state']}    ${CMP_status_check}

Block sha1 certificate and verify certificate installation
    Perform Recommissioning    type=param    param_path=${block_sha1_path}:blockSha1CertChain    operation=update
    ...    value=true    timeout=60
    Restore all Certificate
    Read CMP Parameters    RSA
    Instal Additional certificates1    RSA

Block RSA 2k certificate and verify certificate installation
    Perform Recommissioning
    ...    type=param
    ...    param_path=${block_sha1_path}:blockRsaKeyLengthBelow2048
    ...    operation=update
    ...    value=true
    ...    timeout=60
    Restore all Certificate
    Read CMP Parameters    RSA
    Instal Additional certificates2    RSA

UnBlock sha1 certificate and verify certificate installation
    Perform Recommissioning    type=param    param_path=${block_sha1_path}:blockSha1CertChain    operation=update
    ...    value=false    timeout=60
    Restore all Certificate
    Read CMP Parameters    RSA
    Instal Additional certificates3    RSA

UnBlock RSA 2k certificate and verify certificate installation
    Perform Recommissioning    type=param    param_path=${block_sha1_path}:blockSha1CertChain    operation=update
    ...    value=true    timeout=60
    Perform Recommissioning
    ...    type=param
    ...    param_path=${block_sha1_path}:blockRsaKeyLengthBelow2048
    ...    operation=update
    ...    value=false
    ...    timeout=60
    Restore all Certificate
    Read CMP Parameters    RSA
    Instal Additional certificates4    RSA

Instal Additional certificates1
    [Arguments]    ${CertType}    ${Operation}=install_certificate
    Run keyword And Expect Error
    ...    ${weak_signature}
    ...    Certificate Configure
    ...    key_pool_type=${CertType}
    ...    operation=${Operation}
    ...    cert_file=${block_sha1}
    ...    cert_type=AdditionalCa
    ...    cert_format=${Cert_format}
    Sleep    60
    Certificate Configure    key_pool_type=${CertType}    operation=${Operation}    cert_file=${block_sha2k}
    ...    cert_type=AdditionalCa    cert_format=${Cert_format}
    Sleep    60
    Run keyword And Expect Error
    ...    ${weak_signature}
    ...    Certificate Configure
    ...    key_pool_type=${CertType}
    ...    operation=${Operation}
    ...    cert_file=${block_sha1k}
    ...    cert_type=AdditionalCa
    ...    cert_format=${Cert_format}
    Sleep    60
    Certificate Configure    key_pool_type=${CertType}    operation=${Operation}    cert_file=${block_sha4k}
    ...    cert_type=AdditionalCa    cert_format=${Cert_format}
    Sleep    60

Instal Additional certificates2
    [Arguments]    ${CertType}    ${Operation}=install_certificate
    Run keyword And Expect Error    ${length_not_supported}    Certificate Configure    key_pool_type=${CertType}
    ...    operation=${Operation}    cert_file=${block_sha1}    cert_type=AdditionalCa    cert_format=${Cert_format}
    Sleep    60
    Run keyword And Expect Error    ${length_not_supported}    Certificate Configure    key_pool_type=${CertType}
    ...    operation=${Operation}    cert_file=${block_sha2k}    cert_type=AdditionalCa    cert_format=${Cert_format}
    Sleep    60
    Run keyword And Expect Error    ${weak_signature}    Certificate Configure    key_pool_type=${CertType}
    ...    operation=${Operation}    cert_file=${block_sha1k}    cert_type=AdditionalCa    cert_format=${Cert_format}
    Sleep    60
    Certificate Configure    key_pool_type=${CertType}    operation=${Operation}    cert_file=${block_sha4k}
    ...    cert_type=AdditionalCa    cert_format=${Cert_format}
    Sleep    60

Instal Additional certificates3
    [Arguments]    ${CertType}    ${Operation}=install_certificate
    Run keyword And Expect Error    ${length_not_supported}    Certificate Configure    key_pool_type=${CertType}
    ...    operation=${Operation}    cert_file=${block_sha1}    cert_type=AdditionalCa    cert_format=${Cert_format}
    Sleep    60
    Run keyword And Expect Error    ${length_not_supported}    Certificate Configure    key_pool_type=${CertType}
    ...    operation=${Operation}    cert_file=${block_sha2k}    cert_type=AdditionalCa    cert_format=${Cert_format}
    Sleep    60
    Certificate Configure    key_pool_type=${CertType}    operation=${Operation}    cert_file=${block_sha1k}
    ...    cert_type=AdditionalCa    cert_format=${Cert_format}
    Sleep    60
    Certificate Configure    key_pool_type=${CertType}    operation=${Operation}    cert_file=${block_sha4k}
    ...    cert_type=AdditionalCa    cert_format=${Cert_format}
    Sleep    60

Instal Additional certificates4
    [Arguments]    ${CertType}    ${Operation}=install_certificate
    Run keyword And Expect Error    ${weak_signature}    Certificate Configure    key_pool_type=${CertType}
    ...    operation=${Operation}    cert_file=${block_sha1}    cert_type=AdditionalCa    cert_format=${Cert_format}
    Sleep    60
    Certificate Configure    key_pool_type=${CertType}    operation=${Operation}    cert_file=${block_sha2k}
    ...    cert_type=AdditionalCa    cert_format=${Cert_format}
    Sleep    60
    Run keyword And Expect Error    ${weak_signature}    Certificate Configure    key_pool_type=${CertType}
    ...    operation=${Operation}    cert_file=${block_sha1k}    cert_type=AdditionalCa    cert_format=${Cert_format}
    Sleep    60
    Certificate Configure    key_pool_type=${CertType}    operation=${Operation}    cert_file=${block_sha4k}
    ...    cert_type=AdditionalCa    cert_format=${Cert_format}
    Sleep    60

Install cert on bts
    Certificate Configure
    ...    operation=install_certificate
    ...    cert_file=${PET_cert}
    ...    cert_type=BtsTrustChain
    ...    cert_format=P12
    ...    password=Nokia1234!
    Sleep    60

Verify IPSec Status
    [Arguments]    ${IKEP_State}
    ${ikep_list}=    Query Admin Infomodel    query=get list //IKEP_R-1    timeout=30
    ${len}=    Get Length    ${ikep_list}
    FOR    ${item}    IN    @{ikep_list}
        ${state}=    Get From Dictionary    ${item}    ikePeerState
        Should be Equal    ${state}    ${IKEP_State}
    END

Install Ipsec Cerificate on Strongswan
    SSHLibrary.Open connection    ${config.Strongswan_ip}
    SSHLibrary.Login    ${config.Strongswan_user}    ${config.Strongswan_passwd}
    Execute Command    sudo rm -rf ${cert_PrivateKey}
    Execute Command    sudo rm -rf ${cert_Btspem}
    Execute Command    sudo ln -s ${SHA1_cert_PrivateKey} ${cert_PrivateKey}
    Execute Command    sudo ln -s ${SHA1_cert_Btspem} ${cert_Btspem}
    [Teardown]    SSHLibrary.Close Connection

Validate for 48h and verify Ipsec status
    ${logtime}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Should Match Regexp    ${logtime}    ${TIME_REGEX}
    Sleep    48h
    Verify IPSec Status    ESTABLISHED