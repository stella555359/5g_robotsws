*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   ./Resource/Common.robot

Suite Setup   Common Suite Setup
Suite Teardown   Common Suite Teardown


*** Variables ***
@{ALL_TEST_STATUSs}    passed


*** Test Cases ***
CB009791-C_001_L1Soc_NR_UL_DSP_successful_recovery
    [Documentation]    This case is to verify the L1Soc_NR_UL_DSP_successful_recovery
    [Setup]    robot_common_operations.Common Case Setup
    sleep  30s
    Log To Console   //TODO:
    # ${all_counters}   Get Power Meter Releated Counters
    # ${all_timestamp}   Get ALL Timestamp   all_counters=${all_counters}
    # Set Suite Variable   ${ALL_COUNTERS}
    # Set Suite Variable   ${ALL_TIMESTAMP}
    # Check Power Meter Releated Counters   ALL_COUNTERS=${ALL_COUNTERS}   ALL_TIMESTAMP=${ALL_TIMESTAMP}
    # Check Time Interval   time_interval=${900}   ALL_COUNTERS=${ALL_COUNTERS}   ALL_TIMESTAMP=${ALL_TIMESTAMP}
    [Teardown]    robot_common_operations.Common Case Teardown

CB009791-C_008_L1Soc_NR_DL_DSP_successful_recovery
    [Documentation]    This case is to verify the L1Soc_NR_UL_DSP_successful_recovery
    [Setup]    robot_common_operations.Common Case Setup
    sleep  30s
    Log To Console   //TODO:
    [Teardown]    robot_common_operations.Common Case Teardown

*** Keywords ***
Common Suite Setup
    robot_common_operations.Common Suite Setup
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    Log To Console    Suite Setup TBD...

Common Suite Teardown
    robot_common_operations.Common Suite Teardown
    Log To Console    TearDown TBD...
