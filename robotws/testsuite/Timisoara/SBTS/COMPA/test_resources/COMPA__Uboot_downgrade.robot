*** Settings ***
Documentation  Main purpose of TC is to downgrade the uboot on SBTS

Resource  ../../common_resources/ca_CIT_general.robot
Library   ../../common_resources/python_resources/uboot_downgrade.py


*** Keywords ***
TC__COMPA__Uboot_Downgrade
    [Documentation]
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  16.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26994
    ...  26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27601 - Add check for mapping logs2-mnt directory
    ...  25.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30528 - Change uboot downgrade method
    ...  *******************

    Set Tags  CA-COMPA  OWNER-daniel.cozma@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  PHASE-CRT  SW-SBTS  SW-FDSW  SW-FSM3

    Downgrade Uboot


Downgrade Uboot
    [Timeout]  30min
    Log  Downgrade Uboot  console=true

    ${bts_reset}  Perform Uboot Downgrade
    IF  ${bts_reset}
      Log  Downgrade Uboot finish, performing site reset.  console=true
      Perform Site Reset
    ELSE
      Log  No uboot update needed.  console=true
    END


TC Setup
    Common Test Setup  tc_name=COMPA__Uboot_downgrade


TC Teardown
    Common Test Teardown
