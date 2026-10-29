*** Settings ***
Suite Setup       Suite setup
Suite Teardown    Teardown Suite
Force Tags    PY36
Documentation
...    Author:
...    Contact:
...    squad
...    Feature
Resource          ./Resource/multiAPResource.robot
*** Test Cases ***
TEST
    [Documentation]
    [Tags]    CIT_TRUNK  CRT_TRUNK  CRT_22R2
    TC.Main
*** Keywords ***
Suite setup
    KW.SuiteSetup

Teardown Suite
    KW.SuiteTeardown