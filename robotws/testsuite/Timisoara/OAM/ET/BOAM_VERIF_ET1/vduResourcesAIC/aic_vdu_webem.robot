*** Settings ***
Documentation
...     17.02.2025 -- solved :FOR and RF5.0 issues

Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library           taf.selenium.gnb.oam.coam.vdu         WITH NAME    svdu
Library           SeleniumLibrary
Library           String

*** Variables ***
${WEBUI_URL}          ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
${WEBUI_USER}         ${tl.gnbs[0].dus[0].oam_http_connection_details.username}
${WEBUI_PASSWORD}     ${tl.gnbs[0].dus[0].oam_http_connection_details.password}

*** Keywords ***
vDU WebEM Page Login
    [Timeout]    1min
        [Documentation]  vDU WebEM Login
    ...  author: wei.zuo@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | vDU WebEM Login |
    run keyword and ignore error    vdu.disconnect
    ${vdu_connection}=    vdu.connect to    host=${WEBUI_URL}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}    port=${EMPTY}    secure=True

Open Browser
    [Arguments]     ${URL}
    [Documentation]  Open Browser
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | URL| yes | e.g, https://10.56.125.120 |
    ...
    ...    *RETURN VALUE*
    ...    Parameter Value
    ...
    ...    Example
    ...    | Open Browser | URL=https://10.56.125.120 |
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --start-maximized
#    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    ${URL}

Open WEBEM and Login
    #[Arguments]     ${URL}=http    ${USER}=Nemuadmin   ${PASSWORD}=nemuuser
    [Documentation]  Open WEBEM and Login
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | URL  | yes | e.g, 10.110.125.210 |
    ...    | USER | yes | e.g, Nemuadmin |
    ...    | PASSWORD | yes | e.g, nemuuser |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Open WEBEM and Login | URL=10.110.125.210 | USER=Nemuadmin | PASSWORD=nemuuser |
    Open Browser    ${WEBUI_URL}
    Wait Until Element Is Visible
    ...     xpath=//input[@id="login-username"]     30s
    input text
    ...     xpath=//input[@id="login-username"]  ${WEBUI_USER}
    sleep   3s
    input text      xpath=//input[@id="login-password"]     ${WEBUI_PASSWORD}
    sleep   3s
    Click Element   xpath=//ui-webem-button[@id="login-button"]
    sleep   3s
    Wait Until Element Is Visible     xpath=//span[contains(text(),"Confirm")]    30s
    Click Element     xpath=//span[contains(text(),"Confirm")]

Logout And Close WEBEM
    Wait Until Element Is Visible   xpath=//span[contains(text(),"Nemuadmin")]
    Click Element   xpath=//span[contains(text(),"Nemuadmin")]
    Wait Until Element Is Visible   xpath=//span[contains(text(),"Sign out")]
    Click Element   xpath=//span[contains(text(),"Sign out")]
    SeleniumLibrary.close browser

Check Alarm Should Not Contain Fault By Seleumin
    [Arguments]  ${FAULT_ID}
    [Documentation]  Check Alarm Should Not Contain Fault by Seleumin
    ...  just run by selenium
    ...  author: wei.zuo@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | FAULT_ID    | yes | FAULT_ID, e.g, 23 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check Alarm Should Not contain Fault via seleumin | FAULT_ID=23 |
    sleep    10s
    @{output_alarms}    svdu.get_active_alarm_info
    log to console    alarm=@{output_alarms}
    Should Not Contain    '@{output_alarms}'    u'Fault ID': u'${FAULT_ID}'

Check Alarm Should contain Fault By Seleumin
    [Arguments]  ${FAULT_ID}
    [Documentation]  Check Alarm Should contain Fault via seleumin
    ...  author: wei.zuo@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | FAULT_ID    | yes | FAULT_ID, e.g, 23 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check Alarm Should contain Fault via seleumin | FAULT_ID=23 |
    sleep    10s
    @{output_alarms}    svdu.get_active_alarm_info
    log to console    alarm=@{output_alarms}
    should contain    '@{output_alarms}'    u'Fault ID': u'${FAULT_ID}'

Check History Alarm Should contain Fault By Seleumin
    [Arguments]  ${FAULT_ID}
    [Documentation]  Check History Alarm Should contain Fault via seleumin
    ...  author: wei.zuo@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | FAULT_ID    | yes | FAULT_ID, e.g, 23 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check History Alarm Should contain Fault via seleumin | FAULT_ID=23 |
    sleep    10s
    ${output_alarms}    svdu.get_history_alarm_info
    log to console    alarm=${output_alarms}
    should contain    '${output_alarms}'    u'Fault ID': u'${FAULT_ID}'

Check toggling Alarm Should contain Fault By Seleumin
    [Arguments]    ${status}    ${FAULT_ID}        ${flag}      #${TOGGLING_ID}
    [Documentation]  Check toggling Alarm Should contain Fault via seleumin
    ...  author: miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | status    | yes | status, e.g, Inactive |
    ...    | FAULT_ID    | yes | FAULT_ID, e.g, 4298 |
    ...    | TOGGLING_ID    | yes | TOGGLING_ID, e.g, 4026 |
    ...    | flag    | yes | flag, e.g, true |
    ...
    ...    *RETURN VALUE*
    ...    datetime
    ...
    ...    Example
    ...   | Check toggling Alarm Should contain Fault via seleumin | Inactive | 4298 | 4026 | true |
    ${output_alarms}=  Get Active Alarm Fault by REST API
    log to console    alarm=@{output_alarms}
    run keyword if    ${flag}== True    Should Contain    '@{output_alarms}'    'Fault ID': u'4026'
    run keyword if    ${flag}== False    Should Not Contain    '@{output_alarms}'    'Fault ID': u'4026'
    @{fault_toggle_alarm}    svdu.get_fault_toggling_history
    log to console    alarm=@{fault_toggle_alarm}
    should contain    '@{fault_toggle_alarm}'    'Fault ID': u'${FAULT_ID}'
    should contain   '@{fault_toggle_alarm}'    'State': u'${status}'
    svdu.logout

Copy Existing Object
    [Arguments]  ${object_name}     ${object_class_name}    ${plan_name}    ${object_distinguished_name}
    ...    ${copy_object_with_subtree}=${True}      ${id_value}=None     ${timeout}=60
    [Documentation]  Copy Existing Object
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | object_name      | yes  | where object will be added in |
    ...    | object_class_name| yes  | name of object class |
    ...    | plan_name        | yes  | plan name that object to be copied |
    ...    | object_distinguished_name | yes  | object_distinguished_name |
    ...    | copy_object_with_subtree | no  | Boolean , copying subtree elements |
    ...    | id_value | no  | default is None |
    ...    | timeout | no  | timeout for the element be available to click |
    ...    *RETURN VALUE*
    ...    none
    ...
    ...    Example
    ...    |Copy Existing Object | object_name=MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1 | object_class_name=LCELNR |plan_name=DELTA-PLAN-1
    ...    |object_distinguished_name=MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1 | copy_object_with_subtree=${True} | id_value=2 |
    svdu.choose_plan    plan_name=DELTA-PLAN-1
    ${timeout}   convert to integer  ${timeout}
    svdu.copy_object     ${object_name}     ${object_class_name}    ${plan_name}    ${object_distinguished_name}
    ...    ${copy_object_with_subtree}     ${id_value}     ${timeout}

Go To ALD Status Page
    [Documentation]  Go To ALD Status Page
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    none
    ...
    ...    Example
    ...    | Open WEBEM and Login |
    ...    | Go To ALD Status Page |
    Wait Until Element Is Visible    xpath=//i[contains(@class,'mdi-shield-check')]    1min
    click element   xpath=//i[contains(@class,'mdi-shield-check')]
    Wait Until Element Is Visible   xpath=//span[contains(text(),'ALD Status')]
    Click Element   xpath=//span[contains(text(),'ALD Status')]
    sleep   1s

Select Diagnostic on WebEM
    log to console  ---Start to Select Diagnostic on WEBEM
    ${xpath}=  catenate  SEPARATOR=   xpath=/html/body/vdu-webem-root/div/div/webem-single-column-layout/webem-page-layout/div/
    ...     webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[8]
    Wait Until Element Is Visible   ${xpath}    30s
    Click Element   ${xpath}

Select Tab SFP Monitoring
    log to console  ---Start to Select Tab SFP Monitoring
    ${xpath}=  catenate  SEPARATOR=  xpath=/html/body/vdu-webem-root/div/div/webem-single-column-layout/webem-page-layout/
    ...     div/ui-webem-panel-split/as-split/div[2]/div/ui-webem-status-bar/div/oam-shared-diagnostic-content-menu/ui-webem-submenu/
    ...     p-menubar/div/p-menubarsub/ul/li[4]/a
    Wait Until Element Is Visible   ${xpath}    90s
    Click Element   ${xpath}

Export ALD Status File
    [Arguments]     ${ald_type}=RAE
    RUN    rm /home/ute/Downloads/ALDs_status_${ald_type}*
    RUN    rm /tmp/ALDs_status_${ald_type}*
    Go To ALD Status Page
    click element   xpath=//span[contains(text(),"${ald_type} Status View")]
    sleep   3s
    Wait Until Element Is Visible   xpath=//span[contains(text(),"Export")]
    click element   xpath=//span[contains(text(),"Export")]
    sleep   3s
    ${status_file}  RUN    cd /home/ute/Downloads/; ls|grep ALDs_status_${ald_type}
    ${status_file_path}  OperatingSystem.Join Path   /home/ute/Downloads/   ${status_file}
    RUN     cp ${status_file_path} /tmp/
    ${status_file_path}  OperatingSystem.Join Path   /tmp/${status_file}
    [Return]    ${status_file_path}

Wait Element Visible And Click
    [Arguments]    ${locator}   ${time_out}=10s
    Wait Until Element Is Visible   ${locator}  ${time_out}
    click element   ${locator}

Go to PE ALD
    [Arguments]     ${ald_type}     ${ald_index}=1
    Should Be Uppercase     ${ald_type}
    ${ald_type_tmp}    Convert To Lowercase     ${ald_type}
    Go To ALD Status Page
    click element   xpath=//span[contains(text(),"${ald_type} Status View")]
    Wait Element Visible And Click   xpath=//div[@class="${ald_type_tmp}-tile-view"]//p-button[@title="Operations"]
    Wait Element Visible And Click   xpath=//span[contains(text(),"Go to PE (ALD-${ald_index})")]
    Wait Until Element Is Visible   xpath=//span[contains(text(),"MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ALD-${ald_index}")]

Go to PE ALD_R
    [Arguments]     ${ald_type}     ${ald_index}=1
    Should Be Uppercase     ${ald_type}
    ${ald_type_tmp}    Convert To Lowercase     ${ald_type}
    Go To ALD Status Page
    click element   xpath=//span[contains(text(),"${ald_type} Status View")]
    Wait Element Visible And Click   xpath=//div[@class="${ald_type_tmp}-tile-view"]//p-button[@title="Operations"]
    Wait Element Visible And Click   xpath=//span[contains(text(),"Go to PE (ALD_R-${ald_index})")]
    Wait Until Element Is Visible   xpath=//span[contains(text(),"ALD_R-${ald_index}")]

Go to PE RETU/RAEU
    [Arguments]     ${ald_type}     ${ald_index}=1  ${unit_index}=1
    Should Be Uppercase     ${ald_type}
    ${ald_type_tmp}    Convert To Lowercase     ${ald_type}
    Go To ALD Status Page
    click element   xpath=//span[contains(text(),"${ald_type} Status View")]
    Wait Element Visible And Click   xpath=//div[@class="${ald_type_tmp}u-view"]//p-button[@title="Operations"]
    Wait Element Visible And Click   xpath=//span[contains(text(),"Go to PE (RAEU-${unit_index})")]
    Wait Until Element Is Visible
    ...     xpath=//span[contains(text(),"MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ALD-${ald_index}/${ald_type}U-${unit_index}")]

Go to PE RETU_R/RAEU_R
    [Arguments]     ${ald_type}     ${ald_index}=1  ${unit_index}=1
    Should Be Uppercase     ${ald_type}
    ${ald_type_tmp}    Convert To Lowercase     ${ald_type}
    Go To ALD Status Page
    click element   xpath=//span[contains(text(),"${ald_type} Status View")]
    Wait Element Visible And Click   xpath=//div[@class="${ald_type_tmp}u-view"]//p-button[@title="Operations"]
    Wait Element Visible And Click   xpath=//span[contains(text(),"Go to PE (RAEU_R-${unit_index})")]
    Wait Until Element Is Visible
    ...     xpath=//span[contains(text(),"ALD_R-${ald_index}/${ald_type}U_R-${unit_index}")]

Reset ALD SW
    [Arguments]     ${ald_type}
    Should Be Uppercase     ${ald_type}
    ${ald_type_tmp}    Convert To Lowercase     ${ald_type}
    Go To ALD Status Page
    click element   xpath=//span[contains(text(),"${ald_type} Status View")]
    Wait Element Visible And Click   xpath=//div[@class="${ald_type_tmp}-tile-view"]//p-button[@title="Operations"]
    Wait Element Visible And Click   xpath=//span[contains(text(),"Reset ALD (SW)")]
    Wait Element Visible And Click   xpath=//button[contains(@class,"p-confirm-dialog-accept")]

Reset ALD HW
    [Arguments]     ${ald_type}
    Should Be Uppercase     ${ald_type}
    ${ald_type_tmp}    Convert To Lowercase     ${ald_type}
    Go To ALD Status Page
    click element   xpath=//span[contains(text(),"${ald_type} Status View")]
    Wait Element Visible And Click   xpath=//div[@class="${ald_type_tmp}-tile-view"]//p-button[@title="Operations"]
    Wait Element Visible And Click   xpath=//span[contains(text(),"Reset ALD (HW)")]
    Wait Element Visible And Click   xpath=//button[contains(@class,"p-confirm-dialog-accept")]

RAE Restore Factory Defaults
    [Arguments]     ${ald_type}
    Should Be Uppercase     ${ald_type}
    ${ald_type_tmp}    Convert To Lowercase     ${ald_type}
    Go To ALD Status Page
    click element   xpath=//span[contains(text(),"RAE Status View")]
    Wait Element Visible And Click   xpath=//div[@class="${ald_type_tmp}u-view"]//p-button[@title="Operations"]
    Wait Element Visible And Click   xpath=//span[contains(text(),"Restore Factory Defaults")]
    Wait Element Visible And Click   xpath=//button[contains(@class,"p-confirm-dialog-accept")]

Download RAE Weight Factor File
    [Arguments]     ${weight_file_name}
    RUN   rm /home/ute/Downloads/TYDA*
    RUN   rm /tmp/TYDA*
    Wait Element Visible And Click   xpath=//ui-webem-raeu-tile[@class="ng-star-inserted"]
    Wait Element Visible And Click   xpath=//span[contains(text(),"Weight")]
    Wait Until Element Is Visible   xpath=//td[@title="${weight_file_name}"]
    Wait Until Element Is Visible   xpath=//td[@title="WeightFactorFile"]
    Wait Until Element Is Enabled   xpath=//div[@class="details-panel-body-section"]//span[contains(@class,"mdi-content-save")]
    click element   xpath=//div[@class="details-panel-body-section"]//span[contains(@class,"mdi-content-save")]
    wait until keyword succeeds    1min  10s    Check RAE Weight Factor File Should Be Saved    ${weight_file_name}

Check RAE Weight Factor File Should Be Saved
    [Arguments]     ${weight_file_name}
    ${return}   RUN   cp /home/ute/Downloads/TYDA* /tmp/
    should not contain     ${return}   No such file or directory
    ${size}=     get file size    /tmp/${weight_file_name}
    should be true  ${size} > 0

Open Details Panel
    Wait Element Visible And Click   id=open-detail-panel-button

Hide Details Panel
    Wait Element Visible And Click   id=open-detail-panel-button

Get RETU Text
    Wait Element Visible And Click    xpath=//div[@class="retu-body"]    1min
    ${text}     get text    xpath=//div[@class="retu-body"]
    log to console  ${text}
    set test variable   ${text}

Get Details Pannel Text
    [Arguments]     ${unit}=associated-antenna-units
    Open Details Panel
    Wait Until Element Is Visible    id=${unit}-arrayOfTexts    1min
    ${text}     get text    id=${unit}-arrayOfTexts
    log to console  ${text}
    set test variable   ${text}

Go To Site View Page
    Wait Element Visible And Click    xpath=//i[contains(@class,'mdi-shield-check')]    1min
    Wait Element Visible And Click   xpath=//span[contains(text(),'Site View')]    1min
    sleep   3s

Check RETU Angles
    [Arguments]     ${angle}=3\xb0    ${Mechangle}=4\xb0    ${Minangle}=0\xb0    ${Maxangle}=7\xb0
    Get RETU Text
    should contain    ${text}   ${angle}  ${Mechangle}  ${Minangle}  ${Maxangle}

Add MO Under CMD
    [Arguments]     ${mrbts_id}    ${mo}=RETUCONFILEAPPLYREQ    ${mo_num}=1
    svdu.login      url=https://${WEBUI_URL}    username=${WEBUI_USER}   password=${WEBUI_PASSWORD}   version=${WEBUI_VERSION}
    svdu.choose_plan    plan_name=DELTA-PLAN-1
    FOR    ${mo_id}   IN RANGE    1   ${mo_num}+1
       svdu.add_object  dist_name=MRBTS-${mrbts_id}/MNL-1/CMD-1    object_class_name=${mo}    is_load_default_values=${True}   id_value=${mo_id}
    END
    sleep   2
    [Teardown]     svdu.logout

Check RETU Operational Status
    [Arguments]     ${status}=Enabled
    Wait Element Visible And Click    xpath=//div[@class="retu-body"]    1min
    Open Details Panel
    Wait Until Element Is Visible   id= retu-states-table
    ${text}     get text    id= retu-states-table
    log to console  ${text}
    should contain    ${text}   ${status}

Select ALD By Filter
    [Arguments]     ${ald_id}=1
    Wait Element Visible And Click    xpath=//p-button[@id="filter-button"]    1min
    Wait Element Visible And Click    //span[text()='ALD ID:']//following-sibling::input
    wait until keyword succeeds    1min   10s     SeleniumLibrary.Input Text    //span[text()='ALD ID:']//following-sibling::input    ${ald_id}

Check ALD Status In Detail Panel
    [Arguments]     ${operational_state}    ${availability_status}      ${procedural_status}
    Wait Until Element Is Visible   id=ald-states-table
    ${ald_states}   get text    id=ald-states-table
    should contain  ${ald_states}   ${operational_state}    ${availability_status}      ${procedural_status}

Go To Cell Status Page
    [Documentation]  Go To cell Status Page
    ...  author: miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    none
    ...
    ...    Example
    ...    | Open WEBEM and Login |
    ...    | Go To ALD Status Page |
    log to console   go to site view panel
    Wait Element Visible And Click    xpath=//i[contains(@class,'mdi-shield-check')]    1min
    log to console   go to cell status panel
    Wait Element Visible And Click    xpath=//span[text()="Cells Status"]

Check Cell Status Under Cell Status View
    [Arguments]     ${cell_id}      ${operational_state}    ${Procedural_status}    ${blocking_state}
    log to console    Check Cell Status and cell should be ${blocking_state}
    Go To Cell Status Page
    Wait Element Visible And Click    xpath=//div[@class="vdu-cell-view" and @data-base-cell-id="${cell_id}"]
    Element Should Be Visible     xpath=//span[text()="${operational_state}"]
    Element Should Be Visible     xpath=//span[text()="${Procedural_status}"]
    Element Should Be Visible     xpath=//i[@class="${blocking_state} ng-star-inserted"]

Check Cell Status Under Site View
    [Arguments]     ${cell_id}      ${blocking_state}
    log to console  Check Cell Status under site view
    Go To Site View Page
    Element Should Be Visible     xpath=//div[@data-vducell-name="NRCELL-${cell_id}"]//i[@title="${blocking_state}"]
    log to console    Cell status under site view panel is ${blocking_state}

VDU RESET Via Webem
    Wait Element Visible And Click    xpath=//p-button[@title="Reset vDU"]    1min
    Wait Until Element Is Visible     xpath=//div[contains(@class,'p-confirm-dialog')]
    click Element    xpath=//button[contains(@class,"p-confirm-dialog-accept")]

Block Cell
    [Arguments]     ${cell_id}=1
    Wait Element Visible And Click    xpath=//div[@class="vdu-cell-view" and @data-base-cell-id="${cell_id}"]//p-button[@title="Operations"]
    Wait Element Visible And Click    xpath=//span[text()="Block cell"]
    Wait Until Element Is Visible     xpath=//button[contains(@class,'p-confirm-dialog')]
    click Element    xpath=//button[contains(@class,"p-confirm-dialog-accept")]

Unblock Cell
    [Arguments]     ${cell_id}=1
    Wait Element Visible And Click    xpath=//div[@class="vdu-cell-view" and @data-base-cell-id="${cell_id}"]//p-button[@title="Operations"]
    Wait Element Visible And Click    xpath=//span[text()="Unblock cell"]
    Wait Until Element Is Visible     xpath=//div[contains(@class,'p-confirm-dialog')]
    click button    xpath=//button[contains(@class,"p-confirm-dialog-accept")]
