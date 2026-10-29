*** Settings ***
Documentation      author: Bin Wang
...                contact: bin.3.wang@nokia-sbell.com

Suite Setup       KW.TestSuilt.Start
Suite Teardown    KW.TestSuilt.Stop
Test Timeout         300 min


Resource           testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008278/Resources/TL1101_OAM_KPI_Resources.robot

*** Test Cases ***
CB009826_CB006533 BTS Power Reset
    [Documentation]
    [Tags]
    [Setup]    TestCase.Start 9826
    [Teardown]  Teardown case
    TC1.CB009826_CB006533_BTS_Power_Reset

CB009826_CB006533 Reset Site
    [Documentation]
    [Tags]
    [Setup]    TestCase.Start 9826
    [Teardown]  Teardown case
    TC2.CB009826_CB006533 Reset Site

CB009826_CB006533 Block and Unblock Site
    [Documentation]
    [Tags]
    [Setup]    TestCase.Start 9826
    [Teardown]  Teardown case
    TC3.CB009826_CB006533 Block/Unblock Site

CB009826_CB006533 Reset RAT
    [Documentation]
    [Tags]
    [Setup]    TestCase.Start 9826
    [Teardown]  Teardown case
    TC4.CB009826_CB006533 Reset RAT

CB009826_CB006533 Block and Unblock RAT
    [Documentation]
    [Tags]
    [Setup]    TestCase.Start 9826
    [Teardown]  Teardown case
    TC5.Block/Unblock RAT

CB009826_CB006533 Lock and unlock AMF
    [Documentation]
    [Tags]
    [Setup]    TestCase.Start 9826
    [Teardown]  Teardown case
    TC6.CB009826_CB006533 Lock/unlock AMF

CB009826_CB006533 Reset BBMOD
    [Documentation]
    [Tags]
    [Setup]    TestCase.Start 9826
    [Teardown]  Teardown case
    TC7.CB009826_CB006533 Reset BBMOD

CB009826_CB006533 Lock and unlock BBMOD
    [Documentation]
    [Tags]
    [Setup]    TestCase.Start 9826
    [Teardown]  Teardown case
    TC8.CB009826_CB006533 Lock/unlock BBMOD

CB009826_CB006533 Reset Cell
    [Documentation]
    [Tags]
    [Setup]    TestCase.Start 9826
    [Teardown]  Teardown case
    TC9.CB009826_CB006533 Reset Cell

CB009826_CB006533 Block and unblock Cell
    [Documentation]
    [Tags]
    [Setup]    TestCase.Start 9826
    [Teardown]  Teardown case
    TC10.CB009826_CB006533 Block/unblock Cell/Cell Group

CB009826_CB006533 Reset RU
    [Documentation]
    [Tags]
    [Setup]    TestCase.Start 9826
    [Teardown]  Teardown case
    TC11.CB009826_CB006533 Reset RU

CB009826_CB006533 Lock and unlock RU
    [Documentation]
    [Tags]
    [Setup]    TestCase.Start 9826
    [Teardown]  Teardown case
    TC12.CB009826_CB006533 Lock/unlock RU

CB009826_CB006533 RU power off and power on
    [Documentation]
    [Tags]
    [Setup]    TestCase.Start 9826
    [Teardown]  Teardown case
    TC13.CB009826_CB006533 RU power off and power on

CB009826_CB006533 Delta Plan for parameter requires object locking and bts restart
    [Documentation]     
    [Tags]
    [Setup]    TestCase.Start 9826
    [Teardown]  Teardown case
    TC14.CB009826_CB006533 Delta Plan for parameter requires object locking and bts restart
