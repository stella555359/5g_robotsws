*** Settings ***
Documentation
    ...  Open Commissioning Wizard menu and verify if the page is fully loaded.
    ...  Create delta plan.
    ...  Add one NR cell group.
    ...  Discard changes.
    ...  Add one NR cell group again.
    ...  Try to move in Site View but Saving changes warning is visible.
    ...  Save changes into the plan.
    ...  Move in Site View.
    ...  Open CW again and verify if created NR cell group is still visible.
    ...  Verify if a parameter can be changed.
    ...  Open PE and verify if created NR cell group is visible.
    ...  Delete delta plan.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__Switching_from_CW_to_another_tab_and_come_back
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26785
    ...
    ...  ******************
    ...  - 12.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26785 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  SW-SBTS24  FEATURE-CB005866-E

    Step1: Open Commissioning Wizard And Create Delta Plan
    Step2: Add One NR Cell Group And Discard Changes
    Step3: Move In Site View And Verify The Warning About Saving Changes
    Step4: Open Previously Edited Delta Plan In CW
    Step5: Open Previously Edited Delta Plan In PE


Step1: Open Commissioning Wizard And Create Delta Plan
    Log  \nStep1: Open commissioning wizard and create delta plan  console=true
    Open Commissioning Wizard
    Create Delta Plan For CBTS


Step2: Add One NR Cell Group And Discard Changes
    Log  \nStep2: Add one NR cell group and discard changes  console=true
    Click Element  //*[contains(@aria-label, 'NR Cell Group Settings')]
    Click Element  //*[contains(@class, "mdi mdi-plus-thick p-button-icon ng-star-inserted")]
    Log  NR cell group was added!  console=true
    Discard Plan From Commissioning Wizard
    ${nr_cell_groups_list}  Get List Of NRCELLGRP Ids
    Set Test Variable  ${NR_CELL_GROUPS_LIST}
    Click Element  //*[contains(@aria-label, 'NR Cell Group Settings')]
    Click Element  //*[contains(@class, "mdi mdi-plus-thick p-button-icon ng-star-inserted")]
    Log  NR cell group was added!  console=true
    ${value}  Run Keyword And Return Status
    ...  List Should Not Contain Value  ${NR_CELL_GROUPS_LIST}  0
    ${cloned_nr_group_id}  Run Keyword If  ${value}
    ...  Set Variable  0
    ...  ELSE
    ...  Evaluate  ${NR_CELL_GROUPS_LIST}[-1] + 1
    Set Test Variable  ${CLONED_NR_GROUP_ID}
    Wait Until Keyword Succeeds  30  5
    ...  Element Should Be Visible  //*[contains(@aria-label, "NRCELLGRP-${CLONED_NR_GROUP_ID}")]
    Log  NRCELLGRP-${CLONED_NR_GROUP_ID} was created!  console=true


Step3: Move In Site View And Verify The Warning About Saving Changes
    Log  \nStep3: Move in Site View and verify the warning about saving changes  console=true
    Log  Move into Site View!
    Click Element  ${VDU_SITE_VIEW}
    Wait Until Element Is Visible  //*[contains(text(), "Save warning")]  60
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/button/span
    Wait Until Element Is Clicked  //*[@id="save-btn"]
    Log  Saving plan is ongoing...  console=true
    Sleep  60s  Time for plan to be saved.
    Element Should Be Disabled  //*[@id="save-btn"]
    Log  The plan is saved successfully!  console=true
    Wait Until Element Is Clicked  ${VDU_SITE_VIEW}
    Wait Until Element Is Visible  //span[contains(@class, 'title') and contains(text(), 'Central Unit')]  120


Step4: Open Previously Edited Delta Plan In CW
    Log  \nStep4: Open previously edited delta plan in CW  console=true
    Open Commissioning Wizard
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'NR Cell Group Settings')]
    Wait Until Keyword Succeeds  30  5
    ...  Element Should Be Visible  //*[contains(@aria-label, "NRCELLGRP-${CLONED_NR_GROUP_ID}")]
    Log  Created NRCELLGRP-${CLONED_NR_GROUP_ID} is still visible after changing the tab![OK]  console=true
    Click Element  //*[contains(@aria-label, "NRCELLGRP-${CLONED_NR_GROUP_ID}")]/span[2]/span/div/div[1]
    Sleep  10s
    ${input_field}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody/tr[1]/td[2]
    ...  /cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
    Input Text  ${input_field}  20
    Sleep  5s  Time for the value to be displayed.
    ${input_field_value}  Get Value  ${input_field}
    Run Keyword If  ${input_field_value} == 20
    ...  Log  Plan can be updated after changing the tab![OK]  console=true
    ...  ELSE
    ...  Fail  Plan can not be updated after changing the tab![NOK]
    Save Plan From Commissioning Wizard


Step5: Open Previously Edited Delta Plan In PE
    Log  \nStep5: Open previously edited delta plan in PE  console=true
    Wait Until Element Is Clicked  //*[@id="/parameter-editor"]
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[@id="parameter-search-input"]/div/input  nrCellGrpId
    Click Element  //*[@id="parameter-search-input"]/div/div/i
    Sleep  10s  Time for the page to be uploaded.
    ${count}  SeleniumLibrary.Get Element Count  //*[@id="global-search-table"]/div[2]/p-treetable/div/div[1]/table/tbody/tr
    ${nrcellgroups_number}  Get Length  ${NR_CELL_GROUPS_LIST}
    ${nrcellgroups_number}  Evaluate  ${nrcellgroups_number} + 1
    Run Keyword If  ${count} == ${nrcellgroups_number}
    ...  Log  All NR cell groups are visible, the created one inclusive![OK]  console=true
    ...  ELSE
    ...  Fail  Not all NR cell groups are visible![NOK]
    Wait Until Element Is Clicked  //*[contains(text(), "Commissioning Wizard")]


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__Switching_from_CW_to_another_tab_and_come_back


TC Teardown
    Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown
