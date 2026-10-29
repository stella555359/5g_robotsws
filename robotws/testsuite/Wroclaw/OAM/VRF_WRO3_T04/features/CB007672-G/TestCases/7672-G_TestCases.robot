*** Settings ***
Documentation    Feature CB007672-G
...              author: Jedrzej Kowalski
...              contact: jedrzej.kowalski@nokia.com
...              maintainer: Jedrzej Kowalski
...              contact: jedrzej.kowalski@nokia.com

Resource    ../../../common_resources/admin/admin.robot
Resource    ../../../common_resources/connections/connections.robot
Resource    ../../../common_resources/netact/netact_operations.robot
Resource    ../../../common_resources/commissioning/parameters.robot

Library     ../../../common_resources/netact/netact_operations.py
Library     taf.transport.ssh           WITH NAME      ssh
Library     taf.sbts.oam.coam.admin  WITH NAME  coam_admin
Library     ../Resources/resources_sec_ipv6.py


*** Keywords ***
Create And Connect To BTSApplication User
    ${account_password}=  Set Variable  Yt_!%asdf12
    admin.Setup Local user account    account_type=BTSApplication
    ...                         new_password=${account_password}
    ${connection_BTSApplication}=  Connect to ADMIN  username=BTSApplication
    ...                            password=${account_password}
    [Return]    ${connection_BTSApplication}

Check If Port Has Expected State
    [Arguments]  ${port}  ${state}  ${ip_address}
    # Determine ip address type (IPv4/IPv6)
    # IPv6 = True
    # IPv4 = False
    ${status}=  Run Keyword And Return Status  Should Contain  ${ip_address}  :
    ${ip_type}=  Set Variable If  '${status}'=='True'  -6  -4
    ${output}=   Run  nmap -Pn -p ${port} ${ip_type} ${ip_address}
    Log  ${output}  console=true
    Should Contain  ${output}  ${state}

CB007672-G-SyVe-BTS_blocks_allows_ICMPv6_RS_RA_messages_NetAct
    Turn off TLS
    &{param}=   Create dictionary  icmpv6RouterMessageResponseEnabled  false
    Download SCF and create NetAct connection
    Set Parameter Using NetAct          dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                                 param_changes=${param}
    ...                                 path_to_scf=${scf_filepath}
    ...                                 na_instance=${connection}
    Run Keyword And Ignore Error  Disconnect from NetAct  ${connection}
    ${connection_BTSApplication}=  Create And Connect To BTSApplication User
    Change Parameter on BTS  dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                      param_name=icmpv6RouterMessageResponseEnabled
    ...                      param_value=${True}
    ...                      connection=${connection_BTSApplication}
    [Teardown]  Run Keywords    Disconnect from ADMIN  connection=${connection_BTSApplication}
    ...                         AND
    ...                         Turn On TLS

CB007672-G-SyVe_Application_Administrator_can_modify_ICMPv6_messages_response
    ${connection_BTSApplication}=  Create And Connect To BTSApplication User
    Change Parameter on BTS  dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                      param_name=icmpv6RouterMessageResponseEnabled
    ...                      param_value=${False}
    ...                      connection=${connection_BTSApplication}
    Change Parameter on BTS  dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                      param_name=icmpv6RouterMessageResponseEnabled
    ...                      param_value=${True}
    ...                      connection=${connection_BTSApplication}

CB007672-G-SyVe_Fault_4458
    ${nc_command}=  Set Variable  netcat -l 19000 &
    ${check_nc_command}=  Set Variable  ps -aux | grep 19000
    ${kill_netcat_command}=  Set Variable  pkill netcat
    ${connection_admin}=  Connect to Admin
    ${connection_bts}=  Connect to BTS
    ssh.Send Command    command=${nc_command}
    ...                 connection=${connection_bts}
    ${output}=    ssh.Execute       command= ${check_nc_command}
    ...                             connection=${connection_bts}
    Disconnect from BTS  connection=${connection_bts}
    Log  ${output}  console=True
    Should Contain  ${output}  netcat
    Change Parameter on BTS  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                      param_name=sshPortNumber
    ...                      param_value=19000
    ${connection_bts}=  Connect to BTS
    ssh.Send Command    command=${kill_netcat_command}
    ...                 connection=${connection_bts}
    Disconnect from BTS  connection=${connection_bts}
    [Teardown]  Delete Parameter From BTS   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                     param_name=sshPortNumber

CB007672-G-SyVe_Firewall_port_number_19000-19999
    @{correct_port1}=   Create List  19000  ${True}
    @{correct_port2}=   Create List  19999  ${True}
    @{correct_port3}=   Create List  18999  ${False}
    @{correct_port4}=   Create List  20000  ${False}
    &{ports_dict}=  	Create Dictionary   port1=${correct_port1}
    ...                                     port2=${correct_port2}
    ...                                     port3=${correct_port3}
    ...                                     part4=${correct_port4}
    # example: &{ports} dictionary value: &{ports} = {port1: [19000, True]}
    ${admin_connection}=  Connect To ADMIN
    ${ports}=  Get Dictionary Keys  ${ports_dict}
    FOR    ${port_id}    IN    @{ports}
        ${port}=  Get From Dictionary  ${ports_dict}  ${port_id}
        Log  ${port}[0]  console=True
        ${result}=  Run Keyword And Return Status  Change Parameter on BTS  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
        ...                                                                 param_name=sshPortNumber
        ...                                                                 param_value=${port}[0]
        ...                                                                 connection=${admin_connection}
        Should Be Equal  ${result}  ${port}[1]
    END
    [Teardown]   Run Keywords
    ...          Delete Parameter From BTS   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                      param_name=sshPortNumber
    ...                                      connection=${admin_connection}  AND
    ...          Disconnect from ADMIN  connection=${admin_connection}

CB007672-G-SyVe_Firewall_update_new_port
    ${nmap_command}=  Set Variable  sudo nmap -sS -p 19000 ${SSH_IP}
    ${admin_connection}=  Connect To ADMIN
    Change Parameter on BTS  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                      param_name=sshPortNumber
    ...                      param_value=19000
    ...                      connection=${admin_connection}
    Disconnect from ADMIN  connection=${admin_connection}
    Log  Check ssh port before reboot  console=true
    Wait For Port To Be Open    port=19000    ip_address=${SSH_IP}
    Reboot BTS And Wait Until Available
    Wait Until BTS Reach Configured Or OnAir State
    Log  Check ssh port after reboot  console=true
    Wait For Port To Be Open    port=19000    ip_address=${SSH_IP}
    Run Keyword and expect Error   *unable to connect to 192.168.255.129 on port 22 via SSH*   Connect to BTS
    Run Keyword and expect Error   *    Change Parameter on BTS  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                      param_name=sshPortNumber
    ...                      param_value=443
    ...                      connection=${admin_connection}
    ${admin_connection}=  Connect To ADMIN
    [Teardown]   Run Keywords
    ...          Delete Parameter From BTS   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                      param_name=sshPortNumber
    ...                                      connection=${admin_connection}  AND
    ...          Disconnect from ADMIN  connection=${admin_connection}

CB007672-G-SyVe_Firewall_update_new_port_IPv6
    ${IPv6_addres}=    RUN  netstat -6 -rn | grep /120 | awk '/^::|:/ {print $1}' | cut -d'/' -f1
    ${IPv6_route}=     get_trs_ipv6_route      ipv6_address=${IPv6_addres}
    RUN     sudo ip -6 route add default via ${IPv6_route} dev eth0
    ${admin_connection}=  Connect To ADMIN
    Change Parameter on BTS  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                      param_name=sshPortNumber
    ...                      param_value=19000
    ...                      connection=${admin_connection}
    Check If Port Has Expected State    port=19000
    ...                                 state=open
    ...                                 ip_address=${MPLANE_IPV6}
    [Teardown]   Run Keywords
    ...          Delete Parameter From BTS   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                      param_name=sshPortNumber
    ...                                      connection=${admin_connection}  AND
    ...          Disconnect from ADMIN  connection=${admin_connection}

CB007672-G-SyVe_Firewall_update_old_port
    ${admin_connection}=  Connect To ADMIN
    Change Parameter on BTS  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                      param_name=sshPortNumber
    ...                      param_value=19000
    ...                      connection=${admin_connection}
    ${status}=  Run Keyword And Return Status  Connect To BTS    port=22
    Should Not Be True  ${status}
    [Teardown]   Run Keywords
    ...          Delete Parameter From BTS   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                      param_name=sshPortNumber
    ...                                      connection=${admin_connection}  AND
    ...          Disconnect from ADMIN  connection=${admin_connection}

CB007672-G-SyVe_Firewall_update_old_port_IPv6
    ${admin_connection}=  Connect To ADMIN
    Change Parameter on BTS  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                      param_name=sshPortNumber
    ...                      param_value=19000
    ...                      connection=${admin_connection}
    ${status}=  Run Keyword And Return Status  Connect To BTS  ip_address=${MPLANE_IPV6}  port=22
    Should Not Be True  ${status}
    [Teardown]   Run Keywords
    ...          Delete Parameter From BTS   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                      param_name=sshPortNumber
    ...                                      connection=${admin_connection}  AND
    ...          Disconnect from ADMIN  connection=${admin_connection}

CB007672-G-SyVe_port_update_NetAct
    &{param}=   Create dictionary  sshPortNumber  19000
    Download SCF and create NetAct connection
    Set Parameter Using NetAct          dist_name=${parameter_path}
    ...                                 param_changes=${param}
    ...                                 path_to_scf=${scf_filepath}
    ...                                 na_instance=${connection}
    Run Keyword And Ignore Error  Disconnect from NetAct  ${connection}
    Check If Port Has Expected State    port=19000
    ...                                 state=open
    ...                                 ip_address=${SSH_IP}

CB007672-G-SyVe_System_Administrator_can_modify_ICMPv6_messages_response
    Change Parameter on BTS  MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                      icmpv6RouterMessageResponseEnabled
    ...                      false
    Change Parameter on BTS  MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                      icmpv6RouterMessageResponseEnabled
    ...                      true

CB007672-G-SyVe_System_Administrator_can_modify_SSH_port_number
    ${admin_connection}=  Connect To ADMIN
    Change Parameter on BTS  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                      param_name=sshPortNumber
    ...                      param_value=19550
    ...                      connection=${admin_connection}

    [Teardown]   Run Keywords
    ...          Delete Parameter From BTS   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                      param_name=sshPortNumber
    ...                                      connection=${admin_connection}  AND
    ...          Disconnect from ADMIN  connection=${admin_connection}

CB007672-G-SyVe_Application_Administrator_can_modify_SSH_port_number
    ${connection_BTSApplication}=  Create And Connect To BTSApplication User
    Change Parameter on BTS  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                      param_name=sshPortNumber
    ...                      param_value=19500
    ...                      connection=${connection_BTSApplication}
    [Teardown]  Delete Parameter From BTS   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                     param_name=sshPortNumber

Reset Configuration With Different Credentials
    [Arguments]  ${new_username}  ${new_password}
    Log  [Teardown started]  console=true
    ${admin_connection}=  Connect to ADMIN  username=${new_username}  password=${new_password}
    Run Keyword And Ignore Error    Perform Configuration Reset  connection=${admin_connection}
    Log  [Teardown ended]  console=true

Update password with input old password for BTS System Administrator
    ${new_username}=    username_gen.generate_random_username
    ${new_password}=    passwd_gen.generate_correct_password
    Log   New username: ${new_username}  console=true
    Log   New password: ${new_password}  console=true
    ${admin_connection}=    Connect to ADMIN
    ${status}=  Run Keyword And Return Status  coam_admin.set_user_account  old_username=Nemuadmin
    ...                                                                     new_username=${new_username}
    ...                                                                     old_password=nemuuser
    ...                                                                     new_password=${new_password}
    ...                                                                     connection=${admin_connection}
    Should Be True  ${status}
    ...             msg=Credentials change for "System Administrator" failed!
    Log  Status: ${status}  console=true
    [Teardown]    Run Keywords    Disconnect From ADMIN    connection=${admin_connection}
    ...                           AND
    ...                           Reset Local User Credentials By Removing users.json

Invalid update password for BTS System Administrator
    ${new_username}=    username_gen.generate_random_username
    ${new_password}=    passwd_gen.generate_correct_password
    Log   New username: ${new_username}  console=true
    Log   New password: ${new_password}  console=true
    ${admin_connection}=    Connect to ADMIN
    ${status}=  Run Keyword And Return Status  coam_admin.set_user_account  old_username=Nemuadmin
    ...                                                                     old_password=wrong_password
    ...                                                                     new_password=${new_password}
    ...                                                                     connection=${admin_connection}
    Should Not Be True  ${status}
    ...                 msg=Credentials changed for "System Administrator" (should not be possible)!
    ${status}=  Run Keyword And Return Status  coam_admin.set_user_account  old_username=Nemuadmin
    ...                                                                     old_password=nemuuser
    ...                                                                     new_password=wrong_password
    ...                                                                     connection=${admin_connection}
    Should Not Be True  ${status}
    ...                 msg=Credentials changed for "System Administrator" (should not be possible)!
    [Teardown]    Disconnect From ADMIN    connection=${admin_connection}

Update password for each local user
    ${admin_connection}=    Connect to ADMIN
    ${status}=  Run Keyword And Return Status  admin.Setup Local user account    account_type=BTSSecurity
    ...                                                                    new_password=Nokia123$
    ...                                                                    connection=${admin_connection}
    Should Be True  ${status}
    ...             msg=Credentials change for "BtsSecurity" failed!
    ${status}=  Run Keyword And Return Status  admin.Setup Local user account    account_type=BTSApplication
    ...                                                                    new_password=Nokia123$
    ...                                                                    connection=${admin_connection}
    Should Be True  ${status}
    ...             msg=Credentials change for "BtsApplication" failed!
    ${status}=  Run Keyword And Return Status  admin.Setup Local user account    account_type=BTSRead
    ...                                                                    new_password=Nokia123$
    ...                                                                    connection=${admin_connection}
    Should Be True  ${status}
    ...             msg=Credentials change for "BtsRead" failed!
    [Teardown]    Disconnect From ADMIN    connection=${admin_connection}

Update username and username with password
    ${new_username}=    username_gen.generate_random_username
    Log   New username: ${new_username}  console=true
    ${admin_connection}=    Connect to ADMIN
    ${status}=  Run Keyword And Return Status  coam_admin.set_user_account  old_username=Nemuadmin
    ...                                                                     new_username=${new_username}
    ...                                                                     old_password=nemuuser
    ...                                                                     connection=${admin_connection}
    Should Be True  ${status}
    ...             msg=Username change for "System Administrator" failed!
    Disconnect From ADMIN    connection=${admin_connection}
    ${new_username}=    username_gen.generate_random_username
    ${new_password}=    passwd_gen.generate_correct_password
    Log   New username: ${new_username}  console=true
    Log   New password: ${new_password}  console=true
    Reset Local User Credentials By Removing users.json
    ${admin_connection}=    Connect to ADMIN
    ${status}=  Run Keyword And Return Status  coam_admin.set_user_account  old_username=Nemuadmin
    ...                                                                     new_username=${new_username}
    ...                                                                     old_password=nemuuser
    ...                                                                     new_password=${new_password}
    ...                                                                     connection=${admin_connection}
    Should Be True  ${status}
    ...             msg=Credentials change for "System Administrator" failed!
    Disconnect From ADMIN    connection=${admin_connection}
    ${admin_connection}=    Connect to ADMIN    username=${new_username}
    ...                                         password=${new_password}
    [Teardown]    Run Keywords    Disconnect From ADMIN    connection=${admin_connection}
    ...                           AND
    ...                           Reset Local User Credentials By Removing users.json

Invalid update username for BTS System Administrator
    ${new_username}=    username_gen.generate_random_username
    ${new_password}=    passwd_gen.generate_correct_password
    Log   New username: ${new_username}  console=true
    Log   New password: ${new_password}  console=true
    ${admin_connection}=    Connect to ADMIN
    ${status}=  Run Keyword And Return Status  coam_admin.set_user_account  old_username=Nemuadmin
    ...                                                                     new_username=${new_username}
    ...                                                                     old_password=wrong_password
    ...                                                                     connection=${admin_connection}
    Should Not Be True  ${status}
    ...                 msg=Credentials changed for "System Administrator" (should not be possible)!
    ${status}=  Run Keyword And Return Status  coam_admin.set_user_account  old_username=123
    ...                                                                     old_password=nemuuser
    ...                                                                     new_password=${new_password}
    ...                                                                     connection=${admin_connection}
    Should Not Be True  ${status}
    ...                 msg=Credentials changed for "System Administrator" (should not be possible)!
    [Teardown]    Disconnect From ADMIN    connection=${admin_connection}

Wait For Port To Be Open
    [Arguments]    ${port}    ${ip_address}
    Wait Until Keyword Succeeds    5x    1s    Check If Port Has Expected State
    ...    port=${port}
    ...    state=open
    ...    ip_address=${ip_address}
