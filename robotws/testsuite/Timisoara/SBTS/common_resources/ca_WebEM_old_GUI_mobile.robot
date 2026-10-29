*** Settings ***
Documentation  *AUTHOR*: andreea.burtic@nokia.com
...  This resource is used for WebEM TCs with mobile view and with the old GUI.


*** Variables ***
${LOGIN_USERNAME_MOBILE}  //*[@id="mobile-login-view"]/div/login/div/form/div[4]/input
${LOGIN_PASSWORD_MOBILE}  //*[@id="mobile-login-view"]/div/login/div/form/div[5]/input
${LOGIN_BUTTON_MOBILE}  //*[@id="mobile-login-view"]/div/login/div/form/div[6]/div[1]/div[1]/p-button/button
${LOGIN_OPTION_MOBILE}  //div[contains(@class, "option-button")]
${MOBILE_MENUS_TAB}  //*[@id="main-view"]/div/div[1]/app-header/div[1]/i
${SOFTWARE_MENU_MOBILE}  //div[contains(text(), "Software Management")]
${DIAGNOSTIC_MENU_MOBILE}  //*[@id="main-view"]/div/div[1]/app-header/md-sidenav[1]/main-menu/div[5]/div[1]
${SFP_MONITORING_MOBILE}  //*[@id="main-view"]/div/div[1]/app-header/md-sidenav[1]/main-menu/div[5]/div[3]/div
${SITE_REPORT_MOBILE}  //div[contains(text(), "Site Report")]


*** Keywords ***
Login SBTS Via Mobile
    [Documentation]  This keyword is used to enter user and password into the corresponding fields and login in.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Visible  ${LOGIN_USERNAME_MOBILE}  30
    Input Text  ${LOGIN_USERNAME_MOBILE}  ${OAM_BTS_USER}
    Input Password  ${LOGIN_PASSWORD_MOBILE}  ${OAM_BTS_PASSWORD}
    Click Element  ${LOGIN_BUTTON_MOBILE}


Legal Notice Via Mobile
    [Documentation]  This keyword waits for the legal notice and presses the Confirm button.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Wait for legal notice  console=true
    Wait Until Element Is Visible  //*[contains(text(), 'Legal Notice')]  30s  Legal notice did not appear in 30 seconds.
    Wait Until Element Is Clicked For Mobile
    ...  xpath:/html/body/div[1]/div/div/ui-modal-renderer/login-banner-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button[1]/button
    ...  60
    Log  Admin reached!  console=true


Download Application Logs Via Mobile
    [Documentation]  This keyword is getting the application logs and moving this file to hran_ta directory.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Remove admin_console_log from downloads directory  console=true
    Remove File  ${DOWNLOADS_PATH}/admin_console_log.log
    Wait Until Element Is Visible  ${MOBILE_MENUS_TAB}  60
    Click Element  ${MOBILE_MENUS_TAB}
    Click Element  //*[@id="main-view"]/div/div[1]/app-header/md-sidenav[1]/main-menu/div[6]/div[1]/i
    Click Element  //*[@id="main-view"]/div/div[1]/app-header/md-sidenav[1]/main-menu/div[6]/div[2]/div/div
    Sleep  20  Time for page to be updated
    Move File  ${DOWNLOADS_PATH}/admin_console_log.log  ${BTS_FILES}/admin_console_log_${TEST_NAME}.log


Go To Site View Via Mobile
    [Documentation]  This keyword is used to go to site view via Mobile.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Visible  ${MOBILE_MENUS_TAB}  60
    Click Element  ${MOBILE_MENUS_TAB}
    ${site_view}  Run Keyword And Return Status
    ...  Element Should Be Visible  locator=//*[@id="main-view"]/div/div[1]/app-header/md-sidenav[1]/main-menu/div[1]/div[3]/div/div
    Run Keyword If  '${site_view}' == 'True'
    ...  Wait Until Element Is Clicked For Mobile  xpath=//*[@id="main-view"]/div/div[1]/app-header/md-sidenav[1]/main-menu/div[1]/div[3]/div/div
    ...  ELSE
    ...  Run Keywords
    ...  Wait Until Element Is Clicked For Mobile  xpath=//*[@id="main-view"]/div/div[1]/app-header/md-sidenav[1]/main-menu/div[1]/div[1]/i
    ...  AND
    ...  Wait Until Element Is Clicked For Mobile  xpath=//*[@id="main-view"]/div/div[1]/app-header/md-sidenav[1]/main-menu/div[1]/div[3]/div/div


RAT Reset Via Mobile
    [Documentation]  This keyword is pressing the reset button for the specific technology.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    Log  \n${rat} RAT Reset will be performed.  console=true
    Sleep  15s  Time for page to be updated
    Wait Until Element Is Visible  //*[contains(@class, 'fa fa-info')]  120
    Click Element  //*[contains(@class, 'fa fa-info')]
    Log  ${rat} RAT Reset is ongoing.  console=true
    Click Element  //*[contains(@ui-tooltip, "Reset ${rat}")]
    Click Element  //*[contains(@a-text, 'Reset')]/button
    Sleep  10  Time for page to be updated
    Verify If ${rat} Reset Button Is Disabled
    Sleep  5  Time for page to be updated
    Wait Until Element Is Visible  //*[@id="main-view"]/div/div[1]/app-header/md-backdrop  120
    Click Element  //*[@id="main-view"]/div/div[1]/app-header/md-backdrop


RAT Reset Confirmation Canceled Via Mobile
    [Documentation]  This keyword is pressing the reset button for the specific technology but canceled the confirmation.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    Log  \n${rat} RAT Reset will be performed.  console=true
    Sleep  15s  Time for page to be updated
    Wait Until Element Is Visible  //*[contains(@class, 'fa fa-info')]  120
    Click Element  //*[contains(@class, 'fa fa-info')]
    Click Element  //*[contains(@ui-tooltip, "Reset ${rat}")]
    Click Element  //*[contains(@a-text, 'Cancel')]/button
    Log  Operation is cancelled!  console=true
    Sleep  5  Time for page to be updated
    Wait Until Element Is Visible  //*[@id="main-view"]/div/div[1]/app-header/md-backdrop  120
    Click Element  //*[@id="main-view"]/div/div[1]/app-header/md-backdrop


Get Xpath For Alarm Via Mobile
    [Documentation]  This keyword gets the xpath list for the alarms.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Visible  ${MOBILE_MENUS_TAB}  60
    Click Element  ${MOBILE_MENUS_TAB}
    Click Element  //*[@id="main-view"]/div/div[1]/app-header/md-sidenav[1]/main-menu/div[3]/div/div
    ${alarm_grid_size}  SeleniumLibrary.Get Element Count  class:fm-alarm
    ${alarm_block_xpath}  Create List
    FOR  ${element}  IN RANGE  1  ${alarm_grid_size}+1
        ${alarm}  SeleniumLibrary.Get Element Attribute
        ...  //*[@id="main-view"]/div/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/fault-management-downgrade/div/div[2]/div[${element}]
        ...  class
        ${alarm_element}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/
        ...  fault-management-downgrade/div/div[2]/div[${element}]/div[2]/p-card/div/div[2]/div/div[1]/p[2]
        Run Keyword If  '${alarm}'=='fm-alarm'
        ...  Append To List  ${alarm_block_xpath}  ${alarm_element}
    END

    [Return]  ${alarm_block_xpath}


Open BTS Start-up View Pop-up Via Mobile
    [Documentation]  This keyword Open BTS Start-up View Pop-up Via Mobile.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked For Mobile  ${MOBILE_MENUS_TAB}  120
    ${status_bts_view}  Run Keyword And Return Status
    ...  Element Should Be Visible  //*[@id="main-view"]/div/div[1]/app-header/md-sidenav[1]/main-menu/div[1]/div[2]/div/div
    Run Keyword If  ${status_bts_view}
    ...  Click Element  //*[@id="main-view"]/div/div[1]/app-header/md-sidenav[1]/main-menu/div[1]/div[2]/div/div
    ...  ELSE
    ...  Run Keywords
    ...  Click Element  //*[@id="main-view"]/div/div[1]/app-header/md-sidenav[1]/main-menu/div[1]/div[1]/div
    ...  AND
    ...  Click Element  //*[@id="main-view"]/div/div[1]/app-header/md-sidenav[1]/main-menu/div[1]/div[2]/div/div
