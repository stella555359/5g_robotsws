*** Settings ***
Documentation    Dummy robot resource

*** Keywords ***
hello_world_from_robot_resource
    [Documentation]
    ...    This dummy RF resource was created to show how to run test in UTE.
    log    Hello World from dummy_robot_resource.robot    console=${TRUE}
