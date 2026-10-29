*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Feature_flag_is_enable_alarm_is_raised_update_alarm_by_password_change_to_default
    Enable Default Password Alarm And Check Alarm
    Step2: Change Nemuadmin serviceuser dcuser Password To Non-Default And Check Alarm
    Step3: Change serviceuser dcuser Password To Default And Check Alarm

Case Setup 003
    Common Setup

Case Teardown 003
    Common Teardown

Step2: Change Nemuadmin serviceuser dcuser Password To Non-Default And Check Alarm
    Change Nemuadmin Password To Non-Default
    Change serviceuser Password To Non-Default
    Run Keyword If   '${PROD_VAR}'=='sBTS'   Change dcuser Password To Non-Default
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   10m   1m   COAM Login   password=${non_default_passwd}
    Sleep   2m
    @{contain_list}   Create List
    ...   Nokia Service User Root Account (toor4nsn)

    @{not_contain_list}   Create List
    ...   Bts Sys Admin (Nemuadmin)
    ...   Nokia Service User Non Root Account (serviceuser)
    Run Keyword If   '${PROD_VAR}'=='sBTS'   Append To List   ${not_contain_list}   Dcc Account Access (dcuser)

    Wait Until Keyword Succeeds   1m   10s
    ...   Check Fault 4459 Default User Detail   contain_list=${contain_list}   not_contain_list=${not_contain_list}

    Catch Snapshot And IMS2 File

Step3: Change serviceuser dcuser Password To Default And Check Alarm
    Change serviceuser Password To Default Without Delete shadow
    Run Keyword If   '${PROD_VAR}'=='sBTS'   Change dcuser Password To Default Without Delete dcuser Json
    @{contain_list}   Create List
    ...   Nokia Service User Root Account (toor4nsn)
    ...   Nokia Service User Non Root Account (serviceuser)
    Run Keyword If   '${PROD_VAR}'=='sBTS'   Append To List   ${contain_list}   Dcc Account Access (dcuser)

    @{not_contain_list}   Create List
    ...   Bts Sys Admin (Nemuadmin)

    Wait Until Keyword Succeeds   1m   10s
    ...   Check Fault 4459 Default User Detail   contain_list=${contain_list}   not_contain_list=${not_contain_list}
