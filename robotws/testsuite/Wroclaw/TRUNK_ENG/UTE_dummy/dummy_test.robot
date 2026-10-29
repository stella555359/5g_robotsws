*** Settings ***
Documentation
...     This dummy test was created to show how to run test in UTE.

Resource     testsuite/Wroclaw/TRUNK_ENG/UTE_dummy/resources/dummy_robot_resource.robot
Library      testsuite.Wroclaw.TRUNK_ENG.UTE_dummy.resources.dummy_python_resource    WITH NAME    dummy_python_resource


*** Test Cases ***
demo test
    Hello World from Test Suite
    dummy_robot_resource.Hello_World_from_robot_resource
    dummy_python_resource.hello_world_from_python_resource
    log    Great Success !!!

*** Keywords ***
Hello World from Test Suite
    log    Hello World from Test Suite    console=${TRUE}
