*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for Power Saving tests execution
...    Group in charge: I_MN_RAN_RD_VRF_TSR1_5 <I_MN_RAN_RD_VRF_TSR1_5@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Timisoara.10_18_UTESRANCLOUD1819 -C on -T -d /home/ute/test_results
...    -L TRACE -b debug.log -V testline_configuration/10_18_UTESRANCLOUD1819
...    testsuite/Timisoara/SBTS/PS/PS/Testsuites/SBTS_55201/sbts_crt.robot

Resource        ../../Testcases/PS.28_CB008745_Switching_On_Cell_NR/test.robot
Resource        ../../Testcases/PS.37_CB008745_Suspend_Power_Saving_NR/test.robot
Resource        ../../Testcases/PS.38_CB008745_Backward_compatibility_NR/test.robot
Resource        ../../Testcases/PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI/test.robot
Resource        ../../Testcases/PS.35_CB006830_Automated_GCS_during_BBMOD_reset_via_HWRESETREQ_NA/test.robot
Resource        ../../Testcases/PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown/test.robot
Resource        ../../Testcases/PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ/test.robot
Resource        ../../Testcases/PS.22_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203/test.robot
Resource        ../../Testcases/PS.24_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080/test.robot
Resource        ../../Testcases/PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080/test.robot
Resource        ../../Testcases/PS.25_CB008800_Power_saving_configuration_change/test.robot
Resource        ../../Testcases/PS.27_CB008800_Overlapping_Cell_Periods/test.robot
Resource        ../../Testcases/PS.23_PS_CB008800_Check_SR003080_interworking_with_CB008800/test.robot
Resource        ../../Testcases/PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock/test.robot
Resource        ../../Testcases/PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario/test.robot
Resource        ../../Testcases/PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset/test.robot
Resource        ../../Testcases/PS.05_LTE1203_Reduced_Power_Saving_Activation_via_Admin/test.robot
Resource        ../../Testcases/PS.04_LTE1103-A_Power_Saving_Groups_Activation_via_Admin/test.robot
Resource        ../../Testcases/PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells/test.robot
Resource        ../../Testcases/PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin/test.robot
Resource        ../../Testcases/PS.36_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking/test.robot
Resource        ../../Testcases/PS.09_5GC001553_Intelligent_shut_down_recommissioning_during_power_break/test.robot
Resource        ../../Testcases/PS.11_5GC001553_Intelligent_shut_down_with_WCDMA_RAT_reset/test.robot
Resource        ../../Testcases/PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving/test.robot
Resource        ../../Testcases/PS.32_RAN955_Power_saving_mode_for_3G/test.robot


Force Tags
...           SBTS00  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY39  ## force python3 UTE package
...           CLOUD_SRAN_NLWG_10819_1ASIM_1ABIP_1ABIQ_1ASIB_1ABIA_1ABIN_3AZNA_1AHPMDA_1AHFIB_UTECA
...           SKIP_INSTALL_TOOLS
#...           SKIP_SCF_VALIDATION

Test Timeout  24 hours

#Suite Setup       Test Suite Setup
#Suite Teardown    Test Suite Teardown

*** Variables ***
${att_port_1}         ${tl.enbs[0].rms[0].attenuation_ports[0].port_no}
${att_port_2}         ${tl.enbs[0].rms[0].attenuation_ports[1].port_no}
${att_port_3}         ${tl.enbs[0].rms[0].attenuation_ports[2].port_no}
${att_port_4}         ${tl.enbs[0].rms[0].attenuation_ports[3].port_no}
${att_port_5}         ${tl.enbs[0].rms[1].attenuation_ports[0].port_no}
${att_port_6}         ${tl.enbs[0].rms[1].attenuation_ports[1].port_no}
${att_port_7}         ${tl.enbs[0].rms[1].attenuation_ports[2].port_no}
${att_port_8}         ${tl.enbs[0].rms[1].attenuation_ports[3].port_no}
${att_port_9}         ${tl.enbs[0].rms[2].attenuation_ports[0].port_no}
${att_port_10}        ${tl.enbs[0].rms[2].attenuation_ports[1].port_no}
${att_port_11}        ${tl.enbs[0].rms[2].attenuation_ports[2].port_no}
${att_port_12}        ${tl.enbs[0].rms[2].attenuation_ports[3].port_no}
${att_port_numbers}    ${tl.attenuator[0].attenuation_port_numbers}

${WBTS_ID}  10819
@{PWSM_WCELs}  38190

*** Test Cases ***

[1][2.0] 5GC001553_Intelligent_Shutdown_cells_block_unblock
    [Setup]  Run Keywords  common.Common Test Setup
    PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock
    [Teardown]  PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock.Test Case Teardown

[1][1.0] Automated__PS__5GC001553 Intelligent Cell Shutdown cancelling scenario
    [Setup]  Run Keywords  common.Common Test Setup
    PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario
    [Teardown]  PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario.Test Case Teardown

[1][1.0] PS_SBTS_Intelligent_shut_down_recommissioning_during_power_break
    [Setup]  common.Common Test Setup
    PS.09_5GC001553_Intelligent_shut_down_recommissioning_during_power_break
    [Teardown]  PS.09_5GC001553_Intelligent_shut_down_recommissioning_during_power_break.Test Case Teardown

[1][1.0] PS__5GC001553_Intelligent_Shutdown_of_multiple_cells
    [Setup]  Run Keywords  common.Common Test Setup
    PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells
    [Teardown]  PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells.Test Case Teardown

####################################################################
#[1][1.0] Automated__PS__CB008745_Switching_On_Cell_NR
#    [Setup]  common.Common Test Setup
#    PS.28_CB008745_Switching_On_Cell_NR
#    [Teardown]  PS.28_CB008745_Switching_On_Cell_NR.Test Case Teardown

#[1][1.0] Automated__PS__CB008745_Suspend_Power_Saving_NR
#    [Setup]  common.Common Test Setup
#    PS.37_CB008745_Suspend_Power_Saving_NR
#    [Teardown]  PS.37_CB008745_Suspend_Power_Saving_NR.Test Case Teardown

#[1][1.0] Automated__PS__CB008745_ Backward_compatibility_NR
#    [Setup]  common.Common Test Setup
#    PS.38_CB008745_Backward_compatibility_NR
#    [Teardown]  PS.38_CB008745_Backward_compatibility_NR.Test Case Teardown

#[1][1.0] CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI
#    [Setup]  common.Common Test Setup
#    PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI
#   [Teardown]  PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI.Test Case Teardown

#[1][1.0] CB006830_Automated_Graceful_Cell_Shutdown_during_BBMOD_reset_via_HWRESETREQ_NA
#    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
#    PS.35_CB006830_Automated_GCS_during_BBMOD_reset_via_HWRESETREQ_NA
#    [Teardown]  PS.35_CB006830_Automated_GCS_during_BBMOD_reset_via_HWRESETREQ_NA.Test Case Teardown

#[1][1.0] CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown
#    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
#    PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown
#    [Teardown]  PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown.Test_Specific_Teardown

#[1][1.0] CB006830_Automated_Graceful_Cell_Shutdown_during_RMOD_reset_via_HWRESETREQ
#    [Setup]  common.Common Test Setup
#    PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ
#    [Teardown]  PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ.Test Case Teardown

#[1][1.0] PS_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203
#    [Setup]  common.Common Test Setup
#    PS.22_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203
#    [Teardown]  PS.22_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203.Test Case Teardown

#[1][1.0] PS_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080
#    [Setup]  common.Common Test Setup
#    PS.24_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080
#    [Teardown]  PS.24_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080.Test Case Teardown

#[1][1.0] PS_CB008800_Suspend_LTE1103_and_LTE1203_SR003080
#    [Setup]  common.Common Test Setup
#    PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080
#    [Teardown]  PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080.Test Case Teardown

#[1][1.0] PS_CB008800_Power_saving_configuration_change
#    [Setup]  common.Common Test Setup
#    PS.25_CB008800_Power_saving_configuration_change
#    [Teardown]  PS.25_CB008800_Power_saving_configuration_change.Test Case Teardown

#[1][1.0] Automated__PS__CB008800_Overlapping_Cell_Periods
#    [Setup]  Run Keywords  common.Common Test Setup
#    PS.27_CB008800_Overlapping_Cell_Periods
#    [Teardown]  PS.27_CB008800_Overlapping_Cell_Periods.Test Case Teardown

#[1][1.0] PS_CB008800_Check_SR003080_interworking_with_CB008800
#    [Setup]  Run Keywords  common.Common Test Setup
#    PS.23_PS_CB008800_Check_SR003080_interworking_with_CB008800
#    [Teardown]  PS.23_PS_CB008800_Check_SR003080_interworking_with_CB008800.Test Case Teardown

#[1][1.0] Automated__PS__LBT4152-E_Graceful_cell_shutdown_during_parameter_change_with_eNB_reset
#    [Setup]  Run Keywords  common.Common Test Setup
#    PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset
#    [Teardown]  PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset.Test Case Teardown

#[1][1.0] Automated__PS__LTE1203_Reduced_Power_Saving_Activation
#    [Setup]  Run Keywords  common.Common Test Setup
#    PS.05_LTE1203_Reduced_Power_Saving_Activation_via_Admin
#    [Teardown]  PS.05_LTE1203_Reduced_Power_Saving_Activation_via_Admin.Test Case Teardown

#[1][1.0] Automated__PS__LTE1103-A_Power_Saving_Groups_Activation
#    [Setup]  Run Keywords  common.Common Test Setup
#    PS.04_LTE1103-A_Power_Saving_Groups_Activation_via_Admin
#    [Teardown]  PS.04_LTE1103-A_Power_Saving_Groups_Activation_via_Admin.Test Case Teardown

#[1][1.0] PS_SBTS_Intelligent_shut_down_with_WCDMA_RAT_reset
#    [Setup]  common.Common Test Setup
#    PS.11_5GC001553_Intelligent_shut_down_with_WCDMA_RAT_reset
#    [Teardown]  PS.11_5GC001553_Intelligent_shut_down_with_WCDMA_RAT_reset.Test Case Teardown

#[1][1.0] Automated__PS__BTS_Reboot_While_Grace_Cell_Down
#    [Setup]  Run Keywords  common.Common Test Setup
#    PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin
#    [Teardown]  PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin.Test Case Teardown

#[1][2.0] PS_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking
#    [Setup]  common.Common Test Setup
#    PS.36_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking
#    [Teardown]  PS.36_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking.Test Specific Teardown

#[1][1.0] PS_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving
#    [Setup]  common.Common Test Setup
#    PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving
#    [Teardown]  PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving.Test Case Teardown

#[1][1.0] PS_RAN955_Power saving mode for 3G
#    [Setup]  common.Common Test Setup
#    PS.32_RAN955_Power_saving_mode_for_3G
#    [Teardown]  PS.32_RAN955_Power_saving_mode_for_3G.Test Case Teardown