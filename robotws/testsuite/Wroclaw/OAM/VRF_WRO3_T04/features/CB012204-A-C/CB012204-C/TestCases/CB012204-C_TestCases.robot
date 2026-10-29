*** Settings ***
Documentation
...  author:     Grzegorz Niedzwiedz
...  contact:    grzegorz.niedzwiedz@nokia.com
...  test:       First test is checkign if parameter enableDefaultPasswdAlarm is working as intended
...              with and without wsuser default password
...              Second test is checking connection via SSH to rannic with different keys usege,
...              checking if loging with old password is unable, checking automatic and manual synchronization of rannic device
...              and if elevated privilages are granted after toor4nsn login form serviceuser is performed

Resource    ./../Resources/CB012204-C_keywords.robot

*** Keywords ***
CB012204-C_Wsuser_user_account_default_password_alarm_reporting
    Log    Preconditions: enableDefaultPasswdAlarm is set to "true" and wsuser had default password set.    console=true
    Log    Changing parameter enableDefaultPasswdAlarm on vCU       console=true
    Run keyword and ignore error    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1
    ...                             param_name=enableDefaultPasswdAlarm    param_value=true    hw_type=vCU
    Log    Changing parameter enableDefaultPasswdAlarm on vDU       console=true
    Run keyword and ignore error    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1
    ...                             param_name=enableDefaultPasswdAlarm    param_value=true    hw_type=vDU

    Log    Step 1: Check if fault 4459 is active on vCU and vDU     console=true
    Wait until keyword succeeds     3x  10s     Alarm Should be Active    4459    vCU
    Wait until keyword succeeds     3x  10s     Alarm Should be Active    4459    vDU
    Log    Alarm 4459 is active!    console=true

    Log    Step 2: enableDefaultPasswdAlarm is set to "false" and alarm should be cleard    console=true
    Log    Changing parameter enableDefaultPasswdAlarm on vCU       console=true
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1
    ...                             param_name=enableDefaultPasswdAlarm    param_value=false    hw_type=vCU
    Log    Changing parameter enableDefaultPasswdAlarm on vDU       console=true
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1
    ...                             param_name=enableDefaultPasswdAlarm    param_value=false    hw_type=vDU
    Wait until keyword succeeds     3x  10s     Alarm Should not be Active    4459    vCU
    Wait until keyword succeeds     3x  10s     Alarm Should not be Active    4459    vDU
    Log    Alarm 4459 is not present on BTS!    console=true

    Log    Step 3: enableDefaultPasswdAlarm is set to "true"    console=true
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1
    ...                             param_name=enableDefaultPasswdAlarm    param_value=true    hw_type=vCU
    Log    Changing parameter enableDefaultPasswdAlarm on vDU       console=true
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1
    ...                             param_name=enableDefaultPasswdAlarm    param_value=true    hw_type=vDU
    Wait until keyword succeeds     3x  10s     Alarm Should be Active    4459    vCU
    Wait until keyword succeeds     3x  10s     Alarm Should be Active    4459    vDU
    Log    Alarm 4459 is active again!    console=true

    Log    Step 4: wsuser default password changed to new password, alarm should be cleared.    console=true
    Change Service Account Password    username=${WSUSER_LOGIN}    old_password=${DEFAULT_WSUSER_PWD}    new_password=${NEW_WSUSER_PWD}    hw_type=vCU
    Change Service Account Password    username=${WSUSER_LOGIN}    old_password=${DEFAULT_WSUSER_PWD}    new_password=${NEW_WSUSER_PWD}    hw_type=vDU
    Wait until keyword succeeds     3x  10s     Alarm Should not be Active    4459    vCU
    Wait until keyword succeeds     3x  10s     Alarm Should not be Active    4459    vDU
    Log    Alarm 4459 is cleared due to password change!    console=true
    [Teardown]    Run keywords      Log    Setting up BTS to previous values!    console=true
    ...    AND                      Change Service Account Password    username=${WSUSER_LOGIN}
    ...                             old_password=${NEW_WSUSER_PWD}  new_password=${DEFAULT_WSUSER_PWD}   hw_type=vCU
    ...    AND                      Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1
    ...                             param_name=enableDefaultPasswdAlarm    param_value=false    hw_type=vCU
    ...    AND                      Change Service Account Password    username=${WSUSER_LOGIN}
    ...                             old_password=${NEW_WSUSER_PWD}   new_password=${DEFAULT_WSUSER_PWD}   hw_type=vDU
    ...    AND                      Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1
    ...                             param_name=enableDefaultPasswdAlarm    param_value=false    hw_type=vDU

CB012204-C_account_management_and_synchronization_to_RAN_NIC
    Log    Preconditions:                                   console=true
    Log    Changing password for serviceuser                console=true
    Change Service Account Password    username=${SERVICEUSER_LOGIN}    old_password=${SERVICEUSER_NEW_PWD}
    ...                                 new_password=${SERVICEUSER_NEW_PWD}    hw_type=vDU
    Log    Changing parameter actSshToRanNic on vDU         console=true
    Run keyword and ignore error    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1
    ...                             param_name=actSshToRanNic   param_value=true    hw_type=vDU
    Wait until keyword succeeds    3x    10s    Enable SSH Access and Port      dist_name=${SSH_TUNNEL_REQ}     operation=Enable


    Log    Step 1: Set SSH public key for RAN NIC         console=true
    ${ssh_pub_key}=    wait until keyword succeeds    3x    20s     Generate RSA SSH Key
    ...                                       RSA_key=RSA_key    serviceuser_pass=${SERVICEUSER_NEW_PWD}
    Add SSH Key to vDU      ${ssh_pub_key}    key_descp=#First RSA KEY check

    Log    Step 2: Perform RANNIC SSH login to serviceuser          console=true
    RANNIC SSH Connection   RSA_key=RSA_key    serviceuser_pass=${SERVICEUSER_NEW_PWD}

    Log    Step 3: Turn OFF actSshToRanNic and change serviceuser password          console=true
    Run keyword                     Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1
    ...                             param_name=actSshToRanNic   param_value=false    hw_type=vDU
    Log    Changing password for serviceuser        console=true
    Change Service Account Password    username=${SERVICEUSER_LOGIN}    old_password=${SERVICEUSER_NEW_PWD}
    ...                                new_password=${SERVICEUSER_NEW_PWD_2}    hw_type=vDU

    Log    Step 4: Set actSshToRanNic to true, to trigger automatic synchronization         console=true
    Run keyword                     Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1
    ...                             param_name=actSshToRanNic   param_value=true    hw_type=vDU
    Wait until keyword succeeds    3x    10s    Enable SSH Access and Port      dist_name=${SSH_TUNNEL_REQ}     operation=Enable

    Log    Step 5: Generate new RSA keys and upload it on vDU         console=true
    ${ssh_pub_key}=    wait until keyword succeeds    3x    20s     Generate RSA SSH Key
    ...                                       RSA_key=2ND_RSA_key    serviceuser_pass=${SERVICEUSER_NEW_PWD_2}
    Add SSH Key to vDU      ${ssh_pub_key}    key_descp=#Second RSA KEY check

    Log    Step 6: Perform RANNIC SSH login to serviceuser using new password          console=true
    RANNIC SSH Connection    RSA_key=2ND_RSA_key    serviceuser_pass=${SERVICEUSER_NEW_PWD_2}

    Log    Step 7: Perform RANNIC SSH login to serviceuser using old password          console=true
    Run keyword and expect error    *Authentication failed for user 'serviceuser'.*   RANNIC SSH Connection
    ...                             RSA_key=2ND_RSA_key    serviceuser_pass=${SERVICEUSER_NEW_PWD}

    Log    Step 8: Turn off RANNIC synchronization           console=true
    Wait until keyword succeeds    3x    15s    Enable SSH Access and Port      dist_name=${SSH_TUNNEL_REQ}     operation=Disable

    Log    Step 9: Change serviceuser password          console=true
    Log    Changing password for serviceuser        console=true
    Change Service Account Password    username=${SERVICEUSER_LOGIN}    old_password=${SERVICEUSER_NEW_PWD_2}
    ...                                new_password=${SERVICEUSER_NEW_PWD_3}    hw_type=vDU

    Log    Step 10: Manual synchronization RANNIC device           console=true
    Manual Synchronization Trigger
    Wait until keyword succeeds    5x    5s    Enable SSH Access and Port      dist_name=${SSH_TUNNEL_REQ}     operation=Enable

    Log    Step 11: Generate new SSH keys
    ${ssh_pub_key}=    wait until keyword succeeds    3x    20s     Generate RSA SSH Key
    ...                                       RSA_key=3RD_RSA_key    serviceuser_pass=${SERVICEUSER_NEW_PWD_3}
    Add SSH Key to vDU      ${ssh_pub_key}    key_descp=#Third RSA KEY check

    Log    Step 12: Perform RANNIC SSH login to serviceuser using changed password          console=true
    RANNIC SSH Connection After Manual Synchronization    ${SERVICEUSER_NEW_PWD_3}

    Log    Step 13: Perform RANNIC SSH login to serviceuser using old password          console=true
    Run keyword and expect error   *Authentication failed for user 'serviceuser'.*
    ...                            RANNIC SSH Connection After Manual Synchronization    ${SERVICEUSER_NEW_PWD_2}
    # The "Run Keyword and Ignore Error" was added due to bug in TAF. When fixed - should be removed!
    [Teardown]  Run keywords        Log    Step 14: Teardown          console=true
    ...   AND                       Remove All Generated Keys       RSA_key=3RD_RSA_key    serviceuser_pass=${SERVICEUSER_NEW_PWD_3}
    ...   AND                       Log    Changing parameter actSshToRanNic on vDU to flase         console=true
    ...   AND                       Run keyword and ignore error    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1
    ...                             param_name=actSshToRanNic   param_value=false    hw_type=vDU
    ...   AND                       Log   Deleting parameter rootUserPublicKeys on vDU        console=true
    ...   AND                       Run Keyword and Ignore Error   Delete Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1
    ...                             param_name=rootUserPublicKeys   hw_type=vDU