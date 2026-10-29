*** Settings ***
Documentation
    ...  Open Commissioning Wizard menu and verify if the page is fully loaded.
    ...  Create a new plan and change bts name parameter from CW.
    ...  Activate the plan when are unsaved changes on CBTS.
    ...  Warning message should be visible.
    ...  Save changes.
    ...  Activate the plan with checkbox 'Download plan without activation'.
    ...  Choose inactive configuration and activate the plan.
    ...  Wait until all cells are onAir.
    ...  Verify in parameter editor if bts name was changed.
    ...  Restore initial value for bts name.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${NEW_BTS_NAME}  vDU31  # Mandatory!BTS Name to change
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__WebEM__vDU__CW_Activate_Configuration_plan_in_vDU
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26779
    ...
    ...  ******************
    ...  - 22.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26779 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  SW-SBTS24  FEATURE-CB005866-E

    Step1: Open Commissioning Wizard
    Step2: Create Plan And Change Bts Name
    Step3: Activate The Plan When Are Unsaved Changes On CBTS
    Step4: Save Changes
    Step5: Activate The Plan With Checkbox
    Step6: Restore The Initial Value


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Should Not Be Empty  ${NEW_BTS_NAME}  New bts name for this test must be specified, please provide it and retest.
    Open Commissioning Wizard


Step2: Create Plan And Change Bts Name
    Log  \nStep2: Create plan and change bts name  console=true
    Wait Until Element Is Clicked  //span[contains(text(), "Create Plan")]  120
    Wait Until Keyword Succeeds  120  5
    ...  Input Text  //*[@id="webem-pe-create-plan-plan-name-input"]  NEW-PLAN-1
    Log  Input NEW-PLAN-1 text as plan name!  console=true
    Click Element  //*[contains(@label, 'Duplicate plan from:')]/div/div[2]
    Log  Duplicate plan from current plan was performed!  console=true
    Wait Until Element Is Clicked  //span[contains(@class, "p-button-label ng-star-inserted") and contains(text(), 'OK')]  120
    Sleep  30s  Time for plan to be updated!
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'General Site Settings')]
    ${bts_name_path}  Catenate  SEPARATOR=  //*[contains(@class, "step-content")]/blocks-steps-general-site-setting/div/div[1]/p-panel/div/div[2]/div
    ...  /cem-parameter-editor-table/div/p-treetable/div/div[1]/div/div/table/tbody/tr[1]/td[2]
    ...  /cem-parameter-input/cem-string-input/ot-field/div/input
    ${initial_name_value}  Get Value  ${bts_name_path}
    Set Test Variable  ${INITIAL_NAME_VALUE}
    Set Test Variable  ${BTS_NAME_PATH}
    Wait Until Keyword Succeeds  30s  2s
    ...  Input Text  ${BTS_NAME_PATH}  ${NEW_BTS_NAME}
    Log  BTS name was changed with value ${NEW_BTS_NAME}, initial value was ${INITIAL_NAME_VALUE}!  console=true


Step3: Activate The Plan When Are Unsaved Changes On CBTS
    Log  \nStep3: Activate the plan when are unsaved changes on CBTS  console=true
    Wait Until Element Is Clicked  //*[@id="webem-parameter-editor-menu-plan-activation-button"]
    Wait Until Element Is Clicked  //*[@id="execute-activate-plan"]/button/span
    Wait Until Element Is Visible  //*[@id="laf-component"]/div/div/div[1]/div[1]/span  120
    ${warning_text}  Get Text  //*[@id="laf-component"]/div/div/div[1]/div[1]/span
    Should Be Equal  ${warning_text}  Save warning  Save warning is not visible![NOK]
    Log  '${warning_text}' is visible![OK]  console=true
    ${text}  Catenate  SEPARATOR=  There are some unsaved changes in General Site Settings step. Please click save or discard changes. After that
    ...  , you can switch to other view or do other operation.
    Page Should Contain  ${text}  ${text} is not visible![NOK]
    Log  '${text}' is visible![OK]  console=true
    Click Element  //*[@id="laf-component"]/div/div/div[3]/div/button/span


Step4: Save Changes
    Log  \nStep4: Save changes  console=true
    Save Plan From Commissioning Wizard


Step5: Activate The Plan With Checkbox
    Log  \nStep5: Activate the plan with checkbox  console=true
    Wait Until Element Is Clicked  //*[@id="webem-parameter-editor-menu-plan-activation-button"]
    Wait Until Element Is Clicked  //*[@id="download-plan-without-activation-checkbox"]/div
    Wait Until Element Is Clicked  //*[@id="execute-activate-plan"]/button/span
    Wait Until Element Is Visible  //span[contains(@class, 'feedback-text') and contains(text(), 'Download operation has succeeded')]  300
    Log  'Download operation has succeeded' is visible![OK]  console=true
    Wait Until Element Is Clicked  //*[@id="activate-modal-done"]/button/span
    ${actual_plan}  Get Text  //*[@id="configuration-plans-dropdown"]/div/span[1]
    Should Be Equal  ${actual_plan}  NEW-PLAN-1  NEW-PLAN-1 is not the actual plan anymore![NOK]
    Log  '${actual_plan}' is still the actual plan![OK]  console=true
    ${bts_name_value}  Get Value  ${BTS_NAME_PATH}
    Should Be Equal  ${bts_name_value}  ${NEW_BTS_NAME}  ${NEW_BTS_NAME} is not the bts name anymore![NOK]
    Log  '${bts_name_value}' is still the bts name![OK]  console=true
    ${date_time}  Get Current Date  time_zone=UTC
    ${current_date_time}  Convert Date  ${date_time}  result_format=%Y-%m-%d
    Click Element  //*[@id="configuration-plans-dropdown"]/div/span[1]
    Wait Until Element Is Visible  //span[contains(@class, 'space-pre ng-star-inserted') and contains(text(), '${current_date_time}')]  60
    Log  Inactive configuration is visible![OK]  console=true
    Click Element  //span[contains(@class, 'space-pre ng-star-inserted') and contains(text(), '${current_date_time}')]
    Wait Until Element Is Visible  //span[contains(text(), "is ready to be activated")]  120s
    Wait Until Element Is Clicked  //*[@id="webem-parameter-editor-menu-plan-activation-button"]
    Wait Until Element Is Clicked  //*[@id="execute-activate-plan"]/button/span
    Log  Activate button is pushed![OK]  console=true
    Close Start-up View From VDU WebEM
    Wait Until Element Is Visible  //span[contains(@class, 'feedback-text') and contains(text(), 'Plan activation has finished successfully')]  300
    Log  'Plan activation has finished successfully' is visible![OK]  console=true
    Wait Until Element Is Clicked  //*[@id="activate-modal-done"]/button/span
    Log  Wait for all cells from vDU to be onAir!  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check All Cells From VDU  availability_status=${ONLINE}  operational_state=${ENABLED}
    Log  Cells are Online and Enable![OK]  console=true
    Log  Open Parameter Editor to verify bts name parameter!  console=true
    Wait Until Element Is Clicked  //*[@id="/parameter-editor"]
    Wait Until Element Is Clicked  //*[@id="configuration-plans-dropdown"]/div/span[1]
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'CURRENT_PLAN')]
    Wait Until Keyword Succeeds  120  10
    ...  Input Text  //*[@id="parameter-search-input"]/div/input  btsName
    Click Element  //*[@id="parameter-search-input"]/div/div/i
    Wait Until Element Is Visible  //*[contains(@title, 'btsName')]  120
    Element Should Be Visible  //*[contains(@title, '${NEW_BTS_NAME}')]
    Log  '${NEW_BTS_NAME}' is visible as bts name![OK]  console=true


Step6: Restore The Initial Value
    Log  \nStep6: Restore the initial value  console=true
    Restore The Initial Value Of Bts Name As A Recovery Action From CW


Restore The Initial Value Of Bts Name As A Recovery Action From CW
    Run Keyword And Ignore Error
    ...  Delete Actual Plan Via WebEM
    Wait Until Element Is Clicked  //*[contains(text(), "Commissioning Wizard")]
    Wait Until Element Is Visible  //span[contains(text(), "Create Plan")]  300
    Log  Commissioning Wizard page is fully loaded!  console=true
    Sleep  120s  Time for buttons to be pushed!
    Create Delta Plan For CBTS
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'General Site Settings')]
    Wait Until Keyword Succeeds  30s  2s
    ...  Input Text  ${BTS_NAME_PATH}  ${INITIAL_NAME_VALUE}
    Save Plan From Commissioning Wizard
    Wait Until Element Is Clicked  //*[@id="webem-parameter-editor-menu-plan-activation-button"]
    Wait Until Element Is Clicked  //*[@id="execute-activate-plan"]/button/span
    Wait Until Element Is Visible  //span[contains(@class, 'feedback-text') and contains(text(), 'Plan activation has finished successfully')]  300
    Wait Until Element Is Clicked  //*[@id="activate-modal-done"]/button/span
    Log  Plan activation has finished successfully![OK]  console=true


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Activate_Configuration_plan_in_vDU


TC Teardown
    Run Keyword If Test Failed
    ...  Restore The Initial Value Of Bts Name As A Recovery Action From CW
    VDU WebEM Teardown
    Common VDU Teardown
