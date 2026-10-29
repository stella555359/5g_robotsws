*** Settings ***
Documentation
...    Author: Adrian Alpredi
...    Maintainer: Adrian Alpredi (adrian.alpredi@nokia.com)
...    Group in charge: BTS_OAM_CU
...    References: doors
...    Feature Description: 5GC001662-H-a

Resource    resources/5GC001662-H-a.robot
Resource    resources/xpath_1662-H-a.robot
Force Tags      CRT      requires-ipv4    5G_RAN    CLOUD_5G_AIC    product-vDU

Suite Setup     Run Keyword and Ignore Error  Login vDU
Suite Teardown  Run Keyword and Ignore Error  Logout vDU

*** Test Cases ***
[1][1.0] 7_5GC001662Ha_Check_active_alarm_list_in_vDU_WebEM
    [Tags]         CRT
    Check active alarms
