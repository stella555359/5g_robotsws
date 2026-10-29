*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Commissioning_Wizard_Edit_Activate_Plan
    Step1: Modify Activate Plan
    Step2: Check Parameter

Case Setup: Edit_Activate_Plan
    Common Setup

Case Teardown: Edit_Activate_Plan
    Run Keyword And Ignore Error   COAM WEBUI Undo Changes
    Run Keyword And Ignore Error   COAM WEBUI Validate Plan
    Common Teardown

Step1: Modify Activate Plan
    Enter Into CW Page
    Open CW Modal View
    ${ori_value}   Get Input Parameter In CW Modal View   parameter_name=BTS name
    Modify Input Parameter In CW Modal View   parameter_name=BTS name   value=${ori_value}_CW
    Done CW Modal View
    Set Test Variable   ${ori_value}

Step2: Check Parameter
    COAM WEBUI Save BTS Configuration   SCF_path=${OUTPUT_DIR}/005_SCF.xml
    ${xpath}   Set Variable   cmData/managedObject[@distName="${MO_NAME}"]/p[@name="btsName"]
    ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/005_SCF.xml
    ${new_value}   XML.Get Element Text   ${scf_xml}   xpath=${xpath}
    Should Be Equal   ${new_value}   ${ori_value}_CW
