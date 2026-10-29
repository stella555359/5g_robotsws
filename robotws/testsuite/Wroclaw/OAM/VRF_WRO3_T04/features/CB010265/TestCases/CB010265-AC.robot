*** Settings ***
Documentation
...    Author:            Patryk Tatarek
...    Contact:           patryk.tatarek@nokia.com
...    Test Plan (QC):    /VRF_WRO3_T04/CB010265_Legacy_features_TC's/
...    Description:       Verify visibility of different certificate related alarms and
...                       basic functionalities of certificate related tools like:
...                           - Certificate initialization/installation
...                           - Certificate revocation list update
...                           - CRLDPConfig objects

Resource    ../Resources/CB010265_Keywords.robot

*** Keywords ***
Trust_Anchor_Certificate_expiry_alarm
    Log    Configuring CMP server with CN=CB007672    console=true
    Configure CMP                   ca_subject_name=CN=CB007672    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    Log    Initialization the certificate    console=true
    Initialize Certificate          hw_type=vDU
    ${cert_expire_alarm}=           Convert to String    Operator Certificate About to Expire or Expired
    ${cert_time_mismatch_alarm}=    Convert to String    End Entity Certificate Update Time Mismatch
    Log    Changing the caCertificateUpdateTime parameter to 4999     console=true
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CMP-1
    ...                             param_name=caCertificateUpdateTime    param_value=4999    hw_type=vDU
    ${alarms_list}=                 Get Active Alarms From BTS    hw_type=vDU
    ${alarms}=                      Convert to String    ${alarms_list}
    Log    Checking if "Operator Certificate About to Expire or Expired" alarm is visible on BTS     console=true
    Should Contain                  ${alarms}    ${cert_expire_alarm}
    Log    Changing the caCertificateUpdateTime parameter to 30    console=true
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CMP-1
    ...                             param_name=caCertificateUpdateTime    param_value=30    hw_type=vDU
    ${alarms_list}=                 Get Active Alarms From BTS    hw_type=vDU
    ${alarms}=                      Convert to String    ${alarms_list}
    Log    Checking if "Operator Certificate About to Expire or Expired" alarm is not visible on BTS     console=true
    Should Not Contain              ${alarms}    ${cert_expire_alarm}
    Log    Changing the neCertificateUpdateTime parameter to 4999    console=true
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CMP-1
    ...                             param_name=neCertificateUpdateTime    param_value=4999    hw_type=vDU
    ${alarms_list}=                 Get Active Alarms From BTS    hw_type=vDU
    ${alarms}=                      Convert to String    ${alarms_list}
    Log    Checking if "End Entity Certificate Update Time Mismatch" alarm is visible on BTS     console=true
    Should Contain                  ${alarms}    ${cert_time_mismatch_alarm}
    Log    Changing the neCertificateUpdateTime parameter to 30    console=true
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CMP-1
    ...                             param_name=neCertificateUpdateTime    param_value=30    hw_type=vDU
    ${alarms_list}=                 Get Active Alarms From BTS    hw_type=vDU
    ${alarms}=                      Convert to String    ${alarms_list}
    Log    Checking if "End Entity Certificate Update Time Mismatch" alarm is not visible on BTS     console=true
    Should Not Contain              ${alarms}    ${cert_time_mismatch_alarm}
    [Teardown]                      Restore vDU Default Certificates

Trigger_EC_CRL_Update
    ${cert}=                        Convert to String    CN=CB005999_test
    Configure CMP                   ca_subject_name=CN=CB005999_test    server_type=ECDSA    hw_type=vDU
    Update CMP Server Settings      key_pool_type=ECDSA    hw_type=vDU
    Initialize Certificate          key_pool_type=ECDSA    hw_type=vDU
    ${cert_list}=                   Check Certificates    hw_type=vDU
    ${cert_list_string}=            Convert to String    ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    ${conn}=                        Connect to ADMIN    hw_type=vDU
    ${crl_info}=                    vdu_admin.get_vdu_crl_information    vdu_connection=${conn}
    ${crl_info_string}=             Convert to String    ${crl_info}
    Should not Contain              ${crl_info_string}    ${cert}
    vdu_admin.update_CRL_info       vdu_connection=${conn}
    Sleep    5                      reason=Wait until CRL update starts
    Wait Until Keyword Succeeds     15min    10s    Check if last CRL Update was correct on vDU
    ${cert_list}=                   Check Certificates    hw_type=vDU
    ${cert_list_string}=            Convert to String    ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    ${crl_info}=                    vdu_admin.get_vdu_crl_information    vdu_connection=${conn}
    ${crl_info_string}=             Convert to String    ${crl_info}
    Should Contain                  ${crl_info_string}    ${cert}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn}    hw_type=vDU
    Perform Reset and Wait for Expected State    state=onAir   hw_type=vDU
    Restore vDU Default Certificates
    Initialize Certificate          key_pool_type=ECDSA    hw_type=vDU
    ${conn}=                        Connect to ADMIN    hw_type=vDU
    vdu_admin.update_CRL_info       vdu_connection=${conn}
    Sleep    5                      reason=Wait until CRL update starts
    Wait Until Keyword Succeeds     15min    10s    Check if last CRL Update was correct on vDU
    ${cert_list}=                   Check Certificates    hw_type=vDU
    ${cert_list_string}=            Convert to String    ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    ${conn}=                        Connect to ADMIN    hw_type=vDU
    ${crl_info}=                    vdu_admin.get_vdu_crl_information    vdu_connection=${conn}
    ${crl_info_string}=             Convert to String    ${crl_info}
    Should Contain                  ${crl_info_string}    ${cert}
    Restore vDU Default Certificates
    Initialize Certificate          key_pool_type=ECDSA    hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CMPECDSA-1
    ...                             param_name=caSubjectName    param_value=CN=CB010265_First_ECDSA    hw_type=vDU
    Initialize Certificate          key_pool_type=ECDSA    hw_type=vDU
    ${cert_list}=                   Check Certificates    hw_type=vDU
    ${cert_list_string}=            Convert to String    ${cert_list}
    ${new_cert}=                    Convert to String    CN=CB010265_First_ECDSA
    Should Contain                  ${cert_list_string}    ${new_cert}
    vdu_admin.update_CRL_info       vdu_connection=${conn}
    Sleep    5                      reason=Wait until CRL update starts
    Wait Until Keyword Succeeds     15min    10s    Check if last CRL Update was incorrect on vDU
    ${alarms_list}=                 Get Active Alarms From BTS    hw_type=vDU
    ${alarms}=                      Convert to String    ${alarms_list}
    Should Not Contain              ${alarms}    ${crl_update_alarm}
    [Teardown]                      Run Keywords    Run Keyword and Ignore Error
    ...                             Disconnect from ADMIN    connection=${conn}    hw_type=vDU
    ...    AND                      Configure CMP    ca_subject_name=CN=CB005999_test
    ...                             server_type=ECDSA    hw_type=vDU
    ...    AND                      Restore vDU Default Certificates

Operator_adds_additional_TA_or_cross-signed_certificates_from_cNMS
    FOR    ${nr}    IN RANGE    1    13
        SSHLibrary.Open Connection    ${SSH_VDU_IP}
        SSHLibrary.Login              core    system123
        SSHLibrary.Write              openssl genrsa -out ca${nr}.pem 2048
        Sleep    1s                   reason=Wait until terminal execute the command
        SSHLibrary.Write              openssl genrsa -out cakey.pem 2048
        Sleep    1s                   reason=Wait until terminal execute the command
        ${command}=    Catenate       openssl req -x509 -new -SHA256 -nodes -key cakey.pem -days 3650 -out ca${nr}.pem
        ...                           -addext keyUsage=critical,keyCertSign,cRLSign
        SSHLibrary.Write              ${command}
        Sleep    1s                   reason=Wait until terminal execute the command
        SSHLibrary.Write              ${Empty}
        Sleep    1s                   reason=Wait until terminal execute the command
        SSHLibrary.Write              ${Empty}
        Sleep    1s                   reason=Wait until terminal execute the command
        SSHLibrary.Write              ${Empty}
        Sleep    1s                   reason=Wait until terminal execute the command
        SSHLibrary.Write              ${Empty}
        Sleep    1s                   reason=Wait until terminal execute the command
        SSHLibrary.Write              ${Empty}
        Sleep    1s                   reason=Wait until terminal execute the command
        SSHLibrary.Write              ${Empty}
        Sleep    1s                   reason=Wait until terminal execute the command
        SSHLibrary.Write              ${Empty}
        Sleep    1s                   reason=Wait until terminal execute the command
        SSHLibrary.Get File           ca${nr}.pem    /home/ute/ca${nr}.pem
        Sleep    1s                   reason=Wait until file is downloaded
        SSHLibrary.Write              rm ca${nr}.pem
        Sleep    1s                   reason=Wait until terminal execute the command
        SSHLibrary.Write              rm cakey.pem
        Sleep    1s                   reason=Wait until terminal execute the command
        SSHLibrary.Close Connection
        Install Certificate           cert_path=/home/ute/ca${nr}.pem    cert_type=CA    hw_type=vDU
    END
    SSHLibrary.Open Connection    ${SSH_VDU_IP}
    SSHLibrary.Login              core    system123
    SSHLibrary.Write              openssl ecparam -genkey -name prime256v1 -out ca256.key
    Sleep    1s                   reason=Wait until terminal execute the command
    ${command}=    Catenate       openssl req -x509 -new -SHA256 -nodes -key ca256.key -days 3650 -out ca256.pem
        ...                       -addext keyUsage=keyCertSign
    SSHLibrary.Write              ${command}
    Sleep    1s                   reason=Wait until terminal execute the command
    SSHLibrary.Write              ${Empty}
    Sleep    1s                   reason=Wait until terminal execute the command
    SSHLibrary.Write              ${Empty}
    Sleep    1s                   reason=Wait until terminal execute the command
    SSHLibrary.Write              ${Empty}
    Sleep    1s                   reason=Wait until terminal execute the command
    SSHLibrary.Write              ${Empty}
    Sleep    1s                   reason=Wait until terminal execute the command
    SSHLibrary.Write              ${Empty}
    Sleep    1s                   reason=Wait until terminal execute the command
    SSHLibrary.Write              ${Empty}
    Sleep    1s                   reason=Wait until terminal execute the command
    SSHLibrary.Write              ${Empty}
    Sleep    1s                   reason=Wait until terminal execute the command
    SSHLibrary.Get File           ca256.pem    /home/ute/ca256.pem
    Sleep    1s                   reason=Wait until file is downloaded
    SSHLibrary.Write              rm ca256.pem
    Sleep    1s                   reason=Wait until terminal execute the command
    SSHLibrary.Write              rm ca256.key
    Sleep    1s                   reason=Wait until terminal execute the command
    SSHLibrary.Close Connection
    ${status}=                    Run Keyword and Return Status    Install Certificate
    ...                           cert_path=/home/ute/ca256.pem    cert_type=CA    hw_type=vDU
    Should not be True            ${status}
    [Teardown]    Run Keywords    Run Keyword and Ignore Error    SSHLibrary.Close All Connections
    ...    AND    Delete Downloaded and Installed Certificates
    ...    AND    Restore vDU Default Certificates

Elliptic_curve_certificate_algorithm_and_key_length
    #SHA256
    Configure CMP                   ca_subject_name=CN=CB010265_First_ECDSA    server_type=ECDSA    hw_type=vDU
    Update CMP Server Settings      key_pool_type=ECDSA    hw_type=vDU
    Initialize Certificate          key_pool_type=ECDSA    hw_type=vDU
    ${certs}=                       Check Certificates     hw_type=vDU
    ${certs_string}=                Convert to String      ${certs}
    ${sha256_cert}=                 Convert to String      CN=CB010265_First_ECDSA
    Should Contain                  ${certs_string}        ${sha256_cert}
    Restore vDU Default Certificates
    #SHA384
    Configure CMP                   ca_subject_name=CN=CB005999_test    server_type=ECDSA    hw_type=vDU
    Update CMP Server Settings      key_pool_type=ECDSA    hw_type=vDU
    Initialize Certificate          key_pool_type=ECDSA    hw_type=vDU
    ${certs}=                       Check Certificates     hw_type=vDU
    ${certs_string}=                Convert to String      ${certs}
    ${sha384_cert}=                 Convert to String      CN=CB005999_test
    Should Contain                  ${certs_string}        ${sha384_cert}
    [Teardown]                      Restore vDU Default Certificates

Operator_triggers_certificate_revocation_list_update_via_DP_is_ManualConfiguration_from_WebEM
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=distributionPointSource
    ...                             param_value=Configuration_parameter    hw_type=vDU
    Configure CMP                   ca_subject_name=CN=CB007672    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    Initialize Certificate          hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP
    ...                             param_value=${primary_param_value}    hw_type=vDU
    ${primary_values}=    Create List    pValue2     pValue3     pValue4     pValue5     pValue6     pValue7    pValue8
    ...                                  pValue9     pValue10    pValue11    pValue12    pValue13    pValue14
    ...                                  pValue15    pValue16    pValue17    pValue18    pValue19    pValue20
    Create Mutliple CRLDP Objects with Only PrimaryCRLDP    start=2    stop=21
    ...                                                     primary_values=${primary_values}    hw_type=vDU
    ${conn}=    Connect to ADMIN    hw_type=vDU
    vdu_admin.update_CRL_info       vdu_connection=${conn}
    Wait Until Keyword Succeeds     15min    10s    Check if last CRL Update was incorrect on vDU
    Log                             Looking for "${crl_update_alarm}" alarm    console=True
    Wait Until Keyword Succeeds     15min    10s    Alarm Should be Active    alarm=${crl_update_alarm}    hw_type=vDU
    Disconnect from ADMIN           connection=${conn}    hw_type=vDU
    Perform Reset and Wait for Expected State    state=onAir   hw_type=vDU
    Restore vDU Default Certificates
    Initialize Certificate          hw_type=vDU
    ${conn}=                        Connect to ADMIN    hw_type=vDU
    vdu_admin.update_CRL_info       vdu_connection=${conn}
    Wait Until Keyword Succeeds     15min    10s    Check if last CRL Update was incorrect on vDU
    Log                             Looking for "${crl_update_alarm}" alarm    console=True
    Wait Until Keyword Succeeds     15min    10s    Alarm Should be Active    alarm=${crl_update_alarm}    hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=usageEnabled
    ...                             param_value=Disabled    hw_type=vDU
    vdu_admin.update_CRL_info       vdu_connection=${conn}
    Wait Until Keyword Succeeds     15min    10s    CRL should be empty on vDU
    Wait Until Keyword Succeeds     15min    10s    Alarm Should not be Active    alarm=${crl_update_alarm}    hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=usageEnabled
    ...                             param_value=Enabled    hw_type=vDU
    vdu_admin.update_CRL_info       vdu_connection=${conn}
    Wait Until Keyword Succeeds     15min    10s    Check if last CRL Update was incorrect on vDU
    Log                             Looking for "${crl_update_alarm}" alarm    console=True
    Wait Until Keyword Succeeds     15min    10s    Alarm Should be Active    alarm=${crl_update_alarm}    hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=distributionPointSource
    ...                             param_value=Certificate_extension    hw_type=vDU
    vdu_admin.update_CRL_info       vdu_connection=${conn}
    Wait Until Keyword Succeeds     15min    10s    Check if last CRL Update was correct on vDU
    Sleep                           300    reason=Give this alarm some time
    ${alarms_list}=                 Get Active Alarms From BTS    hw_type=vDU
    ${alarms}=                      Convert to String    ${alarms_list}
    Should Not Contain              ${alarms}    ${crl_update_alarm}
    ${status}=                      Run Keyword and Return Status
    ...                             Add Parameter on BTS
    ...                             dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=secondaryCRLDP
    ...                             param_value=${primary_param_value}    hw_type=vDU
    Should Not Be True              ${status}
    [Teardown]    Run Keywords    Delete Mutliple CRLDP Objects    start=2    stop=21    hw_type=vDU
    ...    AND    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn}    hw_type=vDU
    ...    AND    Restore vDU Default Certificates
    ...    AND    Change Parameter on BTS
    ...           dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...           param_name=distributionPointSource
    ...           param_value=Certificate_extension    hw_type=vDU
    ...    AND    Change Parameter on BTS
    ...           dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...           param_name=usageEnabled
    ...           param_value=Enabled    hw_type=vDU
