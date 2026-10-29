*** Settings ***
Documentation
    ...  This test case is created to perform NR Downlink/Uplink Test.
    ...  Verify if 5G cells exist and open Operational History View.
    ...  Open Diagnostic Tab and perform Trigger Reset to Dedicated State.
    ...  Wait for SBTS to be in Test Dedicated State.
    ...  Open Test Models View and perform NR Downlink Test for all NR cells.
    ...  Test will sleep for 1 minute.
    ...  It is checked to appear properly in Operational History View and saved the results.
    ...  After that, it is performed NR Uplink Test for all NR cells.
    ...  Test will sleep for 1 minute.
    ...  It is checked to appear properly in Operational History View and saved the results.
    ...  SBTS will be restored in online mode.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1200  # Time for SBTS to recovery.


*** Keywords ***
TC__WebEM__Check_test_dedicated_state
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21846
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.09.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21846 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS21B

    Step0: Verify If 5G Cells Exist And Open Operations History
    Step1: Open Diagnostic Tab And Trigger Reset To Test Dedicated State
    Step2: Start And Stop NR Dowlink Test
    Step3: Start And Stop NR Uplink Test
    Step4: Restore SBTS In Online Mode


Step0: Verify If 5G Cells Exist And Open Operations History
    Log  Verify if 5G cells exist  console=true
    Run Keyword If  ${SCF_COUNT_NR}
    ...  Log  NR cells exist!  console=true
    ...  ELSE
    ...  Fail  NR cells does not exist!
    Sleep  15s
    Open Operations History


Step1: Open Diagnostic Tab And Trigger Reset To Test Dedicated State
    Log  Step1: Open Diagnostic Tab and Trigger Reset to Test Dedicated State  console=true
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
    Check A Specific Operation In Operations History  Reset to test dedicated state


Step2: Start And Stop NR Dowlink Test
    Log  Step2: Start and Stop NR Dowlink Test  console=true
    Open Diagnostic Menu
    Click Element  ${TEST_MODELS}
    Click Element  ${NR_DOWNLINK_TEST}
    Run Keyword And Ignore Error  Close Diagnostic Menu
    FOR  ${index}  IN RANGE  1  ${SCF_COUNT_NR}+1
        ${element}  Catenate  SEPARATOR=  //*[contains(@class, "test-models-tabs ng-isolate-scope")]/div/div[2]/div/div[1]/test-models-progress-bar
        ...  /div/nr-test-models-downlink/div/div[1]/nr-downlink-test-setup/div/div[2]/div[1]/div/div[2]/ui-select/div/wf-dropdown/div/button/span[2]
        Click Element  ${element}
        ${element_text}  Catenate  SEPARATOR=  //*[contains(@class, "test-models-tabs ng-isolate-scope")]/div/div[2]/div/div[1]/test-models-progress
        ...  -bar/div/nr-test-models-downlink/div/div[1]
        ...  /nr-downlink-test-setup/div/div[2]/div[1]/div/div[2]/ui-select/div/wf-dropdown/div/ul/wf-dropdown-item[${index}]/li
        ${id_cell_downlink}  Get Text  ${element_text}
        Click Element  ${element_text}
        Log  Start button is pressed for ${id_cell_downlink}!  console=true
        ${start_button}  Catenate  SEPARATOR=  //*[contains(@class, "test-models-tabs ng-isolate-scope")]/div/div[2]/div/div[1]/test-models-progress
        ...  -bar/div/nr-test-models-downlink/div/div[1]
        ...  /test-model-execution-bar/execution-bar/div/div[1]/start-test-button/div/ui-button/button
        Click Element  ${start_button}
        Log  Test will sleep 1 minute!  console=true
        Sleep  60s  Test will sleep 1 minute
        Check A Specific Operation In Operations History  Start 5G downlink test
        Log  Stop button is pressed for ${id_cell_downlink}!  console=true
        ${stop_button}  Catenate  SEPARATOR=  //*[contains(@class, "test-models-tabs ng-isolate-scope")]
        ...  /div/div[2]/div/div[1]/test-models-progress-bar/div/nr-test-models-downlink/div/div[2]
        ...  /div/div[1]/div[1]/nr-started-tests/div/div[2]/div/ui-table/div/ng-transclude/table/tbody/tr[${index}]/td[4]/ui-button/button
        Click Element  ${stop_button}
        Sleep  60s  Test will sleep 1 minute
        Check A Specific Operation In Operations History  Stop 5G downlink test
        Save Test Results  DownlinkTest  ${id_cell_downlink}
    END


Step3: Start And Stop NR Uplink Test
    Log  Step3: Start and Stop NR Uplink Test  console=true
    Click Element  ${NR_UPLINK_TEST}
    FOR  ${index}  IN RANGE  1  ${SCF_COUNT_NR}+1
        ${element}  Catenate  SEPARATOR=  //*[contains(@class, "test-models-tabs ng-isolate-scope")]/div/div[3]/div/div[1]/test-models-progress-bar
        ...  /div/nr-test-models-uplink/div/div[1]/nr-uplink-test-setup/div/div[2]/div[1]/div/div[2]/ui-select/div/wf-dropdown/div/button/span[2]
        Click Element  ${element}
        ${element_text}  Catenate  SEPARATOR=  //*[contains(@class, "test-models-tabs ng-isolate-scope")]
        ...  /div/div[3]/div/div[1]/test-models-progress-bar/div/nr-test-models-uplink/div/div[1]
        ...  /nr-uplink-test-setup/div/div[2]/div[1]/div/div[2]/ui-select/div/wf-dropdown/div/ul/wf-dropdown-item[${index}]/li
        ${id_cell_uplink}  Get Text  ${element_text}
        Click Element  ${element_text}
        Log  Start button is pressed for ${id_cell_uplink}!  console=true
        ${start_button}  Catenate  SEPARATOR=  //*[contains(@class, "test-models-tabs ng-isolate-scope")]
        ...  /div/div[3]/div/div[1]/test-models-progress-bar/div/nr-test-models-uplink/div/
        ...  div[1]/test-model-execution-bar/execution-bar/div/div[1]/start-test-button/div/ui-button/button
        Click Element  ${start_button}
        Log  Test will sleep 1 minute!  console=true
        Sleep  60s  Test will sleep 1 minute
        Check A Specific Operation In Operations History  Start 5G uplink test
        Log  Stop button is pressed for ${id_cell_uplink}!  console=true
        ${stop_button}  Catenate  SEPARATOR=  //*[contains(@class, "test-models-tabs ng-isolate-scope")]
        ...  /div/div[3]/div/div[1]/test-models-progress-bar/div/nr-test-models-uplink/div
        ...  /div[2]/div/div[1]/nr-started-tests/div/div[2]/div/ui-table/div/ng-transclude/table/tbody/tr[${index}]/td[4]/ui-button/button
        Click Element  ${stop_button}
        Sleep  60s  Test will sleep 1 minute
        Check A Specific Operation In Operations History  Stop 5G uplink test
        Save Test Results  UplinkTest  ${id_cell_uplink}
    END


Step4: Restore SBTS In Online Mode
    Log  Step4: Restore SBTS in online mode  console=true
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
    Check A Specific Operation In Operations History  Site reset


Save Test Results
    [Arguments]  ${test_saved}  ${id_cell}

    Wait Until Element Is Enabled  //*[contains(@a-text, "Save Test Results")]  120
    Click Element  //*[contains(@a-text, "Save Test Results")]
    Sleep  10s  Saving test results
    Log  Saving test results has been performed successfully!  console=true
    Move File  /home/ute/Downloads/5G_${test_saved}_*.txt  ${BTS_FILES}/5G_${test_saved}_SBTS-${BTS_ID}_${id_cell}.txt


Restore SBTS
    Open Diagnostic Menu
    Wait Until Element Is Clicked  ${RESET_TO_TEST_DEDICATED_STATE}  60
    Run Keyword And Ignore Error  Close Diagnostic Menu
    ${status}  Run Keyword And Return Status  Element should be visible  //*[contains(@a-text, "Enable")]
    Run Keyword If  ${status}
    ...  Log  SBTS doesn't need to be restored!  console=true
    ...  ELSE
    ...  Run Keywords
    ...  Wait Until Element Is Clicked  //*[contains(@a-text, "Disable")]  60
    ...  AND
    ...  Wait Until Element Is Clicked  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/ui-button[1]  60
    ...  AND
    ...  Go To Site View
    ...  AND
    ...  Close BTS Start-up View
    ...  AND
    ...  Log  Wait for all cells to be Enabled!  console=true
    ...  AND
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    ...  AND
    ...  Log  All cells are Enabled!  console=true


TC Setup
    Common Test Setup  tc_name=WebEM__Check_test_dedicated_state
    WebEM Setup


TC Teardown
    Run Keyword If Test Failed
    ...  Restore SBTS
    WebEM Teardown
    Common Test Teardown
