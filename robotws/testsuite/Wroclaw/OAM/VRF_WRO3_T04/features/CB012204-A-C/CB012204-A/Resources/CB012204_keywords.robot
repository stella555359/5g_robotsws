*** Settings ***
Documentation
...  author:     Grzegorz Niedzwiedz
...  contact:    grzegorz.niedzwiedz@nokia.com

Resource    ./../../../../common_resources/admin/admin.robot
Resource    ./../../../../common_resources/passwords/password_change.robot
Resource    ./../../../../common_resources/commissioning/parameters.robot
Resource    ./../../../../common_resources/alarms/alarm.robot
Library     taf.sbts.oam.coam.admin    WITH NAME    coam_admin
#Library     taf.fdsw.rc                                WITH NAME    rescue
Library     taf.transport.ssh  WITH NAME  ssh
Library     SSHLibrary

*** Variables ***
${DEFAULT_ADMIN_USERNAME}           Nemuadmin
${DEFAULT_ADMIN_PASS}               nemuuser
${NEMUADMIN_NEW_PASS}               Qwerty12#
${DEFAULT_ROOT_PASSWORD}            oZPS0POrRieRtu
${NEW_ROOT_PASSWORD}                Qwerty14#
${DEFAULT_SERVICEUSER_PASSWORD}     Pl(FzaYj5~c5;q
${NEW_SERVICEUSER_PASSWORD}         Qwerty13#
${HOST_IP}                          192.168.255.129
${TOOR_LOGIN}                       toor4nsn
${SERVICE_LOGIN}                    serviceuser
${WSUSER_PASS}                      A0zY~rP#8Mx@
${NEW_PASSWORD}                     Qwerty1234!

*** Keywords ***

Check SSH Connection
    [Arguments]    ${login}    ${pwd}    ${read_until}
    Log    Establishing ssh connection    console=true
    ${ssh_conn}  SSHLibrary.Open Connection  host=${HOST_IP}
    ${login_output}  SSHLibrary.Login  ${login}  ${pwd}
    Log    Checking account information:    console=true
    SSHLibrary.Write  whoami
    ${output}  SSHLibrary.Read Until  ${read_until}
    Log   Printing information about logged account: ${output}    console=true
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close All Connections

Check If Alarm 4459 Is Present On BTS
    [Arguments]    ${value}
    ${connection}=  admin.Connect to ADMIN
    Log    Parameter enableDefaultPasswdAlarm change to TRUE    console=true
    Change Parameter On BTS    MRBTS-${BTS_ID}/MNL-1/AMGR-1  enableDefaultPasswdAlarm  ${value}  connection=${connection}
    Run keyword if  '${value}'=='true'      Run keywords        Alarm Should be Active In BTS    4459
    ...             AND                                         Log   Alarm 4459 is active on BTS    console=true
    ...             ELSE                    Run keywords        Alarm Should not be Active In BTS    4459
    ...             AND                                         Log    Alarm 4459 is inactice on BTS   console=true
    [Teardown]    Run Keyword And Ignore Error
    ...           admin.Disconnect From ADMIN


Change Password For BTS Data Collection User
    [Arguments]    ${old_username}=dcuser    ${old_password}=${EMPTY}    ${connection}=${NONE}
    ${connection}=    coam_admin.connect_to   bts_host=${HOST_IP}     username=${DEFAULT_ADMIN_USERNAME}  password=${NEMUADMIN_NEW_PASS}
    coam_admin.set_user_account         old_username=${old_username}
    ...                                 old_password=${old_password}
    ...                                 new_password=${NEW_PASSWORD}
    ...                                 connection=${connection}
    [Teardown]    Run Keyword And Ignore Error
    ...           admin.Disconnect From ADMIN    connection=${connection}

Change Password For Wsuser
    ${connection}=    coam_admin.connect_to   bts_host=${HOST_IP}    username=${DEFAULT_ADMIN_USERNAME}  password=${NEMUADMIN_NEW_PASS}
    Setup Service User Account          username=wsuser
    ...                                                 old_password=${WSUSER_PASS}
    ...                                                 new_password=${NEW_PASSWORD}
    ...                                                 connection=${connection}
    [Teardown]    Run Keyword And Ignore Error
    ...           admin.Disconnect From ADMIN    connection=${connection}
