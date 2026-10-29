*** Settings ***
Documentation
    ...  This TC is created to save and delete RF diagnostic and RF statistic diagonstic test results.
    ...  Change actRemoteRfDiag to be true.
    ...  Create test object under MNLENT.
    ...  Create and set threshold values of the RF Diagnostic threshold.
    ...  Create RFREQ with all NR cells.
    ...  Start RF Diagnostic test with all NR cells and wait for Success to be visible.
    ...  Save cell results and all results from RF Diagnostic and move all results in test results directory.
    ...  Verify the results in Configuration Management. Should be passed.
    ...  Start RF Statistic Diagnostic test with all radios and wait for Success to be visible.
    ...  Save cell results and all results from RF Statistic Diagnostic and move all results in test results directory.
    ...  Clear finished results on RF Statistic Diagnostic and RF diagnostic test.
    ...  Delete TEST object.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${RF_TEMPERATURE_HIGH_THRESHOLD}  80  # The value to be set for temperature high threshold
${RF_TEMPERATURE_LOW_THRESHOLD}  -5  # The value to be set for temperature low threshold
${TX_ANTENNA_VSWR_HIGH_THRESHOLD}  3  # The value to be set for VSWR high threshold
${RX_ANTENNA_RSSI_HIGH_THRESHOLD}  -30  # The value to be set for RSSI high threshold
${RX_ANTENNA_RSSI_LOW_THRESHOLD}  -110  # The value to be set for RSSI low threshold
${RECOVERY_TIMEOUT}  900  #Time for CBTS to recover


*** Keywords ***
TC__WebEM__vDU__Save_and_delete_RF_diagnostic_and_RF_statistic_diagonstic_test_results
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25158
    ...
    ...  ******************
    ...  - 04.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25158 - Initial TAT creation
    ...  - 06.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28699 - Fix many xpaths

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CB006992

    Step1:Change ActRemoteRfDiag To Be True
    Step2:Create Test Object Under MNLENT
    Step3:Create And Set Threshold Values Of The RF Diagnostic Threshold
    Step4:Create RFREQ With All NR Cells
    Step5:Start RF Diagnostic Test
    Step6:Save Cell Results And All Results From RF Diagnostic
    Step7:Verify The Results In Configuration Management
    Step8:Start RF Statistic Diagnostic Test
    Step9:Save Cell Results And All Results From RF Statistic Diagnostic
    Step10:Clear Finished Results On RF Statistic Diagnostic And RF Diagnostic Test
    Step11:Delete TEST Object


Step1:Change ActRemoteRfDiag To Be True
    Log  \nStep1:Change actRemoteRfDiag to be true  console=true
    Change Specific Parameter For VDU  actRemoteRfDiag  true  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1


Step2:Create Test Object Under MNLENT
    Log  \nStep2:Create test object under MNLENT  console=true
    Wait Until Element Is Clicked  ${VDU_PARAMETER_EDITOR}  120
    Sleep  30s  This sleep is for plan to be updated!
    Page Should Contain  Current Plan
    Create Duplicate Plan For CBTS
    Log  Open MNLENT-1 and create TEST object!  console=true
    ${object_xpath}  Catenate  SEPARATOR=  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/div/blocks-navigation/ot-side-sheet/div/
    ...  div[1]/div/div[2]/p-tree/div/cdk-virtual-scroll-viewport/div[1]/ul
    Set Test Variable  ${OBJECT_XPATH}
    Click Element  ${OBJECT_XPATH}/p-treenode/li/div/button/span
    Log  MRBTS-${VDU_MRBTS_ID} is open![OK]  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'MNL-1')]/button/span
    Log  MNL-1 is open![OK]  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'MNLENT-1')]/button/span
    Wait Until Element Is Clicked  //*[@class="mdi mdi-plus p-button-icon ng-star-inserted"]
    Wait Until Element Is Clicked  //*[@id="className"]/div/span[1]
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[@id="className"]/div/div[3]/div[1]/div/input  TEST
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'TEST')]
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div[2]/p-button[1]/button/span
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'TEST-1')]/span/span/div/div
    Log  TEST object was created under MNLENT-1 and is visible![OK]  console=true


Step3:Create And Set Threshold Values Of The RF Diagnostic Threshold
    Log  \nStep3:Create and set threshold values of the RF Diagnostic threshold  console=true
    Wait Until Element Is Clicked  //*[@class="mdi mdi-plus p-button-icon ng-star-inserted"]
    Wait Until Element Is Clicked  //*[@id="className"]/div/span[1]
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'RFTHLD')]
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div[2]/p-button[1]/button/span
    Log  RFTHLD object was created under TEST-1 and is visible![OK]  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'RFTHLD-1')]/span/span/div/div[1]/div
    Wait Until Keyword Succeeds  30  5
    ...  Input Text
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[4]/cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
    ...  ${RF_TEMPERATURE_HIGH_THRESHOLD}
    Wait Until Element Is Clicked  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[4]/cem-parameter-input/cem-number-input
    Wait Until Keyword Succeeds  30  5
    ...  Input Text
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[4]/cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
    ...  ${RF_TEMPERATURE_LOW_THRESHOLD}
    Wait Until Element Is Clicked  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[8]/td[4]/cem-parameter-input/cem-number-input
    Wait Until Keyword Succeeds  30  5
    ...  Input Text
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[8]/td[4]/cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
    ...  ${TX_ANTENNA_VSWR_HIGH_THRESHOLD}
    Wait Until Element Is Clicked  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[4]/cem-parameter-input/cem-number-input
    Wait Until Keyword Succeeds  30  5
    ...  Input Text
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[4]/cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
    ...  ${RX_ANTENNA_RSSI_HIGH_THRESHOLD}
    Wait Until Element Is Clicked  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[4]/cem-parameter-input/cem-number-input
    Wait Until Keyword Succeeds  30  5
    ...  Input Text
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[4]/cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
    ...  ${RX_ANTENNA_RSSI_LOW_THRESHOLD}
    Sleep  20s  This sleep is for parameter to be updated!
    Log  All parameters are updated with the specific values![OK]  console=true


Step4:Create RFREQ With All NR Cells
    Log  \nStep4:Create RFREQ with all NR cells  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'TEST-1')]/span/span/div/div
    Wait Until Element Is Clicked  //*[@class="mdi mdi-plus p-button-icon ng-star-inserted"]
    Wait Until Element Is Clicked  //*[@id="className"]/div/span[1]
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'RFREQ')]
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[contains(@class, 'field p-inputgroup-with-label--block')]/div/ot-input-number/span/input  1  clear=true
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div[2]/p-button[1]/button/span
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'RFREQ-1')]/span/span/div/div[1]/div
    Log  RFREQ object was created under TEST-1 and is visible![OK]  console=true
    Wait Until Keyword Succeeds  30  5
    ...  Input Text
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[4]/cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
    ...  -1
    Wait Until Element Is Clicked  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[4]/cem-parameter-input/cem-number-input
    Log  targetCellType NR and all cells for targetCellId have been choosen![OK]  console=true
    Wait Until Element Is Clicked  //*[contains(@label, 'Save')]
    Sleep  10s  Time for page to be updated
    Validate And Activate Plan For Unified CBTS
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check All Cells From VDU  administrative_state=${UNLOCKED}
    ...  operational_state=${ENABLED}
    ...  blocking_state=${UNBLOCKED}
    ...  availability_status=${ONLINE}
    Log  All cells are Online and Enabled![OK]  console=true


Step5:Start RF Diagnostic Test
    Log  \nStep5:Start RF Diagnostic test  console=true
    Open RF Diagnostic Tab
    Sleep  10s  This sleep is for page to be upload.
    ${xpaths}  Get WebElements  //*[contains(@aria-label, 'dropdown trigger')]
    FOR  ${xpath}  IN  @{xpaths}
        Click Element  ${xpath}
        ${status}  Run Keyword And Return Status
        ...  Click Element  //*[contains(@aria-label, "All NR cells")]
        Run Keyword If  ${status}
        ...  Exit For Loop
        ...  ELSE
        ...  Continue For Loop
    END
    Log  Start RF Diagnostic Test for all NR cells!  console=true
    Wait Until Element Is Clicked  //*[contains(text(), "Start RF Diagnostic Test")]
    Wait Until Element Is Visible  //span[contains(@class, 'ot-text ng-star-inserted') and contains(text(), 'Success')]  300
    Log  Success message appeared![OK]  console=true
    ${test_date}  DateTime.Get Current Date  result_format=%d.%m.%Y
    Set Test Variable  ${TEST_DATE}
    Log  Verify if the test is passed!  console=true
    Wait Until Element Is Clicked  //span[contains(@class, 'p-tabview-title ng-star-inserted') and contains(text(), 'RF Diagnostic Test Results')]
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain Element  //*[contains(text(), "${TEST_DATE}")]
    Page Should Contain Element  //*[contains(text(), "pass")]
    Page Should Contain Element  //*[contains(text(), "success")]
    Element Should Not Be Visible  //*[contains(text(), "failed")]
    Log  The test is passed and done successfully![OK]  console=true


Step6:Save Cell Results And All Results From RF Diagnostic
    Log  \nStep6:Save cell results and all results from RF Diagnostic  console=true
    Save Results For RF Statistic/Diagnostic Test For VDU WebEM  Save Cell Results  RFDiagnosticTest  NRCELL


Step7:Verify The Results In Configuration Management
    Log  \nStep7:Verify the results in Configuration Management  console=true
    Wait Until Element Is Clicked  ${VDU_PARAMETER_EDITOR}  120
    Sleep  30s  Time for page to be updated
    Click Element  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/blocks-validation-errors/p-tabview/div/div[1]/p-button/button/span[1]
    Wait Until Keyword Succeeds  30  5  Input Text
    ...  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/div/blocks-navigation/ot-side-sheet/div/div[1]/div/div[2]/p-tree/div/div/input
    ...  TEST-1
    Press Keys
    ...  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/div/blocks-navigation/ot-side-sheet/div/div[1]/div/div[2]/p-tree/div/div/input
    ...  ENTER
    Sleep  5s  Time for page to be loaded.
    ${status}  Run Keyword And Return Status  Page Should Not Contain Element  //*[contains(text(), "RFRES")]
    Run Keyword If  ${status}
    ...  Run Keywords
    ...  Wait Until Element Is Clicked  //*[contains(@aria-label, 'TEST-1')]/button/span
    ...  AND
    ...  Wait Until Element Is Clicked  //*[contains(@aria-label, 'RFREQ-2')]/button/span
    Wait Until Element Is Clicked  //*[contains(text(), "RFRES")]
    Wait Until Keyword Succeeds  30  5  Page Should Contain Element  //*[contains(text(), "${TEST_DATE}")]
    Page Should Contain Element  //*[contains(text(), "Pass")]
    Page Should Contain Element  //*[contains(text(), "success")]
    Element Should Not Be Visible  //*[contains(text(), "failed")]
    Log  The test is passed and done successfully![OK]  console=true


Step8:Start RF Statistic Diagnostic Test
    Log  \nStep8:Start RF Statistic Diagnostic test  console=true
    Log  Go to RF Diagnostic Test!  console=true
    Open RF Diagnostic Tab
    ${xpaths}  Get WebElements  //*[contains(@aria-label, 'dropdown trigger')]
    FOR  ${xpath}  IN  @{xpaths}
        Click Element  ${xpath}
        ${status}  Run Keyword And Return Status
        ...  Click Element  //*[contains(@aria-label, "All radios")]
        Run Keyword If  ${status}
        ...  Exit For Loop
        ...  ELSE
        ...  Continue For Loop
    END
    Log  Start Statistics Diagnostic Test for all radios!  console=true
    Wait Until Element Is Clicked  //*[contains(text(), "Start Statistics Diagnostic Test")]
    Wait Until Element Is Visible  //span[contains(@class, 'ot-text ng-star-inserted') and contains(text(), 'Success')]  300
    Log  Success message appeared![OK]  console=true
    Wait Until Element Is Clicked
    ...  //span[contains(@class, 'p-tabview-title ng-star-inserted') and contains(text(), 'RF Statistics Diagnostic Test Results')]
    Log  Verify if the test is passed!  console=true
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain Element  //*[contains(text(), "${TEST_DATE}")]
    Page Should Contain Element  //*[contains(text(), "pass")]
    Page Should Contain Element  //*[contains(text(), "success")]
    Element Should Not Be Visible  //*[contains(text(), "failed")]
    Log  The test is passed and done successfully![OK]  console=true


Step9:Save Cell Results And All Results From RF Statistic Diagnostic
    Log  \nStep9:Save cell results and all results from RF Statistic Diagnostic  console=true
    Save Results For RF Statistic/Diagnostic Test For VDU WebEM  Save Radio Results  RFStatisticsDiagnosticTest  RMOD


Step10:Clear Finished Results On RF Statistic Diagnostic And RF Diagnostic Test
    Log  \nStep10:Clear finished results on RF Statistic Diagnostic and RF diagnostic test  console=true
    Log  Clear finished results from RF Statistic Diagnostic!  console=true
    Clear Finished Results
    Log  Clear finished results from RF Diagnostic!  console=true
    Click Element  //span[contains(@class, 'p-tabview-title ng-star-inserted') and contains(text(), 'RF Diagnostic Test Results')]
    Clear Finished Results


Step11:Delete TEST Object
    Log  \nStep11:Delete TEST object  console=true
    vdu_frame.Connect To VDU  host=${VDU_OAM_IP}
    ${changed_parameter}  Create Dictionary  distName=MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/TEST-1  operation=delete
    ${changed_parameter_list}  Create List  ${changed_parameter}
    ${changed_parameter_string}  Evaluate  json.dumps(${changed_parameter_list})  json
    vdu.Perform Delta Recommissioning  ${changed_parameter_string}


Clear Finished Results
    Wait Until Element Is Clicked  //span[contains(text(), "Clear Finished Results")]  120
    Wait Until Keyword Succeeds  180  5
    ...  Element Should Not Be Visible  //*[contains(text(), "${TEST_DATE}")]
    Wait Until Keyword Succeeds  30  5
    ...  Element Should Not Be Visible  //*[contains(text(), "pass")]
    Wait Until Keyword Succeeds  30  5
    ...  Element Should Not Be Visible  //*[contains(text(), "success")]
    Log  All the results are cleared![OK]  console=true


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__Save_and_delete_RF_diagnostic_and_RF_statistic_diagonstic_test_results


TC Teardown
    VDU WebEM Teardown
    Common VDU Teardown
