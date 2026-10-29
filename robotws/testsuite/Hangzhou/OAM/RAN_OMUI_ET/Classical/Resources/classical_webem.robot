*** Settings ***

Library           SeleniumLibrary   run_on_failure=NONE
Library           String
Variables         webem_locator.py

*** Variables ***
${WEBUI_URL}          10.108.237.52
${WEBUI_USER}         Nemuadmin
${WEBUI_PASSWORD}     nemuuser
${RU_TYPE}            AHBCC

*** Keywords ***

Open Browser
    [Arguments]     ${URL}
    [Documentation]  Open Browser
    ...  author: yingguo.ying@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | URL| yes | e.g, https://10.56.125.120 |
    ...
    ...    *RETURN VALUE*
    ...    Parameter Value
    ...
    ...    Example
    ...    | Open Browser | URL=https://10.56.125.120 |
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    ${prefs}  create dictionary   download.default_directory=/tmp/
    Call Method    ${chrome options}    add_experimental_option   prefs   ${prefs}
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --disable-gpu
    Call Method    ${chrome options}    add_argument    --disable-dev-shm-usage
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Set Window Size    1920    1080
    Maximize Browser Window
    Goto    ${URL}

Open WEBEM and Login
    [Arguments]     ${URL}=http    ${USER}=Nemuadmin   ${PASSWORD}=nemuuser
    [Documentation]  Open WEBEM and Login
    ...  author: yingguo.ying@nokia-sbell.com
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
    Open Browser    https://${WEBUI_URL}
    Wait Until Element Is Visible  ${INPUT_USERNAME}     1min
    input text  ${INPUT_USERNAME}  ${WEBUI_USER}
    sleep   3s
    input text  ${INPUT_PASSWORD}  ${WEBUI_PASSWORD}
    sleep   3s
    Click Element  ${LOGIN_BUTTON}
    sleep   3s
    Wait Until Element Is Visible  ${CONFIRM_BUTTON}    2min
    Click Element  ${CONFIRM_BUTTON}
    sleep   30s

Logout And Close WEBEM
    SeleniumLibrary.close browser

Wait Element Visible And Click
    [Arguments]    ${locator}   ${time_out}=10s
    Wait Until Element Is Visible   ${locator}  ${time_out}
    click element   ${locator}

Check Cell Onair
    Wait Until Element Is Visible   ${ONAIR}    2min

Go to RF Scan Page From Dashboard
    [Arguments]    ${ru_type}
    Wait Element Visible And Click   ${DIAGNOSTIC}
    Wait Element Visible And Click   ${RF_MONITORING}
    run keyword if    '${ru_type}' == 'AHBCC'    Wait Element Visible And Click   ${RF_SCAN_AHBCC}
    ...               ELSE    Wait Element Visible And Click   ${RF_SCAN_AHCA}
    Wait Element Visible And Click   ${SELECT_NR}    1min
    

Select Scan Type
    [Arguments]     ${radios}=AHBCC    ${capture_type}=Composite Rx (HBF0)   ${antenna}=All Antennas   ${local_cell}=NRCELL-1(53054-01)  ${flag}=true
    [Documentation]  Select Scan Type
    ...  author: yingguo.ying@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | radios  | yes | e.g, AHBCC |
    ...    | capture_type | yes | e.g, Composite Rx (HBF0) |
    ...    | antenna | yes | e.g, All Antennas or ANT 1 |
    ...    | local_cell | yes | e.g, NRCELL-1(53054-01) |
    ...    | flag | yes | e.g, true or false |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Select Scan Type | radios=AHCA | capture_type=Carrier Rx (FIR9) | antenna=ANT 2 | local_cell=NRCELL-1 | flag=false
    
    run keyword if  '''${flag}'''=='''true'''     Wait Element Visible And Click   xpath=//td[@class='radios']/wf-dropdown/div/button    ELSE
    ...     Wait Element Visible And Click   xpath=//td[@class='radios n-cell-selected']/wf-dropdown/div/button 
    Wait Element Visible And Click   xpath=//span[text()='RMOD-1 (${radios})']
    Wait Element Visible And Click   xpath=//td[@class='capture-type n-cell-selected']/wf-dropdown/div/button
    Wait Element Visible And Click   xpath=//span[text()='${capture_type}']
    Wait Element Visible And Click   xpath=//td[@class='antenna n-cell-selected']/wf-dropdown/div/button
    Wait Element Visible And Click   xpath=//span[text()='${antenna}']
    run keyword if    '${capture_type}' == 'Carrier Rx (FIR9)'     Select Cell    cell=${local_cell}

Select Cell
    [Arguments]     ${cell}=NRCELL-1(53054-01)
    Wait Element Visible And Click   xpath=//td[@class='local-cell n-cell-selected']/wf-dropdown/div/button
    Wait Element Visible And Click   xpath=//span[text()='${cell}']

Save RF Scan File
    RUN    rm /tmp/RFMonitoring_*.zip
    Wait Element Visible And Click   xpath=//ui-button[@a-text='Start']
    Wait Until Element Is Visible    xpath=//div[text()='Download completed and file saved']    1min
    ${status_file}  RUN    cd /tmp/; ls|grep RFMonitoring_|grep rf-scan
    ${status_file_path}  OperatingSystem.Join Path   /tmp/${status_file}
    [Return]    ${status_file_path}

Check File Should Not Be Empty
    [Arguments]     ${status_file_path}
    ${file_content}  run  cd /tmp
    ${size}=  get file size  ${status_file_path}
    should be true  ${size} > 100