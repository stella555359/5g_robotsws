*** Settings ***
Documentation  *AUTHOR*: andreea.burtic@nokia.com
...  This resource is used for WebEM TCs with the new GUI.


*** Variables ***
${SBTS_NAME_XPATH}  //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[2]/div[1]/div/span[2]
${COMMISIONING_WIZARD}  //*[contains(@aria-label, "Commissioning Wizard")]
${PARAMETER_EDITOR}  //*[contains(@aria-label, "Parameter Editor")]
${ALARMS_BUTTON_SITE_VIEW}  //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[3]/a[5]/i
${BTS_COUNTERS}  //*[contains(@aria-label, "BTS Counters")]
${DETAILED_SITE_VIEW}  //*[contains(@heading, "Detailed Site View")]
${RF_DIAGNOSTIC_TEST}  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'RF Diagnostic Test')]
${TEST_SETUP}  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'Test Setup')]
${RESET_TO_TEST_DEDICATED_STATE}  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'Reset to Test Dedicated State')]
${TEST_MODELS}  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'Test Models')]
${NR_DOWNLINK_TEST}  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'NR Downlink')]
${TDS_SIGN}  //*[contains(@class, 'p-badge p-component p-badge-info') and contains(text(), 'TDS')]
${USER_ACCOUNT_TAB}  //div[contains(@class, "otx-product-user-account")]
${USER_ACCOUNT_MANAGEMENT}  //*[contains(@class, 'otx-element-middle') and contains(text(), 'User Account Management')]
${ACCOUNT_NAME_CLASS}  otx-account-name
${RAD_ICON}  //*[contains(@aria-label, "At least one BTS R&D debug parameter is set to non-default value.")]
${SW_NAME}  //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[2]/div[2]/div[2]/span
${VALIDATE_PLAN_PE}  //span[contains(@class, "mdi mdi-check-all")]
${ACTIVATE_PLAN_PE}  //span[contains(@class, "mdi mdi-download")]
${FIX_ERRORS}  //span[contains(@class, "mdi mdi-wrench")]
${OPTIONS_MENU}  //*[contains(@aria-label, "Options menu")]


*** Keywords ***
Legal Notice
    [Documentation]  This keyword waits for the legal notice and presses the Confirm button.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Wait for legal notice  console=true
    Wait Until Element Is Visible  //*[contains(text(), 'Legal Notice')]  60s  Legal notice did not appear in 30 seconds.
    Wait Until Element Is Visible  //*[contains(text(), 'Accept')]  timeout=60s
    ${banner_text}  Get Text  //*[contains(@class, "login-banner-legal-item")]
    Set Test Variable  ${BANNER_TEXT}
    Wait Until Element Is Clicked  //*[contains(text(), 'Accept')]  60
    Log  Admin reached!  console=true


Download Application Logs
    [Documentation]  This keyword is getting the application logs and moving this file to hran_ta directory.
    ...  *AUTHOR* andreea.burtic@nokia.com

    Log  Remove admin_console_log from downloads directory  console=true
    Remove File  ${DOWNLOADS_PATH}/admin_console_log.log
    Wait Until Element Is Visible  ${OPTIONS_MENU}  60
    Wait Until Element Is Clicked  ${OPTIONS_MENU}  60
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/ul/li[7]/a/span  60
    Sleep  120  Time for application logs to be saved!
    ${current_time}  DateTime.Get Current Date  result_format=%H-%M  exclude_millis=True
    Move File  ${DOWNLOADS_PATH}/admin_console_log.log  ${BTS_FILES}/admin_console_log_${TEST_NAME}_${current_time}.log


Logout From SBTS
    [Documentation]  This keyword is used to disconnect from SBTS.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked  ${USER_ACCOUNT_TAB}  60
    Wait Until Element Is Clicked  //*[contains(@class, 'otx-element-middle') and contains(text(), 'Logout')]  60
    Log  Logout from WebEM was successfully done!  console=true


RAT Reset
    [Documentation]  This keyword is pressing the reset button for the specific technology.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    Log  \n${rat} RAT Reset will be performed.  console=true
    Wait Until Element Is Visible  //*[contains(@aria-label, "Reset ${rat}")]  60
    Wait Until Element Is Clicked  //*[contains(@aria-label, "Reset ${rat}")]  60
    Wait Until Element Is Clicked  //*[contains(@a-text, 'Reset')]/button  60


RAT Reset Confirmation Canceled
    [Documentation]  This keyword is pressing the reset button for the specific technology but canceled the confirmation.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    Log  \n${rat} RAT Reset will be performed.  console=true
    Wait Until Element Is Visible  //*[contains(@aria-label, "Reset ${rat}")]  60
    Wait Until Element Is Clicked  //*[contains(@aria-label, "Reset ${rat}")]  60
    Wait Until Element Is Clicked  //*[contains(@a-text, 'Cancel')]/button  60
    Log  Operation is canceled!  console=true


Get Active Alarms From WebEM
    [Documentation]  This keyword is used to get active alarms from WebEM.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Click Element  ${ALARMS_BUTTON_SITE_VIEW}
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

    Wait Until Element Is Clicked  xpath=//*[contains(@aria-label, "Site View")]


Performing Configuration Reset Via WebEM
    [Documentation]
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    ...  This KW execute configuration reset via WebEM and wait until execution is succeeded.

    Log  Performing Configuration Reset via WebEM  console=true
    Open Configuration Reset Menu
    Click Element  //button[contains(text(),'Execute Reset')]
    Click Element  //button[contains(text(),'Execute') and not(contains(text(),'Execute Reset'))]
    Log  Execute button is pushed, configuration reset via WebeM is performing![OK]  console=true
    Wait Until Element Is Visible  //*[contains(text(), 'Execution succeeded.')]  timeout=600
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
    Open Configuration Reset Menu
    ${message}  Catenate  SEPARATOR=${SPACE}  It will trigger configuration reset with D&RSW on recovery partition.
    ...  If the system module is without recovery partition, it will stay on its target SW.
    IF  '${ENB_BRANCH}' >= 'SBTS26R1'
        Click Element  //*[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'Execute Reset')]
        Wait Until Keyword Succeeds  120  5  Page Should Contain  ${message}
        Click Element  xpath:/html/body/div[2]/div/div[3]/ot-footer/div/div/p-button[1]/button/span
    ELSE
        Click Element  //button[contains(text(),'Execute Reset')]
        Click Element  //button[contains(text(),'Execute') and not(contains(text(),'Execute Reset'))]
    END
    Log  Execute button is pushed, configuration reset via BTS Rescue Console is performing![OK]  console=true
    Wait Until Element Is Visible  locator=//*[contains(text(), 'Execution succeeded.')]  timeout=600
    Log  Execution succeeded![OK]  console=true
    Log  Sleep for ${bts_rescue_console_timeout} until reload page is needed!  console=true
    Sleep  ${bts_rescue_console_timeout}  Time for page to be updated
    Reload Page
    Set FDSW Release  ${username}  ${password}
    Run Keyword If  '${FDSW_RELEASE}' >= 'FDSW24D'
    ...  Login To New BTS Rescue Console  ${username}  ${password}
    ...  ELSE
    ...  Login To BTS Rescue Console  ${username}  ${password}
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
    Wait Until Element Is Visible  //*[contains(@aria-label, "Site View")]  timeout=300
    Log  Web Element Manager is visible![OK]


Set FDSW Release
    [Documentation]
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    ...  This KW sets as a test variable FDSW release.
    [Arguments]  ${username}  ${password}

    Wait Until Keyword Succeeds  180  10  rc.Connect To  ip_address=${OAM_BTS_IP}  port=443  username=${username}  password=${password}  name=fdsw
    ${release}  rc.Get SW Version Name  sw_slot_id=3  connection=fdsw
    ${sw}  Fetch From Right  ${release}  LN_WN_
    ${FDSW_RELEASE}  Fetch From Left  ${sw}  _
    Set Test Variable  ${FDSW_RELEASE}
    Log  FDSW software release: ${FDSW_RELEASE}  console=true

    [Teardown]  rc.Teardown  connection=fdsw


Open Configuration Reset Menu
    [Documentation]  This keyword is used to open configuration reset menu.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked
    ...  //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[1]/ot-compact-drawer/button/span[1]
    ${status}  Run Keyword And Return Status  Wait Until Element Is Visible  xpath=//*[@id="configuration-reset"]  20
    IF  ${status}
        Wait Until Element Is Clicked  xpath=//*[@id="configuration-reset"]
    ELSE
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Configuration')]
        Wait Until Element Is Clicked  xpath=//*[@id="configuration-reset"]
    END
    Close Configuration Menu


Open BTS Start-up View pop-up
    [Documentation]  This keyword is used to BTS start-up view pop-up.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked
    ...  //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[1]/ot-compact-drawer/button/span[1]  60
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'BTS Start-up View')]  20
    IF  ${status}
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'BTS Start-up View')]
    ELSE
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Status')]
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'BTS Start-up View')]
    END


Open Site Report
    [Documentation]  This keyword is used to Open Site Report
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked
    ...  xpath=//*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[1]/ot-compact-drawer/button/span[1]
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Site Report')]  20
    IF  ${status}
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Site Report')]
    ELSE
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Status')]
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Site Report')]
    END
    Log  Site Report menu has opened![OK]  console=true
    Close Status Menu


Open ${specific_menu} Power Reset
    [Documentation]  This keyword is used to Open a specific submenu from Power Reset
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked
    ...  xpath=//*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[1]/ot-compact-drawer/button/span[1]
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), '${specific_menu} Power Reset')]  20
    IF  ${status}
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), '${specific_menu} Power Reset')]
        Log  ${specific_menu} Power Reset menu has opened![OK]  console=true
        Close Procedures Menu
        RETURN
    ELSE
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Procedures')]
    END
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), '${specific_menu} Power Reset')]  20
    IF  ${status}
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), '${specific_menu} Power Reset')]
    ELSE
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Power Reset')]
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), '${specific_menu} Power Reset')]
    END
    Log  ${specific_menu} Power Reset menu has opened![OK]  console=true
    Close Procedures Menu


Open Tuning Synchronization
    [Documentation]  This keyword is used to Open Tuning Synchronization
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Open Diagnostic Menu
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Tuning')]  20
    IF  ${status}
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Tuning')]
    ELSE
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Synchronization')]
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Tuning')]
    END
    Log  Tuning menu has opened![OK]  console=true
    Close Diagnostic Menu


Open RF Scan Monitoring
    [Documentation]  Opens the RF Scan monitoring view from the diagnostic menu in the new WebEM GUI.

    Open Diagnostic Menu
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'RF Scan')]  20
    IF  ${status}
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'RF Scan')]
    ELSE
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'RF Monitoring')]
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'RF Scan')]
    END
    Log  RF Scan Monitoring menu has opened![OK]  console=true
    IF  '${ENB_BRANCH}' < 'SBTS25R3'
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'RF Monitoring')]
    END
    Close Diagnostic Menu


Open PIM Desensitization Monitoring
    [Documentation]  Opens the PIM Desensitization monitoring view from the diagnostic menu in the new WebEM GUI.

    Open Diagnostic Menu
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'PIM Desensitization')]  20
    IF  ${status}
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'PIM Desensitization')]
    ELSE
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'RF Monitoring')]
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'PIM Desensitization')]
    END
    Log  PIM Desensitization Monitoring menu has opened![OK]  console=true
    IF  '${ENB_BRANCH}' < 'SBTS25R3'
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'RF Monitoring')]
    END
    Close Diagnostic Menu


Close ${specific_menu} Menu
    [Documentation]  This keyword is used to close a specific menu.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    IF  '${ENB_BRANCH}' >= 'SBTS25R3'  RETURN
    Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), '${specific_menu}')]
    Open/Close Menus Tab
    Log  ${specific_menu} is closed!  console=true


Open/Close Menus Tab
    [Documentation]  This keyword is used to open or close menus tab.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked
    ...  xpath=//*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[1]/ot-compact-drawer/button/span[1]


Get All Active Alarms
    [Documentation]  This keyword is used to get all active alarms.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked  xpath=${ALARMS_BUTTON_SITE_VIEW}
    Sleep  10s  Time for alarms to appear on page.
    ${fault_id_webem_list}  Create List
    ${alarm}  SeleniumLibrary.Get Element Count  class:alarm-row
    FOR  ${id}  IN RANGE  1  ${alarm}+1
        ${fault_id}  Get Text  //*[contains(@alarm-type, 'current')]/ui-table/div/ng-transclude/table/tbody/tr[${id}]/td[5]
        ${fault_id}  Convert To Integer  ${fault_id}
        Append To List  ${fault_id_webem_list}  ${fault_id}
    END

    [Return]  ${fault_id_webem_list}


Open KPI Dashboard Tab
    [Documentation]  This keyword is used to open KPI dashboard tab.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Open/Close Menus Tab
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'KPI Dashboard')]  20
    IF  ${status}
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'KPI Dashboard')]
    ELSE
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Performance')]
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'KPI Dashboard')]
    END
    IF  '${ENB_BRANCH}' < 'SBTS25R3'
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Performance')]
        Open/Close Menus Tab
    END
    Log  KPI Dashboard is open!  console=true


Open Diagnostic Menu
    [Documentation]  This keyword is used to open diagnostic menu.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked
    ...  xpath=//*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[1]/ot-compact-drawer/button/span[1]
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  xpath=//*[@id="debug-tracing"]  20
    IF  ${status}
        Log  Diagnostic Tab is open!  console=true
    ELSE
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Diagnostic')]
        Log  Diagnostic Tab is open!  console=true
    END


Open BTS R&D Debug Parameters Management
    [Documentation]  This keyword is used to Open BTS R&D Debug Parameters Management.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Open Diagnostic Menu
    Sleep  5s  Time for page to be updated
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  xpath=//*[@id="rd-debug-parameters"]/div/span  20
    IF  ${status}
        Mouse over  //*[@id="rd-debug-parameters"]/div/span
        Wait Until Element Is Clicked  xpath=//*[@id="rd-debug-parameters"]/div/span
    ELSE
        Mouse over  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'BTS R&D Debug Parameters Management')]
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'BTS R&D Debug Parameters Management')]
        Sleep  5s  Time for page to be updated
        Mouse over  //*[@id="rd-debug-parameters"]/div/span
        Wait Until Element Is Clicked  xpath=//*[@id="rd-debug-parameters"]/div/span
    END
    Log  BTS R&D Debug Parameters Management is open!  console=true
    Close Diagnostic Menu


Open IP Connectivity Test
    [Documentation]  This keyword is used to Open IP Connectivity Test.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Open Diagnostic Menu
    Sleep  5s  Time for page to be updated
    Mouse over  //*[@id="ip-connectivity-test"]/div/span
    Wait Until Element Is Clicked  xpath=//*[@id="ip-connectivity-test"]/div/span
    Sleep  5s  Time for page to be updated
    Close Diagnostic Menu


Open Snapshot Collection
    [Documentation]  This keyword is used to open snapshot collection.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Open Diagnostic Menu
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Snapshot Collection')]  20
    IF  ${status}
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Snapshot Collection')]
    ELSE
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Snapshot')]
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Snapshot Collection')]
    END
    IF  '${ENB_BRANCH}' < 'SBTS25R3'  Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Snapshot')]
    Close Diagnostic Menu


Open Interface Mirroring
    [Documentation]  This keyword is used to open Interface Mirroring.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Open Diagnostic Menu
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Interface Mirroring')]  20
    IF  ${status}
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Interface Mirroring')]
    ELSE
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Mirroring')]
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Interface Mirroring')]
    END
    IF  '${ENB_BRANCH}' < 'SBTS25R3'  Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Mirroring')]
    Close Diagnostic Menu


Open Ethernet Port Mirroring
    [Documentation]  This keyword is used to open Ethernet Port Mirroring.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Open Diagnostic Menu
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Ethernet Port Mirroring')]  20
    IF  ${status}
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Ethernet Port Mirroring')]
    ELSE
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Mirroring')]
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Ethernet Port Mirroring')]
    END
    IF  '${ENB_BRANCH}' < 'SBTS25R3'  Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Mirroring')]
    Close Diagnostic Menu


Open BTS Log Level
    [Documentation]  This keyword is used to open BTS Log Level.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Open Diagnostic Menu
    Sleep  5s  Time for page to be updated
    Mouse over  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'BTS Log Level')]
    Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'BTS Log Level')]
    Sleep  5s  Time for page to be updated
    Log  BTS Log Level is open!  console=true
    Close Diagnostic Menu


Open SFP Monitoring
    [Documentation]  This keyword is used to open sfp monitoring.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  \nOpen SFP Monitoring via Diagnostic Tab  console=true
    Open Diagnostic Menu
    Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'SFP Monitoring')]
    Close Diagnostic Menu


Choose All Specific Cells For Troubleshooting Scripts
    [Documentation]  This keyword is used to Choose All Specific Cells For Troubleshooting Scripts.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${technology}

    Click Element  ${CELLS_BUTTON}
    ${number_of_cells}  SeleniumLibrary.Get Element Count  xpath:/html/body/div[2]/div[2]/ul/p-multiselectitem
    ${cells_ids}  Create List
    FOR  ${cell}  IN RANGE  1  ${number_of_cells}+1
        ${cell_id}  Get Text  xpath:/html/body/div[2]/div[2]/ul/p-multiselectitem[${cell}]
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
    [Documentation]  This keyword is used to open operations history.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Open Operations history!  console=true
    Wait Until Element Is Visible  ${OPTIONS_MENU}  60
    Wait Until Element Is Clicked  ${OPTIONS_MENU}  60
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/ul/li[3]/a/span  60
    Log  Operations history was opened!  console=true


Change Session Lock Value
    [Documentation]  This keyword is used to change session lock value.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${value}

    Log  Change Session Lock value on ${value} min!  console=true
    Wait Until Element Is Clicked  ${OPTIONS_MENU}  60
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/ul/li[1]/a  60
    ${status}  Run Keyword And Return Status  Element Should Be Visible  //*[contains(text(), "Update interval(ms)")]
    ${index}  Set Variable If  ${status}  2  1
    IF  '${ENB_BRANCH}' > 'SBTS25R3'
        ${xpath_from_lock_screen}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div/div/div[1]/ng-view/wf-panel/wf-panel-section
        ...  /div/div/settings/div/div/div/div/general-settings-tab/div/div[${index}]/div[1]/ui-text-input/div/input
    ELSE
        ${xpath_from_lock_screen}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[1]/div/ng-view/wf-panel/wf-panel-section
        ...  /div/div/settings/div/div/div/div/general-settings-tab/div/div[${index}]/div[1]/ui-text-input/div/input
    END
    ${lock_screen_value}  Get Value  ${xpath_from_lock_screen}
    ${apply_screen_lock}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[1]/div/ng-view/wf-panel/wf-panel-section/
    ...  div/div/settings/div/div/div/div/execution-bar/div/ui-button[2]/button
    IF  ${lock_screen_value}==${value}
        Log  Screen lock is already setting on ${value} min!  console=true
    ELSE
        Input Text  ${xpath_from_lock_screen}  ${value}
        Click Element  ${apply_screen_lock}
        Log  Screen lock was setting successfully!  console=true
    END
    Go To Site View


Check If Bts Is Disconnected
    [Documentation]  This keyword is used to Check If Bts Is Disconnected.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Element Should Be Visible  //*[@aria-label="Connect"]


Connect BTS
    [Documentation]  This keyword is used to Connect BTS.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${connect}  Run Keyword And Return Status
    ...  Element Should Be Visible  //*[@aria-label="Connect"]
    Run Keyword If  ${connect}
    ...  Click Element  locator=//*[@aria-label="Connect"]


Download Application
    [Documentation]  This keyword is getting the application for offline mode and moving this file to BTS Files directory.
    ...  *AUTHOR* andreea.burtic@nokia.com

    Log  Download Application from Options tab.  console=true
    Wait Until Element Is Visible  ${OPTIONS_MENU}  60
    Wait Until Element Is Clicked  ${OPTIONS_MENU}  60
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/ul/li[6]/a/span  60
    Sleep  60  Time for application to be saved!
    Move File  ${DOWNLOADS_PATH}/Web Element Manager.html  ${BTS_FILES}/Web_Element_Manager.html
    Log  Application was saved in location: ${BTS_FILES}/Web_Element_Manager.html  console=true


Open WebEM In Offline Mode
    [Documentation]  This keyword opens the WebEM in offline mode with chrome browser and maximizes the window.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Open WebEM In Offline Mode  console=true
    ${chrome_options}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    ${prefs}  Create Dictionary  download.default_directory=${DOWNLOADS_PATH}
    Call Method  ${chrome_options}  add_experimental_option  prefs  ${prefs}
    Call Method  ${chrome_options}  add_argument  --ignore-ssl-errors
    Call Method  ${chrome_options}  add_argument  --ignore-certificate-errors
    Call Method  ${chrome_options}  add_argument  --disable-popup-blocking
    Call Method  ${chrome_options}  add_argument  --start-maximized
    Call Method  ${chrome_options}  add_argument  --headless
    Create Webdriver  Chrome  options=${chrome_options}
    Go To  file://${BTS_FILES}/Web_Element_Manager.html
    Log  Wait until the page is loaded.  console=true
    Wait Until Element Is Visible  //*[contains(@class, 'ot-product-name') and contains(text(), 'Web Element Manager')]  60s
    ...  WebElement is not fully loaded in 60s seconds.
    Capture Page Screenshot  WebEM_with_offline_mode_site_view.png
    Log  Chrome browser was opened with offline mode and the screenshot was saved as WebEM_with_offline_mode_site_view.png!  console=true


Open Antenna Line Devices Software
    [Documentation]  This keyword is used to open antenna line devices software.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Open antenna line devices software!  console=true
    Open/Close Menus Tab
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Antenna Line Devices Software')]  20
    IF  ${status}
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Antenna Line Devices Software')]
        Log  Antenna Line Devices Software Tab is open!  console=true
        RETURN
    ELSE
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Software')]
    END
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Antenna Line Devices Software')]  20
    IF  ${status}
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Antenna Line Devices Software')]
    ELSE
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Software Management')]
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Antenna Line Devices Software')]
    END
    IF  '${ENB_BRANCH}' < 'SBTS25R3'
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Software Management')]
        Wait Until Element Is Clicked  xpath=//*[contains(@class, 'p-menuitem-text') and contains(text(), 'Software')]
        Open/Close Menus Tab
    END
    Log  Antenna Line Devices Software Tab is open!  console=true


Collect Snapshot And Ensure GUI Does Not Lock
    [Documentation]  Collects a snapshot in the background and ensures the WebEM GUI does not lock during collection.
    [Arguments]  ${snapshot_name}  ${timeout}=1800

    Log  Wait up to ${timeout}s to collect snapshot.  console=true
    Wait Until Keyword Succeeds  5x  30  Setup Admin  bts_host=${OAM_BTS_IP}  name=snapshot_collection
    ${snapshot}  Run Keyword In Background  Collect Snapshot  ${BTS_FILES}/${snapshot_name}  timeout=1800
    ...  connection=snapshot_collection
    ${timeout_collection}  Evaluate  ${timeout}/5
    FOR  ${i}  IN RANGE  ${timeout_collection}
      Click Element  //*[contains(@class,'menu-button')]
      Click Element  //*[contains(@class,'menu-button')]
      ${status}  ${text}  Run Keyword And Ignore Error  Collect Keyword Result  ${snapshot}  5
      Exit For Loop If  '${status}'=='PASS'
    END
    Log  Snapshot collected.  console=true
    [Teardown]  Teardown Admin  snapshot_collection


Get Serial Number From All Active Alarms
    [Documentation]  This keyword is used to return a dictionary with fault id as a key and proper serial number as a value.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked  xpath=${ALARMS_BUTTON_SITE_VIEW}
    Sleep  10s  Time for alarms to appear on page.
    Wait Until Element Is Clicked  //*[@id="main-view"]/div/div[1]/div/div/div[1]/details-panel/div/ui-button/button/i
    ${fault_id_sn_webem_dict}  Create Dictionary
    ${alarm}  SeleniumLibrary.Get Element Count  class:alarm-row
    ${sn_xpath}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div/div/div[1]/details-panel/div/wf-panel/wf-panel-section/div/div/
    ...  details-panel-content/div/alarms-details/div/div[2]/table/tbody[1]/tr[10]/td[2]/span
    FOR  ${id}  IN RANGE  1  ${alarm}+1
        Wait Until Element Is Clicked  //*[contains(@alarm-type, 'current')]/ui-table/div/ng-transclude/table/tbody/tr[${id}]/td[5]
        ${fault_id}  Get Text  //*[contains(@alarm-type, 'current')]/ui-table/div/ng-transclude/table/tbody/tr[${id}]/td[5]
        ${sn}  Get Text  ${sn_xpath}
        Set To Dictionary  ${fault_id_sn_webem_dict}  ${fault_id}=${sn}
    END

    RETURN  ${fault_id_sn_webem_dict}


Open SSD Wi-Fi Configuration
    [Documentation]  Opens the SSD Wi-Fi configuration view from the menus tab in the new WebEM GUI.

    Open/Close Menus Tab
    ${status}  Run Keyword And Return Status  Wait Until Element Is Visible  //*[@id="ssd-wifi-configuration"]  20
    IF  ${status}
        Wait Until Element Is Clicked  //*[@id="ssd-wifi-configuration"]
    ELSE
        Wait Until Element Is Clicked  //*[@id="undefined_header"]/span[contains(text(), 'Security')]
        Wait Until Element Is Clicked  //*[contains(text(), 'Wi-Fi Management')]
        Wait Until Element Is Clicked  //*[@id="ssd-wifi-configuration"]
    END
    Log  SSD Wi-Fi Configuration Tab is open!  console=true
    IF  '${ENB_BRANCH}' < 'SBTS25R3'  Open/Close Menus Tab
