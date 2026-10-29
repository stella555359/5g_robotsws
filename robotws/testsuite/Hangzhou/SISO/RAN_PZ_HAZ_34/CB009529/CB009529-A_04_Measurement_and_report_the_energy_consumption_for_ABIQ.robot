*** Settings ***
Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup
...    AND    Suite Setup
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
...    AND    Suite Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ./Resources/CB009529_common_keywords.robot

Documentation
...    author: Yuanyuan Liu
...    contact: yuanyuan.liu@nokia-sbell.com
...    squad group: pz3_3
...    feature : CB009529

Force Tags             SBTS00
...    PY36

*** Variables ***
${M40028C0}      1500
${M40028C1}      59700
${M40028C2}      60400
${M40028C3}      62000
${ute_host}      ${tl.test_pc.default_ssh_connection_details.addr}
${ute_user}    ${tl.test_pc.default_ssh_connection_details.username}
${ute_password}    ${tl.test_pc.default_ssh_connection_details.password}

*** Test Cases ***
[1]CB009529-A_04_Measurement_and_report_the_energy_consumption_for_ABIQ
    [Tags]    CRT_TRUNK
    [Setup]    run keywords    robot_common_operations.Common Case Setup
	Power meter Feature activation
	PM counter update enabled
    Run Keyword And Ignore Error    Verify all cells should be onair    connection=GNB_OAM
    Get and Check real time measurements for BBMOD    interval=1min
	Check BTS Counter M40028C for BBMOD    interval=15min
#	CB009529_common_keywords.Collect snapshot log
#    Get snapshot and check energy consumption counter
#    Delete snapshot     ${local_file_path}   ${unzipped}
    [teardown]    run keywords    robot_common_operations.Common Case Teardown
