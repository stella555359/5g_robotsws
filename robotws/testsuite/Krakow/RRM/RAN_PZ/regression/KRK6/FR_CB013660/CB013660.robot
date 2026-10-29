*** Settings ***
Documentation
...    author: Kamil Bielecki, Mikolaj Borkowski
...    contact: kamil.bielecki@nokia.com, mikolaj.borkowski@nokia.com
...    description: Test Cases for CB013660

Resource          ./resources/keywords.robot


Suite Setup    Suite Setup
Suite Teardown    Suite Teardown


*** Test Cases ***
CB013660-SR-A#B01_Policy_User-Configured_SmallCell_RU
    [Setup]    RU SW Only Test Setup
    Perform RU SW Only Upgrade With Simultaneous RU Activation Reset
    Check For DU Rollback Rejected After Ru Only Upgrade
    Rollback RU SW Only
    Perform RU SW Only Upgrade With Sequential RU Activation Reset
    Check For DU Rollback Rejected After Ru Only Upgrade
    Rollback RU SW Only
    Perform RU SW Only Upgrade With User Defined RU Activation Reset
    Check For DU Rollback Rejected After Ru Only Upgrade
    Rollback RU SW Only
   [Teardown]    RU SW Only Test Teardown


CB013660-SR-A#B02_RU+DU_Activate_Simultaneous_SmallCell_RU
    [Setup]    RU+DU Test Setup
    Perform DU SW Upgrade With Simultaneous RU Activation Reset
    Rollback DU SW
    Wait until all cells are onair
    Verify only allowed alarms present on gNB
    [Teardown]    RU+DU Test Teardown
