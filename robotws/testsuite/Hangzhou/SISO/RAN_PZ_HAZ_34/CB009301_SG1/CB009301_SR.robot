*** Settings ***
Documentation      author: Bin Wang
...                contact: bin.3.wang@nokia-sbell.com

Suite Setup       KW.TestSuilt.Start
Suite Teardown    KW.TestSuilt.Stop


Resource           testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009301_SG1/Resources/CB009301_SR_Resources.robot

*** Test Cases ***
CB009301_SR_A disable CB009301 and enable CB009301
    [Documentation]
    [Tags]
    [Setup]    TestCase.Start.9301
    [Teardown]  Teardown case
    TC1.CB009301_SR_A disable CB009301 and enable CB009301

[1][1.0] CB009301_SR_A_006_cell setup with measured delay
    [Documentation]
    [Tags]
    [Setup]    TestCase.Start.9301
    [Teardown]  Teardown case
    TC2.CB009301_SR_A Reset Site

CB009301_SR_A Reset RAT
    [Documentation]
    [Tags]
    [Setup]    TestCase.Start.9301
    [Teardown]  Teardown case
    TC3.CB009301_SR_A Reset RAT

CB009301_SR_A Reset RU
    [Documentation]
    [Tags]
    [Setup]    TestCase.Start.9301
    [Teardown]  Teardown case
    TC4.CB009301_SR_A Reset RU

