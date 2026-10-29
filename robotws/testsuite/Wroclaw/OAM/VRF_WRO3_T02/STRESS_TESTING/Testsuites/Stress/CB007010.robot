*** Settings ***
Documentation
...    Author: mateusz.gumieniak@nokia.com
...    Description: Suite prepared for STRESS TESTING tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRAN2200 -C on -T -d ../test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_16_UTESRAN2200 testsuite/Wroclaw/OAM/VRF_WRO3_T02/STRESS_TESTING/Testsuites/Stress/CB007010.robot


Resource        ../../Testcases/SM.28_CB007010-C_Lock-Unlock_Running_Datastore/test.robot
Resource        ../../Testcases/SM.29_CB007010-D_Site_reset_with_Netconf_server_enabled/test.robot
Resource        ../../Testcases/SM.30_CB007010-D_Enabled-Disabled_Netconf_server/test.robot


Force Tags
...           SBTS00  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY39  ## force python3 UTE package
...           RF50

*** Variables ***
${ITERATIONS}             1
${NETCONF_SERVER}         local

*** Test Cases ***
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
