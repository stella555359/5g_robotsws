*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB010766: Deep Sleep Mode Support for RF6.1 TDD RRH

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

Suite Setup         CB010766 Setup


*** Test Cases ***
[1]CB010766_SISO_TC_2_dedicated_time_window_configuration_for_deep_sleep_mode_multiple_RAT
    [Setup]    Test Setup
    Run Keyword And Continue On Failure    dedicated time window configuration for deep sleep mode
    [Teardown]    Test Teardown

# DEBUG
#    Run Keyword And Continue On Failure    Test Debug
