*** Settings ***
Documentation
    ...  This test case is created to perform Tuning History Report from WebEM on 2 different browsers, Chrome and Mozilla.
    ...  In Step1, the following actions are performed on Chrome:
    ...  Fast mode is checked by the appearance of the specific window.
    ...  Manual mode is performed by randomly chosing one value from 213 to 3883.
    ...  After that, the history report is going to be generated, saved and moved to BTS Files.
    ...  The application log is going to be downloaded and moved to BTS Files.
    ...  In Step2, the same actions are performed on Mozilla.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${SCF_TOPF_PATH}  ${EMPTY}  #Mandatory! Path to SCF with TOP-F if the SBTS has TOP-P synchronization.
${CHECK_CELLS_TIMEOUT}  180s  #Time for cells to be onAir.
${TIMEOUT}  180s  #Time for WebEM to be open and to page to be fully loaded.
${RECOVERY_TIMEOUT}  600s  #Time for SBTS to be onAir.


*** Keywords ***
TC__WebEM__Get_Tuning_History_Report_with_Mozilla_and_Chrome
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21628
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21628 - Initial TAT creation
    ...  - 10.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22773 - Changing Wrong Xpaths
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 03.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24896 - Changing pop-up xpath
    ...  - 15.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26944 - Add headless argument for mozilla
    ...  - 27.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28004 - Tune xpath was changed in 25R1
    ...  - 22.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28275 - Download application logs problem resolved
    ...  - 04.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29025 - Load SCF with TOP-F if the synchronization is TOP-P

    Set Tags  CA-WebEM  OWNER-emina.stefanovici@nokia.com  AUTHOR-cosmina.rebenciuc@nokia.com  MAINTAINER-cosmina.rebenciuc@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS00

    Step1: Verify Synchronization Mode And Upload SCF If Needed
    Step2: Get Tuning History Report With Chrome
    Step3: Get Tuning History Report With Mozilla


Step1: Verify Synchronization Mode And Upload SCF If Needed
    Log  Step1: Verify Synchronization Mode And Upload SCF If Needed  console=true
    ${SYNCHRONIZATION_MODE}  Get Bts Sync Mode
    Set Test Variable  ${SYNCHRONIZATION_MODE}
    IF  '${SYNCHRONIZATION_MODE}' == 'PhaseSync'
        Should not be empty  ${SCF_TOPF_PATH}  SBTS has Phase Synchronization, please provide path to scf with frequency sync.
        Log  SBTS has Phase Synchronization, SCF with TOP-F needs to be uploaded!  console=true
        coam.Perform Commissioning  bts_id=${BTS_ID}  scf_file=${SCF_TOPF_PATH}  skip_parameter_relation_errors=${TRUE}  should_activate=${TRUE}
        ...  timeout=${RECOVERY_TIMEOUT}
        Log  SCF with TOP-F was uploaded and wait for all cells to be onAir...  console=true
        Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
        ...  Admin Check All Required State
    ELSE
        Log  SBTS has Frequency Synchronization already![OK]  console=true
    END


Step2: Get Tuning History Report With Chrome
    Log  Step2: Get Tuning History Report with Chrome  console=true
    Open WebEM  timeout=${TIMEOUT}
    Get Xpath For All Cells
    Open Tuning Synchronization
    Fast Mode
    Manual Mode
    Get History And Save Report
    Download Application Logs
    Close Browser


Step3: Get Tuning History Report With Mozilla
    Log  Step3: Get Tuning History Report with Mozilla  console=true
    Open WebEM With Mozilla  timeout=${TIMEOUT}
    Get Xpath For All Cells
    Open Tuning Synchronization
    Fast Mode
    Manual Mode
    Get History And Save Report
    Download Application Logs
    Close Browser


Fast Mode
    Log  Testing the appeareance of Fast mode, but not performing this.  console=true
    Click Element  xpath=//*[contains(@class, 'p-radiobutton-box p-highlight')]
    Sleep  10s  Time for button to be visible
    IF  '${ENB_BRANCH}' >= 'SBTS25R1'
        Click Element  //*[contains(@class, 'p-element p-button-neutral p-button p-component')]
    ELSE
        Click Element  //*[contains(@class, 'p-element p-button-secondary p-button p-component')]
    END
    Element Should Not Be Visible  xpath=//*[@id="ui-tabpanel-1"]/div/div[1]/tuning/div/tune-bts-clock/div/section/div[1]/div[3]/div[2]/div
    Wait Until Element Is Visible  //*[contains(@class, 'ot-dialog-title ng-star-inserted')]  60
    ${text_header_fast_tuning}  Get Text  //*[contains(@class, 'ot-dialog-title ng-star-inserted')]
    ${status_text_fast_tuning}  Run Keyword And Return Status
    ...  Should Be Equal  '${text_header_fast_tuning}'  'Do you want to start fast tuning?'
    IF  ${status_text_fast_tuning}==${FALSE}  Fail  Text fast tuning header not appeared.
    Log  ${text_header_fast_tuning} view appeared and will be closed.  console=true
    Click Element  //*[contains(@class, 'p-ripple p-element p-button-secondary p-button p-component')]


Manual Mode
    Log  Testing manual mode  console=true
    Wait Until Element Is Visible  //*[contains(@value, 'Manual')]
    Click Element   //*[contains(@value, 'Manual')]
    Sleep  10s
    IF  '${ENB_BRANCH}' >= 'SBTS25R1'
        Wait Until Element Is Visible  //*[contains(@class, 'p-element p-button-neutral p-button p-component')]
    ELSE
        Wait Until Element Is Visible  //*[contains(@class, 'p-element p-button-secondary p-button p-component')]
    END
    ${value_before_change}  Get Text  xpath=//*[@id="current-clock-control-value"]
    ${value}  Evaluate  random.randint(213,3883)  random
    Log  New clock control value: ${value}  console=true
    Input Text  xpath=//*[contains(@class, 'p-inputgroup')]/input  ${value}
    IF  '${ENB_BRANCH}' >= 'SBTS25R1'
        Wait Until Element Is Visible  //*[contains(@class, 'p-element p-button-neutral p-button p-component')]
        Click Element  //*[contains(@class, 'p-element p-button-neutral p-button p-component')]
    ELSE
        Wait Until Element Is Visible  //*[contains(@class, 'p-element p-button-secondary p-button p-component')]
        Click Element  //*[contains(@class, 'p-element p-button-secondary p-button p-component')]
    END
    Sleep  20s
    ${value_after_change}  Get Text  xpath=//*[@id="current-clock-control-value"]
    ${text_manual}  Get Text  //*[contains(@class, 'ot-text ng-star-inserted') and contains(text(), 'Manual tuning completed')]
    ${status_text}  Run Keyword And Return Status
    ...  Should Be Equal  '${text_manual}'  'Manual tuning completed'
    IF  ${status_text}==${FALSE}  Fail  Text not appeared.
    ${status}  Run Keyword And Return Status
    ...  Should Not Be Equal  ${value_before_change}  ${value_after_change}
    IF  ${status}
        Log  Manual tuning was perfomed successfully.  console=true
    ELSE
        Fail  Manual tuning is failed.
    END
    ${all_cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${CHECK_CELLS_TIMEOUT}  10
    ...  Check All Cells
    IF  ${all_cells_status}
        Log  All cells are on air after recovery - recovery succedeed [OK]  console=true
    ELSE
        Fail  Some cells status is not as expected after recovery - recovery filed [NOK]
    END


Get History And Save Report
    Log  Get History and save report  console=true
    Wait Until Element Is Visible  //*[contains(@class, 'p-button-label') and contains(text(), 'Get History')]
    Click Element  //*[contains(@class, 'p-button-label') and contains(text(), 'Get History')]
    Sleep  60s
    ${text_history}  Get Text  //*[contains(@class, 'ot-text ng-star-inserted') and contains(text(), 'Getting history report completed')]
    ${status_text}  Run Keyword And Return Status
    ...  Should Be Equal  '${text_history}'  'Getting history report completed'
    IF  ${status_text}==${FALSE}  Fail  Text not appeared.
    Wait Until Element Is Visible  xpath=//*[contains(@icon, 'mdi mdi-content-save')]
    Wait Until Element Is Visible  xpath=//*[contains(@icon, 'mdi mdi-printer')]
    Click Element  xpath=//*[contains(@icon, 'mdi mdi-content-save')]
    Sleep  10s
    Log  Saving file successfully.  console=true
    ${current_time}  DateTime.Get Current Date  result_format=%H-%M  exclude_millis=true
    ${output}  Run  ls -t /home/ute/Downloads
    ${history_file}  Fetch From Left  ${output}  \n
    Move File  /home/ute/Downloads/${history_file}  ${BTS_FILES}/BTS_clock_tuning_history_report_${TEST_NAME}_${current_time}.txt
    Remove File  /home/ute/Downloads/${history_file}.txt
    Go To Site View


Open WebEM With Mozilla
    [Documentation]  This keyword opens the WebEM in chrome browser and maximizes the window.
    ...  *AUTHOR*: cosmina.rebenciuc@nokia.com
    [Arguments]  ${timeout}

    ${user_agent}  Set Variable  "text/plain" / "application/json"
    ${firefox_options}  Evaluate  sys.modules['selenium.webdriver'].FirefoxOptions()  sys, selenium.webdriver
    Call Method  ${firefox_options}  set_preference  browser.helperApps.neverAsk.saveToDisk  ${user_agent}
    Call Method  ${firefox_options}  add_argument  --headless
    Create Webdriver  Firefox  options=${firefox_options}
    Go To  https://192.168.255.129/#/bts-status/site-view
    Maximize Browser Window
    Check Private Connection
    Login SBTS
    Legal Notice
    Log  Wait until the page is loaded.  console=true
    Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[1]/div  ${timeout}
    ...  WebElement is not fully loaded in ${timeout} seconds.
    Capture Page Screenshot  WebEM_SBTS_initial_state.png


Load initial SCF With Phase Sync
    IF  '${SYNCHRONIZATION_MODE}' == 'PhaseSync'
        Log  Load initial SCF With Phase Sync  console=true
        coam.Perform Commissioning  bts_id=${BTS_ID}  scf_file=${COMMISSIONING_PATH}  skip_parameter_relation_errors=${TRUE}
        ...  should_activate=${TRUE}  timeout=${RECOVERY_TIMEOUT}
        Log  Loading initial SCF is performed successfully.[OK]  console=true
        Log  Wait for all cells to be onAir...  console=true
        Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
        ...  Admin Check All Required State
    END


TC Setup
    Common Test Setup  tc_name=WebEM__Get_Tuning_History_Report_with_Mozilla_and_Chrome


TC Teardown
    Load initial SCF With Phase Sync
    Close All Browsers
    Common Test Teardown
