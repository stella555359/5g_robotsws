*** Settings ***
Documentation
    ...  Open Commissioning Wizard menu and verify if the page is fully loaded.
    ...  Create Plan and save SCF file configuration only.
    ...  SCF is saved in test result directory.
    ...  Delete plan.
    ...  Create delta plan and add one NR cell group.
    ...  Save delta plan to SCF file.
    ...  SCF is saved in test result directory.
    ...  Save delta configuration with current plan.
    ...  SCF is saved in test result directory.
    ...  Delete delta plan.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__CW_Save_configuration_plan
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26712
    ...
    ...  ******************
    ...  - 06.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26712 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  SW-SBTS24  FEATURE-CB005866-E

    Step0: Set Preconditions
    Step1: Open Commissioning Wizard
    Step2: Create Plan And Save SCF File Configuration Only
    Step3: Create Delta Plan And Save Delta Plan To SCF File
    Step4: Save Delta Configuration With Current Plan


Step0: Set Preconditions
    ${date}  Get Current Date  result_format=%Y%m%d
    Set Test Variable  ${DATE}


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Open Commissioning Wizard


Step2: Create Plan And Save SCF File Configuration Only
    Log  \nStep2: Create plan and save SCF file configuration only  console=true
    Wait Until Element Is Clicked  //span[contains(text(), "Create Plan")]  120
    Wait Until Keyword Succeeds  120  5
    ...  Input Text  //*[@id="webem-pe-create-plan-plan-name-input"]  NEW-PLAN-1
    Log  Input NEW-PLAN-1 text as plan name!  console=true
    Click Element  //*[contains(@label, 'Duplicate plan from:')]/div/div[2]
    Log  Duplicate plan from current plan was performed!  console=true
    Wait Until Element Is Clicked  //span[contains(@class, "p-button-label ng-star-inserted") and contains(text(), 'OK')]  120
    Sleep  30s  Time for plan to be updated!
    Click Element  //*[@id="webem-parameter-editor-menu-save-plan-button"]
    Log  Save plan button was pushed!  console=true
    Click Element  //*[@id="Save SCF - configuration only"]
    Log  Save SCF - configuration only was pushed!  console=true
    Wait Until Element Is Clicked  //span[contains(@class, "p-button-label ng-star-inserted") and contains(text(), 'OK')]  60
    Move SCF File In Test Results Directory  Plan_configuration
    Wait Until Element Is Clicked  //span[contains(text(), "Delete Plan")]
    Wait Until Element Is Clicked  //*[@id="webem-parameter-editor-menu-dialog"]/div/div/div[3]/button[2]  90


Step3: Create Delta Plan And Save Delta Plan To SCF File
    Log  \nStep3: Create delta plan and save delta plan to SCF file  console=true
    Create Delta Plan For CBTS
    Log  Add one NR cell group!  console=true
    Click Element  //*[contains(@aria-label, 'NR Cell Group Settings')]
    Click Element  //*[contains(@class, "mdi mdi-plus-thick p-button-icon ng-star-inserted")]
    Log  NR cell group was added!  console=true
    Save Plan From Commissioning Wizard
    Click Element  //*[@id="webem-parameter-editor-menu-save-plan-button"]
    Log  Save plan button was pushed!  console=true
    Click Element  //*[@id="Save Delta SCF - delta configuration only"]
    Log  Save Delta SCF - delta configuration only was pushed!  console=true
    Wait Until Element Is Clicked  //span[contains(@class, "p-button-label ng-star-inserted") and contains(text(), 'OK')]  60
    Move SCF File In Test Results Directory  Delta_configuration


Step4: Save Delta Configuration With Current Plan
    Log  \nStep4: Save delta configuration with current plan  console=true
    Click Element  //*[@id="webem-parameter-editor-menu-save-plan-button"]
    Log  Save plan button was pushed!  console=true
    Click Element  //*[@id="Save Delta SCF with current configuration"]
    Log  Save Delta SCF with current configuration was pushed!  console=true
    Wait Until Element Is Clicked  //span[contains(@class, "p-button-label ng-star-inserted") and contains(text(), 'OK')]  60
    Move SCF File In Test Results Directory  Delta_with_current_configuration


Move SCF File In Test Results Directory
    [Arguments]  ${scf_name}

    Wait Until Created  /home/ute/Downloads/${scf_name}_scf*${DATE}-*.xml  timeout=120s
    Move File  /home/ute/Downloads/${scf_name}_scf*${DATE}-*.xml  ${TEST_RESULTS_DIR}/SCFs/${scf_name}_scf_MRBTS-${VDU_MRBTS_ID}_${DATE}.xml
    Log  SCF was saved in location ${TEST_RESULTS_DIR}/SCFs/${scf_name}_scf_MRBTS-${VDU_MRBTS_ID}_${DATE}.xml  console=true
    ${scf_content}  OperatingSystem.Get File  ${TEST_RESULTS_DIR}/SCFs/${scf_name}_scf_MRBTS-${VDU_MRBTS_ID}_${DATE}.xml
    Should Not Be Empty  ${scf_content}  SCF file is empty![NOK]
    Should Contain  ${scf_content}  raml
    Log  SCF file is not empty and stores data in RAML format![OK]  console=true


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Save_configuration_plan


TC Teardown
    Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown
