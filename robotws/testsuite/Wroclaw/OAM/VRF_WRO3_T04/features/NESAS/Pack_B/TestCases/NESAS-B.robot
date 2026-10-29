*** Settings ***
Documentation
...  author:  Patryk Tatarek
...  contact: patryk.tatarek@nokia.com

Resource    ../../../../common_resources/admin/admin.robot
Resource    ../../../../common_resources/connections/connections.robot
Resource    ../../../../common_resources/commissioning/parameters.robot
Resource    ../../../../common_resources/certificates/certificates.robot
Resource    ../../../../common_resources/passwords/password_change.robot
Resource    ../../../../common_resources/applications_running_with_root/common_keywords.robot
Resource    ../../../../common_resources/ip_traffic/ip_traffic.robot
Resource    ../../../../common_resources/pcap_analysis/pcap_analysis.robot
Resource    ../../../../common_resources/tls/tls.robot
Resource    ../../../../common_resources/netact/netact_operations.robot
Resource    ../../../../common_resources/mantaray/mantaray.robot
Resource    ../Resources/NESAS-B_resources.robot

Library     ../Resources/NESAS-B_resources.py
Library     taf.transport.ssh  WITH NAME  ssh
Library     SSHLibrary
Library     taf.sbts.oam.coam.admin    WITH NAME   coam_admin
Library     taf.selenium.sbts    WITH NAME   selenium
Library     SeleniumLibrary

*** Variables ***
${SERV_USER}               serviceuser
${SERV_PASS}               Pl(FzaYj5~c5;q
${logs_dest}               ${OUTPUT_DIR}/ATL_logs.xml

@{userNames}=                     Nemuadmin:  Nemuadmin\\  Nemuadmin|  Nemuadmin^  Nemuadmin>  Nemuadmin<
@{complexity_passwords}           Nokia    Nokia:123    Nookia!1234    Nokia 1234
...  vjXSGLfHoZrhmVQizJdOyccHyCMujwdlFzTTVcdmPJEYoOLrrNsxMqWifEttuQIusTwiQTCeqCdmyEquEwfAZsreFfKZOwitOKSJitCuuAEkVWKyabnqBnJJPaeYimVYw
@{length_usernames}               A12lk    A12lkA12lkA12lk
@{users}                          BTSSecurity    BTSApplication    BTSRead
@{passwords}                      PASSW32432@    PASSW2343    GFDJRKEwfjdk     343hjfkdsu    2384932d    543Hy342
*** Keywords ***
WebEM_Account_Lockout
    Log    Step 1: Changing parameter for value useed for session login delay after failed login    console=true
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                        param_name=btsSessionLoginDelay
    ...                        param_value=5
    Log    Step 2: Changing parameter for number of max failed login attempts    console=true
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                        param_name=btsMaxFailedLoginAttempts
    ...                        param_value=5
    Log    Step 3: Changing the timer when account is locked after failed login attempt    console=true
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                        param_name=btsAccountLockoutDuration
    ...                        param_value=2
    Log    Step 4: Checking if WebEM account is locked after failed login attempt    console=true
    ${lockout_status}=         check_webem_account_lockout    login_try=7
    ${status}=    Convert to String    ${lockout_status}
    Log    Step 5: Checking if login is denied due to too many login attempt    console=true
    Should Contain    ${status}    Cannot establish socket connection
    Sleep                      130    reason=Wait for the unlocking of Nemuadmin account
    Log    Step 6: Checking if Nemuadmin user is unlocked    console=true
    ${conn}=                   Connect to ADMIN
    [Teardown]                 Disconnect from ADMIN    ${conn}

SSH_Session_Login_Delay
    Log    Step 1: Changing parameter for ssh delay to 8s    console=true
    Change Parameter on BTS                        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                            param_name=sshSessionLoginDelayTimer
    ...                                            param_value=8
    Log    Step 2: Changing the maximum attempt for login to 10    console=true
    Change Parameter on BTS                        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                            param_name=sshMaxAuthAttempts
    ...                                            param_value=10
    Log    Step 3: Checking if delay and attempts work according to parameters    console=true
    check_ssh_session_login_delay                  toor4nsn    serviceuser

Log_Activity_from_SSH_User_Logging
    Log    Step 1: Resetting cache    console=true
    ssh.Reset Cache
    Log    Step 1: Integrating to NetAct    console=true
    ${NMS_LAB}=    mantaray.Integrate BTS To MantaRay With TLS    PREFERRED_LAB=srnclab1044
    Check If Local ATL Is Configured    ${NMS_LAB}
    Clear ATL    ${NMS_LAB}

    Log    Step 3: Connecting and disconnecting to ADMIN to create login event    console=true
    ${conn}=      admin.Connect to ADMIN
    admin.Disconnect from ADMIN    ${conn}
    ${conn}=    Connect to BTS
    Disconnect from BTS    ${conn}
    Sleep    600                  reason=Wait more time to be sure that logs have been generated
    Log    Step 4: Connecting to NetAct    console=true
#    ${connection}=                Connect to NetAct
    Log    Step 5: Get RUEM logs from NetAct    console=true
    ${logs_dest}=    Gather ATL for BTS to Variable    ${NMS_LAB}    ${BTS_ID}
    Log    Step 6: Grepping file by "SSH Login operation"    console=true
    Should Contain                ${logs_dest}     SSH Login operation
    Log    Step 7: Grepping file by "userName=toor4nsn"    console=true
    Should Contain                ${logs_dest}     userName="toor4nsn"
    Log    Step 8: Grepping file by "SSH Logout Operation"    console=true
    Should Contain                ${logs_dest}     SSH Logout Operation
    Log    Step 9: Grepping file by "WebEM session closed"    console=true
    Should Contain                ${logs_dest}     WebEM session closed
    Log    Step 10: Grepping file by "userName="Nemuadmin"    console=true
    Should Contain                ${logs_dest}     userName="Nemuadmin"
    [Teardown]                    Deintegrate BTS from MantaRay     ${NMS_LAB}

Permissions_to_access_logs_files_by_CLI
    Log    Step 1: Setting the allowed permission (-rw-r-----)    console=true
    ${right_permission}=    Set Variable     -rw-r-----
    Log    Step 2: Connecting to the BTS via SSH    console=true
    ${connection}=          Connect to BTS
    Log    Step 3: Executing command about permission of auditlogserver.db file    console=true
    ${output}=              ssh.execute
    ...                     ls -la /ffs/run/logs/oam/asm/auditlog/auditlogserver.db | awk '{print $1}'    ${connection}
    Log    Step 4: Comparing defined permission with the output from command    console=true
    Should Contain          ${output}   ${right_permission}
    Log    Step 5:
    ${permission}=          ssh.execute
    ...                     ls -la /ffs/run/config/users.json | awk '{print $1}'    ${connection}
    Should Contain          ${permission}    ${right_permission}
    [Teardown]    Disconnect from BTS    ${connection}

PLATFORM_Orphaned_Files
    Log    Step 1: Connect to BTS    console=true
    ${connection}=            Connect to BTS
    Log    Step 2: Sending command to find catalogs: "/", "/ffs/fs1", "/ffs/fs2", "/nvrd", "/bootdata"    console=true
    Log    to find files on this parition that have "-nouser" (haven't user), "-nogroup" (haven't group)    console=true
    ssh.send_command
    ...                 find / /ffs/fs{1,2} /nvrd /bootdata -xdev \( -nouser -o -nogroup \) -ls
    ...                 connection=${connection}
    Log    Step 3: Checking output if is empty    console=true
    ${result_perm}=     ssh.read_output   connection=${connection}
    Should be Empty     ${result_perm}
    [Teardown]          Disconnect from BTS    ${connection}

Check_Group_Credentials
    Log    Step 1: Connecting to the BTS    console=true
    ${conn}=    Connect to BTS
    Log    Step 2: Executing command to show content in gshadow file that contains users group    console=true
    ${output}=    ssh.execute    cat /etc/gshadow    ${conn}
    Log    Step 3: Checking output from gshadow file if contains allowed characters (x, !, !!, !*)    console=true
    check_groups_credentials    ${output}
    [Teardown]    Run Keyword And Ignore Error    Disconnect from BTS    ${conn}

Check_predefined_users_for_disabled_access_and_no_login
    Log    Step 1: Connecting to the BTS    console=true
    ${conn}=                  Connect to BTS
    Log    Step 2: Executing command to show content in gshadow file that contains users group    console=true
    ${output}=    ssh.execute    cat /etc/passwd    ${conn}
    Log    Step 3: Checking if users from passwd file are allowed and if disallowed users have no access    console=true
    check_predefined_users    ${output}
    [Teardown]    Run Keyword And Ignore Error    Disconnect from BTS    ${conn}

SSH_Bruteforce_Attempt
    Log    Step 1: Changing the parameter responsible for waiting to allow another login to 1s   console=true
    Change Parameter on BTS                         dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                             param_name=sshSessionLoginDelayTimer
    ...                                             param_value=1
    Log    Step 2: Changing the parameter to indicate the maximum number of authen. attempts via SSH   console=true
    Change Parameter on BTS                         dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                             param_name=sshMaxAuthAttempts
    ...                                             param_value=4
    Log    Step 3: Checking if the SSH login is blocked after unsuccessful login attempts for toor4nsn   console=true
    check_ssh_bruteforce_attempt                    address=${LMP_IP}
    ...                                             username=toor4nsn
    ...                                             wrong_password=badpass1234!
    ...                                             good_password=oZPS0POrRieRtu
    ...                                             number=2
    Log    Step 4: Changing the parameter responsible for waiting to allow another login to 6s   console=true
    Change Parameter on BTS                        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                            param_name=sshSessionLoginDelayTimer
    ...                                            param_value=6
    Log    Step 5: Changing the parameter to indicate the maximum number of authen. attempts via SSH   console=true
    Change Parameter on BTS                        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                            param_name=sshMaxAuthAttempts
    ...                                            param_value=4
    Log    Step 6: Checking if the SSH login is blocked after unsuccessful login attempts for serviceuser   console=true
    check_ssh_bruteforce_attempt                    address=${LMP_IP}
    ...                                             username=serviceuser
    ...                                             wrong_password=Pl(FzaYj5~c5;qg
    ...                                             good_password=Pl(FzaYj5~c5;q
    ...                                             number=2

PLATFORM_Process_user_accounts
    Log    Step 1: Creating list with all processes that needs to be checked    console=true
    @{processes}=    Create List    httpd    ntpd    ospfd    zebrad
    FOR    ${process}    IN    @{processes}
        Log    Step 2: Checking the result for ${process} to filter processes made by root    console=true
        Log    that contains the ${process}. Expected results is empty    console=true
        Check all processes on BTS    ${process}
    END

PLATFORM_Root_Writable_Files
    Log    Step 1: Connecting to the BTS via SSH    console=true
    ${connection}=    Connect to BTS
    Log    Step 2: This command to check common files owned by root (UID 0) that have write right for group   console=true
    ${output}=    ssh.execute    find / -type f -user 0 -perm /002 -ls 2>/dev/null    ${connection}
    Run Keyword and Continue on Failure    check_exceptions    ${output}
    ${step3}=    Catenate    This command to check common files owned by root (UID 0) that does not contain
    ...                      to root group and have write right for group
    Log    Step 3: ${step3}    console=true
    ${output}=    ssh.execute    find / -type f -user 0 ! -group 0 -perm /020 -ls 2>/dev/null    ${connection}
    check_exceptions    ${output}
    [Teardown]  Disconnect from BTS    ${connection}

PLATFORM_gNB_File_Permission_Rules
    Log    Step 1: Connecting to the BTS via SSH    console=true
    ${connection}=  Connect to BTS
    Log    Step 2: Creating list with names of files that must be check    console=true
    @{files}=       Create List    passwd  group  shadow  fstab  inittab  hosts  issue  services
    Log    Step 3: Checking file permission and ownership    console=true
    FOR  ${file}  IN  @{files}
        check_file_permission_rules    ${file}    ${connection}
    END
    [Teardown]  Disconnect from BTS    ${connection}

gNB_Local_Account_Check_For_No_Extra_Users
    Log    Step 1: Connecting to the BTS via SSH    console=true
    ${connection}=      Connect To BTS
    Log    Step 2: Checking if on the BTS is no extra users than toor4nsn, root and serviceuser    console=true
    check_local_account_for_no_extra_users  ${connection}
    [Teardown]          Disconnect From BTS

Handling_of_growing_content_via_tmp
    Log    Step 1: Logging to WebEM    console=true
    ${connection}=    Connect to admin
    ${MRBTS_id}=      admin_utils.get_mrbts_id    connection=${connection}
    Log    Step 2: Changing the actServiceAccountSsh parameter to true    console=true
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                        param_name=actServiceAccountSsh
    ...                        param_value=true
    ...                        connection=${connection}
    Disconnect from ADMIN      connection=${connection}
    Log    Step 3: Connect to BTS as toor4nsn    console=true
    ${connection}=             Connect to BTS
    Log    Step 4: Check free space in /tmp folder    console=true
    ${free_space}              check_free_space
    ...                        /tmp
    ...                        ${connection}
    Log    Step 5: The file with ${free_space} size is created in /tmp folder on BTS    console=true
    Send Logs to BTS    /tmp    ${free_space}    ${connection}
    Log    Step 6: Getting the date from the logs    console=true
    ${date_before}                          get_newest_data_from_logs    ${connection}
    Disconnect from BTS                     connection=${connection}
    Log    Step 7: Comparing free space (checking if free space is not smaller than 3.0)    console=true
    ${free_space}                           check_free_space
    ...                                     /tmp
    ...                                     ${connection}
    compare_free_space                      ${free_space}
    Log    Step 8: Stability test after uploading big file to BTS    console=true
    FOR    ${i}    IN RANGE    20
         Log    The number of loop is ${i}    console=true
         ${ping_status}=    Run Keyword And Return Status    Check If BTS Is Pingable
         Should Be True     ${ping_status}
         ${state_status}=   Run Keyword And Return Status    Check if BTS in Given State    state=OnAir
         Exit For Loop If    '${state_status}'=='${False}'
    END
    Log    Step 9: The BTS is resetted (expected result). Check after reset the state, alarms    console=true
    Sleep    120
    Wait until keyword succeeds  15m  60s   Wait until BTS reach Configured or OnAir state
    Wait Until keyword Succeeds  12x  2min  Check If All Cells Are OnAir
    Add Alarm To Allowed Alarms    4592    BTS Reset Cause
    No Faults Except Allowed Should Be Present On BTS
    ${connection}=                          Connect to BTS
    Log    Step 10: Getting the data from new log to check if logs after big file are collected properly    console=true
    ${date_after}                           get_newest_data_from_logs    ${connection}
    Log    Step 11: Comparing the dates from older and newer logs (to check if it's different)    console=true
    check_logs                              ${date_before}     ${date_after}
    Disconnect from BTS                     connection=${connection}
    [Teardown]    Run Keyword And Ignore Error           remove_log_file    filename    /tmp
    ...                                                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                                                  ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                                                  ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

Handling_of_growing_content_via_var_log
    Log    Step 1: Logging to WebEM    console=true
    ${connection}=    Connect to admin
    ${MRBTS_id}=      admin_utils.get_mrbts_id    connection=${connection}
    Log    Step 2: Changing the actServiceAccountSsh parameter to true    console=true
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                        param_name=actServiceAccountSsh
    ...                        param_value=true
    ...                        connection=${connection}
    Disconnect from ADMIN      connection=${connection}
    Log    Step 3: Connect to BTS as toor4nsn    console=true
    ${connection}=             Connect to BTS
    Log    Step 4: Check free space in /var/log folder    console=true
    ${free_space}              check_free_space
    ...                        /var/log
    ...                        ${connection}
    Log    Step 5: The file with ${free_space} size is created in /var/log folder on BTS    console=true
    Send Logs to BTS    /var/log    ${free_space}    ${connection}
    Log    Step 6: Getting the date from the logs    console=true
    ${date_before}                          get_newest_data_from_logs    ${connection}
    Disconnect from BTS                     connection=${connection}
    Log    Step 7: Comparing free space (checking if free space is not smaller than 3.0)    console=true
    ${free_space}                           check_free_space
    ...                                     /var/log
    ...                                     ${connection}
    compare_free_space                      ${free_space}
    Log    Step 8: Stability test after uploading big file to BTS    console=true
    FOR    ${i}    IN RANGE    20
         Log    The number of loop is ${i}    console=true
         ${ping_status}=    Run Keyword And Return Status    Check If BTS Is Pingable
         Should Be True     ${ping_status}
         ${state_status}=   Run Keyword And Return Status    Check if BTS in Given State    state=OnAir
         Exit For Loop If    '${state_status}'=='${False}'
    END
    Log    Step 9: The BTS is resetted (expected result). Check after reset the state, alarms    console=true
    Sleep    120
    Wait until keyword succeeds  15m  60s   Wait until BTS reach Configured or OnAir state
    Wait Until keyword Succeeds  12x  2min  Check If All Cells Are OnAir
    Add Alarm To Allowed Alarms    4592    BTS Reset Cause
    No Faults Except Allowed Should Be Present On BTS
    ${connection}=                          Connect to BTS
    Log    Step 11: Getting the data from new log to check if logs after big file are collected properly    console=true
    ${date_after}                           get_newest_data_from_logs    ${connection}
    Log    Step 12: Comparing the dates from older and newer logs (to check if it's different)    console=true
    check_logs                              ${date_before}     ${date_after}
    Disconnect from BTS                     connection=${connection}
    [Teardown]    Run Keyword And Ignore Error           remove_log_file    filename    /var/log
    ...                                                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                                                  ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                                                  ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

Unix_account_creation_and_UIDs_verification
    Log    Step 1: Connecting to the ADMIN    console=true
    ${connection}=             Connect to ADMIN
    Log    Step 2: Get MRBTS ID    console=true
    ${MRBTS_ID}=               admin_utils.get_mrbts_id    connection=${connection}
    Log    Step 3: Changing parameter to add possibility to log via SSH to BTS    console=true
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                        param_name=actServiceAccountSsh
    ...                        param_value=true
    Log    Step 4: Connecting to BTS via SSH    console=true
    ${connect}=                Connect to BTS
    Log    Step 5: Creating list for users and allowed IDs for users    console=true
    @{users}=                  Create List    root    toor4nsn    serviceuser
    @{ids}=                    Create List    0    0    1100
    @{id}=                     Create List
    Log    Step 6: Getting the IDs for the users    console=true
    FOR    ${user}    IN    @{users}
        ${output}=             ssh.execute    id -u ${user}    connection=${connect}
        ${x}=                  Split String    ${output}    \r
        Append To List    ${id}    ${x}[0]
    END
    Log    Step 7: Comparing the lists with defined IDs and IDs as output from command    console=true
    Lists Should Be Equal    ${id}    ${ids}
    Log    Step 8: Creating new users to check if IDs won't be repeated    console=true
    create_new_user          number=10    connection=${connect}
    Log    Step 9: Checking if IDs are unique and not repeated    console=true
    check_uniq_id            number=10    connection=${connect}
    Log    Step 10: Deleting user and disconnecting from BTS/ADMIN    console=true
    [Teardown]      Run Keywords        delete_new_user    number=10    connection=${connect}
    ...             AND                 Disconnect from BTS             connection=${connect}

WebEM_session_inactivity_timeout_with_local_users
    Log    Step 1: Downloading SCF to restore the default settings after test    console=true
    ${connection}=              Connect to ADMIN
    ${scf_path}=                admin.Download SCF    connection=${connection}
    Log    Step 2: Changing the webEMSessionLogoutTimer parameter value to 600s    console=true
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=webEMSessionLogoutTimer
    ...                         param_value=600
    ...                         connection=${connection}
    @{list_of_local_account}    Create List    BTSRead    BTSApplication    BTSSecurity
    Log    Step 4: Setting the credentials for ${list_of_local_account} users    console=true
    FOR  ${account_type}  IN  @{list_of_local_account}
        Log    Step 5: Set the credentials for ${account_type}    console=true
        ${status}=    Run Keyword and Return Status    Setup Local user account
        ...                                 account_type=${account_type}
        ...                                 new_password=NokiaPas@123!
        ...                                 connection=${connection}
        Should Be True                      ${status}
        Log    Step 6: Checking if logout will be proceed after 600s of inactivity    console=true
        log_to_webem_and_check_logout_timer    ${account_type}    NokiaPas@123!
    END
    Log    Step 7: Checking if logout will be proceed after 600s of inactivity for Nemuadmin    console=true
    log_to_webem_and_check_logout_timer    Nemuadmin    nemuuser
    Log    Step 8: Configuration reset for restoring the default settings    console=true
    [Teardown]    Configuration Reset    nemuuser   ${scf_path}    reset_type=3

SSH_Keys_provisioning_via_gNB_WebUI_while_key_continuation_is_off
    ssh.reset_cache
    Log    Step 1: Changing keyContinuation to false to have possibility to add root keys to BTS    console=true
    Configure SECADM FEATCADM And SECADM Objects    keyContinuation=false
    Log    Step 2: Creating 11 pairs of servicekeys and add them to BTS (fail because 10 is max limit)    console=true
    Run Keyword And Expect Error  AdminApiProcedureFailureException:*
    ...                           Create SSH Keys and Add or Not Add to BTS  serviceuser  11  serviceUserPublicKeys
    Log    Step 3: Creating 11 pairs of rootkeys and add them to BTS (fail because 10 is max limit)    console=true
    Run Keyword And Expect Error  AdminApiProcedureFailureException:*
    ...                           Create SSH Keys and Add or Not Add to BTS  toor4nsn     11  rootUserPublicKeys
    Log    Step 4: Removing all keys from VM    console=true
    RUN                           cd ${OUTPUT_DIR} && rm -f private_* && rm -f public*
    Log    Step 5: Changing keyContinuation to true to have no possibility to add root keys to BTS    console=true
    Configure SECADM FEATCADM And SECADM Objects    keyContinuation=true
    Log    Step 6: Creating serviceuser keys and add them to BTS    console=true
    ${created_serviceuser_keypairs}=     Create SSH Keys and Add or Not Add to BTS  serviceuser  1  serviceUserPublicKeys
    ${path_to_single_serviceuser_key}=   get_first_private_key_path_from_list_of_keypaths
    ...                                  ${created_serviceuser_keypairs}
    Run Keyword and Ignore Error  Creating Test Directory with Key Files  ${created_serviceuser_keypairs}  ${TEST_OUTPUT_DIR}
    Log    Step 7: Creating root keys and failure during adding them to BTS (due to keyContinuation=true)
    Run Keyword And Expect Error  AdminApiProcedureFailureException:*
    ...                           Create SSH Keys and Add or Not Add to BTS  toor4nsn     10  rootUserPublicKeys
    Log    Step 8: Connecting to toor4nsn with serviceuser key due to keyContinuation=true    console=true
    Connect To Toor4nsn with ServiceUser
    ...    file_path=${TEST_OUTPUT_DIR}/${path_to_single_serviceuser_key}
    ...    toor4nsn_addr=toor4nsn@localhost
    ...    status=True
    ...    file_path1=${TEST_OUTPUT_DIR}/${path_to_single_serviceuser_key}
    [Teardown]    Run Keywords    Configure SECADM FEATCADM And SECADM Objects    true    false    false
    ...           AND             Delete serviceuser SSH Keys From BTS And Locally  ${created_serviceuser_keypairs}
    ...           AND             RUN    cd ${OUTPUT_DIR} && rm -f private_* && rm -f public*
    ...           AND             RUN    rm -rf ${TEST_OUTPUT_DIR}

SSH_Keys_continuation_provisioning_via_gNB_WebUI_while_key_continuation_on_and_serviceuser_accounts_ssh_keys_not_uploaded
    ssh.reset_cache
    Log    Step 1: Configuring the keyContinuation parameter to true to add root SSH keys to BTS    console=true
    ${connection}=    Connect to ADMIN
    Change Multiple Parameters on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                  actServiceAccountSsh=true
    ...                                  keyContinuation=false
    ...                                  skip_parameter_relation_errors=${False}
    ...                                  connection=${connection}
    Change Parameter On BTS              dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                  param_name=systemAcctPermEnable
    ...                                  param_value=true
    ...                                  connection=${connection}
    Log    Step 2: Creating root SSH keys without adding it to BTS    console=true
    ${created_serviceuser_keypairs}=     Create SSH Keys and Add or Not Add to BTS  serviceuser  10  serviceUserPublicKeys  False
    ${path_to_single_serviceuser_key}=   get_first_private_key_path_from_list_of_keypaths
    ...                                  ${created_serviceuser_keypairs}
    Log    Step 3: Copy it to ${TEST_OUTPUT_DIR} directory    console=true
    Run Keyword and Ignore Error  Creating Test Directory with Key Files  ${created_serviceuser_keypairs}  ${TEST_OUTPUT_DIR}
    Log    Step 4: Connecting to serviceuser with SSH keys and expect error (requires password to login)    console=true
    Log    because SSH keys are not uploaded to BTS and the password must be provided    console=true
    Run Keyword And Expect Error         No match found for*
    ...                                  Connect To Toor4nsn with ServiceUser
    ...    file_path=${TEST_OUTPUT_DIR}/${path_to_single_serviceuser_key}
    ...    toor4nsn_addr=toor4nsn@localhost
    ...    status=True
    ...    file_path1=${TEST_OUTPUT_DIR}/${path_to_single_serviceuser_key}
    Log    Step 5: Deleting SSH Keys from BTS and locally    console=true
    Delete serviceuser SSH Keys From BTS And Locally  ${created_serviceuser_keypairs}
    RUN    rm -rf ${TEST_OUTPUT_DIR}
    Log    Step 6: Creting serviceuser SSH keys with adding it to BTS    console=true
    ${created_toor4nsn_keypairs}=        Create SSH Keys and Add or Not Add to BTS  toor4nsn    10  rootUserPublicKeys
    ${path_to_single_toor4nsn_key}=      get_first_private_key_path_from_list_of_keypaths
    ...                                  ${created_toor4nsn_keypairs}
    ${created_serviceuser_keypairs}=     Create SSH Keys and Add or Not Add to BTS  serviceuser  10  serviceUserPublicKeys
    ${path_to_single_serviceuser_key}=   get_first_private_key_path_from_list_of_keypaths
    ...                                  ${created_serviceuser_keypairs}
    Log    Step 7: Copy it to ${TEST_OUTPUT_DIR} directory    console=true
    Run Keyword and Ignore Error   Creating Test Directory with Key Files    ${created_serviceuser_keypairs}    ${TEST_OUTPUT_DIR}
    Run Keyword and Ignore Error   Creating Test Directory with Key Files    ${created_toor4nsn_keypairs}    ${TEST_OUTPUT_DIR}
    Log    Step 8: Connect to toor4nsn with two-step authentication procedure    console=true
    Connect To Toor4nsn with ServiceUser
    ...    file_path=${TEST_OUTPUT_DIR}/${path_to_single_serviceuser_key}
    ...    toor4nsn_addr=toor4nsn@localhost
    ...    status=True
    ...    file_path1=${TEST_OUTPUT_DIR}/${path_to_single_toor4nsn_key}
    Log    Step 9: Changing the systemAcctPermEnable parameter to false    console=true
    Change Parameter On BTS              dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                  param_name=systemAcctPermEnable
    ...                                  param_value=false
    ...                                  connection=${connection}
    Log    Step 10: Connecting to BTS with password and key    console=true
    Connect to BTS
    Connect To Toor4nsn with Key    ${TEST_OUTPUT_DIR}/${path_to_single_toor4nsn_key}
    Log    Step 11: Deleting all keys and checking if toor4nsn has no key    console=true
    Delete toor4nsn SSH Keys From BTS    ${created_toor4nsn_keypairs}
    RUN    rm -rf ${TEST_OUTPUT_DIR}
    Check If toor4nsn Has No Keys
    [Teardown]  Run Keywords    Delete Serviceuser SSH Keys From BTS And Locally  ${created_serviceuser_keypairs}
    ...         AND             Run Keyword and Ignore Error
    ...                         Delete toor4nsn SSH Keys From BTS    ${created_toor4nsn_keypairs}
    ...         AND             Configure SECADM FEATCADM And SECADM Objects    true    false    false
    ...         AND             RUN    rm -rf ${TEST_OUTPUT_DIR}


SSH_Keys_continuation_provisioning_via_gNB_WebUI_while_key_continuation_off_and_toor4nsn_accounts_ssh_keys_not_uploaded
    ssh.reset_cache
    Log    Step 1: Configuring the keyContinuation parameter to true to add root SSH keys to BTS    console=true
    ${connection}=    Connect to ADMIN
    Change Multiple Parameters on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                  actServiceAccountSsh=true
    ...                                  keyContinuation=false
    ...                                  skip_parameter_relation_errors=${False}
    ...                                  connection=${connection}
    Change Parameter On BTS              dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                  param_name=systemAcctPermEnable
    ...                                  param_value=false
    ...                                  connection=${connection}
    Log    Step 2: Creating root SSH keys without adding it to BTS    console=true
    ${created_toor4nsn_keypairs}=        Create SSH Keys and Add or Not Add to BTS  user=toor4nsn
    ...    quantity=10  key_type=rootUserPublicKeys  add_to_bts=False
    ${path_to_single_toor4nsn_key}=      get_first_private_key_path_from_list_of_keypaths
    ...                                  ${created_toor4nsn_keypairs}
    Log    Step 3: Copy it to ${TEST_OUTPUT_DIR} directory    console=true
    Run Keyword and Ignore Error  Creating Test Directory with Key Files  ${created_toor4nsn_keypairs}  ${TEST_OUTPUT_DIR}
    Log    Step 4: Connecting to toor4nsn with SSH keys and expect error (requires password to login)    console=true
    Log    because SSH keys are not uploaded to BTS and the password must be provided    console=true
    Run Keyword And Expect Error         No match found for*
    ...                                  Connect To Toor4nsn with Key
    ...                                  ${TEST_OUTPUT_DIR}/${path_to_single_toor4nsn_key
    Log    Step 5: Deleting SSH Keys from BTS and locally    console=true
    Delete toor4nsn SSH Keys From BTS    ${created_toor4nsn_keypairs}
    Log    Step 6: Creting root SSH keys with adding it to BTS    console=true
    ${created_toor4nsn_keypairs}=        Create SSH Keys and Add or Not Add to BTS  toor4nsn    1  rootUserPublicKeys
    ${path_to_single_toor4nsn_key}=      get_first_private_key_path_from_list_of_keypaths
    ...                                  ${created_toor4nsn_keypairs}
    Log    Step 7: Copy it to ${TEST_OUTPUT_DIR} directory    console=true
    Run Keyword and Ignore Error  Creating Test Directory with Key Files    ${created_toor4nsn_keypairs}    ${TEST_OUTPUT_DIR}
    Change Parameter On BTS              dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                  param_name=systemAcctPermEnable
    ...                                  param_value=false
    ...                                  connection=${connection}
    Log    Step 10: Connecting to BTS with password and key    console=true
    Connect to BTS
    Log    Step 10: Checking if toor4nsn keys from SCF are the same as the SSH keys in the BTS    console=true
    Check If Key For toor4nsn Is Updated
    [Teardown]  Run Keywords             Delete toor4nsn SSH Keys From BTS    ${created_toor4nsn_keypairs}
    ...         AND                      Configure SECADM FEATCADM And SECADM Objects    true    false    false

System_Account_Permission_Logging_via_SSH
    Log    Step 1: Changing the keyContinuation parameter to false    console=true
    Configure SECADM FEATCADM And SECADM Objects                             keyContinuation=false
    Log    Step 2: Changing the systemAcctPermEnable to true to log to BTS via SSH    console=true
    Change Parameter In FEATCADM Object  systemAcctPermEnable                false
    Log    Step 3: Connecting to BTS via SSH    console=true
    Connect to BTS
    Log    Step 4: Disconnecting to BTS via SSH    console=true
    Disconnect from BTS
    Log    Step 5: Connecting to BTS via SSH to M-Plane    console=true
    Connect to BTS  ip_address=${MPLANE_IPV4}
    Log    Step 6: Disconnecting to BTS via SSH from M-Plane   console=true
    Disconnect from BTS
    Log    Step 7: Changing the systemAcctPermEnable to true to not allow logging in    console=true
    Change Parameter In FEATCADM Object  systemAcctPermEnable                true
    Log    Step 8: Expecting ConnectFailedError logging via toor4nsn    console=true
    Run Keyword And Expect Error    ConnectFailedError:*    Connect to BTS
    Log    Step 9: Expecting ConnectFailedError logging via serviceuser    console=true
    Connect to BTS    username=serviceuser    password=Pl(FzaYj5~c5;q
    Log    Step 10: Expecting ConnectFailedError logging via toor4nsn (M-Plane)    console=true
    Run Keyword And Expect Error    ConnectFailedError:*   Connect to BTS  ip_address=${MPLANE_IPV4}
    [Teardown]    Configure SECADM FEATCADM And SECADM Objects    true    false    false

PLATFORM_System_Executables_SUID_SGID
    ${connection}=     Connect to BTS
    check_SUID_SGID    ${connection}
    [Teardown]         Disconnect from BTS    ${connection}

Password_History_Length
    ${connection}=              Connect to ADMIN
    ${scf_path}=                admin.Download SCF    connection=${connection}
    Log    Step 1: Changing the passwdHistoryLength to 3    console=true
    ${username}=                 Set Variable    Nemuadmin
    Change Parameter on BTS      dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                          param_name=passwdHistoryLength
    ...                          param_value=3
    Log    Step 2: Changing password from nemuuser to Pl(FzaYj5~c5;q    console=true
    ${status}=                   Run Keyword And Return Status    Change Local User Account Credentials
    ...                          old_username=${username}    old_password=nemuuser   new_username=${username}
    ...                          new_password=Pl(FzaYj5~c5;q
    Should Be True               ${status}
    Log    Step 3: Changing password from Pl(FzaYj5~c5;q to !Paswo2@23!    console=true
    ${status}=                   Run Keyword And Return Status    Change Local User Account Credentials
    ...                          old_username=${username}    old_password=Pl(FzaYj5~c5;q    new_username=${username}
    ...                          new_password=!Paswo2@23!
    Should Be True               ${status}
    Log    Step 4: Changing password from !Paswo2@23! to Pl(FzaYj5~c5;q (expected failure)    console=true
    ${status}=                   Run Keyword And Return Status    Change Local User Account Credentials
    ...                          old_username=${username}    old_password=!Paswo2@23!    new_username=${username}
    ...                          new_password=Pl(FzaYj5~c5;q
    Should Not Be True           ${status}
    Log    Step 5: Changing password from !Paswo2@23! to @Paswo2023@    console=true
    ${status}=                   Run Keyword And Return Status    Change Local User Account Credentials
    ...                          old_username=${username}    old_password=!Paswo2@23!    new_username=${username}
    ...                          new_password=@Paswo2023@
    Should Be True               ${status}
    Log    Step 6: Changing password from @Paswo2023@ to Pl(FzaYj5~c5;q (expected failure)    console=true
    ${status}=                   Run Keyword And Return Status    Change Local User Account Credentials
    ...                          old_username=${username}    old_password=@Paswo2023@    new_username=${username}
    ...                          new_password=Pl(FzaYj5~c5;q
    Should Not Be True           ${status}
    Log    Step 7: Changing password from @Paswo2023@ to Paswo2023#    console=true
    ${status}=                   Run Keyword And Return Status    Change Local User Account Credentials
    ...                          old_username=${username}    old_password=@Paswo2023@    new_username=${username}
    ...                          new_password=Paswo2023#
    Should Be True               ${status}
    Log    Step 8: Changing password from Paswo2023# to Pl(FzaYj5~c5;q    console=true
    ${status}=                   Run Keyword And Return Status    Change Local User Account Credentials
    ...                          old_username=${username}    old_password=Paswo2023#   new_username=${username}
    ...                          new_password=Pl(FzaYj5~c5;q
    Should Be True               ${status}
    [Teardown]    Run Keywords   Configuration Reset    Pl(FzaYj5~c5;q   ${scf_path}    reset_type=3
    ...           AND            Change Parameter on BTS
    ...                          dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                          param_name=passwdHistoryLength
    ...                          param_value=0

Changing_parameters_with_different_admin_rights_via_WebEM
    Log    Step 1: Connect to ADMIN as BTSSecurity    console=true
    Setup Local user account    account_type=BTSSecurity    new_password=Pl(FzaYj5~c5;q
    ${conn}=                    Connect to ADMIN    username=BTSSecurity    password=Pl(FzaYj5~c5;q
    Log    Step 2: Changing minUserNameLength and maxUserNameLength (succeed)    console=true
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=minUserNameLength
    ...                         param_value=6
    ...                         connection=${conn}
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=maxUserNameLength
    ...                         param_value=14
    ...                         connection=${conn}
    Disconnect from ADMIN       ${conn}
    Log    Step 3: Setting BTSApplication account    console=true
    Setup Local user account    account_type=BTSApplication    new_password=Pl(FzaYj5~c5;q
    ${conn}=                    Connect to ADMIN    username=BTSApplication    password=Pl(FzaYj5~c5;q
    Log    Step 4: Changing minUserNameLength (failed due to priviligies)    console=true
    ${status}=                  Run Keyword and Return Status    Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=minUserNameLength
    ...                         param_value=5
    ...                         connection=${conn}
    Should Not Be True          ${status}
    Disconnect from ADMIN       ${conn}
    Log    Step 5: Setting BTSRead account    console=true
    Setup Local user account    account_type=BTSRead    new_password=Pl(FzaYj5~c5;q
    ${conn}=                    Connect to ADMIN    username=BTSRead    password=Pl(FzaYj5~c5;q
    Log    Step 6: Changing minUserNameLength (failed due to priviligies)    console=true
    ${status}=                  Run Keyword and Return Status    Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=minUserNameLength
    ...                         param_value=5
    ...                         connection=${conn}
    Should Not Be True          ${status}
    Disconnect from ADMIN       ${conn}
    [Teardown]                  Run Keywords    Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=minUserNameLength
    ...                         param_value=4
    ...    AND                  Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=maxUserNameLength
    ...                         param_value=16
    ...    AND                  Run Keyword and Ignore Error    Disconnect from ADMIN    ${conn}

Length_rules_for_users_via_WebEM
    Log    Step 1: Setting BTSSecurity account    console=true
    Setup Local user account    account_type=BTSSecurity    new_password=Pl(FzaYj5~c5;q
    Setup Local user account    account_type=BTSApplication    new_password=Pl(FzaYj5~c5;q
    Setup Local user account    account_type=BTSRead    new_password=Pl(FzaYj5~c5;q
    ${conn}=                    Connect to ADMIN
    ${scf_path}=  admin.Download SCF  connection=${conn}
    Log    Step 2: Setting minUserNameLength and maxUserNameLength    console=true
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=minUserNameLength
    ...                         param_value=6
    ...                         connection=${conn}
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=maxUserNameLength
    ...                         param_value=14
    ...                         connection=${conn}
    Disconnect from ADMIN       ${conn}
    FOR    ${pass}    IN    @{length_usernames}
        ${status}=            Run Keyword And Return Status    Change Local User Account Username
        ...                   old_username=BTSSecurity
        ...                   old_password=Pl(FzaYj5~c5;q
        ...                   new_username=${pass}
        Log    Step 3: Changing username from BTSSecurity to ${pass} (failure)    console=true
        Should Not Be True    ${status}
    END
    Log    Step 4: Changing username from BTSSecurity to A12lkA12lk (passed)    console=true
    ${status}=              Run Keyword And Return Status    Change Local User Account Username
    ...                         old_username=BTSSecurity
    ...                         old_password=Pl(FzaYj5~c5;q
    ...                         new_username=A12lkA12lk
    Should Be True    ${status}
    FOR    ${pass}    IN    @{length_usernames}
        ${status}=            Run Keyword And Return Status    Change Local User Account Username
        ...                   old_username=BTSApplication
        ...                   old_password=Pl(FzaYj5~c5;q
        ...                   new_username=${pass}
        Log    Step 5: Changing username from BTSApplication to ${pass} (failure)    console=true
        Should Not Be True    ${status}
    END
    Log    Step 6: Changing username from BTSApplication to B12lkB12lk (passed)    console=true
    ${status}=              Run Keyword And Return Status    Change Local User Account Username
    ...                         old_username=BTSApplication
    ...                         old_password=Pl(FzaYj5~c5;q
    ...                         new_username=B12lkB12lk
    Should Be True              ${status}
    FOR    ${pass}    IN    @{length_usernames}
        ${status}=            Run Keyword And Return Status    Change Local User Account Username
        ...                   old_username=BTSRead
        ...                   old_password=Pl(FzaYj5~c5;q
        ...                   new_username=${pass}
        Log    Step 7: Changing username from BTSRead to ${pass} (failure)    console=true
        Should Not Be True    ${status}
    END
    Log    Step 8: Changing username from BTSRead to C12lkC12lk (passed)    console=true
    ${status}=              Run Keyword And Return Status    Change Local User Account Username
    ...                         old_username=BTSRead
    ...                         old_password=Pl(FzaYj5~c5;q
    ...                         new_username=C12lkC12lk
    Should Be True              ${status}
    FOR    ${pass}    IN    @{length_usernames}
        ${status}=            Run Keyword And Return Status    Change Local User Account Username
        ...                   old_username=Nemuadmin
        ...                   old_password=nemuuser
        ...                   new_username=${pass}
        Log    Step 9: Changing username from Nemuadmin to ${pass} (failure)    console=true
        Should Not Be True    ${status}
    END
    Log    Step 10: Changing username from Nemuadmin to Tempadmin (passed)    console=true
    ${status}=              Run Keyword And Return Status    Change Local User Account Username
    ...                         old_username=Nemuadmin
    ...                         old_password=nemuuser
    ...                         new_username=Tempadmin
    Should Be True              ${status}
    [Teardown]                  Run Keywords
    ...                         Configuration Reset    new_pass=nemuuser   scf_path=${scf_path}
    ...                         new_username=Tempadmin    reset_type=3
    ...    AND                  Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=minUserNameLength
    ...                         param_value=4
    ...    AND                  Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=maxUserNameLength
    ...                         param_value=16
    ...    AND                  Run Keyword and Ignore Error    Disconnect from ADMIN    ${conn}

Complexity_check_for_user_BTS_Users_via_WebEM
    ${connection}=    Connect to ADMIN
    ${scf_path}=  admin.Download SCF  connection=${connection}
    Log    Step 1: Setting account for BTSSecurity with wrong complexity password    console=true
    FOR    ${pass}    IN    @{complexity_passwords}
        ${status}=  Run Keyword And Return Status  admin.Setup Local User Account    account_type=BTSSecurity
        ...         new_password=${pass}    connection=${connection}
        Should Not Be True  ${status}
    END
    Log    Step 2: Setting account for BTSSecurity with correct complexity password (Nokia@123)    console=true
    ${status}=  Run Keyword And Return Status  admin.Setup Local User Account    account_type=BTSSecurity
    ...         new_password=NokiaPas@123    connection=${connection}
    Should Be True  ${status}
    Log    Step 3: Setting account for BTSApplication with wrong complexity password    console=true
    FOR    ${pass}    IN    @{complexity_passwords}
        ${status}=  Run Keyword And Return Status  admin.Setup Local User Account    account_type=BTSApplication
        ...         new_password=${pass}    connection=${connection}
        Should Not Be True  ${status}
    END
    Log    Step 4: Setting account for BTSApplication with correct complexity password (Nokia@456)    console=true
    ${status}=  Run Keyword And Return Status  admin.Setup Local User Account    account_type=BTSApplication
    ...         new_password=NokiaPas@456    connection=${connection}
    Should Be True  ${status}
    Log    Step 5: Setting account for BTSRead with wrong complexity password    console=true
    FOR    ${pass}    IN    @{complexity_passwords}
         ${status}=  Run Keyword And Return Status  admin.Setup Local User Account    account_type=BTSRead
        ...          new_password=${pass}    connection=${connection}
        Should Not Be True  ${status}
    END
    Log    Step 6: Setting account for BTSRead with correct complexity password (Nokia@789)    console=true
    ${status}=  Run Keyword And Return Status  admin.Setup Local User Account    account_type=BTSRead
    ...         new_password=NokiaPas@789    connection=${connection}
    Should Be True  ${status}
    Log    Step 7: Setting account for Nemuadmin with wrong complexity password    console=true
    FOR    ${pass}    IN    @{complexity_passwords}
        ${status}=    Run Keyword And Return Status    Change Local User Account Credentials    old_username=Nemuadmin
        ...           old_password=nemuuser    new_username=Nemuadmin    new_password=${pass}
        Should Not Be True  ${status}
    END
    Log    Step 8: Setting account for Nemuadmin with correct complexity password (Nokia@12345)    console=true
    ${status}=    Run Keyword And Return Status    Change Local User Account Credentials    old_username=Nemuadmin
        ...           old_password=nemuuser    new_username=Nemuadmin    new_password=NokiaPas@12345
    Should Be True  ${status}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Disconnect From ADMIN    connection=${connection}
    ...           AND    Configuration Reset    NokiaPas@12345   ${scf_path}    reset_type=3

WebEM_Bruteforce_Attempt
    ${connection}=  admin.Connect to ADMIN
    ${mrbts_id}=  admin_utils.get_mrbts_id             connection=${connection}
    Change Parameter on BTS                            dist_name=MRBTS-${mrbts_id}/MNL-1/AMGR-1/LUAC-1
    ...                                                param_name=btsAccountLockoutDuration
    ...                                                param_value=2
    Change Parameter on BTS                            dist_name=MRBTS-${mrbts_id}/MNL-1/AMGR-1/LUAC-1
    ...                                                param_name=btsSessionLoginDelay
    ...                                                param_value=1
    Change Parameter on BTS                            dist_name=MRBTS-${mrbts_id}/MNL-1/AMGR-1/LUAC-1
    ...                                                param_name=btsMaxFailedLoginAttempts
    ...                                                param_value=5

    ${url}=    Set Variable    https://192.168.255.129
    ${username}=    Set Variable    Nemuadmin
    ${sw_release}=    coam_admin.get_sw_release_name    connection=${connection}
    ${legnth}=    Get Length    ${passwords}

    Open Browser    ${url}    chrome
    Maximize Browser Window
    Click Button    Advanced
    Click Link      proceed-link
    Input Text      login-username    ${username}
     FOR    ${i}  IN RANGE       ${legnth}
        Input Password    login-password    ${passwords}[${i}]
        Click Button    Login
        Sleep    3
        IF    ${i} == 5
            Element Should Contain   class:error-field   Access denied due to account is locked
        ELSE
           Element Should Contain     class: error-field  Invalid username or password
        END
        Sleep    3
    END
    [Teardown]        SeleniumLibrary.Close Browser

