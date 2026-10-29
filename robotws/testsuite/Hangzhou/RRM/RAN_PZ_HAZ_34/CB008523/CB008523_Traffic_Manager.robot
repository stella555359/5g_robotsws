*** Settings ***
Documentation     author: wang jiangrong
...               contact: jiangrong.wang@nokia-sbell.com
...               squad group: RAN_PZ_HAZ3_SG02

Force Tags        STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_SA_ASOE_AQQJ_AHPJ    SBTS00    RAN_5G    RAN_5G_TDD

Resource    ./Resource/common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Suite Setup       Test Suite Setup
Suite Teardown    Test Suite Teardown

*** Variables ***
${SUITE_LOG_PATH}
${TS_CASE_LOG_PATH}    /home/ute/
${ALARM_INFO}

*** Test Cases ***
[1]CB008523-E_1_EMIL adaption into Traffic Manager
    [Setup]    robot_common_operations.Common Case Setup
    Start DCAP log
    sleep    100s
    UE preparation for L3 call
    ${status}    UE attach verify
    Set Suite Variable    ${status}  
    sleep    100s
    Stop DCAP log and convert to txt type
    Validate Emil log is adaption to traffic manager
    UE dettach
    [Teardown]    robot_common_operations.Common Case Teardown
    
[1]CB008523-A_1_CP-UE service startup and configuration with Traffic Manager support
    [Setup]    robot_common_operations.Common Case Setup
    run keyword if    ${status}==False    Fail    case failed.
    [Teardown]    robot_common_operations.Common Case Teardown
