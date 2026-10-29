*** Settings ***
Documentation
...     description:    Keywords for test cases for the CB005999-C feature.

Resource            ../../../common_resources/certificates/certificates.robot
Resource            ../../../common_resources/admin/admin.robot
Resource            ../../../common_resources/commissioning/commissioning.robot
Resource            ../../../common_resources/connections/connections.robot
Resource            ../../../common_resources/netact/netact_operations.robot
Resource            ./variables.robot

Library             taf.sbts.oam.coam.admin      WITH NAME   coam_admin
Library             ./resources.py

*** Variables ***
${CERT_PATH}                ${CURDIR}/certificates/CB005999_test.pem
${P12_TOO_SHORT_PATH_TXT}   ${CURDIR}/certificates/ec239_too_short_key_hex_string.txt
${PEM_TOO_SHORT_PATH}       ${CURDIR}/certificates/ca239_too_short_key.pem
${VALID_PEM}                ${CURDIR}/certificates/CB007672_FTP.pem
${LONG_VALIDITY_SUBJECT_NAME}   CN=CB005999_long_validity
${FPRINT}                   ${EMPTY}
${SCF_NAME}                 scf.xml
${ECDSA_SUBJECT_NAME}       CN = CB005999_test
&{PARAMS}                   subjectAltType=DOMAIN    subjectAltName=qwerty
${LOGIN}                    toor4nsn
${PASSWORD}                 oZPS0POrRieRtu
@{KEY_LENGTH}               256  384
${P12_PASSWORD}             YT_xk39b

*** Keywords ***
Check If Fingerprint Is Stored
    ${cert_list}=  Get Certificates List  TA
    Log  ${cert_list}  console=true
    FOR  ${list}  IN  @{cert_list}
        Log  ${list}  console=true
        ${FPRINT}=  Set variable  ${list}[fingerPrint]
        Return From Keyword If  '${list}[issuer]'=='CN = CB005999_test'  ${FPRINT}
    END

Get Fingerprint
    [Arguments]  ${list}
    Set variable  ${FPRINT}:${list}[fingerPrint]
    Log   ${list}[fingerPrint]  console=true
    [Return]  ${FPRINT}

Create Issuers List
    ${cert_list}=  Get Certificates List  TA
    @{issuers}=  Create List  ${EMPTY}
    FOR  ${list}  IN  @{cert_list}
        log  ${list}  console=true
        Append To List  ${issuers}  ${list}[issuer]
    END
    [Return]  @{issuers}

Add eeSubjectAltNames To Scf
    [Documentation]  Adding list eeSubjectAltNames with subjectAltType and subjectAltName parameters to scf and upload it to BTS
    ${base_scf_path}=    Download SCF
    ${new_scf_path}=  modify scf   ${mrbts}   ${PARAMS}  ${base_scf_path}
    Log  Uploading scf...  console=true
    Run Keyword With ADMIN Connection  coam_admin.perform_commissioning    scf_file=${new_scf_path}
    ...                                skip_parameter_relation_errors=False  should_activate=True  timeout=900
    Log  Scf uploaded  console=true

Install And Check Certificate
    [Arguments]  ${key}
    Initialize Certificates From NetAct   connection=${NETACT_CONNECTION}
    ...                                   server_type=ECDSA
    ${connection}=       Connect with SSH    192.168.255.129  ${LOGIN}  ${PASSWORD}  conn
    ${out}=  Execute   ls -la /rom/trs_data/active/keystorage/certs  conn
    ${output}=  Execute  openssl x509 -in /rom/trs_data/active/keystorage/certs/ec_cert.pem -text | grep "X509v3 Subject Alternative Name:" -A1   conn
    Log  ${out}  console=true
    Log  ${output}  console=true
    Log  &{params}[subjectAltName]  console=true
    Should contain  ${output}  &{params}[subjectAltName]
    ${output1}=  Execute  openssl x509 -in /rom/trs_data/active/keystorage/certs/ec_cert.pem -text | grep "Public-Key:"  conn
    Log  ${output1}  console=true
    Should contain  ${output1}  ${key}
    [Teardown]  Disconnect SSH Session    conn

Remove Certificate by WebEM
    ${FPRINT}=  Check if fingerprint is stored
    Delete Certificate From BTS  ${FPRINT}
    ${FPRINT}=  Check if fingerprint is stored
    Should be equal as strings   ${FPRINT}  None

Checking message for SW release
    [Arguments]    ${sw_release}
    ${error_mess}=  Run Keyword If  '${sw_release}'=='SBTS22R4'  Set Variable  *Certificate validation - keyLength is not supported*
    ...             ELSE    Set Variable    *Certificate validation - key length is not supported*
    [Return]    ${error_mess}
