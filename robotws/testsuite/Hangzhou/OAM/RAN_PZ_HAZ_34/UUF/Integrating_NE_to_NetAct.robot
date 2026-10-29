*** Settings ***
Force Tags    PY36
Documentation     Install NE to NetAct

Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/netact_integration.robot


*** Test Cases ***
Integrate NE to NetAct
    [Setup]    Integrating NE to NetAct Case Setup
    UUF Integrating NE to NetAct
    [Teardown]    Integrating NE to NetAct Case Teardown
