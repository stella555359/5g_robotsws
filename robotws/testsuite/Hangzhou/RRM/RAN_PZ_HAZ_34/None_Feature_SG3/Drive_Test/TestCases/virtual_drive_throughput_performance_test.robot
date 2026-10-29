*** Settings ***
Force Tags    PY36
Documentation
...   author: jia-rebecca.liu@nokia-sbell.com
...   contact: Liu Jia-Rebecca

Suite Setup        DT TL suite setup
Suite Teardown     DT TL suite teardown

Resource       ../Resources/Drive_Test_common_keywords.robot




*** Variables ***



*** Test Cases ***
[1]virtual_drive_throughput_performance_test
    [Documentation]
    [Tags]
    [Setup]
    log to console     \n*** start viavi preparation and attach ***\n
    sleep    5s
    [Teardown]


*** Keywords ***

