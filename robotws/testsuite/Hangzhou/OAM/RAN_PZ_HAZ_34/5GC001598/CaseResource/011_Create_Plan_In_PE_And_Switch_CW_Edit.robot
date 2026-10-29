*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Commissioning_Wizard_Create_Plan_In_PE_And_Switch_CW_Edit
    Step1: Create Plan: Create_Plan_In_PE_And_Switch_CW_Edit
    Step2: Change Parameter Value IN PE
    Step3: Check Parameter Value IN CW

Case Setup: Create_Plan_In_PE_And_Switch_CW_Edit
    Common Setup

Case Teardown: Create_Plan_In_PE_And_Switch_CW_Edit
    Common Teardown

Step1: Create Plan: Create_Plan_In_PE_And_Switch_CW_Edit
    COAM WEBUI Create Plan

Step2: Change Parameter Value IN PE
    ${ori_value}   COAM WEBUI Get Parameter Plan Value
    ...   dist_name=${MO_NAME}
    ...   filter_param=BTS name
    ...   abbr=btsName
    ...   bts_configuration=Planned
    Set Test Variable   ${ori_value}
    COAM WEBUI Set Parameter Value
    ...   dist_name=${MO_NAME}
    ...   filter_param=BTS name
    ...   abbr=btsName
    ...   new_value=${ori_value}_PE
    ...   bts_configuration=Planned

Step3: Check Parameter Value IN CW
    Enter Into CW Page
    Open CW Modal View
    ${CW_value}   Get Input Parameter In CW Modal View   parameter_name=BTS name
    Done CW Modal View
    Should Be Equal   ${CW_value}   ${ori_value}_PE
