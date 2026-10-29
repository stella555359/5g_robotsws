*** Settings ***
Documentation      author: Kong Xiangli
...                contact: Xiangli.Kong@nokia-sbell.com
...                feature: CB010823

Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup    AND    Setup Suite
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown    AND    Teardown Suite
Force Tags        SG_01   5G_RAN

Resource           ../CB010823-SG01/Resources/CB010823_Resource.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Test Cases ***
[1]CB010823-SR-A_1_Run RF and SW Diagnostic check online from WebEM
    [Tags]     CRT_23R4
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND     TestCase Setup
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestCase Teardown
    TC.CB010823_1_Run RF and SW Diagnostic check online from WebEM
