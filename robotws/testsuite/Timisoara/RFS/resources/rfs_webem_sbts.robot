*** Settings ***
Documentation  WebEM SBTS Resource

Library  DateTime
Library  SeleniumLibrary  run_on_failure=Nothing
Resource  rfs_webem_common.robot

*** Variables ***
${VDU_OPTIONS_MENU}  //*[contains(@aria-label, "Options menu")]/span  # Xpath for options menu
${VDU_SITE_VIEW}  //*[contains(@aria-label, "Site View")]/i  # Xpath for site view button
${VDU_DASHBOARD}  //*[contains(@aria-label, "Dashboard")]/i  # Xpath for dashboard button
${SBTS_PARAMETER_EDITOR}  //*[contains(@aria-label, "Parameter Editor")]/i  # Xpath for parameter editor button
${VDU_ALARMS_FROM_SITE_VIEW}  //*[@id="laf-component"]/otx-product-bar/div/div/div[3]/a[6]/i  # Xpath for alarms button
${VDU_PERFORMANCE}  //*[contains(@aria-label, "Performance")]/i  # Xpath for performance button
${COMMISIONING_WIZARD}  //*[contains(@aria-label, "Commissioning Wizard")]  # Xpath for commissioning wizard button

*** Keywords ***

SBTS WebEM Setup
    [Documentation]  This keyword is used to SBTS WebEM Setup.
    [Arguments]  ${alias}  ${timeout}=60s

    Set Screenshot Directory  ${Test Results Dir}/webem_screenshots
    Open SBTS WebEM  alias=${alias}  timeout=${timeout}

SBTS WebEM Teardown
    [Documentation]  This keyword is used to SBTS WebEM Teardown.
    [Arguments]  ${alias}  ${capture_page_screenshot}=False

    Switch Browser  ${alias}
    Run Keyword If  ${capture_page_screenshot}  Capture BTS Page Screenshot  screenshot_name=SBTS_Snapshot_after_test
    Logout From SBTS
    Close Browser

Open SBTS WebEM
    [Documentation]  This keyword opens the SBTS WebEM in chrome browser and maximizes the window.
    [Arguments]  ${alias}  ${timeout}  ${capture_page_screenshot}=False

    ${sbts_ip}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_OAM_IP_ADDRESS
    ${username}=  Set Variable  Nemuadmin
    ${password}=  Set Variable  nemuuser

    ${chrome_options}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    ${prefs}  Create Dictionary  download.default_directory=/home/ute/Downloads
    Call Method  ${chrome_options}  add_experimental_option  prefs  ${prefs}
    Call Method  ${chrome_options}  add_argument  --ignore-ssl-errors          # Ignore SSL errors (useful on VMs with self-signed certs)
    Call Method  ${chrome_options}  add_argument  --ignore-certificate-errors  # Bypasses HTTPS certificate checks in test environments
    Call Method  ${chrome_options}  add_argument  --disable-popup-blocking     # Allow popups/windows to open during automation tests
    Call Method  ${chrome_options}  add_argument  --headless                   # Run without UI (headless mode, needed on VMs)
    Call Method  ${chrome_options}  add_argument  --no-sandbox                 # Avoid sandbox issues in VMs; safe with/without headless
    Call Method  ${chrome_options}  add_argument  --disable-dev-shm-usage      # Prevent shared memory crashes in VMs; safe with/without headless
    Call Method  ${chrome_options}  add_argument  --disable-gpu                # Disable GPU acceleration (mainly for headless/VM stability on Linux)
    Call Method  ${chrome_options}  add_argument  --disable-extensions         # Disable extensions (reduce overhead; safe with/without headless)
    Create Webdriver  Chrome  alias=${alias}  options=${chrome_options}
    Switch Browser  ${alias}
    Go To  https://${sbts_ip}
    Set Window Size  ${1920}  ${1800}
    Maximize Browser Window
    Check Private Connection From BTS
    Login On SBTS  username=Nemuadmin  password=nemuuser
    Confirm Legal Notice From SBTS
    Log  Wait until the page is loaded!  console=true
    Wait Until Element Is Visible  //div[contains(text(),'SMODs/BBMODs')]  ${timeout}
    ...  WebElement is not fully loaded in ${timeout} seconds.
    Run Keyword If  ${capture_page_screenshot}  Capture BTS Page Screenshot  screenshot_name=SBTS_WebEM_initial_state

SBTS WebEM Open Parameter Editor Menu
    [Documentation]
    ...  This keyword id used to open the Parameter Editor Menu.
    [Arguments]  ${alias}  ${timeout}=60

    Switch Browser  ${alias}
    Log  Open Parameter Editor menu will be performed  console=true
    Wait Until Element Is Visible  ${SBTS_PARAMETER_EDITOR}  ${timeout}
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  ${SBTS_PARAMETER_EDITOR}
    Log  Wait until Parameter Editor menu page is loaded  console=true
    Wait Until Element Is Visible  xpath=//p-button[@icon='mdi mdi-content-save']  ${timeout}
    ...  Parameter Editor menu page is not fully loaded in ${timeout} seconds
    Run Keyword If  ${status}
    ...  Log  Parameter Editor menu is open  console=true
    ...  ELSE
    ...  Fail  Parameter Editor menu could not be opened!

