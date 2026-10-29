*** Settings ***
Documentation
...   This cases is for CB009791-E
Resource          Common_resource/common_keyword.robot

Suite Setup   Common Suite Setup
Suite Teardown   Common Suite Teardown

Test Setup   Case Setup
Test Teardown   Case Teardown

*** Variables ***
@{ALL_TEST_STATUS}
*** Test Cases ***
CB009791-E_002_FM_FID4019_fault_signature_active_UP_L1_unreachable
    [Setup]    Run Keywords   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND   Case Setup
    Pass Execution   case pass
    [Teardown]   Case Teardown

CB009791-E_002_FM_FID4019_fault_signature_active_UP_L1_process_crashed
    [Setup]     robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    Pass Execution   case pass
    [Teardown]    robot_common_operations.Common Case Teardown

*** Keywords ***
Common Suite Setup
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    AlarmWatchdog.add_allow_alarms    fault_id=4681
    robot_common_operations.Common Suite Setup
    sleep  30s
    Log To Console    Suite Setup TBD...

Common Suite Teardown
    robot_common_operations.Common Suite Teardown
    Log To Console    TearDown TBD...

Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    AlarmWatchdog.add_allow_alarms    fault_id=4681
    sleep  30s
    Log To Console   case Setup TBD...
    robot_common_operations.Common Case Setup

Case Teardown
    sleep  30s
    Log To Console   case Teardown TBD...
    robot_common_operations.Common Case Teardown
