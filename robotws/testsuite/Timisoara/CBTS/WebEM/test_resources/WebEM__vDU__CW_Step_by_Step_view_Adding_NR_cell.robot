*** Settings ***
Documentation
    ...  Open Commissioning Wizard menu and verify if the page is fully loaded.
    ...  Select Create delta plan.
    ...  Adding TDD or FDD RMOD if doesn't exist.
    ...  Add one FDD cell and one TDD cell from site view CW.
    ...  Verify if cells are in "No valid mapping cell".
    ...  Verify if when operator push configure button from site view, the specific cell from step-by-step is highlighted.
    ...  Verify if all specific parameters are visible for both cells.
    ...  Verify if operator can update some parameters for both cells.
    ...  Mapping the cells on specific RMOD and verify if the cells are in site view CW, not in No valip mapping cells anymore.
    ...  Verify highlighted cells when first NRCELLGRP is selected.
    ...  Verify nrCellList parameter from Parameter Editor.
    ...  Delete the created RMOD and verify if the cell mapped on was deleted automatically.
    ...  Delete the second created cell from site view CW.
    ...  Verify if nrCellList parameter from Parameter Editor was updated.
    ...  Verify refNrCellGroup parameter from Parameter Editor.
    ...  Delete one existing cell and verify if the nrcellgrp is not visible anymore.
    ...  Verify if refNrCellGroup parameter from Parameter Editor was updated.
    ...  Delete created delta plan.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26385
    ...
    ...  ******************
    ...  - 20.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26385 - Initial TAT creation
    ...  - 01.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27639 - Many xpaths was changed
    ...  - 29.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28453 - Delete xpath was changed
    ...  - 24.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30534 - Xpaths changed from Mapping TDD Cell On RMOD

    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  SW-SBTS24  FEATURE-CB005866-A

    Step1: Open Commissioning Wizard
    Step2: Create Plan
    Step3: Add FDD And TDD NR Cells
    Step4: Verify Configure Nr Cell Button And If The Cells Are In No Valid Mapping Cells
    Step5: Verify And Configure The Parameters From Both Added Cells
    Step6: Verify Highlighted Cell When NRCELLGRP Is Selected
    Step7: Delete Created Cells And Verify NrCellList
    Step8: Delete One Existing Cell And Verify If The Nrcellgrp Is Not Visible
    Step9: Delete Created Delta Plan


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Open Commissioning Wizard


Step2: Create Plan
    Log  \nStep2: Create plan  console=true
    Create Duplicate Plan For CBTS


Step3: Add FDD And TDD NR Cells
    Log  \nStep3: Add FDD and TDD NR cells  console=true
    ${rmod_status}  vdu.Get Rmods Status
    ${length_rmods}  Get Length  ${rmod_status}
    ${technology_list}  Create List
    FOR  ${rmod}  IN  @{rmod_status}
        Append To List  ${technology_list}  ${rmod}[technology_type]
    END
    ${technology_list}  Remove Duplicates  ${technology_list}
    ${status_tdd}  Run Keyword And Return Status
    ...  List Should Not Contain Value  ${technology_list}  TDD
    Run Keyword If  ${status_tdd}
    ...  Add One TDD Radio Module
    ...  ELSE
    ...  Add One FDD Radio Module
    ${created_rmod_id}  Evaluate  ${length_rmods} + 1
    Set Test Variable  ${CREATED_RMOD_ID}
    Wait Until Keyword Succeeds  30  5
    ...  Click Button  //*[@id="nolinked-cells"]/div/div[2]/button
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/ul/li[1]/a/span
    Wait Until Keyword Succeeds  300  5
    ...  Click Button  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button
    Log  FDD cell was added!  console=true
    Wait Until Keyword Succeeds  30  5
    ...  Click Button  //*[@id="nolinked-cells"]/div/div[2]/button
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/ul/li[2]/a/span
    Log  TDD cell was added!  console=true


Step4: Verify Configure Nr Cell Button And If The Cells Are In No Valid Mapping Cells
    Log  \nStep4: Verify configure nr cell button and if the cells are in no valid mapping cells  console=true
    ${text_no_valid}  Get Text  //*[@id="nolinked-cells"]/div/div[1]/p-tag/span/span
    Should Be Equal  ${text_no_valid}  No valid cell mappings 2  "No valid cell mappings 2" is not visible![NOK]
    Log  "No valid cell mappings 2" is visible![OK]  console=true
    Click Element  //*[@id="nolinked-cells"]/div/div[1]/p-tag/span/span
    ${first_created_cell_id}  Get First Created Cell Id
    Set Test Variable  ${FIRST_CREATED_CELL_ID}
    ${second_created_cell_id}  Get The Second Created Cell Id
    Set Test Variable  ${SECOND_CREATED_CELL_ID}
    Click Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${FIRST_CREATED_CELL_ID}"]/div/div[4]/p-button/button/span[1]
    Sleep  5s  Time for page to be loaded.
    ${first_cell_class}  Get Element Attribute  //*[contains(@aria-label, "FDD${SPACE}NRCELL-${FIRST_CREATED_CELL_ID}")]  class
    Should Contain  ${first_cell_class}  highlight
    ...  NRCELL-${FIRST_CREATED_CELL_ID} was not highlighted in step-by-step after configure button was selected from site view![NOK]
    Log  NRCELL-${FIRST_CREATED_CELL_ID} was highlighted in step-by-step after configure button was selected from site view![OK]  console=true
    Click Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${SECOND_CREATED_CELL_ID}"]/div/div[4]/p-button/button/span[1]
    Sleep  5s  Time for page to be loaded.
    ${second_cell_class}  Get Element Attribute  //*[contains(@aria-label, "TDD${SPACE}NRCELL-${SECOND_CREATED_CELL_ID}")]  class
    Should Contain  ${second_cell_class}  highlight
    ...  NRCELL-${SECOND_CREATED_CELL_ID} was not highlighted in step-by-step after configure button was selected from site view![NOK]
    Log  NRCELL-${SECOND_CREATED_CELL_ID} was highlighted in step-by-step after configure button was selected from site view![OK]  console=true


Step5: Verify And Configure The Parameters From Both Added Cells
    Log  \nStep5: Verify and configure the parameters from both added cells  console=true
    ${nr_cells_group_list}  Get List Of NRCELLGRP Ids
    ${first_nrcellgrp}  Get From List  ${nr_cells_group_list}  0
    Set Test Variable  ${FIRST_NRCELLGRP}
    ${cells_statuses}  vdu.Get Vdu Cells Status
    FOR  ${cell}  IN  @{cells_statuses}
        ${cell_status}  Run Keyword And Return Status
        ...  Should Contain  ${cell}[cell_group_id]  ${FIRST_NRCELLGRP}
        IF  ${cell_status}
          Set Test Variable  ${CELL_ID_ON_FIRST_GROUP}  ${cell}[id]
          BREAK
        END
    END
    Set Selenium Speed  0.2
    Log  Verify and configure the parameters from FDD cell  console=true
    Click Element  //*[contains(@aria-label, "FDD${SPACE}NRCELL-${FIRST_CREATED_CELL_ID}")]
    Verify And Configure Parameters For FDD Cells From Step-by-step  ${FIRST_NRCELLGRP}  ${FIRST_CREATED_CELL_ID}
    Log  Mapping FDD cell on RMOD  console=true
    Mapping FDD Cell On RMOD
    Log  Verify and configure the parameters from TDD cell  console=true
    Click Element  //*[contains(@aria-label, "TDD${SPACE}NRCELL-${SECOND_CREATED_CELL_ID}")]
    Verify And Configure Parameters For TDD Cells From Step-by-step  ${FIRST_NRCELLGRP}  ${SECOND_CREATED_CELL_ID}
    Log  Mapping TDD cell on RMOD  console=true
    Mapping TDD Cell On RMOD
    Set Selenium Speed  1


Step6: Verify Highlighted Cell When NRCELLGRP Is Selected
    Log  \nStep6: Verify highlighted cell when NRCELLGRP is selected  console=true
    Wait Until Element Is Clicked  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELLGRP-${FIRST_NRCELLGRP}"]
    ${existing_cell_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${CELL_ID_ON_FIRST_GROUP}"]/div  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${existing_cell_class}
    ...  highlighted
    ...  NRCELL-${CELL_ID_ON_FIRST_GROUP} was not highlighted after NRCELLGRP-${FIRST_NRCELLGRP} was selected from site view![NOK]
    Log  NRCELL-${CELL_ID_ON_FIRST_GROUP} was highlighted after NRCELLGRP-${FIRST_NRCELLGRP} was selected from site view![OK]  console=true
    Wait Until Element Is Clicked  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELLGRP-${FIRST_NRCELLGRP}"]
    ${first_cell_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${FIRST_CREATED_CELL_ID}"]/div  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${first_cell_class}
    ...  highlighted
    ...  NRCELL-${FIRST_CREATED_CELL_ID} was not highlighted after NRCELLGRP-${FIRST_NRCELLGRP} was selected from site view![NOK]
    Log  NRCELL-${FIRST_CREATED_CELL_ID} was highlighted after NRCELLGRP-${FIRST_NRCELLGRP} was selected from site view![OK]  console=true
    ${second_cell_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${SECOND_CREATED_CELL_ID}"]/div  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${second_cell_class}
    ...  highlighted
    ...  NRCELL-${SECOND_CREATED_CELL_ID} was not highlighted after NRCELLGRP-${FIRST_NRCELLGRP} was selected from site view![NOK]
    Log  NRCELL-${SECOND_CREATED_CELL_ID} was highlighted after NRCELLGRP-${FIRST_NRCELLGRP} was selected from site view![OK]  console=true


Step7: Delete Created Cells And Verify NrCellList
    Log  \nStep7: Delete created cells and verify nrCellList  console=true
    Verify NrCellList Parameter From Parameter Editor Before Delete Created Cells
    Log  Delete created RMOD-${CREATED_RMOD_ID} with technology ${TECHNOLOGY_RMOD}...  console=true
    ${delete_button_rmod}  Catenate  SEPARATOR=  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CREATED_RMOD_ID}"]/ot-card/p-card/div/div/div
    ...  /div/div[1]/div[1]/div[2]/p-button[2]/button/span[1]
    Click Element  ${delete_button_rmod}
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[2]/blocks-delete-check-dialog/div[2]/div/p-checkbox/div/div[2]
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span
    Log  Created RMOD-${CREATED_RMOD_ID} with technology ${TECHNOLOGY_RMOD} was deleted![OK]  console=true
    Log  Verify if created cell with technology ${TECHNOLOGY_RMOD} was deleted too...  console=true
    IF  '${TECHNOLOGY_RMOD}' == 'FDD'
      Wait Until Keyword Succeeds  30  5
      ...  Element Should Not Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${FIRST_CREATED_CELL_ID}"]
      Log  NRCELL-${FIRST_CREATED_CELL_ID} on RMOD-${CREATED_RMOD_ID} was deleted too![OK]  console=true
    ELSE
      Wait Until Keyword Succeeds  30  5
      ...  Element Should Not Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${SECOND_CREATED_CELL_ID}"]
      Log  NRCELL-${SECOND_CREATED_CELL_ID} on RMOD-${CREATED_RMOD_ID} was deleted too![OK]  console=true
    END
    Log  Delete the last created cell from site view!  console=true
    IF  '${TECHNOLOGY_RMOD}' == 'FDD'
      Wait Until Element Is Clicked
      ...  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${SECOND_CREATED_CELL_ID}"]/div/div[5]/p-button/button/span[1]
      Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span
      Wait Until Keyword Succeeds  30  5
      ...  Element Should Not Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${SECOND_CREATED_CELL_ID}"]
      Log  NRCELL-${SECOND_CREATED_CELL_ID} was deleted![OK]  console=true
    ELSE
      Wait Until Element Is Clicked
      ...  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${FIRST_CREATED_CELL_ID}"]/div/div[5]/p-button/button/span[1]
      Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span
      Wait Until Keyword Succeeds  30  5
      ...  Element Should Not Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${FIRST_CREATED_CELL_ID}"]
      Log  NRCELL-${FIRST_CREATED_CELL_ID} was deleted![OK]  console=true
    END
    Log  All created cells are deleted![OK]  console=true
    Verify NrCellList Parameter From Parameter Editor After Created Cells Was Deleted


Step8: Delete One Existing Cell And Verify If The Nrcellgrp Is Not Visible
    Log  \nStep8: Delete one existing cell and verify if the nrcellgrp is not visible  console=true
    Save Plan From Commissioning Wizard
    Log  Open Parameter Editor to verify refNrCellGroup  console=true
    ${nr_cell_groups_list}  Get List Of NRCELLGRP Ids
    ${length}  Get Length  ${nr_cell_groups_list}
    Wait Until Element Is Clicked  //*[@id="/parameter-editor"]
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  refNrCellGroup
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div  ENTER
    Sleep  5s  Time for page to be loaded.
    ${initial_trs_pe}  SeleniumLibrary.Get Element Count  //*[contains(@class, 'p-element p-treetable-tbody')]/tr
    ${initial_nrcellgrps_pe}  Evaluate  ${initial_trs_pe} - 1
    Wait Until Element Is Clicked  //*[@id="/commissioning-wizard"]  120
    Sleep  30s  Time for page to be loaded.
    Click Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${CELL_ID_ON_FIRST_GROUP}"]/div/div[5]/p-button/button/span[1]
    Log  Select checkbox with "Delete related cell groups"!  console=true
    Click Element  //*[@id="laf-component"]/div/div/div[2]/blocks-delete-check-dialog/div[2]/div/p-checkbox/div/div[2]
    Click Element  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span
    Log  Delete button was pushed, verify if the cell and nrcellgrp is not visible anymore!  console=true
    Element Should Not Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${CELL_ID_ON_FIRST_GROUP}"]
    Log  NRCELL-${CELL_ID_ON_FIRST_GROUP} was deleted![OK]  console=true
    Element Should Not Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELLGRP-${FIRST_NRCELLGRP}"]
    Log  NRGELLGRP-${FIRST_NRCELLGRP} was deleted![OK]  console=true
    Save Plan From Commissioning Wizard
    Log  Open Parameter Editor to verify refNrCellGroup  console=true
    Wait Until Element Is Clicked  //*[@id="/parameter-editor"]
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  refNrCellGroup
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div  ENTER
    ${trs_pe}  SeleniumLibrary.Get Element Count  //*[contains(@class, 'p-element p-treetable-tbody')]/tr
    ${nrcellgrps_pe}  Evaluate  ${trs_pe} - 1
    IF  ${initial_nrcellgrps_pe} > ${nrcellgrps_pe}
      Log  refNrCellGroup is corect![OK]  console=true
    ELSE
      Fail  refNrCellGroup is not corect![OK]
    END
    Wait Until Element Is Clicked  //*[@id="/commissioning-wizard"]  120
    Sleep  30s  Time for page to be loaded.


Step9: Delete Created Delta Plan
    Log  \nStep9: Delete created delta plan  console=true
    Delete Actual Plan Via WebEM


Add One TDD Radio Module
    Log  Add one TDD Radio Module  console=true
    Click Element  //*[contains(@class, 'cem-radio-ald-cell')]/table/thead/tr/th[1]/cem-site-view-label-header-panel/div/div[2]/button/span[1]
    Log  Input AEQP...  console=true
    Input Text  //*[@id="laf-component"]/div/div/input  AEQP
    Mouse Over  //*[@id="laf-component"]/div/ul/li[1]/a/span
    Click Element  //*[@id="laf-component"]/div/ul/li[1]/a/span
    Log  Radio Module AEQP was added!  console=true
    Set Test Variable  ${TECHNOLOGY_RMOD}  TDD


Add One FDD Radio Module
    Log  Add one FDD Radio Module  console=true
    Click Element  //*[contains(@class, 'cem-radio-ald-cell')]/table/thead/tr/th[1]/cem-site-view-label-header-panel/div/div[2]/button/span[1]
    Log  Input AHBCC...  console=true
    Input Text  //*[@id="laf-component"]/div/div/input  AHBCC
    Mouse Over  //*[@id="laf-component"]/div/ul/li[1]/a/span
    Click Element  //*[@id="laf-component"]/div/ul/li[1]/a/span
    Log  Radio Module AHBCC was added!  console=true
    Set Test Variable  ${TECHNOLOGY_RMOD}  FDD


Get First Created Cell Id
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
      ${first_cell_id}  Set Variable  0
    ELSE
      ${first_cell_id}  Evaluate  ${last_cell_id} + 1
    END

    [Return]  ${first_cell_id}


Get The Second Created Cell Id
    ${nr_cells_id_list}  Get List Of Nr Cells Id
    Append To List  ${nr_cells_id_list}  ${FIRST_CREATED_CELL_ID}
    Sort List  ${nr_cells_id_list}
    ${length}  Get Length  ${nr_cells_id_list}
    IF  ${nr_cells_id_list}[0] == 0
      ${second_cell_id}  Set Variable  1
    ELSE
      ${second_cell_id}  Evaluate  ${nr_cells_id_list}[-1] + 1
    END

    [Return]  ${second_cell_id}


Verify NrCellList Parameter From Parameter Editor Before Delete Created Cells
    ${nr_cells_id}  Get List Of Nr Cells Id
    ${nr_cells}  Get Length  ${nr_cells_id}
    Save Plan From Commissioning Wizard
    Log  Open Parameter Editor to verify nrCellList  console=true
    Wait Until Element Is Clicked  //*[@id="/parameter-editor"]
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  nrCellList
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div  ENTER
    Sleep  5s  Time for page to be loaded.
    ${trs_pe}  SeleniumLibrary.Get Element Count  //*[contains(@class, 'p-element p-treetable-tbody')]/tr
    ${nr_cell_groups}  Get List Of NRCELLGRP Ids
    ${nrcells_pe}  Evaluate  ${trs_pe} - len(${nr_cell_groups})
    ${nrcells}  Evaluate  ${nr_cells} + 2
    IF  ${nrcells_pe} == ${nrcells}
      Log  nrCellList is corect![OK]  console=true
    ELSE
      Fail  nrCellList is not corect![OK]
    END
    Wait Until Element Is Clicked  //*[@id="/commissioning-wizard"]  120
    Sleep  30s  Time for page to be loaded.


Verify NrCellList Parameter From Parameter Editor After Created Cells Was Deleted
    ${nr_cells_id}  Get List Of Nr Cells Id
    ${nr_cells}  Get Length  ${nr_cells_id}
    Save Plan From Commissioning Wizard
    Log  Open Parameter Editor to verify nrCellList  console=true
    Wait Until Element Is Clicked  //*[@id="/parameter-editor"]
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  nrCellList
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div  ENTER
    Sleep  5s  Time for page to be loaded.
    ${trs_pe}  SeleniumLibrary.Get Element Count  //*[contains(@class, 'p-element p-treetable-tbody')]/tr
    ${nr_cell_groups}  Get List Of NRCELLGRP Ids
    ${nrcells_pe}  Evaluate  ${trs_pe} - len(${nr_cell_groups})
    IF  ${nrcells_pe} == ${nr_cells}
      Log  nrCellList is corect![OK]  console=true
    ELSE
      Fail  nrCellList is not corect![OK]
    END
    Wait Until Element Is Clicked  //*[@id="/commissioning-wizard"]  120
    Sleep  30s  Time for page to be loaded.


Mapping FDD Cell On RMOD
    Wait Until Element Is Clicked
    ...  //*[contains(@class, "grid grid-nogutter m-0")]/div[2]/p-panel[2]/div/div[2]/div/form/div/p-radiobutton[2]/div/div[2]
    Log  Non mMIMO radio was selected!  console=true
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[contains(@class, "p-column-filter")]/ot-column-filter-form-element/div/input  AHBCC${SPACE}RMOD-${CREATED_RMOD_ID}
    Wait Until Element Is Clicked  //*[contains(@class, "p-element p-datatable-tbody")]/tr/td[2]/p-dropdown/div
    Wait Until Element Is Clicked  //*[contains(@aria-label, "TXRX")]
    Wait Until Element Is Clicked  //*[contains(@class, "p-element p-datatable-tbody")]/tr/td[3]/p-dropdown/div
    Wait Until Element Is Clicked  //*[contains(@aria-label, "TXRX")]
    Wait Until Element Is Clicked  //*[contains(@class, "p-element p-datatable-tbody")]/tr/td[4]/p-dropdown/div
    Wait Until Element Is Clicked  //*[contains(@aria-label, "TXRX")]
    Wait Until Element Is Clicked  //*[contains(@class, "p-element p-datatable-tbody")]/tr/td[5]/p-dropdown/div
    Wait Until Element Is Clicked  //*[contains(@aria-label, "TXRX")]
    Wait Until Keyword Succeeds  30  5
    ...  Element Should Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${FIRST_CREATED_CELL_ID}"]/div/div[2]/div


Mapping TDD Cell On RMOD
    Wait Until Element Is Clicked
    ...  //*[contains(@class, "grid grid-nogutter m-0")]/div[2]/p-panel[2]/div/div[2]/div/form/div/p-radiobutton[1]/div/div[2]
    Log  mMIMO radio was selected!  console=true
    Wait Until Element Is Clicked  //*[contains(@class, "p-element p-datatable-tbody")]/tr/td[2]/ot-field/p-checkbox/div/div[2]
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr/td[3]/otx-form-input/div/ot-field/div/ot-input-number/span/input  4
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr/td[4]/otx-form-input/div/ot-field/div/ot-input-number/span/input  4
    Wait Until Keyword Succeeds  30  5
    ...  Element Should Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${SECOND_CREATED_CELL_ID}"]/div/div[2]/div


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell


TC Teardown
    Run Keyword If Test Failed
    ...  Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown
