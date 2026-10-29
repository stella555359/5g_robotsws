*** Settings ***
Documentation
...  author:  Jagoda Kubacka
...  contact: jagoda.kubacka@nokia.com

Resource    ../../../../common_resources/admin/admin.robot
Resource    ../../../../common_resources/connections/connections.robot
Resource    ../../../../common_resources/commissioning/parameters.robot
Resource    ../../../../common_resources/certificates/certificates.robot
Resource    ../../../../common_resources/applications_running_with_root/common_keywords.robot
Resource    ../../../../common_resources/ip_traffic/ip_traffic.robot
Resource    ../../../../common_resources/pcap_analysis/pcap_analysis.robot
Resource    ../../../../common_resources/tls/tls.robot
Resource    ../../../../common_resources/netact/netact_operations.robot
Resource    ../../../../common_resources/passwords/password_change.robot
Resource    ../Resources/NESAS-C_resources.robot
Resource    ../Resources/NESAS_C_keywords.robot

Library     ../../../../common_resources/tls/TLSHandshakeTests.py    WITH NAME    handshake
Library     taf.ul.bts_components.Smod       WITH NAME    smod
Library     taf.ul.bts_components.Bbmod      WITH NAME    bbmod

*** Variables ***
${ca_subject_name}=    CN=CB007672
${XML_FILE}     tls.xml
@{PROTOCOLS}=    UDP    SCTP    TCP
${logs_dest}=    ${OUTPUT_DIR}/ATL_logs.xml

${ipv4_reg}    ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$
${vlan_reg}    ^[0-9]{2,3}$

${mac1}=       hmac-sha2-512-etm
${mac2}=       hmac-sha2-256-etm
${mac3}=       hmac-sha2-512
${mac4}=       hmac-sha2-256
${mac5}=       umac-128-etm
${mac6}=       umac-128
${mac7}=       umac-64-etm

${ciph1}=      aes256-gcm
${ciph2}=      aes128-gcm
${ciph3}=      aes256-ctr
${ciph4}=      aes192-ctr
${ciph5}=      aes128-ctr

${kex1}=       curve25519-sha256
${kex2}=       ecdh-sha2-nistp521
${kex3}=       ecdh-sha2-nistp384
${kex4}=       ecdh-sha2-nistp256
${kex5}=       diffie-hellman-group-exchange-sha256
${kex6}=       diffie-hellman-group18-sha512
${kex7}=       diffie-hellman-group16-sha512
${kex8}=       diffie-hellman-group14-sha256

${pm_technology}=    Nokia SRAN SBTS 25R3
${TEST_PC}=          10.44.69.202
${PC_LOGIN}=         kali
${PC_PASS}=          kalindrome@024
${PC_iface}=         eth3.550
*** Keywords ***
X2-U_IPv4_Nmap
    Log    Checking opened processes for User Plane IPv4 (UDP, SCTP, TCP)    console=true
    FOR    ${protocol}    IN    @{PROTOCOLS}
        ${ports}=    Execute Nmap And Divide    User plane    IPv4    ${protocol}    100
        get_root_opened_processes_on_ports      ${ports}              ${protocol}
    END

X2-C_IPv4_Nmap
    Log    Checking opened processes for Control Plane IPv4 (UDP, SCTP, TCP)    console=true
    FOR    ${protocol}    IN    @{PROTOCOLS}
        ${ports}=    Execute Nmap And Divide    Control plane    IPv4    ${protocol}    100
        get_root_opened_processes_on_ports      ${ports}                 ${protocol}
    END

Xn-U_IPv6_Nmap
    Log    Checking opened processes for Synchronization Plane IPv6 (UDP, SCTP, TCP)    console=true
    FOR    ${protocol}    IN    @{PROTOCOLS}
        ${ports}=    Execute Nmap And Divide    Synchronization plane    IPv6    ${protocol}    100
        get_root_opened_processes_on_ports      ${ports}                         ${protocol}
    END

X2-U_IPv6_Nmap
    Log    Checking opened processes for User Plane IPv6 (UDP, SCTP, TCP)    console=true
    FOR    ${protocol}    IN    @{PROTOCOLS}
        ${ports}=    Execute Nmap And Divide    User plane    IPv6    ${protocol}    100
        get_root_opened_processes_on_ports      ${ports}              ${protocol}
    END

X2-C_IPv6_Nmap
    Log    Checking opened processes for Control Plane IPv6 (UDP, SCTP, TCP)    console=true
    FOR    ${protocol}    IN    @{PROTOCOLS}
        ${ports}=    Execute Nmap And Divide    Control plane    IPv6    ${protocol}    100
        get_root_opened_processes_on_ports      ${ports}                 ${protocol}
    END

Xn-U_IPv4_Nmap
    Log    Checking opened processes for Synchronization Plane IPv4 (UDP, SCTP, TCP)    console=true
    FOR    ${protocol}    IN    @{PROTOCOLS}
        ${ports}=    Execute Nmap And Divide    Synchronization plane    IPv4    ${protocol}    100
        get_root_opened_processes_on_ports      ${ports}                         ${protocol}
    END

Xn-C_IPv6_Nmap
    Log    Checking opened processes for Control SA Plane IPv6 (UDP, SCTP, TCP)    console=true
    FOR    ${protocol}    IN    @{PROTOCOLS}
        ${ports}=    Execute Nmap And Divide    Control SA plane    IPv6    ${protocol}    100
        get_root_opened_processes_on_ports      ${ports}                    ${protocol}
    END

Xn-C_IPv4_Nmap
    Log    Checking opened processes for Control SA Plane IPv4 (UDP, SCTP, TCP)    console=true
    FOR    ${protocol}    IN    @{PROTOCOLS}
        ${ports}=    Execute Nmap And Divide    Control SA plane    IPv4    ${protocol}    100
        get_root_opened_processes_on_ports      ${ports}                    ${protocol}
    END

NG-C_IPv6_Nmap
    Log    Checking opened processes for NG-C IPv6 (UDP, SCTP, TCP)    console=true
    FOR    ${protocol}    IN    @{PROTOCOLS}
        ${ports}=    Execute Nmap And Divide    NG-C    IPv6    ${protocol}    100
        get_root_opened_processes_on_ports      ${ports}        ${protocol}
    END

NG-C_IPv4_Nmap
    Log    Checking opened processes for NG-C IPv4 (UDP, SCTP, TCP)    console=true
    FOR    ${protocol}    IN    @{PROTOCOLS}
        ${ports}=    Execute Nmap And Divide    NG-C    IPv4    ${protocol}    100
        get_root_opened_processes_on_ports      ${ports}        ${protocol}
    END

NG-U_IPv6_Nmap
    Log    Checking opened processes for NG-C IPv6 (UDP, SCTP, TCP)    console=true
    FOR    ${protocol}    IN    @{PROTOCOLS}
        ${ports}=    Execute Nmap And Divide    NG-U    IPv6    ${protocol}    100
        get_root_opened_processes_on_ports      ${ports}        ${protocol}
    END

NG-U_IPv4_Nmap
    Log    Checking opened processes for NG-U IPv4 (UDP, SCTP, TCP)    console=true
    FOR    ${protocol}    IN    @{PROTOCOLS}
        ${ports}=    Execute Nmap And Divide    NG-U    IPv4    ${protocol}    100
        get_root_opened_processes_on_ports      ${ports}        ${protocol}
    END

SPlane_IPv6_Nmap
    Log    Checking opened processes for Synchronization Plane IPv6 (UDP, SCTP, TCP)    console=true
    FOR    ${protocol}    IN    @{PROTOCOLS}
        ${ports}=    Execute Nmap And Divide    Synchronization plane    IPv6    ${protocol}    100
        get_root_opened_processes_on_ports      ${ports}                         ${protocol}
    END

SPlane_IPv4_Nmap
    Log    Checking opened processes for Synchronization Plane IPv4 (UDP, SCTP, TCP)    console=true
    FOR    ${protocol}    IN    @{PROTOCOLS}
        ${ports}=    Execute Nmap And Divide    Synchronization plane    IPv4    ${protocol}    100
        get_root_opened_processes_on_ports      ${ports}                         ${protocol}
    END

MPlane_IPv6_Nmap
    Log    Checking opened processes for Management Plane IPv6 (UDP, SCTP, TCP)    console=true
    FOR    ${protocol}    IN    @{PROTOCOLS}
        ${ports}=    Execute Nmap And Divide    Management plane    IPv6    ${protocol}    100
        get_root_opened_processes_on_ports      ${ports}                    ${protocol}
    END

MPlane_IPv4_Nmap
    Log    Checking opened processes for Management Plane IPv4 (UDP, SCTP, TCP)    console=true
    FOR    ${protocol}    IN    @{PROTOCOLS}
        ${ports}=    Execute Nmap And Divide    Management plane    IPv4    ${protocol}    100
        get_root_opened_processes_on_ports      ${ports}                    ${protocol}
    END

LMP_IPv4_Nmap
    Log    Checking opened processes for LMP IPv4 (UDP, SCTP, TCP)    console=true
    FOR    ${protocol}    IN    @{PROTOCOLS}
        ${ports}=    Execute Nmap And Divide    LMP    IPv4    ${protocol}    100
        get_root_opened_processes_on_ports      ${ports}                    ${protocol}
    END

M-Plane_IPv4_Nmap_Fronthaul
    Log    Step 1: Connecting to TEST PC    console=true
    SSHLibrary.Open Connection      ${TEST_PC}
    SSHLibrary.Login                ${PC_LOGIN}    ${PC_PASS}
    ${login_to_VM}=    Catenate    'sshpass -p "ute" ssh -o BatchMode=no -o PasswordAuthentication=yes -o Preferred
    ...                             Authentications=password ute@192.168.122.12'
    SSHLibrary.Write                ${login_to_VM}
    SSHLibrary.Read
    Sleep    5                      reason=Wait until terminal executes the command
    Log    Step 2: Executing command with nmap    console=true
    SSHLibrary.Write                sudo nmap -sS -p 0-65535 -Pn -vvv --oA TCP_nmap_fhnet --max-rate 300 172.21.1.18
    SSHLibrary.Read
    Sleep    5                      reason=Wait until terminal executes the command
    SSHLibrary.Write                ute
    Sleep    900                    reason=Wait until terminal executes the command
    Log    Step 3: The test will fail. Compare the output with Communication Matrix manually!!!     console=true
    ${output}=                      SSHLibrary.Read
    FAIL                            Compare {output} with Communication Matrix
    [Teardown]    Run Keywords      SSHLibrary.Write    exit
    ...    AND                      SSHLibrary.Close Connection

Perform_Mount_Options_Check_master
    ${ssh_conn}=     Connect to BTS
    Log    Step 1: Executing command 'mount | grep user'    console=true
    ${output}=       ssh.execute   command=mount | grep user    connection=${ssh_conn}
    @{lines}=        Split to Lines    ${output}
    Log    Step 2: Checking if the output has patter 'user_id' and contains 'user_id=0'    console=true
    Check mount options    @{lines}
    [Teardown]       Disconnect from BTS    ${ssh_conn}

Perform_Mount_Options_Check_slave
    Log                 Step 1: Get available bbmods    console=true
    smod.connect_to     address=${LMP_IP}    username=${SSH_USERNAME}    password=${SSH_PASSWORD}
    ${smod_alias}=      smod.get_alias
    @{bbmods_info}=     smod.get_bbmods_topology_info
    Log    Step 2: Checking if the output has patter 'user_id' and contains 'user_id=0'    console=true
    FOR    ${item}    IN    @{bbmods_info}
        IF    '${item['address']}'.endswith('0icom')
            bbmod.connect_to       address=${item['address']}    username=${item['username']}
            ...                    password=${item['password']}    proxy=${smod_alias}
            ${output}=             bbmod.execute    command=mount | grep user
            @{lines}=              Split to Lines    ${output}
            Run Keyword and Continue on Failure    Check mount options    @{lines}
            bbmod.close_connection
        END
    END
    [Teardown]          Run Keywords    Run Keyword and Ignore Error    bbmod.close_connection
    ...    AND                          smod.close_connection

Check_Authorization_Privileges
    Log    Step 1: Connecting to the WebEM with serviceuser account    console=true
    ssh.Connect to    hostname=${LMP_IP}
    ...               username=serviceuser
    ...               password=Pl(FzaYj5~c5;q
    ...               alias=serviceuser_connection
    Log    Step 2: Executing command 'cat /etc/shadow'    console=true
    ${serviceuser_permission}=    ssh.execute    command=cat /etc/shadow    connection=serviceuser_connection
    Log    Step 3: Checking if the permission is denied for serviceuser    console=true
    ${result}=    check_permissions    permission=${serviceuser_permission}
    Should Be True    ${result}
    Disconnect from BTS     serviceuser_connection
    Log    Step 4: Connecting to the WebEM with toor4nsn account    console=true
    ssh.Connect to    hostname=${LMP_IP}
    ...               username=toor4nsn
    ...               password=oZPS0POrRieRtu
    ...               alias=toor4nsn_connection
    Log    Step 5: Executing command 'cat /etc/shadow'    console=true
    ${toor4nsn_permission}=    ssh.execute    command=cat /etc/shadow    connection=toor4nsn_connection
    Log    Step 6: Checking if the permission is not denied for toor4nsn    console=true
    ${result}=    check_permissions    permission=${toor4nsn_permission}
    Should Not Be True    ${result}
    Disconnect from BTS    toor4nsn_connection

Brute_Force_Test_Creation_Unlimited_Login_Sessions_For_NE3S_wsuser_Login_Sessions
    Log    Step 1: Turning off TLS    console=true
    Wait until keyword succeeds    5 min  30sec    Turn OFF TLS
    FOR  ${loop}  IN RANGE  10
        Log    The number of login to NetAct is ${loop}    console=true
        Run Keyword    Connect to NetAct
    END
    Log    Step 2: Checking the usage of the system resources    console=true
    Check_usage_of_system_resources

Verify_Nemuadmin_Password_Storage
    ${connection}=              Connect to ADMIN
    ${scf_path}=                admin.Download SCF    connection=${connection}
    Log    Step 1: Checking if the passowrd for toor4nsn is hashed with SHA512    console=true
    check_local_user_password_hashed_with_sha512    192.168.255.129    toor4nsn    oZPS0POrRieRtu
    check_webem_user_password_hashed_with_sha512    192.168.255.129    toor4nsn    oZPS0POrRieRtu    Nemuadmin
    ${ssh_conn}=                 Connect to BTS
    Log    Step 2: Getting the hash value for the Nemuadmin    console=true
    ${first_password_hash}=      Get hash value of password for Nemuadmin    connection=${ssh_conn}
    Log    Step 3: Changing the password for Nemuadmin    console=true
    Change Local User Account Credentials    old_username=Nemuadmin    old_password=nemuuser
    ...                                      new_username=Nemuadmin    new_password=Pl(FzaYj5~c5;q
    Log    Step 4: Getting the has value for the Nemuadmin after changing the password    console=true
    check_webem_user_password_hashed_with_sha512    192.168.255.129    toor4nsn    oZPS0POrRieRtu    Nemuadmin
    Log    Step 5: Getting the hash value for the Nemuadmin for changed password    console=true
    ${second_password_hash}=     Get hash value of password for Nemuadmin    connection=${ssh_conn}
    Log    Step 6: Checking the hashes - should be the same    console=true
    Should Not Be Equal          ${first_password_hash}    ${second_password_hash}
    Log    Step 7: Changing the password for Nemuadmin    console=true
    Change Local User Account Credentials    old_username=Nemuadmin    old_password=Pl(FzaYj5~c5;q
    ...                                      new_username=Nemuadmin    new_password=!Paswo2@23!
    Log    Step 8: Checking if the new password is hashed with SHA512    console=true
    check_webem_user_password_hashed_with_sha512    192.168.255.129    toor4nsn    oZPS0POrRieRtu    Nemuadmin
    Log    Step 9: Getting the hash value for the Nemuadmin for changes password    console=true
    ${third_password_hash}=      Get hash value of password for Nemuadmin    connection=${ssh_conn}
    Log    Step 10: Comparing the hashed for all passwords for Nemuadmin - should be different    console=true
    Should Not Be Equal          ${second_password_hash}    ${third_password_hash}
    Should Not Be Equal          ${first_password_hash}     ${third_password_hash}
    [Teardown]    Run Keywords    Disconnect from BTS    ${ssh_conn}
    ...    AND                    Configuration Reset    !Paswo2@23!   ${scf_path}    reset_type=3

Verify_Users_Password_Storage
    Log    Step 1: Downloading the SCF    console=true
    ${connection}=              Connect to ADMIN
    ${scf_path}=                admin.Download SCF    connection=${connection}
    Log    Step 2: Setting the BTSSecurity account    console=true
    Setup Local User Account        account_type=BTSSecurity    new_password=Pl(FzaYj5~c5;q
    ${ssh_conn}=                    Connect to BTS
    Log    Step 3: Checking the hash value of the password for the BTSSecurity    console=true
    ${first_BTSSecurity_hash}=      Get hash value of password for local user   BTSSecurity    ${ssh_conn}
    Log    Step 4: Changing the password for BTSSecurity    console=true
    Change Local User Account Password    old_username=BTSSecurity    old_password=Pl(FzaYj5~c5;q
    ...                                                               new_password=!Paswo2@23!
    Log    Step 5: Checking the hash value of the new password for the BTSSecurity    console=true
    ${second_BTSSecurity_hash}=     Get hash value of password for local user   BTSSecurity    ${ssh_conn}
    Log    Step 6: Checking if the password is hashed with SHA512    console=true
    check_webem_user_password_hashed_with_sha512    192.168.255.129    toor4nsn    oZPS0POrRieRtu    BTSSecurity
    Log    Step 7: Checking if the passwords for BTSSecurity are not the same    console=true
    Should Not Be Equal             ${first_BTSSecurity_hash}    ${second_BTSSecurity_hash}
    Log    Step 8: Setting the BTSApplication account    console=true
    Setup Local User account        account_type=BTSApplication    new_password=Pl(FzaYj5~c5;q
    Log    Step 9: Checking the hash value of the password for the BTSApplication    console=true
    ${first_BTSApplication_hash}=      Get hash value of password for local user   BTSApplication    ${ssh_conn}
    Log    Step 10: Changing the password for BTSApplication    console=true
    Change Local User Account Password    old_username=BTSApplication    old_password=Pl(FzaYj5~c5;q
    ...                                                                  new_password=!Paswo2@23!
    Log    Step 11: Checking the hash value of the new password for the BTSApplication    console=true
    ${second_BTSApplication_hash}=     Get hash value of password for local user   BTSApplication    ${ssh_conn}
    Log    Step 12: Checking if the password is hashed with SHA512    console=true
    check_webem_user_password_hashed_with_sha512    192.168.255.129    toor4nsn    oZPS0POrRieRtu    BTSApplication
    Log    Step 13: Checking if the passwords for BTSApplication are not the same    console=true
    Should Not Be Equal          ${first_BTSApplication_hash}    ${second_BTSApplication_hash}
    Log    Step 14: Setting the BTSRead account    console=true
    Setup Local User account    account_type=BTSRead    new_password=Pl(FzaYj5~c5;q
    Log    Step 15: Checking the hash value of the password for the BTSRead    console=true
    ${first_BTSRead_hash}=      Get hash value of password for local user   BTSRead    ${ssh_conn}
    Log    Step 16: Changing the password for BTSRead    console=true
    Change Local User Account Password    old_username=BTSRead    old_password=Pl(FzaYj5~c5;q
    ...                                                           new_password=!Paswo2@23!
    Log    Step 17: Checking the hash value of the new password for the BTSRead    console=true
    ${second_BTSRead_hash}=     Get hash value of password for local user   BTSRead    ${ssh_conn}
    Log    Step 18: Checking if the password is hashed with SHA512    console=true
    check_webem_user_password_hashed_with_sha512    192.168.255.129    toor4nsn    oZPS0POrRieRtu    BTSRead
    Log    Step 19: Checking if the passwords for BTSRead are not the same    console=true
    Should Not Be Equal          ${first_BTSRead_hash}    ${second_BTSRead_hash}
    [Teardown]    Run Keywords    Run Keyword and Ignore Error    Disconnect from BTS    ${ssh_conn}
    ...    AND                    Configuration Reset    nemuuser   ${scf_path}    reset_type=3

Create_Update_Delete_3_VLANs_On_Classical
    Log    Step 1: Collecting the value for the localIpAddr parameter    console=true
    ${ips}=        Check current parameter value    localIpAddr
    ${ip_list}=    Create List
    Log    Step 2: Collecting the IPv4 addresses from the BTS    console=true
    FOR  ${ip}  IN  @{ips}
         ${is_ipv4}=    Run Keyword And Return Status    Should Match Regexp    ${ip}    ${ipv4_reg}
         Run Keyword If    ${is_ipv4}    Append to List    ${ip_list}    ${ip}
    END
    Log    Step 3: Collecting the value for the vlanId parameter    console=true
    ${vlans}=          Check current parameter value    vlanId
    ${vlan_list}=      Create List
    Log    Step 4: Collecting the VLAN addresses from the BTS    console=true
    FOR  ${vlan}  IN  @{vlans}
         ${is_vlan}=    Run Keyword And Return Status    Should Match Regexp    ${vlan}    ${vlan_reg}
         Run Keyword If    ${is_vlan}    Append to List    ${vlan_list}    ${vlan}
    END
    Log to console    ${vlan_list}
    ${nr_of_IP}=       Get Length    ${ip_list}
    ${nr_of_VLAN}=     Get Length    ${vlan_list}
    Log    Step 5: Checking if the amount of IP and VLAN is the same    console=true
    Should Be Equal    ${nr_of_IP}    ${nr_of_VLAN}
    @{combine}=        Set Variable    ${ip_list}    ${vlan_list}
    Log    Step 6: Checking the response for the ${ip} and ${vlan_id} addresses    console=true
    FOR    ${ip}    ${vlan_id}    IN ZIP    @{combine}
        Run Keyword and Continue on Failure    Run Tcpdump On BTS And Check Response    ${vlan_id}    ${ip}
    END

Check_Limit_Of_SSH_Login_Sessions_With_toor4nsn_Or_serviceuser_User_From_LMP_or_M-Plane
    Log    Step 1: Connecting to ADMIN to check active sessions    console=true
    ${connection}=    Connect to ADMIN
    ${output}=    coam_admin.Check Link Status    detailed_output=True    connection=${connection}
    ${is_secured_values}=    extract is secured values    ${output}
    ${count}=    Evaluate    sum(1 for item in ${is_secured_values} if item)
    Log    The secured connection with WebEM are ${is_secured_values} (${count})   console=true
    Disconnect from ADMIN    ${connection}
    ${no_possible_session}=    Evaluate    ${12} - ${count}
    Log    Possible number of session to login is ${no_possible_session}    console=true
    Log    Step 2: Logging to WebEM ${no_possible_session} times    console=true
    FOR    ${nr}    IN RANGE    1    ${no_possible_session}
        Log    The number of login is ${nr}    console=true
        Connect to ADMIN    alias=admin${nr}
    END
    Log    Step 3: Expect error with logging due to exceed the limit    console=true
    ${over_limit}=    Run Keyword and Expect Error  *    coam_admin.connect_to
    ...               bts_host=${LMP_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}
    ...               name=over_limit_admin    timeout=${30}
    [Teardown]        Disconnect for WebEM limit test    ${no_possible_session}    admin


Check_Limit_Of_WebEM_Sessions_as_Local_User
    Log    Step 1: Connecting to ADMIN to check active sessions    console=true
    ${connection}=    Connect to ADMIN
    ${output}=    coam_admin.Check Link Status    detailed_output=True    connection=${connection}
    ${is_secured_values}=    extract is secured values    ${output}
    ${count}=    Evaluate    sum(1 for item in ${is_secured_values} if item)
    Log    The secured connection with WebEM are ${is_secured_values} (${count})   console=true
    Disconnect from ADMIN    ${connection}
    ${no_possible_session}=    Evaluate    ${12} - ${count}
    Setup Local user account    account_type=BTSSecurity    new_password=Pl(FzaYj5~c5;q
    Log    Possible number of session to login is ${no_possible_session}    console=true
    Log    Step 2: Logging to WebEM ${no_possible_session} times    console=true
    FOR    ${nr}    IN RANGE    1    ${no_possible_session}
        Log    The number of login is ${nr}    console=true
        Connect to ADMIN    username=BTSSecurity    password=Pl(FzaYj5~c5;q    alias=sec${nr}
    END
    ${over_limit}=    Run Keyword and Expect Error  *    coam_admin.connect_to
    ...               bts_host=${LMP_IP}    username=BTSSecurity     password=Pl(FzaYj5~c5;q
    ...               name=over_limit_admin    timeout=${30}
    [Teardown]        Disconnect for WebEM limit test    ${no_possible_session}    sec

Protect_Data_Info_Transfer_Other_Protocols
    Change Parameter on BTS    dist_name=MRBTS-${tl.gnbs[0].global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...                        param_name=actFipsMode
    ...                        param_value=false
    SSHLibrary.Open Connection    ${LMP_IP}
    SSHLibrary.Login              ${SSH_USERNAME}    ${SSH_PASSWORD}
    ${mac_all}=        SSHLibrary.Execute Command     cat /etc/ssh/sshd_config | grep MACs
    ${mac_split}=      Split String    ${mac_all}    ,
    ${mac_alg}=        Create List    ${mac1}    ${mac2}    ${mac3}    ${mac4}    ${mac5}    ${mac6}    ${mac7}
    FOR  ${mac}  IN  @{mac_split}
        FOR  ${alg}  IN  @{mac_alg}
            ${status}=    Run Keyword and Return Status    Should Contain    ${mac}    ${alg}
            Run Keyword If    ${status}    Remove Values From List    ${mac_alg}    ${alg}
            Exit For Loop If    ${status}
        END
    END
    Should be Empty    ${mac_alg}
    ${kex_alg_all}=    SSHLibrary.Execute Command     cat /etc/ssh/sshd_config | grep KexAlgorithms
    ${kex_split}=      Split String    ${kex_alg_all}    ,
    ${kex_alg}=    Create List    ${kex1}    ${kex2}    ${kex3}    ${kex4}    ${kex5}    ${kex6}    ${kex7}    ${kex8}
    FOR  ${kex}  IN  @{kex_split}
        FOR  ${alg}  IN  @{kex_alg}
            ${status}=    Run Keyword and Return Status    Should Contain    ${kex}    ${alg}
            Run Keyword If    ${status}    Remove Values From List    ${kex_alg}    ${alg}
            Exit For Loop If    ${status}
        END
    END
    Should be Empty    ${kex_alg}
    ${ciphers_all}=    SSHLibrary.Execute Command     cat /etc/ssh/sshd_config | grep Ciphers
    ${ciph_split}=     Split String    ${ciphers_all}    ,
    ${ciph_alg}=       Create List    ${ciph1}    ${ciph2}    ${ciph3}    ${ciph4}    ${ciph5}
    FOR  ${ciph}  IN  @{ciph_split}
        FOR  ${alg}  IN  @{ciph_alg}
            ${status}=    Run Keyword and Return Status    Should Contain    ${ciph}    ${alg}
            Run Keyword If    ${status}    Remove Values From List    ${ciph_alg}    ${alg}
            Exit For Loop If    ${status}
        END
    END
    Should be Empty    ${ciph_alg}
    [Teardown]         SSHLibrary.Close Connection


Rate_Limit_for_UDP_echo_request_TWAMP_ipRmDropPcktsRtLimTwamp
#    ${NMS_LAB}=    mantaray.Integrate BTS To MantaRay With TLS    PREFERRED_LAB=srnclab2010
    Set Test Variable    ${counter_id}    M51328C7
    ${pps_number}=  NESAS_C_keywords.Get ASIB Or ASIL PPS Number For Certain Counter  5
    ${burst_number}=  NESAS_C_keywords.Get ASIB Or ASIL Burst Number For Certain Counter  5
    Should Be True  ${pps_number} == ${M51328C7_LIMIT}
    Should Be True  ${burst_number} == ${M51328C7_BURST}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    ${admin_conn}=  Connect to ADMIN
    NESAS_C_keywords.Delete IPAPP Object From BTS      ${admin_conn}
    NESAS_C_keywords.Create IPAPP Object if doesn't Exist or Change Parameter               ${admin_conn}
    NESAS_C_keywords.Create TWAMPREFLECT Object        ${admin_conn}
    Disconnect from ADMIN             ${admin_conn}
#    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
#    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C7
#    Wait Until Transport Counters Available After Reboot  M51328C7
#    Wait For New Interval Start  M51328C7
#    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C7
#    ${counter_NetAct_before}=  Get PM Counters from Mantaray    mrbts_id=${BTS_ID}    alias=${NMS_LAB}
#    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C7
#
#    ${index}=    Get Length    ${counter_NetAct_before}
#    ${index}=    Evaluate    ${index} - 1
#    ${counter_NetAct_value_before}=
#    ...   Get from Dictionary    ${counter_NetAct_before}[${index}]    ipRmDropPcktsRtLimTwamp
#    ${counter_SSH_value_before}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  Twamp RL Counter
#    ${NetAct_counter_time}=  Get from Dictionary    ${counter_NetAct_before}[${index}]    period_start_time
#    Compare NetAct And WebEm Counter Time
#    log  NetAct and WebEm counters time is correct  console=yes

#    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
#    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
#    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes

#    Start Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
#    Send Packets For M51328C7 Counter To BTS
#    Kill Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
#    log  packets were successfully sent on BTS with tcpdump    console=true
#    ${number_of_packets}=  Get Number Of Packets After Packets Flood
##    we should divide number of collected packets by two because of TWAMP two-way specific
#    ${equation_scapy_more}=  Catenate  (${number_of_packets} / 2) > (${M51328C7_PACKETS} *
#    ...  ${M51328C7_NUMBER_OF_SCAPY_RUNS} * ${M51328C7_TCPDUMP_STATISTICAL_ERROR_LESS})
#    ${equation_scapy_less}=  Catenate  (${number_of_packets} / 2) < (${M51328C7_PACKETS} *
#    ...  ${M51328C7_NUMBER_OF_SCAPY_RUNS} * ${M51328C7_TCPDUMP_STATISTICAL_ERROR_MORE})
#    Should Be True  ${equation_scapy_more}
#    Should Be True  ${equation_scapy_less}
       Evaluate    (${M51328C7_PACKETS} * ${M51328C7_NUMBER_OF_SCAPY_RUNS} * ${M51328C7_TCPDUMP_STATISTICAL_ERROR_LESS})
       Evaluate    (${M51328C7_PACKETS} * ${M51328C7_NUMBER_OF_SCAPY_RUNS} * ${M51328C7_TCPDUMP_STATISTICAL_ERROR_MORE})
##    log  packets were successfully collected on BTS with tcpdump  console=yes
#    Wait For New Interval Start  M51328C7
#    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C7
#    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C7
#    ${counter_NetAct_after}=  Get PM Counters from Mantaray    mrbts_id=${BTS_ID}    alias=${NMS_LAB}
#    ${index}=    Get Length    ${counter_NetAct_before}
#    ${index}=    Evaluate    ${index} - 1
#    ${counter_NetAct_value_after}=
#    ...    Get from Dictionary    ${counter_NetAct_before}[${index}]    ipRmDropPcktsRtLimTwamp
#    ${NetAct_counter_time}=  Get from Dictionary    ${counter_NetAct_before}[${index}]    period_start_time
#    ${counter_SSH_value_after}=  Get Counter Value From BTS Via SSH For ASIL For Certain Counter  Twamp RL Counter
#    Compare NetAct And WebEm Counter Time
#    Remove NetAct Counters Raport
#    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
#    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
#    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
#    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} >
#    ...   ${M51328C7_SHOULD_BE_COLLECTED} -
#    ...  ${M51328C7_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
#    ...  ${M51328C7_SHOULD_BE_COLLECTED} + ${M51328C7_TEST_STATISTICAL_ERROR})
#    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} -
#    ...${counter_NetAct_value_before} > ${M51328C7_SHOULD_BE_COLLECTED} -
#    ...  ${M51328C7_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
#    ...  ${M51328C7_SHOULD_BE_COLLECTED} + ${M51328C7_TEST_STATISTICAL_ERROR})
#    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} >
#    ...  ${M51328C7_SHOULD_BE_COLLECTED} -
#    ...  ${M51328C7_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
#    ...  ${M51328C7_SHOULD_BE_COLLECTED} + ${M51328C7_TEST_STATISTICAL_ERROR})
#    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} ==
#    ...   (${counter_SSH_value_after} - ${counter_SSH_value_before})
#    Should Be True  ${equation_WebEm}
#    Should Be True  ${equation_NetAct}
#    Should Be True  ${equation_SSH}
#    log  packets were successfully collected in M51328C7 transport counter on BTS  console=yes
#    ${admin_conn}=  Connect to ADMIN
#    Delete IPAPP Object From BTS      ${admin_conn}
#    Disconnect from ADMIN             ${admin_conn}
#    [Teardown]    Deintegrate BTS from MantaRay     ${NMS_LAB}


Rate_Limit_for_M-plane_LTE_ipRmDropPcktsRtLimSrLteMplane
    ${NMS_LAB}=    mantaray.Integrate BTS To MantaRay With TLS    PREFERRED_LAB=srnclab2010
    ${counter_id_status}=  Run Keyword And Ignore Error  Get Counter Value From WebEm  M51328C18
    ${counter_id}=  Set Variable If  'PASS' in ${counter_id_status}  M51328C18  M51328C11
    Set Test Variable    ${counter_id}
    ${pps_number}=  NESAS_C_keywords.Get ASIB Or ASIL PPS Number For Certain Counter  6
    ${burst_number}=  NESAS_C_keywords.Get ASIB Or ASIL Burst Number For Certain Counter  6
    Should Be True  ${pps_number} == ${M51328C18_LIMIT}
    Should Be True  ${burst_number} == ${M51328C18_BURST}
    log to console  pps number is correct: ${pps_number}
    log to console  burst number is correct: ${burst_number}
    Change Rejected Packets Interval and Reporting Interval parameters value to 5 minutes
#  Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  ${counter_id}
#    Wait Until Transport Counters Available After Reboot  ${counter_id}
    Wait For New Interval Start  ${counter_id}
    ${WebEm_counter_time}=  NESAS_C_keywords.Get Counter Time From WebEm  ${counter_id}
    ${counter_WebEm_value_before}=  NESAS_C_keywords.Get Counter Value From WebEm  ${counter_id}
    ${counter_NetAct_value_before}=    NESAS_C_keywords.Get counter from Mantaray
    ...   ${WebEm_counter_time}  -1    ${NMS_LAB}
    ${counter_SSH_value_before}=
    ...   NESAS_C_keywords.Get Counter Value From BTS Via SSH For ASIL For Certain Counter  Mplane RL Counter
##    Compare NetAct And WebEm Counter Time
    Send Packets For M51328C18 Counter To BTS
    log  NetAct and WebEm counters time is correct  console=yes
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    log  counter value from BTS before test is ${counter_SSH_value_before}  console=yes
#    Start Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    NESAS_C_keywords.Send Packets For M51328C18 Counter To BTS
#    Kill Tcpdump For M51328C18 Or M51328C12 Or M51328C7 Counters
    log  packets were successfully sent on BTS with tcpdump  console=yes
#    ${number_of_packets}=  Get Number Of Packets After Packets Flood
#    Should Be True  ${number_of_packets} > (${M51328C18_PACKETS} * ${M51328C18_TCPDUMP_STATISTICAL_ERROR_LESS})
#    Should Be True  ${number_of_packets} < (${M51328C18_PACKETS} * ${M51328C18_TCPDUMP_STATISTICAL_ERROR_MORE})
#    log  packets were successfully collected on BTS with tcpdump  console=yes
    NESAS_C_keywords.Wait For New Interval Start  ${counter_id}
#    Sleep     240s
    ${WebEm_counter_time}=  NESAS_C_keywords.Get Counter Time From WebEm  ${counter_id}
    ${counter_WebEm_value_after}=  NESAS_C_keywords.Get Counter Value From WebEm  ${counter_id}
    ${counter_NetAct_value_after}=    NESAS_C_keywords.Get counter from Mantaray    ipRmDropPcktsRtLimMplane
    ...   ${WebEm_counter_time}  -1    ${NMS_LAB}
    ${counter_SSH_value_after}=
    ...   NESAS_C_keywords.Get Counter Value From BTS Via SSH For ASIL For Certain Counter  Mplane RL Counter
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    log  counter value from BTS after test is ${counter_SSH_value_after}  console=yes
##    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} >
#   ...${M51328C18_SHOULD_BE_COLLECTED} -
##    ...  ${M51328C18_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
##    ...  ${M51328C18_SHOULD_BE_COLLECTED} + ${M51328C18_TEST_STATISTICAL_ERROR})
##    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} >
#   ...   ${M51328C18_SHOULD_BE_COLLECTED} -
##    ...  ${M51328C18_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
##    ...  ${M51328C18_SHOULD_BE_COLLECTED} + ${M51328C18_TEST_STATISTICAL_ERROR})
##    ${equation_SSH}=  Catenate  (${counter_SSH_value_after} - ${counter_SSH_value_before} >
#    ...   ${M51328C18_SHOULD_BE_COLLECTED} -
##    ...  ${M51328C18_TEST_STATISTICAL_ERROR}) and (${counter_SSH_value_after} - ${counter_SSH_value_before} <
##    ...  ${M51328C18_SHOULD_BE_COLLECTED} + ${M51328C18_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after} == (${counter_SSH_value_after} -
#   ...       ${counter_SSH_value_before})
##    Should Be True  ${equation_WebEm}
##    Should Be True  ${equation_NetAct}
##    Should Be True  ${equation_SSH}
#    log  packets were successfully collected in ${counter_id} transport counter on BTS  console=yes
    [Teardown]    Deintegrate BTS from MantaRay     ${NMS_LAB}
