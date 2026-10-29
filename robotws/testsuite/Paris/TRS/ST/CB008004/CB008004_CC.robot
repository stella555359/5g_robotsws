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

Suite Setup         CB008004-CC Setup


*** Test Cases ***
[1]CB008004-CC_TC_02 Configure Feature on Concurrent 4G TDD - 5G TDD (CMCC timings with timing adjustment)
    [Setup]    Test Setup
    Run Keyword And Continue On Failure    Configure Feature on Concurrent 4G TDD 5G TDD
    [Teardown]    Test Teardown

# CB008004_debug
#    [Setup]    Test Setup
#    Run Keyword    COAM Get SW Branch    ${bts_addr}
#    [Teardown]    Test Teardown
