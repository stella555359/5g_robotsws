*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for Power Saving tests execution
...    Group in charge: I_MN_RAN_RD_VRF_TSR1_5 <I_MN_RAN_RD_VRF_TSR1_5@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Timisoara.10_18_UTESRANCLOUD1817 -C on -T -d /home/ute/test_results
...    -L TRACE -b debug.log -V testline_configuration/10_18_UTESRANCLOUD1817
...    testsuite/Timisoara/SBTS/PS/PS/Testsuites/SBTS_8070/sbts_crt.robot



Resource        ../../Testcases/PS.10_CB007416_Load_based_carrier_switch_off_on_for_PS_on_TDD/test.robot
Resource        ../../Testcases/PS.28_CB008745_Switching_On_Cell_NR/test.robot
Resource        ../../Testcases/PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI/test.robot
Resource        ../../Testcases/PS.37_CB008745_Suspend_Power_Saving_NR/test.robot
Resource        ../../Testcases/PS.38_CB008745_Backward_compatibility_NR/test.robot
Resource        ../../Testcases/PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell/test.robot
Resource        ../../Testcases/PS.40_CB010683-B_Cell_Locking_and_blocking_durring_load_based_power_saving/test.robot
Resource        ../../Testcases/PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change/test.robot
Resource        ../../Testcases/PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off/test.robot
Resource        ../../Testcases/PS.43_CB010683-B_Mixed_switch_off_with_extended_configuration_activation_and_deactivation/test.robot
Resource        ../../Testcases/PS.35_CB006830_Automated_GCS_during_BBMOD_reset_via_HWRESETREQ_NA/test.robot
Resource        ../../Testcases/PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown/test.robot
Resource        ../../Testcases/PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ/test.robot
Resource        ../../Testcases/PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080/test.robot
Resource        ../../Testcases/PS.27_CB008800_Overlapping_Cell_Periods/test.robot
Resource        ../../Testcases/PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset/test.robot
Resource        ../../Testcases/PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window/test.robot
Resource        ../../Testcases/PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset/test.robot
Resource        ../../Testcases/PS.29_CB008745_Switching_On_Cell_LTE/test.robot
Resource        ../../Testcases/PS.30_CB008745_Switching_On_Tx_Path_LTE/test.robot
Resource        ../../Testcases/PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin/test.robot
Resource        ../../Testcases/PS.68_CB008133_NRPGRP_With_mMIMO_And_Non_mMIMO_Cells/test.robot
Resource        ../../Testcases/PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad/test.robot


Force Tags
...           SBTS00  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY39  ## force python3 UTE package
...           CLOUD_SRAN_NLG_10817_2ASIB_3ABIA_1ABIL_1ABIN_1ABIO_2AHCA_1FXDB_1FRMF_1AHED_1AHDB_1AZNA_1AVQL_1AHEC
...           SKIP_INSTALL_TOOLS

Test Timeout  24 hours

#Suite Setup       Test Suite Setup
#Suite Teardown    Test Suite Teardown

*** Variables ***
${att_port_1}         ${tl.enbs[0].rms[0].attenuation_ports[0].port_no}
${att_port_2}         ${tl.enbs[1].rms[3].attenuation_ports[0].port_no}
${att_port_3}         ${tl.enbs[1].rms[4].attenuation_ports[0].port_no}
${att_port_4}         ${tl.enbs[1].rms[4].attenuation_ports[1].port_no}
${att_port_5}         ${tl.enbs[1].rms[5].attenuation_ports[0].port_no}
${att_port_6}         ${tl.enbs[1].rms[5].attenuation_ports[1].port_no}
${att_port_7}         ${tl.enbs[0].rms[1].attenuation_ports[0].port_no}
${att_port_8}         ${tl.enbs[0].rms[1].attenuation_ports[1].port_no}
${att_port_9}         ${tl.enbs[0].rms[1].attenuation_ports[2].port_no}
${att_port_10}        ${tl.enbs[0].rms[1].attenuation_ports[3].port_no}
${att_port_11}        ${tl.enbs[0].rms[1].attenuation_ports[4].port_no}
${att_port_12}        ${tl.enbs[0].rms[1].attenuation_ports[5].port_no}
${att_port_13}        ${tl.enbs[0].rms[2].attenuation_ports[0].port_no}
${att_port_14}        ${tl.enbs[0].rms[2].attenuation_ports[1].port_no}
${att_port_15}        ${tl.enbs[0].rms[2].attenuation_ports[2].port_no}
${att_port_16}        ${tl.enbs[0].rms[2].attenuation_ports[3].port_no}
${att_port_17}        ${tl.enbs[0].rms[3].attenuation_ports[0].port_no}
${att_port_18}        ${tl.enbs[0].rms[3].attenuation_ports[1].port_no}
${att_port_19}        ${tl.enbs[1].rms[2].attenuation_ports[0].port_no}
${att_port_20}        ${tl.enbs[1].rms[2].attenuation_ports[1].port_no}
${att_port_21}        ${tl.enbs[1].rms[1].attenuation_ports[0].port_no}
${att_port_22}        ${tl.enbs[1].rms[1].attenuation_ports[1].port_no}
${att_port_23}        ${tl.enbs[1].rms[1].attenuation_ports[2].port_no}
${att_port_24}        ${tl.enbs[1].rms[1].attenuation_ports[3].port_no}
${att_port_numbers}   ${tl.attenuator[0].attenuation_port_numbers}

*** Test Cases ***
#[1][2.0] PS_CB007416_ Load based carrier switch off_on for PS on TDD
#    [Setup]  common.Common Test Setup
#    PS.10_CB007416_Load_based_carrier_switch_off_on_for_PS_on_TDD
#    [Teardown]  PS.10_CB007416_Load_based_carrier_switch_off_on_for_PS_on_TDD.Test Case Teardown

#[1][2.0] PS_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell
#    [Setup]  common.Common Test Setup
#    PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell
#    [Teardown]  PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell.Test Case Teardown

#[1][2.0] PS_CB010683-B_Cell_Locking_and_blocking_durring_load_based_power_saving
#    [Setup]  common.Common Test Setup
#    PS.40_CB010683-B_Cell_Locking_and_blocking_durring_load_based_power_saving
#    [Teardown]  PS.40_CB010683-B_Cell_Locking_and_blocking_durring_load_based_power_saving.Test Case Teardown

#[1][2.0] PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change
#    [Setup]  common.Common Test Setup
#    PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change
#    [Teardown]  PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change.Test Case Teardown

#[1][2.0] PS_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off
#    [Setup]  common.Common Test Setup
#    PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off
#    [Teardown]  PS.42_CB010683-B_Cell_Outage_due_to_other_cell_degraded_during_mixed_switch_off.Test Case Teardown

#[1][1.0] CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI
#    [Setup]  common.Common Test Setup
#    PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI
#    [Teardown]  PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI.Test Case Teardown

#[1][1.0] Automated__PS__CB008745_ Backward_compatibility_NR
#    [Setup]  common.Common Test Setup
#    PS.38_CB008745_Backward_compatibility_NR
#    [Teardown]  PS.38_CB008745_Backward_compatibility_NR.Test Case Teardown

#[1][1.0] Automated__PS__CB008745_Suspend_Power_Saving_NR
#    [Setup]  common.Common Test Setup
#    PS.37_CB008745_Suspend_Power_Saving_NR
#    [Teardown]  PS.37_CB008745_Suspend_Power_Saving_NR.Test Case Teardown

#[1][1.0] CB006830_Automated_Graceful_Cell_Shutdown_during_BBMOD_reset_via_HWRESETREQ_NA
#    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
#    PS.35_CB006830_Automated_GCS_during_BBMOD_reset_via_HWRESETREQ_NA
#    [Teardown]  PS.35_CB006830_Automated_GCS_during_BBMOD_reset_via_HWRESETREQ_NA.Test Case Teardown

#[1][1.0] CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown
#    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
#    PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown
#    [Teardown]  PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown.Test_Specific_Teardown

#[1][1.0] CB010768_interaction_with_CB008800_Suspend_LTE1103_and_LTE1203_SR003080
#    [Setup]  common.Common Test Setup
#    PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080
#    [Teardown]  PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080.Test Case Teardown

#[1][1.0] CB010768_interaction_with_CB008800_Overlapping_Cell_Periods
#    [Setup]  Run Keywords  common.Common Test Setup
#    PS.27_CB008800_Overlapping_Cell_Periods
#    [Teardown]  PS.27_CB008800_Overlapping_Cell_Periods.Test Case Teardown

#[1][1.0] Automated__PS__CB008745_Switching_On_Cell_LTE
#    [Setup]  common.Common Test Setup
#    PS.29_CB008745_Switching_On_Cell_LTE
#    [Teardown]  PS.29_CB008745_Switching_On_Cell_LTE.Test Case Teardown

#[1][1.0] Automated__PS__CB008745_Swiching_On_Tx_Path_LTE
#    [Setup]  common.Common Test Setup
#    PS.30_CB008745_Switching_On_Tx_Path_LTE
#    [Teardown]  PS.30_CB008745_Switching_On_Tx_Path_LTE.Test Case Teardown

#### Regression Tests - below this line ####################################################################################################

[1][1.0] Automated__PS__CB008745_Switching_On_Cell_NR
    [Setup]  common.Common Test Setup
    PS.28_CB008745_Switching_On_Cell_NR
    [Teardown]  PS.28_CB008745_Switching_On_Cell_NR.Test Case Teardown

[1][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
    [Teardown]  PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test Case Teardown

[1][1.0] Automated__PS__CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
    [Teardown]  PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test Case Teardown

[1][1.0] Automated__PS__CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Setup]    Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
    [Teardown]    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test Case Teardown

[1][4.0] PS_CB010683-B_Mixed_switch_off_with_extended_configuration_activation_and_deactivation
    [Setup]  common.Common Test Setup
    PS.43_CB010683-B_Mixed_switch_off_with_extended_configuration_activation_and_deactivation
    [Teardown]  PS.43_CB010683-B_Mixed_switch_off_with_extended_configuration_activation_and_deactivation.Test Case Teardown

[1][1.0] Automated__PS__SR003080_Reduced_Power_Saving_Online_Activation
    [Setup]  common.Common Test Setup
    PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin
    [Teardown]  PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin.Test Case Teardown

[1][6.0] PS_CB008133_NRPGRP_with_mMIMO_amd_non_mMIMO_cells
    [Setup]  common.Common Test Setup
    PS.68_CB008133_NRPGRP_With_mMIMO_And_Non_mMIMO_Cells
    [Teardown]  PS.68_CB008133_NRPGRP_With_mMIMO_And_Non_mMIMO_Cells.Test Case Teardown

[1][1.0] CB006830_Automated_Graceful_Cell_Shutdown_during_RMOD_reset_via_HWRESETREQ
    [Setup]  common.Common Test Setup
    PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ
    [Teardown]  PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ.Test Case Teardown

[1][1.0] PS_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTSMaxLoad
    [Setup]  Run Keywords  common.Common Test Setup
    PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad
    [Teardown]  PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad.Test Case Teardown

