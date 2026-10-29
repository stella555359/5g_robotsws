*** Settings ***
Documentation      author: Gao Ge
...                contact: ge.gao@nokia-sbell.com
...                feature: CB008430

Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup    AND    Setup Suite
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown    AND    Teardown Suite
Force Tags        SG_01   5G_RAN

Resource           ../CB008430/Resources/CB008430_Resource.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Test Cases ***
[1]CB008430_General_SiSo_RF_module_reset_from_GUI
    [Tags]     CRT_23R4
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND     TestCase Setup
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestCase Teardown
    TC.CB008430_General_SiSo_RF_module_reset_from_GUI

[1]CB008430_Manual_SiSo_SM_BTS_Site_Reset
    [Tags]     CRT_23R4
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND     TestCase Setup
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestCase Teardown
    TC.CB008430_Manual_SiSo_SM_BTS_Site_Reset

[1]CB008430_Baseband_module_reset_from_BTSSM_WebEM
    [Tags]     CRT_23R4
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND     TestCase Setup
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestCase Teardown
    TC.CB008430_Baseband_module_reset_from_BTSSM_WebEM

[1]CB008430_General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Tags]     CRT_23R4
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND     TestCase Setup
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestCase Teardown
    TC.CB008430_General_SiSo_E2E_system_setup_with_data_transfer_conducted

[1]CB008430_General_SiSo_Cell_block_and_unblock
    [Tags]     CRT_23R4
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND     TestCase Setup
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestCase Teardown
    TC.CB008430_General_SiSo_Cell_block_and_unblock

[1]CB008430_Manual_SiSo_SM_RF_Module_lock_unlock
    [Tags]     CRT_23R4
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND     TestCase Setup
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestCase Teardown
    TC.CB008430_Manual_SiSo_SM_RF_Module_lock_unlock

[1]CB008430_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]     CRT_23R4
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND     TestCase Setup
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestCase Teardown
    TC.CB008430_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
