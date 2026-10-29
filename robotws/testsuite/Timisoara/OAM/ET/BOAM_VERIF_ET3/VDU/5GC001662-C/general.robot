*** Settings ***
Documentation
...    Author: Andrada Bugiu
...    Maintainer: Adrian Alpredi (adrian.alpredi@nokia.com)
...    Group in charge: BTS_OAM_CU
...    References: doors
...    Feature Description: 5GC001662-C
...    Sample execution: robot -v vDU:https://10.5.62.66 -L TRACE -b debug.log
...    -d results/5GC001662-C /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_CU/5GC001662-C/general.robot

Resource    resources/5GC001662-C.robot
Resource    resources/xpath_1662-C.robot
Suite Setup     run keyword  Login vDU
Suite Teardown  Run Keyword And Ignore Error  Logout vDU
Force Tags      CRT   CIT    requires-ipv4    5G_RAN    CLOUD_5G_AIC    product-vDU


*** Test Cases ***
[1]2. Check if vDU WebEM can be accessed using supported version of Google Chrome and Mozilla Firefox
    [Tags]         CRT
    Check notification doesn`t appear


[1]17. Check if vDU WebEM session info can be checked
    [Tags]         CRT
    Check session info appears


