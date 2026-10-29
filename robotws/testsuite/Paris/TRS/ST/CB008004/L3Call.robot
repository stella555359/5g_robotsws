*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB008004: Flexible synchronization management behavior

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
Resource            Keywords.robot
Resource            Variables.robot

Suite Setup         CB008004-CC Setup


*** Test Cases ***
L3Call Only
    [Setup]    Test Setup
    Run Keyword And Continue On Failure    L3Call Only
    [Teardown]    Test Teardown
