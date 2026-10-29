*** Settings ***
Documentation
    ...  This TC is created to verify multiple menus from Step by step view in Commissioning wizard.
    ...  First, General Site Settings is accessed and parameters like BTS name, time zone, gNB CU type are changed.
    ...  NR Cell Group and Nr Cell are added.
    ...  All types of ALDs are configured: RAE, RET and MHA.
    ...  In Parameter Restriction Configuration one Nr Cell parameter is added to restricted list, and then verified in Parameter Editor.
    ...  The parameter that was added in restricted list cannot be edited from Parameter Editor.
    ...  In Advanced Configuration page, certain objects are verified to be present both in Commissioning wizard and in Parameter Editor.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${PRODUCT_CODE_ALD_RAE}  ${EMPTY}  # Mandatory! Product code for created ALDs-RAEs.
${SERIAL_NUMBER_ALD_RAE}  ${EMPTY}  # Mandatory! Serial number for created ALDs-RAEs.
${MECHANICAL_ANGLE_RAE}  ${EMPTY}  # Mandatory! Mechanical angle for created RAEs.
${PRODUCT_CODE_ALD_RET}  ${EMPTY}  # Mandatory! Product code for created ALDs-RETs.
${SERIAL_NUMBER_ALD_RET}  ${EMPTY}  # Mandatory! Serial number for created ALDs-RETs.
${PRODUCT_CODE_ALD_MHA}  ${EMPTY}  # Mandatory! Product code for created ALDs-MHAs.
${SERIAL_NUMBER_ALD_MHA}  ${EMPTY}  # Mandatory! Serial number for created ALDs-MHAs.


*** Keywords ***
TC__WebEM__vDU__CW_Plan_preparation_with_step_by_step_view
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26640
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  21.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26640 - Initial TAT creation
    ...  ******************
    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  PHASE-CRT  FEATURE-CB005866-D

    Step0: TC Preconditions
    Step1: Open Commissioning Wizard
    Step2: Create Plan
    Step3: Open General Site Settings And Fill Basic Information
    Step4: Add And Configure All Types Of ALDs
    Step5: Add NR Cell Groups And Cells
    Step6: Add Parameters Which Will Not Be Allowed To Modify
    Step7: Verify Advanced Configuration Page


Step0: TC Preconditions
    Log  \nStep0: TC preconditions.  console=true
    ${rmods}  vdu.Get Rmods Status
    FOR  ${rmod}  IN  @{rmods}
        Run Keyword If  ${rmod}[id]==1
        ...  Set Test Variable  ${FIRST_RMOD_NAME}  ${rmod}[product_name]
        ...  ELSE
        ...  Continue For Loop
    END
    ${nrcells_list}  Create List
    ${cells_info}  Get Vdu Cells Status
    ${fdd_cell_id}  Set Variable  0
    ${tdd_cell_id}  Set Variable  0
    FOR  ${cell}  IN  @{cells_info}
        Append To List  ${nrcells_list}  ${cell}[name]
        ${fdd_cell_id}  Run Keyword If  '${cell}[technology]'=='FDD'
        ...  Evaluate  ${fdd_cell_id} + 1
        ...  ELSE
        ...  Set Variable  ${fdd_cell_id}
        ${tdd_cell_id}  Run Keyword If  '${cell}[technology]'=='TDD'
        ...  Evaluate  ${tdd_cell_id} + 1
        ...  ELSE
        ...  Set Variable  ${tdd_cell_id}
    END
    ${fdd_cell_id}  Run Keyword If  ${fdd_cell_id} != 0
    ...  Evaluate  ${fdd_cell_id} + 1
    ...  ELSE
    ...  Set Variable  0
    ${tdd_cell_id}  Run Keyword If  ${tdd_cell_id} != 0
    ...  Evaluate  ${tdd_cell_id} + 1
    ...  ELSE
    ...  Set Variable  0
    ${random_cell_name}  Evaluate  random.choice(${nrcells_list})  random
    Set Test Variable  ${RANDOM_CELL_NAME}
    Set Test Variable  ${FDD_CELL_ID}
    Set Test Variable  ${TDD_CELL_ID}


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Open Commissioning Wizard


Step2: Create Plan
    Log  \nStep2: Create plan  console=true
    Create Duplicate Plan For CBTS


Step3: Open General Site Settings And Fill Basic Information
    Log  \nStep3: Open general site settings and fill basic information.  console=true
    Click Element  //*[contains(@aria-label, 'General Site Settings')]
    Page Should Not Contain Button  //*[@id="back-btn"]/span  General Site Settings page contains "Back" button. [NOK]
    Element Should Be Visible  //*[contains(text(),'BTS name')]
    Element Should Be Visible  //*[contains(text(),'Multi Radio BTS Instance Id')]
    Element Should Be Visible  //*[contains(text(),'Product variant planned')]
    Element Should Be Visible  //*[contains(text(),'Time zone')]
    Element Should Be Visible  //*[contains(text(),'gNB CU type')]
    Element Should Be Visible  //*[contains(text(),'MCC in PLMN')]
    Element Should Be Visible  //*[contains(text(),'MNC in PLMN')]
    Element Should Be Visible  //*[contains(text(),'MNC length of PLMN ID in primary PLMN of gNB')]
    Element Should Be Visible  //*[contains(text(),'New Radio Basestation instance identifier')]
    ${bts_name_path}  Catenate  SEPARATOR=  //*[contains(@class, "step-content")]/blocks-steps-general-site-setting/div/div[1]/p-panel/div/div[2]/div
    ...  /cem-parameter-editor-table/div/p-treetable/div/div[1]/div/div/table/tbody/tr[1]/td[2]
    ...  /cem-parameter-input/cem-string-input/ot-field/div/input

    Input Text  ${bts_name_path}  ${VDU_MRBTS_NAME}
    ${time_zone_path}  Catenate  SEPARATOR=  //*[contains(@class, "step-content")]/blocks-steps-general-site-setting/div/div[1]/p-panel/div/div[2]
    ...  /div/cem-parameter-editor-table/div/p-treetable/div/div[1]/div/div[2]/table/tbody/tr[4]/td[2]
    ...  /cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    Click Element  ${time_zone_path}
    Scroll Element Into View  //*[contains(@aria-label,'(GMT+0) UTC')]
    Click Element  //*[contains(text(),'(GMT+0) UTC')]
    ${gnb_cu_type_path}  Catenate  SEPARATOR=  //*[contains(@class, "step-content")]/blocks-steps-general-site-setting/div/div[2]/p-panel/div/div[2]
    ...  /div/cem-parameter-editor-table/div/p-treetable/div/div[1]/div/div/table/tbody/tr[1]/td[2]
    ...  /cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    Click Element  ${gnb_cu_type_path}
    Wait Until Element Is Clicked  //*[contains(@aria-label,'SA')]  10  2
    ${mcc_path}  Catenate  SEPARATOR=  //*[contains(@class, "step-content")]/blocks-steps-general-site-setting/div/div[2]
    ...  /p-panel/div/div[2]/div/cem-parameter-editor-table/div
    ...  /p-treetable/div/div[1]/div/div/table/tbody/tr[2]/td[2]/cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
    Input Text  ${mcc_path}  540
    ${mnc_path}  Catenate  SEPARATOR=  //*[contains(@class, "step-content")]/blocks-steps-general-site-setting/div/div[2]/p-panel/div/div[2]/div
    ...  /cem-parameter-editor-table/div/p-treetable/div/div[1]/div/div/table/tbody/tr[3]/td[2]/cem-parameter-input/cem-number-input
    ...  /ot-field/div/ot-input-number/span/input
    Input Text  ${mnc_path}  1
    ${mnc_length_path}  Catenate  SEPARATOR=  //*[contains(@class, "step-content")]/blocks-steps-general-site-setting/div/div[2]/p-panel/div/div[2]
    ...  /div/cem-parameter-editor-table/div/p-treetable/div/div[1]/div/div/table/tbody/tr[4]/td[2]
    ...  /cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
    Input Text  ${mnc_length_path}  2
    Scroll Element Into View  //*[contains(@class,'mdi mdi-plus-thick p-button-icon ng-star-inserted')]
    Click Element  //*[contains(@class,'mdi mdi-plus-thick p-button-icon ng-star-inserted')]
    Wait Until Element Is Visible  //*[contains(text(),'gNB DU Name')]
    Element Should Be Visible  //*[contains(text(),'Target distinguished name')]
    ${target_dn_path}  Catenate  SEPARATOR=  //*[contains(@class, "step-content")]/blocks-steps-general-site-setting/div/div[3]/div[2]/p-panel/div
    ...  /div[2]/div/cem-parameter-editor-table/div/p-treetable/div/div[1]/div/div/table/tbody/tr[2]/td[2]
    ...  /cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    Click Element  ${target_dn_path}
    Wait Until Element Is Clicked  //*[contains(@aria-label,'APEQM-1')]  10  2
    Save Plan From Commissioning Wizard


Step4: Add And Configure All Types Of ALDs
    Log  \nStep4: Add and configure all types of ALDs.  console=true
    Log  Adding ALD-RAE from step-by-step!  console=true
    Click Element  //*[contains(@aria-label, 'Antenna Line Devices RAE')]
    Click Element  //*[contains(@class, "step-content")]/blocks-steps-rae-setting/div/div/cem-mod-list/p-panel/div/div//div[2]
    ${no_valid_text}  Get Text  //*[@id="nolinked-alds"]/div/div[1]/p-tag/span/span
    Should Be Equal  ${no_valid_text}  No valid radio links 1  "No valid radio links 1" is not visible, ALD-RAE was not added successfully![NOK]
    Log  ALD-RAE was added from step-by-step successfully!  console=true
    ${existing_alds}  vdu.Get Alds
    ${existing_alds_number}  Get Length  ${existing_alds}
    ${rae_ald_id}  Evaluate  ${existing_alds_number} + 1
    Configure ALD And RAEU  ${rae_ald_id}  ${FIRST_RMOD_NAME}  ${PRODUCT_CODE_ALD_RAE}  ${SERIAL_NUMBER_ALD_RAE}  ${MECHANICAL_ANGLE_RAE}
    Save Plan From Commissioning Wizard

    Log  Adding ALD-RET from step-by-step is performing!  console=true
    Click Element  //*[contains(@aria-label, 'Antenna Line Devices RET')]
    Click Element  //*[contains(@class, "step-content")]/blocks-steps-ret-setting/div/div/cem-mod-list/p-panel/div/div//div[2]
    ${no_valid_text}  Get Text  //*[@id="nolinked-alds"]/div/div[1]/p-tag/span/span
    Should Be Equal  ${no_valid_text}  No valid radio links 1  "No valid radio links 1" is not visible, ALD-RET was not added successfully![NOK]
    Log  ALD-RET was added from step-by-step successfully!  console=true
    ${ret_ald_id}  Evaluate  ${rae_ald_id} + 1
    Configure ALD And RETU  ${ret_ald_id}  ${FIRST_RMOD_NAME}  ${PRODUCT_CODE_ALD_RET}  ${SERIAL_NUMBER_ALD_RET}
    Save Plan From Commissioning Wizard

    Log  Adding ALD-MHA from step-by-step is performing!  console=true
    Click Element  //*[contains(@aria-label, 'Antenna Line Devices MHA')]
    Click Element  //*[contains(@class,'mdi mdi-plus-thick p-button-icon ng-star-inserted')]
    Input Text  //*[@id="laf-component"]/div/div/input  Nokia
    Wait Until Element Is Clicked  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'Nokia')]  10  2
    ${no_valid_text}  Get Text  //*[@id="nolinked-alds"]/div/div[1]/p-tag/span/span
    Should Be Equal  ${no_valid_text}  No valid radio links 2  "No valid radio links 2" is not visible, ALD-MHA was not added successfully![NOK]
    Log  ALD-MHA was added from step-by-step successfully!  console=true
    ${mha_ald_id}  Evaluate  ${ret_ald_id} + 1
    Configure ALD And MHA  ${mha_ald_id}  ${FIRST_RMOD_NAME}  ${PRODUCT_CODE_ALD_MHA}  ${SERIAL_NUMBER_ALD_MHA}
    Save Plan From Commissioning Wizard


Step5: Add NR Cell Groups And Cells
    Log  \nStep5: Add NR Cell Groups and cells.  console=true
    Click Element  //*[contains(@aria-label, 'NR Cell Group Settings')]
    Click Element  //*[contains(@class, "mdi mdi-plus-thick p-button-icon ng-star-inserted")]
    ${cell_group_id}  Get The First Cloned NRCELLGRP Id
    Verify If The NRCELLGRP Was Created And Check The Parameters  ${cell_group_id}  ${VDU_MRBTS_ID}  ${VDU_NRBTS_ID}
    Save Plan From Commissioning Wizard

    Click Element  //*[contains(@aria-label, 'NR Cell and Cell Mapping')]
    Wait Until Element Is Clicked  //*[contains(@class, 'mdi mdi-plus-thick p-button-icon ng-star-inserted')]
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/ul/li[1]/a/span
    Log  FDD cell was added!  console=true
    Wait Until Element Is Clicked  //*[contains(@class, 'mdi mdi-plus-thick p-button-icon ng-star-inserted')]
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/ul/li[2]/a/span
    Log  TDD cell was added!  console=true
    ${nr_cells_group_list}  Get List Of NRCELLGRP Ids
    ${first_nrcellgrp}  Get From List  ${nr_cells_group_list}  0
    Log  Verify and configure the parameters from FDD cell  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, "FDD${SPACE}NRCELL-${FDD_CELL_ID}")]  10  2
    Verify And Configure Parameters For FDD Cells From Step-by-step  ${first_nrcellgrp}  ${FDD_CELL_ID}
    Log  Verify and configure the parameters from TDD cell  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, "TDD${SPACE}NRCELL-${TDD_CELL_ID}")]  10  2
    Verify And Configure Parameters For TDD Cells From Step-by-step  ${first_nrcellgrp}  ${TDD_CELL_ID}
    Save Plan From Commissioning Wizard


Step6: Add Parameters Which Will Not Be Allowed To Modify
    Log  \nStep6: Add parameters which will not be allowed to modify.  console=true
    Click Element  //*[contains(@aria-label, 'Parameter Restriction Configuration')]
    Log  Adding NRCELL instance to restricted instances.  console=true
    Click Element  //*[contains(@class, 'grid grid-nogutter field ng-star-inserted')]/ot-field/p-dropdown/div/span
    Wait Until Element Is Clicked  //span[contains(text(), 'NRCELL')]  10  2
    Wait Until Element Is Clicked  //div[@class='p-element ot-text-ellipsis ng-star-inserted' and text()='${RANDOM_CELL_NAME}']  10  2
    Click Element  //*[@id="restricted-instances"]/div/div[2]/button/span[1]
    ${restricted_instances_text}  Get Text  //*[contains(@class,'flex align-items-center justify-content-between ng-star-inserted')]/div
    Should Be Equal As Strings  ${RANDOM_CELL_NAME}  ${restricted_instances_text}  Could not add NRCELL instance to restricted instances. [NOK]
    Log  NRCELL added successfully to restricted instances.  console=true
    Log  Add NRCELL parameter to restricted parameters.  console=true
    Click Element  //*[contains(text(), "NRCELL-actAdaptiveReTxResMcs")]
    Click Element  //*[@id="restricted-parameters"]/div/div[2]/button/span[1]
    Element Should Be Visible  //div[@class='p-element ot-text-ellipsis' and text()='NRCELL-actAdaptiveReTxResMcs']
    ...  Didn't manage to add NRCELL-actAdaptiveReTxResMcs to restricted parameters. [NOK]
    Save Plan From Commissioning Wizard
    Click Element  //*[@id="/parameter-editor"]
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  actAdaptiveReTxResMcs
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  ENTER
    Sleep  5s  Time for page to be loaded.
    ${number_of_parameters}  SeleniumLibrary.Get Element Count  //*[contains(@class, 'p-element p-treetable-tbody')]/tr
    FOR  ${row}  IN RANGE  1  ${number_of_parameters}
        ${cell_dist_name}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[${row}]/td[2]/div
        ${cell_status}  Run Keyword And Return Status
        ...  Should Contain  ${cell_dist_name}  ${RANDOM_CELL_NAME}
        Continue For Loop If  ${cell_status}==${FALSE}
        Click Element  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[${row}]/td[4]/div
        ${parameter_location}  Catenate  SEPARATOR=  //*[contains(@class, 'p-element p-treetable-tbody')]
        ...  /tr[${row}]/td[4]/div/span/configuration-shared-input/div/span[1]/p-dropdown/div/span[1]
        ${parameter_value}  Get Text  ${parameter_location}
        Run Keyword If  '${parameter_value}' == 'false'
        ...  Run Keywords
        ...  Click Element  //*[contains(@aria-label,'true')]
        ...  AND
        ...  Exit For Loop
        ...  ELSE
        ...  Run Keywords
        ...  Click Element  //*[contains(text(),'false')]
        ...  AND
        ...  Exit For Loop
    END
    Click Element  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[1]
    Wait Until Element Is Clicked  //*[@id="toolbar-activate-plan-button"]/button
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div[2]/p-button[1]/button/span
    Wait Until Keyword Succeeds  120  5
    ...  Page should contain  Plan validation failed
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/p-button[2]/button/span


Step7: Verify Advanced Configuration Page
    Log  \nStep7: Verify advanced configuration page.  console=true
    Click Element  //*[@id="/parameter-editor"]
    Input Text  //*[@class="p-inputtext p-component p-tree-filter"]  CLOCK
    Press Keys  //*[@class="p-inputtext p-component p-tree-filter"]  ENTER
    Wait Until Page Contains  10s  2s  MNL
    Wait Until Page Contains  10s  2s  MNLENT
    Wait Until Page Contains  10s  2s  CLOCK
    Click Element  //*[@id="/commissioning-wizard"]
    Wait Until Element Is Clicked  //*[contains(text(),'Advanced Configuration')]  120  10
    Click Element  //*[@id="laf-component"]/div/blocks-validation-errors/p-tabview/div/div[1]/p-button/button/span[1]
    Input Text  //*[@class="p-inputtext p-component p-tree-filter"]  CLOCK
    Press Keys  //*[@class="p-inputtext p-component p-tree-filter"]  ENTER
    Wait Until Page Contains  10s  2s  MNL
    Wait Until Page Contains  10s  2s  MNLENT
    Wait Until Page Contains  10s  2s  CLOCK
    Page Should Not Contain Button  //*[@id="save-btn"]/span
    Page Should Not Contain Button  //*[@id="undo-btn"]/span


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Plan_preparation_with_step_by_step_view


TC Teardown
    Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown
