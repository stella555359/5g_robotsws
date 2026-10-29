*** Settings ***
Documentation
    ...  Open Commissioning Wizard menu and verify if the page is fully loaded.
    ...  Select Create delta plan.
    ...  Select a random ALD.
    ...  Modify product code and verify if sync icon is visible in site view and step-by-step.
    ...  Create a new subunit for the choosen ALD and verify if sync icon is visible.
    ...  Click on sync icon and verify if is not visible anymore.
    ...  Modify product code again and verify if sync icon is visible after plan was saved.
    ...  Delete created delta plan.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__CW_Align_ALD_type_for_delta_plan_for_detected_ALD
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26783
    ...
    ...  ******************
    ...  - 12.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26783 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  FEATURE-CB005866-E

    Step0: Set Preconditions
    Step1: Open Commissioning Wizard And Create Delta Plan
    Step2: Modify Product Code For A Random ALD And Verify Align Icon
    Step3: Create A Subunit And Verify If Align Icon Is Visible
    Step4: Verify If Align Icon Is Still Visible After Plan Was Saved


Step0: Set Preconditions
    ${existing_rets}  Get Rets Information
    ${existing_raes}  Get Raes Information
    ${existing_mhas}  Get Mhas Information
    ${all_alds}  Combine Lists  ${existing_rets}  ${existing_raes}  ${existing_mhas}
    Should Not Be Empty  ${all_alds}  No existing ALD on vDU and at least one ALD is mandatory for this test!
    ${selected_ald}  Evaluate  random.choice(${all_alds})  random
    ${ald}  Get From Dictionary  ${selected_ald}  ald
    ${subunits}  Get From Dictionary  ${selected_ald}  subunits
    ${mha}  Run Keyword And Return Status
    ...  Dictionary Should Contain Key  ${ald}  mha_type
    Run Keyword If  ${mha}
    ...  Set Test Variable  ${ALD_TYPE}  ${ald}[mha_type]
    ...  ELSE
    ...  Set Test Variable  ${ALD_TYPE}  ${ald}[control_ports][0][port_name]
    Set Test Variable  ${EXISTING_ALD_SUBUNIT_CONFIG}  ${subunits}[0][dist_names][config]
    Set Test Variable  ${ALD_ID}  ${ald}[id]
    Log  ALD-${ALD_ID} ${ALD_TYPE} with subunit distname ${EXISTING_ALD_SUBUNIT_CONFIG} will be tested!  console=true


Step1: Open Commissioning Wizard And Create Delta Plan
    Log  \nStep1: Open commissioning wizard and create delta plan  console=true
    Open Commissioning Wizard
    Log  Create delta plan  console=true
    Create Delta Plan For CBTS


Step2: Modify Product Code For A Random ALD And Verify Align Icon
    Log  \nStep2: Modify product code for a random ALD and verify align icon  console=true
    Click Element  //*[@id="${EXISTING_ALD_SUBUNIT_CONFIG}"]/div/div[2]/p-button/button/span[1]
    Sleep  10s  Time for table to be visible
    Change Product Code
    Wait Until Element Is Clicked  //*[contains(@aria-label, "General Site Settings")]  300
    Sleep  60s  Time for page to be updated
    Click Element  //*[@id="${EXISTING_ALD_SUBUNIT_CONFIG}"]/div/div[3]/p-button/button/span[1]
    Sleep  30s  Time for icon to be visible in both sides, site view and step by step.
    ${sync_count}  SeleniumLibrary.Get Element Count  //*[contains(@class, "mdi mdi-sync-alert p-button-icon ng-star-inserted")]
    Run Keyword If  '${ALD_TYPE}' in ['RET', 'RAE']
    ...  Should Be Equal  ${sync_count}  ${2}  Sync icon is not visible in site view or step-by-step!
    ...  ELSE
    ...  Should Be Equal  ${sync_count}  ${3}  Sync icon is not visible in site view or step-by-step!
    Log  Sync icon is visible on both sides, site view and step-by-step!  console=true


Step3: Create A Subunit And Verify If Align Icon Is Visible
    Log  \nStep3: Create a subunit and verify if align icon is visible  console=true
    Run Keyword If  '${ALD_TYPE}' in ['RET', 'RAE']
    ...  Click Element  //*[contains(@aria-label, 'ALD-${ALD_ID}/ALD_R-${ALD_ID}')]/span/span/div/div[2]/p-button[2]/button/span[1]
    ...  ELSE
    ...  Click Element  //*[contains(@aria-label, '${ALD_TYPE} ALD-${ALD_ID}/ALD_R-${ALD_ID}')]/span/span/div/div[2]/p-button[3]/button/span[1]
    Sleep  10s  Time for sync icon to be visible
    Log  The new subunit was created!  console=true
    ${sync_count}  SeleniumLibrary.Get Element Count  //*[contains(@class, "mdi mdi-sync-alert p-button-icon ng-star-inserted")]
    Run Keyword If  '${ALD_TYPE}' in ['RET', 'RAE']
    ...  Should Be Equal  ${sync_count}  ${3}  Sync icon is not visible for the new subunit!
    ...  ELSE
    ...  Should Be Equal  ${sync_count}  ${4}  Sync icon is not visible for the new subunit!
    Log  Sync icon is visible on both sides, site view and step-by-step for all subunits!  console=true
    Log  Verify if sync is performing when the button is pushed!  console=true
    Click Element  //*[@id="${EXISTING_ALD_SUBUNIT_CONFIG}"]/div/div[2]/p-button/button/span[1]
    Run Keyword And Ignore Error
    ...  Wait Until Keyword Succeeds  60  5
    ...  Click Element  //*[@id="laf-component"]/div/div/div[3]/div/button[1]/span
    ${sync_count}  SeleniumLibrary.Get Element Count  //*[contains(@class, "mdi mdi-sync-alert p-button-icon ng-star-inserted")]
    Should Be Equal  ${sync_count}  ${0}  Sync icon is still visible in site view or step-by-step!
    Log  Sync icon is no longer visible for any subunit!  console=true


Step4: Verify If Align Icon Is Still Visible After Plan Was Saved
    Log  \nStep4: Verify if align icon is still visible after plan was saved  console=true
    Change Product Code
    Save Plan From Commissioning Wizard
    Click Element  //*[@id="${EXISTING_ALD_SUBUNIT_CONFIG}"]/div/div[3]/p-button/button/span[1]
    Sleep  30s  Time for icon to be visible in both sides, site view and step by step.
    Log  Verify if the sync icons are still visible!  console=true
    ${sync_count}  SeleniumLibrary.Get Element Count  //*[contains(@class, "mdi mdi-sync-alert p-button-icon ng-star-inserted")]
    Run Keyword If  '${ALD_TYPE}' in ['RET', 'RAE']
    ...  Should Be Equal  ${sync_count}  ${3}  Sync icon is not visible!
    ...  ELSE
    ...  Should Be Equal  ${sync_count}  ${4}  Sync icon is not visible!
    Log  Sync icon is visible on both sides, site view and step-by-step for all subunits!  console=true


Change Product Code
    Log  Change product code!  console=true
    Run Keyword If  '${ALD_TYPE}' in ['RET', 'RAE']
    ...  Input Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[2]/cem-parameter-input/cem-string-input/ot-field/div/input  0000
    ...  ELSE
    ...  Input Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[2]/cem-parameter-input/cem-string-input/ot-field/div/input  0000
    Sleep  10s  Time for text to be visible
    Log  Product code was changed into 0000!  console=true


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Align_ALD_type_for_delta_plan_for_detected_ALD


TC Teardown
    Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown
