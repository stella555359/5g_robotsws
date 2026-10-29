*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Feature_flag_is_disable_with_default_password_enable_flag
    Disable Default Password Alarm And Check No Alarm
    Enable Default Password Alarm And Check Alarm
    Step3: Reset Site And Check Alarm Set Again

Case Setup 007
    Common Setup

Case Teardown 007
    COAM Update Parameter
    ...   dist_name=${MO_NAME}/MNL-1/AMGR-1
    ...   parameter=enableDefaultPasswdAlarm
    ...   value=false
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   1m   10s   Check Fault 4459 Cleared
    Run Keyword And Ignore Error   COAM Logout
    CI_interface.Common Case Teardown

Step3: Reset Site And Check Alarm Set Again
    COAM Reset Site
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   20m   1m   COAM Check BTS OnAir
    Wait Until Keyword Succeeds   1m   10s   Check Fault 4459 All Users Listed In Detail