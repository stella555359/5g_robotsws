*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for Power Saving tests execution
...    Group in charge: I_MN_RAN_RD_VRF_TSR1_5 <I_MN_RAN_RD_VRF_TSR1_5@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRAN2125 -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_16_UTESRAN2125
...    testsuite/Wroclaw/OAM/regression/MN_RAN_PZ_3_WRO_SG01/PS/Testsuites/SBTS_8038/sbts_crt.robot


Resource        ../../Testcases/PS.01_Grace_Cell_Down_via_NA/test.robot
Resource        ../../Testcases/PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade/test.robot
Resource        ../../Testcases/PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset/test.robot
Resource        ../../Testcases/PS.04_LTE1103-A_Power_Saving_Groups_Activation_via_Admin/test.robot
Resource        ../../Testcases/PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario/test.robot
Resource        ../../Testcases/PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock/test.robot
Resource        ../../Testcases/PS.09_5GC001553_Intelligent_shut_down_recommissioning_during_power_break/test.robot
Resource        ../../Testcases/PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI/test.robot
Resource        ../../Testcases/PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown/test.robot
Resource        ../../Testcases/PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ/test.robot


Force Tags
...           SBTS00  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY39  ## force python3 UTE package
...           CLOUD_SRAN_NL_10815_1ASOE_2AHCA_1AHFIB_1AZQS_UTECA
...           SKIP_INSTALL_TOOLS
#...           SKIP_SCF_VALIDATION

Test Timeout  24 hours

#Suite Setup       Test Suite Setup
#Suite Teardown    Test Suite Teardown

*** Variables ***
#AZQP
${att_port_1}     ${tl.enbs[0].rms[0].attenuation_ports[0].port_no}
${att_port_2}     ${tl.enbs[0].rms[0].attenuation_ports[1].port_no}
${att_port_3}     ${tl.enbs[0].rms[0].attenuation_ports[2].port_no}
${att_port_4}     ${tl.enbs[0].rms[0].attenuation_ports[3].port_no}
${att_port_5}     ${tl.enbs[0].rms[0].attenuation_ports[4].port_no}
${att_port_6}     ${tl.enbs[0].rms[0].attenuation_ports[5].port_no}
${att_port_7}     ${tl.enbs[0].rms[0].attenuation_ports[6].port_no}
${att_port_8}     ${tl.enbs[0].rms[0].attenuation_ports[7].port_no}
#AHFIB
${att_port_9}     ${tl.enbs[0].rms[3].attenuation_ports[0].port_no}
${att_port_10}    ${tl.enbs[0].rms[3].attenuation_ports[1].port_no}
${att_port_11}    ${tl.enbs[0].rms[3].attenuation_ports[2].port_no}
${att_port_12}    ${tl.enbs[0].rms[3].attenuation_ports[3].port_no}
#AHLOA_R_2
${att_port_13}    ${tl.enbs[0].rms[1].attenuation_ports[0].port_no}
${att_port_14}    ${tl.enbs[0].rms[1].attenuation_ports[1].port_no}
${att_port_15}    ${tl.enbs[0].rms[1].attenuation_ports[2].port_no}
${att_port_16}    ${tl.enbs[0].rms[1].attenuation_ports[3].port_no}
#AHLOA_R_3
${att_port_17}    ${tl.enbs[0].rms[2].attenuation_ports[0].port_no}
${att_port_18}    ${tl.enbs[0].rms[2].attenuation_ports[1].port_no}
${att_port_19}    ${tl.enbs[0].rms[2].attenuation_ports[2].port_no}
${att_port_20}    ${tl.enbs[0].rms[2].attenuation_ports[3].port_no}
${att_port_numbers}   ${tl.attenuator[0].attenuation_port_numbers}
#UE
${ue_serial_num}      ${tl.ues[0].serial_number}
${diagnostic_port_command}    setprop sys.usb.config diag,adb

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

#[1][1.0] Automated__PS__LTE1103-A_Power_Saving_Groups_Activation
#    [Setup]  common.Common Test Setup
#    PS.04_LTE1103-A_Power_Saving_Groups_Activation_via_Admin
#    [Teardown]  PS.04_LTE1103-A_Power_Saving_Groups_Activation_via_Admin.Test Case Teardown

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

#[1][1.0] CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI
#    [Setup]  common.Common Test Setup
#    PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI
#    [Teardown]  PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI.Test Case Teardown

[1][1.0] CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown
    [Teardown]  PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown.Test_Specific_Teardown

#[1][1.0] CB006830_Automated_Graceful_Cell_Shutdown_during_RMOD_reset_via_HWRESETREQ
#    [Setup]  common.Common Test Setup
#    PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ
#    [Teardown]  PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ.Test Case Teardown
