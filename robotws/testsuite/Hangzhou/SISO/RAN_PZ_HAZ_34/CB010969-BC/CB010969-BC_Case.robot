*** Settings ***
Documentation
...   author: lixia tang
...   contact: lixia.tang@nokia-sbell.com
...   squad group: PZ3_SG3
...   Feature CB010969 in 5G25R1 program

Suite Setup    Run keywords    robot_common_operations.Common Suite Setup    AND    CI_interface.Common Suite Setup
Suite Teardown
Test Setup
Test Teardown
Test Timeout    600 min

Resource    ./Resources/CB010969_Common_Keyword.robot


*** Test Cases ***
[1][1.0] OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    [Setup]    Case Setup
    Run Keyword and Continue on Failure    Site reset 1 times
    [Teardown]    Case Teardown
