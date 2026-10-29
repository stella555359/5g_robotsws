*** Settings ***
Documentation
    ...  This test case is created to perform WCDMA RAT deleted.
    ...  Verify if LWG cells exists on SBTS.
    ...  Open Commissioning Wizard menu
    ...  Deleting WCDMA RAT from RAT delete button.
    ...  Validate plan.
    ...  Activate plan without errors.
    ...  Verify all cells to be enabled and no alarms to be visible on SBTS.
    ...  Upload initial SCF on SBTS.
    ...  Open Commissioning Wizard menu.
    ...  Deleting WCDMA RAT from Step by Step.
    ...  Validate plan.
    ...  Activate plan without errors.
    ...  Verify all cells to be enabled and no alarms to be visible on SBTS.
    ...  Upload initial SCF on SBTS.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900  # Timeout for SBTS to recover.


*** Keywords ***
TC__WebEM__Wizard_Deleting_WCDMA_RAT
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23296
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 27.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23296 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags  CA-WebEM  OWNER-nicolae-marcel.caragel@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22

    Step1: Verify If WCDMA Exist And Open Commissioning Wizard Menu
    Step2: Deleting WCDMA RAT From RAT Delete Button
    Step3: Deleting WCDMA RAT From Step-by-Step View


Step1: Verify If WCDMA Exist And Open Commissioning Wizard Menu
    Log  Step1: Verify if WCDMA exist and open Commissioning Wizard menu  console=true
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  Log  WCDMA cells exist, test will be continue!  console=true
    ...  ELSE
    ...  Fail  WCDMA cells does not exist, test case should be performed on a platform with WCDMA!
    Run Keyword If  ${SCF_COUNT_LTE} and ${SCF_COUNT_GSM}
    ...  Log  LTE and GSM cells exist, test will be continue!  console=true
    ...  ELSE
    ...  Fail  LTE or GSM cells does not exist, test case should be performed on a platform with LWG!
    Open Commissioning Wizard Menu


Step2: Deleting WCDMA RAT From RAT Delete Button
    Log  Step2: Deleting WCDMA RAT from RAT delete button  console=true
    Log  Delete RAT button is pushed!  console=true
    Wait Until Element Is Visible  //button[@ui-tooltip='Delete RAT']  300
    Wait Until Element Is Clicked  //button[@ui-tooltip='Delete RAT']  120
    Log  WCDMA RAT will be choose to be deleted!  console=true
    Wait Until Element Is Clicked
    ...  xpath:/html/body/div[1]/div/div/ui-modal-renderer/delete-rat-modal/ui-modal/div/div/div[2]/div/ui-body/div[1]/div[1]/div/div[3]/label
    ...  120  3
    Wait Until Element Is Clicked  //*[contains(@a-text, 'Delete')]  120
    Wait Until Element Is Visible  //*[contains(text(), 'Operation succeed')]  300
    Log  'Operation succeed' message appeared!  console=true
    Click Element  xpath=//*[contains(@a-text, 'Close')]
    Validate/Activate Plan And Verify SBTS
    Restore WCDMA RAT


Step3: Deleting WCDMA RAT From Step-by-Step View
    Log  Step3: Deleting WCDMA RAT from Step-by-Step View  console=true
    Open Commissioning Wizard Menu
    Wait Until Element Is Visible  xpath=//*[contains(@heading, 'Steps')]  120
    Click Element  xpath=//*[contains(@heading, 'Steps')]
    Click Element  xpath=//*[contains(@title, 'Cells Configuration')]
    Click Element  xpath=//*[contains(@title, 'WCDMA')]
    Click Element  xpath=//*[contains(@title, 'Basic Cell Settings')]
    Wait Until Element Is Visible  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]/div/modal-body/wizard-steps-modal-body/div  120
    Sleep  5s
    ${number}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]/div/modal-body/
    ...  wizard-steps-modal-body/div/div[2]/div/cell-definition/div/wcdma-cell-definition/div/wizard-expandable-panel
    ${number_of_cells}  SeleniumLibrary.Get Element Count  ${number}
    ${button}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]/div/modal-body/wizard-steps-modal-body
    ...  /div/div[2]/div/cell-definition/div/wcdma-cell-definition/div/wizard-expandable-panel/ui-expandable-panel/div/div/div/div[2]/
    ...  ui-expandable-panel-header-right/ui-button/button
    ${checkbox}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/ui-modal-renderer/remove-cell-object-modal/ui-modal/div/div/div[2]/
    ...  div/ui-body/div[2]/div[2]/n-checkbox/div/label/span
    FOR  ${cell}  IN RANGE  1  ${number_of_cells}+1
        Click Element  ${button}
        Wait Until Element Is Visible  xpath=//*[contains(@title, 'WCDMA Cell Removal')]  60
        ${status}  Run Keyword And Return Status
        ...  Wait Until Element Is Visible  //*[contains(text(), 'Remove whole WCDMA configuration')]  20
        Run Keyword If  ${status}
        ...  Run Keywords
        ...  Click Element  ${checkbox}
        ...  AND
        ...  Click Element  xpath=//*[contains(@a-text, 'OK')]
        ...  AND
        ...  Wait Until Element Is Visible  //*[contains(text(), 'There are no WCDMA cells added yet')]  60
        ...  AND
        ...  Log  Cell number ${cell} is deleted![OK]  console=true
        ...  AND
        ...  Log  All cells are deleted![OK]  console=true
        ...  ELSE
        ...  Run Keywords
        ...  Click Element  xpath=//*[contains(@a-text, 'OK')]
        ...  AND
        ...  Log  Cell number ${cell} is deleted![OK]  console=true
    END
    Click Element  xpath=//*[contains(@a-title, 'Done')]
    Validate/Activate Plan And Verify SBTS
    Restore WCDMA RAT


Validate/Activate Plan And Verify SBTS
    Log  Validate plan will be performed!  console=true
    Wait Until Element Is Visible  xpath=//*[contains(@a-title, 'Validate Plan')]  300
    Wait Until Element Is Clicked  //*[contains(@a-title, 'Validate Plan')]  120
    Log  Activate plan will be performed!  console=true
    Wait Until Element Is Clicked  //*[contains(@a-title, 'Activate Plan')]  300
    Wait Until Element Is Visible  xpath:/html/body/div[1]/div/div/ui-modal-renderer/deploy-plan-modal-component/ui-modal/div/div  300
    Wait Until Element Is Clicked  //*[contains(@a-title, 'Execute')]  120
    Wait Until Element Is Visible  //*[contains(text(), 'This procedure will cause BTS reset')]  300
    Wait Until Element Is Clicked  //*[contains(@a-title, 'Execute')]  120
    Wait Until Element Is Visible  //*[contains(text(), 'Operation finished successfully')]  ${RECOVERY_TIMEOUT}
    Log  'Operation finished successfully' message is visible!  console=true
    Click Element  xpath=//*[contains(@a-text, 'Close')]
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Close BTS Start-up View
    Wait Until Keyword Succeeds  300  10
    ...  Go To Site View
    Log  Verify if WCDMA cells exists!  console=true
    ${status_rat}  Run Keyword And Return Status
    ...  Element Should Not Be Visible  //*[contains(text(), 'WCDMA cells')]
    Run Keyword If  ${status_rat}
    ...  Log  WCDMA cells are not exists on SBTS![OK]  console=true
    ...  ELSE
    ...  Fail  WCDMA cells are still exists![NOK]
    Log  Wait for all cells to be enabled!  console=true
    ${status_cells}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells Without WCDMA Cells  ${ENABLED}
    Run Keyword If  ${status_cells}
    ...  Log  All cells are enabled![OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells are enabled![NOK]
    Log  Verify active alarms!  console=true
    Assert Alarm Inactive  faultId=${FAULT_7319}[fault_id]  timeout=300
    ${list_of_active_alarms}  Admin Check Active Alarms TAF
    ${length}  Get Length  ${list_of_active_alarms}
    Run Keyword If  ${length}>0
    ...  Fail  Unexpected alarms exist: ${list_of_active_alarms}


Check All Cells Without WCDMA Cells
    [Arguments]  ${operational_state}

    Run Keyword If  ${SCF_COUNT_NR}
    ...  Assert Every  NRCEL  operationalState=${operational_state}  timeout=60
    Run Keyword If  ${SCF_COUNT_LTE}
    ...  Assert Every  LNCEL  operationalState=${operational_state}  timeout=60
    Run Keyword If  ${SCF_COUNT_GSM}
    ...  Assert Every  GNCEL  operationalState=${operational_state}  timeout=60


Restore WCDMA RAT
    Log  Restore WCDMA RAT and verify cells on SBTS  console=true
    Admin Get Bts_id And Perform Commissioning  ${COMMISSIONING_PATH}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Close BTS Start-up View
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells


TC Setup
    Common Test Setup  tc_name=WebEM__Wizard_Deleting_WCDMA_RAT
    WebEM Setup


TC Teardown
    Run Keyword If Test Failed
    ...  Restore WCDMA RAT
    WebEM Teardown
    Common Test Teardown
