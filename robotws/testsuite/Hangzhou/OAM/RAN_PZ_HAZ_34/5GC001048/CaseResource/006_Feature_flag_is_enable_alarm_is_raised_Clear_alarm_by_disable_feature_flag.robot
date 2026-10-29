*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Feature_flag_is_enable_alarm_is_raised_Clear_alarm_by_disable_feature_flag
    Enable Default Password Alarm And Check Alarm
    Disable Default Password Alarm And Check No Alarm
    Reset Site And Check Alarm Cleared

Case Setup 006
    Common Setup

Case Teardown 006
    COAM Update Parameter
    ...   dist_name=${MO_NAME}/MNL-1/AMGR-1
    ...   parameter=enableDefaultPasswdAlarm
    ...   value=false
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   1m   10s   Check Fault 4459 Cleared
    Run Keyword And Ignore Error   COAM Logout
    CI_interface.Common Case Teardown
