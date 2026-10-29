*** Settings ***
Documentation
...     description:    TLS related keywords.

Resource    ../../../cloud_common_resources/parameters/parameters.robot

*** Variables ***
@{CIPHER_SUITES1_2}           0xc02c    0xc02b    0xc030    0x009f    0x006b    0x009d    0x009d    0x0003d
...                           0x009e    0x0067    0x009c    0x003c    0x00ff
@{CIPHER_SUITES1_2_RSA}       0xc02c    0xc02b    0xc030    0x009f    0x006b    0x009d    0x003d    0x0009e
...                           0x0067    0x009c    0x003c    0x00ff
@{CIPHER_SUITES1_2_CBC}       0xc02c    0xc02b    0xc030    0x009f    0x009d    0x009e    0x009c    0x00ff
@{CIPHER_SUITES1_2_RSA_CBC}   0xc02c    0xc02b    0xc030    0x009f    0x009e    0x00ff
@{CIPHER_SUITES1_3_1_2}=      0x1302    0x1303    0x1301    0x1305    0x1304    0x00ff
@{CIPHER_SUITES1_3}=          0x1302    0x1303    0x1301    0x1305    0x1304    0xc02c    0xc02b    0xc030    0x009f
...                           0x006b    0x009d    0x003d    0x009e    0x0067    0x009c    0x003c    0x00ff
@{CIPHER_SUITES1_3_RSA}=      TLS_AES_256_GCM_SHA384    TLS_CHACHA20_POLY1305_SHA256    TLS_AES_128_GCM_SHA256
...                           TLS_AES_128_CCM_SHA256    TLS_AES_128_CCM_8_SHA256    TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
...                           TLS_DHE_RSA_WITH_AES_256_GCM_SHA384    TLS_DHE_RSA_WITH_AES_256_CBC_SHA256
...                           TLS_RSA_WITH_AES_256_GCM_SHA384    TLS_RSA_WITH_AES_256_CBC_SHA256
...                           TLS_DHE_RSA_WITH_AES_128_GCM_SHA256    TLS_DHE_RSA_WITH_AES_128_CBC_SHA256
...                           TLS_RSA_WITH_AES_128_GCM_SHA256    TLS_RSA_WITH_AES_128_CBC_SHA256
@{CIPHER_SUITES1_3_ECDSA}=    TLS_AES_256_GCM_SHA384    TLS_CHACHA20_POLY1305_SHA256    TLS_AES_128_GCM_SHA256
...                           TLS_AES_128_CCM_SHA256    TLS_AES_128_CCM_8_SHA256    TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
...                           TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
@{SUPPORTED_GROUPS}=          secp384r1 (0x0018)    secp256r1 (0x0017)    x25519 (0x001d)
@{ADDITIONAL_SUPPORTED_GROUPS}=         secp521r1 (0x0019)    x448 (0x001e)


*** Keywords ***
Test TLS Handshake
    [Documentation]    Description:    The main KW for checking TLS Handshake. This KW contains the following KWs:
    ...                                _Test TLS1.2 Handshake and _Test TLS1.3 Handshake based on TLS that is
    ...                                configured on BTS.
    ...                Input:          file_path = path to PCAP file_path
    ...                                IP_client = IP address of IP_client (source ip)
    ...                                IP_server = IP address of IP_server (destination ip)
    ...                                IP_port = IP port of IP_server (destination port)
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]        ${file_path}    ${IP_client}    ${IP_server}    ${hw_type}    ${IP_port}=${NONE}
    ${TLS13_value}=    Run Keyword If    "${hw_type}"=="vCU"    Check Parameter Value    actEnableTLSv13
    ...                                                         MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                                         hw_type=${hw_type}
    ...                ELSE IF           '${hw_type}'=='vDU'    Check Parameter Value    actEnableTLSv13
    ...                                                         MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                                         hw_type=${hw_type}
    ...                ELSE               FAIL                  hw_type doesn't exist
    ${TLS13_value}=    Set Variable If    "${hw_type}"=="vCU"    ${TLS13_value}[0]     ${TLS13_value}
    Run Keyword If     '${TLS13_value}'=='true'  _Test TLS1.3 Handshake  file_path=${file_path}  IP_client=${IP_client}
    ...                IP_server=${IP_server}    IP_port=${IP_port}
    ...    ELSE        _Test TLS1.2 Handshake    file_path=${file_path}    IP_client=${IP_client}
    ...                IP_server=${IP_server}    IP_port=${IP_port}

Check Ciphersuites
    [Documentation]    Description:    Verify if PCAP contains neccessary cipher suites. The cipher suites depends on
    ...                                TLS1.3 and/or TLS1.2 (and also tls12RsaKExDisabled, tls12CbcCipherDisabled
    ...                                parameters) and/or type of certificates (RSA/ECDSA). The KW check which kind
    ...                                of TLS the BTS is using and which parameters are enabled/disabled
    ...                                to use the correct cipher suites. The variable ${all_cipher_suites} is used to
    ...                                check if mandatory cipher suites are sent via BTS. The variable ${cipher_suites_cert_type}
    ...                                is used to check if the strongest cipher is used based on used certificate.
    ...                Input:          file_path = path to PCAP file_path
    ...                                IP_client = IP address of IP_client (source ip)
    ...                                IP_server = IP address of IP_server (destination ip)
    ...                                cert_type = ECDSA/RSA
    ...                                hw_type = vCU/vDU
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]        ${file_path}   ${IP_client}    ${IP_server}    ${cert_type}    ${hw_type}
    @{all_cipher_suites}=         Create List
    @{cipher_suites_cert_type}=   Create List
    ${MODEL_CIPHER_SUITES}=       _Select Model Cipher Suites    ${hw_type}
    ${cipher_suites_filters}=     Catenate    tls and ip.dst == ${IP_client} and ip.src == ${IP_server} and
    ...                                      tls.handshake.type == 1
    ${packets_cipher_suites}=     Run    tshark -r ${file_path} -Y "${cipher_suites_filters}" -T fields -e tls.handshake.ciphersuite
    ${packets_cipher_suites}=     Split String    ${packets_cipher_suites}    \n
    ${element_of_cipher_suite}=   Split String    ${packets_cipher_suites}[0]    ,
    ${length_of_cipher_suite}=    Get Length    ${element_of_cipher_suite}
    ${cipher_suites}=    Run    tshark -r ${file_path} -Y "${cipher_suites_filters}" -V | grep -E "Cipher Suite: " | head -n ${length_of_cipher_suite}
    ${cipher_suites}=             Split String    ${cipher_suites}    \n
    FOR    ${cipher_suite}    IN    @{cipher_suites}
       ${ciphers_IDs}=    Set Variable    ${cipher_suite}
       ${ciphers_IDs}=    Fetch From Right    ${ciphers_IDs}    (
       ${ciphers_IDs}=    Fetch From Left    ${ciphers_IDs}    )
       Append to List     ${all_cipher_suites}    ${ciphers_IDs}
       ${status}=         Run Keyword And Return Status    Should Contain    ${cipher_suite}    ${cert_type}
       ${cipher_suite}=   Fetch From Right    ${cipher_suite}    (
       ${cipher_suite}=   Fetch From Left    ${cipher_suite}    )
       Run Keyword If    '${status}' == 'True'    Append to List    ${cipher_suites_cert_type}    ${cipher_suite}
    END
    List Should Contain Sub List    ${all_cipher_suites}    ${MODEL_CIPHER_SUITES}
    ${cipher_list_server_filters}=    Catenate      tls and ip.src == ${IP_client} and ip.dst == ${IP_server} and
    ...                                       tls.handshake.type == 2
    ${cipher_list_server}=            Run    tshark -r ${file_path} -Y "${cipher_list_server_filters}" -T fields -e tls.handshake.ciphersuite
    ${cipher_list_server}=            Split String    ${cipher_list_server}    \n
    Should Be Equal                   ${cipher_suites_cert_type}[0]    ${cipher_list_server}[0]


Check Supported Groups
    [Documentation]    Description:    Verify if PCAP contains neccessary supported groups. The KW compare the
    ...                                supported groups from PCAP with mandatory supported groups. It is possible
    ...                                that mandatory supported groups aren't present in PCAP, the additional supported
    ...                                groups must occured. If some other supported groups will be present in PCAP
    ...                                the test will fail because the list won't be empty.
    ...                Input:          file_path = path to PCAP file_path
    ...                                IP_client = IP address of IP_client (source ip)
    ...                                IP_server = IP address of IP_server (destination ip)
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]    ${file_path}    ${IP_client}    ${IP_server}
    ${supported_groups_filters}=    Catenate      tls and ip.dst == ${IP_client} and ip.src == ${IP_server} and
    ...                                      tls.handshake.type == 1
    ${support_groups}=           Run    tshark -r ${file_path} -Y "${supported_groups_filters}" -V | grep -E "Supported Group: "
    ${support_groups}=           Split String    ${support_groups}    \n
    @{all_supported_groups}=     Create List
    FOR    ${supported_group}    IN    @{support_groups}
       ${supported_group}=       Fetch From Right    ${supported_group}    :
       Append to List            ${all_supported_groups}    ${supported_group.strip()}
    END
    List Should Contain Sub List    ${all_supported_groups}    ${SUPPORTED_GROUPS}
    Remove Values From List         ${all_supported_groups}    @{SUPPORTED_GROUPS}
    ${status}=                      Run Keyword and Return Status    Should Be Empty    ${all_supported_groups}
    Run Keyword If                  '${status}'=='False'    Run Keywords
    ...    List Should Contain Sub List    ${all_supported_groups}    ${ADDITIONAL_SUPPORTED_GROUPS}    AND
    ...    Remove Values From List         ${all_supported_groups}    @{ADDITIONAL_SUPPORTED_GROUPS}    AND
    ...    Should Be Empty                 ${all_supported_groups}


Check Certificate
    [Documentation]    Description:    Checking the used certificate during TLS authentication. The PCAP file is
    ...                                checked via tshark if contain the proper certificate (checking subject name).
    ...                Input:          file_path = path to PCAP file_path
    ...                                IP_client = IP address of IP_client (source ip)
    ...                                IP_server = IP address of IP_server (destination ip)
    ...                                ca_subject_name = subject name of certificate using during TLS authentication
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]    ${file_path}    ${IP_client}    ${IP_server}    ${ca_subject_name}
    ${supported_groups_filters}=    Catenate      tls and ip.src == ${IP_client} and ip.dst == ${IP_server} and
    ...                                      tls.handshake.type == 11 and tls.handshake.certificates
    ${support_groups}=    Run    tshark -r ${file_path} -Y "${supported_groups_filters}" -V | grep -A 20 "id-at-commonName="
    ${support_groups}=    Split String    ${support_groups}    --
    Should Contain        ${support_groups}[0]    id-at-commonName=${ca_subject_name}
    Should Contain        ${support_groups}[1]    id-at-commonName=${ca_subject_name}

Check Triggered Ciphersuite
    [Documentation]    Description:    Checking the used cipher suite during TLS connecton. The PCAP file is checked
    ...                                via tshark to confirm if triggered cipher suite during OpenSSL connection is used.
    ...                Input:          file_path = path to PCAP file_path
    ...                                IP_client = IP address of IP_client (source ip)
    ...                                IP_server = IP address of IP_server (destination ip)
    ...                Output:         cipher_suite = cipher suite that is used according to PCAP file
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]                 ${file_path}    ${IP_client}    ${IP_server}
    ${cipher_suite_filters}=    Catenate      tls and ip.src == ${IP_client} and ip.dst == ${IP_server} and
    ...                                       tls.record.content_type == 22
    ${cipher_suite}=            Run    tshark -r ${file_path} -Y "${cipher_suite_filters}" -V | grep -E "Cipher Suite: " | head -n 1
    [Return]                    ${cipher_suite}

Get Random Cipher Suite
    [Documentation]    Description:    Getting the random cipher suite.
    ...                Input:          cipher_suites1_3_names = the list with all used cipher suites
    ...                Output:         icmp_random_type = selected (random) cipher suites
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]             ${cipher_suites1_3_names}
    ${icmp_random_type}=    Evaluate    random.choice(${cipher_suites1_3_names})    random
    [Return]                ${icmp_random_type}

Get VM address
    [Documentation]    Description:    Getting the VM address.
    ...                Input:          None
    ...                Output:         The IP address of VM.
    ...                Author:         jagoda.kubacka@nokia.com
    ${VM_address}=    Run    ip addr | grep "scope global eth0"
    ${VM_address}=    Get Regexp Matches    ${VM_address}    \\d{1,3}[.]\\d{1,3}[.]\\d{1,3}[.]\\d{1,3}
    [Return]          ${VM_address}[0]

Configure TLS versions
    [Documentation]    Description:    Configuration of TLS1.2 and/or TLS1.3
    ...                Input:          1_2 = responsible for enabling (value:true) or disabling (value: false) TLS1.2
    ...                                1_3 = responsible for enabling (value:true) or disabling (value: false) TLS1.3
    ...                                hw_type =  vCU/vDU
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]        ${1_2}=true    ${1_3}=false    ${hw_type}=${NONE}
    @{parameters}=     Create List
    @{param_values}=   Create List
    @{dist_names}=     Create List
    Append To List     ${parameters}      tls12Enabled    actEnableTLSv13
    Append To List     ${param_values}    ${1_2}    ${1_3}
    Run Keyword If    '${hw_type}'=='vCU'    Append To List    ${dist_names}
    ...                                      MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                      MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
    ...    ELSE IF    '${hw_type}'=='vDU'    Append To List    ${dist_names}
    ...                                      MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                      MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1
    Change Multiple Parameters on BTS
    ...                         dist_names=${dist_names}
    ...                         param_names=${parameters}
    ...                         param_values=${param_values}
    ...                         hw_type=${hw_type}

Configure Ciphersuites for TLS1_2
    [Documentation]    Description:    Configuration of parameters responsible for cipher suites in TLS1.2.
    ...                Input:          tls12CbcCipherDisabled = the value for tls12CbcCipherDisabled parameter (true/false)
    ...                                tls12RsaKexDisabled = the value for tls12RsaKexDisabled parameter (true/false)
    ...                                hw_type =  vCU/vDU
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]        ${tls12CbcCipherDisabled}=true    ${tls12RsaKexDisabled}=false    ${hw_type}=${NONE}
    @{parameters}=     Create List
    @{param_values}=   Create List
    @{dist_names}=     Create List
    Append To List     ${parameters}      ls12CbcCipherDisabled    tls12RsaKexDisabled
    Append To List     ${param_values}    ${tls12CbcCipherDisabled}    ${tls12RsaKexDisabled}
    Run Keyword If    '${hw_type}'=='vCU'    Append To List    ${dist_names}
    ...                                      MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                      MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
    ...    ELSE IF    '${hw_type}'=='vDU'    Append To List    ${dist_names}
    ...                                      MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                      MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1
    Change Multiple Parameters on BTS
    ...                         dist_names=${dist_names}
    ...                         param_names=${parameters}
    ...                         param_values=${param_values}
    ...                         hw_type=${hw_type}

Turn On/Off TLS
    [Documentation]    Description:    Turning on or off TLS.
    ...                Input:          state= on/off (enabled or disabled)
    ...                                hw_type =  vCU/vDU
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]        ${state}=on     ${hw_type}=${NONE}
    Run Keyword If    '${state}'=='on' and '${hw_type}'=='vCU'     Change Parameter on BTS
    ...               dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
    ...               param_name=oamTls    param_value=forced    hw_type=${hw_type}
    ...    ELSE IF    '${state}'=='on' and '${hw_type}'=='vDU'     Change Parameter on BTS
    ...               dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1
    ...               param_name=oamTls    param_value=forced    hw_type=${hw_type}
    ...    ELSE IF    '${state}'=='off' and '${hw_type}'=='vCU'    Change Parameter on BTS
    ...               dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
    ...               param_name=oamTls    param_value=off    hw_type=${hw_type}
    ...    ELSE IF    '${state}'=='off' and '${hw_type}'=='vDU'    Change Parameter on BTS
    ...               dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1
    ...               param_name=oamTls    param_value=off    hw_type=${hw_type}

_Test TLS1.2 Handshake
    [Documentation]    Description:    Verify if handshake in case of TLS1.2 is successful and contains every
    ...                                mandatory element in PCAP.
    ...                Input:          file_path = path to PCAP file_path
    ...                                IP_client = IP address of IP_client (source ip)
    ...                                IP_server = IP address of IP_server (destination ip)
    ...                                IP_port = IP port of IP_server (destination port)
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]                 ${file_path}    ${IP_client}    ${IP_server}    ${IP_port}=${NONE}
    ${client_hello_filters}=    Run Keyword If    '${IP_port}' != '${NONE}'
    ...                         Catenate      tls and ip.src == ${IP_client} and ip.dst == ${IP_server} and tcp.dstport == ${IP_port} and
    ...                                       tls.handshake.type == 1
    ...                         ELSE
    ...                         Catenate      tls and ip.src == ${IP_client} and ip.dst == ${IP_server} and
    ...                                       tls.handshake.type == 1
    ${client_hello}=            Run    tshark -r ${file_path} -Y '${client_hello_filters}' | wc -l
	Log                         Packets "Client Hello" is: ${client_hello}    console=true
    Should Not Be Equal         ${client_hello}    0
    ${server_hello_filters}=    Run Keyword If    '${IP_port}' != '${NONE}'
    ...                         Catenate    tls and ip.src == ${IP_server} and ip.dst == ${IP_client} and tcp.srcport == ${IP_port} and
    ...                         tls.handshake.type == 2
    ...                         ELSE
    ...                         Catenate    tls and ip.src == ${IP_server} and ip.dst == ${IP_client} and
    ...                         tls.handshake.type == 2
    ${server_hello}=            Run    tshark -r ${file_path} -Y '${server_hello_filters}' | wc -l
	Log    Packets "Server Hello, Certificate, IP_server Key Exchange, IP_server Hello Done" is: ${server_hello}    console=true
    Should Not Be Equal         ${server_hello}    0
    ${client_exchange_filters}=    Run Keyword If    '${IP_port}' != '${NONE}'
    ...                         Catenate    tls and ip.src == ${IP_client} and ip.dst == ${IP_server} and tcp.dstport == ${IP_port} and
    ...                         tls.handshake.type == 16
    ...                         ELSE
    ...                         Catenate    tls and ip.src == ${IP_client} and ip.dst == ${IP_server} and
    ...                         tls.handshake.type == 16
    ${client_exchange}=         Run    tshark -r ${file_path} -Y '${client_exchange_filters}' | wc -l
	Log    Packets "Client Key Exchange, Change Cipher Spec, Encrypted Handshake Message" is: ${client_exchange}    console=true
    Should Not Be Equal         ${client_exchange}    0
    ${change_cipher_filters}=   Run Keyword If    '${IP_port}' != '${NONE}'
    ...                         Catenate    tls and ip.src == ${IP_client} and ip.dst == ${IP_server} and tcp.dstport == ${IP_port} and
    ...                         tls.record.content_type == 20 and tls.record.content_type == 22
    ...                         ELSE
    ...                         Catenate    tls and ip.src == ${IP_client} and ip.dst == ${IP_server} and
    ...                         tls.record.content_type == 20 and tls.record.content_type == 22
    ${change_cipher}=           Run    tshark -r ${file_path} -Y '${change_cipher_filters}' | wc -l
	Log    Packets "Change Cipher Spec, Encrypted Handshake Message" is: ${change_cipher}    console=true
    Should Not Be Equal         ${change_cipher}    0

_Test TLS1.3 Handshake
    [Documentation]    Description:    Verify if handshake in case of TLS1.3 is successful and contains every
    ...                                mandatory element in PCAP.
    ...                Input:          file_path = path to PCAP file_path
    ...                                IP_client = IP address of IP_client (source ip)
    ...                                IP_server = IP address of IP_server (destination ip)
    ...                                IP_port = IP port of IP_server (destination port)
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]    ${file_path}    ${IP_client}    ${IP_server}    ${IP_port}=${NONE}
    ${client_hello_filters}=    Run Keyword If    '${IP_port}' != '${NONE}'
    ...                         Catenate      tls and ip.src == ${IP_client} and ip.dst == ${IP_server} and tcp.dstport == ${IP_port} and
    ...                                       tls.handshake.type == 1
    ...                         ELSE
    ...                         Catenate      tls and ip.src == ${IP_client} and ip.dst == ${IP_server} and
    ...                                       tls.handshake.type == 1
    ${client_hello}=            Run    tshark -r ${file_path} -Y '${client_hello_filters}' | wc -l
	Log    Packets "Client Hello" is: ${client_hello}    console=true
    Should Not Be Equal         ${client_hello}    0
    ${server_hello_filters}=    Run Keyword If    '${IP_port}' != '${NONE}'
    ...                         Catenate    tls and ip.src == ${IP_server} and ip.dst == ${IP_client} and tcp.srcport == ${IP_port} and
    ...                         tls.handshake.type == 2
    ...                         ELSE
    ...                         Catenate    tls and ip.src == ${IP_server} and ip.dst == ${IP_client} and
    ...                         tls.handshake.type == 2
   ${server_hello}=            Run    tshark -r ${file_path} -Y '${server_hello_filters}' | wc -l
	Log    Packets "Server Hello" is: ${server_hello}    console=true
    Should Not Be Equal         ${server_hello}    0
    ${change_cipher_filters}=   Run Keyword If    '${IP_port}' != '${NONE}'
    ...                         Catenate    tls and ip.src == ${IP_client} and ip.dst == ${IP_server} and tcp.dstport == ${IP_port} and
    ...                         tls.record.content_type == 20
    ...                         ELSE
    ...                         Catenate    tls and ip.src == ${IP_client} and ip.dst == ${IP_server} and
    ...                         tls.record.content_type == 20
   ${change_cipher}=           Run    tshark -r ${file_path} -Y '${change_cipher_filters}' | wc -l
	Log    Packets "Change Cipher Spec, Application Data" is: ${change_cipher}    console=true
    Should Not Be Equal         ${change_cipher}    0

_Select Model Cipher Suites
    [Arguments]    ${hw_type}
    ${TLS13_value}=         Run Keyword If    '${hw_type}'=='vCU'    Check Parameter Value    actEnableTLSv13
    ...                                                              MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                                              hw_type=${hw_type}
    ...                     ELSE    Check Parameter Value    actEnableTLSv13
    ...                             MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1    hw_type=${hw_type}
    ${TLS12_value}=         Run Keyword If    '${hw_type}'=='vCU'    Check Parameter Value    tls12Enabled
    ...                                                              MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                                              hw_type=${hw_type}
    ...                     ELSE    Check Parameter Value    tls12Enabled
    ...                             MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1    hw_type=${hw_type}
    ${TLS12_RSAKEX}=        Run Keyword If
    ...                     '${TLS13_value}'=='false' and '${TLS12_value}'=='true' and '${hw_type}'=='vCU'
    ...                     Check Parameter Value    tls12RsaKExDisabled
    ...                     MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1    hw_type=${hw_type}
    ...    ELSE IF          '${TLS13_value}'=='false' and '${TLS12_value}'=='true' and '${hw_type}'=='vDU'
    ...                     Check Parameter Value    tls12RsaKExDisabled
    ...                     MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1    hw_type=${hw_type}
    ${TLS12_CBC}=           Run Keyword If
    ...                     '${TLS13_value}'=='false' and '${TLS12_value}'=='true' and '${hw_type}'=='vCU'
    ...                     Check Parameter Value    tls12CbcCipherDisabled
    ...                     MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1    hw_type=${hw_type}
    ...    ELSE IF          '${TLS13_value}'=='false' and '${TLS12_value}'=='true' and '${hw_type}'=='vDU'
    ...                     Check Parameter Value    tls12CbcCipherDisabled
    ...                     MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1    hw_type=${hw_type}
    ${ALL_CIPHER_SUITES}=   Run Keyword If    '${TLS13_value}'=='true' and '${TLS12_value}'=='true'    Set Variable    ${CIPHER_SUITES1_3_1_2}
    ...    ELSE IF        '${TLS13_value}'=='true' and '${TLS12_value}'=='false'    Set Variable    ${CIPHER_SUITES1_3}
    ...    ELSE IF        '${TLS12_value}'=='true' and '${TLS12_RSAKEX}'=='true' and '${TLS12_CBC}'=='true' and '${TLS13_value}'=='false'
    ...    Set Variable    ${CIPHER_SUITES1_2_RSA_CBC}
    ...    ELSE IF        '${TLS12_value}'=='true' and '${TLS12_RSAKEX}'=='false' and '${TLS12_CBC}'=='true' and '${TLS13_value}'=='false'
    ...    Set Variable    ${CIPHER_SUITES1_2_CBC}
    ...    ELSE IF        '${TLS12_value}'=='true' and '${TLS12_RSAKEX}'=='true' and '${TLS12_CBC}'=='false' and '${TLS13_value}'=='false'
    ...    Set Variable    ${CIPHER_SUITES1_2_RSA}
    ...    ELSE IF        '${TLS12_value}'=='true' and '${TLS12_RSAKEX}'=='false' and '${TLS12_CBC}'=='false' and '${TLS13_value}'=='false'
    ...    Set Variable    ${CIPHER_SUITES1_2}
    [Return]    ${ALL_CIPHER_SUITES}

