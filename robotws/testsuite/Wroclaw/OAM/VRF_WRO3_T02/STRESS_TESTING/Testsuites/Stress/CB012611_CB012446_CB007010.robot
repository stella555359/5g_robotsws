*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for CB012611, CB012446 and CB007010 tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRAN2061 -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_16_UTESRAN2061
...    testsuite/Wroclaw/OAM/VRF_WRO3_T02/STRESS_TESTING/Testsuites/Stress/CB012611_CB012446_CB007010.robot

Resource        ../../Testcases/SM.28_CB007010-C_Lock-Unlock_Running_Datastore/test.robot
Resource        ../../Testcases/SM.29_CB007010-D_Site_reset_with_Netconf_server_enabled/test.robot
Resource        ../../Testcases/SM.30_CB007010-D_Enabled-Disabled_Netconf_server/test.robot
Resource        ../../Testcases/SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure/test.robot
Resource        ../../Testcases/SM.38_RAT_reset_during_simulate_a_fault_of_single_LOKI_in_ABIO_via_I2C/test.robot
Resource        ../../Testcases/SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing/test.robot
Resource        ../../Testcases/SM.43_Parallel_Site_Reset_of_Primary_and_Secondary_Core/test.robot
Resource        ../../Testcases/SM.44_Sequential_Site_Reset_of_Primary_and_Secondary_Core/test.robot

Force Tags
...           SBTS00  CRT  # Branch indicator; Test Phase indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY310  ## force python3 UTE package
...           RF50
...           CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIN_1ASIB_1ABIA_1ABIN_1ABIL_1AHEC_1AHDB_1FXEB_2FHFB_1AEQP_UTECA
...           SKIP_INSTALL_TOOLS
#...           SKIP_SCF_VALIDATION

*** Variables ***
${ITERATIONS}             1
${NETCONF_SERVER}         local

*** Test Cases ***
[1][1.0] RAT_Block_Unblock_with_ABIN_LOKI_power_failure
    [Setup]  common.Common Test Setup
    Set Test Variable  ${SLOT_IN_AMIA}  SLOT-6    #SLOT-<ID> (1-3, 5-7)
    Set Test Variable  ${BBMOD_DN}      BBMOD-4   #BBMOD-<ID> (1-6)
    SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure
    [Teardown]  SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure.Test Case Teardown

[1][1.0] RAT_Reset_with_ABIO_single_LOKI_via_I2C
    [Setup]  common.Common Test Setup
    Set Test Variable  ${SLOT_IN_AMIA}  SLOT-1    #SLOT-<ID> (1-3, 5-7)
    Set Test Variable  ${BBMOD_DN}      BBMOD-1   #BBMOD-<ID> (1-6)
    SM.38_RAT_reset_during_simulate_a_fault_of_single_LOKI_in_ABIO_via_I2C
    [Teardown]  SM.38_RAT_reset_during_simulate_a_fault_of_single_LOKI_in_ABIO_via_I2C.Test Case Teardown

[1][1.0] RAT_reset_with_ABIO_single_LOKI_ power_failure-cell_ sharing_between_LOKIs_configuration
    [Setup]  common.Common Test Setup
    Set Test Variable  ${SLOT_IN_AMIA}  SLOT-3    #SLOT-<ID> (1-3, 5-7)
    Set Test Variable  ${BBMOD_DN}      BBMOD-6   #BBMOD-<ID> (1-6)
    SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing
    [Teardown]  SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing.Test Case Teardown

[1][1.0] Automated_SM_Parallel_site_reset_of_the primary_and_secondary_core
    [Setup]  common.Common Test Setup
    SM.43_Parallel_Site_Reset_of_Primary_and_Secondary_Core
    [Teardown]  SM.43_Parallel_Site_Reset_of_Primary_and_Secondary_Core.Test Case Teardown

[1][1.0] Automated_SM_Sequential_site_reset_of_the_primary_and_secondary_core
    [Setup]  common.Common Test Setup
    SM.44_Sequential_Site_Reset_of_Primary_and_Secondary_Core
    [Teardown]  SM.44_Sequential_Site_Reset_of_Primary_and_Secondary_Core.Test Case Teardown

[1][1.0] CB007010-C_Lock-Unlock_Running_Datastore
    [Setup]  Run Keywords  Common Test Setup  AND  Setup TAF ONAP
    SM.28_CB007010-C_Lock-Unlock_Running_Datastore
    [Teardown]  Run Keywords  Teardown TAF ONAP  AND  Common Test Teardown

[1][1.0] CB007010-D_Site_reset_with_Netconf_server_enabled
    [Setup]  Run Keywords  Common Test Setup  AND  Setup TAF ONAP
    FOR  ${index}  IN RANGE  1  ${ITERATIONS}+1
        Log To Console  ${index} of ${ITERATIONS} - SM.29_CB007010-D_Site_reset_with_Netconf_server_enabled
        SM.29_CB007010-D_Site_reset_with_Netconf_server_enabled
    END
    [Teardown]  Run Keywords  Teardown TAF ONAP  AND  Common Test Teardown

[1][1.0] CB007010-D_Enabled-Disabled_Netconf_server
    [Setup]  Run Keywords  Common Test Setup  AND  Setup TAF ONAP
    FOR  ${index}  IN RANGE  1  ${ITERATIONS}+1
        Log To Console  ${index} of ${ITERATIONS} - SM.30_CB007010-D_Enabled-Disabled_Netconf_server
        SM.30_CB007010-D_Enabled-Disabled_Netconf_server
    END
    [Teardown]  Run Keywords  Teardown TAF ONAP  AND  Common Test Teardown
