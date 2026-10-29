*** Settings ***
Documentation
    ...  Open Commissioning Wizard menu and verify if the page is fully loaded.
    ...  Select Create plan.
    ...  Try to clone one NRCELLGROUP and verify the message box and the two checkboxes.
    ...  Close the pop-up.
    ...  Clone one NRCELLGROUP without any checkboxes selected.
    ...  Verify the specific parameters from step-by-step cloned group to be the same as from the initial nrcellgroup.
    ...  Verify nrCellGrpId and refNrCellGroup in parameter editor to be specific for each nrcellgroup.
    ...  Clone one NRCELLGROUP with checkboxes selected.
    ...  Verify the specific parameters from step-by-step cloned group and cell to be the same as from the initial nrcellgroup and cell.
    ...  Verify nrCellId and lcrId in parameter editor to be specific for each cell.
    ...  Verify Highlighted Cell When NRCELLGRP Is Selected.
    ...  Verify Highlighted NRCELLGRP When Cell Is Selected.
    ...  Delete created plan.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${CLONED_GROUP_ID}  0  # Mandatory! Id from the cloned nrcellgroup.
${CLONED_CELL_ID}  0  # Mandatory! Id from the cloned nrcell.


*** Keywords ***
TC__WebEM__vDU__Clone_NR_Cell_Group_configuration
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28984
    ...
    ...  ******************
    ...  - 16.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28984 - Initial TAT creation
    ...  - 28.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29197 - Save the plan after nrcellgroup was cloned
    ...  - 25.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29762 - Add 'Activate super cell' verification

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-vDU25R3  FEATURE-CB012501

    Step1: Open Commissioning Wizard
    Step2: Create Plan
    Step3: Try To Clone One NRCELLGROUP And Verify The Message Box And The Two Checkboxes
    Step4: Clone One NRCELLGROUP Without Any Checkboxes Selected And Verify The Specific Parameters
    Step5: Verify nrCellGrpId And refNrCellGroup In Parameter Editor
    Step6: Clone One NRCELLGROUP With Checkboxes Selected And Verify The Specific Parameters
    Step7: Verify nrCellId And lcrId In Parameter Editor
    Step8: Verify Highlighted Cell When NRCELLGRP Is Selected
    Step9: Verify Highlighted NRCELLGRP When Cell Is Selected


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Open Commissioning Wizard


Step2: Create Plan
    Log  \nStep2: Create plan  console=true
    Create Duplicate Plan For CBTS


Step3: Try To Clone One NRCELLGROUP And Verify The Message Box And The Two Checkboxes
    Log  \nStep3: Try To Clone One NRCELLGROUP And Verify The Message Box And The Two Checkboxes  console=true
    ${nr_cells_group_list}  Get List Of NRCELLGRP Ids
    ${EXISTED_NRCELL_GROUP}  Get From List  ${nr_cells_group_list}  0
    Set Test Variable  ${EXISTED_NRCELL_GROUP}
    Wait Until Element Is Clicked  //*[contains(@aria-label, "NR Cell Group Settings")]  300
    Input Text  //*[contains(@class, "p-tree-filter-container ng-star-inserted")]/input  ${EXISTED_NRCELL_GROUP}
    Sleep  3s  Time for text to be visible
    Click element  //*[contains(@class, "mdi mdi-content-copy p-button-icon ng-star-inserted")]
    Log  Clone button was pushed![OK]  console=true
    ${dialog_title}  Get Text  //*[@id="laf-component"]/div/div/div[1]/div[1]/span
    Should Be Equal  ${dialog_title}  Do you want to clone NR cell group from NRCELLGRP-${EXISTED_NRCELL_GROUP}?
    Log  Dialog title '${dialog_title}' is visible!  console=true
    Element Should Be Visible  //*[contains(@class, "p-checkbox-label ng-star-inserted") and contains(text(), 'Clone NR cell(s)')]
    Log  Checkbox 'Clone NR cell(s)' is visible and enabled!  console=true
    Element Should Be Visible  //*[contains(@class, "p-checkbox-label ng-star-inserted p-disabled") and contains(text(), 'Clone cell mapping')]
    Log  Checkbox 'Clone cell mapping' is visible and disabled until checkbox 'Clone NR cell(s)' is selected!  console=true
    Click Element  //*[contains(@class, "p-checkbox-label ng-star-inserted") and contains(text(), 'Clone NR cell(s)')]
    Element Should Be Visible  //*[contains(@class, "p-checkbox-label ng-star-inserted") and contains(text(), 'Clone cell mapping')]
    Log  Checkbox 'Clone cell mapping' is visible and enabled because checkbox 'Clone NR cell(s)' is selected!  console=true
    Click Element  //*[contains(@class, "p-checkbox-label ng-star-inserted") and contains(text(), 'Clone cell mapping')]
    Log  Checkbox 'Clone cell mapping' is selected too!  console=true
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/p-button[2]/button/span  60
    Log  Close button was pushed!  console=true


Step4: Clone One NRCELLGROUP Without Any Checkboxes Selected And Verify The Specific Parameters
    Log  \nStep4: Clone One NRCELLGROUP Without Any Checkboxes Selected And Verify The Specific Parameters  console=true
    Click Element  //*[contains(@aria-label, "NRCELLGRP-${EXISTED_NRCELL_GROUP}")]/span/span/div/div[1]/div
    ${values_from_initial_group}  Get The Parameters Value From The NRCELLGROUP
    Click element  //*[contains(@class, "mdi mdi-content-copy p-button-icon ng-star-inserted")]
    Log  Clone button was pushed![OK]  console=true
    ${dialog_title}  Get Text  //*[@id="laf-component"]/div/div/div[1]/div[1]/span
    Should Be Equal  ${dialog_title}  Do you want to clone NR cell group from NRCELLGRP-${EXISTED_NRCELL_GROUP}?
    Log  Dialog title '${dialog_title}' is visible!  console=true
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span  60
    Log  Clone button was pushed without checkboxes selected!  console=true
    Element Should Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELLGRP-${CLONED_GROUP_ID}"]
    Log  The cloned NRCELLGRP-${CLONED_GROUP_ID} is visible on site view!  console=true
    Input Text  //*[contains(@class, "p-tree-filter-container ng-star-inserted")]/input  ${CLONED_GROUP_ID}
    Element Should Be Visible  //*[contains(@aria-label, "NRCELLGRP-${CLONED_GROUP_ID}")]
    Log  The cloned NRCELLGRP-${CLONED_GROUP_ID} is visible on step by step page!  console=true
    Save Plan From Commissioning Wizard
    Wait Until Element Is Clicked  //*[contains(@aria-label, "NR Cell Group Settings")]  300
    Input Text  //*[contains(@class, "p-tree-filter-container ng-star-inserted")]/input  ${CLONED_GROUP_ID}
    Sleep  5s
    Click Element  //*[contains(@aria-label, "NRCELLGRP-${CLONED_GROUP_ID}")]/span/span/div/div[1]/div
    ${values_from_cloned_group}  Get The Parameters Value From The NRCELLGROUP
    Lists Should Be Equal  ${values_from_initial_group}  ${values_from_cloned_group}
    Log  Cloned NR cell group with initial NR cell group parameters values copied!  console=true


Step5: Verify nrCellGrpId And refNrCellGroup In Parameter Editor
    Log  \nStep5: Verify nrCellGrpId And refNrCellGroup In Parameter Editor  console=true
    Save Plan From Commissioning Wizard
    Log  Open Parameter Editor to verify nrCellGrpId and refNrCellGroup  console=true
    ${nr_cell_groups_list}  Get List Of NRCELLGRP Ids
    Append To List  ${nr_cell_groups_list}  ${CLONED_GROUP_ID}
    ${nr_cell_groups_list_length}  Get Length  ${nr_cell_groups_list}
    Wait Until Element Is Clicked  //*[@id="/parameter-editor"]
    Log  Verify nrCellGrpId  console=true
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  nrCellGrpId
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  ENTER
    Sleep  5s  Time for page to be updated
    ${trs_pe}  SeleniumLibrary.Get Element Count  //*[contains(@class, 'p-element p-treetable-tbody')]/tr
    IF  ${nr_cell_groups_list_length} == ${trs_pe}
        Log  All NRCELLGRPs are visible![OK]  console=true
    ELSE
        Fail  Not all NRCELLGRPs are visible![NOK]
    END
    ${nr_cell_groups_from_pe}  Create List
    FOR  ${row}  IN RANGE  1  ${trs_pe}+1
        ${nrcell_group_id_xpath}  Catenate  SEPARATOR=  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[${row}]/td[4]/cem-parameter-input
        ...  /cem-instance-id-input/ot-field/div/ot-input-number/span/input
        ${nrcell_group_id}  Get Value  ${nrcell_group_id_xpath}
        Append To List  ${nr_cell_groups_from_pe}  ${nrcell_group_id}
    END
    Sort List  ${nr_cell_groups_list}
    Sort List  ${nr_cell_groups_from_pe}
    Lists Should Be Equal  ${nr_cell_groups_list}  ${nr_cell_groups_from_pe}
    Log  nrCellGrpId from the actual nrcell group was not be copied for the new cell group!  console=true
    Log  Parameter nrCellGrpId values from PE are: ${nr_cell_groups_from_pe}  console=true
    Log  Verify refNrCellGroup  console=true
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  refNrCellGroup
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  ENTER
    Sleep  5s  Time for page to be updated
    ${trs_pe}  SeleniumLibrary.Get Element Count  //*[contains(@class, 'p-element p-treetable-tbody')]/tr
    ${nrcellgrps_pe}  Evaluate  ${trs_pe} - 1
    IF  ${nr_cell_groups_list_length} == ${nrcellgrps_pe}
        Log  All NRCELLGRPs are visible![OK]  console=true
    ELSE
        Fail  Not all NRCELLGRPs are visible![NOK]
    END
    ${refNrCellGroup_from_pe}  Create List
    FOR  ${row}  IN RANGE  2  ${trs_pe}+1
        ${nrcell_group_id}  Get Value
        ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[${row}]/td[4]/cem-parameter-input/cem-string-input/ot-field/div/input
        Append To List  ${refNrCellGroup_from_pe}  ${nrcell_group_id}
    END
    Sort List  ${refNrCellGroup_from_pe}
    Lists Should Be Equal  ${nr_cell_groups_list}  ${refNrCellGroup_from_pe}
    Log  refNrCellGroup from the actual nrcell group was not be copied for the new cell group!  console=true
    Log  Parameter refNrCellGroup values from PE are: ${refNrCellGroup_from_pe}  console=true
    Click Element  //*[@id="/commissioning-wizard"]
    Wait Until Element Is Clicked  //*[contains(@aria-label, "NR Cell Group Settings")]  300
    Delete Actual Plan Via WebEM
    Create Duplicate Plan For CBTS


Step6: Clone One NRCELLGROUP With Checkboxes Selected And Verify The Specific Parameters
    Log  \nStep6: Clone One NRCELLGROUP With Checkboxes Selected And Verify The Specific Parameters  console=true
    ${cells_statuses}  vdu.Get Vdu Cells Status
    FOR  ${cell}  IN  @{cells_statuses}
        IF  '${cell}[cell_group_id]' == '${EXISTED_NRCELL_GROUP}'
            Set Test Variable  ${STEP_BY_STEP_INITIAL_NRCELL}  ${cell}[technology] ${cell}[name]
            BREAK
        END
    END
    Wait Until Element Is Clicked  //*[contains(@aria-label, "NR Cell Group Settings")]  300
    Input Text  //*[contains(@class, "p-tree-filter-container ng-star-inserted")]/input  ${EXISTED_NRCELL_GROUP}
    Sleep  3s  Time for text to be visible
    Click Element  //*[contains(@aria-label, "NRCELLGRP-${EXISTED_NRCELL_GROUP}")]/span/span/div/div[1]/div
    ${values_from_initial_group}  Get The Parameters Value From The NRCELLGROUP
    Click element  //*[contains(@class, "mdi mdi-content-copy p-button-icon ng-star-inserted")]
    Log  Clone button was pushed![OK]  console=true
    ${dialog_title}  Get Text  //*[@id="laf-component"]/div/div/div[1]/div[1]/span
    Should Be Equal  ${dialog_title}  Do you want to clone NR cell group from NRCELLGRP-${EXISTED_NRCELL_GROUP}?
    Log  Dialog title '${dialog_title}' is visible!  console=true
    Click Element  //*[contains(@class, "p-checkbox-label ng-star-inserted") and contains(text(), 'Clone NR cell(s)')]
    Element Should Be Visible  //*[contains(@class, "p-checkbox-label ng-star-inserted") and contains(text(), 'Clone cell mapping')]
    Log  Checkbox 'Clone cell mapping' is visible and enabled because checkbox 'Clone NR cell(s)' is selected!  console=true
    Click Element  //*[contains(@class, "p-checkbox-label ng-star-inserted") and contains(text(), 'Clone cell mapping')]
    Log  Checkbox 'Clone cell mapping' is selected too!  console=true
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span  60
    Log  Clone button was pushed with checkboxes selected!  console=true
    Element Should Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELLGRP-${CLONED_GROUP_ID}"]
    Log  The cloned NRCELLGRP-${CLONED_GROUP_ID} is visible on site view!  console=true
    Input Text  //*[contains(@class, "p-tree-filter-container ng-star-inserted")]/input  ${CLONED_GROUP_ID}
    Element Should Be Visible  //*[contains(@aria-label, "NRCELLGRP-${CLONED_GROUP_ID}")]
    Log  The cloned NRCELLGRP-${CLONED_GROUP_ID} is visible on step by step page!  console=true
    Save Plan From Commissioning Wizard
    Wait Until Element Is Clicked  //*[contains(@aria-label, "NR Cell Group Settings")]  300
    Input Text  //*[contains(@class, "p-tree-filter-container ng-star-inserted")]/input  ${CLONED_GROUP_ID}
    Sleep  5s
    Click Element  //*[contains(@aria-label, "NRCELLGRP-${CLONED_GROUP_ID}")]/span/span/div/div[1]/div
    ${values_from_cloned_group}  Get The Parameters Value From The NRCELLGROUP
    Lists Should Be Equal  ${values_from_initial_group}  ${values_from_cloned_group}
    Log  Cloned NR cell group with initial NR cell group parameters values copied!  console=true
    Element Should Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${CLONED_CELL_ID}"]
    Log  The cloned NRCELL-${CLONED_CELL_ID} is visible on site view!  console=true
    Save Plan From Commissioning Wizard
    Wait Until Element Is Clicked  //*[contains(@aria-label, "NR Cell and Cell Mapping")]  300
    Input Text  //*[contains(@class, "p-tree-filter-container ng-star-inserted")]/input  ${CLONED_CELL_ID}
    Sleep  5s
    ${nrcell_id}  Get Text  //*[contains(@class, "p-treenode-content p-treenode-selectable")]/span[2]/span/div/div[1]/div
    Should Contain  ${nrcell_id}  NRCELL-${CLONED_CELL_ID}
    Log  The cloned NRCELL-${CLONED_CELL_ID} is visible on step-by-step view!  console=true
    Input Text  //*[contains(@class, "p-tree-filter-container ng-star-inserted")]/input  ${STEP_BY_STEP_INITIAL_NRCELL}
    Sleep  5s  Time for text to be visible
    Click Element  //*[contains(@class, "p-treenode-content p-treenode-selectable")]/span[2]/span/div/div[1]/div
    Sleep  10s  Time for text to be visible
    ${values_from_initial_nrcell}  Get The Parameters Value From The NRCELL
    Input Text  //*[contains(@class, "p-tree-filter-container ng-star-inserted")]/input  ${CLONED_CELL_ID}
    Sleep  5s  Time for text to be visible
    Click Element  //*[contains(@class, "p-treenode-content p-treenode-selectable")]/span[2]/span/div/div[1]/div
    Sleep  10s  Time for text to be visible
    ${values_from_cloned_nrcell}  Get The Parameters Value From The NRCELL
    Lists Should Be Equal  ${values_from_initial_nrcell}  ${values_from_cloned_nrcell}
    Log  Cloned NR cell with initial NR cell parameters values copied!  console=true


Step7: Verify nrCellId And lcrId In Parameter Editor
    Log  \nStep7: Verify nrCellId And lcrId In Parameter Editor  console=true
    Save Plan From Commissioning Wizard
    ${nr_cells_id}  Get List Of Nr Cells Id
    Append To List  ${nr_cells_id}  ${CLONED_CELL_ID}
    ${nr_cells_id_list_length}  Get Length  ${nr_cells_id}
    Log  Open Parameter Editor  console=true
    Wait Until Element Is Clicked  //*[@id="/parameter-editor"]
    Log  Verify nrCellId parameter!  console=true
    Sleep  30s  Time for page to be uploaded.
    Wait Until Element Is Clicked
    ...  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/blocks-validation-errors/p-tabview/div/div[1]/p-button/button/span[1]
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  nrCellId
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  ENTER
    Sleep  10s  Time for page to be loaded.
    ${trs_pe}  SeleniumLibrary.Get Element Count  //*[contains(@class, 'p-element p-treetable-tbody')]/tr
    ${nr_cell_id_number}  Evaluate  ${trs_pe} // 2
    Should Be Equal  ${nr_cell_id_number}  ${nr_cells_id_list_length}  Parameter nrCellId is not visible for all created and existing nr cells![NOK]
    Log  Parameter nrCellId is visible for all created and existing nr cells![OK]  console=true
    ${nr_cells_id_from_pe}  Create List
    FOR  ${row}  IN RANGE  1  ${nr_cells_id_list_length}+1
        ${nr_cells_xpath}  Catenate  SEPARATOR=  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[${row}]/td[4]/cem-parameter-input
        ...  /cem-instance-id-input/ot-field/div/ot-input-number/span/input
        ${nr_cells}  Get Value  ${nr_cells_xpath}
        Append To List  ${nr_cells_id_from_pe}  ${nr_cells}
    END
    Sort List  ${nr_cells_id}
    Sort List  ${nr_cells_id_from_pe}
    Lists Should Be Equal  ${nr_cells_id}  ${nr_cells_id_from_pe}
    Log  nrCellId from the actual nrcell was not be copied for the new cell!  console=true
    Log  Parameter nrCellId values from PE are: ${nr_cells_id_from_pe}  console=true
    Log  Verify lcrId parameter!  console=true
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  lcrId
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  ENTER
    Sleep  10s  Time for page to be loaded.
    ${lcrid_pe}  SeleniumLibrary.Get Element Count  //*[contains(@class, 'p-element p-treetable-tbody')]/tr
    Should Be Equal  ${lcrid_pe}  ${nr_cells_id_list_length}  Parameter lcrId is not visible for all created and existing nr cells![NOK]
    Log  Parameter lcrId is visible for all created and existing nr cells![OK]  console=true
    ${lcrid_from_pe}  Create List
    FOR  ${row}  IN RANGE  1  ${lcrid_pe}+1
        ${lcrid_xpath}  Catenate  SEPARATOR=  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[${row}]/td[4]/cem-parameter-input/
        ...  cem-number-input/ot-field/div/ot-input-number/span/input
        ${lcrid}  Get Value  ${lcrid_xpath}
        Append To List  ${lcrid_from_pe}  ${lcrid}
    END
    Sort List  ${lcrid_from_pe}
    Lists Should Be Equal  ${nr_cells_id}  ${lcrid_from_pe}
    Log  lcrId from the actual nrcell was not be copied for the new cell!  console=true
    Log  Parameter lcrId values from PE are: ${lcrid_from_pe}  console=true
    Wait Until Element Is Clicked  //*[@id="/commissioning-wizard"]  120
    Sleep  30s  Time for page to be loaded.


Step8: Verify Highlighted Cell When NRCELLGRP Is Selected
    Log  \nStep8: Verify Highlighted Cell When NRCELLGRP Is Selected  console=true
    Click Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELLGRP-${CLONED_GROUP_ID}"]
    ${cell_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${CLONED_CELL_ID}"]/div  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${cell_class}
    ...  highlighted
    ...  Cloned NRCELL-${CLONED_CELL_ID} was not highlighted after cloned NRCELLGRP-${CLONED_GROUP_ID} was selected from site view!
    Log  Cloned NRCELL-${CLONED_CELL_ID} was highlighted after cloned NRCELLGRP-${CLONED_GROUP_ID} was selected from site view!  console=true


Step9: Verify Highlighted NRCELLGRP When Cell Is Selected
    Log  \nStep9: Verify Highlighted NRCELLGRP When Cell Is Selected  console=true
    Click Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${CLONED_CELL_ID}"]
    ${group_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELLGRP-${CLONED_GROUP_ID}"]/div  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${group_class}
    ...  highlighted
    ...  Cloned NRCELLGRP-${CLONED_GROUP_ID} was not highlighted after cloned NRCELL-${CLONED_CELL_ID} was selected from site view!
    Log  Cloned NRCELLGRP-${CLONED_GROUP_ID} was highlighted after cloned NRCELL-${CLONED_CELL_ID} was selected from site view!  console=true


Get The Parameters Value From The NRCELLGROUP
    ${values_from_group}  Create list
    ${number_of_parameters}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody/tr
    ${name_of_parameters_list}  Create List  Additional number of RRC connected users in a New Radio cell for SA handover  Beamforming grid selection
    ...  Maximum number of DL HARQ transmissions  Maximum number of Msg3 transmissions
    ...  Maximum number of non-GBR data radio bearers in New Radio Cell Group for SA
    ...  Maximum number of RRC connected users in a New Radio Cell Group for SA  Maximum number of UL HARQ transmissions
    ...  Number of transmitted Synchronization Signal Blocks  Pucch F2 Max Code Rate  SCS  SP-Cell change enabled  SS Burst Set Period
    FOR  ${row}  IN RANGE  1  ${number_of_parameters}
        ${name}  Wait Until Keyword Succeeds  30  5
        ...  Get Text  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody/tr[${row}]/td[1]
        ${list_index}  Evaluate  ${row} - 1
        Should Be Equal  ${name}  ${name_of_parameters_list}[${list_index}]  "${name}" is not visible![NOK]
        Log  "${name}" is visible![OK]  console=true
        ${value_button}  Catenate  SEPARATOR=  //tbody[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[2]/
        ...  cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
        IF  ${row} not in [1,3,4,5,6,7,12]
            ${value}  Wait Until Keyword Succeeds  30  5
            ...  Get Text  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody/tr[${row}]/td[2]
        ELSE
            ${value}  Get Value  ${value_button}
        END
        Append To List  ${values_from_group}  ${value}
        Log  "${value}" is visible![OK]  console=true
    END

    RETURN  ${values_from_group}


Get The Parameters Value From The NRCELL
    ${values_from_nrcell}  Create list
    Set Selenium Speed  0.2
    ${number_of_parameters}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody/tr
    ${name_of_parameters_list}  Create List  Activate super cell  Cell name  Cell technology  Channel bandwidth  Downlink MIMO Mode  Frequency
    ...  Frequency band Indicator NR  Local cell resource ID  Maximum output power  New Radio Cell instance identifier
    ...  NR Absolute radio frequency channel number  NR cell group  NR Cell type  Physical cell identifier  Timing advance offset  Uplink MIMO mode
    FOR  ${row}  IN RANGE  1  ${number_of_parameters}
        ${name}  Wait Until Keyword Succeeds  30  5
        ...  Get Text  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody/tr[${row}]/td[1]
        IF  '${name}' == 'Activate super cell'  CONTINUE
        ${list_index}  Evaluate  ${row} - 1
        Should Be Equal  ${name}  ${name_of_parameters_list}[${list_index}]  "${name}" is not visible![NOK]
        Log  "${name}" is visible![OK]  console=true
        ${string_xpath}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody/tr[${row}]
        ...  /td[2]/cem-parameter-input/cem-string-input/ot-field/div/input
        ${number_xpath}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody/tr[${row}]/td[2]/
        ...  cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
        IF  ${row} in [8,9,10,12,14]
            CONTINUE
        ELSE IF  ${row} in [3,4,5,13,15,16]
            ${value}  Get Text  //*[contains(@class, "p-element p-treetable-scrollable-view")]/div/table/tbody/tr[${row}]/td[2]
        ELSE IF  ${row} in [2,6]
            ${value}  Get Value  ${string_xpath}
        ELSE IF  ${row} in [7,11]
            ${value}  Get Value  ${number_xpath}
        END
        Append To List  ${values_from_nrcell}  ${value}
        Log  "${value}" is visible![OK]  console=true
    END
    Set Selenium Speed  1

    RETURN  ${values_from_nrcell}


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__Clone_NR_Cell_Group_configuration


TC Teardown
    Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown
