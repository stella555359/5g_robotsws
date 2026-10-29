*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB010802: Deep Sleep Mode Support for RF6.1 TDD RRH

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

Suite Setup         CB010802 Setup


*** Test Cases ***
[1]CB010802_SISO_TC_1_RU_enters_deep_sleep_mode_based_on_cell_switch_off
    [Setup]    Test Setup
    Run Keyword And Continue On Failure    RU enters deep sleep mode
    [Teardown]    Test Teardown

# DEBUG
#    Run Keyword And Continue On Failure    Test Debug
