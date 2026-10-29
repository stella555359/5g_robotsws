*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    Maintainer:
...    Description: block/unblock cells in NR site

Resource         taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource         ./resources/keywords.robot

Variables        taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup      Common Suite Setup With OnAir Test Line Preparation
...              swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...              increase_timeout_for_update_sw=900
...              prefix_tag=Configuration_TL_22

Test Setup       Common Preconditions

Test Teardown    Common Postconditions

*** Test Cases ***
# testsuite/Nanjing/OAM/CB008827/CB008827_OAMP_RMOD.robot
[1][1.0] CB008827-J_TC11_Cell_Block_unBlock
    Log Current Time
    Block All pRRH Cells
    Verify BTS Active Alarms After Cell Block
    Unblock All pRRH Cells
    Verify BTS Active And Historic Alarms After Cell Unblock
    [Teardown]    Test Teardown For BTS Cell Block

[1][1.0] CB008827-J_TC06_CB007758_pRRH_reset
    Log Current Time
    Reset All pRRH Units
    Wait Until All Radio Units Are Available
    Wait For All Cells To Be Operating Correctly
    Wait Until BTS Is OnAir
    Verify BTS Active Alarms After Radio Units Reset

[1][1.0] CB008827-J_TC08_CB007758_pRRH_lock_unlock
    Lock All pRRH Units
    Wait For All pRRH Units To Be Locked
    Verify BTS Active Alarms After Radio Units Lock
    Unlock All pRRH Units
    Wait Until All Radio Units Are Available
    Wait For All Cells To Be Operating Correctly
    Wait Until BTS Is OnAir
    Verify BTS Active Alarms After Radio Units Unlock
