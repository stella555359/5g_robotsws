*** Settings ***
Documentation       TLS common resources

Resource    ../pcap_analysis/pcap_analysis.robot

Library     ./TLSHandshakeTests.py  WITH NAME  handshake
Library     ./tls.py


*** Variables ***
${XML_FILE}     tls.xml
@{SUPPORTED_GROUPS_MANDATORY}   secp384r1(0x0018)   secp256r1(0x0017)   x25519(0x001d)
@{SUPPORTED_GROUPS_NOT_MANDATORY}    secp521r1(0x0019)    x448(0x001e)
@{CIPHER_SUITES1_3}            TLS_AES_256_GCM_SHA384  TLS_CHACHA20_POLY1305_SHA256  TLS_AES_128_GCM_SHA256
...                         TLS_AES_128_CCM_8_SHA256  TLS_AES_128_CCM_SHA256  TLS_EMPTY_RENEGOTIATION_INFO_SCSV
@{CIPHER_SUITES1_2}         TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384  TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
...                         TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384  TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
...                         TLS_DHE_RSA_WITH_AES_256_CBC_SHA256  TLS_RSA_WITH_AES_256_GCM_SHA384
...                         TLS_RSA_WITH_AES_256_CBC_SHA256  TLS_DHE_RSA_WITH_AES_128_GCM_SHA256
...                         TLS_DHE_RSA_WITH_AES_128_CBC_SHA256  TLS_RSA_WITH_AES_128_GCM_SHA256
...                         TLS_RSA_WITH_AES_128_CBC_SHA256  TLS_EMPTY_RENEGOTIATION_INFO_SCSV


*** Keywords ***
Verify TLS Handshake In PCAP
    [Arguments]  ${pcap_file}    ${address1}=${VM_IP}     ${address2}=${MPLANE_IPV4}   ${tls_version}=1_2
    Convert pcap to XML                       filename=${pcap_file}
    ...                                       filters=tls and ip.addr == ${address1} and ip.addr == ${address2}
    ...                                       xml_name=${XML_FILE}
    checking_tls_pcap_messages                ${XML_FILE}   ${tls_version}

Check Supported Groups From PCAP
    [Arguments]    ${PATH_TO_PCAP}    ${PATH_TO_XML}    ${IP_DST}    ${IP_SRC}=${MPLANE_IPV4}
    Convert pcap to XML                     filename=${PATH_TO_PCAP}
    ...                                     filters= ip.src==${IP_SRC} && ip.dst==${IP_DST} && tls.handshake.type==1
    ...                                     xml_name=${PATH_TO_XML}
    ${xml}=       Parse XML    ${PATH_TO_XML}
    ${packets}    Get Elements    ${xml}    packet
    ${first_packet}    Get Element    ${packets}[0]
    ${groups}    Get Elements    ${first_packet}    .//field[@name='tls.handshake.extensions_supported_group']
    @{supported_groups}    Create List
    FOR    ${group}    IN    @{groups}
        ${x}    Get Element Attribute    ${group}    showname
        ${ex}    Split String    ${x}    :    2
        ${strip}    Remove String    ${ex[1]}    ${SPACE}
        Append To List    ${supported_groups}    ${strip}
    END
    Log to console    ${supported_groups}
    List Should Contain Sub List    ${supported_groups}    ${SUPPORTED_GROUPS_MANDATORY}
    ${additional_supp_groups}    List Difference    ${supported_groups}    ${SUPPORTED_GROUPS_MANDATORY}
    ${additional_supp_groups}    List Difference    ${additional_supp_groups}    ${SUPPORTED_GROUPS_NOT_MANDATORY}
    Should Be Empty    ${additional_supp_groups}

Check Cipher Suites From PCAP
    [Arguments]    ${PATH_TO_PCAP}    ${PATH_TO_XML}    ${IP_DST}    ${tls_version}=1_2    ${IP_SRC}=${MPLANE_IPV4}
    Convert pcap to XML                     filename=${PATH_TO_PCAP}
    ...                                     filters= ip.src==${IP_SRC} && ip.dst==${IP_DST}&& tls.handshake.type==1
    ...                                     xml_name=${PATH_TO_XML}
    ${xml}=       Parse XML    ${PATH_TO_XML}
    ${packets}    Get Elements    ${xml}    packet
    ${first_packet}    Get Element    ${packets}[0]
    ${groups}    Get Elements    ${first_packet}    .//field[@name='tls.handshake.ciphersuite']
    @{cipher_suites}    Create List
    FOR    ${group}    IN    @{groups}
        ${x}    Get Element Attribute    ${group}    showname
        ${ex}    Split String    ${x}    :    2
        ${strip}    Remove String    ${ex[1]}    ${SPACE}
        ${z}    Split String    ${strip}    (
        Append To List    ${cipher_suites}    ${z}[0]
    END
    ${CIPHERSUITES_PCAP}    Set Variable If    '${tls_version}'=='1_2'    ${CIPHER_SUITES1_2}    ${CIPHER_SUITES1_3}
    List Should Contain Sub List    ${cipher_suites}    ${CIPHERSUITES_PCAP}
    ${u}    List Difference    ${cipher_suites}    ${CIPHERSUITES_PCAP}
    Should Be Empty    ${u}

List Difference
    [Arguments]    ${list1}    ${list2}
    @{new_list}=    Create List    @{list1}    @{list2}
    FOR    ${item}    IN    @{list2}
        Remove Values From List    ${new_list}    ${item}
    END
    [Return]    ${new_list}
