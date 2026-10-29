*** Settings ***
Documentation
    ...  TC is created to verify if configuration plan is resumed after plan break.
    ...  Open Commissioning Wizard.
    ...  New duplicate plan is created and bts name value is changed.
    ...  Saving changes.
    ...  New delta plan is created and bts name value is changed.
    ...  Saving changes.
    ...  Logout from WebEM is performed.
    ...  Login on WebEM again and open Commissioning Wizard tab.
    ...  Verify if bts name value is the same with the changed value on staged plan in CW and PE.
    ...  Verify if bts name value is the same with the changed value on delta plan in CW and PE.
    ...  Delete all created plans.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__CW_Resume_Configuration_Plan_after_break
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26786
    ...
    ...  ******************
    ...  - 23.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26786 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  SW-SBTS24  FEATURE-CB005866-E

    Step1: Open Commissioning Wizard
    Step2: Create New Plan To Change Bts Name And Saving The Changes
    Step3: Create Delta Plan To Change Bts Name And Saving The Changes
    Step3: Logout From WebeM
    Step4: Login On WebEM Again And Open CW
    Step5: Verify Changes On Staged Plan In CW And PE
    Step6: Verify Changes On Delta Plan In CW And PE
    Step7: Delete All Created Plans


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Open Commissioning Wizard


Step2: Create New Plan To Change Bts Name And Saving The Changes
    Log  \nStep2: Create new plan to change bts name and saving the changes  console=true
    Wait Until Element Is Clicked  //span[contains(text(), "Create Plan")]  120
    Wait Until Keyword Succeeds  120  5
    ...  Input Text  //*[@id="webem-pe-create-plan-plan-name-input"]  NEW-PLAN-1
    Log  Input NEW-PLAN-1 text as plan name!  console=true
    Wait Until Element Is Clicked  //*[contains(@label, 'Duplicate plan from:')]/div/div[2]
    Log  Duplicate plan from current plan was performed!  console=true
    Wait Until Element Is Clicked  //span[contains(@class, "p-button-label ng-star-inserted") and contains(text(), 'OK')]  120
    Sleep  30s  Time for plan to be updated!
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'General Site Settings')]
    ${bts_name_path}  Catenate  SEPARATOR=  //*[contains(@class, "step-content")]/blocks-steps-general-site-setting/div/div[1]/p-panel/div/div[2]/div
    ...  /cem-parameter-editor-table/div/p-treetable/div/div[1]/div/div/table/tbody/tr[1]/td[2]
    ...  /cem-parameter-input/cem-string-input/ot-field/div/input
    ${initial_name_value}  Get Value  ${bts_name_path}
    Set Test Variable  ${INITIAL_NAME_VALUE}
    Set Test Variable  ${NEW_BTS_NAME}  vDU999
    Set Test Variable  ${BTS_NAME_PATH}
    Wait Until Keyword Succeeds  30s  2s
    ...  Input Text  ${BTS_NAME_PATH}  ${NEW_BTS_NAME}
    Log  BTS name was changed with value ${NEW_BTS_NAME}, initial value was ${INITIAL_NAME_VALUE}!  console=true
    Save Plan From Commissioning Wizard


Step3: Create Delta Plan To Change Bts Name And Saving The Changes
    Log  \nStep3: Create delta plan to change bts name and saving the changes  console=true
    Create Delta Plan For CBTS
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'General Site Settings')]
    Wait Until Keyword Succeeds  30s  2s
    ...  Input Text  ${BTS_NAME_PATH}  ${NEW_BTS_NAME}
    Log  BTS name was changed with value ${NEW_BTS_NAME}, initial value was ${INITIAL_NAME_VALUE}!  console=true
    Save Plan From Commissioning Wizard


Step3: Logout From WebeM
    Log  \nStep3: Logout from WebeM  console=true
    Logout From CBTS


Step4: Login On WebEM Again And Open CW
    Log  \nStep4: Login on WebEM again and open CW  console=true
    Wait Until Element Is Visible  //*[@id="login-username"]  120
    Login On CBTS
    Confirm Legal Notice From CBTS
    Log  Wait until the page is loaded!  console=true
    Wait Until Element Is Visible  //span[contains(@class, 'title') and contains(text(), 'Radio Modules Status Summary')]
    ...  120s  WebElement is not fully loaded in 120s seconds.
    Open Commissioning Wizard


Step5: Verify Changes On Staged Plan In CW And PE
    Log  \nStep5: Verify changes on staged plan in CW and PE  console=true
    Click Element  //*[@id="configuration-plans-dropdown"]/div/span[1]
    Wait Until Element Is Visible  //span[contains(@class, 'space-pre ng-star-inserted') and contains(text(), 'NEW-PLAN-1')]  60
    Log  NEW-PLAN-1 configuration is visible![OK]  console=true
    Click Element  //span[contains(@class, 'space-pre ng-star-inserted') and contains(text(), 'NEW-PLAN-1')]
    Wait Until Element Is Clicked  //*[contains(@aria-label, "General Site Settings")]  300
    Element Should Be Disabled  //*[@id="save-btn"]
    ${bts_name_value}  Get Value  ${BTS_NAME_PATH}
    Should Be Equal  ${bts_name_value}  ${NEW_BTS_NAME}  ${NEW_BTS_NAME} is not the bts name anymore![NOK]
    Log  '${bts_name_value}' is still the changed bts name![OK]  console=true
    Log  Open Parameter Editor to verify bts name parameter!  console=true
    Wait Until Element Is Clicked  //*[@id="/parameter-editor"]
    Wait Until Element Is Clicked  //*[@id="configuration-plans-dropdown"]/div/span[1]
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'NEW-PLAN-1')]
    Wait Until Keyword Succeeds  120  10
    ...  Input Text  //*[@id="parameter-search-input"]/div/input  btsName
    Click Element  //*[@id="parameter-search-input"]/div/div/i
    Wait Until Element Is Visible  //*[contains(@title, 'btsName')]  120
    Element Should Be Visible  //*[contains(@title, '${NEW_BTS_NAME}')]
    Log  '${NEW_BTS_NAME}' is visible as bts name![OK]  console=true


Step6: Verify Changes On Delta Plan In CW And PE
    Log  \nStep6: Verify changes on delta plan in CW and PE  console=true
    Wait Until Element Is Clicked  //*[contains(text(), "Commissioning Wizard")]
    Wait Until Element Is Visible  //span[contains(text(), "Create Plan")]  300
    Log  Commissioning Wizard page is fully loaded!  console=true
    Sleep  120s  Time for buttons to be pushed!
    Click Element  //*[@id="configuration-plans-dropdown"]/div/span[1]
    Wait Until Element Is Visible  //span[contains(@class, 'space-pre ng-star-inserted') and contains(text(), 'DELTA-PLAN-1')]  60
    Log  DELTA-PLAN-1 configuration is visible![OK]  console=true
    Click Element  //span[contains(@class, 'space-pre ng-star-inserted') and contains(text(), 'DELTA-PLAN-1')]
    Wait Until Element Is Clicked  //*[contains(@aria-label, "General Site Settings")]  300
    Element Should Be Disabled  //*[@id="save-btn"]
    ${bts_name_value}  Get Value  ${BTS_NAME_PATH}
    Should Be Equal  ${bts_name_value}  ${NEW_BTS_NAME}  ${NEW_BTS_NAME} is not the bts name anymore![NOK]
    Log  '${bts_name_value}' is still the changed bts name![OK]  console=true
    Log  Open Parameter Editor to verify bts name parameter!  console=true
    Wait Until Element Is Clicked  //*[@id="/parameter-editor"]
    Wait Until Element Is Clicked  //*[@id="configuration-plans-dropdown"]/div/span[1]
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'DELTA-PLAN-1')]
    Wait Until Keyword Succeeds  120  10
    ...  Input Text  //*[@id="parameter-search-input"]/div/input  btsName
    Click Element  //*[@id="parameter-search-input"]/div/div/i
    Wait Until Element Is Visible  //*[contains(@title, 'btsName')]  120
    Element Should Be Visible  //*[contains(@title, '${NEW_BTS_NAME}')]
    Log  '${NEW_BTS_NAME}' is visible as bts name![OK]  console=true
    Wait Until Element Is Clicked  //*[contains(text(), "Commissioning Wizard")]


Step7: Delete All Created Plans
    Log  \nStep7: Delete all created plans  console=true
    Delete All Plans


Delete All Plans
    Log  Delete actual delta plan  console=true
    Wait Until Element Is Clicked  //span[contains(text(), "Delete Plan")]
    Log  Delete plan button was pushed!  console=true
    Wait Until Element Is Clicked  //*[@id="webem-parameter-editor-menu-dialog"]/div/div/div[3]/button[2]  60
    Log  Delete delta plan is performing!
    Wait Until Element Is Visible  //span[contains(text(), "Create Delta Plan")]  60
    Log  Delta plan is deleted!  console=true
    Wait Until Element Is Clicked  //*[@id="configuration-plans-dropdown"]/div/span[1]
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'NEW-PLAN-1')]
    Delete Actual Plan Via WebEM


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Resume_Configuration_Plan_after_break


TC Teardown
    Run Keyword If Test Failed
    ...  Delete All Plans
    VDU WebEM Teardown
    Common VDU Teardown
