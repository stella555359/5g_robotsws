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
[1]CB010969_Manual_SiSo_SM_BTS_Site_Reset
    [Setup]    Case Setup
    Run Keyword and Continue on Failure    Site reset 30 times
    [Teardown]    Case Teardown

[1]CB010969_SCF_Commission_in_Loops
    [Setup]
    [Timeout]    500min
    Run Keyword and Continue on Failure    SCF Commission 30 times
    [Teardown]    Case Teardown

[1]CB013125_Site_Reset_without_HWF_in_Loops
    [Setup]
    [Timeout]    500min
    Run Keyword and Continue on Failure    Reset Site without HWF 40 Times
    [Teardown]    Case Teardown

[1]CB010969_Manual_SiSo_SM_BTS_NR_Reset
    [Setup]    Case Setup
    Run Keyword and Continue on Failure    NR reset 30 times
    [Teardown]    Case Teardown
