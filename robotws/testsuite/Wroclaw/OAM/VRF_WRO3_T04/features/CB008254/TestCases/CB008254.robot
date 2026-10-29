*** Settings ***
Documentation    Test for CB008254 feature

Resource        ../../../common_resources/emssim/emssim_setup.robot
Resource        ../../../common_resources/emssim/emssim.robot
Resource        ../../../common_resources/tls/tls.robot
Resource        ../resources/CB008254.robot
Resource        ../../../common_resources/binary_files/binary_files.robot
Resource        ../../../common_resources/scf/scf_objects.robot
Library         ../resources/resources.py
Library         taf.sbts.oam.coam.admin      WITH NAME   coam_admin


*** Keywords ***
CB008254_ECDSA_operator_certificate_based_authentication_with_BTS_as_Client_for_TLSv1.3_NMS
    Setup environment for EMSSIM       cert_type=ECDSA
    Start TCPDump
    ${emssim_connection}               Connect and Activate EMSSIM    cert_type=ECDSA
    Stop TCPDump And Download PCAP     tcpdump_filename=${PCAP_NAME}
    Verify TLS Handshake In PCAP       pcap_file=${OUTPUT DIR}/${TEST NAME}/${PCAP_NAME}   tls_version=1_3
    [Teardown]                         Run Keywords
    ...                                TCPDump Teardown                     AND
    ...                                emssim.Disconnect From EMSSIM
    ...                                connection=${emssim_connection}

CB008254_ECDSA_operator_certificate_based_authentication_with_BTS_as_Client_for_TLSv1.2_and_Earlier
    Setup environment for EMSSIM        cert_type=ECDSA    tls_version=1_2
    Change parameter on BTS             MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                 certTypeForTlsAuth
    ...                                 ECDSA
    Configure CMP                       ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                                 server_type=ECDSA
    Initialize Certificates             key_pool_type=ECDSA
    Sleep                               10
    ...                                 reason=Wait until certificates initialization completed
    Start TCPDump
    Sleep                               15
    ...                                 reason=Wait until tcpdump starts properly
    ${emssim_connection}=               Connect and Activate EMSSIM    cert_type=ECDSA
    Stop TCPDump And Download PCAP      tcpdump_filename=tls1_2.pcap
    tls.Verify TLS Handshake In PCAP     pcap_file${TEST_OUTPUT_DIR}/tls1_2.pcap   tls_version=1_2
    [Teardown]                          Run Keywords
    ...                                 TCPDump Teardown                     AND
    ...                                 emssim.Disconnect From EMSSIM
    ...                                 connection=${emssim_connection}

CB008254_Certificate_Manual_Installation
    Generate Binary File From HEX String    hex_string_file=${P12_ECDSA}
    ...                                     binary_file_name=${CURDIR}/ECDSA.p12
    Generate Binary File From HEX String    hex_string_file=${P12_RSA}
    ...                                     binary_file_name=${CURDIR}/RSA.p12
    Install Certificate On BTS              cert_file=${CURDIR}/ECDSA.p12
    ...                                     cert_type=BtsTrustChain
    ...                                     cert_format=P12
    ...                                     p12password=${P12_PASSWORD}
    ...                                     key_pool_type=ECDSA
    ${keyPoolType}=  Get KeyPoolType From BTS Certificate    CN = CB005999_long_validity
    Log  ${keyPoolType}  console=True
    Check If Certificate File Is Present On BTS  ${keyPoolType}
    Install Certificate On BTS              cert_file=${CURDIR}/RSA.p12
    ...                                     cert_type=BtsTrustChain
    ...                                     cert_format=P12
    ...                                     p12password=${P12_PASSWORD}
    ...                                     key_pool_type=RSA
    ${keyPoolType}=  Get KeyPoolType From BTS Certificate  CN = CB007672
    Log  ${keyPoolType}  console=True
    Check If Certificate File Is Present On BTS  ${keyPoolType}


CB008254_Differentiator_for_RSA_and_ECDSA_operations_error_code
    Generate Binary File From HEX String    hex_string_file=${P12_ECDSA}
    ...                                     binary_file_name=${CURDIR}/ECDSA.p12
    Generate Binary File From HEX String    hex_string_file=${P12_RSA}
    ...                                     binary_file_name=${CURDIR}/RSA.p12
    ${error_ecdsa_p12}=   Run Keyword And Expect Error   *Candidate key mismatch - Received candidate key and selected key type are not matching.*
    ...                                     Install Certificate On BTS
    ...                                     cert_file=${CURDIR}/ECDSA.p12
    ...                                     cert_type=BtsTrustChain
    ...                                     cert_format=P12
    ...                                     p12password=${P12_PASSWORD}
    ...                                     key_pool_type=RSA
    Log  ${error_ecdsa_p12}  console=true
    ${error_rsa_p12}=   Run Keyword And Expect Error   *Candidate key mismatch - Received candidate key and selected key type are not matching.*
    ...                                     Install Certificate On BTS
    ...                                     cert_file=${CURDIR}/RSA.p12
    ...                                     cert_type=BtsTrustChain
    ...                                     cert_format=P12
    ...                                     p12password=${P12_PASSWORD}
    ...                                     key_pool_type=ECDSA
    Log  ${error_rsa_p12}  console=true

CB008254_TLS_ECDHE_Cipher_support
    Configure TLS versions    1_2=true
    Turn On TLS
    Configure CMP                           ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                                     server_type=ECDSA
    Configure CMP                           ca_subject_name=${RSA_SUBJECT_NAME}
    ...                                     server_type=RSA
    Initialize Certificates                 key_pool_type=ECDSA
    Initialize Certificates                 key_pool_type=RSA
    Change parameter on BTS                 MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                     tls12CbcCipherDisabled
    ...                                     true
    FOR  ${port}  IN  @{PORTS}
        Change parameter on BTS                 MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
        ...                                     certTypeForTlsAuth
        ...                                     ECDSA
        Start TCPDump
        Sleep                                   15
        ...                                     reason=Wait until tcpdump starts properly
        ${output}=  RUN   openssl s_client -cipher 'ECDHE-ECDSA-AES256-GCM-SHA384' -connect ${mplane_add}:${port} -tls1_2

        Log  ${output}  console=true
        Sleep                                   15
        ...                                     reason=Wait until conction established
        Stop TCPDump And Download PCAP          tcpdump_filename=ecdsa_${port}.pcap
        Convert pcap to XML                     filename=${TEST_OUTPUT_DIR}/ecdsa_${port}.pcap
        ...                                     filters=tls.record.content_type == 22 && ip.dst==${VM_IP} && ip.src==${mplane_add}
        ...                                     xml_name=${CURDIR}/ecdsa_${port}.xml
        ${ecdsa}=  find_ecdhe_ciphers           ${CURDIR}/ecdsa_${port}.xml
        Log  ${ecdsa}[0][showname]  console=true
        Should contain  ${ecdsa}[0][showname]  TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
        Change parameter on BTS                 MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
        ...                                     certTypeForTlsAuth
        ...                                     RSA
        Start TCPDump
        Sleep                                   15
        ...                                     reason=Wait until tcpdump starts properly
        ${rsa_openssl}=  RUN    openssl s_client -cipher 'DHE-RSA-AES256-GCM-SHA384' -connect ${mplane_add}:${port} -tls1_2
        Log  ${rsa_openssl}  console=true
        Stop TCPDump And Download PCAP          tcpdump_filename=rsa_${port}.pcap
        Convert pcap to XML                     filename=${TEST_OUTPUT_DIR}/rsa_${port}.pcap
        ...                                     filters=tls.record.content_type == 22 && ip.dst==${VM_IP} && ip.src==${mplane_add}
        ...                                     xml_name=${CURDIR}/rsa_${port}.xml
        ${rsa}=  find_ecdhe_ciphers             ${CURDIR}/rsa_${port}.xml
        Log  ${rsa}[0][showname]  console=true
        Should contain  ${rsa}[0][showname]     TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
    END
    [Teardown]                              Run Keywords  TCPDump Teardown  AND
    ...           Change parameter on BTS                 MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                     tls12CbcCipherDisabled
    ...                                     false

CB008254_ECDSA_operator_certificate_based_authentication_with_BTS_as_Client_for_TLSv1.3_LDAP
    Change parameter on BTS                 MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                     certTypeForTlsAuth
    ...                                     ECDSA
    Setup environment for EMSSIM            cert_type=ECDSA
    RUN  sudo chmod 777 /etc/emssim.conf
    RUN  sudo echo ldap_sec_port = 636 >> /etc/emssim.conf
    ${emssim_connection}                    Connect and Activate EMSSIM    cert_type=ECDSA
    Wait until keyword succeeds             5x    1min    emssim_operation.execute_command_on_emssim
    ...                                     command=ldap_user_add secadmin1 Nokia@123 -a RW
    ...                                     connection=${emssim_connection}
    Sleep                                   30
    emssim_operation.execute_command_on_emssim
    ...                                     command=user_info_update -username secadmin1 -password Nokia@123 -type app_adm -status enabled
    ...                                     connection=${emssim_connection}
    Change parameter on BTS                 MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                     actRestrictLoginToCnum
    ...                                     true
    Sleep    90                             reason=Executing command
    ${conn_cnum_app}=                       Connect to ADMIN
    ...                                     username=secadmin1
    ...                                     password=Nokia@123
    ...                                     timeout=${180}
    Change parameter on BTS                 dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                     param_name=actRestrictLoginToCnum
    ...                                     param_value=false
    ...                                     connection=${conn_cnum_app}
    [Teardown]   Run Keywords               emssim.Disconnect From EMSSIM   connection=${emssim_connection}
    ...          AND                        Disconnect from ADMIN           ${conn_cnum_app}

CB008254_Check_certificate_synchronization_between_active_and_passive_partition
    Configure CMP                           ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                                     server_type=ECDSA
    Configure CMP                           ca_subject_name=${RSA_SUBJECT_NAME}
    ...                                     server_type=RSA
    Initialize Certificates   key_pool_type=ECDSA
    Initialize Certificates   key_pool_type=RSA
    Wait Until keyword Succeeds    3x    10min  Check Synchronization By Ssh

CB008254_Eliptic_curve_and_RSA_cross_certification_support_TLS_connection
    Configure CMP                           ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                                     server_type=RSA
    Initialize Certificates                 key_pool_type=RSA
    Configure TLS versions    1_2=true
    Turn On TLS
    FOR  ${port}  IN  @{PORTS}
        Change parameter on BTS                 MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
        ...                                     certTypeForTlsAuth
        ...                                     RSA
        Start Tcpdump
        RUN  openssl s_client -connect ${mplane_add}:${port} -tls1_2
        Stop Tcpdump And Download Pcap          tcpdump_filename=rsa_${port}.pcap
        Convert pcap to XML                     filename=${TEST_OUTPUT_DIR}/rsa_${port}.pcap
        ...                                     filters=tls.handshake.type == 11 and ip.src == ${mplane_add}
        ...                                     xml_name=${CURDIR}/rsa_${port}.xml
        ${rsa}=  analyze_xml  ${CURDIR}/rsa_${port}.xml
        Log  ${rsa}[1][showname]  console=true
        Should contain  ${rsa}[1][showname]  CB005999_test
        Configure CMP                           ca_subject_name=${RSA_SUBJECT_NAME}
        ...                                     server_type=ECDSA
        Initialize Certificates                 key_pool_type=ECDSA
        Change parameter on BTS                 MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
        ...                                     certTypeForTlsAuth
        ...                                     ECDSA
        Start Tcpdump
        RUN  openssl s_client -connect ${mplane_add}:${port} -tls1_2
        Stop Tcpdump And Download Pcap          tcpdump_filename=ecdsa_${port}.pcap
        Convert pcap to XML                     filename=${TEST_OUTPUT_DIR}/ecdsa_${port}.pcap
        ...                                     filters=tls.handshake.type == 11 and ip.src == ${mplane_add}
        ...                                     xml_name=${CURDIR}/ecdsa_${port}.xml
        ${ecdsa}=  analyze_xml  ${CURDIR}/ecdsa_${port}.xml
        Log  ${ecdsa}[1][showname]  console=true
        Should contain  ${ecdsa}[1][showname]  CB007672
    END
    [Teardown]                               TCPDump Teardown

CB008254_ECDSA_operator_certificate_based_authentication_with_BTS_as_Client_for_TLSv1.3_NMS_with_too_short_key
    Generate Binary File From HEX String    hex_string_file=${TOO_SHORT}
    ...                                     binary_file_name=${CURDIR}/too_short.p12
    Add EMSSIM User on VM
    Install Certificate On BTS              cert_file=${CURDIR}/too_short.p12
    ...                                     cert_type=BtsTrustChain
    ...                                     cert_format=P12
    ...                                     p12password=${P12_PASSWORD}
    ...                                     key_pool_type=ECDSA
    Configure TLS versions    1_2=true     cert_type=ECDSA
    Turn On TLS
    Copy certificates to Emssim             too_short
    Start Tcpdump
    ${emssim_connection}                    Run keyword and expect error  *"notConnected" != "secured"*  Connect and Activate EMSSIM    cert_type=none
    Stop TCPDump And Download PCAP          tcpdump_filename=too_short.pcap
    [Teardown]                              Run Keywords
    ...                                     Run keyword and ignore error   Stop TCPDump And Download PCAP   AND
    ...                                     Run keyword and ignore error   TCPDump Teardown   AND
    ...                                     Run keyword and ignore error  emssim.Disconnect From EMSSIM
    ...                                     connection=${emssim_connection}

CB008254_Full_Certificate_trust_chain_for_TLS_establishment
    Configure TLS versions    1_2=true     cert_type=ECDSA
    Turn On TLS
    Configure CMP                           ca_subject_name=${ECDSA_CROSS_SUBJECT_NAME}
    ...                                     server_type=ECDSA
    Initialize Certificates                 key_pool_type=ECDSA
    Sleep                                   60
    ...                                     reason=Wait for certificate inicialization
    FOR  ${port}  IN  @{PORTS}
        Start Tcpdump
        Sleep                                   20
        ...                                     reason=Wait for tcpdump to start
        RUN  openssl s_client -connect ${mplane_add}:${port} -tls1_2
        Sleep                                   30
        ...                                     reason=Wait for connection to close
        Stop Tcpdump And Download Pcap          tcpdump_filename=trust_chain_${port}.pcap
        Sleep                                   30
        ...                                     reason=Wait for pcap
        Convert pcap to XML                     filename=${TEST_OUTPUT_DIR}/trust_chain_${port}.pcap
        ...                                     filters=tls.handshake.type == 11 and ip.src == ${mplane_add}
        ...                                     xml_name=${CURDIR}/trust_chain_${port}.xml
        ${cert1}=  analyze_xml  ${CURDIR}/trust_chain_${port}.xml
        Log  ${cert1}[1][showname]  console=true
        ${issued_to}  CB008254.Get issuedTo Name From BTS Certificate
        Log  ${issued_to}  console=true
        Should contain  ${cert1}[0][showname]   ${issued_to}
        Should contain  ${cert1}[1][showname]   CB00599_cross_SUB
        Should contain  ${cert1}[2][showname]   CB00599_cross
    END
    [Teardown]                              TCPDump Teardown

CB008254_ECDSA_operator_certificate_based_authentication_with_BTS_as_Client_for_TLSv1.3_NMS_with_expired_certificate
    Generate Binary File From HEX String    hex_string_file=${EXPIRED}
    ...                                     binary_file_name=${CURDIR}/expired.p12
    Add EMSSIM User on VM
    Install Certificate On BTS              cert_file=${CURDIR}/expired.p12
    ...                                     cert_type=BtsTrustChain
    ...                                     cert_format=P12
    ...                                     p12password=${P12_PASSWORD}
    ...                                     key_pool_type=ECDSA
    Configure TLS versions    1_2=true     cert_type=ECDSA
    Turn On TLS
    Copy certificates to Emssim             expired
    Start Tcpdump
    ${emssim_connection}                    Run keyword and expect error  *"notConnected" != "secured"*  Connect and Activate EMSSIM    cert_type=none
    Stop TCPDump And Download PCAP          tcpdump_filename=expired.pcap
    Convert pcap to XML                     filename=${TEST_OUTPUT_DIR}/expired.pcap
    ...                                     filters=ip.addr==${VM_IP} && tls.record.content_type == 21
    ...                                     xml_name=${CURDIR}/expired.xml
    ${cert_list}=  check_if_cert_is_expired            xml_path=${CURDIR}/expired.xml
    Log  ${cert_list}  console=true
    Should contain  ${cert_list}[0][showname]  Unknown CA
    [Teardown]                              Run Keywords
    ...                                     TCPDump Teardown                     AND
    ...                                     Run keyword and ignore error  emssim.Disconnect From EMSSIM
    ...                                     connection=${emssim_connection}

CB008254_ECDSA_and_RSA_peer_operator_certificate_supported_configurations
    Configure TLS versions    1_2=true
    Turn On TLS
    Change parameter on BTS                 MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                     certTypeForTlsAuth
    ...                                     ECDSA
    Change parameter on BTS                 MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                     keyLength
    ...                                     256
    Configure CMP                           ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                                     server_type=ECDSA
    Initialize Certificates                 key_pool_type=ECDSA
    Change parameter on BTS                 MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                     ethernetPortSecurityEnabled
    ...                                     false
    ${issued_to}  ${cert_list}    ${cert_list1}             Get Certificate From PCAP  ecdsa_256
    Should contain  ${cert_list}  ${issued_to}
    Should contain  ${cert_list1}  CB005999_test
    Change parameter on BTS                 MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                     keyLength
    ...                                     384
    Initialize Certificates                 key_pool_type=ECDSA
    ${issued_to}  ${cert_list}    ${cert_list1}           Get Certificate From PCAP  ecdsa_384
    Should contain  ${cert_list}  ${issued_to}
    Should contain  ${cert_list1}  CB005999_test
    Generate Binary File From HEX String    hex_string_file=${ECDSA_521}
    ...                                     binary_file_name=${CURDIR}/ECDSA_521.p12
    Install Certificate On BTS              cert_file=${CURDIR}/ECDSA_521.p12
    ...                                     cert_type=BtsTrustChain
    ...                                     cert_format=P12
    ...                                     p12password=${P12_PASSWORD}
    ...                                     key_pool_type=ECDSA
    ${issued_to}  ${cert_list}   ${cert_list1}              Get Certificate From PCAP  ecdsa_521
    Log  ${issued_to}  console=true
    Log  ${cert_list}  console=true
    Log  ${cert_list1}  console=true
    Should contain  ${cert_list}  ${issued_to}
    Should contain  ${cert_list1}  EC521
    Clear Certificates
    Configure CMP                           ca_subject_name=${RSA_SUBJECT_NAME}
    ...                                     server_type=RSA
    Initialize Certificates                 key_pool_type=RSA
    Change parameter on BTS                 MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                     certTypeForTlsAuth
    ...                                     RSA
    ${issued_to}  ${cert_list}   ${cert_list1}           Get Certificate From PCAP  rsa
    Should contain  ${cert_list}  ${issued_to}
    Should contain  ${cert_list1}  CB007672
    [Teardown]                              TCPDump Teardown

CB008254_TLSv1.3_Cipher_suits_and_supported_groups
    Setup environment for EMSSIM            cert_type=ECDSA
    Configure TLS versions    1_3=true     cert_type=ECDSA
    Turn On TLS
    Start Tcpdump
    ${emssim_connection}                    Connect and Activate EMSSIM    cert_type=ECDSA
    Stop TCPDump And Download PCAP          tcpdump_filename=ciphers.pcap
    Convert pcap to XML                     filename=${TEST_OUTPUT_DIR}/ciphers.pcap
    ...                                     filters=tls.handshake.type==1 && ip.src==${mplane_add}
    ...                                     xml_name=${CURDIR}/ciphers.xml
    @{cert_list}=  find_ciphers             xml_path=${CURDIR}/ciphers.xml
    Log  ${cert_list}  console=true
    Check If Ciphersuits Are Stored         @{cert_list}   @{CIPHER_SUITES}
    @{supported_groups}=  find_supported_groups  xml_path=${CURDIR}/ciphers.xml
    ${length}=    Get Length    ${supported_groups}
    Log  ${length}  console=true
    Check If Supported Groups Are Stored   ${length}    @{supported_groups}
    emssim.Disconnect From EMSSIM           connection=${emssim_connection}
    Configure TLS versions    1_2=true     cert_type=ECDSA
    Turn On TLS
    Setup environment for EMSSIM            cert_type=ECDSA  tls_version=1_2
    Start Tcpdump
    ${emssim_connection}                    Connect and Activate EMSSIM    cert_type=ECDSA
    Stop TCPDump And Download PCAP          tcpdump_filename=ciphers1_2.pcap
    Convert pcap to XML                     filename=${TEST_OUTPUT_DIR}/ciphers1_2.pcap
    ...                                     filters=tls.handshake.type==1 && ip.src==${mplane_add}
    ...                                     xml_name=${CURDIR}/ciphers1_2.xml
    @{cert_list}=  find_ciphers             xml_path=${CURDIR}/ciphers1_2.xml
    Log  ${cert_list}  console=true
    Check If Ciphersuits Are Stored For TLS1_2   @{cert_list}
    @{supported_groups}=  find_supported_groups  xml_path=${CURDIR}/ciphers1_2.xml
    ${length}=    Get Length    ${supported_groups}
    Log  ${length}  console=true
    Check If Supported Groups Are Stored   ${length}    @{supported_groups}
    [Teardown]                              Run Keywords
    ...                                     TCPDump Teardown                     AND
    ...                                     Run keyword and ignore error  emssim.Disconnect From EMSSIM
    ...                                     connection=${emssim_connection}

CB008254_Differentiator_for_RSA_and_ECDSA_operations
    Generate Binary File From HEX String    hex_string_file=${P12_ECDSA}
    ...                                     binary_file_name=${CURDIR}/ECDSA.p12
    Generate Binary File From HEX String    hex_string_file=${P12_RSA}
    ...                                     binary_file_name=${CURDIR}/RSA.p12
    Install Certificate On BTS
    ...                                     cert_file=${CURDIR}/ECDSA.p12
    ...                                     cert_type=BtsTrustChain
    ...                                     cert_format=P12
    ...                                     p12password=${P12_PASSWORD}
    ...                                     key_pool_type=ECDSA
    ${value_ECDSA}=   Get keyPoolType And fingerPrint from BTS Certificate   'CN = CB005999_test'    fingerPrint
    Log  ${value_ECDSA}  console=true
    Log  ${fingerPrint_ECDSA}  console=true
    Should Be Equal  ${value_ECDSA}  ${fingerPrint_ECDSA}
    Install Certificate On BTS
    ...                                     cert_file=${CURDIR}/RSA.p12
    ...                                     cert_type=BtsTrustChain
    ...                                     cert_format=P12
    ...                                     p12password=${P12_PASSWORD}
    ...                                     key_pool_type=RSA
    ${value_RSA}=   Get keyPoolType And fingerPrint from BTS Certificate    'CN = CB007672'   fingerPrint
    Log  ${value_RSA}  console=true
    Log  ${fingerPrint_RSA}  console=true
    Should Be Equal  ${value_RSA}  ${fingerPrint_RSA}

CB008254_TLS_authentication
    Configure CMP                   ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                             server_type=ECDSA
    Initialize Certificates         key_pool_type=ECDSA
    Configure TLS versions    1_2=true     cert_type=ECDSA
    Turn On TLS
    FOR  ${port}  IN  @{PORTS}
        Start TCPDump
        RUN    openssl s_client -connect ${mplane_add}:${port} -tls1_2
        Stop TCPDump And Download PCAP          tcpdump_filename=tls_${port}.pcap
        PCAP Should Contain Message         tshark_filter=tls.handshake.type == '2' && ip.src == ${mplane_add}
        ...                                      pcap_file=${TEST_OUTPUT_DIR}/tls_${port}.pcap
        Convert pcap to XML                       filename=${TEST_OUTPUT_DIR}/tls_${port}.pcap
        ...                                       filters=tls.handshake.type == 2 and ip.src == ${mplane_add}
        ...                                       xml_name=${CURDIR}/tls_auth_pcap_${port}.xml
        ${cert}=  analyze xml  ${CURDIR}/tls_auth_pcap_${port}.xml
        ${cert1}=  cert from bts  ${cert}[1][showname]
        log  ${cert1}[0]  console=true
        Should contain  ${cert}[1][showname]  CB005999_test
        Should contain  ${cert}[1][showname]  ${cert1}[0]
    END
    Setup environment for EMSSIM       cert_type=ECDSA  tls_version=1_2
    Start TCPDump
    ${emssim_connection}               Connect and Activate EMSSIM    cert_type=ECDSA
    Stop TCPDump And Download PCAP     tcpdump_filename=emssim.pcap
    PCAP Should Contain Message             tshark_filter=tls.handshake.type == '2' && ip.src == ${mplane_add}
    ...                                     pcap_file=${TEST_OUTPUT_DIR}/emssim.pcap
    Convert pcap to XML                       filename=${TEST_OUTPUT_DIR}/emssim.pcap
    ...                                       filters=tls.handshake.type == 2 and ip.src == ${mplane_add}
    ...                                       xml_name=${CURDIR}/emssim_pcap.xml
    ${cert_emssim}=  analyze xml  ${CURDIR}/emssim_pcap.xml
    ${output}=  RUN  openssl x509 -in /opt/emssim/proxy/ssl/servercert.pem -text
    Should contain  ${cert_emssim}[1][showname]  CB005999_test
    [Teardown]                              Run Keywords
    ...                                     TCPDump Teardown                     AND
    ...                                     Run keyword and ignore error  emssim.Disconnect From EMSSIM
    ...                                     connection=${emssim_connection}

ECDSA_operator_certificate_usage_enabling_for_TLS_authentication
    Configure CMP                   ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                             server_type=ECDSA
    Initialize Certificates         key_pool_type=ECDSA
    Configure TLS versions    1_2=true
    Turn On TLS
    Setup environment for EMSSIM       cert_type=ECDSA   tls_version=1_2
    Start TCPDump
    ${emssim_connection}               Connect and Activate EMSSIM    cert_type=ECDSA
    Stop TCPDump And Download PCAP     tcpdump_filename=opercert_ecdsa.pcap
    PCAP Should Contain Message             tshark_filter=tls.handshake.type == '2' && ip.src == ${mplane_add}
    ...                                     pcap_file=${TEST_OUTPUT_DIR}/opercert_ecdsa.pcap
    Convert pcap to XML                       filename=${TEST_OUTPUT_DIR}/opercert_ecdsa.pcap
    ...                                       filters=tls.handshake.type == 2 and ip.src == ${mplane_add}
    ...                                       xml_name=${CURDIR}/opercert_ecdsa_1.xml
    ${cert}=  analyze xml operator   ${CURDIR}/opercert_ecdsa_1.xml
    Should contain  ${cert}[1][showname]  ecdsa
    emssim.Disconnect From EMSSIM      connection=${emssim_connection}
    Configure CMP                   ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                             server_type=RSA
    Initialize Certificates         key_pool_type=RSA
    Configure TLS versions    1_2=true
    Turn On TLS
    Setup environment for EMSSIM       cert_type=RSA   tls_version=1_2
    Start TCPDump
    ${emssim_connection}               Connect and Activate EMSSIM    cert_type=RSA
    Stop TCPDump And Download PCAP     tcpdump_filename=opercert_rsa.pcap
    PCAP Should Contain Message             tshark_filter=tls.handshake.type == '11' && ip.src == ${mplane_add}
    ...                                     pcap_file=${TEST_OUTPUT_DIR}/opercert_rsa.pcap
    Convert pcap to XML                       filename=${TEST_OUTPUT_DIR}/opercert_rsa.pcap
    ...                                       filters=tls.handshake.type == 11 and ip.src == ${mplane_add}
    ...                                       xml_name=${CURDIR}/opercert_rsa_1.xml
    ${cert1}=  analyze xml operator  ${CURDIR}/opercert_rsa_1.xml
    Should contain  ${cert1}[1][showname]  sha256WithRSAEncryption
    emssim.Disconnect From EMSSIM      connection=${emssim_connection}
    Configure TLS versions    1_2=true     cert_type=ECDSA
    Turn On TLS
    Setup environment for EMSSIM       cert_type=ECDSA   tls_version=1_2
    Start TCPDump
    ${emssim_connection}               Connect and Activate EMSSIM    cert_type=ECDSA
    Stop TCPDump And Download PCAP     tcpdump_filename=opercert_ecdsa1.pcap
    PCAP Should Contain Message             tshark_filter=tls.handshake.type == '2' && ip.src == ${mplane_add}
    ...                                     pcap_file=${TEST_OUTPUT_DIR}/opercert_ecdsa1.pcap
    Convert pcap to XML                       filename=${TEST_OUTPUT_DIR}/opercert_ecdsa1.pcap
    ...                                       filters=tls.handshake.type == 2 and ip.src == ${mplane_add}
    ...                                       xml_name=${CURDIR}/opercert_ecdsa_2.xml
    ${cert2}=  analyze xml operator   ${CURDIR}/opercert_ecdsa_2.xml
    Should contain  ${cert2}[1][showname]  ecdsa
    [Teardown]                              Run Keywords
    ...                                     TCPDump Teardown                     AND
    ...                                     Run keyword and ignore error  emssim.Disconnect From EMSSIM
    ...                                     connection=${emssim_connection}

CB008254_BTS_as_Server_use_ECDSA_certificate_for_TLS_when_NMS_has_RSA_certificate
    Configure CMP                   ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                             server_type=ECDSA
    Initialize Certificates         key_pool_type=ECDSA
    Configure TLS versions    1_2=true     cert_type=ECDSA
    Turn On TLS
    FOR  ${port}  IN  @{PORTS}
        Start TCPDump
        Sleep  20
        ${output}=  RUN    openssl s_client -connect ${mplane_add}:${port} -tls1_2 -cert ${RSA_SERVERCERT} -key ${RSA_PRIVKEY} -CAfile ${RSA_CACERT}
        Log  ${output}  console=true
        Sleep  20
        Stop TCPDump And Download PCAP            tcpdump_filename=bts_server_ecdsa_${port}.pcap
        Convert pcap to XML                       filename=${TEST_OUTPUT_DIR}/bts_server_ecdsa_${port}.pcap
        ...                                       filters=(tls.handshake.type == 11 or tls.handshake.type == 2) and ip.src == ${mplane_add}
        ...                                       xml_name=${CURDIR}/bts_server_ecdsa_${port}.xml
#        tls.Verify TLS Handshake In PCAP     pcap_file=${TEST_OUTPUT_DIR}/bts_server_ecdsa_${port}.pcap   tls_version=1_2
        ${cert_bts_served_ecdsa}=  analyze xml  ${CURDIR}/bts_server_ecdsa_${port}.xml
        log  ${cert_bts_served_ecdsa}[1][showname]  console=true
        Should contain  ${cert_bts_served_ecdsa}[1][showname]  CB005999_test
    END
    [Teardown]                              Run Keywords
    ...                                     TCPDump Teardown                     AND
    ...                                     Run keyword and ignore error  emssim.Disconnect From EMSSIM
    ...                                     connection=${emssim_connection}

CB008254_BTS_as_Server_use_RSA_certificate_for_TLS_when_NMS_has_ECDSA_certificate
    Configure CMP                   ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                             server_type=RSA

    Initialize Certificates         key_pool_type=RSA
    Change parameter on BTS         MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             certTypeForTlsAuth
    ...                             RSA
    Configure TLS versions    1_2=true
    Turn On TLS
    FOR  ${port}  IN  @{PORTS}
        Start TCPDump
        Sleep  20
        RUN    openssl s_client -connect ${MPLANE_IPV4}:${port} -tls1_2 -cert ${ECDSA_SERVERCERT} -key ${ECDSA_PRIVKEY} -CAfile ${ECDSA_CACERT}
        Sleep  20
        Stop TCPDump And Download PCAP          tcpdump_filename=bts_server_rsa_${port}.pcap
        Convert pcap to XML                       filename=${TEST_OUTPUT_DIR}/bts_server_rsa_${port}.pcap
        ...                                       filters=(tls.handshake.type == 11 or tls.handshake.type == 2) and ip.src == ${MPLANE_IPV4}
        ...                                       xml_name=${CURDIR}/bts_server_rsa_${port}.xml
#        tls.Verify TLS Handshake In PCAP     pcap_file=${TEST_OUTPUT_DIR}/bts_server_rsa_${port}.pcap   tls_version=1_2
        ${cert_bts_server_rsa}=  analyze xml  ${CURDIR}/bts_server_rsa_${port}.xml
        log  ${cert_bts_server_rsa}[1][showname]  console=true
        Should contain  ${cert_bts_server_rsa}[1][showname]  CB005999_test
    END
    [Teardown]                              Run Keywords
    ...                                     TCPDump Teardown                     AND
    ...                                     Run keyword and ignore error  emssim.Disconnect From EMSSIM
    ...                                     connection=${emssim_connection}

CB008254-SR-A-04_01_Verify_BTS_certificates_with_EC_signatures_between_BTS_and_syslog_server_for_TLS_authentication
    Configure CMP                   ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                             server_type=ECDSA
    Initialize Certificates         key_pool_type=ECDSA
    Configure TLS versions    1_2=true     cert_type=ECDSA
    Turn On TLS
    Add remoteSyslogConfig Structure To SCF    ${PARAMS}
    Wait Until Keyword Succeeds  30 min  60 sec  Start TCPDump
    Wait Until Keyword Succeeds  30 min  60 sec  Change Parameter on BTS  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                             actRemoteSyslogTransmission  true
    Stop TCPDump And Download PCAP     tcpdump_filename=boam_et_1_2.pcap
    Change parameter on BTS         MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                             actRemoteSyslogTransmission
    ...                             false
    Convert pcap to XML                     filename=${TEST_OUTPUT_DIR}/boam_et_1_2.pcap
    ...                                     filters=tls.handshake.type==1 && ip.src==${mplane_add}
    ...                                     xml_name=${CURDIR}/boam_et_1_2.xml
    @{cert_list1_2}=  find_ciphers             xml_path=${CURDIR}/boam_et_1_2.xml
    ${length}=    Get Length    ${cert_list1_2}
    Log  ${length}  console=true
    Check If Ciphersuits Are Stored For TLS1_2   @{cert_list1_2}
    @{supported_groups1_2}=  find_supported_groups  xml_path=${CURDIR}/boam_et_1_2.xml
    ${length}=    Get Length    ${supported_groups1_2}
    Log  ${length}  console=true
    Check If Supported Groups Are Stored   ${length}    @{supported_groups1_2}
    Configure TLS versions    1_3=true    cert_type=ECDSA
    Turn On TLS
    Wait Until Keyword Succeeds  30 min  60 sec  Start TCPDump
    Wait Until Keyword Succeeds  30 min  60 sec  Change Parameter on BTS  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                             actRemoteSyslogTransmission  true
    Stop TCPDump And Download PCAP     tcpdump_filename=boam_et_1_3.pcap
    Change parameter on BTS         MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                             actRemoteSyslogTransmission
    ...                             false
    Convert pcap to XML                     filename=${TEST_OUTPUT_DIR}/boam_et_1_3.pcap
    ...                                     filters=tls.handshake.type==1 && ip.src==${mplane_add}
    ...                                     xml_name=${CURDIR}/boam_et_1_3.xml
    @{cert_list1_3}=  find_ciphers             xml_path=${CURDIR}/boam_et_1_3.xml
    Log  ${cert_list1_3}  console=true
    Check If Ciphersuits Are Stored         @{cert_list1_3}
    [Teardown]                              Run keywords    TCPDump Teardown   AND
    ...               Change Parameter on BTS  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                             actRemoteSyslogTransmission  false

