*** Settings ***
Documentation
...    VRF HAZ 1 Common Resources.

Library           Selenium2Library    run_on_failure=NONE
Library           String
Variables         python/webem_locator.py
Library           OperatingSystem
Library           Collections



*** Keywords ***
vDU WebEM Page Login
    [Documentation]    vDU WebEM Login
    ...    author: wei.zuo@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | vDU WebEM Login |
    [Timeout]    1min
    run keyword and ignore error    vdu.disconnect
    ${vdu_connection}=    vdu.connect to    host=${WEBUI_URL}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}    port=${EMPTY}    secure=True

Open Browser
    [Arguments]    ${URL}
    [Documentation]    Open Browser
    ...    author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | URL| yes | e.g, https://10.56.125.120 |
    ...
    ...    *RETURN VALUE*
    ...    Parameter Value
    ...
    ...    Example
    ...    | Open Browser | URL=https://10.56.125.120 |
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    ${prefs}    create dictionary    download.default_directory=/tmp/
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
    [Arguments]    ${URL}=http    ${USER}=Nemuadmin    ${PASSWORD}=Nokia@123
    [Documentation]    Open WEBEM and Login
    ...    author: qixuan.zhang@nokia-sbell.com
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
    Open Browser    ${URL}
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
    ...    author: wei.zuo@nokia-sbell.com
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
    ...    author: wei.zuo@nokia-sbell.com
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
    ...    author: wei.zuo@nokia-sbell.com
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
    ...    author: miao.a.cao@nokia-sbell.com
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
    ...    author: qixuan.zhang@nokia-sbell.com
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
    ...    author: qixuan.zhang@nokia-sbell.com
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
    Wait Element Visible And Click    id=open-detail-panel-button

Hide Details Panel
    Wait Element Visible And Click    id=open-detail-panel-button

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
    ...    author: miao.a.cao@nokia-sbell.com
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
    Wait Element Visible And Click    xpath=//div[@class="vdu-cell-view" and @data-base-cell-id="${cell_id}"]//p-button[@title="Operations"]
    Wait Element Visible And Click    xpath=//span[text()="Block cell"]
    Wait Until Element Is Visible    xpath=//button[contains(@class,'p-confirm-dialog')]
    click Element    xpath=//button[contains(@class,"p-confirm-dialog-accept")]
    wait until element is visible    xpath=//div[contains(text(),"block operation finished")]    1min

Unblock Cell
    [Arguments]    ${cell_id}=1
    Wait Element Visible And Click    xpath=//div[@class="vdu-cell-view" and @data-base-cell-id="${cell_id}"]//p-button[@title="Operations"]
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

Download FCE Modules For Current SW
    ${active_sw_version}    Get vDU Version
    ${current_prefix}    Set Variable    ${active_sw_version.split('_')[0].strip()}
    ${current_release}    Set Variable If    "${current_prefix}" == "${Trunk_Prefix}"    vDUCNF00    ${current_prefix}
    ${version_num}    Fetch From Right    ${active_sw_version}    _
    ${current_version}    Set Variable    ${current_release}_${version_num}
    ${fce_worker}    ${fct_files}    Download FCE And FCT    target_version=${current_version}    target_download_path=${TEST_LOG_DIRECTORY}
    ...    release_name=${current_release}   clean_folder=${FALSE}
    [Return]    ${fce_worker}    ${fct_files}

Download FCE And FCT
    [Arguments]    ${target_version}    ${target_download_path}=/home/ute/Downloads    ${release_name}=vDUCNF00    ${clean_folder}=${TRUE}
    #Wait Until Element Is Visible    //webem-page-header//span[contains(@title,"software version:")]/span    60s
    #${sw_version}    Selenium2Library.Get Text    //webem-page-header//span[contains(@title,"software version:")]/span
    #Log To Console    ${sw_version}
    #${version_number}    Fetch From Right    ${target_version}    _
    #${version_head}    Set Variable    vDUCNF00
    #${FCE_WORKER}    Replace Variables    ${FCE_WORKER}
    #${FCT_FILE}    Replace Variables    ${FCT_FILE}
    #Log To Console    ${FCE_WORKER}
    #Log To Console    ${FCT_FILE}
    ${download_command}    Set Variable    sudo wget --progress=dot:giga -T 600 -t 2
    ${download_source_path}    Set Variable
    ...    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/${release_name}
    #...    https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/${release_name}
    ${status}    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${target_download_path}
    Run Keyword Unless    ${status}    OperatingSystem.Create Directory    ${target_download_path}
    ${remove_files_cmd}    Set Variable    sudo rm -rf ${target_download_path}/*
    Run Keyword If    ${clean_folder}    OperatingSystem.Run    ${remove_files_cmd}
    ${fce_worker}    Set Variable    ${target_version}_fce-worker.zip
    ${fct_files}    Set Variable    ${target_version}_fct-files.zip
    Log To Console    \nStart Download FCE For ${target_version}...........
    ${output}    Wait Until Keyword Succeeds    5m    5s    OperatingSystem.Run
    ...    ${download_command} ${download_source_path}/${target_version}/${fce_worker} -O ${target_download_path}/${fce_worker}
    Should Contain    ${output}    100%
    Log To Console    \nComplete Download FCE For ${target_version}...........
    Log To Console    \nStart Download FCT For ${target_version}...........
    ${output}    Wait Until Keyword Succeeds    5m    5s    OperatingSystem.Run
    ...    ${download_command} ${download_source_path}/${target_version}/${fct_files} -O ${target_download_path}/${fct_files}
    Should Contain    ${output}    100%
    Log To Console    \nComplete Download FCT For ${target_version}...........
    #${fce_worker_f_name}    Set Variable    ${version_head}_${version_number}_fce-worker.zip
    #${fct_file_f_name}    Set Variable    ${version_head}_${version_number}_fct-files.zip
    #${rc1}    ${out_put1}    OperatingSystem.Run and Return RC and Output    wget ${FCE_WORKER} -O ${target_download_path}/${fce_worker}
    #${rc2}    ${out_put2}    OperatingSystem.Run and Return RC and Output    wget ${FCT_FILE} -O ${target_download_path}/${fct_files}
    #OperatingSystem.Move File    ${fce_worker_f_name}    ${target_download_path}/${fce_worker_f_name}
    #OperatingSystem.Move File    ${fct_file_f_name}    ${target_download_path}/${fct_file_f_name}
    OperatingSystem.File Should Exist    ${target_download_path}/${fce_worker}
    OperatingSystem.File Should Exist    ${target_download_path}/${fct_files}
    #Set Test Variable    ${fce_worker_name}    ${fce_worker}
    #Set Test Variable    ${fct_files_name}    ${fct_files}
    [Return]    ${fce_worker}    ${fct_files}

Install FCE
    [Arguments]    ${fce_worker_file}
    ${msg}    Set Variable
    Go To Configuration Automation
    Selenium2Library.Choose File    //ot-upload[@id="install-fce"]//input    ${fce_worker_file}
    Sleep    10s
    Capture Page Screenshot
    ${is_succeed}    Run Keyword And Return Status    Wait Until Element Is Enabled    //span[contains(text(),'Install FCT')]/../input    10s
    Return From Keyword If    ${is_succeed}    ${msg}
    Wait Until Element Is Visible    //div[@role="dialog"]//span[contains(text(),"FCE installation failed")]    10s
    ${msg}    Selenium2Library.Get Text    //div[@role="dialog"]//blocks-installed-dialog/div
    Selenium2Library.Click Element    //div[@role="dialog"]//div[contains(@class,"p-dialog-footer")]//button
    [Return]    ${msg}

Install FCT
    [Arguments]    ${fct_file}
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
    Go To PE Page
    Wait Element Visible And Click    xpath=//span[contains(text(),'Configuration Automation')]

Collapse Dropdown List
    [Arguments]    ${xpath}
    ${is_expanded}    Run Keyword And Return Status    Element Should Be Visible    ${xpath}
    Run Keyword If    ${is_expanded}    Selenium2Library.Click Element    ${xpath}
    Wait Until Element Is Not Visible    ${xpath}    3s

Get Button States Of Configuration Automation
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

Get Values Of Param On AC
    [Arguments]    ${param}
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
        ${list_value}    Get Values Of Param On AC    ${param}
        Set To Dictionary    ${dic_param_value}    ${param}    ${list_value}
    END
    [Return]    ${dic_param_value}

Set Param Value Of Feature Object
    [Arguments]    ${feature_name}    ${object_name}    ${dic_value_to_set}
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
    Wait Element Visible And Click    //configuration-shared-create-delta-plan//button
    Selenium2Library.Wait Until Element Is Visible    //input[@id="edit-plan-plan-name-input"]
    Selenium2Library.Input Text    //input[@id="edit-plan-plan-name-input"]    ${plan_name}
    Selenium2Library.Click Element    //p-button[@id="edit-plan-create-button"]/button

Delete Plan
    [Arguments]    ${plan_name}
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
    Wait Element Visible And Click    //p-button[@id="activate-modal-done"]/button    300s
    Wait Until Element Is Not Visible    //div[@role="dialog"]//span[text()="Activate Plan Status"]    10s

Get Plan Options From WebEM CA
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
    Wait Element Visible And Click    //p-dropdown[@id="selectPlan"]//div[@role="button"]
    Wait Element Visible And Click    //p-dropdown[@id="selectPlan"]//p-dropdownitem/li/span[text()="${plan_name}"]

Calculate On CA Page And Get Results
    Wait Element Visible And Click    //cem-operation-button//button/span[text()="Calculate"]
    ${result}    ${table_head_list}    ${validation_result}    Get FCT Caculate Result
    [Return]    ${result}    ${table_head_list}    ${validation_result}

Audit On CA Page And Get Results
    Wait Element Visible And Click    //cem-operation-button//button/span[text()="Audit"]
    ${result}    ${table_head_list}    ${validation_result}    Get FCT Caculate Result
    [Return]    ${result}    ${table_head_list}    ${validation_result}

Get FCT Caculate Result
    Wait Until Element Is Visible    //blocks-configuration-automation-results/p-table
    ${result}    Selenium2Library.Get Text    //blocks-configuration-automation-results/ot-instruction/div/div
    ${thead}    Selenium2Library.Get WebElements    //blocks-configuration-automation-results/p-table//tr/th
    ${table_head_list}    Create List
    FOR    ${th}    IN    @{thead}
        ${item}    Selenium2Library.Get Text    ${th}
        Append To List    ${table_head_list}    ${item}
    END
    ${tbody_tr}    Selenium2Library.Get WebElements    //blocks-configuration-automation-results/p-table//tbody//tr
    ${row_count}    Get Length    ${tbody_tr}
    ${validation_result}    Create List
    FOR    ${index}    IN RANGE    ${1}    ${row_count}+1
        ${td_list}    Selenium2Library.Get WebElements    //blocks-configuration-automation-results/p-table//tbody//tr[${index}]/td
        ${column_dic_onerow}    Generate Column Dictionary For Row    ${table_head_list}    ${td_list}
        Append To List    ${validation_result}    ${column_dic_onerow}
    END
    [Return]    ${result}    ${table_head_list}    ${validation_result}

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

Apply All On CA
    Wait Element Visible And Click    //blocks-configuration-automation-apply//button/span[text()="Apply All"]
    Wait Until Element Is Visible    //blocks-configuration-automation-apply//ot-instruction//span
    ${result}    Selenium2Library.Get Text    //blocks-configuration-automation-apply//ot-instruction//span
    [Return]    ${result}

Filter MOs Of Plan On PE
    [Arguments]    ${filter}    ${plan_name}=CURRENT_PLAN
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
