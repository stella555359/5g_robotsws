*** Settings ***
Documentation
    ...  This TC is created to verify if delta plan can be validated.
    ...  Commissioning Wizard is opened.
    ...  Delta plan is created.
    ...  Changes are made in General Site Settings without saving them.
    ...  Validation operation is proceeded, but warning message appears.
    ...  Changes made in General Site Settings are saved.
    ...  Validation operation is done without any warnings.
    ...  Delta plan is deleted.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${NEW_BTS_NAME}  ${EMPTY}  # Mandatory! BTS Name to change.


*** Keywords ***
TC__WebEM__vDU__CW_Validate_configuration_plan_in_vDU
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26713
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  15.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26713 - Initial TAT creation
    ...  ******************
    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  PHASE-CRT  FEATURE-CB005866-E

    Step1: Open Commissioning Wizard
    Step2: Validate Plan When Changes Are Unsaved


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Open Commissioning Wizard
    Create Duplicate Plan For CBTS


Step2: Validate Plan When Changes Are Unsaved
    Log  \nStep2: Validate plan when changes are unsaved.  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'General Site Settings')]
    ${bts_name_path}  Catenate  SEPARATOR=  //*[contains(@class, "step-content")]/blocks-steps-general-site-setting/div/div[1]/p-panel/div/div[2]/div
    ...  /cem-parameter-editor-table/div/p-treetable/div/div[1]/div/div/table/tbody/tr[1]/td[2]
    ...  /cem-parameter-input/cem-string-input/ot-field/div/input
    Wait Until Keyword Succeeds  30s  2s
    ...  Input Text  ${bts_name_path}  ${NEW_BTS_NAME}
    Wait Until Element Is Clicked  //*[@icon="mdi mdi-check-all"]/button
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div[2]/p-button[1]/button/span
    Wait Until Keyword Succeeds  10s  2s
    ...  Element Should Be Visible  //*[contains(text(),'Unsaved changes exist in selected plan')]
    ${text}  Catenate  Delta changes have not been synchronized to the BTS.
    ...  Please save or discard changes before switching to other view or doing other operation.
    Element Should Be Visible  //*[contains(text(),'${text}')]
    Click Element  //*[contains(text(),'Close')]
    Click Element  //*[contains(text(),'Discard')]
    Wait Until Keyword Succeeds  30s  2s
    ...  Input Text  ${bts_name_path}  ${NEW_BTS_NAME}
    Wait Until Element Is Clicked  //*[@icon="mdi mdi-check-all"]/button
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div[2]/p-button[1]/button/span
    Wait Until Keyword Succeeds  10s  2s
    ...  Element Should Be Visible  //*[contains(text(),'Unsaved changes exist in selected plan')]
    ${text}  Catenate  Delta changes have not been synchronized to the BTS.
    ...  Please save or discard changes before switching to other view or doing other operation.
    Element Should Be Visible  //*[contains(text(),'${text}')]
    Click Element  //*[contains(text(),'Close')]
    Click Element  //*[@id="save-btn"]
    Sleep  20s  Sleep for changes to be saved.
    Wait Until Element Is Clicked  //*[@icon="mdi mdi-check-all"]/button
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div[2]/p-button[1]/button/span
    Wait Until Keyword Succeeds  120  1  Page should contain  Plan Validation operation succeeded
    Delete Actual Plan Via WebEM


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Validate_configuration_plan_in_vDU


TC Teardown
    Run Keyword If Test Failed
    ...  Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown
