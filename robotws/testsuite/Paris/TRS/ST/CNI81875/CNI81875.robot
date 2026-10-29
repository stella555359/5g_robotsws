*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CNI81875: SyncE Assisted Holdover

Library             taf.gnb.oam.coam.admin    WITH NAME    coam
Library             taf.transport.ssh    WITH NAME    ssh
Library             ../Resources/SwitchManager.py
Library             DateTime
Library             taf.collectors.core    WITH NAME    core
Library             taf.collectors.btslog    WITH NAME    btslog
Resource            ../Resources/Common.robot
Resource            ../Resources/COAM.robot
Resource            ../Resources/Logs.robot
Resource            Keywords.robot
Resource            Variables.robot

Suite Setup         CNI81875 Setup


*** Test Cases ***
[1]CNI71176_TC_03_Backplane PTP Sync Holdover with feature activated
    [Setup]    Test Setup
    Run Keyword And Continue On Failure    PTP shutdown and GNB Sync Holdover    1 hour
    [Teardown]    Test Teardown

# [1]CNI71176_TC_06_Backplane PTP Sync long Holdover with feature activated
#    [Setup]    Test Setup
#    Run Keyword And Continue On Failure    PTP shutdown and GNB Sync Holdover    72 hours
#    [Teardown]    Test Teardown
