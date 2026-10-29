*** Settings ***
Documentation  *AUTHOR*: andreea.burtic@nokia.com
...  This resource is used for WebEM TCs with mobile view and with the new GUI.
...  The new GUI is for software releases newer or equal to SBTS25R1.


*** Variables ***
${LOGIN_USERNAME_MOBILE}  //*[@id="loginForm"]/div[1]/input
${LOGIN_PASSWORD_MOBILE}  //*[@id="loginForm"]/div[2]/input
${LOGIN_BUTTON_MOBILE}  //*[contains(@class, 'p-button-label') and contains(text(), 'Login')]
${LOGIN_OPTION_MOBILE}  //*[@id="loginForm"]/div[3]/div[2]/p-button/button/span[2]
${MOBILE_MENUS_TAB}  //*[@id="main-view"]/div/div[1]/div/app-header/product-bar-mob/div/div/button/span[1]
${DIAGNOSTIC_MENU_MOBILE}  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'Diagnostic')]
${SOFTWARE_MENU_MOBILE}  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'Software Management')]
${SFP_MONITORING_MOBILE}  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'SFP Monitoring')]
${SITE_REPORT_MOBILE}  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'Site Report')]


*** Keywords ***
Login SBTS Via Mobile
    [Documentation]  This keyword is used to enter user and password into the corresponding fields and login in.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Visible  ${LOGIN_USERNAME_MOBILE}  30
    Input Text  ${LOGIN_USERNAME_MOBILE}  ${OAM_BTS_USER}
    Input Password  ${LOGIN_PASSWORD_MOBILE}  ${OAM_BTS_PASSWORD}
    Click Element  ${LOGIN_BUTTON_MOBILE}


Logout From SBTS Via Mobile
    [Documentation]  This keyword is used to logout from WebEM.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Visible  ${MOBILE_MENUS_TAB}  60
    Wait Until Element Is Clicked For Mobile  ${MOBILE_MENUS_TAB}  60
    Wait Until Element Is Clicked For Mobile
    ...  //*[@id="main-view"]/div/div[1]/div/app-header/product-bar-mob/div/p-sidebar[1]/div/div[2]/p-panelmenu/div/div[7]/div[1]  60
    Wait Until Element Is Clicked For Mobile  //*[contains(text(), 'Logout')]  60
    Wait Until Element Is Visible  ${LOGIN_USERNAME_MOBILE}  120
    Log  Logout was done successfully!  console=true


Legal Notice Via Mobile
    [Documentation]  This keyword waits for the legal notice and presses the Confirm button.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Wait for legal notice  console=true
    Wait Until Element Is Visible  //*[contains(text(), 'Legal Notice')]  30s  Legal notice did not appear in 30 seconds.
    Wait Until Element Is Clicked For Mobile  //*[contains(text(), 'Accept')]  60
    Wait Until Keyword Succeeds  300  5  Page Should Contain  RMODs/ASIRMODs
    Sleep  60s  Time for all cells to be visible
    Log  Admin reached!  console=true


Download Application Logs Via Mobile
    [Documentation]  This keyword is getting the application logs and moving this file to hran_ta directory.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Remove admin_console_log from downloads directory  console=true
    Remove File  ${DOWNLOADS_PATH}/admin_console_log.log
    Wait Until Element Is Visible  ${MOBILE_MENUS_TAB}  60
    Wait Until Element Is Clicked For Mobile  ${MOBILE_MENUS_TAB}  60
    Wait Until Element Is Clicked For Mobile
    ...  //*[@id="main-view"]/div/div[1]/div/app-header/product-bar-mob/div/p-sidebar[1]/div/div[2]/p-panelmenu/div/div[6]/div[1]  60
    Wait Until Element Is Clicked For Mobile  //*[contains(text(), 'Download Application Logs')]  60
    Sleep  20  Time for page to be updated
    Move File  ${DOWNLOADS_PATH}/admin_console_log.log  ${BTS_FILES}/admin_console_log_${TEST_NAME}.log


RAT Reset Via Mobile
    [Documentation]  This keyword is pressing the reset button for the specific technology.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    Log  \n${rat} RAT Reset will be performed.  console=true
    Sleep  15s  Time for page to be updated
    Wait Until Element Is Visible  //*[contains(@class, 'fa fa-info')]  120
    Wait Until Element Is Clicked For Mobile  xpath=//*[contains(@class, 'fa fa-info')]
    Log  ${rat} RAT Reset is ongoing.  console=true
    Wait Until Element Is Clicked For Mobile  xpath=//*[contains(@ui-tooltip, "Reset ${rat}")]
    Wait Until Element Is Clicked For Mobile  xpath=//*[contains(@a-text, 'Reset')]/button
    Verify If ${rat} Reset Button Is Disabled
    Sleep  5  Time for page to be updated
    Wait Until Keyword Succeeds  30  5  Wait Until Element Is Visible  xpath:/html/body/div[4]  120
    Wait Until Element Is Clicked For Mobile  xpath:/html/body/div[4]


RAT Reset Confirmation Canceled Via Mobile
    [Documentation]  This keyword is pressing the reset button for the specific technology but canceled the confirmation.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    Log  \n${rat} RAT Reset will be performed.  console=true
    Sleep  15s  Time for page to be updated
    Wait Until Element Is Visible  //*[contains(@class, 'fa fa-info')]  120
    Wait Until Element Is Clicked For Mobile  xpath=//*[contains(@class, 'fa fa-info')]
    Wait Until Element Is Clicked For Mobile  xpath=//*[contains(@ui-tooltip, "Reset ${rat}")]
    Wait Until Element Is Clicked For Mobile  xpath=//*[contains(@a-text, 'Cancel')]/button
    Log  Operation is cancelled!  console=true
    Sleep  5  Time for page to be updated
    Wait Until Element Is Visible  xpath:/html/body/div[4]  120
    Wait Until Element Is Clicked For Mobile  xpath:/html/body/div[4]


Go To Site View Via Mobile
    [Documentation]  This keyword is used to go to site view via Mobile.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Visible  ${MOBILE_MENUS_TAB}  60
    Wait Until Element Is Clicked For Mobile  ${MOBILE_MENUS_TAB}  90
    ${site_view}  Run Keyword And Return Status
    ...  Wait Until Element Is Clicked For Mobile  xpath=//*[@id="simplified-site"]
    IF  ${site_view}
        Log  Site View is visible!  console=true
    ELSE
        Wait Until Element Is Clicked For Mobile  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'BTS Status')]
        Wait Until Element Is Clicked For Mobile  xpath=//*[@id="simplified-site"]
    END


Get Xpath For Alarm Via Mobile
    [Documentation]  This keyword gets the xpath list for the alarms.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Visible  ${MOBILE_MENUS_TAB}  60
    Wait Until Element Is Clicked For Mobile  xpath=${MOBILE_MENUS_TAB}
    Wait Until Element Is Clicked For Mobile  xpath=//*[@id="alarms"]/span[2]
    ${alarm_grid_size}  SeleniumLibrary.Get Element Count  class:fm-alarm
    ${alarm_block_xpath}  Create List
    FOR  ${element}  IN RANGE  1  ${alarm_grid_size}+1
        ${alarm}  SeleniumLibrary.Get Element Attribute
        ...  //*[@id="main-view"]/div/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/fault-management-downgrade/div/div[2]/div[${element}]
        ...  class
        ${alarm_element}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/
        ...  fault-management-downgrade/div/div[2]/div[${element}]/div[2]/p-card/div/div[2]/div/div[1]/p[2]
        Run Keyword If  '${alarm}'=='fm-alarm ng-star-inserted'
        ...  Append To List  ${alarm_block_xpath}  ${alarm_element}
    END

    [Return]  ${alarm_block_xpath}


Open BTS Start-up View Pop-up Via Mobile
    [Documentation]  This keyword Open BTS Start-up View Pop-up Via Mobile.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked For Mobile  ${MOBILE_MENUS_TAB}  120
    Sleep  10s  Time for page to be updated
    ${status_bts_view}  Run Keyword And Return Status
    ...  Element Should Be Visible  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'BTS Start-up View')]
    Run Keyword If  ${status_bts_view}
    ...  Wait Until Element Is Clicked For Mobile  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'BTS Start-up View')]
    ...  ELSE
    ...  Run Keywords
    ...  Wait Until Element Is Clicked For Mobile  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Status')]
    ...  AND
    ...  Wait Until Element Is Clicked For Mobile  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'BTS Start-up View')]


Collect Snapshot And Ensure Mobile GUI Does Not Lock
    [Documentation]  Collects a snapshot in the background and ensures the mobile WebEM GUI does not lock during collection.
    [Arguments]  ${snapshot_name}  ${timeout}=1800

    Log  Wait up to ${timeout}s to collect snapshot.  console=true
    Wait Until Keyword Succeeds  5x  30  Setup Admin  bts_host=${OAM_BTS_IP}  name=snapshot_collection
    ${snapshot}  Run Keyword In Background  Collect Snapshot  ${BTS_FILES}/${snapshot_name}  timeout=1800
    ...  connection=snapshot_collection
    ${timeout_collection}  Evaluate  ${timeout}/5
    FOR  ${i}  IN RANGE  ${timeout_collection}
      Click Element  ${MOBILE_MENUS_TAB}
      Click Element At Coordinates  //*[@id="main-view"]  100  100
      ${status}  ${text}  Run Keyword And Ignore Error  Collect Keyword Result  ${snapshot}  5
      Exit For Loop If  '${status}'=='PASS'
    END
    Log  Snapshot collected.  console=true
    [Teardown]  Teardown Admin  snapshot_collection


Go To Site Report Via Mobile
    [Documentation]  This keyword is used to go to site report via Mobile.
    ...  *AUTHOR*: cristina.adam@nokia.com

    Wait Until Element Is Visible  ${MOBILE_MENUS_TAB}  60
    Wait Until Element Is Clicked For Mobile  ${MOBILE_MENUS_TAB}  90
    ${site_report}  Run Keyword And Return Status  Element Should Be Visible  //*[@id="site-report"]
    IF  ${site_report}
        Wait Until Element Is Clicked For Mobile  xpath=//*[@id="site-report"]
    ELSE
        Wait Until Element Is Clicked For Mobile  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'BTS Status')]
        Wait Until Element Is Clicked For Mobile  xpath=//*[@id="site-report"]
    END
