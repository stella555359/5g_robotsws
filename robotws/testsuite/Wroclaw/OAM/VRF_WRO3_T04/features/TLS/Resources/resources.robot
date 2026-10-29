*** Settings ***
Documentation    Resources for TLS and certificates checks
...    Author:   urszula.warminska@nokia.com
...    Maintainer:    urszula.warminska@nokia.com

Resource        ../../../common_resources/emssim/emssim_setup.robot
Resource        ../../../common_resources/emssim/emssim.robot
Resource        ../../../common_resources/tls/tls.robot
Resource        ../../../common_resources/binary_files/binary_files.robot
Resource        ../../../common_resources/scf/scf_objects.robot
Library         taf.sbts.oam.coam.admin      WITH NAME   coam_admin
Resource        ../../../common_resources/admin/admin.robot
Resource        ../../../common_resources/certificates/certificates.robot
Resource        ../../../common_resources/ip_traffic/ip_traffic.robot
Resource        ../../../common_resources/connections/connections.robot
Resource        ../../../common_resources/mantaray/mantaray.robot
Resource        Variables.robot
Resource        ../../../common_resources/netact/netact_operations.robot
Library         ../Resources/resources.py

*** Keywords ***
Check If Vendor Certificate is Present
    [Documentation]    Description:    This keyword checks if vendor certificate is present on BTS
    ${vendor_cert_list}=    Get Certificates List    Vendor
    BuiltIn.Should Not Be Empty   ${vendor_cert_list}
    Log    \tVendor certificate is present on BTS    console=true

Manual install ECDSA and RSA certificate
    [Documentation]    Description:    This keyword installs RSA and ECDSA certificates on BTS. Given certificates has
    ...                                to be in p12 format and exist in TEST_OUTPUT_DIR
    Install Certificate On BTS              cert_file=${TEST_OUTPUT_DIR}/ECDSA.p12
    ...                                     cert_type=BtsTrustChain
    ...                                     cert_format=P12
    ...                                     p12password=${P12_PASSWORD}
    ...                                     key_pool_type=ECDSA
    Install Certificate On BTS              cert_file=${TEST_OUTPUT_DIR}/RSA.p12
    ...                                     cert_type=BtsTrustChain
    ...                                     cert_format=P12
    ...                                     p12password=${P12_PASSWORD}
    ...                                     key_pool_type=RSA

Trust Anchor Certificate with expiry alarm
    Install Certificate On BTS     cert_file=${cert_pem}
    ...                            cert_type=AdditionalCa
    ...                            cert_format=PEM
    Change Parameter on BTS        dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                            param_name=caCertificateUpdateTime
    ...                            param_value=3660
    Wait until keyword succeeds    10 min    30 sec    Alarm Should be Active In BTS    fault_id=61618
    [Teardown]    Clear Certificates

Reconfigure CMP for RSA certificate by WebEM

    Configure CMP                           ca_subject_name=${SECOND_SUBJECT_NAME}[RSA]
    ...                                     server_type=RSA
    Set CMP Server Settings                 key_pool_type=RSA
    Initialize Certificates                 key_pool_type=RSA

Check Synchronization By Ssh
    # dodac aby sprawdzil czy to jest asib, asil i asia, asoe - jesli tak to niech idzie
    [Documentation]    Description:    This keyword verifies if certificates are synchronized between active
    ...                                and passive partition.
    Clear Certificates
    @{cert_type}    Create List
    Append To List    ${cert_type}    RSA    ECDSA
    FOR    ${i}    IN    @{cert_type}
        Set CMP Server Settings    key_pool_type=${i}
        Set CMP Server Settings    key_pool_type=${i}
        Configure CMP              bts_id=${bts_id}
        ...                        server_type=${i}
        ...                        ca_subject_name=${CERTS_SUBJECT_NAME['${i}']}
        Initialize Certificates    key_pool_type=${i}
    END
    ${connection}=       Connect with SSH    192.168.255.129  ${LOGIN}  ${PASSWORD}  conn
    ${output_act_ecdsa}=  ssh.Execute
    ...    openssl x509 -in /rom/trs_data/active/keystorage/certs/ec_cert.pem -text | grep "Serial Number:" -A1   conn
    ${output_act_rsa}=  ssh.Execute
    ...    openssl x509 -in /rom/trs_data/active/keystorage/certs/cert.pem -text | grep "Serial Number:" -A1    conn
    Log  ${output_act_ecdsa}  console=true
    Log  ${output_act_rsa}  console=true
    ${output1}=  ssh.Execute
    ...    encfs --public --crakey "/etc/keys.d/private/sok.crk&enc.crk" ${SYNC_PATHS} -o nonempty,allow_other  conn
    ${output_pass_ecdsa}=  ssh.Execute
    ...    openssl x509 -in /ffs/stb/trs_data/active/keystorage/certs/ec_cert.pem -text | grep "Serial Number:" -A1
    ...    conn
    ${output_pass_rsa}=  ssh.Execute
    ...    openssl x509 -in /ffs/stb/trs_data/active/keystorage/certs/cert.pem -text | grep "Serial Number:" -A1
    ...    conn
    Log  ${output_pass_ecdsa}  console=true
    Log  ${output_pass_rsa}  console=true
    Should be equal as strings   ${output_act_ecdsa}   ${output_pass_ecdsa}
    Should be equal as strings   ${output_act_rsa}   ${output_pass_rsa}
    [Teardown]  Disconnect SSH Session    conn

Check certificates on BTS
    [Documentation]    Description:    This keyword verifies if certificate on BTS has expected key type
    ${keyPoolType_EC}=  Get KeyPoolType From BTS Certificate    CN = CB005999_long_validity
    Log  ${keyPoolType_EC}  console=True
    Check If Certificate File Is Present On BTS  ${keyPoolType_EC}
    ${keyPoolType_RSA}=  Get KeyPoolType From BTS Certificate  C = PL, ST = WRO, O = Nokia, CN = RSA_cert_common
    Log  ${keyPoolType_RSA}  console=True
    Check If Certificate File Is Present On BTS  ${keyPoolType_RSA}
    BuiltIn.Should Be Equal    ${keyPoolType_EC}    ECDSA
    BuiltIn.Should Be Equal    ${keyPoolType_RSA}    RSA

Set Subject Alternative Name
    [Documentation]    Description:    This keyword sets Subject Alternative name for indicated cert type.
    ...                                Type of Subject Alternative Name: DOMAIN.
    ...                Arguments:      ${server_type}: Used certificate type; takes the value: RSA, ECDSA
    [Arguments]    ${server_type}=RSA
    Configure CMP                          ca_subject_name=wrong
    ...                                    server_type=${server_type}
    Run Keyword and Ignore Error           Clear Certificates
    ${server_object_name}               Get From Dictionary   ${CMP_OBJECT}   ${server_type}
    Change Parameter on BTS             dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/${server_object_name}
    ...                                 param_name=eeSubjectAltNames
    ...                                 param_value=${SUBJECT_ALT_NAME_LIST}
    &{SUBJECT_ALT_NAME}=                   Create Dictionary    subjectAltName=${TOO_LONG}    subjectAltType=DOMAIN
    @{parameter}=                          Create List    ${SUBJECT_ALT_NAME}
    Run Keyword And Expect Error           *VALUE_IS_TO_TOO_LONG*    Change Parameter on BTS
    ...                                    dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/${server_object_name}
    ...                                    param_name=eeSubjectAltNames
    ...                                    param_value=${parameter}
    FOR    ${i}    IN    @{SUBJECT_ALT_NAME_INCORRECT}
        Log    Changing the subjectAltName with the following value: ${i}    console=true
        &{SUBJECT_ALT_NAME}=               Create Dictionary    subjectAltName=${i}    subjectAltType=DOMAIN
        @{parameter}=                      Create List    ${SUBJECT_ALT_NAME}
        Run Keyword And Expect Error       *INCORRECT_PATTERN*    Change Parameter on BTS
        ...                                dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/${server_object_name}
        ...                                param_name=eeSubjectAltNames
        ...                                param_value=${parameter}
    END
    &{SUBJECT_ALT_NAME}=                   Create Dictionary    subjectAltName=${SUBJECT_ALT_NAME_INCORRECT1}
    ...                                                         subjectAltType=IP Address
    @{parameter}=                          Create List    ${SUBJECT_ALT_NAME}
    Run Keyword And Expect Error           *subjectAltName shall be of IPV4 or IPV6*    Change Parameter on BTS
    ...                                    dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/${server_object_name}
    ...                                    param_name=eeSubjectAltNames
    ...                                    param_value=${parameter}
    FOR    ${i}    IN    @{SUBJECT_ALT_CORRECT}
        ${altType}=    Set Variable    ${i.split('=')[0]}
        ${altName}=    Set Variable    ${i.split('=')[1]}
        Log    Changing the parameters for CMP and expect success    console=true
        Configure CMP                       ca_subject_name=wrong
        ...                                 server_type=${server_type}
        Run Keyword and Ignore Error        Clear Certificates
        Start TCPDump
        Set CMP Server Settings             key_pool_type=${server_type}
        Change parameter on BTS             MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
        ...                                 certTypeForTlsAuth
        ...                                 ${server_type}
        ${SUBJECT_NAME}    Set Variable If    '${server_type}'=='RSA'    ${RSA_SUBJECT_NAME}    ${ECDSA_SUBJECT_NAME}
        Configure CMP                       ca_subject_name=${SUBJECT_NAME}
        ...                                 server_type=${server_type}
        &{SUBJECT_ALT_NAME}=                Create Dictionary    subjectAltName=${altName}    subjectAltType=${altType}
        @{parameter}=                       Create List    ${SUBJECT_ALT_NAME}
        Change Parameter on BTS             dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/${server_object_name}
        ...                                 param_name=eeSubjectAltNames
        ...                                 param_value=${parameter}
        Initialize Certificates             key_pool_type=${server_type}
        ${path}=                            Stop TCPDump And Download PCAP     tcpdump_filename=domain.pcap
        _Get subjectAltName value from PCAP  ${path}    ${altName}
    END
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    TCPDump Teardown    AND
    ...           Delete Parameter From BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/${server_object_name}
    ...           param_name=eeSubjectAltNames

Connect to BTS with provided certificate and TLS version
    [Documentation]    Description:    This keyword creates connection with emssim and collect pcap from cerificate initialization
    ...                                and creating connection, then close connection. Given cerficate type ane TLS version is used.
    ...                Arguments:      ${cert_type}: Used certificate type; takes the value: RSA, ECDSA
    ...                                ${TLS_version}: Used version of TLS; takes the value: 1_2, 1_3
    [Arguments]    ${cert_type}=RSA    ${TLS_version}=1_3
    Change parameter on BTS                 MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                     certTypeForTlsAuth
    ...                                     ${cert_type}
    Start TCPDump
    ${NMS_LAB}    Integrate BTS to MantaRay with TLS    cert_type=${cert_type}    tls_version=${TLS_version}
    ...           PREFERRED_LAB=srnclab1047
    ${LBJBI_IP}  Get IP From MantaRay  ${NMS_LAB}   LBJBI_IP
    Set Global Variable      ${NETACT_IP}       ${LBJBI_IP}
    [Teardown]    Run Keywords
    ...    Stop TCPDump And Download PCAP          tcpdump_filename=tls${TLS_version}_${cert_type}_conn.pcap
    ...    AND    Deintegrate BTS from MantaRay    ${NMS_LAB}
    ...    AND    Clear Certificates

Verify PCAP messages
    [Documentation]    Description:    This keyword verifies if proper TLS connection parameters are visible in PCAP. As a precondition
    ...                                pcap file containing certificate initialization and TLS connection establishing should be present
    ...                                in ${TEST_OUTPUT_DIR} path. Checked values:
    ...                                General TLS handshake - if handhake messages are appropriate to TLS type,
    ...                                CMP init messages - if all messages are present
    ...                                Supported ciphersuites when BTS acts as a client NOTE: different ciphersuites are used for TLS 1.2 and TLS 1.3
    ...                                Supported groups  when BTS acts as a client
    ...                                Subject alternative name extension NOTE: eeSubjectAltNames structure should be present on BTS
    ...                                Used trust chain NOTE: Only for TLS 1.2
    ...                Arguments:      ${cert_type}: Used certificate type; takes the value: RSA, ECDSA
    ...                                ${TLS_version}: Used version of TLS; takes the value: 1_2, 1_3
    [Arguments]    ${cert_type}=RSA    ${TLS_version}=1_3

    Verify TLS Handshake In PCAP   pcap_file=${TEST_OUTPUT_DIR}/tls${TLS_version}_${cert_type}_conn.pcap
    ...    address1=${NETACT_IP}   tls_version=${TLS_version}

    Log    \t***Converting pcap to xml-BTS as a client***
    Convert pcap to XML                     filename=${TEST_OUTPUT_DIR}/tls${TLS_version}_${cert_type}_conn.pcap
    ...                                     filters=tls.handshake.type==1 && ip.src==${MPLANE_IPV4}
    ...                                     xml_name=${TEST_OUTPUT_DIR}/tls${TLS_version}_${cert_type}.xml
    @{cert_list}=  find_ciphers             xml_path=${TEST_OUTPUT_DIR}/tls${TLS_version}_${cert_type}.xml
    Log  ${cert_list}  console=true
    resources._Check If Ciphersuits Are Stored   ${TLS_version}    ${cert_list}
    @{supported_groups}=  find_supported_groups  xml_path=${TEST_OUTPUT_DIR}/tls${TLS_version}_${cert_type}.xml
    ${length}=    Get Length    ${supported_groups}
    Log  ${length}  console=true
    resources._Check If Supported Groups Are Stored   ${length}    ${supported_groups}

    Run keyword if    ${TLS_version}==1_2     _Verify if proper trust chain is used    ${NETACT_CERT}     ${cert_type}

Verify CMP Messages In PCAP
    [Arguments]    ${cert_type}=RSA
    Clear Certificates
    Start TCPDump
    Configure CMP              ca_subject_name=${CERTS_SUBJECT_NAME}[${cert_type}]
    ...                        server_type=${cert_type}
    Set CMP Server Settings    key_pool_type=${cert_type}
    Initialize Certificates    key_pool_type=${cert_type}
    Stop TCPDump And Download PCAP          tcpdump_filename=cmp_init_${cert_type}.pcap
    _Verify CMP Init Messages In PCAP
    ...                ca_subject_name=${CA_SUBJECT_NAME_PARTIALLY}[${cert_type}]
    ...                pcap_name=cmp_init_${cert_type}.pcap
    [Teardown]    Run Keywords    Clear Certificates    AND
    ...           Run Keyword And Ignore Error    Stop TCPDump And Download PCAP    tcpdump_filename=cmp_init_${cert_type}.pcap

Verify connection to port 443
    [Documentation]    Description:    This keyword verifies if proper certificate is used during connection to WebEM.
    ...                Arguments:      ${cert_type}: Used certificate type; takes the value: RSA, ECDSA
    ...                                ${TLS_version}: Used version of TLS; takes the value: 1_2, 1_3
    [Arguments]    ${cert_type}    ${TLS_version}
    Run Keyword If   '${TLS_version}'=='1_2'   Configure TLS versions    1_2=true    cert_type=${cert_type}
    ...              ELSE   Configure TLS versions    1_3=true    cert_type=${cert_type}
    Clear Certificates
    ${temp_conn}=    Connect to ADMIN
    Set CMP Server Settings    key_pool_type=${cert_type}
    Configure CMP              bts_id=${bts_id}
    ...                                    server_type=${cert_type}
    ...                                    ca_subject_name=${CERTS_SUBJECT_NAME['${cert_type}']}
    ...                                    connection=${temp_conn}
    Initialize Certificates    key_pool_type=${cert_type}    connection=${temp_conn}
    ${openssl_output}=    RUN  timeout 30s openssl s_client -connect ${MPLANE_IPV4}:443 -tls${TLS_version}
    Should contain    ${openssl_output}   ${CA_SUBJECT_NAME_PARTIALLY}[${cert_type}]
    [Teardown]    Run Keywords    Disconnect from ADMIN    ${temp_conn}
    ...           AND    Clear Certificates

Connecting with TLS1.1
    [Documentation]    Description:    This keyword verifies if connection with TLS1.1 is not possible. It uses openssl.
    ...                                It is checked for port 443(WebEM) and 8443(NMS).
    FOR  ${port}  IN  @{PORTS}
        Start TCPDump
        Sleep                                   15
        ...                                     reason=Wait until tcpdump starts properly
        ${output}=  RUN   timeout 30s openssl s_client -connect ${MPLANE_IPV4}:${port} -tls1_1
        Stop TCPDump And Download PCAP          tcpdump_filename=tls11.pcap
        Convert pcap to XML                     filename=${TEST_OUTPUT_DIR}/tls11.pcap
        ...                                     filters=tls.record.content_type == 21 && ip.dst==${VM_IP} && ip.src==${MPLANE_IPV4}
        ...                                     xml_name=${CURDIR}/tls11.xml
        ${pcap_filters}=    Catenate              tls.record.content_type == 21 and ip.addr == ${MPLANE_IPV4} and ip.addr == ${VM_IP}
        ${output_tls11}=    Run    tshark -r ${TEST_OUTPUT_DIR}/tls11.pcap -Y "${pcap_filters}"
        Should Contain   ${output_tls11}   TLSv1.1
        Should Contain   ${output_tls11}   Level: Fatal
        Should Contain   ${output_tls11}   Description: Protocol Version
    END

Reconfigure CMP for ECDSA certificate by NetAct
    Download SCF                          filename=scf_with_cmp_comfigured.xml
    ...                                   local_path=${OUTPUT DIR}
    Netact Setup
    ${param_changes}                      Create Dictionary
    ...                                   caSubjectName=${SECOND_SUBJECT_NAME}[ECDSA]
    ...                                   serverHost=${CA_SERVER_IP}
    ...                                   serverPath=${CA_SERVER_PATH}
    ...                                   serverPort=${CA_DEFAULT_PORT}
    ...                                   caCertificateUpdateTime=90

    Set Parameter Using Netact            dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                   param_changes=${param_changes}
    ...                                   path_to_scf=${OUTPUT DIR}/scf_with_cmp_comfigured.xml
    ...                                   na_instance=${NETACT_CONNECTION}

    Configure CMP Server With NetAct    ${NETACT_CONNECTION}
    ...                                 ${CERT_PRESHARED_KEY}
    ...                                 ${CA_REFERENCE_NUMBER}
    ...                                 ECDSA
    ...                                 MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                                 400
    Run Keyword And Ignore Error            Initialize Certificates From NetAct    #ten keyword jest do poprawy w commonach
    ...                                     connection=${NETACT_CONNECTION}
    ...                                     server_type=ECDSA
    ...                                     timeout=120
    [Teardown]    NetAct Teardown

Check if proper certificates are present on BTS
    [Arguments]    ${key_length}  ${cert_type}    ${expected_CN}
    ${server_object_name}               Get From Dictionary   ${CMP_OBJECT}   ${cert_type}
    Change Parameter on BTS             dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/${server_object_name}
    ...                                 param_name=eeSubjectAltNames
    ...                                 param_value=${SUBJECT_ALT_NAME_LIST}
    Clear Certificates
    Initialize Certificates    key_pool_type=${cert_type}
    _Check Certificate    ${key_length}    ${cert_type}
    _Check if file contains valid data  ${cert_type}
    ${issuer}=    Get Issuer From Certificate From BTS    ${cert_type}    BTS
    BuiltIn.Should Contain    ${issuer}    ${expected_CN}

##################

_Check Certificate
    [Documentation]    Description:    This keyword verifies if operator certificate stored on BTS has expected
    ...                                Subject Alternative Name and key length
    ...                Arguments:      ${key}: Expected key length; takes the value: int, free text
    ...                                ${cert_type}: Used certificate type; takes the value: RSA, ECDSA
    [Arguments]  ${key}    ${cert_type}
    ${connection}=       Connect with SSH    192.168.255.129  ${LOGIN}  ${PASSWORD}  conn
    ${out}=  ssh.Execute   ls -la /rom/trs_data/active/keystorage/certs  conn
    ${output}=  ssh.Execute  openssl x509 -in ${CERT_PATH}[${cert_type}] -text | grep "X509v3 Subject Alternative Name:" -A1   conn
    Log  ${out}  console=true
    Log  ${output}  console=true
    Log  ${params}[subjectAltName]  console=true
    Should contain  ${output}  ${SUBJECT_ALT_NAME_VALUES}[subjectAltName]
    ${output1}=  ssh.Execute  openssl x509 -in ${CERT_PATH}[${cert_type}] -text | grep "Public-Key:"  conn
    Log  ${output1}  console=true
    Should contain  ${output1}  ${key}
    [Teardown]  Disconnect SSH Session    conn

_Check If Supported Groups Are Stored
    [Documentation]    Description:    This keyword checks supported groups in Client Hello message.
    ...                                The main goal is to check mandatory supported groups.
    ...                Arguments:      ${supported_group_length}: length of list of supported groups; takes the value: int
    ...                                @{supported_group}: list of supported groups taken from pcap; takes the value: list of strings
    [Arguments]     ${supported_group_length}    ${supported_group}
    Log    \tVerifying supported groups    console=true
    @{supported_groups_local}=   Set Variable   secp384r1 (0x0018)   secp256r1 (0x0017)   x25519 (0x001d)
    @{supported_groups_not_neccessary}=    Set Variable    secp521r1 (0x0019)    x448 (0x001e)
    FOR  ${i}  IN RANGE  0  ${supported_group_length}
        ${supported_group_string}=  Set Variable    ${supported_group}[${i}][showname]
        ${group}=    Get Substring    ${supported_group_string}    17
        Run Keyword If    '${group}' in ${supported_groups_local}
        ...    Remove Values From List  ${supported_groups_local}  ${group}
        ...    ELSE    Remove Values From List  ${supported_groups_not_neccessary}  ${group}
    END
    Should be empty  ${supported_groups_local}

_Check If Ciphersuits Are Stored
    [Documentation]    Description:    This keyword verifies cipher suites in Client Hello message.
    ...                                Expected supported groups are different for TLS1.2 and TLS1.3
    ...                Arguments:      ${TLS_version}: Used version of TLS; takes the value: 1_2, 1_3
    ...                                @{cipher_list}: List of cipher suites taken from pcap; takes the value: list of strings
    [Arguments]     ${TLS_version}    ${cipher_list}
    Log    \tVerifying ${TLS_version} ciphersuites    console=true
    @{cipher_suites_local}=   Set Variable if    '${TLS_version}'=='1_3'   ${CIPHER_SUITES1_3}    ${CIPHER_SUITES1_2}
    ${list_length}=    Get Length    ${cipher_suites_local}
    FOR  ${i}  IN RANGE  0  ${list_length}
        Log  ${cipher_list}[${i}]\[showname]  console=true
        Should contain any  ${cipher_list}[${i}]\[showname]  @{cipher_suites_local}
        @{cipher}  Split string  ${cipher_list}[${i}]\[showname]
        Remove Values From List  ${cipher_suites_local}  ${cipher}[5]
    END
    Should be empty  ${cipher_suites_local}


_Verify Alternative Name Generation
    [Documentation]    Description:    This keyword verifies if subject alternative name is covered in cmp message.
    ...                Arguments:      ${pcap_file}: path to pcap file; takes the value: string, filename and extension
    [Arguments]    ${pcap_file}
    ${tshark_filters}                Set Variable
    ...                              cmp.body == ir && x509ce.dNSName == "test-domain-name.nokiasolutionsandnetworks.com"
    PCAP Should Contain Message      tshark_filter=${tshark_filters}
    ...                              pcap_file=${TEST_OUTPUT_DIR}/${pcap_file}

_Verify CMP Init Messages In PCAP
    [Documentation]    Description:    This keyword verifies if all required cmp message are visible in pcap
    ...                Arguments:      ${ca_subject_name}: name of CA whitch is requested to sign CSR; takes the value: string
    ...                                ${pcap_file}: path to pcap file; takes the value: string, filename and extension
    [Arguments]    ${ca_subject_name}    ${pcap_name}
    Log            ${\n}PCAP analysis:
    ...            console=${TRUE}
    FOR    ${msg}   IN  @{CMP_INIT_MESSAGES}
        PCAP Should Contain Message    tshark_filter=cmp.body == ${msg} && x509sat.uTF8String == "${ca_subject_name}"
        ...                            pcap_file=${TEST_OUTPUT_DIR}/${pcap_name}
    END

_Check if file contains valid data
    [Documentation]    Description:    This keyword verifies if proper Pre-shared key and Reference number are strored on BTS.
    ...                Arguments:      ${server_type}: Used certificate type; takes the value: RSA, ECDSA
    [Arguments]  ${server_type}
    ${connection}=       Connect with SSH    192.168.255.129  ${login}  ${password}  conn
    Log                  Checking file ${CMPSERVER_SETTINGS_FILEPATH}[${server_type}]  console=True
    ${key}=              ssh.Execute  head -n 1 ${CMPSERVER_SETTINGS_FILEPATH}[${server_type}]  conn
    ${ref_number}=       ssh.Execute  tail -n 1 ${CMPSERVER_SETTINGS_FILEPATH}[${server_type}]  conn
    Log                  ${key}  console=true
    Log                  ${ref_number}  console=true
    Should Match Regexp  ${key}  ${CERT_PRESHARED_KEY}
    Should Match Regexp  ${ref_number}  ${CA_REFERENCE_NUMBER}
    [Teardown]  Disconnect SSH Session  conn

_Get issuedTo Name From BTS Certificate
    [Documentation]    Description:    This keyword collects "issued_to" value from BTS (Security->Certificate management->Operator Certificates)
    ...                                for given cerificate type.
    ...                Arguments:      ${cert_type}: Used certificate type; takes the value: RSA, ECDSA
    [Arguments]    ${cert_type}=RSA
    ${cert_list}=  Get Certificates List  BTS
    Log  ${cert_list}    console=true
    FOR  ${list}  IN  @{cert_list}
        ${issuedTo}=  Set variable  ${list}[issuedTo]
        ${cn}=  get_cn  ${issuedTo}
        Log  ${cn}  console=true
        Return From Keyword If  '${list}[type]'=='EndEntity' and '${list}[keyPoolType]'=='${cert_type}'  ${cn}
    END

_Verify if proper trust chain is used
    [Documentation]    Description:    This keyword verifies if propre trust chain from BTS is used. As a precondition
    ...                                pcap file should be present in ${TEST_OUTPUT_DIR} path.
    ...                                NOTE: This kw is only valid for TLS 1.2, as TLS 1.3 doesn't contain certificate
    ...                                message in handshake.
    ...                Arguments:      ${CA_subject}: Fragment of subject name that should be visible in pcap; takes string as value
    ...                                ${cert_type}:  Used certificate type; takes the value: RSA, ECDSA
    [Arguments]    ${CA_subject}    ${cert_type}=RSA
    Log     \t***Converting pcap to xml-certificate message
    Convert pcap to XML                     filename=${TEST_OUTPUT_DIR}/tls1_2_${cert_type}_conn.pcap
    ...                                     filters=tls.handshake.type == 11 and ip.src == ${MPLANE_IPV4}
    ...                                     xml_name=${TEST_OUTPUT_DIR}/trust_chain_TLS1_2_${cert_type}.xml
    ${cert1}=  get_certificate_from_pcap  ${TEST_OUTPUT_DIR}/trust_chain_TLS1_2_${cert_type}.xml
    ${issued_to}=  resources._Get issuedTo Name From BTS Certificate    ${cert_type}
    FOR    ${i}    IN    @{cert1}
        ${status}    Run Keyword and Return Status    Should Contain    ${i}[showname]    ${CA_subject}
        IF  ${status}
            Exit For Loop
        END
    END

_Get subjectAltName value from PCAP
    [Documentation]      Description:    Checking the if the PCAP file has the proper value in CMP IR message.
    ...                                  The value from PCAP is comapred to the value from the subjectAltName parameter.
    ...                  Author:         jagoda.kubacka@nokia.com
    [Arguments]    ${path}    ${subjectAltName}
    ${cipher_suite_filters}=    Catenate      cmp and x509ce.dNSName and ip.src==${MPLANE_IPV4} and cmp.body==0
    ${cipher_suite}=            Run    tshark -r ${path} -Y "${cipher_suite_filters}" -V | grep -A 20 "dNSName:"
    Should Contain              ${cipher_suite}    ${subjectAltName}
