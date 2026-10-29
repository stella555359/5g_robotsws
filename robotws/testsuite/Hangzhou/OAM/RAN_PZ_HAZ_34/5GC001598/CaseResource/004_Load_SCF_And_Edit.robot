*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Commissioning_Wizard_Load_SCF_And_Edit
    Step1: Load SCF And Get Origin Parameter
    Step2: Modify Parameter
    Step3: Check Parameter

Case Setup: Load_SCF_And_Edit
    Common Setup

Case Teardown: Load_SCF_And_Edit
    Common Teardown

Step1: Load SCF And Get Origin Parameter
    Wait Until Keyword Succeeds   3 times   2s   COAM WEBUI Load SCF
    Sleep   3s
    Enter Into CW Page
    Open CW Modal View
    ${ori_value}   Get Input Parameter In CW Modal View   parameter_name=BTS name
    Set Test Variable   ${ori_value}

Step2: Modify Parameter
    Modify Input Parameter In CW Modal View   parameter_name=BTS name   value=${ori_value}_CW
    Done CW Modal View

Step3: Check Parameter
    COAM WEBUI Save BTS Configuration   SCF_path=${OUTPUT_DIR}/004_SCF.xml
    ${xpath}   Set Variable   cmData/managedObject[@distName="${MO_NAME}"]/p[@name="btsName"]
    ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/004_SCF.xml
    ${new_value}   XML.Get Element Text   ${scf_xml}   xpath=${xpath}
    Should Be Equal   ${new_value}   ${ori_value}_CW
