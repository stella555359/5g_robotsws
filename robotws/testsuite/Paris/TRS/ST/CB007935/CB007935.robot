*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB007935: Radio Unit (RU) synchronization holdover

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

Suite Setup         CB007935 Setup


*** Test Cases ***
[1]CB007935_A_TC_01 SyncE_assisted_HO_period_estimation_with_warm_reset on RU Yoda
    [Setup]    Test Setup
    Run Keyword And Continue On Failure    check Warm Reset on Yoda
    [Teardown]    Test Teardown

[1]CB007935_A_TC_03 SyncE_modify_acceptance_level_SSM_QL on RU Yoda
    [Setup]    Test Setup
    Run Keyword And Continue On Failure    change SSM acceptance Level on Yoda
    [Teardown]    Test Teardown

[1]CB007935_B_TC_02 SyncE_assisted_HO_period expiration on RU Yoda
    [Setup]    Test Setup
    Run Keyword And Continue On Failure    HO expiration on RU Yoda
    [Teardown]    Test Teardown

[1]CB007935_C_TC_02_SyncE_manual_assisted_HO_until_expiration _on_RU_Yoda
    [Setup]    Test Setup
    Run Keyword And Continue On Failure    manual HO expiration on RU Yoda
    [Teardown]    Test Teardown

[1]CB007935_B_TC_33 SyncE Assisted HO and Deep Sleep mode_I
    [Setup]    Test Setup
    Assisted HO and Deep Sleep Mode
    [Teardown]    Test Teardown
