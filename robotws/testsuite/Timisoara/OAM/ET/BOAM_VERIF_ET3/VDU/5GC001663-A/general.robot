*** Settings ***
Documentation
...    Author: Adelina Gordan
...    Maintainer: Adrian Alpredi (adrian.alpredi@nokia.com)
...    Group in charge: BTS_OAM_CU
...    References: doors
...    Feature Description: 5GC001663-A

Resource    ./resources/5GC001663-A.robot
Resource    ./resources/xpath_1663-A.robot

Suite Setup     run keyword  Login vDU
Suite Teardown  Run Keyword And Ignore Error  Logout vDU
Force Tags      CRT      requires-ipv4    5G_RAN    CLOUD_5G_AIC    product-vDU

*** Test Cases ***
[1][1.0] 1.Check if after fault 4527 is raised , logs are collected in snapshot on vDU
    [Tags]         CRT
    Generate fault 4527
    Check fault 4527 is raised
    Collect logs in snapshot
    Check logs are collected
    #Reset vDU
