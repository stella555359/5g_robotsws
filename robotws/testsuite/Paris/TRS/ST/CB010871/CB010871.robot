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

Suite Setup         CB010871 Setup


*** Test Cases ***
[1]CB010871_B_TC_56_Max_configuration_on_50G_link_through_switched_network
    [Setup]    Test Setup
    Run Keyword And Continue On Failure    SFP56 on Yoda and switched network
    [Teardown]    Test Teardown

# [1]CB010871_TC_08_16_Streams_configuration_over_a_50G_link
#    [Setup]    Test Setup
#    Run Keyword And Continue On Failure    SFP56 on Yoda and 16 streams
#    [Teardown]    Test Teardown

# [1]CB010871_TC_57_32_Streams_configuration_over_a_50G_link
#    [Setup]    Test Setup
#    Run Keyword And Continue On Failure    SFP56 on Fisto and 32 streams
#    [Teardown]    Test Teardown

# CB010871_debug
