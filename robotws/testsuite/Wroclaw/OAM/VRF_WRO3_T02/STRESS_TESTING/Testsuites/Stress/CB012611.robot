*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for STRESS TESTING tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRAN2061 -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_16_UTESRAN2061
...    testsuite/Wroclaw/OAM/VRF_WRO3_T02/STRESS_TESTING/Testsuites/Stress/CB012611.robot


Resource        ../../Testcases/SM.33_RAT_Block_Unblock_with_ABIO_all_LOKI_power_failure/test.robot
Resource        ../../Testcases/SM.34_RAT_Block_Unblock_with_ABIO_single_LOKI_power_failure/test.robot
Resource        ../../Testcases/SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure/test.robot
Resource        ../../Testcases/SM.36_RAT_Reset_with_ABIO_all_LOKI_power_failure/test.robot
Resource        ../../Testcases/SM.37_RAT_Reset_with_ABIN_LOKI_power_failure/test.robot
Resource        ../../Testcases/SM.38_RAT_reset_during_simulate_a_fault_of_single_LOKI_in_ABIO_via_I2C/test.robot
Resource        ../../Testcases/SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing/test.robot
Resource        ../../Testcases/SM.40_RAT_Block_Unblock_with_ABIO_single_LOKI_power_failure-cell_sharing/test.robot

Force Tags
...           SBTS00  CRT  # Branch indicator; Test Phase indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY39  ## force python3 UTE package
...           RF50
#...           CLOUD_SRAN_*_UTECA
...           SKIP_INSTALL_TOOLS
#...           SKIP_SCF_VALIDATION

*** Test Cases ***
[1][1.0] RAT_Block_Unblock_with_ABIO_all_LOKI_power_failure
    [Setup]  common.Common Test Setup
    Set Test Variable  ${SLOT_IN_AMIA}  SLOT-1    #SLOT-<ID> (1-3, 5-7)
    Set Test Variable  ${BBMOD_DN}      BBMOD-1   #BBMOD-<ID> (1-6)
    SM.33_RAT_Block_Unblock_with_ABIO_all_LOKI_power_failure
    [Teardown]  SM.33_RAT_Block_Unblock_with_ABIO_all_LOKI_power_failure.Test Case Teardown

[1][1.0] RAT_Block_Unblock_with_ABIO_single_LOKI_power_failure
    [Setup]  common.Common Test Setup
    Set Test Variable  ${SLOT_IN_AMIA}  SLOT-3    #SLOT-<ID> (1-3, 5-7)
    Set Test Variable  ${BBMOD_DN}      BBMOD-6   #BBMOD-<ID> (1-6)
    SM.34_RAT_Block_Unblock_with_ABIO_single_LOKI_power_failure
    [Teardown]  SM.34_RAT_Block_Unblock_with_ABIO_single_LOKI_power_failure.Test Case Teardown

[1][1.0] RAT_Block_Unblock_with_ABIN_LOKI_power_failure
    [Setup]  common.Common Test Setup
    Set Test Variable  ${SLOT_IN_AMIA}  SLOT-2    #SLOT-<ID> (1-3, 5-7)
    Set Test Variable  ${BBMOD_DN}      BBMOD-2   #BBMOD-<ID> (1-6)
    SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure
    [Teardown]  SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure.Test Case Teardown

[1][1.0] RAT_Reset_with_ABIO_all_LOKI_power_failure
    [Setup]  common.Common Test Setup
    Set Test Variable  ${SLOT_IN_AMIA}  SLOT-1    #SLOT-<ID> (1-3, 5-7)
    Set Test Variable  ${BBMOD_DN}      BBMOD-1   #BBMOD-<ID> (1-6)
    SM.36_RAT_Reset_with_ABIO_all_LOKI_power_failure
    [Teardown]  SM.36_RAT_Reset_with_ABIO_all_LOKI_power_failure.Test Case Teardown

[1][1.0] RAT_Reset_with_ABIN_LOKI_power_failure
    [Setup]  common.Common Test Setup
    Set Test Variable  ${SLOT_IN_AMIA}  SLOT-2    #SLOT-<ID> (1-3, 5-7)
    Set Test Variable  ${BBMOD_DN}      BBMOD-2   #BBMOD-<ID> (1-6)
    SM.37_RAT_Reset_with_ABIN_LOKI_power_failure
    [Teardown]  SM.37_RAT_Reset_with_ABIN_LOKI_power_failure.Test Case Teardown

[1][1.0] RAT_reset_during_simulate_a_fault_of_single_LOKI_in_ABIO_via_I2C
    [Setup]  common.Common Test Setup
    Set Test Variable  ${SLOT_IN_AMIA}  SLOT-1    #SLOT-<ID> (1-3, 5-7)
    Set Test Variable  ${BBMOD_DN}      BBMOD-1   #BBMOD-<ID> (1-6)
    SM.38_RAT_reset_during_simulate_a_fault_of_single_LOKI_in_ABIO_via_I2C
    [Teardown]  SM.38_RAT_reset_during_simulate_a_fault_of_single_LOKI_in_ABIO_via_I2C.Test Case Teardown

[1][1.0] RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing
    [Setup]  common.Common Test Setup
    Set Test Variable  ${SLOT_IN_AMIA}  SLOT-1    #SLOT-<ID> (1-3, 5-7)
    Set Test Variable  ${BBMOD_DN}      BBMOD-1   #BBMOD-<ID> (1-6)
    SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing
    [Teardown]  SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing.Test Case Teardown

[1][1.0] RAT_Block_Unblock_with_ABIO_single_LOKI_power_failure-cell_sharing
    [Setup]  common.Common Test Setup
    Set Test Variable  ${SLOT_IN_AMIA}  SLOT-1    #SLOT-<ID> (1-3, 5-7)
    Set Test Variable  ${BBMOD_DN}      BBMOD-1   #BBMOD-<ID> (1-6)
    SM.40_RAT_Block_Unblock_with_ABIO_single_LOKI_power_failure-cell_sharing
    [Teardown]  SM.40_RAT_Block_Unblock_with_ABIO_single_LOKI_power_failure-cell_sharing.Test Case Teardown
