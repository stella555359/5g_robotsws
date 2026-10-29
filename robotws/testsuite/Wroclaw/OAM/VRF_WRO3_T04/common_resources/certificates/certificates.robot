*** Settings ***
Documentation   Keywords regarding certificates management on BTS.

Resource        ../admin/admin.robot
Resource        ../vm/vm_operations.robot
Resource        ../connections/connections.robot
Resource        ../binary_files/binary_files.robot

Library         ../admin/admin_utils.py
Library         ./certificates_utils.py
Library         taf.sbts.oam.coam.admin    WITH NAME   coam_admin
Library         SSHLibrary

*** Variables ***
${CA_SERVER_IP}             10.42.54.13
${CA_SERVER_PATH}           pkix
${CA_DEFAULT_PORT}          8080
${CA_REFERENCE_NUMBER}      5330
${CERT_PRESHARED_KEY}       fnAR-zMMi-4pVz-mwrG
${TEMP_CERT_CONN}           temporary_cert_connection
&{CMP_OBJECT}               RSA=CMP-1
...                         ECDSA=CMPECDSA-1
${LOGIN}                    toor4nsn
${FPRINT}                   ${EMPTY}
${PASSWORD}                 oZPS0POrRieRtu
&{CERT_PATHS}               ECDSA=/rom/trs_data/active/keystorage/certs/ec_cert.pem
...                         RSA=/rom/trs_data/active/keystorage/certs/cert.pem
${P12_PASSWORD}             YT_xk39b
${TOO_SHORT}                ${CURDIR}/certificates_files/BTS_too_short_hex_string.txt
${EXPIRED}                  ${CURDIR}/certificates_files/BTS_expired_hex_string.txt

*** Keywords ***
Certificates Setup with TLS 1.3
    [Arguments]    ${ca_subject_name}=C=PL, O=Common, CN=IPSEC
    ${connection}=                    Connect to ADMIN
    Log                               Configuring certificates...
    ...                               console=${TRUE}
    Configure TLS versions            1_3=True
    ...                               connection=${connection}
    Configure CMP                     bts_id=${BTS_ID}
    ...                               ca_subject_name=${ca_subject_name}
    ...                               connection=${connection}
    Initialize Certificates           connection=${connection}
    [Teardown]                        Disconnect from ADMIN
    ...                               connection=${connection}

Configure CMP
    [Arguments]                         ${ca_subject_name}
    ...                                 ${bts_id}=${BTS_ID}
    ...                                 ${server_type}=RSA
    ...                                 ${ca_server_host}=${CA_SERVER_IP}
    ...                                 ${server_path}=${CA_SERVER_PATH}
    ...                                 ${ca_server_port}=${CA_DEFAULT_PORT}
    ...                                 ${connection}=${NONE}

    ${server_object_name}               Get From Dictionary   ${CMP_OBJECT}   ${server_type}
    ${connection}=                      admin_utils.create connection if not exist    ${connection}    alias=temp_conn

    Change Multiple Parameters on BTS   dist_name=MRBTS-${bts_id}/MNL-1/CERTH-1/${server_object_name}
    ...                                 connection=${connection}
    ...                                 caSubjectName=${ca_subject_name}
    ...                                 serverHost=${ca_server_host}
    ...                                 serverPath=${server_path}
    ...                                 serverPort=${ca_server_port}

    [Teardown]                          Run keyword and ignore error
    ...                                 Disconnect from ADMIN    connection=temp_conn

Configure Secondary CMP
    [Arguments]                          ${subject_name}
    ...                                  ${bts_id}=${BTS_ID}
    ...                                  ${server_host}=${CA_SERVER_IP}
    ...                                  ${server_type}=RSA
    ...                                  ${server_path}=${CA_SERVER_PATH}
    ...                                  ${server_port}=${CA_DEFAULT_PORT}
    ...                                  ${connection}=${NONE}

    ${server_object_name}                Get From Dictionary   ${CMP_OBJECT}   ${server_type}
    ${connection}=                       admin_utils.create connection if not exist    ${connection}    alias=temp_conn

    Change Multiple Parameters on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/${server_object_name}
    ...                                  connection=${connection}
    ...                                  secondaryCaSubjectName=${subject_name}
    ...                                  secondaryServerHost=${server_host}
    ...                                  secondaryServerPath=${server_path}
    ...                                  secondaryServerPort=${server_port}

    [Teardown]                          Run keyword and ignore error
    ...                                 Disconnect from ADMIN    connection=temp_conn

Clear Secondary CMP Configuration
    [Arguments]                          ${server_type}=RSA
    ...                                  ${connection}=${NONE}

    ${server_object_name}                Get From Dictionary   ${CMP_OBJECT}   ${server_type}
    ${delta_object}                      Get Secondary CMP Delete Delta
    ...                                  bts_id=${BTS_ID}
    ...                                  server_type=${server_object_name}

    Recommission Parameters By Delta     delta=${delta_object}
    ...                                  connection=${connection}

Delete Certificate From BTS
    [Arguments]      ${fingerprint}    ${connection}=${NONE}
    ${connection}=   admin_utils.create connection if not exist
    ...              connection=${connection}
    ...              alias=${TEMP_CERT_CONN}

    ${output}        coam_admin.delete_certificate
    ...              fingerprint=${fingerprint}
    ...              connection=${connection}

    Log              Certificate ${fingerprint} deleted.
    ...              console=${TRUE}

    [Teardown]       Run keyword and ignore error
    ...              Disconnect from ADMIN
    ...              connection=${TEMP_CERT_CONN}

Get Operator Certificates List
    [Documentation]     Returns list of operator certficates
    [Arguments]         ${connection}=${NONE}
    ${connection}=      admin_utils.create connection if not exist
    ...                 connection=${connection}
    ...                 alias=${TEMP_CERT_CONN}

    ${certs_list}       Get Certificates List
    ...                 connection=${connection}
    ${operator_certs}   certificates_utils.Get Operator Certificates
    ...                 cert_list=${certs_list}

    [Return]            ${operator_certs}
    [Teardown]          Run keyword and ignore error
    ...                 Disconnect from ADMIN
    ...                 connection=${TEMP_CERT_CONN}

Get Certificates List
    [Documentation]   Returns list of BTS certificates of specified type
    ...               (“BTS”|”RA”|”Vendor”|”TA”|”CA”|”All”|”CBRSVendor”|”CBRSCA”|"CBRSTA")
    [Arguments]       ${cert_type}=All    ${connection}=${NONE}
    ${connection}=    admin_utils.create connection if not exist
    ...               connection=${connection}
    ...               alias=${TEMP_CERT_CONN}

    ${certs_list}     coam_admin.get_certificate_list
    ...               cert_type=${cert_type}
    ...               connection=${connection}

    [Return]          ${certs_list}
    [Teardown]        Run keyword and ignore error
    ...               Disconnect from ADMIN
    ...               connection=${TEMP_CERT_CONN}

Initialize Certificates
    [Arguments]       ${key_pool_type}=RSA  ${timeout}=300    ${connection}=${NONE}
    ${connection}=    admin_utils.create connection if not exist
    ...               connection=${connection}
    ...               alias=${TEMP_CERT_CONN}

    Log               Certificates initialization request sent...
    ...               console=${TRUE}
    coam_admin.cmp_initialize_certificate           key_pool_type=${key_pool_type}
    ...                                        connection=${connection}
    ...                                        timeout=${timeout}
    Log               Certificates initialized.
    ...               console=${TRUE}
    Sleep             20s
    ...               reason=Make sure certificates initialization succeeds.

    [Teardown]        Run keyword and ignore error
    ...               Disconnect from ADMIN
    ...               connection=${TEMP_CERT_CONN}

Install Certificate On BTS
    [Documentation]
    ...               Certificate type, one of: [“BtsTrustChain”, “AdditionalCa”, “CBRSVendorChain”, “CBRSAdditionalCa”
    ...               Certificate format, one of: [“PEM”, “P12”, “DER”]
    [Arguments]      ${cert_file}   ${cert_type}    ${cert_format}    ${connection}=${NONE}   ${p12password}=${NONE}  ${key_pool_type}=${NONE}

    ${connection}=    admin_utils.create connection if not exist
    ...               connection=${connection}
    ...               alias=${TEMP_CERT_CONN}


    ${output}       coam_admin.install_certificate
    ...             cert_file=${cert_file}
    ...             cert_type=${cert_type}
    ...             cert_format=${cert_format}
    ...             password=${p12password}
    ...             connection=${connection}
    ...             key_pool_type=${key_pool_type}

    Log             ${cert_type} certificate installed.
    ...             console=${TRUE}

    [Teardown]      Run keyword and ignore error
    ...             Disconnect from ADMIN
    ...             connection=${TEMP_CERT_CONN}

Set CMP Server Settings
    [Arguments]     ${key_pool_type}=RSA
    ...             ${reference_number}=${CA_REFERENCE_NUMBER}
    ...             ${preshared_key}=${CERT_PRESHARED_KEY}
    ...             ${connection}=${NONE}
    ${connection}   admin_utils.create connection if not exist
    ...             connection=${connection}
    ...             alias=${TEMP_CERT_CONN}

    ${output}       coam_admin.set_certificate_automatic_management
    ...             key_pool_type=${key_pool_type}
    ...             reference_number=${reference_number}
    ...             preshared_key=${preshared_key}
    ...             detailed_output=${TRUE}
    ...             connection=${connection}

    Log             CMP RefNum and PresharedKey set.
    ...             console=${TRUE}

    [Teardown]      Run keyword and ignore error
    ...             Disconnect from ADMIN
    ...             connection=${TEMP_CERT_CONN}

Update CMP Key
    [Arguments]             ${connection}=${NONE}
    ...                     ${key_pool_type}=RSA
    ${connection}           admin_utils.create connection if not exist
    ...                     connection=${connection}
    ...                     alias=${TEMP_CERT_CONN}

    coam_admin.cmp_update_key    connection=${connection}
    ...                     key_pool_type=${key_pool_type}
    Log                     CMP key updated.
    ...                     console=${TRUE}

    [Teardown]              Run keyword and ignore error
    ...                     Disconnect from ADMIN
    ...                     connection=${TEMP_CERT_CONN}

Clear Certificates
    [Documentation]  Delete all certificates from BTS.
    [Arguments]                         ${connection}=${NONE}
    ${connection}                       admin_utils.create connection if not exist
    ...                                 connection=${connection}
    ...                                 alias=${TEMP_CERT_CONN}

    coam_admin.restore_vendor_certificate    connection=${connection}
    sleep      60    Wait for certificate restore
    Remove Additional Certificates      connection=${connection}

    Log                                 All certificates deleted.
    ...                                 console=${TRUE}

    [Teardown]                          Run keyword and ignore error
    ...                                 Disconnect from ADMIN
    ...                                 connection=${TEMP_CERT_CONN}

Remove Additional Certificates
    [Documentation]  Delete additional certificates from BTS.
    [Arguments]                     ${connection}=${NONE}
    ${connection}                   admin_utils.create connection if not exist
    ...                             connection=${connection}
    ...                             alias=${TEMP_CERT_CONN}

    ${cert_list}                    coam_admin.get_certificate_list
    ...                             cert_type=All
    ...                             connection=${connection}

    ${cert_list}                    certificates_utils.Get Operator Certificates       cert_list=${cert_list}
    ${fingerprints}                 Get Certificates Fingerprints   cert_list=${cert_list}

    Delete Multiple Certificates    fingerprints=${fingerprints}
    ...                             connection=${connection}

    [Teardown]                      Run keyword and ignore error
    ...                             Disconnect from ADMIN
    ...                             connection=${TEMP_CERT_CONN}

Generate CSR
    [Arguments]           ${output_file}     ${domain_type}    ${connection}=${NONE}
    ${connection}         admin_utils.create connection if not exist
    ...                   connection=${connection}
    ...                   alias=${TEMP_CERT_CONN}
    coam_admin.generate_csr    cert_file=${output_file}    connection=${connection}      domain_type=${domain_type}
    [Teardown]            Run keyword and ignore error
    ...                   Disconnect from ADMIN
    ...                   connection=${TEMP_CERT_CONN}

Get Subject From Certificate
    [Arguments]  ${path_cert}
    ${openssl_output}=   Run   openssl x509 -subject -noout -in ${path_cert}
    ${subject}=          Get Subject   ${openssl_output}
    [Return]     ${subject}

Get Serial Number From Certificate
    [Arguments]  ${path_cert}
    ${openssl_output}=   Run   openssl x509 -serial -noout -in ${path_cert}
    ${serial_number_hex}=    Get Serial Number   ${openssl_output}
    [Return]     ${serial_number_hex}

Get Issuer From Certificate
    [Arguments]  ${path_cert}
    ${openssl_output}=   Run   openssl x509 -issuer -noout -in ${path_cert}
    ${issuer}=           Get Issuer   ${openssl_output}
    [Return]     ${issuer}

Get Validity From Certificate
    [Arguments]  ${path_cert}  ${date}=notafter
    ${openssl_output}=   Run Keyword If   '${date}'=='notbefore'
    ...          Run   openssl x509 -startdate -noout -in ${path_cert}
    ...  ELSE IF   '${date}'=='notafter'
    ...          Run   openssl x509 -enddate -noout -in ${path_cert}
    ...  ELSE    Run   openssl x509 -dates -noout -in ${path_cert}
    [Return]     ${openssl_output}

Get Signature Algorithm From Certificate
    [Arguments]  ${path_cert}
    ${openssl_output}=          Run   openssl x509 -noout -in ${path_cert} -text
    ${signature_algorithm}=     Get Signature Algorithm       ${openssl_output}
    [Return]     ${signature_algorithm}[0]

Generate Private Key
    [Documentation]    MOCKUP version for RU - generates private key in /tmp folder.
    ...                Keyword generates priveate key using AES256 on target host specified by IP address
    ...                and ${target_host}. Allowed values: ${target_host} = VM | SMOD | RU
    [Arguments]    ${target_host}   ${username}   ${password}   ${target_ip}
    ...            ${key}=testkey.key   ${passphrase}=testpassphrase
    Create Connection With SSHLibrary   ${target_host}   ${username}   ${password}   ${target_ip}
    SSHLibrary.Write                    text=openssl genpkey -algorithm RSA -out ${key} -aes256
    Sleep                               5s   reason=Wait for command processing...
    SSHLibrary.Write                    text=${passphrase}
    Sleep                               3s   reason=Wait for command processing...
    SSHLibrary.Write                    text=${passphrase}
    Sleep                               3s   reason=Wait for command processing...
    Check Prompt With SSHLibrary   ${target_host}   ${username}
    SSHLibrary.Close Connection

Generate Certificate Signing Request
    [Documentation]     MOCKUP version for RU - generates csr in /tmp folder.
    ...                 Keyword generates Certificate Signing Request on target host specified by IP address
    ...                 and ${target_host}. Allowed values: ${target_host} = VM | SMOD | RU
    [Arguments]    ${target_host}     ${username}   ${password}   ${target_ip}   ${key}=testkey.key
    ...            ${csr}=testcsr.csr    ${passphrase}=testpassphrase
    Create Connection With SSHLibrary   ${target_host}   ${username}   ${password}   ${target_ip}
    SSHLibrary.Write                    text=openssl req -new -key ${key} -out ${csr}
    Sleep                               5s   reason=Wait for command processing...
    SSHLibrary.Write                    text=${passphrase}
    Sleep                               3s   reason=Wait for command processing...
    SSHLibrary.Write                    text=PL
    Sleep                               3s   reason=Wait for command processing...
    SSHLibrary.Write                    text=Lower-Silesia
    Sleep                               3s   reason=Wait for command processing...
    SSHLibrary.Write                    text=Wroclaw
    Sleep                               3s   reason=Wait for command processing...
    SSHLibrary.Write                    text=Nokia
    Sleep                               3s   reason=Wait for command processing...
    SSHLibrary.Write                    text=MN
    Sleep                               3s   reason=Wait for command processing...
    SSHLibrary.Write                    text=NOKIA
    Sleep                               3s   reason=Wait for command processing...
    SSHLibrary.Write                    text=test@nokia.com
    Sleep                               3s   reason=Wait for command processing...
    SSHLibrary.Write                    text=\n    #skip extra attributes
    Sleep                               3s   reason=Wait for command processing...
    SSHLibrary.Write                    text=\n    #skip extra attributes
    Sleep                               3s   reason=Wait for command processing...
    Check Prompt With SSHLibrary   ${target_host}   ${username}
    SSHLibrary.Close Connection

Generate Self-signed Root CA Certificate
    [Documentation]     MOCKUP version for RU - generates certificate in /tmp folder.
    ...                 Generates self-signed root CA certificate on target host specified by IP address
    ...                 and ${target_host}. Allowed values: ${target_host} = VM | SMOD | RU
    [Arguments]    ${target_host}   ${username}   ${password}   ${target_ip}
    ...            ${root_CA_key}=rootCA.key    ${root_CA_cert}=rootCA.pem   ${passphrase}=testpassphrase
    Create Connection With SSHLibrary   ${target_host}   ${username}   ${password}   ${target_ip}
    SSHLibrary.Write   text=openssl req -new -key ${root_CA_key} -x509 -sha256 -days 3650 -out ${root_CA_cert}
    Sleep              5s   reason=Wait for command processing...
    SSHLibrary.Write   text=${passphrase}
    Sleep              3s   reason=Wait for command processing...
    SSHLibrary.Write   text=PL
    Sleep              3s   reason=Wait for command processing...
    SSHLibrary.Write   text=Lower-Silesia
    Sleep              3s   reason=Wait for command processing...
    SSHLibrary.Write   text=Wroclaw
    Sleep              3s   reason=Wait for command processing...
    SSHLibrary.Write   text=Nokia
    Sleep              3s   reason=Wait for command processing...
    SSHLibrary.Write   text=MN
    Sleep              3s   reason=Wait for command processing...
    SSHLibrary.Write   text=NOKIA
    Sleep              3s  reason=Wait for command processing...
    SSHLibrary.Write   text=test@nokia.com
    Sleep              3s  reason=Wait for command processing...
    Check Prompt With SSHLibrary   ${target_host}   ${username}
    SSHLibrary.Close Connection

Sign Sub CA CSR With Root CA
    [Documentation]     Allowed values: ${target_host} = VM | SMOD | RU
    [Arguments]    ${target_host}   ${username}   ${password}   ${target_ip}
    ...            ${passphrase}=testpassphrase   ${root_CA_cert}=rootCA.pem
    ...            ${root_CA_key}=rootCA.key   ${sub_CA_csr}=subCA.csr   ${sub_CA_cert}=subCA.pem
    ${command}=    Catenate    openssl x509 -req -in ${sub_CA_csr} -CA ${root_CA_cert} -CAkey ${root_CA_key}
    ...                        -CAcreateserial -out ${sub_CA_cert} -days 1825 -sha256
    Create Connection With SSHLibrary   ${target_host}   ${username}   ${password}   ${target_ip}
    SSHLibrary.Write   text=${command}
    Sleep              5s   reason=Wait for command processing...
    SSHLibrary.Write   text=${passphrase}
    Sleep              3s   reason=Wait for command processing...
    Check Prompt With SSHLibrary   ${target_host}   ${username}
    SSHLibrary.Close Connection

Sign End-entity CSR With Sub CA
   [Documentation]     Allowed values:  ${target_host} = VM | SMOD | RU
   [Arguments]    ${target_host}   ${username}   ${password}   ${target_ip}   ${end_entity_csr}=testcsr.csr
   ...            ${sub_CA_cert}=subCA.pem   ${sub_CA_key}=subCA.key   ${sub_CA_cert}=subCA.pem
   ...            ${output_cert}=outputcert.pem
   ${command}=    Catenate    openssl x509 -req -in ${end_entity_csr} -CA ${sub_CA_cert} -CAkey ${sub_CA_key}
   ...                        -CAcreateserial -out ${outputcert} -days 365 -sha256
   Create Connection With SSHLibrary   ${target_host}   ${username}   ${password}   ${target_ip}
   SSHLibrary.Write                    text=${command}
   Sleep                               5s   reason=Wait for command processing...
   SSHLibrary.Write                    text=${passphrase}
   Sleep                               3s   reason=Wait for command processing...
   Check Prompt With SSHLibrary   ${target_host}   ${username}
   SSHLibrary.Write   openssl x509 -in ${outputcert} -text
   Sleep   3s   reason=Wait for command processing...
   ${output}=   SSHLibrary.Read
   Log    ${output}   console=True
   SSHLibrary.Close Connection

Install Certificate
    [Documentation]     MOCKUP version - allow only to install certificate on VM and ill not install properly on RU
    ...                 due to /etc/ssl/certs/ is on Read-Only partition
    ...                 Also will not install properly on SMOD due to specific Linux distribution
    ...                 First there must be valid certificate in /etc/ssl/certs/ - copy certificate to this destination
    ...                 Allowed values: ${target_host} = VM | SMOD | RU
    [Arguments]    ${target_host}   ${username}   ${password}   ${target_ip}
    Create Connection With SSHLibrary   ${target_host}   ${username}   ${password}   ${target_ip}
    SSHLibrary.Write   text=cd /etc/ssl/certs
    Sleep              3s   reason=Wait for command processing...
    SSHLibrary.Write   text=sudo update-ca-certificates
    Sleep              3s   reason=Wait for command processing...
    Check Prompt With SSHLibrary   ${target_host}   ${username}
    SSHLibrary.Close Connection

Get KeyPoolType From BTS Certificate
    [Arguments]  ${issuer}
    ${cert_list}=   Get Certificates List  TA
    Log  ${cert_list}  console=true
    FOR  ${list}  IN  @{cert_list}
        Log  ${list}  console=true
        ${keyPoolType}=  Set variable  ${list}[keyPoolType]
        Return From Keyword If  '${list}[issuer]'=='${issuer}'  ${keyPoolType}
    END
    [Return]    ${keyPoolType}

Check If Certificate File Is Present On BTS
    [Arguments]  ${keyPoolType}
    ${connection}=   Connect with SSH       192.168.255.129  ${LOGIN}  ${PASSWORD}  conn
    ${output}=  ssh.Execute    openssl x509 -in ${CERT_PATHS}[${keyPoolType}] -text  conn
    Log  ${output}  console=true
    Should Not Contain Any  ${output}  No such file or directory  unable to load certificate
    [Teardown]  Disconnect SSH Session  conn

Get Issuer From Certificate From BTS
    [Arguments]  ${key_pool_type}    ${type}=TA
    ${cert_list}=   Get Certificates List  ${type}
    Log  ${cert_list}  console=true
    FOR  ${list}  IN  @{cert_list}
        Log  ${list}  console=true
        ${issuer}=  Set variable  ${list}[issuer]
        Return From Keyword If  '${list}[keyPoolType]'== '${key_pool_type}'  ${issuer}
    END

Generate and Install Wrong Certificate
    [Arguments]    ${type}=ECDSA    ${name_of_cert}=expired
    Generate Binary File From HEX String    hex_string_file=${EXPIRED}
    ...                                     binary_file_name=${CURDIR}/${name_of_cert}.p12
    Install Certificate On BTS              cert_file=${CURDIR}/${name_of_cert}.p12
    ...                                     cert_type=BtsTrustChain
    ...                                     cert_format=P12
    ...                                     p12password=${P12_PASSWORD}
    ...                                     key_pool_type=${type}

Check Cipher Suites And Supported Groups
    [Arguments]    ${pcap_file}=ciphers_and_supp_groups.pcap    ${xml_name}=ciphers_and_supp_groups.xml
    Convert Pcap To Xml    filename=${TEST_OUTPUT_DIR}/${pcap_file}
    ...                    filters=tls.handshake.type==1 && ip.src=${MPLANE_IPV4}
    ...                    xml_name=${TEST_OUTPUT_DIR}/${xml_name}

Generate and Install To Short Key Certificate
    [Arguments]    ${type}=ECDSA
    Generate Binary File From HEX String    hex_string_file=${EXPIRED}
    ...                                     binary_file_name=${CURDIR}/expired.p12
    Install Certificate On BTS              cert_file=${CURDIR}/expired.p12
    ...                                     cert_type=BtsTrustChain
    ...                                     cert_format=P12
    ...                                     p12password=${P12_PASSWORD}
    ...                                     key_pool_type=${type}

Update Certificate Revocation List
    [Documentation]    Description:    Update Certificate Revocation List
    ...                Input:          domain = 3GPP or CBRS
    [Arguments]        ${domain}    ${timeout}=${300}    ${connection}=${NONE}    ${full_output}=${FALSE}
    ${connection}=     admin_utils.create_connection_if_not_exist
    ...                connection=${connection}
    ...                alias=${TEMP_ADMIN_CONN}
    ${result}=         coam_admin.update_certificate_revocation_list    domain_type=${domain}
    ...                timeout=${timeout}    connection=${connection}    detailed_output=${full_output}
    [Return]           ${result}
    [Teardown]         Run Keyword And Ignore Error    admin.Disconnect from ADMIN    connection=${TEMP_ADMIN_CONN}
