*** Settings ***
Documentation
    ...  Open Commissioning Wizard menu and verify if the page is fully loaded.
    ...  Create delta plan and change bts name parameter from CW.
    ...  SCF is saved in test result directory.
    ...  Activate the plan when are unsaved changes on CBTS.
    ...  Warning message should be visible.
    ...  Save changes.
    ...  Push activate plan button and verify all checkboxes are visible.
    ...  Activate the plan without any checkbox.
    ...  Verify in parameter editor if bts name was changed.
    ...  Restore initial value for bts name.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${NEW_BTS_NAME}  ${EMPTY}  # Mandatory!BTS Name to change


*** Keywords ***
TC__WebEM__vDU__CW_Provision_configuration_plan
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26780
    ...
    ...  ******************
    ...  - 19.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26780 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  SW-SBTS24  FEATURE-CB005866-E

    Step1: Open Commissioning Wizard
    Step2: Create Delta Plan And Change Bts Name
    Step3: Activate The Plan When Are Unsaved Changes On CBTS
    Step4: Save Changes
    Step5: Activate The Plan Without Checkbox
    Step6: Restore The Initial Value


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Should Not Be Empty  ${NEW_BTS_NAME}  New bts name for this test must be specified, please provide it and retest.
    Open Commissioning Wizard


Step2: Create Delta Plan And Change Bts Name
    Log  \nStep2: Create delta plan and change bts name  console=true
    Create Delta Plan For CBTS
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'General Site Settings')]
    ${bts_name_path}  Catenate  SEPARATOR=  //*[contains(@class, "step-content")]/blocks-steps-general-site-setting/div/div[1]/p-panel/div/div[2]/div
    ...  /cem-parameter-editor-table/div/p-treetable/div/div[1]/div/div/table/tbody/tr[1]/td[2]
    ...  /cem-parameter-input/cem-string-input/ot-field/div/input
    ${initial_name_value}  Get Value  ${bts_name_path}
    Set Test Variable  ${INITIAL_NAME_VALUE}
    Set Test Variable  ${BTS_NAME_PATH}
    Wait Until Keyword Succeeds  30s  2s
    ...  Input Text  ${BTS_NAME_PATH}  ${NEW_BTS_NAME}


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


Step5: Activate The Plan Without Checkbox
    Log  \nStep5: Activate the plan without checkbox  console=true
    Wait Until Element Is Clicked  //*[@id="webem-parameter-editor-menu-plan-activation-button"]
    Wait Until Element Is Visible  //*[@id="download-plan-without-activation-checkbox"]  60
    Log  'Download plan without activation' is visible![OK]  console=true
    Wait Until Element Is Visible  //*[@id="force-plan-activation-despite-reset"]  60
    Log  'Force plan activation despite reset' is visible![OK]  console=true
    Wait Until Element Is Visible  //*[@id="force-plan-activation-despite-cell-locking"]  60
    Log  'Force plan activation despite cell locking' is visible![OK]  console=true
    Wait Until Element Is Clicked  //*[@id="execute-activate-plan"]/button/span
    Wait Until Element Is Visible  //span[contains(@class, 'feedback-text') and contains(text(), 'Plan activation has finished successfully')]  300
    Wait Until Element Is Clicked  //*[@id="activate-modal-done"]/button/span
    Log  Plan activation has finished successfully![OK]  console=true
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
    Restore The Initial Value Of Bts Name As A Recovery Action


Restore The Initial Value Of Bts Name As A Recovery Action
    Run Keyword And Ignore Error
    ...  Delete Actual Plan Via WebEM
    Click Element  //*[contains(text(), "Commissioning Wizard")]
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
    Modify Resource Search Order  WebEM__vDU__CW_Provision_configuration_plan


TC Teardown
    Run Keyword If Test Failed
    ...  Restore The Initial Value Of Bts Name As A Recovery Action
    VDU WebEM Teardown
    Common VDU Teardown
