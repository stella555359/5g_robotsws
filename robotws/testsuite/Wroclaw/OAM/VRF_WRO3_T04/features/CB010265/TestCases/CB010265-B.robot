*** Settings ***
Documentation
...  author:     Jagoda Kubacka
...  contact:    jagoda.kubacka@nokia.com

Resource    ../Resources/CB010265_Keywords.robot
Resource    ../../../../cloud_common_resources/certificates/certificates.robot
Resource    ../../../../cloud_common_resources/logs/logs.robot
Resource    ../../../cloud_common_resources/emssim/emssim_setup.robot
Resource    ../../../cloud_common_resources/tls/tls.robot

*** Variables ***

${RSA_SUBJECT_NAME}=        C=PL, O=Common, CN=IPSEC
${RSA_SUBJECT_NAME_CN}=     CN=IPSEC
${ECDSA_SUBJECT_NAME}=      CN=CB005999_test
${SHA-1_SUBJECT_NAME}=      C=PL,O=TRS_SEC,CN=5G22R2_Realease
${SHA-384_SUBJECT_NAME}=    CN=Cloud_SHA384
@{PORTS}                    443    8443

*** Keywords ***
CB010265-B_T01_Secured_TLS_Connection_TLS12_TLS13_vDU
    Log    Step 1, 2, 3: Configuring the CMP object to initialize certificates    console=true
    Update CMP Server Settings      key_pool_type=RSA    hw_type=vDU
    Configure CMP                   ca_subject_name=${RSA_SUBJECT_NAME}    server_type=RSA    hw_type=vDU
    Wait Until Keyword Succeeds    5x    1min      Initialize Certificate    key_pool_type=RSA    hw_type=vDU
    Log    Step 4: Set the actEnableTLSv13 to true    console=true
    Configure TLS versions          1_3=false    hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=certTypeForTlsAuth    param_value=RSA    hw_type=vDU
    Log    Step 5: Set the oamTlsStatus to true    console=true
    Turn On/Off TLS                 state=on     hw_type=vDU
    Log    Step 6: Setup the EMSSIM environmental    console=true
    Setup environment for EMSSIM     cert_type=RSA    hw_type=vDU

    Log    Step 7: Start IP traffic capturing (PCAP collection)    console=true
    Start TCPdump                    capture_type=pod    pod_names=po-oamext-0    hw_type=vDU
    Sleep                            30s    reason=Due to delays in Cloud, the sleep is needed to ensure PCAP collecting
    Log    Step 8: Connecting the VM to the M-Plane with EMSSIM    console=true
    ${emssim_connection}=            Connect and Activate EMSSIM    cert_type=RSA    hw_type=vDU
    Log    Step 9, 10: Stopping IP traffic capturing (PCAP generating and downloading)
    ${pcap_path}=                    Stop TCPdump and Download Pcap    pod_name=po-oamext-0     hw_type=vDU

    Log    Step 11: Check if handshake is visible in PCAP file    console=true
    ${VM_IP}=               Get VM address
    Test TLS Handshake      file_path=${pcap_path}    IP_client=${VM_IP}    IP_server=${LMP_VDU_IP}    hw_type=vDU
    Log    Step 12, 13: Check if all supported ciphersuites are visible in PCAP file    console=true
    Check Ciphersuites      file_path=${pcap_path}    IP_client=${VM_IP}    IP_server=${LMP_VDU_IP}
    ...                     cert_type=RSA    hw_type=vDU
    Log    Step 14: Check if all supported groups are visible in PCAP file    console=true
    Check Supported Groups   file_path=${pcap_path}    IP_client=${VM_IP}    IP_server=${LMP_VDU_IP}

    Log    Step 15, 16: Set the tls12Enabled parameter to true and actEnableTLSv13 to false    console=true
    Configure TLS versions          1_3=false    hw_type=vDU
    ${PARAM_VALUES_CBC}=            Create List    true    false    true    false
    ${PARAM_VALUES_RSA}=            Create List    true    true    false    false
    FOR    ${param_values}    IN RANGE    0    4
        Log    Step 17, 18: Set the tls12CbcCipherDisabled and tls12RsaKexDisabled parameters    console=true
        Configure Ciphersuites for TLS1_2
        ...                     tls12CbcCipherDisabled=${PARAM_VALUES_CBC}[${param_values}]
        ...                     tls12RsaKexDisabled=${PARAM_VALUES_RSA}[${param_values}]
        ...                     hw_type=vDU
        Log    Step 19: Start IP traffic capturing (PCAP collection)    console=true
        Start TCPdump            capture_type=pod    pod_names=po-oamext-0    hw_type=vDU
        Sleep                    30s    reason=Due to delays in Cloud, the sleep is needed to ensure PCAP collecting
        Log    Step 20: Connecting the VM to the M-Plane with EMSSIM    console=true
        ${emssim_connection}=    Connect and Activate EMSSIM    cert_type=RSA    hw_type=vDU
        Log    Step 21, 22: Stop IP traffic capturing (PCAP generating and downloading)    console=true
        ${pcap_path}=            Stop TCPdump and Download Pcap    pod_name=po-oamext-0     hw_type=vDU
        Log    Step 23: Check if handshake if visible in PCAP    console=true
        Test TLS Handshake       file_path=${pcap_path}    IP_client=${VM_IP}    IP_server=${LMP_VDU_IP}    hw_type=vDU
        Log    Step 24, 25: Check if all supported ciphersuites are visible in PCAP file    console=true
        Check Ciphersuites       file_path=${pcap_path}    IP_client=${VM_IP}    IP_server=${LMP_VDU_IP}
        ...                      cert_type=RSA    hw_type=vDU
        Log    Step 26: Check if all supported groups are visible in PCAP file    console=true
        Check Supported Groups   file_path=${pcap_path}    IP_client=${VM_IP}    IP_server=${LMP_VDU_IP}
    END
    [Teardown]    Run Keywords
    ...           TCPdump Teardown    hw_type=vDU                 AND
    ...           Disconnect From EMSSIM    connection=${emssim_connection}    AND
    ...           Restore Default Certificates on BTS    hw_type=vDU

CB010265_B_T02_Authentication_with_supported_and_unsupported_signatures_vDU
    Log    Step 1, 2: Connect to vDU and configure CMP object with SHA-1 signature details   console=true
    Update CMP Server Settings      key_pool_type=RSA    hw_type=vDU
    Turn On/Off TLS                 state=on     hw_type=vDU
    Configure CMP                   ca_subject_name=${SHA-1_SUBJECT_NAME}    server_type=RSA    hw_type=vDU
    Log    Step 3: Initialization should fail due to not supported SHA-1 signature    console=true
    ${status}=         Run Keyword and Return Status    Initialize Certificate    key_pool_type=RSA    hw_type=vDU
    Should Be Equal    ${status}    ${False}
    Log    Step 4: Configure CMP object with SHA-384 signature details    console=True
    Configure CMP      ca_subject_name=${SHA-384_SUBJECT_NAME}    server_type=RSA    hw_type=vDU
    Log    Step 5: Initialization should succeed    console=true
    ${status}=         Run Keyword and Return Status    Initialize Certificate    key_pool_type=RSA    hw_type=vDU
    Should Be Equal    ${status}    ${True}
    Log    Step 6 7: Configure TLS1.3 and turn on TLS    console=true
    Configure TLS versions          1_3=true    hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=certTypeForTlsAuth    param_value=RSA    hw_type=vDU
    Turn On/Off TLS                 state=on     hw_type=vDU
    ${VM_IP}=                       Get VM address

    Log    Step 8, 9, 10, 11: Capturing IP traffic and checking if handshake is successful    console=true
    FOR  ${port}  IN  @{PORTS}
        Start TCPdump         capture_type=pod    pod_names=po-oamext-0    hw_type=vDU
        Sleep                 30s    reason=Due to delays in Cloud, the sleep is needed to ensure PCAP collecting
        RUN                   timeout 30s openssl s_client -connect ${LMP_VDU_IP}:${port} -tls1
        Sleep                 30s    reason=Wait until some amount of packets will be sent to check the details of connection
        ${pcap_path}=         Stop TCPdump and Download Pcap    pod_name=po-oamext-0     hw_type=vDU
        Test TLS Handshake    file_path=${pcap_path}    IP_client=${VM_IP}    IP_server=${LMP_VDU_IP}    hw_type=vDU
    END
    Verification the eeSubjectAltNames parameters    RSA    vCU
    Verification the eeSubjectAltNames parameters    ECDSA    vDU
    [Teardown]    Run Keywords
    ...           TCPdump Teardown    hw_type=vDU                 AND
    ...           Restore Default Certificates on BTS    hw_type=vDU

CB010265_B_T03_RSA_and_ECDSA_operator_certificate_switch_used_NMS_connection_vCU
    Log    Step 1,2: Configure CMP server settings    console=true
    ${ECDSA_CN}=                    Fetch From Right    ${ECDSA_SUBJECT_NAME}    CN=
    ${RSA_CN}=                      Fetch From Right    ${RSA_SUBJECT_NAME_CN}    CN=
    Update CMP Server Settings      key_pool_type=RSA    hw_type=vCU
    Update CMP Server Settings      key_pool_type=ECDSA    hw_type=vCU
    Log    Step 3,4: Configure TLS1.3 and turn on TLS    console=true
    Configure TLS versions          hw_type=vCU
    Turn On/Off TLS                 state=on     hw_type=vCU
    ${VM_IP}=    Get VM address
    FOR  ${port}  IN  @{PORTS}
        Log    Step 5: Configure CMP object with ECDSA subject name    console=true
        Configure CMP              ca_subject_name=${ECDSA_SUBJECT_NAME}    server_type=RSA    hw_type=vCU
        Log    Step 6: Initize the RSA certificate with ECDSA subject name    console=true
        Initialize Certificate     key_pool_type=RSA    hw_type=vCU
        Log    Step 7: Set the certTypeForTlsAuth parameter to RSA    console=true
        Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
        ...                        param_name=certTypeForTlsAuth    param_value=RSA    hw_type=vCU
        Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
        ...                        param_name=certTypeForRestHttpsTLSAuth    param_value=RSA    hw_type=vCU
        Log    Step 8, 9: Connecting to M-Plane via OpenSSL command and capture IP traffic    console=true
        Start TCPdump              capture_type=pod    pod_names=po-oamext-0    hw_type=vCU
        Sleep                      30s    reason=Due to delays in Cloud, the sleep is needed to ensure PCAP collecting
        RUN                        timeout 30s openssl s_client -connect ${LMP_VCU_IP}:${port} -tls1_2
        Sleep                      30s    reason=Wait until some amount of packets will be sent to check the details of connection
        Log    Step 10, 11: Stopping and generating PCAP file    console=true
        ${pcap_path}=              Stop TCPdump and Download Pcap    pod_name=po-oamext-0     hw_type=vCU
        Log    Step 12: Checking handshake and subject name of used certificate in PCAP    console=true
        Test TLS Handshake         file_path=${pcap_path}    IP_client=${VM_IP}    IP_server=${LMP_VCU_IP}    hw_type=vCU
        Check Certificate          file_path=${pcap_path}    IP_client=${LMP_VCU_IP}    IP_server=${VM_IP}
        ...                        ca_subject_name=${ECDSA_CN}
        Log    Step 13: Configure CMPECDSA object with RSA subject name    console=true
        Configure CMP              ca_subject_name=${RSA_SUBJECT_NAME}    server_type=ECDSA    hw_type=vCU
        Log    Step 14: Initize the ECDSA certificate with RSA subject name    console=true
        Initialize Certificate     key_pool_type=ECDSA    hw_type=vCU
        Log    Step 15: Set the certTypeForTlsAuth parameter to ECDSA    console=true
        Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
        ...                        param_name=certTypeForTlsAuth    param_value=ECDSA    hw_type=vCU
        Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
        ...                        param_name=certTypeForRestHttpsTLSAuth    param_value=ECDSA    hw_type=vCU
        Log    Step 16, 17: Connecting to M-Plane via OpenSSL command and capture IP traffic    console=true
        Start TCPdump              capture_type=pod    pod_names=po-oamext-0    hw_type=vCU
        Sleep                      30s    reason=Due to delays in Cloud, the sleep is needed to ensure PCAP collecting
        RUN                        timeout 30s openssl s_client -connect ${LMP_VCU_IP}:${port} -tls1_2
        Sleep                      30s    reason=Wait until some amount of packets will be sent to check the details of connection
        Log    Step 18, 19: Stopping ang generating PCAP file    console=true
        ${pcap_path}=              Stop TCPdump and Download Pcap    pod_name=po-oamext-0     hw_type=vCU
        Log    Step 20: Checking handshake and subject name of used certificate in PCAP    console=true
        Test TLS Handshake        file_path=${pcap_path}    IP_client=${VM_IP}    IP_server=${LMP_VCU_IP}    hw_type=vCU
        Check Certificate         file_path=${pcap_path}    IP_client=${LMP_VCU_IP}    IP_server=${VM_IP}
        ...                       ca_subject_name=${RSA_CN}
    END
    [Teardown]    Run Keywords
    ...           TCPdump Teardown    hw_type=vCU                 AND
    ...           Restore Default Certificates on BTS    hw_type=vCU

CB010265_B_T04_TLS1_1_not_supported_and_TLS_1_3_cipher_suite_selection_vCU
    Log    Step 1, 2: Configure CMP server settings for ECDSA and RSA    console=true
    Update CMP Server Settings      key_pool_type=RSA    hw_type=vCU
    Update CMP Server Settings      key_pool_type=ECDSA    hw_type=vCU
    Log    Step 3, 4: Configure CMPECDSA object and initialize ECDSA certificate    console=true
    Configure CMP                   ca_subject_name=${ECDSA_SUBJECT_NAME}    server_type=RSA    hw_type=vCU
    Initialize Certificate          key_pool_type=ECDSA    hw_type=vCU
    Log    Step 5, 6: Configure CMP object and initialize RSA certificate    console=true
    Configure CMP                   ca_subject_name=${RSA_SUBJECT_NAME}    server_type=RSA    hw_type=vCU
    Initialize Certificate          key_pool_type=RSA    hw_type=vCU
    Log    Step 7, 8: Configure TLS1.3 and turn on TLS    console=true
    Configure TLS versions          1_2=true    1_3=true    hw_type=vCU
    Turn On/Off TLS                 state=on     hw_type=vCU
    ${VM_IP}=    Get VM address

    Log    Step 9, 10: Start IP traffic capturing and connect via OpenSSL with TLS1.1    console=true
    Start TCPdump    capture_type=pod    pod_names=po-oamext-0    hw_type=vCU
    Sleep            30s    reason=Due to delays in Cloud, the sleep is needed to ensure PCAP collecting
    RUN              timeout 30s openssl s_client -connect ${LMP_VCU_IP}:443 -tls1_1
    Sleep            30s    reason=Wait until some amount of packets will be sent to check the details of connection
    Log    Step 11: Stop IP traffic capturing and generate PCAP file    console=true
    ${pcap_path}=    Stop TCPdump and Download Pcap    pod_name=po-oamext-0     hw_type=vCU
    Log    Step 12: Checking if connection is failed due to not supported protocol in PCAP    console=true
    ${tls1_1_filters}=     Catenate    ip.addr == ${VM_IP}  and ip.addr == ${LMP_VCU_IP} and tls.record.content_type == 21
    ${tls1_1_err_mess}=    Run    tshark -r ${pcap_path} -Y "${tls1_1_filters}"
    Should Contain         ${tls1_1_err_mess}    TLSv1.1
    Should Contain         ${tls1_1_err_mess}    Level: Fatal
    Should Contain         ${tls1_1_err_mess}    Description: Protocol Version
    FOR  ${port}  IN  @{PORTS}
        Log    Step 13: Set the certTypeForTlsAuth to ECDSA    console=true
        Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
        ...                        param_name=certTypeForTlsAuth    param_value=ECDSA    hw_type=vCU
        Log    Step 14, 15: Start IP traffic caturing and connect via OpenSSL with defined cipher suite    console=true
        ${cipher_suite}=           Get Random Cipher Suite    ${CIPHER_SUITES1_3_ECDSA}
        Start TCPdump              capture_type=pod    pod_names=po-oamext-0    hw_type=vCU
        Sleep                      30s    reason=Due to delays in Cloud, the sleep is needed to ensure PCAP collecting
        RUN                        timeout 30s openssl s_client -cipher '${cipher_suite}' -connect ${LMP_VCU_IP}:${port} -tls1_3
        Sleep                      30s    reason=Wait until some amount of packets will be sent to check the details of connection
        Log    Step 16: Stop IP traffic capturing and generate PCAP file    console=true
        ${pcap_path}=              Stop TCPdump and Download Pcap    pod_name=po-oamext-0     hw_type=vCU
        Log    Step 17: Check in PCAP if connection contains the defined cipher suite    console=true
        ${cipher_suite}=           Check Triggered Ciphersuite    ${pcap_path}    ${LMP_VCU_IP}    ${VM_IP}
        Should Contain             ${cipher_suite}    ${cipher_suite}

        Log    Step 18: Set the certTypeForTlsAuth to RSA    console=true
        Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
        ...                        param_name=certTypeForTlsAuth    param_value=RSA    hw_type=vCU
        ${cipher_suite}=           Get Random Cipher Suite    ${CIPHER_SUITES1_3_RSA}
        Log    Step 19, 20: Start IP traffic caturing and connect via OpenSSL with defined cipher suite    console=true
        Start TCPdump              capture_type=pod    pod_names=po-oamext-0    hw_type=vCU
        Sleep                      30s    reason=Due to delays in Cloud, the sleep is needed to ensure PCAP collecting
        RUN                        timeout 30s openssl s_client -cipher '${cipher_suite}' -connect ${LMP_VCU_IP}:${port} -tls1_3
        Sleep                      30s    reason=Wait until some amount of packets will be sent to check the details of connection
        Log    Step 21: Stop IP traffic capturing and generate PCAP file    console=true
        ${pcap_path}=              Stop TCPdump and Download Pcap    pod_name=po-oamext-0     hw_type=vCU
        Log    Step 22: Check in PCAP if connection contains the defined cipher suite    console=true
        ${cipher_suite}=           Check Triggered Ciphersuite    ${pcap_path}    ${LMP_VCU_IP}    ${VM_IP}
        Should Contain             ${cipher_suite}    ${cipher_suite}
    END
    [Teardown]    Run Keywords
    ...           TCPdump Teardown    hw_type=vCU                 AND
    ...           Restore Default Certificates on BTS    hw_type=vCU

