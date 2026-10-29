*** Settings ***
Documentation  *AUTHOR*: andreea.burtic@nokia.com
...  This resource is used for WebEM TCs with the old GUI.


*** Variables ***
${SBTS_NAME_XPATH}  //*[@id="main-view"]/div/div[1]/div[1]/div/div[1]/div[1]/div[2]/div[2]
${COMMISIONING_WIZARD}  //*[contains(@ui-tooltip, "Commissioning Wizard")]
${PARAMETER_EDITOR}  //*[@id="main-view"]/div/div[1]/app-header/div[2]/shortcuts-menu/ul/li[3]/nav-link/a
${ALARMS_BUTTON_SITE_VIEW}  //*[contains(@ui-tooltip, "Alarms Total Number")]
${BTS_COUNTERS}  //*[contains(@ui-tooltip, "BTS Counters")]
${DETAILED_SITE_VIEW}  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/site-runtime-views/div/ul/li[2]
${RF_DIAGNOSTIC_TEST}  //span[contains(text(),'RF Diagnostic Test')]
${TEST_SETUP}  //span[contains(text(),'Test Setup')]
${RESET_TO_TEST_DEDICATED_STATE}  //span[contains(text(),'Reset to Test Dedicated State')]
${TEST_MODELS}  //span[contains(text(),'Test Models')]
${NR_DOWNLINK_TEST}  //li[@heading="NR Downlink"]
${TDS_SIGN}  //*[@id="main-view"]/div/div[1]/div[1]/div/div[1]/div[2]/tds-element/span
${USER_ACCOUNT_TAB}  //*[@id="main-view"]/div/div[1]/app-header/div[2]/user-account-management/nav-item/div/nav-menu-link
${USER_ACCOUNT_MANAGEMENT}  //*[contains(@aria-label, "User Account Management")]/i
${ACCOUNT_NAME_CLASS}  user-account-name ng-binding
${RAD_ICON}  //*[contains(@ui-tooltip, "At least one R&D debug parameter is set to non-default value")]
${SW_NAME}  //*[@id="main-view"]/div/div[1]/div[1]/div/div[1]/div[3]/a/span
${VALIDATE_PLAN_PE}  //*[contains(@ng-reflect-text, "Validate Plan")]
${ACTIVATE_PLAN_PE}  //*[contains(@ng-reflect-text, "Activate Plan")]
${FIX_ERRORS}  //*[contains(@ng-reflect-text, "Fix Errors")]
${OPTIONS_MENU}  //*[contains(@ng-reflect-text, "Options")]


*** Keywords ***
Legal Notice
    [Documentation]  This keyword waits for the legal notice and presses the Confirm button.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Wait for legal notice  console=true
    Wait Until Element Is Visible  //*[contains(text(), 'Legal Notice')]  30s  Legal notice did not appear in 30 seconds.
    Wait Until Element Is Visible  //*[contains(@a-text, "Confirm")]  timeout=60s
    ${banner_text}  Get Text  //*[contains(@class, "modal-body-transclude")]
    Set Test Variable  ${BANNER_TEXT}
    Click Element  //*[contains(@a-text, "Confirm")]
    Log  Admin reached!  console=true


Download Application Logs
    [Documentation]  This keyword is getting the application logs and moving this file to hran_ta directory.
    ...  *AUTHOR* andreea.burtic@nokia.com

    Log  Remove admin_console_log from downloads directory  console=true
    Remove File  ${DOWNLOADS_PATH}/admin_console_log.log
    Wait Until Element Is Visible  //*[@id="main-view"]/div/div[1]/app-header/div[2]/menu-bar  60
    Wait Until Element Is Clicked  //*[@id="main-view"]/div/div[1]/app-header/div[2]/menu-bar  60
    Wait Until Element Is Clicked
    ...  //*[@id="main-view"]/div/div[1]/app-header/div[2]/menu-bar/nav-item/div/ng-transclude/ul/li[5]/a  60
    Sleep  120  Time for application logs to be saved!
    ${current_time}  DateTime.Get Current Date  result_format=%H-%M  exclude_millis=True
    Move File  ${DOWNLOADS_PATH}/admin_console_log.log  ${BTS_FILES}/admin_console_log_${TEST_NAME}_${current_time}.log


Logout From SBTS
    [Documentation]  This keyword is used to disconnect from SBTS.
    ...  *AUTHOR* andreea.burtic@nokia.com

    Wait Until Element Is Clicked  //nav-item[contains(@class, "user-account")]  300
    Wait Until Element Is Clicked  //button[@aria-label="Logout"]  120
    Log  Logout from WebEM was successfully done!  console=true


RAT Reset
    [Documentation]  This keyword is pressing the reset button for the specific technology.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    Log  \n${rat} RAT Reset will be performed.  console=true
    Wait Until Element Is Visible  //*[contains(@ui-tooltip, "Reset ${rat}")]  60
    Click Element  //*[contains(@ui-tooltip, "Reset ${rat}")]
    Click Element  //*[contains(@a-text, 'Reset')]/button


RAT Reset Confirmation Canceled
    [Documentation]  This keyword is pressing the reset button for the specific technology but canceled the confirmation.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    Log  \n${rat} RAT Reset will be performed.  console=true
    Wait Until Element Is Visible  //*[contains(@ui-tooltip, "Reset ${rat}")]  60
    Click Element  //*[contains(@ui-tooltip, "Reset ${rat}")]
    Click Element  //*[contains(@a-text, 'Cancel')]/button
    Log  Operation is canceled!  console=true


Get Active Alarms From WebEM
    [Documentation]  This keyword is used to get active alarms from WebEM.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked  xpath=${ALARMS_BUTTON_SITE_VIEW}
    Sleep  10s  Time for page to be updated
    ${active_alarms}  Create Dictionary
    ${alarm}  SeleniumLibrary.Get Element Count  class:alarm-row
    FOR  ${id}  IN RANGE  1  ${alarm}+1
        ${fault_id}  Get Text  //*[contains(@alarm-type, 'current')]/ui-table/div/ng-transclude/table/tbody/tr[${id}]/td[5]
        ${fault_name}  Get Text  //*[contains(@alarm-type, 'current')]/ui-table/div/ng-transclude/table/tbody/tr[${id}]/td[6]
        ${severity}  SeleniumLibrary.Get Element Attribute
        ...  //*[contains(@alarm-type, 'current')]/ui-table/div/ng-transclude/table/tbody/tr[${id}]/td[1]/alarm-bell-icon/div  ui-tooltip
        ${id_alarm}  Convert To String  ${id}
        Set To Dictionary  ${active_alarms}  ${fault_id}=${fault_name}
    END
    Remove From Dictionary  ${active_alarms}  4655  61524  61649

    [Return]  ${active_alarms}


Go To Site View
    [Documentation]  This keyword is used to go to site view.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked  xpath=//*[contains(@ui-tooltip, "Site View")]


Performing Configuration Reset Via WebEM
    [Documentation]
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    ...  This KW execute configuration reset via WebEM and wait until execution is succeeded.

    Log  Performing Configuration Reset via WebEM  console=true
    Click Element  locator=//*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[2]/div/nav-menu-link/span
    Click Element  //*[contains(text(), 'Configuration Reset')]
    ${first_button}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/configuration-reset/wf-panel/
    ...  wf-panel-section/div/div/div/div[1]/div/label[1]/span
    Wait Until Element Is Visible  locator=${first_button}  timeout=60
    Click Element  ${first_button}
    ${second_button}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/configuration-reset/wf-panel/
    ...  wf-panel-section/div/div/div/div[1]/div/label[2]/span
    Wait Until Element Is Visible  locator=${second_button}  timeout=60
    Click Element  ${second_button}
    Click Element  locator=//button[contains(text(),'Execute Reset')]
    Click Element  locator=//button[contains(text(),'Execute') and not(contains(text(),'Execute Reset'))]
    Log  Execute button is pushed, configuration reset via WebeM is performing![OK]  console=true
    Wait Until Element Is Visible  locator=//*[contains(text(), 'Execution succeeded.')]  timeout=600
    Log  Execution succeeded![OK]  console=true
    Plug And Play Pop-up


Performing Configuration Reset Via BTS Rescue Console
    [Documentation]
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    ...  This KW execute configuration reset via BTS Rescue Console.
    ...  Verify if execution is succeeded and sleep for ${bts_rescue_console_timeout} before the page is reloaded and RC is visible.
    ...  Login on BTS Rescue Console.
    ...  Activate option ${config_reset_option} on primary software.
    ...  Wait for ${bts_rescue_console_timeout} before the page is reloaded and Web Element Manager is visible.
    [Arguments]  ${bts_rescue_console_timeout}  ${config_reset_option}  ${username}  ${password}

    Log  Performing Configuration Reset via BTS Rescue Console  console=true
    Click Element  //*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[2]/div/nav-menu-link
    Click Element  //*[contains(text(), 'Configuration Reset')]
    Click Element  locator=//button[contains(text(),'Execute Reset')]
    Click Element  locator=//button[contains(text(),'Execute') and not(contains(text(),'Execute Reset'))]
    Log  Execute button is pushed, configuration reset via BTS Rescue Console is performing![OK]  console=true
    Wait Until Element Is Visible  locator=//*[contains(text(), 'Execution succeeded.')]  timeout=600
    Log  Execution succeeded![OK]  console=true
    Log  Sleep for ${bts_rescue_console_timeout} until reload page is needed!  console=true
    Sleep  ${bts_rescue_console_timeout}  Time for page to be updated
    Reload Page
    Login To BTS Rescue Console  ${username}  ${password}
    Activate The Specific Option For Configuration Reset  ${config_reset_option}
    Log  Message 'Connection with the BTS has been lost' is visible and sleep for ${bts_rescue_console_timeout} is needed![OK]  console=true
    Sleep  ${bts_rescue_console_timeout}  Time for page to be updated
    Reload Page
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  //*[@id="login-username"]  60
    Run Keyword If  ${status}
    ...  Run Keywords
    ...  Sleep  60s  Time for page to be updated
    ...  AND
    ...  Login SBTS
    ...  AND
    ...  Legal Notice
    Wait Until Element Is Visible  locator=//*[@id="main-view"]/div/div[1]/app-header/div[1]  timeout=300
    Log  Web Element Manager is visible![OK]


Open BTS Start-up View pop-up
    [Documentation]  This keyword is used to Open BTS Start-up View pop-up.
    ...  *AUTHOR* andreea.burtic@nokia.com

    Wait Until Element Is Clicked  //span[@ui-tooltip='BTS Status']  120
    Click Element  //*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[1]/div/ng-transclude/div/div[1]/nav-link/a/span[1]


Get All Active Alarms
    [Documentation]  This keyword is used to Get All Active Alarms.
    ...  *AUTHOR* andreea.burtic@nokia.com

    Wait Until Element Is Clicked  //*[@id="main-view"]/div/div[1]/div[1]/div/div[1]/div[6]/status-bar-alarms/a/i  60
    Sleep  10s  Time for alarms to appear on page.
    ${fault_id_webem_list}  Create List
    ${alarm}  SeleniumLibrary.Get Element Count  class:alarm-row
    FOR  ${id}  IN RANGE  1  ${alarm}+1
        ${fault_id}  Get Text  //*[contains(@alarm-type, 'current')]/ui-table/div/ng-transclude/table/tbody/tr[${id}]/td[5]
        ${fault_id}  Convert To Integer  ${fault_id}
        Append To List  ${fault_id_webem_list}  ${fault_id}
    END

    [Return]  ${fault_id_webem_list}


Open Diagnostic Menu
    [Documentation]  This keyword is used to Open Diagnostic Menu.
    ...  *AUTHOR* andreea.burtic@nokia.com

    Wait Until Element Is Clicked  xpath=//span[@ui-tooltip='Diagnostic']
    Log  Diagnostic Tab is open!  console=true


Open Site Report
    [Documentation]  This keyword is used to Open Site Report
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Enabled  //*[@id="admin.navigationBar.btsStatus.TITLE"]  60
    Click Element  //*[@id="admin.navigationBar.btsStatus.TITLE"]
    ${status}  Run Keyword And Return Status
    ...  Click Element  //*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[1]/div/ng-transclude/div/div[4]/nav-link
    Run Keyword If  ${status}
    ...  Log  Site Report menu has opened![OK]  console=true
    ...  ELSE
    ...  Fail  Site Report menu did not open![NOK]


Open BTS R&D Debug Parameters Management
    [Documentation]  This keyword is used to Open BTS R&D Debug Parameters Management.
    ...  *AUTHOR* andreea.burtic@nokia.com

    Wait Until Element Is Clicked  xpath=//span[@ui-tooltip='Procedures']
    Log  Procedures Tab is open!  console=true
    Wait Until Element Is Clicked  xpath=//*[contains(text(), "BTS R&D Debug Parameters Management")]
    Log  BTS R&D Debug Parameters Management is open!  console=true


Open IP Connectivity Test
    [Documentation]  This keyword is used to Open IP Connectivity Test.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Click Element  //*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[6]/div/nav-menu-link
    Click Element  //*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[6]/div/ng-transclude/div/div[2]/nav-link
    Click Element  //*[@id="main-view"]/div/div[1]/div[2]/global-search/div/wf-panel/wf-panel-header/ui-button/button


Open Snapshot Collection
    [Documentation]  This keyword is used to Open Snapshot Collection.
    ...  *AUTHOR* andreea.burtic@nokia.com

    Open Diagnostic Menu
    Wait Until Element Is Clicked
    ...  xpath=//*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[6]/div/ng-transclude/div/div[12]/nav-link/a/span
    Log  Snapshot is open!  console=true


Open RF Scan Monitoring
    [Documentation]  This keyword is used to Open RF Scan Monitoring.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Click Element  locator=//app-header/main-menu[1]/nav-item[6]/div[1]/nav-menu-link[1]/span[1]
    Log  Open RF Monitoring tab!  console=true
    Wait Until Element Is Visible  locator=//span[contains(text(),'RF Monitoring')]  timeout=50
    Click Element  locator=//span[contains(text(),'RF Monitoring')]
    Log  Open RF Scan tab!  console=true
    Wait Until Element Is Visible  locator=//a[contains(text(),'RF Scan')]  timeout=50
    Click Element  locator=//a[contains(text(),'RF Scan')]


Open PIM Desensitization Monitoring
    [Documentation]  This keyword is used to Open PIM Desensitization Monitoring.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Visible  locator=//app-header/main-menu[1]/nav-item[6]/div[1]/nav-menu-link[1]  timeout=300
    Sleep  50  Time for page to be updated
    Click Element  locator=//app-header/main-menu[1]/nav-item[6]/div[1]/nav-menu-link[1]
    Wait Until Element Is Visible  locator=//span[contains(text(),'RF Monitoring')]  timeout=50
    Click Element  locator=//span[contains(text(),'RF Monitoring')]
    Log  Open RF Monitoring tab!  console=true
    Wait Until Element Is Visible  locator=//a[contains(text(),'PIM Desensitization')]  timeout=50
    Click Element  locator=//a[contains(text(),'PIM Desensitization')]
    Log  PIM Desensitization tab is opened!  console=true


Open Tuning Synchronization
    [Documentation]  This keyword is used to Open Tuning Synchronization.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Click Element  xpath=//*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[6]/div
    Click Element  xpath=//*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[6]/div/ng-transclude/div/div[1]
    ${tuning}  Catenate  SEPARATOR=  xpath=//*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/synchronization
    ...  /p-tabview/div/div[1]/div/ul/li[2]
    Click Element  ${tuning}
    Log  Tuning menu has opened![OK]  console=true


Open KPI Dashboard Tab
    [Documentation]  This keyword is used to Open KPI Dashboard Tab.
    ...  *AUTHOR* andreea.burtic@nokia.com

    Wait Until Element Is Clicked  //div[@aria-describedby="admin.navigationBar.performance.TITLE"]  60
    Wait Until Element Is Clicked  //span[contains(text(),'KPI Dashboard')]  60
    Log  KPI Dashboard is open!  console=true


Open Baseband Module Power Reset
    [Documentation]  This keyword is used to Open Baseband Module Power Reset.
    ...  *AUTHOR* andreea.burtic@nokia.com

    Click Element  //*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[7]/div/nav-menu-link/span
    Click Element  //span[contains(text(),'Power Reset')]
    Click Element  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/power-reset-root/p-tabview/div/div[1]/div/ul/li[2]


Open BTS Power Reset
    [Documentation]  This keyword is used to Open BTS Power Reset.
    ...  *AUTHOR* andreea.burtic@nokia.com

    Click Element  //*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[7]/div/nav-menu-link/span
    Click Element  //span[contains(text(),'Power Reset')]
    Click Element  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/power-reset-root/p-tabview/div/div[1]/div/ul/li[1]


Open SFP Monitoring
    [Documentation]  This keyword is used to Open SFP Monitoring.
    ...  *AUTHOR* andreea.burtic@nokia.com

    Log  \nOpen SFP Monitoring via Diagnostic Tab  console=true
    Click Element  //*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[6]/div/nav-menu-link
    Click Element  //*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[6]/div/ng-transclude/div/div[7]/nav-link


Open Interface Mirroring
    [Documentation]  This keyword is used to open Interface Mirroring.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Click Element  //span[@ui-tooltip='Diagnostic']
    Click Element  //*[contains(text(), "Mirroring")]
    Click Element  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/mirroring-tabs/p-tabview/div/div[1]/div/ul/li[2]


Open Ethernet Port Mirroring
    [Documentation]  This keyword is used to open Ethernet Port Mirroring.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Visible  locator=//app-header/main-menu[1]/nav-item[6]/div[1]/nav-menu-link[1]  timeout=30
    Click Element  locator=//app-header/main-menu[1]/nav-item[6]/div[1]/nav-menu-link[1]
    Wait Until Element Is Visible  locator=//span[contains(text(),'Mirroring')]  timeout=30
    Click Element  locator=//span[contains(text(),'Mirroring')]


Open BTS Log Level
    [Documentation]  This keyword is used to open BTS Log Level.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked  //span[@ui-tooltip='Procedures']  120
    Wait Until Element Is Clicked  //span[contains(text(),'BTS Log Level')]  120


Choose All Specific Cells For Troubleshooting Scripts
    [Documentation]  This keyword is used to Choose All Specific Cells For Troubleshooting Scripts.
    ...  *AUTHOR* andreea.burtic@nokia.com
    [Arguments]  ${technology}

    Click Element  ${CELLS_BUTTON}
    ${number_of_cells}  SeleniumLibrary.Get Element Count  xpath:/html/body/div[3]/div[2]/ul/p-multiselectitem
    ${cells_ids}  Create List
    FOR  ${cell}  IN RANGE  1  ${number_of_cells}+1
        ${cell_id}  Get Text  xpath:/html/body/div[3]/div[2]/ul/p-multiselectitem[${cell}]
        ${status_cell_name}  Run Keyword And Return Status
        ...  Should Match Regexp  ${cell_id}  ${technology}-*
        Run Keyword If  ${status_cell_name}
        ...  Append To List  ${cells_ids}  ${cell_id}
    END
    FOR  ${cell}  IN  @{cells_ids}
        Wait Until Element Is Clicked  //*[contains(@aria-label, "${cell}")]  120
    END
    Click Element  ${CELLS_BUTTON}
    Sleep  5s  Time for cells button to be closed.


Open Operations History
    [Documentation]  This keyword is used to Open Operations History.
    ...  *AUTHOR* andreea.burtic@nokia.com

    Log  Open Operations history!  console=true
    Wait Until Element Is Clicked  //*[@id="main-view"]/div/div[1]/app-header/div[2]/menu-bar/nav-item/div  120
    Click Element  //*[@id="main-view"]/div/div[1]/app-header/div[2]/menu-bar/nav-item/div/ng-transclude/ul/li[3]


Change Session Lock Value
    [Documentation]  This keyword is used to Change Session Lock value.
    ...  *AUTHOR* andreea.burtic@nokia.com
    [Arguments]  ${value}

    Log  Change Session Lock value on ${value} min!  console=true
    Click Element  //span[@ui-tooltip="Options"]
    Click Element  //*[@id="main-view"]/div/div[1]/app-header/div[2]/menu-bar/nav-item/div/ng-transclude/ul/li[1]/a
    Wait Until Element Is Visible  //*[contains(text(), "Lock screen when idle for(min)")]  60
    ${xpath_from_lock_screen}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-
    ...  panel-section/div/div/settings/div/div/div/div/general-settings-tab/div/div/div[1]/ui-text-input/div/input
    ${lock_screen_value}  Get Value  ${xpath_from_lock_screen}
    ${apply_screen_lock}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/settings/div/div
    ...  /div/div/execution-bar/div/ui-button[2]/button
    Run Keyword If  ${lock_screen_value}==${value}
    ...  Log  Screen lock is already setting on ${value} min!  console=true
    ...  ELSE
    ...  Run Keywords
    ...  Input Text  ${xpath_from_lock_screen}  ${value}
    ...  AND
    ...  Click Element  ${apply_screen_lock}
    ...  AND
    ...  Log  Screen lock was setting successfully!  console=true
    Go To Site View


Check If Bts Is Disconnected
    [Documentation]  This keyword is used to Check If Bts Is Disconnected.
    ...  *AUTHOR* andreea.burtic@nokia.com

    Click Element  locator=//*[@class="status-bar-menu"]
    Element Should Be Visible  locator=//*[@aria-label="Connect Button" and contains(text(),"Connect")]


Connect BTS
    [Documentation]  This keyword is used to Connect BTS.
    ...  *AUTHOR* andreea.burtic@nokia.com

    Click Element  locator=//*[@class="fa fa-ellipsis-v"]
    ${connect}  Run Keyword And Return Status
    ...  Element Should Be Visible  locator=//*[contains(text(),' Connect')]
    Run Keyword If  ${connect}
    ...  Click Element  locator=//*[contains(text(),' Connect')]
