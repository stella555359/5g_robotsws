*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Feature_flag_is_enable_alarm_is_raised_Clear_alarm_by_password_change_to_non_default
    Enable Default Password Alarm And Check Alarm
    Step2: Change All Password To Non-Default And Check No Alarm
    Reset Site And Check Alarm Cleared

Case Setup 005
    Common Setup

Case Teardown 005
    Common Teardown

Step2: Change All Password To Non-Default And Check No Alarm
    Change All Password To Non-Default
    Run Keyword And Ignore Error   COAM Logout
    COAM Login   password=${non_default_passwd}
    Sleep   1m
    Wait Until Keyword Succeeds   1m   10s   Check Fault 4459 Cleared
