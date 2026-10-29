*** Settings ***
Documentation
...  author:  Patryk Tatarek
...  contact: patryk.tatarek@nokia.com

Resource    ../../../common_resources/admin/admin.robot
Resource    ../../../common_resources/emssim/emssim_setup.robot
Resource    ../../../common_resources/emssim/emssim.robot
Resource    ../../../common_resources/commissioning/parameters.robot
Resource    ../../../common_resources/commissioning/commissioning.robot
Resource    ../../../common_resources/connections/connections.robot
Resource    ../../../common_resources/pcap_analysis/pcap_analysis.robot
Resource    ../../../common_resources/ip_traffic/ip_traffic.robot
Resource    ../../../common_resources/scf/scf_objects.robot

Library    taf.sbts.oam.coam.admin    WITH NAME    coam_admin
Library    ../Resources/Keywords.py
Library     Process
Library     SSHLibrary
Library     OperatingSystem
Library     taf.transport.ssh        WITH NAME    ssh
Library     taf.selenium.sbts        WITH NAME    sbts

*** Variables ***
@{userNames}=          Nemuadmin:  Nemuadmin\\  Nemuadmin|  Nemuadmin^  Nemuadmin>  Nemuadmin<
${ca_subject_name}=    CN=CB007672
${csr_file}=           ${EXECDIR}/csr_key.txt
${ip_syslog}=          10.42.54.11

&{PARAMS1}             remoteSyslogDSCP=0
...                    remoteSyslogFormat=RFC5424
...                    remoteSyslogServerIPaddress=${ip_syslog}
...                    remoteSyslogServerPortNo=6514
...                    remoteSyslogTransmitDuration=240
...                    remoteSyslogTransportProtocol=TLS

*** Keywords ***
Nokia_Service_accounts_are_blocked_for_login_attempt_as_ftp_user_via_SSH
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn  oZPS0POrRieRtu
    Sleep    3          reason=Wait until terminal execute the command
    SSHLibrary.Write    cat /etc/vsftpd.conf
    Sleep    5          reason=Wait until terminal execute the command
    ${output}=          SSHLibrary.Read
    Should Contain      ${output}    Forbid root/toor4nsn and serviceuser to use vsftpd
    SSHLibrary.Write    cat /etc/vsftpd.user_list
    Sleep    3          reason=Wait until terminal execute the command
    ${output}=          SSHLibrary.Read
    ${clear_output}=    Remove String    ${output}    root@asc-0a:~ >
    Should Contain      ${clear_output}    root
    Should Contain      ${clear_output}    toor4nsn
    Should Contain      ${clear_output}    serviceuser
    SSHLibrary.Write    netstat -tlpn | grep ftp
    Sleep    3          reason=Wait until terminal execute the command
    ${output}=          SSHLibrary.Read
    Should Contain      ${output}    :::21
    SSHLibrary.Write    ps -ef | grep -i ftp
    Sleep    3          reason=Wait until terminal execute the command
    ${output}=          SSHLibrary.Read
    Should Contain      ${output}    /vsftpd
    SSHLibrary.Write    telnet
    Sleep    3          reason=Wait until terminal execute the command
    SSHLibrary.Write    open localhost 21
    Sleep    3          reason=Wait until terminal execute the command
    SSHLibrary.Write    USER root
    Sleep    5          reason=Wait until terminal execute the command
    ${output}=          SSHLibrary.Read
    Should Contain      ${output}    Permission denied
    SSHLibrary.Write    USER toor4nsn
    Sleep    5          reason=Wait until terminal execute the command
    ${output}=          SSHLibrary.Read
    Should Contain      ${output}    Permission denied
    SSHLibrary.Write    USER serviceuser
    Sleep    5          reason=Wait until terminal execute the command
    ${output}=          SSHLibrary.Read
    Should Contain      ${output}    Permission denied
    SSHLibrary.Write    lxc-attach -n 0x1018
    Sleep    5          reason=Wait until terminal execute the command
    SSHLibrary.Write    cat /etc/vsftpd.conf
    Sleep    5          reason=Wait until terminal execute the command
    ${output}=          SSHLibrary.Read
    Should Contain      ${output}    Forbid root/toor4nsn and serviceuser to use vsftpd
    SSHLibrary.Write    cat /etc/vsftpd.user_list
    Sleep    3          reason=Wait until terminal execute the command
    ${output}=          SSHLibrary.Read
    Should Contain      ${output}    root@FHNET00:~ >
    ${clear_output}=    Remove String    ${output}    root@FHNET00:~ >
    Should Contain      ${clear_output}    root
    Should Contain      ${clear_output}    toor4nsn
    Should Contain      ${clear_output}    serviceuser
    SSHLibrary.Write    netstat -tlpn | grep ftp
    Sleep    3          reason=Wait until terminal execute the command
    ${output}=          SSHLibrary.Read
    Should Contain      ${output}    :::21
    SSHLibrary.Write    ps -ef | grep -i ftp
    Sleep    3          reason=Wait until terminal execute the command
    ${output}=          SSHLibrary.Read
    Should Contain      ${output}    /vsftpd
    SSHLibrary.Write    telnet
    Sleep    3          reason=Wait until terminal execute the command
    SSHLibrary.Write    open localhost 21
    Sleep    3          reason=Wait until terminal execute the command
    SSHLibrary.Write    USER root
    Sleep    5          reason=Wait until terminal execute the command
    ${output}=          SSHLibrary.Read
    Should Contain      ${output}    Permission denied
    SSHLibrary.Write    USER toor4nsn
    Sleep    5          reason=Wait until terminal execute the command
    ${output}=          SSHLibrary.Read
    Should Contain      ${output}    Permission denied
    SSHLibrary.Write    USER serviceuser
    Sleep    5          reason=Wait until terminal execute the command
    ${output}=          SSHLibrary.Read
    Should Contain      ${output}    Permission denied
    [Teardown]          SSHLibrary.Close Connection

Configurable_length_for_user_BTS_Security_Administrator_via_WebEM
    Setup Local user account    account_type=BTSSecurity    new_password=Pl(FzaYj5~c5;q
    ${conn}=                    Connect to ADMIN    username=BTSSecurity    password=Pl(FzaYj5~c5;q
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=minUserNameLength
    ...                         param_value=6
    ...                         connection=${conn}
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=maxUserNameLength
    ...                         param_value=14
    ...                         connection=${conn}
    Disconnect from ADMIN       ${conn}
    ${too_short}=               Run Keyword And Return Status    Change Local User Account Username
    ...                         old_username=BTSSecurity
    ...                         old_password=Pl(FzaYj5~c5;q
    ...                         new_username=A12lk
    Should Not Be True          ${too_short}
    ${too_long}=                Run Keyword And Return Status    Change Local User Account Username
    ...                         old_username=BTSSecurity
    ...                         old_password=Pl(FzaYj5~c5;q
    ...                         new_username=A12lkA12lkA12lk
    Should Not Be True          ${too_long}
    ${just_right}=              Run Keyword And Return Status    Change Local User Account Username
    ...                         old_username=BTSSecurity
    ...                         old_password=Pl(FzaYj5~c5;q
    ...                         new_username=A12lkA12lk
    Should Be True              ${just_right}
    [Teardown]                  Run Keywords    Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=minUserNameLength
    ...                         param_value=4
    ...    AND                  Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=maxUserNameLength
    ...                         param_value=16
    ...    AND                  Run Keyword and Ignore Error    Disconnect from ADMIN    ${conn}

Configurable_length_for_user_BTS_Application_Administrator_via_WebEM
    Setup Local user account    account_type=BTSApplication    new_password=Pl(FzaYj5~c5;q
    ${conn}=                    Connect to ADMIN    username=BTSApplication    password=Pl(FzaYj5~c5;q
    Disconnect from ADMIN       ${conn}
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=minUserNameLength
    ...                         param_value=6
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=maxUserNameLength
    ...                         param_value=14
    ${too_short}=               Run Keyword And Return Status    Change Local User Account Username
    ...                         old_username=BTSApplication
    ...                         old_password=Pl(FzaYj5~c5;q
    ...                         new_username=B12lk
    Should Not Be True          ${too_short}
    ${too_long}=                Run Keyword And Return Status    Change Local User Account Username
    ...                         old_username=BTSApplication
    ...                         old_password=Pl(FzaYj5~c5;q
    ...                         new_username=B12lkB12lkB12lk
    Should Not Be True          ${too_long}
    ${just_right}=              Run Keyword And Return Status    Change Local User Account Username
    ...                         old_username=BTSApplication
    ...                         old_password=Pl(FzaYj5~c5;q
    ...                         new_username=B12lkB12lk
    Should Be True              ${just_right}
    [Teardown]                  Run Keywords    Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=minUserNameLength
    ...                         param_value=4
    ...    AND                  Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=maxUserNameLength
    ...                         param_value=16
    ...    AND                  Run Keyword and Ignore Error    Disconnect from ADMIN    ${conn}

Configurable_length_for_user_BTS_Read_Only_User_via_WebEM
    Setup Local user account    account_type=BTSRead    new_password=Pl(FzaYj5~c5;q
    ${conn}=                    Connect to ADMIN    username=BTSRead    password=Pl(FzaYj5~c5;q
    Disconnect from ADMIN       ${conn}
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=minUserNameLength
    ...                         param_value=6
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=maxUserNameLength
    ...                         param_value=14
    ${too_short}=               Run Keyword And Return Status    Change Local User Account Username
    ...                         old_username=BTSRead
    ...                         old_password=Pl(FzaYj5~c5;q
    ...                         new_username=C12lk
    Should Not Be True          ${too_short}
    ${too_long}=                Run Keyword And Return Status    Change Local User Account Username
    ...                         old_username=BTSRead
    ...                         old_password=Pl(FzaYj5~c5;q
    ...                         new_username=C12lkC12lkC12lk
    Should Not Be True          ${too_long}
    ${just_right}=              Run Keyword And Return Status    Change Local User Account Username
    ...                         old_username=BTSRead
    ...                         old_password=Pl(FzaYj5~c5;q
    ...                         new_username=C12lkC12lk
    Should Be True              ${just_right}
    [Teardown]                  Run Keywords    Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=minUserNameLength
    ...                         param_value=4
    ...    AND                  Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=maxUserNameLength
    ...                         param_value=16
    ...    AND                  Run Keyword and Ignore Error    Disconnect from ADMIN    ${conn}

Configurable_length_for_user_BTS_System_Administrator_via_WebEM
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=minUserNameLength
    ...                         param_value=6
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=maxUserNameLength
    ...                         param_value=14
    ${too_short}=               Run Keyword And Return Status    Change Local User Account Username
    ...                         old_username=Nemuadmin
    ...                         old_password=nemuuser
    ...                         new_username=Neooo
    Should Not Be True          ${too_short}
    ${too_long}=                Run Keyword And Return Status    Change Local User Account Username
    ...                         old_username=Nemuadmin
    ...                         old_password=nemuuser
    ...                         new_username=NeoNeoNeoNeoNeo
    Should Not Be True          ${too_long}
    ${just_right}=              Run Keyword And Return Status    Change Local User Account Username
    ...                         old_username=Nemuadmin
    ...                         old_password=nemuuser
    ...                         new_username=Tempadmin
    Should Be True              ${just_right}
    [Teardown]                  Run Keywords    Connect to ADMIN    username=Tempadmin    password=nemuuser
    ...    AND                  coam_admin.set_user_account
    ...                         old_username=Tempadmin
    ...                         old_password=nemuuser
    ...                         new_username=Nemuadmin
    ...                         connection=admin
    ...    AND                  Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=minUserNameLength
    ...                         param_value=4
    ...    AND                  Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=maxUserNameLength
    ...                         param_value=16
    ...    AND                  Run Keyword and Ignore Error    Disconnect from ADMIN    admin

Configurable_length_with_admin_rights_via_WebEM
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=minUserNameLength
    ...                         param_value=5
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=maxUserNameLength
    ...                         param_value=15
    Setup Local user account    account_type=BTSSecurity    new_password=Pl(FzaYj5~c5;q
    ${conn}=                    Connect to ADMIN    username=BTSSecurity    password=Pl(FzaYj5~c5;q
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=minUserNameLength
    ...                         param_value=6
    ...                         connection=${conn}
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=maxUserNameLength
    ...                         param_value=14
    ...                         connection=${conn}
    Disconnect from ADMIN       ${conn}
    Setup Local user account    account_type=BTSApplication    new_password=Pl(FzaYj5~c5;q
    ${conn}=                    Connect to ADMIN    username=BTSApplication    password=Pl(FzaYj5~c5;q
    ${status}=                  Run Keyword and Return Status    Change Parameter on BTS
    ...                         dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=minUserNameLength
    ...                         param_value=5
    ...                         connection=${conn}
    Should Not Be True          ${status}
    Disconnect from ADMIN       ${conn}
    Setup Local user account    account_type=BTSRead    new_password=Pl(FzaYj5~c5;q
    ${conn}=                    Connect to ADMIN    username=BTSRead    password=Pl(FzaYj5~c5;q
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

Check_value_for_configurable_length_for_username_via_WebEM
    ${status}=            Run Keyword and Return Status    Change Parameter on BTS
    ...                   dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                   param_name=minUserNameLength
    ...                   param_value=3
    Should Not Be True    ${status}
    ${status}=            Run Keyword and Return Status    Change Parameter on BTS
    ...                   dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                   param_name=maxUserNameLength
    ...                   param_value=17
    Should Not Be True    ${status}
    ${status}=            Run Keyword and Return Status    Change Parameter on BTS
    ...                   dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                   param_name=maxUserNameLength
    ...                   param_value=14
    Should Be True        ${status}
    ${status}=            Run Keyword and Return Status    Change Parameter on BTS
    ...                   dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                   param_name=minUserNameLength
    ...                   param_value=15
    Should Not Be True    ${status}
    ${status}=            Run Keyword and Return Status    Change Parameter on BTS
    ...                   dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                   param_name=minUserNameLength
    ...                   param_value=6
    Should Be True        ${status}
    ${status}=            Run Keyword and Return Status    Change Parameter on BTS
    ...                   dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                   param_name=maxUserNameLength
    ...                   param_value=5
    Should Not Be True    ${status}
    ${status}=            Run Keyword and Return Status    Change Parameter on BTS
    ...                   dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                   param_name=minUserNameLength
    ...                   param_value=10
    Should Be True        ${status}
    ${status}=            Run Keyword and Return Status    Change Parameter on BTS
    ...                   dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                   param_name=maxUserNameLength
    ...                   param_value=10
    Should Be True        ${status}
    Reboot BTS and wait until available
    ${min_value}=         Check current parameter value
    ...                   dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                   param_name=minUserNameLength
    ${10}=                Convert to String    ['10']
    ${min}=               Convert to String    ${min_value}
    Should be Equal       ${min}    ${10}
    ${max_value}=         Check current parameter value
    ...                   dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                   param_name=maxUserNameLength
    ${max}=               Convert to String    ${max_value}
    Should be Equal       ${max}    ${10}
    [Teardown]            Run Keywords    Change Parameter on BTS
    ...                   dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                   param_name=minUserNameLength
    ...                   param_value=4
    ...    AND            Change Parameter on BTS
    ...                   dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                   param_name=maxUserNameLength
    ...                   param_value=16

#Configurable_length_for_user_BTS_System_Administrator_via_NMS
#    Setup environment for EMSSIM
#    ${emssim_connection}=          Connect and Activate EMSSIM
#    Wait until keyword succeeds    5x    1min    execute_command_on_emssim
#    ...                            command=edit LUAC-1 minUserNameLength 6
#    ...                            connection=${emssim_connection}
#    Wait until keyword succeeds    5x    1min    execute_command_on_emssim
#    ...                            command=edit LUAC-1 maxUserNameLength 14
#    ...                            connection=${emssim_connection}
#    Wait until keyword succeeds    5x    1min    execute_command_on_emssim
#    ...      command=user_info_update -username Tempadmin -password nemuuser -type temp -status enabled
#    ...                            connection=${emssim_connection}
#    [Teardown]     Disconnect From EMSSIM    ${emssim_connection}
#    [Teardown]                     Run Keywords    Wait until keyword succeeds
#    ...                            5x    1min    execute_command_on_emssim
#    ...                            command=edit LUAC-1 minUserNameLength 4
#    ...                            connection=${emssim_connection}
#    ...    AND                     Wait until keyword succeeds
#    ...                            5x    1min    execute_command_on_emssim
#    ...                            command=edit LUAC-1 maxUserNameLength 16
#    ...                            connection=${emssim_connection}
#    ...    AND                     Disconnect From EMSSIM    ${emssim_connection}
#
#Configurable_length_for_user_BTS_Security_Administrator_via_NMS
#    Setup environment for EMSSIM
#    Change Parameter on BTS       dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
#    ...                           param_name=actRestrictLoginToCnum
#    ...                           param_value=true
#    ${emssim_connection}=          Connect and Activate EMSSIM
#    Wait until keyword succeeds    5x    1min    execute_command_on_emssim
#    ...                            command=edit LUAC-1 minUserNameLength 6
#    ...                            connection=${emssim_connection}
#    Wait until keyword succeeds    5x    1min    execute_command_on_emssim
#    ...                            command=edit LUAC-1 maxUserNameLength 14
#    ...                            connection=${emssim_connection}
#    Wait until keyword succeeds    5x    1min   execute_command_on_emssim
#    ...                            command=ldap_user_add A1l Pl(FzaYj5~c5;q -a RW
#    ...                            connection=${emssim_connection}
#    Wait until keyword succeeds    5x    1min    execute_command_on_emssim
#    ...    command=user_info_update -username A1l -password Pl(FzaYj5~c5;q -type sec_adm -status enabled
#    ...                            connection=${emssim_connection}
#    ${too_short}=    Run Keyword and Return Status    Connect to ADMIN  username=A1l  password=Pl(FzaYj5~c5;q
#    Should not be True             ${too_short}
#    Wait until keyword succeeds    5x    1min    execute_command_on_emssim
#    ...                            command=ldap_user_add A12lkA12lkA12lk Pl(FzaYj5~c5;q -a RW
#    ...                            connection=${emssim_connection}
#    ${too_long}=                   Run Keyword and Return Status    execute_command_on_emssim
#    ...    command=user_info_update -username A12lkA12lkA12lk -password Pl(FzaYj5~c5;q -type sec_adm -status enabled
#    ...                            connection=${emssim_connection}
#    Should not be True             ${too_long}
#    Wait until keyword succeeds    5x    1min    execute_command_on_emssim
#    ...                            command=ldap_user_add A12lkA12lk Pl(FzaYj5~c5;q -a RW
#    ...                            connection=${emssim_connection}
#    Wait until keyword succeeds    5x    1min    execute_command_on_emssim
#    ...    command=user_info_update -username A12lkA12lk -password Pl(FzaYj5~c5;q -type sec_adm -status enabled
#    ...                            connection=${emssim_connection}
#    [Teardown]    Disconnect From EMSSIM    ${emssim_connection}
#    [Teardown]     Run Keywords    Disconnect From EMSSIM    ${emssim_connection}
#    ...    AND                     Change Parameter on BTS
#    ...                            dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
#    ...                            param_name=actRestrictLoginToCnum
#    ...                            param_value=false
#    [Teardown]                     Run Keywords    Wait until keyword succeeds
#    ...                            5x    1min    execute_command_on_emssim
#    ...                            command=edit LUAC-1 minUserNameLength 4
#    ...                            connection=${emssim_connection}
#    ...    AND                     Wait until keyword succeeds
#    ...                            5x    1min    execute_command_on_emssim
#    ...                            command=edit LUAC-1 maxUserNameLength 16
#    ...                            connection=${emssim_connection}
#    ...    AND    Run Keyword and Ignore Error    Disconnect from ADMIN   admin
#    ...    AND                     Disconnect From EMSSIM    ${emssim_connection}
#    ...    AND                     Change Parameter on BTS
#    ...                            dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
#    ...                            param_name=actRestrictLoginToCnum
#    ...                            param_value=false

Configurable_length_for_username_via_WebEM_UUF_scenario
    ${current_soft}=                 Get Software Release Name
    ${current_soft}=                 functions_benchmarking.Get Software Version From String    ${current_soft}
    ${old_soft}=                     functions_benchmarking.Get Software Version From String
    ...                              SBTS00_ENB_9999_230416_000018
    ${current_soft_path}=            Wait until keyword succeeds    10x    1min
    ...                              Download New Software Version From Remote Repository    ${current_soft}
    ${old_soft_path}=                Wait until keyword succeeds    10x    1min
    ...                              Download New Software Version From Remote Repository    ${old_soft}
    Install Software On BTS          ${old_soft_path}
    Sleep  60                        reason=Waiting to restart system
    Wait Until Keyword Succeeds      20m  30s   Check If BTS Is Pingable
    ${conn}=                         Wait Until Keyword Succeeds    20 min    60 sec    Connect to ADMIN
    Wait Until Keyword Succeeds      20m  30s    Wait Until BTS Reach Configured Or OnAir State
    ${status}=                       Run Keyword and Return Status    Change Parameter on BTS
    ...                              dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                              param_name=minUserNameLength
    ...                              param_value=6
    ...                              connection=${conn}
    Should not be True               ${status}
    ${status}=                       Run Keyword and Return Status    Change Parameter on BTS
    ...                              dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                              param_name=maxUserNameLength
    ...                              param_value=12
    ...                              connection=${conn}
    Should not be True               ${status}
    Disconnect from ADMIN            ${conn}
    Install Software On BTS          ${current_soft_path}
    Sleep  60                        reason=Waiting to restart system
    Wait Until Keyword Succeeds      20m  30s   Check If BTS Is Pingable
    ${conn}=                         Wait Until Keyword Succeeds    20 min    60 sec    Connect to ADMIN
    Wait Until Keyword Succeeds      20m  30s    Wait Until BTS Reach Configured Or OnAir State
    Run Keyword and Ignore Error     Change Parameter on BTS
    ...                              dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                              param_name=enforcedRecovTimeWindow
    ...                              param_value=Enforced recovery enabled within 0 - 90 minutes
    ...                              connection=${conn}
    Change Parameter on BTS          dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                              param_name=minUserNameLength
    ...                              param_value=6
    ...                              connection=${conn}
    Change Parameter on BTS          dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                              param_name=maxUserNameLength
    ...                              param_value=14
    ...                              connection=${conn}
    Install Software On BTS          ${old_soft_path}
    Sleep  60                        reason=Waiting to restart system
    Wait Until Keyword Succeeds      20m  30s   Check If BTS Is Pingable
    ${conn}=                         Wait Until Keyword Succeeds    20 min    60 sec    Connect to ADMIN
    Wait Until Keyword Succeeds      20m  30s    Wait Until BTS Reach Configured Or OnAir State
    ${status}=                       Run Keyword and Return Status    Change Parameter on BTS
    ...                              dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                              param_name=minUserNameLength
    ...                              param_value=6
    ...                              connection=${conn}
    Should not be True               ${status}
    ${status}=                       Run Keyword and Return Status    Change Parameter on BTS
    ...                              dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                              param_name=maxUserNameLength
    ...                              param_value=12
    ...                              connection=${conn}
    Should not be True               ${status}
    [Teardown]                       Run Keywords    Install Software On BTS    ${current_soft_path}
    ...    AND                       Sleep  60       reason=Waiting to restart system
    ...    AND                       Wait Until Keyword Succeeds     20m    30s   Check If BTS Is Pingable
    ...    AND                       Wait Until Keyword Succeeds     20 min    60 sec    Connect to ADMIN
    ...    AND                       Wait Until Keyword Succeeds     20m  30s
    ...                              Wait Until BTS Reach Configured Or OnAir State
    ...    AND                       Run Keyword and Ignore Error     Change Parameter on BTS
    ...                              dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                              param_name=enforcedRecovTimeWindow
    ...                              param_value=Enforced recovery enabled within 0 - 90 minutes
    ...                              connection=admin
    ...    AND                       Run Keyword and Ignore Error    Disconnect from ADMIN    admin
    ...    AND                       Run    rm ${old_soft_path}
    ...    AND                       Run    rm ${current_soft_path}

Complexity_rules_for_user_BTS_System_Administrator_via_WebEM
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                        param_name=minUserNameLength       param_value=5
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                        param_name=maxUserNameLength       param_value=15

    FOR  ${index}  IN RANGE  0  5
        ${passed}=  Run Keyword And Return Status    Change Local User Account Username
        ...  old_username=Nemuadmin    old_password=nemuuser    new_username=${userNames}[${index}]
        Log  ${index}  console=True
        Should Not Be True    ${passed}
    END

    [Teardown]    Run Keywords
    ...           Change Parameter on BTS
    ...           dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...           param_name=minUserNameLength    param_value=4
    ...    AND    Change Parameter on BTS
    ...           dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...           param_name=maxUserNameLength    param_value=16

Complexity_rules_for_user_BTS_Security_Administrator_via_WebEM
    Setup Local user account    account_type=BTSSecurity    new_password=Pl(FzaYj5~c5;q
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=minUserNameLength       param_value=5
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=maxUserNameLength       param_value=15

    FOR  ${index}  IN RANGE  0  5
        ${passed}=  Run Keyword And Return Status    Change Local User Account Username
        ...  old_username=BTSSecurity    old_password=Pl(FzaYj5~c5;q    new_username=${userNames}[${index}]
        Log  ${index}  console=True
        Should Not Be True    ${passed}
    END

    [Teardown]    Run Keywords
    ...           Change Parameter on BTS
    ...           dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...           param_name=minUserNameLength       param_value=4
    ...    AND    Change Parameter on BTS
    ...           dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...           param_name=maxUserNameLength       param_value=16

Complexity_rules_or_user_BTS_Application_Administrator_via_WebEM
    Setup Local user account    account_type=BTSApplication    new_password=Pl(FzaYj5~c5;q
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=minUserNameLength       param_value=5
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=maxUserNameLength       param_value=15

    FOR  ${index}  IN RANGE  0  5
        ${passed}=  Run Keyword And Return Status    Change Local User Account Username
        ...  old_username=BTSApplication   old_password=Pl(FzaYj5~c5;q    new_username=${userNames}[${index}]
        Log  ${index}  console=True
        Should Not Be True    ${passed}
    END

    [Teardown]    Run Keywords
    ...           Change Parameter on BTS
    ...           dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...           param_name=minUserNameLength       param_value=4
    ...    AND    Change Parameter on BTS
    ...           dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...           param_name=maxUserNameLength       param_value=16

Complexity_rules_for_user_BTS_Read_Only_User_via_WebEM
    Setup Local user account    account_type=BTSRead    new_password=Pl(FzaYj5~c5;q
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=minUserNameLength       param_value=5
    Change Parameter on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                         param_name=maxUserNameLength       param_value=15

    FOR  ${index}  IN RANGE  0  5
        ${passed}=  Run Keyword And Return Status    Change Local User Account Username
        ...  old_username=BTSRead   old_password=Pl(FzaYj5~c5;q    new_username=${userNames}[${index}]
        Log  ${index}  console=True
        Should Not Be True    ${passed}
    END

    [Teardown]    Run Keywords
    ...           Change Parameter on BTS
    ...           dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...           param_name=minUserNameLength       param_value=4
    ...    AND    Change Parameter on BTS
    ...           dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...           param_name=maxUserNameLength       param_value=16

Check_Address_Space_layout_randomization_ASLR_activation
    [Arguments]       ${topology}    ${nr}
    ${nr}=            Convert to Integer    ${nr}
    Connect to BTS
    ${output}=        ssh.execute    command=chk sysbshtopo | grep -E '${topology}.*ok|ok.*${topology}'
    ...               connection=cOAM_toor4nsn
    ${bsh}=           get_right_bsh    ${output}    ${nr}
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn  oZPS0POrRieRtu
    Sleep    5          reason=Wait until terminal execute the command
    SSHLibrary.Write    bsh ${bsh}
    Sleep    3          reason=Wait until terminal execute the command
    SSHLibrary.Write    cat /proc/sys/kernel/randomize_va_space
    Sleep    3          reason=Wait until terminal execute the command
    ${value}=           SSHLibrary.Read
    Should Contain      ${value}    2\r\n
    [Teardown]          Run Keywords    Disconnect from BTS    cOAM_toor4nsn
    ...    AND          SSHLibrary.Close Connection

Enable_Address_Space_Layout_Randomization_ASLR
    [Arguments]       ${topology}    ${nr}
    ${nr}=            Convert to Integer    ${nr}
    Connect to BTS
    ${output}=        ssh.execute    command=chk sysbshtopo | grep -E '${topology}.*ok|ok.*${topology}'
    ...               connection=cOAM_toor4nsn
    ${bsh}=           get_right_bsh    ${output}    ${nr}
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn  oZPS0POrRieRtu
    Sleep    5          reason=Wait until terminal execute the command
    SSHLibrary.Write    bsh ${bsh}
    Sleep    3          reason=Wait until terminal execute the command
    SSHLibrary.Write    cat /proc/sys/kernel/randomize_va_space
    Sleep    3          reason=Wait until terminal execute the command
    ${value}=           SSHLibrary.Read
    Should Contain      ${value}    2\r\n
    SSHLibrary.Write    sysctl -w kernel.randomize_va_space=1
    Sleep    3          reason=Wait until terminal execute the command
    SSHLibrary.Write    cat /proc/sys/kernel/randomize_va_space
    Sleep    3          reason=Wait until terminal execute the command
    ${value}=           SSHLibrary.Read
    Should Contain      ${value}    1\r\n
    SSHLibrary.Write    sysctl -w kernel.randomize_va_space=2
    Sleep    3          reason=Wait until terminal execute the command
    SSHLibrary.Write    cat /proc/sys/kernel/randomize_va_space
    Sleep    3          reason=Wait until terminal execute the command
    ${value}=           SSHLibrary.Read
    Should Contain      ${value}    2\r\n
    [Teardown]          Run Keywords    Disconnect from BTS    cOAM_toor4nsn
    ...    AND          SSHLibrary.Close Connection

Removal_of_TLS1.1_support_from_BTS-Emsim
    Setup environment for EMSSIM
    ${status}=                 Run Keyword and Return Status    Change Parameter on BTS
    ...                        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=tls11Enabled
    ...                        param_value=true
    Should not be True         ${status}
    ${status}=                 Run Keyword and Return Status    Change Parameter on BTS
    ...                        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=tls11EnabledStatus
    ...                        param_value=true
    Should not be True         ${status}
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=tls12Enabled
    ...                        param_value=true
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=actEnableTLSv13
    ...                        param_value=true
    Start Tcpdump
    Sleep    3                 Waiting for package
    ${emssim_connection}=      Connect and Activate EMSSIM    cert_type=RSA
    Sleep    3                 Waiting for package
    ${pcap_path}=              Stop Tcpdump And Download Pcap
    Convert pcap to XML        ${pcap_path}    tls.handshake.type==1 && ip.src==${MPLANE_IPV4}    ${CURDIR}/pcap_to_check.txt
    ${inside_pcap}=            OperatingSystem.Get File    ${CURDIR}/pcap_to_check.txt
    Should not Contain         ${inside_pcap}    'TLS_DHE_RSA_WITH_AES_256_CBC_SHA '
    Should not Contain         ${inside_pcap}    'TLS_RSA_WITH_AES_256_CBC_SHA '
    Should not Contain         ${inside_pcap}    'TLS_DHE_RSA_WITH_AES_128_CBC_SHA '
    Should not Contain         ${inside_pcap}    'TLS_RSA_WITH_AES_128_CBC_SHA '
    Should not Contain         ${inside_pcap}    'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA '
    Should not Contain         ${inside_pcap}    'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA '
    Should not Contain         ${inside_pcap}    'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA '
    [Teardown]                 Run Keywords  Disconnect From EMSSIM    ${emssim_connection}
    ...    AND                 Change Parameter on BTS
    ...                        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                        param_name=actRemoteSyslogTransmission
    ...                        param_value=false
    ...    AND                 Run Keyword and Ignore Error    Stop Tcpdump And Download Pcap

Removal_of_TLS1.1_support_from_BTS-supported_ciphers
    Setup environment for EMSSIM    tls_version=1_2
    ${status}=                 Run Keyword and Return Status    Change Parameter on BTS
    ...                        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=tls11Enabled
    ...                        param_value=true
    Should not be True         ${status}
    ${status}=                 Run Keyword and Return Status    Change Parameter on BTS
    ...                        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=tls11EnabledStatus
    ...                        param_value=true
    Should not be True         ${status}
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=tls12Enabled
    ...                        param_value=true
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=actEnableTLSv13
    ...                        param_value=false
    Start Tcpdump
    Sleep    3                 Waiting for package
    ${emssim_connection}=      Connect and Activate EMSSIM    cert_type=RSA
    Sleep    3                 Waiting for package
    ${pcap_path}=              Stop Tcpdump And Download Pcap
    Convert pcap to XML        ${pcap_path}    tls.handshake.type==1 && ip.src==${MPLANE_IPV4}    ${CURDIR}/pcap_to_check.txt
    ${inside_pcap}=            OperatingSystem.Get File    ${CURDIR}/pcap_to_check.txt
    Should Contain             ${inside_pcap}    TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
    Should Contain             ${inside_pcap}    TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_256_CBC_SHA256
    Should Contain             ${inside_pcap}    TLS_RSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_RSA_WITH_AES_256_CBC_SHA256
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_128_GCM_SHA256
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_128_CBC_SHA256
    Should Contain             ${inside_pcap}    TLS_RSA_WITH_AES_128_GCM_SHA256
    Should Contain             ${inside_pcap}    TLS_RSA_WITH_AES_128_CBC_SHA256
    Disconnect From EMSSIM     ${emssim_connection}
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=tls12CbcCipherDisabled
    ...                        param_value=true
    Start Tcpdump
    Sleep    3                 Waiting for package
    ${emssim_connection}=      Connect and Activate EMSSIM    cert_type=RSA
    Sleep    3                 Waiting for package
    ${pcap_path}=              Stop Tcpdump And Download Pcap
    Convert pcap to XML        ${pcap_path}    tls.handshake.type==1 && ip.src==${MPLANE_IPV4}    ${CURDIR}/pcap_to_check.txt
    ${inside_pcap}=            OperatingSystem.Get File    ${CURDIR}/pcap_to_check.txt
    Should Contain             ${inside_pcap}    TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
    Should Contain             ${inside_pcap}    TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_RSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_128_GCM_SHA256
    Should Contain             ${inside_pcap}    TLS_RSA_WITH_AES_128_GCM_SHA256
    Disconnect From EMSSIM     ${emssim_connection}
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=tls12CbcCipherDisabled
    ...                        param_value=false
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=tls12RsaKExDisabled
    ...                        param_value=true
    Start Tcpdump
    Sleep    3                 Waiting for package
    ${emssim_connection}=      Connect and Activate EMSSIM    cert_type=RSA
    Sleep    3                 Waiting for package
    ${pcap_path}=              Stop Tcpdump And Download Pcap
    Convert pcap to XML        ${pcap_path}    tls.handshake.type==1 && ip.src==${MPLANE_IPV4}    ${CURDIR}/pcap_to_check.txt
    ${inside_pcap}=            OperatingSystem.Get File    ${CURDIR}/pcap_to_check.txt
    Should Contain             ${inside_pcap}    TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
    Should Contain             ${inside_pcap}    TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_256_CBC_SHA256
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_128_GCM_SHA256
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_128_CBC_SHA256
    Disconnect From EMSSIM     ${emssim_connection}
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=tls12CbcCipherDisabled
    ...                        param_value=true
    Start Tcpdump
    Sleep    3                 Waiting for package
    ${emssim_connection}=      Connect and Activate EMSSIM    cert_type=RSA
    Sleep    3                 Waiting for package
    ${pcap_path}=              Stop Tcpdump And Download Pcap
    Convert pcap to XML        ${pcap_path}    tls.handshake.type==1 && ip.src==${MPLANE_IPV4}    ${CURDIR}/pcap_to_check.txt
    ${inside_pcap}=            OperatingSystem.Get File    ${CURDIR}/pcap_to_check.txt
    Should Contain             ${inside_pcap}    TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
    Should Contain             ${inside_pcap}    TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_128_GCM_SHA256
    [Teardown]                 Run Keywords    Disconnect From EMSSIM    ${emssim_connection}
    ...    AND                 Change Parameter on BTS
    ...                        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=tls12RsaKExDisabled
    ...                        param_value=false
    ...    AND                 Change Parameter on BTS
    ...                        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=tls12CbcCipherDisabled
    ...                        param_value=false
    ...    AND                 Change Parameter on BTS
    ...                        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                        param_name=actRemoteSyslogTransmission
    ...                        param_value=false
    ...    AND                 Run Keyword and Ignore Error    Stop Tcpdump And Download Pcap

CB008267-D_5GC001599-A_Proxy_ARP_Disabled_ASIA
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn  oZPS0POrRieRtu

    SSHLibrary.Write      cat /proc/sys/net/ipv4/conf/all/proxy_arp
    Sleep    2
    ${value}=           SSHLibrary.Read
    Should Contain      ${value}    0

	SSHLibrary.Write      cat /proc/sys/net/ipv4/conf/default/proxy_arp
    Sleep    2
    ${value}=           SSHLibrary.Read
    Should Contain      ${value}    0

	SSHLibrary.Write      cat /proc/sys/net/ipv6/conf/all/proxy_ndp
    Sleep    2
    ${value}=           SSHLibrary.Read
    Should Contain      ${value}    0

	SSHLibrary.Write      cat /proc/sys/net/ipv6/conf/default/proxy_ndp
    Sleep    2
    ${value}=           SSHLibrary.Read
    Should Contain      ${value}    0

	[Teardown]            SSHLibrary.Close Connection

CB008267-D_5GC001599-A_Perform_Mount_Options_Check_For_ABIA_Loner_ASIA
    @{list}=  Create List  user  nodev  nosuid
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn  oZPS0POrRieRtu

    SSHLibrary.Write      cat /etc/fstab
    Sleep    2
    ${value}=           SSHLibrary.Read
    FOR  ${items}  IN  @{list}
        Should Not Contain  ${value}   ${items}
    END

CB008267-D_5GC001599-A_IPv4_Multicast_Handling_Disabled_ASIA
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn  oZPS0POrRieRtu

    SSHLibrary.Write      ifconfig | grep MULTICAST | awk '{print $1}'
    Sleep   5
    ${value}=           SSHLibrary.Read
    @{list}=           get_interfaces_list    ${value}
    Log To Console  ${list}
    FOR  ${interface}  IN  @{list}
        SSHLibrary.Write      cat /proc/sys/net/ipv4/conf/${interface}/mc_forwarding
        ${value_2}=           SSHLibrary.Read
        check_if_output_matches_value     ${value_2}     0
    END
    [Teardown]            SSHLibrary.Close Connection


CB008267-D_5GC001599-A_IP_Packet_Forwarding_Between_Different_Interfaces_Disabled_ASIA
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn  oZPS0POrRieRtu

    SSHLibrary.Write      cat /proc/sys/net/ipv6/conf/all/forwarding
    Sleep   2
    ${value}=           SSHLibrary.Read
    check_if_output_matches_value     ${value}     0

    SSHLibrary.Write      cat /proc/sys/net/ipv4/ip_forward
    Sleep   2
    ${value}=           SSHLibrary.Read
    check_if_output_matches_value     ${value}     0
    [Teardown]            SSHLibrary.Close Connection

CB008267-D_5GC001599-A_ICMP_Broadcast_Disabled_ASIA
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn  oZPS0POrRieRtu

    SSHLibrary.Write      cat /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
    Sleep   2
    ${value}=           SSHLibrary.Read
    check_if_output_matches_value     ${value}     1

    SSHLibrary.Write      cat /proc/sys/net/ipv4/icmp_echo_ignore_all
    Sleep   2
    ${value}=           SSHLibrary.Read
    check_if_output_matches_value     ${value}     0

    SSHLibrary.Write      cat /proc/sys/net/ipv4/icmp_errors_use_inbound_ifaddr
    Sleep   2
    ${value}=           SSHLibrary.Read
    check_if_output_matches_value     ${value}     0

    SSHLibrary.Write      cat /proc/sys/net/ipv4/conf/all/accept_redirects
    Sleep   2
    ${value}=           SSHLibrary.Read
    check_if_output_matches_value     ${value}     0

    SSHLibrary.Write      cat /proc/sys/net/ipv4/conf/default/accept_redirects
    Sleep   2
    ${value}=           SSHLibrary.Read
   check_if_output_matches_value     ${value}     0

    SSHLibrary.Write      cat /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
    Sleep   2
    ${value}=           SSHLibrary.Read
    check_if_output_matches_value     ${value}     1
    [Teardown]            SSHLibrary.Close Connection

CB008267-D_5GC001599-A_Gratuitous_ARP_Messages_Disabled_ASIA
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn  oZPS0POrRieRtu

    SSHLibrary.Write      grep . /proc/sys/net/ipv4/conf/*/drop_gratuitous_arp
    Sleep   2
    ${value}=           SSHLibrary.Read
    check_if_drop_gratuitous_arp_is_properly_set     ${value}

    SSHLibrary.Write      cat /proc/sys/net/ipv4/conf/all/arp_accept
    Sleep   2
    ${value}=           SSHLibrary.Read
    check_if_output_matches_value     ${value}     0

    SSHLibrary.Write      cat /proc/sys/net/ipv4/conf/all/drop_gratuitous_arp
    Sleep   2
    ${value}=           SSHLibrary.Read
    check_if_output_matches_value     ${value}     0

    SSHLibrary.Write      cat /proc/sys/net/ipv4/conf/default/arp_notify
    Sleep   2
    ${value}=           SSHLibrary.Read
    check_if_output_matches_value     ${value}     0

    SSHLibrary.Write      cat /proc/sys/net/ipv4/conf/default/arp_accept
    Sleep   2
    ${value}=           SSHLibrary.Read
    check_if_output_matches_value     ${value}     0

    SSHLibrary.Write      cat /proc/sys/net/ipv4/conf/default/drop_gratuitous_arp
    Sleep   2
    ${value}=           SSHLibrary.Read
    check_if_output_matches_value     ${value}     0

    SSHLibrary.Write      cat /proc/sys/net/ipv4/conf/all/arp_notify
    Sleep   2
    ${value}=           SSHLibrary.Read
    check_if_output_matches_value     ${value}     0
    [Teardown]            SSHLibrary.Close Connection

CB008267-D_SyVe_BTS_alarms_user_if_SOE_is_NOT_Enabled_NetAct_ASIA
    Setup environment for EMSSIM
    ${emssim_connection}=           Connect and Activate EMSSIM    cert_type=RSA
    Wait until keyword succeeds     5x    1min    execute_command_on_emssim
    ...                             command=edit SECADM-1 ethernetPortSecurityEnabled False
    ...                             connection=${emssim_connection}
    ${conn}=    Connect To Netact
    ${alarms}=  Keywords.get_active_faults_using_netact  ${conn}
    ${correct_alarm_id}=       Convert to Integer    4654
    Should Contain             ${alarms}    ${correct_alarm_id}
    [Teardown]            Run Keywords  Disconnect from Netact  ${conn}  AND
    ...            Wait until keyword succeeds     5x    1min    execute_command_on_emssim
    ...                                            command=edit SECADM-1 ethernetPortSecurityEnabled False
    ...                                            connection=${emssim_connection}

Removal_of_TLS1.1_support_from_BTS-Syslog
    ${status}=                      Run Keyword and Return Status    Change Parameter on BTS
    ...                             dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=tls11Enabled
    ...                             param_value=true
    Should not be True              ${status}
    ${status}=                      Run Keyword and Return Status    Change Parameter on BTS
    ...                             dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=tls11EnabledStatus
    ...                             param_value=true
    Should not be True              ${status}
    ${temp_conn}=                   Connect to ADMIN
    Configure CMP                   ca_subject_name=${ca_subject_name}    connection=${temp_conn}
    Initialize Certificates         connection=${temp_conn}
    Run Keyword and Ignore Error    Disconnect from ADMIN    ${temp_conn}
    Change Parameter on BTS         dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=tls12Enabled
    ...                             param_value=true
    Change Parameter on BTS         dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=actEnableTLSv13
    ...                             param_value=true
    Turn On TLS
    Add remoteSyslogConfig Structure To SCF    ${PARAMS1}
    Wait Until Keyword Succeeds      20m  30s    Wait Until BTS Reach Configured Or OnAir State
    Start Tcpdump
    Sleep    3                 Waiting for package
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                        param_name=actRemoteSyslogTransmission
    ...                        param_value=true
    Sleep    10                Waiting for package
    ${pcap_path}=              Stop Tcpdump And Download Pcap
    Convert pcap to XML        ${pcap_path}    ip.dst==${ip_syslog}
    ...                                        ${CURDIR}/pcap_to_check.txt
    ${inside_pcap}=            OperatingSystem.Get File    ${CURDIR}/pcap_to_check.txt
    Should not Contain         ${inside_pcap}    'TLS_DHE_RSA_WITH_AES_256_CBC_SHA '
    Should not Contain         ${inside_pcap}    'TLS_RSA_WITH_AES_256_CBC_SHA '
    Should not Contain         ${inside_pcap}    'TLS_DHE_RSA_WITH_AES_128_CBC_SHA '
    Should not Contain         ${inside_pcap}    'TLS_RSA_WITH_AES_128_CBC_SHA '
    Should not Contain         ${inside_pcap}    'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA '
    Should not Contain         ${inside_pcap}    'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA '
    Should not Contain         ${inside_pcap}    'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA '
    [Teardown]    Run Keywords    Run Keyword and Ignore Error    Stop Tcpdump And Download Pcap
    ...    AND    Change Parameter on BTS
    ...           dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...           param_name=actRemoteSyslogTransmission
    ...           param_value=false

Removal_of_TLS1.1_support_from_BTS-CNUM_LDAP
    Setup environment for EMSSIM
    ${status}=                 Run Keyword and Return Status    Change Parameter on BTS
    ...                        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=tls11Enabled
    ...                        param_value=true
    Should not be True         ${status}
    ${status}=                 Run Keyword and Return Status    Change Parameter on BTS
    ...                        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=tls11EnabledStatus
    ...                        param_value=true
    Should not be True         ${status}
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=tls12Enabled
    ...                        param_value=false
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=actEnableTLSv13
    ...                        param_value=true
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=tls12RsaKExDisabled
    ...                        param_value=true
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=tls12CbcCipherDisabled
    ...                        param_value=true
    ${conn}=                   Connect to BTS
    ssh.send command           command=reboot    connection=cOAM_toor4nsn
    FOR    ${i}    IN RANGE    300
         ${PING}=    Run    ping -c 2 192.168.255.129
         ${Exit}=    Run Keyword And Return Status    Should Contain    ${PING}    100% packet loss
         Exit For Loop If    ${Exit}==True
    END
    Wait until keyword succeeds     30 min  60sec  Check if BTS status is Configured or OnAir
    Run Keyword and Ignore Error    Disconnect from BTS    ${conn}
    ${status}=                      Run Keyword and Return Status    Change Parameter on BTS
    ...                             dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=tls11Enabled
    ...                             param_value=true
    Should not be True              ${status}
    ${status}=                      Run Keyword and Return Status    Change Parameter on BTS
    ...                             dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=tls11EnabledStatus
    ...                             param_value=true
    Should not be True              ${status}
    ${param_value}=                 Check current parameter value
    ...                             dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=tls12Enabled
    Should Contain                  ${param_value}    False
    ${param_value}=                 Check current parameter value
    ...                             dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=actEnableTLSv13
    Should Contain                  ${param_value}    True
    ${param_value}=                 Check current parameter value
    ...                             dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=tls12RsaKExDisabled
    Should Contain                  ${param_value}    True
    ${param_value}=                 Check current parameter value
    ...                             dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=tls12CbcCipherDisabled
    Should Contain                  ${param_value}    True
    Change Parameter on BTS         dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=tls12Enabled
    ...                             param_value=true
    Change Parameter on BTS         dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=actEnableTLSv13
    ...                             param_value=false
    Start Tcpdump
    Sleep    3                     Waiting for package
    ${emssim_connection}=          Connect and Activate EMSSIM    cert_type=RSA
    Sleep    3                     Waiting for package
    ${pcap_path}=                  Stop Tcpdump And Download Pcap
    Convert pcap to XML            ${pcap_path}    tls.handshake.type==1 && ip.src==${MPLANE_IPV4}    ${CURDIR}/pcap_to_check.txt
    ${inside_pcap}=                OperatingSystem.Get File    ${CURDIR}/pcap_to_check.txt
    Should not Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_256_CBC_SHA
    Should not Contain             ${inside_pcap}    TLS_RSA_WITH_AES_256_CBC_SHA
    Should not Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_128_CBC_SHA
    Should not Contain             ${inside_pcap}    TLS_RSA_WITH_AES_128_CBC_SHA
    Should Contain                 ${inside_pcap}    TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
    Should Contain                 ${inside_pcap}    TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
    [Teardown]                     Run Keywords    Run Keyword and Ignore Error    Disconnect from BTS
    ...    AND                     Disconnect From EMSSIM    ${emssim_connection}
    ...    AND                     Change Parameter on BTS
    ...                            dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                            param_name=actRemoteSyslogTransmission
    ...                            param_value=false
    ...    AND                     Run Keyword and Ignore Error    Stop Tcpdump And Download Pcap

Removal_of_TLS1.1_support_UUF_scenario
    ${current_soft}=                 Get Software Release Name
    ${current_soft}=                 functions_benchmarking.Get Software Version From String    ${current_soft}
    ${old_soft}=                     functions_benchmarking.Get Software Version From String
    ...                              SBTS00_ENB_9999_230416_000018
    ${current_soft_path}=            Wait until keyword succeeds    10x    1min
    ...                              Download New Software Version From Remote Repository    ${current_soft}
    ${old_soft_path}=                Wait until keyword succeeds    10x    1min
    ...                              Download New Software Version From Remote Repository    ${old_soft}
    Install Software On BTS          ${old_soft_path}
    Sleep  60                        reason=Waiting to restart system
    Wait Until Keyword Succeeds      20m  30s   Check If BTS Is Pingable
    ${conn}=                         Wait Until Keyword Succeeds    20 min    60 sec    Connect to ADMIN
    Wait Until Keyword Succeeds      20m  30s    Wait Until BTS Reach Configured Or OnAir State
    ${try}=                          Run keyword and Ignore Error    Change Parameter on BTS
    ...                              dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                              param_name=oamTls
    ...                              param_value=off
    ${errors}=                       Convert to String    ${try}
    ${parameter}=                    Convert to String    tls11Enabled
    Should Contain                   ${errors}    ${parameter}
    ${value}=                        Check current parameter value
    ...                              dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                              param_name=tls12Enabled
    Should Contain Any               ${value}    True    False
    ${value}=                        Check current parameter value
    ...                              dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                              param_name=actEnableTLSv13
    Should Contain Any               ${value}    True    False
    Install Software On BTS          ${current_soft_path}
    Sleep  60                        reason=Waiting to restart system
    Wait Until Keyword Succeeds      20m  30s   Check If BTS Is Pingable
    ${conn}=                         Wait Until Keyword Succeeds    20 min    60 sec    Connect to ADMIN
    Wait Until Keyword Succeeds      20m  30s    Wait Until BTS Reach Configured Or OnAir State
    Run Keyword and Ignore Error     Change Parameter on BTS
    ...                              dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                              param_name=enforcedRecovTimeWindow
    ...                              param_value=Enforced recovery enabled within 0 - 90 minutes
    ...                              connection=${conn}
    Disconnect from ADMIN            admin
    ${status}=                       Run Keyword and Return Status    Change Parameter on BTS
    ...                              dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                              param_name=tls11Enabled
    ...                              param_value=true
    Should not be True               ${status}
    ${status}=                       Run Keyword and Return Status    Change Parameter on BTS
    ...                              dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                              param_name=tls11EnabledStatus
    ...                              param_value=true
    Should not be True               ${status}
    Change Parameter on BTS          dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                              param_name=tls12Enabled
    ...                              param_value=true
    Change Parameter on BTS          dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                              param_name=actEnableTLSv13
    ...                              param_value=false
    [Teardown]                       Run Keywords    Run Keyword and Ignore Error    Disconnect from ADMIN    admin
    ...    AND                       Run    rm ${old_soft_path}
    ...    AND                       Run    rm ${current_soft_path}

Removal_of_TLS1.1_support_from_BTS-WEB_browser
    ${status}=                 Run Keyword and Return Status    Change Parameter on BTS
    ...                        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=tls11Enabled
    ...                        param_value=true
    Should not be True         ${status}
    ${status}=                 Run Keyword and Return Status    Change Parameter on BTS
    ...                        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=tls11EnabledStatus
    ...                        param_value=true
    Should not be True         ${status}
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=tls12Enabled
    ...                        param_value=true
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        param_name=actEnableTLSv13
    ...                        param_value=true
    sbts.Enable Virtual Display
    Start Tcpdump on SMOD via SSH
    Sleep    3                         Waiting for package
    ${browser}=                        open_browser
    switch_tls_on_browser_to_1         ${browser}    about:config
    ${status}=                         Run Keyword and Return Status    try_to_open_webem    ${browser}
    Should not be True                 ${status}
    Sleep    3                         Waiting for package
    ${pcap_path}=                      Stop Tcpdump on SMOD And Download Pcap Via SSH
    Convert pcap to XML                ${pcap_path}.pcap    tls
    ...                                ${CURDIR}/pcap_to_check.txt
    ${inside_pcap}=                    OperatingSystem.Get File    ${CURDIR}/pcap_to_check.txt
    Should not Contain                 ${inside_pcap}    'TLS_DHE_RSA_WITH_AES_256_CBC_SHA '
    Should not Contain                 ${inside_pcap}    'TLS_RSA_WITH_AES_256_CBC_SHA '
    Should not Contain                 ${inside_pcap}    'TLS_DHE_RSA_WITH_AES_128_CBC_SHA '
    Should not Contain                 ${inside_pcap}    'TLS_RSA_WITH_AES_128_CBC_SHA '
    Should not Contain                 ${inside_pcap}    'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA '
    Should not Contain                 ${inside_pcap}    'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA '
    Should not Contain                 ${inside_pcap}    'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA '
    click_prefResetButton              ${browser}
    login_to_webem_with_default_tls    ${browser}
    [Teardown]                         Run Keywords    Keywords.close_browser    ${browser}
    ...    AND                         sbts.Disable Virtual Display
    ...    AND                         Change Parameter on BTS
    ...                                dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                param_name=actRemoteSyslogTransmission
    ...                                param_value=false
    ...    AND                         Run Keyword and Ignore Error    Stop Tcpdump on SMOD And Download Pcap Via SSH
