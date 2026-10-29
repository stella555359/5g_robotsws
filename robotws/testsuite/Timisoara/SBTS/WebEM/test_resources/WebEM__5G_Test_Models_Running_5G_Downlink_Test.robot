*** Settings ***
Documentation
    ...  This test case is created to perform 5G Downlink.
    ...  BTS is in the test dedicated state.
    ...  Operator opens Test Model view and goes to 5G downlink Test tab.
    ...  Operator opens 5G Downklink test.
    ...  Selects local NR cell to be tested and fill in the parameters: NRARFCN downlink, NRARFCN uplink, pMax and choose Test model.
    ...  Operator manually enter test results into Test Result section.
    ...  Operator stops the test.
    ...  Operator saves the test results into separate file, or to the existing commissioning report.
    ...  Deactivate test dedicated state mode.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1200  # Time for SBTS to recover.


*** Keywords ***
TC__WebEM__5G_Test_Models_Running_5G_Downlink_Test
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23225
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 11.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-23225 - Initial TAT creation
    ...  - 15.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-27278 - Xpaths are changed
    ...  - 24.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29024 - Update TC to work on more types of configurations
    ...  - 22.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29223 - Xpath is changed for release greater than 25R3
    ...  - 04.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30277 - Update TC to use only FDD cells

    Set Tags  CA-WebEM  OWNER-george.gheban@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  SW-SBTS24

    Step1: Activate TDS Mode
    Step2: Set Frequency Parameters For NR Cells
    Step3: Downling NR Cells
    Step4: Deactivate TDS Mode


Step1: Activate TDS Mode
    Log  \nStep1: Activate TDS mode  console=true
    Open Diagnostic Menu
    Wait Until Element Is Clicked  ${RESET_TO_TEST_DEDICATED_STATE}  60
    Sleep  5s  Time for page to be updated
    Run Keyword And Ignore Error  Close Diagnostic Menu
    Wait Until Element Is Clicked  //*[contains(@a-text, "Enable")]  60
    Wait Until Element Is Clicked  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/ui-button[1]  60
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Go To Site View
    Close BTS Start-up View
    Log  Wait for SBTS to be in Test Dedicated State!  console=true
    Wait Until Element Is Visible  ${TDS_SIGN}  ${RECOVERY_TIMEOUT}
    Log  SBTS is in Test Dedicated State!  console=true


Step2: Set Frequency Parameters For NR Cells
    Log  \nStep2: Set frequency parameters for NR cells  console=true
    ${fdd_nr_id_list}  Get Id For FDD NR Cells
    Set Test Variable  ${FDD_NR_ID_LIST}
    ${NO_FDD_NR_CELLS}  Get Length  ${FDD_NR_ID_LIST}
    Set Test Variable  ${NO_FDD_NR_CELLS}
    Open Commissioning Wizard Menu
    Wait Until Element Is Clicked  //*[contains(@heading, 'Steps')]  60
    Wait Until Element Is Clicked  //*[contains(@title, 'Cells Configuration')]  60
    ${fdd_downlink_uplink_dictionary}  Get NRARFCN Downlink And NRARFCN Uplink For NR Cells
    Set Test Variable  ${FDD_NR_DOWNLINK_UPLINK_VALUES}  ${fdd_downlink_uplink_dictionary}


Step3: Downling NR Cells
    Log  \nStep3: Downling NR cells  console=true
    Open Diagnostic Menu
    Click Element  ${TEST_MODELS}
    Click Element  ${NR_DOWNLINK_TEST}
    Run Keyword And Ignore Error  Close Diagnostic Menu
    ${choose_cell}  Catenate  SEPARATOR=  //*[contains(@class, "test-models-tabs ng-isolate-scope")]
    ...  /div/div[2]/div/div[1]/test-models-progress-bar/div/nr-test-models-downlink/div/div[1]/nr-downlink-test-setup/div/div[2]/div[1]/div/div[2]
    ...  /ui-select/div/wf-dropdown/div/button
    IF  '${ENB_BRANCH}' < 'SBTS25R3'
        ${nr_downlink}  Catenate  SEPARATOR=  //*[contains(@class, "test-models-tabs ng-isolate-scope")]
        ...  /div/div[2]/div/div[1]/test-models-progress-bar/div/nr-test-models-downlink/div/div[1]/nr-downlink-test-setup/div/div[3]/div[1]
        ...  /test-integer-input/div/div[2]/div/ui-text-input/div/input
    ELSE
        ${nr_downlink}  Catenate  SEPARATOR=  //*[contains(@class, "test-models-tabs ng-isolate-scope")]
        ...  /div/div[2]/div/div[1]/test-models-progress-bar/div/nr-test-models-downlink/div/div[1]/nr-downlink-test-setup/div/div[3]/div[1]
        ...  /test-integer-input/div/div[2]/div/div/ui-text-input/div/input
    END
    ${nr_uplink}  Catenate  SEPARATOR=  //*[contains(@class, "test-models-tabs ng-isolate-scope")]/div
    ...  /div[2]/div/div[1]/test-models-progress-bar/div/nr-test-models-downlink/div/div[1]/nr-downlink-test-setup/div/div[3]/div[2]
    ...  /test-integer-input/div/div[2]/div/div/ui-text-input/div/input
    ${test_model}  Catenate  SEPARATOR=  //*[contains(@class, "test-models-tabs ng-isolate-scope")]/div
    ...  /div[2]/div/div[1]/test-models-progress-bar/div/nr-test-models-downlink/div/div[1]/nr-downlink-test-setup/div/div[4]/div[1]/div/div[2]
    ...  /ui-select/div/wf-dropdown/div/button
    ${choose_test_model}  Catenate  SEPARATOR=  //*[contains(@class, "test-models-tabs ng-isolate-scope")]
    ...  /div/div[2]/div/div[1]/test-models-progress-bar/div/nr-test-models-downlink/div/div[1]/nr-downlink-test-setup/div/div[4]/div[1]/div
    ...  /div[2]/ui-select/div/wf-dropdown/div/ul/wf-dropdown-item[2]/li/a
    ${p_max}  Catenate  SEPARATOR=  //*[contains(@class, "test-models-tabs ng-isolate-scope")]/div/div[2]
    ...  /div/div[1]/test-models-progress-bar/div/nr-test-models-downlink/div/div[1]/nr-downlink-test-setup/div/div[6]/div[2]/test-decimal-input/div
    ...  /div[2]/div/ui-text-input/div/input
    Save Downlink Test File For FDD NR Cells  ${choose_cell}  ${nr_downlink}  ${nr_uplink}  ${test_model}  ${choose_test_model}  ${p_max}


Step4: Deactivate TDS Mode
    Log  \nStep4: Deactivate TDS mode  console=true
    Close Commissioning Wizard Cell Carriers If Visible
    Open Diagnostic Menu
    Wait Until Element Is Clicked  ${RESET_TO_TEST_DEDICATED_STATE}  60
    Run Keyword And Ignore Error  Close Diagnostic Menu
    Wait Until Element Is Clicked  //*[contains(@a-text, "Disable")]  60
    Wait Until Element Is Clicked  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/ui-button[1]  60
    Go To Site View
    Close BTS Start-up View
    Log  Wait for all cells to be Enabled!  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Log  All cells are Enabled!  console=true


Get Id For FDD NR Cells
    ${cells_list}  Get Cells Info
    ${fdd_nr_id_list}  Create List
    FOR  ${cell}  IN  @{cells_list}
        ${cell_status}  Run Keyword And Return Status
        ...  Should Contain  ${cell}[id][internal]  NRCEL
        ${id_cell}  Fetch From Right  ${cell}[id][internal]  -
        IF  '${cell}[technology]' == 'FDD' and ${cell_status}  Append To List  ${fdd_nr_id_list}  ${id_cell}
    END

    RETURN  ${fdd_nr_id_list}


Get NRARFCN Downlink And NRARFCN Uplink For NR Cells
    ${downlink_uplink_dictionary}  Create Dictionary
    Wait Until Element Is Clicked  //*[contains(@title, 'NR FDD')]  60
    Wait Until Element Is Clicked  //*[contains(@title, 'Cell Carriers')]  60
    FOR  ${index_cell}  IN RANGE  1  ${NO_FDD_NR_CELLS}+1
        ${xpath_fdd_cell}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]/div/modal-body
        ...  /wizard-steps-modal-body/div/div[2]/div/nr-fdd-carriers/ui-expandable-panel[${index_cell}]
        Click Element  ${xpath_fdd_cell}
        ${xpath_nr_downlink}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]/div/modal-body
        ...  /wizard-steps-modal-body/div/div[2]/div/nr-fdd-carriers/ui-expandable-panel[${index_cell}]/div/div[2]/div/ui-expandable-panel-body/
        ...  div[1]/div[2]/wizard-parameter-input-cell/div/div[2]/div/ui-text-input/div/input
        ${xpath_nr_uplink}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]/div/modal-body/
        ...  wizard-steps-modal-body/div/div[2]/div/nr-fdd-carriers/ui-expandable-panel[${index_cell}]/div/div[2]/div/ui-expandable-panel-body/
        ...  div[2]/div[2]/wizard-parameter-input-cell/div/div[2]/div/ui-text-input/div/input
        ${fdd_nr_downlink_uplink_values}  Create List
        ${fdd_nr_downlink_value}  Get Value  ${xpath_nr_downlink}
        Append To List  ${fdd_nr_downlink_uplink_values}  ${fdd_nr_downlink_value}
        ${fdd_nr_uplink_value}  Get Value  ${xpath_nr_uplink}
        Append To List  ${fdd_nr_downlink_uplink_values}  ${fdd_nr_uplink_value}
        ${index_list}  Evaluate  ${index_cell}-1
        Set To Dictionary  ${downlink_uplink_dictionary}  nr_cell_${FDD_NR_ID_LIST}[${index_list}]=${fdd_nr_downlink_uplink_values}
        Click Element  ${xpath_fdd_cell}
    END
    Close Commissioning Wizard Cell Carriers If Visible
    Wait Until Element Is Clicked  //*[contains(@title, 'NR FDD')]  60

    RETURN  ${downlink_uplink_dictionary}


Save Downlink Test File For FDD NR Cells
    [Arguments]  ${choose_cell}  ${nr_downlink}  ${nr_uplink}  ${test_model}  ${choose_test_model}  ${p_max}

    ${index}  Set Variable  1
    FOR  ${cell_id}  IN  @{FDD_NR_ID_LIST}
        Wait Until Keyword Succeeds  10  2
        ...  Scroll Element Into View  ${choose_cell}
        Wait Until Keyword Succeeds  10  2  Click Element  ${choose_cell}
        Wait Until Keyword Succeeds  10  2  Click Element  //span[contains(@class, 'ng-item ng-binding') and contains(text(), 'NRCELL-${cell_id}')]
        Wait Until Keyword Succeeds  10  2  Input Text  ${nr_downlink}  ${FDD_NR_DOWNLINK_UPLINK_VALUES}[nr_cell_${cell_id}][0]
        Wait Until Keyword Succeeds  10  2  Input Text  ${nr_uplink}  ${FDD_NR_DOWNLINK_UPLINK_VALUES}[nr_cell_${cell_id}][1]
        Wait Until Keyword Succeeds  10  2  Click Element  ${test_model}
        Wait Until Keyword Succeeds  10  2  Click Element  ${choose_test_model}
        ${value_p_max}  Get Value For PMax Parameter
        Wait Until Keyword Succeeds  10  2  Input Text  ${p_max}  ${value_p_max}
        Wait Until Element Is Clicked  //button[contains(text(),' Start Test')]
        ${stop_test}  Catenate  SEPARATOR=  //*[contains(@class, "test-models-tabs ng-isolate-scope")]/div
        ...  /div[2]/div/div[1]/test-models-progress-bar/div/nr-test-models-downlink/div/div[2]/div/div[1]/div[1]/nr-started-tests/div/div[2]/div
        ...  /ui-table/div/ng-transclude/table/tbody/tr[${index}]/td[4]/ui-button/button
        Wait Until Keyword Succeeds  10  2
        ...  Scroll Element Into View  ${stop_test}
        Wait Until Element Is Clicked  ${stop_test}
        ${index}  Evaluate  ${index}+1
        Wait Until Keyword Succeeds  10  2
        ...  Scroll Element Into View  locator=//button[contains(text(),' Save Test Results')]
        Wait Until Element Is Clicked  //button[contains(text(),' Save Test Results')]
        Log  5G Downlink Test file for NRCELL-${cell_id} is save.  console=true
    END


Close Commissioning Wizard Cell Carriers If Visible
    ${cell_carriers_visible}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  locator=//button[contains(text(),' Cancel')]  timeout=60
    IF  ${cell_carriers_visible}
        Wait Until Element Is Clicked  //button[contains(text(),' Cancel')]
        Wait Until Element Is Visible  xpath:/html/body/div[1]/div/div/ui-modal-renderer/wizard-steps-cancel-modal/ui-modal/div/div/div[1]/div[1]
        ...  timeout=30
        Click Element  locator=//button[contains(text(),' Yes')]
    END


Get Value For PMax Parameter
    ${value_p_max}  Catenate  SEPARATOR=  //*[contains(@class, "test-models-tabs ng-isolate-scope")]/div/div[2]
    ...  /div/div[1]/test-models-progress-bar/div/nr-test-models-downlink/div/div[1]/nr-downlink-test-setup/div/div[6]/div[2]/test-decimal-input
    ...  /div/div[3]/span[2]
    ${interval_dbm}  Get Text  ${value_p_max}
    ${min_value}  Fetch From Right  ${interval_dbm}  [
    ${min_value}  Fetch From Left  ${min_value}  .
    ${min_value}  Convert To Integer  ${min_value}
    IF  ${min_value} > 37
        RETURN  ${min_value}
    ELSE
        RETURN  37
    END


TC Setup
    Common Test Setup  tc_name=WebEM__5G_Test_Models_Running_5G_Downlink_Test
    WebEM Setup


TC Teardown
    Run Keyword If Test Failed
    ...  Step4: Deactivate TDS Mode
    WebEM Teardown
    Common Test Teardown
