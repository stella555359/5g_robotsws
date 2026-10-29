*** Settings ***
Documentation
...    Author: Nicolae Bulata
...    Maintainer: Izabela Muntean
...    Test Description: Web EM keywords based on SeleniumLibrary
...    AC/REQ:

Library     SeleniumLibrary

*** Variables ***
${SELENIUM IMPLICIT WAIT}  1    #keep this small: 1 or 0
${WEBEM_IMPLICIT_TIMEOUT}  30
${BROWSER}                 Chrome
${WEBEM_IP}                https://192.168.255.1      #https://192.168.255.129  https://192.168.255.1
${WEBEM_USERNAME}          Nemuadmin
${WEBEM_PASSWORD}          nemuuser
${LOG_TO_SONSOLE}          True  #Put to False to stop Log to console
${WEBEM_BUTTON_IM_SNAPSHOT_EXECUTE_LOCATOR}  //ui-button[@a-text="Execute"]
${WELCOME_SCREEN_USERNAME_INPUT_22R2}=     //div[@class="ui-inputgroup"]//input[@placeholder="Username"]
${WELCOME_SCREEN_PASS_INPUT_22R2}=         //div[@class="ui-inputgroup"]//input[@placeholder="Password"]
${WELCOME_SCREEN_LOGIN_BTN}=         //p-button[@ng-reflect-label="Login"]
${WELCOME_SCREEN_USERNAME_INPUT}=     //div[@class="p-inputgroup"]//input[@placeholder="Username"]
${WELCOME_SCREEN_PASS_INPUT}=         //div[@class="p-inputgroup"]//input[@placeholder="Password"]
*** Keywords ***
WEBEM Prepare Enviroment
    WEBEM Install Chromedriver
    WEBEM Run Xvfb
    WEBEM Export DISPLAY

WEBEM Install Chromedriver
    Run
    ...    command=sudo cp /home/ute/trunk/selenium/chromedriver /usr/bin
    Run
    ...    command=sudo chmod +x /usr/bin/chromedriver

WEBEM Run Xvfb
    Start Process
    ...    command=/usr/bin/Xvfb :99 -screen 0 1920x1080x16
    ...    shell=yes

WEBEM Export DISPLAY
   Set Environment Variable
   ...     name=DISPLAY
   ...     value=:99
Open Browser
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    ${WEBEM_IP}
    #Sleep    10 secs

WEBEM Login To Web Element Manager
    [Arguments]    ${SW_RELEASE}=${sw_release}
    Set Selenium Implicit Wait    ${SELENIUM IMPLICIT WAIT}
    #Open Browser    ${WEBEM_IP}   ${BROWSER}
    Open Browser
    ${x}  ${y}=	Get Window Position
    Log  Initial Window Position x=${x}, y=${y}
    #Maximize Browser Window
    Set Window Position	 800  10
    Run keyword If      '${SW_RELEASE}' == 'SBTS22R2'   Run Keywords
    ...      Input Text    locator=${WELCOME_SCREEN_USERNAME_INPUT_22R2}  #userName
    ...           text=${WEBEM_USERNAME}
    ...      AND   Input Password    locator=${WELCOME_SCREEN_PASS_INPUT_22R2}  #password
    ...               password=${WEBEM_PASSWORD}
    ...       ELSE   Run Keywords
    ...      Input Text    locator=${WELCOME_SCREEN_USERNAME_INPUT}  #userName
    ...           text=${WEBEM_USERNAME}
    ...      AND   Input Password    locator=${WELCOME_SCREEN_PASS_INPUT}  #password
    ...               password=${WEBEM_PASSWORD}

    Click Element   locator=${WELCOME_SCREEN_LOGIN_BTN}  #//ui-button[@a-text="Login"]
    Run Keyword and Ignore Error  Wait Until Element Is Visible    locator=//ui-button[@a-text="Confirm"]    timeout=10
    Run Keyword and Ignore Error  Click Element    locator=//ui-button[@a-text="Confirm"]
    Run Keyword and Ignore Error  Wait Until Keyword Succeeds  20s  5s  Click Element    locator=//ui-button[@a-text="Close"]
#    Run Keyword and Ignore Error  Click Element    locator=//ui-button[@a-text="Close"]

WEBEM Login To Web Element Manager old 2
    Set Selenium Implicit Wait    ${SELENIUM IMPLICIT WAIT}
    #Open Browser    ${WEBEM_IP}   ${BROWSER}
    Open Browser
    ${x}  ${y}=	Get Window Position
    Log  Initial Window Position x=${x}, y=${y}
    #Maximize Browser Window
    Set Window Position	 800  10
    Input Text    locator=userName
    ...           text=${WEBEM_USERNAME}
    Input Password    locator=password
    ...               password=${WEBEM_PASSWORD}
    Click Element   locator=//ui-button[@a-text="Login"]
    Run Keyword and Ignore Error  Wait Until Element Is Visible    locator=//ui-button[@a-text="Confirm"]    timeout=10
    Run Keyword and Ignore Error  Click Element    locator=//ui-button[@a-text="Confirm"]
    Run Keyword and Ignore Error  Wait Until Keyword Succeeds  20s  5s  Click Element    locator=//ui-button[@a-text="Close"]
#    Run Keyword and Ignore Error  Click Element    locator=//ui-button[@a-text="Close"]

WEBEM Go To Diagnostic
    Wait Until Keyword Succeeds  30s  5s  Click Element
    ...    locator=//div[@aria-describedby="admin.navigationBar.diagnostic.TITLE"]

WEBEM Go To Diagnostic SFP Monitoring
    WEBEM Go To Diagnostic
    Click Element
    ...    locator=//span[contains(text(),'SFP Monitoring')]

WEBEM Go To Diagnostic Snapshot
    Wait Until Keyword Succeeds  30s  5s  Click Element
    ...    locator=//div[@aria-describedby="admin.navigationBar.diagnostic.TITLE"]
    Click Element
    ...    locator=//span[contains(text(),'Snapshot')]

WEBEM Go to Procedures IM Snapshot
    Click Element
    ...    locator=//div[@aria-describedby="admin.navigationBar.procedures.TITLE"]
    Click Element
    ...    locator=//span[contains(text(),'IM Snapshot')]



WEBEM Start Collect Snapshot
    ${button_name}=  Set Variable  Collect Snapshot
    Run Keyword If  ${LOG_TO_SONSOLE}  Log to console  -Will click button ${button_name}
    Click Button  ${button_name}
    Run Keyword If  ${LOG_TO_SONSOLE}  Log to console  +Clicked button ${button_name}

WEBEM Start IM Snapshot

    ${implicit_wait}=   Set Selenium Implicit Wait  5
    ${button_name}=   Set Variable  Execute
    Run Keyword If  ${LOG_TO_SONSOLE}  Log to console  -Will click button ${button_name}
    Click Button  locator=${button_name}
    Run Keyword If  ${LOG_TO_SONSOLE}  Log to console  +Clicked button ${button_name}
    [Teardown]  Set Selenium Implicit Wait  ${implicit_wait}

WEBEM Wait Until Page Contains
    [Arguments]  ${text}  ${timeout}=${WEBEM_IMPLICIT_TIMEOUT}
    Wait Until Page Contains  text=${text}  timeout=${timeout}

WEBEM Page Should Not Contain
    [Arguments]  ${text}  ${loglevel}=NONE
    Page Should Not Contain  text=${text}  loglevel=${loglevel}

WEBEM Page Should Not Contain Element
    [Arguments]  ${locator}  ${loglevel}=NONE
    Page Should Not Contain Element  locator=${locator}  loglevel=${loglevel}

WEBEM Page Should Not Contain Element of Class With Text
    [Arguments]  ${class}  ${text}  ${loglevel}=NONE
    Page Should Not Contain Element  xpath=//div[@class='${class}']//label[contains(text(), '${text}')]  loglevel=${loglevel}

WEBEM Page Should Contain
    [Arguments]  ${text}  ${loglevel}=NONE
    Page Should Contain  text=${text}  loglevel=${loglevel}

WEBEM Page Should Contain Element
    [Arguments]  ${locator}  ${loglevel}=NONE
    Page Should Contain Element  locator=${locator}  loglevel=${loglevel}

WEBEM Wait Until Page Contains Element of Class and Contains Text
    [Arguments]  ${class}  ${text}  ${timeout}=${WEBEM_IMPLICIT_TIMEOUT}
    Run Keyword If  ${LOG_TO_SONSOLE}  Log to console  -Looking in page for element "${text}"
    Wait Until Page Contains Element   xpath=//div[@class='${class}']//label[contains(text(), '${text}')]  timeout=${timeout}
    Run Keyword If  ${LOG_TO_SONSOLE}  Log to console  +Page contains element "${text}"

WEBEM Wait Until Element Is Visible
    [Arguments]  ${locator}  ${timeout}=${WEBEM_IMPLICIT_TIMEOUT}
    Wait Until Element Is Visible  locator=${locator}  timeout=${timeout}

WEBEM Wait Until Element Is Visible and Contains Text
    [Arguments]  ${text}  ${timeout}=${WEBEM_IMPLICIT_TIMEOUT}
    Wait Until Element Is Visible  locator=//span[contains(text(),'${text}')]  timeout=${timeout}

WEBEM Wait Until Element Is Enabled
    [Arguments]  ${locator}  ${timeout}=${WEBEM_IMPLICIT_TIMEOUT}
    Wait Until Element Is Enabled  locator=${locator}  timeout=${timeout}

WEBEM Capture Page Screenshot
    Capture Page Screenshot
