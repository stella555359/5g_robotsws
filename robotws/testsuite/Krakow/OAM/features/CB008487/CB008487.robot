*** Settings ***
Documentation   Nokia Service Account Management on RU
...
...             Test Case author: Jakub Czekaj, Bartlomiej Trybuch
...             Test Case contact: jakub.czekaj@nokia.com, bartlomiej.trybuch@nokia.com

Library         ./Resources/ru_functions.py
Resource        ./Resources/keywords.robot
Resource        taf/rfrl/bts/robot/gnb.robot
Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables       taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags    STATE_SW_UPLOADED    RAN_5G    CRT
...           SBTS00__WITH__CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWEUA_SWITCH

Suite Setup     Run Keywords
...             Common Suite Setup With OnAir Test Line Preparation
...             set_up_passwords

Test Setup      Run Keywords    Common Preconditions With Watching Alarms    AND
...             Change param via WebEM   param_value=true  param=actSyncToRU

Test Teardown   Common Postconditions With Watching Alarms

Suite Teardown  Run Keywords    Change param via WebEM   param_value=false  param=actSyncToRU   AND
...             Common Suite Teardown

*** Variables ***
${tcpdump_options}               -i rlan0 udp -vv -s0 -A -c 160 | grep ServiceAccountConfig | grep SshServerConfig
${SERVICEUSER_NEW_PASSWORD}      Pl(FzaYj5~c5;q12
${SERVICEUSER_DEFAULT_PASSWORD}  Pl(FzaYj5~c5;q
@{additional_allowed_alarms}     No X2 link available for a specific LTEENB
...                              No X2 link available

*** Test Cases ***
[1]CB006017_2 Manually trigger the Service Account synchronization to RU MODULE with WebEM
    Start Tcpdump Between Bts and RU    options=${tcpdump_options}
    Manually trigger the Service Account synchronization to RU RF MODULE
    Check tcpdump
    Verify SSH and hash

[1]CB006017_3 Activate Service Account synchronization to RU module with WebEM
    Change param via WebEM   param_value=false  param=actSyncToRU
    Start Tcpdump Between Bts and RU    options=${tcpdump_options}
    Change param via WebEM   param_value=true  param=actSyncToRU
    Check tcpdump
    Verify SSH and hash

[1]CB006017_6 BTS SSH Client Alive Timer Provisioning via WebUI
    Change param via WebEM   param_value=1  param=sshClientAliveTimer
    ${get_value}=  Get parameter value   param=SSH client alive timer
    Run keyword if  ${get_value} != 1   Fail   Incorrect value was set
    Verify SSH session

[1]CB006017_7 BTS SSH Session Login Delay Provisioning via WebUI
    Change param via WebEM   param_value=30  param=sshSessionLoginDelayTimer
    ${get_value}=  Get parameter value   param=SSH session login delay timer
    Run keyword if  ${get_value} != 30   Fail   Incorrect value was set
    Verify SSH Session Delay Timer

[1]CB006017_8 Service Account SSH Session Idle Timer via WebEM
    Start Tcpdump Between Bts and RU    options=${tcpdump_options}
    Change param via WebEM   param_value=10  param=sshSessionIdleTimer
    Check tcpdump
    Verify SSH and hash
    Verify SSH Session Idle Timer   password=${SERVICEUSER_DEFAULT_PASSWORD}
    [Teardown]    Run Keywords
    ...           Change param via WebEM   param_value=0  param=sshSessionIdleTimer
    ...           AND
    ...           Common Postconditions With Watching Alarms

[1]CB006017_10 RU SSH account configuration persistency after reset
    Change password for user                                  user=serviceuser
    ...                                                       new_password=${SERVICEUSER_NEW_PASSWORD}
    ...                                                       old_password=${SERVICEUSER_DEFAULT_PASSWORD}
    sleep    60sec
    Verify SSH and hash   password=${SERVICEUSER_NEW_PASSWORD}
    Set Global Variable  ${SERVICEUSER_PASSWORD_CHANGE_SUCCESS}   ${TRUE}
    gnbbbu.reset_bts    bts_id=0    wait_for_reconnection=True
    gnbbbu.wait_for_site_to_be_onair    timeout=360
    Verify SSH and hash   password=${SERVICEUSER_NEW_PASSWORD}
    [Teardown]    Run Keywords
    ...            Change password for user                   user=serviceuser
    ...                                                       new_password=${SERVICEUSER_DEFAULT_PASSWORD}
    ...                                                       old_password=${SERVICEUSER_NEW_PASSWORD}
    ...            AND
    ...            Sleep                                      time_=60s
    ...                                                       reason=Waiting for the password to change
    ...            AND
    ...            Common Postconditions With Watching Alarms

[1]CB006017_5 BTS Service Account Password Provisioning via WebEM
    Pass Execution If  ${SERVICEUSER_PASSWORD_CHANGE_SUCCESS} == ${TRUE}
    ...    Test case covered in: 10.CB006017 RU SSH account configuration persistency after reset

[1]CB006017_11 Verify manual trigger with different webEM accounts
    Manually trigger the Service Account synchronization to RU RF MODULE with diffrent accounts

[1]CB006017_12 Verify automatic synchronization with different webEM accounts
    Change param via WebEM   param_value=false  param=actSyncToRU
    Verify automatic synchronization with different webEM accounts
