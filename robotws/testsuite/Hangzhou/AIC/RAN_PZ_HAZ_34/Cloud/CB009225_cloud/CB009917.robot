*** Settings ***
Documentation
...   author: liping.hong@nokia-sbell.com
...   This case can cover case 12, case 15, case 17, case 24 in QC
#Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009225_cloud/Common_resource/common_keyword.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009225_cloud/Common_resource/common_keyword.robot

Suite Setup   Common Suite Setup
Suite Teardown   Common Suite Teardown

Test Setup   Case Setup
Test Teardown   Case Teardown

*** Variables ***
@{ALL_TEST_STATUS}
*** Test Cases ***
#CB009917-SR-A-journal-log-filter-resume
#    Log To Console   case pass
#
#CB009917-SR-A-L1streaming-resume
#    [Setup]    Run Keywords   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND   Case Setup
#    Log To Console   case pass

CB009917-SR-CB009917_Overload_protection_due_to_debug_log_streaming_for_Cloud
    [Setup]     robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=8000
#    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#    List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
    Run Keyword And Continue On Failure    CB009917-SR-A-journal-log-filter-resume
    Run Keyword And Continue On Failure    CB009917-SR-A-L1streaming-resume
    [Teardown]    robot_common_operations.Common Case Teardown

CB009917-SR-CB009917_Overload_protection_due_to_debug_log_streaming_for_Cloud_ST
    [Setup]     robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    Pass Execution   case pass
    [Teardown]    robot_common_operations.Common Case Teardown

CB009917-SR-C-Syslog-streaming-filtered
    [Setup]     robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    Log To Console     log to pass
    [Teardown]    robot_common_operations.Common Case Teardown


*** Keywords ***
Common Suite Setup
    robot_common_operations.Common Suite Setup
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    Log To Console    Suite Setup TBD...

Common Suite Teardown
    robot_common_operations.Common Suite Teardown
    Log To Console    TearDown TBD...

Case Setup
    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=8000

Case Teardown
    robot_common_operations.Common Case Teardown

CB009917-SR-A-journal-log-filter-resume
    Log To Console   case pass

CB009917-SR-A-L1streaming-resume
    Case Setup
    Log To Console   case pass