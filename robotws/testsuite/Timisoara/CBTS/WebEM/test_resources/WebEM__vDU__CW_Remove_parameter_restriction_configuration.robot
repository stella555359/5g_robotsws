*** Settings ***
Documentation
    ...  Open Commissioning Wizard menu and verify if the page is fully loaded.
    ...  Create delta plan is performed.
    ...  Add FEATCADM object with accLevSet parameter in restriction configuration.
    ...  Check that FEATCADM object cannot be moved in restriction configuration.
    ...  Go to parameter editor tab.
    ...  Change accLevSet parameter value and activate the plan.
    ...  Plan activation is failed with a specific message.
    ...  Add a random NRCELL in restriction configuration.
    ...  Delete all added objects and parameters from restriction configuration.
    ...  Delete delta plan.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__CW_Remove_parameter_restriction_configuration
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26807
    ...
    ...  ******************
    ...  - 18.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26807 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  SW-SBTS24  FEATURE-CB005866-D

    Step1: Open Commissioning Wizard And Create Plan
    Step2: Add FEATCADM Object With A Parameter In Restriction Configuration And Verify Validation
    Step3: Add One NRCELL In Restriction Configuration
    Step4: Delete All Added Objects And Parameters From Restriction Configuration


Step1: Open Commissioning Wizard And Create Plan
    Log  \nStep1: Open Commissioning Wizard and create plan  console=true
    Open Commissioning Wizard
    Create Duplicate Plan For CBTS


Step2: Add FEATCADM Object With A Parameter In Restriction Configuration And Verify Validation
    Log  \nStep2: Add FEATCADM object with a parameter in restriction configuration and verify validation  console=true
    Click Element  //*[contains(@aria-label, 'Parameter Restriction Configuration')]
    Log  Adding FEATCADM object to restricted instances  console=true
    Click Element  //*[contains(@class, 'grid grid-nogutter field ng-star-inserted')]/ot-field/p-dropdown/div/span
    Wait Until Element Is Clicked  //span[contains(text(), 'FEATCADM')]  10  2
    Wait Until Element Is Clicked  //div[@class='p-element ot-text-ellipsis ng-star-inserted' and text()='FEATCADM-1']  10  2
    Element Should Be Disabled  //*[@id="restricted-instances"]/div/div[2]/button
    Log  FEATCADM object cannot be moved in restriction configuration![OK]  console=true
    Log  Add accLevSet to restricted parameters  console=true
    Click Element  //*[contains(text(), "FEATCADM-accLevSet")]
    Click Element  //*[@id="restricted-parameters"]/div/div[2]/button/span[1]
    Element Should Be Visible  //div[@class='p-element ot-text-ellipsis' and text()='FEATCADM-accLevSet']
    ...  Didn't manage to add FEATCADM-accLevSet to restricted parameters![NOK]
    Log  FEATCADM-accLevSet was added into restricted parameters![OK]  console=true
    Save Plan From Commissioning Wizard
    Change AccLevSet Parameter And Verify Error Message After Activation


Step3: Add One NRCELL In Restriction Configuration
    Log  \nStep3: Add one NRCELL in restriction configuration  console=true
    ${nrcells_list}  Create List
    ${cells_info}  Get Vdu Cells Status
    FOR  ${cell}  IN  @{cells_info}
        Append To List  ${nrcells_list}  ${cell}[name]
    END
    ${random_cell_name}  Evaluate  random.choice(${nrcells_list})  random
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'Parameter Restriction Configuration')]  120  10
    Log  Adding NRCELL instance to restricted instances  console=true
    Click Element  //*[contains(@class, 'grid grid-nogutter field ng-star-inserted')]/ot-field/p-dropdown/div/span
    Wait Until Element Is Clicked  //span[contains(text(), 'NRCELL')]  10  2
    Wait Until Element Is Clicked  //div[@class='p-element ot-text-ellipsis ng-star-inserted' and text()='${random_cell_name}']  10  2
    Click Element  //*[@id="restricted-instances"]/div/div[2]/button/span[1]
    ${restricted_instances_text}  Get Text  //*[contains(@class,'flex align-items-center justify-content-between ng-star-inserted')]/div
    Should Be Equal As Strings  ${random_cell_name}  ${restricted_instances_text}  Could not add NRCELL instance to restricted instances![NOK]
    Log  NRCELL added successfully to restricted instances![OK]  console=true
    Save Plan From Commissioning Wizard


Step4: Delete All Added Objects And Parameters From Restriction Configuration
    Log  \nStep4: Delete all added objects and parameters from restriction configuration  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'Parameter Restriction Configuration')]  120  10
    Wait Until Element Is Clicked  //*[contains(@class,'flex align-items-center justify-content-between ng-star-inserted')]/p-button/button/span[1]
    ...  10  2
    Element Should Be Visible  //*[contains(@class,'p-picklist-empty-message p-listbox-empty-message ng-star-inserted')]
    Wait Until Element Is Clicked  //*[contains(@class,'flex align-items-center justify-content-between ng-star-inserted')]/p-button/button/span[1]
    ...  10  2
    Sleep  5s  Time for parameter to be deleted!
    ${no_data_count}  SeleniumLibrary.Get Element Count  //*[contains(@class,'p-picklist-empty-message p-listbox-empty-message ng-star-inserted')]
    ${no_data_count}  Convert To String  ${no_data_count}
    Should Be Equal  ${no_data_count}  4  Not all added objects and parameters from restriction configuration are deleted![NOK]
    Log  All added objects and parameters from restriction configuration are deleted![OK]  console=true


Change AccLevSet Parameter And Verify Error Message After Activation
    Log  Change accLevSet parameter and verify error message after activation  console=true
    Click Element  //*[@id="/parameter-editor"]
    Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  accLevSet
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  ENTER
    Sleep  5s  Time for page to be loaded.
    Click Element  //*[contains(@class, 'p-element p-treetable-tbody')]/tr/td[4]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    ${parameter_value}  Get Text
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr/td[4]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    Run Keyword If  '${parameter_value}' == 'Low' or '${parameter_value}' == '<Select Value>'
    ...  Click Element  //*[contains(@aria-label,'High')]
    ...  ELSE
    ...  Click Element  //*[contains(@aria-label,'Low')]
    Click Element  //*[contains(@class, 'p-element p-treetable-tbody')]/tr/td[3]
    Log  accLevSet parameter was changed!  console=true
    Wait Until Element Is Visible  //*[contains(text(),'Activate Plan')]  30s
    Click Element  //*[contains(text(),'Activate Plan')]
    Log  Activate plan button is pushed!  console=true
    Wait Until Element Is Clicked  //*[@id="toolbar-activate-plan-button"]/button
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div[2]/p-button[1]/button/span
    Wait Until Keyword Succeeds  200  5
    ...  Page Should Contain  Plan validation failed. Error message : Modification of restricted parameter
    Page Should Contain  is not allowed.
    Log  Error message: Modification of restricted parameter accLevSet is not allowed is visible![OK]  console=true
    Click Element  //*[contains(text(),'Close')]
    Wait Until Element Is Clicked  //*[@id="/commissioning-wizard"]


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Remove_parameter_restriction_configuration


TC Teardown
    Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown
