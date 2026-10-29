*** Settings ***
Documentation
    ...  This scenario is to describe how the user can use clone option to extend the site configuration with radios, NR Cell Groups and cells.
    ...  In this scenario as a result the changes made by the user are saved in WebEM backend server for further processing.
    ...  The Commissioning Wizard RMOD tab opens successfully, and the user is able to select either a staged plan or the current plan without issues.
    ...  The user in radio module settings step by step view selects one configured radio module and select option to clone.
    ...  In addition, user can select if clone NR cell and NR cell group also.
    ...  WebEM displays a message box and asks if the user wants to clone only radio or also clone NR cell and NR cell group.
    ...  WebEM creates new radio module with radio module parameters values copied from cloned radio module.
    ...  RMOD.rmodId shall not be copied for the new radio module and need use lowest available ID respectively.
    ...  RMOD's child objects also be cloned if have.
    ...  WebEM also creates new ANTL MOs/PHYANT MO, with subsequent instance IDs, for the radio if those were copied.
    ...  In Site view and Step By Step view new radio appears with the same name, product code and serial number as the copied one.
    ...  The user decides to clone radio and also clone NR cell and NR cell group.
    ...  WebEM creates new radio with new subsequent instance ID in working plan using all parameters values from copied radio.
    ...  WebEM creates new NR Cell Group MOs with NR cell with all NR cells parameters' values copied from cloned cells.
    ...  NRCELL.nrCellId and NRCELL.lcrId shall not be copied for new cells and need use lowest available ID respectively.
    ...  Then cell mapping for new NR cells related to new radio will be created automatically also.
    ...  WebEM also creates new ANTL MOs/PHYANT MO, with subsequent instance IDs,
    ...  and sets all ANTL.PHYANT related parameters in the same way as copied once.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__Cloud_Clone_Radio_Configuration
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28983
    ...
    ...  ******************
    ...  22.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28983 - Initial TAT creation
    ...  15.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29201 - Update TC to checks subobjects of cloned rmod
    ...  23.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29559 - Wrong usage of the KW
    ...  19.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30531 - Adapt TC for CNI-CB013031

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-vDU25  FEATURE-CB012501

    Step0: TC Preconditions
    Step1: Open Commissioning Wizard Menu
    Step2: Verify If Default Plan Is Current Plan
    Step3: Clone Radio Module Without NR Cell And NR Cell Group
    Step4: Verify Instance Parameters Betwenn Radio Module And Rmod Cloned
    Step5: Open Commissioning Wizard Menu
    Step6: Clone Radio Module With NR Cell And NR Cell Group
    Step7: Verify Instance Parameters Betwenn Radio Module And Rmod Cloned
    Step8: Undo Changes From Commissioning Wizard


Step0: TC Preconditions
    Log  \nStep0: TC Preconditions  console=true
    ${rmods_ids_list}  Create List
    ${rmods_statuses}  Get Rmods Status
    ${rmods_number}  Get Length  ${rmods_statuses}
    ${ID_FOR_CREATED_RF_WITHOUT_NR_CELL}  Evaluate  ${rmods_number} + 1
    Set Test Variable  ${ID_FOR_CREATED_RF_WITHOUT_NR_CELL}
    ${ID_FOR_CREATED_RF_WITH_NR_CELL}  Evaluate  ${rmods_number} + 2
    Set Test Variable  ${ID_FOR_CREATED_RF_WITH_NR_CELL}
    FOR  ${rmod}  IN  @{rmods_statuses}
        Append To List  ${rmods_ids_list}  ${rmod}[id]
    END
    Set Test Variable  ${ORIGINAL_RMOD_ID}  ${rmods_ids_list}[0]
    ${cells_on_rmod}  Set Variable  ${rmods_statuses}[0][cell_ids]
    ${vdu_cells_id}  Get List Of Nr Cells Id
    ${no_cells_on_rmod}  Get Length  ${cells_on_rmod}
    ${ids_for_cells_created}  Create List
    Set Test Variable  ${IDs_FOR_CELLS_CREATED}
    ${initial_value}  Set variable  0
    WHILE  ${no_cells_on_rmod} != 0
        ${initial_value}  Convert To String  ${initial_value}
        ${status}  Run Keyword And Return Status  List Should Not Contain Value  ${vdu_cells_id}  ${initial_value}
        IF  ${status}
            Append To List  ${IDs_FOR_CELLS_CREATED}  ${initial_value}
            ${no_cells_on_rmod}  Evaluate  ${no_cells_on_rmod} - 1
        END
        ${initial_value}  Evaluate  ${initial_value} + 1
    END


Step${index}: Open Commissioning Wizard Menu
    Log  \nStep${index}: Open Commissioning Wizard menu  console=true
    Open Commissioning Wizard


Step2: Verify If Default Plan Is Current Plan
    Log  \nStep2: Verify If Default Plan Is Current Plan  console=true
    Page Should Contain  Current Plan  Current Plan is not visible as default plan in CW![NOK]
    Log  Current Plan is visible as default plan in CW![OK]  console=true


Step${index}: Clone Radio Module ${Without_With} NR Cell And NR Cell Group
    Log  \nStep${index}: Clone Radio Module ${Without_With} NR Cell And NR Cell Group  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, "Radio Module Settings")]
    ${clone_rmod}  Catenate  SEPARATOR=  //*[@id="laf-component"]/div/div/cem-mod-list/p-panel/div/div[2]/div/p-tree/div/div[2]/ul/p-treenode[1]/li/
    ...  div/span/span/div/div[2]/p-button[2]/button/span[1]
    Wait Until Element Is Clicked  ${clone_rmod}
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain  Do you want to clone radio from RMOD-${ORIGINAL_RMOD_ID}?
    IF  '${Without_With}'=='With'
        Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[2]/blocks-clone-radio-dialog/div/p-checkbox/label
    END
    Click Element  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span
    Log  Clone rmod:RMOD-${ORIGINAL_RMOD_ID} is performing!  console=true
    Save Plan From Commissioning Wizard


Step${index}: Verify Instance Parameters Betwenn Radio Module And Rmod Cloned
    Log  \nStep${index}: Verify Instance Parameters Betwenn Radio Module And Rmod Cloned  console=true
    ${id_for_created_rf}  Set Variable If  ${index} == 4  ${ID_FOR_CREATED_RF_WITHOUT_NR_CELL}  ${ID_FOR_CREATED_RF_WITH_NR_CELL}
    Wait Until Element Is Clicked  //*[contains(@aria-label, "Radio Module Settings")]
    ${status}  Run Keyword And Return Status
    ...  Element Should Be Visible  //*[@data-key="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${id_for_created_rf}"]
    IF  ${status}
        Log  Created radio module with id ${id_for_created_rf} is visible in CW![OK]  console=true
    ELSE
        Fail  Created radio module with id ${id_for_created_rf} is not visible in CW![NOK]
    END
    Check Parameters From CW For RMOD-${id_for_created_rf}
    ${parameters_for_original_rmod}  ${original_parameters_subobjects_rmod}  Get Parameters From PE For RMOD-${ORIGINAL_RMOD_ID}
    ${parameters_for_cloned_rmod}  ${cloned_parameters_subobjects_rmod}  Get Parameters From PE For RMOD-${id_for_created_rf}
    ${status}  Run Keyword And Return Status
    ...  Lists Should Be Equal  ${parameters_for_original_rmod}  ${parameters_for_cloned_rmod}
    IF  ${status}
        Log  Cloned RMOD-${id_for_created_rf} have the same parameters in PE like original RMOD-${ORIGINAL_RMOD_ID} [OK].  console=true
    ELSE
        Fail  Cloned RMOD-${id_for_created_rf} have not the same parameters in PE like original RMOD-${ORIGINAL_RMOD_ID} [NOK].
    END
    ${status}  Run Keyword And Return Status
    ...  Lists Should Be Equal  ${original_parameters_subobjects_rmod}  ${cloned_parameters_subobjects_rmod}
    IF  ${status}
        Log  Cloned RMOD-${id_for_created_rf} have the same subobjects parameters in PE like original RMOD-${ORIGINAL_RMOD_ID} [OK].  console=true
    ELSE
        Fail  Cloned RMOD-${id_for_created_rf} have not the same subobjects parameters in PE like original RMOD-${ORIGINAL_RMOD_ID} [NOK].
    END
    IF  ${index} == 7
        Open Commissioning Wizard
        Verify If NR Cells And NRCELLGRP Appear In CW
    END


Step8: Undo Changes From Commissioning Wizard
    Log  \nStep8: Undo Changes From Commissioning Wizard  console=true
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/cem-toolbar/div/div[1]/div[4]/p-button[4]/button/span[1]
    Wait Until Element Is Visible  //*[contains(text(), "Do you want to undo changes?")]  30
    Click Element  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span
    Wait Until Element Is Visible  //*[contains(@aria-label, "Radio Module Settings")]  30
    Element Should Be Disabled  //*[@id="undo-btn"]
    Log  Changes are removing successfully!  console=true


Check Parameters From CW For RMOD-${RMOD_ID}
    Wait Until Element Is Clicked
    ...  //*[@id="laf-component"]/div/div/cem-mod-list/p-panel/div/div[2]/div/p-tree/div/div[2]/ul/p-treenode[1]/li/div/span/span/div/div[1]/div
    ${parameters_for_original_rmod}  Get Paramaters For Selected Rmod
    Wait Until Element Is Clicked  //*[@data-key="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_ID}"]
    ${parameters_for_cloned_rmod}  Get Paramaters For Selected Rmod
    ${status}  Run Keyword And Return Status
    ...  Lists Should Be Equal  ${parameters_for_original_rmod}  ${parameters_for_cloned_rmod}
    IF  ${status}
        Log  Cloned RMOD-${RMOD_ID} have the same parameters in CW like original RMOD [OK].  console=true
    ELSE
        Fail  Cloned RMOD-${RMOD_ID} have not the same parameters in CW like original RMOD [NOK].
    END


Get Paramaters For Selected Rmod
    ${parameters}  Create List
    ${pc_xpath}  Catenate  SEPARATOR=  //*[contains(@class,'p-element p-treetable-scrollable-view')]/div/table/tbody/tr[4]/td[2]/cem-parameter-input
    ...  /cem-string-input/ot-field/div/input
    ${sn_xpath}  Catenate  SEPARATOR=  //*[contains(@class,'p-element p-treetable-scrollable-view')]/div/table/tbody/tr[5]/td[2]/cem-parameter-input
    ...  /cem-string-input/ot-field/div/input
    ${product_code}  Get Value  ${pc_xpath}
    ${serial_number}  Get Value  ${sn_xpath}
    Append To List  ${parameters}  ${product_code}
    Append To List  ${parameters}  ${serial_number}
    RETURN  ${parameters}


Get Parameters From PE For RMOD-${RMOD}
    ${parameters_rmod}  Create List
    Wait Until Element Is Clicked  //*[@id="/parameter-editor"]
    Wait Until Keyword Succeeds  30  5  Input Text
    ...  //*[contains(@class, 'p-tree-filter-container ng-star-inserted')]/input  RMOD-${RMOD}
    Press Keys  //*[contains(@class, 'p-tree-filter-container ng-star-inserted')]/input  ENTER
    Wait Until Element Is Clicked  //span[contains(@class, 'ot-highlight-text') and contains(text(), 'RMOD-${RMOD}')]
    ${parameters_check}  Create List  administrativeState  alVoltHighThreshold  alVoltLowThreshold  alVoltUnstableThreshold  climateControlProfiling
    ...  cpriARfSharing  digitalCombinerMode  energySavingMode  intPIMLevelMeasurementMajorThreshold  intPIMLevelMeasurementMinorThreshold
    ...  pimCancellingEnabled  prodCodePlanned  ptpSyncRepPrd  radioMemAbnormalThreshold  rfmTransmitMode  serialNumberPlanned
    FOR  ${parameter}  IN  @{parameters_check}
        Wait Until Keyword Succeeds  30  5  Input Text
        ...  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/thead/tr[2]/th[3]/div/input  ${parameter}
        Press Keys  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/thead/tr[2]/th[3]/div/input  ENTER
        Sleep  3s  Time for page to be uploaded
        ${status_1}  Run Keyword And Return Status  Page Should Contain Element
        ...  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[1]/td[4]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div
        ${abbreviation_xpath}  Catenate  SEPARATOR=  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[1]/td[4]/cem-parameter-input/
        ...  cem-number-input/ot-field/div/ot-input-number/span/input
        ${status_2}  Run Keyword And Return Status  Page Should Contain Element  ${abbreviation_xpath}
        ${status_3}  Run Keyword And Return Status  Page Should Contain Element
        ...  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[1]/td[4]/cem-parameter-input/cem-string-input/ot-field/div/input
        IF  ${status_3}
            ${planned_value_xpath}  Catenate  SEPARATOR=  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[1]/td[4]/
            ...  cem-parameter-input/cem-string-input/ot-field/div/input
        ELSE IF  ${status_2}
            ${planned_value_xpath}  Catenate  SEPARATOR=  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[1]/td[4]/
            ...  cem-parameter-input/cem-number-input/ot-field/div/ot-input-number
        ELSE IF  ${status_1}
            ${planned_value_xpath}  Catenate  SEPARATOR=  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[1]/td[4]/
            ...  cem-parameter-input/cem-dropdown-input/div/p-dropdown/div
        ELSE
            ${planned_value_xpath}  Catenate  SEPARATOR=  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[1]/td[4]/
            ...  cem-parameter-input/cem-instance-id-input/ot-field/div/ot-input-number/span/input
        END
        ${parameter_planned_value}  Get Value  ${planned_value_xpath}
        Append To List  ${parameters_rmod}  ${parameter_planned_value}
    END
    Wait Until Element Is Clicked  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/thead/tr[2]/th[3]/div/span[2]/button/i
    ${extend_rmod_xpath}  Catenate  SEPARATOR=  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/div/blocks-navigation/ot-side-sheet/div
    ...  /div[1]/div/div[2]/p-tree/div/cdk-virtual-scroll-viewport/div[1]/ul/p-treenode[4]/li/div/button
    Wait Until Element Is Clicked  ${extend_rmod_xpath}
    ${parameters_subobjects_rmod}  Create List
    ${objects}  SeleniumLibrary.Get Element Count  //*[@class="cdk-virtual-scroll-content-wrapper"]/ul/p-treenode
    FOR  ${object}  IN RANGE  1  ${objects}+1
        ${data_level}  Get Element Attribute  //*[@class="cdk-virtual-scroll-content-wrapper"]/ul/p-treenode[${object}]/li  data-level
        IF  ${data_level} == 4
            Wait Until Element Is Clicked  //*[@class="cdk-virtual-scroll-content-wrapper"]/ul/p-treenode[${object}]/li
            ${number_of_rows}  Get Element Count  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr
            FOR  ${row}  IN RANGE  1  ${number_of_rows}+1
                ${planned_value_xpath}  Catenate  SEPARATOR=  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[${row}]/td[4]/
                ...  cem-parameter-input/cem-number-input/ot-field/div/ot-input-number
                ${status}  Run Keyword And Return Status  Page Should Contain Element  ${planned_value_xpath}
                IF  ${status}
                    ${parameter_planned_value}  Get Value  ${planned_value_xpath}
                    Append To List  ${parameters_subobjects_rmod}  ${parameter_planned_value}
                END
            END
        END
    END

    RETURN  ${parameters_rmod}  ${parameters_subobjects_rmod}


Verify If NR Cells And NRCELLGRP Appear In CW
    FOR  ${created_cell_id}  IN  @{IDs_FOR_CELLS_CREATED}
        Wait Until Keyword Succeeds  30  5
        ...  Element Should Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${created_cell_id}"]/div/div[2]/div
        Log  Cell with id: ${created_cell_id} is visible in CW [OK]  console=true
    END
    ${cloned_group_id}  Get The First Cloned NRCELLGRP Id
    Wait Until Keyword Succeeds  30  5
    ...  Element Should Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELLGRP-${cloned_group_id}"]
    Log  NRCELLGRP-${cloned_group_id} was created!  console=true


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__Cloud_Clone_Radio_Configuration


TC Teardown
    VDU WebEM Teardown
    Common VDU Teardown
