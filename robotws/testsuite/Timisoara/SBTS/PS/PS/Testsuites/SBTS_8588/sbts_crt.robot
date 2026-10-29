*** Settings ***
Documentation
...    Author: roscislaw.szuminski@nokia.com
...    Description: Suite prepared for Power Saving tests execution
...    Group in charge: I_MN_RAN_RD_VRF_TSR1_5 <I_MN_RAN_RD_VRF_TSR1_5@internal.nsn.com>
...    Sample execution:
...    robot -L TRACE -d /home/ute/logs/ --variable CONFIGURATION:Timisoara.10_18_UTESRANCLOUD1818 --variable ENB_BRANCH:SBTS00 --variablefile
...	   /home/ute/testline_configuration/10_18_UTESRANCLOUD1818/__init__.py
...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PS/PS/Testsuites/SBTS_8588/sbts_crt.robot


Resource        ../../Testcases/PS.04_LTE1103-A_Power_Saving_Groups_Activation_via_Admin/test.robot
Resource        ../../Testcases/PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock/test.robot
Resource        ../../Testcases/PS.22_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203/test.robot
Resource        ../../Testcases/PS.23_PS_CB008800_Check_SR003080_interworking_with_CB008800/test.robot
Resource        ../../Testcases/PS.24_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080/test.robot
Resource        ../../Testcases/PS.25_CB008800_Power_saving_configuration_change/test.robot
Resource        ../../Testcases/PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080/test.robot
Resource        ../../Testcases/PS.27_CB008800_Overlapping_Cell_Periods/test.robot
Resource        ../../Testcases/PS.28_CB008745_Switching_On_Cell_NR/test.robot
Resource        ../../Testcases/PS.29_CB008745_Switching_On_Cell_LTE/test.robot
Resource        ../../Testcases/PS.30_CB008745_Switching_On_Tx_Path_LTE/test.robot
Resource        ../../Testcases/PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI/test.robot
Resource        ../../Testcases/PS.35_CB006830_Automated_GCS_during_BBMOD_reset_via_HWRESETREQ_NA/test.robot
Resource        ../../Testcases/PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell/test.robot
Resource        ../../Testcases/PS.40_CB010683-B_Cell_Locking_and_blocking_durring_load_based_power_saving/test.robot
Resource        ../../Testcases/PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change/test.robot
Resource        ../../Testcases/PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off/test.robot
Resource        ../../Testcases/PS.43_CB010683-B_Mixed_switch_off_with_extended_configuration_activation_and_deactivation/test.robot
Resource        ../../Testcases/PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown/test.robot
Resource        ../../Testcases/PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ/test.robot
Resource        ../../Testcases/PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad/test.robot
Resource        ../../Testcases/PS.55_CB010397-D_Load_Based_Power_Saving_Mixed_switch_off_method/test.robot
Resource        ../../Testcases/PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change/test.robot
Resource        ../../Testcases/PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change/test.robot
Resource        ../../Testcases/PS.74_CNI130232_PS_Suspend_Load_Based_Reduced_Tx_Path/test.robot
Resource        ../../Testcases/PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES/test.robot
Resource        ../../Testcases/PS.82_5GC000431_Configuration_update_with_NR_cells_in_ES_or_switchingoff/test.robot


Force Tags
...           SBTS00  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           CA_RAN_VRF_TSR_5
...           PY39  ## force python3 UTE package
...           CLOUD_SRAN_NL_10818_1ASIM_1ABIP_1ASIM_2ABIP_3AHLOA_3AHFIB_3AEHC
...           SKIP_INSTALL_TOOLS
#...           SKIP_SCF_VALIDATION

Test Timeout  24 hours

#Suite Setup       Test Suite Setup
#Suite Teardown    Test Suite Teardown

*** Variables ***
${att_port_1}         ${tl.enbs[0].rms[0].attenuation_ports[0].port_no}
${att_port_2}         ${tl.enbs[0].rms[1].attenuation_ports[0].port_no}
${att_port_3}         ${tl.enbs[0].rms[2].attenuation_ports[0].port_no}
${att_port_4}         ${tl.enbs[1].rms[0].attenuation_ports[0].port_no}
${att_port_5}         ${tl.enbs[1].rms[1].attenuation_ports[0].port_no}
${att_port_6}         ${tl.enbs[1].rms[2].attenuation_ports[0].port_no}
${att_port_7}         ${tl.enbs[1].rms[3].attenuation_ports[0].port_no}
${att_port_8}         ${tl.enbs[1].rms[4].attenuation_ports[0].port_no}
${att_port_9}         ${tl.enbs[1].rms[5].attenuation_ports[0].port_no}
${att_port_numbers}   ${tl.attenuator[0].attenuation_port_numbers}
${ue_serial_num}      ${tl.ues[0].serial_number}
${diagnostic_port_command}    setprop sys.usb.config diag,adb

*** Test Cases ***
[1][1.0] Automated__PS__CB008745_Switching_On_Cell_LTE
    [Setup]  common.Common Test Setup
    PS.29_CB008745_Switching_On_Cell_LTE
    [Teardown]  PS.29_CB008745_Switching_On_Cell_LTE.Test Case Teardown

[1][1.0] Automated__PS__CB008745_Swiching_On_Tx_Path_LTE
    [Setup]  common.Common Test Setup
    PS.30_CB008745_Switching_On_Tx_Path_LTE
    [Teardown]  PS.30_CB008745_Switching_On_Tx_Path_LTE.Test Case Teardown

[1][1.0] PS_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203
    [Setup]  common.Common Test Setup
    PS.22_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203
    [Teardown]  PS.22_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203.Test Case Teardown

[1][2.0] PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change
    [Setup]  common.Common Test Setup
    PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change
    [Teardown]  PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change.Test Case Teardown

[1][2.0] PS_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off
    [Setup]  common.Common Test Setup
    PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off
    [Teardown]  PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off.Test Case Teardown

[1][1.0] CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown
    [Teardown]  PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown.Test_Specific_Teardown

[1][1.0] PS_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTSMaxLoad
    [Setup]  Run Keywords  common.Common Test Setup
    PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad
    [Teardown]  PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad.Test Case Teardown

[1][2.0] Automated__PS__CB010397-D_Load_Based_Power_Saving_Mixed_switch_off_method
    #[Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    [Setup]  Run Keywords  common.Common Test Setup
    PS.55_CB010397-D_LB_PS_Mixed_Switch_Off_Method
    [Teardown]  PS.55_CB010397-D_LB_PS_Mixed_Switch_Off_Method.Test Case Teardown

[1][1.0] PS_CB010397-F_Load_Based_Power_Saving_Mixed_switch_off_method_configuration_change
    [Setup]  Run Keywords  common.Common Test Setup
    PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change
    [Teardown]  PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test Case Teardown

[1][1.0] CNI130232_PS_Suspend_load_based_reduced_tx_path
	Set Test Variable	   ${SWITCH_OFF_DURATION}    150
	[Setup]  Run Keywords  common.Common Test Setup
	PS.74_CNI130232_PS_Suspend_Load_Based_Reduced_Tx_Path
	[Teardown]  PS.74_CNI130232_PS_Suspend_Load_Based_Reduced_Tx_Path.Test Case Teardown

[1][1.0] CNI130232_PS_Handle_power_saving_configuration_change
	Set Test Variable	   ${SWITCH_OFF_DURATION}    150
	[Setup]  Run Keywords  common.Common Test Setup
	PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change
	[Teardown]  PS.73_CNI130232_PS_Handle_Power_Saving_Configuration_Change.Test Case Teardown

[1][2.0] PS_LTE1103_LTE1203_S1_link_break_with_cells_in_energySaving_and_reducedES
	Set Test Variable	   ${SWITCH_OFF_DURATION}    150
	[Setup]  Run Keywords  common.Common Test Setup
	PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES
	[Teardown]  PS.77_LTE1103_LTE1203_S1_Link_Break_With_Cells_In_EnergySaving_And_ReducedES.Test Case Teardown

[1][1.0] PS_5GC000431_Configuration_update_with_NR_cells_in_ES_or_switchingoff
	Set Test Variable	   ${ITERATIONS}    30
	[Setup]  Run Keywords  common.Common Test Setup
	PS.82_5GC000431_Configuration_update_with_NR_cells_in_ES_or_switchingoff
	[Teardown]  PS.82_5GC000431_Configuration_update_with_NR_cells_in_ES_or_switchingoff.Test Case Teardown
