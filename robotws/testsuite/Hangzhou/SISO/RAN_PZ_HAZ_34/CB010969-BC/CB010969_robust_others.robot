*** Settings ***
Documentation
...   author: lixia tang
...   contact: lixia.tang@nokia-sbell.com
...   squad group: PZ3_SG3
...   Feature CB010969 robust test

Suite Setup    Run keywords    robot_common_operations.Common Suite Setup    AND    CI_interface.Common Suite Setup
Suite Teardown
Test Setup
Test Teardown
Test Timeout    1500 min

Resource    ./Resources/CB010969_Common_Keyword.robot


*** Test Cases ***
[1]CB010969_Manual_RU_Lock_Unlock
    [Setup]    Case Setup
    Run Keyword and Continue on Failure    RU Lock Unlock for 30 times
    [Teardown]    Case Teardown

[1]CB010969_Manual_Cell_Block_Unblock
    [Setup]    Case Setup
    Run Keyword and Continue on Failure    Block NR cells for 30 times
    [Teardown]    Case Teardown

[1]CB010969_Manual_RU_Reset
    [Setup]    Case Setup
     Run Keyword and Continue on Failure    RU Reset for 30 times
     [Teardown]    Case Teardown

[1]CB010969_Manual_gNB_Power_Reset
    [Setup]    Case Setup
    Run Keyword and Continue on Failure    Power Reset gNB 20 times
    [Teardown]    Case Teardown