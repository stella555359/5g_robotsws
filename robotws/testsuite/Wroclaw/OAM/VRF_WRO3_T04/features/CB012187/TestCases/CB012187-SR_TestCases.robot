*** Settings ***
Documentation
...    author:          Patryk Tatarek
...    contact:         patryk.tatarek@nokia.com
...    Test Plan (QC):  /VRF_WRO3_T04/25R2/CB012187/
...    Description:     Verify that AllowedLifetime and AllowedIdlePeriod parameters are working as they shoould.

Resource    ../Resources/CB012187-SR_Keywords.robot
Resource    ../../../common_resources/connections/connections.robot
Resource    ../../../common_resources/netact/netact_operations.robot
Resource    ../../../common_resources/emssim/emssim_setup.robot
Resource    ../../../common_resources/emssim/emssim.robot
Resource    ../../../common_resources/commissioning/commissioning.robot
Resource    ../../../common_resources/passwords/password_change.robot

Library     DateTime

*** Variables ***

${SERVICEUSER_USERNAME}=    serviceuser
${SERVICEUSER_PASSWORD}=    Pl(FzaYj5~c5;q

${emssim_system_username}=      BTSSystem
${emssim_app_username}=         BTSApplication
${emssim_sec_username}=         BTSSecurity
${emssim_readonly_username}=    BTSRead
${emssim_password}=             Nokia@1234

${stress_conns}=                6     #Number of connections (+1) as System Admin or Read Only (not both)
${stress_attempts}=             11    #Number of repetitions (+1)

${period_update}=               Inactivity_Period_Update
${lifetime_update}=             Lifetime_Update

*** Keywords ***
Check_if_non-BTS_local_user_accounts_are_blocked
    Log                           Step 1: Login as toor4nsn    console=True
    ${conn_toor4nsn}=             Connect with SSH    ip_addr=${LMP_IP}
    ...                                               user=${SSH_USERNAME}
    ...                                               password=${SSH_PASSWORD}
    ...                                               alias=temp_conn_toor4nsn
    Log                           Step 2: Login as serviceuser    console=True
    ${conn_serviceuser}=          Connect with SSH    ip_addr=${LMP_IP}
    ...                                               user=${SERVICEUSER_USERNAME}
    ...                                               password=${SERVICEUSER_PASSWORD}
    ...                                               alias=temp_conn_serviceuser
    Log                           Step 3: Verify dcuser is available    console=True
    Change Parameter on BTS       dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                           param_name=actDccSupport
    ...                           param_value=true
    ${dcuser_config}=             Execute    command=cat /ffs/run/config/dcusers.json
    ...                                      connection=${conn_toor4nsn}
    ${expected}=                  Convert to String    "isActive": "Active"
    Should Contain                ${dcuser_config}    ${expected}
    Log                           Step 4: Login as wsuser    console=True
    ${conn_wsuser}=               Connect to NetAct
    [Teardown]    Run Keywords    Disconnect SSH Session     ${conn_toor4nsn}
    ...    AND                    Disconnect SSH Session     ${conn_serviceuser}
    ...    AND                    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                                      param_name=actDccSupport    param_value=false
    ...    AND                    Disconnect from NetAct     ${conn_wsuser}

BTS_Local_user_parameters_shall_be_synchronised_between_the_installed_SWs
    Log                           Step 1: Connect as Nemuadmin    console=True
    ${connection}=                Connect to ADMIN
    Log                           Step 2: Enable actLoginCredPartitionSync    console=True
    Change Parameter on BTS       dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                           param_name=actLoginCredPartitionSync
    ...                           param_value=true
    ...                           connection=${connection}
    Log                           Step 3: Connect as toor4nsn    console=True
    ${conn_toor4nsn}=             Connect with SSH    ip_addr=${LMP_IP}
    ...                                               user=${SSH_USERNAME}
    ...                                               password=${SSH_PASSWORD}
    ...                                               alias=temp_conn_toor4nsn
    Log                           Step 4: Check idlePeriodExpTimeStamp value on both partitions    console=True
    ${fs1_idlePeriod}=            Execute    command=cat /ffs/fs1/config/users.json | grep idlePeriodExpTimeStamp
    ...                                      connection=${conn_toor4nsn}
    ${fs2_idlePeriod}=            Execute    command=cat /ffs/fs2/config/users.json | grep idlePeriodExpTimeStamp
    ...                                      connection=${conn_toor4nsn}
    Should be Equal               ${fs1_idlePeriod}    ${fs2_idlePeriod}
    Log                           Step 5: Disable actLoginCredPartitionSync    console=True
    Change Parameter on BTS       dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                           param_name=actLoginCredPartitionSync
    ...                           param_value=false
    ...                           connection=${connection}
    Log                           Step 6-9: Adjust LifeTime/IdlePeriod parameters    console=True
    Change Multiple Parameters on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                  sysAdmAllowedLifetime=100
    ...                                  sysAdmAllowedIdlePeriod=100
    ...                                  localUserAllowedLifetime=100
    ...                                  localUserAllowedIdlePeriod=100
    ...                                  connection=${connection}
    Log                           Step 10-15: Verify ExpDate parameters    console=True
    ${sysAdmLifetime}=            Check current parameter value    param_name=sysAdmLifetimeExpDate
    ...                                                            connection=${connection}
    ${sysAdmIdlePer}=             Check current parameter value    param_name=sysAdmIdlePerExpDate
    ...                                                            connection=${connection}
    ${localUserLifetime}=         Check current parameter value    param_name=localUserLifetimeExpDate
    ...                                                            connection=${connection}
    ${secAdmIdlePer}=             Check current parameter value    param_name=secAdmIdlePerExpDate
    ...                                                            connection=${connection}
    ${appAdmIdlePer}=             Check current parameter value    param_name=appAdmIdlePerExpDate
    ...                                                            connection=${connection}
    ${readOnlyIdlePer}=           Check current parameter value    param_name=readOnlyIdlePerExpDate
    ...                                                            connection=${connection}
    ${currentDate}=               Get Current Date
    ${currentDateUTC}=            Subtract Time From Date    ${currentDate}     2h
    ${expectedDate_plus}=         Add Time to Date    date=${currentDateUTC}    time=101 days
    ${expectedDate}=              Fetch From Left     ${expectedDate_plus}      ${SPACE}
    Run Keyword and Continue on Failure    Should Contain    ${sysAdmLifetime}       ${expectedDate}
    # We can't check that one because of the other system admin connections
    # Run Keyword and Continue on Failure    Should Contain    ${sysAdmIdlePer}        ${expectedDate}
    Run Keyword and Continue on Failure    Should Contain    ${localUserLifetime}    ${expectedDate}
    Run Keyword and Continue on Failure    Should Contain    ${secAdmIdlePer}        ${expectedDate}
    Run Keyword and Continue on Failure    Should Contain    ${appAdmIdlePer}        ${expectedDate}
    Run Keyword and Continue on Failure    Should Contain    ${readOnlyIdlePer}      ${expectedDate}
    Log                           Step 16: Check idlePeriodExpTimeStamp Fvalue on both partitions    console=True
    ${fs1_idlePeriod_sec}=        Execute    command=cat /ffs/fs1/config/users.json | grep idlePeriodExpTimeStamp
    ...                                      connection=${conn_toor4nsn}
    ${fs2_idlePeriod_sec}=        Execute    command=cat /ffs/fs2/config/users.json | grep idlePeriodExpTimeStamp
    ...                                      connection=${conn_toor4nsn}
    Should not be Equal           ${fs1_idlePeriod_sec}    ${fs2_idlePeriod_sec}
    Log                           Step 17: Enable actLoginCredPartitionSync    console=True
    Change Parameter on BTS       dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                           param_name=actLoginCredPartitionSync
    ...                           param_value=true
    ...                           connection=${connection}
    Log                           Step 18: Check idlePeriodExpTimeStamp value on both partitions    console=True
    ${fs1_idlePeriod}=            Execute    command=cat /ffs/fs1/config/users.json | grep idlePeriodExpTimeStamp
    ...                                      connection=${conn_toor4nsn}
    ${fs2_idlePeriod}=            Execute    command=cat /ffs/fs2/config/users.json | grep idlePeriodExpTimeStamp
    ...                                      connection=${conn_toor4nsn}
    Should be Equal               ${fs1_idlePeriod}    ${fs2_idlePeriod}
    [Teardown]    Run Keywords    Disconnect from ADMIN     ${connection}
    ...    AND                    Delete Allowed parameters
    ...    AND                    Disconnect SSH Session    ${conn_toor4nsn}

Configuration_of_Allowed_lifetime_&_Allowed_Idle_period_from_WebEM_without_privileges
    Log                                  Step 1/9: Connect as BTS Application Admin    console=True
    Setup Local user account             account_type=${emssim_app_username}
    ...                                  new_password=${SERVICEUSER_PASSWORD}
    ${conn_app}=                         Connect to ADMIN
    ...                                  username=${emssim_app_username}
    ...                                  password=${SERVICEUSER_PASSWORD}
    Log                                  Step 2/10: Try to change parameters    console=True
    Run Keyword and Expect Error         *    Change Multiple Parameters on BTS
    ...                                  dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                  sysAdmAllowedLifetime=100
    ...                                  sysAdmAllowedIdlePeriod=100
    ...                                  retry=${1}    connection=${conn_app}
    Run Keyword and Expect Error         *    Change Multiple Parameters on BTS
    ...                                  dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                  localUserAllowedLifetime=100
    ...                                  localUserAllowedIdlePeriod=100
    ...                                  retry=${1}    connection=${conn_app}
    Disconnect from ADMIN                ${conn_app}
    Log                                  Step 3/9: Connect as BTS Read Only User    console=True
    Setup Local user account             account_type=${emssim_readonly_username}
    ...                                  new_password=${SERVICEUSER_PASSWORD}
    ${conn_readonly}=                    Connect to ADMIN
    ...                                  username=${emssim_readonly_username}
    ...                                  password=${SERVICEUSER_PASSWORD}
    Log                                  Step 4/11: Try to change parameters    console=True
    Run Keyword and Expect Error         *    Change Multiple Parameters on BTS
    ...                                  dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                  sysAdmAllowedLifetime=100
    ...                                  sysAdmAllowedIdlePeriod=100
    ...                                  retry=${1}    connection=${conn_readonly}
    Run Keyword and Expect Error         *    Change Multiple Parameters on BTS
    ...                                  dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                  localUserAllowedLifetime=100
    ...                                  localUserAllowedIdlePeriod=100
    ...                                  retry=${1}    connection=${conn_readonly}
    Disconnect from ADMIN                ${conn_readonly}
    Log                                  Step 5: Connect as CNUM Application Admin    console=True
    Setup environment for EMSSIM
    Change Parameter On BTS              dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                  param_name=actRestrictLoginToCnum
    ...                                  param_value=true
    ${emssim_connection}=                Connect and Activate EMSSIM    cert_type=RSA
    Wait Until Keyword Succeeds          3x    30s    execute_command_on_emssim
    ...                                  command=edit appAdmActivated.LUAC-1-1-1 true
    ...                                  connection=${emssim_connection}
    Sleep    90                          reason=Executing command
    Wait Until Keyword Succeeds          3x    30s    execute_command_on_emssim
    ...                                  command=ldap_user_add ${emssim_app_username} ${emssim_password} -a RW
    ...                                  connection=${emssim_connection}
    Sleep    30                          reason=Executing command
    ${command}=                          Catenate    user_info_update -username ${emssim_app_username} -password
    ...                                              ${emssim_password} -type bts_application -status enabled
    Wait Until Keyword Succeeds          3x    30s    execute_command_on_emssim    command=${command}
    ...                                  connection=${emssim_connection}
    Sleep    90                          reason=Executing command
    ${conn_cnum_app}=                    Connect to ADMIN
    ...                                  username=${emssim_app_username}
    ...                                  password=${emssim_password}
    ...                                  timeout=${180}
    Log                                  Step 6/12: Try to change parameters    console=True
    Run Keyword and Expect Error         *    Change Multiple Parameters on BTS
    ...                                  dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                  sysAdmAllowedLifetime=100
    ...                                  sysAdmAllowedIdlePeriod=100
    ...                                  retry=${1}    connection=${conn_cnum_app}
    Run Keyword and Expect Error         *    Change Multiple Parameters on BTS
    ...                                  dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                  localUserAllowedLifetime=100
    ...                                  localUserAllowedIdlePeriod=100
    ...                                  retry=${1}    connection=${conn_cnum_app}
    Disconnect from ADMIN                ${conn_cnum_app}
    Log                                  Step 7: Connect as CNUM Read Only User    console=True
    ${emssim_connection}=                Connect and Activate EMSSIM    cert_type=RSA
    Wait Until Keyword Succeeds          3x    30s    execute_command_on_emssim
    ...                                  command=edit readOnlyActivated.LUAC-1-1-1 true
    ...                                  connection=${emssim_connection}
    Sleep    90                          reason=Executing command
    Wait Until Keyword Succeeds          3x    30s    execute_command_on_emssim
    ...                                  command=ldap_user_add ${emssim_readonly_username} ${emssim_password} -a RW
    ...                                  connection=${emssim_connection}
    Sleep    30                          reason=Executing command
    ${command}=                          Catenate    user_info_update -username ${emssim_readonly_username} -password
    ...                                              ${emssim_password} -type bts_read -status enabled
    Wait Until Keyword Succeeds          3x    30s    execute_command_on_emssim    command=${command}
    ...                                  connection=${emssim_connection}
    Sleep    90                          reason=Executing command
    ${conn_cnum_readonly}=               Connect to ADMIN
    ...                                  username=${emssim_readonly_username}
    ...                                  password=${emssim_password}
    ...                                  timeout=${180}
    Log                                  Step 8/13: Try to change parameters    console=True
    Run Keyword and Expect Error         *    Change Multiple Parameters on BTS
    ...                                  dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                  sysAdmAllowedLifetime=100
    ...                                  sysAdmAllowedIdlePeriod=100
    ...                                  retry=${1}    connection=${conn_cnum_readonly}
    Run Keyword and Expect Error         *    Change Multiple Parameters on BTS
    ...                                  dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                  localUserAllowedLifetime=100
    ...                                  localUserAllowedIdlePeriod=100
    ...                                  retry=${1}    connection=${conn_cnum_readonly}
    [Teardown]    Run Keywords           Disconnect from ADMIN    ${conn_cnum_readonly}
    ...    AND                           Run Keyword and Ignore Error    Disconnect from ADMIN    ${conn_app}
    ...    AND                           Run Keyword and Ignore Error    Disconnect from ADMIN    ${conn_readonly}
    ...    AND                           Run Keyword and Ignore Error    Disconnect from ADMIN    ${conn_cnum_app}
    ...    AND                           Disconnect from EMSSIM    ${emssim_connection}
    ...    AND                           Turn off actRestrictLoginToCnum

Configuration_of_Allowed_lifetime_&_Allowed_Idle_period_from_NMS_for_BTS_Local_User_Accounts
    ${current_scf}=                        Download SCF
    Log                                    Step 1: Connect as CNUM System Admin    console=True
    Setup environment for EMSSIM
    Change Parameter On BTS                dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                    param_name=actRestrictLoginToCnum
    ...                                    param_value=true
    ${emssim_connection}=                  Connect and Activate EMSSIM    cert_type=RSA
    Wait Until Keyword Succeeds            3x    30s    execute_command_on_emssim
    ...                                    command=ldap_user_add ${emssim_system_username} ${emssim_password} -a RW
    ...                                    connection=${emssim_connection}
    Sleep    30                            reason=Executing command
    ${command}=                            Catenate    user_info_update -username ${emssim_system_username} -password
    ...                                                ${emssim_password} -type local -status enabled
    Wait Until Keyword Succeeds            3x    30s    execute_command_on_emssim    command=${command}
    ...                                    connection=${emssim_connection}
    Sleep    90                            reason=Executing command
    ${conn_cnum_system}=                   Connect to ADMIN
    ...                                    username=${emssim_system_username}
    ...                                    password=${emssim_password}
    ...                                    timeout=${180}
    Log                                    Step 2: Try to change parameters using incorrect values    console=True
    Run Keyword and Expect Error           *    Change Multiple Parameters on BTS
    ...                                    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                    sysAdmAllowedLifetime=10000
    ...                                    sysAdmAllowedIdlePeriod=10000
    ...                                    retry=${1}    connection=${conn_cnum_system}
    Log                                    Step 3: Change parameters using 0 values    console=True
    Change Multiple Parameters on BTS      dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                    sysAdmAllowedLifetime=0
    ...                                    sysAdmAllowedIdlePeriod=0
    ...                                    connection=${conn_cnum_system}
    Log                                    Step 4-5: Verify ExpDate parameters    console=True
    ${sysAdmLifetime}=                     Check current parameter value    param_name=sysAdmLifetimeExpDate
    ...                                                                     connection=${conn_cnum_system}
    ${sysAdmIdlePer}=                      Check current parameter value    param_name=sysAdmIdlePerExpDate
    ...                                                                     connection=${conn_cnum_system}
    Run Keyword and Continue on Failure    Should be Empty    ${sysAdmLifetime}
    Run Keyword and Continue on Failure    Should be Empty    ${sysAdmIdlePer}
    Log                                    Step 6: Change parameters using max values    console=True
    Change Multiple Parameters on BTS      dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                    sysAdmAllowedLifetime=9999
    ...                                    sysAdmAllowedIdlePeriod=9999
    ...                                    connection=${conn_cnum_system}
    Log                                    Step 7-8: Verify ExpDate parameters    console=True
    ${sysAdmLifetime}=                     Check current parameter value    param_name=sysAdmLifetimeExpDate
    ...                                                                     connection=${conn_cnum_system}
    ${sysAdmIdlePer}=                      Check current parameter value    param_name=sysAdmIdlePerExpDate
    ...                                                                     connection=${conn_cnum_system}
    ${currentDate}=                        Get Current Date
    ${currentDateUTC}=                     Subtract Time From Date    ${currentDate}     2h
    ${expectedDate_plus}=                  Add Time to Date    date=${currentDateUTC}    time=10000 days
    ${expectedDate}=                       Fetch From Left     ${expectedDate_plus}      ${SPACE}
    Run Keyword and Continue on Failure    Should Contain      ${sysAdmLifetime}         ${expectedDate}
    # We can't check that one because of the other system admin connections
    # Run Keyword and Continue on Failure    Should Contain      ${sysAdmIdlePer}        ${expectedDate}
    Log                                    Step 9: Try to change parameters using incorrect values    console=True
    Run Keyword and Expect Error           *    Change Multiple Parameters on BTS
    ...                                    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                    localUserAllowedLifetime=10000
    ...                                    localUserAllowedIdlePeriod=10000
    ...                                    retry=${1}    connection=${conn_cnum_system}
    Log                                    Step 10: Change parameters using 0 values    console=True
    Change Multiple Parameters on BTS      dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                    localUserAllowedLifetime=0
    ...                                    localUserAllowedIdlePeriod=0
    ...                                    connection=${conn_cnum_system}
    Log                                    Step 11-14: Verify ExpDate parameters    console=True
    ${localUserLifetime}=                  Check current parameter value    param_name=localUserLifetimeExpDate
    ...                                                                     connection=${conn_cnum_system}
    ${secAdmIdlePer}=                      Check current parameter value    param_name=secAdmIdlePerExpDate
    ...                                                                     connection=${conn_cnum_system}
    ${appAdmIdlePer}=                      Check current parameter value    param_name=appAdmIdlePerExpDate
    ...                                                                     connection=${conn_cnum_system}
    ${readOnlyIdlePer}=                    Check current parameter value    param_name=readOnlyIdlePerExpDate
    ...                                                                     connection=${conn_cnum_system}
    Run Keyword and Continue on Failure    Should be Empty    ${localUserLifetime}
    Run Keyword and Continue on Failure    Should be Empty    ${secAdmIdlePer}
    Run Keyword and Continue on Failure    Should be Empty    ${appAdmIdlePer}
    Run Keyword and Continue on Failure    Should be Empty    ${readOnlyIdlePer}
    Log                                    Step 15: Change parameters using max values    console=True
    Change Multiple Parameters on BTS      dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                    localUserAllowedLifetime=9999
    ...                                    localUserAllowedIdlePeriod=9999
    ...                                    connection=${conn_cnum_system}
    Log                                    Step 16-19: Verify ExpDate parameters    console=True
    ${localUserLifetime}=                  Check current parameter value    param_name=localUserLifetimeExpDate
    ...                                                                     connection=${conn_cnum_system}
    ${secAdmIdlePer}=                      Check current parameter value    param_name=secAdmIdlePerExpDate
    ...                                                                     connection=${conn_cnum_system}
    ${appAdmIdlePer}=                      Check current parameter value    param_name=appAdmIdlePerExpDate
    ...                                                                     connection=${conn_cnum_system}
    ${readOnlyIdlePer}=                    Check current parameter value    param_name=readOnlyIdlePerExpDate
    ...                                                                     connection=${conn_cnum_system}
    ${currentDate}=                        Get Current Date
    ${currentDateUTC}=                     Subtract Time From Date    ${currentDate}      2h
    ${expectedDate_plus}=                  Add Time to Date    date=${currentDateUTC}     time=10000 days
    ${expectedDate}=                       Fetch From Left     ${expectedDate_plus}    ${SPACE}
    Run Keyword and Continue on Failure    Should Contain      ${localUserLifetime}    ${expectedDate}
    Run Keyword and Continue on Failure    Should Contain      ${secAdmIdlePer}        ${expectedDate}
    Run Keyword and Continue on Failure    Should Contain      ${appAdmIdlePer}        ${expectedDate}
    Run Keyword and Continue on Failure    Should Contain      ${readOnlyIdlePer}      ${expectedDate}
    [Teardown]    Run Keywords             Disconnect from ADMIN     ${conn_cnum_system}
    ...    AND                             Disconnect from EMSSIM    ${emssim_connection}
    ...    AND                             Configuration Reset    new_username=${emssim_system_username}
    ...                                    new_pass=${emssim_password}    scf_path=${current_scf}    reset_type=${3}
    ...    AND                             Run    rm ${current_scf}
    ...    AND                             Turn off actRestrictLoginToCnum
    ...    AND                             Delete Allowed parameters
    ...    AND                             Run Keyword and Ignore Error    Collect Snapshot to Clear Alarms

Stressful_robustness_test_for_WebEM_CLI
    ${current_scf}=                      Download SCF
    ${state_before}=                     Get current BTS state
    ${before}=                           Get Active Alarms From BTS
    ${alarms_before}=                    Sort List    ${before}
    Log                                  Step 1: Create CNUM System Admin and Read Only accounts    console=True
    Setup environment for EMSSIM
    Change Parameter On BTS              dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                  param_name=actRestrictLoginToCnum
    ...                                  param_value=true
    ${emssim_connection}=                Connect and Activate EMSSIM    cert_type=RSA
    Wait Until Keyword Succeeds          3x    30s    execute_command_on_emssim
    ...                                  command=ldap_user_add ${emssim_system_username} ${emssim_password} -a RW
    ...                                  connection=${emssim_connection}
    Sleep    30                          reason=Executing command
    ${command}=                          Catenate    user_info_update -username ${emssim_system_username} -password
    ...                                              ${emssim_password} -type local -status enabled
    Wait Until Keyword Succeeds          3x    30s    execute_command_on_emssim    command=${command}
    ...                                  connection=${emssim_connection}
    Sleep    90                          reason=Executing command
    Log                                  Step 2: Create multiple CNUM System Admin sessions    console=True
    FOR    ${nr}    IN RANGE    1    ${stress_conns}
        Log    Creating System Admin connection nr. ${nr}    console=True
        Connect to ADMIN    username=${emssim_system_username}
        ...                 password=${emssim_password}
        ...                 timeout=${180}
        ...                 alias=admin${nr}
    END
    Log                                  Step 3: Perform stress test as System Admin    console=True
    FOR    ${try}    IN RANGE    1    ${stress_attempts}
        Log    Stress test as System Admin, nr: ${try}    console=True
        Stress parameters change    ${state_before}    ${alarms_before}
    END
    Disconnect from All CNUM System Admin Sessions
    Wait Until Keyword Succeeds          3x    30s    execute_command_on_emssim
    ...                                  command=edit readOnlyActivated.LUAC-1-1-1 true
    ...                                  connection=${emssim_connection}
    Sleep    90                          reason=Executing command
    Wait Until Keyword Succeeds          3x    30s    execute_command_on_emssim
    ...                                  command=ldap_user_add ${emssim_readonly_username} ${emssim_password} -a RW
    ...                                  connection=${emssim_connection}
    Sleep    30                          reason=Executing command
    ${command}=                          Catenate    user_info_update -username ${emssim_readonly_username} -password
    ...                                              ${emssim_password} -type bts_read -status enabled
    Wait Until Keyword Succeeds          3x    30s    execute_command_on_emssim    command=${command}
    ...                                  connection=${emssim_connection}
    Sleep    90                          reason=Executing command
    Log                                  Step 4: Create multiple CNUM Read Only sessions    console=True
    FOR    ${nr}    IN RANGE    1    ${stress_conns}
        Log    Creating Read Only User connection nr. ${nr}    console=True
        Connect to ADMIN    username=${emssim_readonly_username}
        ...                 password=${emssim_password}
        ...                 timeout=${180}
        ...                 alias=read${nr}
    END
    Log                                  Step 5: Perform stress test as Read Only User    console=True
    FOR    ${try}    IN RANGE    1    ${stress_attempts}
        Log    Stress test as Read Only User, nr: ${try}    console=True
        Stress false parameters change    ${state_before}    ${alarms_before}
    END
    [Teardown]    Run Keywords           Run Keyword and Ignore Error    Disconnect from All CNUM Sessions
    ...    AND                           Disconnect from EMSSIM    ${emssim_connection}
    ...    AND                           Add Multiple Alarms to Watchdog List    6278
    ...    AND                           Configuration Reset    new_username=${emssim_system_username}
    ...                                  new_pass=${emssim_password}    scf_path=${current_scf}    reset_type=${3}
    ...    AND                           Remove Multiple Alarms from Watchdog List    6278
    ...    AND                           Run    rm ${current_scf}
    ...    AND                           Turn off actRestrictLoginToCnum
    ...    AND                           Turn off autoCBRSCertDelete
    ...    AND                           Delete localUserAllowed parameters
    ...    AND                           Run Keyword and Ignore Error    Collect Snapshot to Clear Alarms

BTS_Update_Allowed_lifetime_or_Allowed_Idle_period_by_existing_value_for_usable_BTS_local_user_accounts
    Log                                  Precondition: BTS has symc and CMD object exists     console=True
    Wait Until Keyword Succeeds          15min    10s    Alarm Should Not Be Active in BTS    fault_id=4405
    Wait Until Keyword Succeeds          15min    10s    Alarm Should Not Be Active in BTS    fault_id=4298
    ${cmd_exists}=                       Check if Object Exists in Scf File
    ...                                  dist_name=MRBTS-${BTS_ID}/MNL-1
    ...                                  object_name=CMD
    Run Keyword If                       not ${cmd_exists}    Create CMD object
    Log                                  Step 1: Login as BTS System Admin    console=True
    ${conn_sys}=                         Connect to ADMIN
    Log                                  Step 2: Create LUACREQ object as BTS System Admin    console=True
    Create Multiple Parameters on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/CMD-1/LUACREQ-1
    ...                                  luacReqId=${1}    connection=${conn_sys}
    Log                                  Step 3: Try to change parameters in LUACREQ object    console=True
    Run Keyword and Expect Error         *    Change Multiple Parameters on BTS
    ...                                  dist_name=MRBTS-${BTS_ID}/MNL-1/CMD-1/LUACREQ-1
    ...                                  localUserAllowedIdlePerUpdate=50
    ...                                  localUserAllowedLifetimeUpdate=50
    ...                                  retry=${1}    connection=${conn_sys}
    Run Keyword and Expect Error         *    Change Multiple Parameters on BTS
    ...                                  dist_name=MRBTS-${BTS_ID}/MNL-1/CMD-1/LUACREQ-1
    ...                                  sysAdmAllowedIdlePerUpdate=50
    ...                                  sysAdmAllowedLifetimeUpdate=50
    ...                                  retry=${1}    connection=${conn_sys}
    Log                                  Step 4: Check if ExpDate parameters are empty    console=True
    ${sysAdmLifetime}=                   Check current parameter value    param_name=sysAdmLifetimeExpDate
    ...                                                                   connection=${conn_sys}
    ${sysAdmIdlePer}=                    Check current parameter value    param_name=sysAdmIdlePerExpDate
    ...                                                                   connection=${conn_sys}
    ${localUserLifetime}=                Check current parameter value    param_name=localUserLifetimeExpDate
    ...                                                                   connection=${conn_sys}
    ${secAdmIdlePer}=                    Check current parameter value    param_name=secAdmIdlePerExpDate
    ...                                                                   connection=${conn_sys}
    ${appAdmIdlePer}=                    Check current parameter value    param_name=appAdmIdlePerExpDate
    ...                                                                   connection=${conn_sys}
    ${readOnlyIdlePer}=                  Check current parameter value    param_name=readOnlyIdlePerExpDate
    ...                                                                   connection=${conn_sys}
    Should be Empty                      ${sysAdmLifetime}
    Should be Empty                      ${sysAdmIdlePer}
    Should be Empty                      ${localUserLifetime}
    Should be Empty                      ${secAdmIdlePer}
    Should be Empty                      ${appAdmIdlePer}
    Should be Empty                      ${readOnlyIdlePer}
    Log                                  Step 5: Delete LUACREQ object as BTS System Admin    console=True
    Delete Object From BTS               dist_name=MRBTS-${BTS_ID}/MNL-1/CMD-1/LUACREQ-1    connection=${conn_sys}
    ${step7}=                            Catenate    Try to create LUACREQ object with all parameters as BTS System
    ...                                              Admin without necessary parameters in LUAC object
    Log                                  Step 6-7: ${step7}    console=True
    Run Keyword and Expect Error         *    Create Multiple Parameters on BTS
    ...                                  dist_name=MRBTS-${BTS_ID}/MNL-1/CMD-1/LUACREQ-1
    ...                                  localUserAllowedIdlePerUpdate=${period_update}
    ...                                  localUserAllowedLifetimeUpdate=${lifetime_update}
    ...                                  sysAdmAllowedIdlePerUpdate=${period_update}
    ...                                  sysAdmAllowedLifetimeUpdate=${lifetime_update}
    ...                                  luacReqId=${1}    retry=${1}    connection=${conn_sys}
    Log                                  Step 8: Create LUACREQ object with all parameters as BTS System Admin
    ...                                  console=True
    Change Multiple Parameters on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                  sysAdmAllowedLifetime=100
    ...                                  sysAdmAllowedIdlePeriod=100
    ...                                  localUserAllowedLifetime=100
    ...                                  localUserAllowedIdlePeriod=100
    ...                                  connection=${conn_sys}
    Create Multiple Parameters on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/CMD-1/LUACREQ-1
    ...                                  localUserAllowedIdlePerUpdate=${period_update}
    ...                                  localUserAllowedLifetimeUpdate=${lifetime_update}
    ...                                  sysAdmAllowedIdlePerUpdate=${period_update}
    ...                                  sysAdmAllowedLifetimeUpdate=${lifetime_update}
    ...                                  luacReqId=${1}    connection=${conn_sys}
    Log                                  Step 9: Check if ExpDate parameters were updated    console=True
    ${sysAdmLifetime}=                   Check current parameter value    param_name=sysAdmLifetimeExpDate
    ...                                                                   connection=${conn_sys}
    ${sysAdmIdlePer}=                    Check current parameter value    param_name=sysAdmIdlePerExpDate
    ...                                                                   connection=${conn_sys}
    ${localUserLifetime}=                Check current parameter value    param_name=localUserLifetimeExpDate
    ...                                                                   connection=${conn_sys}
    ${secAdmIdlePer}=                    Check current parameter value    param_name=secAdmIdlePerExpDate
    ...                                                                   connection=${conn_sys}
    ${appAdmIdlePer}=                    Check current parameter value    param_name=appAdmIdlePerExpDate
    ...                                                                   connection=${conn_sys}
    ${readOnlyIdlePer}=                  Check current parameter value    param_name=readOnlyIdlePerExpDate
    ...                                                                   connection=${conn_sys}
    ${currentDate}=                      Get Current Date
    ${currentDateUTC}=                   Subtract Time From Date    ${currentDate}         2h
    ${expectedDate_plus}=                Add Time to Date        date=${currentDateUTC}    time=101 days
    ${expectedDate}=                     Fetch From Left         ${expectedDate_plus}      ${SPACE}
    Should Contain                       ${sysAdmLifetime}       ${expectedDate}
    # We can't check that one because of the other system admin connections
    # Should Contain                     ${sysAdmIdlePer}        ${expectedDate}
    Should Contain                       ${localUserLifetime}    ${expectedDate}
    Should Contain                       ${secAdmIdlePer}        ${expectedDate}
    Should Contain                       ${appAdmIdlePer}        ${expectedDate}
    Should Contain                       ${readOnlyIdlePer}      ${expectedDate}
    Log                                  Step 10: Try to create another LUACREQ object with the same ID    console=True
    Run Keyword and Expect Error         *    Create Multiple Parameters on BTS
    ...                                  dist_name=MRBTS-${BTS_ID}/MNL-1/CMD-1/LUACREQ-1
    ...                                  localUserAllowedIdlePerUpdate=${period_update}
    ...                                  localUserAllowedLifetimeUpdate=${lifetime_update}
    ...                                  sysAdmAllowedIdlePerUpdate=${period_update}
    ...                                  sysAdmAllowedLifetimeUpdate=${lifetime_update}
    ...                                  luacReqId=${1}    retry=${1}    connection=${conn_sys}
    Disconnect from ADMIN                ${conn_sys}
    Log                                  Step 11: Create and login as CNUM Security Admin    console=True
    Setup environment for EMSSIM
    Change Parameter On BTS              dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                  param_name=actRestrictLoginToCnum
    ...                                  param_value=true
    ${emssim_connection}=                Connect and Activate EMSSIM    cert_type=RSA
    Wait Until Keyword Succeeds          3x    30s    execute_command_on_emssim
    ...                                  command=edit secAdmActivated.LUAC-1-1-1 true
    ...                                  connection=${emssim_connection}
    Sleep    90                          reason=Executing command
    Wait Until Keyword Succeeds          3x    30s    execute_command_on_emssim
    ...                                  command=ldap_user_add ${emssim_sec_username} ${emssim_password} -a RW
    ...                                  connection=${emssim_connection}
    Sleep    30                          reason=Executing command
    ${command}=                          Catenate    user_info_update -username ${emssim_sec_username} -password
    ...                                              ${emssim_password} -type bts_security -status enabled
    Wait Until Keyword Succeeds          3x    30s    execute_command_on_emssim
    ...                                  command=${command}
    ...                                  connection=${emssim_connection}
    Sleep    90                          reason=Executing command
    ${conn_cnum_sec}=                    Connect to ADMIN
    ...                                  username=${emssim_sec_username}
    ...                                  password=${emssim_password}
    ...                                  timeout=${180}
    Log                                  Step 12: Delete LUACREQ object as CNUM Security Admin    console=True
    Delete Object From BTS               dist_name=MRBTS-${BTS_ID}/MNL-1/CMD-1/LUACREQ-1    connection=${conn_cnum_sec}
    Log                                  Step 13: Create LUACREQ object with localUser parameters as CNUM Security Admin
    ...                                  console=True
    Create Multiple Parameters on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/CMD-1/LUACREQ-1
    ...                                  localUserAllowedIdlePerUpdate=${period_update}
    ...                                  localUserAllowedLifetimeUpdate=${lifetime_update}
    ...                                  luacReqId=${1}    connection=${conn_cnum_sec}
    Log                                  Step 14: Update localUser parameters as CNUM Security Admin    console=True
    Change Multiple Parameters on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                  localUserAllowedLifetime=50
    ...                                  localUserAllowedIdlePeriod=50
    ...                                  connection=${conn_cnum_sec}
    Log                                  Step 15: Check if ExpDate parameters were updated    console=True
    ${localUserLifetime}=                Check current parameter value    param_name=localUserLifetimeExpDate
    ...                                                                   connection=${conn_cnum_sec}
    ${secAdmIdlePer}=                    Check current parameter value    param_name=secAdmIdlePerExpDate
    ...                                                                   connection=${conn_cnum_sec}
    ${appAdmIdlePer}=                    Check current parameter value    param_name=appAdmIdlePerExpDate
    ...                                                                   connection=${conn_cnum_sec}
    ${readOnlyIdlePer}=                  Check current parameter value    param_name=readOnlyIdlePerExpDate
    ...                                                                   connection=${conn_cnum_sec}
    ${currentDate}=                      Get Current Date
    ${currentDateUTC}=                   Subtract Time From Date    ${currentDate}         2h
    ${expectedDate_plus}=                Add Time to Date        date=${currentDateUTC}    time=51 days
    ${expectedDate}=                     Fetch From Left         ${expectedDate_plus}      ${SPACE}
    Should Contain                       ${localUserLifetime}    ${expectedDate}
    # We can't check that when we are loged in as Security Admin
    # Should Contain                     ${secAdmIdlePer}        ${expectedDate}
    Should Contain                       ${appAdmIdlePer}        ${expectedDate}
    Should Contain                       ${readOnlyIdlePer}      ${expectedDate}
    Log                                  Step 16: Delete LUACREQ object as CNUM Security Admin    console=True
    Delete Object From BTS               dist_name=MRBTS-${BTS_ID}/MNL-1/CMD-1/LUACREQ-1    connection=${conn_cnum_sec}
    Disconnect from ADMIN                ${conn_cnum_sec}
    Sleep    60                          reason=Give some time to EMSsim
    Log                                  Step 17-18: Create LUACREQ object via NMS    console=True
    Wait Until Keyword Succeeds          10x    30sec    Create LUACREQ via EMSsim    ${emssim_connection}
    Log                                  Step 19: Change localUserAllowed parameters via NMS     console=True
    Wait Until Keyword Succeeds          3x    30s    execute_command_on_emssim
    ...                                  command=edit localUserAllowedLifetime.LUAC-1-1-1 100
    ...                                  connection=${emssim_connection}
    Sleep    90                          reason=Executing command
    Wait Until Keyword Succeeds          3x    30s    execute_command_on_emssim
    ...                                  command=edit localUserAllowedIdlePeriod.LUAC-1-1-1 100
    ...                                  connection=${emssim_connection}
    Sleep    90                          reason=Executing command
    Log                                  Step 20-22: Check if ExpDate parameters were updated    console=True
    ${localUserLifetime_raw}=            execute_command_on_emssim_and_return_output
    ...                                  command=disp localUserLifetimeExpDate.LUAC_R-1-1-1-1
    ...                                  connection=${emssim_connection}
    Sleep    1                           reason=Executing command
    ${secAdmIdlePer_raw}=                execute_command_on_emssim_and_return_output
    ...                                  command=disp secAdmIdlePerExpDate.LUAC_R-1-1-1-1
    ...                                  connection=${emssim_connection}
    Sleep    1                           reason=Executing command
    ${appAdmIdlePer_raw}=                execute_command_on_emssim_and_return_output
    ...                                  command=disp appAdmIdlePerExpDate.LUAC_R-1-1-1-1
    ...                                  connection=${emssim_connection}
    Sleep    1                           reason=Executing command
    ${readOnlyIdlePer_raw}=              execute_command_on_emssim_and_return_output
    ...                                  command=disp readOnlyIdlePerExpDate.LUAC_R-1-1-1-1
    ...                                  connection=${emssim_connection}
    Sleep    1                           reason=Executing command
    ${localUserLifetime}=                Get Date from EMSsim Output    ${localUserLifetime_raw}
    ${secAdmIdlePer}=                    Get Date from EMSsim Output    ${secAdmIdlePer_raw}
    ${appAdmIdlePer}=                    Get Date from EMSsim Output    ${appAdmIdlePer_raw}
    ${readOnlyIdlePer}=                  Get Date from EMSsim Output    ${readOnlyIdlePer_raw}
    ${currentDate}=                      Get Current Date
    ${currentDateUTC}=                   Subtract Time From Date    ${currentDate}         2h
    ${expectedDate_plus}=                Add Time to Date        date=${currentDateUTC}    time=101 days
    ${expectedDate}=                     Fetch From Left         ${expectedDate_plus}      ${SPACE}
    Should Contain                       ${localUserLifetime}    ${expectedDate}
    Should Contain                       ${secAdmIdlePer}        ${expectedDate}
    Should Contain                       ${appAdmIdlePer}        ${expectedDate}
    Should Contain                       ${readOnlyIdlePer}      ${expectedDate}
    Log                                  Step 23: Turn off sync    console=True
    Add Multiple Alarms to Watchdog List    4405    4452    16    4298    1815    10
    Lose Synchronization with GNSS
    Log                                  Step 24: Login as BTS System Admin    console=True
    ${conn_sys}=                         Connect to ADMIN
    Log                                  Step 25: Try to create another LUACREQ object with the same ID    console=True
    Run Keyword and Expect Error         *    Create Multiple Parameters on BTS
    ...                                  dist_name=MRBTS-${BTS_ID}/MNL-1/CMD-1/LUACREQ-1
    ...                                  localUserAllowedIdlePerUpdate=${period_update}
    ...                                  localUserAllowedLifetimeUpdate=${lifetime_update}
    ...                                  sysAdmAllowedIdlePerUpdate=${period_update}
    ...                                  sysAdmAllowedLifetimeUpdate=${lifetime_update}
    ...                                  luacReqId=${1}    retry=${1}    connection=${conn_sys}
    ...                                  skip_parameter_relation_errors=${TRUE}
    Log                                  Step 26: Delete LUACREQ object    console=True
    Delete Object From BTS               dist_name=MRBTS-${BTS_ID}/MNL-1/CMD-1/LUACREQ-1    connection=${conn_sys}
    ...                                  skip_parameter_relation_errors=${TRUE}
    Log                                  Step 27: Create LUACREQ object with all parameters as BTS System Admin
    ...                                  console=True
    Change Multiple Parameters on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                  sysAdmAllowedLifetime=150
    ...                                  sysAdmAllowedIdlePeriod=150
    ...                                  localUserAllowedLifetime=150
    ...                                  localUserAllowedIdlePeriod=150
    ...                                  connection=${conn_sys}
    ...                                  skip_parameter_relation_errors=${TRUE}
    Create Multiple Parameters on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/CMD-1/LUACREQ-1
    ...                                  localUserAllowedIdlePerUpdate=${period_update}
    ...                                  localUserAllowedLifetimeUpdate=${lifetime_update}
    ...                                  sysAdmAllowedIdlePerUpdate=${period_update}
    ...                                  sysAdmAllowedLifetimeUpdate=${lifetime_update}
    ...                                  luacReqId=${1}    connection=${conn_sys}
    ...                                  skip_parameter_relation_errors=${TRUE}
    Log                                  Step 28-32: Check if ExpDate parameters are empty    console=True
    ${sysAdmLifetime}=                   Check current parameter value    param_name=sysAdmLifetimeExpDate
    ...                                                                   connection=${conn_sys}
    ${sysAdmIdlePer}=                    Check current parameter value    param_name=sysAdmIdlePerExpDate
    ...                                                                   connection=${conn_sys}
    ${localUserLifetime}=                Check current parameter value    param_name=localUserLifetimeExpDate
    ...                                                                   connection=${conn_sys}
    ${secAdmIdlePer}=                    Check current parameter value    param_name=secAdmIdlePerExpDate
    ...                                                                   connection=${conn_sys}
    ${appAdmIdlePer}=                    Check current parameter value    param_name=appAdmIdlePerExpDate
    ...                                                                   connection=${conn_sys}
    ${readOnlyIdlePer}=                  Check current parameter value    param_name=readOnlyIdlePerExpDate
    ...                                                                   connection=${conn_sys}
    Should be Empty                      ${sysAdmLifetime}
    Should be Empty                      ${sysAdmIdlePer}
    Should be Empty                      ${localUserLifetime}
    Should be Empty                      ${secAdmIdlePer}
    Should be Empty                      ${appAdmIdlePer}
    Should be Empty                      ${readOnlyIdlePer}
    Run Keyword and Ignore Error         Disconnect from ADMIN    ${conn_sys}
    Log                                  Step 33: Login as CNUM Security Admin    console=True
    ${conn_cnum_sec}=                    Connect to ADMIN
    ...                                  username=${emssim_sec_username}
    ...                                  password=${emssim_password}
    ...                                  timeout=${180}
    Log                                  Step 34: Try to create another LUACREQ object with the same ID    console=True
    Run Keyword and Expect Error         *    Create Multiple Parameters on BTS
    ...                                  dist_name=MRBTS-${BTS_ID}/MNL-1/CMD-1/LUACREQ-1
    ...                                  localUserAllowedIdlePerUpdate=${period_update}
    ...                                  localUserAllowedLifetimeUpdate=${lifetime_update}
    ...                                  sysAdmAllowedIdlePerUpdate=${period_update}
    ...                                  sysAdmAllowedLifetimeUpdate=${lifetime_update}
    ...                                  luacReqId=${1}    retry=${1}    connection=${conn_cnum_sec}
    ...                                  skip_parameter_relation_errors=${TRUE}
    Log                                  Step 35: Delete LUACREQ object    console=True
    Delete Object From BTS               dist_name=MRBTS-${BTS_ID}/MNL-1/CMD-1/LUACREQ-1    connection=${conn_cnum_sec}
    ...                                  skip_parameter_relation_errors=${TRUE}
    Log                                  Step 36: Create LUACREQ object with all parameters as CNUM Security Admin
    ...                                  console=True
    Change Multiple Parameters on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                  sysAdmAllowedLifetime=150
    ...                                  sysAdmAllowedIdlePeriod=150
    ...                                  localUserAllowedLifetime=150
    ...                                  localUserAllowedIdlePeriod=150
    ...                                  connection=${conn_cnum_sec}
    ...                                  skip_parameter_relation_errors=${TRUE}
    Create Multiple Parameters on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/CMD-1/LUACREQ-1
    ...                                  localUserAllowedIdlePerUpdate=${period_update}
    ...                                  localUserAllowedLifetimeUpdate=${lifetime_update}
    ...                                  sysAdmAllowedIdlePerUpdate=${period_update}
    ...                                  sysAdmAllowedLifetimeUpdate=${lifetime_update}
    ...                                  luacReqId=${1}    connection=${conn_cnum_sec}
    ...                                  skip_parameter_relation_errors=${TRUE}
    Log                                  Step 37-41: Check if ExpDate parameters are empty    console=True
    ${sysAdmLifetime}=                   Check current parameter value    param_name=sysAdmLifetimeExpDate
    ...                                                                   connection=${conn_cnum_sec}
    ${sysAdmIdlePer}=                    Check current parameter value    param_name=sysAdmIdlePerExpDate
    ...                                                                   connection=${conn_cnum_sec}
    ${localUserLifetime}=                Check current parameter value    param_name=localUserLifetimeExpDate
    ...                                                                   connection=${conn_cnum_sec}
    ${secAdmIdlePer}=                    Check current parameter value    param_name=secAdmIdlePerExpDate
    ...                                                                   connection=${conn_cnum_sec}
    ${appAdmIdlePer}=                    Check current parameter value    param_name=appAdmIdlePerExpDate
    ...                                                                   connection=${conn_cnum_sec}
    ${readOnlyIdlePer}=                  Check current parameter value    param_name=readOnlyIdlePerExpDate
    ...                                                                   connection=${conn_cnum_sec}
    Should be Empty                      ${sysAdmLifetime}
    Should be Empty                      ${sysAdmIdlePer}
    Should be Empty                      ${localUserLifetime}
    Should be Empty                      ${secAdmIdlePer}
    Should be Empty                      ${appAdmIdlePer}
    Should be Empty                      ${readOnlyIdlePer}
    Run Keyword and Ignore Error         Disconnect from ADMIN    ${conn_cnum_sec}
    Log                                  Step 42: Turn on sync    console=True
    Add Multiple Alarms to Watchdog List    6280
    Regaine Synchronization with GNSS
    Remove Multiple Alarms from Watchdog List    4405    6280    16    4298    1815    10
    ${conn_sys}=                         Connect to ADMIN
    Log                                  Step 43-48: Check if ExpDate parameters were updated    console=True
    ${sysAdmLifetime}=                   Check current parameter value    param_name=sysAdmLifetimeExpDate
    ...                                                                   connection=${conn_sys}
    ${sysAdmIdlePer}=                    Check current parameter value    param_name=sysAdmIdlePerExpDate
    ...                                                                   connection=${conn_sys}
    ${localUserLifetime}=                Check current parameter value    param_name=localUserLifetimeExpDate
    ...                                                                   connection=${conn_sys}
    ${secAdmIdlePer}=                    Check current parameter value    param_name=secAdmIdlePerExpDate
    ...                                                                   connection=${conn_sys}
    ${appAdmIdlePer}=                    Check current parameter value    param_name=appAdmIdlePerExpDate
    ...                                                                   connection=${conn_sys}
    ${readOnlyIdlePer}=                  Check current parameter value    param_name=readOnlyIdlePerExpDate
    ...                                                                   connection=${conn_sys}
    ${currentDate}=                      Get Current Date
    ${currentDateUTC}=                   Subtract Time From Date    ${currentDate}          2h
    ${expectedDate_plus}=                Add Time to Date        date=${currentDateUTC}     time=151 days
    ${expectedDate}=                     Fetch From Left         ${expectedDate_plus}       ${SPACE}
    Should Contain                       ${sysAdmLifetime}       ${expectedDate}
    # We can't check that one because of the other system admin connections
    # Should Contain                     ${sysAdmIdlePer}        ${expectedDate}
    Should Contain                       ${localUserLifetime}    ${expectedDate}
    Should Contain                       ${secAdmIdlePer}        ${expectedDate}
    Should Contain                       ${appAdmIdlePer}        ${expectedDate}
    Should Contain                       ${readOnlyIdlePer}      ${expectedDate}
    [Teardown]    Run Keywords           Run Keyword and Ignore Error    Disconnect from ADMIN     ${conn_cnum_sec}
    ...    AND                           Disconnect from ADMIN     ${conn_sys}
    ...    AND                           Disconnect from EMSSIM    ${emssim_connection}
    ...    AND                           Delete LUACREQ in Teardown
    ...    AND                           Turn off actRestrictLoginToCnum
    ...    AND                           Delete Allowed parameters
    ...    AND                           Remove Multiple Alarms from Watchdog List       4452
