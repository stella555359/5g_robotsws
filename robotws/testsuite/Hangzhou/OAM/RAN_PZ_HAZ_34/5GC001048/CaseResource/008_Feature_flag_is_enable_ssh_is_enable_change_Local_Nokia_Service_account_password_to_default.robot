*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Feature_flag_is_enable_ssh_is_enable_change_Local_Nokia_Service_account_password_to_default
    Change All Password To Non-Default
    Step2: Enable Default Password Alarm And Check No Alarm
    Step3: Disable Service Account SSH And Change serviceuser Password To Default And Check Alarm
    Step4: Change serviceuser Password To Non-Default And Check No Alarm
    Step5: Enable Service Account SSH And Change serviceuser Password To Default And Check Alarm

Case Setup 008
    Common Setup

Case Teardown 008
    Common Teardown

Step2: Enable Default Password Alarm And Check No Alarm
    COAM Update Parameter
    ...   dist_name=${MO_NAME}/MNL-1/AMGR-1
    ...   parameter=enableDefaultPasswdAlarm
    ...   value=true
    Wait Until Keyword Succeeds   1m   10s   Check Fault 4459 Cleared

Check Fault 4459 Default User Detail Only serviceuser
    @{contain_list}   Create List
    ...   Nokia Service User Non Root Account (serviceuser)

    @{not_contain_list}   Create List
    ...   Bts Sys Admin (Nemuadmin)
    ...   Nokia Service User Root Account (toor4nsn)
    Run Keyword If   '${PROD_VAR}'=='sBTS'   Append To List   ${not_contain_list}   Dcc Account Access (dcuser)

    Wait Until Keyword Succeeds   1m   10s
    ...   Check Fault 4459 Default User Detail   contain_list=${contain_list}   not_contain_list=${not_contain_list}

Step3: Disable Service Account SSH And Change serviceuser Password To Default And Check Alarm
    COAM Update Parameter
    ...   dist_name=${MO_NAME}/MNL-1/MNLENT-1/SECADM-1
    ...   parameter=actServiceAccountSsh
    ...   value=false
    Change serviceuser Password To Default Without Delete shadow
    Check Fault 4459 Default User Detail Only serviceuser

Step4: Change serviceuser Password To Non-Default And Check No Alarm
    Change serviceuser Password To Non-Default
    Wait Until Keyword Succeeds   1m   10s   Check Fault 4459 Cleared

Step5: Enable Service Account SSH And Change serviceuser Password To Default And Check Alarm
    COAM Update Parameter
    ...   dist_name=${MO_NAME}/MNL-1/MNLENT-1/SECADM-1
    ...   parameter=actServiceAccountSsh
    ...   value=true
    Change serviceuser Password To Default Without Delete shadow
    Check Fault 4459 Default User Detail Only serviceuser
