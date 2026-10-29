*** Settings ***
Documentation
...  author:     Grzegorz Niedzwiedz
...  contact:    grzegorz.niedzwiedz@nokia.com

Resource    ./../Resources/CB012204_keywords.robot
Library     taf.sbts.oam.coam.admin    WITH NAME    coam_admin
Library     ./../Resources/resources_12204.py


*** Keywords ***
[1]CB012204-A_Local_user_accounts_default_passwords_update_suppression_and_enforcement_with_alarm_check
    Log   Collecting scf    console=true
    ${connection}=  admin.Connect to ADMIN
    ${scf_path}=  admin.Download SCF  connection=${connection}
    Disconnect from ADMIN   ${connection}
    ${sw_release}=  Get Software Release Name
    Log    ${sw_release}    console=true
	Check if alarm 4459 is present on BTS    true
    Check if alarm 4459 is present on BTS    false
    Log    Checking ssh connection for toor4nsn and serviceuser using default passwords   console=true
    Check ssh connection    ${toor_login}       ${default_root_password}            read_until=root
    Check ssh connection    ${service_login}    ${default_serviceuser_password}     read_until=serviceuser
    Change Parameter On BTS    MRBTS-${BTS_ID}/MNL-1/AMGR-1  enableDefaultPasswdAlarm  true
    Change Parameter On BTS    MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1  allowLocalUserDefaultPassword  false
    ${driver}=  resources_12204.Log To Webem    username=${DEFAULT_ADMIN_USERNAME}    password=${DEFAULT_ADMIN_PASS}
    resources_12204.Update Passwords  driver=${driver}    admin_pass=${NEMUADMIN_NEW_PASS}
    ...               serviceuser_pass=${NEW_SERVICEUSER_PASSWORD}    toor4nsn_pass=${NEW_ROOT_PASSWORD}
    ${connection}=    coam_admin.connect_to   bts_host=${HOST_IP}     username=${DEFAULT_ADMIN_USERNAME}  password=${NEMUADMIN_NEW_PASS}
    Alarm Should be Active In BTS    fault_id=4459    connection=${connection}
    Log   Alarm 4459 is active on BTS    console=true
    Change password for BTS Data Collection User
    Change password for wsuser
    Sleep  10
    Alarm Should not be Active In BTS    fault_id=4459    connection=${connection}
    Log    Alarm 4459 is inactive on BTS   console=true
    Log    Checking ssh connection for toor4nsn and serviceuser using new passwords    console=true
    Check ssh connection    ${toor_login}       ${new_root_password}            read_until=root
    Check ssh connection    ${service_login}    ${new_serviceuser_password}     read_until=serviceuser
    [Teardown]     Run Keywords
    ...            Run Keyword And Ignore Error   Disconnect from ADMIN   ${connection}
    ...            AND   Configuration Reset   new_pass=${NEMUADMIN_NEW_PASS}    scf_path=${scf_path}
