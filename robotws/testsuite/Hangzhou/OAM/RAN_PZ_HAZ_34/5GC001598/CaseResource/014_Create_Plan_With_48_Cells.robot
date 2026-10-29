*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Commissioning_Wizard_Create_Plan_With_48_Cells
    Step1: Create 48 Cells
    Step2: Check 48 Cells Created

Case Setup: Create_Plan_With_48_Cells
    Common Setup

Case Teardown: Create_Plan_With_48_Cells
    Common Teardown

Step1: Create 48 Cells
    Enter Into CW Page
    FOR   ${index}    IN RANGE    ${48}
       Add Cell In CW Site View   cell_type=TDD
    END

Step2: Check 48 Cells Created
    COAM WEBUI Save BTS Configuration   SCF_path=${OUTPUT_DIR}/new_plan.xml
    ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/new_plan.xml
    ${count}   XML.Get Element Count   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    Run Keyword If   ${count} < 48   Fail   Create 48 Cells Failed!