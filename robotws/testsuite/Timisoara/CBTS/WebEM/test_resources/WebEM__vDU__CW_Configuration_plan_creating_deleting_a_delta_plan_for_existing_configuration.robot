*** Settings ***
Documentation
    ...  Open Commissioning Wizard menu and verify if the page is fully loaded.
    ...  Select Create delta plan and verify cancel button.
    ...  Verify if delta plan was not created.
    ...  Select Create delta plan and verify if DELTA-PLAN-1 is visible as default name.
    ...  Input a new name, NEW-DELTA-PLAN, and choose OK.
    ...  Verify if delta plan with name NEW-DELTA-PLAN was created.
    ...  Verify if 'Maximum number of delta plans already created' message is visible.
    ...  Select Delete plan and verify cancel button.
    ...  Verify if delta plan is still visible.
    ...  Select Delete plan and verify if NEW-DELTA-PLAN is deleted.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__CW_Configuration_plan_creating_deleting_a_delta_plan_for_existing_configuration
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26220
    ...
    ...  ******************
    ...  - 03.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26220 - Initial TAT creation
    ...  - 27.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27631 - Many xpaths have changed

    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  FEATURE-CB005866-A

    Step1: Open Commissioning Wizard
    Step2: Verify Cancel Button When Create Delta Plan Is Selected
    Step3: Select Create Delta Plan And Set The Name
    Step4: Verify Cancel Button When Delete Delta Plan Created And Verify Confirmation Dialog
    Step5: Delete Delta Plan Created And Verify Confirmation Dialog


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Open Commissioning Wizard


Step2: Verify Cancel Button When Create Delta Plan Is Selected
    Log  \nStep2: Verify cancel button when create delta plan is selected  console=true
    Wait Until Element Is Clicked  //span[contains(text(), "Create Delta Plan")]  120
    Wait Until Element Is Clicked  //*[@id="edit-plan-cancel-button"]/button/span  60
    Log  Cancel button was pushed when create delta plan was selected!  console=true
    Element Should Be Disabled  //*[@id="configuration-plans-dropdown"]/div/div[1]/input
    Log  No delta plan was created![OK]  console=true


Step3: Select Create Delta Plan And Set The Name
    Log  \nStep3: Select create delta plan and set the name  console=true
    Wait Until Element Is Clicked  //span[contains(text(), "Create Delta Plan")]  120
    Log  Create delta plan button is pushed!  console=true
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain Element  //*[contains(@title, 'DELTA-PLAN-1')]
    Log  Default name DELTA-PLAN-1 is visible!  console=true
    Wait Until Keyword Succeeds  120  5
    ...  Input Text  //*[@id="edit-plan-plan-name-input"]  NEW-DELTA-PLAN
    Log  Input NEW-DELTA-PLAN text as delta plan name!  console=true
    Wait Until Element Is Clicked  //*[@id="edit-plan-create-button"]/button/span  120
    Sleep  30s  Time for plan to be updated!
    ${text_plan}  Get Text  //*[@id="configuration-plans-dropdown"]/div
    Run Keyword If  '${text_plan}'=='NEW-DELTA-PLAN'
    ...  Log  Delta plan 'NEW-DELTA-PLAN' was created![OK]  console=true
    ...  ELSE
    ...  Fail  Delta plan 'NEW-DELTA-PLAN' was not created![NOK]
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain Element  //*[contains(@title, 'Maximum number of delta plans already created')]
    Log  Message 'Maximum number of delta plans already created' is visible on commissioning wizard page![OK]  console=true


Step4: Verify Cancel Button When Delete Delta Plan Created And Verify Confirmation Dialog
    Log  \nStep4: Verify cancel button when delete delta plan created and verify confirmation dialog  console=true
    Wait Until Element Is Clicked  //span[contains(text(), "Delete Plan")]
    Log  Delete plan button was pushed!  console=true
    Wait Until Element Is Visible  //*[contains(text(), "Do you want to delete plan NEW-DELTA-PLAN?")]  60
    Log  Confirmation dialog is visible and message 'Do you want to delete plan NEW-DELTA-PLAN?' appeared![OK]  console=true
    Wait Until Element Is Clicked  //span[contains(text(), "Cancel")]
    Log  Cancel button was pushed!  console=true
    ${text_plan}  Get Text  //*[@id="configuration-plans-dropdown"]/div
    Run Keyword If  '${text_plan}'=='NEW-DELTA-PLAN'
    ...  Log  Delta plan 'NEW-DELTA-PLAN' is still visible![OK]  console=true
    ...  ELSE
    ...  Fail  Delta plan 'NEW-DELTA-PLAN' is not still visible![NOK]


Step5: Delete Delta Plan Created And Verify Confirmation Dialog
    Log  \nStep5: Delete delta plan created and verify confirmation dialog  console=true
    Wait Until Element Is Clicked  //span[contains(text(), "Delete Plan")]
    Log  Delete plan button was pushed!  console=true
    Wait Until Element Is Visible  //*[contains(text(), "Do you want to delete plan NEW-DELTA-PLAN?")]  60
    Log  Confirmation dialog is visible and message 'Do you want to delete plan NEW-DELTA-PLAN?' appeared![OK]  console=true
    Wait Until Element Is Clicked  //*[@id="webem-parameter-editor-menu-dialog"]/div/div/div[3]/button[2]  60  10
    Log  Delete plan is performing!  console=true
    Wait Until Element Is Visible  //span[contains(text(), "Create Delta Plan")]  60
    Element Should Be Disabled  //*[@id="configuration-plans-dropdown"]/div/div[1]/input
    Log  Delta plan 'NEW-DELTA-PLAN' is deleted![OK]  console=true


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Configuration_plan_creating_deleting_a_delta_plan_for_existing_configuration


TC Teardown
    VDU WebEM Teardown
    Common VDU Teardown
