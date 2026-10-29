*** Settings ***
Documentation
    ...  Open Commissioning Wizard menu and verify if the page is fully loaded.
    ...  Select Create delta plan.
    ...  Add new NRCELLGRP from site view CW and verify if it is visible.
    ...  Verify the specific parameters.
    ...  Add new NRCELLGRP from step-by-step CW and verify if it is visible.
    ...  Verify the specific parameters.
    ...  Verify refNrCellGroup parameter from Parameter Editor.
    ...  Delete created NRCELLGRPs.
    ...  Verify highlighted cell when first NRCELLGRP is selected.
    ...  Verify highlighted NRCELLGRP when cell is selected.
    ...  Delete one existing NRCELLGRP and verify if cell is deleted too.
    ...  Delete created delta plan.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${FIRST_CLONED_GROUP_ID}  0  # Mandatory! Id from the first cloned nrcellgroup.
${SECOND_CLONED_GROUP_ID}  1  # Mandatory! Id from the second cloned nrcellgroup.


*** Keywords ***
TC__WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell_group
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26386
    ...
    ...  ******************
    ...  - 07.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26386 - Initial TAT creation
    ...  - 01.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27639 - Many xpaths was changed
    ...  - 06.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27871 - Changes for cloned nrcellgroups
    ...  - 29.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28453 - Delete xpath was changed
    ...  - 03.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28957 - Xpath was changed for deleting NRCELLGRPs
    ...  - 06.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29246 - Save plan before checking the parameters for CB013033

    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  SW-vDU24  FEATURE-CB005866-A

    Step1: Open Commissioning Wizard
    Step2: Create Plan
    Step3: Add New NRCELLGRP From Site View CW And Verify If It Is Visible
    Step4: Add New NRCELLGRP From Step-by-step CW And Verify If It Is Visible
    Step5: Verify RefNrCellGroup Parameter From Parameter Editor
    Step6: Delete Created NRCELLGRPs
    Step7: Verify Highlighted Cell When NRCELLGRP Is Selected
    Step8: Verify Highlighted NRCELLGRP When Cell Is Selected
    Step9: Delete One Existing NRCELLGRP And Verify If Cell Is Deleted Too
    Step10: Delete Created Plan


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Open Commissioning Wizard


Step2: Create Plan
    Log  \nStep2: Create plan  console=true
    Create Duplicate Plan For CBTS


Step3: Add New NRCELLGRP From Site View CW And Verify If It Is Visible
    Log  \nStep3: Add new NRCELLGRP from site view CW and verify if it is visible  console=true
    Click Element  //*[@id="laf-component"]/div[2]/blocks-cell-groups/cem-site-view-label-panel/div[1]/button/span[1]
    Sleep  5s  Time for nrcellgroup to appear in CW
    Wait Until Element Is Clicked  //*[@id="save-btn"]
    Log  Saving plan is ongoing...  console=true
    Sleep  20s  Time for the plan to be saved
    Element Should Be Disabled  //*[@id="save-btn"]
    Log  The plan is saved successfully!  console=true
    Set Selenium Speed  0.2
    Verify If The NRCELLGRP Was Created And Check The Parameters  ${FIRST_CLONED_GROUP_ID}  ${VDU_MRBTS_ID}  ${VDU_NRBTS_ID}
    Set Selenium Speed  1


Step4: Add New NRCELLGRP From Step-by-step CW And Verify If It Is Visible
    Log  \nStep4: Add new NRCELLGRP from step-by-step CW and verify if it is visible  console=true
    Click Element  //*[contains(@class, "mdi mdi-plus-thick p-button-icon ng-star-inserted")]
    Sleep  5s  Time for nrcellgroup to appear in CW
    Wait Until Element Is Clicked  //*[@id="save-btn"]
    Log  Saving plan is ongoing...  console=true
    Sleep  20s  Time for the plan to be saved
    Element Should Be Disabled  //*[@id="save-btn"]
    Log  The plan is saved successfully!  console=true
    Set Selenium Speed  0.3
    Verify If The NRCELLGRP Was Created And Check The Parameters  ${SECOND_CLONED_GROUP_ID}  ${VDU_MRBTS_ID}  ${VDU_NRBTS_ID}
    Set Selenium Speed  1


Step5: Verify RefNrCellGroup Parameter From Parameter Editor
    Log  \nStep5: Verify refNrCellGroup parameter from Parameter Editor  console=true
    Save Plan From Commissioning Wizard
    Log  Open Parameter Editor to verify refNrCellGroup  console=true
    ${nr_cell_groups_list}  Get List Of NRCELLGRP Ids
    ${length}  Get Length  ${nr_cell_groups_list}
    ${nr_cell_groups}  Evaluate  ${length} + 2
    Wait Until Element Is Clicked  //*[@id="/parameter-editor"]
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  refNrCellGroup
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  ENTER
    Sleep  5s  Time for page to be updated
    ${trs_pe}  SeleniumLibrary.Get Element Count  //*[contains(@class, 'p-element p-treetable-tbody')]/tr
    ${nrcellgrps_pe}  Evaluate  ${trs_pe} - 1
    Run Keyword If  ${nr_cell_groups} == ${nrcellgrps_pe}
    ...  Log  All NRCELLGRPs are visible![OK]  console=true
    ...  ELSE
    ...  Fail  Not all NRCELLGRPs are visible![NOK]
    Click Element  //*[@id="/commissioning-wizard"]
    Wait Until Element Is Clicked  //*[contains(@aria-label, "NR Cell Group Settings")]  300


Step6: Delete Created NRCELLGRPs
    Log  \nStep6: Delete created NRCELLGRPs  console=true
    Log  Delete the first cloned NRCELLGRP  console=true
    ${delete_button_first_clone}  Set Variable If  '${VDU_ACTIVE_SW_RELEASE}' == 'vDUCNF25R2'
    ...  //*[contains(@aria-label, "NRCELLGRP-${FIRST_CLONED_GROUP_ID}")]/span/span/div/div[2]/p-button/button/span[1]
    ...  //*[contains(@aria-label, "NRCELLGRP-${FIRST_CLONED_GROUP_ID}")]/span/span/div/div[2]/p-button[2]/button/span[1]
    Click Element  ${delete_button_first_clone}
    Sleep  10s  Time for the element to not be visible anymore.
    Element Should Not Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELLGRP-${FIRST_CLONED_GROUP_ID}"]
    Log  Delete the second cloned NRCELLGRP  console=true
    ${delete_button_second_clone}  Set Variable If  '${VDU_ACTIVE_SW_RELEASE}' == 'vDUCNF25R2'
    ...  //*[contains(@aria-label, "NRCELLGRP-${SECOND_CLONED_GROUP_ID}")]/span/span/div/div[2]/p-button/button/span[1]
    ...  //*[contains(@aria-label, "NRCELLGRP-${SECOND_CLONED_GROUP_ID}")]/span/span/div/div[2]/p-button[2]/button/span[1]
    Click Element  ${delete_button_second_clone}
    Sleep  10s  Time for the element to not be visible anymore.
    Element Should Not Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELLGRP-${SECOND_CLONED_GROUP_ID}"]


Step7: Verify Highlighted Cell When NRCELLGRP Is Selected
    Log  \nStep7: Verify highlighted cell when NRCELLGRP is selected  console=true
    ${nr_cells_group_list}  Get List Of NRCELLGRP Ids
    ${first_existing_nrcellgrp}  Get From List  ${nr_cells_group_list}  0
    Set Test Variable  ${FIRST_EXISTING_NRCELLGRP}
    ${cells_statuses}  vdu.Get Vdu Cells Status
    FOR  ${cell}  IN  @{cells_statuses}
        ${cell_status}  Run Keyword And Return Status
        ...  Should Contain  ${cell}[cell_group_id]  ${FIRST_EXISTING_NRCELLGRP}
        Run Keyword If  ${cell_status}
        ...  Run Keywords
        ...  Set Test Variable  ${CELL_NAME}  ${cell}[name]
        ...  AND
        ...  Exit For Loop
    END
    Click Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELLGRP-${FIRST_EXISTING_NRCELLGRP}"]
    ${group_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/${CELL_NAME}"]/div  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${group_class}
    ...  highlighted
    ...  ${CELL_NAME} was not highlighted after NRCELLGRP-${FIRST_EXISTING_NRCELLGRP} was selected from site view!
    Log  ${CELL_NAME} was highlighted after NRCELLGRP-${FIRST_EXISTING_NRCELLGRP} was selected from site view!  console=true


Step8: Verify Highlighted NRCELLGRP When Cell Is Selected
    Log  \nStep8: Verify highlighted NRCELLGRP when cell is selected  console=true
    Click Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/${CELL_NAME}"]
    ${group_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELLGRP-${FIRST_EXISTING_NRCELLGRP}"]/div  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${group_class}
    ...  highlighted
    ...  NRCELLGRP-${FIRST_EXISTING_NRCELLGRP} was not highlighted after ${CELL_NAME} was selected from site view!
    Log  NRCELLGRP-${FIRST_EXISTING_NRCELLGRP} was highlighted after ${CELL_NAME} was selected from site view!  console=true


Step9: Delete One Existing NRCELLGRP And Verify If Cell Is Deleted Too
    Log  \nStep9: Delete one existing NRCELLGRP and verify if cell is deleted too  console=true
    Click Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELLGRP-${FIRST_EXISTING_NRCELLGRP}"]/div/div[2]/div[2]/p-button/button
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain  Do you want to delete NRCELLGRP-${FIRST_EXISTING_NRCELLGRP}?
    Click Element  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span
    Element Should Not Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELLGRP-${FIRST_EXISTING_NRCELLGRP}"]
    Log  NRGELLGRP-${FIRST_EXISTING_NRCELLGRP} was deleted![OK]  console=true
    Element Should Not Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/${CELL_NAME}"]
    Log  ${CELL_NAME} on NRGELLGRP-${FIRST_EXISTING_NRCELLGRP} was deleted too![OK]  console=true


Step10: Delete Created Plan
    Log  \nStep10: Delete created plan  console=true
    Delete Actual Plan Via WebEM


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell_group


TC Teardown
    Run Keyword If Test Failed
    ...  Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown
