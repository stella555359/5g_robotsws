*** Settings ***
Documentation
    ...  Open Commissioning Wizard menu and verify if the page is fully loaded.
    ...  Select Create plan and verify cancel button.
    ...  Verify if plan was not created.
    ...  Select Create plan and verify if CONF-1 is visible as default name.
    ...  Input a new name, NEW-PLAN-1, and choose OK.
    ...  Verify if plan with name NEW-PLAN-1 was created.
    ...  Fix all errors after plan was created.
    ...  Repet these steps 3 times.
    ...  Verify if 'Maximum number of plans already created' message is visible after 3 plans created.
    ...  Select Delete plan and verify cancel button for each plan created.
    ...  Verify if plan is still visible.
    ...  Select Delete plan for each plan created.
    ...  Duplicate plan for 3 times.
    ...  Verify if 'Maximum number of plans already created' message is visible after 3 plans created.
    ...  Select Delete plan for each plan created.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__CW_Configuration_plan_creation_of_a_new_configuration_plan
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26219
    ...
    ...  ******************
    ...  - 07.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26219 - Initial TAT creation
    ...  - 27.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27631 - Many xpaths have changed
    ...  - 27.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27709 - Fix errors button fixed
    ...  - 24.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29572 - Cancel confirmation messages check for trunk

    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  FEATURE-CB005866-A

    Step1: Open Commissioning Wizard
    Step2: Verify Cancel Button When Create Plan Is Selected
    Step3: Create Three Plans And Verify The Button
    Step4: Verify Cancel Button When Delete All Plans Created And Verify Confirmation Dialog
    Step5: Delete All Plans Created And Verify Confirmation Dialog
    Step6: Duplicate Plan For Three Times And Verify The Button
    Step7: Delete All Plans Created And Verify Confirmation Dialog


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Open Commissioning Wizard


Step2: Verify Cancel Button When Create Plan Is Selected
    Log  \nStep2: Verify cancel button when create plan is selected  console=true
    Wait Until Element Is Clicked  //*[@id="toolbar-create-plan-button"]/button/span[1]  120
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div[2]/p-button[2]/button/span  60
    Log  Cancel button was pushed when create plan was selected!  console=true
    Wait Until Element Is Clicked  //*[contains(@class, 'p-dropdown-group-item')]  120
    Element Should Not Be Visible  //*[contains(@aria-label, 'CONF-1')]
    Log  No plan was created![OK]  console=true


Step3: Create Three Plans And Verify The Button
    Log  \nStep3: Create three plans and verify the button  console=true
    FOR  ${plan_number}  IN RANGE  1  4
        Wait Until Element Is Clicked  //*[@id="toolbar-create-plan-button"]/button/span[1]  120
        Sleep  10s  Time for dropdown to be visible.
        ${plan_name}  Get Value  //*[contains(@class, 'field p-inputgroup-with-label--block')]/div/input
        Should Be Equal  ${plan_name}  CONF-1
        Log  Default name CONF-1 is visible![OK]  console=true
        Wait Until Keyword Succeeds  120  5
        ...  Input Text  //*[contains(@class, 'field p-inputgroup-with-label--block')]/div/input  NEW-PLAN-${plan_number}
        Log  Input NEW-PLAN-${plan_number} text as plan name!  console=true
        Wait Until Element Is Clicked  //*[@id="laf-component"]/div[2]/p-button[1]/button/span  120
        Sleep  30s  Time for plan to be updated!
        Wait Until Element Is Clicked  //*[contains(@class, 'p-dropdown-group-item')]  120
        Wait Until Keyword Succeeds  30  5
        ...  Page Should Contain Element  //*[contains(@aria-label, 'NEW-PLAN-${plan_number}')]
        Log  Plan NEW-PLAN-${plan_number} was created!  console=true
        Fix All Errors After Plan Was Created
    END
    Wait Until Keyword Succeeds  30  5
    ...  Element Should Be Disabled  //*[@id="toolbar-create-plan-button"]/button
    Mouse Over  //*[@id="toolbar-create-plan-button"]/button
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain  Maximum number of plans already created
    Log  Message 'Maximum number of plans already created' is visible on commissioning wizard page![OK]  console=true


Step4: Verify Cancel Button When Delete All Plans Created And Verify Confirmation Dialog
    Log  \nStep4: Verify cancel button when delete all plans created and verify confirmation dialog  console=true
    FOR  ${plan_number}  IN RANGE  1  4
        Wait Until Element Is Clicked  //*[contains(@class, 'p-dropdown-group-item')]  120
        Wait Until Element Is Clicked  //*[contains(@aria-label, 'NEW-PLAN-${plan_number}')]
        Log  Plan NEW-PLAN-${plan_number} was choose to be deleted!  console=true
        Wait Until Element Is Clicked  //*[@id="laf-component"]/div/cem-toolbar/div/div[1]/div[4]/p-button[3]/button/span[1]  120
        Log  Delete plan button was pushed!  console=true
        Wait Until Element Is Visible  //*[contains(text(), "Do you want to delete the plan NEW-PLAN-${plan_number}?")]  60
        Log  Confirmation dialog is visible and message 'Do you want to delete the plan NEW-PLAN-${plan_number}?' appeared![OK]  console=true
        Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/p-button[2]/button/span
        Log  Cancel button was pushed!  console=true
        Wait Until Element Is Clicked  //*[contains(@class, 'p-dropdown-group-item')]  120
        Wait Until Keyword Succeeds  30  5
        ...  Page Should Contain Element  //*[contains(@aria-label, 'NEW-PLAN-${plan_number}')]
        Wait Until Element Is Clicked  //*[contains(@class, 'p-dropdown-group-item')]  120
        Log  Plan NEW-PLAN-${plan_number} is still visible!  console=true
    END


Step${index}: Delete All Plans Created And Verify Confirmation Dialog
    Log  \nStep${index}: Delete all plans created and verify confirmation dialog  console=true
    FOR  ${plan_number}  IN RANGE  1  4
        Wait Until Element Is Clicked  //*[contains(@class, 'p-dropdown-group-item')]  120
        Wait Until Element Is Clicked  //*[contains(@aria-label, 'NEW-PLAN-${plan_number}')]
        Log  Plan NEW-PLAN-${plan_number} was choose to be deleted!  console=true
        Wait Until Element Is Clicked  //*[@id="laf-component"]/div/cem-toolbar/div/div[1]/div[4]/p-button[3]/button/span[1]  120
        Log  Delete plan button was pushed!  console=true
        Wait Until Element Is Visible  //*[contains(text(), "Do you want to delete the plan NEW-PLAN-${plan_number}?")]  60
        Log  Confirmation dialog is visible and message 'Do you want to delete the plan NEW-PLAN-${plan_number}?' appeared![OK]  console=true
        Wait Until Element Is Clicked  //*[contains(text(), "Do you want to delete the plan NEW-PLAN-${plan_number}?")]  60
        Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span  60
        Log  Delete plan is performing!  console=true
        Log  Plan NEW-PLAN-${plan_number} is deleted!  console=true
    END


Step6: Duplicate Plan For Three Times And Verify The Button
    Log  \nStep6: Duplicate plan for three times and verify the button  console=true
    FOR  ${plan_number}  IN RANGE  1  4
        Wait Until Element Is Clicked  //*[@id="toolbar-create-plan-button"]/button/span[1]  120
        Sleep  10s  Time for dropdown to be visible.
        ${plan_name}  Get Value  //*[contains(@class, 'field p-inputgroup-with-label--block')]/div/input
        Should Be Equal  ${plan_name}  CONF-1
        Log  Default name CONF-1 is visible![OK]  console=true
        Wait Until Keyword Succeeds  120  5
        ...  Input Text  //*[contains(@class, 'field p-inputgroup-with-label--block')]/div/input  NEW-PLAN-${plan_number}
        Log  Input NEW-PLAN-${plan_number} text as plan name!  console=true
        Wait Until Element Is Clicked  //*[contains(@class, 'ot-radiogroup ot-radiogroup-vertical')]/p-radiobutton[2]/div/div[2]
        Log  Duplicate plan from current plan was performed!  console=true
        Wait Until Element Is Clicked  //*[@id="laf-component"]/div[2]/p-button[1]/button/span  120
        Sleep  30s  Time for plan to be updated!
        Wait Until Element Is Clicked  //*[contains(@class, 'p-dropdown-group-item')]  120
        Wait Until Keyword Succeeds  30  5
        ...  Page Should Contain Element  //*[contains(@aria-label, 'NEW-PLAN-${plan_number}')]
        Log  Plan NEW-PLAN-${plan_number} was created!  console=true
        Wait Until Element Is Clicked  //*[contains(@class, 'p-dropdown-group-item')]  120
    END
    Wait Until Keyword Succeeds  30  5
    ...  Element Should Be Disabled  //*[@id="toolbar-create-plan-button"]/button
    Mouse Over  //*[@id="toolbar-create-plan-button"]/button
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain  Maximum number of plans already created
    Log  Message 'Maximum number of plans already created' is visible on commissioning wizard page![OK]  console=true


Fix All Errors After Plan Was Created
    Log  Fix all errors after plan was created  console=true
    Save Plan From Commissioning Wizard
    Click Element  //*[@icon="mdi mdi-wrench"]/button
    Wait Until Keyword Succeeds  120  5
    ...  Page Should Contain  Do you want to fix errors?
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span  120
    IF  '${VDU_ACTIVE_SW_RELEASE}' < 'vDUCNF26R1'  Wait Until Keyword Succeeds  120  1
    ...  Page Should Contain  Fix Errors operation succeeded


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Configuration_plan_creation_of_a_new_configuration_plan


TC Teardown
    VDU WebEM Teardown
    Common VDU Teardown
