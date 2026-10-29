*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Commissioning_Wizard_Create_Plan_With_Minimal_Relation_Errors
    Step1: Check No Relation Errors
    Step2: Modify Parameters
    Step3: Check Relation Errors

Case Setup: Create_Plan_With_Minimal_Relation_Errors
    Common Setup

Case Teardown: Create_Plan_With_Minimal_Relation_Errors
    Run Keyword And Ignore Error   COAM WEBUI Undo Changes
    Run Keyword And Ignore Error   COAM WEBUI Validate Plan
    Common Teardown

Step1: Check No Relation Errors
    COAM WEBUI Validate Plan
    ${relation_errors}   COAM WEBUI Get Relation Errors
    Should Be Empty   ${relation_errors}

Step2: Modify Parameters
    COAM WEBUI Set Parameter Value
    ...   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    ...   filter_param=Activate general connectivity bronze use case level
    ...   abbr=actGeneralConnectivityBronze
    ...   new_value=false

Step3: Check Relation Errors
    COAM WEBUI Validate Plan
    ${relation_errors}   COAM WEBUI Get Relation Errors
    Should Not Be Empty   ${relation_errors}
