*** Settings ***
Documentation
...    Author: Xu Yuyan; Liu Bin; Kang Lixin
...    Email address: yuyan.xu@nokia-sbell.com
...    Maintainer: Xu Yuyan
...    Common KWs related to some operation on AIC WebUI.
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guideline: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/09.+AIC+Common+Resource+Supporting+Mode+Improvement
Variables         python/webem_locator.py



*** Keywords ***
Open Browser
    [Arguments]    ${URL}    ${download_path}=/tmp/
    [Documentation]    Open Browser
    ...    | Input Parameters | Man. | Description |
    ...    | URL| yes | e.g, https://10.56.125.120 |
    ...
    ...    *RETURN VALUE*
    ...    Parameter Value
    ...
    ...    Example
    ...    | Open Browser | URL=https://10.56.125.120 |
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    ${prefs}    create dictionary    download.default_directory=${download_path}
    Call Method    ${chrome options}    add_experimental_option    prefs    ${prefs}
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Call Method    ${chrome options}    add_argument    --disable-setuid-sandbox
    Call Method    ${chrome options}    add_argument    --disable-gpu
    Call Method    ${chrome options}    add_argument    --disable-dev-shm-usage
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Set Window Size    1920    1080
    Maximize Browser Window
    Goto    ${URL}

Open WEBEM and Login
    [Arguments]    ${URL}=http    ${USER}=Nemuadmin    ${PASSWORD}=Nokia@123    ${download_path}=/tmp/
    [Documentation]    Open WEBEM and Login
    ...    | Input Parameters | Man. | Description |
    ...    | URL | yes | e.g, 10.110.125.210 |
    ...    | USER | yes | e.g, Nemuadmin |
    ...    | PASSWORD | yes | e.g, nemuuser |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Open WEBEM and Login | URL=10.110.125.210 | USER=Nemuadmin | PASSWORD=nemuuser |
    Comment    Open Browser    https://${URL}
    Open Browser    ${URL}    ${download_path}
    ${resp}    run keyword and ignore error    wait until element is visible    xpath=//div[contains(text(),'vDU WebEM')]    10s
    run keyword if    """${resp[0]}"""=="""FAIL"""    run keywords    Selenium2Library.close browser
    ...    AND    Open Browser    ${URL}
    ...    AND    wait until element is visible    xpath=//div[contains(text(),'vDU WebEM')]    10s
    run keyword and ignore error    Change Password
    wait until element is visible    xpath=//div[contains(text(),'vDU WebEM')]    10s
    input text    ${INPUT_USERNAME}    ${USER}
    sleep    3s
    input text    ${INPUT_PASSWORD}    ${PASSWORD}
    sleep    3s
    Click Element    ${LOGIN_BUTTON}
    sleep    3s
    Wait Until Element Is Visible    ${CONFIRM_BUTTON}    1min
    Click Element    ${CONFIRM_BUTTON}
    ${resp}    run keyword and ignore error    wait until element is visible    ${STARTUP_VIEW}    10s
    run keyword if    """${resp[0]}"""=="""PASS"""    click element    ${STARTUP_VIEW_CLOSE_BUTTON}

Change Password
    [Arguments]    ${current_passwd}=nemuuser    ${new_passwd}=Nokia@123
    input text    ${INPUT_USERNAME}    ${WEBUI_USER}
    sleep    3s
    input text    ${INPUT_PASSWORD}    ${current_passwd}
    sleep    3s
    Click Element    ${LOGIN_BUTTON}
    sleep    3s
    wait until element is visible    ${CHANGE_PASSWORD}    10s
    input text    ${INPUT_CURRENT_PASSWD}    ${current_passwd}
    sleep    3s
    input text    ${INPUT_NEW_PASSWD}    ${new_passwd}
    sleep    3s
    input text    ${INPUT_CONFIRM_PASSWD}    ${new_passwd}
    sleep    3s
    Click Element    ${SAVE_PASSWD}

Logout And Close WEBEM
    Wait Until Element Is Visible    xpath=//span[contains(text(),"Nemuadmin")]
    Click Element    xpath=//span[contains(text(),"Nemuadmin")]
    Wait Until Element Is Visible    xpath=//span[contains(text(),"Sign out")]
    Click Element    xpath=//span[contains(text(),"Sign out")]
    Selenium2Library.close browser

Check Alarm Should Not Contain Fault By Seleumin
    [Arguments]    ${FAULT_ID}
    [Documentation]    Check Alarm Should Not Contain Fault by Seleumin
    ...    just run by selenium
    ...    | Input Parameters | Man. | Description |
    ...    | FAULT_ID | yes | FAULT_ID, e.g, 23 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Check Alarm Should Not contain Fault via seleumin | FAULT_ID=23 |
    sleep    10s
    @{output_alarms}    svdu.get_active_alarm_info
    log to console    alarm=@{output_alarms}
    Should Not Contain    '@{output_alarms}'    u'Fault ID': u'${FAULT_ID}'

Check Alarm Should contain Fault By Seleumin
    [Arguments]    ${FAULT_ID}
    [Documentation]    Check Alarm Should contain Fault via seleumin
    ...    | Input Parameters | Man. | Description |
    ...    | FAULT_ID | yes | FAULT_ID, e.g, 23 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Check Alarm Should contain Fault via seleumin | FAULT_ID=23 |
    sleep    10s
    @{output_alarms}    svdu.get_active_alarm_info
    log to console    alarm=@{output_alarms}
    should contain    '@{output_alarms}'    u'Fault ID': u'${FAULT_ID}'

Check History Alarm Should contain Fault By Seleumin
    [Arguments]    ${FAULT_ID}
    [Documentation]    Check History Alarm Should contain Fault via seleumin
    ...    | Input Parameters | Man. | Description |
    ...    | FAULT_ID | yes | FAULT_ID, e.g, 23 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Check History Alarm Should contain Fault via seleumin | FAULT_ID=23 |
    sleep    10s
    ${output_alarms}    svdu.get_history_alarm_info
    log to console    alarm=${output_alarms}
    should contain    '${output_alarms}'    u'Fault ID': u'${FAULT_ID}'

Check toggling Alarm Should contain Fault By Seleumin
    [Arguments]    ${status}    ${FAULT_ID}    ${TOGGLING_ID}    ${flag}
    [Documentation]    Check toggling Alarm Should contain Fault via seleumin
    ...    | Input Parameters | Man. | Description |
    ...    | status | yes | status, e.g, Inactive |
    ...    | FAULT_ID | yes | FAULT_ID, e.g, 4298 |
    ...    | TOGGLING_ID | yes | TOGGLING_ID, e.g, 4026 |
    ...    | flag | yes | flag, e.g, true |
    ...
    ...    *RETURN VALUE*
    ...    datetime
    ...
    ...    Example
    ...    | Check toggling Alarm Should contain Fault via seleumin | Inactive | 4298 | 4026 | true |
    Log To Console    ${TOGGLING_ID}
    ${output_alarms}=    Get Active Alarm Fault by REST API
    log to console    alarm=@{output_alarms}
    run keyword if    ${flag}== True    Should Contain    '@{output_alarms}'    'Fault ID': u'4026'
    run keyword if    ${flag}== False    Should Not Contain    '@{output_alarms}'    'Fault ID': u'4026'
    @{fault_toggle_alarm}    svdu.get_fault_toggling_history
    log to console    alarm=@{fault_toggle_alarm}
    should contain    '@{fault_toggle_alarm}'    'Fault ID': u'${FAULT_ID}'
    should contain    '@{fault_toggle_alarm}'    'State': u'${status}'
    svdu.logout

Copy Existing Object
    [Arguments]    ${object_name}    ${object_class_name}    ${plan_name}    ${object_distinguished_name}
    ...    ${copy_object_with_subtree}=${True}    ${id_value}=None    ${timeout}=60
    [Documentation]    Copy Existing Object
    ...    | Input Parameters | Man. | Description |
    ...    | object_name | yes | where object will be added in |
    ...    | object_class_name| yes | name of object class |
    ...    | plan_name | yes | plan name that object to be copied |
    ...    | object_distinguished_name | yes | object_distinguished_name |
    ...    | copy_object_with_subtree | no | Boolean , copying subtree elements |
    ...    | id_value | no | default is None |
    ...    | timeout | no | timeout for the element be available to click |
    ...    *RETURN VALUE*
    ...    none
    ...
    ...    Example
    ...    |Copy Existing Object | object_name=MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1 | object_class_name=LCELNR |plan_name=DELTA-PLAN-1
    ...    |object_distinguished_name=MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1 | copy_object_with_subtree=${True} | id_value=2 |
    svdu.choose_plan    plan_name=DELTA-PLAN-1
    ${timeout}    convert to integer    ${timeout}
    svdu.copy_object    ${object_name}    ${object_class_name}    ${plan_name}    ${object_distinguished_name}
    ...    ${copy_object_with_subtree}    ${id_value}    ${timeout}

Go To ALD Status Page
    [Documentation]    Go To ALD Status Page
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    none
    ...
    ...    Example
    ...    | Open WEBEM and Login |
    ...    | Go To ALD Status Page |
    Wait Element Visible And Click    locator=${DASHBOARD_SIDEBAR_STATUS}    time_out=1min
    Wait Element Visible And Click    locator=${ALD_STATUS_VIEW}
    sleep    1s

Select Diagnostic on WebEM
    log to console    ---Start to Select Diagnostic on WEBEM
    Wait Until Element Is Visible    xpath=${DASHBOARD_SIDEBAR_DIAGNOSTIC}    30s
    Click Element    xpath=${DASHBOARD_SIDEBAR_DIAGNOSTIC}

Select Tab SFP Monitoring
    log to console    ---Start to Select Tab SFP Monitoring
    Wait Until Element Is Visible    xpath=${SFP_MONITORING}    90s
    Click Element    xpath=${SFP_MONITORING}

Export ALD Status File
    [Arguments]    ${ald_type}=RAE
    RUN    rm /tmp/${ald_type}_status*
    Go To ALD Status Page
    click element    xpath=//span[contains(text(),"${ald_type} Status View")]
    sleep    3s
    Wait Until Element Is Visible    xpath=${EXPORT_BUTTON}
    click element    xpath=${EXPORT_BUTTON}
    sleep    3s
    ${status_file}    RUN    cd /tmp/; ls|grep ${ald_type}_status
    ${status_file_path}    OperatingSystem.Join Path    /tmp/${status_file}
    [Return]    ${status_file_path}

Wait Element Visible And Click
    [Arguments]    ${locator}    ${time_out}=10s
    Wait Until Element Is Visible    ${locator}    ${time_out}
    wait until keyword succeeds    10s    2s    click element    ${locator}

Go to PE ALD
    [Arguments]    ${ald_type}    ${ald_index}=1
    Log To Console    ${ald_index}
    Should Be Uppercase    ${ald_type}
    ${ald_type_tmp}    Convert To Lowercase    ${ald_type}
    Go To ALD Status Page
    click element    xpath=//span[contains(text(),"${ald_type} Status View")]
    Wait Element Visible And Click    xpath=//div[@class="${ald_type_tmp}-tile-view"]//p-button[@title="Operations"]
    Wait Element Visible And Click    xpath=//span[contains(text(),"Go to PE (ALD-")]
    Wait Until Element Is Visible    xpath=//span[contains(text(),"MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ALD-")]

Go to PE ALD_R
    [Arguments]    ${ald_type}    ${ald_index}=1
    Log To Console    ${ald_index}
    Should Be Uppercase    ${ald_type}
    ${ald_type_tmp}    Convert To Lowercase    ${ald_type}
    Go To ALD Status Page
    click element    xpath=//span[contains(text(),"${ald_type} Status View")]
    Wait Element Visible And Click    xpath=//div[@class="${ald_type_tmp}-tile-right"]//p-button[@title="Operations"]//button
    Wait Element Visible And Click    xpath=//span[contains(text(),"Go to PE (ALD_R-")]
    Wait Until Element Is Visible    xpath=//span[contains(text(),"/ALD_R-")]

Go to PE RETU/RAEU
    [Arguments]    ${ald_type}    ${ald_index}=1    ${unit_index}=1
    Should Be Uppercase    ${ald_type}
    ${ald_type_tmp}    Convert To Lowercase    ${ald_type}
    Go To ALD Status Page
    click element    xpath=//span[contains(text(),"${ald_type} Status View")]
    Wait Element Visible And Click    xpath=//div[@class="${ald_type_tmp}u-view"]//p-button[@title="Operations"]
    Wait Element Visible And Click    xpath=//span[contains(text(),"Go to PE (RAEU-${unit_index})")]
    Wait Until Element Is Visible    xpath=//span[contains(text(),"MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ALD-${ald_index}/${ald_type}U-${unit_index}")]

Go to PE RETU_R/RAEU_R
    [Arguments]    ${ald_type}    ${ald_index}=1    ${unit_index}=1
    Should Be Uppercase    ${ald_type}
    ${ald_type_tmp}    Convert To Lowercase    ${ald_type}
    Go To ALD Status Page
    click element    xpath=//span[contains(text(),"${ald_type} Status View")]
    Wait Element Visible And Click    xpath=//div[@class="${ald_type_tmp}u-view"]//p-button[@title="Operations"]
    Wait Element Visible And Click    xpath=//span[contains(text(),"Go to PE (RAEU_R-${unit_index})")]
    Wait Until Element Is Visible    xpath=//span[contains(text(),"ALD_R-${ald_index}/${ald_type}U_R-${unit_index}")]

Reset ALD SW
    [Arguments]    ${ald_type}
    Should Be Uppercase    ${ald_type}
    ${ald_type_tmp}    Convert To Lowercase    ${ald_type}
    Go To ALD Status Page
    click element    xpath=//span[contains(text(),"${ald_type} Status View")]
    Wait Element Visible And Click    xpath=//div[@class="${ald_type_tmp}-tile-view"]//p-button[@title="Operations"]
    Wait Element Visible And Click    xpath=//span[contains(text(),"Reset ALD (SW)")]
    Wait Element Visible And Click    xpath=//button[contains(@class,"p-confirm-dialog-accept")]

Reset ALD HW
    [Arguments]    ${ald_type}
    Should Be Uppercase    ${ald_type}
    ${ald_type_tmp}    Convert To Lowercase    ${ald_type}
    Go To ALD Status Page
    click element    xpath=//span[contains(text(),"${ald_type} Status View")]
    Wait Element Visible And Click    xpath=//div[@class="${ald_type_tmp}-tile-view"]//p-button[@title="Operations"]
    Wait Element Visible And Click    xpath=//span[contains(text(),"Reset ALD (HW)")]
    Wait Element Visible And Click    xpath=//button[contains(@class,"p-confirm-dialog-accept")]

RAE Restore Factory Defaults
    [Arguments]    ${ald_type}
    Should Be Uppercase    ${ald_type}
    ${ald_type_tmp}    Convert To Lowercase    ${ald_type}
    Go To ALD Status Page
    click element    xpath=//span[contains(text(),"RAE Status View")]
    Wait Element Visible And Click    xpath=//div[@class="${ald_type_tmp}u-view"]//p-button[@title="Operations"]
    Wait Element Visible And Click    xpath=//span[contains(text(),"Restore Factory Defaults")]
    Wait Element Visible And Click    xpath=//button[contains(@class,"p-confirm-dialog-accept")]

Download RAE Weight Factor File
    [Arguments]    ${weight_file_name}
    RUN    rm /tmp/TYDA*
    Wait Element Visible And Click    xpath=//ui-webem-raeu-tile[@class="ng-star-inserted"]
    Wait Element Visible And Click    xpath=//span[contains(text(),"Weight")]
    Wait Until Element Is Visible    xpath=//td[@title="${weight_file_name}"]
    Wait Until Element Is Visible    xpath=//td[@title="WeightFactorFile"]
    Wait Until Element Is Enabled    xpath=//div[@class="details-panel-body-section"]//span[contains(@class,"mdi-content-save")]
    click element    xpath=//div[@class="details-panel-body-section"]//span[contains(@class,"mdi-content-save")]
    wait until keyword succeeds    1min    10s    Check RAE Weight Factor File Should Be Saved    ${weight_file_name}

Check RAE Weight Factor File Should Be Saved
    [Arguments]    ${weight_file_name}
    ${size}=    get file size    /tmp/${weight_file_name}
    should be true    ${size} > 0

Open Details Panel
    Run Keyword And Return Status    Wait Element Visible And Click    //button[@id="open-detail-panel-button" and @title="Open details panel"]
    Wait Until Element Is Visible    //button[@id="open-detail-panel-button" and @title="Close details panel"]

Hide Details Panel
    Run Keyword And Continue On Failure    Wait Element Visible And Click    //button[@id="open-detail-panel-button" and @title="Close details panel"]
    Wait Until Element Is Visible    //button[@id="open-detail-panel-button" and @title="Open details panel"]

Get RETU Text
    Wait Element Visible And Click    xpath=${RETU_BODY}    1min
    ${text}    get text    xpath=${RETU_BODY}
    log to console    ${text}
    set test variable    ${text}
    [Return]    ${text}

Get RAE Text
    Wait Element Visible And Click    xpath=${RAE_TILE_BODY}    1min
    ${text}    get text    xpath=${RAE_TILE_BODY}
    log to console    ${text}
    set test variable    ${text}
    [Return]    ${text}

Get RAEU Text
    Wait Element Visible And Click    xpath=${RAEU_BODY}    1min
    ${text}    get text    xpath=${RAEU_BODY}
    log to console    ${text}
    set test variable    ${text}
    [Return]    ${text}

Get Details Pannel Text
    [Arguments]    ${unit}=associated-antenna-units
    Open Details Panel
    Wait Until Element Is Visible    id=${unit}-arrayOfTexts    1min
    ${text}    get text    id=${unit}-arrayOfTexts
    log to console    ${text}
    set test variable    ${text}

Go To Site View Page
    Wait Element Visible And Click    xpath=//i[contains(@class,'mdi-shield-check')]    1min
    Wait Element Visible And Click    xpath=//span[contains(text(),'Site View')]    1min
    sleep    3s

Check RETU Angles
    [Arguments]    ${angle}=3\xb0    ${Mechangle}=4\xb0    ${Minangle}=0\xb0    ${Maxangle}=7\xb0
    Get RETU Text
    should contain    ${text}    ${angle}    ${Mechangle}    ${Minangle}    ${Maxangle}

Check RETU Operational Status
    [Arguments]    ${status}=Enabled
    Go To ALD Status Page
    click element    xpath=${RET_STATUS_VIEW}
    Wait Element Visible And Click    xpath=${RETU_WIDGET}    1min
    Open Details Panel
    Wait Until Element Is Visible    id=retu-states-table
    ${text}    get text    id=retu-states-table
    log to console    ${text}
    should contain    ${text}    ${status}
    Hide Details Panel

Check LNA Operational Status
    [Arguments]    ${status}=Enabled
    Open WEBEM and Login
    Go To ALD Status Page
    click element    xpath=${MHA_STATUS_VIEW}
    Wait Element Visible And Click    xpath=${MHA_WIDGET}    1min
    Open Details Panel
    Wait Until Element Is Visible    id=lna-states-table
    ${text}    get text    id=lna-states-table
    log to console    ${text}
    should contain    ${text}    ${status}
    Hide Details Panel
    [Teardown]    Logout And Close WEBEM

Select ALD By Filter
    [Arguments]    ${ald_id}=1
    Wait Element Visible And Click    xpath=//p-button[@id="filter-button"]    1min
    Wait Element Visible And Click    //span[text()='ALD ID:']//following-sibling::input
    wait until keyword succeeds    1min    10s    SeleniumLibrary.Input Text    //span[text()='ALD ID:']//following-sibling::input    ${ald_id}
    Wait Element Visible And Click    xpath=//p-button[@id="filter-button"]    1min

Check ALD Status In Detail Panel
    [Arguments]    ${operational_state}    ${availability_status}    ${procedural_status}
    Wait Until Element Is Visible    id=ald-states-table
    ${ald_states}    get text    id=ald-states-table
    should contain    ${ald_states}    ${operational_state}    ${availability_status}    ${procedural_status}

Go To Cell Status Page
    [Documentation]    Go To cell Status Page
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    none
    ...
    ...    Example
    ...    | Open WEBEM and Login |
    ...    | Go To ALD Status Page |
    log to console    go to site view panel
    Wait Element Visible And Click    xpath=//i[contains(@class,'mdi-shield-check')]    1min
    log to console    go to cell status panel
    Wait Element Visible And Click    xpath=//span[text()="Cells Status"]

Check Cell Status Under Cell Status View
    [Arguments]    ${cell_id}    ${operational_state}    ${Procedural_status}    ${blocking_state}
    log to console    Check Cell Status and cell should be ${blocking_state}
    Go To Cell Status Page
    wait until element is visible    xpath=//div[@class="vdu-cell-view" and @data-base-cell-id="${cell_id}"]    10s
    wait until element is visible    xpath=//div[@data-base-cell-id="${cell_id}"]//span[text()="${operational_state}"]    1min
    wait until element is visible    xpath=//div[@data-base-cell-id="${cell_id}"]//span[text()="${Procedural_status}"]    1min
    wait until element is visible    xpath=//i[@class="${blocking_state} ng-star-inserted"]    10s

Check Cell Status Under Site View
    [Arguments]    ${cell_id}    ${blocking_state}
    log to console    Check Cell Status under site view
    Go To Site View Page
    Element Should Be Visible    xpath=//div[@data-vducell-name="NRCELL-${cell_id}"]//i[@title="${blocking_state}"]
    log to console    Cell status under site view panel is ${blocking_state}

VDU RESET Via Webem
    Wait Element Visible And Click    xpath=//i[contains(@class,'mdi-view')]    10s
    Wait Element Visible And Click    xpath=//p-button[@title="Reset vDU"]    1min
    Wait Until Element Is Visible    xpath=//div[contains(@class,'p-confirm-dialog')]
    click Element    xpath=//button[contains(@class,"p-confirm-dialog-accept")]

Block Cell
    [Arguments]    ${cell_id}=1
    Wait Element Visible And Click    //status-shared-tile-grid//ot-card//div[text()=" NRCELL-${cell_id} "]/../..//button
    Wait Element Visible And Click    xpath=//span[text()="Block cell"]
    Wait Until Element Is Visible    xpath=//button[contains(@class,'p-confirm-dialog')]
    click Element    xpath=//button[contains(@class,"p-confirm-dialog-accept")]
    wait until element is visible    xpath=//div[contains(text(),"block operation finished")]    1min

Unblock Cell
    [Arguments]    ${cell_id}=1
    Wait Element Visible And Click    //status-shared-tile-grid//ot-card//div[text()=" NRCELL-${cell_id} "]/../..//button
    Wait Element Visible And Click    xpath=//span[text()="Unblock cell"]
    Wait Until Element Is Visible    xpath=//div[contains(@class,'p-confirm-dialog')]
    click button    xpath=//button[contains(@class,"p-confirm-dialog-accept")]
    wait until element is visible    xpath=//div[contains(text(),"unblock operation finished")]    1min

Check PE Parameter
    [Arguments]    ${para_name}    ${para_value}
    ${line_number}    Selenium2Library.Get Element Count    //parameter-editor-table//tbody//tr
    should not be equal    int(${line_number})    int(0)
    ${line_number}    Evaluate    ${line_number}+1
    FOR    ${row}    IN RANGE    1    ${line_number}
    ${return}    run keyword and ignore error    run keywords    table row should contain    xpath=//parameter-editor-table    ${row}
    ...    ${para_name}
    ...    AND    table row should contain    xpath=//parameter-editor-table    ${row}    ${para_value}
    should not contain    """${return}"""    should have had at least
    Exit For Loop if    """${return[0]}"""=="""PASS"""
    END
    should be true    """${return[0]}"""=="""PASS"""

Go To PE LNA
    Go To ALD Status Page
    click element    xpath=${MHA_STATUS_VIEW}
    Wait Element Visible And Click    xpath=${LNA_OPERATION_BUTTON}
    Wait Element Visible And Click    xpath=//span[contains(text(),'Go to PE (LNA-')]
    wait until element is visible    xpath=//span[contains(text(),"/LNA-")]

Go To PE LNA_R
    Go To ALD Status Page
    click element    xpath=${MHA_STATUS_VIEW}
    Wait Element Visible And Click    xpath=${LNA_OPERATION_BUTTON}
    Wait Element Visible And Click    xpath=//span[contains(text(),'Go to PE (LNA_R-')]
    wait until element is visible    xpath=//span[contains(text(),"/LNA_R-")]

Go To PE Page
    Wait Element Visible And Click    xpath=${DASHBOARD_SIDEBAR_CONFIGURATION}
    Wait Element Visible And Click    xpath=${PARAMETER_EDITOR}

Search Parameter In Current Plan Via WEBEM
    [Arguments]    ${object}    ${abbreviation}
    Go To PE Page
    wait until element is visible    xpath=${OBJECT_FILTER}
    input text    ${OBJECT_FILTER}    ${object}
    Wait Element Visible And Click    xpath=//span[contains(text(),'${object}')]
    wait until element is visible    xpath=${ABBREVIATION_FILTER}
    input text    ${ABBREVIATION_FILTER}    ${abbreviation}
    wait until element is visible    xpath=//td[contains(@id,'parameter-abbreviation/${abbreviation}')]
    ${value}    get text    xpath=//td[contains(@id,'parameter-abbreviation/con')]/following-sibling::td[contains(@id,'parameter-value')]
    [Return]    ${value}

Go To PE Search Page
    Wait Element Visible And Click    xpath=${DASHBOARD_SIDEBAR_CONFIGURATION}
    Wait Element Visible And Click    xpath=${PARAMETER_SEARCH}

Check PE Parameter Under Search Result
    [Arguments]    ${para_name}    ${para_value}
    ${line_number}    Selenium2Library.Get Element Count    //table//tbody//tr
    should not be equal    int(${line_number})    int(0)
    ${line_number}    Evaluate    ${line_number}+1
    FOR    ${row}    IN RANGE    1    ${line_number}
    ${return}    run keyword and ignore error    run keywords    table row should contain    xpath=//table    ${row}
    ...    ${para_name}
    ...    AND    table row should contain    xpath=//table    ${row}    ${para_value}
    should not contain    """${return}"""    should have had at least
    Exit For Loop if    """${return[0]}"""=="""PASS"""
    END
    should be true    """${return[0]}"""=="""PASS"""

Install FCE
    [Arguments]    ${fce_worker_file}
    [Documentation]    Install FCE on WebEM
    ...    | Input Parameters | Man. | Description |
    ...    | fce_worker_file | yes | e.g. fce worker file path |
    ...
    ...    | Return Value | Description |
    ...    | msg | Install FCE success, return empty, or return error message |
    ...
    ...    Example
    ...    | ${msg} | Install FCE | fce_worker_file=${TEST_LOG_DIRECTORY}/vDUCNF00_0.300.14151_fce-worker.zip |
    ${msg}    Set Variable
    Go To Configuration Automation
    Selenium2Library.Choose File    //ot-upload[@id="install-fce"]//input    ${fce_worker_file}
    Sleep    20s
    Capture Page Screenshot
    ${is_succeed}    Run Keyword And Return Status    Wait Until Element Is Enabled    //span[contains(text(),'Install FCT')]/../input    20s
    Return From Keyword If    ${is_succeed}    ${msg}
    Wait Until Element Is Visible    //div[@role="dialog"]//span[contains(text(),"FCE installation failed")]    10s
    ${msg}    Selenium2Library.Get Text    //div[@role="dialog"]//blocks-installed-dialog/div
    Selenium2Library.Click Element    //div[@role="dialog"]//div[contains(@class,"p-dialog-footer")]//button
    [Return]    ${msg}

Install FCT
    [Arguments]    ${fct_file}
    [Documentation]    Install FCT
    ...    | Input Parameters | Man. | Description |
    ...    | fct_file | yes | e.g. fct file path |
    ...
    ...    | Return Value | Description |
    ...    | msg | Install FCT success, return empty, or return error message |
    ...
    ...    Example
    ...    | ${msg} | Install FCT | fct_file=${TEST_LOG_DIRECTORY}/FCT_Files/FCT_PDCCH_MultiRelease.xlsx |
    ${msg}    Set Variable
    Go To Configuration Automation
    Selenium2Library.Choose File    //ot-upload[@id="install-fct"]//input    ${fct_file}
    Sleep    10s
    Capture Page Screenshot
    ${is_fail}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...    //div[@role="dialog"]//span[contains(text(),"FCT installation failed")]    10s
    Return From Keyword If    '${is_fail}'=='False'    ${msg}
    ${msg}    Selenium2Library.Get Text    //div[@role="dialog"]//blocks-installed-dialog/div
    Selenium2Library.Click Element    //div[@role="dialog"]//div[contains(@class,"p-dialog-footer")]//button
    [Return]    ${msg}

Get FCE Feature List
    [Documentation]    Get FCE Feature List installed on BTS
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...    | Return Value | Description |
    ...    | list_FCE_features | return FCE features list |
    ...
    ...    Example
    ...    | ${list_FCE_features} | Get FCE Feature List |
    Go To Configuration Automation
    Wait Element Visible And Click    //p-dropdown[@id="feature"]
    ${elements}    Selenium2Library.Get WebElements    //p-dropdown[@id="feature"]//p-dropdownitem/li/span
    ${list_FCE_features}    Create List
    FOR    ${element}    IN    @{elements}
    ${item}    Selenium2Library.Get Text    ${element}
    Append To List    ${list_FCE_features}    ${item}
    END
    Collapse Dropdown List    //p-dropdown[@id="feature"]//div[@role="button" and @aria-expanded="true"]
    [Return]    ${list_FCE_features}

Go To Configuration Automation
    [Documentation]    Go To Configuration Automation page
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Go To Configuration Automation  |
    Go To PE Page
    Wait Element Visible And Click    xpath=//span[contains(text(),'Configuration Automation')]

Collapse Dropdown List
    [Arguments]    ${xpath}
    [Documentation]    Collapse Dropdown List
    ...    | Input Parameters | Man. | Description |
    ...    | xpath | yes | e.g. dropdown list xpath |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Collapse Dropdown List | xpath=${dropdown_xpath} |
    ${is_expanded}    Run Keyword And Return Status    Element Should Be Visible    ${xpath}
    Run Keyword If    ${is_expanded}    Selenium2Library.Click Element    ${xpath}
    Wait Until Element Is Not Visible    ${xpath}    3s

Get Button States Of Configuration Automation
    [Documentation]    Get buttons status on Configuration Automation page
    ...    | Input Parameters | Man. | Description |
    ...    | None |
    ...    | Return Value | Description |
    ...    | dic_button_states | buttons state format:dictionary|
    ...
    ...    Example
    ...    | ${dic_button_states} | Get Button States Of Configuration Automation |
    Go To Configuration Automation
    ${empty_list}    Create List
    ${dic_button_states}    Create Dictionary    select_feature_states=${false}    list_FCE_features=${empty_list}
    ${install_fce_states}    Run Keyword And Return Status    Wait Until Element Is Enabled    //ot-upload[@id="install-fce"]//input
    ${install_fct_states}    Run Keyword And Return Status    Selenium2Library.Element Should Be Enabled    //ot-upload[@id="install-fct"]//input
    ${atr}    Selenium2Library.Get Element Attribute    //p-dropdown[@id="selectPlan"]/div[contains(@class,"p-dropdown")]    class
    ${select_plan_states}    Run Keyword And Return Status    Should Not Contain    ${atr}    p-disabled
    Set To Dictionary    ${dic_button_states}    install_fce_states=${install_fce_states}
    ...    install_fct_states=${install_fct_states}    select_plan_states=${select_plan_states}
    ${not_install_FCE}    Run Keyword And Return Status    Should Not Be True    ${install_fct_states}
    Return From Keyword If    ${not_install_FCE}    ${dic_button_states}
    ${atr}    Selenium2Library.Get Element Attribute    //p-dropdown[@id="feature"]/div[contains(@class,"p-dropdown")]    class
    ${select_feature_states}    Run Keyword And Return Status    Should Not Contain    ${atr}    p-disabled
    Set To Dictionary    ${dic_button_states}    select_feature_states=${select_feature_states}
    ${list_FCE_features}    Get FCE Feature List
    Set To Dictionary    ${dic_button_states}    list_FCE_features=${list_FCE_features}
    [Return]    ${dic_button_states}

Select Feature In Configuration Automation
    [Arguments]    ${feature_name}
    [Documentation]    Select Feature In Configuration Automation
    ...    | Input Parameters | Man. | Description |
    ...    | xpath | yes | e.g. dropdown list xpath |
    ...    | Return Value | Description |
    ...    | objects | e.g.:[NRCELL]  format:list |
    ...
    ...    Example
    ...    |${object} | Select Feature In Configuration Automation | feature_name=PDCCH_Config_Recommendations_4.7.1 |
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

Select Object In Configuration Automation
    [Arguments]    ${object_name}
    [Documentation]    Select Object In Configuration Automation
    ...    | Input Parameters | Man. | Description |
    ...    | object_name | yes | e.g. dropdown list xpath |
    ...    | Return Value | Description |
    ...    | dic_param_value | e.g.:{'Cell Coverage Level (PDCCH FCT Intent):': 'normal','selected_MOs': ['NRCELL-1', 'NRCELL-2']} |
    ...    | format:dictionary |
    ...
    ...    Example
    ...    |${dic_param_value} | Select Object In Configuration Automation | object_name=NRCELL |
    Wait Element Visible And Click    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//div[@role="button"]
    Wait Element Visible And Click
    ...    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//p-dropdownitem/li/span[text()="${object_name}"]
    Collapse Dropdown List    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//div[@role="button" and @aria-expanded="true"]
    ${dic_param_value}    Create Dictionary
    ${elements}    Selenium2Library.Get WebElements    //div[@blockpanelcontent]//label[contains(@class,"p-element")]
    FOR    ${element}    IN    @{elements}
    ${item}    Selenium2Library.Get Text    ${element}
    ${selected_value}    Selenium2Library.Get Text
    ...    //div[@blockpanelcontent]//label[text()="${item}"]/..//p-dropdown//span[contains(@class,"p-dropdown-label")]
    Set To Dictionary    ${dic_param_value}    ${item}    ${selected_value}
    END
    ${selected_objects_str}    Selenium2Library.Get Text    //p-multiselect//div[contains(@class,"p-multiselect-label-container")]/div
    ${tmp_selected_objects}    Split String    ${selected_objects_str}    ,
    ${selected_objects}    Create List
    FOR    ${selected_object}    IN    @{tmp_selected_objects}
    Append To List    ${selected_objects}    ${selected_object.strip()}
    END
    Set To Dictionary    ${dic_param_value}    selected_MOs    ${selected_objects}
    [Return]    ${dic_param_value}

Get Feature Detail Info On CA
    [Documentation]    Get Feature Detail Info On CA
    ...    | Input Parameters | Man. | Description |
    ...    | None |
    ...    | Return Value | Description |
    ...    | FCT_Prop_Dic | dictionary. FCT detail info |
    ...
    ...    Example
    ...    | ${FCT_Prop_Dic} | Get Feature Detail Info On CA |
    Open Details Panel
    Wait Until Element Is Visible    //div[contains(@class,"details-panel")]//cem-details-content-component    3s
    ${FCT_Detail_Header}    Get Text
    ...    //div[contains(@class,"details-panel")]//cem-details-content-component//span[contains(@class,"cem-details-component-title")]
    Should Be Equal As Strings     ${FCT_Detail_Header}    FCT tool
    ${FCT_Prop_Dic}    Create Dictionary
    ${tmp}    Set Variable
    ...    //div[contains(@class,"details-panel")]//cem-details-content-component
    ${Count}    Selenium2Library.Get Element Count    ${tmp}//div[contains(@class,"cem-details-component-section-item")]
    FOR    ${index}    IN RANGE    1    ${Count}+1
    ${label}    Selenium2Library.Get Text    ${tmp}//div[contains(@class,"cem-details-component-section-item")][${index}]/label
    ${span}    Selenium2Library.Get Text    ${tmp}//div[contains(@class,"cem-details-component-section-item")][${index}]/span
    Set To Dictionary    ${FCT_Prop_Dic}    ${label}=${span}
    END
    [Return]    ${FCT_Prop_Dic}

Get Values Of Param On CA
    [Arguments]    ${param}
    [Documentation]    Get Values Of Param On CA
    ...    | Input Parameters | Man. | Description |
    ...    | param | Yes | parameter name on CA e.g.:Specific BWP Size |
    ...    | Return Value | Description |
    ...    | list_value | e.g. ['n41', 'n45', 'n50', 'n70', 'n75', 'n100', 'n122', 'n131', 'n148', 'n155', 'n203', 'n239', 'n256']  format:list|
    ...
    ...    Example
    ...    | ${list_value} | Get Values Of Param On CA | param=Specific BWP Size |
    Wait Element Visible And Click    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//div[@role="button"]
    Wait Until Element Is Visible    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//p-dropdownitem//span
    ${value_elements}    Selenium2Library.Get WebElements
    ...    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//p-dropdownitem//span
    ${list_value}    Create List
    FOR    ${element}    IN    @{value_elements}
    ${value}    Selenium2Library.Get Text    ${element}
    Append To List    ${list_value}    ${value}
    END
    Collapse Dropdown List    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//div[@role="button" and @aria-expanded="true"]
    [Return]    ${list_value}

Get All Param And Value Of Feature Object
    [Arguments]    ${feature_name}    ${object_name}
    [Documentation]    Get All Param And Value Of Feature Object
    ...    | Input Parameters | Man. | Description |
    ...    | feature_name | Yes | feature name e.g.PDCCH_Config_Recommendations_4.7.1 |
    ...    | object_name | Yes| object name e.g. NRCELL |
    ...    | Return Value | Description |
    ...    | dic_param_value | dictionary, "{Cell Coverage Level (PDCCH FCT Intent):": "[normal, large]",|
    ...    | "Initial BWP Mode (PDCCH FCT Intent):": "[widerInitBWP, sameAsCoreset0]"} |
    ...
    ...    Example
    ...    | ${dic_param_value} | Get All Param And Value Of Feature Object | feature_name=PDCCH_Config_Recommendations_4.7.1 | object_name=NRCELL |
    Go To Configuration Automation
    ${objects}    Select Feature In Configuration Automation    ${feature_name}
    Wait Until Element Is Visible
    ...    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//div[@role="button"]    10s    Button for Object not visible.
    Selenium2Library.Click Element    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//div[@role="button"]
    Wait Element Visible And Click
    ...    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//p-dropdownitem/li/span[text()="${object_name}"]
    Collapse Dropdown List    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//div[@role="button" and @aria-expanded="true"]
    ${dic_param_value}    Create Dictionary
    ${elements}    Selenium2Library.Get WebElements    //div[@blockpanelcontent]//label[contains(@class,"p-element")]
    FOR    ${element}    IN    @{elements}
    ${param}    Selenium2Library.Get Text    ${element}
    ${list_value}    Get Values Of Param On CA    ${param}
    Set To Dictionary    ${dic_param_value}    ${param}    ${list_value}
    END
    [Return]    ${dic_param_value}

Set Param Value Of Feature Object
    [Arguments]    ${feature_name}    ${object_name}    ${dic_value_to_set}
    [Documentation]    Set Param Value Of Feature Object
    ...    | Input Parameters | Man. | Description |
    ...    | feature_name | yes | e.g. PDCCH_Config_Recommendations_4.7.1 |
    ...    | object_name | yes | e.g. NRCELL |
    ...    | dic_value_to_set | yes | dictionary. parametername and value need set |
    ...    | Return Value | Description |
    ...    | None |
    ...
    ...    Example
    ...    | Set Param Value Of Feature Object | feature_name=PDCCH_Config_Recommendations_4.7.1 | object_name=NRCELL |
    ...    | dic_value_to_set={'PUCCH Size LTE (PDCCH FCT Intent):': '16', 'PUCCH Size(PDCCH FCT Intent):': '10'} |
    ${objects}    Select Feature In Configuration Automation    ${feature_name}
    Wait Element Visible And Click    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//div[@role="button"]
    Wait Element Visible And Click
    ...    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//p-dropdownitem/li/span[text()="${object_name}"]
    Collapse Dropdown List    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//div[@role="button" and @aria-expanded="true"]
    ${mos_not_dropdown}    Run Keyword And Return Status    Selenium2Library.Page Should Not Contain Element    //p-multiselect//p-multiselectitem
    Run Keyword If    ${mos_not_dropdown}    Selenium2Library.Click Element    //p-multiselect//div[contains(@class,"p-multiselect-trigger")]/span
    ${empty_list}    Create List
    ${list_MOs_to_select}    Pop From Dictionary    ${dic_value_to_set}    selected_MOs    ${empty_list}
    ${elements}    Selenium2Library.Get WebElements    //p-multiselect//p-multiselectitem/li
    FOR    ${element}    IN    @{elements}
    ${MO_name}    Selenium2Library.Get Element Attribute    ${element}    aria-label
    ${att_class}    Selenium2Library.Get Element Attribute
    ...    //p-multiselect//p-multiselectitem/li[@aria-label="${MO_name}"]//span[contains(@class,"p-checkbox-icon")]    class
    ${is_selected}    Run Keyword And Return Status    Should Contain    ${att_class}    pi
    ${should_select}    Run Keyword And Return Status    List Should Contain Value    ${list_MOs_to_select}    ${MO_name}
    Continue For Loop If    "${is_selected}"=="${should_select}"
    Selenium2Library.Click Element    //p-multiselect//p-multiselectitem//span[text()="${MO_name}"]
    END
    ${params}    Get Dictionary Keys    ${dic_value_to_set}
    FOR    ${param}    IN    @{params}
    ${value_to_set}    Get From Dictionary    ${dic_value_to_set}    ${param}
    Wait Element Visible And Click    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//div[@role="button"]
    Wait Until Element Is Visible    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//p-dropdownitem//span
    Selenium2Library.Click Element
    ...    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//p-dropdownitem//span[text()="${value_to_set}"]
    END

Create Delta Plan
    [Arguments]    ${plan_name}
    [Documentation]    Create Delta Plan on WebEM
    ...    | Input Parameters | Man. | Description |
    ...    | plan_name | yes | plan name |
    ...    | Return Value | Description |
    ...    | None |
    ...
    ...    Example
    ...    | Create Delta Plan | plan_name=${plan name} |
    Wait Element Visible And Click    //configuration-shared-create-delta-plan//button
    Selenium2Library.Wait Until Element Is Visible    //input[@id="edit-plan-plan-name-input"]
    Selenium2Library.Input Text    //input[@id="edit-plan-plan-name-input"]    ${plan_name}
    Selenium2Library.Click Element    //p-button[@id="edit-plan-create-button"]/button

Delete Plan
    [Arguments]    ${plan_name}
    [Documentation]    Delete Plan on WebEM
    ...    | Input Parameters | Man. | Description |
    ...    | plan_name | yes | plan name |
    ...    | Return Value | Description |
    ...    | None |
    ...
    ...    Example
    ...    | Delete Plan | plan_name=${plan name} |
    Go To PE Page
    Wait Element Visible And Click    //configuration-shared-plans-dropdown//div[@role="button"]
    ${count}    Selenium2Library.Get Element Count    //div[@onoverlayanimationend]//span[text()=" ${plan_name}"]
    Return From Keyword If    '${count}'=='${0}'
    Click Element    //div[@onoverlayanimationend]//span[text()=" ${plan_name}"]
    Click Element    //p-button[@id="webem-parameter-editor-menu-delete-plan-button"]/button
    Wait Until Element Is Visible
    ...    //p-confirmdialog[@id="webem-parameter-editor-menu-dialog"]//span[text()="Do you want to delete plan ${plan_name}?"]
    Click Element    //p-confirmdialog[@id="webem-parameter-editor-menu-dialog"]//span[text()="OK"]/..

Validate Plan
    [Arguments]    ${plan_name}
    [Documentation]    Validate Plan on WebEM
    ...    | Input Parameters | Man. | Description |
    ...    | plan_name | yes | plan name |
    ...    | Return Value | Description |
    ...    | has_no_error | True or False |
    ...
    ...    Example
    ...    | ${has_no_error} | Validate Plan | plan_name=${plan name} |
    ${has_no_error}    Set Variable    ${False}
    Go To PE Page
    Wait Element Visible And Click    //span[text()="Errors"]
    Wait Element Visible And Click    //configuration-shared-plans-dropdown//div[@role="button"]
    Wait Element Visible And Click    //div[@onoverlayanimationend]//span[text()=" ${plan_name}"]
    Click Element    //p-button[@id="webem-parameter-editor-menu-plan-validation-button"]/button
    Wait Until Page Contains Element    //span[contains(text(),"Validation in progress")]
    Wait Until Page Does Not Contain Element    //span[contains(text(),"Validation in progress")]    120s
    ${icon_error}    Selenium2Library.Get Element Count    //span[text()="Errors"]/..//i
    ${has_no_error}    Evaluate    ${icon_error}<${1}
    [Return]    ${has_no_error}

Activate Plan
    [Arguments]    ${plan_name}    ${despite_reset}    ${despite_cell_lock}    ${download_only}=${false}
    [Documentation]    Activate Plan on WebEM
    ...    | Input Parameters | Man. | Description |
    ...    | plan_name | yes | plan name |
    ...    | despite_reset | yes | True or False |
    ...    | despite_cell_lock | yes | True or False |
    ...    | download_only | no | True or False |
    ...    | Return Value | Description |
    ...    | None |
    ...
    ...    Example
    ...    | Activate Plan | plan_name='TA_CB009451-D_001' | despite_reset=False | despite_cell_lock=False | download_only=False |
    Go To PE Page
    Wait Element Visible And Click    //configuration-shared-plans-dropdown//div[@role="button"]
    Wait Element Visible And Click    //div[@onoverlayanimationend]//span[text()=" ${plan_name}"]
    Click Element    //ui-webem-overlay-menu-bar[@id="webem-parameter-editor-menu-plan-activation-button"]//button
    Wait Until Element Is Visible    //div[contains(@class,"activation-dialog-body")]
    Run Keyword If    ${despite_reset}    Click Element    //p-checkbox[@id="force-plan-activation-despite-reset"]
    Run Keyword If    ${despite_cell_lock}    Click Element    //p-checkbox[@id="force-plan-activation-despite-cell-locking"]
    Run Keyword If    ${download_only}    Click Element    //p-checkbox[@id="download-plan-without-activation-checkbox"]
    Click Element    //p-button[@id="execute-activate-plan"]/button
    Wait Until Element Is Visible    //div[@role="dialog"]//span[text()="Activate Plan Status"]    60s
    Wait Until Element Is Visible    //p-button[@id="activate-modal-done"]/button    300s
    ${startup_view_exist}    Run Keyword And Return Status    Wait Until Element Is Visible    //p-dynamicdialog//span[text()="Start-up View"]    10s
    Run Keyword If    ${startup_view_exist}    Click Element    //vdu-startup-view-vdu-startup-view//span[text()="Close"]
    Wait Until Keyword Succeeds    10s    2s    Click Element    //p-button[@id="activate-modal-done"]/button
    Wait Until Element Is Not Visible    //div[@role="dialog"]//span[text()="Activate Plan Status"]    10s

Get Plan Options From WebEM CA
    [Documentation]    Get Plan Options From WebEM CA
    ...    | Input Parameters | Man. | Description |
    ...    | None |
    ...    | Return Value | Description |
    ...    | list_plan | plan name list |
    ...    | current_plan | current plan |
    ...
    ...    Example
    ...    | ${list_plan} | ${current_plan} | Get Plan Options From WebEM CA |
    Go To Configuration Automation
    ${current_plan}    Selenium2Library.Get Text    //p-dropdown[@id="selectPlan"]//span[contains(@class,"p-dropdown-label")]
    Wait Element Visible And Click    //p-dropdown[@id="selectPlan"]//div[@role="button"]
    ${plan_options}    Selenium2Library.Get WebElements    //p-dropdown[@id="selectPlan"]//p-dropdownitem/li/span
    ${list_plan}    Create List
    FOR    ${item}    IN    @{plan_options}
    ${plan}    Selenium2Library.Get Text    ${item}
    Append To List    ${list_plan}    ${plan}
    END
    Collapse Dropdown List    //p-dropdown[@id="selectPlan"]//div[@role="button" and @aria-expanded="true"]
    [Return]    ${list_plan}    ${current_plan}

Select Plan On CA
    [Arguments]    ${plan_name}
    [Documentation]    Select Plan On CA
    ...    | Input Parameters | Man. | Description |
    ...    | plan_name | yes | plan name |
    ...    | Return Value | Description |
    ...    | None |
    ...
    ...    Example
    ...    | Select Plan On CA | plan_name=TA_CB009451-C_001 |
    Wait Element Visible And Click    //p-dropdown[@id="selectPlan"]//div[@role="button"]
    Wait Element Visible And Click    //p-dropdown[@id="selectPlan"]//p-dropdownitem/li/span[text()="${plan_name}"]

Calculate On CA Page And Get Results
    [Documentation]    Calculate On CA Page And Get Results
    ...    | Input Parameters | Man. | Description |
    ...    | None |
    ...    | Return Value | Description |
    ...    | result | e.g. There are warning or error in checks. |
    ...    | table_head_list | list. e.g. ['Check ID', 'Object name', 'Severity', 'Checked condition'] |
    ...    | validation_result | list. Detail info in result table |
    ...
    ...    Example
    ...    | ${result} | ${table_head_list} | ${validation_result} | Calculate On CA Page And Get Results |
    Wait Element Visible And Click    //cem-operation-button//button/span[text()="Calculate"]
    ${result}    ${table_head_list}    ${validation_result}    ${addoutput_th_list}    ${add_output_param}    Get FCT Caculate Result
    [Return]    ${result}    ${table_head_list}    ${validation_result}    ${addoutput_th_list}    ${add_output_param}

Audit On CA Page And Get Results
    [Documentation]    Audit On CA Page And Get Results
    ...    | Input Parameters | Man. | Description |
    ...    | None |
    ...    | Return Value | Description |
    ...    | result | e.g. There are warning or error in checks. |
    ...    | table_head_list | list. e.g. ['Check ID', 'Object name', 'Severity', 'Checked condition'] |
    ...    | validation_result | list. Detail info in result table |
    ...
    ...    Example
    ...    | ${result} | ${table_head_list} | ${validation_result} | Audit On CA Page And Get Results |
    Wait Element Visible And Click    //cem-operation-button//button/span[text()="Audit"]
    ${result}    ${table_head_list}    ${validation_result}    ${addoutput_th_list}    ${add_output_param}    Get FCT Caculate Result
    [Return]    ${result}    ${table_head_list}    ${validation_result}    ${addoutput_th_list}    ${add_output_param}

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
    [Documentation]    Get FCT Caculate Result
    ...    | Input Parameters | Man. | Description |
    ...    | None |
    ...    | Return Value | Description |
    ...    | result | e.g. There are warning or error in checks. |
    ...    | table_head_list | list. e.g. ['Check ID', 'Object name', 'Severity', 'Checked condition'] |
    ...    | validation_result | list. Detail info in result table |
    ...
    ...    Example
    ...    | ${result}| ${table_head_list} | ${validation_result} | Get FCT Caculate Result |
    Wait Until Element Is Visible    //blocks-configuration-automation-results//p-table[1]    30s
    Wait Until Element Is Visible    //blocks-configuration-automation-results//p-table[@id="nonNiddParameterTable"]
    ## Validation results
    ${result}    Selenium2Library.Get Text    //blocks-configuration-automation-results//ot-instruction/div/div
    ${validate_th_list}    ${validation_result}    Get FCT Operation Result From GUI Table
    ...    //blocks-configuration-automation-results//p-table[1]
    ## Additional (non-NIDD) output parameters
    ${addoutput_th_list}    ${add_output_param}    Get FCT Operation Result From GUI Table
    ...    //blocks-configuration-automation-results//p-table[@id="nonNiddParameterTable"]
    [Return]    ${result}    ${validate_th_list}    ${validation_result}    ${addoutput_th_list}    ${add_output_param}

Generate Column Dictionary For Row
    [Arguments]    ${table_head_list}    ${one_row_colunms}
    [Documentation]    Generate Column Dictionary For Row
    ...    | Input Parameters | Man. | Description |
    ...    | table_head_list | list. e.g. ['Check ID', 'Object name', 'Severity', 'Checked condition'] |
    ...    | one_row_colunms | one row data |
    ...    | Return Value | Description |
    ...    | row_value | dictionary. one row data format as dictionary |
    ...
    ...    Example
    ...    | ${row_value} | Generate Column Dictionary For Row | table_head_list= ${table_head_list} | one_row_colunms=${td_list} |
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

Apply All On CA
    [Documentation]    Apply All On CA
    ...    | Input Parameters | Man. | Description |
    ...    | None |
    ...    | Return Value | Description |
    ...    | result | e.g. Success |
    ...
    ...    Example
    ...    | ${result} | Apply All On CA |
    Wait Element Visible And Click    //blocks-configuration-automation-apply//button/span[text()="Apply All"]
    Wait Until Element Is Visible    //blocks-configuration-automation-apply//ot-instruction//span
    ${result}    Selenium2Library.Get Text    //blocks-configuration-automation-apply//ot-instruction//span
    [Return]    ${result}

Filter MOs Of Plan On PE
    [Arguments]    ${filter}    ${plan_name}=CURRENT_PLAN
    [Documentation]    Filter MOs Of Plan On PE
    ...    | Input Parameters | Man. | Description |
    ...    | filter | Yes | NRCELL- |
    ...    | plan_name | No |
    ...    | Return Value | Description |
    ...    | list_MOs | MO list |
    ...
    ...    Example
    ...    | ${list_MOs} | Filter MOs Of Plan On PE | filter="NRCELL-" |
    Go To PE Page
    Wait Element Visible And Click    //configuration-shared-plans-dropdown//div[@role="button"]
    Wait Element Visible And Click    //div[@onoverlayanimationend]//span[text()=" ${plan_name}"]
    ${list_MOs}    Create List
    Wait Until Element Is Enabled    //input[@id="filter-input-field-plans-tree"]
    Selenium2Library.Input Text    //input[@id="filter-input-field-plans-tree"]    ${filter}
    Wait Until Page Contains Element    //tree-viewport//span[@class="highlight-search-result"]
    ${elements}    Selenium2Library.Get WebElements    //tree-viewport//span[@class="highlight-search-result"]
    FOR    ${element}    IN    @{elements}
    Selenium2Library.Click Element    ${element}
    Sleep    1s
    Wait Until Page Does Not Contain Element    //p-treetable//div[contains(@class,"p-treetable-loading")]
    Wait Until Element Is Visible    //parameter-editor//span[@id="object-distname"]
    ${dn}    Selenium2Library.Get Text    //parameter-editor//span[@id="object-distname"]
    Append To List    ${list_MOs}    ${dn}
    END
    [Return]    ${list_MOs}

Import CSV On CA
    [Arguments]     ${csv_path}
    [Documentation]    Import CSV On CA
    ...    | Input Parameters | Man. | Description |
    ...    | csv_path | Yes | imported CSV file path |
    ...    | Return Value | Description |
    ...    | None |
    ...
    ...    Example
    ...    | Import CSV On CA | csv_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/AIC/RAN_PZ_HAZ_1/HAZ11/TestData/additionalInfo_11085.csv |
    Selenium2Library.Choose File    //p-fileupload//span[contains(text(),'Import CSV...')]/../input    ${csv_path}
    ${msg}    Selenium2Library.Get Text    //blocks-configuration-automation//ot-instruction/div/div
    Should Be Equal As Strings    ${msg}    Success
    ${file_selected_name}    Selenium2Library.Get Text    //cem-block-panel//div[@class='p-fileupload-buttonbar']/div/span[1]
    ${csv_file_name}    Fetch From Right     ${csv_path}    /
    Should Be Equal As Strings   ${file_selected_name}    ${csv_file_name}

Element Should Not Be Exist
    [Arguments]    ${xpath}
    [Documentation]    Element Should Not Be Exist
    ...    | Input Parameters | Man. | Description |
    ...    | xpath | Yes | Element xpath |
    ...    | Return Value | Description |
    ...    | None |
    ...
    ...    Example
    ...    | Element Should Not Be Exist | xpath=${xpath} |
    ${count}    Selenium2Library.Get Element Count    ${xpath}
    Should Be Equal As Integers    ${count}    ${0}

Compare And Apply Success On CA And Check Result
    [Arguments]    ${parameters_list}
    [Documentation]    Compare And Apply Success On CA And Check Result
    ...    | Input Parameters | Man. | Description |
    ...    | parameters_list | parameter value need return |
    ...    | Return Value | Description |
    ...    | DN_paramValues |  return e.g. MRBTS-11084/NRBTS-11084/NRCELL-1:{pucchSize:30}
    ...
    ...    Example
    ...    | ${DN_paramValues} | Compare And Apply Success On CA And Check Result | [pucchSize] |
    Wait Element Visible And Click     //blocks-configuration-automation-apply//button/span[text()='Compare and Apply']
    Wait Until Element Is Visible    //ot-dialog[@id='compareAndApply']//div[contains(@class,"ot-dialog-title") and text()=' Compare and Apply']
    Element Should Not Be Exist    //ot-dialog[@id='compareAndApply']//p-button[@disabled='true']//span[text()="Apply All"]
    Wait Element Visible And Click    //ot-dialog[@id='compareAndApply']//button/span[text()="Apply All"]
    Sleep    5s
    Wait Until Element Is Visible    //ot-dialog[@id='compareAndApply']//p-button[@disabled='true']//span[text()="Apply All"]
    ${apply_result}    Selenium2Library.Get Text
    ...    //ot-dialog[@id='compareAndApply']//div[@class="cem-operation-button"]//span[text()="Apply All"]/../../..//div/span
    Should Be Equal As Strings    ${apply_result}    Success
    ${count_row}    Selenium2Library.Get Element Count    //ot-dialog[@id="compareAndApply"]//div[contains(@class,"p-treetable-scrollable-body")]//tr
    ${DN_paramValues}    Create Dictionary
    FOR    ${r}    IN RANGE    ${1}    ${${count_row}+1}
    ${cur_val}    Selenium2Library.Get Text
	...    //ot-dialog[@id="compareAndApply"]//div[contains(@class,"p-treetable-scrollable-body")]//tr[${r}]/td[2]
    ${recomm_val}   Selenium2Library.Get Text
	...    //ot-dialog[@id="compareAndApply"]//div[contains(@class,"p-treetable-scrollable-body")]//tr[${r}]/td[3]
    Should Be Equal As Strings    ${cur_val.strip()}    ${recomm_val.strip()}
    ${param}    Selenium2Library.Get Text
    ...    //ot-dialog[@id="compareAndApply"]//div[contains(@class,"p-treetable-scrollable-body")]//tr[${r}]/td[1]/./span
    ${contain}    run keyword and return status    List Should Contain Value    ${parameters_list}    ${param}
    ${distName}    _Find DN Of Parmater On Compare And Apply Table     ${r}
    ${paramValues}    Create Dictionary    ${param}=${cur_val.strip()}
    Run Keyword If    ${contain}    Set To Dictionary    ${DN_paramValues}    ${distName}    ${paramValues}
    END
    Wait Element Visible And Click    //ot-dialog//ot-footer//p-button//span[text()="Close"]
    [Return]    ${DN_paramValues}

_Find DN Of Parmater On Compare And Apply Table
    [Arguments]    ${param_row}
    [Documentation]    Find the distname for one specify paramter On Compare And Apply Table of CA page
    ...    | Input Parameters | Man. | Description |
    ...    | param_row | Yes | row number of one specify parameter |
    ...    | Return Value | Description |
    ...    | distname | the distname of the specify parameter |
    ...
    ...    Example
    ...    | ${distname} | _Find DN Of Parmater On Compare And Apply Table | param_row = 4 |
    ${distname}    Set Variable
    FOR    ${r}    IN RANGE    ${1}    ${param_row}
    ${value}    Selenium2Library.Get Text
    ...    //ot-dialog[@id="compareAndApply"]//div[contains(@class,"p-treetable-scrollable-body")]//tr[${${param_row}-${r}}]/td[1]/./span
    ${DNs}    Get Regexp Matches    ${value}    ^MRBTS-\\d+(/\\w+-\\d+)*
    ${distname}    Set Variable If    "${DNs.__len__()}"!="0"    ${DNs[0]}    ${distname}
    Exit For Loop If    "${DNs.__len__()}"!="0"
    END
    [Return]    ${distname}

Compare And Apply On CA And Get Data
    [Arguments]    ${apply_all}
    [Documentation]    Compare And Apply Success On CA And Check Result
    ...    | Input Parameters | Man. | Description |
    ...    | apply_all | Yes | True or False |
    ...    | Return Value | Description |
    ...    | data_rows | compare and apply table data |
    ...
    ...    Example
    ...    | ${data_rows} | Compare And Apply On CA And Get Data | apply_all = False |
    Wait Element Visible And Click     //blocks-configuration-automation-apply//button/span[text()='Compare And Apply']
    Wait Until Element Is Visible    //ot-dialog[@id='compareAndApply']//div[contains(@class,"ot-dialog-title") and text()=' Compare And Apply']
    Element Should Not Be Exist    //ot-dialog[@id='compareAndApply']//p-button[@disabled='true']//span[text()="Apply All"]
    Run Keyword If    ${apply_all}    Wait Element Visible And Click    //ot-dialog[@id="compareAndApply"]//p-button//span[text()="Apply All"]
    ${count_row}    Selenium2Library.Get Element Count    //ot-dialog[@id="compareAndApply"]//div[contains(@class,"p-treetable-scrollable-body")]//tr
    ${data_rows}    Create List
    FOR    ${r}    IN RANGE    ${1}    ${count_row}
    ${p_name}    Selenium2Library.Get Text    //ot-dialog[@id="compareAndApply"]//div[contains(@class,"p-treetable-scrollable-body")]//tr[${r}]/td[1]
    ${cur_val}    Selenium2Library.Get Text   //ot-dialog[@id="compareAndApply"]//div[contains(@class,"p-treetable-scrollable-body")]//tr[${r}]/td[2]
    ${recomm_val}    Selenium2Library.Get Text
    ...    //ot-dialog[@id="compareAndApply"]//div[contains(@class,"p-treetable-scrollable-body")]//tr[${r}]/td[3]
    ${action}    Selenium2Library.Get Text    //ot-dialog[@id="compareAndApply"]//div[contains(@class,"p-treetable-scrollable-body")]//tr[${r}]/td[4]
    ${data}    Create Dictionary    param_name=${p_name}    cur_val=${cur_val}    recomm_val=${recomm_val}    action=${action}
    Append To List    ${data_rows}    ${data}
    END
    Wait Element Visible And Click    //ot-dialog//ot-footer//p-button//span[text()="Close"]
    [Return]    ${data_rows}

Enable Debug Function On CA
    [Documentation]    Enable debug function on CA and check dialog info, if checkbox is already checked, will not choose again.
    ...    | Input Parameters | Man. | Description |
    ...    | None |
    ...    | Return Value | Description |
    ...    | result | e.g. Success |
    ${pcheckbox_checked}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    //p-checkbox[@name="debugFunction"]/div[contains(@class,"p-checkbox-checked")]
    Return From Keyword If    ${pcheckbox_checked}
    Wait Element Visible And Click    //p-checkbox[@name="debugFunction"]
    Wait Until Element Is Visible    //p-dynamicdialog//div//blocks-installed-dialog
    ${dialog_info}    Selenium2Library.Get Text    //p-dynamicdialog//div//blocks-installed-dialog/div
    Should Be Equal As Strings    ${dialog_info}    If the debug function is enabled, it may cause low performance and application crash.
    Click Element    //p-dynamicdialog//button[1]/span[text()="Enable"]
    Wait Until Element Is Visible    //p-checkbox[@name="debugFunction"]/div[contains(@class,"p-checkbox-checked")]

Save Report From CA
    [Arguments]     ${save_button_xpath}    ${target_file_name}    ${target_path}    ${default_saved_path}
    [Documentation]    Save different kind report on CA according to button locator.
    ...    | Input Parameters | Man. | Description |
    ...    | target_path | Yes | target path to save audit report |
    ...    | default_saved_path | No | default savedd path in this browser |
    ...    | Return Value | Description |
    ...    | audit_report_filename | saved audit report filename |
    ...
    ...    Example
    ...    | Save Report From CA | save_button_xpath=xxx | target_file_name=xx.zip | target_path=/home/ute/test_results/ |
    ${output_before}    OperatingSystem.Run    sudo ls -l ${default_saved_path}/${target_file_name}
    ${files_before}    Split To Lines    ${output_before}
    ${files_before_formatted}    Create List
    FOR    ${item}    IN    @{files_before}
    ${filename}    Fetch From Right    ${item}    ${default_saved_path}
    Append To List     ${files_before_formatted}    ${filename}
    END
    Wait Element Visible And Click    ${save_button_xpath}
    Sleep    10s
    ${output_after}    OperatingSystem.Run    sudo ls -l ${default_saved_path}/${target_file_name}
    ${files_after}    Split To Lines    ${output_after}
    ${files_after_formatted}    Create List
    FOR    ${item}    IN    @{files_after}
    ${filename}    Fetch From Right    ${item}    ${default_saved_path}
    Append To List     ${files_after_formatted}    ${filename}
    END
    Remove Values From List    ${files_after_formatted}    @{files_before_formatted}
    ${file_count}    Get Length    ${files_after_formatted}
    Should Be Equal As Integers    ${file_count}    1
    ${file_list}    Split String    ${files_after_formatted[0]}    /
    ${new_file_name}    Set Variable    ${file_list[-1]}
    ${new_file_path}    Set Variable    ${default_saved_path}/${file_list[-1]}
    ${new_file_size}    Get File Size    ${new_file_path}
    Should Be True    ${new_file_size}>0
    Copy File    ${new_file_path}    ${target_path}
    [Return]    ${new_file_name}

Save Debug FCT On CA
    [Arguments]     ${target_path}    ${default_saved_path}=/tmp
    [Documentation]    Save debug FCT on CA
    ...    | Input Parameters | Man. | Description |
    ...    | target_path | Yes | target path to save audit report |
    ...    | default_saved_path | No | default savedd path in this browser |
    ...    | Return Value | Description |
    ...    | debug_fct_filename | saved audit report filename |
    ...
    ...    Example
    ...    | Save Debug FCT On CA | target_path=/home/ute/test_results/ |
    ${debug_fct_filename}    Save Report From CA
    ...    save_button_xpath=//div[contains(@class,'cem-block-panel-header')]/span[text()='Results']/..//span[text()='Save Debug FCT']
    ...    target_file_name=FCT_MRBTS-${MRBTS_ID_vDU}_*zip    target_path=${target_path}    default_saved_path=${default_saved_path}
    [Return]    ${debug_fct_filename}

Save JSON Report On CA
    [Arguments]     ${target_path}    ${default_saved_path}=/tmp
    [Documentation]    Save JSON Report On CA
    ...    | Input Parameters | Man. | Description |
    ...    | target_path | Yes | target path to save json report |
    ...    | default_saved_path | No | default savedd path in this browser |
    ...    | Return Value | Description |
    ...    | json_report_filename | saved audit report filename |
    ...
    ...    Example
    ...    | Save JSON Report On CA | target_path=/home/ute/test_results/|
    ${json_report_filename}    Save Report From CA
    ...    save_button_xpath=//div[contains(@class,'cem-block-panel-header')]/span[text()='Results']/..//span[text()='Save JSON Report']
    ...    target_file_name=FCE_result_MRBTS-${MRBTS_ID_vDU}_*json    target_path=${target_path}    default_saved_path=${default_saved_path}
    [Return]    ${json_report_filename}

Save Audit Report On CA
    [Arguments]    ${target_path}    ${default_saved_path}=/tmp
    [Documentation]    Save Audit Report On CA
    ...    | Input Parameters | Man. | Description |
    ...    | target_path | Yes | target path to save audit report |
    ...    | default_saved_path | No | default savedd path in this browser |
    ...    | Return Value | Description |
    ...    | audit_report_filename | saved audit report filename |
    ...
    ...    Example
    ...    | Save Audit Report On CA | target_path=/home/ute/test_results/ |
    ${audit_report_filename}    Save Report From CA
    ...    save_button_xpath=//div[contains(@class,'cem-block-panel-header')]/span[text()='Results']/..//span[text()='Save Audit Report']
    ...    target_file_name=Audit_report_*csv   target_path=${target_path}    default_saved_path=${default_saved_path}
    [Return]    ${audit_report_filename}

Set Rnd Debug Parameters
    [Arguments]    ${url}   ${object_name}    ${filter_param}   ${new_value}    ${timeout}=60   ${alias}=vdu_conn
    [Documentation]  Keyword for setting rnd parameter values or editing existing parameter values of given object name.
    ...    Author: Cao Ge
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Set Rnd Debug Parameters | Man. | Description |
    ...    | url | yes | str, url to coam vdu WebEM |
    ...    | object_name | yes | domain object name in which parameter need to set or edit，for example:"NrUlPhy" |
    ...    | filter_param | yes | str, parameter name,for example:"phyEventEnable" |
    ...    | new_value | yes | str, new value to set,for example:"5 - EPhyEvent_PuschTbCrcFailedWithReTx" |
    ...    | timeout | no | int, timeout for the element be available to click |
    ...    | alias | no | (optional) alias that the new coam vdu object |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Set Rnd Debug Parameters | url=https://10.56.9.114/login   object_name=NrUlPhy  filter_param=phyEventEnable
    ...      new_value=5 - EPhyEvent_PuschTbCrcFailedWithReTx   alias=vdu_conn |
    ...
    ${vdu_version}   Get vDU Version
    ${pattern}   re.compile   vDUCNF(.*?)_
    ${res}       re.findall   ${pattern}    ${vdu_version}
    ${version}  Set Variable   ${res[${0}]}
    svdu.login    url=${url}  password=Nokia@123   coam=${alias}    version=${version}
    sleep    10s
    ${res}   svdu.set_rnd_debug_parameters    object_name=${object_name}    filter_param=${filter_param}  new_value=${new_value}
    ...           timeout=${timeout}  coam=${alias}
    log to console   ${res}
    [Teardown]   svdu.logout   coam=${alias}

Restore Rnd Debug Parameters
    [Arguments]    ${url}   ${object_name}    ${filter_param}   ${timeout}=60   ${alias}=vdu_conn
    [Documentation]  Keyword for Restore Rnd Debug Parameters Value.
    ...    Author: Cao Ge
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Restore Rnd Debug Parameters | Man. | Description |
    ...    | url | yes | str, url to coam vdu WebEM |
    ...    | object_name | yes | domain object name in which parameter need to set or edit，for example:"NrUlPhy" |
    ...    | filter_param | yes | str, parameter name,for example:"phyEventEnable" |
    ...    | timeout | no | int, timeout for the element be available to click |
    ...    | alias | no | (optional) alias that the new coam vdu object |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Restore Rnd Debug Parameters | url=https://10.56.9.114/login   object_name=NrUlPhy  filter_param=phyEventEnable
    ...      alias=vdu_conn |
    ...
    ${vdu_version}   Get vDU Version
    ${pattern}   re.compile   vDUCNF(.*?)_
    ${res}       re.findall   ${pattern}    ${vdu_version}
    ${version}  Set Variable   ${res[${0}]}
    svdu.login    url=${url}  password=Nokia@123   coam=${alias}    version=${version}
    sleep    10s
    ${res}   svdu.restore_rnd_debug_parameters    object_name=${object_name}    filter_param=${filter_param}
    ...           timeout=${timeout}  coam=${alias}
    log to console   ${res}
    [Teardown]   svdu.logout   coam=${alias}


vDU WebEM Go To By Site Bar Menu
    [Arguments]    ${root_node}    @{child_nodes}
    [Documentation]  Keyword for Go To By Site Bar Menu on vDU WebEM.
    ...    | Input Parameters | Man. | Description |
    ...    | root_node | Yes | parent node name |
    ...    | child_nodes | Yes | child node names |
    ...    | Return Value | Description |
    ...    | NA | NA |
    ...
    ...    Example
    ...    | vDU WebEM Go To By Site Bar Menu | root_node=Status | child_nodes=Infrastructure Status |
    ${ICON_MAPTO_ROOTNODE}    Create Dictionary    Configuration=mdi-settings    Status=mdi-shield-check
    Mouse Over    //ui-webem-side-bar-menu//i[contains(@class,"${ICON_MAPTO_ROOTNODE['${root_node}']}")]
    Wait Until Element Is Visible    //ui-webem-side-bar-menu//span[text()="${root_node}"]
    Mouse Over    //ui-webem-side-bar-menu//span[text()="${root_node}"]
    ${node_xpath}    Set Variable    //ui-webem-side-bar-menu//span[text()="${root_node}"]/../..
    FOR    ${node}    IN    @{child_nodes}
    Wait Until Element Is Visible    ${node_xpath}//a[text()=" ${node} "]
    Mouse Over    ${node_xpath}//a[text()=" ${node} "]
    ${node_xpath}    Set Variable    ${node_xpath}//a[text()=" ${node} "]
    END
    Click Element    ${node_xpath}
    Wait Until Element Is Visible    //ui-webem-status-bar//li[contains(@class,"active-menu-item")]//span[text()="${node}"]