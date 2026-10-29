*** Settings ***
Documentation      author: Bin Wang
...                 contact: bin.3.wang@nokia-sbell.com
...                This robot file is for EE feature

Suite Setup          SuiteSetup
Suite Teardown       SuiteTearDown

Force Tags           SG_01   5G_RAN
Resource           Resource/EnergySaving_testing_Resource.robot
Resource           ../5GC002479/Resources/5GC002479_CP_Resource.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Test Cases ***
TC01 EE features IWK with Site reset
    [Documentation]
    [Tags]
    [Setup]    ESM.TestCase.Start
    [Teardown]  ESM.TestCase.Stop
    TC01 EE features IWK with Site reset
TC02 Repeatedly entering ESM and DSM by time and exit ESM and DSM by CM update with actCellSwitchOnForCmUpdate
    [Documentation]
    [Tags]
    [Setup]    ESM.TestCase.Start
    [Teardown]  ESM.TestCase.Stop
    TC02 Repeatedly entering ESM and DSM by time and exit ESM and DSM by CM update with actCellSwitchOnForCmUpdate

TC03 Repeatedly entering ESM and DSM by time and exit ESM and DSM by CM update without actCellSwitchOnForCmUpdate
    [Documentation]
    [Tags]
    [Setup]    ESM.TestCase.Start
    [Teardown]  ESM.TestCase.Stop
    TC03 Repeatedly entering ESM and DSM by time and exit ESM and DSM by CM update without actCellSwitchOnForCmUpdate

TC04 Power reset RU in DSM
    [Documentation]
    [Tags]
    [Setup]    ESM.TestCase.Start
    [Teardown]  ESM.TestCase.Stop
    TC04 Power reset RU in DSM

