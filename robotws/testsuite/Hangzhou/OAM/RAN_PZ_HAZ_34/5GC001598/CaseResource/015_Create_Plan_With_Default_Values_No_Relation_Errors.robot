*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Commissioning_Wizard_Create_Plan_With_Default_Values_No_Relation_Errors
    COAM WEBUI Validate Plan
    ${definition_errors}   COAM WEBUI Get Definition Errors
    Should Be Empty   ${definition_errors}

Case Setup: Create_Plan_With_Default_Values_No_Relation_Errors
    Common Setup

Case Teardown: Create_Plan_With_Default_Values_No_Relation_Errors
    Common Teardown
