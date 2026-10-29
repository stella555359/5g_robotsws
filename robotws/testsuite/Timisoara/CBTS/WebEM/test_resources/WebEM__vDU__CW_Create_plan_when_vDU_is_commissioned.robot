*** Settings ***
Documentation
    ...  This TC is created to verify three types of plan creation.
    ...  First plan is created from scratch and all units are verified not to be detected.
    ...  Second plan is duplicated from another plan.
    ...  Third plan is created by detecting hardware.
    ...  Browser is closed and WebEM is set up again.
    ...  Radio Module and all types of ALDs are added.
    ...  After every addition, delta plan is validated and activated.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${RMOD_PRODUCT_NAME}  ${EMPTY}  # Mandatory! Product name for created RMOD.
${RMOD_PRODUCT_CODE}  ${EMPTY}  # Mandatory! Product code for created RMOD.
${RMOD_SERIAL_NUMBER}  ${EMPTY}  # Mandatory! Serial number for created RMOD.
${PRODUCT_CODE_ALD_RAE}  ${EMPTY}  # Mandatory! Product code for created ALDs-RAEs.
${SERIAL_NUMBER_ALD_RAE}  ${EMPTY}  # Mandatory! Serial number for created ALDs-RAEs.
${MECHANICAL_ANGLE_RAE}  ${EMPTY}  # Mandatory! Mechanical angle for created RAEs.
${PRODUCT_CODE_ALD_RET}  ${EMPTY}  # Mandatory! Product code for created ALDs-RETs.
${SERIAL_NUMBER_ALD_RET}  ${EMPTY}  # Mandatory! Serial number for created ALDs-RETs.
${PRODUCT_CODE_ALD_MHA}  ${EMPTY}  # Mandatory! Product code for created ALDs-MHAs.
${SERIAL_NUMBER_ALD_MHA}  ${EMPTY}  # Mandatory! Serial number for created ALDs-MHAs.


*** Keywords ***
TC__WebEM__vDU__CW_Create_plan_when_vDU_is_commissioned
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26701
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  10.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26701 - Initial TAT creation
    ...  ******************
    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  PHASE-CRT  FEATURE-CB005866-E

    Step0: TC Preconditions
    Step1: Open Commissioning Wizard
    Step2: Create Plan From Scratch
    Step3: Create A Copy Of A Staged Plan
    Step4: Create New Plan Based On Detected Hardware
    Step5: Add Radios And ALDs


Step0: TC Preconditions
    Log  \nStep0: TC preconditions.  console=true
    ${rmods_ids_list}  Create List
    ${rmods_types_list}  Create List
    ${nr_cells_names}  Create List
    ${rmods}  vdu.Get Rmods Status
    FOR  ${rmod}  IN  @{rmods}
        Append To List  ${rmods_ids_list}  ${rmod}[id]
        Append To List  ${rmods_types_list}  ${rmod}[product_name]
    END
    ${cells_info}  Get Vdu Cells Status
    FOR  ${cell}  IN  @{cells_info}
        Append To List  ${nr_cells_names}  ${cell}[name]
    END
    ${rmods_list_length}  Get Length  ${rmods}
    ${rmod_id}  Evaluate  ${rmods_list_length} + 1
    Set Test Variable  ${RMODS_IDS_LIST}
    Set Test Variable  ${RMODS_TYPES_LIST}
    Set Test Variable  ${NR_CELLS_NAMES}
    Set Test Variable  ${RMOD_ID}


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Open Commissioning Wizard


Step2: Create Plan From Scratch
    Log  \nStep2: Create plan from scratch  console=true
    Verify Number Of Existing Plans In Commissioning Wizard
    Wait Until Element Is Clicked  //*[contains(text(), "Create Plan")]  5  1
    Wait Until Element Is Clicked  //*[contains(text(), "Creation from scratch")]  5  1
    Wait Until Element Is Clicked  //*[@id="webem-pe-create-plan-panel-ok-button"]/button/span  5  1
    Log  Staged plan successfully created from scratch.  console=true
    Log  Verify units not to be detected.  console=true
    Wait Until Keyword Succeeds  10  2
    ...  Page Should Contain  RAN NIC
    Page Should Contain  RMOD-1
    ${text_locator}  Catenate  //*[contains(@class,'p-element secondary-title-row ot-text-ellipsis flex align-items-center ng-star-inserted')
    ...  and contains(text(),' unknown ')]
    Page Should Contain Element  ${text_locator}
    Log  Radio Module is unkwnown. [OK]  console=true
    Page Should Contain  ALDs
    Page Should Contain  NR Cells
    Page Should Contain  NR Cell Groups
    ${text_count}  Get Element Count  //*[contains(text(),' No data available')]
    Run Keyword If  ${text_count} < 4
    ...  Fail  Other modules are visible on page. [NOK]
    Log  RAN NIC, RMOD, ALDs, NR Cells, NR Cell Groups are not detected. [OK]  console=true
    Delete Actual Plan Via WebEM
    Log  Created plan from scratch was verified and deleted successfully. [OK]  console=true


Step3: Create A Copy Of A Staged Plan
    Log  \nStep3: Create a copy of a staged plan.  console=true
    Wait Until Element Is Clicked  //*[contains(text(), "Create Plan")]  5  1
    Wait Until Element Is Clicked  //*[contains(text(), "Duplicate plan from:")]  5  1
    Wait Until Element Is Clicked  //*[@id="webem-pe-create-plan-panel-ok-button"]/button/span  5  1
    Wait Until Keyword Succeeds  10  2
    ...  Page Should Contain  RAN NIC
    Page Should Contain  A-RINLINE2-B Capacity
    FOR  ${rmod_id}  IN  @{RMODS_IDS_LIST}
        Page Should Contain Element  //div[contains(text(),'RMOD-${rmod_id}')]
    END
    FOR  ${rmod_type}  IN  @{RMODS_TYPES_LIST}
        Page Should Contain Element  //div[contains(text(),'${rmod_type}')]
    END
    FOR  ${cell}  IN  @{NR_CELLS_NAMES}
        Page Should Contain Element  //*[contains(text(),'${cell}')]
    END
    Log  RAN NIC, RMODs, and NR CELLs are detected. [OK]  console=true
    Delete Actual Plan Via WebEM
    Log  Copied plan was verified and deleted successfully. [OK]  console=true


Step4: Create New Plan Based On Detected Hardware
    Log  \nStep4: Create new plan based on detected hardware.  console=true
    Wait Until Element Is Clicked  //*[contains(text(), "Create Plan")]  5  1
    Wait Until Element Is Clicked  //*[contains(text(), "Creation from detected or configured HW")]  5  1
    Wait Until Element Is Clicked  //*[@id="webem-pe-create-plan-panel-ok-button"]/button/span  5  1
    Log  Plan based on detected hardware was created. [OK]  console=true
    Log  Verify if RMODs are detected but other modules are not.  console=true
    Wait Until Keyword Succeeds  10  2
    ...  Page Should Contain  RAN NIC
    Page Should Contain Element  //span[contains(text(), " RAN NIC ")]/ot-instruction/div/span[contains(text(),'Unknown')]
    Log  RAN NIC is unkwnown. [OK]  console=true
    Page Should Contain  ALDs
    Page Should Contain  NR Cells
    Page Should Contain  NR Cell Groups
    ${text_count}  Get Element Count  //*[contains(text(),' No data available')]
    Run Keyword If  ${text_count} < 4
    ...  Fail  Other modules are visible on page. [NOK]
    Log  ALDs, NR CELLs and NR CELL Groups are not detected. [OK]  console=true
    FOR  ${rmod_id}  IN  @{RMODS_IDS_LIST}
        Page Should Contain Element  //div[contains(text(),'RMOD-${rmod_id}')]
    END
    FOR  ${rmod_type}  IN  @{RMODS_TYPES_LIST}
        Page Should Contain Element  //div[contains(text(),'${rmod_type}')]
    END
    Log  Radio Modules are detected. [OK]  console=true
    Delete Actual Plan Via WebEM
    Log  Created plan was verified and deleted successfully. [OK]  console=true
    Logout From CBTS
    Close Browser


Step5: Add Radios And ALDs
    Log  \nStep5: Add Radios and ALDs.  console=true
    VDU WebEM Setup
    Open Commissioning Wizard
    Add New Radio Module To Plan
    Add All Types Of ALDs To Plan


Verify Number Of Existing Plans In Commissioning Wizard
    Click Element  //*[contains(@class,'dropdown-container ng-star-inserted')]
    ${no_of_plans}  Get Element Count  //ul[@role='listbox']/p-dropdownitem
    ${plans_status}  Run Keyword And Return Status
    ...  Should Be Equal As Integers  ${no_of_plans}  3
    Run Keyword If  ${plans_status}
    ...  Fail  No of staged plans in WebEM are 3. Please delete at least one. [NOK]


Add New Radio Module To Plan
    Log  Add new Radio Module...  console=true
    Create Delta Plan For CBTS
    Click Element  //*[contains(@class, 'cem-radio-ald-cell')]/table/thead/tr/th[1]/cem-site-view-label-header-panel/div/div[2]/button/span[1]
    Log  Input ${RMOD_PRODUCT_NAME}...  console=true
    Input Text  //*[@id="laf-component"]/div/div/input  ${RMOD_PRODUCT_NAME} (${RMOD_PRODUCT_CODE})
    Click Element  //*[contains(text(),'${RMOD_PRODUCT_NAME} (${RMOD_PRODUCT_CODE})')]
    Page Should Contain  Administrative state
    Page Should Contain  Connectivity Check Enabled
    Page Should Contain  Legacy wide carrier mode
    Page Should Contain  Product code planned
    Page Should Contain  Serial number planned
    Click Element  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[2]/cem-parameter-input
    Click Element  //*[contains(text(),'Unlocked')]
    Input Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[5]/td[2]/cem-parameter-input/cem-string-input/ot-field/div/input
    ...  ${RMOD_SERIAL_NUMBER}
    Save Plan From Commissioning Wizard
    Page Should Contain  RMOD-${RMOD_ID}
    Log  New Radio Module was added.  console=true
    Validate And Activate Plan For CBTS


Add All Types Of ALDs To Plan
    Log  Adding ALD-RAE from step-by-step!  console=true
    Create Delta Plan For CBTS
    Click Element  //*[contains(@aria-label, 'Antenna Line Devices RAE')]
    Click Element  //*[contains(@class, "step-content")]/blocks-steps-rae-setting/div/div/cem-mod-list/p-panel/div/div//div[2]
    ${existing_alds}  vdu.Get Alds
    ${existing_alds_number}  Get Length  ${existing_alds}
    ${rae_ald_id}  Evaluate  ${existing_alds_number} + 1
    Configure ALD And RAEU  ${rae_ald_id}  ${RMOD_PRODUCT_NAME}  ${PRODUCT_CODE_ALD_RAE}  ${SERIAL_NUMBER_ALD_RAE}  ${MECHANICAL_ANGLE_RAE}
    Save Plan From Commissioning Wizard
    Validate And Activate Plan For CBTS

    Log  Adding ALD-RET from step-by-step is performing!  console=true
    Create Delta Plan For CBTS
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'Antenna Line Devices RET')]
    Click Element  //*[contains(@class, "step-content")]/blocks-steps-ret-setting/div/div/cem-mod-list/p-panel/div/div//div[2]
    ${ret_ald_id}  Evaluate  ${rae_ald_id} + 1
    Configure ALD And RETU  ${ret_ald_id}  ${RMOD_PRODUCT_NAME}  ${PRODUCT_CODE_ALD_RET}  ${SERIAL_NUMBER_ALD_RET}
    Save Plan From Commissioning Wizard
    Validate And Activate Plan For CBTS

    Log  Adding ALD-MHA from step-by-step is performing!  console=true
    Create Delta Plan For CBTS
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'Antenna Line Devices MHA')]
    Click Element  //*[contains(@class,'mdi mdi-plus-thick p-button-icon ng-star-inserted')]
    Scroll Element Into View  //span[contains(text(), "Nokia")]
    Wait Until Element Is Clicked  //span[contains(text(), "Nokia")]  10  2
    ${mha_ald_id}  Evaluate  ${ret_ald_id} + 1
    Configure ALD And MHA  ${mha_ald_id}  ${RMOD_PRODUCT_NAME}  ${PRODUCT_CODE_ALD_MHA}  ${SERIAL_NUMBER_ALD_MHA}
    Save Plan From Commissioning Wizard
    Validate And Activate Plan For CBTS


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Create_plan_when_vDU_is_commissioned


TC Teardown
    Run Keyword If Test Failed
    ...  Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown
