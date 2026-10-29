*** Settings ***
Documentation  BTS Log Level general
Library    SeleniumLibrary
#Library    taf.sbts.oam.coam.admin  WITH NAME  coam

*** Variables ***
${NAVI_BAR_OPTIONS}=  //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[3]/div/a/span
${NAVI_BAR_OPTIONS_SETTING}=  //*[@id="laf-component"]/div/ul/li[1]/a/span
${SETTINGS_LOCK_SCREEN_INPUT_25}=  //*[@id="main-view"]/div/div[1]/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div
...  /settings/div/div/div/div/general-settings-tab/div/div/div[1]/ui-text-input/div/input
${SETTINGS_LOCK_SCREEN_INPUT}=  //*[@id="main-view"]/div/div[1]/div/div/div[1]/ng-view/wf-panel/wf-panel-section/div/div
...    /settings/div/div/div/div/general-settings-tab/div/div[1]/div/ui-text-input/div/input
${BTS_LOG_VIEW}   //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[1]/ot-compact-drawer/p-sidebar/
...  div/div[2]/p-panelmenu/div/div[6]
${BTS_send}   xpath=//span[text()="Sending log data level completed"]
*** Keywords ***
WebEM Login
    [Documentation]
    ...  *AUTHOR* lukasz.targonski@nokia.com
    ...  This keyword opens browser session to WebEM.
    ...  History of changes:
    ...  16.10.2020 - Iuliia Taupeka. Changes due to: https://jira3.ext.net.nokia.com/browse/TAT-20341
    ...  11.06.2021 - Stepan Radysh.  Changes due to: https://jira3.ext.net.nokia.com/browse/TAT-21466

    Check And Resolve Google Chrome And Webdriver Version Compatibility
    ${chrome_params}=  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    Call Method    ${chrome_params}    add_argument    --no-sandbox
    Call Method    ${chrome_params}    add_argument    --headless
    Call Method    ${chrome_params}    add_argument    --disable-extensions
    Call Method    ${chrome_params}    add_argument    --disable-gpu
    Call Method    ${chrome_params}    add_argument    --ignore-certificate-errors
    Create Webdriver    Chrome    chrome_options=${chrome_params}

    Maximize Browser Window
    Go To  https://192.168.255.129/#/login
    Wait Until Keyword Succeeds  1m  5s  Location Should Be  https://192.168.255.129/#/login

    Run Keyword And Ignore Error  Click Button  //button[@id='details-button']
    Sleep  3s
    Run Keyword And Ignore Error  Click Element  //a[@id='proceed-link']
    sleep  10s

    Input Text  login-username  Nemuadmin
    Input Text  login-password  nemuuser
    Press Keys  login-password  RETURN

    Wait Until Keyword Succeeds  1m  5s  Location Should Be  https://192.168.255.129/#/bts-status/site-view

    Run Keyword If  '${sbts version}'=='SBTS24'    Wait Until Page Contains Element
    ...  xpath=/html/body/div[1]/div/div/ui-modal-renderer/login-banner-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button[1]/button
    ...  ELSE  Wait Until Page Contains Element
    ...  xpath=//*[@id="main-view"]/div/div[1]/div[1]/login-banner/login-banner-modal/ot-dialog/p-dialog/div/div/div[3]/ot-footer/p-button[1]/button
    ...  timeout=30s

    Run Keyword If  '${sbts version}'=='SBTS24'  Click Button
    ...  xpath=/html/body/div[1]/div/div/ui-modal-renderer/login-banner-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button[1]/button
    ...  ELSE  Click Button
    ...  xpath=//*[@id="main-view"]/div/div[1]/div[1]/login-banner/login-banner-modal/ot-dialog/p-dialog/div/div/div[3]/ot-footer/p-button[1]/button

WebEM Login with the given path to download files
    [Arguments]    ${DIR_DOWNLOADS}
    [Documentation]
    ...  This keyword opens browser session to WebEM on primary core with given path to download files

    Log  Login to WebEM ongoing...    console=${True}
    Check And Resolve Google Chrome And Webdriver Version Compatibility
    ${chrome_options}=    Create Dictionary
    Set To Dictionary    ${chrome_options}    no-sandbox    True
    Set To Dictionary    ${chrome_options}    headless    True
    Set To Dictionary    ${chrome_options}    disable-extensions    True
    Set To Dictionary    ${chrome_options}    disable-gpu    True
    Set To Dictionary    ${chrome_options}    ignore-certificate-errors    True
    ${prefs}=    Create Dictionary    download.default_directory=${DIR_DOWNLOADS}
    Set To Dictionary    ${chrome_options}    prefs    ${prefs}
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome_options}    add_experimental_option    prefs    ${prefs}
    Call Method    ${chrome_options}    add_argument    --no-sandbox
    Call Method    ${chrome_options}    add_argument    --headless
    Call Method    ${chrome_options}    add_argument    --disable-extensions
    Call Method    ${chrome_options}    add_argument    --disable-gpu
    Call Method    ${chrome_options}    add_argument    --ignore-certificate-errors
    Create Webdriver    Chrome    chrome_options=${chrome_options}

    Go To  https://192.168.255.129/#/login
    Wait Until Keyword Succeeds  1m  5s  Location Should Be  https://192.168.255.129/#/login

    Run Keyword And Ignore Error  Click Button  //button[@id='details-button']
    Sleep  3s
    Run Keyword And Ignore Error  Click Element  //a[@id='proceed-link']
    sleep  10s

    Input Text  login-username  Nemuadmin
    Input Text  login-password  nemuuser
    Press Keys  login-password  RETURN

    Wait Until Keyword Succeeds  1m  5s  Location Should Be  https://192.168.255.129/#/bts-status/site-view

    Run Keyword If  '${sbts version}'=='SBTS24'    Wait Until Page Contains Element
    ...  xpath=/html/body/div[1]/div/div/ui-modal-renderer/login-banner-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button[1]/button
    ...  ELSE  Wait Until Page Contains Element
    ...  xpath=//*[@id="main-view"]/div/div[1]/div[1]/login-banner/login-banner-modal/ot-dialog/p-dialog/div/div/div[3]/ot-footer/p-button[1]/button
    ...  timeout=30s

    Run Keyword If  '${sbts version}'=='SBTS24'  Click Button
    ...  xpath=/html/body/div[1]/div/div/ui-modal-renderer/login-banner-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button[1]/button
    ...  ELSE  Click Button
    ...  xpath=//*[@id="main-view"]/div/div[1]/div[1]/login-banner/login-banner-modal/ot-dialog/p-dialog/div/div/div[3]/ot-footer/p-button[1]/button

    Sleep    60s
    Log  Login to WebM successful!    console=${True}

Check And Resolve Google Chrome And Webdriver Version Compatibility
    [Documentation]
    ...  *AUTHOR* iuliia.taupeka@nokia.com
    ...  This keyword is created as temporary workaround for incompatibility of Google Chome and webdriver version
    ...  Chrome driver installed (older version) to match to the currently installed version of Google Chrome
    ...  23.02.2021 - Iuliia Taupeka. Changes due to TAT-20341 and to resolve issue of incompatibility
    ...  between Google Chrome and webdriver versions.

    ${googlechrome_version}  Run  google-chrome --version
    Log  ${googlechrome_version}  console=${True}
    ${googlechrome_version}  Evaluate  re.search(r'(\\d+)..*', '${googlechrome_version}' ).group(1)  re
    ${googlechrome_version}  Convert To Integer  ${googlechrome_version}

    ${driver_version}  Run  chromedriver --version
    Log  ${driver_version}  console=${True}
    ${driver_version}  Evaluate  re.search(r'(\\d+)..*', '${driver_version}' ).group(1)  re
    ${driver_version}  Convert To Integer  ${driver_version}

    ${install_cmd}  Set Variable  sudo apt install -y --allow-downgrades ute-chromedriver=${googlechrome_version}

    Run Keyword If  ${googlechrome_version}!=${driver_version}  Run Keywords
    ...  Log  Chrome and webdriver versions not compatible, installing webdriver ${googlechrome_version} !  console=${True}
    ...  AND  Run  ${install_cmd}
    ...  AND  Sleep  3s
    ...  ELSE  Run Keywords  Log  Versions are compatible.  console=${True}
    ...  AND  Return From Keyword

    ${driver_version}  Run  chromedriver --version
    ${driver_version}  Evaluate  re.search(r'(\\d+)..*', '${driver_version}' ).group(1)  re
    ${driver_version}  Convert To Integer  ${driver_version}
    Run Keyword If  ${driver_version}==${googlechrome_version}  Log  Install Webriver for chrome ${googlechrome_version} successful!  console=${True}
    ...  ELSE  run keywords  Log  Installation Webriver for chrome ${googlechrome_version} failed!${\n}  console=${True}
    ...  AND  Set Test NoRun  Installation Webriver for chrome ${googlechrome_version} did not succeed!${\n}

Go To BTS Log Level View
    [Documentation]
    ...  *AUTHOR* lukasz.targonski@nokia.com
    ...  This keyword opens BTS Log Level view in WebEM.

    Sleep  30
    Click Element
    ...    xpath=//*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[1]/ot-compact-drawer/button/span[1]
    Sleep  5

    Click Element   ${BTS_LOG_VIEW}
    Sleep  5

    Scroll Element Into View
    ...     locator=//*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[1]/ot-compact-drawer/p-sidebar/div/div[2]

    Click Element  xpath=//span[text()="BTS Log Level"]
    Wait Until Page Contains Element  xpath=//span[text()="Reading log data level completed"]  timeout=20s

Check If BTS Log Level In WebEM Is Set To
    [Documentation]
    ...  *AUTHOR* lukasz.targonski@nokia.com
    ...  This keyword checkes if correct BTS Log Level is displayed in WebEM.
    ...  *INPUT*
    ...  | Parameter              | Description                                              |
    ...  | bts_log_level          | bts log level value, for example: 1      |
    ...  *OUTPUT*
    ...  | True, if BTS Log Level is correct
    ...  | False, if BTS log level is incorrect

    [Arguments]  ${bts_log_level}

    Run Keyword If  '${bts_log_level}'=='other'  Run Keywords
    ...  Wait Until Page Contains Element
    ...  xpath=//span[text()="Current log data level in BTS is different than Minimum, Normal or Full. Define a new log data level."]  timeout=30s
    ...  AND  Close Browser
    ...  AND  Return From Keyword  ${True}
    Sleep    15s
    ${result}=  Run Keyword And Return Status  Page Should Contain Element
    ...    xpath=//input[@type='radio' and @value='${bts_log_level}' and @aria-checked='true']
    Page Should Contain Element    xpath=//input[@type='radio' and @value='${bts_log_level}']
    log to console      Does the radio element exist and have the value ${bts_log_level}? ${result}
    Return From Keyword    ${result}
    Run Keyword If  '${result}'=='FAIL'
    ...  Return From Keyword  ${False}
    ...  ELSE  Return From Keyword  ${True}

Check If BTS Log Level Validity In WebEM Is Set To
    [Documentation]
    ...  *AUTHOR* lukasz.targonski@nokia.com
    ...  This keyword checkes if correct BTS Log Level is displayed in WebEM.
    ...  *INPUT*
    ...  | Parameter              | Description                                              |
    ...  | bts_log_level          | bts log level value, for example: 1      |
    ...  *OUTPUT*
    ...  | True, if BTS Log Level is correct
    ...  | False, if BTS log level is incorrect

    [Arguments]  ${validity}=PersistentChanges

    ${result}  ${_}  Run Keyword And Ignore Error  Radio Button Should Be Set To  validityRadio  ${validity}
    Run Keyword If  '${result}'=='FAIL'
    ...  Return From Keyword  ${False}
    ...  ELSE  Return From Keyword  ${True}

Change Bts Log Level
    [Arguments]    ${bts_log_level}    #${validity}=PersistentChanges
    Wait Until Element Is Visible    xpath=//p-radiobutton[.//input[@value='${bts_log_level}']]//label    timeout=10s
    Click Element                    xpath=//p-radiobutton[.//input[@value='${bts_log_level}']]//label
    Log To Console    bts_log_level for Click is: ${bts_log_level}
    Click Element    xpath=//button[.//span[normalize-space(text())='Send']]
    Log To Console    bts_log_level for send is: ${bts_log_level}
    ${result}  ${_}=  Run Keyword And Ignore Error  Wait Until Page Contains Element  ${BTS_send}   timeout=30s
    Run Keyword If  '${result}'=='FAIL'  Return From Keyword  ${False}
    ...  ELSE  Return From Keyword  ${True}

Restore Bts Log Level
    [Documentation]
    ...  *AUTHOR* lukasz.targonski@nokia.com
    ...  This keyword restores BTS Log Level using WebEM.

    Click Element  xpath=//ui-button/button[text()=' Restore Defaults']
    Wait Until Page Contains Element  xpath=//span[text()="Restoring factory defaults..."]  timeout=20s
    Wait Until Page Contains Element  xpath=//span[text()="Reading log data level completed"]  timeout=20s

Go To Certificate Managment View
    [Documentation]
    ...  *AUTHOR* lukasz.targonski@nokia.com
    ...  This keyword opens Certificate Managment view in WebEM.
    Wait Until Page Contains Element  xpath=//div[@aria-describedby\="admin.navigationBar.configuration.TITLE"]  timeout=30s
    Sleep  60s
    Click Element  xpath=//i[@class='nav-menu-link-icon ng-scope fa fa-cog']
    Click Element  xpath=//span[text()="Certificate Management"]

Upload Certificate File
    [Arguments]  ${file_location}
    Go To Certificate Managment View
    Choose File  xpath=//input[@accept='.pem,.der,.crt,.cer']  ${file_location}
    Wait Until Page Contains Element  xpath=//span[normalize-space()='Install']  timeout=60s
    Click Element  xpath=//span[normalize-space()='Install']
    Wait Until Page Contains Element  xpath=//span[text()="Certificates installation completed"]  timeout=60s

Remove Certificate File
    Go To Certificate Managment View
    Wait Until Page Contains Element  xpath=//div[@class='p-checkbox-box']
    Click Element  xpath=//div[@class='p-checkbox-box']
    Click Element  xpath=//span[normalize-space()='Delete']
    Wait Until Page Contains Element  xpath=//p[contains(text(),'Deletion of CA certificate may prevent establishme')]  timeout=60s
    Click Element
    ...  xpath=//button[@class='p-ripple p-element p-button p-component']//span[@class='p-button-label ng-star-inserted'][normalize-space()='Delete']
    Sleep  60s

Change Screen Lock Timeout
    [Documentation]
    ...  *AUTHOR* damian.kotula@nokia.com
    ...  This KW sets WebEm screen lock timeout to 60 min. Different timeout can be set by passing timeout value in minutes as argument.
    [Arguments]    ${timeout_value}=60
    Run Keyword If  '${sbts version}'=='SBTS25'    Run Keywords
    ...    Wait Until Keyword Succeeds  2min  2s  Click Element  ${NAVI_BAR_OPTIONS}
    ...    AND    Wait Until Keyword Succeeds  1min  2s  Click Element  ${NAVI_BAR_OPTIONS_SETTING}
    ...    AND    Wait Until Page Contains Element  ${SETTINGS_LOCK_SCREEN_INPUT_25}
    ...    AND    Input Text  ${SETTINGS_LOCK_SCREEN_INPUT_25}    ${timeout_value}
    ...    AND    Sleep    5
    ...    AND    Click Element  xpath=//button[text()=" Apply"]
    ...    AND    Capture Page Screenshot
    ...    ELSE  Run Keywords
    ...    Wait Until Keyword Succeeds  2min  2s  Click Element  ${NAVI_BAR_OPTIONS}
    ...    AND    Wait Until Keyword Succeeds  1min  2s  Click Element  ${NAVI_BAR_OPTIONS_SETTING}
    ...    AND    Wait Until Page Contains Element  ${SETTINGS_LOCK_SCREEN_INPUT}
    ...    AND    Input Text  ${SETTINGS_LOCK_SCREEN_INPUT}    ${timeout_value}
    ...    AND    Sleep    5
    ...    AND    Click Element  xpath=//button[text()=" Apply"]
    ...    AND    Capture Page Screenshot
