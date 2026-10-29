*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for Power Saving tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRAN3870 -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_16_UTESRAN3870 testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG01/PS/Testsuites/SBTS_8395/sbts_crt.robot


Resource        ../../Testcases/PS.01_Grace_Cell_Down_via_NA/test.robot
Resource        ../../Testcases/PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade/test.robot
Resource        ../../Testcases/PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset/test.robot
Resource        ../../Testcases/PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario/test.robot
Resource        ../../Testcases/PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock/test.robot
Resource        ../../Testcases/PS.09_5GC001553_Intelligent_shut_down_recommissioning_during_power_break/test.robot


Force Tags
...           SBTS00  SBTS23R1  SBTS22R4  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_ST  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY39  ## force python3 UTE package

Test Timeout  24 hours

Suite Setup       Test Suite Setup
Suite Teardown    Test Suite Teardown

*** Test Cases ***
#[1][1.0] Automated__PS__LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade
#    [Setup]  common.Common Test Setup
#    PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade
#    [Teardown]  PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade.Test Case Teardown

[1][1.0] Automated__PS__Graceful Cell Shut Down
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.01_Grace_Cell_Down_via_NA
    [Teardown]  PS.01_Grace_Cell_Down_via_NA.Test Case Teardown

[1][1.0] Automated__PS__LBT4152-E_Graceful_cell_shutdown_during_parameter_change_with_eNB_reset
    [Setup]  common.Common Test Setup
    PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset
    [Teardown]  PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset.Test Case Teardown

[1][1.0] Automated__PS__5GC001553 Intelligent Cell Shutdown cancelling scenario
    [Setup]  common.Common Test Setup
    PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario
    [Teardown]  PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario.Test Case Teardown

[1][2.0] 5GC001553_Intelligent_Shutdown_cells_block_unblock
    [Setup]  common.Common Test Setup
    PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock
    [Teardown]  PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock.Test Case Teardown

[1][1.0] PS_SBTS_Intelligent_shut_down_recommissioning_during_power_break
    [Setup]  common.Common Test Setup
    PS.09_5GC001553_Intelligent_shut_down_recommissioning_during_power_break
    [Teardown]  PS.09_5GC001553_Intelligent_shut_down_recommissioning_during_power_break.Test Case Teardown
