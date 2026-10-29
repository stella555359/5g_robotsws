*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Commissioning_Wizard_Create_Plan_In_CW_And_Switch_PE_Edit
    Step1: Create Plan: Create_Plan_In_CW_And_Switch_PE_Edit
    Step2: Change Parameter Value IN CW: Create_Plan_In_CW_And_Switch_PE_Edit
    Step3: Check Parameter Value IN PE

Case Setup: Create_Plan_In_CW_And_Switch_PE_Edit
    Common Setup

Case Teardown: Create_Plan_In_CW_And_Switch_PE_Edit
    Common Teardown

Step1: Create Plan: Create_Plan_In_CW_And_Switch_PE_Edit
    COAM WEBUI Create Plan

Step2: Change Parameter Value IN CW: Create_Plan_In_CW_And_Switch_PE_Edit
    Enter Into CW Page
    Open CW Modal View
    ${ori_value}   Get Input Parameter In CW Modal View   parameter_name=BTS name
    Modify Input Parameter In CW Modal View   parameter_name=BTS name   value=${ori_value}_CW
    Done CW Modal View
    Set Test Variable   ${ori_value}

Step3: Check Parameter Value IN PE
    ${pe_value}   COAM WEBUI Get Parameter Plan Value
    ...   dist_name=${MO_NAME}
    ...   filter_param=BTS name
    ...   abbr=btsName
    ...   bts_configuration=Planned
    Should Be Equal   ${pe_value}   ${ori_value}_CW

