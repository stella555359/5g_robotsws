*** Settings ***
Documentation  WebEM VDU Resource

Library  DateTime
Library  SeleniumLibrary  run_on_failure=Nothing
Resource  rfs_webem_common.robot

*** Variables ***
${VDU_OPTIONS_MENU}  //*[contains(@aria-label, "Options menu")]/span  # Xpath for options menu
${VDU_SITE_VIEW}  //*[contains(@aria-label, "Site View")]/i  # Xpath for site view button
${VDU_DASHBOARD}  //*[contains(@aria-label, "Dashboard")]/i  # Xpath for dashboard button
${VDU_PARAMETER_EDITOR}  //*[contains(@aria-label, "Parameter Editor")]/i  # Xpath for parameter editor button
${VDU_ALARMS_FROM_SITE_VIEW}  //*[@id="laf-component"]/otx-product-bar/div/div/div[3]/a[6]/i  # Xpath for alarms button
${VDU_PERFORMANCE}  //*[contains(@aria-label, "Performance")]/i  # Xpath for performance button
${COMMISIONING_WIZARD}  //*[contains(@aria-label, "Commissioning Wizard")]  # Xpath for commissioning wizard button

*** Keywords ***

VDU WebEM Setup
    [Documentation]  This keyword is used to vDU WebEM Setup.
    [Arguments]  ${alias}  ${vdu_alias}  ${timeout}=60s

    Set Screenshot Directory  ${Test Results Dir}/webem_screenshots
    Open VDU WebEM  alias=${alias}  vdu_alias=${vdu_alias}  timeout=${timeout}

VDU WebEM Teardown
    [Documentation]  This keyword is used to vDU WebEM Teardown.
    [Arguments]  ${alias}  ${vdu_alias}  ${capture_page_screenshot}=False

    Switch Browser  ${alias}_${vdu_alias}
    Run Keyword If  ${capture_page_screenshot}  Capture BTS Page Screenshot  screenshot_name=vDU_Snapshot_after_test
    Logout From CBTS
    Close Browser

Open VDU WebEM
    [Documentation]  This keyword opens the vDU WebEM in chrome browser and maximizes the window.
    [Arguments]  ${alias}  ${vdu_alias}  ${timeout}  ${capture_page_screenshot}=False

    ${vdu_list}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_VDU
    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}
        FOR  ${key}  ${value}  IN  &{vdu_info}
           Set Test Variable  ${${alias.lower()}_vdu${index+1}_${key.lower()}}  ${value}
        END
    END

    ${vdu_ip}=  Set Variable  ${${alias.upper()}_${vdu_alias.upper()}_IP_ADDRESS}
    ${vdu_port}=  Set Variable  ${${alias.upper()}_${vdu_alias.upper()}_PORT}
    ${vdu_username}=  Set Variable  ${${alias.upper()}_${vdu_alias.upper()}_USERNAME}
    ${vdu_password}=  Set Variable  ${${alias.upper()}_${vdu_alias.upper()}_PASSWORD}

    ${chrome_options}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    ${prefs}  Create Dictionary  download.default_directory=/home/ute/Downloads
    Call Method  ${chrome_options}  add_experimental_option  prefs  ${prefs}
    Call Method  ${chrome_options}  add_argument  --ignore-ssl-errors             # Ignore SSL errors (useful on VMs with self-signed certs)
    Call Method  ${chrome_options}  add_argument  --ignore-certificate-errors     # Bypasses HTTPS certificate checks in test environments
    Call Method  ${chrome_options}  add_argument  --disable-popup-blocking        # Allow popups/windows to open during automation tests
    Call Method  ${chrome_options}  add_argument  --headless\=new                 # Run without UI (headless mode, needed on VMs)
    Call Method  ${chrome_options}  add_argument  --window-size\=1920,1800        # Set window size
    Call Method  ${chrome_options}  add_argument  --force-device-scale-factor\=1  # Ensure consistent scaling in headless mode
    Call Method  ${chrome_options}  add_argument  --no-sandbox                    # Avoid sandbox issues in VMs; safe with/without headless
    Call Method  ${chrome_options}  add_argument  --disable-dev-shm-usage         # Prevent shared memory crashes in VMs; safe with/without headless
    Call Method  ${chrome_options}  add_argument  --disable-gpu                   # Disable GPU acceleration (mainly for headless/Linux VM stability)
    Call Method  ${chrome_options}  add_argument  --disable-extensions            # Disable extensions (reduce overhead; safe with/without headless)
    Create Webdriver  Chrome  alias=${alias}_${vdu_alias}  options=${chrome_options}
    Switch Browser  ${alias}_${vdu_alias}
    Go To  https://${vdu_ip}:${vdu_port}
    Check Private Connection From BTS
    Login On CBTS  username=${vdu_username}  password=${vdu_password}
    Confirm Legal Notice From CBTS
    Log  Wait until the page is loaded!  console=true
    Wait Until Element Is Visible  //span[contains(@class, 'title') and contains(text(), 'Radio Modules Status Summary')]  ${timeout}
    ...  WebElement is not fully loaded in ${timeout} seconds.
    Run Keyword If  ${capture_page_screenshot}  Capture BTS Page Screenshot  screenshot_name=vDU_WebEM_initial_state

Reset VDU From VDU WebEM
    [Documentation]  This keyword is used to reset vDU from vDU WebEM
    [Arguments]  ${alias}  ${vdu_alias}

    Switch Browser  ${alias}_${vdu_alias}
    Wait Until Keyword Succeeds  60  5
    ...  Click Element  ${VDU_DASHBOARD}
    Log  Reset vDU from vDU WebEM  console=true
    Wait Until Keyword Succeeds  30  5
    ...  Click Element  //p-button[@title="Reset vDU"]
    Wait Until Element Is Visible  xpath:/html/body/p-dynamicdialog/div/div  30
    Wait Until Keyword Succeeds  60  5
    ...  Click Element  //span[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'OK')]

Close Start-up View From VDU WebEM
    [Documentation]  This keyword is used to close Start-up view from vDU WebEM

    Log  Close Start-up view from vDU WebEM  console=true
    Wait Until Element Is Visible  //*[contains(@class, 'vdu-startup-view')]  600
    Wait Until Keyword Succeeds  60  5
    ...  Click Element  xpath=//p-button[@id='Close']/button/span
    Log  Start-up view is closed![OK]  console=true

VDU WebEM Open Commissioning Wizard Menu
    [Documentation]
    ...  This keyword id used to open the Commissioning Wizard Menu.
    [Arguments]  ${alias}  ${vdu_alias}  ${timeout}=60

    Switch Browser  ${alias}_${vdu_alias}
    Log  Open Commissioning Wizard menu will be performed  console=true
    Wait Until Element Is Visible  ${COMMISIONING_WIZARD}  ${timeout}
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  ${COMMISIONING_WIZARD}
    Log  Wait until Commissioning Wizard menu page is loaded  console=true
    Wait Until Element Is Visible  xpath=//span[contains(.,'Radio Modules')]  ${timeout}
    ...  Commissioning Wizard menu page is not fully loaded in ${timeout} seconds
    Run Keyword If  ${status}
    ...  Log  Commissioning Wizard menu is open  console=true
    ...  ELSE
    ...  Fail  Commissioning Wizard menu could not be opened!

VDU WebEM Perform Save Commissioning Wizard Changes
    [Arguments]   ${alias}  ${vdu_alias}  ${timeout}=30

    Switch Browser  ${alias}_${vdu_alias}
    Log  Start Save Commissioning Wizard Changes  console=True
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//button[@id='save-btn']
    Wait Until Element Is Visible  xpath=//span[contains(.,'Radio Modules')]  ${timeout}
    Run Keyword If  ${status}
    ...  Log  Save Commissioning Wizard Changes succesfully performed!  console=True
    ...  ELSE
    ...  Fail  Save Commissioning Wizard Changes could not be performed!

VDU WebEM Perform Validate Plan
    [Arguments]   ${alias}  ${vdu_alias}  ${timeout}=30

    Switch Browser  ${alias}_${vdu_alias}
    Log  Start Validate Plan  console=True
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//p-button[@icon='mdi mdi-check-all']//button[@type='button']
    Wait Until Element Is Visible  xpath=//p-button[@icon='mdi mdi-content-save']//button[@type='button']  ${timeout}
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Mouse Out  xpath=//p-button[@icon='mdi mdi-content-save']//button[@type='button']
    Run Keyword If  ${status}
    ...  Log  Validate Plan succesfully performed!  console=True
    ...  ELSE
    ...  Fail  Validate Plan could not be performed!

VDU WebEM Perform Activate Plan without VDU reset
    [Arguments]   ${alias}  ${vdu_alias}  ${timeout}=30

    Switch Browser  ${alias}_${vdu_alias}
    Log  Start Activate Plan  console=True
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//p-button[@id='toolbar-activate-plan-button']//button[@type='button']
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//span[contains(.,'Execute')]
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//span[contains(.,'Close')]
    Wait Until Element Is Visible  xpath=//p-button[@icon='mdi mdi-content-save']//button[@type='button']  ${timeout}
    Run Keyword If  ${status}
    ...  Log  Activate Plan succesfully performed!  console=True
    ...  ELSE
    ...  Fail  Activate Plan could not be performed!

VDU WebEM Perform Activate Plan with VDU reset
    [Arguments]  ${alias}  ${vdu_alias}  ${timeout}=30

    Switch Browser  ${alias}_${vdu_alias}
    Log  Start Activate Plan  console=True
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//p-button[@id='toolbar-activate-plan-button']//button[@type='button']
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//span[contains(.,'Execute')]
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//span[contains(.,'Continue')]
    Close Start-up View From VDU WebEM
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//span[contains(.,'Close')]
    Wait Until Element Is Visible  xpath=//p-button[@icon='mdi mdi-content-save']//button[@type='button']  ${timeout}
    Run Keyword If  ${status}
    ...  Log  Activate Plan succesfully performed! Waiting for VDU reset!  console=True
    ...  ELSE
    ...  Fail  Activate Plan could not be performed!

VDU WebEM Open Parameter Editor Menu
    [Documentation]
    ...  This keyword id used to open the Parameter Editor Menu.
    [Arguments]  ${alias}  ${vdu_alias}  ${timeout}=60

    Switch Browser  ${alias}_${vdu_alias}
    Log  Open Parameter Editor menu will be performed  console=true
    Wait Until Element Is Visible  ${VDU_PARAMETER_EDITOR}  ${timeout}
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  ${VDU_PARAMETER_EDITOR}
    Log  Wait until Parameter Editor menu page is loaded  console=true
    Wait Until Element Is Visible  xpath=//p-button[@icon='mdi mdi-content-save']//button[@type='button']  ${timeout}
    ...  Parameter Editor menu page is not fully loaded in ${timeout} seconds
    Run Keyword If  ${status}
    ...  Log  Parameter Editor menu is open  console=true
    ...  ELSE
    ...  Fail  Parameter Editor menu could not be opened!

VDU WebEM Perform Save Parameter Editor Changes
    [Arguments]   ${alias}  ${vdu_alias}  ${timeout}=60

    Switch Browser  ${alias}_${vdu_alias}
    Log  Start Save Parameter Editor Changes  console=True
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//span[normalize-space()='Save']
    Wait Until Element Is Visible  xpath=//p-button[@icon='mdi mdi-content-save']//button[@type='button']  ${timeout}
    Run Keyword If  ${status}
    ...  Log  Save Parameter Editor Changes succesfully performed!  console=True
    ...  ELSE
    ...  Fail  Save Parameter Editor Changes could not be performed!

VDU WebEM Open Site View Menu
    [Documentation]
    ...  This keyword id used to open the Site View Menu.
    [Arguments]  ${alias}  ${vdu_alias}  ${timeout}=60

    Switch Browser  ${alias}_${vdu_alias}
    Log  Open Site View menu will be performed  console=true
    Wait Until Element Is Visible  ${VDU_SITE_VIEW}  ${timeout}
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  ${VDU_SITE_VIEW}
    Log  Wait until Site View menu page is loaded  console=true
    Wait Until Element Is Visible  xpath=//div[normalize-space()='Radio Modules']  ${timeout}
    ...  Site View menu page is not fully loaded in ${timeout} seconds
    Run Keyword If  ${status}
    ...  Log  Site View menu is open  console=true
    ...  ELSE
    ...  Fail  Site View menu could not be opened!
