*** Settings ***
Documentation  Suite fot the regression of the feature 5GC002568-C/D
...  Authors:  Marzena Skolucka, Aleksander Lagierski
...  Contact:  marzena.skolucka@nokia.com, aleksander.lagierski@nokia.com

Resource  ./resources/keywords.robot
Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables  taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags    STATE_GNB_NOT_COMMISSIONED    CRT     PY36


Suite Setup   Run Keywords      Common Suite Setup With Commissioning
...               AND   Verify Chk Sys Cmd
Suite Teardown  Common Suite Teardown

Test Setup  Common Preconditions
Test Teardown  Common Postconditions

*** Test Cases ***
[1]Verify_gNB_UE_attach_detach
    Attach and Detach

[1]Verify_SgNBAddition_setup
    Verify SgNBAddition

[1]Verify_DLUL_traffic_with_MCS0
    Start DL and UL Data Transfer

[1]Verify_DLUL_traffic_with_MCS0_after_cell_lock_unlock
    [Tags]
    Lock Unlock Cells
    Start DL and UL Data Transfer

[1]Verify_DLUL_traffic_with_MCS0_after_RU_reset
    Perform RU reset
    Start DL and UL Data Transfer

[1]Verify_DLUL_traffic_normal_after_system_restart
    Perform gNB reset
    Start DL and UL Data Transfer
