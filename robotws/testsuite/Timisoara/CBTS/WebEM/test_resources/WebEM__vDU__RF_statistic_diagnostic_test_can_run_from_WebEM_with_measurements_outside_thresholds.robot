*** Settings ***
Documentation
    ...  This TC is created for RF statistic diagnostic test running from WebEM with measurements outside thresholds.
    ...  Change actRemoteRfDiag to be true.
    ...  Create test object under MNLENT.
    ...  Create and set threshold values of the RF Diagnostic threshold.
    ...  Create RFREQ with all NR cells.
    ...  Validate and activate plan.
    ...  Verify the results in Configuration Management. Should be passed.
    ...  Start RF Statistic Diagnostic test with all radios and wait for Success to be visible.
    ...  Verify the results in RF Statistic Diagnostic Test Results.
    ...  Verify the results in RFSTATRES MO created.
    ...  Delete TEST object.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${RF_TEMPERATURE_HIGH_THRESHOLD}  -40  # The value to be set for temperature high threshold
${RF_TEMPERATURE_LOW_THRESHOLD}  -55  # The value to be set for temperature low threshold
${TX_ANTENNA_VSWR_HIGH_THRESHOLD}  1  # The value to be set for VSWR high threshold
${RX_ANTENNA_RSSI_HIGH_THRESHOLD}  -150  # The value to be set for RSSI high threshold
${RX_ANTENNA_RSSI_LOW_THRESHOLD}  -180  # The value to be set for RSSI low threshold


*** Keywords ***
TC__WebEM__vDU__RF_statistic_diagnostic_test_can_run_from_WebEM_with_measurements_outside_thresholds
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25157
    ...
    ...  ******************
    ...  - 01.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25157 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CB006992

    Step1:Change ActRemoteRfDiag To Be True
    Step2:Create Test Object Under MNLENT
    Step3:Create And Set Threshold Values Of The RF Diagnostic Threshold
    Step4:Create RFREQ With All NR Cells
    Step5:Verify The Results In Configuration Management
    Step6:Start RF Statistic Diagnostic Test
    Step7:Verify The Results In RF Statistic Diagnostic
    Step8:Verify The Results In Configuration Management
    Step9:Delete TEST Object


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
    Click Element  //*[contains(@aria-label, 'MNL-1')]/button/span
    Log  MNL-1 is open![OK]  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'MNLENT-1')]/button/span
    Wait Until Element Is Clicked  //*[@class="mdi mdi-plus p-button-icon ng-star-inserted"]
    Wait Until Element Is Clicked  //*[@id="className"]/div/span[1]
    Wait Until Keyword Succeeds  30  5
    ...  Input Text  //*[@id="className"]/div/div[3]/div[1]/div/input  TEST
    Click Element  //*[contains(@aria-label, 'TEST')]
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
    Click Element  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[4]/cem-parameter-input/cem-number-input
    Wait Until Keyword Succeeds  30  5
    ...  Input Text
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[4]/cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
    ...  ${RF_TEMPERATURE_LOW_THRESHOLD}
    Click Element  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[6]/td[4]/cem-parameter-input/cem-number-input
    Wait Until Keyword Succeeds  30  5
    ...  Input Text
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[6]/td[4]/cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
    ...  ${TX_ANTENNA_VSWR_HIGH_THRESHOLD}
    Click Element  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[4]/cem-parameter-input/cem-number-input
    Wait Until Keyword Succeeds  30  5
    ...  Input Text
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[4]/cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
    ...  ${RX_ANTENNA_RSSI_HIGH_THRESHOLD}
    Click Element  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[4]/cem-parameter-input/cem-number-input
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


Step5:Verify The Results In Configuration Management
    Log  \nStep5:Verify the results in Configuration Management  console=true
    Wait Until Element Is Clicked  ${VDU_PARAMETER_EDITOR}  120
    Sleep  30s  Time for page to be updated
    Click Element  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/blocks-validation-errors/p-tabview/div/div[1]/p-button/button/span[1]
    Wait Until Element Is Clicked  ${OBJECT_XPATH}/p-treenode/li/div/button/span
    Log  MRBTS-${VDU_MRBTS_ID} is open![OK]  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'MNL-1')]/button/span
    Log  MNL-1 is open![OK]  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'MNLENT-1')]/button/span
    Log  MNLENT-1 is open![OK]  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'TEST-1')]/button/span
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'RFREQ-2')]/button/span
    Wait Until Element Is Clicked  //*[contains(text(), "RFRES")]
    ${test_date}  DateTime.Get Current Date  result_format=%d.%m.%Y
    Set Test Variable  ${TEST_DATE}
    ${parameters_list}  Create List  ${TEST_DATE}  result  testOutcome  testOutcomeAdditionalInfo  sinr  rssi  vswr  fwdTestDisp  rvrsTestDisp  Pass
    FOR  ${parameter}  IN  @{parameters_list}
        Wait Until Keyword Succeeds  30  5
        ...  Page Should Contain  ${parameter}
        Log  Parameter ${parameter} is visible![OK]  console=true
    END


Step6:Start RF Statistic Diagnostic Test
    Log  \nStep6:Start RF Statistic Diagnostic test  console=true
    Log  Go to RF Diagnostic Test!  console=true
    Open RF Diagnostic Tab
    ${xpaths}  Get WebElements  //*[contains(@aria-label, 'dropdown trigger')]
    FOR  ${xpath}  IN  @{xpaths}
        Click Element  ${xpath}
        ${status}  Run Keyword And Return Status
        ...  Wait Until Element Is Clicked  //*[contains(@aria-label, "All radios")]
        Run Keyword If  ${status}
        ...  Exit For Loop
        ...  ELSE
        ...  Continue For Loop
    END
    Log  Start Statistics Diagnostic Test for all radios!  console=true
    Wait Until Element Is Clicked  //*[contains(text(), "Start Statistics Diagnostic Test")]
    ${status_passed}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  //span[contains(@class, 'ot-text ng-star-inserted') and contains(text(), 'Success')]  300
    Run Keyword If  ${status_passed}
    ...  Log  RF Statistic Diagnostic test was done with status Success![OK]  console=true
    ...  ELSE
    ...  Fail  RF Statistic Diagnostic test was done with status Failed![NOK]


Step7:Verify The Results In RF Statistic Diagnostic
    Log  \nStep7:Verify the results in RF Statistic Diagnostic  console=true
    Click Element  //span[contains(@class, 'p-tabview-title ng-star-inserted') and contains(text(), 'RF Statistics Diagnostic Test Results')]
    Log  Verify if the following measurements are visible!  console=true
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain Element  //*[contains(text(), "${TEST_DATE}")]
    ${measurements_list}  Create List  Temperature value  Received errored frames  Received frames  Received multicast frames  Received octets
    ...  Received unknown type frames  Received unknown VLAN frames  Transmitted frames  Transmitted multicast frames  Transmitted octets
    ...  Sensor name  BTS test start time  BTS test stop time  Result  Outcome  Uptime (sec)  success
    FOR  ${measurement}  IN  @{measurements_list}
        Page Should Contain Element  //*[contains(text(), "${measurement}")]
        Log  ${measurement} is visible on RF Statistics Diagnostic Test Results![OK]  console=true
    END
    ${status_pass}  Run Keyword And Return Status
    ...  Page Should Contain Element  //*[contains(text(), "pass")]
    ${status_fail}  Run Keyword And Return Status
    ...  Page Should Contain Element  //*[contains(text(), "failed")]
    Run Keyword If  ${status_fail}
    ...  Log  The test outcome is failed but done successfully![OK]  console=true
    ...  ELSE IF  ${status_pass}
    ...  Log  The test outcome is passed and done successfully![OK]  console=true
    ...  ELSE
    ...  Fail  The test outcome has no value![NOK]
    Set Test Variable  ${STATUS_PASS}
    Set Test Variable  ${STATUS_FAIL}


Step8:Verify The Results In Configuration Management
    Log  \nStep8:Verify the results in Configuration Management  console=true
    Wait Until Element Is Clicked  ${VDU_PARAMETER_EDITOR}  120
    Sleep  30s  Time for page to be updated
    Click Element  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/blocks-validation-errors/p-tabview/div/div[1]/p-button/button/span[1]
    Wait Until Element Is Clicked  ${OBJECT_XPATH}/p-treenode/li/div/button/span
    Log  MRBTS-${VDU_MRBTS_ID} is open![OK]  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'MNL-1')]/button/span
    Log  MNL-1 is open![OK]  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'MNLENT-1')]/button/span
    Log  MNLENT-1 is open![OK]  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'TEST-1')]/button/span
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'RFSTATREQ-2')]/button/span
    Wait Until Element Is Clicked  //*[contains(text(), "RFSTATRES")]
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain Element  //*[contains(text(), "${TEST_DATE}")]
    ${measurements_list}  Create List  temperatureValue  receivedErroredFrames  receivedFrames  receivedMulticastFrames  receivedOctets
    ...  receivedUnknownTypeFrames  receivedUnknownVLANFrames  transmittedFrames  transmittedMulticastFrames  transmittedOctets  sensorName
    ...  startTime  rfStatResId  testOutcome  testOutcomeAdditionalInfo  uptime  result  success
    FOR  ${measurement}  IN  @{measurements_list}
        Page Should Contain Element  //*[contains(text(), "${measurement}")]
        Log  ${measurement} is visible on RFSTATRES MO created![OK]  console=true
    END
    ${pass_parameter}  Run Keyword And Return Status
    ...  Page Should Contain Element  //*[contains(text(), "pass")]
    ${fail_parameter}  Run Keyword And Return Status
    ...  Page Should Contain Element  //*[contains(text(), "failed")]
    Run Keyword If  ${fail_parameter}==${STATUS_FAIL}
    ...  Log  The test outcome is failed on both sides![OK]  console=true
    ...  ELSE IF  ${pass_parameter}==${STATUS_PASS}
    ...  Log  The test outcome is passed on both sides![OK]  console=true
    ...  ELSE
    ...  Fail  The test outcome has no similar value on both sides![NOK]


Step9:Delete TEST Object
    Log  \nStep9:Delete TEST object  console=true
    vdu_frame.Connect To VDU  host=${VDU_OAM_IP}
    ${changed_parameter}  Create Dictionary  distName=MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/TEST-1  operation=delete
    ${changed_parameter_list}  Create List  ${changed_parameter}
    ${changed_parameter_string}  Evaluate  json.dumps(${changed_parameter_list})  json
    vdu.Perform Delta Recommissioning  ${changed_parameter_string}


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__RF_statistic_diagnostic_test_can_run_from_WebEM_with_measurements_outside_thresholds


TC Teardown
    VDU WebEM Teardown
    Common VDU Teardown
