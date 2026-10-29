*** Settings ***
Documentation
    ...  Open Commissioning Wizard menu and verify if the page is fully loaded.
    ...  Create delta plan.
    ...  Clone first NR cell with existing group, on the same group and with checkbox selected.
    ...  Verify if PDL errors are visible.
    ...  Verify if the cell was cloned on the right RMOD and group.
    ...  Delete cloned cell.
    ...  On the same group maximum number of cells is 8. Clone as many cells to the maximum number.
    ...  When 8 cells are created, clone function on the same group is not possible anymore.
    ...  Verify nrcellid, nrcellList and lcrid parameters from parameter editor.
    ...  Clone first NR cell with existing group and on another NRCELLGRP without selecting the checkbox.
    ...  Verify if PDL errors are visible.
    ...  If the BTS has only one group, the test will be adding another one.
    ...  If the BTS has more than 1 group, test will continue without adding another one.
    ...  Clone first NR cell on new group and verify refNrCellGroup from parameter editor.
    ...  Verify if PDL errors are visible.
    ...  Delete created delta plan

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${MAX_NUMBER_OF_CELLS}  8  # Number of maximum cells that can be added on the same NRCELLGRP


*** Keywords ***
TC__WebEM__vDU__CW_Step_by_Step_view_clone_NR_cell
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26387
    ...
    ...  ******************
    ...  - 24.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26387 - Initial TAT creation
    ...  - 26.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27640 - Adding sleep and wait until KW succeeds
    ...  - 29.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28453 - Delete xpath was changed
    ...  - 04.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28700 - Comparasion correction for nrcellid and lcrid
    ...  - 27.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28925 - Additional check for PDL errors

    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-vDU24  FEATURE-CB005866-A

    Step1: Open Commissioning Wizard Menu
    Step2: Select Create Plan
    Step3: Clone First NR Cell With Existing Group And On The Same NRCELLGRP
    Step4: Add 8 NR Cell On First NRCELLGRP And Try To Clone Again One NR Cell On The Same NRCELLGRP
    Step5: Verify NrCellId , NrCellList And Lcrid Parameters From Parameter Editor
    Step6: Clone First NR Cell With Existing Group And On Another NRCELLGRP Without Selecting The Checkbox
    Step7: Clone First NR Cell On New Group And Verify RefNrCellGroup
    Step8: Delete Created Plan


Step1: Open Commissioning Wizard Menu
    Log  \nStep1: Open Commissioning Wizard menu  console=true
    Open Commissioning Wizard


Step2: Select Create Plan
    Log  \nStep2: Select Create plan  console=true
    Create Duplicate Plan For CBTS


Step3: Clone First NR Cell With Existing Group And On The Same NRCELLGRP
    Log  \nStep3: Clone first NR cell with existing group and on the same NRCELLGRP  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, "NR Cell and Cell Mapping")]
    Log  Choosing first nrcell from the first RMOD!  console=true
    Set Nr Cell Id And Nrcell Group Id Depends On First RMOD
    Log  NRCELL-${CELL_ID} on NRCELLGRP-${CELL_GROUP_ID} and with technology ${CELL_TECHNOLOGY} was chosen!  console=true
    Log  Clone NRCELL-${CELL_ID} with existing group and on the same NRCELLGRP!  console=true
    Clone Nr Cell With Existing Group And On The Same NRCELLGRP  ${CELL_ID}  ${CELL_GROUP_ID}
    ${cloned_cell_id}  Verify If NR Cell With Existing Group And On The Same Group Was Cloned On Right HW
    Wait Until Element Is Clicked
    ...  //*[contains(@aria-label, "${CELL_TECHNOLOGY}${SPACE}NRCELL-${cloned_cell_id}")]/span/span/div/div[2]/p-button[3]/button/span[1]
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span
    Wait Until Keyword Succeeds  30  5
    ...  Element Should Not Be Visible  //*[contains(@aria-label, "${CELL_TECHNOLOGY}${SPACE}NRCELL-${cloned_cell_id}")]


Step4: Add 8 NR Cell On First NRCELLGRP And Try To Clone Again One NR Cell On The Same NRCELLGRP
    Log  \nStep4: Add 8 NR cell on first NRCELLGRP and try to clone again one NR cell on the same NRCELLGRP  console=true
    ${nrcell_list_from_first_nrcellgrp}  ${nr_cell_group_id}  Get List Of Nr Cells From The First Group
    ${list_length}  Get Length  ${nrcell_list_from_first_nrcellgrp}
    ${cloned_cell_id}  Get From List  ${nrcell_list_from_first_nrcellgrp}  0
    ${number_of_cells_to_be_cloned}  Evaluate  ${MAX_NUMBER_OF_CELLS} - ${list_length}
    Set Test Variable  ${NUMBER_OF_CELLS_TO_BE_CLONED}
    FOR  ${number}  IN RANGE  1  ${NUMBER_OF_CELLS_TO_BE_CLONED}+1
        Clone Nr Cell With Existing Group And On The Same NRCELLGRP  ${cloned_cell_id}  ${nr_cell_group_id}
        IF  ${number} == ${NUMBER_OF_CELLS_TO_BE_CLONED}+1
        ...  Verify If Clone Nr Cell With Existing Group And On The Same NRCELLGRP Is Not Possible  ${cloned_cell_id}  ${nr_cell_group_id}
    END
    Save Plan


Step5: Verify NrCellId , NrCellList And Lcrid Parameters From Parameter Editor
    Log  \nStep5: Verify nrCellId , nrCellList and lcrid parameters from parameter editor  console=true
    ${nr_cells_id}  Get List Of Nr Cells Id
    ${list_length}  Get Length  ${nr_cells_id}
    ${total_nr_cells}  Evaluate  ${NUMBER_OF_CELLS_TO_BE_CLONED} + ${list_length}
    ${nrcell_list_from_first_nrcellgrp}  ${nr_cell_group_id}  Get List Of Nr Cells From The First Group
    ${list_length}  Get Length  ${nrcell_list_from_first_nrcellgrp}
    ${total_nr_cells_on_first_group}  Evaluate  ${NUMBER_OF_CELLS_TO_BE_CLONED} + ${list_length}
    Log  Open Parameter Editor  console=true
    Wait Until Element Is Clicked  //*[@id="/parameter-editor"]
    Log  Verify nrCellId parameter!  console=true
    Sleep  30s  Time for page to be uploaded.
    Wait Until Element Is Clicked
    ...  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/blocks-validation-errors/p-tabview/div/div[1]/p-button/button/span[1]
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  nrCellId
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div  ENTER
    Sleep  10s  Time for page to be loaded.
    ${trs_pe}  SeleniumLibrary.Get Element Count  //*[contains(@class, 'p-element p-treetable-tbody')]/tr
    ${nr_cell_id_number}  Evaluate  ${trs_pe} // 2
    Should Be Equal  ${nr_cell_id_number}  ${total_nr_cells}  Parameter nrCellId is not visible for all created and existing nr cells![NOK]
    Log  Parameter nrCellId is visible for all created and existing nr cells![OK]  console=true
    Log  Verify nrCellList parameter!  console=true
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  nrCellList
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div  ENTER
    Sleep  10s  Time for page to be loaded.
    ${trs_pe}  SeleniumLibrary.Get Element Count  //*[contains(@class, 'p-element p-treetable-tbody')]/tr
    ${nr_cell_groups}  Get List Of NRCELLGRP Ids
    ${nrcells_pe}  Evaluate  ${trs_pe} - len(${nr_cell_groups})
    Should Be Equal  ${nrcells_pe}  ${total_nr_cells}  Parameter nrCellList is not visible for all created and existing nr cells![NOK]
    Log  Parameter nrCellList is visible for all created and existing nr cells![OK]  console=true
    Log  Verify lcrId parameter!  console=true
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  lcrId
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div  ENTER
    Sleep  10s  Time for page to be loaded.
    ${lcrid_pe}  SeleniumLibrary.Get Element Count  //*[contains(@class, 'p-element p-treetable-tbody')]/tr
    Should Be Equal  ${lcrid_pe}  ${total_nr_cells}  Parameter lcrId is not visible for all created and existing nr cells![NOK]
    Log  Parameter lcrId is visible for all created and existing nr cells![OK]  console=true
    Wait Until Element Is Clicked  //*[@id="/commissioning-wizard"]  120
    Sleep  30s  Time for page to be loaded.
    Delete Actual Plan Via WebEM
    Create Duplicate Plan For CBTS


Step6: Clone First NR Cell With Existing Group And On Another NRCELLGRP Without Selecting The Checkbox
    Log  \nStep6: Clone first NR cell with existing group and on another NRCELLGRP without selecting the checkbox  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, "NR Cell and Cell Mapping")]
    ${nrcellgrp_ids_list}  Get List Of NRCELLGRP Ids
    ${nrcellgrp_length}  Get Length  ${nrcellgrp_ids_list}
    IF  ${nrcellgrp_length} == 1
      ${cell_group_id}  Adding A New Group And Get The Id
    ELSE
      Remove Values From List  ${nrcellgrp_ids_list}  ${CELL_GROUP_ID}
      ${cell_group_id}  Remove From List  ${nrcellgrp_ids_list}  0
    END
    Log  Choosing first nrcell from the first RMOD!  console=true
    Log  NRCELL-${CELL_ID} with technology ${CELL_TECHNOLOGY} was chosen!  console=true
    Log  Clone NRCELL-${CELL_ID} with existing group and on another NRCELLGRP!  console=true
    Wait Until Element Is Clicked
    ...  //*[contains(@aria-label, "${CELL_TECHNOLOGY}${SPACE}NRCELL-${CELL_ID}")]/span/span/div/div[2]/p-button[2]/button/span[1]
    Wait Until Element Is Clicked  //*[@id="cloneCell"]/p-dialog/div/div/div[2]/div/div[1]/div/div[1]/div[1]/p-radiobutton/div/div[2]
    Log  Existing group was chosen!  console=true
    Wait Until Element Is Clicked  //*[@id="cloneCell"]/p-dialog/div/div/div[2]/div/div[1]/div/div[1]/div[2]/p-dropdown/div
    Wait Until Element Is Clicked  //*[contains(@aria-label, "NRCELLGRP-${cell_group_id}")]
    Log  Another cell group was chosen, NRCELLGRP-${cell_group_id}!  console=true
    Log  Checkbox for clone cell mapping was not chosen!  console=true
    Wait Until Element Is Clicked  //*[@id="cloneCell"]/p-dialog/div/div/div[3]/ot-footer/cem-operation-button/div/p-button/button
    Log  Clone NR cell is performing!  console=true
    Sleep  30s  Time for page to be uploaded.
    Log  Check if any PDL error is visible!  console=true
    Element Should Not Be Visible  //i[contains(@class, "p-element oi oi-error p-clickable")]
    Log  PDL errors are not visible after clone operation![OK]  console=true
    ${cloned_cell_id}  Verify If NR Cell With Existing Group And On Another Group Was Cloned On Right HW  ${cell_group_id}
    Click Element  //*[contains(@class, "flex flex-column ng-star-inserted")]/cem-cell-group-widget[2]/div/div[2]/div[2]/p-button/button/span[1]
    Run Keyword And Ignore Error
    ...  Wait Until Element Is Visible  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span  120
    Run Keyword And Ignore Error
    ...  Click Element  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span
    Run Keyword And Ignore Error
    ...  Click Element  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span
    Wait Until Element Is Clicked  //*[contains(@aria-label, "NR Cell and Cell Mapping")]
    Run Keyword And Ignore Error
    ...  Wait Until Element Is Visible  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span  120
    Run Keyword And Ignore Error
    ...  Click Element  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span
    Delete Actual Plan Via WebEM
    Create Duplicate Plan For CBTS


Step7: Clone First NR Cell On New Group And Verify RefNrCellGroup
    Log  \nStep7: Clone first NR cell on new group and verify refNrCellGroup  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, "NR Cell and Cell Mapping")]
    Log  Clone NRCELL-${CELL_ID} on a new NRCELLGRP!  console=true
    Wait Until Element Is Clicked
    ...  //*[contains(@aria-label, "${CELL_TECHNOLOGY}${SPACE}NRCELL-${CELL_ID}")]/span/span/div/div[2]/p-button[2]/button/span[1]
    Wait Until Element Is Clicked  //*[@id="cloneCell"]/p-dialog/div/div/div[2]/div/div[1]/div/div[2]/div/p-radiobutton/div/div[2]
    Log  New group was chosen!  console=true
    Wait Until Element Is Clicked  //*[@id="cloneCell"]/p-dialog/div/div/div[2]/div/div[2]/div/p-checkbox/div/div[2]
    Log  Checkbox for clone cell mapping was chosen!  console=true
    Wait Until Element Is Clicked  //*[@id="cloneCell"]/p-dialog/div/div/div[3]/ot-footer/cem-operation-button/div/p-button/button
    Sleep  30s  Time for page to be uploaded.
    Log  Check if any PDL error is visible!  console=true
    Element Should Not Be Visible  //i[contains(@class, "p-element oi oi-error p-clickable")]
    Log  PDL errors are not visible after clone operation![OK]  console=true
    Log  Clone NR cell is performing!  console=true
    Verify If NR Cell Was Cloned On A New NRCELLGRP And On Right HW
    Save Plan
    Log  Open Parameter Editor to verify refNrCellGroup  console=true
    ${nr_cell_groups_list}  Get List Of NRCELLGRP Ids
    ${cloned_group_id}  Get Cloned NRCELLGRP Id
    Append To List  ${nr_cell_groups_list}  ${cloned_group_id}
    ${length}  Get Length  ${nr_cell_groups_list}
    Wait Until Element Is Clicked  //*[@id="/parameter-editor"]
    Wait Until Element Is Clicked
    ...  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/blocks-validation-errors/p-tabview/div/div[1]/p-button/button/span[1]
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  refNrCellGroup
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div  ENTER
    Sleep  10s  Time for page to be updated
    ${trs_pe}  SeleniumLibrary.Get Element Count  //*[contains(@class, 'p-element p-treetable-tbody')]/tr
    ${nrcellgrps_pe}  Evaluate  ${trs_pe} - 1
    IF  ${length} == ${nrcellgrps_pe}
      Log  refNrCellGroup is corect![OK]  console=true
    ELSE
      Fail  refNrCellGroup is not corect![NOK]
    END
    Wait Until Element Is Clicked  //*[@id="/commissioning-wizard"]  120
    Wait Until Element Is Clicked  //*[contains(@aria-label, "NR Cell and Cell Mapping")]  300


Step8: Delete Created Plan
    Log  \nStep8: Delete created plan  console=true
    Delete Actual Plan Via WebEM


Adding A New Group And Get The Id
    Sleep  30s  Time for page to be uploaded.
    Click Element  //*[@id="laf-component"]/div[2]/blocks-cell-groups/cem-site-view-label-panel/div[1]/button/span[1]
    ${new_group_name}  Get Text  //*[contains(@class, "flex flex-column ng-star-inserted")]/cem-cell-group-widget[2]
    ${group_id}  Fetch From Right  ${new_group_name}  -
    Wait Until Element Is Clicked  //*[contains(@aria-label, "NR Cell and Cell Mapping")]
    Run Keyword And Ignore Error
    ...  Wait Until Element Is Visible  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span  120
    Run Keyword And Ignore Error
    ...  Click Element  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span

    [Return]  ${group_id}


Clone Nr Cell With Existing Group And On The Same NRCELLGRP
    [Arguments]  ${cell_id}  ${cell_group_id}

    Click Element  //*[contains(@aria-label, "${CELL_TECHNOLOGY}${SPACE}NRCELL-${cell_id}")]/span/span/div/div[2]/p-button[2]/button/span[1]
    Click Element  //*[@id="cloneCell"]/p-dialog/div/div/div[2]/div/div[1]/div/div[1]/div[1]/p-radiobutton/div/div[2]
    Log  Existing group was chosen!  console=true
    Click Element  //*[@id="cloneCell"]/p-dialog/div/div/div[2]/div/div[1]/div/div[1]/div[2]/p-dropdown/div
    Click Element  //*[contains(@aria-label, "NRCELLGRP-${cell_group_id} (same cell group)")]
    Log  The same cell group was chosen!  console=true
    Wait Until Element Is Clicked  //*[@id="cloneCell"]/p-dialog/div/div/div[2]/div/div[2]/div/p-checkbox/div/div[2]
    Log  Checkbox for clone cell mapping was chosen!  console=true
    Wait Until Element Is Clicked  //*[@id="cloneCell"]/p-dialog/div/div/div[3]/ot-footer/cem-operation-button/div/p-button/button
    Log  Clone NR cell is performing!  console=true
    Sleep  30s  Time for page to be uploaded.
    Log  Check if any PDL error is visible!  console=true
    Element Should Not Be Visible  //i[contains(@class, "p-element oi oi-error p-clickable")]
    Log  PDL errors are not visible after clone operation![OK]  console=true


Verify If Clone Nr Cell With Existing Group And On The Same NRCELLGRP Is Not Possible
    [Arguments]  ${cell_id}  ${cell_group_id}

    Click Element  //*[contains(@aria-label, "${CELL_TECHNOLOGY}${SPACE}NRCELL-${cell_id}")]/span/span/div/div[2]/p-button[2]/button/span[1]
    Click Element  //*[@id="cloneCell"]/p-dialog/div/div/div[2]/div/div[1]/div/div[1]/div[1]/p-radiobutton/div/div[2]
    Log  Existing group was chosen!  console=true
    Click Element  //*[@id="cloneCell"]/p-dialog/div/div/div[2]/div/div[1]/div/div[1]/div[2]/p-dropdown/div
    Element Should Not Be Visible  //*[contains(@aria-label, "NRCELLGRP-${cell_group_id} (same cell group)")]
    Log  Is not possible anymore to choose the same group because number of maximum cells on group is reached!  console=true
    Click Element  //*[@id="cloneCell"]/p-dialog/div/div/div[3]/ot-footer/p-button/button


Get List Of Nr Cells From The First Group
    ${nr_cells_id_list_from_first_group}  Create List
    ${nr_cells_groups_list}  Get List Of NRCELLGRP Ids
    ${first_nr_cell_group_id}  Get From List  ${nr_cells_groups_list}  0
    ${cells_statuses}  vdu.Get Vdu Cells Status
    FOR  ${cell}  IN  @{cells_statuses}
        IF  ${cell}[cell_group_id] == ${first_nr_cell_group_id}
          Append To List  ${nr_cells_id_list_from_first_group}  ${cell}[id]
        ELSE
          CONTINUE
        END
    END

    [Return]  ${nr_cells_id_list_from_first_group}  ${first_nr_cell_group_id}


Verify If NR Cell With Existing Group And On The Same Group Was Cloned On Right HW
    Log  Verify if NR cell with existing group and on the same group was cloned on right HW!  console=true
    ${cloned_cell_id}  ${dist_name}  Get Cloned Cell Id And Dist Name
    Wait Until Keyword Succeeds  30  5
    ...  Element Should Be Visible  //*[contains(@aria-label, "${CELL_TECHNOLOGY}${SPACE}NRCELL-${cloned_cell_id}")]
    Wait Until Element Is Clicked  //*[@id="${dist_name}NRCELL-${cloned_cell_id}"]
    Log  Verify highlighted Radio Module from site view when the cell is selected from site view!  console=true
    ${rmod_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1"]/ot-card  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${rmod_class}
    ...  highlighted  Radio Module RMOD-1 was not highlighted after NRCELL-${cloned_cell_id} was selected from site view!
    Log  Radio Module RMOD-1 was highlighted after NRCELL-${cloned_cell_id} was selected from site view!  console=true
    Log  Verify highlighted NRCELLGRP from site view when the cell is selected from site view!  console=true
    ${group_class}  Get Element Attribute  //*[@id="${dist_name}NRCELLGRP-${CELL_GROUP_ID}"]/div  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${group_class}
    ...  highlighted
    ...  NRCELLGRP-${CELL_GROUP_ID} was not highlighted after NRCELL-${cloned_cell_id} was selected from site view!
    Log  NRCELLGRP-${CELL_GROUP_ID} was highlighted after NRCELL-${cloned_cell_id} was selected from site view!  console=true

    [Return]  ${cloned_cell_id}


Verify If NR Cell Was Cloned On A New NRCELLGRP And On Right HW
    Log  Verify if NR cell was cloned on a new NRCELLGRP and on right HW  console=true
    ${cloned_cell_id}  ${dist_name}  Get Cloned Cell Id And Dist Name
    ${cloned_group_id}  Get Cloned NRCELLGRP Id
    Wait Until Keyword Succeeds  30  5
    ...  Element Should Be Visible  //*[contains(@aria-label, "${CELL_TECHNOLOGY}${SPACE}NRCELL-${cloned_cell_id}")]
    Wait Until Element Is Clicked  //*[@id="${dist_name}NRCELL-${cloned_cell_id}"]
    Log  Verify highlighted Radio Module from site view when the cell is selected from site view!  console=true
    ${rmod_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1"]/ot-card  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${rmod_class}
    ...  highlighted  Radio Module RMOD-1 was not highlighted after NRCELL-${cloned_cell_id} was selected from site view!
    Log  Radio Module RMOD-1 was highlighted after NRCELL-${cloned_cell_id} was selected from site view!  console=true
    Log  Verify highlighted NRCELLGRP from site view when the cell is selected from site view!  console=true
    ${group_class}  Get Element Attribute  //*[@id="${dist_name}NRCELLGRP-${cloned_group_id}"]/div  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${group_class}
    ...  highlighted
    ...  NRCELLGRP-${cloned_group_id} was not highlighted after NRCELL-${cloned_cell_id} was selected from site view!
    Log  NRCELLGRP-${cloned_group_id} was highlighted after NRCELL-${cloned_cell_id} was selected from site view!  console=true


Verify If NR Cell With Existing Group And On Another Group Was Cloned On Right HW
    [Arguments]  ${existing_cell_group_id}

    Log  Verify if NR cell with existing group and on another group was cloned on right HW  console=true
    ${cloned_cell_id}  ${dist_name}  Get Cloned Cell Id And Dist Name
    Wait Until Keyword Succeeds  30  5
    ...  Element Should Be Visible  //*[contains(@aria-label, "${CELL_TECHNOLOGY}${SPACE}NRCELL-${cloned_cell_id}")]
    Element Should Not Be Visible  //*[@id="${dist_name}NRCELL-${cloned_cell_id}"]
    Element Should Be Visible  //*[contains(text(), "No valid cell mappings")]
    Log  No valid cell mappings is visible on CW page in NR Cell tab!  console=true
    Click Element  //*[contains(text(), "No valid cell mappings")]
    Element Should Be Visible  //*[@id="${dist_name}NRCELL-${cloned_cell_id}"]
    Log  NRCELL-${cloned_cell_id} is visible on No valid cell mappings tab!  console=true
    Click Element  //*[@id="${dist_name}NRCELL-${cloned_cell_id}"]
    Sleep  10s
    Log  Verify highlighted NRCELLGRP from site view when the cell is selected from site view!  console=true
    ${group_class}  Get Element Attribute  //*[@id="${dist_name}NRCELLGRP-${existing_cell_group_id}"]/div  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${group_class}
    ...  highlighted
    ...  NRCELLGRP-${existing_cell_group_id} was not highlighted after NRCELL-${cloned_cell_id} was selected from site view!
    Log  NRCELLGRP-${existing_cell_group_id} was highlighted after NRCELL-${cloned_cell_id} was selected from site view!  console=true

    [Return]  ${cloned_cell_id}


Get Cloned Cell Id And Dist Name
    ${nr_cells_id_list}  Get List Of Nr Cells Id
    Sort List  ${nr_cells_id_list}
    ${length}  Get Length  ${nr_cells_id_list}
    IF  ${length} > 1
      ${last_cell_id}  Remove From List  ${nr_cells_id_list}  -1
    ELSE
      ${last_cell_id}  Set Variable  ${nr_cells_id_list}[0]
    END
    ${value}  Run Keyword And Return Status
    ...  List Should Not Contain Value  ${nr_cells_id_list}  0
    IF  ${value}
      ${cloned_cell_id}  Set Variable  0
    ELSE
      ${cloned_cell_id}  Evaluate  ${last_cell_id} + 1
    END
    ${dist_name}  Fetch From Left  ${CONFIG_CELL}  NRCELL-

    [Return]  ${cloned_cell_id}  ${dist_name}


Get Cloned NRCELLGRP Id
    ${nr_cells_group_list}  Get List Of NRCELLGRP Ids
    ${length}  Get Length  ${nr_cells_group_list}
    IF  ${length} > 1
      ${last_group_id}  Remove From List  ${nr_cells_group_list}  -1
    ELSE
      ${last_group_id}  Set Variable  ${nr_cells_group_list}[0]
    END
    ${value}  Run Keyword And Return Status
    ...  List Should Not Contain Value  ${nr_cells_group_list}  0
    IF  ${value}
      ${cloned_group_id}  Set Variable  0
    ELSE
      ${cloned_group_id}  Evaluate  ${last_group_id} + 1
    END

    [Return]  ${cloned_group_id}


Save Plan
    Wait Until Element Is Clicked  //*[@id="save-btn"]
    Log  Saving plan is ongoing...  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, "NR Cell and Cell Mapping")]  300
    Element Should Be Disabled  //*[@id="save-btn"]
    Log  The plan is saved successfully!  console=true


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Step_by_Step_view_clone_NR_cell


TC Teardown
    Run Keyword If Test Failed
    ...  Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown
