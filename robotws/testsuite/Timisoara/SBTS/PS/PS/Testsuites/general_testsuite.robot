*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for Power Saving tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRANxxxx -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_16_UTESRANxxxx
...    testsuite/Wroclaw/OAM/regression/MN_RAN_PZ_3_WRO_SG01/PS/Testsuites/general_testsuite.robot


Resource        ../Testcases/PS.01_Grace_Cell_Down_via_NA/test.robot
Resource        ../Testcases/PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade/test.robot
Resource        ../Testcases/PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset/test.robot
Resource        ../Testcases/PS.04_LTE1103-A_Power_Saving_Groups_Activation_via_Admin/test.robot
Resource        ../Testcases/PS.05_LTE1203_Reduced_Power_Saving_Activation_via_Admin/test.robot
Resource        ../Testcases/PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin/test.robot
Resource        ../Testcases/PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario/test.robot
Resource        ../Testcases/PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock/test.robot
Resource        ../Testcases/PS.09_5GC001553_Intelligent_shut_down_recommissioning_during_power_break/test.robot
Resource        ../Testcases/PS.10_CB007416_Load_based_carrier_switch_off_on_for_PS_on_TDD/test.robot
Resource        ../Testcases/PS.11_5GC001553_Intelligent_shut_down_with_WCDMA_RAT_reset/test.robot
Resource        ../Testcases/PS.12_LTE3330_A_Load_based_Power_Saving_for_AirScale_SM_for_Energy_Efficiency/test.robot
Resource        ../Testcases/PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin/test.robot
Resource        ../Testcases/PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells/test.robot
Resource        ../Testcases/PS.22_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203/test.robot
Resource        ../Testcases/PS.23_PS_CB008800_Check_SR003080_interworking_with_CB008800/test.robot
Resource        ../Testcases/PS.24_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080/test.robot
Resource        ../Testcases/PS.25_CB008800_Power_saving_configuration_change/test.robot
Resource        ../Testcases/PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080/test.robot
Resource        ../Testcases/PS.43_CB010683-B_Mixed_switch_off_with_extended_configuration_activation_and_deactivation/test.robot

Force Tags
...           SBTS00  SBTS23R1  SBTS22R4  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_ST  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY39  ## force python3 UTE package

Suite Setup       Test Suite Setup
Suite Teardown    Test Suite Teardown

*** Test Cases ***
[1][1.0] Automated__PS__LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade
    [Setup]  common.Common Test Setup
    PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade
    [Teardown]  PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade.Test Case Teardown

[1][1.0] Automated__PS__Graceful Cell Shut Down
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.01_Grace_Cell_Down_via_NA
    [Teardown]  PS.01_Grace_Cell_Down_via_NA.Test Case Teardown

[1][1.0] Automated__PS__LBT4152-E_Graceful_cell_shutdown_during_parameter_change_with_eNB_reset
    [Setup]  common.Common Test Setup
    PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset
    [Teardown]  PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset.Test Case Teardown

[1][1.0] Automated__PS__LTE1103-A_Power_Saving_Groups_Activation
    [Setup]  common.Common Test Setup
    PS.04_LTE1103-A_Power_Saving_Groups_Activation_via_Admin
    [Teardown]  PS.04_LTE1103-A_Power_Saving_Groups_Activation_via_Admin.Test Case Teardown

[1][1.0] Automated__PS__LTE1203_Reduced_Power_Saving_Activation
    [Setup]  common.Common Test Setup
    PS.05_LTE1203_Reduced_Power_Saving_Activation_via_Admin
    [Teardown]  PS.05_LTE1203_Reduced_Power_Saving_Activation_via_Admin.Test Case Teardown

[1][1.0] Automated__PS__BTS_Reboot_While_Grace_Cell_Down
    [Setup]  common.Common Test Setup
    PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin
    [Teardown]  PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin.Test Case Teardown

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

[1][2.0] PS_CB007416_ Load based carrier switch off_on for PS on TDD
    [Setup]  common.Common Test Setup
    PS.10_CB007416_Load_based_carrier_switch_off_on_for_PS_on_TDD
    [Teardown]  PS.10_CB007416_Load_based_carrier_switch_off_on_for_PS_on_TDD.Test Case Teardown

[1][1.0] PS_SBTS_Intelligent_shut_down_with_WCDMA_RAT_reset
    [Setup]  Common Test Setup
    PS.11_5GC001553_Intelligent_shut_down_with_WCDMA_RAT_reset
    [Teardown]  PS.11_5GC001553_Intelligent_shut_down_with_WCDMA_RAT_reset.Test Case Teardown

[1]Automated__PS__LTE3330-A_Load_based_Power_Saving_for_AirScale_SM_for_Energy_Efficiency
	[Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
	PS.12_LTE3330_A_Load_based_Power_Saving_for_AirScale_SM_for_Energy_Efficiency
	[Teardown]  PS.12_LTE3330_A_Load_based_Power_Saving_for_AirScale_SM_for_Energy_Efficiency.Test Case Teardown

[1][1.0] Automated__PS__SR003080_Reduced_Power_Saving_Online_Activation
    [Setup]  common.Common Test Setup
    PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin
    [Teardown]  PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin.Test Case Teardown

[1]PS__5GC001553_Intelligent_Shutdown_of_multiple_cells
    [Setup]  common.Common Test Setup
    PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells
    [Teardown]  PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells.Test Case Teardown

[1][1.0] PS_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203
    [Setup]  common.Common Test Setup
    PS.22_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203
    [Teardown]  PS.22_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203.Test Case Teardown

[1][2.0] PS_CB008800_Check_SR003080_interworking_with_CB008800
    [Setup]  common.Common Test Setup
    PS.23_PS_CB008800_Check_SR003080_interworking_with_CB008800
    [Teardown]  PS.23_PS_CB008800_Check_SR003080_interworking_with_CB008800.Test Case Teardown

[1][1.0] PS_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080
    [Setup]  common.Common Test Setup
    PS.24_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080
    [Teardown]  PS.24_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080.Test Case Teardown

[1][1.0] PS_CB008800_Power_saving_configuration_change
    [Setup]  common.Common Test Setup
    PS.25_CB008800_Power_saving_configuration_change
    [Teardown]  PS.25_CB008800_Power_saving_configuration_change.Test Case Teardown

[1][1.0] PS_CB008800_Suspend_LTE1103_and_LTE1203_SR003080
    [Setup]  common.Common Test Setup
    PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080
    [Teardown]  PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080.Test Case Teardown

[1][1.0] CB010683-B_Mixed_switch_off_with_extended_configuration_activation_and_deactivation
    [Setup]  common.Common Test Setup
    PS.43_CB010683-B_Mixed_switch_off_with_extended_configuration_activation_and_deactivation
    [Teardown]  PS.43_CB010683-B_Mixed_switch_off_with_extended_configuration_activation_and_deactivation.Test Case Teardown
