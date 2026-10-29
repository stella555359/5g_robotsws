*** Settings ***
Documentation   Suite for CB008254 feature.

Resource        ../../../common_resources/admin/admin.robot
Resource        ../../../common_resources/certificates/certificates.robot
Resource        ../../../common_resources/ip_traffic/ip_traffic.robot
Resource        ../../../common_resources/connections/connections.robot
Library         taf.sbts.oam.coam.admin      WITH NAME   coam_admin

*** Variables ***
${ECDSA_SUBJECT_NAME}        CN = CB005999_test
${RSA_SUBJECT_NAME}          CN = CB007672
${ECDSA_CROSS_SUBJECT_NAME}  CN=CB00599_cross_SUB
${PCAP_NAME}                ${CURDIR}/certs.pcap
${repo_path}                /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/VRF_WRO3_T04
${P12_ECDSA}                ${repo_path}/common_resources/emssim/certificates/bts256_hex_string.txt
${P12_RSA}                  ${repo_path}/common_resources/emssim/certificates//BTSRSA_hex_string.txt
${TOO_SHORT}                ${repo_path}/common_resources/emssim/certificates/tificates/BTS_too_short_hex_string.txt
${EXPIRED}                  ${repo_path}/common_resources/emssim/certificates//BTS_expired_hex_string.txt
${ECDSA_521}                ${repo_path}/common_resources/emssim/certificates//BTS521_hex_string.txt
${P12_PASSWORD}             YT_xk39b
${CERT_PATH}                ${repo_path}/common_resources/emssim/certificates//CB005999_test.pem
${LOGIN}                    toor4nsn
${FPRINT}                   ${EMPTY}
${PASSWORD}                 oZPS0POrRieRtu
&{CERT_PATHS}               ECDSA=/rom/trs_data/active/keystorage/certs/ec_cert.pem
...                         RSA=/rom/trs_data/active/keystorage/certs/cert.pem
@{PORTS}                    443  8443
@{CIPHER_SUITES}            TLS_AES_256_GCM_SHA384  TLS_CHACHA20_POLY1305_SHA256  TLS_AES_128_GCM_SHA256
...                         TLS_AES_128_CCM_8_SHA256  TLS_AES_128_CCM_SHA256  TLS_EMPTY_RENEGOTIATION_INFO_SCSV
@{CIPHER_SUITES1_2}         TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384  TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
...                         TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384  TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
...                         TLS_DHE_RSA_WITH_AES_256_CBC_SHA256  TLS_RSA_WITH_AES_256_GCM_SHA384
...                         TLS_RSA_WITH_AES_256_CBC_SHA256  TLS_DHE_RSA_WITH_AES_128_GCM_SHA256
...                         TLS_DHE_RSA_WITH_AES_128_CBC_SHA256  TLS_RSA_WITH_AES_128_GCM_SHA256
...                         TLS_RSA_WITH_AES_128_CBC_SHA256  TLS_EMPTY_RENEGOTIATION_INFO_SCSV
@{SUPPORTED_GROUPS}         secp384r1 (0x0018)   secp256r1 (0x0017)   x25519 (0x001d)
@{SUPPORTED_GROUPS1_2}      secp384r1 (24)   secp256r1 (23)   x25519 (29)
${fingerPrint_RSA}          76:37:C7:9C:12:4C:C0:31:C6:7F:9B:9C:83:66:E6:B7:0B:EF:EC:31
${fingerPrint_ECDSA}        66:8E:DA:D8:FE:E7:E8:B2:AA:DA:C8:4D:DF:C2:09:0B:FA:F9:1A:41
${ECDSA_SERVERCERT}         ${repo_path}/common_resources/emssim/certificates/ECDSA/servercert.pem
${ECDSA_PRIVKEY}            ${repo_path}/common_resources/emssim/certificates/ECDSA/serverprivkey.pem
${ECDSA_CACERT}             ${repo_path}/common_resources/emssim/certificates/ECDSA/cacert.pem
${RSA_SERVERCERT}           ${repo_path}/common_resources/emssim/certificates/RSA/servercert.pem
${RSA_PRIVKEY}              ${repo_path}/common_resources/emssim/certificates/RSA/serverprivkey.pem
${RSA_CACERT}               ${repo_path}/common_resources/emssim/certificates/RSA/cacert.pem
${SYNC_PATHS}               /ffs/stb/trs_data/active/.keystorage /ffs/stb/trs_data/active/keystorage
&{PARAMS}                   remoteSyslogDSCP=0    remoteSyslogFormat=RFC5424   remoteSyslogServerHost=10.42.54.11
...                         remoteSyslogServerPortNo=6515   remoteSyslogTransmitDuration=10080
...                         remoteSyslogTransportProtocol=TLS

*** Keywords ***
Get issuedTo Name From BTS Certificate
    ${cert_list}=  Get Certificates List  BTS
    Log  ${cert_list}    console=true
    FOR  ${list}  IN  @{cert_list}
        ${issuedTo}=  Set variable  ${list}[issuedTo]
        ${cn}=  get_cn  ${issuedTo}
        Log  ${cn}  console=true
        Return From Keyword If  '${list}[type]'=='EndEntity'  ${cn}
    END

Get Certificate From PCAP
    [Arguments]     ${file_name}=cert
    Start Tcpdump
    Sleep                               20
    ...                                 reason=Wait until tcpdump stars
    RUN  openssl s_client -connect ${MPLANE_IPV4}:443 -tls1_2
    Sleep                               20
    ...                                 reason=Wait until connection established
    Stop Tcpdump And Download Pcap          tcpdump_filename=${file_name}.pcap
    Convert pcap to XML                     filename=${TEST_OUTPUT_DIR}/${file_name}.pcap
    ...                                     filters=tls.handshake.type == 11 and ip.src == ${MPLANE_IPV4}
    ...                                     xml_name=${CURDIR}/${file_name}.xml
    ${cert}=  analyze_xml  ${CURDIR}/${file_name}.xml
    ${cert1}  analyze_xml  ${CURDIR}/${file_name}.xml
    ${issued_to}  CB008254.Get issuedTo Name From BTS Certificate
    [Return]  ${issued_to}  ${cert}[0][showname]  ${cert1}[1][showname]

Check If Ciphersuits Are Stored
    [Arguments]     @{cipher_list}
    FOR  ${i}  IN RANGE  0  6
        Log  ${cipher_list}[${i}][showname]  console=true
        Should contain any  ${cipher_list}[${i}][showname]  @{CIPHER_SUITES}
        @{cipher}  Split string  ${cipher_list}[${i}][showname]
        Remove Values From List  ${CIPHER_SUITES}  ${cipher}[2]
    END
    Should be empty  ${CIPHER_SUITES}

Check If Ciphersuits Are Stored For TLS1_2
    [Arguments]     @{cipher_list}
    @{cipher_suites}=   Set Variable   ${CIPHER_SUITES1_2}
    Log  ${cipher_suites}  console=true
    FOR  ${i}  IN RANGE  0  12
        Log  ${cipher_list}[${i}][showname]  console=true
        Should contain any  ${cipher_list}[${i}][showname]  @{cipher_suites}
        @{cipher}  Split string  ${cipher_list}[${i}][showname]
        Remove Values From List  ${cipher_suites}  ${cipher}[2]
    END
    Should be empty  ${cipher_suites}

Check If Supported Groups Are Stored
    [Arguments]     ${supported_group_lenght}    @{supported_group}
    @{supported_groups_local}=   Set Variable   secp384r1 (0x0018)   secp256r1 (0x0017)   x25519 (0x001d)
    @{supported_groups_not_neccessary}=    Set Variable    secp521r1 (0x0019)    x448 (0x001e)
    Log  ${supported_groups_local}  console=true
    FOR  ${i}  IN RANGE  0  ${supported_group_lenght}
        Log  ${supported_group}[${i}][showname]  console=true
        ${group}  Get Substring  ${supported_group}[${i}][showname]  17  35
        Log to console    ${group}
        Run Keyword If    '${group}' in ${supported_groups_local}
        ...    Remove Values From List  ${supported_groups_local}  ${group}
        ...    ELSE    Remove Values From List  ${supported_groups_not_neccessary}  ${group}
    END
    Should be empty  ${supported_groups_local}


Get keyPoolType And fingerPrint from BTS Certificate
    [Arguments]  ${issuer}   ${item}
    ${cert_list}=   Get Certificates List  TA
    Log  ${cert_list}  console=true
    FOR  ${list}  IN  @{cert_list}
        Log  ${list}  console=true
        ${value}=  Set variable  ${list}[${item}]
        Return From Keyword If  '${list}[issuer]'==${issuer}  ${value}
    END


Check Synchronization By Ssh
    ${connection}=       Connect with SSH    192.168.255.129  ${LOGIN}  ${PASSWORD}  conn
    ${output_act_ecdsa}=  Execute  openssl x509 -in /rom/trs_data/active/keystorage/certs/ec_cert.pem -text | grep "Serial Number:" -A1   conn
    ${output_act_rsa}=  Execute  openssl x509 -in /rom/trs_data/active/keystorage/certs/cert.pem -text | grep "Serial Number:" -A1    conn
    Log  ${output_act_ecdsa}  console=true
    Log  ${output_act_rsa}  console=true
    ${output1}=  Execute  encfs --public --crakey "/etc/keys.d/private/sok.crk&enc.crk" ${SYNC_PATHS} -o nonempty,allow_other  conn
    ${output_pass_ecdsa}=  Execute  openssl x509 -in /ffs/stb/trs_data/active/keystorage/certs/ec_cert.pem -text | grep "Serial Number:" -A1   conn
    ${output_pass_rsa}=  Execute  openssl x509 -in /ffs/stb/trs_data/active/keystorage/certs/cert.pem -text | grep "Serial Number:" -A1   conn
    Log  ${output_pass_ecdsa}  console=true
    Log  ${output_pass_rsa}  console=true
    Should be equal as strings   ${output_act_ecdsa}   ${output_pass_ecdsa}
    Should be equal as strings   ${output_act_rsa}   ${output_pass_rsa}
    [Teardown]  Disconnect SSH Session    conn
