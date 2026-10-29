*** Settings ***
Documentation
...     description:    Test cases for the CB005999-C feature.

Resource            ../resources/CB005999-C.robot
Resource            ../resources/variables.robot
Resource            ../../../common_resources/admin/admin.robot
Resource            ../../../common_resources/binary_files/binary_files.robot

*** Keywords ***
CB005999_Manual_install_EC_additional_TA_CA_Certificates_from_Webem_or_NMS
    Install Certificate On BTS     cert_file=${CERT_PATH}
    ...                            cert_type=AdditionalCa
    ...                            cert_format=PEM
    ${issuers}=  Create Issuers List
    Should Contain        ${issuers}   CN = CB005999_test
    [Teardown]    Clear Certificates

CB005999_Manual_removal_of_EC_type_TA_CA_certificates_from_WebEM_or_NMS
    ${netact_conn}=                         Connect to NetAct
    Install Certificate On BTS              cert_file=${CERT_PATH}
    ...                                     cert_type=AdditionalCa
    ...                                     cert_format=PEM
    ${FPRINT}=    Check If Fingerprint Is Stored
    Delete Certificate With NetAct          connection=${netact_conn}
    ...                                     fingerprint=${FPRINT}
    Sleep                                   30
    ...                                     reason=Wait until certificates on BTS updates
    ${FPRINT}=    Check If Fingerprint Is Stored
    Should Be Equal As Strings   ${FPRINT}  None
    [Teardown]    Disconnect from NetAct    connection=${netact_conn}

CB005999_Network_Element_Certificate_Profile_and_Key_Size
    Configure CMP  ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                     server_type=ECDSA
    Add eeSubjectAltNames To Scf
    FOR   ${key}   IN   @{KEY_LENGTH}
        Wait Until Keyword Succeeds  30 min  60 sec  Change Parameter on BTS  MRBTS-${mrbts}/MNL-1/CERTH-1/CMPECDSA-1  keyLength  ${key}
        Install And Check Certificate  ${key}
    END
    [Teardown]   Clear Certificates

CB005999_NE_rejects_EC_certificate_with_key_length_less_than_256bits
    ${sw_release}=  Get Software Release Name
    Log    ${sw_release}    console=true
    ${error_mess}=  Checking message for SW release  ${sw_release}
    Log    ${error_mess}    console=true
    Generate Binary File From HEX String    hex_string_file=${P12_TOO_SHORT_PATH_TXT}
    ...                                     binary_file_name=${CURDIR}/too_short_key.p12
    ${error_p12}=   Run Keyword And Expect Error   ${error_mess}
    ...                            Install Certificate On BTS
    ...                            cert_file=${CURDIR}/too_short_key.p12
    ...                            cert_type=BtsTrustChain
    ...                            cert_format=P12
    ...                            p12password=${P12_PASSWORD}
    ...                            key_pool_type=ECDSA
    Log  ${error_p12}  console=true
    ${error_pem}=  Run Keyword And Expect Error   ${error_mess}
    ...                            Install Certificate On BTS
    ...                            cert_file=${PEM_TOO_SHORT_PATH}
    ...                            cert_type=AdditionalCa
    ...                            cert_format=PEM
    ...                            key_pool_type=ECDSA
    Log  ${error_pem}   console=true

CB005999_Elliptic_curve_certificate_handling_for_vendor_certificate_restore
    Configure CMP                   ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                             server_type=ECDSA
    Initialize Certificates         key_pool_type=ECDSA
    ${FPRINT}=                      Check if Fingerprint Is Stored
    Log  ${FPRINT}  console=true
    ${cert_list}=                   Get Certificates List  TA
    Log  ${cert_list}  console=true
    Clear Certificates
    ${FPRINT}=                      Check if fingerprint is stored
    Log  ${FPRINT}  console=true
    Should Be Equal As Strings  ${FPRINT}  None

CB005999_NE_stores_new_Root_CA_Certificate_or_intermediate_CA_certficate_as_additional_Trust_Anchor
    Configure CMP                  ca_subject_name=${LONG_VALIDITY_SUBJECT_NAME}
    ...                            server_type=ECDSA

    Initialize Certificates        key_pool_type=ECDSA

    Configure CMP                  ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                            server_type=ECDSA

    Initialize Certificates        key_pool_type=ECDSA

    Install Certificate On BTS     cert_file=${VALID_PEM}
    ...                            cert_type=AdditionalCa
    ...                            cert_format=PEM

    Run Keyword And Expect Error   *Duplicate certificate found/error*
    ...                            Install Certificate On BTS
    ...                            cert_file=${cert_path}
    ...                            cert_type=AdditionalCa
    ...                            cert_format=PEM
    [Teardown]                     Clear Certificates

CB005999_Elliptic_curve_certificate_handling_for_clear_operator_certificate
    Install Certificate On BTS              cert_file=${cert_path}
    ...                                     cert_type=AdditionalCa
    ...                                     cert_format=PEM
    ${cert_list}=  Get Operator Certificates List
    Log  ${cert_list}  console=true
    ${FPRINT}=    Check If Fingerprint Is Stored
    Delete Certificate From BTS        ${FPRINT}
    ${FPRINT}=    Check If Fingerprint Is Stored
    Should Be Equal As Strings   ${FPRINT}  None
