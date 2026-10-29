*** Settings ***
Documentation   All KW for upgrade with secrurity test cases


Resource        ../../../common_resources/certificates/certificates.robot
Resource        ../../../common_resources/ipsec/ipsec.robot
Resource        ../../../common_resources/ip_traffic/ip_traffic.robot
Resource        ../../../common_resources/port_scanning/port_scanning.robot
Resource        ../../../common_resources/emssim/emssim_setup.robot
Resource        ../../../common_resources/emssim/emssim.robot
Resource        ../../../common_resources/pcap_analysis/pcap_analysis.robot
Resource        ../../../common_resources/alarms/alarm.robot
Resource        ../../../common_resources/tls/tls.robot
Resource        ../../../common_resources/gathering_logs/gathering_logs.robot
Resource        ../../../common_resources/variables/variables.robot

*** Variables ***

@{PLANES}    M-Plane    C-Plane    U-Plane
@{M-Plane_open}    22    443    8443
@{M-plane_closed}    20401
${NetAct_name}=    srnclab1015
${ECDSA_SUBJECT_NAME}       CN = CB005999_test
${ECDSA_SUBJECT_NAME_IPSEC}     CN = C=PL, O=Common, CN=IPSEC
${RSA_SUBJECT_NAME}         CN = CB007672
${RSA_SHORT_VALIDITY}       CN = 8154_short_validity
${ECDSA_CROSS_SUBJECT_NAME}    CN=CB00599_cross_SUB
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
@{PORTS}                    443  8443
${ECDSA_SUBJECT_NAME_WRONG}    CN = wrong_ecdsa
${RSA_SUBJECT_NAME_WRONG}    CN = wrong_rsa
@{NOT_TRUNK_BRANCHES}       SBTS25R3    SBTS25R2
${TMO2_SCF_PATH}    /home/ute/topology-configs/CLOUD_SRAN_TL281_TMO-2

*** Keywords ***
Check If Port 3600 Is In Expected State
    [Arguments]    ${expected_status}
    ${port_status}=    RUN    nmap -p 3600 ${MPLANE_IPV4}
    Log    The status for port 3600: ${port_status}    console=true
    Should contain    ${port_status}  ${expected_status}

Nmap
    ${result_tcp}    Run Scan    TCP    -sS    100    300    IPv4
    FOR    ${plane}    IN    @{PLANES}
        ${open_ports}    Get Ports From Output    ${result_tcp}    ${plane}    open_ports
        ${closed_ports}    Get Ports From Output    ${result_tcp}    ${plane}    closed_ports
        ${filtered_ports}    Get Ports From Output    ${result_tcp}    ${plane}    filtered_ports
        Run Keyword If    '${plane}'=='M-Plane'    Run Keywords
        ...    Lists Should Be Equal    ${open_ports}    ${M-Plane_open}    ignore_order=True    AND
        ...    Lists Should Be Equal    ${closed_ports}    ${M-Plane_closed}    AND
        ...    Should Be Empty    ${filtered_ports}
        ...    ELSE    Run Keywords
        ...    Should Be Empty    ${open_ports}    AND
        ...    Should Be Empty    ${closed_ports}    AND
        ...    Should Be Empty    ${filtered_ports}
    END
    ${result_stcp}    Run Scan    SCTP    -sY    100    300    IPv4
    FOR    ${plane}    IN    @{PLANES}
        ${open_ports}    Get Ports From Output    ${result_stcp}    ${plane}    open_ports
        ${closed_ports}    Get Ports From Output    ${result_stcp}    ${plane}    closed_ports
        ${filtered_ports}    Get Ports From Output    ${result_stcp}    ${plane}    filtered_ports
        Should Be Empty    ${open_ports}
        Should Be Empty    ${closed_ports}
        Should Be Empty    ${filtered_ports}
    END

Certificates
    Log    Step 1: Configure the CMP, CMPECDSA object    console=True
    Set Test Variable       ${TEST_OUTPUT_DIR}          ${OUTPUT_DIR}/${TEST_NAME}
    Clear Certificates
    Configure CMP                           ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                                     server_type=ECDSA
    Configure CMP                           ca_subject_name=${RSA_SUBJECT_NAME}
    ...                                     server_type=RSA
    Set CMP Server Settings                 key_pool_type=ECDSA
    Set CMP Server Settings                 key_pool_type=RSA
    Initialize Certificates                 key_pool_type=ECDSA
    Initialize Certificates                 key_pool_type=RSA
    Log    Step 2: Checking keyPoolType and certificate present on BTS    console=True
    ${keyPoolType_RSA}=    Get KeyPoolType From BTS Certificate    ${RSA_SUBJECT_NAME}
    Check If Certificate File Is Present On BTS    ${keyPoolType_RSA}
    ${keyPoolType_ECDSA}=    Get KeyPoolType From BTS Certificate    ${ECDSA_SUBJECT_NAME}
    Check If Certificate File Is Present On BTS    ${keyPoolType_ECDSA}
    Log    Step 3: Restore the certificates and delete values from CMP and CMPECDSA object    console=True
    Configure CMP                           ca_subject_name=${ECDSA_SUBJECT_NAME_WRONG}
    ...                                     server_type=ECDSA
    Configure CMP                           ca_subject_name=${RSA_SUBJECT_NAME_WRONG}
    ...                                     server_type=RSA
    Clear Certificates
    Log    Step 4: Manually install the expired ECDSA certificate on BTS    console=True
    Configure TLS versions    1_2=true    cert_type=ECDSA
    Run Keyword and Continue on Failure    Configure EMSSIM with Wrong Certificate    type_of_certificate=expired
    ...    type_of_message=Unknown CA
    Log    Step 5: Manually install the too short key ECDSA certificate on BTS    console=True
    Run Keyword and Continue on Failure    Configure EMSSIM with Wrong Certificate    type_of_certificate=too_short
    Log    Step 6: Upload short validity certificate and expect FID:61618    console=True
    Change Parameter on BTS       MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                           neCertificateUpdateTime  30
    Configure CMP                 ca_subject_name=${RSA_SHORT_VALIDITY}
    ...                           server_type=RSA
    Initialize Certificates       key_pool_type=RSA
    Wait Until Keyword Succeeds   10 min   60 sec
    ...                           Alarm Should be Active In BTS
    ...                           fault_id=61618
    Log    Step 7: Restore the certificates, remove the CN from CMP object and check alarms   console=True
    Clear Certificates
    Delete Parameter From BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                           param_name=caSubjectName
    Wait Until Keyword Succeeds   5 min   20 sec
    ...                           Alarm Should Not Be Active In BTS
    ...                           fault_id=61618
    Reset Site And Reconnect
    Wait Until Keyword Succeeds  10 min  30sec    Check if BTS in given state    state=OnAir
    Log    Step 9: Checking if M-Plane is pingable    console=True
    Change Parameter on BTS       MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1    icmpResponseEnabled  true
    Wait Until Keyword Succeeds      10m  30s   Check If BTS Is Pingable
    Log    Step 10: Sending flooding packages and expect onAir state    console=True
    Send TCP SYN Flood
    Wait Until Keyword Succeeds  10 min  30sec    Check if BTS in given state    state=OnAir
    Change Parameter on BTS       MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    actCli  true
    Log    Step 11: Checking the state of port 3600    console=True
    Check If Port 3600 Is In Expected State  open
    Change Parameter on BTS       MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1    icmpResponseEnabled  true
    Log    Step 12: Changing the icmpResponseEnabled parameter to true and check if is pingable    console=True
    ${command_ping}=          Run    ping -c 1 ${LMP_IP}
    Should Contain            ${command_ping}    0% packet loss
    Change Parameter on BTS       MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1    icmpResponseEnabled  true
    ${command_ping}=          Run    ping -c 1 ${MPLANE_IPV4}
    Should Contain            ${command_ping}    0% packet loss
    Log    Step 13: Resetting and expect the same behavior (pingable and onAir state)    console=True
    Reset Site And Reconnect
    Wait Until Keyword Succeeds  10 min  30sec    Check if BTS in given state    state=OnAir
    Log    Step 14: Check if 3600 port is still open and icmp responses enabled    console=True
    Check If Port 3600 Is In Expected State  open
    ${command_ping}=          Run    ping -c 1 ${LMP_IP}
    Should Contain            ${command_ping}    0% packet loss
    ${command_ping}=          Run    ping -c 1 ${MPLANE_IPV4}
    Should Contain            ${command_ping}    0% packet loss
    Log    Step 15: Set the actCli parameter to false and check the state of port 3600    console=True
    Change Parameter on BTS       MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    actCli  false
    Check If Port 3600 Is In Expected State  filtered
    Log    Step 16: Disable icmpResponseEnabled and expect diabled ping    console=True
    Change Parameter on BTS       MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1    icmpResponseEnabled  false
    ${command_ping}=    Run    ping -c 1 ${LMP_IP}
    Should Contain    ${command_ping}    0% packet loss
    ${command_ping}=    Run    ping -c 1 ${MPLANE_IPV4}
    Should Contain    ${command_ping}    100% packet loss
    Log    Step 17: Reset the BTS and check if ping is disabled and port 3600 is filtered    console=True
    Reset Site And Reconnect
    Wait Until Keyword Succeeds  10 min  30sec    Check if BTS in given state    state=OnAir
    Log    Step 18: Check if 3600 port is closed and icmp response disabled    console=True
    Check If Port 3600 Is In Expected State  filtered
    ${command_ping}=          Run    ping -c 1 ${LMP_IP}
    Should Contain            ${command_ping}    0% packet loss
    ${command_ping}=          Run    ping -c 1 ${MPLANE_IPV4}
    Should Contain            ${command_ping}    100% packet loss
    Clear Certificates
    Configure CMP                           ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                                     server_type=ECDSA
    Configure CMP                           ca_subject_name=${RSA_SUBJECT_NAME}
    ...                                     server_type=RSA
    Set CMP Server Settings                 key_pool_type=ECDSA
    Set CMP Server Settings                 key_pool_type=RSA
    Initialize Certificates                 key_pool_type=ECDSA
    Initialize Certificates                 key_pool_type=RSA

Send TCP SYN Flood
    [Documentation]    Test case to send TCP SYN flood using scapy
    ${python_path}=  Run  which python
    ${command}=    Catenate
    ...          'import scapy.all as scapy; scapy.sendpfast((scapy.Ether()
    ...           / scapy.IP(dst="${MPLANE_IPV4}")
    ...           / scapy.TCP(dport=443, flags="S")), pps=25000, iface="eth0", loop=1500000)'
    ${output}=      Run    sudo -E ${python_path} -c ${command}
    Log             ${output}

Configure EMSSIM with Wrong Certificate
    [Arguments]    ${type_of_certificate}    ${type_of_message}=${None}
    Generate and Install Wrong Certificate    type=ECDSA    name_of_cert=${type_of_certificate}
    Add EMSSIM User on VM
    Turn On TLS
    Copy certificates to Emssim             cert_type=${type_of_certificate}
    Start Tcpdump
    ${emssim_connection}                    Run keyword and expect error  *"notConnected" != "secured"*  Connect and Activate EMSSIM    cert_type=none
    Stop TCPDump And Download PCAP          tcpdump_filename=${type_of_certificate}.pcap
    Convert pcap to XML                     filename=${OUTPUT_DIR}/${TEST_NAME}/${type_of_certificate}.pcap
    ...                                     filters=ip.addr==${VM_IP} && tls.record.content_type == 21
    ...                                     xml_name=${OUTPUT_DIR}/${TEST_NAME}/${type_of_certificate}.xml
    Run Keyword If    '${type_of_certificate}'=='expired'
    ...               Check Alert Message From PCAP    ${OUTPUT_DIR}/${TEST_NAME}/${type_of_certificate}.xml    ${type_of_message}
    [Teardown]    Run Keywords
    ...           Clear Certificates    AND
    ...           Run Keyword and Ignore Error    TCPDump Teardown    AND
    ...           Run Keyword and Ignore Error    emssim.Disconnect From EMSSIM
    ...           connection=${emssim_connection}

Connecting with MantaRay
    Clear Certificates
    Start TCPDump
    ${NMS_LAB}      Integrate BTS to MantaRay with TLS
    Sleep    120    reason=Waiting for proper collecting the packets
    Stop TCPDump And Download PCAP          tcpdump_filename=mantaray.pcap
    [Teardown]    Run Keywords    Deintegrate BTS from MantaRay    LAB_NAME=${NMS_LAB}    AND
    ...                           Wait Until Keyword Succeeds   15 min   60 sec    Wait until BTS reach Configured or OnAir state

Permissions
    SSHLibrary.Open Connection                              host=${LMP_IP}
    SSHLibrary.Login         username=${SSH_USERNAME}      password=${SSH_PASSWORD}
    ${output}=               SSHLibrary.Execute Command     ls -l /etc/shadow
    Should Contain           ${output}                      ----------
    [Teardown]    SSHLibrary.Close Connection


IPSEC
    [Documentation]    Uploads IPSEC and configure CMP
    Set Test Variable       ${TEST_OUTPUT_DIR}          ${OUTPUT_DIR}/${TEST_NAME}
    RUN   bash -elc 'cd /home/ute; git clone git@gitlabe2.ext.net.nokia.com:uca/ran/topology-configs.git'
    Sleep   10min   reason=Wait until repo will be cloned
    Wait Until Keyword Succeeds  40x  30s  Check if BTS status is Configured or OnAir
    Clear Certificates
    RUN    mkdir ${TEST_OUTPUT_DIR}
    Download SCF    local_path=${TEST_OUTPUT_DIR}/SCF/
    Set CMP Server Settings
    Configure CMP    C=PL, O=Common, CN=IPSEC
    Initialize Certificates
    ${INSTALLED_SW_BRANCH}=    Get Software Release Name
    ${INSTALLED_SW_BRANCH}=    Set Variable If    "${INSTALLED_SW_BRANCH}" in ${NOT_TRUNK_BRANCHES}
    ...                        ${INSTALLED_SW_BRANCH}    SBTS00
    ${scf_path}=    Set Variable
    ...    ${TMO2_SCF_PATH}/${INSTALLED_SW_BRANCH}/MRBTS-50291_TL281_${INSTALLED_SW_BRANCH}_IPSEC.xml
    Commission SCF    scf_file=${scf_path}
    ${conn}=      Connect to ADMIN    sw_release=${INSTALLED_SW_BRANCH}
    Wait Until Keyword Succeeds  40x  30s  Check if BTS status is Configured or OnAir    ${conn}
    Disconnect from ADMIN    ${conn}
    ${ike_association}=    Checking IKE Association    sw_release=${INSTALLED_SW_BRANCH}
    Log    ${ike_association}    console=true

Checking IKE Association
    [Arguments]    ${sw_release}    ${policy_order_no}=5
    ${conn}=      Connect to ADMIN    sw_release=${sw_release}
    ${association}           coam_admin.get_ike_association    policy_order_number=${policy_order_no}    connection=${conn}
    ${association_status}    Get From Dictionary    ${association}[0][stateInfo]    proceduralState
    [Return]      ${association_status}
    [Teardown]    Disconnect from ADMIN    ${conn}

Checking IPSEC Connection
    ${INSTALLED_SW_BRANCH}=    Get Software Release Name
    ${INSTALLED_SW_BRANCH}=    Set Variable If    "${INSTALLED_SW_BRANCH}" in ${NOT_TRUNK_BRANCHES}
    ...                        ${INSTALLED_SW_BRANCH}    SBTS00
    ${ike_association}=    Checking IKE Association    sw_release=${INSTALLED_SW_BRANCH}
    Log    ${ike_association}    console=true

Logs Before Security UUF Test
    Run Keyword and Continue on Failure   Set Test Variable       ${TEST_OUTPUT_DIR}          ${OUTPUT_DIR}/${TEST_NAME}
    Run Keyword and Continue on Failure   Start Watchdog
    Run Keyword and Continue on Failure   gathering_logs._Setup Syslog

Logs After Security UUF Test
    [Arguments]    ${test_name}    ${syslog_path}
    Run Keyword and Continue on Failure   Check if Disallowed Alarm was Detected during Watchdog
    Run Keyword and Continue on Failure   Stop Watchdog
    Run Keyword and Continue on Failure   No Faults Except Allowed Should Be Present On BTS
    Run Keyword and Continue on Failure   gathering_logs._Collect Snapshot File   log_dir=${OUTPUT_DIR}/${TEST_NAME}/${test_name}.zip
    Run Keyword and Continue on Failure   gathering_logs._Collect Syslog Files    log_dir=${syslog_path}
