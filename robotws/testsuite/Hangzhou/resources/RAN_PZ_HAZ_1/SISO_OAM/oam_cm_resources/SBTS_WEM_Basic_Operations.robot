*** Settings ***
Documentation
...    Maintainer: I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
...    Common KWs related to UI operation for SBTS cases.
...  ******************
...  History of changes
...  ******************
...  - 19.05.2023 - Xu Yuyan commit to robotws
Library           Selenium2Library    run_on_failure=${None}
Library           Collections
Library           String
Resource          SBTS_WEM_Service_Logic_Processor.robot

*** Variables ***
${IS_VIRTAUL_DISPLAYED}    ${True}

*** Keywords ***
SBTS WEM Logout
    FOR    ${time_step}    IN RANGE    ${0}    ${5}
        Sleep    3s
        Wait Until WebElement Exist    //main-view//app-header//div[@class="right-side"]//user-account-management/nav-item/div[@role="menu"]
        ${is_button_show}    Run Keyword And Return Status    Element Should Be Visible
       ...  //main-view//app-header//div[@class="right-side"]//user-account-management/nav-item/div[@role="menu"]//ui-button[@a-text="Logout"]/button
        Run Keyword Unless    ${is_button_show}    SBTS WEM Click Button Or Element
        ...    //main-view//app-header//div[@class="right-side"]//user-account-management/nav-item/div[@role="menu"]
        ${is_succeed}    Run Keyword And Return Status    SBTS WEM Click Button Or Element
       ...  //main-view//app-header//div[@class="right-side"]//user-account-management/nav-item/div[@role="menu"]//ui-button[@a-text="Logout"]/button
        Exit For Loop If    ${is_succeed}
    END
    Run Keyword And Return Status    Wait Until Keyword Succeeds    5x    2s    Handle Insecure Warning From Chrome
    Wait Until Page Contains Element    id:login-username    10s

SBTS WEM Logon
    [Arguments]    ${url}    ${setup_param}=${True}    ${setup_value}=true    ${mode}=headless    ${browser}=chrome    ${skip_error}=${False}
    ...    ${user}=Nemuadmin    ${pwd}=nemuuser    ${open_new_window}=${True}    ${enable_fullscreen_mode}=${False}
    [Documentation]    Open Browser and logon SBTS WEM
    [Timeout]    10 minutes
    ${window_index}    SBTS WEM Accessing    ${url}    ${mode}    ${browser}    ${user}    ${pwd}
    ...    ${open_new_window}
    Wait Until Keyword Succeeds    60    5    SBTS WEM Status Bar Should Be Loaded Completed
    ${except_warning}    Run Keyword And Return Status    Wait Until WebElement Exist    //div[@uib-modal-transclude]    30s    3s
    Run Keyword If    '${skip_error}'=='False' and '${except_warning}'=='True'    Fail
    ${tmp1}    Set Variable    //div[@uib-modal-transclude]//button[contains(text(),"Confirm") or
    ${tmp2}    Set Variable    contains(text(),"Continue") or contains(text(),"OK") or contains(text(),"Yes")]
    ${btn_element}    Run Keyword If    ${except_warning}    Get WebElement    ${tmp1} ${tmp2}
    Run Keyword If    ${except_warning}    Click Button    ${btn_element}
    Run Keyword If    ${setup_param}    SBTS WEM Set Detected HW    ${setup_value}
    #Set WebEM session time out to max value
    SBTS WEM Filt Parameter    webEMSessionLogoutTimer
    ${para}    SBTS WEM Get Parameters In PE Table
    ${count}    BuiltIn.Get Length    ${para}
    Should Be Equal As Integers    ${count}    ${1}
    ${para_value}    Set variable    ${para[0]["actual_value"]}
    Run Keyword If    '${para[0]["actual_value"]}'!='${7200}'    SBTS WEM Modify Parameters In PE Table
    ...    ${para[0]["object"]}    ${para[0]["full_name"]}    7200
    SBTS WEM Validate Plan
    Run Keyword If    '${para[0]["actual_value"]}'!='${7200}'    SBTS WEM Activate Plan
    SBTS WEM Set WEM Lock Time    120
    #add for BOAM_ET CB005809
    Run Keyword If    ${enable_fullscreen_mode}    Run Keywords    Turn On Fullscreen Mode
    ...    AND    Turn Off Fullscreen Mode
    [Return]    ${window_index}

Turn On Fullscreen Mode
    Element Should Be Visible    //*[@id="main-view"]/div/div[1]/app-header/div[2]/fullscreen-toggle/div/div/span/ui-icon/div
    Click Element    //*[@id="main-view"]/div/div[1]/app-header/div[2]/fullscreen-toggle/div/div/span/ui-icon/div
    ${check_fullscreen}    Execute Javascript    return document.fullscreen
    Should Be Equal    ${check_fullscreen}    ${True}
    Element Should Be Visible    //main-view//div[contains(@class,"ui-icon-svg ui-icon-normal-screen")]

Turn Off Fullscreen Mode
    Element Should Be Visible    //*[@id="main-view"]/div/div[1]/app-header/div[2]/fullscreen-toggle/div/div/span/ui-icon/div
    Click Element    //*[@id="main-view"]/div/div[1]/app-header/div[2]/fullscreen-toggle/div/div/span/ui-icon/div
    ${check_fullscreen}    Execute Javascript    return document.fullscreen
    Should Be Equal    ${check_fullscreen}    ${False}
    Element Should Be Visible    //main-view//div[contains(@class,"ui-icon-svg ui-icon-full-screen")]

SBTS WEM Accessing
    [Arguments]    ${url}    ${mode}=headless    ${browser}=chrome    ${user}=Nemuadmin    ${pwd}=nemuuser    ${open_new_window}=${True}
    ${options}    Run Keyword If    "${open_new_window}"=="${True}"    Chrome Set Headless Mode    ${mode}
    Comment    Run Keyword If    "${IS_VIRTAUL_DISPLAYED}"=="${True}" and "${open_new_window}"=="${True}"    Start Virtual Display
    ${window_index}    Run Keyword If    "${open_new_window}"=="${True}"    open browser    ${url}    ${browser}    options=${options}
    Selenium2Library.Set Window Size    1600    1200
    Wait Until Keyword Succeeds    5x    2s    Handle Insecure Warning From Chrome
    Wait Until Page Contains Element    id:login-username
    ${is_option_expanded}    Run Keyword And Return Status    Element Should Be Visible    id:Port
    Run Keyword Unless    ${is_option_expanded}    Click Element    //span[text()="Options"]
    Run Keyword Unless    ${is_option_expanded}    Wait Until Element Is Visible    id:Port
    Clear Element Text    id:login-username
    Input Text    id:login-username    ${user}
    Input Text    id:login-password    ${pwd}
    Clear Element Text    id:Port
    Input Text    id:Port    443
    Click Button    //button/span[text()="Login"]/../../button
    [Return]    ${window_index}

SBTS WEM Re-Logon
    [Arguments]    ${password}=nemuuser
    [Timeout]    5 minutes
    ${count}    Selenium2Library.Get Element Count    id:login-password
    RunKeyword If    "${count}"!="1"    SBTS WEM Close BTS StartUp View    3s
    Return From Keyword If    "${count}"!="1"
    Input Text    id:login-password    ${password}
    Click Button    //button/span[text()="Login"]/../../button
    Comment    Click Button    //ui-button[@a-text="Login"]/button
    ${ret}    Wait Until Keyword Succeeds    30    5    SBTS WEM Status Bar Should Be Loaded Completed
    Return From Keyword If    '${ret}' != 'True'    #While KW called in tear down, assertion shall not break off KW. Return forwardly to save time.
    ${except_warning}    Run Keyword And Return Status    Wait Until WebElement Exist    //div[@uib-modal-transclude]    30s    3s
    ${tmp1}    Set Variable    //div[@uib-modal-transclude]//button[contains(text(),"Confirm") or
    ${tmp2}    Set Variable    contains(text(),"Continue") or contains(text(),"OK") or contains(text(),"Yes")]
    ${btn_element}    Run Keyword If    ${except_warning}    Get WebElement     ${tmp1} ${tmp2}
    Run Keyword If    ${except_warning}    Click Button    ${btn_element}
    ${tmp1}    Set Variable    //div[@uib-modal-transclude]//button[contains(text(),"Confirm") or
    ${tmp2}    Set Variable    contains(text(),"Continue") or contains(text(),"OK") or contains(text(),"Yes")]
    ${count}    Selenium2Library.Get Element Count    ${tmp1} ${tmp2}
    Return From Keyword If    "${count}"=="0"
    ${tmp1}    Set Variable    //div[@uib-modal-transclude]//button[contains(text(),"Confirm") or
    ${tmp2}    Set Variable    contains(text(),"Continue") or contains(text(),"OK") or contains(text(),"Yes")]
    ${btn_element}    Get WebElement    ${tmp1} ${tmp2}
    Click Button    ${btn_element}

SBTS WEM Logon RD Mode
    [Arguments]    ${url}    ${setup_param}=${False}    ${setup_value}=true    ${enable_RD}=${True}
    ...    ${skip_error}=${True}    ${user}=developer
    ...    ${pwd}=\$developer\#    ${open_new_window}=${True}
    SBTS WEM Logon    ${url}    ${setup_param}    ${setup_value}    headless    chrome    ${skip_error}
    ...    ${user}    ${pwd}    ${open_new_window}
    SBTS WEM Open Option    Settings
    Wait Until WebElement Exist    //ng-view//general-settings-tab//div[contains(@class,"parameter-editor-visibility-future-features-parameters")]
    ${is_enabled}    Selenium2Library.Get Element Attribute
    ...    //ng-view//general-settings-tab//div[contains(@class,"parameter-editor-visibility-future-features-parameters")]/label/input    checked
    ${is_enabled}    Set Variable If    "${is_enabled}"=="checked"    ${True}    ${False}
    Run Keyword If    "${is_enabled}"!= "${enable_RD}"    SBTS WEM Click Button Or Element
    ...    //ng-view//general-settings-tab//div[contains(@class,"parameter-editor-visibility-future-features-parameters")]/label
    ${is_enable}    Run Keyword And Return Status    Element Should Be Enabled With Attribute
    ...    //ng-view//wf-panel-section//settings//execution-bar//ui-button[@a-text="Apply"]/button
    Run Keyword If    ${is_enable}    SBTS WEM Click Button Or Element
    ...    //ng-view//wf-panel-section//settings//execution-bar//ui-button[@a-text="Apply"]/button

SBTS WEM Kick By Restricted Access
    [Arguments]    ${survival_time}
    ${time}    Get Time    epoch
    Wait Until WebElement Exist
    ...    //common-modal[@modal-body="You'll be disconnected in ${survival_time} seconds by BTS. Restricted access feature is activated."]
    Capture Page Screenshot    ${time}_WebEM_Kicked.png
    ${tmp1}    Set Variable
    ...    //common-modal[@modal-body="You'll be disconnected in ${survival_time} seconds by BTS. Restricted access feature is activated."]//
    ${tmp2}    Set Variable    ui-button[@a-text="Close"]/button
    Click Button    ${tmp1}${tmp2}
    Sleep    ${survival_time}s
    ${ret}    SBTS WEM Status Bar Should Be Loading
    Should Be True    ${ret}

SBTS WEM Logon Fail By Restricted Access
    [Arguments]    ${ip}    ${open_new_window}=${True}
    ${time}    Get Time    epoch
    ${window_index}    SBTS WEM Accessing    https://${ip}    open_new_window=${open_new_window}
    Wait Until WebElement Exist    //common-modal//*[@id="modal-title" and @title="Session establishment error"]    120s    20s
    Capture Page Screenshot    ${time}_WebEM_Logon_Restriced.png
    Click Button    //common-modal//*[@id="modal-title" and @title="Session establishment error"]/../../..//ui-button[@a-text="OK"]/button
    ${except_warning}    Run Keyword And Return Status    Wait Until WebElement Exist    //div[@uib-modal-transclude]    10s    2s
    ${tmp1}    Set Variable    //div[@uib-modal-transclude]//button[contains(text(),"Confirm") or
    ${tmp2}    Set Variable    contains(text(),"Continue") or contains(text(),"OK") or contains(text(),"Yes")]
    ${btn_element}    Run Keyword If    ${except_warning}    Get WebElement    ${tmp1} ${tmp2}
    Run Keyword If    ${except_warning}    Click Button    ${btn_element}
    ${ret}    SBTS WEM Status Bar Should Be Loading
    Should Be True    ${ret}
    [Return]    ${window_index}

SBTS WEM Download Chrome Console Log
    [Arguments]    ${default_chrome_download_path}=/home/ute/Downloads
    SBTS WEM Open Option    Download application logs
    ${time}    Get Time    epoch
    Run Keyword And Return Status    OperatingSystem.Move File    ${default_chrome_download_path}/admin_console_log.log
    ...    ${OUTPUT DIR}/webEM_console_log_${time}.log

SBTS WEM Click Text
    [Arguments]    ${text}
    [Documentation]    Click element by visible text on current page.Text must be sole.
    ...    Some common and changeless texts of WebEM are already recorded in global variable ${WEB_EM_COMMON_TEXT},
    ...    better to find your text in ${WEB_EM_COMMON_TEXT} and use keyword 'SBTS WEM Click Common Text' insteadly.
    ...    If your text is common and changeless in WebEM, please record it to ${WEB_EM_COMMON_TEXT}.
    SBTS WEM Click Button Or Element    //*[text()="${text}"]

SBTS WEM Reset UI Logout Timer
    [Documentation]    Open/Close detail panel to prevent WebUI logout due to long static automatic.
    ${count}    Selenium2Library.Get Element Count    //screen-lock-warning-modal//ui-button[@a-text="Confirm"]/button
    Run Keyword If    "${count}"=="${1}"    SBTS WEM Click Button Or Element    //screen-lock-warning-modal//ui-button[@a-text="Confirm"]/button
    SBTS WEM Click Button Or Element
    ...    //global-search//ui-button[contains(@class,"gs-open-button")]/button | //global-search//wf-panel-header//ui-button/button
    Sleep    2s    Time for panel expand or close
    SBTS WEM Click Button Or Element
    ...    //global-search//ui-button[contains(@class,"gs-open-button")]/button | //global-search//wf-panel-header//ui-button/button

SBTS WEM Close BTS StartUp View
    [Arguments]    ${timeout}=60s
    ${is_pop}    Run Keyword And Return Status    Wait Until WebElement Exist
    ...    //ui-modal[@a-title="BTS Start-up View"]//ui-button[@a-text="Close"]/button    ${timeout}    1s
    Run Keyword If    ${is_pop}    SBTS WEM Click Button Or Element
    ...    //ui-modal[@a-title="BTS Start-up View"]//ui-button[@a-text="Close"]/button    3    3s    Wait Until WebElement Not Exist
    ...    //ui-modal[@a-title="BTS Start-up View"]//ui-button[@a-text="Close"]/button

SBTS WEM Set WEM Lock Time
    [Arguments]    ${time_to_lock}=15
    [Timeout]    2 minutes
    SBTS WEM Open Option    Settings
    Wait Until WebElement Exist
    ...    //ng-view//wf-panel-section//settings//general-settings-tab//div[contains(@class,"screen-lock-interval")]//ui-text-input//input
    Clear Element Text
    ...    //ng-view//wf-panel-section//settings//general-settings-tab//div[contains(@class,"screen-lock-interval")]//ui-text-input//input
    Input Text    //ng-view//wf-panel-section//settings//general-settings-tab//div[contains(@class,"screen-lock-interval")]//ui-text-input//input
    ...    ${time_to_lock}
    ${is_enable}    Run Keyword And Return Status    Element Should Be Enabled With Attribute
    ...    //ng-view//wf-panel-section//settings//execution-bar//ui-button[@a-text="Apply"]/button
    Run Keyword If    ${is_enable}    SBTS WEM Click Button Or Element
    ...    //ng-view//wf-panel-section//settings//execution-bar//ui-button[@a-text="Apply"]/button

SBTS WEM Get Current Main View Title
    [Timeout]    1 minute
    Wait Until Keyword Succeeds    10s    1s    Element Should Be Exist
    ...    //ng-view//span | //ng-view//ui-view-panel//wf-panel-header/div[contains(@class,"ui-view-panel-header-title")]
    ${element}    Get WebElement
    ...    //ng-view//span | //ng-view//ui-view-panel//wf-panel-header/div[contains(@class,"ui-view-panel-header-title")]
    ${main_view_title}    Get Text    ${element}
    [Return]    ${main_view_title}

SBTS WEM Status Bar Should Be Loaded Completed
    ${ret}    Set Variable    ${False}
    ${connection_status}    Get Text    //main-view//div[@status-bar]//connection-status
    Should Be Equal As Strings    ${connection_status}    Online
    Element Should Not Be Exist
    ...    //main-view//div[@status-bar]//div[contains(@class,"status-bar-bts-element")]//span[contains(text(),"--")]
    ${tmp1}    Set Variable
    ...    //main-view//div[@status-bar]//div[contains(@class,"status-bar-bts-element")]//
    ${tmp2}    Set Variable   div[contains(@class,"status-bar-text-overflow") and contains(text(),"--")]
    Element Should Not Be Exist    ${tmp1}${tmp2}
    ${ret}    Set Variable    ${True}
    [Return]    ${ret}

SBTS WEM Status Bar Should Be Loading
    ${ret}    Set Variable    ${False}
    ${connection_status}    Get Text    //main-view//div[@status-bar]//connection-status
    Should Not Be Equal As Strings    ${connection_status}    Online
    Element Should Be Exist
    ...    //main-view//div[@status-bar]//div[contains(@class,"status-bar-bts-element")]//span[contains(text(),"--")]
    ${tmp1}    Set Variable
    ...    //main-view//div[@status-bar]//div[contains(@class,"status-bar-bts-element")]//
    ${tmp2}    Set Variable   div[contains(@class,"status-bar-text-overflow") and contains(text(),"--")]
    Element Should Be Exist    ${tmp1}${tmp2}
    ${ret}    Set Variable    ${True}
    [Return]    ${ret}

SBTS WEM Status Bar Should Be Connected
    ${connection_status}    Get Text    //main-view//div[@status-bar]//connection-status
    Should Be Equal As Strings    ${connection_status}    Online

SBTS WEM Location Should Contain
    [Arguments]    ${expect}
    ${location}    Get Location
    Should Contain    ${location}    ${expect}

SBTS WEM Open Option
    [Arguments]    ${menu_name}
    FOR    ${time_step}    IN RANGE    ${0}    ${5}
        Wait Until WebElement Exist    //main-view//app-header//div[@class="right-side"]//menu-bar/nav-item/div[@role="menu"]
        ${is_list_show}    Run Keyword And Return Status    Element Should Be Visible
        ...    //main-view//app-header//div[@class="right-side"]//menu-bar/nav-item/div[@role="menu"]/ng-transclude//li/a[text()="${menu_name}"]
        Run Keyword Unless    ${is_list_show}    SBTS WEM Click Button Or Element
        ...    //main-view//app-header//div[@class="right-side"]//menu-bar/nav-item/div[@role="menu"]
        Run Keyword And Return Status    Wait Until Keyword Succeeds    10s    3s    Element Should Be Visible
        ...    //main-view//app-header//div[@class="right-side"]//menu-bar/nav-item/div[@role="menu"]/ng-transclude//li/a[text()="${menu_name}"]
        ${is_succeed}    Run Keyword And Return Status    SBTS WEM Click Button Or Element
        ...    //main-view//app-header//div[@class="right-side"]//menu-bar/nav-item/div[@role="menu"]/ng-transclude//li/a[text()="${menu_name}"]
        Exit For Loop If    ${is_succeed}
        Sleep    3s
    END
    Should Be True    ${is_succeed}

SBTS WEM Open RunTime View
    [Arguments]    ${target_tab}=SRV
    [Documentation]    target_tab should be one of the keys of {'SRV':'detailed-site-view','C':'cells','CA':'carrier-aggregation','SV':'site-view'}
    [Timeout]    1 minute
    ${main_view_title}    SBTS WEM Get Current Main View Title
    Return From Keyword If    '${main_view_title}'=='Site Runtime View' and '${target_tab}'=='None'
    ${target_tab}    Set Variable If    '${target_tab}' == 'None'    SRV    ${target_tab}
    &{url_dic}    Evaluate    {'SRV':'detailed-site-view','C':'cells','CA':'carrier-aggregation','SV':'site-view'}
    ${tab_url}    Set Variable    ${url_dic['${target_tab}']}
    ${is_tab_right}    Run Keyword And Return Status    SBTS WEM Location Should Contain    ${tab_url}
    Return From Keyword If    ${is_tab_right}
    Wait Until WebElement Exist    //nav-item[1]    30s    3s
    Click Element    //nav-item[1]/div
    Mouse Over    //main-view//app-header/div[contains(@class,"app-name")]
    Element Should Be Exist    //nav-item[1]/div[@aria-expanded="true"]//*[text()="Site Runtime View"]
    Mouse Over    //nav-item[1]/div[@aria-expanded="true"]//*[text()="Site Runtime View"]
    ${tmp1}    set variable    {'SRV':'//nav-item[1]//a[@href="#/bts-status/detailed-site-view"]',
    ${tmp2}    set variable    'C':'//nav-item[1]//a[@href="#/bts-status/cells"]',
    ${tmp3}    set variable    'CA':'//nav-item[1]//a[@href="#/bts-status/carrier-aggregation"]',
    ${tmp4}    set variable    'SV':'//nav-item[1]//a[@href="#/bts-status/site-view"]'}
    &{tab_dic}    Evaluate    ${tmp1}${tmp2}${tmp3}${tmp4}
    ${tab_xpath}    Set Variable    ${tab_dic['${target_tab}']}
    Click Element    ${tab_xpath}
    &{tab_dic}    Evaluate
    ...    {'SV':'//ng-view//site','SRV':'//ng-view//site-toolbar','C':'//ng-view//div[@cells-view]','CA':'//ng-view//div[@ca-filter-toolbar]'}
    ${tab_xpath}    Set Variable    ${tab_dic['${target_tab}']}
    Wait Until WebElement Exist    ${tab_xpath}
    Sleep    2s    #Give 2 seconds to WebUI to load page

SBTS WEM Open Diagnostic
    [Arguments]    ${target_tab}=Snapshot
    [Timeout]    1 minute
    ${main_view_title}    SBTS WEM Get Current Main View Title
    Return From Keyword If    '${main_view_title}'=='Runtime View' and '${target_tab}'=='None'
    ${target_tab}    Set Variable If    '${target_tab}' == 'None'    snapshot    ${target_tab}
    &{url_dic}    Evaluate    {'Snapshot':'snapshot','O-RAN O1 Management':'o1-management'}
    ${tab_url}    Set Variable    ${url_dic['${target_tab}']}
    ${is_tab_right}    Run Keyword And Return Status    SBTS WEM Location Should Contain    ${tab_url}
    Return From Keyword If    ${is_tab_right}
    Wait Until WebElement Exist    //nav-item[6]    30s    3s
    Click Element    //nav-item[6]/div
    Mouse Over    //main-view//app-header/div[contains(@class,"app-name")]
    element should be visible    //nav-item[6]/div[@aria-expanded="true"]//*[text()="${target_tab}"]
    &{tab_dic}    Evaluate    {'Snapshot':'//a[@href="#/diagnostic/snapshot"]','O-RAN O1 Management':'//a[@href="#/diagnostic/o1-management"]'}
    ${tab_xpath}    Set Variable    ${tab_dic['${target_tab}']}
    Click Element    ${tab_xpath}

SBTS WEM Open Service Account SSH
    Log    SBTS WEM Open Service Account SSH    console=${True}
    ${main_view_title}    SBTS WEM Get Current Main View Title
    Comment    Return From Keyword If    '${main_view_title}'=='Service Account SSH'
    Wait Until WebElement Exist    //nav-item[7]    30s    3s
    Click Element    //nav-item[7]/div
    Mouse Over    //main-view//app-header/div[contains(@class,"app-name")]
    element should be visible    //nav-item[7]/div[@aria-expanded="true"]//*[text()="Service Account SSH"]
    Mouse Over    //nav-item[7]/div[@aria-expanded="true"]//*[text()="Service Account SSH"]
    Click Element    //nav-item[7]/div[@aria-expanded="true"]//*[text()="Service Account SSH"]
    Wait Until WebElement Exist    //ng-view/wf-panel/wf-panel-header/span[@class="title"]/h1[text()="Service Account SSH"]    10s    1s

SBTS WEM Open Configuration Manager
    [Arguments]    ${target_tab}=PE
    [Documentation]    Go to configuration manager page. Should Logon SBTS WEM before.
    ...    ${target_tab} should be one key of dictionary:{'PE':'parameters-editor','CW':'commissioning',
    ...    'DE':'definition-errors','RE':'relation-errors','HE':'hardware-errors'}
    [Timeout]    2 minutes
    ${main_view_title}    SBTS WEM Get Current Main View Title
    Return From Keyword If    '${main_view_title}'=='Configuration Management' and '${target_tab}'=='None'
    ${target_tab}    Set Variable If    '${target_tab}' == 'None'    PE    ${target_tab}
    ${tmp1}    Set Variable    {'PE':'parameters-editor','CA':'configuration-automation','CW':'commissioning','DE':'definition-errors',
    ${tmp2}    Set Variable    'RE':'relation-errors','HE':'hardware-errors'}
    &{url_dic}    Evaluate    ${tmp1}${tmp2}
    ${tab_url}    Set Variable    ${url_dic['${target_tab}']}
    ${is_tab_right}    Run Keyword And Return Status    SBTS WEM Location Should Contain    ${tab_url}
    Return From Keyword If    ${is_tab_right}
    Wait Until WebElement Exist    //nav-item[2]    30s    3s
    Click Element    //nav-item[2]/div
    Mouse Over    //main-view//app-header/div[contains(@class,"app-name")]
    element should be visible    //nav-item[2]/div[@aria-expanded="true"]//*[text()="Configuration Management"]
    Mouse Over    //nav-item[2]/div[@aria-expanded="true"]//*[text()="Configuration Management"]
    ${tmp1}    Set Variable    {'PE':'//nav-item[2]//a[@href="#/configuration/parameters-editor"]',
    ${tmp2}    Set Variable    'CA':'//nav-item[2]//a[@href="#/configuration/configuration-automation"]',
    ${tmp3}    Set Variable    'CW':'//nav-item[2]//a[@href="#/configuration/commissioning"]',
    ${tmp4}    Set Variable    'DE':'//nav-item[2]//a[@href="#/configuration/definition-errors"]',
    ${tmp5}    Set Variable    'RE':'//nav-item[2]//a[@href="#/configuration/relation-errors"]',
    ${tmp6}    Set Variable    'HE':'//nav-item[2]//a[@href="#/configuration/hardware-errors"]'}
    &{tab_dic}    Evaluate    ${tmp1}${tmp2}${tmp3}${tmp4}${tmp5}${tmp6}
    ${tab_xpath}    Set Variable    ${tab_dic['${target_tab}']}
    Click Element    ${tab_xpath}
    sleep    3s    #wait for Validation Errors in Configuration
    ${is_warning}    Run Keyword And Return Status    Element Should Be Exist
    ...    //validation-errors-modal/ui-modal[@a-title="Validation Errors in Configuration"]
    Run Keyword If    ${is_warning}    Click Button
    ...    //validation-errors-modal/ui-modal[@a-title="Validation Errors in Configuration"]//ui-footer//button

SBTS WEM Open Alarm Management
    [Arguments]    ${target_tab}=AA
    [Timeout]    1 minute
    ${main_view_title}    SBTS WEM Get Current Main View Title
    Return From Keyword If    '${main_view_title}'=='Alarm Management' and '${target_tab}'=='None'
    ${target_tab}    Set Variable If    '${target_tab}' == 'None'    AA    ${target_tab}
    &{url_dic}    Evaluate    {'AA':'/alarms/current','AH':'/alarms/historical'}
    ${tab_url}    Set Variable    ${url_dic['${target_tab}']}
    ${is_tab_right}    Run Keyword And Return Status    SBTS WEM Location Should Contain    ${tab_url}
    Return From Keyword If    ${is_tab_right}
    Wait Until WebElement Exist    //nav-item[4]    30s    3s
    Click Element    //nav-item[4]/div
    Mouse Over    //main-view//app-header/div[contains(@class,"app-name")]
    element should be visible    //nav-item[4]/div[@aria-expanded="true"]//*[text()="Alarm Management"]
    Mouse Over    //nav-item[4]/div[@aria-expanded="true"]//*[text()="Alarm Management"]
    &{tab_dic}    Evaluate    {'AA':'//nav-item[4]//a[@href="#/alarms/current"]','AH':'//nav-item[4]//a[@href="#/alarms/historical"]'}
    ${tab_xpath}    Set Variable    ${tab_dic['${target_tab}']}
    Click Element    ${tab_xpath}

SBTS WEM Open Configure In Commissioning Wizard
    [Arguments]    ${skip_validate_error}=${True}
    [Timeout]    1 minute 30 seconds
    SBTS WEM Open Configuration Manager    CW
    FOR    ${counter}    IN RANGE    0    10
        Exit For Loop If    not ${skip_validate_error}
        ${validate_error}    Run Keyword And Return Status    Element Should Be Exist    //validation-errors-modal
        Run Keyword If    ${validate_error}    Click Button    //validation-errors-modal//ui-button[@a-text="OK"]/button
        Exit For Loop If    ${validate_error}
        Sleep    1s
    END
    Wait Until Keyword Succeeds    10s    1s    Element Should Be Exist
    ...    //ng-view//wf-panel-section//commissioning-wizard//site-commissioning//div[@id]//button[@title="Configure"]
    ${button_elements}    Get WebElements
    ...    //ng-view//wf-panel-section//commissioning-wizard//site-commissioning//div[@id]//button[@title="Configure"]
    ${count}    Get Length    ${button_elements}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    Comment    Mouse Down    ${button_elements[${index}]}
    Comment    Mouse Up    ${button_elements[${index}]}
    Click Button    ${button_elements[${index}]}
    Wait Until Keyword Succeeds    10s    1s    Element Should Be Exist    //div[@uib-modal-transclude]//wizard-steps-modal-body//ul//li

SBTS WEM Enable Service Account SSH
    [Timeout]    1 minute
    SBTS WEM Open Service Account SSH
    ${count}    Selenium2Library.Get Element Count
    ...    //ng-view/wf-panel/wf-panel-section//service-account-ssh//div[@class="service-account-ssh-status"]/span[text()="Enabled"]
    Return From Keyword If    "${count}"=="${1}"
    Click Element    //ng-view/wf-panel/wf-panel-section//service-account-ssh//ui-button[@a-text="Enable"]/button

SBTS WEM Expand Detail Panel
    ${is_expanded}    Run Keyword And Return Status    Element Should Not Be Exist
    ...    //details-panel//ui-button[contains(@class,"show-panel-button")]
    Return From Keyword If    ${is_expanded}
    Click Button    //details-panel//ui-button[contains(@class,"show-panel-button")]/button

SBTS WEM Expand Navigation Panel
    [Documentation]    Expand Navigation Panel on SBTS WEM, no-matter under which main-menu. Should logon SBTS WEM before this step.
    [Timeout]    1 minute
    ${is_expanded}    Run Keyword And Return Status    Element Should Not Be Exist    //ui-button[contains(@class,"gs-open-button")]
    Return From Keyword If    ${is_expanded}
    Comment    Wait Until WebElement Exist    //main-view[@class="ng-isolate-scope"]//div[@class="main-view"]
    Wait Until Element Is Visible    //global-search    10s
    Click Button    //ui-button[contains(@class,"gs-open-button")]/button
    ${object_tree_not_exist}    Run Keyword And Return Status    Element Should Not Be Exist
    ...    //global-search//wf-panel-section//li[contains(@class,'uib-tab nav-item ng-isolate-scope') and @heading="Objects"]
    Return From Keyword If    ${object_tree_not_exist}
    Wait Until Element Is Enabled
    ...    //global-search//wf-panel-section//li[contains(@class,'uib-tab nav-item ng-isolate-scope') and @heading="Objects"]    10s
    Click Element    //global-search//wf-panel-section//li[@heading="Objects"]/a
    Element Should Be Exist    //global-search//wf-panel-section//li[contains(@class,'active') and @heading="Objects"]

SBTS WEM Expand Object Tree On Navigation Panel
    SBTS WEM Open Configuration Manager    PE
    SBTS WEM Expand Navigation Panel
    Wait Until WebElement Exist    //global-search//execution-bar//ui-button[@a-title="Expand all"]/button
    Click Button    //global-search//execution-bar//ui-button[@a-title="Expand all"]/button

SBTS WEM Expand Object Tree On Navigation Panel Under Pramater Editor
    [Documentation]    Expand MOs those are showing.
    ${elements}    Get WebElements    //global-search//li//i[contains(@class,"expand-icon")]/..//span[@ui-tooltip]
    ${count}    Get Length    ${elements}
    Return From Keyword If    ${count}==${0}
    FOR    ${element}    IN    @{elements}
        ${mo}    Get Text    ${element}
    END
    FOR    ${index}    IN RANGE    ${-1}    -${count+1}    ${-1}
        ${mo}    Get Text    ${elements[${index}]}
        Double Click Element    ${elements[${index}]}
        Sleep    3s
    END
    SBTS WEM Expand Object Tree On Navigation Panel Under Pramater Editor

SBTS WEM Expand Configuration Tree On Navigation Panel Under Pramater Editor
    [Arguments]    ${tree_name}=Current BTS configuration
    [Documentation]    ${tree_name} can be one of "Current BTS configuration",
    ...    "Planned BTS configurations" and "Inactive BTS configurations" which can be visble under object tab.
    SBTS WEM Open Configuration Manager    PE
    SBTS WEM Expand Navigation Panel
    ${tmp1}    Set Variable    //global-search//global-search-tab-content/pe-global-search-objects//
    ${tmp2}    Set Variable    div[@class="tree-list-body"]/div[contains(@class,"tree-list-grouping-renderer")]
    ${count}    Selenium2Library.Get Element Count    ${tmp1}${tmp2}
    FOR    ${index}    IN RANGE    1    ${count}+1
        ${tmp1}    Set Variable    //global-search//global-search-tab-content/pe-global-search-objects//
        ${tmp2}    Set Variable    div[@class="tree-list-body"]/div[contains(@class,"tree-list-grouping-renderer")]
        ${tmp3}    Set Variable    [${index}]//div[@class="ui-expandable-panel-header"]
        ${is_enable}    Selenium2Library.Get Element Attribute    ${tmp1}${tmp2}${tmp3}    aria-disabled
        Continue For Loop If    '${is_enable}'=='true'
        ${tmp1}    Set Variable    //global-search//global-search-tab-content/pe-global-search-objects//div[@class="tree-list-body"]
        ${tmp2}    Set Variable    /div[contains(@class,"tree-list-grouping-renderer")][${index}]//ui-expandable-panel-header
        ${title}    Get Text    ${tmp1}${tmp2}
        ${ret}    Set Variable If    '${title}'=='${tree_name}'    ${True}    ${False}
        ${tmp1}    Set Variable    //global-search//global-search-tab-content/pe-global-search-objects//div[@class="tree-list-body"]
        ${tmp2}    Set Variable    /div[contains(@class,"tree-list-grouping-renderer")][${index}]//div[contains(@class,"ui-expandable-panel-body")]
        ${is_expanded}    Run Keyword And Return Status    Element Should Be Visible    ${tmp1}${tmp2}
        Continue For Loop If    '${ret}'=='${is_expanded}'
        ${tmp1}    Set Variable    //global-search//global-search-tab-content/pe-global-search-objects//
        ${tmp2}    Set Variable    div[@class="tree-list-body"]/div[contains(@class,"tree-list-grouping-renderer")][${index}]//
        ${tmp3}    Set Variable    div[@class="ui-expandable-panel-header"]//ui-expandable-panel-header
        Wait Until Keyword Succeeds    30    3s     Click Element    ${tmp1}${tmp2}${tmp3}
    END
    ${tmp1}    Set Variable    //global-search//global-search-tab-content/pe-global-search-objects//div[@class="tree-list-body"]/
    ${tmp2}    Set Variable    div[contains(@class,"tree-list-grouping-renderer")]//div[contains(@class,"ui-expandable-panel-body")]
    ${count}    Selenium2Library.Get Element Count    ${tmp1}${tmp2}
    ${tmp1}    Set Variable    //global-search//global-search-tab-content/pe-global-search-objects//div[@class="tree-list-body"]/
    ${tmp2}    Set Variable    div[contains(@class,"tree-list-grouping-renderer")]//div[contains(@class,"ui-expandable-panel-body")]
    Run Keyword If    "${count}"!="${0}"    Click Element    ${tmp1}${tmp2}

SBTS WEM Select Object On Navigation Panel Under Runtime View
    [Arguments]    ${object_full_name}    ${filter}
    ${ret}    Set Variable    ${False}
    Should Not Be Equal As Strings    ${filter.strip()}    ${EMPTY}
    ${elements}    SBTS WEM Filt Object On Navigation Panel Under Runtime View    ${filter}
    ${count}    Get Length    ${elements}
    Return From Keyword If    ${count}==${0}    ${ret}
    Run Keyword If    ${count}==${1}    Run Keywords    Click Element    ${elements[0]}
    ...    AND    Return From Keyword    ${True}
    FOR    ${element}    IN    @{elements}
        ${text}    Selenium2Library.Get Text    ${element}
        Continue For Loop If    '${text}'!='${filter}'
        Click Element    ${element}
    END
    Return From Keyword    ${True}
    SBTS WEM Expand Detail Panel
    ${tab}    Set Variable    Parameters
    FOR    ${element}    IN    @{elements}
        Call Method    ${element}    click
        SBTS WEM Click Button Or Element    //details-panel//ul//li[@heading="${tab}" and not(contains(@class,"disabled"))]
        ...    KW_checker=Wait Until Page Contains Element    param_checker=//details-panel//div[contains(@class,"element-nidd-name")]
        ${full_mo_path}    Selenium2Library.Get Text    //details-panel//div[contains(@class,"element-nidd-name")]
        ${ret}    Run Keyword And Return Status    Should Be Equal As Strings    ${full_mo_path}    ${object_full_name}
        Exit For Loop If    ${ret}
    END
    ${tab}    Set Variable    Info
    SBTS WEM Click Button Or Element    //details-panel//ul//li[@heading="${tab}" and not(contains(@class,"disabled"))]
    ...    KW_checker=Wait Until Page Contains Element    param_checker=//details-panel//ul//li[@heading="${tab}" and contains(@class,"active")]
    [Return]    ${ret}

SBTS WEM Oper MO On RuntimeView
    [Arguments]    ${object_full_name}    ${filter}    ${action}
    [Documentation]    Select the MO filtered on the Navigation Panel on SiteView and do the operation of ${action} on Detail Panel.
    SBTS WEM Open RunTime View    SV
    SBTS WEM Expand Navigation Panel
    SBTS WEM Expand Detail Panel
    SBTS WEM Select Object On Navigation Panel Under Runtime View    ${object_full_name}    ${filter}
    Wait Until Element Is Visible    //details-panel//ul//li[@heading="Info"]    10s
    Click Element    //details-panel//ul//li[@heading="Info"]
    Wait Until Element Is Visible    //details-panel//actions-buttons//ui-button[@a-text="${action}" and @a-title="${action}"]/button
    ...    10s    Button "${action}" is not shown or not enable.
    SBTS WEM Click Button Or Element    //details-panel//actions-buttons//ui-button[@a-text="${action}" and @a-title="${action}"]/button
    ...    KW_checker=Wait Until WebElement Exist    param_checker=//common-modal
    Click Button    //common-modal//modal-footer//ui-button[@a-text!="Cancel"]/button

SBTS WEM Get Detail Info On SV
    [Arguments]    ${object_full_name}    ${filter}    ${info_title}
    SBTS WEM Open RunTime View    SV
    SBTS WEM Expand Navigation Panel
    SBTS WEM Expand Detail Panel
    ${ret}    SBTS WEM Select Object On Navigation Panel Under Runtime View    ${object_full_name}    ${filter}
    Should Be True    ${ret}
    Wait Until Element Is Visible    //details-panel//ul//li[@heading="Info"]    10s
    Click Element    //details-panel//ul//li[@heading="Info"]
    ${tmp1}    Set Variable    //details-panel//hardware-details//div[contains(@class,"details-info-name")]/
    ${tmp2}    Set Variable    div[contains(@class,"name") and text()="${info_title}"]/../../table//tr
    ${row_count}    Selenium2Library.Get Element Count    ${tmp1}${tmp2}
    ${dic_param}    Create Dictionary
    FOR    ${j}    IN RANGE    ${1}    ${row_count+1}
        ${tmp1}    Set Variable    //details-panel//hardware-details//div[contains(@class,"details-info-name")]/
        ${tmp2}    Set Variable   div[contains(@class,"name") and text()="${info_title}"]/../../table//tr[${j}]/td[contains(@class,"parameter-name")]
        ${p_name}    Selenium2Library.Get Text    ${tmp1}${tmp2}
        ${tmp1}    Set Variable    //details-panel//hardware-details//div[contains(@class,"details-info-name")]/
        ${tmp2}    Set Variable  div[contains(@class,"name") and text()="${info_title}"]/../../table//tr[${j}]/td[contains(@class,"parameter-value")]
        ${count}    Selenium2Library.Get Element Count    ${tmp1}${tmp2}
        ${tmp1}    Set Variable    //details-panel//hardware-details//div[contains(@class,"details-info-name")]/
        ${tmp1}    Set Variable  div[contains(@class,"name") and text()="${info_title}"]/../../table//tr[${j}]/td[contains(@class,"parameter-value")]
        ${p_value}    Run Keyword If    "${count}"=="${1}"    Selenium2Library.Get Text    ${tmp1}${tmp2}
        ${p_value}    Set Variable If    "${count}"=="${1}"    ${p_value}    ${EMPTY}
        Set To Dictionary    ${dic_param}    ${p_name}    ${p_value}
    END
    LOG Dictionary    ${dic_param}
    [Return]    ${dic_param}

SBTS WEM Get Detail Info On RuntimeView
    SBTS WEM Expand Detail Panel
    Wait Until Element Is Visible    //details-panel//ul//li[@heading="Info"]    10s
    Click Element    //details-panel//ul//li[@heading="Info"]
    ${dic_param}    Create Dictionary
    ${param_xpath}    Set Variable
    ...    //details-panel//hardware-details//table[@class="details-info-table"]//tr/td[contains(@class,"parameter-name")]
    ${param_name_elements}    Selenium2Library.Get WebElements    ${param_xpath}
    FOR    ${element}    IN    @{param_name_elements}
        ${p_name}    Selenium2Library.Get Text    ${element}
        ${tmp1}    Set Variable   //details-panel//hardware-details//table[@class="details-info-table"]//tr/
        ${tmp2}    Set Variable    td[contains(@class,"parameter-name") and text()="${p_name}"]/../td[contains(@class,"parameter-value")]
        ${count}    Selenium2Library.Get Element Count    ${tmp1}${tmp2}
        ${tmp1}    Set Variable    //details-panel//hardware-details//table[@class="details-info-table"]//tr/
        ${tmp2}    Set Variable    td[contains(@class,"parameter-name") and text()="${p_name}"]/../td[contains(@class,"parameter-value")]
        ${p_value}    Run Keyword If    "${count}"=="${1}"    Selenium2Library.Get Text    ${tmp1}${tmp2}
        ${p_value}    Set Variable If    "${count}"=="${1}"    ${p_value}    ${EMPTY}
        Set To Dictionary    ${dic_param}    ${p_name}    ${p_value}
    END
    ${cell_name}    Selenium2Library.Get Text    //details-panel//hardware-details//div[@class="header"]//div[@class="element-name"]//span[text()]
    Set To Dictionary    ${dic_param}    Cell name:    ${cell_name}
    Click Element    //details-panel//ul//li[@heading="Parameters"]
    Wait Until Element Is Visible    //details-panel//hardware-details//div[@details-parameters]//div[@class="object-names"]
    ${DN}    Selenium2Library.Get Text
    ...    //details-panel//hardware-details//div[@details-parameters]//div[@class="object-names"]/div[contains(@class,"element-nidd-name")]
    Set To Dictionary    ${dic_param}    distName    ${DN}
    [Return]    ${dic_param}

SBTS WEM Get MO Detail Info On RuntimeView
    [Arguments]    ${object_full_name}    ${filter}   ${target_tab}=SV
    SBTS WEM Open RunTime View    ${target_tab}
    SBTS WEM Expand Navigation Panel
    ${ret}    SBTS WEM Select Object On Navigation Panel Under Runtime View    ${object_full_name}    ${filter}
    Should Be True    ${ret}
    ${dic_param}    SBTS WEM Get Detail Info On RuntimeView
    [Return]    ${dic_param}

SBTS WEM Synch To Raido Modules
    SBTS WEM Open Service Account SSH
    Element Should Be Enabled With Attribute    //service-account-ssh//ui-button[@a-text="Synchronize To Radio Modules"]/button
    SBTS WEM Click Button Or Element    //service-account-ssh//ui-button[@a-text="Synchronize To Radio Modules"]/button
    Wait Until WebElement Exist    //service-account-ssh//ssh-procedure-bar[@type="SyncRu"]//span[text()="Synchronize radio modules succeeded."]

SBTS WEM Select Object On Commissioning Wizard Configure Popup
    [Arguments]    ${object_path}
    [Documentation]    ${object_path} should be the full path of leaf node graded by \\, example: Cells/Carriers\\Cell Definition
    ${is_enable}    Set Variable    ${False}
    ${objects}    Split String    ${object_path}    \\
    ${count}    Get Length    ${objects}
    FOR    ${index}    IN RANGE    0    ${count}
        ${tmp1}    Set Variable    //div[@uib-modal-transclude]//wizard-steps-modal-body//ul//li//
        ${tmp2}    Set Variable    div[@title="${objects[${index}]}"]/highlighter[@text="${objects[${index}]}"]
        Element Should Be Exist    ${tmp1}${tmp2}
        ${tmp1}    Set Variable    //div[@uib-modal-transclude]//wizard-steps-modal-body//ul//li//div[@title="${objects[${index}]}"]/
        ${tmp2}    Set Variable    highlighter[@text="${objects[${index}]}"]/../../../../../i[contains(@class,"expand-icon")]
        ${not_expand}    Run Keyword And Return Status    Element Should Be Exist    ${tmp1}${tmp2}
        ${tmp1}    Set Variable    //div[@uib-modal-transclude]//wizard-steps-modal-body//ul//li//div[@title="${objects[${index}]}"]/
        ${tmp2}    Set Variable    highlighter[@text="${objects[${index}]}"]/../../../../../i[contains(@class,"expand-icon")]
        Run Keyword If    ${not_expand}    Click Element    ${tmp1}${tmp2}
    END
    LOG    ${objects[${count-1}]}
    ${tmp1}    Set Variable    //div[@uib-modal-transclude]//wizard-steps-modal-body//ul//li//
    ${tmp2}    Set Variable    div[@title="${objects[${count-1}]}"]/highlighter[@text="${objects[${count-1}]}"]
    ${is_enable}    Run Keyword And Return Status    Element Should Be Exist    ${tmp1}${tmp2}
    ${tmp1}    Set Variable    //div[@uib-modal-transclude]//wizard-steps-modal-body//ul//li//
    ${tmp2}    Set Variable    div[@title="${objects[${count-1}]}"]/highlighter[@text="${objects[${count-1}]}"]
    Run Keyword If    ${is_enable}    Click Element    ${tmp1}${tmp2}
    [Return]    ${is_enable}

SBTS WEM Select Object On Navigation Panel Under Pramater Editor
    [Arguments]    ${object_path}    ${filter}    ${tree_name}=Current BTS configuration
    # ${object_path} is fuzzy matching, can be part of the whole object path
    SBTS WEM Open Configuration Manager    PE
    ${elements}    SBTS WEM Filt Object On Navigation Panel Under Pramater Editor    ${filter}    ${tree_name}
    ${key}    Set Variable    ${EMPTY}
    ${bool}    Run Keyword And Return Status    Dictionary Should Contain Key    ${elements}    ${object_path}
    ${key}    Set Variable If    ${bool}    ${object_path}    ${EMPTY}
    ${keys}    Get Dictionary Keys    ${elements}
    FOR    ${k}    IN    @{keys}
        Exit For Loop If    ${bool}
        ${bool}    Run Keyword And Return Status    Should Contain    ${k}    ${object_path}
        ${key}    Set Variable If    ${bool}    ${k}    ${EMPTY}
    END
    ${object}    Get From Dictionary    ${elements}    ${key}
    Call Method    ${object}    click
    ${full_object_path}    Set Variable    ${key}
    Wait Until WebElement Exist    //global-search//li[contains(@class,"active")]//ui-button    10s    1s
    [Return]    ${full_object_path}

SBTS WEM Filt Object On Navigation Panel Under Runtime View
    [Arguments]    ${filter}
    Comment    &{titles_elements}    create Dictionary
    ${titles_elements}    Create List
    Return From Keyword If    '${filter.strip()}'==''    ${titles_elements}
    SBTS WEM Expand Navigation Panel
    Wait Until Element Is Visible    //global-search-filter//input    10s
    Clear Element Text    //global-search-filter//input
    input text    //global-search-filter//input    ${filter}
    ${titles_elements}    Get Webelements    //main-view//global-search//global-search-tab-content//highlighter[contains(@text,"${filter}")]
    [Return]    ${titles_elements}

SBTS WEM Filt Object On Navigation Panel Under Pramater Editor
    [Arguments]    ${filter}    ${tree_name}=Current BTS configuration
    [Documentation]    Filt objet on Navigation Panel under paramter editor in Configuration Manager. Should logon SBTS WEM before.
    ...    Return dictionary with object path as key and webelement as value of objects.
    Should Not Be Equal As Strings    ${filter.strip()}    ${EMPTY}
    &{titles_elements}    create Dictionary
    SBTS WEM Open Configuration Manager    PE
    SBTS WEM Expand Navigation Panel
    wait until keyword succeeds    30    3s    element should be visible    //pe-global-search-filter//input
    Clear Element Text    //ng-view//pe-toolbar//ui-text-input[@a-type="search"]//input
    Clear Element Text    //pe-global-search-filter//input
    input text    //pe-global-search-filter//input    ${filter}
    Sleep    3s    #give seconds to WebEM for responding
    SBTS WEM Expand Configuration Tree On Navigation Panel Under Pramater Editor    ${tree_name}
    ${count}    Selenium2Library.Get Element Count    //global-search//li//span[contains(@aria-label,'${filter}')]
    Return From Keyword If    '${count}'=='0'    ${titles_elements}
    ${object_list}    Get Webelements    //global-search//li//span[contains(@aria-label,'${filter}')]
    FOR    ${object}    IN    @{object_list}
        Call Method    ${object}    click
        wait until keyword succeeds    3x    1s    element should be visible
        ...    //ng-view//wf-panel-section//parameters-editor//div[contains(@class,"pe-middle-panel-header-inner-margin")]//small
        ${object_path}    Get Text
        ...    //ng-view//wf-panel-section//parameters-editor//div[contains(@class,"pe-middle-panel-header-inner-margin")]//small
        Set To Dictionary    ${titles_elements}    ${object_path}=${object}
    END
    [Return]    ${titles_elements}

SBTS WEM Get Sub-objects On Navigation Panel Under Pramater Editor
    [Arguments]    ${object_path}    ${tree_name}=Current BTS configuration
    ${sub_object}    Create List
    ${filter}    Fetch From Right    ${object_path}    /
    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    ${object_path}    ${filter}    ${tree_name}
    ${tmp1}    Set Variable   //global-search//pe-global-search-objects//div[contains(@class,"tree-list-body")]//
    ${tmp2}    Set Variable   li[contains(@class,"active")]//div[contains(@class,"tree-list-row-indent")]/i
    ${has_no_child}    Run Keyword And Return Status    Element Should Not Be Exist    ${tmp1}${tmp2}
    Return From Keyword If    ${has_no_child}    ${sub_object}
    ${tmp1}    Set Variable    //global-search//pe-global-search-objects//div[contains(@class,"tree-list-body")]//
    ${tmp2}    Set Variable    li[contains(@class,"active")]//div[contains(@class,"tree-list-row-indent")]/i
    ${att}    Selenium2Library.Get Element Attribute    ${tmp1}${tmp2}    class
    ${is_expand}    Get Count    ${att}    collapse-icon
    ${tmp1}    Set Variable    //global-search//pe-global-search-objects//div[contains(@class,"tree-list-body")]//
    ${tmp2}    Set Variable    li[contains(@class,"active")]//div[contains(@class,"tree-list-row-indent")]/i
    Run Keyword If    ${is_expand}==${0}    Click Element    ${tmp1}${tmp2}
    ${tree_elements}    Get Webelements    //global-search//pe-global-search-objects//div[contains(@class,"tree-list-body")]//li[@id]
    FOR    ${tree_element}    IN    @{tree_elements}
        Click Element    ${tree_element}
        ${count}    Selenium2Library.Get Element Count
        ...    //ng-view//wf-panel-section//parameters-editor//div[contains(@class,"pe-middle-panel-header-inner-margin")]//small
        Continue For Loop If    ${count}==${0}
        ${path}    Get Text    //ng-view//wf-panel-section//parameters-editor//div[contains(@class,"pe-middle-panel-header-inner-margin")]//small
        Continue For Loop If    '${path}'=='${object_path}'
        ${is_not_sub}    Run Keyword And Return Status    Should Not Contain    ${path}    ${object_path}
        Continue For Loop If    ${is_not_sub}
        Append To List    ${sub_object}    ${path}
    END
    Clear Element Text    //pe-global-search-filter//input
    [Return]    ${sub_object}    # a list, full path of objects under ${object_path}.

SBTS WEM Remove Object On Navigation Panel Under Pramater Editor
    [Arguments]    ${object_path}    ${filter}    ${tree_name}=Current BTS configuration    ${confirm}=${True}
    # ${object_path} is fuzzy matching, can be part of the whole object path
    SBTS WEM Open Configuration Manager
    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    ${object_path}    ${filter}    ${tree_name}
    Element Should Be Exist    //global-search//li[contains(@class,"active")]//button[@ui-tooltip="Remove object"]
    Click Button    //global-search//li[contains(@class,"active")]//button[@ui-tooltip="Remove object"]
    Wait Until Page Contains Element    //common-modal[@modal-title="Object Removal"]    5s
    ${button_xpath}    Set Variable If    ${confirm}    //common-modal[@modal-title="Object Removal"]//ui-button[@a-text="Submit"]/button
    ...    //common-modal[@modal-title="Object Removal"]//ui-button[@a-text="Cancel"]/button
    SBTS WEM Click Button Or Element    ${button_xpath}    3    3s    KW_checker=Element Should Not Be Exist
    ...    param_checker=//common-modal[@modal-title\="Object Removal"]

SBTS WEM Add Object On Navigation Panell Under Pramater Editor
    [Arguments]    ${object_path}    ${filter}    ${params}    ${tree_name}=Current BTS configuration    ${confirm}=${True}
    # ${object_path} is fuzzy matching, can be part of the whole object path
    ${created_object_path}    Set Variable
    SBTS WEM Open Configuration Manager
    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    ${object_path}    ${filter}    ${tree_name}
    Wait Until Keyword Succeeds    5s    1s    Element Should Be Exist    //li[contains(@class,"active")]//button[@ui-tooltip="Add object"]
    ${is_enable_to_add}    Run Keyword And Return Status    Element Should Be Enabled With Attribute
    ...    //li[contains(@class,"active")]//button[@ui-tooltip="Add object"]
    Return From Keyword If    not ${is_enable_to_add}    ${created_object_path}
    Click Button    //li[contains(@class,"active")]//button[@ui-tooltip="Add object"]
    Wait Until Keyword Succeeds    10s    1s    Element Should Be Exist
    ...    //div[@uib-modal-transclude]//ui-modal[@a-title="Add Object"]//div[@class="modal-body"]
    FOR    ${param}    IN    @{params}
        ${tmp1}    Set Variable    //div[@uib-modal-transclude]//ui-modal[@a-title="Add Object"]//div[@class="modal-body"]//
        ${tmp2}    Set Variable    div[contains(text(),"${param[0]}")]/../div[@class="data-input"]//input
        Run Key Word If    '${param[1]}'=='textbox'    Input Text    ${tmp1}${tmp2}    ${param[2]}
        ${tmp1}    Set Variable    //div[@uib-modal-transclude]//ui-modal[@a-title="Add Object"]//div[@class="modal-body"]//
        ${tmp2}    Set Variable    div[contains(text(),"${param[0]}")]/../div[@class="data-input"]//input
        Run Key Word If    '${param[1]}'=='checkbox'    Set Web CheckBox    ${tmp1}${tmp2}    ${param[2]}
        Run Key Word If    '${param[1]}'=='selectedlist'    Select List On Adding Object Popup    ${param[0]}    ${param[2]}
    END
    ${button_xpath}    Set Variable If    ${confirm}
    ...    //div[@uib-modal-transclude]//ui-modal[@a-title="Add Object"]//ui-button[@a-text="Submit"]/button
    ...    //div[@uib-modal-transclude]//ui-modal[@a-title="Add Object"]//ui-button[@a-text="Cancel"]/button
    Click Button    ${button_xpath}
    Wait Until Keyword Succeeds    30s    3s    Element Should Not Be Exist    //div[@uib-modal-transclude]//ui-modal[@a-title="Add Object"]
    Wait Until Keyword Succeeds    30s    3s    Element Should Be Exist
    ...    //ng-view//wf-panel-section//parameters-editor//div[contains(@class,"pe-middle-panel-header-inner-margin")]//small
    ${created_object_path}    Get Text
    ...    //ng-view//wf-panel-section//parameters-editor//div[contains(@class,"pe-middle-panel-header-inner-margin")]//small
    [Return]    ${created_object_path}

SBTS WEM Get LTE And WCDMA Carriers Infor
    SBTS WEM Open Configure In Commissioning Wizard
    ${LTE_Type}    Create List    LTE FDD    LTE TDD    LTE Standalone NB IoT    WCDMA
    &{carrier_info}    Create Dictionary
    FOR    ${type}    IN    @{LTE_Type}
        SBTS WEM Select Object On Commissioning Wizard Configure Popup    Cells Configuration\\${type}\\Cell Carriers
    END
    Element Should Be Exist    //div[@uib-modal-transclude]//wizard-steps-modal-body//ul//li//div[@title="Cell Carriers"]
    ${elements}    Get WebElements    //div[@uib-modal-transclude]//wizard-steps-modal-body//ul//li//div[@title="Cell Carriers"]
    FOR    ${element}    IN    @{elements}
        Click Element    ${element}
        ${title}    Get Text   //div[@uib-modal-transclude]//div[@class="center-panel"]//wizard-expandable-toggle-buttons/div/wizard-sub-header//span
        ${type}    Fetch From Left    ${title}    Carriers configuration
        Continue For Loop If    "${type.strip()}"=="GSM"
        ${data}    SBTS WEM Get Selected Cell Carriers Infor    ${carrier_info}    ${type.strip()}
    END
    Click Button    //div[@uib-modal-transclude]//wizard-steps-modal-footer//div[@class="right-buttons"]//ui-button[@a-text="Cancel"]/button
    Wait Until Keyword Succeeds    10s    1s    Element Should Be Exist
    ...    //div[@uib-modal-transclude]//wizard-steps-cancel-modal//label/span[text()="Perform revalidation after cancelling"]
    Mouse Down    //div[@uib-modal-transclude]//wizard-steps-cancel-modal//label/span[text()="Perform revalidation after cancelling"]
    Mouse Up    //div[@uib-modal-transclude]//wizard-steps-cancel-modal//label/span[text()="Perform revalidation after cancelling"]
    Mouse Down    //div[@uib-modal-transclude]//wizard-steps-cancel-modal//ui-default-buttons//ui-button[@a-text="Yes"]/button
    Mouse Up    //div[@uib-modal-transclude]//wizard-steps-cancel-modal//ui-default-buttons//ui-button[@a-text="Yes"]/button
    ${cells}    Get Dictionary Keys    ${carrier_info}
    FOR    ${cell}    IN    @{cells}
        ${not_wcdma}    Run Keyword And Return Status    Should Not Contain    ${cell}    WNCEL
        Continue For Loop If    ${not_wcdma}
        ${frq_info_dic}    SBTS WEM Get WCDMA Cell Freq Info    ${cell}
        Set To Dictionary    ${carrier_info['${cell}']}    BW_DL=${frq_info_dic['Downlink channel bandwidth:']}
        Set To Dictionary    ${carrier_info['${cell}']}    BW_UL=${frq_info_dic['Uplink channel bandwidth:']}
        Set To Dictionary    ${carrier_info['${cell}']}    FREQ_DL=${frq_info_dic['Downlink frequency:']}
        Set To Dictionary    ${carrier_info['${cell}']}    FREQ_UL=${frq_info_dic['Uplink frequency:']}
    END
    [Return]    ${carrier_info}

SBTS WEM Get GSM Cell Radio Frequency
    &{ret}    Create Dictionary
    ${cell_names}    SBTS WEM Get All Cell Name
    ${gsm_cell}    Create List
    FOR    ${name}    IN    @{cell_names}
        ${is_GSM}    Run Keyword And Return Status    Should Contain    ${name}    GNCEL
        Run Keyword If    ${is_GSM}    Append To List    ${gsm_cell}    ${name}
    END
    ${count}    Get Length    ${gsm_cell}
    Return From Keyword If    '${count}'=='0'    ${ret}
    SBTS WEM Expand Detail Panel
    FOR    ${name}    IN    @{gsm_cell}
        SBTS WEM Select Object On Navigation Panel Under Runtime View    ${name}    ${name}
        ${downlink_freq_1}    Get Text    //details-panel//table[@class="trx-table"]//tbody[1]/tr[1]/td[2]
        ${uplink_freq_1}    Get Text    //details-panel//table[@class="trx-table"]//tbody[1]/tr[1]/td[3]
        ${downlink_freq_2}    Get Text    //details-panel//table[@class="trx-table"]//tbody[2]/tr[1]/td[2]
        ${uplink_freq_2}    Get Text    //details-panel//table[@class="trx-table"]//tbody[2]/tr[1]/td[3]
        &{dic1}    Create Dictionary    Downlink freq=${downlink_freq_1}    Uplink freq=${uplink_freq_1}
        &{dic2}    Create Dictionary    Downlink freq=${downlink_freq_2}    Uplink freq=${uplink_freq_2}
        ${list}    Create List    ${dic1}    ${dic2}
        Set To Dictionary    ${ret}    ${name}=${list}
    END
    [Return]    ${ret}

SBTS WEM Get WCDMA Cell Freq Info
    [Arguments]    ${cell_name}
    SBTS WEM Open RunTime View    C
    SBTS WEM Select Object On Navigation Panel Under Runtime View    ${cell_name}    ${cell_name}
    SBTS WEM Expand Detail Panel
    Wait Until Element Is Visible    //details-panel//details-panel-content//hardware-details//li[@heading="Info"]    10s
    Click Element    //details-panel//details-panel-content//hardware-details//li[@heading="Info"]
    ${object_name}    Get Text    //details-panel//details-panel-content//hardware-details//div[contains(@class,"element-name")]
    Should Be Equal As Strings    ${object_name}    ${cell_name}
    ${param_name_elements}    Get WebElements
    ...    //details-panel//details-panel-content//div[@details-info-table]//div[2]//table//td[contains(@class,"parameter-name")]
    ${param_value_elements}    Get WebElements
    ...    //details-panel//details-panel-content//div[@details-info-table]//div[2]//table//td[contains(@class,"parameter-value")]
    &{ret_dic}    Create Dictionary
    ${count}    Get Length    ${param_name_elements}
    FOR    ${index}    IN RANGE    0    ${count}
        ${para_name}    Get Text    ${param_name_elements[${index}]}
        ${para_value}    Get Text    ${param_value_elements[${index}]}
        Set To Dictionary    ${ret_dic}    ${para_name}=${para_value}
    END
    [Return]    ${ret_dic}

SBTS WEM Get Selected Cell Carriers Infor
    [Arguments]    ${carrier_info}    ${type}
    Wait Until WebElement Exist
    ...    //div[@uib-modal-transclude]//wizard-steps-modal-body//wizard-expandable-toggle-buttons//ui-button[@a-title="Expand all"]
    ${cell_count}    Selenium2Library.Get Element Count
    ...    //div[@uib-modal-transclude]//wizard-steps-modal-body//div[contains(@class,"center-panel")]//ui-expandable-panel
    FOR    ${index}    IN RANGE    1    ${cell_count}+1
        ${tmp1}    Set Variable    //div[@uib-modal-transclude]//wizard-steps-modal-body//div[contains(@class,"center-panel")]//
        ${tmp2}    Set Variable    ui-expandable-panel[${index}]//ui-expandable-panel-header/cell-panel-header/div/wizard-accordion-header
        ${cell_name}    Get Text    ${tmp1}${tmp2}
        ${tmp1}    Set Variable    //div[@uib-modal-transclude]//wizard-steps-modal-body//
        ${tmp2}    Set Variable    div[contains(@class,"center-panel")]//ui-expandable-panel[${index}]//ui-expandable-panel-header/
        ${tmp3}    Set Variable    cell-panel-header/div/wizard-accordion-detail//div[contains(@class,"parameter-value")][1]
        ${bandwith}    Get Text    ${tmp1}${tmp2}${tmp3}
        ${bandwith_list}    Split String    ${bandwith}    /
        ${tmp1}    Set Variable    //div[@uib-modal-transclude]//wizard-steps-modal-body//div[contains(@class,"center-panel")]//
        ${tmp2}    Set Variable    ui-expandable-panel[${index}]//ui-expandable-panel-header/cell-panel-header/div/
        ${tmp3}    Set Variable    wizard-accordion-detail//div[contains(@class,"parameter-value")][2]
        ${val_list}    Get Text    ${tmp1}${tmp2}${tmp3}
        ${fcn_list}    Split String    ${val_list}    /
        ${tmp1}    Set Variable    //div[@uib-modal-transclude]//wizard-steps-modal-body//div[contains(@class,"center-panel")]//
        ${tmp2}    Set Variable    ui-expandable-panel[${index}]//ui-expandable-panel-header/cell-panel-header/div/
        ${tmp3}    Set Variable    wizard-accordion-detail//div[contains(@class,"parameter-value")][3]
        ${val_list}    Get Text    ${tmp1}${tmp2}${tmp3}
        ${freq_list}    Split String    ${val_list}    /
        ${tmp1}    Set Variable    //div[@uib-modal-transclude]//wizard-steps-modal-body//div[contains(@class,"center-panel")]//
        ${tmp2}    Set Variable    ui-expandable-panel[${index}]//ui-expandable-panel-header/cell-panel-header/div/
        ${tmp3}    Set Variable    wizard-accordion-detail//div[contains(@class,"parameter-value")][4]
        ${cell_power}    Get Text    ${tmp1}${tmp2}${tmp3}
        &{carrier_dic}    Create Dictionary    BW_UL=${bandwith_list[0].strip()}    BW_DL=${bandwith_list[-1].strip()}
        ...    FCN_DL=${fcn_list[0].strip()}    FCN_UL=${fcn_list[-1].strip()}
        ...    FREQ_DL=${freq_list[0].strip()}    FREQ_UL=${freq_list[-1].strip()}    CELL_POWER=${cell_power}    type=${type}
        Set To Dictionary    ${carrier_info}    ${cell_name}=${carrier_dic}
    END
    [Return]    ${carrier_info}

SBTS WEM Get Cells Name And Path
    [Arguments]    ${type}    ${tree_name}=Current BTS configuration
    [Documentation]    ${type} should be one of GSM/WCDMA/LTE/NR
    &{type_dic}    Evaluate    {"GSM":"GNCEL-","WCDMA":"WNCEL-","LTE":"LNCEL-","NR":"NRCELL-"}
    ${key}    Get From Dictionary    ${type_dic}    ${type}
    ${elements}    SBTS WEM Filt Object On Navigation Panel Under Pramater Editor    ${key}    ${tree_name}
    ${paths}    Get Dictionary Keys    ${elements}
    &{dic}    Create Dictionary
    FOR    ${path}    IN    @{paths}
        ${name}    Fetch From Right    ${path}    /
        ${is_not_cell}    Run Keyword And Return Status    Should Not Start With    ${name}    ${key}
        Continue For Loop If    ${is_not_cell}
        Set To Dictionary    ${dic}    ${name}    ${path}
    END
    [Return]    ${dic}

SBTS WEM Get Mediator Infor
    SBTS WEM Open RunTime View    SV
    ${tmp1}    Set Variable    //ng-view/wf-panel/wf-panel-section//simplified-site-tab//div[contains(@class,"system-section-content")]//
    ${tmp2}    Set Variable    div[contains(@class,"system-section-subcolumn")][2]/div[contains(@class,"system-block-list")]
    Wait Until WebElement Exist    ${tmp1}${tmp2}
    ${tmp1}    Set Variable    //ng-view/wf-panel/wf-panel-section//simplified-site-tab//div[contains(@class,"system-section-content")]//
    ${tmp2}    Set Variable    div[contains(@class,"system-section-subcolumn")][2]/div[contains(@class,"system-block-list")]
    Click Element    ${tmp1}${tmp2}
    ${tmp1}    Set Variable    //ng-view/wf-panel/wf-panel-section//simplified-site-tab//div[contains(@class,"system-section-content")]//
    ${tmp2}    Set Variable    div[contains(@class,"system-section-subcolumn")][2]/div[contains(@class,"system-block-list")]
    ${mediator_name}    Selenium2Library.Get Text    ${tmp1}${tmp2}//div[contains(@class,"block-main-header")]
    ${tmp1}    Set Variable     //ng-view/wf-panel/wf-panel-section//simplified-site-tab//div[contains(@class,"system-section-content")]//
    ${tmp2}    Set Variable    div[contains(@class,"system-section-subcolumn")][2]/div[contains(@class,"system-block-list")]
    ${mediator_status}    Selenium2Library.Get Element Attribute    ${tmp1}${tmp2}//div[contains(@class,"square-diode")]    title
    ${tmp1}    Set Variable    //ng-view/wf-panel/wf-panel-section//simplified-site-tab//div[contains(@class,"system-section-content")]//
    ${tmp2}    Set Variable    div[contains(@class,"system-section-subcolumn")][2]/div[contains(@class,"system-block-list")]//
    ${mediator_diode_class}    Selenium2Library.Get Element Attribute    ${tmp1}${tmp2}div[contains(@class,"square-diode")]    class
    [Return]    ${mediator_name}    ${mediator_status}    ${mediator_diode_class}

SBTS WEM Filt Parameter
    [Arguments]    ${toolbar_filter}=${None}    ${form_param_name}=${None}    ${form_abbreviation}=${None}
    ...    ${form_status_option}=default    ${form_status_show}=default
    [Documentation]    ${form_status_option} should be one of 'all','mandatoryOnly','optionalOnly'
    SBTS WEM Open Configuration Manager
    Wait Until WebElement Exist    //ng-view//pe-toolbar//ui-text-input[@a-type="search"]//input    30s    3s
    Clear Element Text    //ng-view//pe-toolbar//ui-text-input[@a-type="search"]//input
    Sleep    2s
    Run Keyword Unless    '${toolbar_filter}' == 'None'    Input Text    //ng-view//pe-toolbar//ui-text-input[@a-type="search"]//input
    ...    ${toolbar_filter}
    Press Keys    //ng-view//pe-toolbar//ui-text-input[@a-type="search"]//input    ${\n}    #press ENTER of keyboard
    ${is_parameter_tatble_load}    Run Keyword And Return Status    Wait Until Page Contains Element    //parameters-editor-table-header    10s
    Return From Keyword If    not ${is_parameter_tatble_load}
    Clear Element Text    //parameters-editor-table-header//th[@class="pe-full-name-cell"]/input
    Run Keyword Unless    '${form_param_name}' == 'None'    Input Text    //parameters-editor-table-header//th[@class="pe-full-name-cell"]/input
    ...    ${form_param_name}
    Clear Element Text    //parameters-editor-table-header//th[@class="pe-abbreviation-cell"]/input
    Run Keyword Unless    '${form_abbreviation}' == 'None'    Input Text
    ...    //parameters-editor-table-header//th[@class="pe-abbreviation-cell"]/input    ${form_abbreviation}
    Run Keyword Unless    '${form_status_option}'=='default'    Run Keywords    Click Button
    ...    //parameters-editor-table-header//th[@class="pe-info-cell"]//button[@class="table-parameter-search"]
    ...    AND    Click Element    //input[@type='radio' and @name='pe-filter-radio' and @value='${form_status_option}']/..
    ...    AND    Click Button    //parameters-editor-table-header//th[@class="pe-info-cell"]//button[@class="table-parameter-search"]
    Return From Keyword If    '${form_status_show}'=='default'
    ${len}    Get Length    ${form_status_show}
    Should Be Equal As Integers    ${4}    ${len}    form_status_show should a be 4 bit binary string or 'default' but was '${form_status_show}'
    Click Button    //parameters-editor-table-header//th[@class="pe-info-cell"]//button[@class="table-parameter-search"]
    Run Keyword If    '${form_status_show[0]}'=='1'    Click Element    //input[@type='checkbox' and @id='pe-filter-modified']/..
    Run Keyword If    '${form_status_show[1]}'=='1'    Click Element    //input[@type='checkbox' and @id='pe-filter-invalid']/..
    Run Keyword If    '${form_status_show[2]}'=='1'    Click Element    //input[@type='checkbox' and @id='pe-filter-existing']/..
    Run Keyword If    '${form_status_show[3]}'=='1'    Click Element    //input[@type='checkbox' and @id='pe-filter-non-existing']/..
    Click Button    //parameters-editor-table-header//th[@class="pe-info-cell"]//button[@class="table-parameter-search"]
    [Teardown]    Sleep    1s    # Give a second to the WebUI for responding

SBTS WEM Get Parameters In PE Table
    [Documentation]    Should filter parameter or select object before calling this keyword
    @{parameters}    Create List
    ${table_x_path}    Set Variable    //parameters-editor-table-body/table
    ${is_table_exist}    Run Keyword And Return Status    Wait Until WebElement Exist    ${table_x_path}    20s    1s
    Return From Keyword If    not ${is_table_exist}    ${parameters}
    ${row_x_path}    Set Variable    ${table_x_path}//tbody/tr[contains(@class,"row-existing") or contains(@class,"row-non-existing")]
    ${row_count}    Selenium2Library.Get Element Count    ${row_x_path}
    ${full_name}    Set Variable
    FOR    ${row_index}    IN RANGE    1    ${row_count}+1
        ${attribute_class}    Selenium2Library.Get Element Attribute    ${row_x_path}\[${row_index}\]    class
        ${is_param_not_configured}    Run Keyword And Return Status    Should Contain    ${attribute_class}    row-non-existing
        ${col_full_name_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-full-name-cell")]
        ${col_list_lable_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-list-label-cell")]
        ${actual_value_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-actual-value-cell")]
        ${abbreviation_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-abbreviation-cell")]
        ${object_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-full-name-cell")]/div
        ${plan_value_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-value-cell")]
        ${cur_full_name}    Run Keyword If    '${col_full_name_count}'=='1'    Get Text
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-full-name-cell")]//highlighter
        ${full_name}    Set Variable If    '${cur_full_name}'=='None'    ${full_name}    ${cur_full_name}
        ${list_lable}    Run Keyword If    '${col_list_lable_count}'=='1'    Get Text
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-list-label-cell")]
        ${abbreviation}    Run Keyword If    '${abbreviation_count}'=='1'    Get Text
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-abbreviation-cell")]//highlighter/span
        ${actual_value}    Run Keyword If    '${actual_value_count}'=='1'    Get Text
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-actual-value-cell")]//highlighter/span
        ${actual_value}    Set Variable If    ${is_param_not_configured}    !DELETE!    ${actual_value}
        ${object}    Run Keyword If    '${object_count}'=='1'    Get Text
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-full-name-cell")]/div
        ${plan_value}    Run Keyword If    '${plan_value_count}'=='1'    Get Text
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-value-cell")]
        &{parameter}    Create Dictionary
        Set To Dictionary    ${parameter}    full_name    ${full_name}
        Set To Dictionary    ${parameter}    list_lable    ${list_lable}
        Set To Dictionary    ${parameter}    abbreviation    ${abbreviation}
        Set To Dictionary    ${parameter}    actual_value    ${actual_value}
        Set To Dictionary    ${parameter}    object    ${object}
        Set To Dictionary    ${parameter}    plan_value    ${plan_value}
        Append To List    ${parameters}    ${parameter}
    END
    ${object_count}    Selenium2Library.Get Element Count
    ...    //ng-view//wf-panel-section//parameters-editor//div[contains(@class,"pe-middle-panel-header-inner-margin")]//small
    Return From Keyword If    '${object_count}'=='0'    ${parameters}
    ${object}    Get Text    //ng-view//wf-panel-section//parameters-editor//div[contains(@class,"pe-middle-panel-header-inner-margin")]//small
    FOR    ${param}    IN    @{parameters}
        Set To Dictionary    ${param}    object    ${object}
    END
    [Return]    ${parameters}

SBTS WEM Check MO Type Exists On PE
    [Arguments]    ${father_MO}    ${MO_type}    ${should_exist}=${True}
    SBTS WEM Open Configuration Manager
    ${filter}    Fetch From Right    ${father_MO}    /
    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    ${father_MO}    ${filter}
    Wait Until Keyword Succeeds    5s    1s    Element Should Be Exist    //li[contains(@class,"active")]//button[@ui-tooltip="Add object"]
    ${is_enable_to_add}    Run Keyword And Return Status    Element Should Be Enabled With Attribute
    ...    //li[contains(@class,"active")]//button[@ui-tooltip="Add object"]
    Return From Keyword If    not ${is_enable_to_add}    ${created_object_path}
    Click Button    //li[contains(@class,"active")]//button[@ui-tooltip="Add object"]
    Wait Until Keyword Succeeds    10s    1s    Element Should Be Exist
    ...    //div[@uib-modal-transclude]//ui-modal[@a-title="Add Object"]//div[@class="modal-body"]
    ${tmp1}    Set Variable    //div[@uib-modal-transclude]//ui-modal[@a-title="Add Object"]//div[@class="modal-body"]//
    ${tmp2}    Set Variable    //div[@uib-modal-transclude]//ui-modal[@a-title="Add Object"]//div[@class="modal-body"]//
    ${count}    Selenium2Library.Get Element Count    ${tmp1}${tmp2}div[contains(text(),"Object class:")]/../div[@class="data-input"]//button
    Should Not Be Equal As Integers    ${count}    ${0}
    ${tmp1}    Set Variable    //div[@uib-modal-transclude]//ui-modal[@a-title="Add Object"]//
    Click Button    ${tmp1}div[@class="modal-body"]//div[contains(text(),"Object class:")]/../div[@class="data-input"]//button
    ${tmp1}    Set Variable    //div[@uib-modal-transclude]//ui-modal[@a-title="Add Object"]//div[@class="modal-body"]//
    ${ret}    Run Keyword And Return Status    Wait Until WebElement Exist
    ...    ${tmp1}div[contains(text(),"Object class:")]/../div[@class="data-input"]//li[@data-value="${MO_type}"]    5s    1s
    Click Button    //div[@uib-modal-transclude]//ui-modal[@a-title="Add Object"]//ui-button[@a-text="Cancel"]/button
    Clear Element Text    //pe-global-search-filter//input
    Should Be Equal As Strings    ${ret}    ${should_exist}

SBTS WEM Modify Parameters In PE Table
    [Arguments]    ${object}    ${param_name}    ${value}    ${sub_item_name}=${EMPTY}    ${tree_name}=Current BTS configuration
    [Documentation]    ${object} should be full path of object
    ...    ${param_name} should be full name of parameter
    ...    ${sub_item_name} should be the sub-item name of ${param_name}
    ...    if the input type is select list, ${value} should be the label text which need to be selected.
    ...    if the ${value} is !DELETE! , the parameter shall be deleted.
    ${is_delete}    Run Keyword And Return Status    Should Be Equal As Strings    ${value}    !DELETE!
    ${succeed}    Run Keyword If    ${is_delete}    SBTS WEM Click Action In PE Table    ${object}    ${param_name}    Delete parameter
    ...    ${sub_item_name}    ${tree_name}
    Return From Keyword If    ${is_delete}    ${succeed}
    ${succeed}    Set Variable    ${False}
    SBTS WEM Open Configuration Manager    PE
    ${is_object_selected}    Check If Object Selected On Navigation Panel Under Pramater Editor    ${object}
    ${object_name}    Fetch From Right    ${object}    /
    Run Keyword Unless    ${is_object_selected}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor
    ...    ${object}    ${object_name}    ${tree_name}
    Wait Until WebElement Exist    //parameters-editor-table-header//th[@class="pe-full-name-cell"]/input    20s    2s
    Input Text    //parameters-editor-table-header//th[@class="pe-full-name-cell"]/input    ${param_name}
    Sleep    3s    Give seconds to WebUI for responding...
    ${row_x_path}    Set Variable
    ...    //parameters-editor-table-body/table//tbody/tr[contains(@class,"row-existing") or contains(@class,"row-non-existing")]
    ${row_count}    Selenium2Library.Get Element Count    ${row_x_path}
    Return From Keyword If    '${row_count}'=='0'    ${succeed}
    ${full_name}    Set Variable
    FOR    ${row_index}    IN RANGE    1    ${row_count}+1
        ${col_full_name_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-full-name-cell")]
        ${col_list_lable_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-list-label-cell")]
        ${cur_full_name}    Run Keyword If    '${col_full_name_count}'=='1'    Get Text
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-full-name-cell")]//highlighter
        ${full_name}    Set Variable If    '${cur_full_name}'=='None'    ${full_name}    ${cur_full_name}
        ${list_lable}    Run Keyword If    '${col_list_lable_count}'=='1'    Get Text
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-list-label-cell")]
        Continue For Loop If    '${full_name}'!='${param_name}'
        Continue For Loop If    '${sub_item_name}'!='' and '${sub_item_name}'!='${list_lable}'
        ${input_count}    Selenium2Library.Get Element Count
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-value-cell")]//parameter-input//input
        ${select_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-value-cell")]//select
        ${listbutton_count}    Selenium2Library.Get Element Count
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-value-cell")]//parameter-input//wf-dropdown//button
        Continue For Loop If    '${input_count}'=='0' and '${select_count}'=='0' and '${listbutton_count}'=='0'
        ${planned_value_elements}    Set Variable If    '${input_count}'=='1'
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-value-cell")]//input
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-value-cell")]//select
        ${planned_value_elements}    Set Variable If    '${listbutton_count}'=='1'
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-value-cell")]//parameter-input//wf-dropdown//button    ${planned_value_elements}
        ${att_disabled}    Selenium2Library.Get Element Attribute    ${planned_value_elements}    disabled
        ${succeed}    Set Variable If    '${att_disabled}'=='disabled' or '${att_disabled}'=='true'    ${True}    ${False}
        Continue For Loop If    '${att_disabled}'=='disabled' or '${att_disabled}'=='true'
        Run Keyword If    '${select_count}'=='1'    Select From List By Label    ${planned_value_elements}    ${value}
        ${succeed}    Set Variable If    '${select_count}'=='1'    ${True}    ${False}
        Exit For Loop If    ${succeed}
        Run Keyword If    '${listbutton_count}'=='1'    Select PE Table ButtonList By Value
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-value-cell")]//parameter-input//button    ${value}
        ${succeed}    Set Variable If    '${listbutton_count}'=='1'    ${True}    ${False}
        Exit For Loop If    ${succeed}
        Clear Element Text    ${planned_value_elements}
        Input Text    ${planned_value_elements}    ${value}
        Clear Element Text    //parameters-editor-table-header//th[@class="pe-full-name-cell"]/input
        ${succeed}    Set Variable    ${True}
    END
    [Return]    ${succeed}

SBTS WEM Click Action In PE Table
    [Arguments]    ${object}    ${param_name}    ${action_name}    ${sub_item_name}=${EMPTY}    ${tree_name}=Current BTS configuration
    [Documentation]    ${object} should be full path of object
    ...    ${param_name} should be full name of parameter
    ...    ${action_name} should be the title of action button
    ...    ${sub_item_name} should be the sub-item name of ${param_name}
    ${succeed}    Set Variable    ${False}
    ${is_object_selected}    Run Keyword And Return Status    Wait Until Page Contains Element
    ...    //ng-view//wf-panel-section//parameters-editor//div[contains(@class,"pe-middle-panel-header-inner-margin")]//small    10s
    ${object_name}    Fetch From Right    ${object}    /
    Run Keyword Unless    ${is_object_selected}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor
    ...    ${object}    ${object_name}    ${tree_name}
    Wait Until WebElement Exist    //parameters-editor-table-header//th[@class="pe-full-name-cell"]/input    20s    2s
    Input Text    //parameters-editor-table-header//th[@class="pe-full-name-cell"]/input    ${param_name}
    ${row_x_path}    Set Variable
    ...    //parameters-editor-table-body/table//tbody/tr[contains(@class,"row-existing") or contains(@class,"row-non-existing")]
    ${row_count}    Selenium2Library.Get Element Count    ${row_x_path}
    Return From Keyword If    '${row_count}'=='0'    ${succeed}
    ${full_name}    Set Variable
    FOR    ${row_index}    IN RANGE    1    ${row_count}+1
        ${col_full_name_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-full-name-cell")]
        ${col_list_lable_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-list-label-cell")]
        ${cur_full_name}    Run Keyword If    '${col_full_name_count}'=='1'    Get Text
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-full-name-cell")]//highlighter
        ${full_name}    Set Variable If    '${cur_full_name}'=='None'    ${full_name}    ${cur_full_name}
        ${list_lable}    Run Keyword If    '${col_list_lable_count}'=='1'    Get Text
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-list-label-cell")]
        Continue For Loop If    '${full_name}'!='${param_name}'
        Continue For Loop If    '${sub_item_name}'!='' and '${sub_item_name}'!='${list_lable}'
        ${button_count}    Selenium2Library.Get Element Count
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"parameter-action-buttons-cell")]//button[@ui-tooltip="${action_name}"]
        Continue For Loop If    '${button_count}' == '0'
        ${is_active}    Run Keyword And Return Status    Element Should Be Enabled
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"parameter-action-buttons-cell")]//button[@ui-tooltip="${action_name}"]
        Continue For Loop If    not ${is_active}
        Click Button    ${row_x_path}\[${row_index}\]/td[contains(@class,"parameter-action-buttons-cell")]//button[@ui-tooltip="${action_name}"]
        ${succeed}    Set Variable    ${True}
    END
    Clear Element Text    //parameters-editor-table-header//th[@class="pe-full-name-cell"]/input
    [Return]    ${succeed}

SBTS WEM Get Name Of New Add Sub-ItemIn PE
    [Arguments]    ${param_name}
    Wait Until WebElement Exist    //parameters-editor-table-header//th[@class="pe-full-name-cell"]/input    20s    2s
    Input Text    //parameters-editor-table-header//th[@class="pe-full-name-cell"]/input    ${param_name}
    ${sub_item_name}    Create List
    ${xpath_str1}    Set Variable    //parameters-editor-table-body/table//tbody/tr[@ng-repeat]/td[@pe-value-cell]/../
    ${xpath_str2}    Set Variable    td/i[@title="Invalid parameter value"]/../../td[@pe-full-name-cell or @pe-list-label]
    ${sub_item_elements}    Selenium2Library.Get Webelements    ${xpath_str1}${xpath_str2}
    FOR    ${e}    IN    @{sub_item_elements}
        ${item_name}    Selenium2Library.Get Text    ${e}
        Append To List    ${sub_item_name}    ${item_name}
    END
    [Return]    ${sub_item_name}

SBTS WEM Set New Add Sub-Item In PE
    [Arguments]    ${object}    ${full_name}    ${value}    ${sub-item_name}=${None}    ${tree_name}=Current BTS configuration
    SBTS WEM Open Configuration Manager
    ${filter}    Fetch From Right    ${object}    /
    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    ${object}    ${filter}    ${tree_name}
    SBTS WEM Filt Parameter    ${full_name}
    ${succeed}    SBTS WEM Click Action In PE Table    ${object}    ${full_name}    Add Element    tree_name=Current BTS configuration
    Should Be True    ${succeed}
    ${new_item_name}    SBTS WEM Get Name Of New Add Sub-ItemIn PE    ${full_name}
    Run Keyword If    '${sub-item_name}'!='None'    Should Be Equal As Strings    ${new_item_name}    ${sub-item_name}
    Should Be Equal As Integers    ${new_item_name.__len__()}    ${1}
    ${succeed}    SBTS WEM Modify Parameters In PE table    ${object}    ${full_name}    ${value}    ${new_item_name[0]}    ${tree_name}
    Should Be True    ${succeed}
    [Return]    ${new_item_name}

SBTS WEM Click All Notify Messages
    [Documentation]    Click all the notify pops-up of SBTS WebEM at the moment this KW is called.
    ${count}    Selenium2Library.Get Element Count    //div[contains(@class,"notifyjs-corner")]//i[contains(@class,"notify-icon")]
    Return From Keyword If    "${count}"=="0"
    ${elements}    Get WebElements    //div[contains(@class,"notifyjs-corner")]//i[contains(@class,"notify-icon")]
    ${ret}    Set Variable    ${True}
    FOR    ${elemet}    IN    @{elements}
        Run Keyword And Return Status    Click Element    ${elemet}
    END
    [Return]    ${ret}

SBTS WEM Validate Plan
    LOG    SBTS WEM Validate Plan    console=${True}
    SBTS WEM Open Configuration Manager    PE
    Wait Until WebElement Exist    //ng-view//revalidate-action-button    30s    3s
    Wait Until Keyword Succeeds    30s    5s    Element Should Be Enabled With Attribute    //ng-view//revalidate-action-button
    Click Button    //ng-view//revalidate-action-button//button
    Wait Until WebElement Exist    //loading-screen//div[@id="loading-screen" and @aria-hidden="false"]    3s    1s
    Wait Until WebElement Exist    //loading-screen//div[@id="loading-screen" and @aria-hidden="true"]

SBTS WEM Activate Plan
    [Arguments]    ${forced_activate}=${False}    ${download_only}=${False}    ${timeout}=600    ${wait_until_finish}=${True}
    ...    ${reset_list}=${None}
    LOG    SBTS WEM Activate Plan    console=${True}
    SBTS WEM Open Configuration Manager    ${None}
    Wait Until WebElement Exist    //ng-view//deploy-action-button    10s    1s
    ${warning_msg}    Set Variable
    ${is_enabled}    Selenium2Library.Get Element Attribute    //ng-view//deploy-action-button//button    disabled
    ${tips}    Selenium2Library.Get Element Attribute    //ng-view//deploy-action-button//ui-button    a-title
    Should Be True    "${is_enabled}"=="None"    ${tips}
    Return From Keyword If    "${is_enabled}"!="None"    ${tips}
    #While KW called in tear down, assertion shall not break off KW. Return forwardly to save time.
    Click Button    //ng-view//deploy-action-button//button
    Wait Until WebElement Exist    //deploy-plan-modal-component    10s    1s
    ${is_pass}    ${input}    Run Keyword And Ignore Error    Get WebElements    //deploy-plan-modal-component//label
    Run Keyword If    ${download_only}    Select Checkbox    ${input[0]}
    ${count}    Get Length    ${input}
    ${is_pass}    Set Variable If    ${count} > 0    PASS    FAIL
    ${is_forced_enable}    Evaluate    ${count} > 1
    Run Keyword If    ${forced_activate} and ${is_forced_enable}    Select Checkbox    ${input[1]}
    ${is_enabled}    Run Keyword And Return Status    Element Should Be Enabled
    ...    //deploy-plan-modal-component//ui-button[@a-text="Execute"]//button
    Should Be True    ${is_enabled}    Excute button is not enabled
    Click Button    //deploy-plan-modal-component//ui-button[@a-text="Execute"]//button    #click excute button to start activation
    ${tex}    Run Keyword If    ${is_forced_enable}    Get Text    //deploy-plan-modal-component//label[1]
    Run Keyword If    "${is_pass}"=="PASS"    Wait Until Keyword Succeeds    30x    1s    Element Should Be Disabled
    ...    //deploy-plan-modal-component//ui-button[@a-text="Execute"]//button
    Run Keyword If    ${reset_list}    Wait Until Element Is Enabled
    ...    //deploy-plan-modal-component//ui-button[@a-text="Execute"]//button    200s
    ${warning_msg}    Run Keyword If    ${reset_list}    Get Text
    ...    //deploy-plan-modal-component//div[@class="feedback-section"]//i[contains(@class,"icon-warning")]/../span
    Run Keyword If    ${reset_list}    Click Button    //deploy-plan-modal-component//ui-button[@a-text="Execute"]//button
    #Double check while delta commission will cause any reset.
    Return From Keyword If    not ${wait_until_finish}    ${warning_msg}
    Wait Until Keyword Succeeds    ${timeout}    10s    Element Should Contain    //deploy-plan-modal-component//div[@class="feedback-section"]
    ...    Operation finished successfully
    SBTS WEM Close BTS StartUp View    3s
    Comment    Click Button    //deploy-plan-modal-component//ui-button[@a-text="Close"]//button    #click close button to close pop-up window
    SBTS WEM Click Button Or Element    //deploy-plan-modal-component//ui-button[@a-text="Close"]//button
    ...    KW_checker=Wait Until WebElement Not Exist    param_checker=//deploy-plan-modal-component
    [Return]    ${warning_msg}

SBTS WEM Close Dialog After Activation
    [Arguments]    ${activate_should_be_successful}=${True}
    Wait Until WebElement Enabled With Attribute    //deploy-plan-modal-component//ui-button[@a-text="Close"]//button
    SBTS WEM Close BTS StartUp View    3s
    ${warning_msg}    Get Text    //deploy-plan-modal-component//div[@class="feedback-section"]//div[@aria-hidden="false"]
    Run Keyword If    ${activate_should_be_successful}    Should Contain    ${warning_msg}    Operation finished successfully
    Click Button    //deploy-plan-modal-component//ui-button[@a-text="Close"]//button    #click close button to close pop-up window
    [Return]    ${warning_msg}

SBTS WEM Reset SBTS
    [Arguments]    ${wait_reset_finish}=${True}
    SBTS WEM Open RunTime View
    Wait Until WebElement Exist    //ng-view//site-toolbar//reset-site-button//ui-button/button
    Click Button    //ng-view//site-toolbar//reset-site-button//ui-button/button
    Wait Until WebElement Exist    //common-modal[@modal-title="Reset Site"]//ui-button[@a-text="Reset"]/button
    Click Button    //common-modal[@modal-title="Reset Site"]//ui-button[@a-text="Reset"]/button
    Run Keyword If    '${wait_reset_finish}'=='${True}'    SBTS WEM Check SBTS Has Restarted Successful

SBTS WEM Get Configuration Errors
    [Arguments]    ${type}
    [Documentation]    ${type} should be one of HE/DE/RE
    SBTS WEM Open Configuration Manager    ${type}
    &{errors_dic}    Create Dictionary
    ${tmp1}    Set Variable    //ng-view//definition-errors-table | //ng-view//skipped-elements-table | //
    ${is_config_table_exist}    Run Keyword And Return Status    Wait Until Keyword Succeeds    10s    1s    Element Should Be Exist
    ...    ${tmp1}ng-view//parameter-validation-errors | //ng-view//global-validation-errors
    Return From Keyword If    not ${is_config_table_exist}    ${errors_dic}
    ${error_type_list}    Create List    definition-errors-table    skipped-elements-table    parameter-validation-errors
    ...    global-validation-errors
    FOR    ${error_type}    IN    @{error_type_list}
        ${is_error_exist}    Run Keyword And Return Status    Element Should Be Exist    //ng-view//${error_type}
        Continue For Loop If    not ${is_error_exist}
        ${table_xpath}    Set Variable    //ng-view//${error_type}//table
        ${table_contain}    SBTS WEM Get Configuration-table Data    ${table_xpath}
        ${data_count}    Get Length    ${table_contain}
        Continue For Loop If    '${data_count}'=='${0}'
        Set To Dictionary    ${errors_dic}    ${error_type}    ${table_contain}
    END
    Return From Keyword    ${errors_dic}
    [Return]    ${errors_dic}

SBTS WEM Get Configuration-table Data
    [Arguments]    ${table_xpath}
    [Documentation]    Get the data of table in current page after validation.
    ${table_data}    Create List
    ${is_data_exist}    Run Keyword And Return Status    Element Should Be Exist    ${table_xpath}/tbody/tr/td
    Return From Keyword If    not ${is_data_exist}    ${table_data}
    ${table_head_elements}    Get WebElements    ${table_xpath}/thead/tr[1]/th
    ${table_heads}    Create List
    FOR    ${element}    IN    @{table_head_elements}
        ${head_text}    Get Text    ${element}
        Append To List    ${table_heads}    ${head_text}
    END
    ${row_count}    Selenium2Library.Get Element Count    ${table_xpath}/tbody/tr
    FOR    ${index}    IN RANGE    ${1}    ${row_count}+1
        ${col_elements}    Get WebElements    ${table_xpath}/tbody/tr[${index}]/td
        Continue For Loop If    '${col_elements.__len__()}'!='${table_heads.__len__()}'
        ${row_dic}    Table Row Text To Dictionary    ${table_heads}    ${col_elements}
        Append To List    ${table_data}    ${row_dic}
    END
    [Return]    ${table_data}

SBTS WEM Get Cell Status
    [Arguments]    ${name_of_cell}
    [Documentation]    ${name_of_cell} should be name of Cell, returns dictionary of all states in "Status" visible in Detail Info Panel
    SBTS WEM Open RunTime View    C
    SBTS WEM Select Object On Navigation Panel Under Runtime View    ${name_of_cell}    ${name_of_cell.split('/')[-1]}
    SBTS WEM Expand Detail Panel
    Wait Until Element Is Visible    //details-panel//details-panel-content//hardware-details//li[@heading="Info"]    10s
    Click Element    //details-panel//details-panel-content//hardware-details//li[@heading="Info"]
    ${object_name}    Get Text    //details-panel//details-panel-content//hardware-details//div[contains(@class,"element-name")]
    #Should Be Equal As Strings    ${object_name}    ${name_of_cell.split('/')[-1]}
    Element Should Be Exist
    ...    //details-panel//details-panel-content//div[@common-section]//div[contains(@class,"details-info-name")]/div[text()="Status"]
    ${tmp1}    Set Variable    //details-panel//details-panel-content//div[@common-section]//div[contains(@class,"details-info-name")]/
    ${status_name_elements}    Get WebElements    ${tmp1}div[text()="Status"]/../..//td[contains(@class,"parameter-name")]
    ${tmp1}    Set Variable    //details-panel//details-panel-content//div[@common-section]//div[contains(@class,"details-info-name")]/
    ${status_value_elements}    Get WebElements    ${tmp1}div[text()="Status"]/../..//td[contains(@class,"parameter-value")]
    ${count}    Get Length    ${status_name_elements}
    &{cell_status}    Create Dictionary
    FOR    ${index}    IN RANGE    ${count}
        ${key}    Get Text    ${status_name_elements[${index}]}
        ${value}    Get Text    ${status_value_elements[${index}]}
        Set To Dictionary    ${cell_status}    ${key.replace(':','')}=${value}
    END
    ${tmp1}    Set Variable    //div[contains(@class,"cell-element-root")]//div[contains(@class,"cell-element-container")]//
    ${icon_elements}    Get WebElements    ${tmp1}span[@ui-tooltip="${object_name}"]/..//*[@title]
    ${infors}    Create List
    FOR    ${element}    IN    @{icon_elements}
        ${icon_title}    Selenium2Library.Get Element Attribute    ${element}    title
        Append To List    ${infors}    ${icon_title}
    END
    Set To Dictionary    ${cell_status}    icon titles    ${infors}
    [Return]    ${cell_status}

SBTS WEM Get RAT Status
    [Documentation]    Returns RAT status list as example:{'LTE': {'cell_state': 'Cells partially disabled',
    ...    'rat_state': 'On air','block_state'='Unblocked'}, 'WCDMA': {'cell_state': 'All cells enabled', 'rat_state': 'On air',
    ...    'block_state'='Unblocked'}, 'GSM': {'cell_state': 'No cells available', 'rat_state': 'Not commissioned','block_state'='Unblocked'},
    ...    'GSM': {'cell_state': 'No cells available', 'rat_state': 'Integrated to RAN','block_state'='Blocked'}}
    Wait Until WebElement Exist    //cells-status    2s    1s
    ${rat_count}    Selenium2Library.Get Element Count    //cells-status
    &{all_state}    Create Dictionary
    FOR    ${index}    IN RANGE    1    ${rat_count}+1
        ${rat_state}    Get Text    //cells-status[${index}]//div[contains(@class,"nbts-operational-state")]
        ${rat}    Get Text    //cells-status[${index}]//div[contains(@class,"cells-status-container")]/div[contains(@class,"cells-status-info")]
        ${cell_state}    Selenium2Library.Get Element Attribute
        ...    //cells-status[${index}]//div[contains(@class,"cells-status-container")]/div[contains(@class,"cells-status-svg")]    title
        &{status}    Create Dictionary
        ${is_rat_not_blocked}    Run Keyword And Return Status    Element Should Not Be Exist
        ...    //cells-status[${index}]//div[contains(@class,"cells-status-container")]//i[contains(@ui-tooltip,"blocked")]
        ${block_state}    Set Variable If    ${is_rat_not_blocked}    Unblocked    Blocked
        Set To Dictionary    ${status}    rat_state=${rat_state}    cell_state=${cell_state}    block_state=${block_state}
        Set To Dictionary    ${all_state}    ${rat}=${status}
    END
    [Return]    ${all_state}

SBTS WEM Get Alarms On Current Page
    [Arguments]    ${remove_appeared_time}=${True}
    ${is_no_alarms}    Run Keyword And Return Status    Element Should Contain
    ...    //ng-view//alarms-display//table/tbody/tr/td    No alarms available
    ${alarm_list}    Create List
    ${time}    Get Time    epoch
    Run Keyword If    ${is_no_alarms}    Capture Page Screenshot    ${time}.png
    Return From Keyword If    ${is_no_alarms}    ${alarm_list}
    ${alarm_field_elements}    Get WebElements    //ng-view//alarms-display//table/thead/tr/th/span[@class="ng-binding"]
    ${alarm_fields}    Create List
    FOR    ${element}    IN    @{alarm_field_elements}
        ${field}    Get Text    ${element}
        Append To List    ${alarm_fields}    ${field}
    END
    ${alarm_row_count}    Selenium2Library.Get Element Count    //ng-view//alarms-display//table/tbody/tr
    FOR    ${index}    IN RANGE    1    ${alarm_row_count+1}
        ${alarm_col_elements}    Get WebElements    //ng-view//alarms-display//table/tbody/tr[${index}]/td
        ${alarm}    Table Row Text To Dictionary    ${alarm_fields}    ${alarm_col_elements}
        ${alarm_severity}    Selenium2Library.Get Element Attribute
        ...    //ng-view//alarms-display//table/tbody/tr[${index}]/td[1]/alarm-bell-icon/div    title
        Set To Dictionary    ${alarm}    ${alarm_fields[0]}=${alarm_severity}
        Append To List    ${alarm_list}    ${alarm}
    END
    Return From Keyword If    '${remove_appeared_time}'=='False'    ${alarm_list}
    FOR    ${alarm}    IN    @{alarm_list}
        Remove From Dictionary    ${alarm}    Appeared
    END
    [Return]    ${alarm_list}

SBTS WEM Get Cell Link Path
    [Documentation]    return: list containing dictionaries of cell link path, dictionary as:
    ...    | key | value |
    ...    | parent-target | cell object path in runtime view |
    ...    | source | ant object path in runtime view |
    ...    | target | cell mapping \ object path in runtime view |
    ...
    ...    example:
    ...    [{'parent-target': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-3968/LNCEL_R-1', 'source':
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-2/ANTL_R-2', 'target':
    ...    '/MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1/CELL_M-1/CHANNEL_GROUP_M-1/CHANNEL_M-5'},
    ...    {'parent-target': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-3968/LNCEL_R-1', 'source':
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-2/ANTL_R-1', 'target':
    ...    '/MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1/CELL_M-1/CHANNEL_GROUP_M-1/CHANNEL_M-4'}]
    SBTS WEM Open RunTime View    SRV
    ${ret_cell_link_path_list}    Wait Until Keyword Succeeds    20s    1s    Get Cell Link Path
    LOG    ${ret_cell_link_path_list}
    ${wcdma_cell_mapping_pair}    SBTS WEM Get WCDMA Cell And Mapping Pairs
    &{wcdma_mapping_cell_pair}    Create Dictionary
    ${w_cells}    Get Dictionary Keys    ${wcdma_cell_mapping_pair}
    FOR    ${cell}    IN    @{w_cells}
        ${cell_mapping}    Fetch From Right    ${wcdma_cell_mapping_pair["${cell}"]}    /
        Set To Dictionary    ${wcdma_mapping_cell_pair}    ${cell_mapping}=${cell}
    END
    &{cell_name_mapping_dic}    Evaluate    {'LCELL_A':'LNCEL','LCELW_A':'WNCEL','CELL_M':'GNCEL','LCELNR_A':'NRCELL'}
    &{cell_mapping_mapping_dic}    Evaluate    {'LCELL_A':'LCELL','LCELW_A':'LCELW','CELL_M':'LCELC','LCELNR_A':'LCELNR'}
    FOR    ${cell_link_path}    IN    @{ret_cell_link_path_list}
        ${target}    Get From Dictionary    ${cell_link_path}    cell_mapping
        ${cell_inter_name}    Should Match Regexp    ${target}    LCELL_A-\\d+|LCELW_A-\\d+|CELL_M-\\d|LCELNR_A-\\d+
        ${cell_inter_type}    Fetch From Left    ${cell_inter_name}    -
        ${cell_inter_id}    Fetch From Right    ${cell_inter_name}    -
        ${cell_mapping_type}    Get From Dictionary    ${cell_mapping_mapping_dic}    ${cell_inter_type}
        ${cell_mapping}    Set Variable    ${cell_mapping_type}-${cell_inter_id}
        Set To Dictionary    ${cell_link_path}    cell_mapping=${cell_mapping}
        ${cell_type}    Get From Dictionary    ${cell_name_mapping_dic}    ${cell_inter_type}
        Set To Dictionary    ${cell_link_path}    cell=${cell_type}-${cell_inter_id}
        Continue For Loop If    '${cell_type}'!='WNCEL'
        Set To Dictionary    ${cell_link_path}    cell=${wcdma_mapping_cell_pair['${cell_mapping}']}
    END
    [Return]    ${ret_cell_link_path_list}

SBTS WEM Block One RAT
    [Arguments]    ${RAT}    ${check_result}=${True}
    SBTS WEM Open RunTime View
    Wait Until WebElement Exist    //site-runtime-views//rat-block-unblock//wf-dropdown//button
    SBTS WEM Click Button Or Element    //site-runtime-views//rat-block-unblock//wf-dropdown//button
    ...    KW_checker=Wait Until WebElement Exist    param_checker=//site-runtime-views//rat-block-unblock//wf-dropdown//ul[@aria-hidden="false"]
    SBTS WEM Click Button Or Element    //site-runtime-views//rat-block-unblock//wf-dropdown//ul//wf-dropdown-item//li[@title="Block ${RAT}"]
    ...    KW_checker=Wait Until WebElement Exist    param_checker=//common-modal[@modal-title="Block ${RAT}"]
    SBTS WEM Click Button Or Element    //common-modal[@modal-title="Block ${RAT}"]//ui-button[@a-text="Block"]/button
    ...    KW_checker=Wait Until WebElement Not Exist    param_checker=//common-modal[@modal-title="Block ${RAT}"]
    Return From Keyword If    not ${check_result}
    Wait Until Keyword Succeeds    300s    15s    SBTS WEM Check Rat Is Blocked    ${RAT}

SBTS WEM Unblock One RAT
    [Arguments]    ${RAT}    ${check_result}=${True}
    SBTS WEM Open RunTime View
    Wait Until WebElement Exist    //site-runtime-views//rat-block-unblock//wf-dropdown//button
    SBTS WEM Click Button Or Element    //site-runtime-views//rat-block-unblock//wf-dropdown//button
    ...    KW_checker=Wait Until WebElement Exist    param_checker=//site-runtime-views//rat-block-unblock//wf-dropdown//ul[@aria-hidden="false"]
    SBTS WEM Click Button Or Element    //site-runtime-views//rat-block-unblock//wf-dropdown//ul//wf-dropdown-item//li[@title="Unblock ${RAT}"]
    ...    KW_checker=Wait Until WebElement Exist    param_checker=//common-modal[@modal-title="Unblock ${RAT}"]
    SBTS WEM Click Button Or Element    //common-modal[@modal-title="Unblock ${RAT}"]//ui-button[@a-text="Unblock"]/button
    ...    KW_checker=Wait Until WebElement Not Exist    param_checker=//common-modal[@modal-title="Unblock ${RAT}"]
    Return From Keyword If    not ${check_result}
    Wait Until Keyword Succeeds    600s    30s    SBTS WEM Check Rat Is Unblocked    ${RAT}

SBTS WEM Check Rat Is Blocked
    [Arguments]    ${RAT}
    ${rat_status}    SBTS WEM Get RAT Status
    Should Be Equal As Strings    ${rat_status['${RAT}']['block_state']}    Blocked    ignore_case=True

SBTS WEM Check Rat Is Unblocked
    [Arguments]    ${RAT}
    ${rat_status}    SBTS WEM Get RAT Status
    Should Be Equal As Strings    ${rat_status['${RAT}']['block_state']}    Unblocked    ignore_case=True

SBTS WEM Block Cells
    [Arguments]    ${cell_name_list}    ${check_result}=${True}
    SBTS WEM Open RunTime View    C
    SBTS WEM Expand Navigation Panel
    SBTS WEM Expand Detail Panel
    FOR    ${cell}    IN    @{cell_name_list}
        SBTS WEM Select Object On Navigation Panel Under Runtime View    ${cell}    ${cell.split('/')[-1]}
        ${tmp1}    Set Variable    //details-panel//wf-panel//wf-panel-section//details-panel-content//hardware-details//
        ${block_able}    Run Keyword And Return Status    Element Should Be Exist
        ...    ${tmp1}div[@hardware-details-operations]//actions-buttons//ui-button[@a-title="Block Cell"]
        Continue For Loop If    not ${block_able}
        ${tmp1}    Set Variable    //details-panel//wf-panel//wf-panel-section//details-panel-content//hardware-details//
        SBTS WEM Click Button Or Element    ${tmp1}div[@hardware-details-operations]//actions-buttons//ui-button[@a-title="Block Cell"]/button
        ...    KW_checker=Wait Until WebElement Exist
        ...    param_checker=//common-modal[contains(@modal-title,"Block Cell")]//modal-footer//ui-button[@a-text="Block"]/button
        Click Button    //common-modal[contains(@modal-title,"Block Cell")]//modal-footer//ui-button[@a-text="Block"]/button
        Wait Until Element Is Not Visible    //common-modal[contains(@modal-title,"Block Cell")]    10s
        Comment    Wait Until WebElement Not Exist    //common-modal[contains(@modal-title,"Block Cell")]    10s    1s
    END
    Return From Keyword If    not ${check_result}
    FOR    ${cell}    IN    @{cell_name_list}
        SBTS WEM Select Object On Navigation Panel Under Runtime View    ${cell}    ${cell.split('/')[-1]}
        ${tmp1}    Set Variable    //details-panel//wf-panel//wf-panel-section//details-panel-content//hardware-details//
        Wait Until Keyword Succeeds    300s    10s    Element Should Be Exist
        ...    ${tmp1}div[@hardware-details-operations]//actions-buttons//ui-button[@a-title="Unblock Cell"]/button
    END

SBTS WEM Unblock Cells
    [Arguments]    ${cell_name_list}    ${check_result}=${True}
    SBTS WEM Open RunTime View    C
    SBTS WEM Expand Navigation Panel
    SBTS WEM Expand Detail Panel
    FOR    ${cell}    IN    @{cell_name_list}
        SBTS WEM Select Object On Navigation Panel Under Runtime View    ${cell}    ${cell.split('/')[-1]}
        ${tmp1}    Set Variable    //details-panel//wf-panel//wf-panel-section//details-panel-content//hardware-details//
        ${unblock_able}    Run Keyword And Return Status    Element Should Be Exist
        ...    ${tmp1}div[@hardware-details-operations]//actions-buttons//ui-button[@a-title="Unblock Cell"]/button
        Continue For Loop If    not ${unblock_able}
        ${tmp1}    Set Variable    //details-panel//wf-panel//wf-panel-section//details-panel-content//hardware-details//
        SBTS WEM Click Button Or Element    ${tmp1}div[@hardware-details-operations]//actions-buttons//ui-button[@a-title="Unblock Cell"]/button
        ...    KW_checker=Wait Until WebElement Exist
        ...    param_checker=//common-modal[contains(@modal-title,"Unblock Cell")]//modal-footer//ui-button[@a-text="Unblock"]/button
        Click Button    //common-modal[contains(@modal-title,"Unblock Cell")]//modal-footer//ui-button[@a-text="Unblock"]/button
        Wait Until Element Is Not Visible    //common-modal[contains(@modal-title,"Block Cell")]    5s
        Comment    Wait Until WebElement Not Exist    //common-modal[contains(@modal-title,"Unblock Cell")]    10s    1s
    END
    Return From Keyword If    not ${check_result}
    FOR    ${cell}    IN    @{cell_name_list}
       SBTS WEM Select Object On Navigation Panel Under Runtime View    ${cell}    ${cell.split('/')[-1]}
        ${tmp1}    Set Variable    //details-panel//wf-panel//wf-panel-section//details-panel-content//hardware-details//
        Wait Until Keyword Succeeds    300s    10s    Element Should Be Exist
        ...    ${tmp1}div[@hardware-details-operations]//actions-buttons//ui-button[@a-title="Block Cell"]
    END

SBTS WEM Set Cell EARFCN
    [Arguments]    ${Cell_Name}    ${Cell_Type}    ${FCN_UL}=${EMPTY}    ${FCN_DL}=${EMPTY}
    ${full_object_path}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    ${Cell_Name}    ${Cell_Type}-
    ${tmp1}    Set Variable    {"LNCEL_FDD":["EARFCN downlink","EARFCN uplink"],"NBIOT_FDD":["NB-IoT standalone EARFCN Downlink",
    ${tmp2}    Set Variable    "NB-IoT standalone EARFCN Uplink"],"WNCEL":["Default carrier","Default carrier"]}
    &{para_name_dic}    Evaluate    ${tmp1}${tmp2}
    ${para}    Get From Dictionary    ${para_name_dic}    ${Cell_Type}
    Run Keyword If    "${FCN_DL}"!=""    SBTS WEM Modify Parameters In PE Table    ${full_object_path}    ${para[0]}    ${FCN_DL}
    Return From Keyword If    "WNCEL"=="${Cell_Type}"
    Run Keyword If    "${FCN_UL}"!=""    SBTS WEM Modify Parameters In PE Table    ${full_object_path}    ${para[1]}    ${FCN_UL}

SBTS WEM Set WCDMA Cell UARFCN
    [Arguments]    ${cell_name}    ${fcn}
    SBTS WEM Open Configure In Commissioning Wizard
    SBTS WEM Select Object On Commissioning Wizard Configure Popup    Cells/Carriers\\Carriers\\WCDMA
    Wait Until Keyword Succeeds    10s    1s    Element Should Be Exist
    ...   //div[@uib-modal-transclude]//wizard-steps-modal-body//generic-step-renderer//div[@class="wizard-step-container"]//table
    ${cell_name_elements}    Get WebElements
    ...    //div[@uib-modal-transclude]//wizard-steps-modal-body//generic-step-renderer//div[@class="wizard-step-container"]//table/tbody/tr/td[1]
    ${index}    Set Variable    ${0}
    ${count}    Get Length    ${cell_name_elements}
    FOR    ${index}    IN RANGE    0    ${count}
        ${cell}    Get Text    ${cell_name_elements[${index}]}
        Exit For Loop If    '${cell}'=='${cell_name}'
    END
    ${tmp1}    Set Variable    //div[@uib-modal-transclude]//wizard-steps-modal-body//generic-step-renderer//
    ${tmp2}    Set Variable    div[@class="wizard-step-container"]//table/tbody/tr[${index+1}]/td[5]//input
    Input Text    ${tmp1}${tmp2}    ${fcn}
    Click Button    //div[@uib-modal-transclude]//wizard-steps-modal-footer//div[@class="right-buttons"]//ui-button[@a-text="Done"]/button

SBTS WEM Remove GSM Cell By Name
    [Arguments]    ${cell_name}    ${delete_cell_mapping_automatic}=${False}    ${tree_name}=Current BTS configuration
    ${removed_MO_path}    Create Dictionary
    ${cell_path}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    ${cell_name}    ${cell_name.split('/')[-1]}
    SBTS WEM Filt Parameter    form_param_name=LCELC Identifier
    ${parameters}    SBTS WEM Get Parameters In PE Table
    Should Be Equal As Integers    ${parameters.__len__()}    ${1}
    ${lcelcId}    Set Variable    ${parameters[0]['actual_value']}
    SBTS WEM Remove Object On Navigation Panel Under Pramater Editor    ${cell_path}    ${cell_name}    ${tree_name}
    Set To Dictionary    ${removed_MO_path}    cell=${cell_path}
    Return From Keyword If    not ${delete_cell_mapping_automatic}    ${removed_MO_path}
    ${cellMapping_path}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    LCELC-${lcelcId}    LCELC-${lcelcId}
    SBTS WEM Remove Object On Navigation Panel Under Pramater Editor    ${cellMapping_path}    ${cellMapping_path.split('/')[-1]}    ${tree_name}
    Set To Dictionary    ${removed_MO_path}    cellMapping=${cellMapping_path}
    ${param}    Create Dictionary    LCELC Identifier=${lcelcId}
    Set To Dictionary    ${removed_MO_path}    ${cell_path}=${param}
    [Return]    ${removed_MO_path}

SBTS WEM Remove WCMD Cell By Name
    [Arguments]    ${cell_name}    ${delete_cell_mapping_automatic}=${False}    ${tree_name}=Current BTS configuration
    ${removed_MO_path}    Create Dictionary
    ${cell_path}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    ${cell_name}    ${cell_name.split('/')[-1]}
    SBTS WEM Remove Object On Navigation Panel Under Pramater Editor    ${cell_path}    ${cell_name}    ${tree_name}
    ${wcell_group_object_path}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    WNCELG-    WNCELG-    ${tree_name}
    SBTS WEM Filt Parameter    ${None}    Local cell identifier list
    ${params}    SBTS WEM Get Parameters In PE Table
    ${cell_id}    Fetch From Right    ${cell_name}    -
    ${sub_item_name}    Set Variable
    FOR    ${param}    IN    @{params}
        ${sub_item_name}    Set Variable If    "${cell_id}"=="${param['actual_value']}"    ${param['list_lable']}    ${EMPTY}
        Exit For Loop If    "${cell_id}"=="${param['actual_value']}"
    END
    Run Keyword If    '${sub_item_name}'==''    Fail    Cannot find the WCell Group identifier
    ${succeed}    SBTS WEM Click Action In PE Table    ${wcell_group_object_path}    Local cell identifier list
    ...    Remove Element    ${sub_item_name}    ${tree_name}
    Should Be True    ${succeed}
    Set To Dictionary    ${removed_MO_path}    cell=${cell_path}
    Return From Keyword If    not ${delete_cell_mapping_automatic}    ${removed_MO_path}
    ${cell_and_cell_mapping_pair_dic}    SBTS WEM Get WCDMA Cell And Mapping Pairs
    ${cellMapping_path}    Get From Dictionary    ${cell_and_cell_mapping_pair_dic}    ${cell_name}
    Comment    ${cell_mapping_name}    Set Variable    LCELW-${cell_id}
    SBTS WEM Remove Object On Navigation Panel Under Pramater Editor    ${cellMapping_path}    ${cellMapping_path.split('/')[-1]}    ${tree_name}
    Set To Dictionary    ${removed_MO_path}    cellMapping=${cellMapping_path}
    [Return]    ${removed_MO_path}

SBTS WEM Remove LTE Cell By Name
    [Arguments]    ${cell_name}    ${delete_cell_mapping_automatic}=${False}    ${tree_name}=Current BTS configuration
    ${removed_MO_path}    Create Dictionary
    ${cell_path}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    ${cell_name}    ${cell_name.split('/')[-1]}
    SBTS WEM Filt Parameter    form_param_name=Local cell resource ID    form_abbreviation=lcrId
    ${parameters}    SBTS WEM Get Parameters In PE Table
    Should Be Equal As Integers    ${parameters.__len__()}    ${1}
    ${lcrId}    Set Variable    ${parameters[0]['actual_value']}
    SBTS WEM Remove Object On Navigation Panel Under Pramater Editor    ${cell_path}    ${cell_name}    ${tree_name}
    Set To Dictionary    ${removed_MO_path}    cell=${cell_path}
    Return From Keyword If    not ${delete_cell_mapping_automatic}    ${removed_MO_path}
    ${cellMapping_path}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    LCELL-${lcrId}    LCELL-${lcrId}
    Set To Dictionary    ${removed_MO_path}    cellMapping=${cellMapping_path}
    SBTS WEM Remove Object On Navigation Panel Under Pramater Editor    ${cellMapping_path}    ${cellMapping_path.split('/')[-1]}    ${tree_name}
    [Return]    ${removed_MO_path}

SBTS WEM Remove NR Cell By Name
    [Arguments]    ${cell_name}    ${delete_cell_mapping_automatic}=${False}    ${tree_name}=Current BTS configuration
    ${removed_MO_path}    Create Dictionary
    ${cell_path}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    ${cell_name}    ${cell_name.split('/')[-1]}
    SBTS WEM Filt Parameter    form_param_name=Local cell resource ID    form_abbreviation=lcrId
    ${parameters}    SBTS WEM Get Parameters In PE Table
    Should Be Equal As Integers    ${parameters.__len__()}    ${1}
    ${lCelnrId}    Set Variable    ${parameters[0]['actual_value']}
    SBTS WEM Remove Object On Navigation Panel Under Pramater Editor    ${cell_path}    ${cell_name}    ${tree_name}
    Set To Dictionary    ${removed_MO_path}    cell=${cell_path}
    Return From Keyword If    not ${delete_cell_mapping_automatic}    ${removed_MO_path}
    ${cellMapping_path}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    LCELNR-${lCelnrId}    LCELNR-${lCelnrId}
    ${MOs}    Get Objects By Condition    MRBTS/NRBTS/NRCELLGRP[List of NR cells assigned to cell group(!)#1=${lCelnrId}]
    ${cell_group_path}    Set Variable    ${MOs[0]}
    ${cell_group_id}    Set Variable    ${cell_group_path.split('/')[-1].split('-')[-1]}
    SBTS WEM Remove Object On Navigation Panel Under Pramater Editor    ${cellMapping_path}    ${cellMapping_path.split('/')[-1]}    ${tree_name}
    SBTS WEM Remove Object On Navigation Panel Under Pramater Editor    ${cell_group_path}    ${cell_group_path.split('/')[-1]}    ${tree_name}
    ${nrdu}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    NRDU-    NRDU-
    SBTS WEM Filt Parameter    form_param_name=Reference to cell group
    ${parameters}    SBTS WEM Get Parameters In PE Table
    ${sub_item_name}    Set Variable
    FOR    ${param}    IN    @{parameters}
        ${sub_item_name}    Set Variable If    "${cell_group_id}"=="${param['actual_value']}"    ${param['list_lable']}    ${EMPTY}
        Exit For Loop If    "${cell_group_id}"=="${param['actual_value']}"
    END
    Run Keyword If    '${sub_item_name}'==''    Fail    Cannot find the Reference to cell group
    ${succeed}    SBTS WEM Click Action In PE Table    ${nrdu}    Reference to cell group    Remove Element    ${sub_item_name}
    Should Be True    ${succeed}
    Set To Dictionary    ${removed_MO_path}    cellMapping=${cellMapping_path}    cellGroup=${cell_group_path}
    [Return]    ${removed_MO_path}

SBTS WEM Remove Cell By Name
    [Arguments]    ${cell_name}    ${delete_cell_mapping_automatic}=${False}
    ${cell_type}    Fetch From Left    ${cell_name}    -
    ${tmp1}    Set Variable    {'LNCEL':'SBTS WEM Remove LTE Cell By Name','WNCEL':'SBTS WEM Remove WCMD Cell By Name',
    ${tmp2}    Set Variable    'GNCEL':'SBTS WEM Remove GSM Cell By Name','NRCELL':'SBTS WEM Remove NR Cell By Name'}
    &{KW_mapping}    Evaluate    ${tmp1}${tmp2}
    ${KW}    Get From Dictionary    ${KW_mapping}    ${cell_type}
    ${removed_MO_path}    Run Keyword    ${KW}    ${cell_name}    ${delete_cell_mapping_automatic}
    [Return]    ${removed_MO_path}

SBTS WEM Get All Cell Name
    SBTS WEM Open RunTime View    C
    ${cell_name_list}    Create List
    ${count}    Selenium2Library.Get Element Count
    ...    //ng-view//div[@cell-element]//div[contains(@class,"cell-element-container")]//span[contains(@class,"cell-element-name")]
    Return From Keyword If    ${count}==${0}    ${cell_name_list}
    ${elements}    Get WebElements
    ...    //ng-view//div[@cell-element]//div[contains(@class,"cell-element-container")]//span[contains(@class,"cell-element-name")]
    FOR    ${element}    IN    @{elements}
        ${name}    Get Text    ${element}
        Append To List    ${cell_name_list}    ${name}
    END
    [Return]    ${cell_name_list}

SBTS WEM Get NR Cell Of NR Cell Group
    [Arguments]    ${nrcellgrp_mo}
    ${nr_cell_mo_list}    Create List
    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    ${nrcellgrp_mo}    ${nrcellgrp_mo.split('/')[-1]}
    SBTS WEM Filt Parameter    form_param_name=List of NR cells assigned to cell group
    ${parameters}    SBTS WEM Get Parameters In PE Table
    FOR    ${param}    IN    @{parameters}
        Continue For Loop If    "${param['list_lable']}" == "None" or "${param['actual_value']}" == "None"
        ${cell_mo_list}    Get Objects By Condition    MRBTS/NRBTS/NRCELL[Local cell resource ID=${param['actual_value']}]
        Continue For Loop If    '${cell_mo_list.__len__()}'=='${0}'
        Append To List    ${nr_cell_mo_list}    @{cell_mo_list}
    END
    [Return]    ${nr_cell_mo_list}

SBTS WEM Get Name Of All Blocked Cells
    SBTS WEM Open RunTime View    C
    ${blocked_cell_name_list}    Create List
    ${tmp1}    Set Variable
    ...    //ng-view//div[@cell-element]//div[contains(@class,"cell-element-container") and contains(@class,"cell-element-offline-cell")]//
    ${count}    Selenium2Library.Get Element Count
    ...    ${tmp1}span[contains(@class,"cell-element-name")]
    Return From Keyword If    ${count}==${0}    ${blocked_cell_name_list}
    ${tmp1}    Set Variable
    ...    //ng-view//div[@cell-element]//div[contains(@class,"cell-element-container") and contains(@class,"cell-element-offline-cell")]//
    ${elemetns}    Get WebElements    ${tmp1}span[contains(@class,"cell-element-name")]
    FOR    ${element}    IN    @{elemetns}
        ${name}    Get Text    ${element}
        Append To List    ${blocked_cell_name_list}    ${name}
    END
    [Return]    ${blocked_cell_name_list}

SBTS WEM Get Name Of All Unblocked Cells
    SBTS WEM Open RunTime View    C
    ${unblocked_cell_name_list}    Create List
    ${tmp1}    Set Variable
    ...    //ng-view//div[@cell-element]//div[contains(@class,"cell-element-container") and contains(@class,"cell-element-online-cell")]//
    ${count}    Selenium2Library.Get Element Count
    ...    ${tmp1}span[contains(@class,"cell-element-name")]
    Return From Keyword If    ${count}==${0}    ${unblocked_cell_name_list}
    ${tmp1}    Set Variable
    ...    //ng-view//div[@cell-element]//div[contains(@class,"cell-element-container") and contains(@class,"cell-element-online-cell")]//
    ${elemetns}    Get WebElements    ${tmp1}span[contains(@class,"cell-element-name")]
    FOR    ${element}    IN    @{elemetns}
        ${name}    Get Text    ${element}
        Append To List    ${unblocked_cell_name_list}    ${name}
    END
    [Return]    ${unblocked_cell_name_list}

SBTS WEM Get Configuration Names
    [Arguments]    ${conf_set}
    ${conf_name_list}    Create List
    SBTS WEM Expand Configuration Tree On Navigation Panel Under Pramater Editor    ${conf_set}
    Wait Until WebElement Exist    //global-search//execution-bar//ui-button[@a-title="Collapse all"]/button
    Comment    Click Button    //global-search//execution-bar//ui-button[@a-title="Collapse all"]/button
    ${count}    Selenium2Library.Get Element Count
    ...    //global-search//global-search-tab-content/pe-global-search-objects//div[@class="tree-list-body"]//li
    Return From Keyword If    '${count}'=='0'    ${conf_name_list}
    FOR    ${index}    IN RANGE    1    ${count}+1
        ${name}    Get Text
        ...    //global-search//global-search-tab-content/pe-global-search-objects//div[@class="tree-list-body"]//li[${index}]//highlighter/span
        Append To List    ${conf_name_list}    ${name}
    END
    [Return]    ${conf_name_list}

SBTS WEM Get Parameter Name By Abbreviation
    [Arguments]    ${object}    ${abbreviation_name}    ${tree_name}=Current BTS configuration
    ${filter}    Fetch From Right    ${object}    /
    ${is_object_selected}    Check If Object Selected On Navigation Panel Under Pramater Editor    ${object}
    Run Keyword Unless    ${is_object_selected}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor
    ...    ${object}    ${filter}    ${tree_name}
    SBTS WEM Filt Parameter    form_abbreviation=${abbreviation_name}
    ${param_list}    SBTS WEM Get Parameters In PE Table
    ${count}    Get Length    ${param_list}
    Should Be Equal As Integers    ${count}    ${1}    More then one or none parameter is mapped by ${abbreviation_name} of ${object}
    ${parameter_name}    Set Variable    ${param_list[0]['full_name']}
    [Return]    ${parameter_name}

SBTS WEM Get Parameters Of Deleting Objects
    [Arguments]    ${eliminate_obj_str}=${EMPTY}    ${param_dic}=${EMPTY}
    ${tmp1}    Set Variable    //global-search//ui-expandable-panel-body//li//pe-global-search-row//
    ${elements}    Get WebElements    ${tmp1}i[@ng-if="isDeleted(row)" or @ng-if="isDeleted()"]/../span[@aria-label]
    ${tmp_dic}    Create Dictionary
    ${is_empty}    Run Keyword And Return Status    Should Be Empty    ${param_dic}
    ${param_dic}    Set Variable If    ${is_empty}    ${tmp_dic}    ${param_dic}
    FOR    ${element}    IN    @{elements}
        Click Element    ${element}
        ${object_path}    Get Text
        ...    //ng-view//wf-panel-section//parameters-editor//div[contains(@class,"pe-middle-panel-header-inner-margin")]//small
        ${tmp_str_list}    Run Keyword If    '${eliminate_obj_str}'!=''    Get Regexp Matches    ${object_path}    ${eliminate_obj_str}
        ${count}    Run Keyword If    '${eliminate_obj_str}'!=''    Get Length    ${tmp_str_list}
        Continue For Loop If    '${count}'!='0' and '${count}'!='None'
        ${param}    SBTS WEM Get Parameters In PE table
        Set To Dictionary    ${param_dic}    ${object_path}=${param}
    END
    [Return]    ${param_dic}

SBTS WEM Get Parameters Of One Object
    [Arguments]    ${object}    ${parameter_full_name_list}    ${tree_name}=Current BTS configuration
    ${filter}    Fetch From Right    ${object}    /
    ${is_object_selected}    Check If Object Selected On Navigation Panel Under Pramater Editor    ${object}
    Run Keyword Unless    ${is_object_selected}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor
    ...    ${object}    ${filter}    ${tree_name}
    &{target_param_dic}    Create Dictionary
    FOR    ${parameter_full_name}    IN    @{parameter_full_name_list}
        ${full_name}    Fetch From Left    ${parameter_full_name}    (!)
        ${list_lable}    Fetch From Right    ${parameter_full_name}    (!)
        ${list_lable}    Set Variable If    '${list_lable}'!='${parameter_full_name}'    ${list_lable}    ${None}
        SBTS WEM Filt Parameter    form_param_name=${full_name}
        ${param_list}    SBTS WEM Get Parameters In PE Table
        Set Parameter To Dictionary Matching By Name    ${target_param_dic}    ${full_name}    ${list_lable}    ${param_list}
        Continue For Loop
        ${count}    Get Length    ${param_list}
        Run Keyword If    '${count}'!='${0}'    Set Parameter To Dictionary Matching By Name    ${target_param_dic}    ${full_name}    ${list_lable}
        ...    ${param_list}
        Continue For Loop If    '${count}'!='${0}'
        #Try to get parameter by Abbreviation again
        ${param_full_name_corrected}    SBTS WEM Get Parameter Name By Abbreviation    ${object}    ${parameter_full_name}
        SBTS WEM Filt Parameter    form_param_name=${param_full_name_corrected}
        ${param_list}    SBTS WEM Get Parameters In PE Table
        Set Parameter To Dictionary Matching By Name    ${target_param_dic}    ${param_full_name_corrected}    ${list_lable}    ${param_list}
    END
    [Return]    ${target_param_dic}

SBTS WEM Create Configuration Plan
    [Arguments]    ${name_of_plan}    ${copy_from_plan_name}=CURRENT_BTS_CONF-1
    SBTS WEM Open Configuration Manager    PE
    Wait Until WebElement Exist    //ng-view//create-configuration-button    30s    3s
    Wait Until Keyword Succeeds    30s    5s    Element Should Be Enabled With Attribute    //ng-view//create-configuration-button
    Click Button    //ng-view//create-configuration-button//button
    Wait Until WebElement Exist    //create-configuration-modal-renderer    20s    2s
    Input Text    //create-configuration-modal-renderer//li[contains(@class,"new-configuration-name-complex")]//input    ${name_of_plan}
    ${flag}    Set Variable If    "${copy_from_plan_name}"!=""    1    0
    FOR    ${index}    IN RANGE    0    ${flag}
        Click Element    //create-configuration-modal-renderer//li[contains(@class,"copy-configuration-complex")]//span
        sleep    1s
        Click Element    //create-configuration-modal-renderer//li[contains(@class,"copy-configuration-complex")]//button
        sleep    1s
        ${tmp1}    Set Variable    //create-configuration-modal-renderer//li[contains(@class,"copy-configuration-complex")]//
        Click Element    ${tmp1}wf-dropdown-item//li[@data-value="${copy_from_plan_name}"]//span
        sleep    1s
    END
    Click Button    //create-configuration-modal-renderer//div[@class="modal-footer"]//ui-button[@a-text="Create"]/button

SBTS WEM Lock Units
    [Arguments]    ${unit_name_list}
    SBTS WEM Open RunTime View    SV
    SBTS WEM Expand Navigation Panel
    SBTS WEM Expand Detail Panel
    FOR    ${unit}    IN    @{unit_name_list}
        SBTS WEM Select Object On Navigation Panel Under Runtime View    ${unit}    ${unit}
        ${block_able}    Run Keyword And Return Status    Wait Until WebElement Exist
        ...    //div[@class="header"]//div[@hardware-details-operations]//actions-buttons//ui-button[@a-title="Lock"]
        Continue For Loop If    not ${block_able}
        SBTS WEM Click Button Or Element
        ...    //div[@class="header"]//div[@hardware-details-operations]//actions-buttons//ui-button[@a-title="Lock"]/button
        ...    KW_checker=Wait Until WebElement Exist
        ...    param_checker=//common-modal[contains(@modal-title,"Lock")]//modal-footer//ui-button[@a-text="Lock"]/button
        Click Button    //common-modal[contains(@modal-title,"Lock")]//modal-footer//ui-button[@a-text="Lock"]/button
        Wait Until Keyword Succeeds    300s    10s    Element Should Be Exist
        ...    //div[@class="header"]//div[@hardware-details-operations]//actions-buttons//ui-button[@a-title="Unlock"]
    END
    Return From Keyword
    FOR    ${unit}    IN    @{unit_name_list}
        SBTS WEM Select Object On Navigation Panel Under Runtime View    ${unit}    ${unit}
        Wait Until Keyword Succeeds    300s    10s    Element Should Be Exist
        ...    //div[@class="header"]//div[@hardware-details-operations]//actions-buttons//ui-button[@a-title="Unlock"]
    END

SBTS WEM Unlock Units
    [Arguments]    ${unit_name_list}
    SBTS WEM Open RunTime View    SV
    SBTS WEM Expand Navigation Panel
    SBTS WEM Expand Detail Panel
    FOR    ${unit}    IN    @{unit_name_list}
        SBTS WEM Select Object On Navigation Panel Under Runtime View    ${unit}    ${unit}
        ${unblock_able}    Run Keyword And Return Status    Wait Until WebElement Exist
        ...    //div[@class="header"]//div[@hardware-details-operations]//actions-buttons//ui-button[@a-title="Unlock"]
        Continue For Loop If    not ${unblock_able}
        SBTS WEM Click Button Or Element
        ...    //div[@class="header"]//div[@hardware-details-operations]//actions-buttons//ui-button[@a-title="Unlock"]/button
        ...    KW_checker=Wait Until WebElement Exist
        ...    param_checker=//common-modal[contains(@modal-title,"Unlock")]//modal-footer//ui-button[@a-text="Unlock"]/button
        Click Button    //common-modal[contains(@modal-title,"Unlock")]//modal-footer//ui-button[@a-text="Unlock"]/button
        Wait Until Keyword Succeeds    300s    10s    Element Should Be Exist
        ...    //div[@class="header"]//div[@hardware-details-operations]//actions-buttons//ui-button[@a-title="Lock"]
    END
    Return From Keyword
    FOR    ${unit}    IN    @{unit_name_list}
        SBTS WEM Select Object On Navigation Panel Under Runtime View    ${unit}    ${unit}
        Wait Until Keyword Succeeds    300s    10s    Element Should Be Exist
        ...    //div[@class="header"]//div[@hardware-details-operations]//actions-buttons//ui-button[@a-title="Lock"]
    END

SBTS WEM Handle Conflicting Commissioning Data
    [Arguments]    ${operation}=Frozen Mode
    [Timeout]    3 minutes
    ${is_conflics}    Run Keyword And Return Status    Element Should Be Exist
    ...    //runtime-configuration-conflicts-modal-renderer/ui-modal[@a-title="Conflicting Commissioning Data"]
    Return From Keyword If    ${is_conflics}
    ${tmp1}    Set Variable    //runtime-configuration-conflicts-modal-renderer/
    Click Button    ${tmp1}ui-modal[@a-title="Conflicting Commissioning Data"]//ui-button[@a-text="${operation}"]/button
    Run Keyword If    '${operation}'=='Frozen Mode'    Wait Until WebElement Exist
    ...    //ng-view/configuration//wf-panel/wf-panel-header//*[@title="Frozen Mode activated"]
    Return From Keyword If    '${operation}'=='Save SCF'
    Element Should Not Be Exist    //runtime-configuration-conflicts-modal-renderer/ui-modal[@a-title="Conflicting Commissioning Data"]

SBTS WEM Get Cell id
    [Arguments]    ${name_of_cell}
    SBTS WEM Open RunTime View    C
    SBTS WEM Select Object On Navigation Panel Under Runtime View    ${name_of_cell}    ${name_of_cell}
    SBTS WEM Expand Detail Panel
    Wait Until Element Is Visible    //details-panel//details-panel-content//hardware-details//li[@heading="Info"]    10s
    Click Element    //details-panel//details-panel-content//hardware-details//li[@heading="Info"]
    ${object_name}    Get Text    //details-panel//details-panel-content//hardware-details//div[contains(@class,"element-name")]
    Should Be Equal As Strings    ${object_name}    ${name_of_cell}
    Element Should Be Exist    //details-panel//details-panel-content//div[@common-section]//table[contains(@class,"details-info-table")]
    ${tmp1}    Set Variable    //details-panel//details-panel-content//div[@common-section]//table[contains(@class,"details-info-table")]//
    ${cellid_name_elements}    Get WebElements    ${tmp1}td[contains(@class,"parameter-name ng-binding")]
    ${tmp1}    Set Variable    //details-panel//details-panel-content//div[@common-section]//table[contains(@class,"details-info-table")]//
    ${cellid_value_elements}    Get WebElements    ${tmp1}td[contains(@class,"parameter-value ng-binding")]
    ${count}    Get Length    ${cellid_name_elements}
    &{cell_ids}    Create Dictionary
    FOR    ${index}    IN RANGE    ${count}
        ${key}    Get Text    ${cellid_name_elements[${index}]}
        ${value}    Get Text    ${cellid_value_elements[${index}]}
        Set To Dictionary    ${cell_ids}    ${key}=${value}
    END
    ${cell_type}    Fetch From Left    ${name_of_cell}    -
    ${cell_id}    Set Variable If    '${cell_type}'== 'GNCEL'    ${cell_ids['GSM sector ID:']}
    Return From Keyword If    '${cell_type}'== 'GNCEL'    ${cell_id}
    ${cell_id}    Set Variable If    '${cell_type}'== 'WNCEL'    ${cell_ids['Cell ID:']}
    Return From Keyword If    '${cell_type}'== 'WNCEL'    ${cell_id}
    ${cell_id}    Set Variable If    '${cell_type}'=='LNCEL'    ${cell_ids['E-UTRAN cell ID:']}
    Return From Keyword If    '${cell_type}'=='LNCEL'    ${cell_id}
    [Return]    ${cell_id}

SBTS WEM Update Service Account Password
    [Arguments]    ${user}    ${old_pwd}    ${new_pwd}
    ${ret_msg}    Set Variable
    Wait Until WebElement Exist    //main-view//app-header//div[@class="right-side"]//user-account-management/nav-item/div[@role="menu"]
    SBTS WEM Click Button Or Element    //main-view//app-header//div[@class="right-side"]//user-account-management/nav-item/div[@role="menu"]
    ${tmp1}    Set Variable    //main-view//app-header//div[@class="right-side"]//user-account-management/
    SBTS WEM Click Button Or Element    ${tmp1}nav-item/div[@role="menu"]//ui-button[@a-text="User Account Management"]/button
    Wait Until WebElement Exist    //common-modal//h4[@title="User Account Management"]
    SBTS WEM Click Button Or Element    //common-modal//uam-modal-body//li/a[text()="Service Account Management"]
    Wait Until Page Contains Element    id:uam-service-user-name    10s
    Input Text    id:uam-service-user-name    ${user}
    Input Text    id:uam-service-old-password    ${old_pwd}
    Input Text    id:uam-service-new-password    ${new_pwd}
    Input Text    id:uam-service-confirm-password    ${new_pwd}
    Element Should Be Enabled With Attribute    //common-modal//uam-modal-footer//ui-button[@a-text="Save"]//button
    SBTS WEM Click Button Or Element    //common-modal//uam-modal-footer//ui-button[@a-text="Save"]//button
    ${tmp1}    Set Variable    //common-modal//uam-validation-message//span[contains(@class,"uam-validation-message")]/
    Wait Until WebElement Exist    ${tmp1}i[contains(@class,"icon-error") or contains(@class,"icon-ok")]
    ${ret_msg}    Selenium2Library.Get Text    //common-modal//uam-validation-message//span[contains(@class,"uam-validation-message")]
    [Teardown]    SBTS WEM Click Button Or Element    //common-modal//uam-modal-footer//ui-button[@a-text="Close"]//button
    [Return]    ${ret_msg}

SBTS WEM Oper NG-Link
    [Arguments]    ${oper}    ${need_check}=${True}
    SBTS WEM Open RunTime View    SV
    Wait Until Element Is Visible    //site-runtime-views//execution-bar//ng-links//wf-dropdown//button[@aria-expanded="false"]
    SBTS WEM Click Button Or Element    //site-runtime-views//execution-bar//ng-links//wf-dropdown//button[@aria-expanded="false"]    3    1s
    ...    Wait Until Element Is Visible    //site-runtime-views//execution-bar//ng-links//wf-dropdown-item/li/a/span[text()="${oper}"]
    SBTS WEM Click Button Or Element    //site-runtime-views//execution-bar//ng-links//wf-dropdown-item/li/a/span[text()="${oper}"]    3    1s
    ...    Wait Until Element Is Visible    //common-modal[@modal-title="${oper} all NG links"]//ui-button[@a-text="${oper}"]/button
    SBTS WEM Click Button Or Element    //common-modal[@modal-title="${oper} all NG links"]//ui-button[@a-text="${oper}"]/button    3    1s
    ...    Wait Until Element Is Not Visible    //common-modal[@modal-title="${oper} all NG links"]
    Run Keyword If    ${need_check}    Wait Until WebElement Enabled With Attribute
    ...    //site-runtime-views//execution-bar//ng-links//wf-dropdown//button

SBTS WEM Get Selected MO States On SiteView
    ${count}    Selenium2Library.Get Element Count    //site-runtime-views//div[contains(@class,"selected")]
    Should Be Equal As Integers    ${count}    ${1}
    ${icon_titles}    Create List
    ${elements}    Selenium2Library.Get WebElements    //site-runtime-views//div[contains(@class,"selected")]//div[@class="block-icons"]//*[@title]
    FOR    ${element}    IN    @{elements}
        ${icon_title}    Selenium2Library.Get Element Attribute    ${element}    title
        Append To List    ${icon_titles}    ${icon_title}
    END
    ${tmp1}    Set Variable    //site-runtime-views//div[contains(@class,"selected")]//div[@class="block-icons"]//
    ${count_barred_icon}    Selenium2Library.Get Element Count    ${tmp1}*[name()="svg"]/*[name()="title" and text()="Cell Barred"]
    ${tmp1}    Set Variable    //site-runtime-views//div[contains(@class,"selected")]//div[@class="block-icons"]//
    ${count_Massive_MIMO_icon}    Selenium2Library.Get Element Count    ${tmp1}*[name()="svg"]/*[name()="title" and text()="Massive MIMO"]
    Run Keyword If    ${count_barred_icon}    Append To List    ${icon_titles}    Cell Barred
    Run Keyword If    ${count_Massive_MIMO_icon}    Append To List    ${icon_titles}    Massive MIMO
    [Return]    ${icon_titles}

SBTS WEM Get All Cell States On SiteView
    SBTS WEM Open RunTime View    SV
    ${elements_expanded_cell_block}    Get WebElements    //site-runtime-views//div[@class="multi-cell-block"]/div[contains(@class,"cell-block")]
    ${dic_all_cell_param}    Create Dictionary
    FOR    ${element}    IN    @{elements_expanded_cell_block}
        Click Element    ${element}
        ${dic_param}    SBTS WEM Get Detail Info On RuntimeView
        ${icon_titles}    SBTS WEM Get Selected MO States On SiteView
        Set To Dictionary    ${dic_param}    icon titles    ${icon_titles}
        ${cell_name}    Get From Dictionary    ${dic_param}    Cell name:
        Set To Dictionary    ${dic_all_cell_param}    ${cell_name}    ${dic_param}
    END
    Log Dictionary    ${dic_all_cell_param}
    [Return]    ${dic_all_cell_param}

SBTS WEM Get All Cell States On DetailedSiteView
    SBTS WEM Open RunTime View    SRV
    ${elements_of_cell}    Selenium2Library.Get WebElements    //site-runtime-views//div[@class="cell-row"]/div[@distname]
    ${dic_cell_states}    Create Dictionary
    FOR    ${element}    IN    @{elements_of_cell}
        ${dn}    Selenium2Library.Get Element Attribute    ${element}    distname
        ${tmp1}    Set Variable    //site-runtime-views//div[@class="cell-row"]/div[@distname="${dn}"]//span[contains(@class,"text")]
        ${tmp2}    Set Variable   //site-runtime-views//div[@class="cell-row"]/div[@distname="${dn}" and contains(@class,"nbiot-cell")]//span[@title]
        ${cell_name}    Selenium2Library.Get Text    ${tmp1}|${tmp2}
        ${infors}    SBTS WEM Get Cell States On DetailedSiteView    ${cell_name}
        Click Element	${tmp1}|${tmp2}
        ${dic_param}    SBTS WEM Get Detail Info On RuntimeView
        Set To Dictionary    ${dic_param}    icon titles    ${infors}
        Set To Dictionary    ${dic_cell_states}    ${cell_name}    ${dic_param}
    END
    [Return]    ${dic_cell_states}

SBTS WEM Get Cell States On DetailedSiteView
    [Arguments]    ${cell_name}
    ${elements_of_cell}    Selenium2Library.Get WebElements
    ...    //site-runtime-views//div[@class="cell-row"]//span[text()="${cell_name}"]/../..//*[@title]
    ${infors}    Create List
    FOR    ${element}    IN    @{elements_of_cell}
        ${icon_title}    Selenium2Library.Get Element Attribute    ${element}    title
        Append To List    ${infors}    ${icon_title}
    END
    ${tmp1}    Set Variable    //site-runtime-views//div[@class="cell-row"]//span[text()="${cell_name}"]/../..//*[name()="svg"]/
    ${count_barred_icon}    Selenium2Library.Get Element Count    ${tmp1}*[name()="title" and text()="Cell Barred"]
    Run Keyword If    ${count_barred_icon}    Append To List    ${infors}    Cell Barred
    [Return]    ${infors}

SBTS WEM Load SCF File
    [Arguments]    ${scf_file}
    [Documentation]    Load one SCF file via SBTS WebEM
    ...    Author: Liu Bin
    ...    Contact: bin.7.Liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | scf_file | yes | scf file full name |
    ...
    ...    Example
    ...    | SBTS WEM Load SCF File | C:\\\\windows_folder\\\\scf_SBTS_1894.xml |
    ...    | SBTS WEM Load SCF File | /home/ute/linux_folder/scf_SBTS_1894.xml |
    SBTS WEM Open Configuration Manager
    Selenium2Library.Choose File    //div//ui-file-input[@a-text="Load SCF"]//input    ${scf_file}
    Selenium2Library.Wait Until Element Is Visible    //scf-load-modal//li[@class="ng-scope passed"]//div[contains(text(),"Loading finished")]
    Selenium2Library.Wait Until Element Is Visible    //scf-load-modal//ui-button[@a-text="Close"]//button
    Selenium2Library.Click Button    //scf-load-modal//ui-button[@a-text="Close"]//button

Set Web CheckBox
    [Arguments]    ${Xpath}    ${selected}=${True}
    Run Key Word If    ${selected}    Select Checkbox    ${Xpath}
    Run Key Word Unless    ${selected}    Unselect Checkbox    ${Xpath}

Chrome Set Headless Mode
    [Arguments]    ${mode}=headless
    Return From Keyword If    '${mode}'!='headless'    ${None}
    ${chrome_options}    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome_options}    add_argument    --headless
    Call Method    ${chrome_options}    add_argument    --disable-gpu
    Call Method    ${chrome_options}    add_argument    --no-sandbox
    Call Method    ${chrome_options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome_options}    add_argument    --disable-setuid-sandbox
    Call Method    ${chrome_options}    add_argument    --disable-dev-shm-usage
    Comment    ${options}    Call Method    ${chrome_options}    to_capabilities
    [Return]    ${chrome_options}

Get Table Data
    [Arguments]    ${xpath}
    ${data}    Create List
    ${col_name_elements}    Get WebElements    ${xpath}/thead/tr/th
    ${col_name_list}    Create List
    FOR    ${element}    IN    @{col_name_elements}
        ${name}    Get Text    ${element}
        Append To List    ${col_name_list}    ${name}
    END
    ${row_count}    Selenium2Library.Get Element Count    ${xpath}/tbody/tr
    FOR    ${index}    IN RANGE    1    ${row_count}+1
        ${col_elements}    Get WebElements    ${xpath}/tbody/tr[${index}]/td
        ${row_data}    Table Row Text To Dictionary    ${col_name_list}    ${col_elements}
        Append To List    ${data}    ${row_data}
    END
    [Return]    ${data}

Table Row Text To Dictionary
    [Arguments]    ${keys}    ${col_elements_of_row}
    ${key_count}    Get Length    ${keys}
    &{dic}    Create Dictionary
    FOR    ${index}    IN RANGE    ${key_count}
        ${col_text}    Get Text    ${col_elements_of_row[${index}]}
        Set To Dictionary    ${dic}    ${keys[${index}]}    ${col_text}
    END
    [Return]    ${dic}

Select List On Adding Object Popup
    [Arguments]    ${param_name}    ${value}
    ${tmp1}    Set Variable    //div[@uib-modal-transclude]//ui-modal[@a-title="Add Object"]//div[@class="modal-body"]//
    ${count}    Selenium2Library.Get Element Count    ${tmp1}div[contains(text(),"${param_name}")]/../div[@class="data-input"]//button
    Should Not Be Equal As Integers    ${count}    ${0}
    ${tmp1}    Set Variable    //div[@uib-modal-transclude]//ui-modal[@a-title="Add Object"]//
    Click Button    ${tmp1}div[@class="modal-body"]//div[contains(text(),"${param_name}")]/../div[@class="data-input"]//button
    ${tmp1}    Set Variable    //div[@uib-modal-transclude]//ui-modal[@a-title="Add Object"]//div[@class="modal-body"]//
    Wait Until WebElement Exist
    ...    ${tmp1}div[contains(text(),"${param_name}")]/../div[@class="data-input"]//li[@data-value="${value}"]    10s    1s
    ${tmp1}    Set Variable   //div[@uib-modal-transclude]//ui-modal[@a-title="Add Object"]//div[@class="modal-body"]//
    Click Element    ${tmp1}div[contains(text(),"${param_name}")]/../div[@class="data-input"]//li[@data-value="${value}"]

Set Parameter To Dictionary Matching By Name
    [Arguments]    ${target_param_dic}    ${full_name}    ${list_lable}    ${param_list}
    FOR    ${param_dic}    IN    @{param_list}
        ${is_match}    Evaluate    "${param_dic['full_name']}"=="${full_name}" and "${param_dic['list_lable']}"=="${list_lable}"
        ${name}    Set Variable If    '${param_dic['list_lable']}'=='None'
        ...    ${param_dic['full_name']}    ${param_dic['full_name']}(!)${param_dic['list_lable']}
        Run Keyword If    ${is_match}    Set To Dictionary    ${target_param_dic}    ${name}=${param_dic['actual_value']}
        Exit For Loop If    ${is_match}
    END

Check If Object Selected On Navigation Panel Under Pramater Editor
    [Arguments]    ${object}
    ${is_object_selected}    Run Keyword And Return Status    Wait Until WebElement Exist
    ...    //ng-view//wf-panel-section//parameters-editor//div[contains(@class,"pe-middle-panel-header-inner-margin")]//small    10s    1s
    ${selected_object}    Run Keyword If    ${is_object_selected}    Get Text
    ...    //ng-view//wf-panel-section//parameters-editor//div[contains(@class,"pe-middle-panel-header-inner-margin")]//small
    ${is_object_selected}    Run Keyword And Return Status    Should Be Equal As Strings    ${selected_object}    ${object}
    [Return]    ${is_object_selected}

Select PE Table ButtonList By Value
    [Arguments]    ${button_xpath}    ${value}
    Comment    Click Button    ${button_xpath}
    SBTS WEM Click Button Or Element    ${button_xpath}
    ${count}    Selenium2Library.Get Element Count    ${button_xpath}/../ul[@aria-hidden="false"]/wf-dropdown-item/li/a/span[text()="${value}"]
    Run Keyword If    "${count}"=="${0}"    Click Button    ${button_xpath}
    #Some list shall show tips while first click, click it twice to make list shown
    Click Element    ${button_xpath}/../ul[@aria-hidden="false"]/wf-dropdown-item/li/a/span[text()="${value}"]

Element Should Be Enabled With Attribute
    [Arguments]    ${xpath}    ${att_name}=disabled
    ${is_enabled}    Selenium2Library.Get Element Attribute    ${xpath}    ${att_name}
    Should Be True    "${is_enabled}"=="None"

Element Should Be Disabled With Attribute
    [Arguments]    ${xpath}    ${att_name}=disabled
    ${is_enabled}    Selenium2Library.Get Element Attribute    ${xpath}    ${att_name}
    Should Be True    "${is_enabled}"=="true"

Element Should Be Exist
    [Arguments]    ${Xpath}
    ${count}    Selenium2Library.Get Element Count    ${Xpath}
    Should Not Be Equal As Integers    ${count}    ${0}

Element Should Not Be Exist
    [Arguments]    ${Xpath}
    ${count}    Selenium2Library.Get Element Count    ${Xpath}
    Should Be Equal As Integers    ${count}    ${0}

Get Cell Link Path
    ${site_children_count}    Selenium2Library.Get Element Count
    ...    //ng-view//site-runtime-views//div[@n-progress-bar]//div[@new-site]//div[contains(@id,"site") and @class="new-site"]/*
    Should Not Be Equal As Numbers    ${site_children_count}    0
    ${tmp1}    Set Variable    //ng-view//site-runtime-views//div[@n-progress-bar]//
    ${cell_link_path_count}    Selenium2Library.Get Element Count
    ...    ${tmp1}div[@new-site]//div[contains(@id,"site") and @class="new-site"]/*[position()=${site_children_count}]/*
    Should Not Be Equal As Numbers    ${cell_link_path_count}    0
    ${cell_link_path_list}    Create List
    FOR    ${index}    IN RANGE    1    ${cell_link_path_count}+1
        ${tmp1}    Set Variable    //ng-view//site-runtime-views//div[@n-progress-bar]//div[@new-site]//
        ${cell_link_path_source}    Selenium2Library.Get Element Attribute
        ...   ${tmp1}div[contains(@id,"site") and @class="new-site"]/*[position()=${site_children_count}]/*[position()=${index}]    source
        ${tmp1}    Set Variable    //ng-view//site-runtime-views//div[@n-progress-bar]//div[@new-site]//
        ${cell_link_path_target}    Selenium2Library.Get Element Attribute
        ...    ${tmp1}div[contains(@id,"site") and @class="new-site"]/*[position()=${site_children_count}]/*[position()=${index}]    target
        ${tmp1}    Set Variable    //ng-view//site-runtime-views//div[@n-progress-bar]//div[@new-site]//
        ${cell_link_path_parent-target}    Selenium2Library.Get Element Attribute
        ...    ${tmp1}div[contains(@id,"site") and @class="new-site"]/*[position()=${site_children_count}]/*[position()=${index}]    parent-target
        &{cell_link_path_dic}    Create Dictionary    ant=${cell_link_path_source}    cell_mapping=${cell_link_path_target}
        ...    cell=${cell_link_path_parent-target}
        Append To List    ${cell_link_path_list}    ${cell_link_path_dic}
    END
    [Return]    ${cell_link_path_list}

Remove Object From List If Not Match Sub-Object Condition
    [Arguments]    ${sub_object_condition_list}    ${sub_object_list}    ${object_list}    ${object}
    FOR    ${object_condition}    IN    @{sub_object_condition_list}
        ${sub_object_type}    Set Variable    ${object_condition[1:]}
        ${is_should_contain}    Run Keyword And Return Status    Should Start With    ${object_condition}    /
        ${is_contain}    Check If Object List Contains Type Of Object    ${sub_object_list}    ${sub_object_type}
        Run Keyword If    '${is_should_contain}' != '${is_contain}'    Remove Values From List    ${object_list}    ${object}
    END

Check If Object List Contains Type Of Object
    [Arguments]    ${object_list}    ${object_type}
    ${is_equal}    Set Variable    ${False}
    FOR    ${sub_object}    IN    @{object_list}
        ${object_name}    Fetch From Right    ${sub_object}    /
        ${type}    Fetch From Left    ${object_name}    -
        ${is_equal}    Run Keyword And Return Status    Should Be Equal As Strings    ${type}    ${object_type}
        Exit For Loop If    ${is_equal}
    END
    [Return]    ${is_equal}

Get Special Object By Condition
    [Arguments]    ${condition_str}
    ${obj_list}    Create List
    Return From Keyword If    "${condition_str}"==""    ${obj_list}
    ${rat_type}    Create List    NR    WCDMA    LTE    GSM    SBTS
    ...    CELL    NRCELLGRP
    ${is_not_rat}    Run Keyword And Return Status    Should Not Contain    ${rat_type}    ${condition_str}
    Return From Keyword If    ${is_not_rat}    ${obj_list}
    Append To List    ${obj_list}    ${condition_str}
    [Return]    ${obj_list}

Remove Object From List If Not Match Parameter Condition
    [Arguments]    ${sub_condition_list}    ${param_dic}    ${object_list}    ${object}
    ${tmp1}    Set Variable    {"=":"Should Be Equal","!=":"Should Not Be Equal","~":"Should Contain",
    &{oper_kw_dic}    Evaluate    ${tmp1}"!~":"Should Not Contain",">":"Should Larger Than","<":"Should Less Than"}
    FOR    ${param_condition}    IN    @{sub_condition_list}
        ${oper}    Get Regexp Matches    ${param_condition}    =|!=|~|!~|>|<
        ${name}    Fetch From Left    ${param_condition}    ${oper[0]}
        ${value}    Fetch From Right    ${param_condition}    ${oper[0]}
        ${act_value}    Get From Dictionary    ${param_dic}    ${name.strip()}
        ${KW}    Get From Dictionary    ${oper_kw_dic}    ${oper[0]}
        ${is_match}    Run keyword And Return Status    ${KW}    ${act_value}    ${value.strip()}
        Run Keyword Unless    ${is_match}    Remove Values From List    ${object_list}    ${object}
    END

Handle Insecure Warning From Chrome
    ${is_insecure}    Run Keyword And Return Status    Wait Until WebElement Exist    //body[contains(@class,"ssl")]
    Return From Keyword If    '${is_insecure}'!='${True}'
    ${is_hiden}    Selenium2Library.Get Element Attribute    //body//div[@id="details"]    class
    Run Keyword If    "hidden"=="${is_hiden}"    Click Button    id:details-button
    Wait Until Page Contains Element    //body//div[@id="details" and @class!="hidden"]//p[@id="final-paragraph"]/a[@id="proceed-link"]    5s
    Click Element    //body//div[@id="details" and @class!="hidden"]//p[@id="final-paragraph"]/a[@id="proceed-link"]
    Wait Until Page Contains Element    id:login-username    30s

Wait Element Visible And Click
    [Arguments]    ${locator}    ${time_out}=10s
    Wait Until Element Is Visible    ${locator}    ${time_out}
    Wait Until Keyword Succeeds    10s    2s    Click Element    ${locator}

Install FCE From WebEM CA
    [Arguments]      ${fce_path}
    ${msg}    Set Variable
    SBTS WEM Open Configuration Manager    CA
    Selenium2Library.Choose File    //span[contains(text(),'Install FCE')]/../input    ${fce_path}
    ${is_fail}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...    //div[@role="dialog"]//span[contains(text(),"FCE installation failed")]    10s
    Return From Keyword If    '${is_fail}'=='False'    ${msg}
    ${msg}    Selenium2Library.Get Text    //div[@role="dialog"]//div[contains(@class,"p-dialog-content")]/blocks-installed-dialog/div
    Wait Element Visible And Click    //div[@role="dialog"]//div[contains(@class,"p-dialog-footer")]//button/span[contains(text(),'OK')]
    [Return]    ${msg}

Install FCT On WebEM CA
    [Arguments]    ${fct_path}
    ${msg}    Set Variable
    SBTS WEM Open Configuration Manager    CA
    Selenium2Library.Choose File    //span[contains(text(),'Install FCT')]/../input    ${fct_path}
    ${is_fail}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...    //div[@role="dialog"]//span[contains(text(),"FCT installation failed")]    10s
    Return From Keyword If    '${is_fail}'=='False'    ${msg}
    ${msg}    Selenium2Library.Get Text    //div[@role="dialog"]//div[contains(@class,"p-dialog-content")]/blocks-installed-dialog/div
    Wait Element Visible And Click    //div[@role="dialog"]//div[contains(@class,"p-dialog-footer")]//button/span[contains(text(),'OK')]
    [Return]    ${msg}

Collapse Dropdown List
    [Arguments]    ${xpath}
    ${is_expanded}    Run Keyword And Return Status    Element Should Be Visible    ${xpath}
    Run Keyword If    ${is_expanded}    Selenium2Library.Click Element    ${xpath}
    Wait Until Element Is Not Visible    ${xpath}    3s

Get Button States On CA Page
    ${empty_list}    Create List
    ${dic_button_states}    Create Dictionary    select_feature_states=${false}    list_FCE_features=${empty_list}
    ${install_fce_states}    Run Keyword And Return Status    Selenium2Library.Wait Until Element Is Enabled   //ot-upload[@id="install-fce"]//input
    ${install_fct_states}    Run Keyword And Return Status    Selenium2Library.Element Should Be Enabled    //ot-upload[@id="install-fct"]//input
    ${atr}    Selenium2Library.Get Element Attribute    //p-dropdown[@id="selectPlan"]/div[contains(@class,"p-dropdown")]    class
    ${select_plan_states}    Run Keyword And Return Status    Should Not Contain    ${atr}    p-disabled
    Set To Dictionary    ${dic_button_states}    install_fce_states=${install_fce_states}    install_fct_states=${install_fct_states}
    ...    select_plan_states=${select_plan_states}
    ${not_install_FCE}    Run Keyword And Return Status    Should Not Be True    ${install_fct_states}
    Return From Keyword If    ${not_install_FCE}    ${dic_button_states}
    ${atr}    Selenium2Library.Get Element Attribute    //p-dropdown[@id="feature"]/div[contains(@class,"p-dropdown")]    class
    ${select_feature_states}    Run Keyword And Return Status    Should Not Contain    ${atr}    p-disabled
    Set To Dictionary    ${dic_button_states}    select_feature_states=${select_feature_states}
    ${list_FCE_features}    Get FCE Feature List
    Set To Dictionary    ${dic_button_states}    list_FCE_features=${list_FCE_features}
    [Return]    ${dic_button_states}

Get FCE Feature List
    SBTS WEM Open Configuration Manager    CA
    Wait Element Visible And Click    //p-dropdown[@id="feature"]
    ${elements}    Selenium2Library.Get WebElements    //p-dropdown[@id="feature"]//p-dropdownitem/li/span
    ${list_FCE_features}    Create List
    FOR    ${element}    IN    @{elements}
        ${item}    Selenium2Library.Get Text    ${element}
        Append To List    ${list_FCE_features}    ${item}
    END
    Collapse Dropdown List    //p-dropdown[@id="feature"]//div[@role="button" and @aria-expanded="true"]
    [Return]    ${list_FCE_features}

SBTS WEM Select Feature On CA
    [Arguments]    ${feature_name}
    SBTS WEM Open Configuration Manager    CA
    Wait Element Visible And Click    //p-dropdown[@id="feature"]//div[@role="button"]
    Wait Element Visible And Click    //p-dropdown[@id="feature"]//p-dropdownitem/li/span[text()="${feature_name}"]
    Wait Element Visible And Click    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//div[@role="button"]
    ${objects}    Create List
    ${elements}    Selenium2Library.Get WebElements    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//p-dropdownitem/li/span
    FOR    ${element}    IN    @{elements}
        ${item}    Selenium2Library.Get Text    ${element}
        Append To List    ${objects}    ${item}
    END
    Collapse Dropdown List    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//div[@role="button" and @aria-expanded="true"]
    [Return]    ${objects}

SBTS WEM Get Feature Detail Info On CA
    SBTS WEM Expand Detail Panel
    Wait Until Element Is Visible    //details-panel-content//cem-details-content-component/span    3s
    ${FCT_Detail_Header}    Get Text    //details-panel-content//cem-details-content-component/span
    Should Be Equal As Strings     ${FCT_Detail_Header}    FCT tool
    ${FCT_Prop_Dic}    Create Dictionary
    ${tmp}    Set Variable    //details-panel-content//cem-details-content-component//div[contains(@class,"cem-details-component-content")]
    ${Count}    Selenium2Library.Get Element Count    ${tmp}/div[contains(@class,"cem-details-component-section-item")]
    FOR    ${index}    IN RANGE    1    ${Count}+1
        ${label}    Selenium2Library.Get Text    ${tmp}/div[contains(@class,"cem-details-component-section-item")][${index}]/label
        ${span}    Selenium2Library.Get Text    ${tmp}/div[contains(@class,"cem-details-component-section-item")][${index}]/span
        Set To Dictionary    ${FCT_Prop_Dic}    ${label}=${span}
    END
    [Return]    ${FCT_Prop_Dic}

SBTS WEM Calculate On CA Page And Get Results
    Wait Element Visible And Click    //cem-operation-button//button/span[text()="Calculate"]
    ${result}    ${table_head_list}    ${validation_result}    Get FCT Caculate Result
    [Return]    ${result}    ${table_head_list}    ${validation_result}

SBTS WEM Audit On CA Page And Get Results
    Wait Element Visible And Click    //cem-operation-button//button/span[text()="Audit"]
    ${result}    ${table_head_list}    ${validation_result}    Get FCT Caculate Result
    [Return]    ${result}    ${table_head_list}    ${validation_result}

Get FCT Operation Result From GUI Table
    [Documentation]    Help for getting different FCT operation result from html table element
    [Arguments]     ${xpath_table}
	${thead}    Selenium2Library.Get WebElements    ${xpath_table}//tr/th
    ${table_head_list}    Create List
    FOR    ${th}    IN    @{thead}
        ${item}    Selenium2Library.Get Text    ${th}
        Append To List    ${table_head_list}    ${item}
    END
    ${tbody_tr}    Selenium2Library.Get WebElements    ${xpath_table}//tbody//tr
    ${row_count}    Get Length    ${tbody_tr}
    ${table_content}    Create List
    FOR    ${index}    IN RANGE    ${1}    ${row_count}+1
        ${td_list}    Selenium2Library.Get WebElements    ${xpath_table}//tr[${index}]/td
        ${column_dic_onerow}    Generate Column Dictionary For Row    ${table_head_list}    ${td_list}
        Append To List    ${table_content}    ${column_dic_onerow}
    END
    [Return]    ${table_head_list}    ${table_content}

Get FCT Caculate Result
    Wait Until Element Is Visible    //blocks-configuration-automation-results//p-table[1]
    Wait Until Element Is Visible    //blocks-configuration-automation-results//p-table[@id="nonNiddParameterTable"]
    ## Validation results
    ${result}    Selenium2Library.Get Text    //blocks-configuration-automation-results//ot-instruction/div/div
    ${validate_th_list}    ${validation_result}    Get FCT Operation Result From GUI Table
    ...    //blocks-configuration-automation-results//p-table[1]
    ## Additional (non-NIDD) output parameters
    ${addoutput_th_list}    ${add_output_param}    Get FCT Operation Result From GUI Table
    ...    //blocks-configuration-automation-results//p-table[@id="nonNiddParameterTable"]
    [Return]    ${result}    ${validate_th_list}    ${validation_result}    #${addoutput_th_list}    ${add_output_param}

Generate Column Dictionary For Row
    [Arguments]    ${table_head_list}    ${one_row_colunms}
    ${row_value}    Create Dictionary
    ${key_num}    Get Length    ${table_head_list}
    ${colunm_num}    Get Length    ${one_row_colunms}
    ${value}    Run Keyword If    '${key_num}'!='${colunm_num}' and '${colunm_num}'=='${1}'    Selenium2Library.Get Text    ${one_row_colunms[0]}
    Return From Keyword If    '${key_num}'!='${colunm_num}' and '${colunm_num}'=='${1}'    ${value}
    FOR    ${index}    IN RANGE    ${0}    ${key_num}
        ${value}    Selenium2Library.Get Text    ${one_row_colunms[${index}]}
        Set To Dictionary    ${row_value}    ${table_head_list[${index}]}=${value}
    END
    [Return]    ${row_value}

Get Feature List From WebEM CA
    SBTS WEM Open Configuration Manager    CA
    Wait Element Visible And Click    //span[contains(text(),'<Select feature>')]
    ${es}    Selenium2Library.Get WebElements    //span[contains(text(),'<Select feature>')]/..//p-dropdownitem/li/span
    ${list_FCE_features}    Create List
    FOR    ${e}    IN    @{es}
        ${item}    Selenium2Library.Get Text    ${e}
        Append To List    ${list_FCE_features}    ${item}
    END
    Collapse Dropdown List    //p-dropdown[@id="feature"]//div[@role="button" and @aria-expanded="true"]
    [Return]    ${list_FCE_features}

Get Plan Options From WebEM CA
    SBTS WEM Open Configuration Manager    CA
    ${current_plan}    Selenium2Library.Get Text    //p-dropdown[@id="selectPlan"]//div/span[contains(@class,"p-dropdown-label")]
    Wait Element Visible And Click    //p-dropdown[@id="selectPlan"]//div[@role="button"]
    ${plan_options}    Selenium2Library.Get WebElements    //p-dropdown[@id="selectPlan"]//p-dropdownitem/li/span
    ${list_plan}    Create List
    FOR    ${item}    IN    @{plan_options}
        ${plan}    Selenium2Library.Get Text    ${item}
        Append To List    ${list_plan}    ${plan}
    END
    Collapse Dropdown List    //p-dropdown[@id="selectPlan"]//div[@role="button" and @aria-expanded="true"]
    [Return]    ${list_plan}    ${current_plan}

SBTS WEM Select Plan On CA
    [Arguments]     ${plan_name}
	SBTS WEM Open Configuration Manager    CA
    Wait Element Visible And Click    //p-dropdown[@id="selectPlan"]//div[@role="button"]
    Wait Element Visible And Click    //p-dropdown[@id="selectPlan"]//p-dropdownitem/li/span[text()="${plan_name}"]

Get Values Of Param On AC
    [Arguments]    ${param}
    Wait Element Visible And Click    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//div[@role="button"]
    Wait Until Element Is Visible    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//p-dropdownitem//span
    ${value_elements}    Selenium2Library.Get WebElements    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//p-dropdownitem//span
    ${list_value}    Create List
    FOR    ${element}    IN    @{value_elements}
        ${value}    Selenium2Library.Get Text    ${element}
        Append To List    ${list_value}    ${value}
    END
    Collapse Dropdown List    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//div[@role="button" and @aria-expanded="true"]
    [Return]    ${list_value}

SBTS WEM Select Object On CA
    [Arguments]    ${object_name}
    Wait Element Visible And Click    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//div[@role="button"]
    Wait Element Visible And Click
    ...   //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//p-dropdownitem/li/span[text()="${object_name}"]
    Collapse Dropdown List    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//div[@role="button" and @aria-expanded="true"]
	${selected_object_instance}    Selenium2Library.Get Text    //p-multiselect//div[2]/div
    ${dic_param_value}    Create Dictionary
    ${elements}    Selenium2Library.Get WebElements    //div[@blockpanelcontent]//label[contains(@class,"p-element")]
    FOR    ${element}    IN    @{elements}
        ${item}    Selenium2Library.Get Text    ${element}
        ${selected_value}    Selenium2Library.Get Text
        ...    //div[@blockpanelcontent]//label[text()="${item}"]/..//p-dropdown//span[contains(@class,"p-dropdown-label")]
        Set To Dictionary    ${dic_param_value}    ${item}    ${selected_value}
    END
    [Return]    ${selected_object_instance}    ${dic_param_value}

Get All Additional Param Value And Object Instance
    [Arguments]    ${object_name}
    Wait Element Visible And Click    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//div[@role="button"]
    Wait Element Visible And Click
    ...    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//p-dropdownitem//span[text()="${object_name}"]
    ${dic_param_value}    Create Dictionary
    ${elements}    Selenium2Library.Get WebElements    //div[@blockpanelcontent]//label[contains(@class,"p-element")]
    FOR    ${element}    IN    @{elements}
        ${param}    Selenium2Library.Get Text    ${element}
        ${has_tag}    ${tag}    Run Keyword And Ignore Error
        ...    Should Match Regexp    ${param}    \\(rel \\>=\\w+\\)|\\(rel \\<=\\w+\\)|\\(rel \\<\\w+\\)|\\(rel \\>\\w+\\)|\\(rel \\=\\w+\\)
        ${compare_result}    Run Keyword If    '${has_tag}'=='PASS'
        ...    Compare Additional Param Support Version With Current SW From Tag     ${tag}
        Continue For Loop If    '${has_tag}'=='PASS' and '${compare_result}'!='True'
        ${list_value}    Get Values Of Param On AC    ${param}
        Set To Dictionary    ${dic_param_value}    ${param}    ${list_value}
    END
    Collapse Dropdown List    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//div[@role="button" and @aria-expanded="true"]
	Wait Element Visible And Click    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-multiselect//span
	${sub_obj_list}    Create List
    ${elements}    Selenium2Library.Get WebElements    //p-multiselectitem
    FOR    ${element}    IN    @{elements}
        ${obj}    Selenium2Library.Get Text    ${element}
        Append To List    ${sub_obj_list}    ${obj}
    END
    Selenium2Library.Click Element    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-multiselect//span
    [Return]    ${sub_obj_list}    ${dic_param_value}

Set Param Value Of Feature Object
    [Arguments]     ${dic_value_to_set}
    ${params}    Get Dictionary Keys    ${dic_value_to_set}
    FOR    ${param}    IN    @{params}
        ${value_to_set}    Get From Dictionary    ${dic_value_to_set}    ${param}
        Wait Element Visible And Click    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//div[@role="button"]
        Wait Until Element Is Visible    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//p-dropdownitem//span
        Run Keyword If    '${value_to_set}'!=''    Selenium2Library.Click Element
        ...    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//p-dropdownitem//span[text()="${value_to_set}"]
    END

SBTS WEM Apply All On CA
    Wait Element Visible And Click    //blocks-configuration-automation-apply//button/span[text()="Apply All"]
    Wait Until Element Is Visible    //blocks-configuration-automation-apply//ot-instruction//span
    ${result}    Selenium2Library.Get Text    //blocks-configuration-automation-apply//ot-instruction//span
    [Return]     ${result}

SBTS WEM Import CSV On CA
    [Arguments]     ${csv_path}
    Selenium2Library.Choose File    //p-fileupload//span[contains(text(),'Import CSV...')]/../input    ${csv_path}
    ${msg}    Selenium2Library.Get Text    //blocks-configuration-automation//ot-instruction/div/div
    Should Be Equal As Strings    ${msg}    Success
    ${csv_file_name}    Fetch From Right     ${csv_path}    /
    ${file_selected_name}    Selenium2Library.Get Text
	...    //cem-block-panel//div[@class='p-fileupload-buttonbar']/div/span[@title='${csv_file_name}']
    Should Be Equal As Strings   ${file_selected_name}    ${csv_file_name}

SBTS WEM Save Audit Report On CA
    [Arguments]    ${target_path}
    ${output_before}    OperatingSystem.Run    sudo ls -l Audit_report_*csv
    ${files_before}    Split To Lines    ${output_before}
    Wait Element Visible And Click    //div[contains(@class,'cem-block-panel-header')]/span[text()='Results']/..//span[text()='Save Audit Report']
    Sleep    5s
    ${output_after}    OperatingSystem.Run    sudo ls -l Audit_report_*csv
    ${files_after}    Split To Lines    ${output_after}
    Remove Values From List    ${files_after}    @{files_before}
    ${file_count}    Get Length    ${files_after}
    Should Be Equal As Integers    ${file_count}    1
    ${file_list}    Split String    ${files_after[0]}
    ${audit_report_filename}    Set Variable    ${file_list[-1]}
    ${audit_report_size}    Get File Size    ${audit_report_filename}
    Should Be True    ${audit_report_size}>0
    Copy File    ${audit_report_filename}    ${target_path}
    [Return]    ${audit_report_filename}

Compare And Apply Success And Check Result On CA
    Wait Element Visible And Click     //blocks-configuration-automation-apply//button/span[text()='Compare and Apply']
    Wait Until Element Is Visible    //ot-dialog[@id='compareAndApply']//div[contains(@class,"ot-dialog-title") and text()=' Compare and Apply']
    Element Should Not Be Exist    //ot-dialog[@id='compareAndApply']//p-button[@disabled='true']//span[text()="Apply All"]
    Wait Element Visible And Click    //ot-dialog[@id='compareAndApply']//button/span[text()="Apply All"]
    Sleep    5s
    Wait Until Element Is Visible    //ot-dialog[@id='compareAndApply']//p-button[@disabled='true']//span[text()="Apply All"]
    ${apply_result}    Selenium2Library.Get Text
    ...    //ot-dialog[@id='compareAndApply']//div[@class="cem-operation-button"]//span[text()="Apply All"]/../../..//div/span
    Should Be Equal As Strings    ${apply_result}    Success
    ${count_row}    Selenium2Library.Get Element Count
    ...    //ot-dialog[@id='compareAndApply']//div[contains(@class,"p-treetable-scrollable-body")]//tr
    FOR    ${r}    IN RANGE    ${1}    ${count_row}
        ${cur_val}    Selenium2Library.Get Text
        ...    //ot-dialog[@id='compareAndApply']//div[contains(@class,"p-treetable-scrollable-body")]//tr[${r}]/td[2]
        ${recomm_val}   Selenium2Library.Get Text
        ...    //ot-dialog[@id='compareAndApply']//div[contains(@class,"p-treetable-scrollable-body")]//tr[${r}]/td[3]
        Should Be Equal As Strings    ${cur_val.strip()}    ${recomm_val.strip()}
    END
    Wait Element Visible And Click    //ot-dialog[@id='compareAndApply']//div[contains(@class,'p-dialog-footer')]//span[text()='Close']

SBTS WEM Get Datas Of ORAN O1 Management
    [Arguments]    @{block_names}
    SBTS WEM Open Diagnostic    O-RAN O1 Management
    ${xpath_tables}    Create Dictionary    Active alarms=//blocks-alarms//table    Netconf clients=//blocks-netconf-clients//table
    ...    VES endpoints=//blocks-ves-endpoints//table
    ${datas}    Create Dictionary
    ${blocks}    Get Dictionary Keys    ${xpath_tables}
    FOR    ${block}    IN    @{blocks}
        ${data}    SBTS WEM Get Configuration-table Data    ${xpath_tables['${block}']}
        Set To Dictionary    ${datas}    ${block}=${data}
    END
    ${netconf_server_state}    Selenium2Library.Get Text    //blocks-netconf-server//span
    Set To Dictionary    ${datas}    Netconf server=${netconf_server_state}
    Return From Keyword If    '${block_names.__len__()}'=='0'    ${datas}
    Keep In Dictionary    ${datas}    @{block_names}
    [Return]    ${datas}

SBTS WEM Kill Session on ORAN O1 Management
    [Arguments]    ${sessionId}    ${ip}    ${user}=cmuser
    ${result}    Set Variable    ${False}
    SBTS WEM Open Diagnostic    O-RAN O1 Management
    ${tr_count}    Selenium2Library.Get Element Count    //blocks-netconf-clients//tbody/tr
    ${td_count}    Selenium2Library.Get Element Count    //blocks-netconf-clients//tbody/tr/td
    Return From Keyword If    "${td_count}"=="${1}"    ${result}
    FOR    ${i}    IN RANGE    1    ${tr_count}+1
        ${sessionId_WebEM}    Get Text    //blocks-netconf-clients//tbody/tr[${i}]/td[1]
        ${cmuser_WebEM}    Get Text    //blocks-netconf-clients//tbody/tr[${i}]/td[2]
        ${ip_WebEM}    Get Text    //blocks-netconf-clients//tbody/tr[${i}]/td[3]
        Continue For Loop If    "${sessionId_WebEM}"!="${sessionId}" or "${cmuser_WebEM}"!="${user}" or "${ip_WebEM}"!="${ip}"
        Click Element
        ...   //blocks-netconf-clients//tbody/tr[${i}]/td[5]//p-button[@ng-reflect-text="Terminate this session"]/button
        Wait Until WebElement Exist     //div[@role="dialog"]/div[contains(@class,"p-dialog-footer")]//button//span[text()="Terminate session"]
        Click Element    //div[@role="dialog"]/div[contains(@class,"p-dialog-footer")]//button//span[text()="Terminate session"]
        ${result}    Set Variable    ${True}
        Exit For Loop
    END
    Return From Keyword If    "${result}"=="${False}"    ${result}
    sleep    10s
    ${tr_count}    Selenium2Library.Get Element Count    //blocks-netconf-clients//tbody/tr
    FOR    ${j}    IN RANGE    1    ${tr_count}+1
        ${sessionId_WebEM}    Get Text    //blocks-netconf-clients//tbody/tr[${j}]/td[1]
        ${result}    Set Variable If    "${sessionId_WebEM}"=="${sessionId}"    ${False}    ${result}
        Exit For Loop If    "${sessionId_WebEM}"=="${sessionId}"
    END
    [Return]    ${result}

SBTS WEM Save Snapshot
    [Arguments]    ${coverage}=${EMPTY}    ${save_location}=${EMPTY}    ${filter_keyword}=${EMPTY}    ${reason}=${EMPTY}    @{LTE_cell_select}
    [Documentation]    Save snapthot on 'Snapshot Collection', file will save to default path ~/Download.
    ...    ${coverage}, one text of 'Coverage' on web page:['All log files','Most important log files','Health check log files',
    ...    'All log files without RF logs','Most important files without RF logs','System module health check log files']
    ...    ${save_location}, one text of 'Save location' on web page:['Local','Remote']
    ...    ${filter_keyword}, text to input to 'Filter keyword' on web page.
    ...    ${reason}, text to input to 'Reason' on web page.
    ...    @{LTE_cell_select}, lncel to be selected of 'LTE cell filter' on web page.

    ...    *Example*
    ...    | SBTS WEM Save Snapshot | | | | | |
    ...    | SBTS WEM Save Snapshot | Most important log files | Local | ${EMPTY} | ${EMPTY} | LNCEL-1 |
    ...    | SBTS WEM Save Snapshot | Most important log files | Local | ${EMPTY} | ${EMPTY} | @{cell_list} |

    ${output}    OperatingSystem.Run    ls ~/Downloads|grep -E ^Snapshot_.*\\.zip$
    ${file_before}    Split To Lines    ${output}
    SBTS WEM Open Diagnostic
    Selenium2Library.Input Text    //textarea[@name="keyword"]    ${filter_keyword}
    Selenium2Library.Input Text    //span[@id="snapshot-reason-label"]/..//textarea    ${reason}
    Run Keyword If    """${coverage}"""!="""${EMPTY}"""    Click Element    //span[@id="snapshot-coverage-label"]/..//label[text()="${coverage}"]
    Run Keyword If    """${save_location}"""!="""${EMPTY}"""
    ...    Click Element    //span[@id="snapshot-location-label"]/..//label[text()="${save_location}"]
    FOR    ${cell}    IN    @{LTE_cell_select}
        Click Element    //table-multiselect//label[text()="${cell}"]
    END
    Click Button    //ui-button[@a-text="Collect Snapshot"]/button
    Wait Until Element Is Visible    //label[contains(text(),"Collecting files")]    timeout=2 min
    Wait Until Element Is Visible    //label[contains(text(),"Collection completed")]    timeout=15 min
    FOR    ${i}    IN RANGE    ${0}    ${18}
        Sleep    10s
        ${output}    OperatingSystem.Run    ls ~/Downloads|grep -E ^Snapshot_.*\\.zip$
        ${file_after}    Split To Lines    ${output}
        Exit For Loop If    ${file_after.__len__()}>${file_before.__len__()}
    END
    Remove Values From List    ${file_after}    @{file_before}
    Should Be Equal As Integers    ${file_after.__len__()}    ${1}
    ${file}    Set Variable    ${file_after[0]}
    [Return]    ${file}
