*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Feature_flag_is_enable_password_change_to_default
    Step1: Check Invalid Password To Raise Exception
    Step2: Check Invalid User To Raise Exception
    Step3: Enable Default Password Alarm And Change All Password To Non-Default And Check No Alarm

Case Setup 002
    Common Setup

Case Teardown 002
    Common Teardown

Step1: Check Invalid Password To Raise Exception
    ${err_web_new_pwd}   Run Keyword And Return Status
    ...   COAM Change WEBEM Password   old_password=${Nemuadmin_passwd}   new_password=error_new_password
    ${err_ssh_old_pwd}   Run Keyword And Return Status
    ...   COAM Change SSH Password   username=toor4nsn   old_password=error_old_password   new_password=${non_default_passwd}
    ${err_ssh_new_pwd}   Run Keyword And Return Status
    ...   COAM Change SSH Password   username=toor4nsn   old_password=${toor4nsn_passwd}   new_password=error_new_password
    Should Not Be True   ${err_web_new_pwd}
    Should Not Be True   ${err_ssh_old_pwd}
    Should Not Be True   ${err_ssh_new_pwd}

Step2: Check Invalid User To Raise Exception
    COAM Enable Local Account State And Change Password

    Run Keyword And Ignore Error   COAM Logout
    COAM Login   username=BTSSecurity   password=${non_default_passwd}
    ${btssecurity_status}   Run Keyword And Return Status   COAM Update Parameter
    ...   dist_name=${MO_NAME}/MNL-1/AMGR-1
    ...   parameter=enableDefaultPasswdAlarm
    ...   value=true

    Run Keyword And Ignore Error   COAM Logout
    COAM Login   username=BTSApplication   password=${non_default_passwd}
    ${btsapplication_status}   Run Keyword And Return Status   COAM Update Parameter
    ...   dist_name=${MO_NAME}/MNL-1/AMGR-1
    ...   parameter=enableDefaultPasswdAlarm
    ...   value=true

    Run Keyword And Ignore Error   COAM Logout
    COAM Login   username=BTSRead   password=${non_default_passwd}
    ${btsread_status}   Run Keyword And Return Status   COAM Update Parameter
    ...   dist_name=${MO_NAME}/MNL-1/AMGR-1
    ...   parameter=enableDefaultPasswdAlarm
    ...   value=true

    Should Be True   ${btssecurity_status}
    Should Not Be True   ${btsapplication_status}
    Should Not Be True   ${btsread_status}

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   COAM Logout   AND
    ...   Wait Until Keyword Succeeds   15m   1m   COAM Login   AND
    ...   COAM Change Local Account State By Commission   enable=false

Step3: Enable Default Password Alarm And Change All Password To Non-Default And Check No Alarm
    COAM Update Parameter
    ...   dist_name=${MO_NAME}/MNL-1/AMGR-1
    ...   parameter=enableDefaultPasswdAlarm
    ...   value=true
    Change All Password To Non-Default
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   10m   30s   COAM Login   password=${non_default_passwd}
    Sleep   1m
    Wait Until Keyword Succeeds   1m   10s   Check Fault 4459 Cleared
