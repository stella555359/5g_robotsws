*** Settings ***
Documentation    Set for CB006915_CB008305_CB008360_CB009055 test case
Resource    CB006915_CB008305_CB008360_CB009055_resources/CB006915_CB008305_CB008360_CB009055_resources.robot

Suite Setup  Connect To Admin

Suite Teardown  Close Admin Connection

*** Test Cases ***
CB006915_CB008305_CB008360_CB009055
    [Tags]    CB006915_CB008305_CB008360_CB009055
    CB006915_CB008305_CB008360_CB009055 Test Case Scenario
