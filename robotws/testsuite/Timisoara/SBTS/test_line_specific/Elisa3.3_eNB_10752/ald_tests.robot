*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_L_10752_1FSMF_2FBBC_1FRMC_1FXED_1FRGU  STATE_COMMISSIONED
Library           XML  use_lxml=True
Resource    ../ALD_TSR2/Testcases/ALD.01_ALD_HW_Restart/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.02_ALD_SW_Restart/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.03_ALD_Additional_data_for_ALDs/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.08_ALD_DC_voltage_management_in_runtime/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.10_ALD_HDLC_Communication_management_with_reset/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.11_ALD_HDLC_Communication_management_in_runtime/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.13_ALD_Detect_and_setup_RF_module_reset_with_configured_ALDs/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.14_ALD_Detect_and_setup_AL_devices_start-up/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.16_ALD_Software_upgrade_for_ALDs/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.17_ALD_Configure_Commissioned_RET_Antenna/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.19_ALD_Planned_commissioning_with_Nokia_MHA/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.20_ALD_RET_No_Connection_To_Unit/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.21_ALD_MHA_No_Connection_To_Unit/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.24_ALD_MHA_Overcurrent_alarm_in_CWA/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.26_ALD_MHA_Below_Current/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.31_CB008219_IMF_Bypass_Mode/test.robot
Resource    ../ALD_TSR2/Testcases/ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode/test.robot



Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1752


*** Test Cases ***
[1][1.1] Automated__ALD__ALD HW Restart
    [Setup]  common.Common Test Setup
    ALD.01_ALD_HW_Restart
    [Teardown]  ALD.01_ALD_HW_Restart.Test Case Teardown

[1][1.1] Automated__ALD__ALD SW Restart
    [Setup]  common.Common Test Setup
    ALD.02_ALD_SW_Restart
    [Teardown]  ALD.02_ALD_SW_Restart.Test Case Teardown

[1][2.0] Automated_ALD__Additional data for ALDs
    [Setup]  common.Common Test Setup
    ALD.03_ALD_Additional_data_for_ALDs
    [Teardown]  ALD.03_ALD_Additional_data_for_ALDs.Test Case Teardown

[1][1.1] Automated__ALD__BTS Reconfiguration with ALDs removal
    [Setup]  common.Common Test Setup
    ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal
    [Teardown]  ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal.Test Case Teardown

[1][1.1] Automated__ALD__Manual commissioning with Nokia MHA_ALDs assigned as external units
    [Setup]  common.Common Test Setup
    ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units
    [Teardown]  ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units.Test Case Teardown

[1][1.1] Automated__ALD__Manual commissioning with Nokia MHA_Passdev as RX Gain
    [Setup]  common.Common Test Setup
    ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain
    [Teardown]  ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain.Test Case Teardown

[1][1.1] Automated__ALD__DC voltage management in runtime
    [Setup]  common.Common Test Setup
    ALD.08_ALD_DC_voltage_management_in_runtime
    [Teardown]  ALD.08_ALD_DC_voltage_management_in_runtime.Test Case Teardown

[1][1.1] Automated__ALD__HDLC Communication management with reset
    [Setup]  common.Common Test Setup
    ALD.10_ALD_HDLC_Communication_management_with_reset
    [Teardown]  ALD.10_ALD_HDLC_Communication_management_with_reset.Test Case Teardown

[1][1.1] Automated__ALD__HDLC Communication management in runtime
    [Setup]  common.Common Test Setup
    ALD.11_ALD_HDLC_Communication_management_in_runtime
    [Teardown]  ALD.11_ALD_HDLC_Communication_management_in_runtime.Test Case Teardown

[1][1.0] Automated__ALD__Detect and setup AL devices Lock Unlock
    [Setup]  common.Common Test Setup
    ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock
    [Teardown]  ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock.Test Case Teardown

[1][1.1] Automated__ALD__Detect and setup__RF module reset with configured ALDs
    [Setup]  common.Common Test Setup
    ALD.13_ALD_Detect_and_setup_RF_module_reset_with_configured_ALDs
    [Teardown]  ALD.13_ALD_Detect_and_setup_RF_module_reset_with_configured_ALDs.Test Case Teardown

[1][1.1] Automated__ALD__Detect and setup AL devices Start-up
    [Setup]  common.Common Test Setup
    ALD.14_ALD_Detect_and_setup_AL_devices_start-up
    [Teardown]  ALD.14_ALD_Detect_and_setup_AL_devices_start-up.Test Case Teardown

[1][1.0] Automated__ALD__Software upgrade for ALDs
    [Setup]  common.Common Test Setup
    ALD.16_ALD_Software_upgrade_for_ALDs
    [Teardown]  ALD.16_ALD_Software_upgrade_for_ALDs.Test Case Teardown

[1][1.1] Automated__ALD__Configure_Commissioned_RET_Antenna
    [Setup]  common.Common Test Setup
    ALD.17_ALD_Configure_Commissioned_RET_Antenna
    [Teardown]  ALD.17_ALD_Configure_Commissioned_RET_Antenna.Test Case Teardown

[1][1.1] Automated__ALD__Planned commissioning with Nokia MHA
    [Setup]  common.Common Test Setup
    ALD.19_ALD_Planned_commissioning_with_Nokia_MHA
    [Teardown]  ALD.19_ALD_Planned_commissioning_with_Nokia_MHA.Test Case Teardown

[1][1.1] Automated__ALD__RET_AISG2.0_No_Connection_To_Unit
    [Setup]  common.Common Test Setup
    ALD.20_ALD_RET_No_Connection_To_Unit
    [Teardown]  ALD.20_ALD_RET_No_Connection_To_Unit.Test Case Teardown

[1][1.1] Automated__ALD__MHA_AISG2.0_No_Connection_To_Unit
    [Setup]  common.Common Test Setup
    ALD.21_ALD_MHA_No_Connection_To_Unit
    [Teardown]  ALD.21_ALD_MHA_No_Connection_To_Unit.Test Case Teardown

[1][1.0] Automated__ALD__MHA_Overcurrent_alarm_in_AISG_mode_with_RM_Lock_Unlock
    [Setup]  Run Keywords  common.Common Test Setup
    ...  AND  Set Test Variable  ${OC_INTERFACE}  OC_MDGA
    ...  AND  Set Test Variable  ${ANTL_A}  /RMOD_A-4/ANTL_A-1
    ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG
    [Teardown]  ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test Case Teardown

[1][1.0] Automated__ALD__MHA_Overcurrent_alarm_in_CWA_mode_with_RM_Lock_Unlock
    [Setup]  Run Keywords  common.Common Test Setup
    ...  AND  Set Test Variable  ${OC_INTERFACE}  OC_MDGA
    ...  AND  Set Test Variable  ${ANTL_A}  /RMOD_A-4/ANTL_A-19
    ALD.24_ALD_MHA_Overcurrent_alarm_in_CWA
    [Teardown]  ALD.24_ALD_MHA_Overcurrent_alarm_in_CWA.Test Case Teardown

[1][3.0] Automated__ALD__MHA Below Current alarm with RM Lock Unlock
    [Setup]  Run Keywords  common.Common Test Setup
    ...  AND  Set Test Variable  ${BELOW_INTERFACE}  MHA_X4132663514
    ...  AND  Set Test Variable  ${ANTL_A}  /RMOD_A-4/ANTL_A-19
    ALD.26_ALD_MHA_Below_Current
    [Teardown]  ALD.26_ALD_MHA_Below_Current.Test Case Teardown

[1][1.0] ALD__ALD MHA and IMF mode change
    [Setup]  common.Common Test Setup
    ALD.31_CB008219_IMF_Bypass_Mode
    [Teardown]  ALD.31_CB008219_IMF_Bypass_Mode.Test Case Teardown

[1][1.0] ALD__ALD Changing operating mode of Multi-band MHA
    [Setup]  common.Common Test Setup
    ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode
    [Teardown]  ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode.Test Case Teardown
