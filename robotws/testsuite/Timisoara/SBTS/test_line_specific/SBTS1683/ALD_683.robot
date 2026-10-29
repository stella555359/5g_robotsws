*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_LWG_10683_1ASIA_1ABIA_1FSMF_2FBBC_1AHED_1AHEGB_1FRGU_1FXDB  STATE_COMMISSIONED
Library           XML  use_lxml=True
Resource        ../../ALD/Testcases/ALD.01_ALD_HW_Restart/test.robot
Resource        ../../ALD/Testcases/ALD.02_ALD_SW_Restart/test.robot
Resource        ../../ALD/Testcases/ALD.03_ALD_Additional_data_for_ALDs/test.robot
Resource        ../../ALD/Testcases/ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment/test.robot
Resource        ../../ALD/Testcases/ALD.08_ALD_DC_voltage_management_in_runtime/test.robot
Resource        ../../ALD/Testcases/ALD.10_ALD_HDLC_Communication_management_with_reset/test.robot
Resource        ../../ALD/Testcases/ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock/test.robot
Resource        ../../ALD/Testcases/ALD.14_ALD_Detect_and_setup_AL_devices_start-up/test.robot
Resource        ../../ALD/Testcases/ALD.16_ALD_Software_upgrade_for_ALDs/test.robot
Resource        ../../ALD/Testcases/ALD.17_ALD_Configure_Commissioned_RET_Antenna/test.robot
Resource        ../../ALD/Testcases/ALD.19_ALD_Planned_commissioning_with_Nokia_MHA/test.robot
Resource        ../../ALD/Testcases/ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM/test.robot
Resource        ../../ALD/Testcases/ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM/test.robot


Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general
				 Run keywords    Map BuildShareTimi01


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1683


*** Test Cases ***
[1][1.1] Automated__ALD__ALD HW Restart
    [Setup]  common.Common Test Setup
    ALD.01_ALD_HW_Restart
    [Teardown]  ALD.01_ALD_HW_Restart.Test Case Teardown  SEND_SNAPSHOT_FOR_SCRAMBLING=${True}

[1][1.1] Automated__ALD__ALD SW Restart
    [Setup]  common.Common Test Setup
    ALD.02_ALD_SW_Restart
    [Teardown]  ALD.02_ALD_SW_Restart.Test Case Teardown

[1][2.0] Automated_ALD__Additional data for ALDs
    [Setup]  common.Common Test Setup
    ALD.03_ALD_Additional_data_for_ALDs
    [Teardown]  ALD.03_ALD_Additional_data_for_ALDs.Test Case Teardown

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

#[1][1.1] Automated__ALD__RET_AISG2.0_No_Connection_To_Unit
#    [Setup]  common.Common Test Setup
#    ALD.20_ALD_RET_No_Connection_To_Unit
#    [Teardown]  ALD.20_ALD_RET_No_Connection_To_Unit.Test Case Teardown
#
#[1][1.1] Automated__ALD__MHA_AISG2.0_No_Connection_To_Unit
#    [Setup]  common.Common Test Setup
#    ALD.21_ALD_MHA_No_Connection_To_Unit
#    [Teardown]  ALD.21_ALD_MHA_No_Connection_To_Unit.Test Case Teardown

[1][1.0] Automated__ALD__Activate MHA auto configure feature after BTS commissioning
    [Setup]  common.Common Test Setup
    ALD.22_ALD_Activate_MHA_auto_configure_feature_after_BTS_commissioning
    [Teardown]  ALD.22_ALD_Activate_MHA_auto_configure_feature_after_BTS_commissioning.Test Case Teardown

#[1][1.0] Automated__ALD__MHA_Overcurrent_alarm_in_AISG_mode_with_RM_Lock_Unlock
#    [Setup]  Run Keywords  common.Common Test Setup
#    ...  AND  Set Test Variable  ${OC_INTERFACE}  OC_UY161469640
#    ...  AND  Set Test Variable  ${ANTL_A}  /RMOD_A-1/ANTL_A-3
#    ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG
#    [Teardown]  ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test Case Teardown

[1][1.0] Automated__ALD__RS485_Power_Failure_with_RM_Lock_Unlock
    [Setup]  Run Keywords  common.Common Test Setup
    ...  AND  Set Test Variable  ${RS485_FAILURE}  RET_RS485_FAILURE
    ...  AND  Set Test Variable  ${RMOD_A}  RMOD_A-4
    ALD.27_ALD_RS485_Power_Failure
    [Teardown]  ALD.27_ALD_RS485_Power_Failure.Test Case Teardown

[1][1.1] Automated__ALD__Configure_Commissioned_RET_Antenna
    [Setup]  common.Common Test Setup
    ALD.17_ALD_Configure_Commissioned_RET_Antenna
    [Teardown]  ALD.17_ALD_Configure_Commissioned_RET_Antenna.Test Case Teardown

[1][1.1] Automated__ALD__Planned commissioning with Nokia MHA
    [Setup]  common.Common Test Setup
    ALD.19_ALD_Planned_commissioning_with_Nokia_MHA
    [Teardown]  ALD.19_ALD_Planned_commissioning_with_Nokia_MHA.Test Case Teardown

[1][1.0] Automated__ALD__BTS_Remote_Tool_command_RET_Unit_Editable_Parameter_setting
    [Setup]  common.Common Test Setup
    CLI.02_Admin_CLI_setTiltAngle
    [Teardown]  CLI.02_Admin_CLI_setTiltAngle.Test Case Teardown

[1][1.0] Automated__ALD__BTS_Remote_Tool_command_RET_Unit_information_retrieving
    [Setup]  common.Common Test Setup
    CLI.04_Admin_CLI_getRETById
    [Teardown]  common.Common Test Teardown

[1][1.0] Automated__ALD__RAE_Reading_2D_beamforming_weight_factors
    [Setup]  common.Common Test Setup
    ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors
    [Teardown]  ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors.Test Case Teardown

[1][1.0] Automated__ALD__Read_RAE_sensor_telemetry_on_demand_with_radio_reset
    [Setup]  common.Common Test Setup
    ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand
    [Teardown]  ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand.Test Case Teardown

[1][1.0] Automated__ALD__Read_RAE_sensor_telemetry_periodically_Netact
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact
    [Teardown]  ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact.Test Case Teardown

[1][1.0] Automated__ALD__RAE_Reading_1D_beamforming_weight_factors
    [Setup]  common.Common Test Setup
    ALD.35_CB006856_ALD_RAE_Reading_1D_beamforming_weight_factors
    [Teardown]  ALD.35_CB006856_ALD_RAE_Reading_1D_beamforming_weight_factors.Test Case Teardown
	
*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  SEPARATOR=  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/ cifs _netdev,
    ...  noperm,username=userbuild,,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
    Run  sudo cp -r /home/ute/testline_configuration/10_18_UTESRANCLOUD1683 /home/ute/


