*** Settings ***
Documentation
    ...  This test case is created to check options bar, copyright and WebEM info in online and offline mode.
    ...  Login into WebEM in online mode with 1366x768 pixels and save screenshot with site view page.
    ...  Verify About View in online mode. (application name, application version, Nokia brand sign, list of supported browsers,
    ...  application SW build, copyrights)
    ...  Download Application for offline mode from Options menu.
    ...  Open WebEM in Offline Mode.
    ...  Verify About View in online mode. (application name, application version, Nokia brand sign, list of supported browsers,
    ...  application SW build, copyrights)

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28458
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28458 - Initial TAT creation
    ...  - 22.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29224 - Xpath for build time is removed on release version greater than 25R3

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS25  FEATURE-CB012840

    Step1: Open And Verify About View In Online Mode
    Step2: Download Application And Logout From Online Mode
    Step3: Open And Verify About View In Offline Mode


Step1: Open And Verify About View In Online Mode
    Log  Step1: Open And Verify About View In Online Mode  console=true
    Set Screenshot Directory  ${BTS_FILES}/selenium_screenshot_${TEST_NAME}
    ${chrome_options}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    ${prefs}  Create Dictionary  download.default_directory=/home/ute/Downloads
    Call Method  ${chrome_options}  add_experimental_option  prefs  ${prefs}
    Call Method  ${chrome_options}  add_argument  --ignore-ssl-errors
    Call Method  ${chrome_options}  add_argument  --ignore-certificate-errors
    Call Method  ${chrome_options}  add_argument  --disable-popup-blocking
    Call Method  ${chrome_options}  add_argument  --headless
    Create Webdriver  Chrome  options=${chrome_options}
    Go To  https://${OAM_BTS_IP}
    Set Window Size  ${1366}  ${768}
    Check Private Connection
    Login SBTS
    Legal Notice
    Log  Wait until the page is loaded.  console=true
    Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[1]/div  60
    ...  WebElement is not fully loaded in 60 seconds.
    Capture Page Screenshot  WebEM_SBTS_with_minimum_resolution.png
    Log  Chrome browser was opened with 1366x768 pixels and the screenshot was saved as WebEM_SBTS_with_minimum_resolution.png!  console=true
    Open About Pop-up And Verify The Info


Step2: Download Application And Logout From Online Mode
    Log  Step2: Download Application And Logout From Online Mode  console=true
    Download Application
    Logout From SBTS
    Close Browser


Step3: Open And Verify About View In Offline Mode
    Log  Step3: Open And Verify About View In Offline Mode  console=true
    Open WebEM In Offline Mode
    Open About Pop-up And Verify The Info


Open About Pop-up And Verify The Info
    [Documentation]  This keyword opens about pop-up and verify the info.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Visible  ${OPTIONS_MENU}  60
    Wait Until Element Is Clicked  ${OPTIONS_MENU}  60
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/ul/li[13]/a/span  60
    Wait Until Element Is Visible  //*[contains(@class, 'ot-dialog-title') and contains(text(), 'About Web Element Manager')]  60
    Log  Application name: 'About Web Element Manager' is visible![OK]  console=true
    ${version}  Get Text  xpath:/html/body/p-dynamicdialog/div/div/ng-component/ot-about-dialog/div[1]/div[1]/div/div/div[2]
    Should Start With  ${version}  Version:
    Log  Application version: '${version}' is visible![OK]  console=true
    Wait Until Element Is Visible  //*[contains(@class, "nokia-logo-row")]  10
    Log  Application logo is visible![OK]  console=true
    Wait Until Element Is Visible  //*[contains(@class, 'dialog-row-value') and contains(text(), 'WebEM supports Chrome and Mozilla Firefox.')]  10
    Log  Supported browsers: 'WebEM supports Chrome and Mozilla Firefox' is visible![OK]  console=true
    IF  '${ENB_BRANCH}' < 'SBTS25R3'
        ${build}  Get Text  xpath:/html/body/p-dynamicdialog/div/div/ng-component/ot-about-dialog/div[2]/div[4]/div[2]
        Should Match Regexp  ${build}  ${SPACE}GMT\\+[0-9]{4}$
        Log  Application build: '${build}' is visible![OK]  console=true
    END
    Wait Until Element Is Visible  //*[contains(@class, 'copy-right') and contains(text(), 'Nokia. All rights reserved.')]  10
    Log  Copyrights: 'Nokia. All rights reserved.' is visible![OK]  console=true
    Wait Until Element Is Clicked  //*[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'Close')]  60
    Log  The window for 'About' was closed![OK]  console=true


TC Setup
    Common Test Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
