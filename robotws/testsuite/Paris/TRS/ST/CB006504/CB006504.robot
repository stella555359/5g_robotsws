*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB006504: Flexible synchronization management behavior

Library             taf.sbts.oam.coam.admin    WITH NAME    coam
Library             taf.transport.ssh    WITH NAME    ssh
Library             ../Resources/SwitchManager.py
Library             DateTime
Library             taf.collectors.core    WITH NAME    core
Library             taf.collectors.btslog    WITH NAME    btslog
Library             ../Resources/TrsUtil.py
Resource            ../Resources/Common.robot
Resource            ../Resources/COAM.robot
Resource            ../Resources/Logs.robot
Resource            Keywords.robot
Resource            Variables.robot

Suite Setup         CB006504 Setup


*** Test Cases ***
[1]CB006504_1_TC_01_NR_TDD_alarm_raised_radio_disabled_or_not_radio_recovery
    [Setup]    Test Setup
    Run Keyword And Continue On Failure    NRTDD disabled and recovery
    [Teardown]    Test Teardown

# [1]CB006504_1_TC_02_EN-DC_alarm_raised_service_not_disabled_radio_disabled_radio_recovery
#    [Setup]    Test Setup
#    Run Keyword And Continue On Failure    ENDC not disabled
#    [Teardown]    Test Teardown

# [1]CB006504_1_TC_03_DSS_alarm raised_service_radio_disabled or_not_service_recovery
#    [Setup]    Test Setup
#    Run Keyword And Continue On Failure    DSS disabled and recovery
#    [Teardown]    Test Teardown

# [1]CB006504_1_TC_14_DSS_cells_locks_unlocks_while_TE_increases_decreases
#    [Setup]    Test Setup
#    Run Keyword And Continue On Failure    DSS lock unlock
#    [Teardown]    Test Teardown

# [1]CB006504_1_TC_41_CA_disabled_by_PCell_adaptive_HO_estimated_TE_exceeds_TE_allowed
#    [Setup]    Test Setup
#    Run Keyword And Continue On Failure    CA_disabled_by_PCell_HO
#    [Teardown]    Test Teardown

# CB006504_debug
#    [Setup]    Test Setup
#    Run Keyword And Continue On Failure    Test Debug
#    [Teardown]    Test Teardown
