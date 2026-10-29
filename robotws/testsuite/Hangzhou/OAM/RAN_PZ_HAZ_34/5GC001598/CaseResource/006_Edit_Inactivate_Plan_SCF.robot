*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Commissioning_Wizard_Edit_Inactivate_Plan_SCF
    Step1: Create Plan: Edit_Inactivate_Plan_SCF
    Step2: Change Parameter Value IN CW: Edit_Inactivate_Plan_SCF
    Step3: Check Parameter Value

Case Setup: Edit_Inactivate_Plan_SCF
    Common Setup

Case Teardown: Edit_Inactivate_Plan_SCF
    Common Teardown

Step1: Create Plan: Edit_Inactivate_Plan_SCF
    COAM WEBUI Create Plan

Step2: Change Parameter Value IN CW: Edit_Inactivate_Plan_SCF
    Enter Into CW Page
    Open CW Modal View
    ${ori_value}   Get Input Parameter In CW Modal View   parameter_name=BTS name
    Modify Input Parameter In CW Modal View   parameter_name=BTS name   value=${ori_value}_CW
    Done CW Modal View
    Set Test Variable   ${ori_value}

Step3: Check Parameter Value
    COAM WEBUI Save BTS Configuration   SCF_path=${OUTPUT_DIR}/006_SCF.xml
    ${xpath}   Set Variable   cmData/managedObject[@distName="${MO_NAME}"]/p[@name="btsName"]
    ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/006_SCF.xml
    ${new_value}   XML.Get Element Text   ${scf_xml}   xpath=${xpath}
    Should Be Equal   ${new_value}   ${ori_value}_CW
