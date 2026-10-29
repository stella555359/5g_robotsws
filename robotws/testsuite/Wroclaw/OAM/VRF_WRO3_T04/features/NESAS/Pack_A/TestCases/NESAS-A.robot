*** Settings ***
Documentation
...  author:  Patryk Tatarek
...  contact: patryk.tatarek@nokia.com

Resource    ../../../../common_resources/admin/admin.robot
Resource    ../../../../common_resources/connections/connections.robot
Resource    ../../../../common_resources/commissioning/parameters.robot
Resource    ../../../../common_resources/certificates/certificates.robot
Resource    ../../../../common_resources/applications_running_with_root/common_keywords.robot
Resource    ../../../../common_resources/ip_traffic/ip_traffic.robot
Resource    ../../../../common_resources/pcap_analysis/pcap_analysis.robot
Resource    ../../../../common_resources/tls/tls.robot
Resource    ../../../../common_resources/netact/netact_operations.robot
Resource    ../Resources/NESAS-A_resources.robot
Library     taf.sbts.oam.coam.admin    WITH NAME    admin
Library     SSHLibrary

*** Variables ***
${python_path_testpc}=    /usr/bin/python
${TEST_PC_IP}=            10.44.69.202
${TEST_PC_USER}=          kali
${TEST_PC_PASS}=          kalindrome@024
*** Keywords ***

Unencrypted_Private_Keys_Check_Bin
    Log    Step 1: Connect to BTS    console=true
    ${conn}=               Connect to BTS
    ssh.execute            command=cd /bin    connection=${conn}
    Sleep    5s
    Log    Step 2: Search for binary files using the following command    console=true
    ${bin_files}=          ssh.execute    command=find . -type f -exec grep -IL . "{}" \\;
    ...                                   connection=${conn}    timeout=30s
    Sleep    5s
    ssh.execute            command=cd /sbin    connection=${conn}
    Sleep    5s
    ${sbin_files}=         ssh.execute    command=find . -type f -exec grep -IL . "{}" \\;
    ...                                   connection=${conn}    timeout=30s
    @{bin_paths_list}=     prepare list from console    ${bin_files}
    @{sbin_paths_list}=    prepare list from console    ${sbin_files}
    Log    Step 3: Search for unecrypted private keys in binary files in bin and sbin    console=true
    FOR  ${bin}  IN  @{bin_paths_list}
       EXIT FOR LOOP IF    '''${bin}'''=='''${EMPTY}'''
       ${bin_output}=      ssh.execute    command=cat ${bin}    connection=${conn}
       Run Keyword if      '''${bin_output}'''!='''${EMPTY}'''    Should Contain Any
       ...                 ${bin_output}    -----BEGIN    No such file
    END
    FOR  ${sbin}  IN  @{sbin_paths_list}
       EXIT FOR LOOP IF    '''${sbin}'''=='''${EMPTY}'''
       ${sbin_output}=     ssh.execute    command=cat ${sbin}    connection=${conn}
       Run Keyword if      '''${sbin_output}'''!='''${EMPTY}'''    Should Contain Any
       ...                 ${sbin_output}    -----BEGIN    No such file
    END
    [Teardown]             Run Keyword And Ignore Error    Disconnect from BTS    ${conn}

Crypto_Agent_Initialization_To_Protect_Private_Keys_And_Secure_Storage_Of_The_Files
    Log    Step 1: Connect to BTS    console=true
    ${conn}=                Connect to BTS
    Log    Step 2: Check if private key exists and if it is encrypted    console=true
    ${certificate_priv}=    ssh.execute    command=cat ${crypto_agent_priv}    connection=${conn}    timeout=10s
    Should not contain      ${certificate_priv}    No such file or directory
    Should contain          ${certificate_priv}    BEGIN ENCRYPTED PRIVATE KEY
    Log    Step 3: Check if public key exists    console=true
    ${certificate_pub}=     ssh.execute    command=cat ${crypto_agent_pub}    connection=${conn}    timeout=10s
    Should not contain      ${certificate_pub}    No such file or directory
    Log    Step 4: Check if file storage is secured
    ${output}=        ssh.execute    command=mount | grep encfs    connection=${conn}    timeout=10s
    Should Contain    ${output}    trs_data/active/keystorage type fuse.encfs
    ...                            (rw,nosuid,nodev,relatime,user_id=0,group_id=0,default_permissions,allow_other)
    [Teardown]              Run Keyword And Ignore Error    Disconnect from BTS    ${conn}


Crypto_Agent_Secure_Storage_Of_The_Keys_Vendor_Certificate
    Log    Step 1: Connect to BTS    console=true
    ${conn}=             Connect to BTS
    Log    Step 2: Check if vendor cert is signed with sha256 algorithm by correct issuer   console=true
    ${certificate}=      ssh.execute    command=openssl x509 -text -in ${public_vendor_key}
    ...                                 connection=${conn}    timeout=10s
    Should Match Regexp   ${certificate}    Issuer: O = Nokia( Siemens Networks)?, CN = Factory Certification Authority
    Should contain       ${certificate}    Signature Algorithm: sha256WithRSAEncryption
    Log    Step 3: Check if signing of works correctly    console=true
    ${output_before}=    ssh.execute    command=ls -la /ffs/run | grep swconfig.txt.p7
    ...                                 connection=${conn}    timeout=10s
    ssh.execute          command=crasign /ffs/run/swconfig.txt    connection=${conn}
    ${output_after}=     ssh.execute    command=ls -la /ffs/run/ | grep swconfig.txt.p7
    ...                                 connection=${conn}    timeout=10s
    Should Contain       ${output_after}    swconfig.txt.p7
    Should Not be Equal  ${output_before}    ${output_after}
    ${output}=           ssh.execute    command=craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    ...                                 connection=${conn}    timeout=10s
    Should Contain       ${output}      good signature
    ssh.Download File       ${public_vendor_key}    ${vendor_basic_cert_local_path}    connection=${conn}
    ${certificate_name}=    ssh.execute
    ...                     command=openssl pkcs7 -inform DER -print_certs -in /ffs/run/swconfig.txt.p7 > ${swconfig_cert}
    ...                     connection=${conn}    timeout=10s
    ssh.Download File       ${swconfig_cert}    ${swconfig_basic_cert_local_path}    connection=${conn}
    ${vendor_basic_cert_dict}=            decode_cert    ${vendor_basic_cert_local_path}
    ${swconfig_basic_cert_dict}=          decode_cert    ${swconfig_basic_cert_local_path}
    compare_certs           ${vendor_basic_cert_dict}     ${swconfig_basic_cert_dict}
    compare_x509_fields     ${vendor_basic_cert_local_path}    ${swconfig_basic_cert_local_path}
    ${certificate}=         ssh.execute    command=openssl x509 -text -in /ffs/run/pkcs7_cert.pem
    ...                                    connection=${conn}    timeout=10s
    Should contain          ${certificate}    Signature Algorithm: sha256WithRSAEncryption
    [Teardown]              Run Keyword And Ignore Error    Disconnect from BTS    ${conn}

Default_Users_Pass_Check_Unprotected_Files
    Log    Step 1: Connect to BTS    console=true
    ${conn}=    Connect to BTS
    Log    Step 2: Verify if each default passwords is not stored in plain text
    Verify if each default passwords is not stored in plain text on BTS in json files
    Verify if each default passwords is not stored in plain text on BTS in txt files
    Verify if each default passwords is not stored in plain text on BTS in log files
    Verify if each default passwords is not stored in plain text in /var/log directory
    Verify if each default passwords is not stored in plain text in binary /opt/SysAdapter/SysAdapter file
    Verify if each default passwords is not stored in plain text in binary /opt/BTSOM/BTSOMexe file
    Verify if each default passwords is not stored in plain text in popular system files
    [Teardown]    Run Keyword And Ignore Error    Disconnect from BTS    ${conn}

Echo_Reply_Send_Check_ICMP_IPv4
    Log    Step 0: Get IP adresses    console=true
    ${fronthaul_ip}=    Get Fronthaul IP address
    ${ip_addresses}=    Create List       ${fronthaul_ip}   ${MPLANE_IPV4}    ${LMP_IP}
    Log    Step 1: Connect to BTS    console=true
    ${conn}=                   Connect to ADMIN
    Log    Step 2: Set icmpResponseEnabled to true    console=true
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                        param_name=icmpResponseEnabled
    ...                        param_value=true
    ...                        connection=${conn}
    Log    Step 3: Send ping to fronthaul/backhaul/LMP ip address and check if packets are accepted    console=true
    FOR    ${ip}    IN    @{ip_addresses}
        ${command_true}=           Run    ping -c 1 ${ip}
        Sleep                      5
        Should Contain             ${command_true}    0% packet loss
    END
    Log    Step 4: Set icmpResponseEnabled to false    console=true
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                        param_name=icmpResponseEnabled
    ...                        param_value=false
    ...                        connection=${conn}
    Log    Step 5: Send ping to fronthaul/backhaul/LMP ip address and check if packets are rejected    console=true
    FOR    ${ip}    IN    @{ip_addresses}
        ${command_false}=          Run    ping -c 1 ${ip}
        Sleep                      5
        Run Keyword If    '${ip}'=='${LMP_IP}'
        ...               Should Contain              ${command_false}     0% packet loss
        Run Keyword If    '${ip}'!='${LMP_IP}'
        ...                Should Contain             ${command_false}    100% packet loss
    END
    [Teardown]                 Run Keyword And Ignore Error    Disconnect from ADMIN    ${conn}


Echo_Reply_Send_Check_ICMP_IPv6
    Log    Step 1: Connect to BTS    console=true
    ${conn}=                   Connect to ADMIN
    Log    Step 2: Set icmpResponseEnabled to true    console=true
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                        param_name=icmpResponseEnabled
    ...                        param_value=true
    ...                        connection=${conn}
    Log    Step 3: Send ping to IPv6 ip address and check if packets are accepted    console=true
    ${command_true}=           Run    ping -c 1 ${MPLANE_IPV6}
    Sleep                      5
    Should Contain             ${command_true}    0% packet loss
        Log    Step 4: Set icmpResponseEnabled to true    console=true
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                        param_name=icmpResponseEnabled
    ...                        param_value=false
    ...                        connection=${conn}
    Log    Step 5: Send ping to IPv6 ip address and check if packets are rejected    console=true
    ${command_true}=           Run    ping -c 1 ${MPLANE_IPV6}
    Sleep                      5
    Should Contain             ${command_true}    100% packet loss
    [Teardown]                 Run Keyword And Ignore Error    Disconnect from ADMIN    ${conn}


Unencrypted_Password_New_User
    Log     Step 1:Connect to BTS     console=true
    ${conn}=      Connect to BTS
    Log     Step 2: Check if /etc/shadow contains unecrypted password    console=true
    ${shadow}=    ssh.execute    command=cat /etc/shadow    connection=${conn}    timeout=10s
    Should Not Contain    ${shadow}    ${new_ssh_username}
    Log     Step 3: Create new user    console=true
    ${username}=    ssh.execute    command=useradd ${new_ssh_username}    connection=${conn}    timeout=10s
    ${password}=    ssh.execute    command=echo -e "${new_ssh_password}\n${new_ssh_password}\n" | passwd ${new_ssh_username}
    ...                            connection=${conn}    timeout=10s
    Log     Step 3: Check if /etc/shadow and other directories contain unecrypted password    console=true
    ${shadow2}=     ssh.execute    command=cat /etc/shadow    connection=${conn}    timeout=10s
    Should Contain        ${shadow2}    ${new_ssh_username}
    Should Not Contain    ${shadow2}    ${new_ssh_password}
    ${shadow3}=     ssh.execute    command=cat /ffs/run/etc/p_shadow    connection=${conn}    timeout=10s
    Should Not Contain    ${shadow3}    ${new_ssh_password}
    ${opasswd}=     ssh.execute    command=cat /etc/security/opasswd    connection=${conn}    timeout=10s
    Should Not Contain    ${opasswd}    ${new_ssh_password}
    ${opasswd2}=    ssh.execute    command=cat /ffs/run/etc/security/opasswd    connection=${conn}    timeout=10s
    Should Not Contain    ${opasswd2}    ${new_ssh_password}
    ${passwd}=      ssh.execute    command=cat /etc/passwd    connection=${conn}    timeout=10s
    Should Not Contain    ${passwd}    ${new_ssh_password}
    Log     Step 4: Delate user and check if the action was succesful    console=true
    ssh.execute  command=userdel ${new_ssh_username}    connection=${conn}    timeout=10s
    ${shadow_after_delete}=    ssh.execute    command=cat /etc/shadow    connection=${conn}    timeout=10s
    Should Not Contain    ${shadow_after_delete}    ${new_ssh_username}
    [Teardown]            Run Keyword And Ignore Error    Disconnect from BTS    ${conn}

Unencrypted_Password_wsuser
    Log     Step 1: Connect to BTS     console=true
    ${conn}=      Connect to BTS
    Log     Step 2: Verify if password is not stored in plain text     console=true
    Verify if ${wsuser_password} password is not stored in plain text in binary /opt/NE3SADAPT/NE3SADAPT file
    ssh.Upload File        ${local_path_script}    ${remote_path_script}    connection=${conn}
    ${output}=             ssh.execute    command=python3 ${remote_path_script}    connection=${conn}    timeout=10s
    Should Contain         ${output}    Query WSUSER passwd from SQLite DB
    Should Not Contain     ${output}    ${wsuser_password}
    Log     Step 3: Change password for wsuser    console=true
    Change password for wsuser    old_password=${WSUSER_PASS}    new_password=${NEW_PASSWORD}
    Log     Step 4: Verify if new password is not stored in plain text  console=true
    ${output_new}=         ssh.execute    command=python3 ${remote_path_script}    connection=${conn}    timeout=10s
    Should Contain         ${output_new}    Query WSUSER passwd from SQLite DB
    Should Not Contain     ${output_new}    ${wsuser_new_password}
    [Teardown]             Run Keywords    Change password for wsuser
    ...                                    old_password=${NEW_PASSWORD}    new_password=${WSUSER_PASS}
    ...    AND             Run Keyword And Ignore Error    Disconnect from BTS    ${conn}

Unencrypted_Private_Keys_Check
    ${conn}=         Connect to BTS
    ${pem_files}=    ssh.execute    command=find / -name *.pem | grep -v cert   connection=${conn}    timeout=10s
    @{certifiactes_paths_list}=     prepare list from console    ${pem_files}
    FOR  ${cert}  IN  @{certifiactes_paths_list}
       EXIT FOR LOOP IF    '''${cert}'''=='''${EMPTY}'''
       ${cert_output}=     ssh.execute    command=cat ${cert}    connection=${conn}
       Run Keyword if      '''${cert_output}'''!='''${EMPTY}'''    Should Contain Any
       ...                 ${cert_output}    -----BEGIN    No such file
    END
    ${ls1}=       ssh.execute    command=find /etc/keys.d/board/privkey.pem -printf "%f:%p:%u:%g:%m\n"
    ...                          connection=${conn}    timeout=10s
    Run Keyword and Continue on Failure    Should End With              ${ls1}    0\r\n
    ${ls2}=       ssh.execute    command=find /ffs/run/config/ne3sadapt/certs/ne.key.pem -printf "%f:%p:%u:%g:%m\n"
    ...                          connection=${conn}    timeout=10s
    Run Keyword and Continue on Failure    Should End With              ${ls2}    0\r\n
    Configure CMP    ca_subject_name=${ca_subject_name}
    Initialize Certificates
    FOR    ${i}    IN RANGE    1000
         ${PING}=    Run    ping -c 2 192.168.255.119
         ${Exit}=    Run Keyword And Return Status    Should Contain    ${PING}    100% packet loss
         Exit For Loop If    ${Exit}==True
    END
    Wait until keyword succeeds    15 min  60sec  Check if BTS status is Configured or OnAir
    ${ls3}=       ssh.execute    command=find /rom/trs_data/active/keystorage/certs/cert.pem -printf "%f:%p:%u:%g:%m\n"
    ...                          connection=${conn}    timeout=10s
    Run Keyword and Continue on Failure    Should Contain    ${ls3}    cert.pem:btssw:btssw:640
    [Teardown]                   Run Keyword And Ignore Error    Disconnect from BTS    ${conn}

IPv4_packet_with_and_without_IP_options
    Log    Step 0: Get IP adresses and python path    console=true
    ${python_path}=     Run    which python
    ${fronthaul_ip}=    Get Fronthaul IP address
    ${ip_addresses}=    Create List       ${fronthaul_ip}   ${MPLANE_IPV4}
    Log    Step 1: Connect to BTS    console=true
    ${conn}=                   Connect to ADMIN
    Log    Step 2: Set ethernetPortSecurityEnabled to true    console=true
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                        param_name=ethernetPortSecurityEnabled
    ...                        param_value=false
    ...                        connection=${conn}
    Log    Step 3a: Send packets using scapy from VM to LMP address   console=true
    ${command1}=    Catenate    'import scapy.all as scapy; x,y = scapy.sr(scapy.IP(dst="${LMP_IP}"
        ...                      ,options = scapy.IPOption(option = "timestamp"))
        ...                      /scapy.TCP(dport=22, flags="S")
        ...                      /"with IP options", timeout=2); print(x); print(y)'
    ${command2}=    Catenate    'import scapy.all as scapy; x,y = scapy.sr(scapy.IP(dst="${LMP_IP}")
        ...                      /scapy.TCP(dport=22, flags="S"),
        ...                      timeout=2); print(x); print(y)'
    ${output}=      Run          sudo -E ${python_path} -c ${command1}
    Should Contain  ${output}    Results: TCP:0
    ${output}=      Run          sudo -E ${python_path} -c ${command2}
    Should Contain  ${output}    Results: TCP:1
    SSHLibrary.Open Connection   host=${TEST_PC_IP}
    SSHLibrary.Login             username=${TEST_PC_USER}       password=${TEST_PC_PASS}
    SSHLibrary.Write             sudo su
    SSHLibrary.Write             ${TEST_PC_PASS}
    Log     Step 3b: Send packets using scapy from test PC to mplane and fronthaul addresses    console=true
    FOR    ${ip}    IN    @{ip_addresses}
        ${command1}=    Catenate    'import scapy.all as scapy; x,y = scapy.sr(scapy.IP(dst="${ip}"
        ...                         ,options = scapy.IPOption(option = "timestamp"))
        ...                         /scapy.TCP(dport=22, flags="S")
        ...                         /"with IP options", timeout=2); print(x); print(y)'
        ${command2}=    Catenate    'import scapy.all as scapy; x,y = scapy.sr(scapy.IP(dst="${ip}")
        ...                         /scapy.TCP(dport=22, flags="S"),
        ...                         timeout=2); print(x); print(y)'
        SSHLibrary.Write    sudo -E ${python_path_testpc} -c ${command1}
        Sleep    20
        ${output}=    SSHLibrary.Read
        Should Contain  ${output}    Results: TCP:0
        SSHLibrary.Write    sudo -E ${python_path_testpc} -c ${command2}
        Sleep    20
        ${output}=    SSHLibrary.Read
        Run Keyword If      '${ip}'=='${MPLANE_IPV4}'
        ...                  Should Contain    ${output}    Results: TCP:1
        Run Keyword If      '${ip}'=='${fronthaul_ip}'
        ...                  Should Contain    ${output}    Unanswered: TCP:1
    END
    [Teardown]    Run Keywords    Change Parameter on BTS
    ...                           dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                           param_name=ethernetPortSecurityEnabled
    ...                           param_value=false
    ...                           connection=${conn}
    ...           AND             Disconnect from ADMIN    ${conn}
    ...           AND             SSHLibrary.Close Connection

IPv6_packet_with_and_without_extension_header_Mplane
    Log    Step 1: Connect to BTS    console=true
    ${conn}=    Connect to ADMIN
    Log    Step 2: Set ethernetPortSecurityEnabled to true   console=true
    Change Parameter on BTS       dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                           param_name=ethernetPortSecurityEnabled
    ...                           param_value=true
    ...                           connection=${conn}
    Log    Step 3: Send packets with extension header using scapy    console=true
    SSHLibrary.Open Connection    host=${TEST_PC_IP}
    SSHLibrary.Login              username=${TEST_PC_USER}       password=${TEST_PC_PASS}
    SSHLibrary.Write              sudo su
    SSHLibrary.Write              ${TEST_PC_PASS}
    ${command1}=    Catenate     'import scapy.all as scapy;
    ...                          x,y = scapy.sr(scapy.IPv6(dst="${MPLANE_IPV6}")
    ...                          /scapy.IPv6ExtHdrDestOpt()/scapy.TCP(dport=22, flags="S")
    ...                          /"with extension header", timeout=5); print(x); print(y)'
    Start Tcpdump
    SSHLibrary.Write             sudo -E ${python_path_testpc} -c ${command1}
    Sleep    20
    ${pcap_path1}=                Stop Tcpdump And Download Pcap    tcpdump_filename=with.pcap
    ${filter1}=                   Catenate    (ipv6.src == ${MPLANE_IPV6}) &&
     ...                          (_ws.col.info == "Parameter Problem (unrecognized Next Header type encountered)")

    PCAP Should Contain Message
    ...                           ${filter1}
    ...                           ${pcap_path1}
    ${Scapy_output1}=            SSHLibrary.Read
    Should Contain               ${Scapy_output1}    Results: TCP:1
    Log    Step 4: Set ethernetPortSecurityEnabled to false   console=true
    Change Parameter on BTS      dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                          param_name=ethernetPortSecurityEnabled
    ...                          param_value=false
    ...                          connection=${conn}
    Log    Step 5: Send packets without extension header using scapy    console=true
    ${command2}=    Catenate    'import scapy.all as scapy; x,y = scapy.sr(scapy.IPv6(dst="${MPLANE_IPV6}")
    ...                         /scapy.TCP(dport=22, flags="S")
    ...                         /"without extension header", timeout=5); print(x); print(y)'
    Start Tcpdump
    SSHLibrary.Write            sudo -E ${python_path_testpc} -c ${command2}
    Sleep    20
    ${pcap_path2}=               Stop Tcpdump And Download Pcap    tcpdump_filename=without.pcap
    ${Scapy_output2}=            SSHLibrary.Read
    ${filter2}=                  Catenate    ipv6.src == ${MPLANE_IPV6}
    ...                          && _ws.col.info == "22 → 20 [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=1440"
    PCAP Should Contain Message
    ...                           ${filter2}
    ...                           ${pcap_path2}
    Should Contain      ${Scapy_output2}    Results: TCP:1

    [Teardown]    Run Keywords    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                           param_name=ethernetPortSecurityEnabled
    ...                           param_value=false
    ...                           connection=${conn}
    ...           AND             TCPDump Teardown
    ...           AND             Run Keyword and Ignore Error    Disconnect from ADMIN    ${conn}
    ...           AND             SSHLibrary.Close Connection

Process_check_ICMP_IPv4
    Log    Step 0: Get IP adresses and python path   console=true
    ${python_path}=     Run    which python
    ${fronthaul_ip}=    Get Fronthaul IP address
    ${ip_addresses}=    Create List       ${fronthaul_ip}   ${MPLANE_IPV4}    ${LMP_IP}
    Log    Step 1: Check IP route    console=true
    ${bts_ssh}=    Connect to BTS
    ${output}=     ssh.execute    command=ip route show   connection=${bts_ssh}  timeout=10s
    Disconnect from BTS    ${bts_ssh}
    Log    Step 2: Connect to BTS    console=true
    ${conn}=      Connect to ADMIN
    Log    Step 3: Set icmpResponseEnabled to true    console=true
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                        param_name=icmpResponseEnabled
    ...                        param_value=true
    ...                        connection=${conn}
    Log    Step 4: Send packets using scapy and compare ip routes    console=true
    ${command}=     Catenate    'import scapy.all as scapy; x,y = scapy.sr(scapy.IP(dst="${LMP_IP}")
    ...                         /scapy.ICMP(type=5, code=1, gw="11.80.154.80")
    ...                         /scapy.IP(dst="11.80.154.90"), timeout=2); print(x); print(y)'
    ${Scapy_output}=            Run    sudo -E ${python_path} -c ${command}
    Should Contain     ${Scapy_output}    <Unanswered: TCP:0 UDP:0 ICMP:1 Other:0>
    Sleep  15s
    ${bts_ssh}=    Connect to BTS
    ${output_new}=     ssh.execute    command=ip route show   connection=${bts_ssh}  timeout=10s
    Disconnect from BTS    ${bts_ssh}
    Should Be Equal    ${output}    ${output_new}
    ${output2b}=        Run    sudo nping --icmp --icmp-type 14 ${LMP_IP} -c 1
    Should Contain    ${output2b}    Rcvd: 0 (0B) | Lost: 1 (100.00%)
    SSHLibrary.Open Connection   host=${TEST_PC_IP}
    SSHLibrary.Login             username=${TEST_PC_USER}       password=${TEST_PC_PASS}
    SSHLibrary.Write             sudo su
    SSHLibrary.Write             ${TEST_PC_PASS}
    FOR    ${ip}    IN    @{ip_addresses}
        ${command}=     Catenate    'import scapy.all as scapy; x,y = scapy.sr(scapy.IP(dst="${ip}")
        ...                         /scapy.ICMP(type=5, code=1, gw="11.80.154.80")
        ...                         /scapy.IP(dst="11.80.154.90"), timeout=2); print(x); print(y)'
        SSHLibrary.Write            sudo -E ${python_path_testpc} -c ${command}
        Sleep                       20
        ${Scapy_output}=            SSHLibrary.Read
        Should Contain     ${Scapy_output}    <Unanswered: TCP:0 UDP:0 ICMP:1 Other:0>
        Sleep  15s

        ${bts_ssh}=    Connect to BTS
        ${output_new}=     ssh.execute    command=ip route show   connection=${bts_ssh}  timeout=10s
        Disconnect from BTS    ${bts_ssh}
        Should Be Equal    ${output}    ${output_new}
        ${output2b}=     Run    sudo nping --icmp --icmp-type 14 ${ip} -c 1
        Should Contain    ${output2b}    Rcvd: 0 (0B) | Lost: 1 (100.00%)
     END
    [Teardown]         Run Keyword And Ignore Error    Disconnect from ADMIN    ${conn}

Process_check_ICMP_IPv6
    Log    Step 1: Check IP route    console=true
    ${bts_ssh}=    Connect to BTS
    ${output}=     ssh.execute    command=ip route show   connection=${bts_ssh}  timeout=10s
    Disconnect from BTS    ${bts_ssh}
    Log    Step 2: Connect to BTS    console=true
    ${conn}=      Connect to ADMIN
    Log    Step 3: Set icmpResponseEnabled and icmpv6RouterMessageResponseEnabled to true    console=true
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                        param_name=icmpResponseEnabled
    ...                        param_value=true
    ...                        connection=${conn}
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                        param_name=icmpv6RouterMessageResponseEnabled
    ...                        param_value=true
    ...                        connection=${conn}
    Log    Step 4: Send redirect packets using scapy and compare ip routes    console=true
    SSHLibrary.Open Connection   host=${TEST_PC_IP}
    SSHLibrary.Login             username=${TEST_PC_USER}       password=${TEST_PC_PASS}
    SSHLibrary.Write             sudo su
    SSHLibrary.Write             ${TEST_PC_PASS}
    ${command1}=    Catenate    'import scapy.all as scapy;
    ...                         x,y = scapy.sr(scapy.IPv6(dst="${MPLANE_IPV6}")
    ...                         /scapy.ICMPv6ND_Redirect(tgt="::2", dst="::3"), timeout=5); print(x); print(y)'
    SSHLibrary.Write            sudo -E ${python_path_testpc} -c ${command1}
    Sleep    20
    ${Scapy_output1}=            SSHLibrary.Read
    Should Contain      ${Scapy_output1}    Unanswered: TCP:0 UDP:0 ICMP:0 Other:1
    ${bts_ssh}=    Connect to BTS
    ${output1}=     ssh.execute    command=ip route show   connection=${bts_ssh}  timeout=10s
    Disconnect from BTS    ${bts_ssh}
    Should Be Equal    ${output}    ${output1}
    Log    Step 5: Send router solicitation packets using scapy and compare ip routes    console=true
    ${command2}=    Catenate    'import scapy.all as scapy;
    ...                          x,y = scapy.sr(scapy.IPv6(dst="${MPLANE_IPV6}")
    ...                         /scapy.ICMPv6ND_RS(), timeout=5); print(x); print(y)'
    SSHLibrary.Write    sudo -E ${python_path_testpc} -c ${command2}
    Sleep    20
    ${Scapy_output2}=    SSHLibrary.Read
    Should Contain      ${Scapy_output2}    Unanswered: TCP:0 UDP:0 ICMP:0 Other:1
    ${bts_ssh}=    Connect to BTS
    ${output2}=     ssh.execute    command=ip route show   connection=${bts_ssh}  timeout=10s
    Disconnect from BTS    ${bts_ssh}
    Should Be Equal    ${output}    ${output2}
    Log    Step 6: Send router advertisment packets using scapy and compare ip routes    console=true
    ${command3}=    Catenate    'import scapy.all as scapy;
    ...                         x,y = scapy.sr(scapy.IPv6(dst="${MPLANE_IPV6}")
    ...                         /scapy.ICMPv6ND_RA(), timeout=5); print(x); print(y)'
    SSHLibrary.Write     sudo -E ${python_path_testpc} -c ${command3}
    Sleep    20
    ${Scapy_output3}=    SSHLibrary.Read
    Should Contain       ${Scapy_output3}    Unanswered: TCP:0 UDP:0 ICMP:0 Other:1
    ${bts_ssh}=    Connect to BTS
    ${output3}=     ssh.execute    command=ip route show   connection=${bts_ssh}  timeout=10s
    Disconnect from BTS    ${bts_ssh}
    Should Be Equal       ${output}    ${output3}
    Log    Step 7: Set icmpv6RouterMessageResponseEnabled to false    console=true
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                        param_name=icmpv6RouterMessageResponseEnabled
    ...                        param_value=false
    ...                        connection=${conn}
    Log    Step 8: Send router solicitation packets using scapy and compare ip routes    console=true
    ${command4}=    Catenate    'import scapy.all as scapy; x,y = scapy.sr(scapy.IPv6(dst="${MPLANE_IPV6}")
    ...                         /scapy.ICMPv6ND_RS(), timeout=5); print(x); print(y)'
    SSHLibrary.Write       sudo -E ${python_path_testpc} -c ${command4}
    Sleep    20
    ${Scapy_output4}=      SSHLibrary.Read
    Should Contain         ${Scapy_output4}    Unanswered: TCP:0 UDP:0 ICMP:0 Other:1
    ${bts_ssh}=    Connect to BTS
    ${output4}=     ssh.execute    command=ip route show   connection=${bts_ssh}  timeout=10s
    Disconnect from BTS    ${bts_ssh}
    Should Be Equal    ${output}    ${output4}
    Log    Step 6: Send router advertisment packets using scapy and compare ip routes    console=true
    ${command5}=    Catenate    'import scapy.all as scapy;
    ...                          x,y = scapy.sr(scapy.IPv6(dst="${MPLANE_IPV6}")
    ...                         /scapy.ICMPv6ND_RA(), timeout=5); print(x); print(y)'
    SSHLibrary.Write      sudo -E ${python_path_testpc} -c ${command5}
    Sleep    20
    ${Scapy_output5}=    SSHLibrary.Read
    Should Contain      ${Scapy_output5}    Unanswered: TCP:0 UDP:0 ICMP:0 Other:1
    ${bts_ssh}=    Connect to BTS
    ${output5}=     ssh.execute    command=ip route show   connection=${bts_ssh}  timeout=10s
    Disconnect from BTS    ${bts_ssh}
    Should Be Equal    ${output}    ${output5}
    [Teardown]    Run Keyword And Ignore Error    Disconnect from ADMIN    ${conn}

Respond_check_ICMP_IPv4_set1
    Log    Step 0: Get IP adresses    console=true
    ${fronthaul_ip}=    Get Fronthaul IP address
    ${ip_addresses}=    Create List       ${fronthaul_ip}   ${MPLANE_IPV4}    ${LMP_IP}
    Log    Step 1: Connect to BTS    console=true
    ${conn}=      Connect to ADMIN
    Log    Step 2: Set icmpResponseEnabled to true    console=true
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                        param_name=icmpResponseEnabled
    ...                        param_value=true
    ...                        connection=${conn}
    Log    Step 3: Send different types of ICMP packets using nping    console=true
    FOR    ${ip}    IN    @{ip_addresses}
        Sleep  15s
        ${output1b}=        Run    sudo nping --icmp --icmp-type 0 ${ip} -c 1
        Sleep  15s
        Should Contain    ${output1b}    Rcvd: 0 (0B) | Lost: 1 (100.00%)
        Sleep  15s
        ${output2b}=        Run    sudo nping --icmp --icmp-type 3 ${ip} -c 1
        Sleep  15s
        Should Contain    ${output2b}    Rcvd: 0 (0B) | Lost: 1 (100.00%)
        Sleep  15s
        ${output3b}=        Run    sudo nping --icmp --icmp-type 11 ${ip} -c 1
        Sleep  15s
        Should Contain    ${output3b}    Rcvd: 0 (0B) | Lost: 1 (100.00%)
        Sleep  15s
        ${output4b}=        Run    sudo nping --icmp --icmp-type 12 ${ip} -c 1
        Sleep  15s
        Should Contain    ${output4b}    Rcvd: 0 (0B) | Lost: 1 (100.00%)
    END
    [Teardown]    Run Keyword And Ignore Error    Disconnect from ADMIN    ${conn}

Respond_check_ICMP_IPv6_set1
    Log    Step 0: Get python path   console=true
    ${python_path}=     Run    which python
    Log    Step 1: Connect to BTS    console=true
    ${conn}=      Connect to ADMIN
    Log    Step 2: Set icmpResponseEnabled to true     console=true
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                        param_name=icmpResponseEnabled
    ...                        param_value=true
    ...                        connection=${conn}
    Sleep  15s
    Log    Step 3: Send ICMPv6EchoRequest packets using scapy    console=true
    ${command}=    Catenate    'import scapy.all as scapy; x,y = scapy.sr(scapy.IPv6(dst="${MPLANE_IPV6}")
    ...                        /scapy.ICMPv6EchoRequest(type=129, data="text"*50), timeout=5); print(x); print(y)'
    Sleep  15s
    ${Scapy_output}=           Run     sudo -E ${python_path} -c ${command}
    Should Contain      ${Scapy_output}    <Results: TCP:0 UDP:0 ICMP:0 Other:0>\n<Unanswered: TCP:0 UDP:0 ICMP:0 Other:1>
    Sleep  15s
    Log    Step 4: Send ICMPv6DestUnreach packets using scapy    console=true
    ${command}=    Catenate    'import scapy.all as scapy; x, y = scapy.sr(scapy.IPv6(dst="${MPLANE_IPV6}")
    ...                        / scapy.ICMPv6DestUnreach(code=0)
    ...                        / scapy.IPv6(src="${MPLANE_IPV6}", dst="${MPLANE_IPV6}"),
    ...                        timeout=5); print(x); print(y)'
    ${Scapy_output}=           Run    sudo -E ${python_path} -c ${command}
    Should Contain      ${Scapy_output}    <Results: TCP:0 UDP:0 ICMP:0 Other:0>\n<Unanswered: TCP:0 UDP:0 ICMP:0 Other:1>
    Log    Step 5: Send ICMPv6TimeExceeded packets using scapy    console=true
    ${command}=    Catenate    'import scapy.all as scapy; x,y = scapy.sr(scapy.IPv6(dst="${MPLANE_IPV6}")
    ...                        /scapy.ICMPv6TimeExceeded()/scapy.IPv6(), timeout=5); print(x); print(y)'
    ${Scapy_output}=           Run    sudo -E ${python_path} -c ${command}
    Should Contain      ${Scapy_output}    <Results: TCP:0 UDP:0 ICMP:0 Other:0>\n<Unanswered: TCP:0 UDP:0 ICMP:0 Other:1>
    Log    Step 6: Send ICMPv6ParamProblem packets using scapy    console=true
    Sleep  15s
    ${command}=    Catenate    'import scapy.all as scapy; x, y = scapy.sr(scapy.IPv6
    ...                         (dst="${MPLANE_IPV6}") / scapy.ICMPv6ParamProblem()
    ...                         / scapy.IPv6(src="2a00:8a00:6000:607c::8e04", dst="2a00:8a00:6000:607c::8e04"),
    ...                         timeout=5); print(x); print(y)'
    ${Scapy_output}=           Run    sudo -E ${python_path} -c ${command}
    Sleep  15s
    Should Contain      ${Scapy_output}    <Results: TCP:0 UDP:0 ICMP:0 Other:0>\n<Unanswered: TCP:0 UDP:0 ICMP:0 Other:1>
    Sleep  15s
    Log    Step 7: Send ICMPv6PacketTooBig packets using scapy    console=true
    ${command}=    Catenate    'import scapy.all as scapy; x,y = scapy.sr(scapy.IPv6(dst="${MPLANE_IPV6}")
    ...                        /scapy.ICMPv6PacketTooBig()/IPv6(), timeout=5); print(x); print(y)'
    ${Scapy_output}=           Run    sudo -E ${python_path} -c ${command}
    Sleep  15s
    Log    Step 8: Send ICMPv6ND_NS packets using scapy    console=true
    ${command}=    Catenate    'import scapy.all as scapy; x,y = scapy.sr(scapy.IPv6(dst="${MPLANE_IPV6}")
    ...                        /scapy.ICMPv6ND_NS(tgt="${MPLANE_IPV6}"), timeout=5); print(x); print(y)'
    ${Scapy_output}=           Run    sudo -E ${python_path} -c ${command}
    Sleep  15s
    Should Contain      ${Scapy_output}    <Results: TCP:0 UDP:0 ICMP:0 Other:0>\n<Unanswered: TCP:0 UDP:0 ICMP:0 Other:1>
    Sleep  15s
    Log    Step 9: Send ICMPv6ND_NA packets using scapy    console=true
    ${command}=    Catenate    'import scapy.all as scapy; x,y = scapy.sr(scapy.IPv6(dst="${MPLANE_IPV6}")
    ...                        /scapy.ICMPv6ND_NA(tgt="${MPLANE_IPV6}"), timeout=5); print(x); print(y)'
    ${Scapy_output}=           Run    sudo -E ${python_path} -c ${command}
    Sleep  15s
    Should Contain      ${Scapy_output}    <Results: TCP:0 UDP:0 ICMP:0 Other:0>\n<Unanswered: TCP:0 UDP:0 ICMP:0 Other:1>
    [Teardown]    Run Keyword And Ignore Error    Disconnect from ADMIN    ${conn}

Timestamp_reply_send_check_ICMP_IPv4
    Log    Step 0: Get IP adresses    console=true
    ${fronthaul_ip}=    Get Fronthaul IP address
    ${ip_addresses}=    Create List       ${fronthaul_ip}   ${MPLANE_IPV4}    ${LMP_IP}
    Log    Step 1: Connect to BTS    console=true
    ${conn}=      Connect to ADMIN
    Log    Step 2: Set icmpResponseEnabled to true    console=true
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                        param_name=icmpResponseEnabled
    ...                        param_value=true
    ...                        connection=${conn}
    Log    Step 3: Send packets using nping
    FOR    ${ip}    IN    @{ip_addresses}
        Sleep  15s
        ${output}=         Run    sudo nping --icmp --icmp-type timestamp ${ip} -c 1
        Sleep  15s
        Should Contain     ${output}    Rcvd: 0 (0B) | Lost: 1 (100.00%)
    END
    [Teardown]    Run Keyword And Ignore Error    Disconnect from ADMIN    ${conn}

Egress_rules_check_ICMP_IPv6
    Log    Step 1: Connect to BTS (WebEM)    console=true
    ${conn}=                      Connect to ADMIN
    Log    Step 2: Set icmpv6RouterMessageResponseEnabled to true    console=true
    Change Parameter on BTS       dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                           param_name=icmpv6RouterMessageResponseEnabled
    ...                           param_value=true
    ...                           connection=${conn}
    Log    Step 3: Connect to BTS (ssh)    console=true
    ${conn_bts}=                  Connect to BTS
    Log    Step 4: Run the command and check the outpput    console=true
    ${rules1}=                     ssh.execute    command=nft list chain ip6 filter ICMP_EGRESS
    ...                                          connection=${conn_bts}    timeout=10s
    Should Contain        ${rules1}    destination-unreachable    #ipv6-icmptype 1
    Should Contain        ${rules1}    echo-request               #ipv6-icmptype 128
    Should Contain        ${rules1}    parameter-problem          #ipv6-icmptype 4
    Should Contain        ${rules1}    packet-too-big             #ipv6-icmptype 2
    Should Contain        ${rules1}    neighbor-solicit           #ipv6-icmptype 135
    Should Contain        ${rules1}    neighbor-advert            #ipv6-icmptype 136
    Should Contain        ${rules1}    echo-reply                 #ipv6-icmptype 129
    Should Contain        ${rules1}    time-exceeded              #ipv6-icmptype 3
    Should Contain        ${rules1}    router-advert              #ipv6-icmptype 134
    Should Not Contain    ${rules1}    redirect-message           #ipv6-icmptype 137
    ${rules1_NDP}=                     ssh.execute    command=nft list chain ip6 filter EGRESS_NDP_CHAIN
    ...                                connection=${conn_bts}    timeout=10s
    Should Contain        ${rules1_NDP}    limit rate 500/second
    Log    Step 5: Set icmpv6RouterMessageResponseEnabled to false    console=true
    Change Parameter on BTS       dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                           param_name=icmpv6RouterMessageResponseEnabled
    ...                           param_value=false
    ...                           connection=${conn}
    Log    Step 6: Run the command and check the outpput    console=true
    ${rules2}=                     ssh.execute    command=nft list chain ip6 filter ICMP_EGRESS
    ...                                          connection=${conn_bts}    timeout=10s
    Should Contain        ${rules2}    destination-unreachable    #ipv6-icmptype 1
    Should Contain        ${rules2}    echo-request               #ipv6-icmptype 128
    Should Contain        ${rules2}    parameter-problem          #ipv6-icmptype 4
    Should Contain        ${rules2}    packet-too-big             #ipv6-icmptype 2
    Should Contain        ${rules2}    neighbor-solicit           #ipv6-icmptype 135
    Should Contain        ${rules2}    neighbor-advert            #ipv6-icmptype 136
    Should Contain        ${rules2}    echo-reply                 #ipv6-icmptype 129
    Should Contain        ${rules2}    time-exceeded              #ipv6-icmptype 3
    Should Contain        ${rules2}    router-advert              #ipv6-icmptype 134
    Should Not Contain    ${rules2}    redirect-message           #ipv6-icmptype 137
    ${rules1_NDP}=                     ssh.execute    command=nft list chain ip6 filter EGRESS_NDP_CHAIN
    ...                                connection=${conn_bts}    timeout=10s
    Should Contain        ${rules1_NDP}    limit rate 500/second
    [Teardown]            Run Keywords     Run Keyword And Ignore Error    Disconnect from BTS    ${conn_bts}
    ...    AND            Run Keyword and Ignore Error    Disconnect from ADMIN    ${conn}

Egress_rules_check_ICMP_IPv4
    Log    Step 1: Connect to BTS    console=true
    ${conn}=              Connect to BTS
    Log    Step 2: Run the command and check the output    console=true
    ${rules}=             ssh.execute    command=nft list chain ip filter ICMP_EGRESS    connection=${conn}    timeout=10s
    Should Contain        ${rules}    destination-unreachable    #icmp type 3
    Should Contain        ${rules}    echo-request               #icmp type 8
    Should Contain        ${rules}    parameter-problem          #icmp type 12
    Should Contain        ${rules}    echo-reply                 #icmp type 0
    Should Contain        ${rules}    time-exceeded              #icmp type 11
    Should Not Contain    ${rules}    redirect-message           #icmp type 5
    Should Not Contain    ${rules}    timestamp-request          #icmp type 15
    Should Not Contain    ${rules}    timestamp-reply            #icmp type 14
    [Teardown]            Run Keyword And Ignore Error    Disconnect from BTS    ${conn}

Ingress_rules_check_ICMP_IPv4
    Log    Step 1: Connect to BTS    console=true
    ${conn_bts}=          Connect to BTS
    Log    Step 2: Run the command and check the output    console=true
    ${rules}=             ssh.execute    command=nft list chain ip filter ICMP_EGRESS | grep -v icmpv6
    ...                                  connection=${conn_bts}    timeout=10s
    Should Contain        ${rules}    destination-unreachable    #icmptype 3
    Should Contain        ${rules}    echo-request               #icmptype 8
    Should Contain        ${rules}    parameter-problem          #icmptype 12
    Should Contain        ${rules}    echo-reply                 #icmptype 0
    Should Contain        ${rules}    time-exceeded              #icmptype 11
    Should Not Contain    ${rules}    redirect                   #icmptype 5
    Should Not Contain    ${rules}    timestamp                  #icmptype 13
    Should Not Contain    ${rules}    timestamp-reply            #icmptype 14
    [Teardown]            Run Keyword And Ignore Error    Disconnect from BTS    ${conn_bts}

Ingress_rules_check_ICMP_IPv6_extended
    Log    Step 1: Connect to BTS    console=true
    ${conn}=                      Connect to ADMIN
    Log    Step 2: Set icmpv6RouterMessageResponseEnabled to true
    Change Parameter on BTS       dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                           param_name=icmpv6RouterMessageResponseEnabled
    ...                           param_value=true
    ...                           connection=${conn}
    Log    Step 4: Connect to BTS via ssh    console=true
    ${ssh_conn}=    Connect to BTS
    Log    Step 5: Execute the command and check the output    console=true
    ${rules1}=    ssh.execute               nft list chain ip6 filter ICMP_EGRESS
    ...                                    connection=${ssh_conn}    timeout=10s
    Should Contain        ${rules1}    destination-unreachable    #ipv6-icmptype 1
    Should Contain        ${rules1}    echo-request               #ipv6-icmptype 128
    Should Contain        ${rules1}    parameter-problem          #ipv6-icmptype 4
    Should Contain        ${rules1}    packet-too-big             #ipv6-icmptype 2
    Should Contain        ${rules1}    neighbor-solicit           #ipv6-icmptype 135
    Should Contain        ${rules1}    neighbor-advert            #ipv6-icmptype 136
    Should Contain        ${rules1}    echo-reply                 #ipv6-icmptype 129
    Should Contain        ${rules1}    time-exceeded              #ipv6-icmptype 3
    Should Contain        ${rules1}    nd-router-advert           #ipv6-icmptype 134
    Should Contain        ${rules1}    nd-router-solicit          #ipv6-icmptype 133
    Should Not Contain    ${rules1}    redirect-message           #ipv6-icmptype 137
    ${rules1_RARS}=       ssh.execute  nft list chain ip6 filter ICMP_RARS_ENABLE
    ...                                connection=${ssh_conn}    timeout=10s
    ${rules1_NDP}=        ssh.execute  nft list chain ip6 filter INGRESS_NDP_CHAIN
    ...                                connection=${ssh_conn}    timeout=10s
    Should Contain        ${rules1_RARS}    INGRESS_NDP_CHAIN
    Should Contain        ${rules1_NDP}     limit rate 500/second
    Log    Step 6: Set icmpv6RouterMessageResponseEnabled to false
    Change Parameter on BTS       dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                           param_name=icmpv6RouterMessageResponseEnabled
    ...                           param_value=false
    ...                           connection=${conn}
    Log    Step 7: Execute the command and check the output    console=true
    ${rules2}=    ssh.execute               nft list chain ip6 filter ICMP_EGRESS
    ...                                    connection=${ssh_conn}    timeout=10s
    Should Contain        ${rules2}    destination-unreachable    #ipv6-icmptype 1
    Should Contain        ${rules2}    echo-request               #ipv6-icmptype 128
    Should Contain        ${rules2}    parameter-problem          #ipv6-icmptype 4
    Should Contain        ${rules2}    packet-too-big             #ipv6-icmptype 2
    Should Contain        ${rules2}    neighbor-solicit           #ipv6-icmptype 135
    Should Contain        ${rules2}    neighbor-advert            #ipv6-icmptype 136
    Should Contain        ${rules2}    echo-reply                 #ipv6-icmptype 129
    Should Contain        ${rules2}    time-exceeded              #ipv6-icmptype 3
    Should Contain        ${rules2}    nd-router-advert           #ipv6-icmptype 134
    Should Contain        ${rules2}    nd-router-solicit          #ipv6-icmptype 133
    Should Not Contain    ${rules2}    redirect-message           #ipv6-icmptype 13
    ${rules2_RARS}=       ssh.execute  nft list chain ip6 filter ICMP_RARS_ENABLE
    ...                                connection=${ssh_conn}    timeout=10s
    ${rules2_NDP}=        ssh.execute  nft list chain ip6 filter INGRESS_NDP_CHAIN
    ...                                connection=${ssh_conn}    timeout=10s
    Should Contain        ${rules2_RARS}     ICMP_RARS_ENABLE {\r\n\t}\r\n}\r\n
    Should Contain        ${rules2_NDP}      limit rate 500/second
    [Teardown]            Run Keywords    Run Keyword and Ignore Error     SSHLibrary.Write    exit
    ...    AND            Run Keyword and Ignore Error    Disconnect from ADMIN    ${conn}
