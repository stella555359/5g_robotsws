*** Settings ***
Documentation
    ...  Open Commissioning Wizard menu and verify if the page is fully loaded.
    ...  Select Create delta plan.
    ...  Choose add New Radio Module and input the radio module name wanted.
    ...  Mouse over the name and verify HW data sheets to be visible correctly as in global variables.
    ...  Verify if instance ID from created Radio Module is correct.
    ...  Save the plan.
    ...  Open parameter editor and change prodCodePlanned parameter for created Radio Module to be 1234.
    ...  Going back to CW and verify if unknown name and PC 1234 is visible on Radio module.
    ...  Open parameter editor and change prodCodePlanned parameter for created Radio Module to be empty.
    ...  Going back to CW and verify if unknown name and PC - is visible on Radio module.
    ...  Open parameter editor and change prodCodePlanned parameter for created Radio Module to be inital value.
    ...  Going back to CW and verify if initial values of name and PC is visible on Radio module.
    ...  Verify highlighted Radio Module when a cell is selected from site view.
    ...  Verify highlighted Radio Module and NRCELL when a cell is selected from step-by-step.
    ...  Delete created Radio Module.
    ...  Delete the first existing Radio module and verify confirmation dialog.
    ...  Cancel the operation.
    ...  Delete Radio Module 1 without checkbox selected and verify if key icon is visible and specific NRCELL is deleted.
    ...  Verify if radio module was deleted.
    ...  Delete Radio Module 1 with checkbox selected and verify if key icon is visible and specific NRCELL and NRCELLGROUP are deleted.
    ...  Verify if radio module was deleted.
    ...  Delete created delta plan.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${RADIO_MODULE_NAME}  AEQP  # Radio nodule name wanted to be created. This variable is mandatory.
${PRODUCT_CODE}  475238A  # Product code of wanted radio module from HW data sheets. This variable is mandatory.
${DUPLEX_MODE}  TDD  # Duplex mode of wanted radio module from HW data sheets. Only if exist.
${SUPPORTED_NR_BANDS}  78  # Supported nr bands of wanted radio module from HW data sheets. Only if exist.
${MASSIVE_MIMO}  Yes  # Massive mode of wanted radio module from HW data sheets. Only if exist.
${CHAINING_SUPPORTED}  No  # Chaining supported of wanted radio module from HW data sheets. Only if exist.
${SUPPORTED_EXTENSION_MODULES}  ${EMPTY}  # Supported extension modules of wanted radio module from HW data sheets. Only if exist.
${EXTENSION_MODULE}  ${EMPTY}  # Extension module of wanted radio module from HW data sheets. Only if exist.


*** Keywords ***
TC__WebEM__vDU__CW_Step_by_Step_view_Adding_new_radios
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26204
    ...
    ...  ******************
    ...  - 09.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26204 - Initial TAT creation
    ...  - 27.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27638 - Many xpaths have changed
    ...  - 02.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27862 - Remove SFP feature according to req OAM_REQ_WEBEM_4715
    ...  - 29.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28453 - Delete xpath was changed
    ...  - 06.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28705 - Wrench button is not visible in planned configuration after CB012840
    ...  - 03.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28957 - Xpath was changed for deleting radio module

    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  FEATURE-CB005866-A

    Step1: Open Commissioning Wizard
    Step2: Create Plan
    Step3: Add A New Radio Module And Verify HW Data Sheet
    Step4: Verify Instance ID From Radio Module
    Step5: Save And Verify ProdCodePlanned From PE To Be A Random Number And To Be Empty
    Step6: Verify Highlighted Radio Module When A Cell Is Selected
    Step7: Delete Created Radio Module
    Step8: Delete One Existing Radio Module And Verify Confirmation Dialog
    Step9: Delete Created Plan


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Open Commissioning Wizard


Step2: Create Plan
    Log  \nStep2: Create plan  console=true
    Create Duplicate Plan For CBTS


Step3: Add A New Radio Module And Verify HW Data Sheet
    Log  \nStep3: Add a new Radio Module and verify HW data sheet  console=true
    Click Element  //*[contains(@class, 'cem-radio-ald-cell')]/table/thead/tr/th[1]/cem-site-view-label-header-panel/div/div[2]/button/span[1]
    Log  Input ${RADIO_MODULE_NAME}...  console=true
    Input Text  //*[@id="laf-component"]/div/div/input  ${RADIO_MODULE_NAME}
    Mouse Over  //*[@id="laf-component"]/div/ul/li[1]/a/span
    Sleep  5s  Time for HW data sheets to be visible.
    Page Should Contain  Radio module name
    Page Should Contain  ${RADIO_MODULE_NAME}
    Log  Radio module name with value ${RADIO_MODULE_NAME} is visible!  console=true
    Page Should Contain  Product code
    Page Should Contain  ${PRODUCT_CODE}
    Log  Product code with value ${PRODUCT_CODE} is visible!  console=true
    Verify The Occasional Parameters From HW Data Sheets  ${DUPLEX_MODE}  Duplex mode
    Verify The Occasional Parameters From HW Data Sheets  ${SUPPORTED_NR_BANDS}  Supported NR bands
    Verify The Occasional Parameters From HW Data Sheets  ${MASSIVE_MIMO}  Massive MIMO
    Verify The Occasional Parameters From HW Data Sheets  ${CHAINING_SUPPORTED}  Chaining supported
    Verify The Occasional Parameters From HW Data Sheets  ${SUPPORTED_EXTENSION_MODULES}  Supported extension modules
    Verify The Occasional Parameters From HW Data Sheets  ${EXTENSION_MODULE}  Extension module
    Click Element  //*[@id="laf-component"]/div/ul/li[1]/a/span
    Log  Radio Module ${RADIO_MODULE_NAME} was added!  console=true


Step4: Verify Instance ID From Radio Module
    Log  \nStep4: Verify instance ID from Radio Module  console=true
    ${rmods_statuses}  vdu.Get Rmods Status
    ${rmods_number}  Get Length  ${rmods_statuses}
    ${id_for_created_rf}  Evaluate  ${rmods_number} + 1
    Element Should Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${id_for_created_rf}"]
    ${created_rmod_id}  Get Text
    ...  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${id_for_created_rf}"]/ot-card/p-card/div/div/div/div/div[1]/div[1]/div/div
    ${rmod_name}  Get Text  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${id_for_created_rf}"]/ot-card/p-card/div/div/div/div/div[1]/div[2]
    Run Keyword If  'RMOD-${id_for_created_rf}' == '${created_rmod_id}' and '${RADIO_MODULE_NAME}' == '${rmod_name}'
    ...  Log  Created radio module with id ${id_for_created_rf} and name ${RADIO_MODULE_NAME} is visible in CW![OK]  console=true
    ...  ELSE
    ...  Fail  Created radio module with id ${id_for_created_rf} and name ${RADIO_MODULE_NAME} is not visible in CW![NOK]
    Click Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/${created_rmod_id}"]/ot-card/p-card/div/div/div/div/div[1]/div[2]
    Set Test Variable  ${CREATED_RMOD_ID}


Step5: Save And Verify ProdCodePlanned From PE To Be A Random Number And To Be Empty
    Log  \nStep5: Save and verify prodCodePlanned from PE to be a random number and to be empty  console=true
    Wait Until Element Is Clicked  //*[@id="save-btn"]
    Log  Saving plan is ongoing...  console=true
    Wait Until Element Is Clicked  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/${CREATED_RMOD_ID}"]/ot-card/p-card/div/div/div/div/div[1]/div[2]  300
    Element Should Be Disabled  //*[@id="save-btn"]
    Log  The plan is saved successfully!  console=true
    Change ProdCodePlanned For Created Radio Module With 1234 Value And Verify In CW
    Change ProdCodePlanned For Created Radio Module With Empty Value And Verify In CW
    Change ProdCodePlanned For Created Radio Module With Initial Value And Verify In CW


Step6: Verify Highlighted Radio Module When A Cell Is Selected
    Log  \nStep6: Verify highlighted Radio Module when a cell is selected  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, "NR Cell and Cell Mapping")]
    Set Nr Cell Id And Nrcell Group Id Depends On First RMOD
    Log  Verify highlighted Radio Module from site view when the cell is selected from site view!  console=true
    Click Element  //*[@id="${CONFIG_CELL}"]
    ${rmod_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1"]/ot-card  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${rmod_class}  highlighted  Radio Module RMOD-1 was not highlighted after NRCELL-${CELL_ID} was selected from site view!
    Log  Radio Module RMOD-1 was highlighted after NRCELL-${CELL_ID} was selected from site view!  console=true
    Log  Verify highlighted Radio Module and nrcell from site view when the cell is selected from step-by-step!  console=true
    Input Text  //*[contains(@class, 'p-tree-filter-container ng-star-inserted')]/input  NRCELL-${CELL_ID}
    Click Element  //span[contains(@class, 'ot-highlight-text') and contains(text(), 'NRCELL-${CELL_ID}')]
    ${rmod_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1"]/ot-card  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${rmod_class}  highlighted  Radio Module RMOD-1 was not highlighted after NRCELL-${CELL_ID} was selected from step-by-step!
    Log  Radio Module RMOD-1 was highlighted after NRCELL-${CELL_ID} was selected from step-by-step!  console=true
    ${cell_class}  Get Element Attribute  //*[@id="${CONFIG_CELL}"]/div  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${cell_class}
    ...  selected
    ...  NRCELL-${CELL_ID} from site view was not highlighted after NRCELL-${CELL_ID} was selected from step-by-step!
    Log  NRCELL-${CELL_ID} from site view was highlighted after NRCELL-${CELL_ID} was selected from step-by-step!  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, "Radio Module Settings")]


Step7: Delete Created Radio Module
    Log  \nStep7: Delete created Radio Module  console=true
    ${delete_button}  Set Variable If  '${VDU_ACTIVE_SW_RELEASE}' == 'vDUCNF25R2'
    ...  //*[contains(@aria-label, "${RADIO_MODULE_NAME}${SPACE}${CREATED_RMOD_ID}")]/span/span/div/div[2]/p-button[2]/button/span[1]
    ...  //*[contains(@aria-label, "${RADIO_MODULE_NAME}${SPACE}${CREATED_RMOD_ID}")]/span/span/div/div[2]/p-button[3]/button/span[1]
    Wait Until Element Is Clicked  ${delete_button}
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Not Contain Element  //*[contains(@aria-label, "${RADIO_MODULE_NAME}${SPACE}${CREATED_RMOD_ID}")]
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Not Contain Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/${CREATED_RMOD_ID}"]
    Log  Radio module created was deleted!  console=true


Step8: Delete One Existing Radio Module And Verify Confirmation Dialog
    Log  \nStep8: Delete one existing Radio module and verify confirmation dialog  console=true
    Press Keys  //*[contains(@class, 'p-tree-filter-container ng-star-inserted')]/input  CTRL+a+BACKSPACE
    Cancel Delete Action On First Radio Module
    Delete First Radio Module Without Selecting Checkbox
    Delete Actual Plan Via WebEM
    Create Duplicate Plan For CBTS
    Delete First Radio Module With Checkbox Selected


Step9: Delete Created Plan
    Log  \nStep9: Delete created plan  console=true
    Delete Actual Plan Via WebEM


Verify The Occasional Parameters From HW Data Sheets
    [Arguments]  ${parameter_value}  ${parameter_name}

    Run Keyword If  '${parameter_value}' != '${EMPTY}'
    ...  Run Keywords
    ...  Page Should Contain  ${parameter_name}
    ...  AND
    ...  Page Should Contain  ${parameter_value}
    ...  AND
    ...  Log  ${parameter_name} with value ${parameter_value} is visible!  console=true
    ...  ELSE
    ...  Log  ${parameter_name} doesn't exist!  console=true


Change ProdCodePlanned For Created Radio Module With 1234 Value And Verify In CW
    Log  Change prodCodePlanned for created Radio Module with 1234 value and verify in CW  console=true
    Log  Open Parameter Editor  console=true
    Wait Until Element Is Clicked  //*[@id="/parameter-editor"]
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  prodCodePlanned
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  ENTER
    Sleep  5s  Time for page to be loaded.
    ${initial_trs_pe}  SeleniumLibrary.Get Element Count  //*[contains(@class, 'p-element p-treetable-tbody')]/tr
    FOR  ${tr}  IN RANGE  1  ${initial_trs_pe}+1
        ${product_code_pe}  Get Value
        ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[${tr}]/td[4]/cem-parameter-input/cem-string-input/ot-field/div/input
        Run keyword if  '${product_code_pe}'=='${PRODUCT_CODE}'
        ...  Run Keywords
        ...  Wait Until Keyword Succeeds  30  5
        ...  Input Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[${tr}]/td[4]/cem-parameter-input/cem-string-input/ot-field/div/input
        ...  1234
        ...  AND
        ...  Exit For Loop
    END
    Log  Parameter prodCodePlanned was changed with 1234 value!  console=true
    Wait Until Element Is Clicked  //button[@label="Save"]
    Wait Until Element Is Clicked  //*[@id="/commissioning-wizard"]  120
    Wait Until Element Is Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/${CREATED_RMOD_ID}"]  600
    Log  Commissioning Wizard page is fully loaded!  console=true
    ${actual_title}  Wait Until Keyword Succeeds  30  5
    ...  Get Text  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/${CREATED_RMOD_ID}"]/ot-card/p-card/div/div/div/div/div[1]/div[2]
    ${actual_product_code}  Wait Until Keyword Succeeds  30  5
    ...  Get Text  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/${CREATED_RMOD_ID}"]/ot-card/p-card/div/div/div/div/div[1]/div[4]/div
    Run Keyword If  '${actual_title}' == 'unknown' and '${actual_product_code}' == 'PC:${SPACE}1234'
    ...  Log  Unknown name and PC: 1234 is visible on created Radion Module![OK]  console=true
    ...  ELSE
    ...  Fail  Unknown name and PC: 1234 is not visible on created Radion Module![NOK]


Change ProdCodePlanned For Created Radio Module With Empty Value And Verify In CW
    Log  Change prodCodePlanned for created Radio Module with empty value and verify in CW  console=true
    Log  Open Parameter Editor  console=true
    Wait Until Element Is Clicked  //*[@id="/parameter-editor"]
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  prodCodePlanned
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  ENTER
    Sleep  5s  Time for page to be loaded.
    ${initial_trs_pe}  SeleniumLibrary.Get Element Count  //*[contains(@class, 'p-element p-treetable-tbody')]/tr
    FOR  ${tr}  IN RANGE  1  ${initial_trs_pe}+1
        ${product_code_pe}  Get Value
        ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[${tr}]/td[4]/cem-parameter-input/cem-string-input/ot-field/div/input
        Run keyword if  '${product_code_pe}'=='1234'
        ...  Run Keywords
        ...  Wait Until Keyword Succeeds  30  5
        ...  Press Keys  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[${tr}]/td[4]/cem-parameter-input/cem-string-input/ot-field/div/input
        ...  CTRL+a+BACKSPACE
        ...  AND
        ...  Exit For Loop
    END
    Log  Parameter prodCodePlanned was changed with an empty value!  console=true
    Wait Until Element Is Clicked  //button[@label="Save"]
    Wait Until Element Is Clicked  //*[@id="/commissioning-wizard"]  120
    Wait Until Element Is Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/${CREATED_RMOD_ID}"]  600
    Log  Commissioning Wizard page is fully loaded!  console=true
    ${actual_title}  Wait Until Keyword Succeeds  30  5
    ...  Get Text  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/${CREATED_RMOD_ID}"]/ot-card/p-card/div/div/div/div/div[1]/div[2]
    ${actual_product_code}  Wait Until Keyword Succeeds  30  5
    ...  Get Text  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/${CREATED_RMOD_ID}"]/ot-card/p-card/div/div/div/div/div[1]/div[4]/div
    Run Keyword If  '${actual_title}' == 'unknown' and '${actual_product_code}' == 'PC:${SPACE}-'
    ...  Log  Unknown name and PC: - is visible on created Radion Module![OK]  console=true
    ...  ELSE
    ...  Fail  Unknown name and PC: - is not visible on created Radion Module![NOK]


Change ProdCodePlanned For Created Radio Module With Initial Value And Verify In CW
    Log  Change prodCodePlanned for created Radio Module with initial value and verify in CW  console=true
    Log  Open Parameter Editor  console=true
    Wait Until Element Is Clicked  //*[@id="/parameter-editor"]
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  prodCodePlanned
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  ENTER
    Sleep  5s  Time for page to be loaded.
    ${initial_trs_pe}  SeleniumLibrary.Get Element Count  //*[contains(@class, 'p-element p-treetable-tbody')]/tr
    FOR  ${tr}  IN RANGE  1  ${initial_trs_pe}+1
        ${product_code_pe}  Get Value
        ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[${tr}]/td[4]/cem-parameter-input/cem-string-input/ot-field/div/input
        Run keyword if  '${product_code_pe}'=='${EMPTY}'
        ...  Run Keywords
        ...  Wait Until Keyword Succeeds  30  5
        ...  Input Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[${tr}]/td[4]/cem-parameter-input/cem-string-input/ot-field/div/input
        ...  ${PRODUCT_CODE}
        ...  AND
        ...  Exit For Loop
    END
    Log  Parameter prodCodePlanned was changed with initial value!  console=true
    Wait Until Element Is Clicked  //button[@label="Save"]
    Wait Until Element Is Clicked  //*[@id="/commissioning-wizard"]  120
    Wait Until Element Is Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/${CREATED_RMOD_ID}"]  600
    Log  Commissioning Wizard page is fully loaded!  console=true
    ${actual_title}  Wait Until Keyword Succeeds  30  5
    ...  Get Text  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/${CREATED_RMOD_ID}"]/ot-card/p-card/div/div/div/div/div[1]/div[2]
    ${actual_product_code}  Wait Until Keyword Succeeds  30  5
    ...  Get Text  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/${CREATED_RMOD_ID}"]/ot-card/p-card/div/div/div/div/div[1]/div[4]/div
    Run Keyword If  '${actual_title}' == '${RADIO_MODULE_NAME}' and '${actual_product_code}' == 'PC:${SPACE}${PRODUCT_CODE}'
    ...  Log  ${RADIO_MODULE_NAME} name and PC: ${PRODUCT_CODE} is visible on created Radion Module![OK]  console=true
    ...  ELSE
    ...  Fail  ${RADIO_MODULE_NAME} name and PC: ${PRODUCT_CODE} is not visible on created Radion Module![NOK]


Cancel Delete Action On First Radio Module
    Log  Cancel delete action on first Radio Module  console=true
    Wait Until Element Is Clicked
    ...  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1"]/ot-card/p-card/div/div/div/div/div[1]/div[1]/div[2]/p-button[2]/button/span[1]
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain  Do you want to delete
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain  Delete related cell(s) and cell group(s)
    Click Element  //*[@id="laf-component"]/div/div/div[3]/div/p-button[2]/button/span
    Log  Delete action was cancel![OK]  console=true


Delete First Radio Module Without Selecting Checkbox
    Log  Delete first Radio Module without selecting checkbox  console=true
    Wait Until Element Is Clicked
    ...  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1"]/ot-card/p-card/div/div/div/div/div[1]/div[1]/div[2]/p-button[2]/button/span[1]
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain  Do you want to delete
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain  Delete related cell(s) and cell group(s)
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span
    Log  Radio Module was deleted!  console=true
    Log  Verify if cell is not still visible!  console=true
    ${cell_status}  Run Keyword And Return Status
    ...  Page Should Not Contain  NRCELL-${CELL_ID}
    Run Keyword If  ${cell_status}
    ...  Log  NRCELL-${CELL_ID} on RMOD-1 is not visible anymore![OK]  console=true
    ...  ELSE
    ...  Fail  NRCELL-${CELL_ID} on RMOD-1 is still visible![NOK]
    Log  Verify if nr group cell is still visible!  console=true
    ${group_status}  Run Keyword And Return Status
    ...  Page Should Contain  NRCELLGRP-${CELL_GROUP_ID}
    Run Keyword If  ${group_status}
    ...  Log  NRCELLGRP-${CELL_GROUP_ID} on RMOD-1 is still visible![OK]  console=true
    ...  ELSE
    ...  Fail  NRCELLGRP-${CELL_GROUP_ID} on RMOD-1 is not visible anymore![NOK]
    Log  Verify if radio module is not visible!  console=true
    ${rmod_status}  Run Keyword And Return Status
    ...  Page Should Not Contain Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1"]
    Run Keyword If  ${rmod_status}
    ...  Log  RMOD is not visible anymore![OK]  console=true
    ...  ELSE
    ...  Fail  RMOD is still visible![NOK]


Delete First Radio Module With Checkbox Selected
    Log  Delete first Radio Module with checkbox selected  console=true
    Wait Until Element Is Clicked
    ...  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1"]/ot-card/p-card/div/div/div/div/div[1]/div[1]/div[2]/p-button[2]/button/span[1]
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain  Do you want to delete
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain  Delete related cell(s) and cell group(s)
    Click Element  //*[@id="laf-component"]/div/div/div[2]/blocks-delete-check-dialog/div[2]/div/p-checkbox/div/div[2]
    Log  Checkbox was selected!  console=true
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span
    Log  Radio Module was deleted!  console=true
    Log  Verify if cell is not still visible!  console=true
    ${cell_status}  Run Keyword And Return Status
    ...  Page Should Not Contain  NRCELL-${CELL_ID}
    Run Keyword If  ${cell_status}
    ...  Log  NRCELL-${CELL_ID} on RMOD-1 is not visible anymore![OK]  console=true
    ...  ELSE
    ...  Fail  NRCELL-${CELL_ID} on RMOD-1 is still visible![NOK]
    Log  Verify if nr group cell is not still visible!  console=true
    ${group_status}  Run Keyword And Return Status
    ...  Page Should Not Contain  NRCELLGRP-${CELL_GROUP_ID}
    Run Keyword If  ${group_status}
    ...  Log  NRCELLGRP-${CELL_GROUP_ID} on RMOD-1 is not visible anymore[OK]  console=true
    ...  ELSE
    ...  Fail  NRCELLGRP-${CELL_GROUP_ID} on RMOD-1 is still visible![NOK]
    Log  Verify if radio module is not visible!  console=true
    ${rmod_status}  Run Keyword And Return Status
    ...  Page Should Not Contain Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1"]
    Run Keyword If  ${rmod_status}
    ...  Log  RMOD is not visible anymore![OK]  console=true
    ...  ELSE
    ...  Fail  RMOD is still visible![NOK]


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Step_by_Step_view_Adding_new_radios


TC Teardown
    Run Keyword If Test Failed
    ...  Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown
