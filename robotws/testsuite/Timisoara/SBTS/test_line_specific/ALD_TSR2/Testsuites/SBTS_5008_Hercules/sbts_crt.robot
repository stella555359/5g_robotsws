*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for ALD tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRAN2120 -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_16_UTESRAN2120 testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG01/ALD/Testsuites/SBTS_5008_Hercules/sbts_crt.robot


Resource        ../../Testcases/ALD.03_ALD_Additional_data_for_ALDs/test.robot
Resource        ../../Testcases/ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal/test.robot
Resource        ../../Testcases/ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain/test.robot
Resource        ../../Testcases/ALD.08_ALD_DC_voltage_management_in_runtime/test.robot
Resource        ../../Testcases/ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock/test.robot
Resource        ../../Testcases/ALD.14_ALD_Detect_and_setup_AL_devices_start-up/test.robot
Resource        ../../Testcases/ALD.17_ALD_Configure_Commissioned_RET_Antenna/test.robot
Resource        ../../Testcases/ALD.19_ALD_Planned_commissioning_with_Nokia_MHA/test.robot
Resource        ../../Testcases/ALD.17_ALD_Configure_Commissioned_RET_Antenna/test.robot

Force Tags
...           SBTS00  SBTS23R1  SBTS22R4  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_ST  QCD_MN_RAN  ## QC project; QC domain for reporting
...           CA_RAN_PZ_WRO_3
...           PY39  ## force python3 UTE package
#...           CLOUD_SRAN_NLWG_1ASIB_1ABIO_1ABIN_1ABIA_1FXED_1FXFC_1FRGU_1FRMC_2FRHC  # label

Suite Setup       Test Suite Setup
Suite Teardown    Test Suite Teardown

*** Test Cases ***
[1][1.1] Automated__ALD__BTS Reconfiguration with ALDs removal
    [Setup]  common.Common Test Setup
    ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal
    [Teardown]  ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal.Test Case Teardown

[1][1.1] Automated__ALD__Manual commissioning with Nokia MHA_Passdev as RX Gain
    [Setup]  common.Common Test Setup
    ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain
    [Teardown]  ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain.Test Case Teardown

[1][1.1] Automated__ALD__Planned commissioning with Nokia MHA
    [Setup]  common.Common Test Setup
    ALD.19_ALD_Planned_commissioning_with_Nokia_MHA
    [Teardown]  ALD.19_ALD_Planned_commissioning_with_Nokia_MHA.Test Case Teardown

[1][1.1] Automated__ALD__Configure_Commissioned_RET_Antenna
    [Setup]  common.Common Test Setup
    ALD.17_ALD_Configure_Commissioned_RET_Antenna
    [Teardown]  ALD.17_ALD_Configure_Commissioned_RET_Antenna.Test Case Teardown

[1][1.1] Automated__ALD__Detect and setup AL devices Start-up
    [Setup]  common.Common Test Setup
    ALD.14_ALD_Detect_and_setup_AL_devices_start-up
    [Teardown]  ALD.14_ALD_Detect_and_setup_AL_devices_start-up.Test Case Teardown

[1][1.0] Automated__ALD__Detect and setup AL devices Lock Unlock
    [Setup]  common.Common Test Setup
    ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock
    [Teardown]  ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock.Test Case Teardown

[1][1.1] Automated__ALD__DC voltage management in runtime
    [Setup]  common.Common Test Setup
    ALD.08_ALD_DC_voltage_management_in_runtime
    [Teardown]  ALD.08_ALD_DC_voltage_management_in_runtime.Test Case Teardown

[1][2.0] Automated_ALD__Additional data for ALDs
    [Setup]  common.Common Test Setup
    ALD.03_ALD_Additional_data_for_ALDs
    [Teardown]  ALD.03_ALD_Additional_data_for_ALDs.Test Case Teardown
