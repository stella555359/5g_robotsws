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
Resource            ../Resources/UE_Android.robot
Resource            Keywords.robot
Resource            Variables.robot

Suite Setup         CB010294 Setup


*** Test Cases ***
[1]CB010294_TC_03_L3_call_and_traffic_with_Nokia_SFP56-LR_eCPRI_link_in_ABIO
    [Setup]    Test Setup
    Run Keyword And Continue On Failure    L3 Call with SFP56 on ABIO
    [Teardown]    Test Teardown

# CB010294_debug
