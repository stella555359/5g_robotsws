*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB013569: RU config

Library             taf.sbts.oam.coam.admin    WITH NAME    coam
Library             taf.transport.ssh    WITH NAME    ssh
Library             ../Resources/SwitchManager.py
Library             DateTime
Library             taf.collectors.core    WITH NAME    core
Library             taf.collectors.tcpdump    WITH NAME    tcpdump
Library             taf.collectors.btslog    WITH NAME    btslog
Library             ../Resources/TrsUtil.py
Library             SSHLibrary
Library             taf.ue
Resource            ../Resources/Common.robot
Resource            ../Resources/COAM.robot
Resource            ../Resources/Logs.robot
Resource            ../Resources/UE_Android.robot
Resource            Keywords.robot
Resource            Variables_A.robot

Suite Setup         CB013569_A Setup


*** Test Cases ***
[1]CB013569_A
    [Setup]    Test Setup
    Run Keyword And Continue On Failure    AWHKB type
    [Teardown]    Test Teardown
