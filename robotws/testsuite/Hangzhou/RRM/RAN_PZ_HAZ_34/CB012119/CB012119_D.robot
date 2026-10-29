*** Settings ***
Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
Test Setup        Run Keywords    robot_common_operations.Common Case Setup
Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown

Resource    ./Resources/CB012119_common_keywords.robot
Variables   ./Resources/CB012119_scf_modify.py

Documentation
...    author: yuanyuan liu
...    contact: yuanyuan.liu@nokia-sbell.com
...    squad group: MMW3
...    feature : CB012119

Force Tags    CRT_TRUNK

*** Variables ***
${scf_name}    CB008158_FULL_SCF.xml
${5QI_value}    7
${ue_index}     1

*** Test Cases ***
[1]CB012119-D_02_DL_Average_IP_latency_PMQAP_FR1_TDD_SA
    [Tags]    HAZ3_T03
    CB012119 SA case Preparation
	run keyword and continue on failure    5QI-1 and 5QI-2 and 5QI-5 traffic condition
	run keyword and continue on failure    5QI-8 small traffic condition    ue_index=1
    [Teardown]    Testcase specific teardown






